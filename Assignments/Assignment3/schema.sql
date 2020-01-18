-- COMP3311 19T3 Assignment 3 Database Schema

create table Terms (
	id          integer,
	name        char(4) not null unique,  -- e.g. '20T0'
	long_name   text not null unique,     -- e.g. 'Summer Term 2020'
	start_date  date not null,
	end_date    date not null,
	primary key (id)
);

insert into Terms values
 (5192, '19T0', 'Summer Term 2019', '2019-01-02', '2019-02-09'),
 (5193, '19T1', 'Term 1 2019', '2019-02-18', '2019-05-18'),
 (5196, '19T2', 'Term 2 2019', '2019-06-03', '2019-08-31'),
 (5199, '19T3', 'Term 3 2019', '2019-09-16', '2019-12-14')
;

create table ClassTypes (
	id          integer,
	tag         char(3),  -- e.g. 'LEC','TUT', used in SiMS
	name        text,
	primary key (id)
);

insert into ClassTypes values
 (1,'CLN','Class ?'),   (2,'CRS','Course registration'),
 (3,'DST','Distance'),  (4,'FLD','Field trip'),
 (5,'HON','Honours'),   (6,'IND','Independent study'),
 (7,'LAB','Lab class'), (8,'LEC','Lecture'),
 (9,'OTH','Other'),     (10,'PRJ','Project work'),
 (11,'SEM','Seminar'),  (12,'STD','Studio'),
 (13,'THE','Thesis'),   (14,'TLB','Tute/Lab'),
 (15,'TUT','Tutorial'), (16,'WEB','Web stream'),
 (17,'WRK','Work')
;

create table RoomTypes (
	id          integer,
	tag         char(4),  -- e.g. 'LEC','TUT', used in SiMS
	name        text,
	primary key (id)
);

insert into RoomTypes values
 (1,'AUD','Auditorium'), (2,'CMLB','Computer Lab'), (3,'EXAM','Exam Room'),
 (4,'LAB','Laboratory'), (5,'LCTR','Lecture Theatre'), (6,'MEET','Meeting Room'),
 (7,'OTHR','Other Room'), (8,'SDIO','Studio'), (9,'SPRT','Sporting Facility'),
 (10,'TUSM','Tute/Seminar Room'), (11,'UNKN','Unknown')
;

create table People (
	id          integer,  -- zID, without the "z"
	name        text not null,  -- name to display
	sort_name   text not null,  -- name to sort by
	title       char(4),  -- e.g. 'Dr','Prof',...
	primary key (id)
);

create table Buildings (
	id          integer,
	name        text not null,
	location    char(8) not null,  -- grid reference
	primary key (id)
);

create table Rooms (
	id          integer,
	code        char(15),  -- e.g. K-K17-G01
	name        text not null unique,  -- name to display
	long_name   text unique,
	type_id     integer not null,
	within      integer,
	capacity    integer check (capacity between 0 and 9999),
	foreign key (type_id) references RoomTypes(id),
	foreign key (within) references Buildings(id),
	primary key (id)
);

create table Subjects (
	id          integer,
	code        char(8) not null,  -- e.g. 'COMP3311'
	title       text not null,     -- e.g. 'Database Systems'
	uoc         integer not null check (uoc between 0 and 24),
	primary key (id)
);	

create table Courses (
	id          integer,
	subject_id  integer not null,
	term_id     integer not null,
	convenor    integer,
	quota       integer check (quota between 0 and 9999),
	foreign key (subject_id) references Subjects(id),
	foreign key (term_id) references Terms(id),
	foreign key (convenor) references People(id),
	primary key (id)
);	

create table Classes (
	id          integer,
	course_id   integer not null,
	type_id     integer not null,
	tag         char(4), -- e.g. 'T14A'
	quota       integer not null check (quota between 0 and 999),
	foreign key (course_id) references Courses(id),
	foreign key (type_id) references ClassTypes(id),
	primary key (id)
);	

create type WeekDay as enum ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
create domain DayTime integer check (value between 0000 and 2359);

create table Meetings (
	id           integer,
	class_id     integer not null,
	day          WeekDay not null,
	start_time   DayTime not null,
	end_time     DayTime not null,
	room_id      integer not null,
	weeks        text not null,  -- e.g. 1,2-5,6
	weeks_binary text,  -- e.g. 11111011111
	--constraint  NoDoubleBookings
	--            unique(*term*,day,start_time,end_time,room_id),
    -- would be nice to enforce, but needs triggers
	foreign key (class_id) references Classes(id),
	foreign key (room_id) references Rooms(id),
	primary key (id)
);	

create table Course_Enrolment (
	person_id   integer,
	course_id   integer,
	foreign key (person_id) references People(id),
	foreign key (course_id) references Courses(id),
	primary key (person_id,course_id)
);

create table Class_Enrolment (
	person_id   integer,
	class_id    integer,
	foreign key (person_id) references People(id),
	foreign key (class_id) references Classes(id),
	primary key (person_id,class_id)
);
