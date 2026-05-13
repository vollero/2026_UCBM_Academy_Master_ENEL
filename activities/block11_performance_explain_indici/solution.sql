-- Blocco 11 - Performance di un DBMS per dashboard
-- Prerequisito: caricare prima lo schema ticketing.
-- Con lo stack dedicato:
-- docker exec rdsql-ticket-postgres psql -U training -d training -v ON_ERROR_STOP=1 -f /sql/ticket_architecture_schema.sql

SET search_path TO ticketing;

EXPLAIN (ANALYZE, BUFFERS)
SELECT ticket_id, opened_at, priority, category, region, status
FROM support_tickets
WHERE status IN ('open', 'assigned', 'waiting_customer')
  AND opened_at >= TIMESTAMP '2026-05-01'
  AND opened_at <  TIMESTAMP '2026-05-14'
ORDER BY opened_at DESC, ticket_id DESC;

CREATE INDEX IF NOT EXISTS idx_ticketing_open_dashboard
ON support_tickets (opened_at DESC, ticket_id DESC)
WHERE status IN ('open', 'assigned', 'waiting_customer');

EXPLAIN (ANALYZE, BUFFERS)
SELECT ticket_id, opened_at, priority, category, region, status
FROM support_tickets
WHERE status IN ('open', 'assigned', 'waiting_customer')
  AND opened_at >= TIMESTAMP '2026-05-01'
  AND opened_at <  TIMESTAMP '2026-05-14'
ORDER BY opened_at DESC, ticket_id DESC;

DROP MATERIALIZED VIEW IF EXISTS ticket_daily_metrics;

CREATE MATERIALIZED VIEW ticket_daily_metrics AS
SELECT opened_at::date AS day,
       priority,
       region,
       count(*) AS opened_tickets,
       count(*) FILTER (WHERE closed_at IS NOT NULL) AS closed_tickets,
       count(*) FILTER (WHERE
           COALESCE(closed_at, TIMESTAMP '2026-05-13 09:00:00') > sla_due_at
       ) AS sla_breached_tickets
FROM support_tickets
GROUP BY opened_at::date, priority, region;

CREATE INDEX idx_ticket_daily_metrics_day
ON ticket_daily_metrics(day, priority, region);

SELECT day,
       sum(opened_tickets) AS opened_tickets,
       sum(closed_tickets) AS closed_tickets,
       sum(sla_breached_tickets) AS sla_breached_tickets
FROM ticket_daily_metrics
GROUP BY day
ORDER BY day;

SELECT (SELECT count(*) FROM support_tickets_raw) AS raw_events,
       (SELECT count(*) FROM support_tickets) AS curated_tickets,
       (SELECT count(*)
        FROM support_tickets_raw r
        LEFT JOIN support_tickets t
          ON t.external_ticket_id = r.external_ticket_id
        WHERE t.ticket_id IS NULL) AS raw_without_curated_ticket;

DROP INDEX IF EXISTS idx_ticketing_open_dashboard;
DROP MATERIALIZED VIEW IF EXISTS ticket_daily_metrics;
