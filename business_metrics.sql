Query 1: 

select
 "Location",
 COUNT(DISTINCT "AccountID") AS total_customers,
 ROUND(AVG("AccountBalance")::numeric, 2) AS avg_balance,
 COUNT("TransactionID") AS total_transactions,
 ROUND((COUNT("TransactionID")::numeric / COUNT(DISTINCT "AccountID")::numeric), 2) AS avg_txn_per_customer
FROM "Customer_Data"
group by "Location"
ORDER by avg_txn_per_customer desc

Query 2: 

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
        -- Get the previous month's customer count
        LAG(active_customers, 1) OVER (ORDER BY activity_month) AS prev_month_customers
    FROM monthly_activity
)
SELECT
    activity_month,
    active_customers,
    prev_month_customers,
    -- Calculate the percentage change (MoM Growth Rate)
    ROUND(((active_customers - prev_month_customers)::numeric / prev_month_customers) * 100, 2) AS mom_growth_rate_pct
FROM mom_comparison
ORDER BY activity_month DESC;

Query 3: 

  select
 EXTRACT(YEAR FROM "TransactionDate") AS transaction_year,
 EXTRACT(QUARTER FROM "TransactionDate") AS transaction_quarter,
 COUNT("TransactionID") AS total_transactions,
 ROUND((COUNT("TransactionID")::numeric / COUNT(DISTINCT "AccountID")::numeric), 2) AS avg_txn_per_quarter
 FROM "Customer_Data"
 GROUP BY transaction_year, transaction_quarter 
 ORDER BY transaction_year DESC, transaction_quarter desc

Query 4:
WITH max_date_ref AS (
  
  SELECT MAX("TransactionDate") as latest_file_date FROM "Customer_Data"
),
customer_lifetime AS (
  select
   "AccountID",
   MAX("TransactionDate") as last_active_date,
   COUNT("TransactionID") as lifetime_transactions,
   AVG("AccountBalance") as avg_lifetime_balance
  FROM "Customer_Data"
  GROUP BY "AccountID" 
),
current_status AS (
  -- Gets the most recent balance for each account
  SELECT DISTINCT ON ("AccountID") 
    "AccountID", 
    "AccountBalance" as current_balance
  FROM "Customer_Data"
  ORDER BY "AccountID", "TransactionDate" DESC
)
SELECT 
 l."AccountID",
 l.lifetime_transactions,
 ROUND(l.avg_lifetime_balance::numeric, 2) as avg_lifetime_balance,
 ROUND(s.current_balance::numeric, 2) as current_balance,
 -- Calculates days relative to the end of the dataset, not today's date
 (m.latest_file_date::date - l.last_active_date::date) AS days_since_last_activity
FROM customer_lifetime l
JOIN current_status s ON l."AccountID" = s."AccountID"
CROSS JOIN max_date_ref m -- Brings the latest_file_date into every row for calculation
WHERE l.lifetime_transactions > 5 
  AND (m.latest_file_date::date - l.last_active_date::date) > 60
ORDER BY days_since_last_activity DESC, l.avg_lifetime_balance DESC;

Query 5: 

select
 "CustomerOccupation",
 "TransactionAmount"
From(
   Select 
   "CustomerOccupation",
   "TransactionAmount",
   PERCENT_RANK() OVER (ORDER by "TransactionAmount" ASC) as pct_rank
  FROM "Customer_Data"
) AS ranked_data
WHERE pct_rank >= 0.90; 
