-- CS4400: Introduction to Database Systems: Monday, March 3, 2025
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like the model and the engine.  
Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_maintenanced boolean, in ip_model varchar(50),
    in ip_neo boolean)
sp_main: begin

	#check if plane type is valid (boeing, airbus, or neither (null) )
	if ip_plane_type not in ('Boeing', 'Airbus') and ip_plane_type is not null then 
		select 'plane type is not Boeing, Airbus, or neither';
		leave sp_main;
	else 
		#check if boeing, then check if model and maintenance has value
		if ip_plane_type like 'Boeing' then
			if ip_model is null or ip_maintenanced is null then 
				select 'Boeing plane does not have model and maintenance values';
				leave sp_main;
			end if;
		end if;
		
        #check if airbus, then check if neo has value
		if ip_plane_type like 'Airbus' then
			if ip_neo is null then 
				select 'Airbus plane does not have neo values';
				leave sp_main;
			end if;
		end if;
    end if;
    
    #check that plane has non zero seat capacity
    if ip_seat_capacity = 0 then
		select 'seat capacity does not have non zero value';
		leave sp_main;
	end if;
    
	#check that plane has non zero speed
    if ip_speed = 0  then
		select 'speed does not have non zero value';
		leave sp_main;
	end if;
    
    #check that airplane has unique location 
    if ip_locationID in (select locationID from airplane) then
		select 'location ID is not unique';
		leave sp_main;
	end if;
    
    #insert new locationID into location table (double make sure locationID is unique)
    if ip_locationID not in (select locationID from location) then
		insert into location (locationID) values (ip_locationID);
	end if;
    
    #check that airplane has existing airline
    if ip_airlineID not in (select airlineID from airplane) then 
		select 'airline ID does not already exist';
		leave sp_main;
	else
		#check that tail num is unique for that airline
		if ip_tail_num in (select tail_num from airplane where ip_airlineID = airlineID) then
			select 'tail number is not unique for specific airline';
			leave sp_main;
		end if;
	end if;
    
	#insert values into airplane table
    insert into airplane values (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_maintenanced, ip_model, ip_neo);
    
	-- Ensure that the plane type is valid: Boeing, Airbus, or neither
    -- Ensure that the type-specific attributes are accurate for the type
    -- Ensure that the airplane and location values are new and unique
    -- Add airplane and location into respective tables

end //
delimiter ;

#call add_airplane('Delta', 'n281fc', 6, 500, 'plane_41', 'Airbus', null, null, TRUE);

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings.  An airport may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin

	#check that airportID is unique
	if ip_airportID in (select airportID from airport) then
		select 'airport ID is not unique';
		leave sp_main;
	end if;
    
    #check that locationID for airport is unique
    if ip_locationID in (select locationID from airport) then
		select 'location ID is not unique';
        leave sp_main;
	end if;
    
    #insert new locationID into location table (double check that locationID is unique) 
    if ip_locationID not in (select locationID from location) then
		insert into location (locationID) values (ip_locationID);
	end if;

	#check that airport has city name (not necessary, already satisfied)
	if ip_city is null then
		select 'city does not have value';
        leave sp_main;
	end if;
    
    #check that airport has state name (not necessary, already satisfied)
	if ip_state is null then
		select 'state does not have value';
        leave sp_main;
	end if;
    
    #check that airport has country name (not necessary, already satisfied)
	if ip_country is null then
		select 'country does not have value';
        leave sp_main;
	end if;
    

	insert into airport values (ip_airportID, ip_airport_name, ip_city, ip_state, ip_country, ip_locationID);

	-- Ensure that the airport and location values are new and unique
    -- Add airport and location into respective tables

end //
delimiter ;

#call add_airport('JFK', 'John F_Kennedy International', 'New York', 'New York', 'USA', 'port_33');


