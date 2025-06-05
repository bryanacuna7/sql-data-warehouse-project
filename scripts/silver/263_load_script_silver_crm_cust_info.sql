-- Insert transformed and cleaned data from 'bronze_crm_sales_details' into 'silver_crm_sales_details'
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

-- Step 1: Use a CTE to normalize prices first
WITH cleaned_prices AS (
    SELECT
        sls_ord_num,            -- Sales order number (unchanged)
        sls_prd_key,            -- Product key (unchanged)
        sls_cust_id,            -- Customer ID (unchanged)

        /*
         * Convert sls_order_dt (VARCHAR 'YYYYMMDD') to DATE.
         * If the value is 0 or not exactly 8 characters, treat as NULL.
         */
        CASE
            WHEN sls_order_dt = 0
              OR LENGTH(sls_order_dt) != 8
            THEN NULL
            ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
        END AS sls_order_dt,

        /*
         * Convert sls_ship_dt (VARCHAR 'YYYYMMDD') to DATE.
         * If the value is 0 or not exactly 8 characters, treat as NULL.
         */
        CASE
            WHEN sls_ship_dt = 0
              OR LENGTH(sls_ship_dt) != 8
            THEN NULL
            ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
        END AS sls_ship_dt,

        /*
         * Convert sls_due_dt (VARCHAR 'YYYYMMDD') to DATE.
         * If the value is 0 or not exactly 8 characters, treat as NULL.
         */
        CASE
            WHEN sls_due_dt = 0
              OR LENGTH(sls_due_dt) != 8
            THEN NULL
            ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
        END AS sls_due_dt,

        sls_quantity,           -- Quantity of products sold (unchanged)

        sls_sales       AS sls_sales_original,  -- Preserve original sales value
        sls_price       AS sls_price_original,  -- Preserve original price value

        /*
         * Compute an intermediate “price2” based on the original sls_price:
         *   1) If sls_price < 0, use ABS(sls_price) to convert to positive.
         *   2) If sls_price IS NULL or = 0, recalculate as sls_sales_original / sls_quantity
         *      • Use NULLIF(sls_quantity, 0) to avoid division by zero
         *      • ROUND result to 2 decimal places
         *   3) Otherwise, keep sls_price as is.
         */
        CASE
            WHEN sls_price < 0
                THEN ABS(sls_price)

            WHEN sls_price IS NULL
              OR sls_price = 0
                THEN ROUND(sls_sales / NULLIF(sls_quantity, 0), 2)

            ELSE sls_price
        END AS price2

    FROM bronze_crm_sales_details
)

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    sls_order_dt,   -- Converted order date
    sls_ship_dt,    -- Converted ship date
    sls_due_dt,     -- Converted due date

    /*
     * Compute final sls_sales:
     *   a) If sls_sales_original IS NULL, ≤ 0, or does not equal (sls_quantity * price2),
     *      recalculate as (sls_quantity * price2).
     *   b) Otherwise, keep sls_sales_original.
     */
    CASE
        WHEN sls_sales_original IS NULL
          OR sls_sales_original <= 0
          OR sls_sales_original <> sls_quantity * price2
        THEN sls_quantity * price2
        ELSE sls_sales_original
    END AS sls_sales,

    sls_quantity,    -- Quantity (unchanged)

    price2 AS sls_price  -- Final normalized price
FROM cleaned_prices;
