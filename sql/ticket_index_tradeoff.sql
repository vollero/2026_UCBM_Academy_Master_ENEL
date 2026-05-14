-- Esperimento guidato sugli indici del caso ticketing.
-- Prerequisiti:
--   1. eseguire sql/ticket_architecture_schema.sql
--   2. eseguire sql/ticket_load_generate.sql con un carico significativo
--
-- Uso consigliato:
--   docker exec -i rdsql-ticket-postgres psql -U training -d training -f /sql/ticket_index_tradeoff.sql
--
-- Parametro opzionale:
--   write_size: righe usate per misurare il costo di scrittura, default 3000

\set ON_ERROR_STOP on

\if :{?write_size}
\else
\set write_size 3000
\endif

SET search_path TO ticketing;

\timing on

DROP INDEX IF EXISTS idx_support_tickets_open_dashboard;
DROP INDEX IF EXISTS idx_support_tickets_region_category_date;

ANALYZE support_tickets;

SELECT count(*) AS tickets,
       count(*) FILTER (WHERE external_ticket_id LIKE 'SIMLOAD-%') AS synthetic_tickets
FROM support_tickets;

SELECT pg_size_pretty(pg_total_relation_size('ticketing.support_tickets')) AS support_tickets_total_size;

-- Query target: drill-down dei ticket ancora aperti.
-- Su pochi dati la differenza è quasi invisibile; con decine di migliaia di righe il piano cambia.
EXPLAIN (ANALYZE, BUFFERS)
SELECT ticket_id, opened_at, priority, region, status
FROM support_tickets
WHERE status IN ('open', 'assigned', 'waiting_customer')
  AND opened_at >= TIMESTAMP '2026-03-01'
ORDER BY opened_at DESC, ticket_id DESC
LIMIT 50;

-- Costo di scrittura prima degli indici aggiuntivi.
BEGIN;
EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO support_tickets (
    source_id, external_ticket_id, opened_at, closed_at, status,
    priority, category, region, customer_segment, channel, subject, sla_due_at
)
SELECT 1,
       format('WRITE-NOINDEX-%s', lpad(g::text, 8, '0')),
       TIMESTAMP '2026-06-01 00:00:00' + (g * interval '1 second'),
       NULL,
       (ARRAY['open', 'assigned', 'waiting_customer'])[1 + (g % 3)],
       (ARRAY['low', 'medium', 'high', 'urgent'])[1 + (g % 4)],
       (ARRAY['billing', 'outage', 'installation', 'data_quality', 'contract', 'portal'])[1 + (g % 6)],
       (ARRAY['north', 'center', 'south', 'islands', 'international'])[1 + (g % 5)],
       (ARRAY['residential', 'sme', 'enterprise', 'public_sector'])[1 + (g % 4)],
       (ARRAY['email', 'web', 'phone', 'field_app', 'api'])[1 + (g % 5)],
       'Write benchmark before custom indexes',
       TIMESTAMP '2026-06-01 00:00:00' + (g * interval '1 second') + interval '24 hours'
FROM generate_series(1, :'write_size'::int) AS g;
ROLLBACK;

-- Indice parziale: serve la card di dettaglio dei ticket non chiusi.
-- È più piccolo di un indice globale perché esclude ticket closed/resolved.
CREATE INDEX idx_support_tickets_open_dashboard
ON support_tickets (opened_at DESC, ticket_id DESC)
INCLUDE (priority, region, status, category, sla_due_at)
WHERE status IN ('open', 'assigned', 'waiting_customer');

-- Indice composito: serve dashboard filtrate per area, categoria e periodo.
CREATE INDEX idx_support_tickets_region_category_date
ON support_tickets (region, category, opened_at DESC)
INCLUDE (status, priority, closed_at, sla_due_at);

ANALYZE support_tickets;

SELECT c.relname AS index_name,
       pg_size_pretty(pg_relation_size(c.oid)) AS index_size
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'ticketing'
  AND c.relname IN (
      'idx_support_tickets_open_dashboard',
      'idx_support_tickets_region_category_date'
  )
ORDER BY c.relname;

-- Stessa query dopo gli indici.
EXPLAIN (ANALYZE, BUFFERS)
SELECT ticket_id, opened_at, priority, region, status
FROM support_tickets
WHERE status IN ('open', 'assigned', 'waiting_customer')
  AND opened_at >= TIMESTAMP '2026-03-01'
ORDER BY opened_at DESC, ticket_id DESC
LIMIT 50;

-- Query filtrata: qui l'indice composito può ridurre molte letture inutili.
EXPLAIN (ANALYZE, BUFFERS)
SELECT priority,
       status,
       count(*) AS tickets,
       count(*) FILTER (WHERE COALESCE(closed_at, TIMESTAMP '2026-05-13 09:00:00') > sla_due_at) AS sla_breached
FROM support_tickets
WHERE region = 'north'
  AND category = 'outage'
  AND opened_at >= TIMESTAMP '2026-03-01'
GROUP BY priority, status
ORDER BY priority, status;

-- Costo di scrittura dopo gli indici aggiuntivi.
BEGIN;
EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO support_tickets (
    source_id, external_ticket_id, opened_at, closed_at, status,
    priority, category, region, customer_segment, channel, subject, sla_due_at
)
SELECT 1,
       format('WRITE-WITHINDEX-%s', lpad(g::text, 8, '0')),
       TIMESTAMP '2026-06-01 00:00:00' + (g * interval '1 second'),
       NULL,
       (ARRAY['open', 'assigned', 'waiting_customer'])[1 + (g % 3)],
       (ARRAY['low', 'medium', 'high', 'urgent'])[1 + (g % 4)],
       (ARRAY['billing', 'outage', 'installation', 'data_quality', 'contract', 'portal'])[1 + (g % 6)],
       (ARRAY['north', 'center', 'south', 'islands', 'international'])[1 + (g % 5)],
       (ARRAY['residential', 'sme', 'enterprise', 'public_sector'])[1 + (g % 4)],
       (ARRAY['email', 'web', 'phone', 'field_app', 'api'])[1 + (g % 5)],
       'Write benchmark after custom indexes',
       TIMESTAMP '2026-06-01 00:00:00' + (g * interval '1 second') + interval '24 hours'
FROM generate_series(1, :'write_size'::int) AS g;
ROLLBACK;

SELECT 'Trade-off: letture dashboard più selettive, ma più spazio e più costo per INSERT/UPDATE/DELETE.' AS conclusion;
