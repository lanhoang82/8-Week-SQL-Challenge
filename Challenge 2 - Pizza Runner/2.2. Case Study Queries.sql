/*					Case Study Questions
This case study has LOTS of questions - they are broken up by area of focus including:

1. Pizza Metrics
2. Runner and Customer Experience
3. Ingredient Optimisation
4. Pricing and Ratings
5. Bonus DML Challenges (DML = Data Manipulation Language)

Each of the following case study questions can be answered using a single SQL statement.

There are many questions in this case study - please feel free to pick and choose which ones you’d like to try!

Before you start writing your SQL queries however - you might want to investigate the data, you may want 
to do something with some of those null values and data types in the customer_orders and runner_orders 
tables!*/

/* Data Cleaning: runner_orders*/

UPDATE runner_orders /* Replace 'null' string with actual null value */
SET cancellation = NULLIF(cancellation,'null');

UPDATE runner_orders	/* Replace null values with 0 */
SET duration = '0' WHERE duration = 'null';

UPDATE runner_orders	 /* Replace null values with 0 */
SET distance = '0'
	WHERE distance = 'null';

UPDATE runner_orders /*\D being the class shorthand for "not a digit", 4th parameter 'g' 
						(for "globally") to replace all occurrences.*/
SET distance = regexp_replace(duration, '\D', '', 'g')::numeric;

ALTER TABLE runner_orders
RENAME COLUMN distance TO distance_km;

UPDATE runner_orders /*keeping only the digits in the duration column*/
SET duration = regexp_replace(duration, '\D', '', 'g')::numeric;

ALTER TABLE runner_orders
RENAME COLUMN duration TO duration_min;

UPDATE runner_orders /*replace the string 'null' with actual NULL value*/
SET pickup_time = NULLIF(pickup_time,'null');

SELECT NULLIF(pickup_time,'null') 
FROM runner_orders;

ALTER TABLE runner_orders /*convert data type to timestamp*/
ALTER pickup_time TYPE TIMESTAMP USING pickup_time::timestamp without time zone;

ALTER TABLE runner_orders /*convert data type to integer*/
ALTER distance_km TYPE INTEGER USING distance_km::integer;

ALTER TABLE runner_orders /*convert data type to timestamp*/
ALTER duration_min TYPE INTEGER USING duration_min::integer;

SELECT * FROM runner_orders;

/* Data Cleaning: customer_orders*/

UPDATE customer_orders /*replace the string 'null with actual NULL value'*/
SET exclusions = NULLIF(exclusions,'');

UPDATE customer_orders /*replace the string 'null with actual NULL value'*/
SET extras = NULLIF(extras,'');

SELECT * FROM customer_orders;

/*A. Pizza Metrics

1. How many pizzas were ordered?*/

SELECT COUNT(pizza_id) "num_pizzas_ordered"
FROM customer_orders AS co
INNER JOIN runner_orders AS ro
ON co.order_id = ro.order_id
WHERE cancellation ISNULL;

/*2. How many unique customer orders were made?*/

SELECT COUNT(DISTINCT customer_id) "unique_cust_order#" 
FROM customer_orders;

/*3. How many successful orders were delivered by each runner?*/

SELECT runner_id, COUNT(order_id) AS num_succ_order
FROM runner_orders AS ro
WHERE ro.distance_km > 0
GROUP BY runner_id
ORDER BY num_succ_order DESC;

/*4. How many of each type of pizza was delivered? */

SELECT pizza_id, COUNT(pizza_id)
FROM customer_orders AS co
INNER JOIN runner_orders AS ro
ON co.order_id = ro.order_id
WHERE cancellation ISNULL
GROUP BY pizza_id;

/*5. How many Vegetarian and Meatlovers were ordered by each customer? */

SELECT customer_id, pizza_name, COUNT(co.pizza_id)
FROM customer_orders AS co
LEFT JOIN pizza_names AS pn
ON co.pizza_id = pn.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id;

/*6. What was the maximum number of pizzas delivered in a single order? */
SELECT * FROM customer_orders;

WITH num_piz_per_order AS
	(SELECT order_id, COUNT(pizza_id) "num_pizza"
	 FROM customer_orders AS co
	 GROUP BY order_id)
SELECT order_id, num_pizza
FROM num_piz_per_order
WHERE num_pizza = (
	SELECT MAX(num_pizza)
	FROM num_piz_per_order
);


/*7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?*/
/*8. How many pizzas were delivered that had both exclusions and extras?*/
/*9. What was the total volume of pizzas ordered for each hour of the day?*/
/*10. What was the volume of orders for each day of the week?*/

/*B. Runner and Customer Experience
/*1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)*/
/*2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to 
pickup the order?*/
/*3. Is there any relationship between the number of pizzas and how long the order takes to prepare?*/
/*4. What was the average distance travelled for each customer?*/
/*5. What was the difference between the longest and shortest delivery times for all orders?*/
/*6. What was the average speed for each runner for each delivery and do you notice any trend for 
these values?*/
/*7. What is the successful delivery percentage for each runner?*/

C. Ingredient Optimisation
1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
	a. Meat Lovers
	b. Meat Lovers - Exclude Beef
	c. Meat Lovers - Extra Bacon
	d. Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the 
customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

D. Pricing and Ratings
1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
	a. Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their 
runner, how would you design an additional table for this new dataset - generate a schema for this new table 
and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which 
has the following information for successful deliveries?
	a. customer_id
	b. order_id
	c. runner_id
	d. rating
	e. order_time
	f. pickup_time
	g. Time between order and pickup
	h. Delivery duration
	i. Average speed
	j. Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

E. Bonus Questions
If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?*/