-- CS4400: Introduction to Database Systems (Spring 2025)
-- Phase II: Create Table & Insert Statements [v0] Monday, February 3, 2025 @ 17:00 EST


-- Honoka Miura 


-- Directions:
-- Please follow all instructions for Phase II as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.
-- Create Table statements must be manually written, not taken from an SQL Dump file.
-- This file must run without error for credit.

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'airline_management';
drop database if exists airline_management;
create database if not exists airline_management;
use airline_management;

-- Define the database structures
/* You must enter your tables definitions, along with your primary, unique and foreign key
declarations, and data insertion statements here.  You may sequence them in any order that
works for you.  When executed, your statements must create a functional database that contains
all of the data, and supports as many of the constraints as reasonably possible. */

create table route (
  routeID varchar(50) not null,
  primary key (routeID)
) engine = innodb;

insert into route values
('americas_hub_exchange'),
('americas_one'),
('americas_three'),
('americas_two'),
('big_europe_loop'),
('euro_north'),
('euro_south'),
('germany_local'),
('pacific_rim_tour'),
('south_euro_loop'),
('texas_local'),
('korea_direct');

create table flight (
  flightID varchar(50) not null,
  cost int not null,
  route varchar(50) not null,
  primary key (flightID),
  constraint fk1 foreign key (route) references route (routeID)
) engine = innodb;

insert into flight values
('dl_10', 200, 'americas_one'),
('un_38', 200, 'americas_three'),
('ba_61', 200, 'americas_two'),
('lf_20', 300, 'euro_north'),
('km_16', 400, 'euro_south'),
('ba_51', 100, 'big_europe_loop'),
('ja_35', 300, 'pacific_rim_tour'),
('ry_34', 100, 'germany_local'),
('aa_12', 150, 'americas_hub_exchange'),
('dl_42', 220, 'texas_local'),
('ke_64', 500, 'korea_direct'),
('lf_67', 900, 'euro_north');


create table airline (
  airlineID varchar(50) not null,
  revenue int,
  primary key (airlineID)
) engine = innodb;

insert into airline values
('Delta', 53000),
('United', 48000),
('British Airways', 24000),
('Lufthansa', 35000),
('Air_France', 29000),
('KLM', 29000),
('Ryanair', 10000),
('Japan Airlines', 9000),
('China Southern Airlines', 14000),
('Korean Air Lines', 10000),
('American', 52000);


create table location (
  locID varchar(50) not null unique,
  primary key (locID)
) engine = innodb;

insert into location values
('port_1'),
('port_2'),
('port_3'),
('port_10'),
('port_17'),
('plane_1'),
('plane_5'),
('plane_8'),
('plane_13'),
('plane_20'),
('port_12'),
('port_14'),
('port_15'),
('port_20'),
('port_4'),
('port_16'),
('port_11'),
('port_23'),
('port_7'),
('port_6'),
('port_13'),
('port_21'),
('port_18'),
('port_22'),
('plane_6'),
('plane_18'),
('plane_7'),
('plane_2'),
('plane_3'),
('plane_4'),
('port_24'),
('plane_10'),
('port_25');

create table airport (
  airportID char(3) not null unique,
  locID varchar(50),
  airport_name varchar(50) not null,
  city varchar(50) not null,
  state varchar(50) not null,
  country char(3) not null,
  primary key (airportID),
  unique key (locID),
  constraint fk2 foreign key (locID) references location (locID)
) engine = innodb;

