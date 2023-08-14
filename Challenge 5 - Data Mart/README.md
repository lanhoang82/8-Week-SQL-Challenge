# Case Study 5 - Data Mart

![Week 5 Cover](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/ecf1d520-3edb-4c50-ac30-f3450ef35386)

# Table of Content
- Introduction
- Entity Relationship Diagram
- Business Questions and Solutions via SQL Codes

## Introduction

Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - support is needed to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs help quantifying the impact of this change on the sales performance for Data Mart and its separate business areas.

The key business question he wants to answer are the following:

- What was the quantifiable impact of the changes introduced in June 2020?
- Which platform, region, segment and customer types were the most impacted by this change?
- What can we do about future introduction of similar sustainability updates to the business to minimize impact on sales?

## Entity Relationship Diagram

![image](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/3bc09407-4d57-4f9a-8eb6-9b463f16f309)

Some further details about the dataset:
- Data Mart has international operations using a multi-region strategy
- Data Mart has both, a retail and online platform in the form of a Shopify store front to serve their customers
- Customer segment and customer_type data relates to personal age and demographics information that is shared with Data Mart transactions is the count of unique purchases made through Data Mart and sales is the actual dollar amount of purchases
- Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a week_date value which represents the start of the sales week.

## Business Questions and Solutions via SQL Codes

### A. Data Cleansing Steps
In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

1. Convert the week_date to a DATE format
2. Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
3. Add a month_number with the calendar month for each week_date value as the 3rd column
4. Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
5. Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value:
   
![5a](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/b07f08a3-3880-4695-a43b-0d0cef039b51)

6. Add a new demographic column using the following mapping for the first letter in the segment values:

![5b](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/d15fee51-6183-4f45-9837-d21607bc86c7)

7. Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
8. Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

###### Answer:

```
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
FROM weekly_sales;

SELECT *
FROM clean_weekly_sales
LIMIT 5;

SELECT *
FROM clean_weekly_sales
LIMIT 5;
```


![a 5 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/1ed617e8-227f-47ff-b8fe-dae4946f9f91)


### B. Data Exploration

#### 1. What day of the week is used for each week_date value?
###### Answer: 
```
SELECT DISTINCT EXTRACT('dow' FROM week_date)
FROM clean_weekly_sales;
```
![w5 5 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/6d7873fb-9ba5-4e7d-b08b-efca9e3605ce)

Per PostgreSQL convention, weekday `1` signifies Monday.

#### 2. What range of week numbers are missing from the dataset?
###### Answer:
```
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
```
![w5 5 2](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/ee633002-b5aa-4012-a2c9-04acaebdc3ab)

#### 3. How many total transactions were there for each year in the dataset?
###### Answer:
```
SELECT calendar_year, SUM(transactions) "total_txn"
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY total_txn DESC;
```
![w5 5 3](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/e1c20949-a614-4412-9cd9-08a238995389)

#### 4. What are the total sales for each region for each month?
###### Answer:
```
SELECT region, month_number, SUM(sales) "total_sales"
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number ASC;
```
![w5 5 4](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/4af3a1d1-ae23-4343-9fa9-092ff21a26a7)

#### 5. What is the total count of transactions for each platform?
###### Answer:
Retail seems to dominate the number of transactions out of the two platforms.
```
SELECT platform, SUM(transactions) "total_txn"
FROM clean_weekly_sales
GROUP BY platform
ORDER BY total_txn DESC;
```
![w5 5 5](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/242a441a-b250-416c-ad00-7a72082af864)

#### 6. What is the percentage of sales for Retail vs Shopify for each month?
###### Answer:
```
SELECT platform, month_number, SUM(sales) "monthly_sales_platform",
	SUM(SUM(sales)) OVER (PARTITION BY month_number) "total_sales_monthly",
	ROUND((SUM(sales)/SUM(SUM(sales)) OVER (PARTITION BY month_number))*100, 2) "sales_pct"
FROM data_mart.clean_weekly_sales
GROUP BY month_number, platform
ORDER BY month_number, platform;
```
![w5 5 6](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/a51ecd28-01b6-45b7-9162-03b74febfec4)

