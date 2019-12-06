create or replace function sqr(num numeric) 
returns numeric 
as $$
begin
    return num*num;
end;

$$ language plpgsql;

create or replace function fac(n integer)
returns integer as
$$
declare
    answer integer;
    num integer;
begin
    answer := 1;
    num := n;
    if (n < 0) then
        return null;
    end if;
    for num in 1..n
    loop
        answer := answer * num;
    end loop;
    return answer;
end;
$$ language plpgsql;

create or replace function fac(n integer)
returns integer as
$$
begin
    if (n < 0) then 
        return null;
    elsif (n = 0) then
        return 1;
    elsif (n = 1) then
        return 1;
    else
        return n*fac(n-1)
    end if;
end;
$$language plpgsql;

create or replace function spread(str text)
returns text
as $$
declare 
    result text := '';
    i integer;
    len integer;
begin
    i := 1;
    len := length($1);
    while (i <= len) loop
        result := result || substr($1,i,1)|| ' ';
        i := i+1;
    end loop;   
    return result;
end;
$$language plpgsql;

create or replace function seq(n integer)
returns setof IntValue as
$$
declare
    i integer;
    r IntValue%rowtype;
begin
  for i in 1..n loop
    r.val = i;
    return next r;
  end loop;
end;
$$language plpgsql;

create type IntValue as (val integer);
create or replace function seq(int,int,int) 
returns setof IntValue as
$$
declare 
    i integer;
    counter integer;
    r IntValue%rowtype;
begin
    counter := 0;
    i := $1;
    if ($3 > 0) then
        while (i <= $2) loop
            r.val := i;
            i := i + $3;
            return next r;
        end loop;
    elsif ($3 < 0) then
        while (i >= $2) loop
            r.val := i;
            i := i + $3;
            return next r;
        end loop;
    end if;      
end;
$$ language plpgsql;

create type IntValue as (val integer);
create or replace function seq(int,int,int) 
returns setof IntValue as
$$
declare 
    i integer;
    counter integer;
    r IntValue%rowtype;
begin
    counter := 0;
    i := $1;
    if ($3 > 0) then
        while (i <= $2) loop
            r.val := i;
            i := i + $3;
            return next r;
        end loop;
    elsif ($3 < 0) then
        while (i >= $2) loop
            r.val := i;
            i := i + $3;
            return next r;
        end loop;
    end if;      
end;
$$ language plpgsql;

create or replace function
	seq(int) returns setof IntValue
as $$
	select * from seq(1,$1,1);
$$
language sql;

create or replace function
	hotelsIn (_addr text) returns text
as $$
declare 
	pubnames text;
    nohotel text;
    i integer;
	p record;
begin
    i := 0;
    nohotel := 'There are no hotels in '||$1;
	pubnames:= 'Hotels in ' || $1 || ':';
	for p in select * from Bars where addr = _addr
	loop
		pubnames := pubnames||' '||p.name;
        i := i + 1;
	end loop;
    if (i = 0) then
        return nohotel;
    else
	    pubnames := pubnames||e'\n';
	    return pubnames;
    end if;
end;
$$ language plpgsql;

create or replace function Hotelsin2(addr text)
returns setof Bars
as
$$
    select * from bars where addr = $1;
$$ language sql;

create or replace function branchdetail(loc text)
returns setof Branches
as $$
declare
    r Branches;
begin
    select * into r
    from Branches where location = $1;
    return r;
end;
$$language plpgsql;

create or replace function branchList() returns text
as $$
declare
    a record;
    b record;
    tot integer;
    qry text;
    out text := e'\n';
begin 
    for b in select * from Branches
    loop
      out:= out || 'Branch: '||b.location||',';
      
    end loop;

$$ language plpgsql;


create of replace function spread(text)
returns text as $$


$$ language plpgsql