insert into airport values
('ATL', 'port_1', 'Atlanta Hartsfield_Jackson International', 'Atlanta', 'Georgia', 'USA'),
('DXB', 'port_2', 'Dubai International', 'Dubai', 'Al Garhoud', 'UAE'),
('HND', 'port_3', 'Tokyo International Haneda', 'Ota City', 'Tokyo', 'JPN'),
('LHR','port_4','London Heathrow','London','England','GBR'),
('IST',NULL,'Istanbul International','Arnavutkoy','Istanbul','TUR'),
('DFW','port_6','Dallas_Fort Worth International','Dallas','Texas','USA'),
('CAN','port_7','Guangzhou International','Guangzhou','Guangdong','CHN'),
('DEN',NULL,'Denver International','Denver','Colorado','USA'),
('LAX',NULL,'Los Angeles International','Los Angeles','California','USA'),
('ORD','port_10','O_Hare International','Chicago','Illinois','USA'),
('AMS','port_11','Amsterdam Schipol International','Amsterdam','Haarlemmermeer','NLD'),
('CDG','port_12','Paris Charles de Gaulle','Roissy_en_France','Paris','FRA'),
('FRA','port_13','Frankfurt International','Frankfurt','Frankfurt_Rhine_Main','DEU'),
('MAD','port_14','Madrid Adolfo Suarez_Barajas','Madrid','Barajas','ESP'),
('BCN','port_15','Barcelona International','Barcelona','Catalonia','ESP'),
('FCO','port_16','Rome Fiumicino','Fiumicino','Lazio','ITA'),
('LGW','port_17','London Gatwick','London','England','GBR'),
('MUC','port_18','Munich International','Munich','Bavaria','DEU'),
('MDW',NULL,'Chicago Midway International','Chicago','Illinois','USA'),
('IAH','port_20','George Bush Intercontinental','Houston','Texas','USA'),
('HOU','port_21','William P_Hobby International','Houston','Texas','USA'),
('NRT','port_22','Narita International','Narita','Chiba','JPN'),
('BER','port_23','Berlin Brandenburg Willy Brandt International','Berlin','Schonefeld','DEU'),
('ICN','port_24','Incheon International Airport','Seoul','Jung_gu','KOR'),
('PVG','port_25','Shanghai Pudong International Airport','Shanghai','Pudong','CHN');

create table airplane (
  tail_num varchar(50) not null,
  locID varchar(50),
  airlineID varchar(50) not null,
  speed int not null,
  seat_cap int not null,
  supporting_flight varchar(50),
  progress int,
  airplane_status enum('in_flight','on_ground'),
  next_time time,
  primary key (tail_num,airlineID),
  unique key (locID),
  constraint fk3 foreign key (locID) references location (locID),
  constraint fk4 foreign key (airlineID) references airline (airlineID),
  constraint fk5 foreign key (supporting_flight) references flight (flightID)
) engine = innodb;

insert into airplane values
('n106js','plane_1','Delta',800,4,'dl_10',1,'in_flight','08:00:00'),
('n110jn','plane_3','Delta',800,5,'dl_42',0,'on_ground','13:45:00'),
('n127js',NULL,'Delta',600,4, NULL, NULL, NULL, NULL),
('n330ss',NULL,'United',800,4,NULL, NULL, NULL, NULL),
('n380sd','plane_5','United',400,5,'un_38',2,'in_flight','14:30:00'),
('n616lt','plane_6','British Airways',600,7,'ba_61',0,'on_ground','09:30:00'),
('n517ly','plane_7','British Airways',600,4,'ba_51',0,'on_ground','11:30:00'),
('n620la','plane_8','Lufthansa',800,4,'lf_20',3,'in_flight','11:00:00'),
('n401fj',NULL,'Lufthansa',300,4,NULL, NULL, NULL, NULL),
('n653fk','plane_10','Lufthansa',600,6,'lf_67',6,'on_ground','21:23:00'),
('n118fm',NULL,'Air_France',400,4,NULL, NULL, NULL, NULL),
('n815pw',NULL,'Air_France',400,3,NULL, NULL, NULL, NULL),
('n161fk','plane_13','KLM',600,4,'km_16',6,'in_flight','14:00:00'),
('n337as',NULL,'KLM',400,5,NULL, NULL, NULL, NULL),
('n256ap',NULL,'KLM',300,4,NULL, NULL, NULL, NULL),
('n156sq',NULL,'Ryanair',600,8,NULL, NULL, NULL, NULL),
('n451fi',NULL,'Ryanair',600,5,NULL, NULL, NULL, NULL),
('n341eb','plane_18','Ryanair',400,4,'ry_34',0,'on_ground','15:00:00'),
('n353kz',NULL,'Ryanair',400,4,NULL, NULL, NULL, NULL),
('n305fv','plane_20','Japan Airlines',400,6,'ja_35',1,'in_flight','09:30:00'),
('n443wu',NULL,'Japan Airlines',800,4,NULL, NULL, NULL, NULL),
('n454gq',NULL,'China Southern Airlines',400,3,NULL, NULL, NULL, NULL),
('n249yk',NULL,'China Southern Airlines',400,4,NULL, NULL, NULL, NULL),
('n180co','plane_4','Korean Air Lines',600,5,'ke_64',0,'on_ground','16:00:00'),
('n448cs',NULL,'American',400,4,NULL, NULL, NULL, NULL),
('n225sb',NULL,'American',800,8,NULL, NULL, NULL, NULL),
('n553qn','plane_2','American',800,5,'aa_12',1,'on_ground','12:15:00');

