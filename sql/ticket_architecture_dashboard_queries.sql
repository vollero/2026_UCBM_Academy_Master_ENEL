-- Query per dashboard Metabase sullo schema ticketing.
-- Prerequisito: eseguire prima sql/ticket_architecture_schema.sql

SET search_path TO ticketing;

-- 1. KPI sintetici: aperti, chiusi, ancora aperti, violazioni SLA.
SELECT count(*) AS total_tickets,
       count(*) FILTER (WHERE closed_at IS NULL) AS open_tickets,
       count(*) FILTER (WHERE closed_at IS NOT NULL) AS closed_tickets,
       count(*) FILTER (WHERE sla_breached) AS sla_breached_tickets
FROM dashboard_ticket_base;

-- 2. Serie giornaliera: ticket aperti, risolti e backlog incrementale.
SELECT day, opened_tickets, resolved_tickets, backlog_delta
FROM dashboard_daily_flow
ORDER BY day;

-- 3. Distribuzione per priorità e stato.
SELECT priority, status, tickets, sla_breached_tickets
FROM dashboard_priority_status
ORDER BY priority, status;

-- 4. Tempo medio di risoluzione per priorità e regione.
SELECT priority,
       region,
       count(*) FILTER (WHERE closed_at IS NOT NULL) AS resolved_tickets,
       round(avg(resolution_hours), 2) AS avg_resolution_hours
FROM dashboard_ticket_base
WHERE closed_at IS NOT NULL
GROUP BY priority, region
ORDER BY priority, avg_resolution_hours DESC NULLS LAST;

-- 5. Ranking categorie per numero di ticket.
SELECT category,
       count(*) AS tickets,
       rank() OVER (ORDER BY count(*) DESC, category) AS category_rank
FROM dashboard_ticket_base
GROUP BY category
ORDER BY category_rank, category;

-- 6. Trend con media mobile a 3 giorni.
SELECT day,
       opened_tickets,
       round(avg(opened_tickets) OVER (
           ORDER BY day ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 2) AS opened_3d_avg
FROM dashboard_daily_flow
ORDER BY day;

-- 7. Ticket aperti da usare come tabella di dettaglio.
SELECT ticket_id,
       source_code,
       external_ticket_id,
       opened_at,
       priority,
       category,
       region,
       customer_segment,
       channel,
       subject,
       sla_due_at,
       sla_breached
FROM dashboard_ticket_base
WHERE closed_at IS NULL
ORDER BY priority DESC, opened_at;

-- 8. Qualità della pipeline: raw vs curated.
SELECT (SELECT count(*) FROM support_tickets_raw) AS raw_events,
       (SELECT count(*) FROM support_tickets) AS curated_tickets,
       (SELECT count(*) FROM support_tickets_raw r
        LEFT JOIN support_tickets t
          ON t.external_ticket_id = r.external_ticket_id
        WHERE t.ticket_id IS NULL) AS raw_without_curated_ticket;
