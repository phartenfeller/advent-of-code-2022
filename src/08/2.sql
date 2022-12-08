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

variable x number;
variable y number;
variable height number;

begin
  select x, y, height
    into :x, :y, :height
    from aoc_trees 
  where x = 3
    and y = 4
  ;
end;
/

prompt 3, 4 data:
select * from aoc_trees where x = :x and y = :y;

variable max_x number;
variable max_y number;

begin
  select max(x) into :max_x from aoc_trees;
  select max(y) into :max_y from aoc_trees;
end;
/

prompt example query for 3, 4
with neighbour_data as (
      select * from (
        -- get distance to next left tree that is higher or equal
        select * from (
          select :x - x as dist, 'l' as direction
            from aoc_trees
           where x < :x
             and y = :y
             and height >= :height
           order by x desc
           fetch first 1 rows only
        )
        union
         -- get distance to next right tree that is higher or equal
        select * from (
          select x - :x as dist, 'r' as direction
            from aoc_trees
          where x > :x
            and y = :y
            and height >= :height
          order by x
          fetch first 1 rows only
        )
        union
         -- get distance to next bottom tree that is higher or equal
        select * from (
          select :y - y as dist, 'b' as direction
            from aoc_trees
          where x = :x
            and y < :y
            and height >= :height
          order by y desc
          fetch first 1 rows only
        )
        union
         -- get distance to next top tree that is higher or equal
        select * from (
          select y - :y as dist, 't' as direction
            from aoc_trees
           where x = :x
             and y > :y
             and height >= :height
           order by y
           fetch first 1 rows only
        )
      )
      -- transform rows into columns
      pivot (
        max(dist)
        for direction in ('l' as l, 'r' as r, 't' as t, 'b' as b)
      )
), fill_nulls as (
    -- coalesce because when there is no higher in one direction
    -- we get null
    select coalesce(l, :x - 1) as l
         , coalesce(r, :max_x - :x) as r
         , coalesce(t, :max_y - :y) as t
         , coalesce(b, :y - 1) as b
      from neighbour_data
)
select l * r * t * b as score, l, r, t, b 
  from fill_nulls
;


declare
  l_max_x pls_integer;
  l_max_y pls_integer;

  l_highest_score  pls_integer := 0;
  l_curr_score     pls_integer;
begin
  select max(x) into l_max_x from aoc_trees;
  select max(y) into l_max_y from aoc_trees;

  for rec in (
    select *
      from aoc_trees
    where x != 1 and y != 1
      and x != l_max_x and y != l_max_y
  )
  loop
    with neighbour_data as (
          select * from (
            select * from (
              select rec.x - x as dist, 'l' as direction
                from aoc_trees
              where x < rec.x
                and y = rec.y
                and height >= rec.height
              order by x desc
              fetch first 1 rows only
            )
            union
            select * from (
              select x - rec.x as dist, 'r' as direction
                from aoc_trees
              where x > rec.x
                and y = rec.y
                and height >= rec.height
              order by x
              fetch first 1 rows only
            )
            union
            select * from (
              select rec.y - y as dist, 'b' as direction
                from aoc_trees
              where x = rec.x
                and y < rec.y
                and height >= rec.height
              order by y desc
              fetch first 1 rows only
            )
            union
            select * from (
              select y - rec.y as dist, 't' as direction
                from aoc_trees
              where x = rec.x
                and y > rec.y
                and height >= rec.height
              order by y
              fetch first 1 rows only
            )
          )
          pivot (
            max(dist)
            for direction in ('l' as l, 'r' as r, 't' as t, 'b' as b)
          )
    ), fill_nulls as (
        -- coalesce because when there is no higher in one direction
        -- we get null
        select coalesce(l, rec.x - 1) as l
            , coalesce(r, l_max_x - rec.x) as r
            , coalesce(t, l_max_y - rec.y) as t
            , coalesce(b, rec.y - 1) as b
          from neighbour_data
    )
    select l * r * t * b as score
      into l_curr_score
      from fill_nulls
    ;
    if l_curr_score > l_highest_score then 
      l_highest_score := l_curr_score;
      dbms_output.put_line( 'New high score: ' || rec.x || ', ' || rec.y || ' = ' || l_highest_score );
    end if;
  end loop;

  dbms_output.put_line( 'Result: ' || l_highest_score );

end;
/
    

drop table aoc_trees;
