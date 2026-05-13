-- Blocco 9 - Architettura dati containerizzata
-- Prerequisito: caricare prima lo schema ticketing.
-- Con lo stack dedicato:
-- docker exec rdsql-ticket-postgres psql -U training -d training -v ON_ERROR_STOP=1 -f /sql/ticket_architecture_schema.sql

SET search_path TO ticketing;

SELECT source_id, source_code, description
FROM ticket_sources
ORDER BY source_id;

SELECT count(*) AS raw_events
FROM support_tickets_raw;

SELECT count(*) AS curated_tickets
FROM support_tickets;

SELECT ticket_id,
       source_code,
       external_ticket_id,
       opened_at,
       priority,
       category,
       region,
       status,
       sla_breached
FROM dashboard_ticket_base
ORDER BY opened_at
LIMIT 10;

SELECT day, opened_tickets, resolved_tickets, backlog_delta
FROM dashboard_daily_flow
ORDER BY day;

SELECT (SELECT count(*) FROM support_tickets_raw) AS raw_events,
       (SELECT count(*) FROM support_tickets) AS curated_tickets,
       (SELECT count(*)
        FROM support_tickets_raw r
        LEFT JOIN support_tickets t
          ON t.external_ticket_id = r.external_ticket_id
        WHERE t.ticket_id IS NULL) AS raw_without_curated_ticket;