#### 7. What is the percentage of sales by demographic for each year in the dataset?
###### Answer:    
```
SELECT demographic, SUM(sales) "sales_by_demo",
	SUM(SUM(sales)) OVER(PARTITION BY demographic) "total_sales_by_demo",
	ROUND((SUM(sales)/SUM(SUM(sales)) OVER())*100, 2) "sales_pct" 
FROM data_mart.clean_weekly_sales
GROUP BY demographic
ORDER BY sales_pct DESC;
```
![w5 5 7](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/5375e8ce-877a-409e-903d-0566173f3a6e)

#### 8. Which age_band and demographic values contribute the most to Retail sales?
###### Answer:
It looks like we have a big group of unknown age band and demographic, but coming second is the retirees (in families or in couples) who contribute the most to Retail sales.
```
SELECT age_band, demographic, SUM(sales) "total_sales"
FROM data_mart.clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC;
```
![w5 5 8](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/dabced8a-d31c-4552-a60c-c5540ead4573)

#### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
###### Answer:

When calculating the average transaction size for each year and platform, we need to consider the sum 
of sales and the sum of transactions for each group (year and platform). Dividing the total sales 
by the total transactions of each group will give us the average transaction size for that particular 
group.

Using AVG(sales/transactions) would calculate the average of the ratios of sales to transactions for 
each individual record within the group, which is not what we want in this case. This approach would 
give you a different result, as it would consider the average of averages instead of the overall average
for the entire group.
```
SELECT calendar_year, platform, 
		SUM(sales) "total_sales",
		SUM(transactions) "total_txn",
		ROUND(SUM(sales)/SUM(transactions),2) "avg_txn_size", ROUND(AVG(avg_transaction), 2) "wrong_avg"
FROM data_mart.clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
```
![w5 5 9](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/c710f40c-7a9a-4466-837e-33750cadab48)

### C. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time. Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before. Using this analysis approach - answer the following questions:

#### 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?*/

###### Answer: 
We see a 30% reduction in sales 4 weeks after the change, compared to the 4 weeks before the change to sustainable packaging.

```
WITH cte_before_after AS(
	SELECT DISTINCT week_number "change_week", 
					week_number - 4 "four_weeks_before",
					week_number + 3 "four_weeks_after"
	FROM data_mart.clean_weekly_sales
	WHERE week_date = '2020-06-15'
),
total_sales_bef_aft AS(
	SELECT CASE 
		WHEN week_number < cte_before_after.change_week AND week_number >= cte_before_after.four_weeks_before THEN 'Before'
		WHEN week_number >= cte_before_after.change_week AND week_number <= cte_before_after.four_weeks_after THEN 'After'
		ELSE 'Not included'
		END AS calc_period,
		SUM(sales)::NUMERIC AS total_sales
	FROM data_mart.clean_weekly_sales, cte_before_after
	GROUP BY calc_period
)	

SELECT 
	(SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'After') "after_sales",
	(SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'Before') "before_sales",
	(SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'After') - 
	(SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'Before') "absolute_change",
	 ROUND(((SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'After')  -
	 (SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'Before')) /
		   	(SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'Before')  * 100 , 2) 
		 "pct_change"; 
```
![4 weeks](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/dcd53f57-e86c-4592-9e86-8744efeffe5b)



#### 2. What about the entire 12 weeks before and after?

###### Answer: 
We see an even bigger reduction in sales 12 weeks after the change, compared to the 12 weeks before the change to sustainable packaging.

```
WITH cte_before_after AS(
	SELECT DISTINCT week_number "change_week", 
					week_number - 12 "twelve_weeks_before",
					week_number + 11 "twelve_weeks_after"
	FROM data_mart.clean_weekly_sales
	WHERE week_date = '2020-06-15'
),
total_sales_bef_aft AS(
	SELECT CASE 
		WHEN week_number < cte_before_after.change_week AND week_number >= cte_before_after.twelve_weeks_before THEN 'Before'
		WHEN week_number >= cte_before_after.change_week AND week_number <= cte_before_after.twelve_weeks_after THEN 'After'
		ELSE 'Not included'
		END AS calc_period,
		SUM(sales)::NUMERIC AS total_sales
	FROM data_mart.clean_weekly_sales, cte_before_after
	GROUP BY calc_period
)	

SELECT 
	(SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'After') "after_sales",
	(SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'Before') "before_sales",
	(SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'After') - 
	(SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'Before') "absolute_change",
	 ROUND(((SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'After')  -
	 (SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'Before')) /
		   	(SELECT total_sales FROM total_sales_bef_aft WHERE calc_period = 'Before')  * 100 , 2)
		 "pct_change";
```
![12 weeks](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/db203a27-0033-4fbb-b6d6-64b9228463dc)



