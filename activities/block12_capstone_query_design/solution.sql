-- Relational Databases & SQL - soluzione SQL blocco 12
-- Prerequisito: caricare prima ../../sql/01_schema_seed_postgres.sql
-- Target: PostgreSQL 13+

SET search_path TO training;

WITH valid_revenue AS (
    SELECT r.order_id, r.customer_id, r.order_date, r.channel, r.gross_revenue
    FROM order_revenue r
    WHERE r.status NOT IN ('cancelled', 'refunded')
), segment_month AS (
    SELECT date_trunc('month', v.order_date)::date AS month,
           c.segment,
           count(*) AS orders,
           round(sum(v.gross_revenue), 2) AS revenue
    FROM valid_revenue v
    JOIN customers c ON c.customer_id = v.customer_id
    GROUP BY month, c.segment
), ranked AS (
    SELECT month, segment, orders, revenue,
           rank() OVER (PARTITION BY month ORDER BY revenue DESC, segment) AS segment_rank,
           round(100 * revenue / sum(revenue) OVER (PARTITION BY month), 2) AS pct_month_revenue
    FROM segment_month
)
SELECT month, segment, orders, revenue, segment_rank, pct_month_revenue
FROM ranked
WHERE segment_rank <= 3
ORDER BY month, segment_rank, segment;


WITH valid_revenue AS (
    SELECT * FROM order_revenue
    WHERE status NOT IN ('cancelled', 'refunded')
)
SELECT count(*) AS valid_orders,
       round(sum(gross_revenue), 2) AS valid_revenue
FROM valid_revenue;

SELECT count(*) AS customers,
       count(DISTINCT customer_id) AS distinct_customers
FROM customers;
