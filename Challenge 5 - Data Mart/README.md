## Case Study 5 - Data Mart

![Week 5 Cover](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/ecf1d520-3edb-4c50-ac30-f3450ef35386)

## Table of Content
- Introduction
- Entity Relationship Diagram
- Business Questions and Solutions via SQL Codes

### Introduction

Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - support is needed to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs help to quantify the impact of this change on the sales performance for Data Mart and its separate business areas.

The key business question he wants to answer are the following:

- What was the quantifiable impact of the changes introduced in June 2020?
- Which platform, region, segment and customer types were the most impacted by this change?
- What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?

### Entity Relationship Diagram

![image](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/3bc09407-4d57-4f9a-8eb6-9b463f16f309)

Some further details about the dataset:
- Data Mart has international operations using a multi-region strategy
- Data Mart has both, a retail and online platform in the form of a Shopify store front to serve their customers
- Customer segment and customer_type data relates to personal age and demographics information that is shared with Data Mart transactions is the count of unique purchases made through Data Mart and sales is the actual dollar amount of purchases
- Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a week_date value which represents the start of the sales week.

### Business Questions and Solutions via SQL Codes

#### A. Data Cleansing Steps
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

````
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
````


![a 5 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/1ed617e8-227f-47ff-b8fe-dae4946f9f91)


#### B. Data Exploration
1. What day of the week is used for each week_date value?
2. What range of week numbers are missing from the dataset?
3. How many total transactions were there for each year in the dataset?
4. What are the total sales for each region for each month?
5. What is the total count of transactions for each platform
6. What is the percentage of sales for Retail vs Shopify for each month?
7. What is the percentage of sales by demographic for each year in the dataset?
8. Which age_band and demographic values contribute the most to Retail sales?
9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
