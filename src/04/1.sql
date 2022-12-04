prompt results
with lines as (  
  select rownum as line_no, column_value as line
                 -- split by newline
    from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 4 )
), bounds as (
  select line_no
      , line
      , to_number(regexp_substr(line, '([0-9]+)-[0-9]+,[0-9]+-[0-9]+', 1, 1, null, 1)) as lower_1
      , to_number(regexp_substr(line, '[0-9]+-([0-9]+),[0-9]+-[0-9]+', 1, 1, null, 1)) as upper_1
      , to_number(regexp_substr(line, '[0-9]+-[0-9]+,([0-9]+)-[0-9]+', 1, 1, null, 1)) as lower_2
      , to_number(regexp_substr(line, '[0-9]+-[0-9]+,[0-9]+-([0-9]+)', 1, 1, null, 1)) as upper_2
    from lines
)
select *
  from bounds
 where (lower_1 <= lower_2 and upper_1 >= upper_2)
    or (lower_2 <= lower_1 and upper_2 >= upper_1)
;

prompt only count
with lines as (  
  select rownum as line_no, column_value as line
                 -- split by newline
    from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 4 )
), bounds as (
  select line_no
      , line
      , to_number(regexp_substr(line, '([0-9]+)-[0-9]+,[0-9]+-[0-9]+', 1, 1, null, 1)) as lower_1
      , to_number(regexp_substr(line, '[0-9]+-([0-9]+),[0-9]+-[0-9]+', 1, 1, null, 1)) as upper_1
      , to_number(regexp_substr(line, '[0-9]+-[0-9]+,([0-9]+)-[0-9]+', 1, 1, null, 1)) as lower_2
      , to_number(regexp_substr(line, '[0-9]+-[0-9]+,[0-9]+-([0-9]+)', 1, 1, null, 1)) as upper_2
    from lines
)
select count(*)
  from bounds
 where (lower_1 <= lower_2 and upper_1 >= upper_2)
    or (lower_2 <= lower_1 and upper_2 >= upper_1)
;
