-- COMP3311 19T3 Assignment 2
--
-- check.sql ... checking functions
--
-- Written by: John Shepherd, September 2012
-- Updated by: Hayden Smith, October 2019
--

--
-- Helper functions
--

create or replace function
	ass2_table_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='r';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	ass2_view_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	ass2_function_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=tname;
	return (_check > 0);
end;
$$ language plpgsql;

-- ass2_check_result:
-- * determines appropriate message, based on count of
--   excess and missing tuples in user output vs expected output

create or replace function
	ass2_check_result(nexcess integer, nmissing integer) returns text
as $$
begin
	if (nexcess = 0 and nmissing = 0) then
		return 'correct';
	elsif (nexcess > 0 and nmissing = 0) then
		return 'too many result tuples';
	elsif (nexcess = 0 and nmissing > 0) then
		return 'missing result tuples';
	elsif (nexcess > 0 and nmissing > 0) then
		return 'incorrect result tuples';
	end if;
end;
$$ language plpgsql;

-- ass2_check:
-- * compares output of user view/function against expected output
-- * returns string (text message) containing analysis of results

create or replace function
	ass2_check(_type text, _name text, _res text, _query text) returns text
as $$
declare
	nexcess integer;
	nmissing integer;
	excessQ text;
	missingQ text;
