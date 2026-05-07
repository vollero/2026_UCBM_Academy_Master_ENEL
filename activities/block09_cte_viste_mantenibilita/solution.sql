-- Relational Databases & SQL - soluzione SQL blocco 9
-- Prerequisito: caricare prima ../../sql/01_schema_seed_postgres.sql
-- Target: PostgreSQL 13+

SET search_path TO training;

CREATE OR REPLACE VIEW valid_order_revenue AS
SELECT r.order_id, r.customer_id, r.order_date, r.channel,
       r.status, r.gross_revenue
FROM order_revenue r
WHERE r.status NOT IN ('cancelled', 'refunded');

WITH monthly_channel AS (
    SELECT date_trunc('month', order_date)::date AS month,
           channel,
           round(sum(gross_revenue), 2) AS revenue
    FROM valid_order_revenue
    GROUP BY month, channel
)
SELECT month, channel, revenue
FROM monthly_channel
ORDER BY month, channel;


WITH customer_revenue AS (
    SELECT customer_id, round(sum(gross_revenue), 2) AS revenue
    FROM valid_order_revenue
    GROUP BY customer_id
), enriched AS (
    SELECT c.customer_id, c.full_name, c.segment,
           coalesce(cr.revenue, 0) AS revenue
    FROM customers c
    LEFT JOIN customer_revenue cr ON cr.customer_id = c.customer_id
)
SELECT *
FROM enriched
ORDER BY revenue DESC, customer_id;
