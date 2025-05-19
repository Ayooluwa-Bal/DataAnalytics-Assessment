-- QUESTION 2 --

SELECT 
    -- assigning each user a frequency category based on their average number of monthly transactions
    CASE
        WHEN AvgMT.AverageTransaction >= 10 THEN 'High Frequency'
        WHEN AvgMT.AverageTransaction >= 3 AND AvgMT.AverageTransaction <= 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
	COUNT(*) AS customer_count, -- Count of users in each frequency category
    ROUND(AVG(AvgMT.AverageTransaction), 2) AS avg_transactions_per_month -- Average number of monthly transactions within each frequency category
FROM (
    -- Subquery: Calculate average monthly transaction count for each user
    SELECT 
        UMT.id,
        ROUND(AVG(UMT.Number_Of_Transactions), 2) AS AverageTransaction
    FROM (
        -- Sub-subquery: Count number of transactions per user per month
        SELECT 
            U.id,
            DATE_FORMAT(S.transaction_date, '%Y-%m') AS YearMonth,
            COUNT(*) AS Number_Of_Transactions
        FROM 
            savings_savingsaccount S
        LEFT JOIN 
            users_customuser U ON S.owner_id = U.id
        WHERE 
            transaction_status IN ('success', 'successful')  -- Only include successful transactions
        GROUP BY 
            U.id, DATE_FORMAT(S.transaction_date, '%Y-%m')   -- Group by user and month
        ORDER BY 
            U.id, DATE_FORMAT(S.transaction_date, '%Y-%m')
    ) UMT
    GROUP BY 
        UMT.id   -- Group by user to calculate their average monthly transactions
) AvgMT
GROUP BY 
    frequency_category;
