-- COMP3311 19T3 ... schema for IMDB data

create domain Counter integer check (value >= 0);
-- these are ideal domain definitions
-- create domain Minutes integer check (value > 0);
-- create domain YearType integer check (value > 1800);
-- unfortunately, the data in IMDB doesn't agree
-- so we use these instead
create domain Minutes integer check (value >= 0);
create domain YearType integer check (value >= 0);

create table Titles (
	id          integer,
	format      text not null,
	main_title  text not null,
	orig_title  text,  -- null if same as a main_title
	is_adult    boolean default false,
	start_year  YearType not null,
	end_year    YearType,
	runtime     Minutes,
	rating      float,
	nvotes      Counter,
--	genres      via Title_Genres
	primary key (id)
);

create table Title_genres (
	title_id    integer,  -- not null because PK
	genre       text,     -- not null because PK
	foreign key (title_id) references Titles(id),
	primary key (title_id, genre)
);

create table Episodes (
	title_id    integer,
	parent_id   integer,
	season      Counter,
	episode     Counter,
	foreign key (title_id) references Titles(id),
	foreign key (parent_id) references Titles(id),
	primary key (title_id)
);

create table Aliases (
	id          integer,
	title_id    integer not null,
	ordering    Counter not null,
	local_title text not null,
	region      char(4),
	language	char(4),
--	types       via Alias_Types	
--	extras      via Alias_Extras	
	foreign key (title_id) references Titles(id),
	primary key (id)
);

create table Alias_types (
	alias_id    integer not null,
	al_type     text not null,
	foreign key (alias_id) references Aliases(id),
	primary key (alias_id, al_type)
);

create table Alias_extras (
	alias_id    integer not null,
	al_extra    text not null,
	foreign key (alias_id) references Aliases(id),
	primary key (alias_id, al_extra)
);

create table Names (
	id          integer,
	name        text not null,
	birth_year  YearType,  -- ideally, not null
	death_year  YearType,
	primary key (id)
);

create table Worked_as (
	name_id     integer not null,
	work_role   text not null,
	foreign key (name_id) references Names(id)
--	primary key (name_id, work_role)
--	don't need primary key since all fields involved
);

create table Known_for (
	title_id    integer,  -- not null because PK
	name_id     integer,  -- not null because PK
	foreign key (name_id) references Names(id),
	foreign key (title_id) references Titles(id),
	primary key (title_id, name_id)
);

create table Principals (
	title_id    integer,  -- not null because PK
	ordering    Counter,  -- not null because PK
	name_id     integer not null,
    job_cat     text not null,
    job         text,
	foreign key (title_id) references Titles(id),
	foreign key (name_id) references Names(id),
	primary key (title_id, ordering)
);

create table Actor_roles (
	title_id    integer not null,
	name_id     integer not null,
	played      text not null,
	foreign key (title_id) references Titles(id),
	foreign key (name_id) references Names(id)
--	primary key (title_id,name_id,played)
--	don't need primary key since all fields involved
);

create table Crew_roles (
	title_id    integer not null,
	name_id     integer not null,
	role        text not null,
	foreign key (title_id) references Titles(id),
	foreign key (name_id) references Names(id)
--	primary key (title_id,name_id,role)
--	don't need primary key since all fields involved
);
