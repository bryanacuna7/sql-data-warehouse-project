-- ============================
-- QUALITY CHECKS - BRONZE LAYER
-- ============================

-- Check for NULLs or duplicate values in primary key (prd_id)
-- Expectation: No results
SELECT
	prd_id
FROM bronze_crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for leading/trailing unwanted spaces in product names
-- Expectation: No results
SELECT
	prd_nm
FROM bronze_crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or negative values in product cost
-- Expectation: No results
SELECT
	prd_cost
FROM bronze_crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check for inconsistent or unexpected product line values
-- Expectation: Only expected product line codes should appear (e.g., 'M', 'R', 'S', 'T')
SELECT DISTINCT
	prd_line
FROM bronze_crm_prd_info;

-- Check for invalid date orders (end date before start date)
-- Note: If prd_end_dt doesn't exist in bronze, this may need to be removed
-- Expectation: No results
SELECT *
FROM bronze_crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ============================
-- QUALITY CHECKS - SILVER LAYER
-- After table transformations
-- ============================

-- Check for NULLs or duplicate values in primary key (prd_id)
-- Expectation: No results
SELECT
	prd_id,
	COUNT(*)
FROM silver_crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for leading/trailing unwanted spaces in product names
-- Expectation: No results
SELECT
	prd_nm
FROM silver_crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or negative values in product cost
-- Expectation: No results
SELECT
	prd_cost
FROM silver_crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check for consistent product line values
-- Expectation: Only mapped values (Mountain, Road, Other Sales, Touring, n/a)
SELECT DISTINCT
	prd_line
FROM silver_crm_prd_info;

-- Check for invalid date orders (prd_end_dt earlier than prd_start_dt)
-- Expectation: No results
SELECT *
FROM silver_crm_prd_info
WHERE prd_end_dt < prd_start_dt;
