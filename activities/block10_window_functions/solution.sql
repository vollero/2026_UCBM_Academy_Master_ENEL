-- Relational Databases & SQL - soluzione SQL blocco 10
-- Prerequisito: caricare prima ../../sql/01_schema_seed_postgres.sql
-- Target: PostgreSQL 13+

SET search_path TO training;

WITH country_month AS (
    SELECT date_trunc('month', r.order_date)::date AS month,
           c.country,
           round(sum(r.gross_revenue), 2) AS revenue
    FROM order_revenue r
    JOIN customers c ON c.customer_id = r.customer_id
    WHERE r.status NOT IN ('cancelled', 'refunded')
    GROUP BY month, c.country
)
SELECT month, country, revenue,
       rank() OVER (PARTITION BY month ORDER BY revenue DESC, country) AS country_rank,
       round(100 * revenue / sum(revenue) OVER (PARTITION BY month), 2) AS pct_month
FROM country_month
ORDER BY month, country_rank, country;


WITH monthly_channel AS (
    SELECT date_trunc('month', order_date)::date AS month,
           channel,
           round(sum(gross_revenue), 2) AS revenue
    FROM order_revenue
    WHERE status NOT IN ('cancelled', 'refunded')
    GROUP BY month, channel
)
SELECT month, channel, revenue,
       sum(revenue) OVER (PARTITION BY channel ORDER BY month
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
       lag(revenue) OVER (PARTITION BY channel ORDER BY month) AS previous_month_revenue
FROM monthly_channel
ORDER BY channel, month;
