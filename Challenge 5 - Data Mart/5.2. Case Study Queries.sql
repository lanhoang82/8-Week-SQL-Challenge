/*Case Study Questions
The following case study questions require some data cleaning steps before we start to unpack Danny’s key 
business questions in more depth.

A. Data Cleansing Steps
In a single query, perform the following operations and generate a new table in the data_mart schema named 
clean_weekly_sales:

1. Convert the week_date to a DATE format
2. Add a week_number as the second column for each week_date value, for example any value from the 1st of 
January to 7th of January will be 1, 8th to 14th will be 2 etc
3. Add a month_number with the calendar month for each week_date value as the 3rd column
4. Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
5. Add a new column called age_band after the original segment column using the following mapping on the 
number inside the segment value
6. Add a new demographic column using the following mapping for the first letter in the segment values:
7. Ensure all null string values with an "unknown" string value in the original segment column as well as the 
new age_band and demographic columns
8. Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal 
places for each record*/

DROP TABLE IF EXISTS data_mart.clean_weekly_sales;
CREATE TABLE data_mart.clean_weekly_sales AS -- create a new table based on the result set of a SELECT query
	SELECT TO_DATE(week_date, 'dd/mm/yy') AS week_date,
	EXTRACT (WEEK FROM TO_DATE(week_date, 'dd/mm/yy')) AS week_number,
	EXTRACT (MONTH FROM TO_DATE(week_date, 'dd/mm/yy')) AS month_number,
	EXTRACT (YEAR FROM TO_DATE(week_date, 'dd/mm/yy')) AS calendar_year,
	region,
	platform,
	segment,
	customer_type, transactions, sales,
	CASE 
		WHEN segment LIKE '%1' THEN 'Young Adults'
		WHEN segment LIKE '%2' THEN 'Middle Aged'
		WHEN segment LIKE '%3' OR segment LIKE '%4' THEN 'Retirees' 
		ELSE 'Unknown'
		END AS age_band,
	CASE
		WHEN segment LIKE 'C%' THEN 'Couples'
		WHEN segment LIKE 'F%' THEN 'Families'
		ELSE 'Unknown'
		END AS demographic,
	ROUND(sales/transactions, 2) AS avg_transaction
FROM data_mart.weekly_sales;

SELECT *
FROM data_mart.clean_weekly_sales
LIMIT 5;

/*B. Data Exploration

1. What day of the week is used for each week_date value?*/

SELECT DISTINCT EXTRACT('dow' FROM week_date)
FROM clean_weekly_sales;

/*2. What range of week numbers are missing from the dataset?*/
WITH all_week_num_cte AS(
	SELECT DISTINCT EXTRACT(WEEK FROM all_week_date) "all_week_number"
	FROM generate_series(
		(SELECT MIN(week_date)::date FROM clean_weekly_sales),
		(SELECT MAX(week_date)::date FROM clean_weekly_sales),
		'1 week'::interval) AS all_week_date
	ORDER BY all_week_number
)
SELECT all_week_number
FROM all_week_num_cte
WHERE all_week_number NOT IN (SELECT week_number FROM clean_weekly_sales)
ORDER BY all_week_number;

/*3. How many total transactions were there for each year in the dataset?*/

SELECT calendar_year, SUM(transactions) "total_txn"
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY total_txn DESC;

/*4. What is the total sales for each region for each month?*/
SELECT region, month_number, SUM(sales) "total_sales"
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number ASC;

/*5. What is the total count of transactions for each platform*/
SELECT platform, SUM(transactions) "total_txn"
FROM clean_weekly_sales
GROUP BY platform
ORDER BY total_txn DESC;

/*6. What is the percentage of sales for Retail vs Shopify for each month?*/

SELECT platform, month_number, SUM(sales) "monthly_sales_platform",
	SUM(SUM(sales)) OVER (PARTITION BY month_number) "total_sales_monthly",
	ROUND((SUM(sales)/SUM(SUM(sales)) OVER (PARTITION BY month_number))*100, 2) "sales_pct"
FROM data_mart.clean_weekly_sales
GROUP BY month_number, platform
ORDER BY month_number, platform;

/*7. What is the percentage of sales by demographic for each year in the dataset?*/
SELECT demographic, SUM(sales) "sales_by_demo",
	SUM(SUM(sales)) OVER(PARTITION BY demographic) "total_sales_by_demo",
	ROUND((SUM(sales)/SUM(SUM(sales)) OVER())*100, 2) "sales_pct" 
FROM data_mart.clean_weekly_sales
GROUP BY demographic
ORDER BY sales_pct DESC;

/*8. Which age_band and demographic values contribute the most to Retail sales?*/
SELECT age_band, demographic, SUM(sales) "total_sales"
FROM data_mart.clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC;

/*9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs 
Shopify? If not - how would you calculate it instead?

When calculating the average transaction size for each year and platform, we need to consider the sum 
of sales and the sum of transactions for each group (year and platform). Dividing the total sales 
by the total transactions of each group will give us the average transaction size for that particular 
group.

Using AVG(sales/transactions) would calculate the average of the ratios of sales to transactions for 
each individual record within the group, which is not what we want in this case. This approach would 
give you a different result, as it would consider the average of averages instead of the overall average
for the entire group.*/

SELECT calendar_year, platform, 
		SUM(sales) "total_sales",
		SUM(transactions) "total_txn",
		ROUND(SUM(sales)/SUM(transactions),2) "avg_txn_size", ROUND(AVG(avg_transaction), 2) "wrong_avg"
FROM data_mart.clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;


/*C. Before & After Analysis
This technique is usually used when we inspect an important event and want to inspect the impact before and 
after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging 
changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the 
previous week_date values would be before

Using this analysis approach - answer the following questions:

What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate 
in actual values and percentage of sales?
What about the entire 12 weeks before and after?
How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

D. Bonus Question

1. Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 
12 week before and after period?

a. region
b. platform
c. age_band
d. demographic
e. customer_type

2. Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based 
off this analysis?*/