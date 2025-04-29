-- Business Problems and Solutions

select *
from td_locations;

-- 1. What are the top 5 cities by total revenue generated over the last 3 years?

select top 5
    pickup_city,
    round(sum(fare_amount + surge_fee),2) as total_city_revenue
from td_locations
where
    pickup_time >= dateadd(year,-3,getdate())
    and pickup_city <> 'N/A'
group by pickup_city
order by total_city_revenue desc;

-- Answer: Manhattan, Queens, Brooklyn, The Bronx, Staten Island

-- 2. What is the average trip duration and distance by city and vehicle type?

select
    pickup_city,
    vehicle,
    avg(datediff(minute,pickup_time,drop_off_time)) as avg_trip_duration,
    avg(trip_distance) as avg_distance
from td_locations
group by
    pickup_city,
    vehicle
order by pickup_city;

-- 4. What is the average surge fee by hour in each city? Highlight peak surge periods.

-- Finds average surge fee by pickup hour and city
with surge_by_hour as(
    select
        pickup_city,
        datepart(hour,pickup_time) as pickup_hour,
        round(avg(surge_fee),2) as avg_surge
    from td_locations
    group by
        pickup_city,
        DATEPART(HOUR,pickup_time)

),
-- Ranks the surcharge by pickup city from highest to lowest
ranked as(
    select
        *,
        rank() over(partition by pickup_city order by avg_surge desc) as surge_rank
    from surge_by_hour

)

-- Retrieves the pickup hour with the highest avg_surcharge per city, highlighting peak surge periods per city
select *
from ranked
where surge_rank = 1
   and pickup_city <> 'N/A'
order by pickup_city;

-- 5. Which cities have the highest average fare per mile traveled? Exclude trips under 1 mile.

select top 5
    pickup_city,
    round((sum(fare_amount)/sum(trip_distance)),2) as avg_fare_per_mile
from td_locations
where trip_distance >= 1
and pickup_city <> 'N/A'
group by pickup_city
order by avg_fare_per_mile desc;

-- 6. How prevalent is surge pricing across different cities, and what insights can be drawn about its contribution to revenue and customer cost impact?

with trip_counts as (
    select 
        pickup_city,
        count(trip_id) as total_trips,
        -- could use WHERE clause inside SELECT here but unable to do so with T-SQL. Used CASE instead
        sum(case when surge_fee > 0 then 1 else 0 end) as surge_trips,
        round(sum(surge_fee),2) as total_surge_revenue,
        round(sum(surge_fee)/sum(fare_amount) * 100,2) as surge_cost_pct
    from td_locations
    where pickup_city <> 'N/A'
    group by
        pickup_city
)

select
    pickup_city,
    total_trips,
    round((cast(surge_trips as float) / total_trips * 100),2) as surge_pct_of_trips,
    surge_cost_pct,
    total_surge_revenue
from trip_counts
order by
    total_surge_revenue desc,
    surge_cost_pct desc,
    surge_pct_of_trips desc;

/* Answer: Newark, NJ accounts for only a single trip in this dataset and should be excluded from further analysis due to insufficient data volume.
Among the remaining cities, Manhattan consistently leads across all categories, generating the highest surge revenue in New York.
The percentage of trips that include a surge fee remains relatively stable across cities, ranging from approximately 60% to 65%, with a minimum of
at least half of total trips. Similarly, surge costs to the consumer tend to hover around 15%, despite significant differences in
total trip volume by city.
*/

-- 7. Analyze the distribution of trip durations and their impact on total revenue. How do different trip durations correlate with costs?


-- Finds trip durations in minutes and groups them into short, medium, or long. Calculates total revenue per group
with duration_analysis as (
    select
        trip_id,
        datediff(minute,pickup_time,drop_off_time) as duration,
        case 
            when datediff(minute,pickup_time,drop_off_time) < 15 then 'Short'
            when datediff(minute,pickup_time,drop_off_time) between 15 and 30 then 'Medium'
            when datediff(minute,pickup_time,drop_off_time) > 30 then 'Long'
            end as duration_category,
        fare_amount + surge_fee as total_revenue
    from td_locations

),
-- Finds average minutes and average revenue for each group
avg_stats as (
    select
        duration_category,
        avg(duration) as avg_duration,
        avg(total_revenue) as avg_revenue
    from duration_analysis
    group by duration_category

)

-- Finds revenue per minute for each group
select
    *,
    avg_revenue/avg_duration as revenue_per_minute,
    
from avg_stats;

/*
Answer: Despite increasing overall revenue with longer trips, the revenue per minute decreases as the trip duration increases.
This suggests that while longer trips generate more revenue, they may be less efficient in terms of revenue per minute. This could
indicate that for longer trips, the fare may be impacted by base fare caps, price strategies, or customer discounts that are less prominent
in shorter trips.
*/

