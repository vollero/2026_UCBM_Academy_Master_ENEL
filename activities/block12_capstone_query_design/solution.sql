-- Blocco 12 - Capstone architettura DBMS e dashboard
-- Query principali da usare dopo l'avvio dello stack docker-compose.ticketing.yml

SET search_path TO ticketing;

SELECT count(*) AS tickets
FROM support_tickets;

SELECT count(*) AS raw_events
FROM support_tickets_raw;

SELECT count(*) AS total_tickets,
       count(*) FILTER (WHERE closed_at IS NULL) AS open_tickets,
       count(*) FILTER (WHERE closed_at IS NOT NULL) AS closed_tickets,
       count(*) FILTER (WHERE sla_breached) AS sla_breached_tickets
FROM dashboard_ticket_base;

SELECT day, opened_tickets, resolved_tickets, backlog_delta
FROM dashboard_daily_flow
ORDER BY day;

SELECT category,
       count(*) AS tickets,
       rank() OVER (ORDER BY count(*) DESC, category) AS category_rank
FROM dashboard_ticket_base
GROUP BY category
ORDER BY category_rank, category;

SELECT ticket_id, source_code, external_ticket_id,
       opened_at, priority, category, region,
       customer_segment, channel, subject,
       sla_due_at, sla_breached
FROM dashboard_ticket_base
WHERE closed_at IS NULL
ORDER BY priority DESC, opened_at;

SELECT (SELECT count(*) FROM support_tickets_raw) AS raw_events,
       (SELECT count(*) FROM support_tickets) AS curated_tickets,
       (SELECT count(*)
        FROM support_tickets_raw r
        LEFT JOIN support_tickets t
          ON t.external_ticket_id = r.external_ticket_id
        WHERE t.ticket_id IS NULL) AS raw_without_curated_ticket;

-- Esperimento indici: query target per il piano prima/dopo.
-- Per rendere il beneficio visibile, caricare prima:
--   psql -U training -d training -v load_size=80000 -f /sql/ticket_load_generate.sql

EXPLAIN (ANALYZE, BUFFERS)
SELECT ticket_id, opened_at, priority, region, status
FROM support_tickets
WHERE status IN ('open', 'assigned', 'waiting_customer')
  AND opened_at >= TIMESTAMP '2026-03-01'
ORDER BY opened_at DESC, ticket_id DESC
LIMIT 50;

CREATE INDEX IF NOT EXISTS idx_support_tickets_open_dashboard
ON support_tickets (opened_at DESC, ticket_id DESC)
INCLUDE (priority, region, status, category, sla_due_at)
WHERE status IN ('open', 'assigned', 'waiting_customer');

CREATE INDEX IF NOT EXISTS idx_support_tickets_region_category_date
ON support_tickets (region, category, opened_at DESC)
INCLUDE (status, priority, closed_at, sla_due_at);

ANALYZE support_tickets;

EXPLAIN (ANALYZE, BUFFERS)
SELECT ticket_id, opened_at, priority, region, status
FROM support_tickets
WHERE status IN ('open', 'assigned', 'waiting_customer')
  AND opened_at >= TIMESTAMP '2026-03-01'
ORDER BY opened_at DESC, ticket_id DESC
LIMIT 50;

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