create table leg (
  legID varchar(50) not null,
  distance int not null,
  arriving_airport char(3) not null,
  departing_airport char(3) not null,
  primary key (legID),
  constraint fk6 foreign key (arriving_airport) references airport (airportID),
  constraint fk7 foreign key (departing_airport) references airport (airportID)
) engine = innodb;

insert into leg values
('leg_33',4400,'LHR','ICN'),
('leg_34',5900,'LAX','ICN'),
('leg_35',3700,'ORD','CDG'),
('leg_36',100,'HND','NRT'),
('leg_37',500,'ICN','PVG'),
('leg_38',6500,'PVG','LAX'),
('leg_4',600,'ORD','ATL'),
('leg_2',3900,'AMS','ATL'),
('leg_1',400,'BER','AMS'),
('leg_31',3700,'CDG','ORD'),
('leg_14',400,'MUC','CDG'),
('leg_3',3700,'LHR','ATL'),
('leg_22',600,'BER','LHR'),
('leg_23',500,'MUC','LHR'),
('leg_29',400,'FCO','MUC'),
('leg_16',800,'MAD','FCO'),
('leg_25',600,'CDG','MAD'),
('leg_13',200,'LHR','CDG'),
('leg_24',300,'BCN','MAD'),
('leg_5',500,'CDG','BCN'),
('leg_27',300,'BER','MUC'),
('leg_8',600,'LGW','BER'),
('leg_21',600,'BER','LGW'),
('leg_9',300,'MUC','BER'),
('leg_28',400,'CDG','MUC'),
('leg_11',500,'BCN','CDG'),
('leg_6',300,'MAD','BCN'),
('leg_26',800,'FCO','MAD'),
('leg_30',200,'FRA','MUC'),
('leg_17',300,'BER','FRA'),
('leg_7',4700,'CAN','BER'),
('leg_10',1600,'HND','CAN'),
('leg_18',100,'NRT','HND'),
('leg_12',600,'FCO','CDG'),
('leg_15',200,'IAH','DFW'),
('leg_20',100,'HOU','IAH'),
('leg_19',300,'DFW','HOU'),
('leg_32',6800,'ICN','DFW');



create table boeing (
  tail_num varchar(50) not null,
  airlineID varchar(50) not null,
  model varchar(50) not null,
  maintained boolean not null,
  primary key (tail_num, airlineID),
  constraint fk8 foreign key (tail_num) references airplane (tail_num),
  constraint fk9 foreign key (airlineID) references airline (airlineID)
) engine = innodb;

insert into boeing values
('n118fm','Air_France',777,FALSE),
('n256ap','KLM',737,FALSE),
('n341eb','Ryanair',737,TRUE),
('n353kz','Ryanair',737,TRUE),
('n249yk','China Southern Airlines',787,FALSE),
('n448cs','American',787,TRUE);

create table airbus (
  tail_num varchar(50) not null,
  airlineID varchar(50) not null,
  neo_variant boolean not null,
  primary key (tail_num, airlineID),
  constraint fk10 foreign key (tail_num) references airplane (tail_num),
  constraint fk11 foreign key (airlineID) references airline (airlineID)
) engine = innodb;

