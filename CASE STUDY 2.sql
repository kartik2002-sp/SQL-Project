USE pizza_runner;

/*
 * =============================================================================
 * INITIAL SCHEMA & DATA SETUP
 * =============================================================================
 */
 -- 1. Create and use the schema


-- 2. Create tables and insert data (Removed double quotes)
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time DATETIME
);

INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, 'null', '1', '2020-01-08 21:00:29'),
  (6, 101, 2, 'null', 'null', '2020-01-08 21:03:13'),
  (7, 105, 2, 'null', '1', '2020-01-08 21:20:29'),
  (8, 102, 1, 'null', 'null', '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, 'null', 'null', '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, 'null', 'null', 'null', 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  (9, 2, 'null', 'null', 'null', 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name VARCHAR(50)
);

INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings VARCHAR(50)
);

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name VARCHAR(50)
);

INSERT INTO pizza_toppings (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
/*
 * =============================================================================
 * SECTION A: INGREDIENT OPTIMISATION
 * =============================================================================
 */

/*
 * Find standard ingredients for each pizza type.
 *
 * - Uses a recursive number generator to split strings.
 * - Maps the IDs to the toppings table.
 * - Groups and joins names using GROUP_CONCAT.
 */
WITH RECURSIVE numbers AS (
  SELECT 1 AS n UNION ALL SELECT n + 1 FROM numbers WHERE n < 15
),
SplitToppings AS (
  SELECT 
    pizza_id,
    CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', n), ',', -1)) AS UNSIGNED) AS topping_id
  FROM pizza_runner.pizza_recipes
  JOIN numbers ON CHAR_LENGTH(toppings) - CHAR_LENGTH(REPLACE(toppings, ',', '')) >= n - 1
)
SELECT 
  pn.pizza_name, 
  GROUP_CONCAT(pt.topping_name ORDER BY pt.topping_name ASC SEPARATOR ', ') AS standard_ingredients
FROM SplitToppings st
JOIN pizza_runner.pizza_names pn ON st.pizza_id = pn.pizza_id
JOIN pizza_runner.pizza_toppings pt ON st.topping_id = pt.topping_id
GROUP BY pn.pizza_name;


/*
 * Identify the most frequently added extra topping.
 *
 * - Cleans null and empty values from extras.
 * - Splits the extras into individual topping IDs.
 * - Counts occurrences and retrieves the top result.
 */
WITH RECURSIVE numbers AS (
  SELECT 1 AS n UNION ALL SELECT n + 1 FROM numbers WHERE n < 10
),
CleanExtras AS (
    SELECT CASE WHEN extras IN ('null', '') THEN NULL ELSE extras END AS extras
    FROM pizza_runner.customer_orders
)
SELECT pt.topping_name, COUNT(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ce.extras, ',', n.n), ',', -1))) AS times_added
FROM CleanExtras ce
JOIN numbers n ON CHAR_LENGTH(ce.extras) - CHAR_LENGTH(REPLACE(ce.extras, ',', '')) >= n.n - 1
JOIN pizza_runner.pizza_toppings pt ON CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ce.extras, ',', n.n), ',', -1)) AS UNSIGNED) = pt.topping_id
WHERE ce.extras IS NOT NULL
GROUP BY pt.topping_name
ORDER BY times_added DESC
LIMIT 1;


/*
 * Find the most commonly excluded pizza topping.
 *
 * - Cleans up the exclusions column data.
 * - Splits exclusions string into separate rows.
 * - Counts exclusions and selects the highest one.
 */
WITH RECURSIVE numbers AS (
  SELECT 1 AS n UNION ALL SELECT n + 1 FROM numbers WHERE n < 10
),
CleanExclusions AS (
    SELECT CASE WHEN exclusions IN ('null', '') THEN NULL ELSE exclusions END AS exclusions
    FROM pizza_runner.customer_orders
)
SELECT pt.topping_name, COUNT(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ce.exclusions, ',', n.n), ',', -1))) AS times_excluded
FROM CleanExclusions ce
JOIN numbers n ON CHAR_LENGTH(ce.exclusions) - CHAR_LENGTH(REPLACE(ce.exclusions, ',', '')) >= n.n - 1
JOIN pizza_runner.pizza_toppings pt ON CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ce.exclusions, ',', n.n), ',', -1)) AS UNSIGNED) = pt.topping_id
WHERE ce.exclusions IS NOT NULL
GROUP BY pt.topping_name
ORDER BY times_excluded DESC
LIMIT 1;


/*
 * Generate text descriptions for each customer order.
 *
 * - Creates a unique row ID per pizza.
 * - Extracts and translates exclusions and extras.
 * - Concatenates names into a final readable string.
 */
