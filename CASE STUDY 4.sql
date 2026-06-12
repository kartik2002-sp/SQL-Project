-- =====================================================
-- SECTION A: CUSTOMER NODES EXPLORATION
-- =====================================================

-- A.1: How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;

-- A.2: What is the number of nodes per region?
SELECT 
    r.region_id,
    r.region_name,
    COUNT(DISTINCT cn.node_id) AS node_count
FROM regions r
LEFT JOIN customer_nodes cn ON r.region_id = cn.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;

-- A.3: How many customers are allocated to each region?
SELECT 
    r.region_id,
    r.region_name,
    COUNT(DISTINCT cn.customer_id) AS customer_count
FROM regions r
LEFT JOIN customer_nodes cn ON r.region_id = cn.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;

-- A.4: How many days on average are customers reallocated to a different node?
SELECT 
    AVG(reallocation_days) AS avg_reallocation_days
FROM (
    SELECT 
        customer_id,
        DATEDIFF(end_date, start_date) AS reallocation_days
    FROM customer_nodes
    WHERE end_date IS NOT NULL
) AS reallocation_data;

-- A.5: What is the median, 80th and 95th percentile for reallocation days metric for each region?
WITH pct_data AS (
    SELECT 
        cn.region_id,
        r.region_name,
        DATEDIFF(cn.end_date, cn.start_date) AS reallocation_days,
        ROW_NUMBER() OVER (PARTITION BY cn.region_id ORDER BY DATEDIFF(cn.end_date, cn.start_date)) AS row_num,
        COUNT(*) OVER (PARTITION BY cn.region_id) AS total_rows
    FROM customer_nodes cn
    JOIN regions r ON cn.region_id = r.region_id
    WHERE cn.end_date IS NOT NULL
)
SELECT 
    region_id,
    region_name,
    MIN(CASE WHEN row_num >= total_rows * 0.50 THEN reallocation_days END) AS median_days,
    MIN(CASE WHEN row_num >= total_rows * 0.80 THEN reallocation_days END) AS percentile_80_days,
    MIN(CASE WHEN row_num >= total_rows * 0.95 THEN reallocation_days END) AS percentile_95_days
FROM pct_data
GROUP BY region_id, region_name
ORDER BY region_id;


-- =====================================================
-- SECTION B: CUSTOMER TRANSACTIONS
-- =====================================================

-- B.1: What is the unique count and total amount for each transaction type?
SELECT 
    txn_type,
    COUNT(*) AS transaction_count,
    SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type
ORDER BY txn_type;

-- B.2: What is the average total historical deposit counts and amounts for all customers?
WITH customer_deposits AS (
    SELECT 
        customer_id,
        COUNT(*) AS deposit_count,
        SUM(txn_amount) AS total_deposit_amount
    FROM customer_transactions
    WHERE txn_type = 'deposit'
    GROUP BY customer_id
)
SELECT 
    ROUND(AVG(deposit_count), 2) AS avg_deposit_count,
    ROUND(AVG(total_deposit_amount), 2) AS avg_deposit_amount
FROM customer_deposits;

-- B.3: For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH monthly_transactions AS (
    SELECT 
        customer_id,
        DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
        SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
        SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
    FROM customer_transactions
    GROUP BY customer_id, DATE_FORMAT(txn_date, '%Y-%m')
)
SELECT 
    txn_month,
    COUNT(DISTINCT customer_id) AS customer_count
FROM monthly_transactions
WHERE deposit_count > 1
AND (purchase_count >= 1 OR withdrawal_count >= 1)
GROUP BY txn_month
ORDER BY txn_month;

-- B.4: What is the closing balance for each customer at the end of the month?
WITH monthly_balances AS (
    SELECT 
        customer_id,
        DATE_FORMAT(txn_date, '%Y-%m-01') AS month_start,
        LAST_DAY(txn_date) AS month_end,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
            ELSE 0 
        END) AS net_change
    FROM customer_transactions
    GROUP BY customer_id, DATE_FORMAT(txn_date, '%Y-%m-01'), LAST_DAY(txn_date)
)
SELECT 
    customer_id,
    month_end,
    SUM(net_change) OVER (PARTITION BY customer_id ORDER BY month_end) AS closing_balance
FROM monthly_balances
ORDER BY customer_id, month_end;

