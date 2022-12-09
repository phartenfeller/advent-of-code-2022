set serveroutput on

declare
  e_err exception;

  type t_number_map is table of number index by varchar2(20);
  l_tail_positions t_number_map;

  l_tail_x pls_integer := 0;
  l_tail_y pls_integer := 0;
  l_head_x pls_integer := 0;
  l_head_y pls_integer := 0;

  l_move_x pls_integer;
  l_move_y pls_integer;

  l_step_dir varchar2(1);
  l_steps number;

  l_last_moves varchar2(4000);
begin

  for rec in (
    select rownum as line_no, column_value as line
      from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 9 )
  )
  loop 
    l_step_dir := substr(rec.line, 1, 1);
    l_steps := to_number(substr(rec.line, 3));

    l_last_moves := '';

    --dbms_output.put_line('line_no: ' || rec.line_no || ' dir: ' || l_step_dir || ' steps: ' || l_steps);

    for i in 1 .. l_steps
    loop 
      case l_step_dir
        when 'R' then l_head_x := l_head_x + 1;
        when 'L' then l_head_x := l_head_x - 1;
        when 'U' then l_head_y := l_head_y + 1;
        when 'D' then l_head_y := l_head_y - 1;
      end case;

      if l_head_x = l_tail_x and l_head_y = l_tail_y then
        --dbms_output.put_line('head: ' || l_head_x || ',' || l_head_y || '  |  tail: ' || l_tail_x || ',' || l_tail_y);
        continue;
      end if;

      l_move_x := l_tail_x;
      l_move_y := l_tail_y;

      if     l_head_y != l_tail_y 
         and l_head_x != l_tail_x  then
        -- move diagonally
        if l_head_x  > l_tail_x then
          l_move_x := l_tail_x + 1;
        else
          l_move_x := l_tail_x - 1;
        end if;
        
        if l_head_y  > l_tail_y then
          l_move_y := l_tail_y + 1;
        else
          l_move_y := l_tail_y - 1;
        end if;

      elsif l_step_dir = 'R' and l_tail_x < l_head_x then
        l_move_x := l_tail_x + 1;
      elsif l_step_dir = 'L' and l_tail_x > l_head_x then
        l_move_x := l_tail_x - 1;
      elsif l_step_dir = 'U' and l_tail_y < l_head_y  then
        l_move_y := l_tail_y + 1;
      elsif l_step_dir = 'D' and l_tail_y > l_head_y then
        l_move_y := l_tail_y - 1;
      end if;


      if not (l_move_x = l_head_x and l_move_y = l_head_y) then
        l_tail_y := l_move_y;
        l_tail_x := l_move_x;
      end if;

      l_last_moves := l_last_moves || apex_string.format(', h: %0,%1 | t: %2,%3 ', l_head_x, l_head_y, l_tail_x, l_tail_y) ;

      if abs(l_head_x - l_tail_x) > 1 or abs(l_head_y - l_tail_y) > 1 then
        dbms_output.put_line(
          apex_string.format('Too far away: h: %0,%1 | t: %2,%3 | line_no: %4', l_head_x, l_head_y, l_tail_x, l_tail_y, rec.line_no)
        );
        raise e_err;
      end if;

      --dbms_output.put_line('head: ' || l_head_x || ',' || l_head_y || '  |  tail: ' || l_tail_x || ',' || l_tail_y);
      l_tail_positions(l_tail_x || ',' || l_tail_y) := 1;

    end loop;

  end loop;

  dbms_output.put_line('tail_positions: ' || l_tail_positions.count);
exception
  when e_err then
    dbms_output.put_line('Error aborted!!' || l_last_moves);
end;
/
