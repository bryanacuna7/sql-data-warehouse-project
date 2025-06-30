/*
===========================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===========================================================================

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.

    Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

===========================================================================
*/

CREATE PROCEDURE `script_silver_load`()
BEGIN
    -- ================================================
    -- Section 1: Load latest customer records
    --   - Keep only most recent entry per customer
    --   - Trim whitespace, normalize status/gender codes
    -- ================================================
    TRUNCATE TABLE silver_crm_cust_info;

    INSERT INTO silver_crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,          -- Remove extra spaces
        TRIM(cst_lastname)  AS cst_lastname,
        CASE                                           -- Map code to full status
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE                                           -- Map code to full gender
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date                               -- Source creation timestamp
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS flag_last                            -- Rank by most recent
        FROM bronze_crm_cust_info
        WHERE cst_id IS NOT NULL
          AND cst_id != 0
    ) t
    WHERE flag_last = 1;                              -- Only the latest record

    -- ================================================
    -- Section 2: Load product master data
    --   - Extract category and product keys
    --   - Fill missing costs with zero
    --   - Map line codes to descriptive names
    --   - Compute end date as day before next start
    -- ================================================
    TRUNCATE TABLE silver_crm_prd_info;

    INSERT INTO silver_crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,  -- Standardize category IDs
        SUBSTRING(prd_key, 7)           AS prd_key,             -- Remove prefix
        prd_nm,
        COALESCE(prd_cost, 0)           AS prd_cost,            -- Default null to zero
        CASE UPPER(TRIM(prd_line))                               -- Normalize product lines
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        DATE(prd_start_dt)               AS prd_start_dt,
        DATE(
            LEAD(prd_start_dt) OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ) - INTERVAL 1 DAY
        )                                 AS prd_end_dt          -- End one day before next
    FROM bronze_crm_prd_info;

    -- ================================================
    -- Section 3: Load and clean sales details
    --   - Parse string dates to DATE, nullify invalid values
    --   - Calculate unit price fallback and fix negatives
    --   - Correct sales amount if mismatched or invalid
    -- ================================================
    TRUNCATE TABLE silver_crm_sales_details;

    INSERT INTO silver_crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
        cp.sls_ord_num,
        cp.sls_prd_key,
        cp.sls_cust_id,
        cp.sls_order_dt,
        cp.sls_ship_dt,
        cp.sls_due_dt,
        CASE                                                  -- Ensure sales amount consistency
            WHEN cp.sls_sales_original IS NULL
              OR cp.sls_sales_original <= 0
              OR cp.sls_sales_original <> cp.sls_quantity * cp.price2
            THEN cp.sls_quantity * cp.price2
            ELSE cp.sls_sales_original
        END AS sls_sales,
        cp.sls_quantity,
        cp.price2 AS sls_price                              -- Final unit price
    FROM (
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE WHEN sls_order_dt = '0' OR LENGTH(sls_order_dt) <> 8
                 THEN NULL
                 ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d') END AS sls_order_dt,
            CASE WHEN sls_ship_dt  = '0' OR LENGTH(sls_ship_dt)  <> 8
                 THEN NULL
                 ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d') END AS sls_ship_dt,
            CASE WHEN sls_due_dt   = '0' OR LENGTH(sls_due_dt)   <> 8
                 THEN NULL
                 ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d') END AS sls_due_dt,
            sls_quantity,
            sls_sales    AS sls_sales_original,
            sls_price    AS sls_price_original,
            CASE                                                -- Handle invalid or zero prices
                WHEN sls_price < 0                          THEN ABS(sls_price)
                WHEN sls_price IS NULL OR sls_price = 0     THEN ROUND(sls_sales/NULLIF(sls_quantity,0),2)
                ELSE sls_price
            END AS price2
        FROM bronze_crm_sales_details
    ) AS cp;

    -- ================================================
    -- Section 4: Load ERP customer demographic data
    --   - Strip 'NAS' prefix
    --   - Nullify future birthdates
    --   - Standardize gender codes
    -- ================================================
    TRUNCATE TABLE silver_erp_cust_az12;

    INSERT INTO silver_erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)       -- Remove 'NAS' prefix
            ELSE cid
        END AS cid,
        CASE                                            -- Prevent future birth dates
            WHEN bdate > NOW() THEN NULL
            ELSE bdate
        END AS bdate,
        CASE                                            -- Normalize gender flags
            WHEN UPPER(gen) LIKE '%F%' THEN 'Female'
            WHEN UPPER(gen) LIKE '%M%' THEN 'Male'
            ELSE 'n/a'
        END AS gen
    FROM bronze_erp_cust_az12;

    -- ================================================
    -- Section 5: Load ERP location data
    --   - Clean whitespace and non-breaking spaces
    --   - Standardize country codes
    -- ================================================
    TRUNCATE TABLE silver_erp_loc_a101;

    INSERT INTO silver_erp_loc_a101 (
        cid,
        cntry
    )
    SELECT DISTINCT
        REPLACE(cid, '-', '') AS cid,                   -- Remove hyphens from ID
        CASE                                            -- Map country codes
            WHEN cleaned = '' OR cleaned IS NULL THEN 'n/a'
            WHEN UPPER(cleaned) = 'DE'      THEN 'Germany'
            WHEN UPPER(cleaned) IN ('US','USA') THEN 'United States'
            ELSE cleaned
        END AS cntry
    FROM (
        SELECT
            cid,
            cntry,
            TRIM(
                BOTH ' ' FROM
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(cntry, CHAR(9), ''),    -- Remove tabs
                                    CHAR(13), ''),       -- Remove CR
                                CHAR(10), ''),          -- Remove LF
                    UNHEX('C2A0'), ''                    -- Remove non-breaking space
                )
            ) AS cleaned
        FROM bronze_erp_loc_a101
    ) t
    ORDER BY cntry;

    -- ================================================
    -- Section 6: Load ERP maintenance flags
    --   - Clean whitespace/controls
    --   - Only include valid YES/NO entries
    -- ================================================
    TRUNCATE TABLE silver_erp_px_cat_g1v2;

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
        CASE                                             -- Map cleaned flags
            WHEN UPPER(cleaned) = 'YES' THEN 'Yes'
            WHEN UPPER(cleaned) = 'NO'  THEN 'No'
        END AS maintenance
    FROM (
        SELECT
            id,
            cat,
            subcat,
            TRIM(
                BOTH ' ' FROM
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(maintenance, CHAR(9), ''),
                                    CHAR(13), ''),
                                CHAR(10), ''),
                    UNHEX('C2A0'), ''
                )
            ) AS cleaned
        FROM bronze_erp_px_cat_g1v2
    ) AS cleaned_flags
    WHERE UPPER(cleaned) IN ('YES','NO')               -- Exclude invalid values
    ORDER BY id;

END
