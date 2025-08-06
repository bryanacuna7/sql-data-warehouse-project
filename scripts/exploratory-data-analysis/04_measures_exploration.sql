/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

Tables Used:
    - gold_fact_sales
    - gold_dim_products
    - gold_dim_customers

SQL Functions Used:
    - COUNT()
    - SUM()
    - AVG()
    - ROUND()
    - UNION ALL
===============================================================================
*/

-- Calculate the total sales amount
SELECT
    SUM(sales_amount) AS total_sales
FROM
    gold_fact_sales;

-- Calculate the total number of items sold
SELECT
    SUM(quantity) AS total_quantity
FROM
    gold_fact_sales;

-- Calculate the average selling price
SELECT
    AVG(price) AS avg_price
FROM
    gold_fact_sales;

-- Calculate the total number of distinct orders
SELECT
    COUNT(DISTINCT order_number) AS total_orders
FROM
    gold_fact_sales;

-- Calculate the total number of products in the catalog
SELECT
    COUNT(product_name) AS total_products
FROM
    gold_dim_products;

-- Calculate the total number of customers in the database
SELECT
    COUNT(customer_id) AS total_customers
FROM
    gold_dim_customers;

-- Calculate the number of customers who have placed at least one order
SELECT
    COUNT(DISTINCT customer_key) AS active_customers
FROM
    gold_fact_sales;

-- Generate a single report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold_fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold_fact_sales
UNION ALL
SELECT 'Average Price', ROUND(AVG(price)) FROM gold_fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold_fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold_dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold_dim_customers;
