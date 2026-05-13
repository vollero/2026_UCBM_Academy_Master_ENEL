# Blocco 10 - Query SQL per dashboard

## 1. Problema in forma informale
La direzione vuole una dashboard operativa sui ticket. Prima di costruirla in Metabase, bisogna scrivere query SQL verificabili per KPI, trend, ranking e dettaglio.

## 2. Specifica corretta del problema
- input: schema `ticketing` e viste `dashboard_*`;
- output: query-card copiabili in Metabase;
- vincolo: ogni query deve avere una granularità chiara;
- vincolo: includere almeno KPI, serie temporale, ranking, media mobile e tabella di dettaglio;
- vincolo: usare SQL esplicito, non formule nascoste nella dashboard.

## 3. Definizione della soluzione
1. caricare lo schema ticketing;
2. eseguire le query del file `sql/ticket_architecture_dashboard_queries.sql`;
3. associare ogni query a una visualizzazione;
4. discutere filtri e denominatori;
5. salvare le query come domande Metabase.

## 4. Implementazione completa
Caricare prima lo schema nello stack ticketing, poi eseguire le query dashboard:

```bash
docker exec rdsql-ticket-postgres psql -U training -d training -v ON_ERROR_STOP=1 -f /sql/ticket_architecture_schema.sql
docker exec rdsql-ticket-postgres psql -U training -d training -v ON_ERROR_STOP=1 -f /sql/ticket_architecture_dashboard_queries.sql
```

Query principale per KPI:

```sql
SET search_path TO ticketing;

SELECT count(*) AS total_tickets,
       count(*) FILTER (WHERE closed_at IS NULL) AS open_tickets,
       count(*) FILTER (WHERE closed_at IS NOT NULL) AS closed_tickets,
       count(*) FILTER (WHERE sla_breached) AS sla_breached_tickets
FROM dashboard_ticket_base;
```

Query per trend:

```sql
SELECT day, opened_tickets, resolved_tickets, backlog_delta
FROM dashboard_daily_flow
ORDER BY day;
```

Query con window function:

```sql
SELECT day,
       opened_tickets,
       round(avg(opened_tickets) OVER (
           ORDER BY day ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 2) AS opened_3d_avg
FROM dashboard_daily_flow
ORDER BY day;
```

## 5. Criteri di verifica
- ogni query restituisce il numero di righe atteso;
- i KPI hanno denominatori chiari;
- i trend usano una riga per giorno;
- ranking e media mobile sono calcolati in SQL;
- ogni query può diventare una card Metabase.
