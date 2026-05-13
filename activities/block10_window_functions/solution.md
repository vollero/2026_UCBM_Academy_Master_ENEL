# Soluzione - Blocco 10 - Query SQL per dashboard

La soluzione usa lo schema `ticketing` e il file `sql/ticket_architecture_dashboard_queries.sql`, che contiene query già organizzate per card Metabase: KPI, serie giornaliera, distribuzioni, ranking, media mobile e tabella di dettaglio.

```bash
docker exec rdsql-ticket-postgres psql -U training -d training -v ON_ERROR_STOP=1 -f /sql/ticket_architecture_schema.sql
docker exec rdsql-ticket-postgres psql -U training -d training -v ON_ERROR_STOP=1 -f /sql/ticket_architecture_dashboard_queries.sql
```

## Card suggerite
- KPI: totale ticket, aperti, chiusi, violazioni SLA.
- Line chart: `dashboard_daily_flow`.
- Bar chart: ticket per priorità e stato.
- Table: ticket aperti con dettaglio.
- Ranking: categorie per numero di ticket.

## Perché è corretta
- ogni query ha una granularità definita;
- le metriche sono esplicite in SQL;
- la dashboard può essere ricostruita da file versionati;
- le window function sono usate per ranking e trend.
