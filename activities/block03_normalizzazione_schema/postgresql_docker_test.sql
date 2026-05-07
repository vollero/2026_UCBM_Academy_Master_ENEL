-- Blocco 3 -- PostgreSQL in Docker
-- Script di test per creare uno schema normalizzato e verificare alcune query.
-- Esecuzione dalla radice del corso:
-- docker exec -i rdsql-postgres psql -U training -d training < activities/block03_normalizzazione_schema/postgresql_docker_test.sql

DROP SCHEMA IF EXISTS block03_lab CASCADE;
CREATE SCHEMA block03_lab;
SET search_path TO block03_lab;

-- Entità stabile: cliente.
-- I dati anagrafici del cliente non devono essere copiati in ogni vendita.
CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  customer_name TEXT NOT NULL,
  city TEXT NOT NULL
);

-- Entità stabile: prodotto.
-- Il nome prodotto e lo SKU descrivono il prodotto in generale.
CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  sku TEXT NOT NULL UNIQUE,
  product_name TEXT NOT NULL,
  category TEXT NOT NULL
);

-- Evento: vendita.
-- Una vendita avviene in una data e riguarda un cliente.
CREATE TABLE sales (
  sale_id INTEGER PRIMARY KEY,
  sale_date DATE NOT NULL,
  customer_id INTEGER NOT NULL REFERENCES customers(customer_id)
);

-- Dettaglio evento: riga vendita.
-- Quantità e prezzo unitario sono storici: descrivono quella vendita specifica.
CREATE TABLE sale_items (
  sale_id INTEGER NOT NULL REFERENCES sales(sale_id),
  line_no INTEGER NOT NULL,
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
  PRIMARY KEY (sale_id, line_no)
);

INSERT INTO customers (customer_id, customer_name, city) VALUES
  (1, 'Alfa Market', 'Roma'),
  (2, 'Beta Shop', 'Milano'),
  (3, 'Gamma Store', 'Napoli');

INSERT INTO products (product_id, sku, product_name, category) VALUES
  (10, 'PEN-01', 'Penna blu', 'Cancelleria'),
  (20, 'NOTE-02', 'Quaderno A4', 'Cancelleria'),
  (30, 'USB-32', 'Memoria USB 32GB', 'Elettronica'),
  (40, 'BAG-15', 'Borsa notebook', 'Accessori');

INSERT INTO sales (sale_id, sale_date, customer_id) VALUES
  (100, DATE '2026-05-07', 1),
  (101, DATE '2026-05-07', 2),
  (102, DATE '2026-05-08', 1);

INSERT INTO sale_items (sale_id, line_no, product_id, quantity, unit_price) VALUES
  (100, 1, 10, 20, 1.20),
  (100, 2, 20, 5, 2.50),
  (101, 1, 30, 2, 12.90),
  (102, 1, 10, 10, 1.10),
  (102, 2, 30, 1, 11.90);

-- Query 1: ricostruzione del report iniziale.
SELECT
  s.sale_id,
  s.sale_date,
  c.customer_name,
  c.city,
  p.sku,
  p.product_name,
  si.quantity,
  si.unit_price
FROM sales AS s
JOIN customers AS c
  ON c.customer_id = s.customer_id
JOIN sale_items AS si
  ON si.sale_id = s.sale_id
JOIN products AS p
  ON p.product_id = si.product_id
ORDER BY s.sale_id, si.line_no;

-- Query 2: totale di ogni vendita.
SELECT
  s.sale_id,
  s.sale_date,
  c.customer_name,
  SUM(si.quantity * si.unit_price) AS sale_total
FROM sales AS s
JOIN customers AS c
  ON c.customer_id = s.customer_id
JOIN sale_items AS si
  ON si.sale_id = s.sale_id
GROUP BY s.sale_id, s.sale_date, c.customer_name
ORDER BY s.sale_id;

-- Query 3: prodotti presenti in anagrafica ma non ancora venduti.
SELECT
  product_id,
  sku,
  product_name
FROM products
WHERE product_id NOT IN (
  SELECT product_id
  FROM sale_items
)
ORDER BY product_id;

