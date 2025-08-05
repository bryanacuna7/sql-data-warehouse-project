/*
===============================================================================
Date Range Exploration
===============================================================================
Purpose:
    - Determine the temporal boundaries of order data.
    - Calculate the total duration of historical data in years and months.
Tables:
    - gold_fact_sales
    - gold_dim_customers
SQL Functions:
    - MIN()
    - MAX()
    - TIMESTAMPDIFF()
===============================================================================
*/

-- 1) Get the first and last order date, and compute the total span in years and months
SELECT
    MIN(order_date) AS first_order_date,                                           -- Earliest recorded order date
    MAX(order_date) AS last_order_date,                                            -- Latest recorded order date
    TIMESTAMPDIFF(YEAR, MIN(order_date), MAX(order_date)) + 1 AS order_range_years, -- Total span in years (inclusive of start year)
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) + 1 AS order_range_months-- Total span in months (inclusive of start month)
FROM
    gold_fact_sales;

-- 2) Find the oldest and youngest customers by birthdate, and calculate their current ages
SELECT
    MIN(birthdate) AS oldest_birthdate,                        -- Earliest birthdate (oldest customer)
    TIMESTAMPDIFF(YEAR, MIN(birthdate), CURDATE()) AS oldest_age,   -- Current age of the oldest customer in years
    MAX(birthdate) AS youngest_birthdate,                      -- Latest birthdate (youngest customer)
    TIMESTAMPDIFF(YEAR, MAX(birthdate), CURDATE()) AS youngest_age  -- Current age of the youngest customer in years
FROM
    gold_dim_customers;
