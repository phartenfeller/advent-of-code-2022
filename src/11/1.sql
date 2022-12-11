set serveroutput on

create table aoc_monkeys (
  id number primary key,
  starting_items varchar2(4000),
  op varchar2(200),
  test_number number(*,0),
  throw_true_monkey number(*,0),
  throw_false_monkey number(*,0)
) inmemory;

create table aoc_monkey_inspections (
  id number primary key,
  inspections number(*,0)
) inmemory;

declare
  l_monkey_row aoc_monkeys%rowtype;
begin
  for mo in (
    select rownum as monkey_no, column_value as line
        from table ( select apex_string.split(input, apex_application.LF || apex_application.LF) from aoc_input where year = 2022 and day = 11 )
  )
  loop 
    --dbms_output.put_line(mo.monkey_no || ' ' || mo.line);
    l_monkey_row.id := mo.monkey_no - 1;

    for rec in (
      select rownum as line_no, column_value as line
        from table ( select apex_string.split(mo.line) from dual )
    )
    loop 
      case rec.line_no
        when 2 then
          l_monkey_row.starting_items := regexp_substr(rec.line, 'Starting items: (.*)', 1, 1, null, 1);
        when 3 then
          l_monkey_row.op := regexp_substr(rec.line, 'Operation: new = (.*)', 1, 1, null, 1);
        when 4 then
          l_monkey_row.test_number := regexp_substr(rec.line, 'Test: divisible by (\d+)', 1, 1, null, 1);
        when 5 then
          l_monkey_row.throw_true_monkey := regexp_substr(rec.line, 'If true: throw to monkey (\d+)', 1, 1, null, 1);
        when 6 then
          l_monkey_row.throw_false_monkey := regexp_substr(rec.line, 'If false: throw to monkey (\d+)', 1, 1, null, 1);
        else
          null;
      end case;
    end loop;

    insert into aoc_monkeys values l_monkey_row;

  end loop;
end;
/

select * from aoc_monkeys;

declare
  type t_monkey_items_map is table of apex_t_number index by pls_integer;
  l_monkey_items_map t_monkey_items_map;

  type t_monkey_inspections is table of number index by pls_integer;
  l_monkey_inspections t_monkey_inspections := t_monkey_inspections();

  l_curr_worry pls_integer;
  l_new_worry  pls_integer;
  l_monkey_row aoc_monkeys%rowtype;
  l_sql varchar2(4000);

  l_tmp_array apex_t_number;
begin
  for rec in (
    select id, starting_items
      from aoc_monkeys
  )
  loop 
    l_monkey_items_map(rec.id) := apex_string.split_numbers(rec.starting_items, ', ');
    dbms_output.put_line(rec.id || ' ' || apex_string.join(l_monkey_items_map(rec.id), ':'));
    l_monkey_inspections(rec.id) := 0;
  end loop;

  -- loop through all rounds
  for r in 1..20
  loop

    dbms_output.put_line('===== Round ' || r);
  
    -- loop through all monkeys
    for m in l_monkey_items_map.first .. l_monkey_items_map.last
    loop
      dbms_output.put_line('  ===== Monkey ' || m);

      select *
        into l_monkey_row
        from aoc_monkeys
        where id = m;

      l_sql := 'select ' || replace(l_monkey_row.op, 'old', ':1') ||' into :l_new_worry from dual';
      dbms_output.put_line('  ' || l_sql);

      dbms_output.put_line('  Items: ' || apex_string.join(l_monkey_items_map(m), ':'));

      -- loop through items of monkey
      for i in 1 .. l_monkey_items_map(m).count
      loop
        l_curr_worry := l_monkey_items_map(m)(i);
        l_monkey_inspections(m) := l_monkey_inspections(m) + 1;
        dbms_output.put_line('    == Start worry: ' || l_curr_worry);

        -- when 2 parameters are used, use the same value twice
        if regexp_count(l_sql, ':1') = 2 then
          execute immediate l_sql into l_new_worry using l_curr_worry, l_curr_worry;
        else
          execute immediate l_sql into l_new_worry using l_curr_worry;
        end if;
        dbms_output.put_line('    New worry: ' || l_new_worry);

        l_curr_worry := floor(l_new_worry / 3);
        dbms_output.put_line('    New worry2: ' || l_curr_worry || ' (divided by ' || l_monkey_row.test_number || ')');

        if mod(l_curr_worry, l_monkey_row.test_number) = 0 then
          dbms_output.put_line('    Throw to monkey ' || l_monkey_row.throw_true_monkey);
          l_tmp_array := l_monkey_items_map(l_monkey_row.throw_true_monkey);
          apex_string.push(l_tmp_array, l_curr_worry );
          l_monkey_items_map(l_monkey_row.throw_true_monkey) := l_tmp_array;
          --dbms_output.put_line('    New items: ' || apex_string.join(l_tmp_array, ':'));
        else
          dbms_output.put_line('    Throw to monkey ' || l_monkey_row.throw_false_monkey);
          l_tmp_array := l_monkey_items_map(l_monkey_row.throw_false_monkey);
          apex_string.push(l_tmp_array, l_curr_worry );
          l_monkey_items_map(l_monkey_row.throw_false_monkey) := l_tmp_array;
          --dbms_output.put_line('    New items: ' || apex_string.join(l_tmp_array, ':'));
        end if;

      end loop;
    
      -- reset items of monkey
      l_monkey_items_map(m) := apex_t_number();

    end loop;
  
  end loop;

  for i in l_monkey_inspections.first .. l_monkey_inspections.last
  loop
    insert into aoc_monkey_inspections values (i, l_monkey_inspections(i));
  end loop;

end;
/

select id, inspections, row_number() over (order by inspections desc) as i_rank
  from aoc_monkey_inspections;

with rank_data as (
  select id, inspections, row_number() over (order by inspections desc) as i_rank
  from aoc_monkey_inspections
)
select (select inspections from rank_data where i_rank = 1) * (select inspections from rank_data where i_rank = 2) as result
  from dual
;

drop table aoc_monkeys;
drop table aoc_monkey_inspections;