-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a pilot role or a passenger role (exclusively).  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin

	#check that personID is unique
	if ip_personID in (select personID from person) then
		select 'personID is not unique';
        leave sp_main;
	end if;
    
    #check that locationID exists and is valid
    if ip_locationID not in (select locationID from location) then
		select 'locationID is not valid';
        leave sp_main;
	end if;
    
    #check that person has first name
    if ip_first_name is null then
		select 'first name does not have value';
        leave sp_main;
	end if;
    
    #check that person is either pilot (has taxID and experience) or passenger (has miles and funds)
    if not ((ip_taxID is not null and ip_experience is not null) or (ip_miles is not null and ip_funds is not null)) then
		select 'person is neither pilot nor passenger';
        leave sp_main;
	end if;
    
	#insert values into person table
	insert into person values (ip_personID, ip_first_name, ip_last_name, ip_locationID);

    #for passengers, add values to passenger table
    if ip_miles is not null and ip_funds is not null then
		insert into passenger (personID, miles, funds) values (ip_personID, ip_miles, ip_funds);
	end if;

	#for pilots, add values to pilot table
	if ip_taxID is not null and ip_experience is not null then
		insert into pilot (personID, taxID, experience) values (ip_personID, ip_taxID, ip_experience);
	end if;
    
    

	-- Ensure that the location is valid
    -- Ensure that the persion ID is unique
    -- Ensure that the person is a pilot or passenger
    -- Add them to the person table as well as the table of their respective role

end //
delimiter ;


#call add_person('p61', 'Sabrina', 'Duncan', 'port_1', '366-50-3732', 27, null, null);

-- [4] grant_or_revoke_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license.  If the license
doesn't exist, it must be created; and, if it aready exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin

	#check that person is valid pilot
	if ip_personID not in (select personID from pilot) then
		select 'person is not a valid pilot';
        leave sp_main;
	else
		#check that listed license exists in pilot_licenses table,
        
        #if license is already in table, delete it
		if ip_license in (select license from pilot_licenses) then
			delete from pilot_licenses where license = ip_license;
		#if license not in table, insert it
		else
			insert into pilot_licenses values (ip_personID, ip_license);
		end if;
	end if;
	
	-- Ensure that the person is a valid pilot
    -- If license exists, delete it, otherwise add the license

end //
delimiter ;



-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  And
the airplane, if designated, must not be in use by another flight.  The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground.  You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin

	#check that airplane for flight exists
	if (ip_support_airline, ip_support_tail) not in (select airlineID, tail_num from airplane) then
		select 'airplane does not exist';
        leave sp_main;
	end if;

	#check that airplane has existing valid route
	if ip_routeID not in (select routeID from route) then
		select 'does not have valid route';
        leave sp_main;
	end if;
        
	#check that plane is not being used by another flight
	if (ip_support_airline, ip_support_tail) in (select support_airline, support_tail from flight) then
     select 'airplane in use by another flight';
     leave sp_main;
	end if;
    
    #check that flight progress is less than length of route
    if ip_progress >= (select max(sequence) from route_path where ip_routeID = routeID) then
		select 'flight is not at valid location along route';
        leave sp_main;
	end if;
    
	#insert values into flight table
	insert into flight values (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, 'on_ground', ip_next_time, ip_cost);

	-- Ensure that the airplane exists
    -- Ensure that the route exists
    -- Ensure that the progress is less than the length of the route
    -- Create the flight with the airplane starting in on the ground

end //
delimiter ;


#call offer_flight('un_41', 'americas_three', 'United', 'n330ss', 0, '11:30:00', 400);

-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin

	#declare variables
	declare current_loc varchar(50);
    declare flight_distance int;

	#check that flight is valid
	if ip_flightID not in (select flightID from flight) then
		select 'not a valid flight';
        leave sp_main;
	end if;
    
    #check that plane status is in air
    if (select airplane_status from flight where flightID=ip_flightID) = 'on_ground' then
		select 'flight is not in air';
        leave sp_main;
	end if;
    
    #add next time by 1 hour and change plane status to on ground
    update flight
		set next_time = addtime(next_time, '01:00:00'),
			airplane_status = 'on_ground'
        where ip_flightID = flightID;

    #update pilot to add experience level
    update pilot
		set experience = (experience + 1) 
        where ip_flightID = commanding_flight;
        
	#set current_loc
    select a.locationID
    from airplane as a 
    join flight as f on (a.airlineID=f.support_airline and a.tail_num=f.support_tail)
    where f.flightID=ip_flightID
    into current_loc;
    
    #set flight_distance
    select l.distance
    from leg as l 
    join route_path as rp on l.legID=rp.legID 
    join flight as f on (rp.routeID=f.routeID and rp.sequence=f.progress) 
    join airplane as a on (a.airlineID=f.support_airline and a.tail_num=f.support_tail)
    where f.flightID= ip_flightID
	into flight_distance;

    #update passenger to have added miles where their location is at flight location 
    update passenger as pass
		join person as p on p.personID=pass.personID
        set pass.miles = pass.miles + flight_distance
        where p.locationID = current_loc;



	-- Ensure that the flight exists
    -- Ensure that the flight is in the air
    
    -- Increment the pilot's experience by 1
    -- Increment the frequent flyer miles of all passengers on the plane
    -- Update the status of the flight and increment the next time to 1 hour later
		-- Hint: use addtime()

