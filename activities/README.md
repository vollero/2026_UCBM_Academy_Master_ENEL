# Attività pratiche

Questa cartella contiene le attività pratiche del corso, separate dalle slide.

Le attività SQL sono pensate per essere eseguite nel container PostgreSQL Docker del corso. Prima dei blocchi SQL 4-8 avviare il laboratorio con `docker compose up -d postgres` dalla cartella principale della repository. Per i blocchi 9-12 usare invece lo stack ticketing con `docker compose -f docker-compose.ticketing.yml up -d`. Per i blocchi NoSQL 15-16 usare lo stack telemetry con `docker compose -f docker-compose.telemetry.yml up -d`.

Ogni blocco 30-90 ha una cartella dedicata. La struttura della pratica è uniforme:

1. problema in forma informale;
2. specifica corretta del problema;
3. definizione della soluzione;
4. implementazione completa o artefatto atteso;
5. criteri di verifica e checkpoint.

File disponibili per ogni blocco:

- `activity.md`: traccia pratica;
- `solution.md`: soluzione o discussione guidata;
- `<blocco>_activity.pdf`: PDF attività con traccia, suggerimenti e soluzione;
- `solution.sql`: query soluzione caricabili nel DBMS per i blocchi 4-12;
- `solution.js`: script MongoDB caricabili nel DBMS per i blocchi NoSQL operativi;
- slide descrittive e solutive nel PDF del blocco corrispondente.

Materiale aggiuntivo disponibile:

- `block03_normalizzazione_schema/casi_studio.md`: casi di studio per discussione guidata sul blocco 3;
- `block03_normalizzazione_schema/block03_normalizzazione_schema_casi_studio_handout.pdf`: handout con tracce, suggerimenti e soluzioni.
- `block03_normalizzazione_schema/postgresql_docker.md`: guida operativa per avviare PostgreSQL in Docker e interagire con il container;
- `block03_normalizzazione_schema/block03_normalizzazione_schema_postgresql_docker.pdf`: PDF della guida Docker/PostgreSQL del blocco 3;
- `block03_normalizzazione_schema/postgresql_docker_test.sql`: script SQL per creazione tabelle, dati e query di controllo nel container;
- `block04_select_sql_base/introduzione_sql.md`: introduzione progressiva alla sintassi SQL del blocco 4;
- `block04_select_sql_base/block04_select_sql_base_introduzione_sql_handout.pdf`: handout con sintassi, esempi e soluzioni;
- `block04_select_sql_base/introduzione_sql_examples.sql`: esempi SQL eseguibili sullo schema di laboratorio.
- `block05_join_cardinalita/introduzione_join.md`: introduzione progressiva a `JOIN`, cardinalità e fan-out;
- `block05_join_cardinalita/block05_join_cardinalita_introduzione_join_handout.pdf`: handout con sintassi, esempi e soluzioni sui JOIN;
- `block05_join_cardinalita/introduzione_join_examples.sql`: esempi SQL eseguibili per il blocco 5.
- `block04_select_sql_base/docker_exercises.md`: esercitazioni Docker su `SELECT`, filtri, ordinamento e `CASE`;
- `block05_join_cardinalita/docker_exercises.md`: esercitazioni Docker su `JOIN`, `LEFT JOIN` e fan-out;
- `block06_aggregazioni_kpi/introduzione_aggregazioni.md`: introduzione progressiva ad aggregazioni e KPI;
- `block06_aggregazioni_kpi/docker_exercises.md`: esercitazioni Docker su `GROUP BY`, KPI e `HAVING`;
- `block07_ddl_dml_transazioni/introduzione_ddl_dml.md`: introduzione progressiva a DDL, DML e transazioni;
- `block07_ddl_dml_transazioni/docker_exercises.md`: esercitazioni Docker su modifiche controllate e transazioni;
- `block08_subquery_set_logic/introduzione_subquery.md`: introduzione progressiva a subquery e logica insiemistica;
- `block08_subquery_set_logic/docker_exercises.md`: esercitazioni Docker su `EXISTS`, `NOT EXISTS` ed `EXCEPT`;
- `../sql/ticket_architecture_schema.sql`: schema e dati del caso architetturale ticketing per i blocchi 9-12;
- `../sql/ticket_collector_tick.sql`: simulazione incrementale del sistema di collezionamento;
- `../sql/ticket_architecture_dashboard_queries.sql`: query SQL pronte per costruire schede e dashboard in Metabase;
- `../sql/ticket_load_generate.sql`: generatore di carico storico per rendere visibili i costi delle query;
- `../sql/ticket_index_tradeoff.sql`: esperimento guidato su indici, piani di esecuzione e costi di scrittura.
- `block13_nosql_fondamenti/panoramica_comparativa_nosql.md`: panoramica comparativa delle famiglie NoSQL con scenari applicativi e tabelle decisionali;
- `block14_nosql_scenari_modelli/architetture_polyglot.md`: guida al passaggio dal modello DB singolo a un'architettura con eventi, read model e persistenze specializzate;
- `../nosql/telemetry_schema.js`: schema, dati seed e indici del caso telemetria NoSQL;
- `../nosql/telemetry_collector_tick.js`: simulazione incrementale del collector telemetrico;
- `../nosql/telemetry_dashboard_queries.js`: aggregation pipeline per dashboard NoSQL.

