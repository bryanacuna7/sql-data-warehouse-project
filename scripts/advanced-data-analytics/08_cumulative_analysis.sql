/*
===============================================================================
Cumulative Sales Analysis
===============================================================================
Purpose:
    - Calculate monthly total sales with running total and running average price.
    - Reset running totals and averages at the start of each year.
    - Track performance over time to identify growth trends within each year.
    - Useful for both monthly and annual performance monitoring.

Tables Used:
    - gold_fact_sales

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
    - Date Functions: DATE_FORMAT(), CAST()
    - Aggregates: SUM(), AVG()
===============================================================================
*/

SELECT
    DATE_FORMAT(order_date, '%Y-%b') AS order_month, -- Year-Month label
    total_sales, -- Monthly total sales
    SUM(total_sales) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_total_sales, -- YTD running sales
    avg_price, -- Monthly average price
    AVG(avg_price) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_total_avg_price -- YTD running average price
FROM (
    SELECT
        CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE) AS order_date, -- First day of the month for grouping
        SUM(sales_amount) AS total_sales, -- Aggregate monthly sales
        AVG(price) AS avg_price -- Average price per month
    FROM gold_fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE) -- Group data by month
) AS sales_data
ORDER BY order_date; -- Chronological order
