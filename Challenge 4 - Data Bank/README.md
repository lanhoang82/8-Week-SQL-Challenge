## Case Study 4 - Data Bank 

![Week 4 Cover](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/df853fc2-ad58-42fe-8270-3febc44e7f79)

## Table of Content
- Introduction
- Entity Relationship Diagram
- Business Questions and Solutions via SQL Codes

### Introduction

There is a new innovation in the financial industry called Neo-Banks: new aged digital only banks without physical branches. Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help! The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

### Entity Relationship Diagram
![image](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/ce77c552-297e-41d9-acb1-aae6cb5e4a8e)


### Business Questions and Solutions via SQL Codes

#### A. Customer Nodes Exploration

##### 1. How many unique nodes are there on the Data Bank system?

```
SELECT COUNT(DISTINCT node_id) FROM customer_nodes;
```

![4 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/01ad8dcb-de1c-4a82-afd4-e3e6a1a5a833)

##### 2. What is the number of nodes per region? 

```
SELECT region_id, COUNT(node_id)
FROM customer_nodes
GROUP BY region_id
ORDER BY region_id ASC;
```
![4 2](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/ad4c3a85-8261-4759-bd0d-2ca9a83525f1)


##### 3. How many customers are allocated to each region?

```
SELECT region_id, COUNT(DISTINCT customer_id) "num_cust"
FROM customer_nodes
GROUP BY region_id
ORDER BY num_cust DESC;
```
![4 3](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/df6f2938-367d-4e21-bc44-762464dd2ce9)

##### 4. How many days on average are customers reallocated to a different node? (how many days do customers stay on the same node before switching?

Per customer:
```
WITH day_diff_cte AS (
	SELECT customer_id, node_id, start_date, end_date, end_date-start_date "day_diff"
	FROM customer_nodes
)
SELECT customer_id, ROUND(AVG(day_diff), 2) "avg_days"
FROM day_diff_cte
WHERE end_date <> '9999-12-31' /*assuming this indicates the present node that hasn't been changed*/
GROUP BY customer_id
ORDER BY customer_id ASC;
```
![4 4](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/2bfd0862-1fe8-46c5-9034-c4c2ec2f797f)

For all customers:

```
WITH day_diff_cte AS (
	SELECT customer_id, node_id, start_date, end_date, end_date-start_date "day_diff"
	FROM customer_nodes
)
SELECT ROUND(AVG(day_diff), 2) "avg_days"
FROM day_diff_cte
WHERE end_date <> '9999-12-31';
 ```
![4 4 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/fbbd07c7-5993-40a8-922f-e5542ef8d40c)


##### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

```
WITH day_diff_cte AS (
	SELECT customer_id, region_id, node_id, start_date, end_date, end_date-start_date "day_diff"
	FROM customer_nodes
)
SELECT region_id, 
		ROUND(AVG(day_diff), 2) "avg_days", 
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY day_diff) "median",
		PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY day_diff) "80_percentile",
		PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY day_diff) "95_percentile"
FROM day_diff_cte
WHERE end_date <> '9999-12-31' 
GROUP BY region_id
ORDER BY region_id ASC;
```
![4 5](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/ced596e7-01a0-419b-8f9b-ca93291984e4)

#### B. Customer Transactions
##### 1. What is the unique count and total amount for each transaction type?

```
SELECT txn_type, COUNT(DISTINCT CONCAT(customer_id::text, txn_date::text)) "unique_txn_count",
				SUM(txn_amount) "total_amount"
FROM customer_transactions
GROUP BY txn_type;
```
![b 4 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/770d6ca4-2af3-43de-af32-f59761114aef)


##### 2. What is the average total historical deposit counts and amounts for all customers?

```
WITH cust_hist_agg_cte AS (
	SELECT customer_id, (COUNT(customer_id)) "deposit_count", (SUM(txn_amount)) "deposit_amount"
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY customer_id
)
SELECT ROUND(AVG(deposit_count),2) "avg_deposit", ROUND(AVG(deposit_amount),2) "avg_amount"
FROM cust_hist_agg_cte;
```

![b 4 2](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/8b9536ba-2c52-44d3-85eb-8f7329400481)

##### 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

```
WITH customer_txn_mo_cte AS (
	SELECT 
		DATE_PART('month', txn_date) AS "txn_month",
		customer_id,
		SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) "deposit_count",
		SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) "withdrawal_count",
		SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) "purchase_count"
		
	FROM customer_transactions
	GROUP BY txn_month, customer_id
	ORDER BY txn_month, customer_id
)

SELECT txn_month, COUNT(customer_id) "cust_num"
FROM customer_txn_mo_cte
WHERE deposit_count > 1 AND (withdrawal_count = 1 or purchase_count = 1)		
GROUP BY txn_month;
```

![b 4 3](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/3c9652af-1394-40be-8df4-96b6c88aa339)
