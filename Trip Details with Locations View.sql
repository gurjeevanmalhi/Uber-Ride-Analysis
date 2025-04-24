-- Trip Details with Locations View

create view td_locations as
    select
        t.*,
        l1.location as pickup_location,
        l1.city as pickup_city,
        l2.location as dropoff_location,
        l2.city as dropoff_city
    from trip_details as t 
    left join locations as l1 
        on t.PULocationID = l1.LocationID
     left join locations as l2
        on t.DOLocationID = l2.LocationID;