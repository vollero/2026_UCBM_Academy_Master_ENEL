# Relational Databases, SQL & NoSQL

Materiale del corso **Relational Databases & SQL** per il Master ENEL 2026, con estensione NoSQL sui blocchi finali.

Qui trovate slide, attività pratiche, esercitazioni SQL/NoSQL e script per lavorare con PostgreSQL e MongoDB in Docker.

## Da Dove Iniziare

1. Leggete [docs/guida-studenti.md](docs/guida-studenti.md).
2. Aprite le slide del blocco in `slides/blocks/`.
3. Usate il PDF attività corrispondente in `activities/<blocco>/`.
4. Per le esercitazioni operative, preparate PostgreSQL o MongoDB seguendo [docs/setup-laboratorio.md](docs/setup-laboratorio.md).
5. Per avvio, stop e interazione controllata con le piattaforme, usate [docs/guida-operativa-piattaforme.md](docs/guida-operativa-piattaforme.md).
6. Per i comandi da copiare e incollare in aula, usate [docs/comandi-laboratorio-docker.md](docs/comandi-laboratorio-docker.md).

## Organizzazione

- `slides/blocks/`: slide PDF delle lezioni e materiali introduttivi aggiuntivi.
- `activities/`: tracce, handout, esercitazioni Docker, file Markdown, script SQL e script MongoDB.
- `sql/`: schema dati e script SQL generali del laboratorio.
- `nosql/`: script MongoDB per il laboratorio di telemetria NoSQL.
- `docs/`: guida studenti, setup laboratorio e indice dei materiali.
- `docker-compose.yml`: ambiente Docker standard del laboratorio PostgreSQL.
- `docker-compose.ticketing.yml`: stack dei blocchi 9-12 con PostgreSQL, collector simulato e Metabase.
- `docker-compose.telemetry.yml`: stack dei blocchi 15-16 con MongoDB, collector simulato e mongo-express.
- `docs/query-copia-incolla.md`: query SQL pronte per copia/incolla.

## Percorso Del Corso

| Blocco | Tema |
| --- | --- |
| 1 | Dalla tabella singola alle relazioni |
| 2 | Chiavi, domini e integrità |
| 3 | Normalizzazione e schema relazionale |
| 4 | Prime query SQL |
| 5 | JOIN e cardinalità |
| 6 | Aggregazioni e KPI |
| 7 | DDL, DML e transazioni |
| 8 | Subquery e logica insiemistica |
| 9 | Architettura dati containerizzata con DBMS |
| 10 | Query SQL per dashboard Metabase |
| 11 | Performance di un DBMS per dashboard |
| 12 | Capstone architettura DBMS e dashboard |
| 13 | Fondamenti NoSQL |
| 14 | Scenari e modellazione NoSQL |
| 15 | Telemetria NoSQL con MongoDB |
| 16 | Dashboard e capstone NoSQL |

## Laboratorio SQL

Il laboratorio SQL usa PostgreSQL in Docker. Per avviare il container:

```bash
docker compose up -d postgres
```

Per caricare il database di laboratorio:

```bash
docker exec -i rdsql-postgres psql -U training -d training < sql/01_schema_seed_postgres.sql
```

La procedura completa è in [docs/setup-laboratorio.md](docs/setup-laboratorio.md).

I comandi rapidi per gestione container, `psql`, esercitazioni e soluzioni sono in [docs/comandi-laboratorio-docker.md](docs/comandi-laboratorio-docker.md).

La guida operativa per avvio, stop e interazione controllata con le piattaforme ticketing e telemetria è in [docs/guida-operativa-piattaforme.md](docs/guida-operativa-piattaforme.md).

Le query SQL pronte per cancellazione, creazione, inserimento, `JOIN` e `GROUP BY` sono in [docs/query-copia-incolla.md](docs/query-copia-incolla.md).

Per i blocchi 9-12 usate anche lo stack ticketing con PostgreSQL, collector simulato e Metabase:

```bash
docker compose -f docker-compose.ticketing.yml up -d
```

La guida dedicata è in [docs/architettura-ticketing.md](docs/architettura-ticketing.md).

Per il blocco 12 sono disponibili anche due script per discutere i trade-off degli indici:

```bash
docker exec -i rdsql-ticket-postgres psql -U training -d training -v load_size=80000 -f /sql/ticket_load_generate.sql
docker exec -i rdsql-ticket-postgres psql -U training -d training -f /sql/ticket_index_tradeoff.sql
```

## Laboratorio NoSQL

I blocchi 13-14 introducono tecnologie, modelli e scenari NoSQL. I blocchi 15-16 usano un sistema di telemetria con MongoDB, collector simulato e interfaccia web `mongo-express`.

Per la lezione NoSQL sono disponibili anche due materiali aggiuntivi:

- `slides/blocks/block13_nosql_fondamenti/block13_nosql_fondamenti_panoramica_nosql.pdf`: panoramica comparativa di document database, key-value, wide-column, graph, search, time-series e vector database;
- `slides/blocks/block14_nosql_scenari_modelli/block14_nosql_scenari_modelli_architetture_polyglot.pdf`: architetture oltre il modello DB singolo, con esempio su gestione guasti e interventi;
- `activities/block13_nosql_fondamenti/panoramica_comparativa_nosql.md`: handout testuale con tabelle comparative e scenari applicativi;
- `activities/block14_nosql_scenari_modelli/architetture_polyglot.md`: handout su polyglot persistence, eventi, read model e trade-off.

Per avviare lo stack:

```bash
docker compose -f docker-compose.telemetry.yml up -d
```

Per ricaricare schema e dati:

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_schema.js
```

Per eseguire le query dashboard:

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_dashboard_queries.js
```

La guida dedicata è in [docs/architettura-telemetria.md](docs/architettura-telemetria.md).

## Indice Completo

L'elenco dei materiali principali è in [docs/indice-materiali.md](docs/indice-materiali.md).

Il file `manifest/materials.tsv` è un elenco tecnico dei file presenti nella repository.
