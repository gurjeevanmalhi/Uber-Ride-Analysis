# Uber Trip Analysis

## Overview

This project aims to analyze Uber trip data from the state of New York, leveraging PostgreSQL for data analysis to answer key business questions. It features two interactive dashboards created in Power BI, providing deeper insights into ride demand, revenue patterns, and trip efficiency. The dashboards are designed to empower stakeholders with data-driven insights, enabling them to optimize operational performance effectively.

## Project Goals

1. Provide insights into Uber trip trends in New York.
2. Visualize ride demand and peak hours.
3. Analyze revenue patterns and trip efficiency.
4. Create an interactive experience to explore and analyze data

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

## Dataset

The dataset consists of two primary tables:

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
### Location Table:
- LocationID: Unique identifier for each location.
- Location: Name of the area or neighborhood.
- City: City in which the location exists.
