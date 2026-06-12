-- =====================================================================================
-- Foodie-Fi SQL Case Study Solutions
-- =====================================================================================

SELECT 
    COUNT(DISTINCT customer_id) AS churn_count,
    ROUND(100.0 * COUNT(DISTINCT customer_id) / (SELECT 
                    COUNT(DISTINCT customer_id)
                FROM
                    foodie_fi.subscriptions),
            1) AS churn_percentage
FROM
    foodie_fi.subscriptions
WHERE
    plan_id = 4;


-- -------------------------------------------------------------------------------------
-- 2. How many customers have churned straight after their initial free trial - 
--    what percentage is this rounded to the nearest whole number?
-- -------------------------------------------------------------------------------------
WITH ranked_plans AS (
  SELECT 
    customer_id, 
    plan_id, 
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_date) AS plan_rank
  FROM foodie_fi.subscriptions
)
SELECT 
  COUNT(*) AS churn_after_trial_count,
  ROUND(
    100.0 * COUNT(*) / (
      SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions
    ), 0
  ) AS churn_percentage
FROM ranked_plans
WHERE plan_id = 4 AND plan_rank = 2;


-- -------------------------------------------------------------------------------------
-- 3. What is the number and percentage of customer plans after their initial free trial?
-- -------------------------------------------------------------------------------------
WITH ranked_plans AS (
  SELECT 
    customer_id, 
    plan_id, 
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_date) AS plan_rank
  FROM foodie_fi.subscriptions
)
SELECT 
  p.plan_name,
  COUNT(r.customer_id) AS customer_count,
  ROUND(
    100.0 * COUNT(r.customer_id) / (
      SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions
    ), 1
  ) AS percentage
FROM ranked_plans r
JOIN foodie_fi.plans p 
  ON r.plan_id = p.plan_id
WHERE r.plan_rank = 2
GROUP BY p.plan_name
ORDER BY customer_count DESC;


-- -------------------------------------------------------------------------------------
-- 4. What is the customer count and percentage breakdown of all 5 plan_name values 
--    at 2020-12-31?
-- -------------------------------------------------------------------------------------
WITH active_plans_at_yearend AS (
  SELECT 
    customer_id, 
    plan_id, 
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_date DESC) AS latest_plan
  FROM foodie_fi.subscriptions
  WHERE start_date <= '2020-12-31'
)
SELECT 
  p.plan_name,
  COUNT(a.customer_id) AS customer_count,
  ROUND(
    100.0 * COUNT(a.customer_id) / (
      SELECT COUNT(DISTINCT customer_id) 
      FROM active_plans_at_yearend 
      WHERE latest_plan = 1
    ), 1
  ) AS percentage
FROM active_plans_at_yearend a
JOIN foodie_fi.plans p 
  ON a.plan_id = p.plan_id
WHERE a.latest_plan = 1
GROUP BY p.plan_name, p.plan_id
ORDER BY p.plan_id;


-- -------------------------------------------------------------------------------------
-- 5. How many customers have upgraded to an annual plan in 2020?
-- -------------------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT customer_id) AS annual_upgrades_2020
FROM
    foodie_fi.subscriptions
WHERE
    plan_id = 3
        AND EXTRACT(YEAR FROM start_date) = 2020;


-- -------------------------------------------------------------------------------------
-- 6. How many days on average does it take for a customer to upgrade to an annual plan 
--    from the day they join Foodie-Fi?
-- -------------------------------------------------------------------------------------
WITH trial_dates AS (
  SELECT customer_id, start_date AS trial_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
),
annual_dates AS (
  SELECT customer_id, start_date AS annual_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
)
SELECT 
  ROUND(AVG(a.annual_date - t.trial_date), 0) AS avg_days_to_upgrade
FROM trial_dates t
JOIN annual_dates a 
  ON t.customer_id = a.customer_id;


