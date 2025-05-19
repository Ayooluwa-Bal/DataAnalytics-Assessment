# DataAnalytics-Assessment

### Question 1: High-Value Customers with Multiple Products

**Scenario**  
The business wants  to identify customers who have at least one funded savings plan AND one funded investment plan products—prime cross-sell opportunities.

**Task**  
List customers who have at least one **funded savings plan** and one **funded investment plan**, ordered by their **total confirmed deposits**.

**Identification of Relevant Tables**  
- `users_customuser`  aliased U  has customer IDs and names.
- `plans_plan`  aliased PL show us the allocation of plans to clients with each plan flagged as savings is `is_regular_savings = 1` or investment is `is_a_fund = 1`.
- `savings_savingsaccount` aliased S  summarizes every deposit made on an account, but we filter on confirmed amount greater than zero and transaction status in ( “success”, “successful” ) to only count positive cash inflows.

**Approach**  
1. Join users to their plans and then to deposits.  
2. Use `COUNT(DISTINCT IF(...))` to count each savings or investment plan only if it has a confirmed deposit.  
3. Calculate for Total Deposits using SUM(...) to sum all deposits (divided by 100, since the amounts are in kobo) for each customer and ROUNDing it to 2 sig. figures to make it more readable.  
4. After grouping by user, we use the HAVING clause to keep only those rows where:
- savings_count is greater than 0  AND investment_count is greater than 0, to ensure each returned customer has at least one of each plan type and then we sort by total deposits in DESCending order so the highest-value cross-sell opportunities float to the top of the result.


### Question 2: Transaction Frequency Analysis
**Scenario**
The finance team wants to segment customers by how often they transact.

**Task**
Compute each customer’s average transactions per month and bucket them into:

- High Frequency (≥10 months)

- Medium Frequency (3–9 months)

- Low Frequency (≤2 months)

**Identification of Relevant Tables**

- `users_customuser`

- `savings_savingsaccount`

**Approach**

1. Count each user’s transactions per month.

2. Average those monthly counts per user.

3. Use a CASE to assign frequency categories.

4. Count customers per category and compute their average transaction rate.


### Question 3: Account Inactivity Alert
**Scenario**
The ops team needs to flag accounts with no inflow for over a year.

**Task**
Find active savings or investment plans that haven’t had a successful deposit in the last 365 days (1 year).

**Identification of Relevant Tables & Filters**

- `plans_plan`

- `savings_savingsaccount`

**Approach**`

1. Selection of active plans (is_regular_savings=1 OR is_a_fund=1).

2. Finding each plan’s last successful deposit date.

3. Use COALESCE to fall back to start_date if never deposited i.e., no transaction_date.

4. Filter to those with inactivity > 365 days.


### Question 4: Customer Lifetime Value (CLV) Estimation
**Scenario**
Marketing wants a simple CLV model that is based on tenure and transaction volume.

**Task**
Information to obtain for each customer:

- Tenure in months since signup

- Total successful transactions

- Average profit per transaction (0.1% of value)

- CLV = (transactions/tenure) × 12 × avg_profit

- Sort by CLV descending.

**Identification of Relevant Tables**

- `users_customuser`

- `savings_savingsaccount`

**Approach**

1. Calculate tenure with TIMESTAMPDIFF.

2. Count & average transaction values.

3. Apply the CLV formula and order the results.


# CHALLENGES

1. Lack of a data dictionary to help define certain colums that has very similar (if not same data types) made determining some criteria difficult; e.g, active and inactive account.
   > I overcame this by using the is_deleted column as a determiner of whether the account is active or not
2. The transaction_status column had values that were entered in a consistent and unified manner. e.g success, successful, monnify_successful 3 values that probably describe the same thing.
   > I used only the first 2 - success and successful to filter for actual transactions as their meaning is common knowledge.
