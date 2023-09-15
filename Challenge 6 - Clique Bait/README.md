# Case Study 6 - Clique Bait

![6](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/eb17e82b-c8fa-4623-821b-2c82dd9097af)


# Table of Content
- Introduction
- Entity Relationship Diagram
- Business Questions and Solutions via SQL Codes

## Introduction
Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - I am required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

## Entity Relationship Diagram

![Relationship Diagram](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/159be58e-a379-4869-8263-3210cfd7ca6d)

Some further details about the dataset:
- Users: Customers who visit the Clique Bait website are tagged via their `cookie_id`.
- Events: Customer visits are logged in this `events` table at a `cookie_id` level and the `event_type` and `page_id` values can be used to join onto relevant satellite tables to obtain further information about each event. The sequence_number is used to order the events within each visit.
- Event Identifier: The `event_identifier` table shows the types of events which are captured by Clique Bait’s digital data systems.
- Campaign Identifier: This table shows information for the 3 campaigns that Clique Bait has run on their website so far in 2020.
- Page Hierarchy: This table lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.

## Business Questions and Solutions via SQL Codes

### A. Digital Analysis

Using the available datasets - answer the following questions using a single query for each one:

1. How many users are there?
###### Answer:
```
SELECT COUNT(DISTINCT user_id) "num_users"
FROM clique_bait.users;
```
![6 1](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/462db508-0cf6-4e30-a1a4-d826d5084671)

2. How many cookies does each user have on average?
###### Answer:
```
WITH cookie_per_user_cte AS (
	SELECT user_id, COUNT(DISTINCT cookie_id) "num_cookie"
	FROM clique_bait.users
	GROUP BY user_id
)
SELECT ROUND(AVG(num_cookie),2) "avg_cookie_per_user"
FROM cookie_per_user_cte;
```
![6 2](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/646283f0-3b79-4880-8e25-6a1659a9c238)

3. What is the unique number of visits by all users per month?
###### Answer:
```
WITH event_by_month_cte AS (
	SELECT visit_id, 
	EXTRACT('MONTH' FROM event_time) "event_month"
	FROM clique_bait.events
)
SELECT event_month, COUNT(DISTINCT visit_id) "unique_visit"
FROM event_by_month_cte
GROUP BY event_month;
```
![6 3](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/46ca6b29-50a4-4118-95fe-6a7f62b393ec)

4. What is the number of events for each event type?
###### Answer:
```
SELECT clique_bait.event_identifier.event_name, COUNT(visit_id) "num_events"
FROM clique_bait.events
LEFT JOIN clique_bait.event_identifier
ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
GROUP BY clique_bait.event_identifier.event_name;
```
![6 4](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/421bf44c-9576-4d8b-afd6-2b1e04fb5f7f)

5. What is the percentage of visits which have a purchase event?
###### Answer:
```
SELECT clique_bait.event_identifier.event_name, 
		ROUND((COUNT(visit_id)::numeric / (SELECT COUNT(visit_id) FROM clique_bait.events)::numeric) * 100, 2) "pct_events"
FROM clique_bait.events
LEFT JOIN clique_bait.event_identifier
ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
WHERE clique_bait.event_identifier.event_name = 'Purchase'
GROUP BY clique_bait.event_identifier.event_name;
```
![6 5](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/36746163-f20f-4889-8cb1-5b47d11f82d0)

6. What is the percentage of visits which view the checkout page but do not have a purchase event?
###### Answer:
```
SELECT 
	ROUND((COUNT(*)::numeric/ (SELECT COUNT(*) FROM clique_bait.events)::numeric) * 100, 2) "pct_no_purchase"
FROM clique_bait.events
LEFT JOIN clique_bait.event_identifier
	ON clique_bait.events.event_type = clique_bait.event_identifier.event_type
LEFT JOIN clique_bait.page_hierarchy
	ON clique_bait.events.page_id = clique_bait.page_hierarchy.page_id
WHERE clique_bait.page_hierarchy.page_name = 'Checkout' 
	AND clique_bait.event_identifier.event_name <> 'Purchase';
```
![6 6](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/69c5594e-c295-4cb8-aa49-91040750a6c0)


7. What are the top 3 pages by number of views?
###### Answer:
```
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
```
![6 7](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/adf99267-9cd3-47c4-b659-fbe9cd1b4236)


8. What is the number of views and cart adds for each product category?
###### Answer:
```
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
```
![6 8](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/f7412c78-4540-4b2e-81c4-f976ca9c8a47)


9. What are the top 3 products by purchase?
###### Answer:
```
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
```
![6 9](https://github.com/lanhoang82/8-Week-SQL-Challenge/assets/47191803/01ed0f02-9631-44a3-bb01-aeb6d1d7515a)


### B. Product Funnel Analysis

### C. Campaigns Analysis








