# Bank-Transaction-Analysis
## Overview
This project analyzes bank transaction data to understand customer behavior, financial stability, and engagement patterns. The goal is to transform raw transaction records into actionable insights that support customer segmentation, retention strategies, and risk monitoring.

An interactive dashboard was created to visualize customer health, spending behavior, geographic patterns, and volatility metrics, enabling stakeholders to quickly assess trends and identify high-value or at-risk customers.

---

## Business Objectives

The project answers the following key business questions:

1. Who are the most valuable customers?

2. How does customer behavior differ by segment?

3. What are the dominant spending patterns?

4. Which customers show declining activity?

5. Which customers are financially unstable?

6. How volatile are customer balances?

7. How often do customers interact with the bank?

8. Are there geographic differences in behavior?

9. How does customer behavior change over time?

10. Are there seasonal transaction patterns?

11. Which customers should be targeted for retention?

12. Which customers are candidates for upselling?

13. Can a customer health score be assigned?

---

## Dataset Description 
- **Source:** Kaggle – Bank Transaction Dataset  
Time Period: 2023 – 2024
Size: 2,500+ transaction records

Key Fields:
- Customer ID
- Transaction date
- Transaction amount
- Account balance
- Customer segment (VIP, Regular, Occasional)
- Geographic location
- Occupation
- Transaction frequency

The dataset includes both behavioral and financial attributes, enabling analysis across engagement, risk, and value dimensions.

---

## Methodology

### Data Preparation
- Cleaned and standardized transaction dates and numeric fields
- Aggregated transaction metrics per customer (total spend, frequency, volatility)
- Derived monthly and quarterly activity trends

### Customer Segmentation Logic
Customers were segmented based on transaction frequency and total lifetime value:
- **VIP**: High spend and high activity
- **Regular**: Moderate spend and activity
- **Occasional**: Low spend and infrequent transactions

### Risk Indicators Identified
- Balance volatility
- Declining transaction frequency
- Spending outliers
- Low customer health scores

These indicators were used to flag financially unstable or disengaging customers.

---

## Key Findings
- VIP customers account for a disproportionate share of total transaction value despite representing a smaller portion of the customer base.
- Occasional customers show the highest balance volatility and the lowest long-term value.
- Los Angeles and New York exhibit higher customer concentration and transaction volumes compared to other cities.
- Customer activity peaks mid-year, with a noticeable decline toward the end of the year, indicating seasonal behavior.
- A subset of customers demonstrates declining activity trends, suggesting churn risk.
- High-value customers display more consistent transaction patterns and lower volatility.
- A customer health score can effectively distinguish stable, engaged customers from at-risk accounts.
---


## Tools & Technologies
- **SQL**: (database implementation to be added)
- **Microsoft Excel**: Data transformation and aggregation
- **Data Visualization**: Excel charts and dashboard design
- **GitHub** for version control

---

## Dashboard Highlights
The dashboard provides a high-level executive summary and detailed behavioral analysis, including:
- Customer health vs. recency
- Segment distribution and lifetime value
- Geographic performance comparison
- Monthly activity trends
- Spending outlier detection
- Balance volatility analysis
  
  Dashboard preview:
<img width="1413" height="704" alt="image" src="https://github.com/user-attachments/assets/12bc6686-b7d4-4c57-9616-c3603f5e5aa7" />

---
## SQL Query Examples
- Customer segmentation calculation:
WITH customer_base AS (
SELECT 
"AccountID",
SUM("TransactionAmount") AS total_spent,
COUNT("TransactionID") AS total_orders,
MAX("TransactionDate") AS last_active,
CASE 
WHEN SUM("TransactionAmount") > 5000 THEN 'VIP'
WHEN SUM("TransactionAmount") BETWEEN 1000 AND 5000 THEN 'Regular'
ELSE 'Occasional'
END AS customer_segment
FROM "Customer_Data"
GROUP BY "AccountID"
)

SELECT 
    customer_segment,
    COUNT("AccountID") AS customer_count,
    ROUND(AVG(total_spent)::numeric, 2) AS avg_lifetime_value,
    ROUND(AVG(total_orders)::numeric, 1) AS avg_purchase_frequency,
    ROUND(AVG(CURRENT_DATE - last_active::date)::numeric, 0) AS avg_days_since_last_purchase
FROM customer_base
GROUP BY customer_segment
ORDER BY avg_lifetime_value DESC;
'''
**Purpose**:
Classifies customers into VIP, Regular, and Occasional segments based on total transaction value and calculates key behavioral metrics for each group.

- -Monthly transaction aggregation: 

WITH monthly_activity AS (
    SELECT
        DATE_TRUNC('month', "TransactionDate") AS activity_month,
        COUNT(DISTINCT "AccountID") AS active_customers,
        ROUND(SUM("AccountBalance")::numeric, 2) AS total_monthly_balance
    FROM "Customer_Data"
    GROUP BY 1
),
mom_comparison AS (
    SELECT
        activity_month,
        active_customers,
        LAG(active_customers, 1) OVER (ORDER BY activity_month) AS prev_month_customers
    FROM monthly_activity
)

SELECT
    activity_month,
    active_customers,
    prev_month_customers,
    ROUND(
        ((active_customers - prev_month_customers)::numeric / prev_month_customers) * 100,
        2
    ) AS mom_growth_rate_pct
FROM mom_comparison
ORDER BY activity_month DESC;

**Purpose**: Aggregates monthly customer activity and calculates month-over-month growth to identify seasonal trends and engagement changes.

--Volatitly and churn risk identification:

WITH balance_snapshots AS (
    SELECT
        "AccountID",
        "TransactionDate",
        "AccountBalance",
        LAG("AccountBalance") OVER (PARTITION BY "AccountID" ORDER BY "TransactionDate") AS previous_balance
    FROM "Customer_Data"
),
balance_drops AS (
    SELECT
        "AccountID",
        previous_balance - "AccountBalance" AS drop_amount
    FROM balance_snapshots
    WHERE (previous_balance - "AccountBalance") > 1000 -- Look for drops over $1000
)
SELECT 
    "AccountID",
    COUNT(drop_amount) AS frequent_large_drops_count,
    ROUND(AVG(drop_amount)::numeric, 2) as avg_drop_amount
FROM balance_drops
GROUP BY "AccountID"
HAVING COUNT(drop_amount) >= 3 -- Flag customers who experienced 3+ large drops recently
ORDER BY frequent_large_drops_count DESC;

**Purpose**:Identifies customers with repeated large balance drops as potential churn or financial risk candidates.

---
## Business Recommendations
- Implement targeted retention campaigns for customers showing declining activity and high volatility.
- Focus upselling strategies on VIP and stable Regular customers with high lifetime value.
- Monitor balance volatility as an early warning indicator of financial instability.
- Allocate marketing and branch resources toward high-activity geographic regions.
- Use customer health scores to prioritize customer relationship management efforts.

## Future Improvements
With additional time or data, this project could be enhanced by:
- Integrating predictive churn models
- Adding demographic attributes for deeper segmentation
- Automating data refresh using a live database connection
- Expanding the health score into a weighted scoring model
- Building the dashboard in Tableau or Power BI for interactive filtering
