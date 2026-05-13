-- Relational Databases & SQL - architettura ticketing per dashboard
-- Target: PostgreSQL 13+
-- Uso: psql -U training -d training -f sql/ticket_architecture_schema.sql

DROP SCHEMA IF EXISTS ticketing CASCADE;
CREATE SCHEMA ticketing;
SET search_path TO ticketing;

CREATE TABLE ticket_sources (
    source_id smallserial PRIMARY KEY,
    source_code text NOT NULL UNIQUE,
    description text NOT NULL
);

CREATE TABLE support_tickets_raw (
    raw_id bigserial PRIMARY KEY,
    source_id smallint NOT NULL REFERENCES ticket_sources(source_id),
    received_at timestamp NOT NULL DEFAULT now(),
    external_ticket_id text NOT NULL,
    payload jsonb NOT NULL,
    UNIQUE (source_id, external_ticket_id)
);

CREATE TABLE support_tickets (
    ticket_id bigserial PRIMARY KEY,
    source_id smallint NOT NULL REFERENCES ticket_sources(source_id),
    external_ticket_id text NOT NULL,
    opened_at timestamp NOT NULL,
    closed_at timestamp,
    status text NOT NULL CHECK (status IN ('open', 'assigned', 'waiting_customer', 'resolved', 'closed')),
    priority text NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    category text NOT NULL CHECK (category IN ('billing', 'outage', 'installation', 'data_quality', 'contract', 'portal')),
    region text NOT NULL CHECK (region IN ('north', 'center', 'south', 'islands', 'international')),
    customer_segment text NOT NULL CHECK (customer_segment IN ('residential', 'sme', 'enterprise', 'public_sector')),
    channel text NOT NULL CHECK (channel IN ('email', 'web', 'phone', 'field_app', 'api')),
    subject text NOT NULL,
    sla_due_at timestamp NOT NULL,
    inserted_at timestamp NOT NULL DEFAULT now(),
    UNIQUE (source_id, external_ticket_id),
    CHECK (closed_at IS NULL OR closed_at >= opened_at),
    CHECK (sla_due_at >= opened_at)
);

CREATE TABLE support_ticket_events (
    event_id bigserial PRIMARY KEY,
    ticket_id bigint NOT NULL REFERENCES support_tickets(ticket_id) ON DELETE CASCADE,
    event_at timestamp NOT NULL,
    event_type text NOT NULL CHECK (event_type IN ('created', 'assigned', 'comment', 'status_change', 'resolved', 'closed')),
    actor text NOT NULL,
    payload jsonb NOT NULL DEFAULT '{}'::jsonb
);

INSERT INTO ticket_sources (source_code, description) VALUES
('zendesk', 'Ticket importati dal portale customer care'),
('field_app', 'Segnalazioni aperte da tecnici sul campo'),
('api_partner', 'Ticket ricevuti da sistemi partner via API');