WITH RECURSIVE numbers AS (
  SELECT 1 AS n UNION ALL SELECT n + 1 FROM numbers WHERE n < 10
),
BaseOrders AS (
    SELECT 
        order_id, customer_id, pizza_id,
        ROW_NUMBER() OVER (ORDER BY order_id, pizza_id) AS row_id,
        CASE WHEN exclusions IN ('null', '') THEN NULL ELSE exclusions END AS exc,
        CASE WHEN extras IN ('null', '') THEN NULL ELSE extras END AS ext
    FROM pizza_runner.customer_orders
),
ExclusionsText AS (
    SELECT bo.row_id, GROUP_CONCAT(pt.topping_name SEPARATOR ', ') AS exc_names
    FROM BaseOrders bo
    JOIN numbers n ON CHAR_LENGTH(bo.exc) - CHAR_LENGTH(REPLACE(bo.exc, ',', '')) >= n.n - 1
    JOIN pizza_runner.pizza_toppings pt ON CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(bo.exc, ',', n.n), ',', -1)) AS UNSIGNED) = pt.topping_id
    WHERE bo.exc IS NOT NULL
    GROUP BY bo.row_id
),
ExtrasText AS (
    SELECT bo.row_id, GROUP_CONCAT(pt.topping_name SEPARATOR ', ') AS ext_names
    FROM BaseOrders bo
    JOIN numbers n ON CHAR_LENGTH(bo.ext) - CHAR_LENGTH(REPLACE(bo.ext, ',', '')) >= n.n - 1
    JOIN pizza_runner.pizza_toppings pt ON CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(bo.ext, ',', n.n), ',', -1)) AS UNSIGNED) = pt.topping_id
    WHERE bo.ext IS NOT NULL
    GROUP BY bo.row_id
)
SELECT 
    bo.order_id,
    CONCAT_WS(' - ', 
        pn.pizza_name, 
        IF(et.exc_names IS NOT NULL, CONCAT('Exclude ', et.exc_names), NULL),
        IF(xt.ext_names IS NOT NULL, CONCAT('Extra ', xt.ext_names), NULL)
    ) AS order_item
FROM BaseOrders bo
JOIN pizza_runner.pizza_names pn ON bo.pizza_id = pn.pizza_id
LEFT JOIN ExclusionsText et ON bo.row_id = et.row_id
LEFT JOIN ExtrasText xt ON bo.row_id = xt.row_id;


/*
 * Create ordered ingredient lists for each order.
 *
 * - Gathers all base ingredients for ordered pizzas.
 * - Filters out any excluded ingredients mathematically.
 * - Adds any extra ingredients to the pool.
 * - Aggregates the final list alphabetically with quantities.
 */
WITH RECURSIVE numbers AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM numbers WHERE n < 15
),
BaseOrders AS (
    SELECT 
        order_id, pizza_id, 
        ROW_NUMBER() OVER (ORDER BY order_id) AS row_id,
        CASE WHEN exclusions IN ('null', '') THEN NULL ELSE exclusions END AS exc,
        CASE WHEN extras IN ('null', '') THEN NULL ELSE extras END AS ext
    FROM pizza_runner.customer_orders
),
IngredientPool AS (
    SELECT 
        bo.row_id, bo.order_id, pn.pizza_name, 
        CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pr.toppings, ',', n.n), ',', -1)) AS UNSIGNED) AS t_id
    FROM BaseOrders bo
    JOIN pizza_runner.pizza_recipes pr ON bo.pizza_id = pr.pizza_id
    JOIN pizza_runner.pizza_names pn ON bo.pizza_id = pn.pizza_id
    JOIN numbers n ON CHAR_LENGTH(pr.toppings) - CHAR_LENGTH(REPLACE(pr.toppings, ',', '')) >= n.n - 1
),
ExcludedList AS (
    SELECT bo.row_id, CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(bo.exc, ',', n.n), ',', -1)) AS UNSIGNED) AS t_id
    FROM BaseOrders bo
    JOIN numbers n ON CHAR_LENGTH(bo.exc) - CHAR_LENGTH(REPLACE(bo.exc, ',', '')) >= n.n - 1
    WHERE bo.exc IS NOT NULL
),
ExtrasList AS (
    SELECT bo.row_id, CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(bo.ext, ',', n.n), ',', -1)) AS UNSIGNED) AS t_id, bo.order_id, pn.pizza_name
    FROM BaseOrders bo
    JOIN pizza_runner.pizza_names pn ON bo.pizza_id = pn.pizza_id
    JOIN numbers n ON CHAR_LENGTH(bo.ext) - CHAR_LENGTH(REPLACE(bo.ext, ',', '')) >= n.n - 1
    WHERE bo.ext IS NOT NULL
),
FinalIngredients AS (
    SELECT ip.row_id, ip.order_id, ip.pizza_name, ip.t_id 
    FROM IngredientPool ip
    LEFT JOIN ExcludedList e ON ip.row_id = e.row_id AND ip.t_id = e.t_id
    WHERE e.t_id IS NULL
    UNION ALL
    SELECT row_id, order_id, pizza_name, t_id FROM ExtrasList
)
SELECT 
    fi.order_id,
    CONCAT(fi.pizza_name, ': ', GROUP_CONCAT(
        CASE WHEN fi.cnt > 1 THEN CONCAT(fi.cnt, 'x', pt.topping_name) ELSE pt.topping_name END 
        ORDER BY pt.topping_name ASC SEPARATOR ', '
    )) AS ingredient_list
