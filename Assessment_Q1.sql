-- QUESTION 1 --
  
SELECT 
    U.id AS owner_id,
    CONCAT(U.first_name, ' ', U.last_name) AS name,
    COUNT(DISTINCT IF(
        PL.is_regular_savings = 1 
        AND S.confirmed_amount > 0, 
        PL.id, 
        NULL)
        ) AS savings_count,
    COUNT(DISTINCT IF(
        PL.is_a_fund = 1 
        AND S.confirmed_amount > 0, 
        PL.id, 
        NULL)
        ) AS investment_count,
    -- Total confirmed deposits across all plans, converted to standard currency (divided by 100)
    ROUND(SUM(S.confirmed_amount) / 100, 2) AS total_deposits
FROM 
    users_customuser U
-- Join users table with the plans owned by the user
JOIN 
    plans_plan PL 
    ON PL.owner_id = U.id
-- Left join with savings accounts linked to each plan
LEFT JOIN 
    savings_savingsaccount S 
    ON S.plan_id = PL.id
-- Group by user to aggregate savings/investment data per user
GROUP BY 
    U.id, U.first_name, U.last_name
-- Filter result to only include users who have both savings and investment plans
HAVING 
    savings_count > 0
    AND investment_count > 0
-- Order the result by total confirmed deposit amount with the highest being at the top
ORDER BY 
    total_deposits DESC;
 