end //
delimiter ;


-- call flight_landing('random'); # test for fake flight 
-- call flight_landing('aa_12'); # test flight that is on the ground


-- [7] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that Airbus and general planes have at least one pilot
assigned, while Boeing must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin

	#declare variables
	declare flight_distance int;
    declare flight_speed int;
    declare flight_time time;
    declare ip_plane_type varchar(100);

	#check that flight is valid
	if ip_flightID not in (select flightID from flight) then
		select 'not a valid flight';
        leave sp_main;
	end if;
    
    #check that flight is on ground
    if (select airplane_status from flight where flightID=ip_flightID) = 'in_flight' then
		select 'flight is not on ground';
        leave sp_main;
	end if;
    
    #check that there are still more legs to fly
    if (select progress from flight as f where f.flightID=ip_flightID) >= (select max(sequence) from route_path as rp join flight as f on f.routeID=rp.routeID where f.flightID=ip_flightID) then
		select 'no more legs to fly';
        leave sp_main;
	end if;
    
    #set ip_plane_type
    select plane_type from airplane as a 
    join flight as f on (f.support_tail=a.tail_num and f.support_airline=a.airlineID)
    where f.flightID=ip_flightID
    into ip_plane_type;
    
    #check Boeing
    if ip_plane_type = 'Boeing' then
		#check that pilot count assigned to flight is at least 2
		if (select count(personID) from pilot where commanding_flight=ip_flightID) < 2 then
			select 'not enough pilots for Boeing';
			#update time by 30 min if not enough pilots
            update flight 
				set next_time= addtime(next_time, '00:30:00')
                where ip_flightID=flightID;
			leave sp_main;
		end if;
	#check other plane type
	else
		#check that pilot count assigned to flight is at least 1
		if (select count(personID) from pilot where commanding_flight=ip_flightID) < 1 then
			select 'not enough pilots';
            #update time by 30 min if not enough pilots
            update flight 
				set next_time= addtime(next_time, '00:30:00')
                where ip_flightID=flightID;
			leave sp_main;
		end if;
	end if;
    
    #change flight status to in flight and add progress
    update flight
		set progress = progress + 1, 
			airplane_status = 'in_flight'
        where ip_flightID= flightID;
	
    #set flight_distance and flight_speed
    select l.distance, a.speed
    from leg as l
    join route_path as rp on rp.legID=l.legID 
    join flight as f on (f.routeID=rp.routeID and f.progress=rp.sequence) 
    join airplane as a on (f.support_airline=a.airlineID and f.support_tail=a.tail_num)
    where f.flightID= ip_flightID
    into flight_distance, flight_speed;
    
    #calculate and set flight_time
    set flight_time = sec_to_time(flight_distance / flight_speed * 3600);
    
    #update flight next time by time of flight 
    update flight
		set next_time = addtime(next_time, flight_time)
		where flightID=ip_flightID;
        

	-- Ensure that the flight exists
    -- Ensure that the flight is on the ground
    -- Ensure that the flight has another leg to fly
    -- Ensure that there are enough pilots (1 for Airbus and general, 2 for Boeing)
		-- If there are not enough, move next time to 30 minutes later
        
	-- Increment the progress and set the status to in flight
    -- Calculate the flight time using the speed of airplane and distance of leg
    -- Update the next time using the flight time

end //
delimiter ;

-- call flight_takeoff('random'); # test for fake flight 
-- call flight_takeoff('af_19'); # test flight that is in air
-- call flight_takeoff('aa_12'); # test flight with no legs remaining

-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight.  Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------

drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin

	#declare variables
	declare current_airport char(3);
    declare flight_cost int;
    declare flight_seats int;
    declare total_passengers int;
    declare next_destination char(3);
    declare new_plane_loc varchar(50);

	#check that flight is valid and exists
	if ip_flightID not in (select flightID from flight) then
		select 'not a valid flight';
        leave sp_main;
	end if;
    
    #check that flight is on ground
    if (select airplane_status from flight where flightID=ip_flightID) = 'in_flight' then
		select 'flight is not on ground';
        leave sp_main;
	end if;
    
    #check that flight has more legs to fly
    if (select progress from flight as f where f.flightID=ip_flightID) >= (select max(sequence) from route_path as rp join flight as f on f.routeID=rp.routeID where f.flightID = ip_flightID) then
		select 'no more legs to fly';
        leave sp_main;
	end if;
    
	#set current_airport
    select case
		when rp.sequence=f.progress then l.arrival
        when f.progress=0 and rp.sequence=1 then l.departure
	end
    from flight as f 
    join route_path as rp on ((f.routeID=rp.routeID and f.progress=rp.sequence) or (f.routeID=rp.routeID and f.progress=0 and rp.sequence=1))  
    join leg as l on l.legID=rp.legID
    where f.flightID=ip_flightID
	into current_airport;
    
	#set flight_cost
    select cost 
    from flight as f 
    where f.flightID=ip_flightID
	into flight_cost;

    #set flight_seats
	select seat_capacity
    from airplane as a join flight as f on (f.support_airline=a.airlineID and f.support_tail=a.tail_num)
    where f.flightID=ip_flightID
	into flight_seats;
    
    #set next_destination
    select l.arrival
    from flight as f join route_path as rp on (f.routeID=rp.routeID and f.progress+1=rp.sequence) join leg as l on l.legID=rp.legID
    where f.flightID= ip_flightID
	into next_destination;

	#set new_plane_loc
	select a.locationID
    from flight as f join airplane as a on (f.support_airline=a.airlineID and f.support_tail=a.tail_num)
    where f.flightID=ip_flightID
	into new_plane_loc;

    #set total_passengers where passengers has enough funds, is at airport of plae, and immediate next destination is next location
    select count(p.personID) 
    from passenger as pass
    join person as p on p.personID=pass.personID 
    join passenger_vacations as pv on p.personID=pv.personID 
    join airport as a on a.locationID=p.locationID
    where pass.funds > flight_cost and a.airportID = current_airport and pv.airportID=next_destination and pv.sequence=1
	into total_passengers;
    
    #check there are enough seats on plane
    if total_passengers > flight_seats then
		select 'not enough seats';
        leave sp_main;
	else
		#if enough seats, reduce passenger funds by flight cost, and change location to plane location
		update passenger as pass
		join person as p on p.personID=pass.personID 
        join passenger_vacations as pv on p.personID=pv.personID 
        join airport as a on a.locationID=p.locationID
        set pass.funds = pass.funds - flight_cost, p.locationID=new_plane_loc
        where pv.sequence=1 and pass.funds > flight_cost and a.airportID = current_airport and pv.airportID=next_destination;
	end if;


	-- Ensure the flight exists
    -- Ensure that the flight is on the ground
    -- Ensure that the flight has further legs to be flown
    
    -- Determine the number of passengers attempting to board the flight
    -- Use the following to check:
		-- The airport the airplane is currently located at
        -- The passengers are located at that airport
        -- The passenger's immediate next destination matches that of the flight
        -- The passenger has enough funds to afford the flight
        
	-- Check if there enough seats for all the passengers
		-- If not, do not add board any passengers
        -- If there are, board them and deduct their funds

end //
delimiter ;

-- call passengers_board('af_19'); # test flight that is in air
-- call passengers_board('aa_12'); # test flight with no more legs remaining

