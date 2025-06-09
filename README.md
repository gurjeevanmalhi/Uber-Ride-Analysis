# Uber Trip Analysis

## Project Overview

Uber Technologies Inc. is a global leader in the ride-sharing industry, operating since 2009. The company connects riders and drivers through its mobile platform, offering a scalable and flexible alternative to traditional taxi services. Uber’s business model is built on dynamic pricing, on-demand availability, and widespread coverage. Key business metrics include trip volume, fare revenue, driver utilization, and wait times.

In August 2024, Uber’s Regional Operations team requested a deep-dive into ride activity across the state of New York, as customers had reported concerns about long wait times, inconsistent pricing, and limited driver availability. The objective of this analysis was to identify when and where service gaps are occurring, uncover patterns in rider behavior, and evaluate pricing performance to support decisions around resource planning, pricing adjustments, and market strategy.

Insights from this project will be delivered to the Operations, Marketing, and Finance teams to improve driver distribution, develop targeted campaigns based on rider behavior, and evaluate fare structures and the impact of surge pricing.

Insights and recommendations are provided on the following key areas:

- Trip Volume and Timing: Identifying peak usage periods to support scheduling and driver coverage.
- Geographic Demand Patterns: Analyzing high and low-demand zones to optimize driver deployment.
- Fare and Surge Pricing: Evaluating fare structures and the impact of surge pricing on revenue.
- Passenger and Trip Behavior: Understanding trends in ride distance, passenger count, and trip frequency.

Targeted SQL queries regarding various business questions can be found [here](Business%20Problems.sql).

An interactive Power BI dashboard used to report and explore ride trends can be found [here](Uber%20Trips%20Dashboard.pbix).

---

## Data Structure

The company’s main database structure for this project consists of two primary tables: trip_details and locations, with a total row count of 104,003 records combined. A description of each table is as follows:

- Trip Details: contains fact details for each Uber ride, including trip times, passenger count, distances, pickup and drop-off locations, payment details, and vehicle type.
- Locations: contains unique location IDs, neighborhood names, and the city in which each location exists.

![ERD](Entity%20Relationship%20Diagram.png)

---

## Technologies and Key Skills Used

1. PostgreSQL
2. Power BI
3. Power Query
4. DAX
5. Data Modeling
6. Data Visualization
7. Excel

## Files

1. Business Problems: contains queries answering business questions
2. Dashboard.pbix: Power BI dashboard
3. Database Design: intitial database set up queries
4. Completed Dashboard Images: JPG images of dashboard
5. Images and Icons: contains images and icons used in dashboard
6. Problem Statement: contains business problems answered for Power BI report
7. Location Table: dataset for locations
8. Uber Trip Details: dataset for Uber trips



### Trip Details Table:
- Trip ID: Unique identifier for each trip.
- Pickup Time: Date and time when passenger was picked up.
- Drop Off Time: Date and time when passenger was dropped off.
- Passenger Count: Number of passengers in each trip.
- Trip Distance: Miles traveled during each trip.
- PULocationID: Pickup location identifier.
- DOLocationID: Drop-off location identifier.
- Payment Type: Mode of payment for each trip.
- Fare Amount: Base fare amount for each trip.
- Surge Fee: Additional charge applied during high-demand periods.
- Vehicle: Type of Uber service (vehicle type).

## Location Table
  
### Location Table:
- LocationID: Unique identifier for each location.
- Location: Name of the area or neighborhood.
- City: City in which the location exists.
