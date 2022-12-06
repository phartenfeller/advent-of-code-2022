with input as (
  select input as input
    from aoc_input 
   where year = 2022 and day = 6
), char_sequence as (
select char_number
     , to_char( substr(input, char_number, 1) ) curr_char
  from input
 cross join lateral(
      select level char_number
        from dual
     connect by level <= length(input)
  ) char_rows
), lag_data as (
select char_number
     , curr_char
     , lag(curr_char, 1) over (order by char_number) prev_char
     , lag(curr_char, 2) over (order by char_number) prev_char_2
     , lag(curr_char, 3) over (order by char_number) prev_char_3
     ,    curr_char || lag(curr_char, 1) over (order by char_number)
       || lag(curr_char, 2) over (order by char_number) || lag(curr_char, 3) over (order by char_number) as char_seq
 from char_sequence
), unique_info as (
  select char_number
       , char_seq
   , case when regexp_count(char_seq, curr_char) = 1
           and regexp_count(char_seq, prev_char) = 1
           and regexp_count(char_seq, prev_char_2) = 1
           and regexp_count(char_seq, prev_char_3) = 1
        then 1
        else 0
      end as uniq_seq
    from lag_data
)
select * 
  from unique_info
 where uniq_seq = 1
 order by char_number
 fetch first row only
;
