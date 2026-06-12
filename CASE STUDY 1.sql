
-- -----------------------------------------------------------------------------
-- 1. Which item was the most popular for each customer?
-- -----------------------------------------------------------------------------
WITH ItemCounts AS (
    SELECT 
        s.customer_id, 
        m.product_name, 
        COUNT(s.product_id) AS order_count,
        DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rank_num
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM ItemCounts
WHERE rank_num = 1;

-- -----------------------------------------------------------------------------
-- 2. Which item was purchased first by the customer after they became a member?
-- -----------------------------------------------------------------------------
WITH FirstPurchases AS (
    SELECT 
        s.customer_id, 
        s.order_date, 
        m.product_name,
        DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rank_num
    FROM sales s
    JOIN members mem ON s.customer_id = mem.customer_id
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.order_date >= mem.join_date
)
SELECT customer_id, order_date, product_name
FROM FirstPurchases
WHERE rank_num = 1;

-- -----------------------------------------------------------------------------
-- 3. Which item was purchased just before the customer became a member?
-- -----------------------------------------------------------------------------
WITH PriorPurchases AS (
    SELECT 
        s.customer_id, 
        s.order_date, 
        m.product_name,
        DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank_num
    FROM sales s
    JOIN members mem ON s.customer_id = mem.customer_id
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.order_date < mem.join_date
)
SELECT customer_id, order_date, product_name
FROM PriorPurchases
WHERE rank_num = 1;

-- -----------------------------------------------------------------------------
-- 4. What is the total items and amount spent for each member before they became a member?
-- -----------------------------------------------------------------------------
SELECT 
    s.customer_id, 
    COUNT(s.product_id) AS total_items, 
    SUM(m.price) AS total_spent
FROM sales s
JOIN members mem ON s.customer_id = mem.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- -----------------------------------------------------------------------------
-- 5. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
--    how many points would each customer have?
-- -----------------------------------------------------------------------------
SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 20 
            ELSE m.price * 10 
        END
    ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- -----------------------------------------------------------------------------
-- 6. In the first week after a customer joins the program they earn 2x points 
--    on all items - how many points do customer A and B have at the end of January?
-- -----------------------------------------------------------------------------
SELECT 
    s.customer_id,
    SUM(
        CASE
            -- First week of membership (join date + 6 days) earns 20 points per $1
            WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) THEN m.price * 20
            -- Sushi always earns 20 points per $1
            WHEN m.product_name = 'sushi' THEN m.price * 20
            -- Everything else earns standard 10 points per $1
            ELSE m.price * 10
        END
    ) AS total_points
FROM sales s
JOIN members mem ON s.customer_id = mem.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- -----------------------------------------------------------------------------
-- 7. Ranking of customer products (Null ranking values for non-member purchases)
-- -----------------------------------------------------------------------------
WITH CustomerData AS (
    SELECT 
        s.customer_id, 
        s.order_date, 
        m.product_name, 
        m.price,
        CASE
            WHEN mem.join_date IS NOT NULL AND s.order_date >= mem.join_date THEN 'Y'
            ELSE 'N'
        END AS member_status
    FROM sales s
    LEFT JOIN members mem ON s.customer_id = mem.customer_id
    JOIN menu m ON s.product_id = m.product_id
)
SELECT 
    customer_id, 
    order_date, 
    product_name, 
    price, 
    member_status,
    CASE
        WHEN member_status = 'N' THEN NULL
        ELSE DENSE_RANK() OVER(PARTITION BY customer_id, member_status ORDER BY order_date)
    END AS ranking
FROM CustomerData
ORDER BY customer_id, order_date, product_name;