-- count how many students enrolled in each course
create or replace view nenroll as
select course_id, count(person_id)
from course_enrolments
group by course_id;

create or replace view q2helper1 as
SELECT s.id, regexp_matches(s.code, '([A-Z]+)')  as course,
regexp_matches(s.code, '([0-9$]+)') as digit
FROM subjects s
order by course
;

create or replace view q2helper2 as
SELECT digit, count(digit)
FROM q2helper1
group by digit
order by digit
;
create or replace view q3helper as
select distinct b.name, s.code
from buildings b
join rooms r on r.within = b.id
join meetings m on m.room_id = r.id
join classes cl on cl.id = m.class_id
join courses c on c.id = cl.course_id
join subjects s on c.subject_id = s.id
where c.term_id = 5196
order by b.name
;

create or replace view q4helper as
select t.name, s.code, count(ce.person_id)
from terms t
join courses c on c.term_id = t.id
join subjects s on c.subject_id = s.id
join course_enrolments ce on ce.course_id = c.id
group by t.name,s.code
order by t.name,s.code
;

-- count how many students enrolled in each class
create or replace view nclassenrol as
select class_id, count(person_id) as enrolled
from class_enrolments 
group by class_id
;

create or replace view q5helper1 as
select s.code, q.class_id, q.enrolled, cl.quota
from nclassenrol q
join classes cl on q.class_id = cl.id
join courses c on c.id = cl.course_id
join subjects s on s.id = c.subject_id
where q.enrolled < 0.5*cl.quota
order by code
;

create or replace view q5helper2 as
select q.code,ct.name, c.tag,(100*q.enrolled)/(q.quota) as percentage
from classes c
join q5helper1 q on q.class_id = c.id
join classtypes ct on ct.id = c.type_id
order by ct.name,c.tag, percentage
;
-- Question 7
create or replace view q7helper1 as
select cl.id as class_id, r.id as room_id, r.code as room,t.name as term, m.day, m.start_time, m.end_time , m.weeks_binary
from rooms r
left join meetings m on m.room_id = r.id
left join classes cl on cl.id = m.class_id
left join courses c on c.id = cl.course_id
left join terms t on t.id = c.term_id
where r.code like 'K-%' and weeks_binary != '00000000001'
order by room
;
-- count total number of rooms
create or replace view q7helper2 as
select r.id
from rooms r
where r.code like 'K-%'
;

-- Find two classes with same room+day+term
create or replace view SameRDT as
select q1.class_id, q1.room_id, q1.term,q1.day,q1.start_time,q1.end_time,q1.weeks_binary
from q7helper1 q1
join q7helper1 q2 on
q1.room_id = q2.room_id and q1.class_id != q2.class_id and q1.term = q2.term 
and q1.day = q2.day and q1.weeks_binary = q2.weeks_binary
;

-- Find two classes with same time or overlapped time
create or replace view Overlap as
select distinct s1.class_id, s1.room_id, s1.term, s1.start_time,s1.end_time,s1.weeks_binary 
from SameRDT s1
join SameRDT s2 on
s1.room_id = s2.room_id and s1.class_id != s2.class_id and s1.term = s2.term 
and s1.day = s2.day and s1.start_time = s2.start_time and s1.end_time = s2.end_time and s1.weeks_binary = s2.weeks_binary
;

-- Find two classes with overlapped time (not same)
create or replace view Overlap1 as
select distinct s1.class_id, s1.room_id, s1.term, s1.start_time,s1.end_time,s1.weeks_binary 
from SameRDT s1
join SameRDT s2 on
s1.room_id = s2.room_id and s1.class_id != s2.class_id and s1.term = s2.term 
and s1.day = s2.day and s1.start_time > s2.start_time and s1.end_time < s2.end_time and s1.weeks_binary = s2.weeks_binary
;



-- Question 8
create or replace view q8helper1 as
select s.code, cl.id, ct.name as type, m.day, m.start_time, m.end_time, (m.end_time - m.start_time)/100 as hours
from classes cl
left join meetings m on cl.id = m.class_id
left join courses c on c.id = cl.course_id
left join subjects s on c.subject_id = s.id
left join classtypes ct on ct.id = cl.type_id
where c.term_id = 5199 
order by day,start_time,end_time
;

create aggregate concat(text) (
    sfunc = append,
    stype = text,
    initcond = ''
);
create aggregate concat(text) (
    sfunc = append,
    stype = text,
    initcond = ""
);