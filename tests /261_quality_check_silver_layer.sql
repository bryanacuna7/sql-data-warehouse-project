-- Check for nulls or duplicates in Primary Key
-- Expectation: No Results

SELECT
	cst_id,
	COUNT(*)
FROM
	silver_crm_cust_info
GROUP BY
	cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Check for unwanted spaces
-- Expectation: No Results

SELECT
	cst_firstname
FROM
	silver_crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT
	cst_lastname
FROM
	silver_crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


-- Data Standarization & Consistency

SELECT
	DISTINCT cst_gndr
FROM
	silver_crm_cust_info;


SELECT
	DISTINCT cst_marital_status
FROM
	silver_crm_cust_info;
	
	
