-- Theory 03
Update table Employees e
set e.salary = 1.1*e.salary 
where eid in 
    (select eid from Worksin w, departments d
    where dname = 'Sales' and d.did = w.did;
    );

create table Employees (
      eid       integer,
      ename     varchar(30),
      age       integer check(salary >= 15000),
      salary    real,
      primary key (eid)
);
create table Departments (
    did       integer,
    dname     varchar(20),
    budget    real,
    manager   integer not null,
    primary key (did),
    foreign key (manager) references Employees(eid)
    constraint ManagerTimeCheck
        check(1.00 = (select w.pct_time
                    from WorksIn w
                    where w.eid = manager)
            )
);
create table WorksIn (
    eid       integer,
    did       integer,
    pct_time  real,
    primary key (eid,did),
    foreign key (eid) references Employees(eid) on delete cascade,
    foreign key (did) references Departments(did) on delete cascade,
    constraint MaxFullTimeCheck
            check(1.00 >= (select sum(w.pct_time)
                        from WorksIn w
                        where w.eid = eid)
                )
);