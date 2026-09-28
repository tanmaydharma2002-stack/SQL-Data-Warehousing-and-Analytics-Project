/*
=======================================================================
Quality Checks
=======================================================================
Script Purpose:
This script performs various quality checks for data consistency, accuracy,
and standardization across the 'silver' schemas. It includes checks for:
- Null or duplicate primary keys.
- Unwanted spaces in string fields.
- Data standardization and consistency.
- Invalid date ranges and orders.
- Data consistency between related fields.

Usage Notes:
- Run these checks after data loading Silver Layer.
- Investigate and resolve any discrepancies found during the checks.

==================================================================================
*/
=========================================
-- Checking silver.crm_cust_info
========================================
-- -- Check for Unwanted Spaces
-- Expectatiions: No results

SELECT * FROM silver.crm_cust_info;

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);


======================================================
-- Checking silver.crm_prd_info
=====================================================
-- Checking for Nulls and Duplicates in primary 
-- Expectations: No Results 
SELECT prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- No results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for Invalid cost values (Nulls and Negatives)
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Data Standardization and Consistency
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

--Check for Invalid Date Orders
-- Expectations: No results
SELECT prd_id,
prd_key,
prd_start_dt,
prd_end_dt
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;


SELECT * FROM silver.crm_prd_info;


======================================================================
-- Checking silver.crm_sales_details
========================================================================

-- Checking invalid Values
SELECT sls_price
FROM silver.crm_sales_details
WHERE sls_price < 0 OR sls_price IS NULL;

--Checking Unwanted Spaces
-- Expectations: No result
SELECT * FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);


-- Check whether Order Dates are earlier than Ship and due dates
-- Expectations: They should be
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

--Check Data Consistency: Between Sales, Quantity, and Price
-- Sales = Quantity * Price
-- Values must not be NULL, zero, or negative.

SELECT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


=====================================================
-- Checking silver.erp_cust_azi2
======================================================
-- Checking primarry key for NULLs and Duplicates (All before loading data to silver layer)
SELECT cid, COUNT(cid)
FROM silver.erp_cust_azi2
GROUP BY cid
HAVING COUNT(cid) > 1 OR cid IS NULL;

-- Check for Null dates
--Expectations: No results 
SELECT bdate
FROM silver.erp_cust_azi2
WHERE bdate IS NULL;

-- Check for out of range dates
--Expectations: No results 
SELECT bdate
FROM silver.erp_cust_azi2
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Data Standardization and Consistency
SELECT DISTINCT gen 
FROM silver.erp_cust_azi2;


===================================================
-- Checking silver.erp_loc_a101
===================================================
SELECT DISTINCT cntry FROM silver.erp_loc_a101;


===================================================
-- Checking silver.erp_px_cat_g1v2
===================================================
SELECT * FROM silver.erp_px_cat_g1v2;
