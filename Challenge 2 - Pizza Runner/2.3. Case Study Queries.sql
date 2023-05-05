/*					Case Study Questions
This case study has LOTS of questions - they are broken up by area of focus including:

1. Pizza Metrics
2. Runner and Customer Experience
3. Ingredient Optimisation
4. Pricing and Ratings
5. Bonus DML Challenges (DML = Data Manipulation Language)

Each of the following case study questions can be answered using a single SQL statement.

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

WITH order_change_cte AS (
	SELECT pizza_id, exclusions, extras,
		CASE
			WHEN exclusions ISNULL AND extras ISNULL THEN 'N'
			ELSE 'Y'
		END AS order_change
	FROM customer_orders AS co
	INNER JOIN runner_orders AS ro
	ON co.order_id = ro.order_id
	WHERE cancellation ISNULL
)
SELECT order_change, COUNT(pizza_id) "num_pizza"
FROM order_change_cte
GROUP BY order_change;

/*8. How many pizzas were delivered that had both exclusions and extras?*/

SELECT COUNT(pizza_id)
FROM customer_orders AS co
INNER JOIN runner_orders AS ro
ON co.order_id = ro.order_id 
WHERE ro.cancellation ISNULL AND co.exclusions IS NOT NULL AND co.extras IS NOT NULL;
/*9. What was the total volume of pizzas ordered for each hour of the day?*/

SELECT * FROM customer_orders;
/*10. What was the volume of orders for each day of the week?*/
SELECT order_date, COUNT(order_id) "order_vol"
FROM customer_orders
GROUP BY order_date
ORDER BY order_date;

/*B. Runner and Customer Experience
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)*/

/*Using data from runner_orders table*/
WITH runner_in_week_cte AS (
	SELECT runner_id, pickup_date, DATE_PART('week', pickup_date) "week_period"
	FROM runner_orders
	WHERE cancellation IS NULL
)
SELECT week_period, COUNT(runner_id) "num_runner"
FROM runner_in_week_cte
GROUP BY week_period;

/*Using data from runners table*/

WITH runner_in_week_cte AS (
	SELECT runner_id, registration_date, DATE_PART('week', registration_date) "week_period"
	FROM runners
)
SELECT week_period, COUNT(runner_id) "num_runner"
FROM runner_in_week_cte
GROUP BY week_period;

/*2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to 
pickup the order?*/

WITH runner_time_cte AS(
	SELECT runner_id, order_time, pickup_time, (pickup_time - order_time) "runner_duration"
	FROM customer_orders AS co
	INNER JOIN runner_orders AS ro
	ON co.order_id = ro.order_id
	WHERE pickup_time IS NOT NULL
)
SELECT runner_id, AVG(runner_duration) "avg_time"
FROM runner_time_cte
GROUP BY runner_id
ORDER BY avg_time ASC;

/*3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
Answer: there seems to be some correlation between the number of pizzas ordered and the time it takes 
to prepare, apart from 1 order of 1 pizza that takes twice the time as that of the similar orders.*/
SELECT * FROM customer_orders;

WITH runner_time_cte AS (
	SELECT ro.order_id, pizza_id, order_time, pickup_time, (pickup_time - order_time) "runner_duration"
	FROM customer_orders AS co
	INNER JOIN runner_orders AS ro
	ON co.order_id = ro.order_id
	WHERE pickup_time IS NOT NULL
)
SELECT order_id, COUNT(pizza_id) "num_pizza", runner_duration
FROM runner_time_cte
GROUP BY order_id, runner_duration
ORDER BY num_pizza DESC;

/*4. What was the average distance travelled for each customer?*/
SELECT customer_id, ROUND(AVG(distance_km),2) "avg_distance"
FROM runner_orders AS ro
INNER JOIN customer_orders AS co
ON co.order_id = ro.order_id
WHERE distance_km IS NOT NULL
GROUP BY customer_id
ORDER BY avg_distance DESC;

/*5. What was the difference between the longest and shortest delivery times for all orders?*/
SELECT * FROM runner_orders;

SELECT MAX(duration_min) - MIN(duration_min) "delivery_time_diff"
FROM runner_orders
WHERE duration_min > 0; 

/*6. What was the average speed for each runner for each delivery and do you notice any trend for 
these values?*/

SELECT runner_id, ROUND(AVG((distance_km / duration_min )),2) "avg_speed"
FROM runner_orders
WHERE cancellation ISNULL
GROUP BY runner_id
ORDER BY avg_speed DESC;

/*7. What is the successful delivery percentage for each runner?*/
WITH num_order_cte AS(
	SELECT runner_id, COUNT(order_id) "num_orders"
	FROM runner_orders
	GROUP BY runner_id
),
num_succ_orders_cte AS(
	SELECT runner_id, COUNT(order_id) "num_succ_orders"
	FROM runner_orders
	WHERE cancellation ISNULL
	GROUP BY runner_id
)
SELECT t1.runner_id, ROUND((num_succ_orders::decimal / num_orders::decimal), 2)
/*columns have integer types, and integer division truncates the result towards zero. 
To get an accurate result, need to cast at least one of the values to float or decimal:*/
FROM num_order_cte AS t1
JOIN num_succ_orders_cte AS t2
ON t1.runner_id = t2.runner_id

/*C. Ingredient Optimisation
1. What are the standard ingredients for each pizza?*/

WITH pizza_recipe_pivot_cte AS(
	SELECT pizza_id, UNNEST(string_to_array(toppings, ','))::integer "topping_id"
	FROM pizza_recipes
)
SELECT pr.pizza_id, pizza_name, pr.topping_id, topping_name
FROM pizza_recipe_pivot_cte AS pr
LEFT JOIN pizza_toppings AS pt
ON pr.topping_id = pt.topping_id
LEFT JOIN pizza_names AS pn
ON pn.pizza_id = pr.pizza_id
ORDER BY pizza_id

/*2. What was the most commonly added extra?*/
WITH extras_cte AS (
	SELECT pizza_id, UNNEST(string_to_array(extras, ','))::integer "extra_topping" 
	FROM customer_orders AS co
	WHERE extras IS NOT NULL
	ORDER BY pizza_id
),
extra_count_cte AS (
	SELECT topping_name, COUNT(topping_name) "occurence", 
		RANK() OVER(ORDER BY COUNT(topping_name) DESC) AS "occur_rank"
	FROM extras_cte AS ec
	LEFT JOIN pizza_toppings AS pt
	ON ec.extra_topping = pt.topping_id
	GROUP BY topping_name
)
SELECT topping_name, occurence
FROM extra_count_cte
WHERE occur_rank = 1;

/*3. What was the most common exclusion?*/
WITH excl_topping_cte AS (
	SELECT pizza_id, UNNEST(string_to_array(exclusions, ','))::integer "excl_topping" 
	FROM customer_orders AS co
)
SELECT topping_name, COUNT(excl_topping) "excl_num"
FROM excl_topping_cte AS et
LEFT JOIN pizza_toppings AS pt
ON et.excl_topping = pt.topping_id
GROUP BY topping_name
ORDER BY excl_num DESC;

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