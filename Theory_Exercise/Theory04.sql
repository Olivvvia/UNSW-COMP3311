Suppliers(sid, sname, address)
Parts(pid, pname, colour)
Catalog(sid, pid, cost)
select s.sid 
from suppiers s
where not exists(
    (select p.pid from parts p)
    except
    (select c.pid from catalog c where c.sid = s.sid)
)

select sid
from suppliers s
where not exists (
    (select pid from parts p where color = 'red')
    except
    (select c.pid from catalog c where c.sid = s.sid)
)
-- g)
select sid
from suppliers s
where not exists (
    (select pid from parts p where color = 'red' or color = 'green')
    except
    (select c.pid from catalog c where c.sid = s.sid)
)

--h)
(
    select sid from suppliers s
    where not exists (
        (select pid from parts p where color = 'red')
        except
        (select c.pid from catalog c where c.sid = s.sid)
    )
)
union
(
    select sid from suppliers s
    where not exists (
        (select pid from parts p where color = 'green')
        except
        (select c.pid from catalog c where c.sid = s.sid)
    )
)

--i)
select c1.sid, c2.sid 
from catalog c1, catalog c2
where c1.pid = c2.pid and c1.sid != c2.sid and c1.cost > c2.cost
;

select c.pid
from catalog c
where exists(select c1.sid
            from catalog c1
            where c.pid = c1.pid and c.sid != c1.sid
            )
;

--k)
select c.pid 
from catalog c
join suppliers s on s.sid = c.sid
where s.name = 'Yosemite Sham'
c.cost in (
    select max(c1.cost) from catalog c1
    join suppliers s on s.sid = c.sid
    where s.name = 'Yosemite Sham'
)

--i)
select c.pid 
from catalog c
where c.cost < 200
group by c.pid having count(*) = (select count(*) from suppliers)
;

Student(id, name, major, stage, age)
Class(name, meetsAt, room, lecturer)
Enrolled(student, class, mark)
Lecturer(id, name, department)
Department(id, name)

select name
from   Student S, Enrolled e1, Enrolled e2, Class c1, Class c2
where  S.id = e1.student and
e1.student = e2.student and e1.class != e2.class
and e1.class = c1.name and e2.class = c2.name
and c1.meetsAt = c2.meetsAt;

select c1.name , c2.name 
from class c1, class c2
where c1.meetsAt = c2.meetsAt and c1.name != c2.name
;



select s.sid from suppliers s
where not exists (select p.pid from Parts p
                except 
                select (c.pid from catalog c where c.sid = s.sid)
)

select s.sid from suppliers s 
where not exists (
    select pid from parts
    except 
    select c.pid from catalog c where c.sid = s.sid
)


--find name of pizza has all toppings
select p.id from pizzas p
where not exists (
    select t.id from toppings t
    except 
    select h.topping from has h where h.pizza=p.id
);


-- find name of stores that sell all pizzas
select s.id from stores s
where not exists (
    select p.id from pizzas p
    except
    select so.pizza from soldin so where so.store = s.id
)

select ename from emp 
where salary > (select budget from dept)