-- [9] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin

	#declare variables
	declare flight_location varchar(50);
    declare next_destination char(3);
    declare airport_loc varchar(50);
    
    #check that flight is valid and exists
	if ip_flightID not in (select flightID from flight) then
		select 'not a valid flight';
        leave sp_main;
	end if;
    
    #check that flight is in air 
    if (select airplane_status from flight where flightID=ip_flightID) = 'in_flight' then
		select 'flight is not on ground';
        leave sp_main;
	end if;
    
    #set flight_location
	select a.locationID from flight as f join airplane as a on (f.support_airline=a.airlineID and f.support_tail=a.tail_num)
    where f.flightID=ip_flightID
    into flight_location; 
    
    #set next_destination
	select l.arrival
    from flight as f join route_path as rp on (f.routeID=rp.routeID and f.progress=rp.sequence) join leg as l on l.legID=rp.legID
    where f.flightID= ip_flightID
	into next_destination; 
    
    #set airport_loc
    select a.locationID from airport as a
    where a.airportID=next_destination
    into airport_loc;
    
    #create temporary table to store passengers to disembark 
    drop temporary table if exists passenger_to_disembark;
	create temporary table passenger_to_disembark (v_personID varchar(50));
		insert into passenger_to_disembark (v_personID)
		select p.personID
		from person as p
		join passenger as pass on p.personID=pass.personID
		join passenger_vacations as pv on pv.personID=p.personID
		where p.locationID = flight_location 
		and pv.airportID = next_destination 
		and pv.sequence = 1;
        
	#update passengers in temp table's location to airport location 
	update person as p 
		set p.locationID=airport_loc
        where p.personID in (select * from passenger_to_disembark);
	
    #delete vacations of passengers in temp table where destination matches their next immediate destination
    delete from passenger_vacations as pv
		where pv.personID in (select * from passenger_to_disembark) and pv.sequence=1;

	#update vacations table so that all sequences are reduced by one
	update passenger_vacations as pv
		set pv.sequence = pv.sequence -1
        where pv.personID in (select * from passenger_to_disembark);

	#remove temp table
	drop temporary table if exists passenger_to_embark;

	-- Ensure the flight exists
    -- Ensure that the flight is on the ground
    
    -- Determine the list of passengers who are disembarking
	-- Use the following to check:
		-- Passengers must be on the plane supporting the flight
        -- Passenger has reached their immediate next destionation airport
        
	-- Move the appropriate passengers to the airport
    -- Update the vacation plans of the passengers

end //
delimiter ;

-- call passengers_disembark('random'); # test for fake flight 
-- call passengers_disembark('af_19'); # test flight that is in air

-- [10] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin

	#declare variables
	declare pilot_airport char(3);
	declare plane_airport char(3);
    declare plane_loc varchar(50);

	#check that flight is valid and exists
	if ip_flightID not in (select flightID from flight) then
		select 'not a valid flight';
        leave sp_main;
	end if;
    
	#check that flight is on ground
    if (select airplane_status from flight where flightID=ip_flightID) = 'in_flight' then
		select 'flight is not on ground';
        leave sp_main;
	end if;
    
    #check that flight has more legs to fly
    if (select progress from flight as f where f.flightID=ip_flightID) >= (select max(sequence) from route_path as rp join flight as f on f.routeID=rp.routeID where f.flightID = ip_flightID) then
		select 'no more legs to fly';
        leave sp_main;
	end if;
    
    #check that pilot exists
    if ip_personID not in (select p.personID from pilot as p) then
		select 'pilot does not exist';
        leave sp_main;
	end if;
    
	#check that pilot is not already assigned a flight
    if (select p.commanding_flight from pilot as p where p.personID = ip_personID) is not null then
		select 'pilot is already assigned a flight';
        leave sp_main;
	end if;
    
    #check that pilot has appropriate license
    if (select a.plane_type from flight as f 
	join airplane as a on (f.support_airline=a.airlineID and f.support_tail=a.tail_num)
    where f.flightID=ip_flightID) not in (select pl.license from pilot_licenses as pl where pl.personID=ip_personID) then
		select 'pilot does not have appropriate license';
        leave sp_main;
	end if;
    
    #set pilot_airport
    select a.airportID from pilot as pil 
		join person as p on pil.personID=p.personID 
		join airport as a on p.locationID = a.locationID
        where p.personID=ip_personID 
	into pilot_airport;

	#set plane_airport
    select case
		when rp.sequence=f.progress then l.arrival
        when f.progress=0 and rp.sequence=1 then l.departure
	end
    from flight as f 
    join route_path as rp on ((f.routeID=rp.routeID and f.progress=rp.sequence) or (f.routeID=rp.routeID and f.progress=0 and rp.sequence=1))  
    join leg as l on l.legID=rp.legID
    where f.flightID=ip_flightID
	into plane_airport;

	#make sure pilot is at airport where plane is located
	if pilot_airport != plane_airport then
		select 'Pilot not in airport where plane is located';
        leave sp_main;
	end if;

	#update pilot so that they are commanding a flight
	update pilot
		set commanding_flight = ip_flightID
        where personID=ip_personID;
        
	#set plane_loc
	select a.locationID from flight as f join airplane as a on (f.support_airline=a.airlineID and f.support_tail=a.tail_num)
    where f.flightID=ip_flightID
    into plane_loc;
       
	#update person so that their new location is in plane
	update person
		set locationID=plane_loc
        where personID=ip_personID;
        
    
	-- Ensure the flight exists
    -- Ensure that the flight is on the ground
    -- Ensure that the flight has further legs to be flown
    
    -- Ensure that the pilot exists and is not already assigned
	-- Ensure that the pilot has the appropriate license
    -- Ensure the pilot is located at the airport of the plane that is supporting the flight
    
    -- Assign the pilot to the flight and update their location to be on the plane

