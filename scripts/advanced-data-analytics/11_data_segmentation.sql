/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/

WITH product_segments AS (
SELECT
	product_key, -- Unique identifier for each product
	product_name, -- Product description/name
	`cost`, -- Product cost
	CASE WHEN `cost` < 100 THEN 'Below 100' -- Low cost
		 WHEN `cost` BETWEEN 100 and 500 THEN '100-500' -- Mid-low cost
		 WHEN `cost` BETWEEN 500 AND 1000 THEN '500-1000' -- Mid-high cost
		 ELSE 'Above 1000' -- High cost
	END AS cost_range -- Segmentation label
FROM gold_dim_products
)

SELECT 
	cost_range, -- Category of product cost
	COUNT(*) AS total_products -- Number of products in each cost category
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC; -- Highest product count first

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_spending AS (

SELECT
	c.customer_key, -- Unique identifier for each customer
	SUM(f.sales_amount) AS total_spending, -- Total amount spent by the customer
	MIN(order_date) AS first_order, -- First purchase date
	MAX(order_date) AS last_order, -- Most recent purchase date
	TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan -- Customer lifespan in months
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c ON f.customer_key = c.customer_key -- Join sales to customer data
GROUP BY c.customer_key
)

SELECT
	customer_segment, -- Category of customer based on rules below
	COUNT(*) AS total_customers -- Number of customers in each segment
FROM (
SELECT
	customer_key,
	CASE WHEN lifespan >= 12 and total_spending <= 5000 THEN 'Regular' -- Long-term but lower spend
		 WHEN lifespan >=12 AND total_spending > 5000 THEN 'VIP' -- Long-term and high spend
		 ELSE "New" -- Less than 12 months as a customer
	END AS customer_segment
FROM customer_spending
) t
GROUP BY customer_segment
ORDER BY total_customers DESC; -- Largest group first
