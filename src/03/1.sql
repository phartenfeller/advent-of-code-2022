set serveroutput on

create table aoc_backpacks (
  id number primary key
, line  varchar2(1000)
, half1 varchar2(500)
, half2 varchar2(500)
) inmemory;

create table aoc_duplicate_chars (
  line     number primary key
, dup_char varchar2(1 char)
, prio     number
) inmemory;



insert into aoc_backpacks
with data as (
  select rownum as line_no, column_value as line, length(column_value) as line_len
                 -- split by newline
    from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 3 )
)
select line_no as id
     , line
     , substr(line, 1, line_len/2) as half1
     , substr(line, line_len/2+1,  line_len/2) as half2
  from data
;

select * from aoc_backpacks fetch first 6 rows only;


declare
  type t_backpacks is table of aoc_backpacks%rowtype;
  l_backpacks t_backpacks;

  l_len   pls_integer;
  l_char  varchar2(1 char);
  l_count pls_integer;
begin
  select *
    bulk collect into l_backpacks
    from aoc_backpacks
  ;

  for i in 1 .. l_backpacks.count loop
    l_len := length(l_backpacks(i).half1);

    -- loop every char of half1
    for j in 1 .. l_len loop
      l_char := substr(l_backpacks(i).half1, j, 1);

      -- count occurrences of char in half2
      l_count := regexp_count(l_backpacks(i).half2, l_char);

      if l_count > 0 then
        dbms_output.put_line( apex_string.format('(%0) Char "%1" found in half.', i, l_char) );

        insert into aoc_duplicate_chars (line, dup_char) values (i, l_char);

        -- we only need to find the first match
        exit;

      end if;
    end loop;
  end loop;
end;
/

update aoc_duplicate_chars
   set prio  = case when lower(dup_char) = dup_char then 
                 ASCII(dup_char) - 96  -- when lower char, subtract 96
               else 
                 ASCII(dup_char) - 38  -- when upper char, subtract 38
               end
;

prompt dup chars and their prios
select * 
  from aoc_duplicate_chars
  fetch first 10 rows only;

prompt sum of prios
select sum(prio) as sum
  from aoc_duplicate_chars
;


drop table aoc_backpacks purge;
drop table aoc_duplicate_chars purge;
