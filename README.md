# Uber Rides Analysis

## Project Overview

Uber Technologies Inc. is a global leader in the ride-sharing industry, operating since 2009. The company connects riders and drivers through its mobile platform, offering a scalable and flexible alternative to traditional taxi services. Uber’s business model is built on dynamic pricing, on-demand availability, and widespread coverage. Key business metrics include trip volume, fare revenue, driver utilization, and wait times.

In August 2024, Uber’s Regional Operations team requested a deep-dive into ride activity across the state of New York, as customers had reported concerns about long wait times, inconsistent pricing, and limited driver availability. The objective of this analysis was to identify when and where service gaps are occurring, uncover patterns in rider behavior, and evaluate pricing performance to support decisions around resource planning, pricing adjustments, and market strategy.

Insights from this project will be delivered to the Operations, Marketing, and Finance teams to improve driver distribution, develop targeted campaigns based on rider behavior, and evaluate fare structures and the impact of surge pricing.

Insights and recommendations are provided on the following key areas:

- Customer Behavior: Analyzing payment preferences, preferred vehicle types, and location patterns to understand rider habits and regional demand.
- Revenue Trends: Exploring city-level revenue distribution and surge-related income to identify opportunities for profitability and operational efficiency.
- Ride Times and Duration: Examining ride distributions throughout the day, peak hours and days, and average distances to uncover demand cycles and trip characteristics.

Targeted SQL queries regarding various business questions can be found [here](Exploratory%20Data%20Analysis.sql).

An interactive Power BI dashboard used to report and explore ride trends can be found [here](Uber%20Trips%20Dashboard.pbix).

---

## Data Structure

The company’s main database structure for this project consists of two primary tables: trip_details and locations, with a total row count of 104,003 records combined. A description of each table is as follows:

- Trip Details: contains fact details for each Uber ride, including trip times, passenger count, distances, pickup and drop-off locations, payment details, and vehicle type.
- Locations: contains unique location IDs, neighborhood names, and the city in which each location exists.

![ERD](Entity%20Relationship%20Diagram.png)

---

## Executive Summary

### Overview of Findings

Uber's highest volume and revenue consistently come from Manhattan, however the proportion of fare attributed to surge fees remains steady around 15% across cities — suggesting a uniform customer impact despite regionality. The majority of bookings occur during daytime hours, with Uber Pay being the most common payment method. Despite rider access to various vehicle types, trip costs and durations remain relatively consistent, suggesting Uber’s pricing and routing strategies effectively standardize the rider experience across services.

![Business Overview](Dashboard%20PDFs/Business%20Overview.jpg)

---

## Insights Deep Dive

### Customer Behavior

- Most rides are scheduled during daytime hours, which account for 63% of total ride volume. Demand peaks in the afternoon, followed by night and morning, with the highest activity observed around 3PM, 5PM, and 11AM.
- UberX is the most preferred service option, representing 37% of all rides. Ride durations and distances remain consistent across vehicle types, suggesting a similar experience across service tiers.
- Uber Pay is the most commonly used payment method, making up 70% of all transactions across cities.

### Revenue Trends

- Manhattan leads overall revenue regionally, generating $922,669 and accounting for 59% of total ride revenue. This concentration suggests a strong demand hub, likely driven by dense population, tourism, and commercial activity.
- Surge fees contribute a consistent 15% of total fare revenue across cities, indicating a uniform pricing impact regardless of geography. This stability helps with predictable revenue forecasting and pricing strategy development.
- Longer rides bring in higher total revenue but yield less per minute, with a 64% drop in revenue per minute when comparing rides over 30 minutes to those between 15–30 minutes. This suggests diminishing financial returns on extended trips.

![Details Analysis](Dashboard%20PDFs/Details%20Analysis.jpg)

### Ride Times and Duration

- Afternoon hours drive the highest ride volume. Ride activity peaks in the afternoon, followed by night and morning. The most requested times are 3 PM, 5 PM, and 11 AM, with a noticeable spike around 5 PM—likely tied to commuter and post-work travel behavior.
- Saturday records the highest number of ride requests, accounting for 19% of total rides. This indicates increased weekend demand, possibly due to social plans, events, and leisure travel.
- Average ride durations remain consistent across cities and vehicle types. Despite differences in geography and ride preferences, the average ride lasts around 16 minutes.

![Time Analysis](Dashboard%20PDFs/Time%20Analysis.jpg)

---

## Recommendations

Based on the insights and findings above, we would recommend the Operations, Finance, and Marketing teams to consider the following:

- High volume of rides during daytime and peak hours: Operations should optimize driver schedules and deployment to match peak demand times, especially around 3pm and 5pm, to improve availability and reduce wait times.
- Uber Pay is the dominant payment method (70%): Finance and Marketing teams can focus on promoting and enhancing the Uber Pay experience, including potential loyalty or incentive programs, to strengthen customer retention.
- Manhattan accounts for 59% of revenue and shows strong surge pricing impact: Marketing and Operations should prioritize targeted promotions and dynamic driver incentives in Manhattan to capitalize on surge revenue opportunities while ensuring customer satisfaction.
- Ride distribution peaks on Saturdays (19% of total rides): Marketing campaigns and special offers could be timed to boost weekday ridership, balancing demand and improving revenue stability throughout the week.
- Longer rides yield lower revenue per minute: Finance and Operations may explore pricing adjustments or incentives encouraging a mix of ride lengths to optimize driver earnings and company profitability.

--- 

## Assumptions and Caveats

Throughout the analysis, the following assumptions were made to manage challenges with the data. These assumptions and caveats are noted below:

- Newark, NJ was excluded from analysis due to lack of sufficent data.

## Technologies and Key Skills Used

1. PostgreSQL
2. Power BI
3. Power Query
4. DAX
5. Excel
6. Data Analysis
7. Data Modeling
8. Data Visualization
