-- Relational Databases & SQL - Blocco 6
-- Esercitazioni Docker
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- Esercizio 1: Ricavo per mese e canale
-- Richiesta: Scrivere la query che calcola ricavo e numero ordini per mese e canale, escludendo cancellati e rimborsati.
SELECT date_trunc('month', order_date)::date AS month,
       channel,
       count(*) AS orders,
       round(sum(gross_revenue), 2) AS revenue
FROM order_revenue
WHERE status NOT IN ('cancelled', 'refunded')
GROUP BY month, channel
ORDER BY month, channel;

-- Esercizio 2: AOV per segmento
-- Richiesta: Scrivere la query che calcola valore medio ordine per segmento cliente.
SELECT c.segment,
       count(*) AS valid_orders,
       round(avg(r.gross_revenue), 2) AS avg_order_value
FROM order_revenue AS r
JOIN customers AS c ON c.customer_id = r.customer_id
WHERE r.status NOT IN ('cancelled', 'refunded')
GROUP BY c.segment
ORDER BY avg_order_value DESC;

-- Esercizio 3: Categorie con almeno 10 unità
-- Richiesta: Scrivere la query che mostra categorie con almeno 10 unità vendute valide.
SELECT p.category,
       sum(oi.quantity) AS units
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY p.category
HAVING sum(oi.quantity) >= 10
ORDER BY units DESC;
