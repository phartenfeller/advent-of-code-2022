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
), overlap_data as (
  select line_no
      , line
      , lower_1
      , upper_1
      , lower_2
      , upper_2
      , upper_1 - lower_1 as range_1
      , upper_2 - lower_2 as range_2
      , case when lower_1 < lower_2 then 1 else 0 end as one_lower
      , case when lower_2 <= lower_1 and upper_2 >= upper_1 then 1 else 0 end as one_in_two
    from bounds
         -- negative phrasing makes more sense to my head...
         -- if lower of one is > than upper of other 
         --   or upper < lower of other
         -- they can't overlap
   where (not lower_1 > upper_2 and not lower_2 > upper_1)
      or (not lower_2 > upper_1 and not lower_1 > upper_2)
)
select * from overlap_data
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
), overlap_data as (
  select line_no
      , line
      , lower_1
      , upper_1
      , lower_2
      , upper_2
      , upper_1 - lower_1 as range_1
      , upper_2 - lower_2 as range_2
      , case when lower_1 < lower_2 then 1 else 0 end as one_lower
      , case when lower_2 <= lower_1 and upper_2 >= upper_1 then 1 else 0 end as one_in_two
    from bounds
         -- negative phrasing makes more sense to my head...
         -- if lower of one is > than upper of other 
         --   or upper < lower of other
         -- they can't overlap
   where (not lower_1 > upper_2 and not lower_2 > upper_1)
      or (not lower_2 > upper_1 and not lower_1 > upper_2)
)
select count(*) from overlap_data;