-- B.5: What is the percentage of customers who increase their closing balance by more than 5%?
WITH monthly_balances AS (
    SELECT 
        customer_id,
        DATE_FORMAT(txn_date, '%Y-%m-01') AS month_start,
        LAST_DAY(txn_date) AS month_end,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
            ELSE 0 
        END) AS net_change
    FROM customer_transactions
    GROUP BY customer_id, DATE_FORMAT(txn_date, '%Y-%m-01'), LAST_DAY(txn_date)
),
cumulative_balances AS (
    SELECT 
        customer_id,
        month_end,
        closing_balance,
        LAG(closing_balance) OVER (PARTITION BY customer_id ORDER BY month_end) AS prev_balance
    FROM (
        SELECT 
            customer_id,
            month_end,
            SUM(net_change) OVER (PARTITION BY customer_id ORDER BY month_end) AS closing_balance
        FROM monthly_balances
    ) inner_running
),
balance_growth AS (
    SELECT 
        customer_id,
        closing_balance,
        prev_balance,
        CASE 
            WHEN prev_balance > 0 AND closing_balance > prev_balance * 1.05 THEN 1
            ELSE 0 
        END AS increased_by_5_percent
    FROM cumulative_balances
    WHERE prev_balance IS NOT NULL
)
SELECT 
    ROUND(100.0 * SUM(increased_by_5_percent) / COUNT(DISTINCT customer_id), 2) AS percentage_increased
FROM balance_growth;


-- =====================================================
-- SECTION C: DATA ALLOCATION CHALLENGE
-- =====================================================

-- C. Step 1: Running customer balance with running sum
WITH transaction_sequence AS (
    SELECT 
        customer_id,
        txn_date,
        txn_type,
        txn_amount,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
            ELSE 0 
        END) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_balance
    FROM customer_transactions
)
SELECT 
    customer_id,
    txn_date,
    txn_type,
    txn_amount,
    running_balance
FROM transaction_sequence
ORDER BY customer_id, txn_date;

-- C. Step 2: Customer balance at end of each month
WITH monthly_net AS (
    SELECT
        customer_id,
        LAST_DAY(txn_date) AS month_end,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
            ELSE 0 
        END) AS net_change
    FROM customer_transactions
    GROUP BY customer_id, LAST_DAY(txn_date)
)
SELECT
    customer_id,
    month_end,
    SUM(net_change) OVER (PARTITION BY customer_id ORDER BY month_end) AS closing_balance
FROM monthly_net
ORDER BY customer_id, month_end;

-- C. Step 3: Min, Max, Average running balance for each customer
WITH transaction_sequence AS (
    SELECT 
        customer_id,
        txn_date,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
            ELSE 0 
        END) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_balance
    FROM customer_transactions
)
SELECT 
    customer_id,
    MIN(running_balance) AS min_running_balance,
    AVG(running_balance) AS avg_running_balance,
    MAX(running_balance) AS max_running_balance
FROM transaction_sequence
GROUP BY customer_id
ORDER BY customer_id;

-- Option 1: Data allocated based on end of previous month balance
WITH monthly_net AS (
    SELECT
        customer_id,
        DATE_FORMAT(txn_date, '%Y-%m-01') AS txn_month_start,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
            ELSE 0 
        END) AS net_change
    FROM customer_transactions
    GROUP BY customer_id, DATE_FORMAT(txn_date, '%Y-%m-01')
),
monthly_closing AS (
    SELECT
        customer_id,
        txn_month_start,
        SUM(net_change) OVER (PARTITION BY customer_id ORDER BY txn_month_start) AS monthly_closing_balance
    FROM monthly_net
)
SELECT
    DATE_FORMAT(txn_month_start + INTERVAL 1 MONTH, '%Y-%m') AS allocation_month,
    ROUND(SUM(CASE WHEN monthly_closing_balance > 0 THEN monthly_closing_balance ELSE 0 END) / 1000000, 3) AS total_data_required_mb
FROM monthly_closing
GROUP BY allocation_month
ORDER BY allocation_month;

-- Option 2: Data allocated on average amount in previous 30 days
WITH transaction_balances AS (
    SELECT
        customer_id,
        txn_date,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
            ELSE 0 
        END) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_balance
    FROM customer_transactions
),
rolling_30_day AS (
    SELECT
        customer_id,
        txn_date,
        AVG(running_balance) OVER (PARTITION BY customer_id ORDER BY txn_date RANGE BETWEEN INTERVAL 30 DAY PRECEDING AND CURRENT ROW) AS avg_30_day_balance
    FROM transaction_balances
)
SELECT 
    DATE_FORMAT(txn_date + INTERVAL 1 MONTH, '%Y-%m') AS allocation_month,
    ROUND(SUM(CASE WHEN avg_30_day_balance > 0 THEN avg_30_day_balance ELSE 0 END) / 1000000, 3) AS total_data_required_mb
FROM rolling_30_day
GROUP BY allocation_month
ORDER BY allocation_month;