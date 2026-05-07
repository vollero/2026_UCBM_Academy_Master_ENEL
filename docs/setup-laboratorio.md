# Setup Laboratorio PostgreSQL

Questa guida mostra come eseguire gli script SQL del corso con PostgreSQL.

## Opzione Consigliata: Docker

Avviare PostgreSQL:

```bash
docker run --name rdsql-postgres \
  -e POSTGRES_USER=training \
  -e POSTGRES_PASSWORD=training \
  -e POSTGRES_DB=training \
  -p 5432:5432 \
  -d postgres:16
```

Entrare nel database:

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
docker stop rdsql-postgres
```

Riavviarlo:

```bash
docker start rdsql-postgres
```

Rimuoverlo completamente:

```bash
docker rm -f rdsql-postgres
```

## Problemi Comuni

Se la porta `5432` è occupata, usare una porta locale diversa:

```bash
docker run --name rdsql-postgres \
  -e POSTGRES_USER=training \
  -e POSTGRES_PASSWORD=training \
  -e POSTGRES_DB=training \
  -p 15432:5432 \
  -d postgres:16
```

Se compare `relation does not exist`, controllare di avere caricato lo schema e di usare:

```sql
SET search_path TO training;
```

