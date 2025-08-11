/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

Tables Used:
    - gold_fact_sales

SQL Functions Used:
    - Date Functions: YEAR(), MONTH(), DATE_FORMAT()
    - Aggregate Functions: SUM(), COUNT(), RANK()
===============================================================================
*/

-- Yearly sales performance analysis
SELECT 
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM 
    gold_fact_sales
WHERE 
    order_date IS NOT NULL
GROUP BY 
    YEAR(order_date)
ORDER BY 
    order_year;

-- Monthly sales performance analysis
SELECT 
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity,
    RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS best_month_rank
FROM 
    gold_fact_sales
WHERE 
    order_date IS NOT NULL
GROUP BY 
    MONTH(order_date)
ORDER BY 
    order_month;

-- Year and month sales performance analysis
SELECT
    DATE_FORMAT(order_date, '%Y-%b') AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM 
    gold_fact_sales
WHERE 
    order_date IS NOT NULL
GROUP BY 
    DATE_FORMAT(order_date, '%Y-%b')
ORDER BY 
    order_month;