insert into airbus values
('n106js','Delta',FALSE),
('n110jn','Delta',FALSE),
('n127js','Delta',TRUE),
('n330ss','United',FALSE),
('n380sd','United',FALSE),
('n616lt','British Airways',FALSE),
('n517ly','British Airways',FALSE),
('n620la','Lufthansa',TRUE),
('n653fk','Lufthansa',FALSE),
('n815pw','Air_France',FALSE),
('n161fk','KLM',TRUE),
('n337as','KLM',FALSE),
('n156sq','Ryanair',FALSE),
('n451fi','Ryanair',TRUE),
('n305fv','Japan Airlines',FALSE),
('n443wu','Japan Airlines',TRUE),
('n180co','Korean Air Lines',FALSE),
('n225sb','American',FALSE),
('n553qn','American',FALSE);

create table pilot (
  personID varchar(50) not null unique,
  first_name varchar(100) not null,
  last_name varchar(100),
  location_occupied varchar(50) not null,
  taxID char(11) not null,
  experience int,
  commanding_flight varchar(50),
  primary key (personID),
  unique key (taxID),
  constraint fk12 foreign key (location_occupied) references location (locID),
  constraint fk13 foreign key (commanding_flight) references flight (flightID), 
  check (taxID REGEXP '^[0-9]{3}-[0-9]{2}-[0-9]{4}$')
) engine = innodb;

insert into pilot values
('p1','Jeanne','Nelson','port_1','330-12-6907',31,'dl_10'),
('p2','Roxanne','Byrd','port_1','842-88-1257',9,'dl_10'),
('p11','Sandra','Cruz','port_3','369-22-9505',22,'km_16'),
('p13','Bryant','Figueroa','port_3','513-40-4168',24,'km_16'),
('p14','Dana','Perry','port_3','454-71-7847',13,'km_16'),
('p15','Matt','Hunt','port_10','153-47-8101',30,'ja_35'),
('p16','Edna','Brown','port_10','598-47-5172',28,'ja_35'),
('p12','Dan','Ball','port_3','680-92-5329',24,'ry_34'),
('p17','Ruby','Burgess','plane_3','865-71-6800',36,'dl_42'),
('p18','Esther','Pittman','plane_10','250-86-2784',23,'lf_67'),
('p19','Doug','Fowler','port_17','386-39-7881',2,NULL),
('p8','Bennie','Palmer','port_2','701-38-2179',12,'ry_34'),
('p20','Thomas','Olson','port_17','522-44-3098',28,NULL),
('p3','Tanya','Nguyen','port_1','750-24-7616',11,'un_38'),
('p4','Kendra','Jacobs','port_1','776-21-8098',24,'un_38'),
('p5','Jeff','Burton','port_1','933-93-2165',27,'ba_61'),
('p6','Randal','Parks','port_1','707-84-4555',38,'ba_61'),
('p10','Lawrence','Morgan','port_3','769-60-1266',15,'lf_20'),
('p7','Sonya','Owens','port_2','450-25-5617',13,'lf_20'),
('p9','Marlene','Warner','port_3','936-44-6941',13,'lf_20');

create table passenger (
  personID varchar(50) not null unique,
  first_name varchar(10) not null,
  last_name varchar(100),
  location_occupied varchar(50) not null,
  miles int,
  funds int,
  primary key (personID),
  constraint fk14 foreign key (location_occupied) references location (locID)
) engine= innodb;

insert into passenger values
('p21','Mona','Harrison','plane_1',771,700),
('p22','Arlene','Massey','plane_1',374,200),
('p23','Judith','Patrick','plane_1',414,400),
('p24','Reginald','Rhodes','plane_5',292,500),
('p25','Vincent','Garcia','plane_5',390,300),
('p26','Cheryl','Moore','plane_5',302,600),
('p27','Michael','Rivera','plane_8',470,400),
('p28','Luther','Matthews','plane_8',208,400),
('p29','Moses','Parks','plane_13',	292,700),
('p30','Ora','Steele','plane_13',686,500),
('p31','Antonio','Flores','plane_13',547,400),
('p32','Glenn','Ross','plane_13',257,500),
('p33','Irma','Thomas','plane_20',564,600),
('p34','Ann','Maldonado','plane_20',211,200),
('p35','Jeffrey','Cruz','port_12',233,500),
('p36','Sonya','Price','port_12',293,400),
('p37','Tracy','Hale','port_12',552,700),
('p38','Albert','Simmons','port_14',812,700),
('p39','Karen','Terry','port_15',541,400),
('p40','Glen','Kelley','port_20',441,700),
('p41','Brooke','Little','port_3',875,300),
('p42','Daryl','Nguyen','port_4',691,500),
('p43','Judy','Willis','port_14',572,300),
('p44','Marco','Klein','port_15',572,500),
('p45','Angelica','Hampton','port_16',663,500),
('p46','Janice','White','plane_10',690,5000);



