-- Relational Databases & SQL - Blocco 8
-- Esercitazioni Docker
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- Esercizio 1: Prodotti mai venduti
-- Richiesta: Scrivere la query che mostra i prodotti presenti in catalogo ma mai venduti.
SELECT p.product_id, p.sku, p.product_name
FROM products AS p
WHERE NOT EXISTS (
  SELECT 1
  FROM order_items AS oi
  WHERE oi.product_id = p.product_id
)
ORDER BY p.product_id;

-- Esercizio 2: Clienti con ordini sopra media
-- Richiesta: Scrivere la query che mostra clienti con almeno un ordine valido sopra la media degli ordini validi.
SELECT c.customer_id, c.full_name
FROM customers AS c
WHERE EXISTS (
  SELECT 1
  FROM order_revenue AS r
  WHERE r.customer_id = c.customer_id
    AND r.status NOT IN ('cancelled', 'refunded')
    AND r.gross_revenue > (
      SELECT avg(gross_revenue)
      FROM order_revenue
      WHERE status NOT IN ('cancelled', 'refunded')
    )
)
ORDER BY c.full_name;

-- Esercizio 3: Clienti senza ordini con EXCEPT
-- Richiesta: Scrivere la differenza tra tutti i clienti e i clienti presenti negli ordini.
SELECT customer_id
FROM customers
EXCEPT
SELECT customer_id
FROM orders
ORDER BY customer_id;
