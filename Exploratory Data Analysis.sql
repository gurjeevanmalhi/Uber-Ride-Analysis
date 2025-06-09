-- EDA

--------------------------------------------------------------------------------------------------------------------------

-- Key SQL Functions & Concepts Used:
-- 1. WITH (CTEs)         -- Used for step-by-step analysis and modular query building
-- 2. CASE WHEN           -- Categorizes trip durations, times of day, and percentiles
-- 3. EXTRACT()           -- Extracts parts of timestamps (e.g., hour, duration in minutes)
-- 4. ROUND()             -- Rounds numeric results for clean outputs
-- 5. FILTER()            -- Conditional aggregation (e.g., surge trip counts)
-- 6. PERCENTILE_CONT()   -- Finds percentiles for grouping (trip volumes)
-- 7. RANK(), LAG()       -- Used to rank and compare across groups and time windows
-- 8. ROLLUP()            -- Adds subtotals and grand totals in payment breakdowns
-- 9. Window Functions    -- Used with AVG(), RANK(), LAG() for advanced comparisons
--10. COALESCE()          -- Handles NULLs in group labels

--------------------------------------------------------------------------------------------------------------------------

-- 1. Analyze the distribution of trip durations and their impact on total revenue. How do different trip durations correlate with costs?

-- Finds trip durations in minutes and groups them into short, medium, or long. Calculates total revenue per group
WITH duration_details AS (
    SELECT
        trip_id,
        ROUND(EXTRACT(EPOCH FROM (DROP_OFF_TIME - PICKUP_TIME)) / 60, 2) AS duration,
        fare_amount + surge_fee AS total_cost
    FROM td_locations
),
categorized AS (
    SELECT
        *,
        CASE
            WHEN duration < 15 THEN 'Short'
            WHEN duration BETWEEN 15 AND 30 THEN 'Medium'
            ELSE 'Long'
        END AS duration_category
    FROM duration_details
),
-- Finds average minutes and average revenue for each group
avg_stats AS (
    SELECT
        duration_category,
        AVG(duration) AS avg_duration,
        AVG(total_cost) AS avg_cost
    FROM categorized
    GROUP BY duration_category
),
-- Finds revenue per minute for each group
cost_metrics AS (
    SELECT
        *,
        avg_cost / avg_duration AS cost_per_minute
    FROM avg_stats
)
-- Finds percent change in revenue per minute for each group
SELECT 
    *,
    ((cost_per_minute - LAG(cost_per_minute) OVER (ORDER BY avg_duration)) / 
    LAG(cost_per_minute) OVER (ORDER BY avg_duration)) * 100 AS pct_change
FROM cost_metrics
ORDER BY avg_duration ASC;

/* 
Answer: While longer trips contribute more to total revenue, they are significantly less efficient in terms of revenue per minute.
The analysis reveals a 64% drop in revenue per minute when comparing long-duration trips (30 minutes) to medium-duration trips (15-30 minutes).
This inverse relationship suggests that longer trips may be affected by fare structures such as capped rates, pricing incentives, or discounts
that diminish marginal returns over time. For drivers aiming to optimize earnings on a per-minute basis, targeting shorter trips may yield
better financial efficiency.
*/

--------------------------------------------------------------------------------------------------------------------------

-- 2. How prevalent is surge pricing across different cities, and what insights can be drawn about its contribution to revenue and customer cost impact?

WITH surge_details AS (
	SELECT 
		pickup_city,
		COUNT(trip_id) AS total_trips,
		COUNT(trip_id) FILTER (WHERE surge_fee > 0) AS surge_trips,
		(COUNT(trip_id) FILTER (WHERE surge_fee > 0)::NUMERIC / COUNT(trip_id)) * 100 AS surge_trip_rate,
		SUM(surge_fee) AS surge_revenue,
		(SUM(surge_fee) / SUM(fare_amount)) * 100 AS surge_pct_of_fare
	FROM td_locations
	WHERE pickup_city NOT IN ('Newark, New Jersey', 'N/A')
	GROUP BY pickup_city
) 
SELECT
	pickup_city,
	surge_trips,
	surge_trip_rate,
	AVG(surge_trip_rate) OVER () AS avg_surge_trip_rate,
	surge_trip_rate - AVG(surge_trip_rate) OVER () AS surge_trip_gap,
	surge_revenue,
	surge_pct_of_fare,
	AVG(surge_pct_of_fare) OVER () AS avg_surge_pct_of_fare,
	surge_pct_of_fare - AVG(surge_pct_of_fare) OVER () AS surge_rev_gap