end //
delimiter ;

-- call assign_pilot('random', 'p19'); # test for fake flight with valid pilot
-- call assign_pilot('af_19', 'p19'); # test flight that is in air with valid pilot
-- call assign_pilot('aa_12', 'p19'); # test flight with no legs remaining with valid pilot
-- call assign_pilot('ba_51', 'pp'); # test valid flight with fake pilot
-- call assign_pilot('ba_51', 'p1'); # test valid flight with pilot already assigned 
-- call assign_pilot('ba_51', 'p19'); # test valid flight with pilot not assigned in wrong aiport
-- call assign_pilot('ry_34', 'p20'); # test valid flight with pilot with wrong license

-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin

	#declare variables
	declare flight_location varchar(50);
    declare passenger_count_in_plane int;
    declare plane_airport char(3);
    declare plane_loc varchar(50);

	#check that flight is valid and existst
	if ip_flightID not in (select flightID from flight) then
		select 'not a valid flight';
        leave sp_main;
	end if;
    
    #check that flight is on ground
    if (select airplane_status from flight where flightID=ip_flightID) = 'in_flight' then
		select 'flight is not on ground';
        leave sp_main;
	end if;
    
    #check that flight has no more legs to fly
    if (select progress from flight as f where f.flightID=ip_flightID) < (select max(sequence) from route_path as rp join flight as f on f.routeID=rp.routeID where f.flightID=ip_flightID) then
		select 'there are more legs to fly';
        leave sp_main;
	end if;
    
    #set flight_location 
	select a.locationID from flight as f join airplane as a on (f.support_airline=a.airlineID and f.support_tail=a.tail_num)
    where f.flightID=ip_flightID
    into flight_location; 
    
    #set passenger_count_in_plane
    select count(*) from passenger as pass join person as p on p.personID=pass.personID 
    where p.locationID=flight_location
    into passenger_count_in_plane;
    
    #check if flight is empty
	if passenger_count_in_plane !=0 then
		select 'flight is not empty of passengers';
        leave sp_main;
	end if;
       
	#set plane_loc
	select case
		when rp.sequence=f.progress then l.arrival
        when f.progress=0 and rp.sequence=1 then l.departure
	end
    from flight as f 
    join route_path as rp on ((f.routeID=rp.routeID and f.progress=rp.sequence) or (f.routeID=rp.routeID and f.progress=0 and rp.sequence=1))  
    join leg as l on l.legID=rp.legID
    where f.flightID=ip_flightID
	into plane_airport;
        
    select ap.locationID from airport as ap where ap.airportID = plane_airport
    into plane_loc;
    
    #move pilots to airport of plane landing
    update person as p
		join pilot as pil on p.personID=pil.personID
		set p.locationID=plane_loc
        where pil.commanding_flight = ip_flightID;
        
    #update pilot so commanding flight is null
	update pilot
		set commanding_flight = null
        where commanding_flight = ip_flightID;
       
	-- Ensure that the flight is on the ground
    -- Ensure that the flight does not have any more legs
    -- Ensure that the flight is empty of passengers
    -- Update assignements of all pilots
    -- Move all pilots to the airport the plane of the flight is located at

end //
delimiter ;

-- call recycle_crew('random'); # test for fake flight 
-- call recycle_crew('af_19'); # test flight that is in air
-- call recycle_crew('ba_51'); # test flight with more legs remaining
-- call recycle_crew('lf_67'); # test flight thats not empty