FROM (
    SELECT row_id, order_id, pizza_name, t_id, COUNT(*) as cnt
    FROM FinalIngredients 
    GROUP BY row_id, order_id, pizza_name, t_id
) fi
JOIN pizza_runner.pizza_toppings pt ON fi.t_id = pt.topping_id
GROUP BY fi.row_id, fi.order_id, fi.pizza_name;


/*
 * Count total used ingredients for delivered pizzas.
 *
 * - Excludes cancelled orders from the final count.
 * - Combines base recipes minus exclusions plus extras.
 * - Sums up the overall usage of each ingredient.
 */
WITH RECURSIVE numbers AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM numbers WHERE n < 15
),
ValidOrders AS (
    SELECT 
        co.order_id, co.pizza_id, 
        ROW_NUMBER() OVER (ORDER BY co.order_id) AS row_id,
        CASE WHEN co.exclusions IN ('null', '') THEN NULL ELSE co.exclusions END AS exc,
        CASE WHEN co.extras IN ('null', '') THEN NULL ELSE co.extras END AS ext
    FROM pizza_runner.customer_orders co
    JOIN pizza_runner.runner_orders ro ON co.order_id = ro.order_id
    WHERE ro.cancellation IS NULL OR ro.cancellation IN ('null', '')
),
IngredientPool AS (
    SELECT vo.row_id, CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pr.toppings, ',', n.n), ',', -1)) AS UNSIGNED) AS t_id
    FROM ValidOrders vo
    JOIN pizza_runner.pizza_recipes pr ON vo.pizza_id = pr.pizza_id
    JOIN numbers n ON CHAR_LENGTH(pr.toppings) - CHAR_LENGTH(REPLACE(pr.toppings, ',', '')) >= n.n - 1
),
Excluded AS (
    SELECT vo.row_id, CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(vo.exc, ',', n.n), ',', -1)) AS UNSIGNED) AS t_id
    FROM ValidOrders vo 
    JOIN numbers n ON CHAR_LENGTH(vo.exc) - CHAR_LENGTH(REPLACE(vo.exc, ',', '')) >= n.n - 1
    WHERE vo.exc IS NOT NULL
),
Extras AS (
    SELECT vo.row_id, CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(vo.ext, ',', n.n), ',', -1)) AS UNSIGNED) AS t_id
    FROM ValidOrders vo 
    JOIN numbers n ON CHAR_LENGTH(vo.ext) - CHAR_LENGTH(REPLACE(vo.ext, ',', '')) >= n.n - 1
    WHERE vo.ext IS NOT NULL
),
DeliveredIngredients AS (
    SELECT ip.row_id, ip.t_id FROM IngredientPool ip
    LEFT JOIN Excluded e ON ip.row_id = e.row_id AND ip.t_id = e.t_id
    WHERE e.t_id IS NULL
    UNION ALL
    SELECT row_id, t_id FROM Extras
)
SELECT pt.topping_name, COUNT(di.t_id) AS total_quantity
FROM DeliveredIngredients di
JOIN pizza_runner.pizza_toppings pt ON di.t_id = pt.topping_id
GROUP BY pt.topping_name
ORDER BY total_quantity DESC;


/*
 * =============================================================================
 * SECTION B: PRICING AND RATINGS
 * =============================================================================
 */

/*
 * Calculate total revenue from base pizza prices.
 *
 * - Checks for successfully delivered orders only.
 * - Charges $12 for Meatlovers and $10 for Vegetarian.
 * - Sums up all the individual pizza charges.
 */
SELECT 
  SUM(CASE WHEN co.pizza_id = 1 THEN 12 ELSE 10 END) AS total_revenue
FROM pizza_runner.customer_orders co
JOIN pizza_runner.runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation IN ('null', '');


/*
 * Calculate total revenue including charges for extras.
 *
 * - Computes the base revenue for successful deliveries.
 * - Counts total individual extra toppings added.
 * - Adds $1 to the total for every extra.
 */
