-- ============================
-- QUALITY CHECKS - BRONZE LAYER
-- ============================

-- Identify Out-of-Range Dates
SELECT DISTINCT
    bdate
FROM bronze_erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > NOW();

-- Data Standardization & Consistency
SELECT DISTINCT
    gen AS original_gen,
    CASE 
        WHEN UPPER(gen) LIKE '%F%' THEN 'Female'
        WHEN UPPER(gen) LIKE '%M%' THEN 'Male'
        ELSE 'n/a'
    END AS standardized_gen
FROM bronze_erp_cust_az12;


-- ============================
-- QUALITY CHECKS - SILVER LAYER
-- After table transformations
-- ============================

-- Identify Out-of-Range Dates
SELECT DISTINCT
    bdate
FROM silver_erp_cust_az12
WHERE bdate > NOW();

-- Data Standardization & Consistency
SELECT DISTINCT
    gen
FROM silver_erp_cust_az12;
