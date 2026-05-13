# Soluzione - Blocco 9 - Architettura dati containerizzata

La soluzione carica lo schema `ticketing`, verifica raw event e ticket curati, poi interroga le viste che faranno da contratto per Metabase.

Caricare prima lo schema nello stack ticketing:

```bash
docker exec rdsql-ticket-postgres psql -U training -d training -v ON_ERROR_STOP=1 -f /sql/ticket_architecture_schema.sql
```

```sql
SET search_path TO ticketing;

SELECT source_id, source_code, description
FROM ticket_sources
ORDER BY source_id;

SELECT count(*) AS raw_events
FROM support_tickets_raw;

SELECT count(*) AS curated_tickets
FROM support_tickets;

SELECT ticket_id, source_code, external_ticket_id,
       opened_at, priority, category, region, status, sla_breached
FROM dashboard_ticket_base
ORDER BY opened_at
LIMIT 10;

SELECT day, opened_tickets, resolved_tickets, backlog_delta
FROM dashboard_daily_flow
ORDER BY day;
```

## Perché è corretta
- distingue raw data e dato curato;
- usa viste con granularità chiara;
- prepara il semantic layer per Metabase;
- include controlli minimi di completezza.
