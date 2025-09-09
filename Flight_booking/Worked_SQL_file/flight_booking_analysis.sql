create database flight_booking;
use flight_booking;

select * from airports;
select * from bookings;
select * from crew;
select * from flights;
select * from passengers;

/* On-time performance
Find the % of flights delayed per route and airline. */
select airline,source,destination,
       count(*) as Total_flights,
       sum(case when f.status = "delayed" then 1 else 0 end) as delayed_flights,
       round(
       100 * sum(case when f.status ="delayed" then 1 else 0 end) /
       nullif(sum(case when f.status in ("delayed","on time") then 1 else 0 end ) ,0),2) as delayed_percentage
from flights f
group by airline,source,destination
having delayed_percentage > 0.0 and destination is not null
order by delayed_percentage desc;		
    
/* Insights
Certain routes like GoAir Kolkata and IndiGo Chennai–Delhi have high delays (~30–33%), while most other routes fall between 15–25%.
Some airports (Kolkata, Chennai, Delhi) show consistent delays across multiple airlines, indicating systemic congestion or operational issues.
Data-Driven Suggestions
Focus on high-delay routes (>25%) for operational improvements, including crew scheduling, turnaround time, and airport coordination.*/

/*Most congested routes
Top 10 busiest source-destination routes.*/
 
 select source,destination,count(*) as total_flights
 from flights
 where status in ("on time","delayed")
 group by source,destination
 order by total_flights desc
 limit 10;
/* Insight
The top 10 busiest routes are concentrated on major metros like Kolkata, Mumbai, Chennai, Hyderabad, and Bengaluru, indicating high passenger traffic and potential congestion.
Data-Driven Suggestion
Prioritize operational efficiency and resource allocation (crew, ground handling, slot management) on these high-traffic routes to reduce delays and improve on-time performance.
*/

/* Top passengers by spend (loyalty analysis)
Who are the top 5 spenders per airline? */

with vips as (
 select p.passenger_id,p.name ,sum(b.amount) as total_spent 
 from passengers p
 join bookings b using (passenger_id)
 group by p.passenger_id,p.name 
 ),
 top_vips as (
    select *,rank() over( order by total_spent desc) as top_vips 
    from vips
)
select * from top_vips 
where top_vips <=5;
/* Insight
These passengers are the highest contributors to revenue, making them key targets for loyalty programs, VIP perks, and personalized marketing.
Data-Driven Suggestion
Focus on retention strategies like exclusive offers, frequent flyer bonuses, and priority services for these top 5 spenders to maximize lifetime value.*/

/* Booking frequency analysis
Find passengers who book multiple flights per month.*/

WITH yearly_stats AS (
    SELECT 
        p.passenger_id,
        p.name,
        EXTRACT(YEAR FROM b.booking_date) AS booking_year,
        COUNT(*) AS bookings_count,
        SUM(b.amount) AS total_spent
    FROM passengers p
    JOIN bookings b USING(passenger_id)
    WHERE EXTRACT(YEAR FROM b.booking_date) IN (2024, 2025)
    GROUP BY p.passenger_id, p.name, EXTRACT(YEAR FROM b.booking_date)
),
pivot_stats AS (
    SELECT
        passenger_id,
        name,
        COALESCE(MAX(CASE WHEN booking_year = 2024 THEN bookings_count END),0) AS bookings_2024,
        COALESCE(MAX(CASE WHEN booking_year = 2024 THEN total_spent END),0) AS spent_2024,
        COALESCE(MAX(CASE WHEN booking_year = 2025 THEN bookings_count END),0) AS bookings_2025,
        COALESCE(MAX(CASE WHEN booking_year = 2025 THEN total_spent END),0) AS spent_2025,
        COALESCE(MAX(CASE WHEN booking_year = 2024 THEN bookings_count END),0) +
        COALESCE(MAX(CASE WHEN booking_year = 2025 THEN bookings_count END),0) AS total_bookings,
        COALESCE(MAX(CASE WHEN booking_year = 2024 THEN total_spent END),0) +
        COALESCE(MAX(CASE WHEN booking_year = 2025 THEN total_spent END),0) AS total_spent_all
    FROM yearly_stats
    GROUP BY passenger_id, name
)
SELECT *,
       RANK() OVER(ORDER BY total_bookings DESC, total_spent_all DESC) AS rank_position
