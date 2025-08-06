/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
    - Understand the range of values for customer geography and product hierarchy.

Tables Used:
    - gold_dim_customers
    - gold_dim_products

SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Retrieve a list of distinct countries our customers come from
SELECT DISTINCT
    country
FROM
    gold_dim_customers;

-- Retrieve a distinct list of product categories, subcategories, and product names
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM
    gold_dim_products
ORDER BY
    category,
    subcategory,
    product_name;
