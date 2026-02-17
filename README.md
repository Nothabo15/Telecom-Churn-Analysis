Telco Customer Churn: Revenue Risk & Retention Strategy

Analyst: Nothabo Moyo
Dataset: 7,043 customer records
Final Analytical Dataset: 7,032 validated records (99.84% retention)
Tools: SQLite (SQL), Tableau
Objective: Identify churn drivers and quantify revenue exposure to inform targeted retention strategy.

Executive Summary

Customer churn analysis revealed that revenue risk is highly concentrated among early-tenure, high-spend customers on month-to-month contracts.While the overall churn rate is 26.58%, risk is not evenly distributed. A small but financially significant segment drives the majority of churn-related revenue exposure, totaling $139,131 in monthly revenue at risk.This project moves beyond churn measurement and delivers segment-level intervention priorities aligned to financial impact.

Business Problem

Customer attrition reduces lifetime value, increases acquisition costs, and creates revenue volatility.

The objective was to:

1. Ensure full data integrity prior to modeling.

2. Identify behavioral and financial churn drivers.

3. Quantify revenue exposure by segment.

4. Translate findings into prioritized retention actions. 

Data Quality & Preparation Pipeline

Before analysis, a structured SQL data validation framework was implemented:

 Primary Key Validation

- Confirmed 1:1 customer-to-record ratio

- No duplicate customer records detected

 Data Standardization

- Cleaned categorical fields (case normalization, trimming)

- Standardized service flags

- Converted TotalCharges from TEXT → NUMERIC with NULL handling

Business Logic Validation

- Identified and excluded 11 inconsistent records (tenure = 0 with charges > 0)

- Final clean dataset: 7,032 records (99.84% integrity retention)

 Feature Engineering

- Spend Segmentation: Low / Medium / High (balanced terciles)

- Tenure Lifecycle Groups:

0–1 year

1–3 years

3+ years

Production Views Created

- churn_new → modeling-ready dataset

- churn_analysis → extended segmentation

- churn_eda_summary → executive dashboard aggregation

This pipeline ensures analytical reliability and production-level reusability.