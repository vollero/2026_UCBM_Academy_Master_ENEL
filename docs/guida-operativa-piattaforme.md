# Guida Operativa Alle Piattaforme

Questa guida è un runbook rapido per usare in modo controllato le due piattaforme architetturali del corso:

- piattaforma ticketing: PostgreSQL, collector simulato e Metabase;
- piattaforma telemetria: MongoDB, collector simulato e mongo-express.

I comandi vanno eseguiti dalla cartella principale della repository.

## Principi Di Uso

Usate `stop` quando volete fermare i container ma conservare i dati.

Usate `down -v` solo quando volete ripartire da zero cancellando anche i volumi dati.

Per una dimostrazione controllata, avviate prima solo il DBMS, caricate lo schema e poi simulate un singolo evento. Avviare lo stack completo significa avviare anche il collector automatico, quindi i dati cambiano ogni pochi secondi.

## Stato Generale

Vedere i container attivi:

```bash
docker ps
```

Vedere anche i container fermi:

```bash
docker ps -a
```

Fermare il PostgreSQL standard del laboratorio SQL:

```bash
docker compose stop postgres
```

## Piattaforma Ticketing

La piattaforma ticketing è usata nei blocchi 9-12. Serve a mostrare una architettura relazionale con ingestion simulata, DBMS PostgreSQL e dashboard Metabase.

### Avvio Completo

```bash
docker compose -f docker-compose.ticketing.yml up -d
```

Controllare lo stato:

```bash
docker compose -f docker-compose.ticketing.yml ps
```

Seguire il collector:

```bash
docker logs -f rdsql-ticket-collector
```

### Avvio Controllato

Avviare solo PostgreSQL:

```bash
docker compose -f docker-compose.ticketing.yml up -d postgres
```

Caricare o ricaricare schema e dati seed:

```bash
docker exec rdsql-ticket-postgres psql -U training -d training -f /sql/ticket_architecture_schema.sql
```

Simulare un solo ticket:

```bash
docker exec rdsql-ticket-postgres psql -U training -d training -f /sql/ticket_collector_tick.sql
```

Avviare Metabase senza avviare il collector:

```bash
docker compose -f docker-compose.ticketing.yml up -d metabase
```

Avviare o riavviare il collector quando serve generare dati in modo continuo:

```bash
docker compose -f docker-compose.ticketing.yml up -d ticket-collector
```

Fermare solo il collector:

```bash
docker compose -f docker-compose.ticketing.yml stop ticket-collector
```

### Interazione Con PostgreSQL

Entrare in `psql`:

```bash
docker exec -it rdsql-ticket-postgres psql -U training -d training
```

Comandi da eseguire dentro `psql`:

```sql
SET search_path TO ticketing;
\dt
SELECT count(*) AS tickets FROM support_tickets;
SELECT count(*) AS raw_events FROM support_tickets_raw;
SELECT * FROM dashboard_daily_flow ORDER BY day;
\q
```

Eseguire le query dashboard da terminale:

```bash
docker exec rdsql-ticket-postgres psql -U training -d training -f /sql/ticket_architecture_dashboard_queries.sql
```

Generare un carico storico per il blocco 12:

```bash
docker exec -i rdsql-ticket-postgres psql -U training -d training \
  -v load_size=80000 \
  -f /sql/ticket_load_generate.sql
```

Eseguire l'esperimento su indici e trade-off:

```bash
docker exec -i rdsql-ticket-postgres psql -U training -d training \
  -f /sql/ticket_index_tradeoff.sql
```

### Accesso A Metabase

Aprire:

```text
http://localhost:3000
```

Parametri connessione:

```text
host: postgres
port: 5432
database: training
user: training
password: training
```

### Stop E Reset

Fermare la piattaforma conservando i dati:

```bash
docker compose -f docker-compose.ticketing.yml stop
```

Rimuovere i container conservando i volumi:

```bash
docker compose -f docker-compose.ticketing.yml down
```

