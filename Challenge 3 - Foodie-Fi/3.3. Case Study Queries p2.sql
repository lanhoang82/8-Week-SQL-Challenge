/*C. Challenge Payment Question
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid 
by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid 
plan
- upgrades from basic monthly (1) to pro plans (2 or 3) will have price of new plans reduced by the 
current paid amount of previous plan in that month and start immediately
- upgrades from pro monthly (2) to pro annual (3) are paid at the end of the current billing period and 
also starts at the end of the month period
- once a customer churns (4) they will no longer make payments
*/

SELECT customer_id, s.plan_id, plan_name, start_date, price
FROM subscriptions AS s
LEFT JOIN plan AS pl
ON s.plan_id = pl.plan_id
WHERE start_date <= '2020-12-30' AND start_date >= '2020-01-01' AND s.plan_id <> 0
ORDER BY customer_id ASC

DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
	customer_id INTEGER,
	plan_id INTEGER,
	plan_name VARCHAR(13),
	payment_date DATE,
	payment_amount DECIMAL(5,2),
	payment_order INTEGER
);

INSERT INTO payments (customer_id, plan_id, plan_name, payment_date, payment_amount, payment_order)
SELECT
  s.customer_id,
  s.plan_id,
  pl.plan_name,
  s.start_date + INTERVAL '1 MONTH' * (EXTRACT(YEAR FROM AGE('2020-12-31'::date, s.start_date)) * 12 + EXTRACT(MONTH FROM AGE('2020-12-31'::date, s.start_date))) AS payment_date,
  pl.price,
  1 AS payment_order
FROM
  subscriptions s
JOIN
  plan pl ON s.plan_id = pl.plan_id
WHERE
  pl.plan_id IN (1, 2)
  AND s.start_date <= '2020-12-31'::date;
  
SELECT * FROM payments;