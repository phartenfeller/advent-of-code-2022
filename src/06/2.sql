with input as (
  select input as input
    from aoc_input 
   where year = 2022 and day = 6
), 
-- get sequences of 14 characters
char_sequence as (
select char_number + 13 as char_number
     , to_char( substr(input, char_number, 14) ) char_sequence
  from input
 cross join lateral(
      select level char_number
        from dual
     connect by level <= length(input)
  ) char_rows
 where char_number <= length(input) - 13
), 
-- get each character in the sequence
single_chars as (
  select char_number 
       , i
       , substr(char_sequence, i, 1) as single_char
    from char_sequence
     cross join lateral(
      select level i
        from dual
     connect by level <= 14
  ) char_rows
)
-- count unique characters for each sequence
select char_number
     , count(distinct single_char) as distinct_chars
  from single_chars
  group by char_number
  having count(distinct single_char) = 14
  fetch first 1 rows only
;
