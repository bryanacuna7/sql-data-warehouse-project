-- Insert cleaned and standardized customer data into the silver table
INSERT INTO silver_erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT 
    -- If cid starts with 'NAS', drop the first three characters; otherwise leave it intact
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid 
    END AS cid,

    -- Null out any birthdates that fall in the future
    CASE 
        WHEN bdate > NOW() THEN NULL 
        ELSE bdate 
    END AS bdate,

    -- Normalize gender codes: map any 'F' to 'Female', any 'M' to 'Male', fallback to 'n/a'
    CASE 
        WHEN UPPER(gen) LIKE '%F%' THEN 'Female'
        WHEN UPPER(gen) LIKE '%M%' THEN 'Male'
        ELSE 'n/a'
    END AS gen

FROM bronze_erp_cust_az12;

-- Insert cleaned and standardized location data into the silver table
INSERT INTO silver_erp_loc_a101 (
    cid,
    cntry
)
SELECT DISTINCT
    REPLACE(cid, '-', '') AS cid,  -- Remove hyphens from the customer ID
    CASE
        WHEN cleaned = '' OR cleaned IS NULL THEN 'n/a'         -- Empty or NULL → 'n/a'
        WHEN UPPER(cleaned) = 'DE'           THEN 'Germany'      -- DE → Germany
        WHEN UPPER(cleaned) IN ('US','USA')  THEN 'United States'-- US/USA → United States
        ELSE cleaned                                             -- All other values unchanged
    END AS cntry
FROM (
    SELECT
        cid,
        cntry,
        -- Strip out tabs, carriage returns, line feeds, and non-breaking spaces, then trim ordinary spaces
        TRIM(BOTH ' ' FROM
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(cntry, CHAR(9), ''),    -- remove tab characters
                    CHAR(13), ''),                        -- remove carriage returns
                CHAR(10), ''),                            -- remove line feeds
            UNHEX('C2A0'), ''                              -- remove non-breaking spaces
            )
        ) AS cleaned
    FROM bronze_erp_loc_a101
) t
ORDER BY cntry;  -- Sort by the standardized country value

-- Insert only 'Yes' or 'No' maintenance flags into silver table
INSERT INTO silver_erp_px_cat_g1v2 (
  id,
  cat,
  subcat,
  maintenance
)
SELECT
  id,
  cat,
  subcat,
  CASE
    WHEN UPPER(cleaned) = 'YES' THEN 'Yes'
    WHEN UPPER(cleaned) = 'NO'  THEN 'No'
  END AS maintenance
FROM (
  SELECT
    id,
    cat,
    subcat,
    TRIM(
      BOTH ' '
      FROM REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(maintenance, CHAR(9), ''),   -- remove tabs
          CHAR(13), ''),                         -- remove carriage returns
        CHAR(10), ''),                           -- remove line feeds
      UNHEX('C2A0'), '')                       -- remove non-breaking spaces
    ) AS cleaned
  FROM bronze_erp_px_cat_g1v2
) AS cleaned_flags
WHERE UPPER(cleaned) IN ('YES','NO')
ORDER BY id;
