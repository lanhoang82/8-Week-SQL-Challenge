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

```
WITH rev_per_txn_cte AS (
	SELECT txn_id, SUM(qty*price) "rev_per_txn"
	FROM balanced_tree.sales
	GROUP BY txn_id
	ORDER BY rev_per_txn DESC
)
SELECT 
	PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY rev_per_txn) "25th_percentile",
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY rev_per_txn) "50th_percentile",
	PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY rev_per_txn) "75th_percentile"
	-- analytic function that is used to sort the percentile of the specific values for discrete distribution
FROM rev_per_txn_cte;
```
###### Answer:
![7 b 3](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/5ae1e63f-c692-4966-8c4c-ad30460c8cea)

4. What is the average discount value per transaction?

```
WITH disc_per_txn_cte AS (
	SELECT SUM(qty*price* (discount::numeric / 100)) "disc_per_txn"
	FROM balanced_tree.sales
	GROUP BY txn_id
)
SELECT ROUND(AVG(disc_per_txn), 2) "avg_disc_per_txn"
FROM disc_per_txn_cte;
```
###### Answer:
![Untitled7 b 4](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/9cb3dae1-f351-4e81-b8c7-b0e622c3eecf)

5. What is the percentage split of all transactions for members vs non-members?

```
SELECT member, COUNT(*), 
		ROUND((COUNT(*)::numeric/(SELECT COUNT(member)::numeric FROM balanced_tree.sales)), 2) "pct_member"
FROM balanced_tree.sales
GROUP BY member
```
###### Answer:
![7 b 5](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/5020d4a7-e210-46f4-9af4-cc7dd84367df)

6. What is the average revenue for member transactions and non-member transactions?

```
WITH sum_rev_mem_cte AS (
	SELECT member, txn_id, SUM(qty*price) "sum_rev"
	FROM balanced_tree.sales
	GROUP BY member, txn_id
	ORDER BY member
)
SELECT member, ROUND(AVG(sum_rev), 2) "avg_rev"
FROM sum_rev_mem_cte
GROUP BY member;
```
###### Answer:
![7 b 6](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/dc5c63a0-0c2f-4e0c-8144-a6877225e0f2)


### C. Product Analysis

1. What are the top 3 products by total revenue before discount?

```
SELECT prod_id, product_name, SUM(qty*s.price) "total_rev"
FROM balanced_tree.sales AS s
LEFT JOIN balanced_tree.product_details AS pd
ON s.prod_id = pd.product_id
GROUP BY prod_id, product_name
ORDER BY total_rev DESC
LIMIT 3;
```
###### Answer:
![7 c 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/036bc93a-0483-480e-ad70-64e009b6c6bc)

2. What is the total quantity, revenue and discount for each segment?

```
SELECT segment_name, 
		SUM(qty) "total_qty",
		SUM(qty*s.price) "total_rev",
		ROUND(SUM(qty*s.price* (discount::numeric/100 )), 2)  "total_discount"

FROM balanced_tree.sales AS s
LEFT JOIN balanced_tree.product_details AS pd
ON s.prod_id = pd.product_id
GROUP BY segment_name
ORDER BY segment_name ASC;
```
###### Answer:
![7 c 2](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/c2633e9b-cc26-4e5e-89fb-21690956473c)

3. What is the top selling product for each segment?

```
WITH rank_top_sales_cte AS (
	SELECT segment_name, product_name,
		SUM(qty) "total_qty",
		SUM(qty*s.price) "total_rev",
		RANK() OVER(PARTITION BY segment_name ORDER BY SUM(qty*s.price) DESC)	
	FROM balanced_tree.sales AS s
	LEFT JOIN balanced_tree.product_details AS pd
	ON s.prod_id = pd.product_id
	GROUP BY segment_name, product_name
	ORDER BY segment_name ASC, total_rev DESC
-- When using window functions like RANK(), we cannot reference them directly in
-- the WHERE clause because window functions are applied after the filtering performed by the 
-- WHERE clause. 
)

SELECT segment_name, product_name "top_selling_prod", total_rev
-- here we chose total revenue as the metric for top-selling products, depending on the criteria, 
-- this could also be revenue after discount or quantity
FROM rank_top_sales_cte
WHERE rank = 1;
```
###### Answer:
![7 c 3](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/2655f0d8-f7d8-4096-8a7c-168dfef9e2b3)

4. What is the total quantity, revenue and discount for each category?

```

```
###### Answer:

5. What is the top selling product for each category?

```

```
###### Answer:

6. What is the percentage split of revenue by product for each segment?

```

```
###### Answer:

7. What is the percentage split of revenue by segment for each category?

```

```
###### Answer:

8. What is the percentage split of total revenue by category?

```

```
###### Answer:

9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

```

```
###### Answer:

10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

```

```
###### Answer:
