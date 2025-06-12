-- Insert cleaned and standardized customer data into the silver table
INSERT INTO silver_erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT 
    -- If the customer ID starts with 'NAS', strip off the first three characters; otherwise leave it unchanged
    CASE 
        WHEN cid LIKE 'NAS%' 
            THEN SUBSTRING(cid, 4, LENGTH(cid)) 
        ELSE cid 
    END AS cid,

    -- If the birthdate is in the future, null it out; otherwise keep the original date
    CASE 
        WHEN bdate > NOW() 
            THEN NULL 
        ELSE bdate 
    END AS bdate,

    -- Normalize gender indicators: map any form of 'F' to 'Female', any 'M' to 'Male', fallback to 'n/a'
    CASE 
        WHEN UPPER(gen) LIKE '%F%' THEN 'Female'
        WHEN UPPER(gen) LIKE '%M%' THEN 'Male'
        ELSE 'n/a'
    END AS gen

FROM bronze_erp_cust_az12;
