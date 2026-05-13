-- Inserisce un ticket simulato. Pensato per il servizio ticket-collector.
-- Eseguibile più volte: ogni run genera un external_ticket_id nuovo.

SET search_path TO ticketing;

WITH generated AS (
    SELECT 1::smallint AS source_id,
           'SIM-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISSMS') AS external_ticket_id,
           clock_timestamp() AS opened_at,
           (ARRAY['open', 'assigned', 'waiting_customer'])[1 + floor(random() * 3)::int] AS status,
           (ARRAY['low', 'medium', 'high', 'urgent'])[1 + floor(random() * 4)::int] AS priority,
           (ARRAY['billing', 'outage', 'installation', 'data_quality', 'contract', 'portal'])[1 + floor(random() * 6)::int] AS category,
           (ARRAY['north', 'center', 'south', 'islands', 'international'])[1 + floor(random() * 5)::int] AS region,
           (ARRAY['residential', 'sme', 'enterprise', 'public_sector'])[1 + floor(random() * 4)::int] AS customer_segment,
           (ARRAY['email', 'web', 'phone', 'field_app', 'api'])[1 + floor(random() * 5)::int] AS channel
), raw_insert AS (
    INSERT INTO support_tickets_raw (source_id, external_ticket_id, payload)
    SELECT source_id,
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
               'subject', 'Simulated ticket from collector'
           )
    FROM generated
    RETURNING source_id, external_ticket_id, payload
), curated_insert AS (
    INSERT INTO support_tickets (
        source_id, external_ticket_id, opened_at, closed_at, status,
        priority, category, region, customer_segment, channel, subject, sla_due_at
    )
    SELECT source_id,
           external_ticket_id,
           (payload->>'opened_at')::timestamp,
           NULL,
           payload->>'status',
           payload->>'priority',
           payload->>'category',
           payload->>'region',
           payload->>'segment',
           payload->>'channel',
           payload->>'subject',
           (payload->>'opened_at')::timestamp + interval '24 hours'
    FROM raw_insert
    RETURNING ticket_id, opened_at, status, priority
)
INSERT INTO support_ticket_events (ticket_id, event_at, event_type, actor, payload)
SELECT ticket_id,
       opened_at,
       'created',
       'ticket-collector',
       jsonb_build_object('status', status, 'priority', priority)
FROM curated_insert;
