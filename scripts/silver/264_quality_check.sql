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

SELECT DISTINCT
  cntry,
  CASE
    WHEN cleaned = '' OR cleaned IS NULL      THEN 'n/a'             -- empty or NULL → 'n/a'
    WHEN UPPER(cleaned) = 'DE'                THEN 'Germany'         -- DE → Germany
    WHEN UPPER(cleaned) IN ('US','USA')       THEN 'United States'   -- US/USA → United States
    ELSE cleaned                                                    -- leave other values unchanged
  END AS cntry
FROM (
  SELECT
    cid,
    cntry,
    -- strip tabs, carriage returns, line feeds, and non-breaking spaces, then trim normal spaces
    TRIM(
      BOTH ' '
      FROM REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(cntry, CHAR(9), ''),     -- remove tab characters
          CHAR(13), ''),                     -- remove carriage returns
        CHAR(10), ''),                       -- remove line feeds
      UNHEX('C2A0'), '')                   -- remove non-breaking spaces
    ) AS cleaned
  FROM bronze_erp_loc_a101
) t
ORDER BY cntry;  -- order by the original country value


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
