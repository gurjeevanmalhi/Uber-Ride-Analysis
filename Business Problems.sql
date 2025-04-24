-- Business Problems and Solutions

-- 1. What are the top 5 cities by total revenue generated over the last 3 years?

with pickup_cities as (
    select
        (t.fare_amount + t.surge_fee) as total_ride_revenue,
        l.city as pickup_city,
        t.pickup_time
    from trip_details as t 
    left join locations as l 
        on t.pulocationid = l.locationid
    where t.pickup_time >= dateadd(year,-3,getdate())
)

select top 5
    pickup_city,
    round(sum(total_ride_revenue),2) as total_city_revenue
from pickup_cities
where pickup_city <> 'N/A'
group by pickup_city
order by total_city_revenue desc;


-- 2. What is the average trip duration and distance by city and vehicle type?

select
    l.city,
    t.vehicle,
    avg(datediff(minute,t.pickup_time,t.drop_off_time)) as avg_trip_duration,
    round(avg(t.trip_distance),2) as avg_distance
from trip_details as t 
left join locations as l 
    on t.pulocationid = l.locationid
group by
    l.city,
    t.vehicle
order by l.city;

-- 3. What are the top 10 pickup and drop-off location pairs by number of trips?

-- 4. What is the average surge fee by hour of day and city? Highlight peak surge periods.

-- calculates average surge fee by pickup hour and city
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
-- ranks the surcharge by pickup city from highest to lowest
ranked as(
    select
        *,
        rank() over(partition by pickup_city order by avg_surge desc) as surge_rank
    from surge_by_hour

)

-- retrieves the pickup hour with the highest avg_surcharge per city
select *
from ranked
where surge_rank = 1
    and pickup_city <> 'N/A'
order by pickup_city;

-- 5. Which cities have the highest average fare per mile traveled? Exclude trips under 1 mile.

-- 6. What percentage of trips include a surge fee, and how does this vary by city and vehicle type?

-- 7. Identify the top 10% of longest trips (by duration) and analyze their impact on total revenue.

-- 8. Which hours of the day have the highest trip volume by city? Show daypart trends using a window function.

-- 9. What is the revenue contribution by vehicle type across cities over the past year?

-- 10. Identify repeat pickup/drop-off pairs (same location ID) and calculate average fare and surge fee for those trips.

-- 11. What is the average number of passengers per trip by vehicle type and city?

-- 12. What are the trends in trip volume and revenue month-over-month for each city?

-- 13. Identify the top 10 pickup locations with the highest average surge fees.

-- 14. What is the average time between trips (lag) by vehicle type in each city?

-- 15. Rank cities by trip efficiency (distance per minute) and identify the top and bottom 3.
