set serveroutput on

create table aoc_filesystem (
  fs_path       varchar2(100 char) primary key
, fs_type       varchar2(1 char) not null
, fs_size       number(32,0)
, fs_level      number(32,0)
, fs_parent_dir varchar2(100 char)
) inmemory;
 
declare
  l_curr_path apex_t_varchar2;
  l_dest      varchar2(1000 char);
  l_path      aoc_filesystem.fs_path%type;
  l_size      aoc_filesystem.fs_size%type;
  l_level     aoc_filesystem.fs_level%type;
  l_parent    aoc_filesystem.fs_parent_dir%type;


  function get_curr_path 
    return varchar2 
  as
  begin
    return '/' || apex_string.join(l_curr_path, '/');
  end get_curr_path;

  function join_to_curr_path (
    pi_dest varchar2
  )
    return varchar2
  as
    l_tmp varchar2(1000 char);
  begin
    l_tmp := get_curr_path() || '/' || pi_dest;
    -- if we on root we added a second slash
    return replace(l_tmp, '//', '/');
  end join_to_curr_path;
begin
  for rec in (
    with lines as (  
      select rownum as line_no, column_value as line
        from table ( select apex_string.split(input) from aoc_input where year = 2022 and day = 7 )
    )
    select *
      from lines
  )
  loop
    if rec.line like '$ %' then

      if rec.line = '$ ls' then
        continue;
      elsif rec.line like '$ cd %' then
        l_dest := substr(rec.line, 6);

        if l_dest = '/' then
          l_curr_path := apex_t_varchar2();
        elsif l_dest = '..' then
          l_curr_path.trim(1);
        else
          apex_string.push(l_curr_path, l_dest);
        end if;

         dbms_output.put_line('cd ' || l_dest || ' | ' || get_curr_path());
      else
        dbms_output.put_line('Unknown command: ');
        dbms_output.put_line(rec.line_no || ' ' || rec.line);
      end if;
      
    else

      if rec.line like 'dir%' then
        l_dest := substr(rec.line, 5);
        l_path := join_to_curr_path(l_dest);
        l_level := l_curr_path.count + 1;
        l_parent := get_curr_path();

        insert into aoc_filesystem (fs_path, fs_type, fs_size, fs_level, fs_parent_dir)
        values (l_path, 'D', null, l_level, l_parent);
      else
        l_size := regexp_substr(rec.line, '([0-9]+) .*', 1, 1, null, 1 );
        l_dest := regexp_substr(rec.line, '[0-9]+ (.*)', 1, 1, null, 1 );
        l_path := join_to_curr_path(l_dest);
        l_level := l_curr_path.count + 1;
        l_parent := get_curr_path();

        insert into aoc_filesystem (fs_path, fs_type, fs_size, fs_level, fs_parent_dir)
        values (l_path, 'F', l_size, l_level, l_parent);
      end if;

    end if;
  end loop;

  insert into aoc_filesystem (fs_path, fs_type, fs_size, fs_level, fs_parent_dir)
  values ('/', 'D', null, 0, null);
end;
/

prompt resulting filesystem
select *
  from aoc_filesystem
 order by fs_path
;

prompt folder sizes
with contained_data as (
  select fs_size
       , fs_path
       , connect_by_root fs_path as contained_in
    from aoc_filesystem
  connect by prior fs_path = fs_parent_dir
), size_sums as (
select sum(fs_size) dir_size_sum, contained_in as dir_path
  from contained_data
 group by contained_in
)
select dir_path, dir_size_sum
  from size_sums
  join aoc_filesystem 
    on dir_path = fs_path
   and fs_type = 'D'
;

prompt How much we need to delete to have 30000000 free space

def size_needed
col needed_size for a30 new_value size_needed

with contained_data as (
  select fs_size
       , fs_path
       , connect_by_root fs_path as contained_in
    from aoc_filesystem
  connect by prior fs_path = fs_parent_dir
), size_sums as (
select sum(fs_size) dir_size_sum, contained_in as dir_path
  from contained_data
 group by contained_in
), only_folders as (
select dir_path, dir_size_sum
  from size_sums
  join aoc_filesystem 
    on dir_path = fs_path
   and fs_type = 'D'
)
select 30000000 - (70000000 - dir_size_sum)  as needed_size
  from only_folders
 where dir_path = '/'
;

prompt size sum of folders < &size_needed size  (result)
with contained_data as (
  select fs_size
       , fs_path
       , connect_by_root fs_path as contained_in
    from aoc_filesystem
  connect by prior fs_path = fs_parent_dir
), size_sums as (
select sum(fs_size) dir_size_sum, contained_in as dir_path
  from contained_data
 group by contained_in
), only_folders as (
select dir_path, dir_size_sum
  from size_sums
  join aoc_filesystem 
    on dir_path = fs_path
   and fs_type = 'D'
)
select dir_path, dir_size_sum
  from only_folders
 where dir_size_sum >= &size_needed
 order by dir_size_sum
 fetch first 1 rows only
;

drop table aoc_filesystem;
