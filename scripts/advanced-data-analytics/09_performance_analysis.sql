/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
 - To measure the performance of products, customers, or regions over time.
 - For benchmarking and identifying high-performing entities.
 - To track yearly trends and growth.

SQL Functions Used:
 - LAG(): Accesses data from previous rows.
 - AVG() OVER(): Computes average values within partitions.
 - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* 
Step 1: Aggregate yearly product sales.
This subquery calculates the total sales per product for each year. 
It prepares the data for further comparison to averages and prior-year performance.
*/
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,              -- Extract the year from the order date
        p.product_name,                                -- Product name from the product dimension table
        SUM(f.sales_amount) AS current_sales           -- Total sales amount for the year per product
    FROM gold_fact_sales f
    LEFT JOIN gold_dim_products p 
        ON f.product_key = p.product_key               -- Join sales to product information
    WHERE f.order_date IS NOT NULL                     -- Exclude rows without a valid date
    GROUP BY YEAR(f.order_date), p.product_name        -- Group results by year and product
)

/* 
Step 2: Compare each product's yearly performance 
to both its historical average and its prior-year sales.
*/
SELECT
    order_year,                                        -- Year of the sales data
    product_name,                                      -- Product name
    current_sales,                                     -- Total sales in the given year
    
    -- Average sales for the product across all years
    AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
    
    -- Difference from the product's average sales
    current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
    
    -- Categorize as 'Above Avg', 'Below Avg', or 'Avg' based on the difference
    CASE 
        WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    
    -- Retrieve the previous year's sales for the same product
    LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
    
    -- Difference from the previous year's sales
    current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
    
    -- Categorize year-over-year change as 'Increase', 'Decrease', or 'No change'
    CASE 
        WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No change'
    END AS py_change

FROM yearly_product_sales
ORDER BY product_name, order_year;                     -- Sort results by product and year