FROM surge_details
ORDER BY surge_revenue DESC;

/*
Answer: Manhattan consistently ranks highest across all surge-related metrics, contributing the largest share of surge revenue in the dataset.
Across most New York City boroughs, the prevalence of surge pricing is relatively consistent, with surge trips comprising approximately
60% to 65% of total trips — closely aligned with the citywide average.The proportion of fare attributed to surge fees remains steady
around 15% across cities. This indicates a relatively uniform impact of surge pricing on customer costs. Newark, NJ, represented by only a single
trip, lacks sufficient data for meaningful comparison and should be excluded from further analysis.
*/

--------------------------------------------------------------------------------------------------------------------------

-- 3. When are the best times for an Uber driver to work throughout the day?

-- Categorizes different pickup hours into morning, afternoon, and night. Calculates total revenue
WITH categorized AS (
    SELECT
    	trip_id,
    	CASE
	        WHEN EXTRACT(hour FROM pickup_time) BETWEEN 5 AND 11 THEN 'Morning'
	        WHEN EXTRACT(hour FROM pickup_time) BETWEEN 12 AND 16 THEN 'Afternoon'
	        WHEN EXTRACT(hour FROM pickup_time) >= 17 OR EXTRACT(hour FROM pickup_time) < 5 THEN 'Night'
	    END AS time_of_day,
    EXTRACT(hour FROM pickup_time) AS pickup_hour,
    fare_amount + surge_fee AS total_revenue
	FROM td_locations
),
-- Groups metrics into pickup hour and time of day
time_analysis AS (
	SELECT
		time_of_day,
		pickup_hour,
		COUNT(trip_id) AS total_trips,
		SUM(total_revenue) AS total_rev_per
	FROM categorized
	GROUP BY
		time_of_day,
		pickup_hour
)
-- Finds the busiest hour, based on total trips, during each time of day
SELECT *
FROM (
	SELECT
		time_of_day,
		pickup_hour AS peak_hour,
		total_trips,
		total_rev_per,
		RANK() OVER (PARTITION BY time_of_day ORDER BY total_trips DESC) AS rank
	FROM time_analysis
) AS t1
WHERE rank = 1
ORDER BY total_trips DESC;

/*
Answer: Uber riders most commonly request trips during the afternoon, followed by night and morning.
Drivers should work during peak hours at 3pm, 5pm and 11am.
*/ 

--------------------------------------------------------------------------------------------------------------------------

-- 4. What is the distribution of trips across different cities and how do they compare? 

WITH city_trip_counts AS (
	SELECT
		pickup_city,
		COUNT(trip_id) AS total_trips
	FROM td_locations
	WHERE pickup_city NOT IN ('N/A', 'Newark, New Jersey')
	GROUP BY pickup_city
),
percentiles AS (
	SELECT
		PERCENTILE_CONT(0.33) WITHIN GROUP(ORDER BY total_trips) AS bottom_percentile,
		PERCENTILE_CONT(0.66) WITHIN GROUP(ORDER BY total_trips) AS top_percentile
	FROM city_trip_counts
),
categorized AS (
	SELECT
		pickup_city,
		total_trips,
		CASE
			WHEN total_trips <= (SELECT bottom_percentile FROM percentiles) THEN 'Bottom Percentile'
			WHEN total_trips <= (SELECT top_percentile FROM percentiles) THEN 'Middle Percentile'
			ELSE 'Top Percentile'
		END AS percentile_category
	FROM city_trip_counts
)
SELECT
	pickup_city,
	percentile_category,
	total_trips,
	ROUND((total_trips / (SELECT SUM(total_trips) FROM city_trip_counts)) * 100, 2) AS total_trip_pct
FROM categorized
ORDER BY
	CASE
		WHEN percentile_category = 'Top Percentile' THEN 1
		WHEN percentile_category = 'Middle Percentile' THEN 2
		WHEN percentile_category = 'Bottom Percentile' THEN 3
	END,
	total_trips DESC;

/*
Answer: Manhattan and Queens are positioned in the top percentile, collectively representing 78% of the total trips in the dataset.
Brooklyn falls within the middle percentile, contributing approximately 20% of the trip volume. The Bronx, along with
Staten Island, account for the remaining trip counts, highlighting a significant disparity in trip distribution across the boroughs.
*/ 

--------------------------------------------------------------------------------------------------------------------------

-- 5. How does the distribution of payment types vary across different regions and cities?

SELECT
    COALESCE(pickup_city, 'All Pickup Cities') AS pickup_city,
    COALESCE(payment_type, 'All Payment Types') AS payment_type,
    COUNT(trip_id) AS trip_count
