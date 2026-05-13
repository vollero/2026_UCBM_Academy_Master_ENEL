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