INSERT INTO support_tickets (source_id, external_ticket_id, opened_at, closed_at, status, priority, category, region, customer_segment, channel, subject, sla_due_at) VALUES
(1, 'ZD-1001', '2026-05-01 08:10', '2026-05-01 11:40', 'closed', 'medium', 'billing', 'north', 'residential', 'web', 'Bill amount not clear', '2026-05-02 08:10'),
(1, 'ZD-1002', '2026-05-01 09:20', '2026-05-03 16:10', 'closed', 'high', 'outage', 'center', 'sme', 'phone', 'Power outage in office', '2026-05-02 09:20'),
(2, 'FA-2001', '2026-05-01 14:05', '2026-05-02 12:25', 'closed', 'high', 'installation', 'south', 'enterprise', 'field_app', 'Meter installation blocked', '2026-05-03 14:05'),
(3, 'AP-3001', '2026-05-02 10:30', NULL, 'assigned', 'urgent', 'data_quality', 'international', 'enterprise', 'api', 'Partner readings inconsistent', '2026-05-02 18:30'),
(1, 'ZD-1003', '2026-05-02 13:15', '2026-05-02 16:30', 'resolved', 'low', 'portal', 'islands', 'residential', 'web', 'Portal password reset', '2026-05-04 13:15'),
(1, 'ZD-1004', '2026-05-03 08:45', NULL, 'waiting_customer', 'medium', 'contract', 'north', 'sme', 'email', 'Contract change clarification', '2026-05-06 08:45'),
(2, 'FA-2002', '2026-05-03 11:50', '2026-05-03 18:15', 'closed', 'urgent', 'outage', 'center', 'public_sector', 'field_app', 'Hospital feeder alert', '2026-05-03 19:50'),
(1, 'ZD-1005', '2026-05-04 09:10', '2026-05-05 10:00', 'closed', 'medium', 'billing', 'south', 'residential', 'phone', 'Duplicate payment', '2026-05-06 09:10'),
(3, 'AP-3002', '2026-05-04 15:25', NULL, 'open', 'high', 'data_quality', 'international', 'enterprise', 'api', 'Missing telemetry batch', '2026-05-05 15:25'),
(1, 'ZD-1006', '2026-05-05 08:35', '2026-05-05 09:40', 'closed', 'low', 'portal', 'center', 'residential', 'web', 'Download invoice', '2026-05-07 08:35'),
(2, 'FA-2003', '2026-05-05 12:10', '2026-05-07 17:00', 'resolved', 'high', 'installation', 'north', 'enterprise', 'field_app', 'Transformer access issue', '2026-05-07 12:10'),
(1, 'ZD-1007', '2026-05-06 10:05', NULL, 'assigned', 'medium', 'contract', 'south', 'sme', 'email', 'Tariff plan question', '2026-05-09 10:05'),
(3, 'AP-3003', '2026-05-06 16:45', '2026-05-07 08:20', 'closed', 'urgent', 'outage', 'international', 'enterprise', 'api', 'Critical site unavailable', '2026-05-07 00:45'),
(1, 'ZD-1008', '2026-05-07 09:30', '2026-05-07 12:05', 'closed', 'low', 'billing', 'islands', 'residential', 'web', 'Billing address update', '2026-05-09 09:30'),
(2, 'FA-2004', '2026-05-07 13:10', NULL, 'open', 'urgent', 'outage', 'south', 'public_sector', 'field_app', 'Water plant supply alert', '2026-05-07 21:10'),
(1, 'ZD-1009', '2026-05-08 08:25', '2026-05-10 14:55', 'closed', 'medium', 'installation', 'center', 'sme', 'phone', 'Installation appointment moved', '2026-05-11 08:25'),
(3, 'AP-3004', '2026-05-08 17:40', NULL, 'assigned', 'high', 'data_quality', 'international', 'enterprise', 'api', 'Negative consumption anomaly', '2026-05-09 17:40'),
(1, 'ZD-1010', '2026-05-09 09:15', '2026-05-09 15:15', 'resolved', 'medium', 'portal', 'north', 'residential', 'web', 'Self service error', '2026-05-12 09:15'),
(2, 'FA-2005', '2026-05-09 11:30', '2026-05-09 18:30', 'closed', 'high', 'outage', 'center', 'enterprise', 'field_app', 'Industrial district outage', '2026-05-10 11:30'),
(1, 'ZD-1011', '2026-05-10 10:10', NULL, 'open', 'low', 'billing', 'south', 'residential', 'email', 'Payment receipt request', '2026-05-13 10:10'),
(3, 'AP-3005', '2026-05-10 18:20', NULL, 'assigned', 'urgent', 'data_quality', 'international', 'enterprise', 'api', 'Late metering file', '2026-05-11 02:20'),
(1, 'ZD-1012', '2026-05-11 08:55', '2026-05-11 17:20', 'closed', 'medium', 'contract', 'north', 'sme', 'phone', 'Contract holder update', '2026-05-14 08:55'),
(2, 'FA-2006', '2026-05-11 14:35', NULL, 'waiting_customer', 'high', 'installation', 'islands', 'public_sector', 'field_app', 'Permit missing for installation', '2026-05-13 14:35'),
(1, 'ZD-1013', '2026-05-12 09:40', NULL, 'open', 'medium', 'portal', 'center', 'residential', 'web', 'Customer area unavailable', '2026-05-15 09:40'),
(3, 'AP-3006', '2026-05-12 15:15', NULL, 'assigned', 'high', 'data_quality', 'international', 'enterprise', 'api', 'Duplicated readings', '2026-05-13 15:15'),
(2, 'FA-2007', '2026-05-13 07:50', NULL, 'open', 'urgent', 'outage', 'south', 'public_sector', 'field_app', 'Municipality outage escalation', '2026-05-13 15:50');

