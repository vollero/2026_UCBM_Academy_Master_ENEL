# Relational Databases & SQL

Materiale del corso **Relational Databases & SQL** per il Master ENEL 2026.

Qui trovate slide, attività pratiche, esercitazioni SQL e script per lavorare con PostgreSQL.

## Da Dove Iniziare

1. Leggete [docs/guida-studenti.md](docs/guida-studenti.md).
2. Aprite le slide del blocco in `slides/blocks/`.
3. Usate il PDF attività corrispondente in `activities/<blocco>/`.
4. Per le esercitazioni SQL, preparate PostgreSQL seguendo [docs/setup-laboratorio.md](docs/setup-laboratorio.md).

## Organizzazione

- `slides/blocks/`: slide PDF delle lezioni e materiali introduttivi aggiuntivi.
- `activities/`: tracce, handout, esercitazioni Docker, file Markdown e script SQL.
- `sql/`: schema dati e script SQL generali del laboratorio.
- `docs/`: guida studenti, setup laboratorio e indice dei materiali.

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
| 9 | CTE, viste e mantenibilità |
| 10 | Window function |
| 11 | Performance, EXPLAIN e indici |
| 12 | Capstone query design |

## Laboratorio SQL

Per caricare il database di laboratorio in PostgreSQL:

```bash
psql -d sql_training -f sql/01_schema_seed_postgres.sql
```

Se usate Docker, seguite [docs/setup-laboratorio.md](docs/setup-laboratorio.md).

## Indice Completo

L'elenco dei materiali principali è in [docs/indice-materiali.md](docs/indice-materiali.md).

Il file `manifest/materials.tsv` è un elenco tecnico dei file presenti nella repository.

