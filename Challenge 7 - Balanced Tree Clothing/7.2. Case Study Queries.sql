-- Case Study Questions
/*The following questions can be considered key business questions and metrics that the Balanced Tree 
team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each 
individual problem, keep in mind how you would generate all of these metrics in a single SQL script 
which the Balanced Tree team can run each month.*/

-- A. High Level Sales Analysis
/*1. What was the total quantity sold for all products?*/
SELECT SUM(qty) "total_qty_sold"
FROM balanced_tree.sales;

/*2. What is the total generated revenue for all products before discounts?*/
SELECT SUM(qty*price) "total_rev_full"
FROM balanced_tree.sales;

/*3. What was the total discount amount for all products?*/
SELECT SUM((discount::numeric / 100) * price * qty)::integer "total_disc_amt"
FROM balanced_tree.sales;


-- B. Transaction Analysis
/*1. How many unique transactions were there?*/
SELECT COUNT(DISTINCT txn_id) "unique_txt_count"
FROM balanced_tree.sales;

/*2. What is the average unique products purchased in each transaction?*/
WITH unique_prod_per_txn_cte AS (
	SELECT txn_id, COUNT(DISTINCT prod_id) "unique_prod_count"
	FROM balanced_tree.sales
	GROUP BY txn_id
)
SELECT AVG(unique_prod_count)::integer "avg_unique_prod"
FROM unique_prod_per_txn_cte;

/*3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?*/
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

/*4. What is the average discount value per transaction?*/
WITH disc_per_txn_cte AS (
	SELECT SUM(qty*price* (discount::numeric / 100)) "disc_per_txn"
	FROM balanced_tree.sales
	GROUP BY txn_id
)
SELECT ROUND(AVG(disc_per_txn), 2) "avg_disc_per_txn"
FROM disc_per_txn_cte;

/*5. What is the percentage split of all transactions for members vs non-members?*/
SELECT member, COUNT(*), 
		ROUND((COUNT(*)::numeric/(SELECT COUNT(member)::numeric FROM balanced_tree.sales)), 2) "pct_member"
FROM balanced_tree.sales
GROUP BY member

/*6. What is the average revenue for member transactions and non-member transactions?*/
WITH sum_rev_mem_cte AS (
	SELECT member, txn_id, SUM(qty*price) "sum_rev"
	FROM balanced_tree.sales
	GROUP BY member, txn_id
	ORDER BY member
)
SELECT member, ROUND(AVG(sum_rev), 2) "avg_rev"
FROM sum_rev_mem_cte
GROUP BY member;

-- C. Product Analysis
/*1. What are the top 3 products by total revenue before discount?*/

SELECT prod_id, product_name, SUM(qty*s.price) "total_rev"
FROM balanced_tree.sales AS s
LEFT JOIN balanced_tree.product_details AS pd
ON s.prod_id = pd.product_id
GROUP BY prod_id, product_name
ORDER BY total_rev DESC
LIMIT 3;

/*2. What is the total quantity, revenue and discount for each segment?*/

SELECT segment_name, 
		SUM(qty) "total_qty",
		SUM(qty*s.price) "total_rev",
		ROUND(SUM(qty*s.price* (discount::numeric/100 )), 2)  "total_discount"

FROM balanced_tree.sales AS s
LEFT JOIN balanced_tree.product_details AS pd
ON s.prod_id = pd.product_id
GROUP BY segment_name
ORDER BY segment_name ASC;

/*3. What is the top selling product for each segment?*/
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

/*4. What is the total quantity, revenue and discount for each category?*/
SELECT category_name, 
		SUM(qty) "total_qty",
		SUM(qty*s.price) "total_rev",
		ROUND(SUM(qty*s.price* (discount::numeric/100 )), 2)  "total_discount"
FROM balanced_tree.sales AS s
LEFT JOIN balanced_tree.product_details AS pd
ON s.prod_id = pd.product_id
GROUP BY category_name;

/*5. What is the top selling product for each category?*/
WITH rank_top_sales_cat_cte AS (
	SELECT category_name, product_name,
		SUM(qty) "total_qty",
		SUM(qty*s.price) "total_rev",
		RANK() OVER(PARTITION BY category_name ORDER BY SUM(qty*s.price) DESC)	
	FROM balanced_tree.sales AS s
	LEFT JOIN balanced_tree.product_details AS pd
	ON s.prod_id = pd.product_id
	GROUP BY category_name, product_name
	ORDER BY category_name ASC, total_rev DESC
-- When using window functions like RANK(), we cannot reference them directly in
-- the WHERE clause because window functions are applied after the filtering performed by the 
-- WHERE clause. 
)
SELECT category_name, product_name "top_selling_prod", total_rev
-- here we chose total revenue as the metric for top-selling products, depending on the criteria, 
-- this could also be revenue after discount or quantity
FROM rank_top_sales_cat_cte
WHERE rank = 1;

/*6. What is the percentage split of revenue by product for each segment?*/

SELECT segment_name, 
		SUM(qty*s.price) "total_rev",
		ROUND(100*SUM(qty*s.price) / SUM(SUM(qty*s.price)) OVER(), 2) AS pct_rev
		--OVER() by itself in the context of a window function, it means that 
		--we want to consider the entire result set as a single window
FROM balanced_tree.sales AS s
LEFT JOIN balanced_tree.product_details AS pd
ON s.prod_id = pd.product_id
GROUP BY segment_name
ORDER BY total_rev DESC;

/*7. What is the percentage split of revenue by segment for each category?*/

SELECT category_name, segment_name, 
		SUM(qty*s.price) "total_rev",
		ROUND(100*SUM(qty*s.price) / SUM(SUM(qty*s.price)) OVER(PARTITION BY category_name), 2) AS pct_rev
		--we use the PARTITION BY clause to specify how the rows should be divided into partitions, 
		--and then we apply an aggregate function SUM over this partition
FROM balanced_tree.sales AS s
LEFT JOIN balanced_tree.product_details AS pd
ON s.prod_id = pd.product_id
GROUP BY category_name, segment_name
ORDER BY category_name ASC, total_rev DESC;

/*8. What is the percentage split of total revenue by category?*/
/*9. What is the total transaction “penetration” for each product? (hint: penetration = number of 
transactions where at least 1 quantity of a product was purchased divided by total number of transactions)*/
/*10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?*/

-- D. Reporting Challenge
/*Write a single SQL script that combines all of the previous questions into a scheduled report that 
the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at 
the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate 
that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly 
reference which table outputs relate to which question for full marks :)*/

-- E. Bonus Challenge
/*Use a single SQL query to transform the product_hierarchy and product_prices datasets to the 
product_details table.

Hint: you may want to consider using a recursive CTE to solve this problem!*/