### D. Bonus Question

#### 1. Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 weeks before and after period?

#### Region
###### Answer: Europe and Africa are the two regions hardest hit by the change. 
```
WITH region_sales AS(
	SELECT * FROM CROSSTAB($$ --performing table pivot 
		WITH cte_before_after AS (
			SELECT DISTINCT
				week_number AS change_week,
				week_number - 12 AS twelve_weeks_before,
				week_number + 11 AS twelve_weeks_after
			FROM
				data_mart.clean_weekly_sales
			WHERE
				week_date = '2020-06-15'
		)
		SELECT
			region,
			CASE 
				WHEN week_number < cte.change_week AND week_number >= cte.twelve_weeks_before THEN 'before_sales'
				WHEN week_number >= cte.change_week AND week_number <= cte.twelve_weeks_after THEN 'after_sales'
				ELSE 'Not included'
			END AS calc_period,
			SUM(sales)::NUMERIC AS total_sales
		FROM
			data_mart.clean_weekly_sales,
			cte_before_after cte
		GROUP BY
			region, calc_period
		ORDER BY
			region, calc_period
	$$) AS ct (Region VARCHAR, "before_sales" NUMERIC, "after_sales" NUMERIC, "Not included" NUMERIC)
	ORDER BY Region ASC
)
SELECT region, before_sales, after_sales, after_sales - before_sales "absolute_change", 
		ROUND((after_sales - before_sales) / before_sales * 100, 2) "pct_change"
FROM region_sales
ORDER BY pct_change ASC;
```
![region](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/c612e936-c8fb-4260-a0d2-65cbe5dba64b)


#### Platform
###### Answer: Shopify is the platform that incurs a negative impact in sales after the change.
```
WITH platform_sales AS(
	SELECT * FROM CROSSTAB($$ --performing table pivot 
		WITH cte_before_after AS (
			SELECT DISTINCT
				week_number AS change_week,
				week_number - 12 AS twelve_weeks_before,
				week_number + 11 AS twelve_weeks_after
			FROM data_mart.clean_weekly_sales
			WHERE week_date = '2020-06-15'
		)
		SELECT platform,
			CASE 
				WHEN week_number < cte.change_week AND week_number >= cte.twelve_weeks_before THEN 'before_sales'
				WHEN week_number >= cte.change_week AND week_number <= cte.twelve_weeks_after THEN 'after_sales'
				ELSE 'Not included'
			END AS calc_period,
			SUM(sales)::NUMERIC AS total_sales
		FROM data_mart.clean_weekly_sales,
			cte_before_after cte
		GROUP BY platform, calc_period
		ORDER BY platform, calc_period
	$$) AS ct (platform VARCHAR, "before_sales" NUMERIC, "after_sales" NUMERIC, "Not included" NUMERIC)
	ORDER BY platform ASC
)
SELECT platform, before_sales, after_sales, after_sales - before_sales "absolute_change", 
		ROUND((after_sales - before_sales) / before_sales * 100, 2) "pct_change"
FROM platform_sales
ORDER BY pct_change ASC;
```
![platform](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/72a6f289-6dbf-4c93-8611-bbd42d2f9e06)


#### Age Band
###### Answer: Retirees are the ones with the least positive increase after the change.
```
WITH age_band_sales AS(
	SELECT * FROM CROSSTAB($$ --performing table pivot 
		WITH cte_before_after AS (
			SELECT DISTINCT
				week_number AS change_week,
				week_number - 12 AS twelve_weeks_before,
				week_number + 11 AS twelve_weeks_after
			FROM
				data_mart.clean_weekly_sales
			WHERE
				week_date = '2020-06-15'
		)
		SELECT
			age_band,
			CASE 
				WHEN week_number < cte.change_week AND week_number >= cte.twelve_weeks_before THEN 'before_sales'
				WHEN week_number >= cte.change_week AND week_number <= cte.twelve_weeks_after THEN 'after_sales'
				ELSE 'Not included'
			END AS calc_period,
			SUM(sales)::NUMERIC AS total_sales
		FROM
			data_mart.clean_weekly_sales,
			cte_before_after cte
		GROUP BY
			age_band, calc_period
		ORDER BY
			age_band, calc_period
	$$) AS ct (age_band TEXT, "before_sales" NUMERIC, "after_sales" NUMERIC, "Not included" NUMERIC)
	ORDER BY age_band ASC
)
SELECT age_band, before_sales, after_sales, after_sales - before_sales "absolute_change", 
		ROUND((after_sales - before_sales) / before_sales * 100, 2) "pct_change"
FROM age_band_sales
ORDER BY pct_change ASC;
```
![age_band](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/1c87255e-9ad9-4408-8793-88ca47c54336)


#### Demographic
###### Answer: Families are the ones with the least positive increase after the change.
```
WITH demographic_sales AS(
	SELECT * FROM CROSSTAB($$ --performing table pivot 
		WITH cte_before_after AS (
			SELECT DISTINCT
				week_number AS change_week,
				week_number - 12 AS twelve_weeks_before,
				week_number + 11 AS twelve_weeks_after
			FROM
				data_mart.clean_weekly_sales
			WHERE
				week_date = '2020-06-15'
		)
		SELECT
			demographic,
			CASE 
				WHEN week_number < cte.change_week AND week_number >= cte.twelve_weeks_before THEN 'before_sales'
				WHEN week_number >= cte.change_week AND week_number <= cte.twelve_weeks_after THEN 'after_sales'
				ELSE 'Not included'
			END AS calc_period,
			SUM(sales)::NUMERIC AS total_sales
		FROM
			data_mart.clean_weekly_sales,
			cte_before_after cte
		GROUP BY
			demographic, calc_period
		ORDER BY
			demographic, calc_period
	$$) AS ct (demographic TEXT, "before_sales" NUMERIC, "after_sales" NUMERIC, "Not included" NUMERIC)
	ORDER BY demographic ASC
)
SELECT demographic, before_sales, after_sales, after_sales - before_sales "absolute_change", 
		ROUND((after_sales - before_sales) / before_sales * 100, 2) "pct_change"
FROM demographic_sales
ORDER BY pct_change ASC;
```
![demographic](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/198cde0d-4eb1-4720-b59e-4a48a00c6e87)


#### Customer Type
###### Answer: New customers are the customer type that incurs a negative impact in sales after the change.
```
WITH customer_type_sales AS(
	SELECT * FROM CROSSTAB($$ --performing table pivot 
		WITH cte_before_after AS (
			SELECT DISTINCT
				week_number AS change_week,
				week_number - 12 AS twelve_weeks_before,
				week_number + 11 AS twelve_weeks_after
			FROM
				data_mart.clean_weekly_sales
			WHERE
				week_date = '2020-06-15'
		)
		SELECT
			customer_type,
			CASE 
				WHEN week_number < cte.change_week AND week_number >= cte.twelve_weeks_before THEN 'before_sales'
				WHEN week_number >= cte.change_week AND week_number <= cte.twelve_weeks_after THEN 'after_sales'
				ELSE 'Not included'
			END AS calc_period,
			SUM(sales)::NUMERIC AS total_sales
		FROM
			data_mart.clean_weekly_sales,
			cte_before_after cte
		GROUP BY
			customer_type, calc_period
		ORDER BY
			customer_type, calc_period
	$$) AS ct (customer_type VARCHAR, "before_sales" NUMERIC, "after_sales" NUMERIC, "Not included" NUMERIC)
	ORDER BY customer_type ASC
)
SELECT customer_type, before_sales, after_sales, after_sales - before_sales "absolute_change", 
		ROUND((after_sales - before_sales) / before_sales * 100, 2) "pct_change"
FROM customer_type_sales
ORDER BY pct_change ASC;
```

![customer_type](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/c46fce6d-9e48-4a13-b00c-f279ae1f3b67)