Ripartire da zero cancellando i dati:

```bash
docker compose -f docker-compose.ticketing.yml down -v
docker compose -f docker-compose.ticketing.yml up -d
```

## Piattaforma Telemetria

La piattaforma telemetria è usata nei blocchi 15-16. Serve a mostrare una architettura NoSQL con ingestion simulata, DBMS MongoDB e ispezione dei documenti con mongo-express.

### Avvio Completo

```bash
docker compose -f docker-compose.telemetry.yml up -d
```

Controllare lo stato:

```bash
docker compose -f docker-compose.telemetry.yml ps
```

Seguire il collector:

```bash
docker logs -f rdnosql-telemetry-collector
```

### Avvio Controllato

Avviare solo MongoDB:

```bash
docker compose -f docker-compose.telemetry.yml up -d mongo
```

Caricare o ricaricare database, dati seed e indici:

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_schema.js
```

Simulare una sola lettura:

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_collector_tick.js
```

Avviare mongo-express senza avviare il collector:

```bash
docker compose -f docker-compose.telemetry.yml up -d mongo-express
```

Avviare o riavviare il collector quando serve generare dati in modo continuo:

```bash
docker compose -f docker-compose.telemetry.yml up -d telemetry-collector
```

Fermare solo il collector:

```bash
docker compose -f docker-compose.telemetry.yml stop telemetry-collector
```

### Interazione Con MongoDB

Entrare in `mongosh`:

```bash
docker exec -it rdnosql-telemetry-mongo mongosh
```

Comandi da eseguire dentro `mongosh`:

```javascript
use telemetry
show collections
db.devices.countDocuments()
db.readings_raw.countDocuments()
db.readings_curated.countDocuments()
db.readings_curated.find().sort({ ts: -1 }).limit(3)
exit
```

Eseguire le query dashboard da terminale:

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_dashboard_queries.js
```

Eseguire le soluzioni operative:

```bash
docker exec rdnosql-telemetry-mongo mongosh /activities/block15_telemetria_mongodb_architettura/solution.js
docker exec rdnosql-telemetry-mongo mongosh /activities/block16_telemetria_dashboard_capstone/solution.js
```

### Accesso A mongo-express

Aprire:

```text
http://localhost:8081
```

Credenziali:

```text
user: training
password: training
```

### Stop E Reset

Fermare la piattaforma conservando i dati:

```bash
docker compose -f docker-compose.telemetry.yml stop
```

Rimuovere i container conservando i volumi:

```bash
docker compose -f docker-compose.telemetry.yml down
```

Ripartire da zero cancellando i dati:

```bash
docker compose -f docker-compose.telemetry.yml down -v
docker compose -f docker-compose.telemetry.yml up -d
```

## Stop Rapido Di Tutto Il Laboratorio

```bash
docker compose stop postgres
docker compose -f docker-compose.ticketing.yml stop
docker compose -f docker-compose.telemetry.yml stop
```

## Problemi Comuni

Se una porta è occupata, controllare i container attivi con:

```bash
docker ps
```

Le porte usate di default sono:

```text
PostgreSQL standard: 5432
PostgreSQL ticketing: 5433
Metabase: 3000
MongoDB telemetria: 27018
mongo-express: 8081
```

Se una tabella o una collection non esiste, ricaricare lo schema della piattaforma corrispondente.

Se i dati cambiano mentre state spiegando una query, fermare il collector e simulare manualmente un singolo evento.

Se Docker segnala che il nome container `rdnosql-telemetry-mongo` è già in uso, esiste un vecchio container telemetry creato da un avvio precedente o da un'altra cartella. Controllare con:

```bash
docker ps -a --filter name=rdnosql-telemetry
```

Poi rimuovere i container dello stack senza cancellare i volumi dati:

```bash
docker compose -f docker-compose.telemetry.yml down
docker compose -f docker-compose.telemetry.yml up -d
```
