-- Genera un carico storico per il caso ticketing.
-- Uso consigliato:
--   docker exec -i rdsql-ticket-postgres psql -U training -d training -v load_size=80000 -f /sql/ticket_load_generate.sql
--
-- Parametri opzionali:
--   load_size: numero di ticket sintetici da generare, default 60000
--   day_span: numero di giorni su cui distribuire gli eventi, default 150

\set ON_ERROR_STOP on

\if :{?load_size}
\else
\set load_size 60000
\endif

\if :{?day_span}
\else
\set day_span 150
\endif

SET search_path TO ticketing;

SELECT format(
    'Rigenero %s ticket sintetici distribuiti su %s giorni',
    :'load_size',
    :'day_span'
) AS load_plan;

DELETE FROM support_tickets
WHERE external_ticket_id LIKE 'SIMLOAD-%';

DELETE FROM support_tickets_raw
WHERE external_ticket_id LIKE 'SIMLOAD-%';

WITH params AS (
    SELECT :'load_size'::int AS load_size,
           :'day_span'::int AS day_span
), base AS (
    SELECT g AS seq,
           ((g % 3) + 1)::smallint AS source_id,
           format('SIMLOAD-%s', lpad(g::text, 8, '0')) AS external_ticket_id,
           TIMESTAMP '2026-01-01 00:00:00'
             + ((g % p.day_span) * interval '1 day')
             + (((g * 37) % 86400) * interval '1 second') AS opened_at,
           (ARRAY['low', 'medium', 'high', 'urgent'])[1 + (g % 4)] AS priority,
           (ARRAY['billing', 'outage', 'installation', 'data_quality', 'contract', 'portal'])[1 + (g % 6)] AS category,
           (ARRAY['north', 'center', 'south', 'islands', 'international'])[1 + (g % 5)] AS region,
           (ARRAY['residential', 'sme', 'enterprise', 'public_sector'])[1 + (g % 4)] AS customer_segment,
           (ARRAY['email', 'web', 'phone', 'field_app', 'api'])[1 + (g % 5)] AS channel
    FROM params p
    CROSS JOIN generate_series(1, p.load_size) AS g
), classified AS (
    SELECT *,
           CASE
               WHEN seq % 10 IN (0, 1) THEN 'open'
               WHEN seq % 10 IN (2, 3) THEN 'assigned'
               WHEN seq % 10 = 4 THEN 'waiting_customer'
               WHEN seq % 10 IN (5, 6, 7) THEN 'resolved'
               ELSE 'closed'
           END AS status
    FROM base
), generated AS (
    SELECT *,
           CASE priority
               WHEN 'urgent' THEN opened_at + interval '8 hours'
               WHEN 'high' THEN opened_at + interval '24 hours'
               WHEN 'medium' THEN opened_at + interval '72 hours'
               ELSE opened_at + interval '120 hours'
           END AS sla_due_at,
           CASE
               WHEN status IN ('resolved', 'closed')
                   THEN opened_at + (((seq * 17) % 96) + 1) * interval '1 hour'
               ELSE NULL::timestamp
           END AS closed_at
    FROM classified
), raw_insert AS (
    INSERT INTO support_tickets_raw (source_id, received_at, external_ticket_id, payload)
    SELECT source_id,
           opened_at + interval '1 minute',
           external_ticket_id,
           jsonb_build_object(
               'external_ticket_id', external_ticket_id,
               'opened_at', opened_at,
               'status', status,
               'priority', priority,
               'category', category,
               'region', region,
               'segment', customer_segment,
               'channel', channel,
               'subject', 'Synthetic ticket for index trade-off laboratory',
               'generator_seq', seq
           )
    FROM generated
    RETURNING external_ticket_id
), ticket_insert AS (
    INSERT INTO support_tickets (
        source_id, external_ticket_id, opened_at, closed_at, status,
        priority, category, region, customer_segment, channel, subject, sla_due_at
    )
    SELECT source_id,
           external_ticket_id,
           opened_at,
           closed_at,
           status,
           priority,
           category,
           region,
           customer_segment,
           channel,
           'Synthetic ticket for index trade-off laboratory',
           sla_due_at
    FROM generated
    RETURNING ticket_id, external_ticket_id, opened_at, closed_at, status, priority
)
INSERT INTO support_ticket_events (ticket_id, event_at, event_type, actor, payload)
SELECT ticket_id,
       opened_at,
       'created',
       'load-generator',
       jsonb_build_object('status', status, 'priority', priority)
FROM ticket_insert
UNION ALL
SELECT ticket_id,
       opened_at + interval '20 minutes',
       'assigned',
       'dispatcher',
       jsonb_build_object('priority', priority)
FROM ticket_insert
WHERE priority IN ('high', 'urgent') OR status <> 'open'
UNION ALL
SELECT ticket_id,
       opened_at + interval '1 hour',
       'comment',
       'support_agent',
       jsonb_build_object('note', 'Synthetic follow-up event')
FROM ticket_insert
WHERE ticket_id % 3 = 0
UNION ALL
SELECT ticket_id,
       opened_at + interval '2 hours',
       'status_change',
       'support_agent',
       jsonb_build_object('status', status)
FROM ticket_insert
WHERE status IN ('assigned', 'waiting_customer', 'resolved', 'closed')
UNION ALL
SELECT ticket_id,
       closed_at,
       CASE WHEN status = 'closed' THEN 'closed' ELSE 'resolved' END,
       'support_agent',
       jsonb_build_object('status', status)
FROM ticket_insert
WHERE closed_at IS NOT NULL;

ANALYZE support_tickets;
ANALYZE support_tickets_raw;
ANALYZE support_ticket_events;

SELECT count(*) AS generated_tickets
FROM support_tickets
WHERE external_ticket_id LIKE 'SIMLOAD-%';

SELECT count(*) AS generated_events
FROM support_ticket_events e
JOIN support_tickets t ON t.ticket_id = e.ticket_id
WHERE t.external_ticket_id LIKE 'SIMLOAD-%';

SELECT count(*) AS total_tickets
FROM support_tickets;

SELECT count(*) AS total_events
FROM support_ticket_events;
