set serveroutput on

create table aoc_hill (
  x number(*,0)
, y number(*,0)
, elevation number(*,0)
, visited number(1,0) default 0
, cost number(*,0) default 999999999
, prior_node varchar2(255)
, constraint aoc_hill_pk primary key (x, y)
) inmemory;

insert into aoc_hill
  (x, y, elevation)
with lines as (  
  select rownum as line_no, column_value as line
    from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 12 )
), letters as (
  select line_no
       , char_no
       , substr(line, char_no, 1) as letter
    from lines
   cross join lateral(
      select level char_no
        from dual
     connect by level <= length(line)
  ) char_rows
)
select line_no
     , char_no
     , case when letter = 'S' then 0
            when letter = 'E' then 27
            else ascii(letter) - 96
       end as elevation
  from letters
order by line_no, char_no;



declare
  l_row aoc_hill%rowtype;
  l_min_cost_to_goal pls_integer := 999999999;
  l_unvisited_count pls_integer := 1;

  procedure dijkstra_climb(
    p_x in number
  , p_y in number
  , p_cost in number
  , p_elevation in number
  )
  is
    l_next_elevation number(38,0);
    l_next_cost number(38,0);
  begin
    l_next_elevation := p_elevation + 1;
    l_next_cost := p_cost + 1;

    for rec in (
      select x, y, elevation, cost
        from aoc_hill
       where ( -- no diagonals
                 (x between p_x - 1 and p_x + 1 and p_y = y) 
              or (y between p_y - 1 and p_y + 1 and p_x = x)
             )
         and elevation <= l_next_elevation
         and visited = 0
    )
    loop
      if rec.cost > l_next_cost then
        update aoc_hill
           set cost = l_next_cost
             , prior_node = p_x || ',' || p_y
         where x = rec.x
           and y = rec.y;
      end if;
    end loop;

    update aoc_hill
       set visited = 1
     where x = p_x
       and y = p_y;

  end dijkstra_climb;

begin
  select *
    into l_row
    from aoc_hill
   where elevation = 0
  ;

  update aoc_hill
     set cost = 0
   where x = l_row.x
     and y = l_row.y;


  while l_unvisited_count > 0
  loop
    select *
      into l_row
      from aoc_hill
     where visited = 0
     order by cost
     fetch first 1 rows only;

    dijkstra_climb(l_row.x, l_row.y, l_row.cost, l_row.elevation);

    select count(*) into l_unvisited_count from aoc_hill where visited = 0;
  end loop;
end;
/

select * from aoc_hill where elevation = 27;

drop table aoc_hill;
