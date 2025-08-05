/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for a specific table.

Tables Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Retrieve a list of all tables within the 'DataWarehouse' schema
SELECT
    *
FROM information_schema.tables
WHERE table_schema = 'DataWarehouse';

-- Retrieve all columns and metadata for the 'gold_dim_customers' table
SELECT
    *
FROM information_schema.columns
WHERE table_name = 'gold_dim_customers';
