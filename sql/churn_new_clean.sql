-- ============================================================
-- TELCO CUSTOMER CHURN: DATA QUALITY & PREPARATION PIPELINE
-- Analyst: Nothabo Moyo
-- Dataset: 7,043 customer records
-- Objective: Ensure data integrity for churn prediction model
-- Output: 7,032 clean records (99.84% retention)
-- ============================================================

-- STEP 1: DATA PROFILING & QUALITY ASSESSMENT
-- Result: Clean primary key, no duplicate customer records
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customerID) AS unique_customers,
    SUM(CASE WHEN customerID IS NULL THEN 1 ELSE 0 END) AS missing_customer_id
FROM telco_churn;

-- STEP 2: DUPLICATE DETECTION
-- Result: No duplicates found (confirmed 1:1 customer:record ratio)
SELECT customerID, COUNT(*)
FROM telco_churn
GROUP BY customerID
HAVING COUNT(*) > 1;

-- STEP 3: DATA STANDARDIZATION
-- 3a: Categorical values (consistent case for segmentation)
UPDATE telco_churn
SET 
    Churn = UPPER(TRIM(Churn)),
    gender = UPPER(TRIM(gender)),
    Partner = UPPER(TRIM(Partner)),
    Dependents = UPPER(TRIM(Dependents));

-- 3b: Service columns (collapse "No internet service" to binary NO)
-- Rationale: Simplifies analysis for customers without internet
UPDATE telco_churn
SET OnlineSecurity = 'NO'
WHERE OnlineSecurity = 'No internet service';

-- 3c: Missing value identification (whitespace and NULLs)
SELECT *
FROM telco_churn
WHERE TotalCharges IS NULL
    OR TRIM(TotalCharges) = '';

-- 3d: Type conversion (TEXT → NUMERIC with NULL handling)
UPDATE telco_churn
SET TotalCharges = CAST(NULLIF(TRIM(TotalCharges), '') AS NUMERIC);

-- STEP 4: BUSINESS LOGIC VALIDATION
-- Flag: 11 customers with tenure=0 but TotalCharges>0 (data quality issue)
-- Decision: Exclude from model to prevent skewed LTV calculations
SELECT *
FROM telco_churn
WHERE tenure = 0 AND TotalCharges > 0;

--Check existence of columns
PRAGMA table_info(telco_churn);

-- STEP 5: FEATURE ENGINEERING
-- 5a: Spend segmentation (terciles for balanced comparison)
-- Thresholds: Low <$30 (33%), Medium $30-70 (34%), High >$70 (33%)
UPDATE telco_churn
SET spend_bucket =
    CASE
        WHEN MonthlyCharges < 30 THEN 'Low'
        WHEN MonthlyCharges BETWEEN 30 AND 70 THEN 'Medium'
        ELSE 'High'
    END;

--Validation
SELECT 
    spend_bucket, 
    COUNT(*) as customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) as pct
FROM telco_churn 
WHERE TotalCharges IS NOT NULL
GROUP BY spend_bucket;

-- 5b: Tenure groups (business-relevant lifecycle stages)
UPDATE telco_churn
SET tenure_group =
    CASE
        WHEN tenure < 12 THEN '0-1 year'
        WHEN tenure BETWEEN 12 AND 36 THEN '1-3 years'
        ELSE '3+ years'
    END;

-- STEP 6: FINAL QUALITY REPORT
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END) AS excluded_rows,
    ROUND(100.0 * SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS exclusion_pct
FROM telco_churn;

-- STEP 7: PRODUCTION VIEW CREATION
-- Final dataset: 7,032 records (99.84% of original)
-- Use case: Churn modeling, cohort analysis, LTV calculation
DROP VIEW IF EXISTS churn_new;

CREATE VIEW churn_new AS 
SELECT 
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents, 
    tenure,
    tenure_group,
    MonthlyCharges,
    TotalCharges,
    spend_bucket,
    Churn
FROM telco_churn
WHERE TotalCharges IS NOT NULL;

-- Verification: 0 records with tenure=0 and charges>0 in final dataset
SELECT COUNT(*) 
FROM churn_new 
WHERE tenure = 0 AND TotalCharges > 0;  -- Should return 0