# Architettura Ticketing Con PostgreSQL E Metabase

Questa guida riguarda i blocchi 9-12. L'obiettivo è riprodurre una piccola architettura dati con:

- un DBMS PostgreSQL;
- un collector simulato che inserisce ticket;
- uno schema relazionale `ticketing`;
- viste SQL per dashboard;
- Metabase come sistema di dashboarding.

## Avvio

```bash
docker compose -f docker-compose.ticketing.yml up -d
```

```bash
docker compose -f docker-compose.ticketing.yml ps
```

```bash
docker logs -f rdsql-ticket-collector
```

## Accesso A PostgreSQL

```bash
docker exec -it rdsql-ticket-postgres psql -U training -d training
```

Dentro `psql`:

```sql
SET search_path TO ticketing;
\dt
SELECT count(*) FROM support_tickets;
SELECT count(*) FROM support_tickets_raw;
SELECT * FROM dashboard_daily_flow ORDER BY day;
```

## Accesso A Metabase

Aprire:

```text
http://localhost:3000
```

Configurare la connessione PostgreSQL:

```text
host: postgres
port: 5432
database: training
user: training
password: training
```

## Query Da Usare Per Le Card

Le query principali sono nel file:

```text
sql/ticket_architecture_dashboard_queries.sql
```

Le card minime consigliate sono:

- KPI ticket totali, aperti, chiusi e SLA violati;
- serie giornaliera aperti/risolti/backlog;
- distribuzione priorità-stato;
- tempo medio di risoluzione per priorità e regione;
- ranking categorie;
- tabella di dettaglio ticket aperti.

## Carico E Indici Per Il Blocco 12

Per rendere visibile l'utilità degli indici è possibile generare molti ticket distribuiti nel tempo:

```bash
docker exec -i rdsql-ticket-postgres psql -U training -d training \
  -v load_size=80000 \
  -f /sql/ticket_load_generate.sql
```

Poi eseguire l'esperimento su piani di esecuzione, indici e costo di scrittura:

```bash
docker exec -i rdsql-ticket-postgres psql -U training -d training \
  -f /sql/ticket_index_tradeoff.sql
```

L'obiettivo non è aggiungere indici in modo automatico, ma leggere il trade-off: query dashboard più selettive, più spazio occupato, scritture più costose e maggiore manutenzione.

## Spegnimento

```bash
docker compose -f docker-compose.ticketing.yml down
```

Per rimuovere anche i dati:

```bash
docker compose -f docker-compose.ticketing.yml down -v
```
