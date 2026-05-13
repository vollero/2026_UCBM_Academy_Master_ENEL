# Setup Laboratorio PostgreSQL

Questa guida mostra come eseguire gli script SQL del corso con PostgreSQL in Docker.

L'ambiente standard del laboratorio è il container `rdsql-postgres` definito in `docker-compose.yml`. Non è necessario installare PostgreSQL localmente.

Per una lista compatta di comandi da copiare e incollare durante il laboratorio, vedere [comandi-laboratorio-docker.md](comandi-laboratorio-docker.md).

Per una raccolta di query SQL pronte per cancellazione, creazione, inserimento, `JOIN` e raggruppamenti, vedere [query-copia-incolla.md](query-copia-incolla.md).

Per i blocchi 9-12 è disponibile anche uno stack dedicato con PostgreSQL, collector simulato e Metabase. La guida è [architettura-ticketing.md](architettura-ticketing.md).

## Avviare PostgreSQL In Docker

Dalla cartella principale della repository:

```bash
docker compose up -d postgres
```

Controllare che il container sia attivo:

```bash
docker compose ps
```

Se il comando `docker compose` non è disponibile, aggiornare Docker Desktop o Docker Engine prima del laboratorio.

## Entrare Nel Database

```bash
docker exec -it rdsql-postgres psql -U training -d training
```

Uscire da `psql`:

```text
\q
```

## Caricare Lo Schema Di Laboratorio

Dalla cartella della repository:

```bash
docker exec -i rdsql-postgres psql -U training -d training < sql/01_schema_seed_postgres.sql
```

Verificare che le tabelle siano state caricate:

```bash
docker exec -it rdsql-postgres psql -U training -d training
```

Poi dentro `psql`:

```sql
SET search_path TO training;
\dt
```

## Eseguire Una Esercitazione

Esempio per il blocco 5:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block05_join_cardinalita/docker_exercises.sql
```

Esempio per lo script generale dei laboratori:

```bash
docker exec -i rdsql-postgres psql -U training -d training < sql/02_labs.sql
```

## Riavviare O Rimuovere Il Container

Fermare PostgreSQL:

```bash
docker compose stop postgres
```

Riavviarlo:

```bash
docker compose up -d postgres
```

Rimuovere container e dati di laboratorio:

```bash
docker compose down -v
```

## Problemi Comuni

Se la porta `5432` è occupata, modificare la riga `5432:5432` in `docker-compose.yml`, ad esempio:

```yaml
ports:
  - "15432:5432"
```

Se compare `relation does not exist`, controllare di avere caricato lo schema e di usare:

```sql
SET search_path TO training;
```

## Stack Ticketing Per Blocchi 9-12

Avviare PostgreSQL, collector simulato e Metabase:

```bash
docker compose -f docker-compose.ticketing.yml up -d
```

Metabase è disponibile su:

```text
http://localhost:3000
```

Per collegare Metabase al database PostgreSQL usare:

```text
host: postgres
port: 5432
database: training
user: training
password: training
```

Per entrare nel PostgreSQL dello stack ticketing:

```bash
docker exec -it rdsql-ticket-postgres psql -U training -d training
```

Dentro `psql`:

```sql
SET search_path TO ticketing;
\dt
SELECT count(*) FROM support_tickets;
SELECT count(*) FROM support_tickets_raw;
```
