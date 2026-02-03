Query 1:

WITH ranked_customers AS (
  SELECT 
   "AccountID",
   SUM("TransactionAmount") as "total_spent",
   PERCENT_RANK() OVER(ORDER BY SUM("TransactionAmount") DESC) as spend_percentile
   FROM "Customer_Data"
   GROUP BY "AccountID"
) -- Calculate the top percentage of customers
SELECT *
FROM "ranked_customers"
WHERE "spend_percentile" <= 0.10
ORDER BY total_spent DESC; 

Query 2: 

WITH "customer_base" AS (
    
    SELECT 
        "AccountID",
        SUM("TransactionAmount") as total_spent,
        COUNT("TransactionID") as total_orders,
        MAX("TransactionDate") as last_active,
        CASE 
            WHEN SUM("TransactionAmount") > 5000 THEN 'VIP'
            WHEN SUM("TransactionAmount") BETWEEN 1000 AND 5000 THEN 'Regular'
            ELSE 'Occasional'
        END as customer_segment --Classify the top customers based on transaction amount
    FROM "Customer_Data"
    GROUP BY "AccountID"
)

SELECT 
    customer_segment,
    COUNT("AccountID") as customer_count,
    ROUND(AVG(total_spent)::numeric, 2) as avg_lifetime_value,
    ROUND(AVG(total_orders)::numeric, 1) as avg_purchase_frequency,
    ROUND(AVG(CURRENT_DATE - last_active::date)::numeric, 0) as avg_days_since_last_purchase
FROM customer_base
GROUP BY customer_segment
ORDER BY avg_lifetime_value DESC;

Query 3: 

SELECT 
 TO_CHAR("TransactionDate", 'DAY') AS day_of_week,
 EXTRACT(HOUR FROM "TransactionDate") AS hour_of_day,
 COUNT("TransactionID") AS total_transactions,
 ROUND(SUM("TransactionAmount")::numeric, 2) AS total_revenue
FROM "Customer_Data"
GROUP BY 1,2 
ORDER BY total_revenue desc
LIMIT 10

Query 4: 

select
 DATE_TRUNC('month', "TransactionDate") AS spending_month,
 "AccountID",
 ROUND(AVG("TransactionAmount")::numeric, 2) AS avg_ticket_size,
 COUNT("TransactionID") AS total_orders,
 ROUND((STDDEV("TransactionAmount") / nullif(AVG("TransactionAmount"), 0))::numeric, 2) AS spending_cosistency
FROM "Customer_Data"
GROUP BY spending_month, "AccountID" 
HAVING COUNT("TransactionID") >= 2
ORDER BY spending_month DESC, avg_ticket_size DESC
