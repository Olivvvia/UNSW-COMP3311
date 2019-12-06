create table Supplier (
    name varchar(20),
    city varchar(20),
    primary key (name)
);
create table Part (
    number integer(10),
    colour varchar(10),
    primary key(number)
);

create table Supply (
    supplier varchar(20),
    quantity float(10),
    part integer(10),
    foreign key (supplier) references Supplier(name),
    foreign key (part) references part(number),
    primary key(supplier,part)

);

-- single-table-style
create table Person (
    ssn integer,
    name text,
    address text,
    primary key (ssn),
    isPatient boolean,
    isDoctor boolean,
    isPharmacist boolean,
    -- patient-specific attributes
    primaryPhys integer,
    DOB date check (DOB is not null if ptype = 'Patient'), 
    -- doctor specific attributes
    --Specialities text check (Specialities IS NOT NULL if ptype='Doctor'),
    --YeatsExp integer check (Years IS NOT NULL if ptype='Doctor'),
    Qualification text check (Qualification IS NOT NULL if ptype='Pharmacist')
    foreign key (primaryPhys) reference Person(ssn),

);

--ER Style Mapping
create table Doctor (
    YearsExp integer,
    ssn integer references Person(ssn),
    primary key(ssn)
);
create table Specialities (
    doctor integer,
    Speciality text,
    primary key(doctor),
    foreign key (doctor) references Doctor(ssn)
);
create table Pharmacist (
    ssn integer,
    Qualification text,
    primary key(ssn) references Person(ssn)
);

create table Person(
    TFN text,
    Name text check (Name is not null),
    Address text check (Address is not null),
    ptype text check (ptype in ('Author','Editor')),
    penname text,
    

);