-- 8. When are the best times for an Uber driver to work throughout the day?

-- Calculates revenue per each hour of the day and groups different times into morning, afternoon, or night
with time_analysis as(
    select
    case
        when datepart(hour,pickup_time) between 5 and 11 then 'Morning'
        when datepart(hour,pickup_time) between 12 and 16 then 'Afternoon'
        when datepart(hour,pickup_time) >= 17 or datepart(hour,pickup_time) < 5 then 'Night'
        end as time_of_day,
    DATEPART(hour,pickup_time) as pickup_hour,
    count(trip_id) as total_trips,
    sum(fare_amount + surge_fee) as total_revenue_per_hour
from td_locations
group by 
    case
            when datepart(hour,pickup_time) between 5 and 11 then 'Morning'
            when datepart(hour,pickup_time) between 12 and 16 then 'Afternoon'
            when datepart(hour,pickup_time) >= 17 or datepart(hour,pickup_time) < 5 then 'Night'
            end,
    DATEPART(hour,pickup_time)

)

-- Finds the busiest hour, based on total trips, during each time of day and calculates percent of revenue generated
select *
from(
    select
        time_of_day,
        pickup_hour as peak_hour,
        total_trips,
        (total_revenue_per_hour/sum(total_revenue_per_hour) over() * 100) as pct_of_revenue, 
        rank() OVER(partition by time_of_day order by total_trips desc) as rank
    from time_analysis
) as t1
where rank = 1
order by total_trips desc;

/* Answer: Uber riders most commonly request trips during the afternoon, followed by night and morning.
Drivers should work during peak hours at 11am, 3pm, and most notably 5pm. These 3 hours alone will generate
about 20% of drivers' daily gross pay.
*/ 

-- 9. Which kinds of vehicles do Uber riders prefer? Does customer preference change based on trip length?

select
    vehicle,
    count(trip_id) as total_trips,
    round(avg(datediff(minute,pickup_time,drop_off_time)),2) as avg_duration,
    round(avg(trip_distance),2) as avg_distance,
    round(sum(fare_amount + surge_fee),2) as total_revenue
from td_locations
group by
    vehicle
order by
    total_trips desc,
    avg_duration desc,
    avg_distance desc;

/* Answer: UberX is the most commonly preferred vehicle. There is insufficient variance between average trip durations
and distance to establish a correlation between vehicle type and trip durations and/or distance. Despite vehicle selection,
average trip times steady around 15 minutes and 3.3 miles in distance.
*/

-- 11. What is the average number of passengers per trip by vehicle type?

    select
        vehicle,
        avg(passenger_count) as avg_passengers
    from td_locations
    group by
        vehicle;

-- Answer: 1 passenger per vehicle

-- 12. What are the trends in trip volume and revenue for each city by day or week?

-- 13. Identify the top 10 pickup locations with the highest average surge fees.

-- 14. What is the average time between trips (lag) by vehicle type in each city?

-- 15. Rank cities by trip efficiency (distance per minute) and identify the top and bottom 3.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* 
-- 16. How does the distribution of payment types vary across different regions and cities, 
This question would help understand regional preferences in payment methods, enabling
 targeted marketing or promotional strategies based on payment behaviors.
*/

with payments as(

    select
    pickup_city,
    payment_type,
    -- total transactions per payment type and city
    count(payment_type) as transaction_count,
    -- Percent of each type of payment type per city
    (count(payment_type)*1.0 / sum(count(payment_type)) over(partition by pickup_city)*100) as transactions_pct_per_city,
    rank() over(partition by pickup_city order by count(payment_type) desc) as rank
from td_locations
where pickup_city <> 'N/A'
group by
    pickup_city,
    payment_type

)

select
    *,
    avg(transactions_pct_per_city) over(partition by payment_type) as avg_pct_payment,
    transactions_pct_per_city - avg(transactions_pct_per_city) over(partition by payment_type) as gap_vs_trend
from payments
where pickup_city <> 'Newark, New Jersey'
order by rank asc,
transaction_count desc;

/* Answer: Uber Pay is the clear preferred payment method for riders, ranking first in
every city, accounting for 65% of total transactions. Cash follows second, accounting for 
33% of transactions, with all else totaling less than 1%. Payment preferences by riders remain 
the same and vary by city. 

-- 17. What is the impact of surge pricing on payment type preferences?
/* 
   This question would assess whether surge pricing influences customers' choice of payment methods (e.g., credit card vs. mobile wallet), 
   and could guide decisions on payment processing fees or the introduction of new payment options during high-demand periods.
*/

-- 18. What is the correlation between the payment type used and the average fare amount, 
/* 
   This question explores whether customers using specific payment methods tend to pay higher fares or have distinct spending patterns, 
   potentially informing pricing strategies or customer loyalty initiatives.
*/


