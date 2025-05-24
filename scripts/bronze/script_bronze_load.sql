-- language: sql

/*
=============================================================
Load Source Data into Bronze Layer Tables
=============================================================
Script Purpose:
    This script truncates and reloads data from various CSV source files
    into their corresponding tables within the 'bronze' schema. These
    tables serve as the raw ingestion layer of the data warehouse, storing
    untransformed CRM and ERP data.

Sources:
    - CRM customer info (cust_info.csv)
    - CRM product info (prd_info.csv)
    - CRM sales details (sales_details.csv)
    - ERP customer data (CUST_AZ12.csv)
    - ERP location data (LOC_A101.csv)
    - ERP product categories (PX_CAT_G1V2.csv)

WARNING:
    Each table is truncated before data is reloaded. Any existing data in
    the tables will be permanently removed. Ensure backups exist if needed.
=============================================================
*/

-- Clear and load CRM customer info
TRUNCATE TABLE bronze_crm_cust_info;
LOAD DATA LOCAL INFILE '/Users/bryanacuna/Documents/Education/SQL/Baraa/SQL Data Warehouse Project/datasets/source_crm/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','  
IGNORE 1 ROWS;

-- Clear and load CRM product info
TRUNCATE TABLE bronze_crm_prd_info;
LOAD DATA LOCAL INFILE '/Users/bryanacuna/Documents/Education/SQL/Baraa/SQL Data Warehouse Project/datasets/source_crm/prd_info.csv'
INTO TABLE bronze_crm_prd_info
FIELDS TERMINATED BY ','  
IGNORE 1 ROWS;

-- Clear and load CRM sales details
TRUNCATE TABLE bronze_crm_sales_details;
LOAD DATA LOCAL INFILE '/Users/bryanacuna/Documents/Education/SQL/Baraa/SQL Data Warehouse Project/datasets/source_crm/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ','  
IGNORE 1 ROWS;

-- Clear and load ERP customer data
TRUNCATE TABLE bronze_erp_cust_az12;
LOAD DATA LOCAL INFILE '/Users/bryanacuna/Documents/Education/SQL/Baraa/SQL Data Warehouse Project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ','  
IGNORE 1 ROWS;

-- Clear and load ERP location data
TRUNCATE TABLE bronze_erp_loc_a101;
LOAD DATA LOCAL INFILE '/Users/bryanacuna/Documents/Education/SQL/Baraa/SQL Data Warehouse Project/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ','  
IGNORE 1 ROWS;

-- Clear and load ERP product categories
TRUNCATE TABLE bronze_erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE '/Users/bryanacuna/Documents/Education/SQL/Baraa/SQL Data Warehouse Project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ','  
IGNORE 1 ROWS;
