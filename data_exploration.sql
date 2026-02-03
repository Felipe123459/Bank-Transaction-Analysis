Query 1:
  
SElECT 
COUNT(*) AS total_rows,
MIN("TransactionDate") AS earliest_date,
MAX("TransactionDate") AS latest_date
FROM "Customer_Data";

Query 2:
select
"TransactionType",
COUNT(*) AS "type_count"
FROM "Customer_Data"
GROUP BY "TransactionType"
ORDER BY "type_count" DESC;

Query 3:

select
 COUNT(*)-COUNT("TransactionID") AS "missing_ids",
 COUNT(*)-COUNT("AccountID") AS "missing_amounts"
from "Customer_Data"

Query 4:

select
 AVG("TransactionAmount") AS "average_amount",
 MIN("TransactionAmount") AS "minimum_amount",
 MAX("TransactionAmount") AS "maximum_amount",
 STDDEV("TransactionAmount") AS "standard_deviation",
 SUM("TransactionAmount") AS "total_sum"
FROM "Customer_Data"--Basic statistics

Query 5: 

SELECT 
"AccountID",
 SUM("TransactionAmount") AS "total_amount",
 MAX("TransactionDate") AS "last_date",
 Count("TransactionID") AS "frequency",
 (current_date - MAX("TransactionDate")::date) as recency_days
FROM "Customer_Data"
group By "AccountID" --Shows the declining activity



