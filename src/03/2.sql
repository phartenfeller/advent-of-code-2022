set serveroutput on

create table aoc_backpacks (
  id number primary key
, line  varchar2(1000)
, half1 varchar2(500)
, half2 varchar2(500)
) inmemory;

create table aoc_triplet_chars (
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

  l_longest_line aoc_backpacks.line%type;
  l_len   pls_integer;
  l_char  varchar2(1 char);

  l_idx_to_check1 pls_integer;
  l_found1        boolean;
  l_idx_to_check2 pls_integer;
  l_found2        boolean;
begin
  select *
    bulk collect into l_backpacks
    from aoc_backpacks
  ;

  for i in 1 .. l_backpacks.count loop
   -- only process every third line
    if mod(i, 3) != 0 then
      continue; 
    end if;

    dbms_output.put_line('Processing line ' || i);

    l_longest_line := l_backpacks(i).line;
    l_len := length(l_backpacks(i).line);
    l_idx_to_check1 := i - 1;
    l_idx_to_check2 := i - 2;

    -- check if line in other group is longer
    if length(l_backpacks(i - 1).line) > l_len then
      l_longest_line := l_backpacks(i - 1).line;
      l_len := length(l_backpacks(i - 1).line);
      l_idx_to_check1 := i;
      l_idx_to_check2 := i - 2;
    end if;

    if length(l_backpacks(i - 2).line) > l_len then
      l_longest_line := l_backpacks(i - 2).line;
      l_len := length(l_backpacks(i - 2).line);
      l_idx_to_check1 := i;
      l_idx_to_check2 := i - 1;
    end if;

    -- dbms_output.put_line('Str1: ' || l_longest_line);
    -- dbms_output.put_line('Str2: ' || l_backpacks(l_idx_to_check1).line || ' - ' || l_idx_to_check1);
    -- dbms_output.put_line('Str3: ' || l_backpacks(l_idx_to_check2).line || ' - ' || l_idx_to_check2);

    -- loop every char of the longest line
    for j in 1 .. l_len loop
      l_char := substr(l_longest_line, j, 1);

      -- count occurrences of char in two other lines
      l_found1 := regexp_count(l_backpacks(l_idx_to_check1).line, l_char) > 0;
      l_found2 := regexp_count(l_backpacks(l_idx_to_check2).line, l_char) > 0;

      if l_found1 and l_found2 then
        dbms_output.put_line( apex_string.format('(%0) Char "%1" found in every line.', i / 3, l_char) );

        insert into aoc_triplet_chars (line, dup_char) values (i, l_char);

        -- we only need to find the first match
        exit;

      end if;
    end loop;
  end loop;
end;
/

update aoc_triplet_chars
   set prio  = case when lower(dup_char) = dup_char then 
                 ASCII(dup_char) - 96  -- when lower char, subtract 96
               else 
                 ASCII(dup_char) - 38  -- when upper char, subtract 38
               end
;

prompt dup chars and their prios
select * 
  from aoc_triplet_chars
  fetch first 10 rows only;

prompt sum of prios
select sum(prio) as sum
  from aoc_triplet_chars
;


drop table aoc_backpacks purge;
drop table aoc_triplet_chars purge;
