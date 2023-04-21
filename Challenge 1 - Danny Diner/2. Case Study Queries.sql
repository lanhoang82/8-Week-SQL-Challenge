/*Case Study Questions*/ 
 
/*Each of the following case study questions can be answered using a single 
SQL statement:

1. What is the total amount each customer spent at the restaurant?*/
SELECT s.customer_id, SUM(me.price) "total_sales"
FROM sales AS s
LEFT JOIN menu AS me
ON s.product_id = me.product_id
GROUP BY s.customer_id
ORDER BY total_sales DESC;

/*2. How many days has each customer visited the restaurant?*/
SELECT customer_id, COUNT(DISTINCT order_date) "days_visited"
FROM sales AS s
GROUP BY customer_id;

/*3. What was the first item from the menu purchased by each customer?
We need to identify the earliest date of each customer.
Then get the product name of that customer from that earliest date*/
WITH first_order_date AS (
	SELECT customer_id, MIN(order_date) "date"
	FROM sales
	GROUP BY customer_id
)
SELECT DISTINCT s.customer_id, first_order_date.date, product_name
FROM sales AS s
LEFT JOIN menu AS me ON s.product_id = me.product_id
INNER JOIN first_order_date ON s.customer_id = first_order_date.customer_id
WHERE s.order_date = first_order_date.date;


/*4. What is the most purchased item on the menu and how many times was it purchased by 
all customers?
Need to find the sum of all product_id, rank them DESC */
SELECT s.product_id, product_name, SUM(s.product_id) "volume_sold"
FROM sales AS s
LEFT JOIN menu AS me
ON s.product_id = me.product_id
GROUP BY s.product_id, me.product_name
ORDER BY volume_sold DESC;

/*5. Which item was the most popular for each customer?
(approach: find the number of products bought by each customer, assign rank based on number of products bought
then get the product with highest number of each customer based on the first rank
*/
WITH product_count AS (
	SELECT customer_id,  me.product_name, COUNT(s.product_id) "prod_count",
		DENSE_RANK() OVER(PARTITION BY s.customer_id
      	ORDER BY COUNT(s.product_id) DESC) AS rank
	FROM sales AS s
	INNER JOIN menu AS me
	ON s.product_id = me.product_id
	GROUP BY me.product_name, customer_id
)
SELECT customer_id, product_name, prod_count
FROM product_count
WHERE rank = 1;

/*6. Which item was purchased first by the customer after they became a member?*/
WITH member_order_cte AS (	
	SELECT s.customer_id, s.order_date, me.product_name, 
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS date_rank
	FROM sales AS s
	INNER JOIN members AS mb
		ON s.customer_id = mb.customer_id
	INNER JOIN menu AS me
		ON s.product_id = me.product_id
	WHERE s.order_date >= mb.join_date
)
SELECT customer_id, order_date, product_name
FROM member_order_cte
WHERE date_rank = 1;


/*7. Which item was purchased just before the customer became a member?*/
WITH order_bf_member_cte AS (
	SELECT s.customer_id, s.order_date, me.product_name, 
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS date_rank
	FROM sales AS s
	INNER JOIN members AS mb
		ON s.customer_id = mb.customer_id
	INNER JOIN menu AS me
		ON s.product_id = me.product_id
	WHERE s.order_date < mb.join_date
)
SELECT customer_id, order_date, product_name
FROM order_bf_member_cte
WHERE date_rank = 1;

/*8. What is the total items and amount spent for each member before they became a member?*/
WITH order_bf_member_cte AS (
	SELECT s.customer_id, s.order_date, me.product_name, price,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS date_rank
	FROM sales AS s
	INNER JOIN members AS mb
		ON s.customer_id = mb.customer_id
	INNER JOIN menu AS me
		ON s.product_id = me.product_id
	WHERE s.order_date < mb.join_date
)
SELECT customer_id, COUNT(product_name) AS total_item, SUM(price) AS amount_spent
FROM order_bf_member_cte AS ob
GROUP BY customer_id;
/*9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?*/
/*10. In the first week after a customer joins the program (including their join date)
they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?*/