-- Database Design

-- Creating Trip Details Table

create table trip_details(
	trip_id int primary key,
	pickup_time timestamp not null,
	drop_off_time timestamp not null,
	passenger_count smallint not null,
	trip_distance decimal not null,
	pu_location_id smallint not null,
	do_location_id smallint not null,
	fare_amount decimal not null,
	surge_fee decimal not null,
	vehicle varchar(20) not null,
	payment_type varchar(20) not null
);

-- Creating Locations Table

create table locations(
	location_id int,
	location_name varchar(75) not null,
	city varchar(30) not null
);

-- Creating Windows View

create view td_locations as
    select
        t.*,
        l1.location_name as pickup_location,
        l1.city as pickup_city,
        l2.location_name as dropoff_location,
        l2.city as dropoff_city
    from trip_details as t 
    left join locations as l1 
        on t.pu_location_id= l1.location_id
     left join locations as l2
        on t.do_location_id = l2.location_id;


	