-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin

	#declare variables
	declare people_count_in_plane int;
    declare flight_location varchar(50);
    declare max_route_sequence int;
    
	#check if flight is valid and exists
	if ip_flightID not in (select flightID from flight) then
		select 'not a valid flight';
        leave sp_main;
	end if;
    
    #check that flight is on ground
    if (select airplane_status from flight where flightID=ip_flightID) = 'in_flight' then
		select 'flight is not on ground';
        leave sp_main;
	end if;
    
    #check that flight has no more legs to fly
    if (select progress from flight as f where f.flightID=ip_flightID) < (select max(sequence) from route_path as rp join flight as f on f.routeID=rp.routeID where f.flightID=ip_flightID) then
		select 'there are more legs to fly';
        leave sp_main;
	end if;
    
    #set flight_location
	select a.locationID from flight as f join airplane as a on (f.support_airline=a.airlineID and f.support_tail=a.tail_num)
    where f.flightID=ip_flightID
    into flight_location; 
    
    #set people_count_in_plane
	select count(*) from person as p
    where p.locationID=flight_location
    into people_count_in_plane;
    
    #check that flight is empty
	if people_count_in_plane !=0 then
		select 'flight is not empty of passengers/pilots'; 
        leave sp_main;
	end if;
    
    #set max_route_sequence
    select max(sequence) from route_path as rp join flight as f on f.routeID=rp.routeID
    where f.flightID=ip_flightID
    group by rp.routeID
    into max_route_sequence;
    
	#check that flight is at end of route
    if (select f.progress from flight as f where f.flightID=ip_flightID) != 0 then
		if  (select f.progress from flight as f where f.flightID=ip_flightID) != max_route_sequence then
			select 'flight is still in progress';
            leave sp_main;
		end if;
	end if;
    
    #remove flight from system
    delete from flight where flightID=ip_flightID;
    
	-- Ensure that the flight is on the ground
    -- Ensure that the flight does not have any more legs
    -- Ensure that there are no more people on the plane supporting the flight
    -- Remove the flight from the system

end //
delimiter ;

-- call retire_flight('random'); # test for fake flight 
-- call retire_flight('af_19'); # test flight that is in air
-- call recycle_crew('ba_51'); # test flight with more legs remaining
-- call retire_flight('lf_67'); # test flight thats not empty

-- [13] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin

	#declare variables
	declare next_flight varchar(50);
    declare plane_status varchar(100);
    declare end_sequence int;

	#set next_flight
    select f.flightID from flight as f 
    order by f.next_time asc,
    case f.airplane_status
		when 'in_flight' then 0
        when 'on_ground' then 1
	end,
    f.flightID asc
    limit 1
    into next_flight; 
    
	#set plane_status
    select f.airplane_status from flight as f
    where f.flightID=next_flight
    into plane_status;

	#set end_sequence
	select max(rp.sequence) from flight as f join route_path as rp on f.routeID=rp.routeID
    where f.flightID=next_flight
    group by f.flightID
    into end_sequence;
    
    #check if flight in air, then land flight, disembark passengers
    if plane_status = 'in_flight' then
		call flight_landing(next_flight);
        call passengers_disembark(next_flight);
	end if;
    
    #check if flight on ground
    if plane_status = 'on_ground' then
		#further if flight is at end of route, then retire flight and recycle crew
        if (select f.progress from flight as f where f.flightID=next_flight) = end_sequence then
			call retire_flight(next_flight);
            call recycle_crew(next_flight);
		end if;
		#further if flight is still in progress, then board passengers and take off flight
		if (select f.progress from flight as f where f.flightID=next_flight) != end_sequence then
			call passengers_board(next_flight);
			call flight_takeoff(next_flight);
		end if;
	end if;

	-- Identify the next flight to be processed
    -- If the flight is in the air:
		-- Land the flight and disembark passengers
        -- If it has reached the end:
			-- Recycle crew and retire flight
	-- If the flight is on the ground:
		-- Board passengers and have the plane takeoff
	-- Hint: use the previously created procedures

end //
delimiter ;

#call simulation_cycle();

-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. 
We need to display what airports these flights are departing from, what airports 
they are arriving at, the number of flights that are flying between the 
departure and arrival airport, the list of those flights (ordered by their 
flight IDs), the earliest and latest arrival times for the destinations and the 
list of planes (by their respective flight IDs) flying these flights. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
select l.departure, l.arrival, count(f.flightID), group_concat(f.flightID order by f.flightID),	min(f.next_time), max(f.next_time), group_concat(a.locationID order by a.locationID desc)
from flight as f join route_path as rp on (f.routeID=rp.routeID and f.progress=rp.sequence) join leg as l on l.legID=rp.legID join airplane as a on (f.support_tail=a.tail_num and f.support_airline=a.airlineID)
where f.airplane_status like 'in_flight'
and f.progress=rp.sequence
group by l.departure, l.arrival;

-- select * from flights_in_the_air; # Test view

