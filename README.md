# TELCO CUSTOMER CHURN 
## Revenue Risk & Retention Strategy
Prepared by: Nothabo Moyo  
Dataset: 7,043 customers | 7,032 validated records (99.84% data integrity)    
Prepared for: VP Customer Success | Chief Revenue Officer | Head of Data | Senior Product Leaders  

## 1. Executive Summary 
Revenue risk is structurally concentrated in early-tenure, high-spend, month-to-month customers. Churn is not random, it is predictable and segment-driven.

### Headline Metrics 
- Total Customers: 7,032
- Overall Churn Rate: 26.58%
- Average Monthly Charge: $64.80
- Monthly Revenue Exposure: $139,131
- Annualized Exposure: $1.67M

### The "So What"
- 1 in 4 customers churn.
- High-value customers represent both the largest revenue base and the highest volatility risk.
- Revenue instability is primarily driven by first-year attrition.
- Contract structure is a primary behavioral driver of churn.

Without targeted intervention, revenue erosion will compound through high-value customer attrition.

## 2. Data Integrity & Governance 
Prior to analysis, a structured data quality framework was implemented to ensure analytical reliability and executive-level confidence:
- Primary key validation
- Duplicate detection (0 duplicates found)
- Categorical standardization
- Missing value remediation
- Business logic validation (excluded 11 tenure = 0 anomalies)
- Feature engineering (spend & life cycle segmentation)
- Production-ready view creation
Result: 7,032 clean records (99.84% retention), ensuring analytical reliability, reporting accuracy, and executive-grade decision support. 

## 3. Business-Relevant SQL Insights
Below are production-level queries that directly inform revenue strategy. 

### A. Contract-Driven Revenue Exposure 
![Contract Analysis](images/contract_analysis.jpeg)  
Insight:
Month-to-month contracts materially drive churn and should be viewed as a structural revenue risk. 
 
### B. Realized Lifetime Value Gap
![Average LTV](images/avg_lifetime_value.jpeg)  
Business Interpretation:
Churned customers realize significantly lower LTV, indicating onboarding and early engagement failure. 

### C. Churn Risk by Tenure & Spend Segment
![Tenure Spend](images/tenure_group_spend_bucket.jpeg)  
Insight: 
- Early-tenure customers on month-to-month contracts.
- High-spend customers with short tenure.
- Low-loalty, high-value segments driving disproportionate risk. 





