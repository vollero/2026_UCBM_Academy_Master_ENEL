-- Relational Databases & SQL - Blocco 4
-- Esercitazioni Docker
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- Esercizio 1: Prodotti hardware costosi
-- Richiesta: Scrivere una query che mostri i prodotti hardware con prezzo almeno 500, ordinati per prezzo decrescente.
SELECT product_id, sku, product_name, unit_price
FROM products
WHERE category = 'hardware'
  AND unit_price >= 500
ORDER BY unit_price DESC, product_id;

-- Esercizio 2: Fascia prezzo
-- Richiesta: Scrivere una query che assegni una fascia low/medium/high ai prodotti in base al prezzo.
SELECT product_id, product_name, unit_price,
       CASE
         WHEN unit_price < 100 THEN 'low'
         WHEN unit_price < 700 THEN 'medium'
         ELSE 'high'
       END AS price_band
FROM products
ORDER BY unit_price, product_id;

-- Esercizio 3: Top 5 prodotti
-- Richiesta: Scrivere una query che mostri i cinque prodotti più costosi.
SELECT product_id, sku, product_name, unit_price
FROM products
WHERE active = true
ORDER BY unit_price DESC, product_id
LIMIT 5;
