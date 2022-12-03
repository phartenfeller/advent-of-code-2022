/*
create table aoc_input (
  year number(4,0)
, day number(2,0)
, input clob
, sample_input clob
, constraint aoc_input_pk primary key (year, day)
);
*/

/* Get package here: https://gist.github.com/TysonJouglet/fefffe3ee4e874aeab2e42b2b1649f28 */
/* Beware: needs ACL */

declare
  l_year  aoc_input.year%type   := 2022;
  l_day   aoc_input.day%type    := 3;
  l_input aoc_input.input%type;

begin
  l_input := aoc.get_input(p_year => 2022, p_day => 3);

  insert into aoc_input (year, day, input)
  values (l_year, l_day, l_input);

  commit;
end;
/

/* Or manually 

declare
  l_year         aoc_input.year%type   := 2022;
  l_day          aoc_input.day%type    := 3;
  l_input        aoc_input.input%type;
  l_sample_input aoc_input.input%type;
begin
  l_sample_input := q'!vJrwpWtwJgWrhcsFMMfFFhFp
...
CrZsJsPPZsGzwwsLwLmpwMDw!';

  l_input := q'!jVTBgVbgJQVrTLRRsLvRzWcZvnDs
...
jRRwCqwCZhlhZRpSZpjSqWwqmDMQdMmHPQQMHGdlHdTldNGd!';

  insert into aoc_input (year, day, input, sample_input)
  values (l_year, l_day, l_input, l_sample_input);

  commit;
end;
/


*/
