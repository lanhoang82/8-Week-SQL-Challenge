# Case Study 7 - Balanced Tree Clothing Co.

![Week 7 Cover](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/2b1dff64-dd79-4f5c-95f5-b0e1c355ad1c)

# Table of Content
- Introduction
- Entity Relationship Diagram
- Business Questions and Solutions via SQL Codes

## Introduction
Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

## Entity Relationship Diagram
![W7 Entity Relationship Diagram](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/6d4bb87b-715b-48b4-85ad-ba3f7be452b4)


For this case study there is a total of 4 datasets for this case study - however I will only need to utilise 2 main tables to solve all of the regular questions, and the additional 2 tables are used only for the bonus challenge question!

## Business Questions and Solutions via SQL Codes

The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

### A. High Level Sales Analysis

1. What was the total quantity sold for all products?

```
SELECT SUM(qty) "total_qty_sold"
FROM balanced_tree.sales;
```
###### Answer:
![7 a 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/0f214dd2-6fa3-47dc-882a-e0e534dff88f)


2. What is the total generated revenue for all products before discounts?

```
SELECT SUM(qty*price) "total_rev_full"
FROM balanced_tree.sales;
```
###### Answer:
![7 a 2](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/ee7f87df-f9f3-45f5-b253-0793a9153007)


3. What was the total discount amount for all products?

```
SELECT SUM((discount::numeric / 100) * price * qty)::integer "total_disc_amt"
FROM balanced_tree.sales;
```
###### Answer:
![7 a 3](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/fea8a7cb-d04f-446f-ae5b-b6f900aec966)


### B. Transaction Analysis

1. How many unique transactions were there?

```
SELECT COUNT(DISTINCT txn_id) "unique_txt_count"
FROM balanced_tree.sales;
```
###### Answer:
![7 b 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/c2f22562-a081-44a7-b088-147c8eac1b1b)


2. What is the average unique products purchased in each transaction?

```
WITH unique_prod_per_txn_cte AS (
	SELECT txn_id, COUNT(DISTINCT prod_id) "unique_prod_count"
	FROM balanced_tree.sales
	GROUP BY txn_id
)
SELECT AVG(unique_prod_count)::integer "avg_unique_prod"
FROM unique_prod_per_txn_cte;
```
###### Answer:
![7 b 2](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/0010376f-1a0d-463f-8a07-34dcee5af66b)


3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

4. What is the average discount value per transaction?

5. What is the percentage split of all transactions for members vs non-members?

6. What is the average revenue for member transactions and non-member transactions?


### C. Product Analysis

1. What are the top 3 products by total revenue before discount?

2. What is the total quantity, revenue and discount for each segment?

3. What is the top selling product for each segment?

4. What is the total quantity, revenue and discount for each category?

5. What is the top selling product for each category?

6. What is the percentage split of revenue by product for each segment?

7. What is the percentage split of revenue by segment for each category?

8. What is the percentage split of total revenue by category?

9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
