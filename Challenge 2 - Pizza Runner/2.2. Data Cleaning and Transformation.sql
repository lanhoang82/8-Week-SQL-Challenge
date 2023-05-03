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
SELECT * FROM runner_orders;

UPDATE runner_orders /* Replace 'null' string with actual null value */
SET cancellation = NULLIF(cancellation,'null');

UPDATE runner_orders /* Replace 'null' string with actual null value */
SET cancellation = NULLIF(cancellation,'');

UPDATE runner_orders	/* Replace null values with 0 */
SET duration = '0' WHERE duration = 'null';

UPDATE runner_orders	 /* Replace null values with 0 */
SET distance = '0'
	WHERE distance = 'null';

UPDATE runner_orders /*\D being the class shorthand for "not a digit", 4th parameter 'g' 
						(for "globally") to replace all occurrences.*/
SET distance = regexp_replace(distance, 'km', '', 'g')::numeric;

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
ALTER distance_km TYPE DECIMAL USING distance_km::decimal;

ALTER TABLE runner_orders /*convert data type to timestamp*/
ALTER duration_min TYPE INTEGER USING duration_min::integer;

ALTER TABLE runner_orders
ADD COLUMN pickup_date DATE;

UPDATE runner_orders
SET pickup_date = DATE(pickup_time);

SELECT * FROM runner_orders;

/* Data Cleaning: customer_orders*/

UPDATE customer_orders /*replace the string 'null with actual NULL value'*/
SET exclusions = NULLIF(exclusions,'');

UPDATE customer_orders /*replace the string 'null with actual NULL value'*/
SET extras = NULLIF(extras,'');

ALTER TABLE customer_orders
ADD COLUMN order_date DATE;

UPDATE customer_orders
SET order_date = DATE(order_time);