FROM pivot_stats
ORDER BY rank_position
limit 25;

/* Revenue by route
Which routes and airline contribute the most revenue?*/


select f.airline, f.source,f.destination,sum(b.amount) as total_revenue
from flights f
join bookings b using(flight_id)
where b.payment_status = "paid" 
group by f.airline, f.source,f.destination
order by total_revenue desc
limit 10 ;

/*Revenue leakage
Find cancelled flights vs lost revenue.*/

select airline,count(*) as cancelled_flights,
       sum(price)  as lost_revenue
from flights
where status ="cancelled"
group by airline
order by cancelled_flights desc;

/* Crew workload balance
Flights per role per month.*/

select c.role,count(flight_id) as no_of_flights,
	   date_format(f.departure_time,'%Y-%m') as work_days
from crew c
join flights f using(flight_id)
group by  c.role,date_format(f.departure_time,'%Y-%m');

# revenue per airport 

select a.city,sum(f.price) as revenue,date_format(b.booking_date,'%Y') as yearly
from airports a
join flights f on a.city=f.source
join bookings b on 
f.flight_id=b.flight_id
group by a.city,date_format(b.booking_date,'%Y')
order by a.city,yearly ;

/* Seasonality Analysis
Find the average monthly revenue per airline and detect seasonal peaks. */

with monthly_revenue as (
select airline,sum(price) as total_revenue,
       date_format(departure_time,'%Y-%M') as months
from flights 
group by airline,date_format(departure_time,'%Y-%M'))
select airline,avg(total_revenue) as avg_monthly_revenue
from monthly_revenue
group by airline
order by avg_monthly_revenue desc;

with peak_season as (
SELECT 
    airline,
    DATE_FORMAT(departure_time, '%Y-%m') AS month,
    SUM(price) AS monthly_revenue,
    RANK() OVER (PARTITION BY airline ORDER BY SUM(price) DESC) AS peak_rank
FROM flights

GROUP BY airline, DATE_FORMAT(departure_time, '%Y-%m')
ORDER BY airline, month
)
select* from peak_season
where peak_rank =1;

##  Booking Cancellation Rate
select 
 f.airline,
 count(*) as  total_bookings,
 sum(case when f.status= 'cancelled' then 1 else 0 end ) as cancelled_bookings,
 round((sum(case when f.status= 'cancelled' then 1 else 0 end ) /count(*)) * 100,2) as cancellation_rate_percentage
 from flights f
 join bookings b on f.flight_id=b.flight_id
 group by f.airline
 order by cancellation_rate_percentage desc;
 
 # Do last-minute bookings generate more revenue?
 select case when datediff(f.departure_time,b.booking_date) <= 3 then 'Last-Minute'
            when datediff(f.departure_time,b.booking_date) between 4 and 15 then 'Medium'
            else 'Early' end as booking_window,
            count(*) as total_tickets,
       sum(b.amount) as price
from bookings b
join flights f using(flight_id)
group by booking_window
order by price desc ;

 WITH passengers_2024 AS (
    SELECT DISTINCT b.passenger_id, f.airline
    FROM bookings b
    JOIN flights f USING(flight_id)
    WHERE EXTRACT(YEAR FROM b.booking_date) = 2024
),
passengers_2025 AS (
    SELECT DISTINCT b.passenger_id, f.airline
    FROM bookings b
    JOIN flights f USING(flight_id)
    WHERE EXTRACT(YEAR FROM b.booking_date) = 2025
),
retained AS (
    SELECT p24.airline, COUNT(DISTINCT p24.passenger_id) AS retained_customers
    FROM passengers_2024 p24
    JOIN passengers_2025 p25
      ON p24.passenger_id = p25.passenger_id
     AND p24.airline = p25.airline
    GROUP BY p24.airline
),
totals AS (
    SELECT airline, COUNT(DISTINCT passenger_id) AS total_customers_2024
    FROM passengers_2024
    GROUP BY airline
)
SELECT t.airline,
       t.total_customers_2024,
       r.retained_customers,
       ROUND(100.0 * r.retained_customers / NULLIF(t.total_customers_2024,0), 2) AS retention_rate