begin
	if (_type = 'view' and not ass2_view_exists(_name)) then
		return 'No '||_name||' view; did it load correctly?';
	elsif (_type = 'function' and not ass2_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (not ass2_table_exists(_res)) then
		return _res||': No expected results!';
	else
		excessQ := 'select count(*) '||
			   'from (('||_query||') except '||
			   '(select * from '||_res||')) as X';
		-- raise notice 'Q: %',excessQ;
		execute excessQ into nexcess;
		missingQ := 'select count(*) '||
			    'from ((select * from '||_res||') '||
			    'except ('||_query||')) as X';
		-- raise notice 'Q: %',missingQ;
		execute missingQ into nmissing;
		return ass2_check_result(nexcess,nmissing);
	end if;
	return '???';
end;
$$ language plpgsql;

-- ass2_rescheck:
-- * compares output of user function against expected result
-- * returns string (text message) containing analysis of results

create or replace function
	ass2_rescheck(_type text, _name text, _res text, _query text) returns text
as $$
declare
	_sql text;
	_chk boolean;
begin
	if (_type = 'function' and not ass2_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (_res is null) then
		_sql := 'select ('||_query||') is null';
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	else
		_sql := 'select ('||_query||') = '||quote_literal(_res);
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	end if;
	if (_chk) then
		return 'correct';
	else
		return 'incorrect result';
	end if;
end;
$$ language plpgsql;

-- check_all:
-- * run all of the checks and return a table of results

drop type if exists testingresult cascade;
create type testingresult as (test text, result text);

create or replace function
	check_all() returns setof testingresult
as $$
declare
	i int;
	testQ text;
	result text;
	out testingresult;
	tests text[] := array[
				'q1', 'q2', 'q3', 'q4', 'q5', 'q6', 'q7',
				'q8', 'q9', 'q10a', 'q10b', 'q10c', 'q10d', 'q10e',
				'q10f'
				];
begin
	for i in array_lower(tests,1) .. array_upper(tests,1)
	loop
		testQ := 'select check_'||tests[i]||'()';
		execute testQ into result;
		out := (tests[i],result);
		return next out;
	end loop;
	return;
end;
$$ language plpgsql;


--
-- Check functions for specific test-cases in Assignment 2
--

create or replace function check_q1() returns text
as $chk$
select ass2_check('view','q1','q1_expected',
                   $$select * from q1$$)
$chk$ language sql;

create or replace function check_q2() returns text
as $chk$
select ass2_check('view','q2','q2_expected',
                   $$select * from q2$$)
$chk$ language sql;

create or replace function check_q3() returns text
as $chk$
select ass2_check('view','q3','q3_expected',
                   $$select * from q3$$)
$chk$ language sql;

create or replace function check_q4() returns text
as $chk$
select ass2_check('view','q4','q4_expected',
                   $$select * from q4$$)
$chk$ language sql;

create or replace function check_q5() returns text
as $chk$
select ass2_check('view','q5','q5_expected',
                   $$select * from q5$$)
$chk$ language sql;

create or replace function check_q6() returns text
as $chk$
select ass2_check('view','q6','q6_expected',
                   $$select * from q6$$)
$chk$ language sql;

create or replace function check_q7() returns text
as $chk$
select ass2_check('view','q7','q7_expected',
                   $$select * from q7$$)
$chk$ language sql;

create or replace function check_q8() returns text
as $chk$
select ass2_check('view','q8','q8_expected',
                   $$select * from q8$$)
$chk$ language sql;

create or replace function check_q9() returns text
as $chk$
select ass2_check('view','q9','q9_expected',
                   $$select * from q9$$)
$chk$ language sql;

create or replace function check_q10a() returns text
as $chk$
select ass2_check('function','q10','q10a_expected',
                   $$select * from q10('wwe')$$)
$chk$ language sql;

create or replace function check_q10b() returns text
as $chk$
select ass2_check('function','q10','q10b_expected',
                   $$select * from q10('bill')$$)
$chk$ language sql;

create or replace function check_q10c() returns text
as $chk$
select ass2_check('function','q10','q10c_expected',
                   $$select * from q10('2016')$$)
$chk$ language sql;

create or replace function check_q10d() returns text
as $chk$
select ass2_check('function','q10','q10d_expected',
                   $$select * from q10('death')$$)
$chk$ language sql;

create or replace function check_q10e() returns text
as $chk$
select ass2_check('function','q10','q10e_expected',
                   $$select * from q10('1.3')$$)
$chk$ language sql;

create or replace function check_q10f() returns text
as $chk$
select ass2_check('function','q10','q10f_expected',
                   $$select * from q10('xyz')$$)
$chk$ language sql;

--
-- Tables of expected results for test cases
--

drop table if exists q1_expected;
create table q1_expected (
    title text
);

drop table if exists q2_expected;
create table q2_expected (
    format text,
    ntitles integer
);

drop table if exists q3_expected;
create table q3_expected (
    title text,
    rating float,
    nvotes integer
);

drop table if exists q4_expected;
create table q4_expected (
    title text,
    nepisodes integer
);

drop table if exists q5_expected;
create table q5_expected (
    title text,
    nlanguages integer
);

drop table if exists q6_expected;
create table q6_expected (
    name text
);

drop table if exists q7_expected;
create table q7_expected (
    title text,
    genres text
);

drop table if exists q8_expected;
create table q8_expected (
    name text
);

drop table if exists q9_expected;
create table q9_expected (
    name text,
    age integer
);

drop table if exists q10a_expected;
create table q10a_expected (
    q10 text
);

drop table if exists q10b_expected;
create table q10b_expected (
    q10 text
);

drop table if exists q10c_expected;
create table q10c_expected (
    q10 text
);

drop table if exists q10d_expected;
create table q10d_expected (
    q10 text
);

drop table if exists q10e_expected;
create table q10e_expected (
    q10 text
);

drop table if exists q10f_expected;
create table q10f_expected (
    q10 text
);

--
-- Resultant data
--

COPY q1_expected (title) FROM stdin;
100
1998: The Deadliest Year For Children In American History
An Infants Journey: Reggio Emilia Approach
A Time to Stir
Bullfighting Memories
CzechMate: In Search of Jirí Menzel
Dead Souls
Early Women Filmmakers
Europa: The Last Battle
Fan
h36:
La flor
Make Me Fly
Next Stop
Qw
Raoul Wallenberg Tragic Hero or Agent 103?
Report
Sdsdsdsdsdsds
Silence not silence, red not red, live not live
The Freshman Experience
The Innocence
The Spectacular Spider-Man Trilogy (Responsibility, Repute and Requiem)
Wholy
Who Was Hitler
Women Make Film: A New Road Movie Through Cinema
\.


COPY q2_expected (format, ntitles) FROM stdin;
movie	52404
short	116449
tvEpisode	40092
tvMiniSeries	6452
tvMovie	8713
tvSeries	1561
tvShort	884
tvSpecial	2577
video	27542
videoGame	2653
\.

COPY q3_expected (title, rating, nvotes) FROM stdin;
Fan	9.6	1008
Truth and Justice	9.3	1337
Aloko Udapadi	9.2	6529
Ardaas Karaan	9.2	1269
Dominion	9.2	1303
Ekvtime: Man of God	9.2	2620
Human Capital	9.2	1225
Mosul	9.2	2600
Peranbu	9.2	10452
Care of Kancharapalem	9.1	2624
\.

COPY q4_expected (title, nepisodes) FROM stdin;
H.A.N.D	5
Instagram Famous	12
That's My Chair, That Is	2
The Little Housewives of Posh Town	1
\.

COPY q5_expected (title, nlanguages) FROM stdin;
A Wrinkle in Time	22
\.

COPY q6_expected (name) FROM stdin;
Mark Chavarria
\.

COPY q7_expected (title, genres) FROM stdin;
A Room Full of Nothing	comedy,drama,fantasy,romance
Zombie with a Shotgun	action,comedy,horror,romance
\.

COPY q8_expected (name) FROM stdin;
Aleksandr Kuznetsov
Alexander Kulikov
Andrew Gause
Bill Bushwick
Chase Craig
Christophe Otzenberger
Graham Fletcher-Cook
Jeff Adachi
Jonathan Crombie
Larry Flash Jenkins
Rob Stewart
Steve Cadwell
Thomas Mikal Ford
Tommy Lewis
\.

COPY q9_expected (name, age) FROM stdin;
Egor Klinaev	18
\.

COPY q10a_expected (q10) FROM stdin;
WWE: Kurt Angle - The Essential Collection has 2 cast and crew
\.

COPY q10b_expected (q10) FROM stdin;
Avicii Feat. Billy Raffoul: You Be Love has 1 cast and crew
Burned by Bill Nye has 1 cast and crew
Bushwick Bill: Geto Boy has 2 cast and crew
\.

COPY q10c_expected (q10) FROM stdin;
2016: Famous Faces We\'ve Lost has 4 cast and crew
2016 the End has 1 cast and crew
International Wrestling Festival 2016 has 1 cast and crew
\.

COPY q10d_expected (q10) FROM stdin;
Deathly Bite has 1 cast and crew
Death of the Filmmaker has 1 cast and crew
Enticing, Sugary, Boundless or Songs and Dances about Death has 1 cast and crew
Jo Cox: Death of an MP has 1 cast and crew
LONG LIVE X: The Life and Death of XXXTENTACION has 1 cast and crew
The Death of Aimee Spencer has 1 cast and crew
The Sound of Death Note has 1 cast and crew
Updating Death has 3 cast and crew
\.

COPY q10e_expected (q10) FROM stdin;
Episode #1.3 has 1 cast and crew
Episode #1.3 has 1 cast and crew
Episode #1.3 has 1 cast and crew
Episode #1.3 has 1 cast and crew
Episode #1.3 has 1 cast and crew
Episode #1.3 has 1 cast and crew
Episode #1.3 has 1 cast and crew
Episode #1.3 has 1 cast and crew
Episode #1.3 has 1 cast and crew
Episode #1.3 has 1 cast and crew
\.

COPY q10f_expected (q10) FROM stdin;
No matching titles
\.
