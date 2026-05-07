-- Relational Databases & SQL - Blocco 10
-- Gentle introduction: Window function
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- 1. Ranking ordini per cliente
SELECT customer_id,
       order_id,
       order_date,
       gross_revenue,
       row_number() OVER (
         PARTITION BY customer_id
         ORDER BY order_date, order_id
       ) AS order_seq
FROM order_revenue
ORDER BY customer_id, order_seq;

-- 2. Top prodotti per categoria
SELECT *
FROM (
  SELECT p.category,
         p.product_name,
         sum(oi.quantity) AS units,
         rank() OVER (
           PARTITION BY p.category
           ORDER BY sum(oi.quantity) DESC
         ) AS category_rank
  FROM order_items AS oi
  JOIN products AS p ON p.product_id = oi.product_id
  GROUP BY p.category, p.product_name
) AS ranked
WHERE category_rank <= 3
ORDER BY category, category_rank;

-- 3. Ricavo progressivo per canale
SELECT channel,
       order_date,
       order_id,
       gross_revenue,
       sum(gross_revenue) OVER (
         PARTITION BY channel
         ORDER BY order_date, order_id
       ) AS running_revenue
FROM order_revenue
WHERE status NOT IN ('cancelled', 'refunded')
ORDER BY channel, order_date, order_id;
