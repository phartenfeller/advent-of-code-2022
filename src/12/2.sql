set serveroutput on

create table aoc_hill_input (
  x number(*,0)
, y number(*,0)
, node_id varchar2(255)
, elevation number(*,0)
, visited number(1,0) default 0
, cost number(*,0) default 999999999
, prior_node varchar2(255)
, constraint aoc_hill_input_pk primary key (x, y)
, constraint aoc_hill_input_uq unique (node_id)
) inmemory;

create table aoc_hill (
  x number(*,0)
, y number(*,0)
, node_id varchar2(255)
, elevation number(*,0)
, visited number(1,0) default 0
, cost number(*,0) default 999999999
, prior_node varchar2(255)
, constraint aoc_hill_pk primary key (x, y)
, constraint aoc_hill_uq unique (node_id)
) inmemory;

create table aoc_results (
  entered date default sysdate
, res_num number
, res_node_id varchar2(255)
);

insert into aoc_hill_input
  (x, y, node_id, elevation)
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
     , line_no || ',' || char_no as node_id
     , case when letter = 'S' then 1
            when letter = 'E' then 27
            else ascii(letter) - 96
       end as elevation
  from letters
order by line_no, char_no;


declare
    l_curr_cost pls_integer := 0;
    l_min_cost_to_goal pls_integer := 999999999;

    l_row aoc_hill%rowtype;
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
  for rec in (
    with low_data as (
      select h.x
           , h.y
           , l.elevation as left_elevation
           , r.elevation as right_elevation
           , t.elevation as top_elevation
           , b.elevation as bottom_elevation
        from aoc_hill_input h
        left join aoc_hill_input l on h.x -1 = l.x and h.y = l.y
        left join aoc_hill_input r on h.x +1 = r.x and h.y = r.y
        left join aoc_hill_input t on h.x = t.x and h.y -1 = t.y
        left join aoc_hill_input b on h.x = b.x and h.y +1 = b.y
      where h.elevation = 1
    )
    select x, y
      from low_data
     where left_elevation = 2
        or right_elevation = 2
        or top_elevation = 2
        or bottom_elevation = 2
  )
  loop
    delete from aoc_hill where 1 = 1;
    insert into aoc_hill select * from aoc_hill_input;

    select count(*) into l_unvisited_count from aoc_results where res_node_id = rec.x || ',' || rec.y;

    if l_unvisited_count > 0 then
      dbms_output.put_line('Skipping ' || rec.x || ',' || rec.y);
      continue;
    end if;

    l_unvisited_count := 1;

    dbms_output.put_line('Starting at ' || rec.x || ',' || rec.y);

    begin
      select *
        into l_row
        from aoc_hill
      where x = rec.x
        and y = rec.y
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

    select cost into l_curr_cost from aoc_hill where elevation = 27;

    dbms_output.put_line('Cost to goal: ' || l_curr_cost);
    insert into aoc_results (res_num, res_node_id) values (l_min_cost_to_goal, rec.x || ',' || rec.y);
    commit;

    if l_curr_cost < l_min_cost_to_goal then
      l_min_cost_to_goal := l_curr_cost; 
    end if;
  
  end loop;

  dbms_output.put_line('min cost to goal: ' || l_min_cost_to_goal);
end;
/

select * from aoc_results;

drop table aoc_hill purge;
drop table aoc_hill_input purge;
drop table aoc_results purge;
