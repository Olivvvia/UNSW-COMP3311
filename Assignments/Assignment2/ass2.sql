-- COMP3311 19T3 Assignment 2
-- Written by Yumeng Dong z5183940

-- Q1 Which movies are more than 6 hours long? 

create or replace view Q1(title)
as
select main_title as title from Titles where runtime > 360 and format='movie'
;


-- Q2 What different formats are there in Titles, and how many of each?

create or replace view Q2(format, ntitles)
as
select distinct format, count(id) from titles group by format;
;


-- Q3 What are the top 10 movies that received more than 1000 votes?

create or replace view Q3(title, rating, nvotes)
as
select main_title as title,rating,nvotes 
from titles 
where rating IS NOT NULL and nvotes>1000 and format='movie' order by rating desc,title limit 10
;


-- Q4 What are the top-rating TV series and how many episodes did each have?

create or replace view Q4(title, nepisodes)
as
select t.main_title as title, count(e.episode) as nepisodes 
from titles t,episodes e 
where t.rating in (select max(rating) from titles) and t.format LIKE '%Series' and t.id = e.parent_id 
group by t.main_title
;


-- Q5 Which movie was released in the most languages?
create or replace view released_movie as
select id, main_title from Titles
where format = 'movie' and start_year <= 2019;

create or replace view count_languages as
select r.main_title as title, count(distinct a.language) as nlanguages
from aliases a 
join released_movie r on r.id = a.title_id 
group by title
;

create or replace view Q5(title, nlanguages)
as
select * from count_languages 
where nlanguages in (select max(nlanguages) from count_languages)
;

-- Q6 Which actor has the highest average rating in movies that they're known for?
-- view 1 : find the rating for known movies
create or replace view Q6helper1 as
select name_id,title_id,main_title ,rating from known_for k 
join titles t on t.id = k.title_id where rating is not null and format = 'movie'
;
-- view 2: find the number of movie for each actors
create or replace view Q6helper2 as 
select name_id, count(title_id) as nmovie from Q6helper1
group by name_id
;

create or replace view Q6helper3  as
select n.name ,avg(k.rating) as avg_rating from Q6helper1 k
join names n on n.id = k.name_id 
where n.id in (select name_id from Q6helper2 where nmovie >= 2)
and n.id in (select name_id from worked_as where work_role = 'actor')
group by n.name order by avg_rating desc
;

create or replace view Q6(name)
as
select name from Q6helper3 
where avg_rating in (select max(avg_rating) from Q6helper3)
;



-- Q7 For each movie with more than 3 genres, show the movie title and a comma-separated list of the genres
create or replace view count_genres as 
select title_id,count(distinct genre) as ngenres from title_genres 
group by title_id;

create or replace view genres_more_than_3 as
select t.main_title as title, t.id from titles t
join count_genres c on c.title_id = t.id 
where c.ngenres > 3
;

create or replace view Q7 (title,genres) as
select g.title as title, string_agg(tg.genre,',' order by tg.genre) as genres from genres_more_than_3 g 
join title_genres tg on tg.title_id = g.id
group by g.title
;


-- Q8 Get the names of all people who had both actor and crew roles on the same movie

create or replace view actor_crew_roles as
select distinct a.title_id, a.name_id from actor_roles a
join crew_roles c on c.title_id = a.title_id and c.name_id = a.name_id
;

create or replace view actor_crew_in_movie as
select ac.title_id, ac.name_id from actor_crew_roles ac
join titles t on ac.title_id = t.id
where t.format = 'movie'
;

create or replace view Q8(name)
as select distinct n.name as name from names n
join actor_crew_in_movie a on a.name_id = n.id 
order by name
;


-- Q9 Who was the youngest person to have an acting role in a movie, and how old were they when the movie started?

create or replace view act_in_movie as
select distinct a.title_id, a.name_id from actor_roles a
join titles t on a.title_id = t.id 
where t.format = 'movie' 
;

create or replace view actor_info as
select a.name_id, a.title_id, n.name, n.birth_year from names n
join act_in_movie a on n.id = a.name_id
;

-- the age is at the time (year) the movie started shooting
create or replace view actor_age as
select ai.title_id, ai.name, (t.start_year - ai.birth_year) as age from actor_info ai
join titles t on t.id = ai.title_id
order by age
;

create or replace view Q9(name,age)
as
select name, age from actor_age
where age in (select min(age) from actor_Age)
;

-- Q10 Write a PLpgSQL function that, given part of a title, shows the full title and the total size of the cast and crew
create or replace view q10Helper1 as
select a.name_id, a.title_id from actor_roles a
union
select c.name_id, c.title_id from crew_roles c
union
select p.name_id, p.title_id from Principals p
;

create or replace function 
	count_acp(t_id integer) returns integer
as $$
declare 
	n integer;
begin 
	n := 0;
	select count(q.name_id) into n from q10Helper1 q
	where q.title_id = t_id group by q.title_id;
	return n;
end;
$$ language plpgsql;

create or replace function
	Q10(partial_title text) returns setof text
as $$
declare 
	full_title text;
	total integer;
	t_id integer;
	emp record;
	is_return boolean;
begin 
	is_return := false;
	for emp in 
		select * from titles t
		where t.main_title iLIKE ('%'||partial_title||'%')
	loop	
		total := count_acp(emp.id);
		full_title := emp.main_title;
		if total != 0 then
			is_return := true;
			return next full_title || ' has ' || total || ' cast and crew';
		end if;
	end loop;
	if is_return = false then
		return next 'No matching titles';
	end if;
end;

$$ language plpgsql;

