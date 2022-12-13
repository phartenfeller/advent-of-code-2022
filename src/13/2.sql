set serveroutput on

declare
  l_lines apex_t_varchar2;
  l_res   varchar2(1 char);

  l_arr1 json_array_t;
  l_arr2 json_array_t;

  l_huge_arr json_array_t := json_array_t();
  l_arr_str varchar2(4000 char);

  l_idx1 pls_integer := 0;
  l_idx2 pls_integer := 0;

  l_action_cnt pls_integer := 0;

  function compare_arrays (
    pi_arr1 in json_array_t,
    pi_arr2 in json_array_t
  ) return varchar2
  as
    l_temp varchar2(1 char);
    l_new_arr1 json_array_t;
    l_new_arr2 json_array_t;

    l_size1 number(38,0);
    l_size2 number(38,0);
    l_size_min number(38,0);

    l_type1 varchar2(4000 char);
    l_type2 varchar2(4000 char);

    l_num1 number(38,0);
    l_num2 number(38,0);
  begin
    l_size1 := pi_arr1.get_size;
    l_size2 := pi_arr2.get_size;
    l_size_min := least(l_size1, l_size2);
    --dbms_output.put_line( apex_string.format('-- l_size1: %0, l_size2: %1, l_size_min: %2', l_size1, l_size2, l_size_min) );

    if l_size1 = 0 and l_size2 = 0 then
      --dbms_output.put_line( 'both empty' );
      return '=';
    elsif l_size2 = 0 then
      --dbms_output.put_line( 'Right side empty' );
      return '>';
    elsif l_size1 = 0 and l_size2 > 0 then
      --dbms_output.put_line( 'left side empty and right side not' );
      return '<';
    end if;

        /*
        dbms_output.put_line( 
        apex_string.format(
          'compare_arrays: %0  |||  %1'
        , pi_arr1.stringify
        , pi_arr2.stringify
        )
      );
      */


    for i in 0 .. l_size_min - 1
    loop
      l_type1 := pi_arr1.get_type(i);
      l_type2 := pi_arr2.get_type(i);
      --dbms_output.put_line( apex_string.format('-- l_type1: %0, l_type2: %1 (%2)', l_type1, l_type2, i) );

      if l_type1 = 'ARRAY' or l_type2 = 'ARRAY' then
        if l_type1 = 'SCALAR' then
          l_num1 := pi_arr1.get_number(i);
          l_new_arr1 := json_array_t('['||l_num1||']');
        else
          l_new_arr1 := treat(pi_arr1.get(i) as json_array_t);
        end if;

        if l_type2 = 'SCALAR' then
          l_num2 := pi_arr2.get_number(i);
          l_new_arr2 := json_array_t('['||l_num2||']');
        else
          l_new_arr2 := treat(pi_arr2.get(i) as json_array_t);
        end if;

        l_temp := compare_arrays(l_new_arr1, l_new_arr2);
        if l_temp != '=' then
          return l_temp;
        end if;

      else
        l_num1 := pi_arr1.get_number(i);
        l_num2 := pi_arr2.get_number(i);

        if l_num1 > l_num2 then
          --dbms_output.put_line( apex_string.format('-- l_num1 > l_num2: %0, %1', l_num1, l_num2) );
          return '>';
        elsif l_num1 < l_num2 then
          --dbms_output.put_line( apex_string.format('-- l_num1 < l_num2: %0, %1', l_num1, l_num2) );
          return '<';
        end if;

      end if;

      if l_size2 < l_size1 and i+1 = l_size2 then
        --dbms_output.put_line( apex_string.format('-- l_size2 Ran out of items: %0, %1', l_size2, l_size1) );
        return '>';
      elsif l_size1 < l_size2 and i+1 = l_size1 then
        --dbms_output.put_line( apex_string.format('-- l_size1 Ran out of items: %0, %1', l_size1, l_size2) );
        return '<'; 
      end if;
    end loop;

    /*
    dbms_output.put_line(apex_string.format(
          '= %0  |||  %1'
        , pi_arr1.stringify
        , pi_arr2.stringify
        ));
        */
    return '=';
  
  end;
begin
  -- starter packets
  l_arr1 := json_array_t('[[2]]');
  l_arr2 := json_array_t('[[6]]');

  l_huge_arr.append(l_arr1);
  l_huge_arr.append(l_arr2);

  for rec in (
      select rownum as pair_no, column_value as line
        from table ( select apex_string.split(input, apex_application.LF || apex_application.LF) from aoc_input where year = 2022 and day = 13 )
  )
  loop 
    l_lines := apex_string.split(rec.line, apex_application.LF);

    l_arr1 := json_array_t(l_lines(1));
    l_arr2 := json_array_t(l_lines(2));

    l_res := compare_arrays(l_arr1, l_arr2);
    if l_res = '<' then
      l_huge_arr.append(l_arr1);
      l_huge_arr.append(l_arr2);
    else
      l_huge_arr.append(l_arr2);
      l_huge_arr.append(l_arr1);
    end if;

    dbms_output.put_line(rec.pair_no || ': ' || l_res);
  end loop;

  l_action_cnt := 1;
  while l_action_cnt > 0 
  loop 
    l_action_cnt := 0;

    for i in 0 .. l_huge_arr.get_size - 2
    loop
      l_arr1 := treat(l_huge_arr.get(i) as json_array_t);
      l_arr2 := treat(l_huge_arr.get(i+1) as json_array_t);

      l_res := compare_arrays(l_arr1, l_arr2);
      if l_res = '>' then
        -- switch positions
        l_huge_arr.put(i, l_arr2, true);
        l_huge_arr.put(i+1, l_arr1, true);
        l_action_cnt := l_action_cnt + 1;
      end if;
    end loop;

  end loop;

  for i in 0 .. l_huge_arr.get_size - 1
  loop 
    l_arr1 := treat(l_huge_arr.get(i) as json_array_t);
    l_arr_str := l_arr1.stringify;
    if l_arr_str = '[[2]]' then
      l_idx1 := i + 1;
      dbms_output.put_line('Packet 1: ' || l_idx1);
    elsif l_arr_str = '[[6]]' then
      l_idx2 := i + 1;
      dbms_output.put_line('Packet 6: ' || l_idx2);
    end if;
  end loop;

  dbms_output.put_line('Answer: ' || l_idx1 * l_idx2);
end;
/
