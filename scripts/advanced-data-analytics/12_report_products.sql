/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold_report_customers
-- =============================================================================
CREATE VIEW gold_report_customers AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
SELECT
    f.order_number, -- Unique order identifier
    f.product_key, -- Product reference
    f.order_date, -- Date of purchase
    f.sales_amount, -- Sales amount for the order
    f.quantity, -- Quantity purchased
    c.customer_key, -- Unique customer reference
    c.customer_number, -- Customer number/code
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, -- Full name
    TIMESTAMPDIFF(YEAR, c.birthdate, NOW()) AS age -- Customer age in years
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c ON c.customer_key = f.customer_key -- Join sales with customer info
WHERE f.order_date IS NOT NULL -- Exclude incomplete records
),

customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders, -- Total distinct orders
    SUM(sales_amount) AS total_sales, -- Total revenue from customer
    SUM(quantity) AS total_quantity, -- Total units purchased
    COUNT(DISTINCT product_key) AS total_products, -- Variety of products bought
    MAX(order_date) AS last_order, -- Most recent order date
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan -- Customer lifespan in months
FROM base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    age
)

-- ============================================================================
-- Final Output: Add segmentation, KPIs, and calculated fields
-- ============================================================================
SELECT
	customer_key,
    customer_number,
    customer_name,
    age,
	CASE 
        WHEN age < 20 THEN 'Under 20'
   		WHEN age BETWEEN 20 AND 29 THEN '20-29'
     	WHEN age BETWEEN 30 AND 39 THEN '30-39'
     	WHEN age BETWEEN 40 AND 49 THEN '40-49'
     	ELSE '50 and above'
    END AS age_group, -- Age bucket classification

    CASE 
    	WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular' -- Long-term but low spend
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP' -- Long-term and high spend
		ELSE 'New' -- Less than 12 months as customer
	END AS customer_segment,
	
	lifespan, -- Duration as customer (months)
	TIMESTAMPDIFF(MONTH, last_order, NOW()) AS recency, -- Months since last purchase
    total_orders, -- Total orders placed
    total_sales, -- Total spend
    CASE WHEN total_orders = 0 THEN 0 ELSE total_sales / total_orders END AS avg_order_value, -- Avg revenue per order
    total_quantity, -- Total units bought
    total_products, -- Unique products purchased
    last_order, -- Date of most recent order
    CASE WHEN lifespan = 0 THEN total_sales ELSE total_sales / lifespan END AS avg_montly_spent -- Avg spend per month
FROM customer_aggregation;