FROM totals t
LEFT JOIN retained r ON t.airline = r.airline
ORDER BY retention_rate DESC;

#how many unique airlines they have traveled

SELECT 
    p.passenger_id,
    p.name,
    COUNT(DISTINCT f.airline) AS airlines_traveled
FROM passengers p
JOIN bookings b USING(passenger_id)
JOIN flights f USING(flight_id)
GROUP BY p.passenger_id, p.name
ORDER BY airlines_traveled DESC;

# experienced crew members are paid fairly compared to their peers in the same role & airline.

WITH crew_stats AS (
    SELECT 
        f.airline,
        c.role,
        c.name,
        c.experience_years,
        c.salary,
        AVG(c.salary) OVER(PARTITION BY f.airline, c.role) AS avg_role_salary,
        AVG(c.experience_years) OVER(PARTITION BY f.airline, c.role) AS avg_role_experience
    FROM crew c
    JOIN flights f USING(flight_id)
)
SELECT 
    airline,
    role,
    name,
    experience_years,
    salary,
    avg_role_salary,
    avg_role_experience,
    CASE 
        WHEN salary < avg_role_salary AND experience_years > avg_role_experience THEN '⚠ Underpaid'
        WHEN salary > avg_role_salary AND experience_years < avg_role_experience THEN '💰 Overpaid'
        ELSE 'Fairly Paid'
    END AS pay_status
FROM crew_stats
ORDER BY airline, role, pay_status;

# Airlines want to analyze seat-class utilization and revenue leakage.

WITH seat_stats AS (
    SELECT 
        f.airline,
        f.flight_id,
        b.seat_no,
        b.class,
        b.amount,
        COUNT(*) OVER(PARTITION BY f.flight_id, b.class) AS total_booked_in_class,
        COUNT(*) OVER(PARTITION BY f.flight_id) AS total_booked_in_flight,
        SUM(b.amount) OVER(PARTITION BY f.flight_id, b.class) AS revenue_per_class,
        SUM(b.amount) OVER(PARTITION BY f.flight_id) AS total_revenue_flight
    FROM bookings b
    JOIN flights f ON b.flight_id = f.flight_id
    WHERE b.payment_status = 'Paid'
)
SELECT 
    airline,
    flight_id,
    class,
    total_booked_in_class,
    total_booked_in_flight,
    ROUND((total_booked_in_class * 100.0 / total_booked_in_flight),2) AS class_utilization_pct,
    revenue_per_class,
    total_revenue_flight,
    ROUND((revenue_per_class * 100.0 / total_revenue_flight),2) AS revenue_share_pct
FROM seat_stats
GROUP BY airline, flight_id, class, total_booked_in_class, total_booked_in_flight, revenue_per_class, total_revenue_flight
ORDER BY airline, flight_id, revenue_share_pct DESC;

# Airlines want to identify Top Passengers by Class Preference (Business / First / Economy)

WITH passenger_class_stats AS (
    SELECT 
        p.passenger_id,
        p.name,
        f.airline,
        b.class,
        COUNT(b.booking_id) AS total_flights,
        SUM(b.amount) AS total_spent
    FROM passengers p
    JOIN bookings b ON p.passenger_id = b.passenger_id
    JOIN flights f ON b.flight_id = f.flight_id
    JOIN airports a ON f.source = a.city   -- extra join to show departure airport info
    WHERE b.payment_status = 'Paid'
    GROUP BY p.passenger_id, p.name, f.airline, b.class
),
ranked_passengers AS (
    SELECT 
        passenger_id,
        name,
        airline,
        class,
        total_flights,
        total_spent,
        RANK() OVER(PARTITION BY airline, class ORDER BY total_spent DESC) AS class_rank
    FROM passenger_class_stats
)
SELECT *
FROM ranked_passengers
WHERE class_rank <= 5 and class = "Business"
ORDER BY airline, class, class_rank;

