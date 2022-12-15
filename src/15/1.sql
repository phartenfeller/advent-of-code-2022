set serveroutput on

create table aoc_coords (
  line_no number(38,0)
, s_x number(38,0)
, s_y number(38,0)
, b_x number(38,0)
, b_y number(38,0)
, distance number(38,0)
) inmemory;

insert into aoc_coords
with lines as  (
  select rownum as line_no, column_value as line
    from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 15 )
), parsed_coords as (
select line_no
     , line
     , regexp_substr(line, 'Sensor at x=(-?\d+)', 1, 1, null, 1) as s_x
     , regexp_substr(line, 'Sensor at x=-?\d+, y=(-?\d+)', 1, 1, null, 1) as s_y
     , regexp_substr(line, 'beacon is at x=(-?\d+)', 1, 1, null, 1) as b_x
     , regexp_substr(line, 'beacon is at x=-?\d+, y=(-?\d+)', 1, 1, null, 1) as b_y
  from lines
)
select line_no, s_x, s_y, b_x, b_y
     , abs(s_x - b_x) + abs(s_y - b_y) as distance
  from parsed_coords
;

select * from aoc_coords
 fetch first 5 rows only
;

declare
  c_searched_y constant number(38,0) :=  2000000; --10;

  l_min number(38,0);
  l_max number(38,0);
  l_max_distance number(38,0);
  l_diff number(38,0);

  type t_impossible_cords is table of number(38,0) index by pls_integer;
  l_impossible_cords t_impossible_cords := t_impossible_cords();
  l_obstruced_coords t_impossible_cords := t_impossible_cords();


  type t_coords is table of aoc_coords%rowtype index by pls_integer;
  l_coords t_coords;

  l_key pls_integer;
  l_count number(38,0);
begin
  select least(min(s_x), min(b_x)) into l_min from aoc_coords;
  select greatest(max(s_x), max(b_x)) into l_max from aoc_coords;
  select max(distance) into l_max_distance from aoc_coords;

  l_max := l_max + l_max_distance;
  l_min := l_min - l_max_distance;

  dbms_output.put_line('min: ' || l_min);
  dbms_output.put_line('max: ' || l_max);

  select * 
   bulk collect into l_coords
   from aoc_coords
   order by line_no
  ;

  for rec in (
    select s_x as key
      from aoc_coords
     where s_y = c_searched_y
    union
    select b_x as key
      from aoc_coords
     where b_y = c_searched_y
  )
  loop 
    l_obstruced_coords(rec.key) := 1;
  end loop;

  for i in l_min .. l_max 
  loop
    if l_impossible_cords.exists(i) then
      continue;
    end if;

    --dbms_output.put_line('i: ' || i);

    for c in l_coords.first .. l_coords.last
    loop 
      l_diff := abs(l_coords(c).s_x - i) + abs(l_coords(c).s_y - c_searched_y);
      if l_diff <= l_coords(c).distance then

        -- also directly mark next ones
        if l_coords(c).distance - l_diff > 0 then
          for j in i + 1 .. i + (l_coords(c).distance - l_diff)
          loop
            if not l_obstruced_coords.exists( j) then
              l_impossible_cords(j) := 1;
            end if;
          end loop;
        end if;

        -- check if there is a beacon or sensor at this position
        if not l_obstruced_coords.exists( i) then
          l_impossible_cords(i) := 1;
          exit;
        end if;
      end if;
    end loop;

  end loop;

  dbms_output.put_line('impossible: ' || l_impossible_cords.count);

  /*
  l_key := l_impossible_cords.first(); -- returns the first key

  while l_key is not null
  loop
      dbms_output.put_line( l_key );
      l_key := l_impossible_cords.next( l_key ); -- get the next key
  end loop;
  */

end;
/

drop table aoc_coords purge;
