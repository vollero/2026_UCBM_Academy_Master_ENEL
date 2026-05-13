# Blocco 12 - Capstone architettura DBMS e dashboard

## 1. Problema in forma informale
Bisogna consegnare un piccolo sistema dati replicabile: container PostgreSQL, collector simulato, schema ticketing, query SQL e dashboard Metabase.

## 2. Specifica corretta del problema
- input: `docker-compose.ticketing.yml`, script SQL ticketing e Metabase;
- output: stack avviato, database popolato, dashboard con query SQL, controlli;
- vincolo: la dashboard deve usare PostgreSQL come sorgente;
- vincolo: le query devono essere versionate nei file `.sql`;
- vincolo: la presentazione deve spiegare architettura, metriche e limiti.

## 3. Definizione della soluzione
1. avviare lo stack Compose;
2. verificare PostgreSQL e collector;
3. collegare Metabase a PostgreSQL;
4. creare le card a partire dalle query SQL;
5. costruire la dashboard;
6. eseguire controlli dati e performance.

## 4. Implementazione completa
```bash
docker compose -f docker-compose.ticketing.yml up -d
docker compose -f docker-compose.ticketing.yml ps
docker logs -f rdsql-ticket-collector
```

Dentro PostgreSQL:

```sql
SET search_path TO ticketing;

SELECT count(*) AS tickets
FROM support_tickets;

SELECT count(*) AS raw_events
FROM support_tickets_raw;

SELECT day, opened_tickets, resolved_tickets, backlog_delta
FROM dashboard_daily_flow
ORDER BY day;
```

Query da copiare in Metabase:

```sql
SELECT count(*) AS total_tickets,
       count(*) FILTER (WHERE closed_at IS NULL) AS open_tickets,
       count(*) FILTER (WHERE closed_at IS NOT NULL) AS closed_tickets,
       count(*) FILTER (WHERE sla_breached) AS sla_breached_tickets
FROM ticketing.dashboard_ticket_base;
```

## 5. Criteri di verifica
- i tre container sono avviati;
- Metabase si collega al database `training`;
- il collector aggiunge nuove righe;
- la dashboard contiene KPI, trend, ranking e dettaglio;
- la soluzione dichiara limiti e trade-off.
