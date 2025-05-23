/*
=============================================================
Create a Single Database with Multiple Tables Organized by Logical Schemas
=============================================================
Script Purpose:
    This script creates a single database named 'DataWarehouse' and sets it up
    as the foundation for organizing tables into logical schemas: 'bronze',
    'silver', and 'gold'. Each logical schema can contain multiple tables.

WARNING:
    If the 'DataWarehouse' database already exists, it will be dropped and recreated.
    All existing data in the database will be lost. Proceed with caution.
=============================================================
*/

-- Drop the 'DataWarehouse' database if it exists
DROP DATABASE IF EXISTS DataWarehouse;

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;

-- Switch to the 'DataWarehouse' database
USE DataWarehouse;

-- Placeholder for bronze schema tables
-- Add the tables for the 'bronze' schema here
-- Example:
-- CREATE TABLE bronze_example_table (...);

-- Placeholder for silver schema tables
-- Add the tables for the 'silver' schema here
-- Example:
-- CREATE TABLE silver_example_table (...);

-- Placeholder for gold schema tables
-- Add the tables for the 'gold' schema here
-- Example:
-- CREATE TABLE gold_example_table (...);
