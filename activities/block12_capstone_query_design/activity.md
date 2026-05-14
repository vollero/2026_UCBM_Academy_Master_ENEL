# Blocco 12 - Capstone architettura DBMS e dashboard

## 1. Problema in forma informale
Bisogna consegnare un piccolo sistema dati replicabile: container PostgreSQL, collector simulato, schema ticketing, query SQL, dashboard Metabase e una discussione esplicita sui trade-off degli indici.

## 2. Specifica corretta del problema
- input: `docker-compose.ticketing.yml`, script SQL ticketing e Metabase;
- output: stack avviato, database popolato, dashboard con query SQL, controlli;
- vincolo: la dashboard deve usare PostgreSQL come sorgente;
- vincolo: le query devono essere versionate nei file `.sql`;
- vincolo: il sistema deve permettere di aumentare il volume dei ticket;
- vincolo: la presentazione deve spiegare architettura, metriche, limiti e trade-off degli indici.

## 3. Definizione della soluzione
1. avviare lo stack Compose;
2. verificare PostgreSQL e collector;
3. collegare Metabase a PostgreSQL;
4. creare le card a partire dalle query SQL;
5. costruire la dashboard;
6. generare un carico storico di ticket ed eventi;
7. confrontare query prima e dopo gli indici;
8. eseguire controlli dati e performance.

## 4. Implementazione completa
```bash
docker compose -f docker-compose.ticketing.yml up -d
docker compose -f docker-compose.ticketing.yml ps
docker logs -f rdsql-ticket-collector
```

Generazione di un carico sintetico:

```bash
docker exec -i rdsql-ticket-postgres psql -U training -d training \
  -v load_size=80000 \
  -f /sql/ticket_load_generate.sql
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

Esperimento sugli indici:

```bash
docker exec -i rdsql-ticket-postgres psql -U training -d training \
  -f /sql/ticket_index_tradeoff.sql
```

Query target da discutere:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT ticket_id, opened_at, priority, region, status
FROM ticketing.support_tickets
WHERE status IN ('open', 'assigned', 'waiting_customer')
  AND opened_at >= TIMESTAMP '2026-03-01'
ORDER BY opened_at DESC, ticket_id DESC
LIMIT 50;
```

## 5. Criteri di verifica
- i tre container sono avviati;
- Metabase si collega al database `training`;
- il collector aggiunge nuove righe;
- lo script di carico aumenta ticket ed eventi;
- la dashboard contiene KPI, trend, ranking e dettaglio;
- il piano `EXPLAIN` cambia dopo la creazione degli indici;
- la soluzione dichiara limiti e trade-off: letture più veloci, scritture più costose, spazio e manutenzione.
