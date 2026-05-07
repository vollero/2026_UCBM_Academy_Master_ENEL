-- Relational Databases & SQL - Blocco 12
-- Gentle introduction: Capstone query design
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- 1. Specifica in CTE
WITH valid_orders AS (
  SELECT *
  FROM order_revenue
  WHERE status NOT IN ('cancelled', 'refunded')
),
customer_kpi AS (
  SELECT c.customer_id,
         c.full_name,
         c.segment,
         count(*) AS orders,
         round(sum(v.gross_revenue), 2) AS revenue
  FROM valid_orders AS v
  JOIN customers AS c ON c.customer_id = v.customer_id
  GROUP BY c.customer_id, c.full_name, c.segment
)
SELECT *
FROM customer_kpi
WHERE revenue >= 1000
ORDER BY revenue DESC;

-- 2. Controllo del denominatore
WITH valid_orders AS (
  SELECT *
  FROM order_revenue
  WHERE status NOT IN ('cancelled', 'refunded')
)
SELECT count(*) AS valid_orders,
       count(DISTINCT customer_id) AS customers,
       round(sum(gross_revenue), 2) AS revenue
FROM valid_orders;

-- 3. Report finale per paese e segmento
WITH valid_orders AS (
  SELECT *
  FROM order_revenue
  WHERE status NOT IN ('cancelled', 'refunded')
),
enriched AS (
  SELECT v.*, c.country, c.segment
  FROM valid_orders AS v
  JOIN customers AS c ON c.customer_id = v.customer_id
)
SELECT country, segment,
       count(*) AS orders,
       round(sum(gross_revenue), 2) AS revenue,
       round(avg(gross_revenue), 2) AS aov
FROM enriched
GROUP BY country, segment
ORDER BY country, revenue DESC;
