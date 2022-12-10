prompt Info if pixel is drawn

set heading off
set pagesize 0
set linesize 1000

column 0 Format a1
column 1 Format a1
column 2 Format a1
column 3 Format a1
column 4 Format a1
column 5 Format a1
column 6 Format a1
column 7 Format a1
column 8 Format a1
column 9 Format a1
column 10 Format a1
column 11 Format a1
column 12 Format a1
column 13 Format a1
column 14 Format a1
column 15 Format a1
column 16 Format a1
column 17 Format a1
column 18 Format a1
column 19 Format a1
column 20 Format a1
column 21 Format a1
column 22 Format a1
column 23 Format a1
column 24 Format a1
column 25 Format a1
column 26 Format a1
column 27 Format a1
column 28 Format a1
column 29 Format a1
column 30 Format a1
column 31 Format a1
column 32 Format a1
column 33 Format a1
column 34 Format a1
column 35 Format a1
column 36 Format a1
column 37 Format a1
column 38 Format a1
column 39 Format a1

prompt display
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
), sprite_info as (
select cycle_no
     , sum(add_x) over (order by cycle_no) as sprite_position
  from cycle_times
), sprite_data as (
select cycle_no
     , mod(cycle_no - 1, 40) as pixel_position
     , floor( (cycle_no - 1) / 40) as row_position
     , sprite_position
  from sprite_info
), pixel_data as (
select cycle_no
     , pixel_position
     , row_position
     , sprite_position
     , case when 
        pixel_position between sprite_position - 1 and sprite_position + 1 
          then 1 else 0 
       end as draw_pixel
  from sprite_data
), prep_data as (
select row_position
     , pixel_position
     , draw_pixel
  from pixel_data
 where cycle_no <= 240
)
  select row_position 
       , case when "0" = 1 then '#' else '.' end as "0"
       , case when "1" = 1 then '#' else '.' end as "1"
       , case when "2" = 1 then '#' else '.' end as "2"
       , case when "3" = 1 then '#' else '.' end as "3"
       , case when "4" = 1 then '#' else '.' end as "4"
       , case when "5" = 1 then '#' else '.' end as "5"
       , case when "6" = 1 then '#' else '.' end as "6"
       , case when "7" = 1 then '#' else '.' end as "7"
       , case when "8" = 1 then '#' else '.' end as "8"
       , case when "9" = 1 then '#' else '.' end as "9"
       , case when "10" = 1 then '#' else '.' end as "10"
       , case when "11" = 1 then '#' else '.' end as "11"
       , case when "12" = 1 then '#' else '.' end as "12"
       , case when "13" = 1 then '#' else '.' end as "13"
       , case when "14" = 1 then '#' else '.' end as "14"
       , case when "15" = 1 then '#' else '.' end as "15"
       , case when "16" = 1 then '#' else '.' end as "16"
       , case when "17" = 1 then '#' else '.' end as "17"
       , case when "18" = 1 then '#' else '.' end as "18"
       , case when "19" = 1 then '#' else '.' end as "19"
       , case when "20" = 1 then '#' else '.' end as "20"
       , case when "21" = 1 then '#' else '.' end as "21"
       , case when "22" = 1 then '#' else '.' end as "22"
       , case when "23" = 1 then '#' else '.' end as "23"
       , case when "24" = 1 then '#' else '.' end as "24"
       , case when "25" = 1 then '#' else '.' end as "25"
       , case when "26" = 1 then '#' else '.' end as "26"
       , case when "27" = 1 then '#' else '.' end as "27"
       , case when "28" = 1 then '#' else '.' end as "28"
       , case when "29" = 1 then '#' else '.' end as "29"
       , case when "30" = 1 then '#' else '.' end as "30"
       , case when "31" = 1 then '#' else '.' end as "31"
       , case when "32" = 1 then '#' else '.' end as "32"
       , case when "33" = 1 then '#' else '.' end as "33"
       , case when "34" = 1 then '#' else '.' end as "34"
       , case when "35" = 1 then '#' else '.' end as "35"
       , case when "36" = 1 then '#' else '.' end as "36"
       , case when "37" = 1 then '#' else '.' end as "37"
       , case when "38" = 1 then '#' else '.' end as "38"
       , case when "39" = 1 then '#' else '.' end as "39"
    from prep_data
  pivot (
    max(draw_pixel)
    for pixel_position in (
      0  as "0"
    , 1  as "1"
    , 2  as "2"
    , 3  as "3"
    , 4  as "4"
    , 5  as "5"
    , 6  as "6"
    , 7  as "7"
    , 8  as "8"
    , 9  as "9"
    , 10 as "10"
    , 11 as "11"
    , 12 as "12"
    , 13 as "13"
    , 14 as "14"
    , 15 as "15"
    , 16 as "16"
    , 17 as "17"
    , 18 as "18"
    , 19 as "19"
    , 20 as "20"
    , 21 as "21"
    , 22 as "22"
    , 23 as "23"
    , 24 as "24"
    , 25 as "25"
    , 26 as "26"
    , 27 as "27"
    , 28 as "28"
    , 29 as "29"
    , 30 as "30"
    , 31 as "31"
    , 32 as "32"
    , 33 as "33"
    , 34 as "34"
    , 35 as "35"
    , 36 as "36"
    , 37 as "37"
    , 38 as "38"
    , 39 as "39"
    )
  )
;
