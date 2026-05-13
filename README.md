# Relational Databases & SQL

Materiale del corso **Relational Databases & SQL** per il Master ENEL 2026.

Qui trovate slide, attività pratiche, esercitazioni SQL e script per lavorare con PostgreSQL in Docker.

## Da Dove Iniziare

1. Leggete [docs/guida-studenti.md](docs/guida-studenti.md).
2. Aprite le slide del blocco in `slides/blocks/`.
3. Usate il PDF attività corrispondente in `activities/<blocco>/`.
4. Per le esercitazioni SQL, preparate PostgreSQL seguendo [docs/setup-laboratorio.md](docs/setup-laboratorio.md).
5. Per i comandi da copiare e incollare in aula, usate [docs/comandi-laboratorio-docker.md](docs/comandi-laboratorio-docker.md).

## Organizzazione

- `slides/blocks/`: slide PDF delle lezioni e materiali introduttivi aggiuntivi.
- `activities/`: tracce, handout, esercitazioni Docker, file Markdown e script SQL.
- `sql/`: schema dati e script SQL generali del laboratorio.
- `docs/`: guida studenti, setup laboratorio e indice dei materiali.
- `docker-compose.yml`: ambiente Docker standard del laboratorio PostgreSQL.
- `docker-compose.ticketing.yml`: stack dei blocchi 9-12 con PostgreSQL, collector simulato e Metabase.
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

Le query SQL pronte per cancellazione, creazione, inserimento, `JOIN` e `GROUP BY` sono in [docs/query-copia-incolla.md](docs/query-copia-incolla.md).

Per i blocchi 9-12 usate anche lo stack ticketing con PostgreSQL, collector simulato e Metabase:

```bash
docker compose -f docker-compose.ticketing.yml up -d
```

La guida dedicata è in [docs/architettura-ticketing.md](docs/architettura-ticketing.md).

## Indice Completo

L'elenco dei materiali principali è in [docs/indice-materiali.md](docs/indice-materiali.md).

Il file `manifest/materials.tsv` è un elenco tecnico dei file presenti nella repository.
