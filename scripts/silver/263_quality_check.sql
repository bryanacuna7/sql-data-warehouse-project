-- ============================
-- QUALITY CHECKS - BRONZE LAYER
-- ============================

-- Check for invalid dates

SELECT
	NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM
	bronze_crm_sales_details
WHERE
	sls_due_dt <= 0
	OR LENGTH(sls_due_dt) != 8
	OR sls_due_dt >20500101
	OR sls_due_dt < 19000101;
	
-- Check for invalid date orders	

SELECT * FROM bronze_crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.

SELECT DISTINCT
	sls_sales as old_sls_sales,
	sls_quantity,
	sls_price as old_sls_price,
CASE
	WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
CASE 
	WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity,0)
	ELSE sls_price
END AS sls_price
FROM bronze_crm_sales_details
WHERE (sls_quantity * sls_price) != sls_sales
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY 1,2,3;



-- ============================
-- QUALITY CHECKS - SILVER LAYER
-- After table transformations
-- ============================

-- Check for invalid dates

SELECT
	NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM
	silver_crm_sales_details
WHERE
	sls_due_dt <= 0
	OR LENGTH(sls_due_dt) != 8
	OR sls_due_dt >20500101
	OR sls_due_dt < 19000101;
	
-- Check for invalid date orders	

SELECT * FROM silver_crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.

SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price	
FROM silver_crm_sales_details
WHERE sls_quantity * sls_price != sls_sales
	OR sls_sales IS NULL 
	OR sls_quantity IS NULL 
	OR sls_price IS NULL
	OR sls_sales <= 0 
	OR sls_quantity <= 0 
	OR sls_price <= 0
ORDER BY 1,2,3;