## Indice

| Blocco | Tema | PDF attività | Traccia | Soluzione | Script |
| --- | --- | --- | --- | --- | --- |
| 1 | Dalla tabella singola alle relazioni | `block01_dominio_relazioni/block01_dominio_relazioni_activity.pdf` | `block01_dominio_relazioni/activity.md` | `block01_dominio_relazioni/solution.md` | - |
| 2 | Chiavi, domini e integrità | `block02_chiavi_vincoli_integrita/block02_chiavi_vincoli_integrita_activity.pdf` | `block02_chiavi_vincoli_integrita/activity.md` | `block02_chiavi_vincoli_integrita/solution.md` | - |
| 3 | Normalizzazione e schema | `block03_normalizzazione_schema/block03_normalizzazione_schema_activity.pdf` | `block03_normalizzazione_schema/activity.md` | `block03_normalizzazione_schema/solution.md` | - |
| 4 | Prime query SQL | `block04_select_sql_base/block04_select_sql_base_activity.pdf` | `block04_select_sql_base/activity.md` | `block04_select_sql_base/solution.md` | `block04_select_sql_base/solution.sql` |
| 5 | JOIN e cardinalità | `block05_join_cardinalita/block05_join_cardinalita_activity.pdf` | `block05_join_cardinalita/activity.md` | `block05_join_cardinalita/solution.md` | `block05_join_cardinalita/solution.sql` |
| 6 | Aggregazioni e KPI | `block06_aggregazioni_kpi/block06_aggregazioni_kpi_activity.pdf` | `block06_aggregazioni_kpi/activity.md` | `block06_aggregazioni_kpi/solution.md` | `block06_aggregazioni_kpi/solution.sql` |
| 7 | DDL, DML e transazioni | `block07_ddl_dml_transazioni/block07_ddl_dml_transazioni_activity.pdf` | `block07_ddl_dml_transazioni/activity.md` | `block07_ddl_dml_transazioni/solution.md` | `block07_ddl_dml_transazioni/solution.sql` |
| 8 | Subquery e logica insiemistica | `block08_subquery_set_logic/block08_subquery_set_logic_activity.pdf` | `block08_subquery_set_logic/activity.md` | `block08_subquery_set_logic/solution.md` | `block08_subquery_set_logic/solution.sql` |
| 9 | Architettura dati containerizzata con DBMS | `block09_cte_viste_mantenibilita/block09_cte_viste_mantenibilita_activity.pdf` | `block09_cte_viste_mantenibilita/activity.md` | `block09_cte_viste_mantenibilita/solution.md` | `block09_cte_viste_mantenibilita/solution.sql` |
| 10 | Query SQL per dashboard Metabase | `block10_window_functions/block10_window_functions_activity.pdf` | `block10_window_functions/activity.md` | `block10_window_functions/solution.md` | `block10_window_functions/solution.sql` |
| 11 | Performance di un DBMS per dashboard | `block11_performance_explain_indici/block11_performance_explain_indici_activity.pdf` | `block11_performance_explain_indici/activity.md` | `block11_performance_explain_indici/solution.md` | `block11_performance_explain_indici/solution.sql` |
| 12 | Capstone architettura DBMS e dashboard | `block12_capstone_query_design/block12_capstone_query_design_activity.pdf` | `block12_capstone_query_design/activity.md` | `block12_capstone_query_design/solution.md` | `block12_capstone_query_design/solution.sql` |
| 13 | Fondamenti NoSQL | `block13_nosql_fondamenti/block13_nosql_fondamenti_activity.pdf` | `block13_nosql_fondamenti/activity.md` | `block13_nosql_fondamenti/solution.md` | - |
| 14 | Scenari e modellazione NoSQL | `block14_nosql_scenari_modelli/block14_nosql_scenari_modelli_activity.pdf` | `block14_nosql_scenari_modelli/activity.md` | `block14_nosql_scenari_modelli/solution.md` | - |
| 15 | Telemetria NoSQL con MongoDB | `block15_telemetria_mongodb_architettura/block15_telemetria_mongodb_architettura_activity.pdf` | `block15_telemetria_mongodb_architettura/activity.md` | `block15_telemetria_mongodb_architettura/solution.md` | `block15_telemetria_mongodb_architettura/solution.js` |
| 16 | Dashboard e capstone NoSQL | `block16_telemetria_dashboard_capstone/block16_telemetria_dashboard_capstone_activity.pdf` | `block16_telemetria_dashboard_capstone/activity.md` | `block16_telemetria_dashboard_capstone/solution.md` | `block16_telemetria_dashboard_capstone/solution.js` |

Le soluzioni SQL dei blocchi 4-8 sono raccolte anche in `../sql/03_solutions.sql`.
I blocchi 9-12 usano lo schema dedicato `ticketing`: caricare prima `../sql/ticket_architecture_schema.sql`, poi eseguire le soluzioni del blocco o le query dashboard.
I blocchi 15-16 usano il database MongoDB `telemetry`: caricare prima `../nosql/telemetry_schema.js`, poi eseguire le pipeline dashboard o le soluzioni del blocco.
