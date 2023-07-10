/*Case Study Questions
The following case study questions include some general data exploration analysis for the nodes and 
transactions before diving right into the core business questions and finishes with a challenging final 
request!

A. Customer Nodes Exploration
1. How many unique nodes are there on the Data Bank system?*/
SELECT COUNT(DISTINCT node_id) "num_nodes"
FROM customer_nodes;

/*2. What is the number of nodes per region? */
SELECT region_id, COUNT(node_id)
FROM customer_nodes
GROUP BY region_id
ORDER BY region_id ASC;

/*3. How many customers are allocated to each region?*/
SELECT region_id, COUNT(DISTINCT customer_id) "num_cust"
FROM customer_nodes
GROUP BY region_id
ORDER BY num_cust DESC;

/*4. How many days on average are customers reallocated to a different node? (how many days do customers
stay on the same node before switching?*/
WITH day_diff_cte AS (
	SELECT customer_id, node_id, start_date, end_date, end_date-start_date "day_diff"
	FROM customer_nodes
)
SELECT ROUND(AVG(day_diff), 2) "avg_days_all"
FROM day_diff_cte
WHERE end_date <> '9999-12-31'; /*assuming this indicates the present node that hasn't been changed*/

/*5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?*/
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

/*B. Customer Transactions
1. What is the unique count and total amount for each transaction type?*/

SELECT txn_type, 
		COUNT(DISTINCT CONCAT(customer_id::text, txn_date::text)) "unique_txn_count",
		SUM(txn_amount) "total_amount"
FROM customer_transactions
GROUP BY txn_type;


/*2. What is the average total historical deposit counts and amounts for all customers?*/
WITH cust_hist_agg_cte AS (
	SELECT customer_id, (COUNT(customer_id)) "deposit_count", (SUM(txn_amount)) "deposit_amount"
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY customer_id
)
SELECT ROUND(AVG(deposit_count),2) "avg_deposit", ROUND(AVG(deposit_amount),2) "avg_amount"
FROM cust_hist_agg_cte;

/*3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 
withdrawal in a single month?*/
SELECT * 
FROM customer_transactions;

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

/*4. What is the closing balance for each customer at the end of the month?
perhaps I should generate the ending date of each month and closing balance.
The trick is for months without a transaction, the amount is 0 */

SELECT customer_id, DATE_PART('month', txn_date) AS "txn_month", txn_date, txn_type, txn_amount	
FROM customer_transactions
ORDER BY customer_id, txn_date

/*5. What is the percentage of customers who increase their closing balance by more than 5%?


C. Data Allocation Challenge
6. To test out a few different hypotheses - the Data Bank team wants to run an experiment where different 
groups of customers would be allocated data using 3 different options:

Option 1: data is allocated based off the amount of money at the end of the previous month
Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
Option 3: data is updated real-time
For this multi-part challenge question - you have been requested to generate the following data elements 
to help the Data Bank team estimate how much data will need to be provisioned for each option:

running customer balance column that includes the impact each transaction
customer balance at the end of each month
minimum, average and maximum values of the running balance for each customer
Using all of the data available - how much data would have been required for each option on a monthly 
basis?

D. Extra Challenge
Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate
data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by 
increasing their data allocation based off the interest calculated on a daily basis at the end of each 
day, how much data would be required for this option on a monthly basis?

Special notes:

Data Bank wants an initial calculation which does not allow for compounding interest, however they may 
also be interested in a daily compounding interest calculation so you can try to perform this calculation
if you have the stamina!

Extension Request
The Data Bank team wants you to use the outputs generated from the above sections to create a quick 
Powerpoint presentation which will be used as marketing materials for both external investors who might 
want to buy Data Bank shares and new prospective customers who might want to bank with Data Bank.

Using the outputs generated from the customer node questions, generate a few headline insights which
Data Bank might use to market it’s world-leading security features to potential investors and customers.

With the transaction analysis - prepare a 1 page presentation slide which contains all the relevant 
information about the various options for the data provisioning so the Data Bank management team can 
make an informed decision.*/