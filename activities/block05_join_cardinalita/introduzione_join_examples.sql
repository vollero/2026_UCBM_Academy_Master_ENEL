-- Relational Databases & SQL - Blocco 5
-- Gentle introduction ai JOIN: esempi eseguibili
-- Lo schema richiama il caso vendite normalizzato discusso nel blocco 3.
-- Target: PostgreSQL 13+

DROP SCHEMA IF EXISTS block05_join_intro CASCADE;
CREATE SCHEMA block05_join_intro;
SET search_path TO block05_join_intro;

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  customer_name TEXT NOT NULL,
  city TEXT NOT NULL
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  sku TEXT NOT NULL UNIQUE,
  product_name TEXT NOT NULL,
  category TEXT NOT NULL
);

CREATE TABLE sales (
  sale_id INTEGER PRIMARY KEY,
  sale_date DATE NOT NULL,
  customer_id INTEGER NOT NULL REFERENCES customers(customer_id)
);

CREATE TABLE sale_items (
  sale_id INTEGER NOT NULL REFERENCES sales(sale_id),
  line_no INTEGER NOT NULL,
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
  PRIMARY KEY (sale_id, line_no)
);

CREATE TABLE shipments (
  shipment_id INTEGER PRIMARY KEY,
  sale_id INTEGER NOT NULL UNIQUE REFERENCES sales(sale_id),
  shipped_at DATE NOT NULL,
  delivered_at DATE,
  carrier TEXT NOT NULL,
  CHECK (delivered_at IS NULL OR delivered_at >= shipped_at)
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

INSERT INTO shipments (shipment_id, sale_id, shipped_at, delivered_at, carrier) VALUES
  (1000, 100, DATE '2026-05-08', DATE '2026-05-09', 'DHL'),
  (1001, 101, DATE '2026-05-08', NULL, 'LocalPost');

-- 1. Primo JOIN: ogni vendita con nome e città del cliente.
SELECT
  s.sale_id,
  s.sale_date,
  c.customer_name,
  c.city
FROM sales AS s
JOIN customers AS c
  ON c.customer_id = s.customer_id
ORDER BY s.sale_id;

-- 2. JOIN 1-a-molti: vendite e righe vendita.
SELECT
  s.sale_id,
  s.sale_date,
  si.line_no,
  si.product_id,
  si.quantity
FROM sales AS s
JOIN sale_items AS si
  ON si.sale_id = s.sale_id
ORDER BY s.sale_id, si.line_no;

-- 3. Controllo del fan-out.
SELECT COUNT(*) AS sales_rows
FROM sales;

SELECT COUNT(*) AS joined_rows
FROM sales AS s
JOIN sale_items AS si
  ON si.sale_id = s.sale_id;

-- 4. Ricostruzione del report iniziale.
SELECT
  s.sale_id,
  s.sale_date,
  c.customer_name,
  c.city,
  p.sku,
  p.product_name,
  si.quantity,
  si.unit_price
FROM sale_items AS si
JOIN sales AS s
  ON s.sale_id = si.sale_id
JOIN customers AS c
  ON c.customer_id = s.customer_id
JOIN products AS p
  ON p.product_id = si.product_id
ORDER BY s.sale_id, si.line_no;

-- 5. INNER JOIN su relazione obbligatoria: riga vendita e prodotto.
SELECT
  si.sale_id,
  si.line_no,
  p.product_name,
  si.quantity
FROM sale_items AS si
JOIN products AS p
  ON p.product_id = si.product_id
ORDER BY si.sale_id, si.line_no;

-- 6. LEFT JOIN: prodotti presenti in anagrafica ma mai venduti.
SELECT
  p.product_id,
  p.sku,
  p.product_name
FROM products AS p
LEFT JOIN sale_items AS si
  ON si.product_id = p.product_id
WHERE si.sale_id IS NULL
ORDER BY p.product_id;

-- 7. LEFT JOIN: clienti senza vendite.
SELECT
  c.customer_id,
  c.customer_name,
  c.city
FROM customers AS c
LEFT JOIN sales AS s
  ON s.customer_id = c.customer_id
WHERE s.sale_id IS NULL
ORDER BY c.customer_id;

-- 8. LEFT JOIN su collegamento opzionale: vendite senza spedizione.
SELECT
  s.sale_id,
  s.sale_date,
  c.customer_name
FROM sales AS s
JOIN customers AS c
  ON c.customer_id = s.customer_id
LEFT JOIN shipments AS sh
  ON sh.sale_id = s.sale_id
WHERE sh.shipment_id IS NULL
ORDER BY s.sale_id;

-- 9. Query costruita per passaggi: riga vendita con importo.
SELECT
  si.sale_id,
  si.line_no,
  c.customer_name,
  p.product_name,
  si.quantity,
  si.unit_price,
  si.quantity * si.unit_price AS line_amount
FROM sale_items AS si
JOIN sales AS s
  ON s.sale_id = si.sale_id
JOIN customers AS c
  ON c.customer_id = s.customer_id
JOIN products AS p
  ON p.product_id = si.product_id
ORDER BY si.sale_id, si.line_no;

-- 10. Esempio commentato di errore: join senza condizione reale.
-- Non eseguire come soluzione: combinerebbe ogni vendita con ogni cliente.
-- SELECT s.sale_id, c.customer_name
-- FROM sales AS s
-- JOIN customers AS c
--   ON true;

