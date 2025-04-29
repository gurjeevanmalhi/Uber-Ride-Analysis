-- Creating Trip Details Table
CREATE TABLE trip_details (
	trip_id INT PRIMARY KEY,
	pickup_time TIMESTAMP NOT NULL,
	drop_off_time TIMESTAMP NOT NULL,
	passenger_count SMALLINT NOT NULL,
	trip_distance DECIMAL NOT NULL,
	pu_location_id SMALLINT NOT NULL,
	do_location_id SMALLINT NOT NULL,
	fare_amount DECIMAL NOT NULL,
	surge_fee DECIMAL NOT NULL,
	vehicle VARCHAR(20) NOT NULL,
	payment_type VARCHAR(20) NOT NULL
	);

-- Creating Locations Table
CREATE TABLE locations (
	location_id INT,
	location_name VARCHAR(75) NOT NULL,
	city VARCHAR(30) NOT NULL
	);

-- Normalizing Cities
UPDATE LOCATIONS
SET city = 'The Bronx'
WHERE(city) IN ('Bronx', 'The Bronx');

-- Creating Windows View
CREATE VIEW td_locations
AS
SELECT t.*,
	l1.location_name AS pickup_location,
	l1.city AS pickup_city,
	l2.location_name AS dropoff_location,
	l2.city AS dropoff_city
FROM trip_details AS t
LEFT JOIN locations AS l1 ON t.pu_location_id = l1.location_id
LEFT JOIN locations AS l2 ON t.do_location_id = l2.location_id;









