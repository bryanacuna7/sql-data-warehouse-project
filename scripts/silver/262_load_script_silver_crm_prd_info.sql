-- Drop the table if it already exists to ensure a clean slate
DROP TABLE IF EXISTS silver_crm_prd_info;

-- Create the 'silver_crm_prd_info' table with product details
CREATE TABLE silver_crm_prd_info (
	prd_id INT,
	cat_id NVARCHAR(50),        -- Category ID extracted from product key
	prd_key NVARCHAR(50),       -- Unique product key (modified version)
	prd_nm NVARCHAR(50),        -- Product name
	prd_cost INT,               -- Product cost, defaults to 0 if null
	prd_line NVARCHAR(50),      -- Product line (e.g., Mountain, Road)
	prd_start_dt DATE,          -- Product start date
	prd_end_dt DATE,            -- Product end date (calculated using LEAD)
	dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP -- Record creation timestamp
);

-- Insert transformed and cleaned data from 'bronze_crm_prd_info' into 'silver_crm_prd_info'
INSERT INTO silver_crm_prd_info (
	prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,             -- Extract and clean category ID
	SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,                 -- Extract actual product key
	prd_nm,
	IFNULL(prd_cost, 0) AS prd_cost,                                   -- Replace null cost with 0
	CASE UPPER(TRIM(prd_line))                                         -- Map product line codes to labels
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	DATE(prd_start_dt) AS prd_start_dt,
	-- Set prd_end_dt to the day before the next start date for the same product key
	DATE(
		LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL 1 DAY
	) AS prd_end_dt
FROM bronze_crm_prd_info;