create table license (
  personID varchar(50) not null,
  license_name varchar(50) not null,
  primary key (personID, license_name),
  constraint fk15 foreign key (personID) references pilot (personID)
) engine= innodb;

insert into license values
('p1','airbus'),
('p2','airbus'),
('p2','boeing'),
('p11','airbus'),
('p11','boeing'),
('p13','airbus'),
('p14','airbus'),
('p15','airbus'),
('p15','boeing'),
('p15','general'),
('p16','airbus'),
('p12','boeing'),
('p17','airbus'),
('p17','boeing'),
('p18','airbus'),
('p19','airbus'),
('p8','boeing'),
('p20','airbus'),
('p3','airbus'),
('p4','airbus'),
('p4','boeing'),
('p5','airbus'),
('p6','airbus'),
('p6','boeing'),
('p10','airbus'),
('p7','airbus'),
('p9','airbus'),
('p9','boeing'),
('p9','general');


  
create table vacation (
  personID varchar(50) not null,
  destination char(3) not null,
  sequence int not null,
  primary key (personID, destination, sequence),
  constraint fk16 foreign key (personID) references passenger (personID)
) engine= innodb;

insert into vacation values
('p21','AMS',1),
('p22','AMS',1),
('p23','BER',1),
('p24','MUC',1),
('p24','CDG',2),
('p25','MUC',1),
('p26','MUC',1),
('p27','BER',1),
('p28','LGW',1),
('p29','FCO',1),
('p29','LHR',2),
('p30','FCO',1),
('p30','MAD',2),
('p31','FCO',1),
('p32','FCO',1),
('p33','CAN',1),
('p34','HND',1),
('p35','LGW',1),
('p36','FCO',1),
('p37','FCO',1),
('p37','LGW',2),
('p37','CDG',3),
('p38','MUC',1),
('p39','MUC',1),
('p40','HND',1),
('p46','LGW',1);

create table route_contains (
  routeID varchar(50) not null,
  legID varchar(50) not null,
  sequence int not null,
  primary key (routeID, legID, sequence),
  constraint fk17 foreign key (routeID) references route (routeID),
  constraint fk18 foreign key (legID) references leg (legID)
) engine= innodb;

insert into route_contains values
('americas_hub_exchange','leg_4',1),
('americas_one','leg_2',1),
('americas_one','leg_1',2),
('americas_three','leg_31',1),
('americas_three','leg_14',2),
('americas_two','leg_3',1),
('americas_two','leg_22',2),
('big_europe_loop','leg_23',1),
('big_europe_loop','leg_29',2),
('big_europe_loop','leg_16',3),
('big_europe_loop','leg_25',4),
('big_europe_loop','leg_13',5),
('euro_north','leg_16',1),
('euro_north','leg_24',2),
('euro_north','leg_5',3),
('euro_north','leg_14',4),
('euro_north','leg_27',5),
('euro_north','leg_8',6),
('euro_south','leg_21',1),
('euro_south','leg_9',2),
('euro_south','leg_28',3),
('euro_south','leg_11',4),
('euro_south','leg_6',5),
('euro_south','leg_26',6),
('germany_local','leg_9',1),
('germany_local','leg_30',2),
('germany_local','leg_17',3),
('pacific_rim_tour','leg_7',1),
('pacific_rim_tour','leg_10',2),
('pacific_rim_tour','leg_18',3),
('south_euro_loop','leg_16',1),
('south_euro_loop','leg_24',2),
('south_euro_loop','leg_5',3),
('south_euro_loop','leg_12',4),
('texas_local','leg_15',1),
('texas_local','leg_20',2),
('texas_local','leg_19',3),
('korea_direct','leg_32', 1);

