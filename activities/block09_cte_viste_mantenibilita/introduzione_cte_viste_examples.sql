-- Relational Databases & SQL - Blocco 9
-- Gentle introduction: CTE, viste e mantenibilità
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- 1. Ordini validi come CTE
WITH valid_orders AS (
  SELECT *
  FROM order_revenue
  WHERE status NOT IN ('cancelled', 'refunded')
)
SELECT channel,
       count(*) AS orders,
       round(sum(gross_revenue), 2) AS revenue
FROM valid_orders
GROUP BY channel
ORDER BY revenue DESC;

-- 2. Pipeline con più CTE
WITH valid_orders AS (
  SELECT *
  FROM order_revenue
  WHERE status NOT IN ('cancelled', 'refunded')
),
orders_with_customer AS (
  SELECT r.*, c.country, c.segment
  FROM valid_orders AS r
  JOIN customers AS c ON c.customer_id = r.customer_id
)
SELECT country, segment, count(*) AS orders
FROM orders_with_customer
GROUP BY country, segment
ORDER BY country, segment;

-- 3. Vista temporanea di sessione
CREATE TEMP VIEW valid_order_revenue_session AS
SELECT *
FROM order_revenue
WHERE status NOT IN ('cancelled', 'refunded');

SELECT channel, round(sum(gross_revenue), 2) AS revenue
FROM valid_order_revenue_session
GROUP BY channel
ORDER BY revenue DESC;
