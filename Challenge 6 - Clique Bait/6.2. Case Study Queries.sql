/*2. Digital Analysis
Using the available datasets - answer the following questions using a single query for each one:*/

SELECT * FROM clique_bait.events
WHERE visit_id = 'fbfdcb';

/*1. How many users are there?*/

SELECT COUNT(DISTINCT user_id) "num_users"
FROM clique_bait.users;

/*2. How many cookies does each user have on average?*/
WITH cookie_per_user_cte AS (
	SELECT user_id, COUNT(DISTINCT cookie_id) "num_cookie"
	FROM clique_bait.users
	GROUP BY user_id
)
SELECT ROUND(AVG(num_cookie),2) "avg_cookie_per_user"
FROM cookie_per_user_cte;

/*3. What is the unique number of visits by all users per month?*/

WITH event_by_month_cte AS (
	SELECT visit_id, 
	EXTRACT('MONTH' FROM event_time) "event_month"
	FROM clique_bait.events
)
SELECT event_month, COUNT(DISTINCT visit_id) "unique_visit"
FROM event_by_month_cte
GROUP BY event_month;

/*4. What is the number of events for each event type?*/
SELECT clique_bait.event_identifier.event_name, COUNT(visit_id) "num_events"
FROM clique_bait.events
LEFT JOIN clique_bait.event_identifier
ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
GROUP BY clique_bait.event_identifier.event_name;

/*5. What is the percentage of visits which have a purchase event?*/

SELECT clique_bait.event_identifier.event_name, 
		ROUND((COUNT(visit_id)::numeric / (SELECT COUNT(visit_id) FROM clique_bait.events)::numeric) * 100, 2) "pct_events"
FROM clique_bait.events
LEFT JOIN clique_bait.event_identifier
ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
WHERE clique_bait.event_identifier.event_name = 'Purchase'
GROUP BY clique_bait.event_identifier.event_name;

/*6. What is the percentage of visits which view the checkout page but do not have a purchase event?*/
SELECT 
	ROUND((COUNT(*)::numeric/ (SELECT COUNT(*) FROM clique_bait.events)::numeric) * 100, 2) "pct_no_purchase"
FROM clique_bait.events
LEFT JOIN clique_bait.event_identifier
	ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
LEFT JOIN clique_bait.page_hierarchy
	ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
WHERE clique_bait.page_hierarchy.page_name = 'Checkout' 
	AND clique_bait.event_identifier.event_name <> 'Purchase';

/*7. What are the top 3 pages by number of views?*/
SELECT 
	clique_bait.page_hierarchy.page_name, COUNT(*) "page_view_count"
FROM clique_bait.events
LEFT JOIN clique_bait.event_identifier
	ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
LEFT JOIN clique_bait.page_hierarchy
	ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
GROUP BY clique_bait.page_hierarchy.page_name
ORDER BY "page_view_count" DESC
LIMIT 3;
	
/*8. What is the number of views and cart adds for each product category?*/
SELECT  clique_bait.page_hierarchy.product_category, 
		clique_bait.event_identifier.event_name, 
		COUNT(*) "event_count"
FROM clique_bait.events
LEFT JOIN clique_bait.event_identifier
	ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
LEFT JOIN clique_bait.page_hierarchy
	ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
WHERE clique_bait.event_identifier.event_name IN ('Page View', 'Add to Cart')
GROUP BY clique_bait.page_hierarchy.product_category, clique_bait.event_identifier.event_name
ORDER BY clique_bait.page_hierarchy.product_category DESC, 
		event_count DESC;

/*9. What are the top 3 products by purchases?*/

WITH purchase_visit_cte AS (--create cte with unique visit_id that ends in Purchase
	SELECT DISTINCT visit_id, MAX(sequence_number) "final_event", event_name
	FROM clique_bait.events
	LEFT JOIN clique_bait.event_identifier
		ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
	WHERE event_name = 'Purchase'
	GROUP BY visit_id, event_name
),
purchased_product_cte AS (--create cte with products added to cart that ends in purchase
	SELECT clique_bait.events.visit_id, page_name, product_category, sequence_number, clique_bait.event_identifier.event_name
	FROM clique_bait.events
	INNER JOIN purchase_visit_cte
		ON purchase_visit_cte.visit_id = clique_bait.events.visit_id
	LEFT JOIN clique_bait.event_identifier
		ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
	LEFT JOIN clique_bait.page_hierarchy
		ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
	WHERE clique_bait.event_identifier.event_name = 'Add to Cart'
)
SELECT page_name "purchased_product", COUNT(*) "product_count"
FROM purchased_product_cte
GROUP BY page_name
ORDER BY product_count DESC
LIMIT 3;


/*3. Product Funnel Analysis
Using a single SQL query - create a new output table which has the following details:*/

/*1. How many times was each product viewed?*/
/*2. How many times was each product added to cart?*/
/*3. How many times was each product added to a cart but not purchased (abandoned)?*/
/*4. How many times was each product purchased?*/

CREATE TABLE funnel_analysis AS

WITH page_view_cte AS(
SELECT page_name, COUNT(visit_id) "page_view_count"
	FROM clique_bait.events
	LEFT JOIN clique_bait.event_identifier
		ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
	LEFT JOIN clique_bait.page_hierarchy
		ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
	WHERE product_category IS NOT NULL 
	 	AND event_name = 'Page View'
	GROUP BY page_name
),
last_step_purchase_cte AS(
SELECT visit_id, MAX(sequence_number) "last_step_purchase"
FROM clique_bait.events
	WHERE event_type = 3
GROUP BY visit_id
),

