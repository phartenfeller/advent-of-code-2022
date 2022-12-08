set serveroutput on

create table aoc_trees (
  x number
, y number
, height number
, constraint aoc_trees_pk primary key (x, y)
) inmemory;

insert into aoc_trees (x, y, height)
with lines as (  
      select rownum as line_no, column_value as line
        from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 8 )
)
select tree_x as x
     , line_no as y
     , to_number( substr(line, tree_x, 1) ) as height
  from lines
 cross join lateral(
      select level tree_x
        from dual
     connect by level <= length(line)
  ) char_rows
;

select * 
  from aoc_trees 
 order by x, y
fetch first 10 rows only;

prompt example query for 3,3
with neighbour_data as (
      select * from (
        select height, 'x' as direction
          from aoc_trees
        where x = 3
          and y = 3
        union
        select max(height) height, 'l' as direction
          from aoc_trees
        where x < 3
          and y = 3
        union
        select max(height) height, 'r' as direction
          from aoc_trees
        where x > 3
          and y = 3
        union
        select max(height) height, 'b' as direction
          from aoc_trees
        where x = 3
          and y < 3
        union
        select max(height) height, 't' as direction
          from aoc_trees
        where x = 3
          and y > 3
      )
      pivot (
        max(height)
        for direction in ( 'x' as x, 'l' as l, 'r' as r, 't' as t, 'b' as b)
      )
    )
    select case 
              when  x <= l
                and x <= r
                and x <= t
                and x <= b then 1
              else 0
            end as invisible
          , x, l, r, t, b 
      from neighbour_data
    ;


declare
  l_max_x pls_integer;
  l_max_y pls_integer;

  l_visible_count pls_integer;
  l_invisible     pls_integer;
begin
  select max(x) into l_max_x from aoc_trees;
  select max(y) into l_max_y from aoc_trees;

  select count(*)
    into l_visible_count
    from aoc_trees
   where x = 1 or y = 1
      or x = l_max_x or y = l_max_y
  ;

  dbms_output.put_line( 'Visible because outer ring: ' || l_visible_count );

  for rec in (
    select *
      from aoc_trees
    where x != 1 and y != 1
      and x != l_max_x and y != l_max_y
  )
  loop
      with neighbour_data as (
        select * from (
          select height, 'x' as direction
            from aoc_trees
          where x = rec.x
            and y = rec.y
          union
          select max(height) height, 'l' as direction
            from aoc_trees
          where x < rec.x
            and y = rec.y
          union
          select max(height) height, 'r' as direction
            from aoc_trees
          where x > rec.x
            and y = rec.y
          union
          select max(height) height, 'b' as direction
            from aoc_trees
          where x = rec.x
            and y < rec.y
          union
          select max(height) height, 't' as direction
            from aoc_trees
          where x = rec.x
            and y > rec.y
        )
        pivot (
          max(height)
          for direction in ( 'x' as x, 'l' as l, 'r' as r, 't' as t, 'b' as b)
        )
      )
    select case 
              when  x <= l
                and x <= r
                and x <= t
                and x <= b then 1
              else 0
            end as invisible
      into l_invisible
      from neighbour_data
    ;

    if l_invisible = 0 then 
      l_visible_count := l_visible_count + 1;
    else 
      dbms_output.put_line( 'Invisible: ' || rec.x || ', ' || rec.y );
    end if;
  end loop;

  dbms_output.put_line( 'Result visible: ' || l_visible_count );

end;
/
    

drop table aoc_trees;
