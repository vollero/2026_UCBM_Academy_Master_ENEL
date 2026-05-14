# Soluzione - Blocco 12 - Capstone architettura DBMS e dashboard

## Avvio
```bash
docker compose -f docker-compose.ticketing.yml up -d
docker compose -f docker-compose.ticketing.yml ps
docker logs -f rdsql-ticket-collector
```

## Carico sintetico per rendere visibili gli indici
```bash
docker exec -i rdsql-ticket-postgres psql -U training -d training \
  -v load_size=80000 \
  -f /sql/ticket_load_generate.sql
```

Lo script genera ticket distribuiti nel tempo, eventi raw e lifecycle event. Con un dataset piccolo PostgreSQL può scegliere una scansione completa anche se esiste un indice: il carico serve a rendere evidente quando l'indice riduce davvero il lavoro.

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

## Esperimento indici
```bash
docker exec -i rdsql-ticket-postgres psql -U training -d training \
  -f /sql/ticket_index_tradeoff.sql
```

Punti da leggere nell'output:
- piano prima degli indici: scansione e ordinamento più costosi;
- indice parziale sui ticket aperti: utile per drill-down operativi;
- indice composito su regione, categoria e data: utile per filtri dashboard;
- dimensione degli indici: spazio aggiuntivo;
- benchmark di scrittura: inserire righe costa di più quando ci sono più indici da aggiornare.

## Verifica
- PostgreSQL contiene lo schema `ticketing`;
- il collector aggiunge righe;
- il carico sintetico aumenta ticket ed eventi;
- Metabase legge da PostgreSQL;
- le card usano query salvate;
- la presentazione spiega metriche, filtri, limiti, controlli e trade-off degli indici.