WITH RECURSIVE numbers AS (
  SELECT 1 AS n UNION ALL SELECT n + 1 FROM numbers WHERE n < 10
),
SuccessfulDeliveries AS (
  SELECT 
      co.order_id, co.pizza_id,
      CASE WHEN co.extras IN ('null', '') THEN NULL ELSE co.extras END AS extras
  FROM pizza_runner.customer_orders co
  JOIN pizza_runner.runner_orders ro ON co.order_id = ro.order_id
  WHERE ro.cancellation IS NULL OR ro.cancellation IN ('null', '')
),
ExtraCounts AS (
  SELECT 
      sd.order_id, 
      COUNT(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(sd.extras, ',', n.n), ',', -1))) AS extra_count
  FROM SuccessfulDeliveries sd
  JOIN numbers n ON CHAR_LENGTH(sd.extras) - CHAR_LENGTH(REPLACE(sd.extras, ',', '')) >= n.n - 1
  WHERE sd.extras IS NOT NULL
  GROUP BY sd.order_id
)
SELECT 
  SUM(CASE WHEN sd.pizza_id = 1 THEN 12 ELSE 10 END) + COALESCE(SUM(ec.extra_count), 0) AS total_revenue_with_extras
FROM SuccessfulDeliveries sd
LEFT JOIN ExtraCounts ec ON sd.order_id = ec.order_id;


/*
 * Create and populate a runner ratings table.
 *
 * - Drops existing ratings table to avoid conflicts.
 * - Creates new table with constraints for 1-5 ratings.
 * - Inserts sample ratings for each successful delivery.
 */
DROP TABLE IF EXISTS pizza_runner.runner_ratings;
CREATE TABLE pizza_runner.runner_ratings (
  order_id INTEGER,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  rating_comment VARCHAR(100)
);

INSERT INTO pizza_runner.runner_ratings (order_id, rating, rating_comment)
VALUES 
  (1, 5, 'Great!'),
  (2, 4, 'Good speed.'),
  (3, 5, 'Perfect.'),
  (4, 3, 'A bit cold.'),
  (5, 5, 'Awesome service!'),
  (7, 4, 'No issues.'),
  (8, 5, 'Super fast.'),
  (10, 5, 'Friendly runner.');


/*
 * Consolidate order, delivery, and rating information together.
 *
 * - Cleans string formats for distance and duration.
 * - Calculates minutes between order and pickup time.
 * - Computes the runner's average speed in km/h.
 * - Joins order, delivery, and rating data together.
 */
WITH CleanedRunnerOrders AS (
  SELECT 
    order_id, runner_id,
    CAST(CASE WHEN pickup_time IN ('null', '') THEN NULL ELSE pickup_time END AS DATETIME) AS pickup_time,
    CAST(TRIM(REPLACE(REPLACE(distance, 'km', ''), ' ', '')) AS DECIMAL(10,2)) AS dist_km,
    CAST(TRIM(REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'mins', ''), 'minute', '')) AS UNSIGNED) AS dur_mins
  FROM pizza_runner.runner_orders
  WHERE cancellation IS NULL OR cancellation IN ('null', '')
)
SELECT 
  co.customer_id, co.order_id, ro.runner_id, rr.rating, co.order_time, ro.pickup_time,
  TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time) AS time_to_pickup_mins,
  ro.dur_mins AS delivery_duration_mins,
  ROUND((ro.dist_km / ro.dur_mins) * 60, 2) AS avg_speed_kmh,
  COUNT(co.pizza_id) AS total_pizzas
FROM pizza_runner.customer_orders co
JOIN CleanedRunnerOrders ro ON co.order_id = ro.order_id
LEFT JOIN pizza_runner.runner_ratings rr ON ro.order_id = rr.order_id
GROUP BY 
  co.customer_id, co.order_id, ro.runner_id, rr.rating, co.order_time, ro.pickup_time, ro.dur_mins, ro.dist_km;


/*
 * Calculate net revenue after runner kilometer payouts.
 *
 * - Determines gross revenue from delivered pizza prices.
 * - Extracts unique trip distances for runner payouts.
 * - Deducts the total payout from the total revenue.
 */
WITH SuccessfulOrders AS (
  SELECT 
    co.order_id, co.pizza_id, ro.distance
  FROM pizza_runner.customer_orders co
  JOIN pizza_runner.runner_orders ro ON co.order_id = ro.order_id
  WHERE ro.cancellation IS NULL OR ro.cancellation IN ('null', '')
),
Revenue AS (
  SELECT SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS gross_revenue
  FROM SuccessfulOrders
),
Expenses AS (
  SELECT SUM(dist_km * 0.30) AS runner_payout
  FROM (
    SELECT DISTINCT order_id, 
    CAST(TRIM(REPLACE(REPLACE(distance, 'km', ''), ' ', '')) AS DECIMAL(10,2)) AS dist_km
    FROM SuccessfulOrders
  ) unique_trips
)
SELECT 
  (SELECT gross_revenue FROM Revenue) - (SELECT runner_payout FROM Expenses) AS net_profit;