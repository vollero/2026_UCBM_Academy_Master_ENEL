# Indice Materiali

## Slide

- Blocco 1: `slides/blocks/block01_dominio_relazioni/block01_dominio_relazioni.pdf`
- Blocco 2: `slides/blocks/block02_chiavi_vincoli_integrita/block02_chiavi_vincoli_integrita.pdf`
- Blocco 3: `slides/blocks/block03_normalizzazione_schema/block03_normalizzazione_schema.pdf`
- Blocco 4: `slides/blocks/block04_select_sql_base/block04_select_sql_base.pdf`
- Blocco 5: `slides/blocks/block05_join_cardinalita/block05_join_cardinalita.pdf`
- Blocco 6: `slides/blocks/block06_aggregazioni_kpi/block06_aggregazioni_kpi.pdf`
- Blocco 7: `slides/blocks/block07_ddl_dml_transazioni/block07_ddl_dml_transazioni.pdf`
- Blocco 8: `slides/blocks/block08_subquery_set_logic/block08_subquery_set_logic.pdf`
- Blocco 9: `slides/blocks/block09_cte_viste_mantenibilita/block09_cte_viste_mantenibilita.pdf`
- Blocco 10: `slides/blocks/block10_window_functions/block10_window_functions.pdf`
- Blocco 11: `slides/blocks/block11_performance_explain_indici/block11_performance_explain_indici.pdf`
- Blocco 12: `slides/blocks/block12_capstone_query_design/block12_capstone_query_design.pdf`
- Blocco 13: `slides/blocks/block13_nosql_fondamenti/block13_nosql_fondamenti.pdf`
- Blocco 14: `slides/blocks/block14_nosql_scenari_modelli/block14_nosql_scenari_modelli.pdf`
- Blocco 15: `slides/blocks/block15_telemetria_mongodb_architettura/block15_telemetria_mongodb_architettura.pdf`
- Blocco 16: `slides/blocks/block16_telemetria_dashboard_capstone/block16_telemetria_dashboard_capstone.pdf`

## Attività

Le attività sono in `activities/<blocco>/`.

Per ogni blocco sono presenti:

- `activity.md`: traccia;
- `solution.md`: soluzione o discussione guidata;
- `<blocco>_activity.pdf`: handout PDF.

## Esercitazioni Docker

- Blocco 4: `activities/block04_select_sql_base/docker_exercises.md`
- Blocco 5: `activities/block05_join_cardinalita/docker_exercises.md`
- Blocco 6: `activities/block06_aggregazioni_kpi/docker_exercises.md`
- Blocco 7: `activities/block07_ddl_dml_transazioni/docker_exercises.md`
- Blocco 8: `activities/block08_subquery_set_logic/docker_exercises.md`

## Script SQL Generali

- `sql/01_schema_seed_postgres.sql`: schema e dati di laboratorio;
- `sql/02_labs.sql`: tracce SQL operative;
- `sql/03_solutions.sql`: soluzioni SQL;
- `sql/00_schema_and_all_solutions_postgres.sql`: schema, dati e soluzioni in un unico script;
- `sql/query_copia_incolla.sql`: script demo con cancellazione, creazione, inserimenti, `JOIN` e raggruppamenti;
- `sql/ticket_architecture_schema.sql`: schema ticketing per i blocchi 9-12;
- `sql/ticket_architecture_dashboard_queries.sql`: query SQL per dashboard Metabase;
- `sql/ticket_collector_tick.sql`: inserimento simulato di un nuovo ticket;
- `docs/query-copia-incolla.md`: documento con query SQL pronte per copia/incolla.

## Script NoSQL Generali

- `nosql/telemetry_schema.js`: database MongoDB `telemetry`, dati seed e indici;
- `nosql/telemetry_collector_tick.js`: simulazione di una nuova lettura di telemetria;
- `nosql/telemetry_dashboard_queries.js`: aggregation pipeline per le schede dashboard;
- `activities/block15_telemetria_mongodb_architettura/solution.js`: soluzione operativa del blocco 15;
- `activities/block16_telemetria_dashboard_capstone/solution.js`: soluzione operativa del blocco 16.

## Ambiente Docker

- `docker-compose.yml`: container PostgreSQL standard del laboratorio;
- `docker-compose.ticketing.yml`: stack ticketing con PostgreSQL, collector simulato e Metabase;
- `docker-compose.telemetry.yml`: stack telemetria con MongoDB, collector simulato e mongo-express;
- `docs/setup-laboratorio.md`: istruzioni per avviare il container, caricare lo schema ed eseguire gli script;
- `docs/guida-operativa-piattaforme.md`: runbook per avvio, stop e interazione controllata con ticketing e telemetria;
- `docs/comandi-laboratorio-docker.md`: comandi rapidi per gestione container, `psql`, esercitazioni e soluzioni;
- `docs/architettura-ticketing.md`: guida specifica per lo stack dei blocchi 9-12;
- `docs/architettura-telemetria.md`: guida specifica per lo stack NoSQL dei blocchi 15-16.
