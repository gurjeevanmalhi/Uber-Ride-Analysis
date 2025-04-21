-- Business Problems and Solutions

-- Notes
select *
from locations
where city = 'Queens';

select * 
from trip_details;

select 
    t.*,
    l.city as pickup_city,
    l2.city as dropoff_city,
    (t.fare_amount + t.surge_fee) as total_revenue
from trip_details as t
left join locations as l 
    on t.pulocationid = l.locationid
left join locations as l2
    on t.dolocationid = l2.locationid;

select surge_fee
from trip_details
order by surge_fee asc;


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

-- 3. What are the top 10 pickup and drop-off location pairs by number of trips?

-- 4. What is the average surge fee by hour of day and city? Highlight peak surge periods.

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
