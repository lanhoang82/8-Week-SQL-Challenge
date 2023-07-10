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
FROM weekly_sales;

SELECT *
FROM clean_weekly_sales
LIMIT 5;

/*B. Data Exploration

1. What day of the week is used for each week_date value?
2. What range of week numbers are missing from the dataset?
3. How many total transactions were there for each year in the dataset?
4. What is the total sales for each region for each month?
5. What is the total count of transactions for each platform
6. What is the percentage of sales for Retail vs Shopify for each month?
7. What is the percentage of sales by demographic for each year in the dataset?
8. Which age_band and demographic values contribute the most to Retail sales?
9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs 
Shopify? If not - how would you calculate it instead?

C. Before & After Analysis
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