-- -------------------------------------------------------------------------------------
-- 7. Can you further breakdown this average value into 30 day periods 
--    (i.e. 0-30 days, 31-60 days etc)?
-- -------------------------------------------------------------------------------------
WITH trial_dates AS (
  SELECT customer_id, start_date AS trial_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
),
annual_dates AS (
  SELECT customer_id, start_date AS annual_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
),
day_diffs AS (
  SELECT 
    t.customer_id, 
    (a.annual_date - t.trial_date) AS days_to_upgrade
  FROM trial_dates t
  JOIN annual_dates a 
    ON t.customer_id = a.customer_id
)
SELECT 
  FLOOR(days_to_upgrade / 30) * 30 || ' - ' || (FLOOR(days_to_upgrade / 30) * 30 + 30) || ' days' AS period,
  COUNT(customer_id) AS customer_count
FROM day_diffs
GROUP BY FLOOR(days_to_upgrade / 30)
ORDER BY FLOOR(days_to_upgrade / 30);


-- -------------------------------------------------------------------------------------
-- 8. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
-- -------------------------------------------------------------------------------------
WITH preceding_plans AS (
  SELECT 
    customer_id, 
    plan_id, 
    start_date,
    LAG(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS previous_plan
  FROM foodie_fi.subscriptions
  WHERE EXTRACT(YEAR FROM start_date) = 2020
)
SELECT 
  COUNT(DISTINCT customer_id) AS downgrade_count
FROM preceding_plans
WHERE plan_id = 1 AND previous_plan = 2;


-- -------------------------------------------------------------------------------------
-- 9. Create a new payments table for the year 2020 that includes amounts paid by each 
--    customer in the subscriptions table with specific requirements.
-- -------------------------------------------------------------------------------------
CREATE TABLE foodie_fi.payments_2020 AS
WITH RECURSIVE payment_series AS (
  -- Base Query: Initial payments for all non-trial and non-churn plans in 2020
  SELECT 
    s.customer_id, 
    s.plan_id, 
    p.plan_name, 
    s.start_date AS payment_date, 
    s.start_date AS plan_start_date,
    LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) AS next_plan_date,
    p.price AS amount
  FROM foodie_fi.subscriptions s
  JOIN foodie_fi.plans p 
    ON s.plan_id = p.plan_id
  WHERE p.plan_name NOT IN ('trial', 'churn')
    AND YEAR(s.start_date) = 2020

  UNION ALL

  -- Recursive Query: Generating subsequent monthly payments using MySQL syntax
  SELECT 
    ps.customer_id, 
    ps.plan_id, 
    ps.plan_name, 
    CAST(ps.payment_date + INTERVAL 1 MONTH AS DATE) AS payment_date, 
    ps.plan_start_date,
    ps.next_plan_date,
    ps.amount
  FROM payment_series ps
  WHERE ps.plan_name LIKE '%monthly%' 
    AND (
      -- Case A: If there is a next plan, payment must happen BEFORE the upgrade date
      (ps.next_plan_date IS NOT NULL AND CAST(ps.payment_date + INTERVAL 1 MONTH AS DATE) < ps.next_plan_date)
      OR 
      -- Case B: If no next plan, payments can continue UP TO AND INCLUDING Dec 31
      (ps.next_plan_date IS NULL AND CAST(ps.payment_date + INTERVAL 1 MONTH AS DATE) <= '2020-12-31')
    )
)
-- Resolving the transition discount
, final_payments AS (
  SELECT 
    customer_id, 
    plan_id, 
    plan_name, 
    payment_date, 
    CASE 
      WHEN LAG(plan_id) OVER(PARTITION BY customer_id ORDER BY payment_date) = 1 AND plan_id IN (2, 3) 
      THEN amount - (SELECT price FROM foodie_fi.plans WHERE plan_id = 1)
      ELSE amount 
    END AS amount
  FROM payment_series
)
SELECT 
  customer_id, 
  plan_id, 
  plan_name, 
  payment_date, 
  amount, 
  ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM final_payments
ORDER BY customer_id, payment_date;