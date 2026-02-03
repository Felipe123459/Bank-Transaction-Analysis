Query 1: 

WITH purchase_gaps AS (
  select
   "AccountID",
   "TransactionDate",
   LAG("TransactionDate") OVER (PARTITION BY "AccountID" ORDER BY "TransactionDate") as prev_transaction
  FROM "Customer_Data"
),
gap_analysis AS (
  SELECT 
  "AccountID",
  AVG("TransactionDate"::date - prev_transaction::date) as avg_gap,
  MAX("TransactionDate"::date - prev_transaction::date) as latest_gap
  FROM purchase_gaps
  WHERE prev_transaction IS NOT null
  GROUP BY "AccountID"
)
SELECT *
FROM gap_analysis
WHERE latest_gap > (avg_gap * 1.5)
ORDER BY latest_gap DESC

Query 2: 

WITH daily_balances AS (
 select
   "AccountID",
   AVG("AccountBalance") AS avg_daily_balance 
FROM "Customer_Data" 
GROUP BY "AccountID"
)
select
 "AccountID",
 ROUND(avg_daily_balance::numeric, 2) AS average_balance
 FROM daily_balances
 WHERE avg_daily_balance < 2000
 ORDER BY average_balance ASC

Query 3: 

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

Query 4: 

WITH max_date_ref AS (
  -- This replaces "Today" with the most recent date in your CSV
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
