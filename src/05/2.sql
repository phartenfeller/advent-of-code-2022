set serveroutput on

create table aoc_initial_blocks (
  line_no number
, stack_no number
, block varchar2(1 char)
, constraint aoc_initial_blocks_pk primary key (line_no, stack_no)
) inmemory;

create table aoc_moves (
  line_no number
, amount number
, from_stack number
, to_stack number
, constraint aoc_moves_pk primary key (line_no)
) inmemory;


insert into aoc_initial_blocks
  ( line_no, stack_no, block )
  with lines as (  
    select rownum as line_no, trim(replace( 
                replace(column_value, '    ', ' [-]')
              , '][', '] ['
          )) as line
      from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 5 )
  ), starting_grid as (
    select line_no, line
      from lines
    where line like '[%'
  )
  select distinct line_no
      , block_no
      , regexp_substr(line, '\[([A-Z]|-)\]', 1, block_no, null, 1) as block
    from starting_grid
    cross join lateral(
      select level block_no
        from dual
    connect by level <= regexp_count(line, ' ') + 1
    ) block_rows
  order by line_no
;

prompt parsed inital blocks:
select * from aoc_initial_blocks;

prompt parse moves
insert into aoc_moves
 with lines as (  
    select rownum as line_no, trim(replace( 
                replace(column_value, '    ', ' [-]')
              , '][', '] ['
          )) as line
      from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 5 )
  )
  select line_no
       , regexp_substr(line, 'move ([0-9]+) from [0-9]+ to [0-9]+', 1, 1, null, 1) as amount
       , regexp_substr(line, 'move [0-9]+ from ([0-9]+) to [0-9]+', 1, 1, null, 1) as from_stack
       , regexp_substr(line, 'move [0-9]+ from [0-9]+ to ([0-9]+)', 1, 1, null, 1) as to_stack
    from lines
   where line like 'move%'
;

prompt moves:
select * from aoc_moves fetch first 10 rows only;


declare
  type t_block_arr is table of varchar2(1 char) index by pls_integer;
  type t_stack_arr is table of t_block_arr index by pls_integer;
  l_stack_arr t_stack_arr;
  l_tmp_block_arr t_block_arr;

  l_stack_count pls_integer;

  l_tmp_from_index pls_integer;
  l_tmp_to_index pls_integer;
  l_tmp_block_to_move varchar2(1 char);

  l_result varchar2(255 char) := '';
begin
  select max(stack_no) into l_stack_count from aoc_initial_blocks;
  dbms_output.put_line('stack count: ' || l_stack_count);

  for i in 1 .. l_stack_count
  loop 
    select block
      bulk collect into l_stack_arr(i)
      from aoc_initial_blocks
     where stack_no = i
       and block != '-'
     order by line_no desc;

    dbms_output.put_line('stack ' || i || ' has ' || l_stack_arr(i).count || ' blocks');
  end loop;

  for rec in (
    select * from aoc_moves order by line_no
  )
  loop

    l_tmp_block_arr := t_block_arr();

    for i in 1 .. rec.amount
    loop 
    
      l_tmp_from_index := l_stack_arr(rec.from_stack).count;
      l_tmp_block_to_move := l_stack_arr(rec.from_stack)(l_tmp_from_index);
      l_tmp_block_arr(i) := l_tmp_block_to_move;
      l_stack_arr(rec.from_stack).delete(l_tmp_from_index);

    end loop;


    for i in reverse 1 .. rec.amount
    loop
      l_tmp_to_index := l_stack_arr(rec.to_stack).count + 1;
      l_stack_arr(rec.to_stack)(l_tmp_to_index) := l_tmp_block_arr(i);
      l_tmp_block_arr.delete(i);


      dbms_output.put_line( 
        apex_string.format(
          'moving %0 (%1) from %2 (now %3) to %4 (now %5) - loop %6 of %7'
          , coalesce(l_tmp_block_to_move, '-')
          , l_tmp_from_index
          , rec.from_stack
          , l_stack_arr(rec.from_stack).count
          , rec.to_stack
          , l_stack_arr(rec.to_stack).count
          , i
          , rec.amount
        )
      );
    end loop;
  
  end loop;

  for i in 1 .. l_stack_count
  loop
    dbms_output.put_line('stack ' || i || ' has ' || l_stack_arr(i).count || ' blocks. Last item => ' || l_stack_arr(i)(l_stack_arr(i).count));
    l_result := l_result || l_stack_arr(i)(l_stack_arr(i).count);
  end loop;

  dbms_output.put_line('result: ' || l_result);

end;
/


drop table aoc_initial_blocks;
drop table aoc_moves;