add_cart_cte AS(
SELECT page_name, COUNT(clique_bait.events.visit_id) "add_cart_count"
	FROM clique_bait.events
	LEFT JOIN clique_bait.event_identifier
		ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
	LEFT JOIN clique_bait.page_hierarchy
		ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
	WHERE product_category IS NOT NULL 
	 	AND event_name = 'Add to Cart'
	GROUP BY page_name
),

cart_purchased_cte AS(
SELECT page_name, COUNT(clique_bait.events.visit_id) "add_cart_purchased_count"
	FROM clique_bait.events
	LEFT JOIN clique_bait.event_identifier
		ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
	LEFT JOIN clique_bait.page_hierarchy
		ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
	INNER JOIN last_step_purchase_cte
		ON last_step_purchase_cte.visit_id = clique_bait.events.visit_id -- visit_ids that resulted in purchase at the last step
	WHERE product_category IS NOT NULL 
	 	AND event_name = 'Add to Cart'
	GROUP BY page_name
)
		
SELECT page_view_cte.page_name, page_view_count, add_cart_count, add_cart_purchased_count,
	add_cart_count - add_cart_purchased_count "cart_abandoned_count",
	ROUND((add_cart_purchased_count::numeric / page_view_count::numeric) * 100, 2) "view_to_purchase_pct"
FROM page_view_cte
	JOIN add_cart_cte
		ON page_view_cte.page_name = add_cart_cte.page_name
	JOIN cart_purchased_cte
		ON page_view_cte.page_name = cart_purchased_cte.page_name;

/*5. Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.*/

CREATE TABLE funnel_analysis_prod_cat AS

WITH page_view_cte AS(
SELECT product_category, COUNT(visit_id) "page_view_count"
	FROM clique_bait.events
	LEFT JOIN clique_bait.event_identifier
		ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
	LEFT JOIN clique_bait.page_hierarchy
		ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
	WHERE product_category IS NOT NULL 
	 	AND event_name = 'Page View'
	GROUP BY product_category
),
last_step_purchase_cte AS(
SELECT visit_id, MAX(sequence_number) "last_step_purchase"
FROM clique_bait.events
	WHERE event_type = 3
GROUP BY visit_id
),

add_cart_cte AS(
SELECT product_category, COUNT(clique_bait.events.visit_id) "add_cart_count"
	FROM clique_bait.events
	LEFT JOIN clique_bait.event_identifier
		ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
	LEFT JOIN clique_bait.page_hierarchy
		ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
	WHERE product_category IS NOT NULL 
	 	AND event_name = 'Add to Cart'
	GROUP BY product_category
),

cart_purchased_cte AS(
SELECT product_category, COUNT(clique_bait.events.visit_id) "add_cart_purchased_count"
	FROM clique_bait.events
	LEFT JOIN clique_bait.event_identifier
		ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
	LEFT JOIN clique_bait.page_hierarchy
		ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
	INNER JOIN last_step_purchase_cte
		ON last_step_purchase_cte.visit_id = clique_bait.events.visit_id -- visit_ids that resulted in purchase at the last step
	WHERE product_category IS NOT NULL 
	 	AND event_name = 'Add to Cart'
	GROUP BY product_category
)
		
SELECT page_view_cte.product_category, page_view_count, add_cart_count, add_cart_purchased_count,
	add_cart_count - add_cart_purchased_count "cart_abandoned_count"
FROM page_view_cte
	JOIN add_cart_cte
		ON page_view_cte.product_category = add_cart_cte.product_category
	JOIN cart_purchased_cte
		ON page_view_cte.product_category = cart_purchased_cte.product_category;
		
/*Use your 2 new output tables - answer the following questions:*/

/*1. Which product had the most views, cart adds and purchases?*/

-- Oyster has the most views,
-- Lobster has the most cart adds,
-- Lobster also has the highest purchases

-- Overall lobster seems to be doing quite well as a product. 

/*2. Which product was most likely to be abandoned?*/
-- Russian caviar is most likely to be abandoned after being added to cart. 

/*3. Which product had the highest view to purchase percentage?*/
-- Lobster has the highest view to purchase percentage, at 48.74%

/*4. What is the average conversion rate from view to cart add?*/
SELECT 
	ROUND(AVG((add_cart_count::numeric/page_view_count::numeric)*100),2) "avg_view_2_cart_rate"
FROM funnel_analysis

/*5. What is the average conversion rate from cart add to purchase?*/
SELECT 
	ROUND(AVG((add_cart_purchased_count::numeric/add_cart_count::numeric)*100),2) "avg_cart_2_purchase"
FROM funnel_analysis

/*3. Campaigns Analysis
Generate a table that has 1 single row for every unique visit_id record and has the following columns:*/

/*- user_id*/
/*- visit_id*/
/*- visit_start_time: the earliest event_time for each visit*/
/*- page_views: count of page views for each visit*/
/*- cart_adds: count of product cart add events for each visit*/
/*- purchase: 1/0 flag if a purchase event exists for each visit*/
/*- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date*/
/*- impression: count of ad impressions for each visit*/
/*- click: count of ad clicks for each visit*/
/*- (Optional column) cart_products: a comma separated text value with products added to the cart sorted 
by the order they were added to the cart (hint: use the sequence_number)
Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a 
single A4 infographic that the team can use for their management reporting sessions, be sure to 
emphasise the most important points from your findings.*/

/*Some ideas you might want to investigate further include:

- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to eachother?*/