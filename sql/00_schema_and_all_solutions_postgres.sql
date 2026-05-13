-- Relational Databases & SQL - database di laboratorio
-- Target: PostgreSQL 13+

DROP SCHEMA IF EXISTS training CASCADE;
CREATE SCHEMA training;
SET search_path TO training;

CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    full_name text NOT NULL,
    email text NOT NULL UNIQUE,
    signup_date date NOT NULL,
    country char(2) NOT NULL,
    city text NOT NULL,
    segment text NOT NULL CHECK (segment IN ('consumer', 'smb', 'enterprise'))
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    sku text NOT NULL UNIQUE,
    product_name text NOT NULL,
    category text NOT NULL CHECK (category IN ('hardware', 'software', 'services', 'accessories')),
    unit_price numeric(10, 2) NOT NULL CHECK (unit_price >= 0),
    active boolean NOT NULL DEFAULT true
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES customers(customer_id),
    order_date date NOT NULL,
    status text NOT NULL CHECK (status IN ('pending', 'completed', 'shipped', 'cancelled', 'refunded')),
    channel text NOT NULL CHECK (channel IN ('web', 'sales', 'marketplace', 'partner'))
);

CREATE TABLE order_items (
    order_id integer NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id integer NOT NULL REFERENCES products(product_id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(10, 2) NOT NULL CHECK (unit_price >= 0),
    discount_pct numeric(5, 2) NOT NULL DEFAULT 0 CHECK (discount_pct >= 0 AND discount_pct < 100),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id integer PRIMARY KEY,
    order_id integer NOT NULL REFERENCES orders(order_id),
    paid_at timestamp NOT NULL,
    amount numeric(10, 2) NOT NULL CHECK (amount >= 0),
    method text NOT NULL CHECK (method IN ('card', 'bank_transfer', 'paypal', 'invoice')),
    status text NOT NULL CHECK (status IN ('authorized', 'captured', 'failed', 'refunded'))
);

CREATE TABLE shipments (
    shipment_id integer PRIMARY KEY,
    order_id integer NOT NULL UNIQUE REFERENCES orders(order_id),
    shipped_at date NOT NULL,
    delivered_at date,
    carrier text NOT NULL CHECK (carrier IN ('DHL', 'UPS', 'FedEx', 'LocalPost')),
    shipping_cost numeric(10, 2) NOT NULL CHECK (shipping_cost >= 0),
    CHECK (delivered_at IS NULL OR delivered_at >= shipped_at)
);

CREATE TABLE support_tickets (
    ticket_id integer PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES customers(customer_id),
    order_id integer REFERENCES orders(order_id),
    opened_at timestamp NOT NULL,
    closed_at timestamp,
    priority text NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status text NOT NULL CHECK (status IN ('open', 'waiting_customer', 'resolved', 'closed')),
    topic text NOT NULL,
    CHECK (closed_at IS NULL OR closed_at >= opened_at)
);

CREATE TABLE inventory_movements (
    movement_id integer PRIMARY KEY,
    product_id integer NOT NULL REFERENCES products(product_id),
    movement_date date NOT NULL,
    movement_type text NOT NULL CHECK (movement_type IN ('purchase', 'sale', 'return', 'adjustment')),
    quantity_delta integer NOT NULL CHECK (quantity_delta <> 0),
    reason text NOT NULL
);

INSERT INTO customers (customer_id, full_name, email, signup_date, country, city, segment) VALUES
(1, 'Alice Bianchi', 'alice.bianchi@example.com', '2025-01-05', 'IT', 'Roma', 'consumer'),
(2, 'Marco Rossi', 'marco.rossi@example.com', '2025-01-12', 'IT', 'Milano', 'smb'),
(3, 'Giulia Verdi', 'giulia.verdi@example.com', '2025-02-01', 'IT', 'Torino', 'consumer'),
(4, 'Luca Neri', 'luca.neri@example.com', '2025-02-05', 'IT', 'Bologna', 'enterprise'),
(5, 'Sara Gallo', 'sara.gallo@example.com', '2025-02-20', 'IT', 'Napoli', 'consumer'),
(6, 'Emma Smith', 'emma.smith@example.com', '2025-01-18', 'UK', 'London', 'smb'),
(7, 'James Brown', 'james.brown@example.com', '2025-03-01', 'UK', 'Manchester', 'consumer'),
(8, 'Claire Martin', 'claire.martin@example.com', '2025-02-14', 'FR', 'Paris', 'enterprise'),
(9, 'Pierre Dubois', 'pierre.dubois@example.com', '2025-03-10', 'FR', 'Lyon', 'consumer'),
(10, 'Anna Muller', 'anna.muller@example.com', '2025-01-30', 'DE', 'Berlin', 'smb'),
(11, 'Hans Weber', 'hans.weber@example.com', '2025-03-20', 'DE', 'Munich', 'enterprise'),
(12, 'Sofia Garcia', 'sofia.garcia@example.com', '2025-04-02', 'ES', 'Madrid', 'consumer'),
(13, 'Pablo Lopez', 'pablo.lopez@example.com', '2025-02-28', 'ES', 'Barcelona', 'smb'),
(14, 'Marta Silva', 'marta.silva@example.com', '2025-04-12', 'PT', 'Lisbon', 'consumer'),
(15, 'Niels Jensen', 'niels.jensen@example.com', '2025-04-17', 'DK', 'Copenhagen', 'smb'),
(16, 'Eva Novak', 'eva.novak@example.com', '2025-05-01', 'CZ', 'Prague', 'enterprise'),
(17, 'Omar Haddad', 'omar.haddad@example.com', '2025-03-25', 'AE', 'Dubai', 'enterprise'),
(18, 'Lina Chen', 'lina.chen@example.com', '2025-05-09', 'SG', 'Singapore', 'smb'),
(19, 'Mei Tan', 'mei.tan@example.com', '2025-05-10', 'SG', 'Singapore', 'consumer'),
(20, 'Noah Wilson', 'noah.wilson@example.com', '2025-01-22', 'US', 'New York', 'enterprise');

INSERT INTO products (product_id, sku, product_name, category, unit_price, active) VALUES
(1, 'LAP-13', 'Laptop 13 Pro', 'hardware', 1199.00, true),
(2, 'LAP-15', 'Laptop 15 Max', 'hardware', 1699.00, true),
(3, 'MON-27', 'Monitor 27', 'hardware', 329.00, true),
(4, 'KEY-MECH', 'Mechanical Keyboard', 'accessories', 99.00, true),
(5, 'MOU-WL', 'Wireless Mouse', 'accessories', 39.00, true),
(6, 'DOC-USBC', 'USB-C Dock', 'accessories', 149.00, true),
(7, 'BAG-15', 'Laptop Backpack', 'accessories', 79.00, true),
(8, 'LIC-STD', 'Analytics Suite Standard', 'software', 39.00, true),
(9, 'LIC-PRO', 'Analytics Suite Pro', 'software', 99.00, true),
(10, 'SRV-SETUP', 'Onboarding Workshop', 'services', 650.00, true),
(11, 'SRV-SQL', 'SQL Performance Review', 'services', 900.00, true),
(12, 'HEAD-ANC', 'Noise Cancelling Headset', 'accessories', 179.00, true),
(13, 'CAM-HD', 'Webcam HD', 'accessories', 89.00, true),
(14, 'TAB-11', 'Tablet 11', 'hardware', 599.00, true),
(15, 'PHONE-X', 'Business Phone', 'hardware', 799.00, true),
(16, 'WARRANTY-3Y', 'Extended Warranty 3Y', 'services', 199.00, true);

INSERT INTO orders (order_id, customer_id, order_date, status, channel) VALUES
(1, 1, '2025-01-06', 'completed', 'web'),
(2, 2, '2025-01-14', 'completed', 'sales'),
(3, 6, '2025-01-20', 'shipped', 'web'),
(4, 20, '2025-01-25', 'completed', 'sales'),
(5, 10, '2025-02-02', 'completed', 'web'),
(6, 3, '2025-02-04', 'completed', 'marketplace'),
(7, 8, '2025-02-16', 'completed', 'sales'),
(8, 4, '2025-02-18', 'cancelled', 'sales'),
(9, 5, '2025-02-22', 'completed', 'web'),
(10, 13, '2025-03-02', 'shipped', 'partner'),
(11, 7, '2025-03-04', 'completed', 'web'),
(12, 9, '2025-03-11', 'refunded', 'web'),
(13, 11, '2025-03-22', 'completed', 'sales'),
(14, 17, '2025-03-28', 'completed', 'partner'),
(15, 1, '2025-04-03', 'completed', 'web'),
(16, 12, '2025-04-05', 'shipped', 'marketplace'),
(17, 14, '2025-04-14', 'completed', 'web'),
(18, 15, '2025-04-18', 'pending', 'web'),
(19, 2, '2025-04-23', 'completed', 'sales'),
(20, 8, '2025-04-25', 'shipped', 'sales'),
(21, 16, '2025-05-03', 'completed', 'sales'),
(22, 18, '2025-05-10', 'completed', 'web'),
(23, 19, '2025-05-12', 'completed', 'marketplace'),
(24, 20, '2025-05-15', 'completed', 'sales'),
(25, 6, '2025-05-20', 'refunded', 'web'),
(26, 11, '2025-05-26', 'shipped', 'partner'),
(27, 3, '2025-06-03', 'completed', 'web'),
(28, 12, '2025-06-04', 'pending', 'marketplace'),
(29, 17, '2025-06-07', 'completed', 'sales'),
(30, 18, '2025-06-10', 'completed', 'web'),
(31, 1, '2025-06-12', 'shipped', 'web'),
(32, 5, '2025-06-15', 'cancelled', 'web'),
(33, 10, '2025-06-18', 'completed', 'sales'),
(34, 13, '2025-06-19', 'completed', 'partner'),
(35, 14, '2025-06-21', 'completed', 'web'),
(36, 15, '2025-06-22', 'completed', 'web'),
(37, 16, '2025-06-24', 'shipped', 'sales'),
(38, 7, '2025-06-25', 'completed', 'marketplace'),
(39, 9, '2025-06-27', 'completed', 'web'),
(40, 4, '2025-06-28', 'completed', 'sales');

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(1, 1, 1, 1199.00, 5), (1, 7, 1, 79.00, 0), (1, 16, 1, 199.00, 10),
(2, 2, 2, 1699.00, 8), (2, 6, 2, 149.00, 0), (2, 10, 1, 650.00, 0),
(3, 3, 2, 329.00, 0), (3, 4, 2, 99.00, 0), (3, 5, 2, 39.00, 0),
(4, 2, 4, 1699.00, 12), (4, 9, 20, 99.00, 15), (4, 11, 1, 900.00, 0),
(5, 8, 10, 39.00, 0), (5, 13, 2, 89.00, 0),
(6, 14, 1, 599.00, 3), (6, 12, 1, 179.00, 0),
(7, 1, 5, 1199.00, 10), (7, 6, 5, 149.00, 5), (7, 10, 2, 650.00, 0),
(8, 2, 3, 1699.00, 0), (8, 11, 1, 900.00, 0),
(9, 15, 1, 799.00, 0), (9, 5, 1, 39.00, 0), (9, 13, 1, 89.00, 0),
(10, 9, 8, 99.00, 10), (10, 10, 1, 650.00, 0),
(11, 3, 1, 329.00, 0), (11, 4, 1, 99.00, 0), (11, 5, 1, 39.00, 0),
(12, 14, 1, 599.00, 0), (12, 7, 1, 79.00, 0),
(13, 2, 6, 1699.00, 15), (13, 11, 2, 900.00, 0), (13, 16, 6, 199.00, 20),
(14, 1, 8, 1199.00, 12), (14, 9, 25, 99.00, 20), (14, 11, 1, 900.00, 0),
(15, 8, 4, 39.00, 0), (15, 12, 1, 179.00, 0),
(16, 15, 1, 799.00, 5), (16, 13, 1, 89.00, 0),
(17, 5, 2, 39.00, 0), (17, 7, 1, 79.00, 0),
(18, 3, 2, 329.00, 0), (18, 6, 1, 149.00, 0),
(19, 1, 2, 1199.00, 7), (19, 10, 1, 650.00, 0),
(20, 2, 2, 1699.00, 10), (20, 9, 10, 99.00, 15),
(21, 11, 3, 900.00, 0), (21, 9, 30, 99.00, 25),
(22, 4, 3, 99.00, 0), (22, 5, 3, 39.00, 0), (22, 13, 2, 89.00, 0),
(23, 14, 1, 599.00, 0), (23, 12, 1, 179.00, 5),
(24, 2, 3, 1699.00, 10), (24, 6, 3, 149.00, 0), (24, 16, 3, 199.00, 20),
(25, 1, 1, 1199.00, 0), (25, 7, 1, 79.00, 0),
(26, 2, 2, 1699.00, 12), (26, 11, 1, 900.00, 0),
(27, 8, 12, 39.00, 0), (27, 13, 1, 89.00, 0),
(28, 15, 1, 799.00, 0), (28, 5, 1, 39.00, 0),
(29, 1, 6, 1199.00, 10), (29, 9, 18, 99.00, 20), (29, 10, 1, 650.00, 0),
(30, 3, 2, 329.00, 0), (30, 12, 2, 179.00, 0),
(31, 14, 2, 599.00, 5), (31, 16, 2, 199.00, 15),
(32, 15, 2, 799.00, 0),
(33, 6, 4, 149.00, 0), (33, 4, 4, 99.00, 0), (33, 5, 4, 39.00, 0),
(34, 9, 15, 99.00, 18), (34, 10, 1, 650.00, 0),
(35, 8, 6, 39.00, 0), (35, 13, 1, 89.00, 0),
(36, 3, 1, 329.00, 0), (36, 12, 1, 179.00, 0), (36, 7, 1, 79.00, 0),
(37, 2, 1, 1699.00, 5), (37, 11, 1, 900.00, 0),
(38, 14, 1, 599.00, 10), (38, 5, 1, 39.00, 0),
(39, 1, 1, 1199.00, 15), (39, 16, 1, 199.00, 0),
(40, 2, 5, 1699.00, 18), (40, 9, 20, 99.00, 20), (40, 11, 2, 900.00, 0);

INSERT INTO payments (payment_id, order_id, paid_at, amount, method, status) VALUES
(1, 1, '2025-01-06 10:12:00', 1418.25, 'card', 'captured'),
(2, 2, '2025-01-14 16:45:00', 5074.16, 'invoice', 'captured'),
(3, 3, '2025-01-20 11:20:00', 934.00, 'paypal', 'authorized'),
(4, 4, '2025-01-25 09:10:00', 10556.48, 'bank_transfer', 'captured'),
(5, 5, '2025-02-02 18:30:00', 568.00, 'card', 'captured'),
(6, 6, '2025-02-04 14:00:00', 760.03, 'paypal', 'captured'),
(7, 7, '2025-02-16 15:33:00', 7448.25, 'invoice', 'captured'),
(8, 8, '2025-02-18 08:51:00', 0.00, 'invoice', 'failed'),
(9, 9, '2025-02-22 12:07:00', 927.00, 'card', 'captured'),
(10, 10, '2025-03-02 17:02:00', 1362.80, 'bank_transfer', 'captured'),
(11, 11, '2025-03-04 10:15:00', 467.00, 'card', 'captured'),
(12, 12, '2025-03-11 19:20:00', 678.00, 'paypal', 'refunded'),
(13, 13, '2025-03-22 13:40:00', 11657.10, 'invoice', 'captured'),
(14, 14, '2025-03-28 09:50:00', 12623.56, 'bank_transfer', 'captured'),
(15, 15, '2025-04-03 20:22:00', 335.00, 'card', 'captured'),
(16, 16, '2025-04-05 11:25:00', 848.05, 'paypal', 'captured'),
(17, 17, '2025-04-14 16:13:00', 157.00, 'card', 'captured'),
(18, 18, '2025-04-18 09:15:00', 807.00, 'card', 'authorized'),
(19, 19, '2025-04-23 10:05:00', 2880.14, 'invoice', 'captured'),
(20, 20, '2025-04-25 14:22:00', 3900.30, 'invoice', 'captured'),
(21, 21, '2025-05-03 12:34:00', 4927.50, 'bank_transfer', 'captured'),
(22, 22, '2025-05-10 10:20:00', 592.00, 'card', 'captured'),
(23, 23, '2025-05-12 18:01:00', 769.05, 'paypal', 'captured'),
(24, 24, '2025-05-15 10:54:00', 5639.30, 'invoice', 'captured'),
(25, 25, '2025-05-20 13:04:00', 1278.00, 'card', 'refunded'),
(26, 26, '2025-05-26 11:47:00', 3890.24, 'invoice', 'captured'),
(27, 27, '2025-06-03 15:37:00', 557.00, 'card', 'captured'),
(28, 28, '2025-06-04 09:40:00', 838.00, 'paypal', 'authorized'),
(29, 29, '2025-06-07 12:15:00', 8568.60, 'bank_transfer', 'captured'),
(30, 30, '2025-06-10 16:25:00', 1016.00, 'card', 'captured'),
(31, 31, '2025-06-12 18:00:00', 1470.90, 'card', 'captured'),
(32, 32, '2025-06-15 08:22:00', 0.00, 'card', 'failed'),
(33, 33, '2025-06-18 09:08:00', 1148.00, 'invoice', 'captured'),
(34, 34, '2025-06-19 10:16:00', 1867.70, 'bank_transfer', 'captured'),
(35, 35, '2025-06-21 19:10:00', 323.00, 'paypal', 'captured'),
(36, 36, '2025-06-22 10:18:00', 587.00, 'card', 'captured'),
(37, 37, '2025-06-24 13:55:00', 2514.05, 'invoice', 'captured'),
(38, 38, '2025-06-25 17:30:00', 578.10, 'paypal', 'captured'),
(39, 39, '2025-06-27 11:05:00', 1218.15, 'card', 'captured'),
(40, 40, '2025-06-28 12:42:00', 10307.90, 'bank_transfer', 'captured');

INSERT INTO shipments (shipment_id, order_id, shipped_at, delivered_at, carrier, shipping_cost) VALUES
(1, 1, '2025-01-07', '2025-01-09', 'DHL', 18.00),
(2, 2, '2025-01-16', '2025-01-20', 'UPS', 42.00),
(3, 3, '2025-01-21', NULL, 'LocalPost', 15.00),
(4, 4, '2025-01-27', '2025-02-03', 'FedEx', 80.00),
(5, 5, '2025-02-03', '2025-02-05', 'DHL', 12.00),
(6, 6, '2025-02-05', '2025-02-07', 'LocalPost', 11.00),
(7, 7, '2025-02-18', '2025-02-21', 'UPS', 65.00),
(8, 9, '2025-02-23', '2025-02-26', 'DHL', 14.00),
(9, 10, '2025-03-04', NULL, 'FedEx', 30.00),
(10, 11, '2025-03-05', '2025-03-09', 'LocalPost', 10.00),
(11, 12, '2025-03-12', '2025-03-14', 'DHL', 13.00),
(12, 13, '2025-03-24', '2025-03-29', 'UPS', 90.00),
(13, 14, '2025-03-30', '2025-04-05', 'FedEx', 110.00),
(14, 15, '2025-04-04', '2025-04-06', 'DHL', 10.00),
(15, 16, '2025-04-06', NULL, 'LocalPost', 12.00),
(16, 17, '2025-04-15', '2025-04-17', 'DHL', 9.00),
(17, 19, '2025-04-24', '2025-04-28', 'UPS', 35.00),
(18, 20, '2025-04-27', NULL, 'UPS', 48.00),
(19, 21, '2025-05-05', '2025-05-10', 'FedEx', 70.00),
(20, 22, '2025-05-11', '2025-05-15', 'LocalPost', 10.00),
(21, 23, '2025-05-13', '2025-05-16', 'DHL', 14.00),
(22, 24, '2025-05-17', '2025-05-23', 'UPS', 58.00),
(23, 25, '2025-05-21', '2025-05-24', 'DHL', 18.00),
(24, 26, '2025-05-28', NULL, 'FedEx', 55.00),
(25, 27, '2025-06-04', '2025-06-08', 'LocalPost', 10.00),
(26, 29, '2025-06-09', '2025-06-15', 'FedEx', 92.00),
(27, 30, '2025-06-11', '2025-06-14', 'DHL', 15.00),
(28, 31, '2025-06-13', NULL, 'DHL', 20.00),
(29, 33, '2025-06-19', '2025-06-22', 'UPS', 24.00),
(30, 34, '2025-06-20', '2025-06-25', 'FedEx', 28.00),
(31, 35, '2025-06-22', '2025-06-24', 'LocalPost', 10.00),
(32, 36, '2025-06-23', '2025-06-27', 'DHL', 12.00),
(33, 37, '2025-06-25', NULL, 'UPS', 42.00),
(34, 38, '2025-06-26', '2025-06-29', 'LocalPost', 10.00),
(35, 39, '2025-06-28', '2025-07-01', 'DHL', 18.00),
(36, 40, '2025-06-30', '2025-07-06', 'FedEx', 95.00);

INSERT INTO support_tickets (ticket_id, customer_id, order_id, opened_at, closed_at, priority, status, topic) VALUES
(1, 1, 1, '2025-01-08 09:15:00', '2025-01-08 17:10:00', 'low', 'closed', 'invoice request'),
(2, 6, 3, '2025-01-25 11:05:00', NULL, 'medium', 'waiting_customer', 'delivery delay'),
(3, 20, 4, '2025-02-05 10:00:00', '2025-02-06 16:35:00', 'medium', 'closed', 'missing serial number'),
(4, 9, 12, '2025-03-14 12:30:00', '2025-03-16 09:20:00', 'high', 'closed', 'refund request'),
(5, 14, 17, '2025-04-16 18:55:00', '2025-04-18 12:00:00', 'low', 'resolved', 'product question'),
(6, 8, 20, '2025-04-30 08:10:00', NULL, 'high', 'open', 'late enterprise delivery'),
(7, 16, 21, '2025-05-07 15:42:00', '2025-05-08 11:30:00', 'medium', 'closed', 'contract update'),
(8, 6, 25, '2025-05-23 14:00:00', '2025-05-25 10:10:00', 'urgent', 'closed', 'refund escalation'),
(9, 12, 28, '2025-06-05 09:25:00', NULL, 'medium', 'open', 'payment authorization'),
(10, 1, 31, '2025-06-16 10:40:00', NULL, 'medium', 'open', 'shipment tracking'),
(11, 16, 37, '2025-06-27 13:05:00', NULL, 'high', 'open', 'enterprise onboarding'),
(12, 4, 40, '2025-07-01 09:00:00', '2025-07-03 18:20:00', 'medium', 'resolved', 'delivery scheduling');

INSERT INTO inventory_movements (movement_id, product_id, movement_date, movement_type, quantity_delta, reason) VALUES
(1, 1, '2025-01-01', 'purchase', 50, 'initial stock'),
(2, 2, '2025-01-01', 'purchase', 40, 'initial stock'),
(3, 3, '2025-01-01', 'purchase', 80, 'initial stock'),
(4, 4, '2025-01-01', 'purchase', 120, 'initial stock'),
(5, 5, '2025-01-01', 'purchase', 150, 'initial stock'),
(6, 6, '2025-01-01', 'purchase', 70, 'initial stock'),
(7, 7, '2025-01-01', 'purchase', 90, 'initial stock'),
(8, 12, '2025-01-01', 'purchase', 60, 'initial stock'),
(9, 13, '2025-01-01', 'purchase', 75, 'initial stock'),
(10, 14, '2025-01-01', 'purchase', 35, 'initial stock'),
(11, 15, '2025-01-01', 'purchase', 45, 'initial stock'),
(12, 1, '2025-01-06', 'sale', -1, 'order 1'),
(13, 2, '2025-01-14', 'sale', -2, 'order 2'),
(14, 3, '2025-01-20', 'sale', -2, 'order 3'),
(15, 2, '2025-01-25', 'sale', -4, 'order 4'),
(16, 14, '2025-02-04', 'sale', -1, 'order 6'),
(17, 1, '2025-02-16', 'sale', -5, 'order 7'),
(18, 15, '2025-02-22', 'sale', -1, 'order 9'),
(19, 3, '2025-03-04', 'sale', -1, 'order 11'),
(20, 14, '2025-03-16', 'return', 1, 'order 12 refund'),
(21, 2, '2025-03-22', 'sale', -6, 'order 13'),
(22, 1, '2025-03-28', 'sale', -8, 'order 14'),
(23, 15, '2025-04-05', 'sale', -1, 'order 16'),
(24, 1, '2025-04-23', 'sale', -2, 'order 19'),
(25, 2, '2025-04-25', 'sale', -2, 'order 20'),
(26, 2, '2025-05-01', 'purchase', 30, 'supplier restock'),
(27, 1, '2025-05-01', 'purchase', 25, 'supplier restock'),
(28, 14, '2025-05-12', 'sale', -1, 'order 23'),
(29, 2, '2025-05-15', 'sale', -3, 'order 24'),
(30, 1, '2025-05-25', 'return', 1, 'order 25 refund'),
(31, 2, '2025-05-26', 'sale', -2, 'order 26'),
(32, 1, '2025-06-07', 'sale', -6, 'order 29'),
(33, 14, '2025-06-12', 'sale', -2, 'order 31'),
(34, 2, '2025-06-24', 'sale', -1, 'order 37'),
(35, 2, '2025-06-28', 'sale', -5, 'order 40');

CREATE VIEW order_revenue AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.channel,
    round(sum(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS gross_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.customer_id, o.order_date, o.status, o.channel;

ANALYZE;

-- Relational Databases & SQL - soluzioni SQL generate
-- Le soluzioni SQL partono dal blocco 4: i blocchi 1-3 sono modellazione.

-- ============================================================
-- Blocco 4 - Prime query SQL
-- ============================================================

SET search_path TO training;

SELECT product_id, sku, product_name, unit_price
FROM products
WHERE active
ORDER BY unit_price DESC, product_id;

SELECT customer_id, full_name, country, signup_date
FROM customers
WHERE signup_date >= DATE '2025-02-01'
ORDER BY signup_date, customer_id;


SELECT order_id, customer_id, order_date, status, channel
FROM orders
WHERE status IN ('pending', 'cancelled', 'refunded')
ORDER BY order_date, order_id;

SELECT order_id, product_id,
       round(quantity * unit_price * (1 - discount_pct / 100.0), 2) AS net_amount
FROM order_items
ORDER BY order_id, product_id;

SELECT shipment_id, order_id, shipped_at, delivered_at
FROM shipments
WHERE delivered_at IS NULL
ORDER BY shipped_at, shipment_id;

-- ============================================================
-- Blocco 5 - JOIN e cardinalita
-- ============================================================

SET search_path TO training;

SELECT o.order_id, o.order_date, c.full_name, c.country, o.status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_date, o.order_id;

SELECT o.order_id, c.full_name, p.sku, p.product_name,
       oi.quantity,
       round(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0), 2) AS net_amount
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN products p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.sku;


SELECT o.order_id, c.full_name, o.order_date, o.status,
       s.shipment_id, s.shipped_at, s.delivered_at
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN shipments s ON s.order_id = o.order_id
WHERE s.shipment_id IS NULL
ORDER BY o.order_date, o.order_id;

SELECT o.order_id, count(oi.product_id) AS line_rows
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id
ORDER BY line_rows DESC, o.order_id;

-- ============================================================
-- Blocco 6 - Aggregazioni e KPI
-- ============================================================

SET search_path TO training;

SELECT date_trunc('month', order_date)::date AS month,
       channel,
       round(sum(gross_revenue), 2) AS revenue
FROM order_revenue
WHERE status NOT IN ('cancelled', 'refunded')
GROUP BY month, channel
ORDER BY month, channel;

SELECT c.country,
       count(DISTINCT r.order_id) AS orders,
       round(sum(r.gross_revenue), 2) AS revenue
FROM order_revenue r
JOIN customers c ON c.customer_id = r.customer_id
WHERE r.status NOT IN ('cancelled', 'refunded')
GROUP BY c.country
ORDER BY revenue DESC;


SELECT c.segment,
       count(*) AS valid_orders,
       round(sum(r.gross_revenue), 2) AS revenue,
       round(avg(r.gross_revenue), 2) AS avg_order_value
FROM order_revenue r
JOIN customers c ON c.customer_id = r.customer_id
WHERE r.status NOT IN ('cancelled', 'refunded')
GROUP BY c.segment
HAVING count(*) >= 2
ORDER BY revenue DESC;

SELECT channel,
       count(*) FILTER (WHERE status = 'completed') AS completed_orders,
       count(*) FILTER (WHERE status = 'shipped') AS shipped_orders,
       count(*) FILTER (WHERE status = 'pending') AS pending_orders
FROM orders
GROUP BY channel
ORDER BY channel;

-- ============================================================
-- Blocco 7 - DDL, DML e transazioni
-- ============================================================

SET search_path TO training;

BEGIN;

SELECT product_id, sku, unit_price
FROM products
WHERE category = 'accessories' AND active
ORDER BY product_id;

CREATE TABLE IF NOT EXISTS product_price_audit (
    audit_id bigserial PRIMARY KEY,
    product_id integer NOT NULL REFERENCES products(product_id),
    old_price numeric(10,2) NOT NULL,
    new_price numeric(10,2) NOT NULL,
    reason text NOT NULL,
    changed_at timestamp NOT NULL DEFAULT now()
);


WITH candidates AS (
    SELECT product_id, unit_price AS old_price,
           round(unit_price * 1.05, 2) AS new_price
    FROM products
    WHERE category = 'accessories' AND active
), changed AS (
    UPDATE products p
    SET unit_price = c.new_price
    FROM candidates c
    WHERE c.product_id = p.product_id
    RETURNING p.product_id, c.old_price, p.unit_price AS new_price
)
INSERT INTO product_price_audit(product_id, old_price, new_price, reason)
SELECT product_id, old_price, new_price, 'annual price review'
FROM changed;

SELECT * FROM product_price_audit ORDER BY audit_id DESC;

ROLLBACK;

-- ============================================================
-- Blocco 8 - Subquery e logica insiemistica
-- ============================================================

SET search_path TO training;

SELECT c.customer_id, c.full_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM order_revenue r
    WHERE r.customer_id = c.customer_id
      AND r.status NOT IN ('cancelled', 'refunded')
      AND r.gross_revenue > (
          SELECT avg(gross_revenue)
          FROM order_revenue
          WHERE status NOT IN ('cancelled', 'refunded')
      )
)
ORDER BY c.full_name;


SELECT p.product_id, p.sku, p.product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
)
ORDER BY p.sku;

SELECT customer_id
FROM customers
EXCEPT
SELECT DISTINCT customer_id
FROM support_tickets
ORDER BY customer_id;

-- ============================================================
-- Blocchi 9-12 - Architettura ticketing, dashboard e performance
-- ============================================================

-- I blocchi 9-12 usano uno schema dedicato al caso architetturale ticketing.
-- Eseguire in sequenza:
--   sql/ticket_architecture_schema.sql
--   sql/ticket_architecture_dashboard_queries.sql
-- e poi le solution.sql dei blocchi 9-12.

SELECT 'Blocchi 9-12: usare gli script ticket_architecture_* dedicati' AS note;