INSERT INTO support_tickets_raw (source_id, received_at, external_ticket_id, payload)
SELECT source_id,
       inserted_at,
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
           'subject', subject
       )
FROM support_tickets;

INSERT INTO support_ticket_events (ticket_id, event_at, event_type, actor, payload)
SELECT ticket_id, opened_at, 'created', 'collector', jsonb_build_object('status', status)
FROM support_tickets;

INSERT INTO support_ticket_events (ticket_id, event_at, event_type, actor, payload)
SELECT ticket_id, opened_at + interval '45 minutes', 'assigned', 'dispatcher', jsonb_build_object('priority', priority)
FROM support_tickets
WHERE priority IN ('high', 'urgent');

INSERT INTO support_ticket_events (ticket_id, event_at, event_type, actor, payload)
SELECT ticket_id, closed_at, CASE WHEN status = 'closed' THEN 'closed' ELSE 'resolved' END, 'support_agent', jsonb_build_object('status', status)
FROM support_tickets
WHERE closed_at IS NOT NULL;

CREATE OR REPLACE VIEW dashboard_ticket_base AS
SELECT t.ticket_id,
       s.source_code,
       t.external_ticket_id,
       t.opened_at,
       t.closed_at,
       t.status,
       t.priority,
       t.category,
       t.region,
       t.customer_segment,
       t.channel,
       t.subject,
       t.sla_due_at,
       round(EXTRACT(EPOCH FROM (t.closed_at - t.opened_at)) / 3600.0, 2) AS resolution_hours,
       (COALESCE(t.closed_at, TIMESTAMP '2026-05-13 09:00:00') > t.sla_due_at) AS sla_breached
FROM support_tickets t
JOIN ticket_sources s ON s.source_id = t.source_id;

CREATE OR REPLACE VIEW dashboard_daily_flow AS
WITH days AS (
    SELECT generate_series(DATE '2026-05-01', DATE '2026-05-13', interval '1 day')::date AS day
), opened AS (
    SELECT opened_at::date AS day, count(*) AS opened_tickets
    FROM support_tickets
    GROUP BY opened_at::date
), resolved AS (
    SELECT closed_at::date AS day, count(*) AS resolved_tickets
    FROM support_tickets
    WHERE closed_at IS NOT NULL
    GROUP BY closed_at::date
)
SELECT d.day,
       COALESCE(o.opened_tickets, 0) AS opened_tickets,
       COALESCE(r.resolved_tickets, 0) AS resolved_tickets,
       sum(COALESCE(o.opened_tickets, 0) - COALESCE(r.resolved_tickets, 0))
           OVER (ORDER BY d.day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS backlog_delta
FROM days d
LEFT JOIN opened o ON o.day = d.day
LEFT JOIN resolved r ON r.day = d.day
ORDER BY d.day;

CREATE OR REPLACE VIEW dashboard_priority_status AS
SELECT priority,
       status,
       count(*) AS tickets,
       count(*) FILTER (WHERE sla_breached) AS sla_breached_tickets
FROM dashboard_ticket_base
GROUP BY priority, status;

ANALYZE support_tickets;
ANALYZE support_ticket_events;
ANALYZE support_tickets_raw;
