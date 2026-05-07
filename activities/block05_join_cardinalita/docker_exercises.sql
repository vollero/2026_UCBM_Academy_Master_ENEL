-- Relational Databases & SQL - Blocco 5
-- Esercitazioni Docker
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- Esercizio 1: Righe ordine leggibili
-- Richiesta: Costruire la query che ricostruisce la tabella ordine-cliente-prodotto-quantità partendo dallo schema normalizzato.
SELECT o.order_id,
       c.full_name,
       p.product_name,
       oi.quantity
FROM order_items AS oi
JOIN orders AS o ON o.order_id = oi.order_id
JOIN customers AS c ON c.customer_id = o.customer_id
JOIN products AS p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.product_name;

-- Esercizio 2: Ordini senza spedizione
-- Richiesta: Scrivere una query che mostri gli ordini senza spedizione associata.
SELECT o.order_id, o.order_date, c.full_name, o.status
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
LEFT JOIN shipments AS s ON s.order_id = o.order_id
WHERE s.shipment_id IS NULL
ORDER BY o.order_date, o.order_id;

-- Esercizio 3: Controllo fan-out
-- Richiesta: Contare le righe ordine e confrontarle con il numero di ordini.
SELECT count(*) AS orders
FROM orders;

SELECT count(*) AS order_item_rows
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id;
