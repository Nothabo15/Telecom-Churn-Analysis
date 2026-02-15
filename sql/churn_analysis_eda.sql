-- ===================================================
-- TELCO CUSTOMER CHURN EXLORATORY DATA ANALYSIS
--Analyst: Nothabo Moyo
--Dataset: churn_new (7,032 clean customer records)
--Objective: Identify churn patterns and revenue risk drivers
--Output: Executive-ready churn insights
--SQL Dialect: SQLite
-- ===================================================

-- 1. Baseline Churn Overview
-- Actual churn rate is  26.58% 
SELECT 
		Churn,
		COUNT(*) AS customers,
		ROUND (100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct -- Window function used to calculate % of total customers
FROM churn_new
GROUP BY Churn;

-- 2. Churn by Customer Lifecycle
-- 2.1 Establish the tenure group churn stats | What % of total churners are in 0-1 year?
SELECT 
		tenure_group,
		Churn,
		COUNT(*) AS customers
FROM churn_new
GROUP BY tenure_group, Churn
ORDER BY tenure_group;

-- 2.2 Identify early vs long-term churn risk
--Early-life customers churn at the highest rate (48.54%) | onboarding risk
SELECT 
			tenure_group,
			ROUND(
							100.0 * SUM(CASE WHEN Churn = 'YES' THEN 1 ELSE 0 END) / COUNT(*),
							2
				       ) AS churn_rate_pct
FROM churn_new
GROUP BY tenure_group
ORDER BY churn_rate_pct DESC;

-- 3. Churn by Spend Level (Revenue Exposure)
-- High-spend customers represent the largest segment (3,581 customers) with the highest average monthly charge ($90.24),
-- and the highest churn rate (35.38%), compared to Medium (24.39%) and Low spend customers (9.84%).
SELECT
			spend_bucket, 
			COUNT(*) AS customers,
			ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge, 
			ROUND(
						100.0 * SUM(CASE WHEN Churn = 'YES' THEN 1 ELSE 0 END) / COUNT(*), 
						2
				) AS churn_rate_pct
FROM churn_new
GROUP BY spend_bucket;

-- 4. Churn by Contract Stability
-- Month-to-month contracts drive churn | Upsell opportunity to longer-term plans
-- churn_analysis created to include Contract column not present in churn_new
DROP VIEW IF EXISTS churn_analysis;

CREATE VIEW churn_analysis AS 
SELECT 
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents, 
    Contract,
    tenure,
    tenure_group,
    MonthlyCharges,
    TotalCharges,
    spend_bucket,
    Churn
FROM telco_churn
WHERE TotalCharges IS NOT NULL;

SELECT 
    Contract, 
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'YES' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct,
    COUNT(*) AS customers
FROM churn_analysis
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- 5. Demographic & Household Factors 
-- 5.1 SeniorCitizen | Senior Citizens have a high churn rate at 41.68%
SELECT
		SeniorCitizen, 
		ROUND(
					100.0 * SUM(CASE WHEN Churn = 'YES' THEN 1 ELSE 0 END) / COUNT(*),
					2
				) AS churn_rate_pct
FROM churn_analysis
GROUP BY SeniorCitizen;

-- 5.2 Partner/ Dependents | Customers with neither a partner nor dependents have the highest churn rate (34.24%)
SELECT 
      Partner,
	  Dependents, 
	  ROUND(
				100.0 * SUM(CASE WHEN Churn = 'YES' THEN 1 ELSE 0 END) / COUNT(*), 
				2
			) AS churn_rate_pct
FROM churn_analysis
GROUP BY Partner, Dependents;

-- 6. Tenure x Spend Interaction 
-- High spend + short-tenure customers = highest churn risk 
SELECT 
		tenure_group, 
		spend_bucket, 
		ROUND(
				100.0 * SUM(CASE WHEN Churn = 'YES' THEN 1 ELSE 0 END) / COUNT(*), 
				2
			) AS churn_rate_pct,
			COUNT(*) AS customers
FROM churn_analysis
GROUP BY tenure_group, spend_bucket
ORDER BY churn_rate_pct DESC;

-- 7. Customer Lifetime Value Comparison
-- Churned customers represent significantly low realized LTV at $1,531.80
SELECT 
	Churn, 
	ROUND(AVG(TotalCharges), 2) AS avg_lifetime_value
FROM churn_analysis
GROUP BY Churn;

-- 8. Executive EDA Summary View 
-- For dashboarding, stakeholder reporting, cohort analysis
DROP VIEW IF EXISTS churn_eda_summary;

CREATE VIEW churn_eda_summary AS 
SELECT 
		tenure_group, 
		spend_bucket, 
		COUNT(*) AS customers, 
		ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge, 
		ROUND(
					100.0 * SUM(CASE WHEN Churn = 'YES' THEN 1 ELSE 0 END) / COUNT(*), 
					2
				) AS churn_rate_pct
FROM churn_analysis
GROUP BY tenure_group, spend_bucket; 

-- 9. Strategic Intervention
-- Priorities
-- Ranked by: ( Segment Size x Churn Rate x Avg Monthly Charge) / Implementation Complexity
WITH risk_scored AS (
			SELECT
						tenure_group, 
						spend_bucket, 
						COUNT(*) * 
						(SUM(CASE WHEN Churn = 'YES' 
THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) *
			AVG(MonthlyCharges) AS 
revenue_at_risk_score
		FROM churn_analysis
		GROUP BY tenure_group, 
spend_bucket
)
SELECT 
			tenure_group || ' + ' || 
spend_bucket AS segment, 
			ROUND(revenue_at_risk_score, 0) AS risk_score, 
		CASE 
				WHEN tenure_group = '0-1 year'
AND spend_bucket = 'High'
				THEN 'URGENT: Day-30 proactive outreach'
				WHEN spend_bucket = 'High'
				THEN 'HIGH: Loyalty program eligibility'
				ELSE 'MONITOR: Quartely health checks'
		END AS recommended_action, 
		CASE 
				WHEN tenure_group = '0-1 year'
		THEN 'Immediate'
				WHEN tenure_group = '1-2 years'
			THEN 'This quarter'
			ELSE 'Annual review'
	END AS timeline
FROM risk_scored
ORDER BY revenue_at_risk_score DESC
LIMIT 3;

