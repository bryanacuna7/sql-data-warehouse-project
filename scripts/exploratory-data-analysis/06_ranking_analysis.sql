/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

Tables Used:
    - gold_fact_sales
    - gold_dim_products
    - gold_dim_customers

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER()
    - Clauses: GROUP BY, ORDER BY, LIMIT
===============================================================================
*/

-- Find the 5 products generating the highest revenue (simple ranking)
SELECT
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM
    gold_fact_sales f
    LEFT JOIN gold_dim_products p ON p.product_key = f.product_key
GROUP BY
    p.product_name
ORDER BY
    total_revenue DESC
LIMIT 5;

-- Find the 5 top-performing products using ROW_NUMBER() (flexible ranking)
SELECT
    *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM
        gold_fact_sales f
        LEFT JOIN gold_dim_products p ON p.product_key = f.product_key
    GROUP BY
        p.product_name
) t
WHERE
    rank_products <= 5;

-- Find the 5 worst-performing products in terms of total sales
SELECT
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM
    gold_fact_sales f
    LEFT JOIN gold_dim_products p ON p.product_key = f.product_key
GROUP BY
    p.product_name
ORDER BY
    total_revenue ASC
LIMIT 5;

-- Find the top 10 customers who have generated the highest total revenue
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM
    gold_fact_sales f
    LEFT JOIN gold_dim_customers c ON c.customer_key = f.customer_key
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY
    total_revenue DESC
LIMIT 10;

-- Find the 3 customers with the fewest orders placed
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM
    gold_fact_sales f
    LEFT JOIN gold_dim_customers c ON c.customer_key = f.customer_key
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY
    total_orders ASC
LIMIT 3;