FROM td_locations
WHERE pickup_city not in ('N/A','Newark, New Jersey')
GROUP BY
    ROLLUP(pickup_city, payment_type)
ORDER BY
    pickup_city,
    trip_count DESC;

/*
Answer: Uber Pay is the clear preferred payment method for riders, with the highest amount of
transactions in each city. Cash is second, followed by Amazon Pay and Google Pay. Payment preferences
by riders remain the same for each city.
*/

--------------------------------------------------------------------------------------------------------------------------

-- 6. Highlight peak surge periods for each city.

-- Finds average surge fee for each hour in each city
WITH surge_by_hour
AS (
	SELECT pickup_city,
		EXTRACT(HOUR FROM pickup_time) AS pickup_hour,
		round(avg(surge_fee), 2) AS avg_surge
	FROM td_locations
	GROUP BY
	pickup_city,
		EXTRACT(HOUR FROM pickup_time)
	),
-- Ranks the surge fee by pickup city from highest to lowest
ranked
AS (
	SELECT
		*,
		rank() OVER (PARTITION BY pickup_city ORDER BY avg_surge DESC) AS surge_rank
	FROM surge_by_hour
	)
-- Retrieves the pickup hour with the highest avg_surcharge per city, showing peak surge periods per city
SELECT *
FROM ranked
WHERE surge_rank = 1
	AND pickup_city not in ('N/A','Newark, New Jersey')
ORDER BY avg_surge desc;

/*
Answer: Staten Island has the highest average surge per hour, followed up by The Bronx and Queens, which
can be attributed to lower driver supply in early morning hours. The remaining cities have peak surge
periods from 5-6pm and at 10pm, indicating busier travel periods during the evening.
*/

--------------------------------------------------------------------------------------------------------------------------

-- 7. Which kinds of vehicles do Uber riders prefer? Does customer preference change based on trip length?

SELECT
    vehicle,
    COUNT(trip_id) AS total_trips,
    ROUND(AVG((EXTRACT(epoch FROM(drop_off_time - pickup_time)) / 60)), 2) AS avg_duration,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(SUM(fare_amount + surge_fee), 2) AS total_revenue
FROM td_locations
GROUP BY
    vehicle
ORDER BY
    total_trips DESC,
    avg_duration DESC,
    avg_distance DESC;

/*
Answer: UberX is the most commonly preferred vehicle. There is insufficient variance between average trip durations
and distance to establish a correlation between vehicle type and trip durations and/or distance. Despite vehicle selection,
average trip times steady around 15 minutes and 3.3 miles in distance.
*/

--------------------------------------------------------------------------------------------------------------------------

-- 8. Which cities have the highest average fare per mile traveled? Exclude trips under 1 mile.

SELECT
	PICKUP_CITY,
	ROUND((SUM(FARE_AMOUNT) / SUM(TRIP_DISTANCE)), 2) AS AVG_FARE_PER_MILE
FROM
	TD_LOCATIONS
WHERE
	TRIP_DISTANCE >= 1
	AND PICKUP_CITY <> 'N/A'
GROUP BY
	PICKUP_CITY
ORDER BY
	AVG_FARE_PER_MILE DESC
LIMIT
	5;

-- Answer: Manhattan, The Bronx, Brooklyn, Staten Island, Queens

--------------------------------------------------------------------------------------------------------------------------

-- 9. What are the top 5 cities by total revenue generated over the last 3 years?

SELECT
	PICKUP_CITY,
	ROUND(SUM(FARE_AMOUNT + SURGE_FEE), 2) AS TOTAL_CITY_REVENUE
FROM
	TD_LOCATIONS
WHERE
	PICKUP_TIME >= CURRENT_TIMESTAMP - INTERVAL '3 years'
	AND PICKUP_CITY <> 'N/A'
GROUP BY
	PICKUP_CITY
ORDER BY
	TOTAL_CITY_REVENUE DESC
LIMIT
	5;

-- Answer: Manhattan, Queens, Brooklyn, The Bronx, Staten Island

--------------------------------------------------------------------------------------------------------------------------

-- 10. What is the average trip duration and distance by city and vehicle type?

SELECT
	PICKUP_CITY,
	VEHICLE,
	AVG(
		EXTRACT(EPOCH FROM (DROP_OFF_TIME - PICKUP_TIME)) / 60) AS AVG_DURATION,
	AVG(TRIP_DISTANCE) AS AVG_DISTANCE
FROM
	TD_LOCATIONS
GROUP BY
	PICKUP_CITY,
	VEHICLE
ORDER BY
	PICKUP_CITY;

