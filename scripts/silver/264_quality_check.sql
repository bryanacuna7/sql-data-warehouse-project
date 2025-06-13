-- ============================
-- QUALITY CHECKS – BRONZE LAYER
-- ============================

-- Identify birthdates that are unrealistically old or in the future
SELECT DISTINCT
    bdate
FROM bronze_erp_cust_az12
WHERE bdate < '1924-01-01'      -- before Jan 1, 1924
   OR bdate > NOW();            -- after current timestamp

-- Standardize gender codes
SELECT DISTINCT
    gen AS original_gen,
    CASE 
        WHEN UPPER(gen) LIKE '%F%' THEN 'Female'   -- any form of F → Female
        WHEN UPPER(gen) LIKE '%M%' THEN 'Male'     -- any form of M → Male
        ELSE 'n/a'                                 -- all other or missing → n/a
    END AS standardized_gen
FROM bronze_erp_cust_az12;

-- Standardize country values
SELECT DISTINCT
  cntry,
  CASE
    WHEN cleaned = '' OR cleaned IS NULL      THEN 'n/a'             -- empty or NULL → n/a
    WHEN UPPER(cleaned) = 'DE'                THEN 'Germany'         -- DE → Germany
    WHEN UPPER(cleaned) IN ('US','USA')       THEN 'United States'   -- US/USA → United States
    ELSE cleaned                                                    -- leave other values unchanged
  END AS cntry
FROM (
  SELECT
    cid,
    cntry,
    -- remove tabs, CR, LF, NBSP and then trim normal spaces
    TRIM(
      BOTH ' '
      FROM REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(cntry, CHAR(9), ''),     -- strip tab chars
                  CHAR(13), ''),            -- strip carriage returns
              CHAR(10), ''),                -- strip line feeds
        UNHEX('C2A0'), ''                   -- strip non-breaking spaces
    )) AS cleaned
  FROM bronze_erp_loc_a101
) t
ORDER BY cntry;  -- sort by country code


-- ============================
-- QUALITY CHECKS – SILVER LAYER
-- After table transformations
-- ============================

-- Identify any future-dated birthdates after loading
SELECT DISTINCT
    bdate
FROM silver_erp_cust_az12
WHERE bdate > NOW();            -- should not happen after cleaning

-- Inspect normalized gender values
SELECT DISTINCT
    gen                            -- should already be 'Female', 'Male', or 'n/a'
FROM silver_erp_cust_az12;

-- Verify country standardization post-load
SELECT DISTINCT
  cntry,
  CASE
    WHEN cleaned = '' OR cleaned IS NULL      THEN 'n/a'
    WHEN UPPER(cleaned) = 'DE'                THEN 'Germany'
    WHEN UPPER(cleaned) IN ('US','USA')       THEN 'United States'
    ELSE cleaned
  END AS cntry
FROM (
  SELECT
    cid,
    cntry,
    -- repeat whitespace cleanup for silver layer
    TRIM(
      BOTH ' '
      FROM REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(cntry, CHAR(9), ''), 
                  CHAR(13), ''), 
              CHAR(10), ''), 
        UNHEX('C2A0'), '' 
    )) AS cleaned
  FROM silver_erp_loc_a101
) t
ORDER BY cntry;  -- confirm consistency of country values

-- ============================
-- QUALITY CHECKS – BRONZE LAYER
-- ============================

-- Check for Unwanted Spaces

SELECT 
	*
FROM bronze_erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Data Standarization & Consistency

SELECT DISTINCT cat
FROM bronze_erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM bronze_erp_px_cat_g1v2;

-- Standardize maintenance flag values

WITH cleaned_flags AS (
  SELECT
    -- strip tabs, CR, LF, NBSP, then trim regular spaces
    TRIM(
      BOTH ' '
      FROM REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(maintenance, CHAR(9), ''),    -- remove tabs
          CHAR(13), ''),                          -- remove carriage returns
        CHAR(10), ''),                            -- remove line feeds
      UNHEX('C2A0'), '')                        -- remove non-breaking spaces
    ) AS cleaned
  FROM bronze_erp_px_cat_g1v2
)
SELECT DISTINCT
  CASE
    WHEN UPPER(cleaned) = 'YES' THEN 'Yes'   -- map any exact YES → 'Yes'
    WHEN UPPER(cleaned) = 'NO'  THEN 'No'    -- map any exact NO  → 'No'
  END AS maintenance
FROM cleaned_flags
WHERE UPPER(cleaned) IN ('YES','NO')       -- filter out any other values
ORDER BY maintenance;

-- ============================
-- QUALITY CHECKS – SILVER LAYER
-- After table transformations
-- ============================

-- Check for Unwanted Spaces

SELECT 
	*
FROM silver_erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Data Standarization & Consistency

SELECT DISTINCT cat
FROM silver_erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM silver_erp_px_cat_g1v2;

-- Standardize maintenance flag values

SELECT DISTINCT maintenance
FROM silver_erp_px_cat_g1v2;