-- [15] flights_on_the_ground()
-- ------------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are 
located. We need to display what airports these flights are departing from, how 
many flights are departing from each airport, the list of flights departing from 
each airport (ordered by their flight IDs), the earliest and latest arrival time 
amongst all of these flights at each airport, and the list of planes (by their 
respective flight IDs) that are departing from each airport.*/
-- ------------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
select case
	when rp.sequence=f.progress then l.arrival
    when f.progress=0 and rp.sequence=1 then l.departure
end as departure_airport, 
count(f.flightID), group_concat(f.flightID order by f.flightID), min(f.next_time), max(f.next_time), group_concat(a.locationID order by a.locationID desc)
from flight as f join route_path as rp on f.routeID=rp.routeID join leg as l on l.legID=rp.legID join airplane as a on (f.support_tail=a.tail_num and f.support_airline=a.airlineID)
where f.airplane_status like 'on_ground'
and f.progress=rp.sequence or (f.progress=0 and rp.sequence=1)
group by departure_airport;

-- select * from flights_on_the_ground; # Test view

-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. We 
need to display what airports these people are departing from, what airports 
they are arriving at, the list of planes (by the location id) flying these 
people, the list of flights these people are on (by flight ID), the earliest 
and latest arrival times of these people, the number of these people that are 
pilots, the number of these people that are passengers, the total number of 
people on the airplane, and the list of these people by their person id. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
select l.departure, l.arrival, count(distinct a.locationID), group_concat(distinct a.locationID order by a.locationID), 
group_concat(distinct f.flightID order by f.flightID),min(next_time), max(next_time), 
count(case when pil.personID is not null then 1 end), count(case when pass.personID is not null then 1 end), count(p.personID), group_concat(p.personID order by p.personID)
from person as p join airplane as a on p.locationID=a.locationID join flight as f on (f.support_tail=a.tail_num and f.support_airline=a.airlineID)
join route_path as rp on f.routeID=rp.routeID join leg as l on l.legID=rp.legID
left join passenger as pass on p.personID=pass.personID
left join pilot as pil on p.personID=pil.personID 
where f.airplane_status='in_flight'
and f.progress=rp.sequence
group by l.departure,l.arrival;

-- select * from people_in_the_air; # Test view

-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground and in an 
airport are located. We need to display what airports these people are departing 
from by airport id, location id, and airport name, the city and state of these 
airports, the number of these people that are pilots, the number of these people 
that are passengers, the total number people at the airport, and the list of 
these people by their person id. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, country, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select aport.airportID, aport.locationID, aport.airport_name, aport.city, aport.state, aport.country, 
count(case when pil.personID is not null then 1 end), count(case when pass.personID is not null then 1 end), count(p.personID), group_concat(p.personID order by p.personID)
from person as p join airport as aport on p.locationID=aport.locationID
left join passenger as pass on p.personID=pass.personID
left join pilot as pil on p.personID=pil.personID 
group by aport.airportID;

-- select * from people_on_the_ground; # Test view

-- [18] route_summary()
-- -----------------------------------------------------------------------------
/* This view will give a summary of every route. This will include the routeID, 
the number of legs per route, the legs of the route in sequence, the total 
distance of the route, the number of flights on this route, the flightIDs of 
those flights by flight ID, and the sequence of airports visited by the route. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
select r.routeID, r.count_legs, r.legs_list, r.sum_distance, count(f.flightID), 
group_concat(distinct f.flightID), r.sequence
from 
(select rp.routeID, count(rp.legID) as count_legs, group_concat(distinct rp.legID order by rp.sequence) as legs_list, 
sum(l.distance) as sum_distance, group_concat(distinct concat(l.departure,'->',l.arrival) order by rp.sequence) as sequence
from route_path as rp join leg as l on rp.legID=l.legID 
group by rp.routeID) as r
left join flight as f on r.routeID=f.routeID
group by r.routeID;

-- select * from route_summary; # Test view

-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. It should 
specify the city, state, the number of airports shared, and the lists of the 
airport codes and airport names that are shared both by airport ID. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, country, num_airports,
	airport_code_list, airport_name_list) as
select a.city, a.state, a.country, count(a.airportID) as num_airports, group_concat(a.airportID order by a.airportID) as airport_code_list, group_concat(a.airport_name order by a.airportID) as airport_name_list
from airport as a
group by a.city,a.state, a.country
having count(a.airportID) > 1;

-- select * from alternative_airports; # Test view



