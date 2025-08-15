/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?

-- Step 1: Aggregate sales by category
WITH category_sales AS (
    SELECT
        p.category,                                 -- Product category
        SUM(f.sales_amount) AS total_sales          -- Total sales for the category
    FROM
        gold_fact_sales f
        LEFT JOIN gold_dim_products p 
            ON f.product_key = p.product_key 
    GROUP BY p.category
)

-- Step 2: Calculate percentage contribution of each category
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,       -- Grand total across all categories
    CONCAT(ROUND((total_sales / SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_of_total -- Share of total
FROM category_sales
ORDER BY total_sales DESC;                          -- Sort from highest to lowest contribution
