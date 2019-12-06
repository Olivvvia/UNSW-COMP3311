-- COMP3311 Prac Exercise
--
-- Written by: YOU

-- Q1: how many page accesses on March 2

... replace this line by auxiliary views (or delete it) ...

create view Q1 as
select count(page) from Accesses where acctime like '%-03-02%'
;


-- Q2: how many times was the MessageBoard search facility used?

... replace this line by auxiliary views (or delete it) ...

create or replace view Q2(nsearches) as
select count(*) from accesses where page like '%webcms%messageboard%' 
and params like '%state=search%'
;


-- Q3: on which Tuba lab machines were there incomplete sessions?

... replace this line by auxiliary views (or delete it) ...

create view Q3 as
select distinct h.hostname from sessions s
join hosts h on h.id = s.host
where s.complete = 'f' and h.hostname like '%tuba%'
order by h.hostname
;

-- Q4: min,avg,max bytes transferred in page accesses
create view Q4 as
select min(nbytes),round(avg(nbytes)),max(nbytes)
from accesses
;


-- Q5: number of sessions from CSE hosts

create or replace view Q5(nhosts) as
select count(distinct s.id), h.hostname
from hosts h
join sessions s on s.host = h.id
join accesses a on a.session = s.id
where h.hostname like '%cse.unsw.edu.au' and h.hostname is not null
;


-- Q6: number of sessions from non-CSE hosts

create or replace view Q6(nhosts) as
select count(distinct s.id), h.hostname
from hosts h
join sessions s on s.host = h.id
join accesses a on a.session = s.id
where h.hostname not like '%cse.unsw.edu.au' 
and h.hostname is not null
;


-- Q7: session id and number of accesses for the longest session?

create view Q7helper as 
select session, count(accTime) as ntime from accesses
group by session
;

create view Q7 as 
select * from q7helper
where ntime in (select max(ntime) from Q7helper)
;



-- Q8: frequency of page accesses

create view Q8 as
select page,count(*) as freq from accesses
group by page
;


-- Q9: frequency of module accesses

create or replace view Q9(module,freq) as
select 
;


-- Q10: "sessions" which have no page accesses

create view Q10 as
select s.id from sessions s
where s.id not in (select session from accesses)
;


-- Q11: hosts which are not the source of any sessions
drop view if exists q11;
create view Q11 as
select h.hostname from hosts h where 
h.id not in (select distinct s.host from sessions s
    join accesses a on a.session = s.id
) and h.hostname is not null
;
