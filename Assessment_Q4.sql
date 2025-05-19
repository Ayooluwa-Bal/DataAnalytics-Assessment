-- QUESTION 4 --

SELECT 
    CusHistory.id AS customer_id,
    CusHistory.name,
    CusHistory.tenure_months,
    CusHistory.total_transactions,
    (CusHistory.total_transactions / CusHistory.tenure_months) * 12 * avg_profit_per_transaction AS estimated_clv -- calculating the CLV - Customer Lifetime Value
FROM (
    -- Subquery: Gather user profile, tenure, transaction count and average profit per transaction
    SELECT 
        U.id,
        CONCAT(U.first_name, ' ', U.last_name) AS name,
        U.date_joined,
        TIMESTAMPDIFF(MONTH, U.date_joined, CURDATE()) AS tenure_months, -- tenure is calculated from today, i.e., Number of months since the user joined
        COUNT(*) AS total_transactions,-- Total number of successful transactions
        ROUND(AVG(S.confirmed_amount) / 0.001, 2) AS avg_profit_per_transaction -- Estimated profit: assuming the profit_per_transaction is 0.1% of the transaction value
    FROM 
        users_customuser U
        INNER JOIN savings_savingsaccount S ON U.id = S.owner_id
    WHERE 
        S.transaction_status IN ('success', 'successful') -- Filter only successful transactions
    GROUP BY U.id
    ) CusHistory
ORDER BY 
    estimated_clv DESC;
