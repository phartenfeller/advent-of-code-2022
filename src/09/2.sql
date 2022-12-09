set serveroutput on

declare
  e_err exception;

  type t_number_map is table of number index by varchar2(20);
  l_tail_positions t_number_map;

  type t_knot is record (
    x pls_integer,
    y pls_integer
  );

  type t_knot_map is table of t_knot index by pls_integer;
  l_knot_map t_knot_map;

  l_head t_knot := t_knot(0, 0);
  l_tmp t_knot;

  l_step_dir varchar2(1);
  l_steps number;

  l_last_moves varchar2(4000);

  procedure simulate_single_knot(
    p_head in t_knot
  , p_tail in out t_knot
  , p_step_dir in varchar2
  )
  as
    l_move_x pls_integer;
    l_move_y pls_integer;
  begin
      /*
      dbms_output.put_line(
        apex_string.format('Input: h: %0,%1 | t: %2,%3 | p_step_dir: %4', p_head.x, p_head.y, p_tail.x, p_tail.y, p_step_dir)
      );
      */

      if p_head.x = p_tail.x and p_head.y = p_tail.y then
        return;
      end if;

      l_move_x := p_tail.x;
      l_move_y := p_tail.y;

      if     p_head.y != p_tail.y 
         and p_head.x != p_tail.x  then
        -- move diagonally
        if p_head.x  > p_tail.x then
          l_move_x := p_tail.x + 1;
        else
          l_move_x := p_tail.x - 1;
        end if;
        
        if p_head.y  > p_tail.y then
          l_move_y := p_tail.y + 1;
        else
          l_move_y := p_tail.y - 1;
        end if;

      elsif p_tail.x < p_head.x then
        l_move_x := p_tail.x + 1;
      elsif p_tail.x > p_head.x then
        l_move_x := p_tail.x - 1;
      elsif p_tail.y < p_head.y  then
        l_move_y := p_tail.y + 1;
      elsif p_tail.y > p_head.y then
        l_move_y := p_tail.y - 1;
      end if;


      if not (l_move_x = p_head.x and l_move_y = p_head.y) then
        p_tail.y := l_move_y;
        p_tail.x := l_move_x;
      end if;


      if abs(p_head.x - p_tail.x) > 1 or abs(p_head.y - p_tail.y) > 1 then
        dbms_output.put_line(
          apex_string.format('Too far away: h: %0,%1 | t: %2,%3', p_head.x, p_head.y, p_tail.x, p_tail.y)
        );
        raise e_err;
      end if;
  end;
begin
  for i in 1..9
  loop
    l_knot_map(i) := t_knot(0, 0);
  end loop;

  for rec in (
    select rownum as line_no, column_value as line
      from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 9 )
  )
  loop 
    l_step_dir := substr(rec.line, 1, 1);
    l_steps := to_number(substr(rec.line, 3));

    l_last_moves := '';

    dbms_output.put_line('== ' || l_step_dir || ' ' || l_steps);

    for i in 1 .. l_steps
    loop 
      case l_step_dir
        when 'R' then l_head.x := l_head.x + 1;
        when 'L' then l_head.x := l_head.x - 1;
        when 'U' then l_head.y := l_head.y + 1;
        when 'D' then l_head.y := l_head.y - 1;
      end case;

      for j in 1..9
      loop
        if j = 1 then
          simulate_single_knot(l_head, l_knot_map(j), l_step_dir);
        else
          simulate_single_knot(l_knot_map(j-1), l_knot_map(j), l_step_dir);

          if j = 9 then
            l_tail_positions(l_knot_map(j).x || ',' || l_knot_map(j).y) := 1;
          end if;

        end if;
        
      end loop;

    end loop;

    dbms_output.put_line('head: ' || l_head.x || ',' || l_head.y || ' tail: ' || l_knot_map(9).x || ',' || l_knot_map(9).y);

    if l_step_dir = 'L' and l_steps = 8 then
      dbms_output.put_line('1: ' || l_knot_map(1).x || ',' || l_knot_map(1).y);
      dbms_output.put_line('2: ' || l_knot_map(2).x || ',' || l_knot_map(2).y);
      dbms_output.put_line('3: ' || l_knot_map(3).x || ',' || l_knot_map(3).y);
      dbms_output.put_line('4: ' || l_knot_map(4).x || ',' || l_knot_map(4).y);
      dbms_output.put_line('5: ' || l_knot_map(5).x || ',' || l_knot_map(5).y);
      dbms_output.put_line('6: ' || l_knot_map(6).x || ',' || l_knot_map(6).y);
      dbms_output.put_line('7: ' || l_knot_map(7).x || ',' || l_knot_map(7).y);
      dbms_output.put_line('8: ' || l_knot_map(8).x || ',' || l_knot_map(8).y);
    end if;
    

  end loop;

  dbms_output.put_line('tail_positions: ' || l_tail_positions.count);
exception
  when e_err then
    dbms_output.put_line('Error aborted!!' || l_last_moves);
end;
/
