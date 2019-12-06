drop view if exists q1;
create view q1 as
select b.name from beers b
join brewers br on br.id = b.brewer
where br.name like "Toohey's"
;


drop view if exists q2;
create view q2 as
select b.name as Beer, br.name as Brewer
from beers b , brewers br
where br.id = b.brewer
order by b.name
;

drop view if exists q3;
create view q3 as
select br.name from brewers br
join beers b on br.id = b.brewer
join likes l on l.beer = b.id
join drinkers d on d.id = l.drinker
where d.name = 'John'
;

drop view if exists q4;
create view q4 as
select count(distinct id) from beers;

drop view if exists q5;
create view q5 as
select count(distinct id) from brewers;

drop view if exists q6;
create view q6 as
select distinct b1.name, b2.name 
from beers b1, beers b2
join brewers br1 on br1.id = b1.brewer
join brewers br2 on br2.id = b2.brewer
where br1.id = br2.id and b1.name < b2.name
;
drop view if exists q7;
create view q7 as
select br1.name as brewer,count(b1.name) as nbeers
from beers b1
join brewers br1 on br1.id = b1.brewer
group by br1.name
;

drop view if exists q8;
create view q8 as
select brewer from q7
where nbeers in (select max(nbeers) from q7)
;

drop view if exists q9helper;
create view q9helper as
select br.id, count(b.id) as nbeer from beers b
join brewers br on br.id = b.brewer
group by br.id
;
drop view if exists q9;
create view q9 as
select b.name from beers b
join q9helper q on q.id = b.brewer
where q.nbeer = 1
;

drop view if exists q10;
create view q10 as
select distinct b.name from frequents f
join drinkers d on d.id = f.drinker
join bars ba on ba.id = f.bar
join sells s on s.bar = ba.id
join beers b on b.id = s.beer
where d.name = 'John' order by b.name
;

drop view if exists q11;
create view q11 as
select distinct b.name from frequents f
join drinkers d on d.id = f.drinker
join bars b on b.id = f.bar
where d.name = 'John' or d.name = 'Gernot'
order by b.name
;
drop view if exists q12;
create view q12 as 
select distinct b.name from bars b
where b.name in (
    select distinct b.name from frequents f
    join drinkers d on d.id = f.drinker
    join bars b on b.id = f.bar
    where d.name = 'John'
    intersect 
    select distinct b.name from frequents f
    join drinkers d on d.id = f.drinker
    join bars b on b.id = f.bar
    where d.name = 'Gernot'
)
order by b.name
;

drop view if exists q13;
create view q13 as 
select distinct b.name from bars b
where b.name in (
    select distinct b.name from frequents f
    join drinkers d on d.id = f.drinker
    join bars b on b.id = f.bar
    where d.name = 'John' and b.name not in (
        select distinct b.name from frequents f
        join drinkers d on d.id = f.drinker
        join bars b on b.id = f.bar
        where d.name = 'Gernot'
    )
)
order by b.name
;

drop view if exists q14;
create view q14 as
select b.name from sells s
join beers b on s.beer = b.id
where s.price in (select max(s1.price) from sells s1);


drop view if exists q15;
create view q15 as
select distinct ba.name from bars ba
join sells s on s.bar = ba.id
join beers b on b.id = s.beer
where s.price in (
        select s.price from bars ba
        join sells s on s.bar = ba.id
        join beers b on b.id = s.beer 
        where ba.name = 'Coogee Bay Hotel' and b.name = 'Victoria Bitter')
and ba.name != 'Coogee Bay Hotel'
;

drop view if exists q16;
create view q16 as
select b.name as beer,round(avg(s.price),2) as AvgPrice from beers b
join sells s on s.beer = b.id
join sells s1 on s1.beer = b.id
where s.bar != s1.bar
group by b.name
order by AvgPrice
;

drop view if exists q17;
create view q17 as 
select distinct ba.name from bars ba
join sells s on s.bar = ba.id
join beers b on b.id = s.beer
where s.price in (
    select min(s.price) from sells s
    join beers b on b.id = s.beer
    where b.name = 'New'
);

drop view if exists q18;
drop view if exists q18helper;

create view q18helper as
select bar, count(drinker) as ndrinker from frequents
group by bar;

create view q18 as
select ba.name from bars ba
join q18helper q on q.bar = ba.id
where q.ndrinker in (
    (select max(ndrinker) from q18helper)
)
group by ba.name
;
drop view if exists q19;
create view q19 as
select ba.name from bars ba
join q18helper q on q.bar = ba.id
where q.ndrinker in (
    (select min(ndrinker) from q18helper)
)
group by ba.name
;

drop view if exists q20;
drop view if exists q20helper;

create view q20helper as
select s.bar as bar, avg(s.price) as avgp from sells s
group by s.bar;

create view q20 as
select ba.name from bars ba
where ba.id in (
    select q.bar from q20helper q
    where q.avgp in (select max(avgp) from q20helper)
);

drop view if exists q21;
create view q21 as
select b.name from beers b
where not exists (
    select b.id from beers b
    except
    select s.beer from sells s where s.beer = b.id
)
;

drop view if exists q22;
create view q22 as
select ba.name as bar, round(min(s.price),2) as minp
from bars ba
join sells s on s.bar = ba.id
group by ba.name;

drop view if exists q23;
create view q23 as
select q.bar, b.name
from q22 q 
join bars ba on ba.name = q.bar
join sells s on s.bar = ba.id
join beers b on s.beer = b.id
where s.price = q.minp 
;

drop view if exists q24;
create view q24 as
select dr.addr, count(dr.id) from drinkers dr
group by dr.addr order by dr.addr desc
;

drop view if exists q25;
create view q25 as
select q.addr, count(b.id) 
from q24 q
left join bars b on b.addr = q.addr
group by q.addr;
