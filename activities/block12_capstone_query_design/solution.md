# Soluzione - Blocco 12 - Capstone architettura DBMS e dashboard

## Avvio
```bash
docker compose -f docker-compose.ticketing.yml up -d
docker compose -f docker-compose.ticketing.yml ps
docker logs -f rdsql-ticket-collector
```

## Connessione Metabase
- URL: `http://localhost:3000`
- tipo database: PostgreSQL
- host: `postgres`
- porta: `5432`
- database: `training`
- user/password: `training` / `training`

## Query card principale
```sql
SELECT count(*) AS total_tickets,
       count(*) FILTER (WHERE closed_at IS NULL) AS open_tickets,
       count(*) FILTER (WHERE closed_at IS NOT NULL) AS closed_tickets,
       count(*) FILTER (WHERE sla_breached) AS sla_breached_tickets
FROM ticketing.dashboard_ticket_base;
```

## Verifica
- PostgreSQL contiene lo schema `ticketing`;
- il collector aggiunge righe;
- Metabase legge da PostgreSQL;
- le card usano query salvate;
- la presentazione spiega metriche, filtri, limiti e controlli.
