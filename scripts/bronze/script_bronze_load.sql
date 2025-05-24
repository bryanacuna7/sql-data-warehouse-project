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
