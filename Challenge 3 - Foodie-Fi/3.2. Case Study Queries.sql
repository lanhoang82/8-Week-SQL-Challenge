/*Case Study Questions
This case study is split into an initial data understanding question before diving straight into 
data analysis questions before finishing with 1 single extension challenge.

A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief 
description about each customer’s onboarding journey.

Customer 1, 2, 3, 5 started out with a trial and converted to either a basic or pro plan ever since.
Customer 7, 8 started out with a trial, then converted to a basic plan but later on converted to a pro plan.
Customer 4, 6 started out with a trial, the converted to the basic plan but then churned a couple of months later.


Try to keep it as short as possible - you may also want to run some sort of join to make your explanations 
a bit easier!*/

SELECT customer_id, s.plan_id, start_date, plan_name FROM subscriptions AS s
LEFT JOIN plan AS p
ON p.plan_id = s.plan_id
WHERE customer_id <= 8;

/*B. Data Analysis Questions
1. How many customers has Foodie-Fi ever had?*/
SELECT COUNT(DISTINCT customer_id) 
FROM subscriptions;

/*2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the 
month as the group by value*/
SELECT EXTRACT(MONTH from start_date) "start_month", COUNT(customer_id)
FROM subscriptions
WHERE plan_id = 0
GROUP BY start_month
ORDER BY start_month ASC;

/*3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of 
events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?