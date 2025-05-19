-- Question 3 ---

SELECT
  plan_id,
  owner_id,
  CASE 
    WHEN merged.is_regular_savings = 1 THEN 'savings' 
    WHEN merged.is_a_fund = 1 THEN 'investment'
    ELSE 'none'
  END AS 'type', -- Label the account as 'savings' or 'investment' based on its type
  merged.last_transaction_date, -- the latest transaction date (if any)
  DATEDIFF(CURDATE(), COALESCE(merged.last_transaction_date, merged.start_date)) AS inactivity_days -- Days since last transaction or start_date (whichever is later)
FROM (
  -- Merge relevant plan data with transaction data
  SELECT
    PL.plan_id,
    PL.owner_id,
    PL.is_regular_savings,
    PL.is_a_fund,
    PL.start_date,
    inflow.last_transaction_date
  FROM (
    -- Select only active, undeleted plans that are either savings or investment
    SELECT 
      id AS plan_id, 
      owner_id, 
      is_regular_savings, 
      is_a_fund,
      start_date
    FROM plans_plan
    WHERE is_regular_savings = 1 OR is_a_fund = 1
      ) AS PL
  -- Join with most recent successful inflow transaction per plan
  LEFT JOIN (
    SELECT 
      plan_id, 
      MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0  -- filtering for only real deposits
      AND transaction_status IN ('success', 'successful') 
    GROUP BY plan_id
			) AS inflow ON inflow.plan_id = PL.plan_id
    ) AS merged
WHERE DATEDIFF(CURDATE(), COALESCE(merged.last_transaction_date, merged.start_date)) > 365 -- filtering for accounts with no transactions in the last 1 year (365 days)
-- One row per plan
GROUP BY plan_id, owner_id;

