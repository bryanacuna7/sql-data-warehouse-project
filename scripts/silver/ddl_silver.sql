/*
===============================================================================
DDL Script: Create Silver Tables (MySQL Version - No Schema Prefix)
===============================================================================
Script Purpose:
    This script creates the silver prefixed tables, dropping them first 
    if they already exist.
    Run this script to re-define the DDL structure of the silver layer tables.
===============================================================================
*/

-- Drop and recreate table: silver_crm_cust_info
DROP TABLE IF EXISTS silver_crm_cust_info;

CREATE TABLE silver_crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

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

-- Drop and recreate table: silver_crm_sales_details
DROP TABLE IF EXISTS silver_crm_sales_details;

CREATE TABLE silver_crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Drop and recreate table: silver_erp_loc_a101
DROP TABLE IF EXISTS silver_erp_loc_a101;

CREATE TABLE silver_erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Drop and recreate table: silver_erp_cust_az12
DROP TABLE IF EXISTS silver_erp_cust_az12;

CREATE TABLE silver_erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Drop and recreate table: silver_erp_px_cat_g1v2
DROP TABLE IF EXISTS silver_erp_px_cat_g1v2;

CREATE TABLE silver_erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
