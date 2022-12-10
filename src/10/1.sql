prompt Searched Cycle Times
with lines as (  
      select rownum as line_no, column_value as line
        from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 10 )
), statements as (
select line_no, substr(line, 1, 4) as op, to_number(substr(line, 6)) as add_x
  from lines
), cycle_times as (
select row_number() over (order by line_no, command_cycle) + 1 as cycle_no
     , case when command_cycle = 2 then add_x else null end as add_x
  from statements
 cross join lateral(
      select level command_cycle
        from dual
     connect by level <= case when op = 'noop' then 1 else 2 end
  ) char_rows
 union
 select 1, 1 from dual -- initial state -> x = 1
), signal_strength as (
select cycle_no
     , sum(add_x) over (order by cycle_no) as curr_x
     , sum(add_x) over (order by cycle_no) * cycle_no as signal_strength
  from cycle_times
)
select cycle_no, curr_x, signal_strength
  from signal_strength
 where cycle_no in (20, 60, 100, 140, 180, 220)
;

prompt result
with lines as (  
      select rownum as line_no, column_value as line
        from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 10 )
), statements as (
select line_no, substr(line, 1, 4) as op, to_number(substr(line, 6)) as add_x
  from lines
), cycle_times as (
select row_number() over (order by line_no, command_cycle) + 1 as cycle_no
     , case when command_cycle = 2 then add_x else null end as add_x
  from statements
 cross join lateral(
      select level command_cycle
        from dual
     connect by level <= case when op = 'noop' then 1 else 2 end
  ) char_rows
 union
 select 1, 1 from dual -- initial state -> x = 1
), signal_strength as (
select cycle_no
     , sum(add_x) over (order by cycle_no) as curr_x
     , sum(add_x) over (order by cycle_no) * cycle_no as signal_strength
  from cycle_times
)
select sum(signal_strength) as sum_signal_strength
  from signal_strength
 where cycle_no in (20, 60, 100, 140, 180, 220)
;
