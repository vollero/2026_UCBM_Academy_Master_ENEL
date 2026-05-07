# Relational Databases & SQL

Materiale didattico per 24 ore di lezione, organizzato in 12 blocchi da 2 ore:

- 30 minuti di teoria;
- 90 minuti di pratica;
- 3 giornate da 8 ore, con 4 blocchi per giornata.

La sequenza è model-first e procede sempre da una rappresentazione semplice verso un modello più generale: tabella singola, limiti della tabella unica, tabelle collegate, formalizzazione. I primi tre blocchi introducono modello relazionale, chiavi, vincoli e normalizzazione senza partire da SQL. Dal blocco 4 si passa a SQL, dalle query base fino a window function, performance e capstone.

## Struttura

- `slides/blocks/<blocco>/`: una cartella per ogni blocco 30-90.
- `slides/blocks/<blocco>/main.tex`: sorgente Beamer del blocco.
- `slides/blocks/<blocco>/<blocco>.pdf`: PDF compilato del blocco.
- `slides/common/preamble.tex`: stile condiviso dei deck.
- `slides/archive/`: materiale precedente archiviato.
- `activities/README.md`: indice delle attività pratiche.
- `activities/<blocco>/activity.md`: consegna pratica del blocco.
- `activities/<blocco>/solution.md`: soluzione o soluzione guidata del blocco.
- `activities/<blocco>/<blocco>_activity.pdf`: PDF attività con traccia, suggerimenti e soluzione.
- `activities/<blocco>/solution.sql`: soluzione SQL caricabile nel DBMS per i blocchi 4-12.
- `slides/blocks/block03_normalizzazione_schema/block03_normalizzazione_schema_casi_studio.pdf`: casi di studio aggiuntivi per il blocco 3.
- `activities/block03_normalizzazione_schema/block03_normalizzazione_schema_casi_studio_handout.pdf`: handout dei casi di studio del blocco 3.
- `activities/block03_normalizzazione_schema/block03_normalizzazione_schema_postgresql_docker.pdf`: guida Docker/PostgreSQL per testare creazione tabelle e query nel blocco 3.
- `activities/block03_normalizzazione_schema/postgresql_docker_test.sql`: script SQL di test per la guida Docker/PostgreSQL del blocco 3.
- `slides/blocks/block04_select_sql_base/block04_select_sql_base_introduzione_sql.pdf`: introduzione progressiva a SQL per il blocco 4.
- `activities/block04_select_sql_base/block04_select_sql_base_introduzione_sql_handout.pdf`: handout dell'introduzione SQL del blocco 4.
- `slides/blocks/block05_join_cardinalita/block05_join_cardinalita_introduzione_join.pdf`: introduzione progressiva ai JOIN per il blocco 5.
- `activities/block05_join_cardinalita/block05_join_cardinalita_introduzione_join_handout.pdf`: handout dell'introduzione ai JOIN del blocco 5.
- `activities/block05_join_cardinalita/introduzione_join_examples.sql`: esempi SQL eseguibili per l'introduzione ai JOIN del blocco 5.
- `activities/common/activity_preamble.tex`: stile condiviso dei PDF attività.
- `sql/00_schema_and_all_solutions_postgres.sql`: script unico con schema, dati e tutte le query soluzione.
- `sql/01_schema_seed_postgres.sql`: schema e dati di laboratorio per PostgreSQL.
- `sql/02_labs.sql`: tracce operative SQL per i blocchi 4-12.
- `sql/03_solutions.sql`: soluzioni SQL di riferimento.
- `instructor_guide.md`: guida docente con ritmo, checkpoint e valutazione.
- `scripts/generate_didactic_material.py`: generatore dei sorgenti Beamer e dei PDF activity secondo il formato didattico comune.
- `Makefile`: build dei PDF.

## Blocchi

| Blocco | Tema | PDF | Attivita | Soluzione |
| --- | --- | --- | --- | --- |
| 1 | dalla tabella singola alle relazioni | `slides/blocks/block01_dominio_relazioni/block01_dominio_relazioni.pdf` | `activities/block01_dominio_relazioni/activity.md` | `activities/block01_dominio_relazioni/solution.md` |
| 2 | chiavi, domini, integrità | `slides/blocks/block02_chiavi_vincoli_integrita/block02_chiavi_vincoli_integrita.pdf` | `activities/block02_chiavi_vincoli_integrita/activity.md` | `activities/block02_chiavi_vincoli_integrita/solution.md` |
| 3 | normalizzazione e schema relazionale | `slides/blocks/block03_normalizzazione_schema/block03_normalizzazione_schema.pdf` | `activities/block03_normalizzazione_schema/activity.md` | `activities/block03_normalizzazione_schema/solution.md` |
| 4 | prime query SQL | `slides/blocks/block04_select_sql_base/block04_select_sql_base.pdf` | `activities/block04_select_sql_base/activity.md` | `activities/block04_select_sql_base/solution.md` |
| 5 | JOIN e cardinalità | `slides/blocks/block05_join_cardinalita/block05_join_cardinalita.pdf` | `activities/block05_join_cardinalita/activity.md` | `activities/block05_join_cardinalita/solution.md` |
| 6 | aggregazioni e KPI | `slides/blocks/block06_aggregazioni_kpi/block06_aggregazioni_kpi.pdf` | `activities/block06_aggregazioni_kpi/activity.md` | `activities/block06_aggregazioni_kpi/solution.md` |
| 7 | DDL, DML e transazioni | `slides/blocks/block07_ddl_dml_transazioni/block07_ddl_dml_transazioni.pdf` | `activities/block07_ddl_dml_transazioni/activity.md` | `activities/block07_ddl_dml_transazioni/solution.md` |
| 8 | subquery e logica insiemistica | `slides/blocks/block08_subquery_set_logic/block08_subquery_set_logic.pdf` | `activities/block08_subquery_set_logic/activity.md` | `activities/block08_subquery_set_logic/solution.md` |
| 9 | CTE, viste e mantenibilità | `slides/blocks/block09_cte_viste_mantenibilita/block09_cte_viste_mantenibilita.pdf` | `activities/block09_cte_viste_mantenibilita/activity.md` | `activities/block09_cte_viste_mantenibilita/solution.md` |
| 10 | window function | `slides/blocks/block10_window_functions/block10_window_functions.pdf` | `activities/block10_window_functions/activity.md` | `activities/block10_window_functions/solution.md` |
| 11 | performance, EXPLAIN e indici | `slides/blocks/block11_performance_explain_indici/block11_performance_explain_indici.pdf` | `activities/block11_performance_explain_indici/activity.md` | `activities/block11_performance_explain_indici/solution.md` |
| 12 | capstone query design | `slides/blocks/block12_capstone_query_design/block12_capstone_query_design.pdf` | `activities/block12_capstone_query_design/activity.md` | `activities/block12_capstone_query_design/solution.md` |

Ogni deck contiene:

- rappresentazione iniziale semplice, spesso una tabella unica o una soluzione ingenua;
- discussione dei limiti: duplicazione, spreco, rigidità, ambiguità o scarsa verificabilità;
- introduzione di una soluzione più generale e flessibile;
- formalizzazione dei concetti emersi dall'esempio;
- analogia o caso esplicativo per rendere il concetto meno astratto;
- esempio guidato con ragionamento e implementazione o artefatto;
- pratica guidata con problema informale, specifica corretta, definizione della soluzione e implementazione completa;
- errori frequenti e criteri di verifica;
- checkpoint finale.

## Attività pratiche

Le attività sono raccolte in modo esplicito in `activities/`, separate dalle slide. Per ogni blocco 30-90:

- aprire il PDF del blocco per la parte teoria e per la presentazione in aula;
- distribuire `activities/<blocco>/<blocco>_activity.pdf` come handout pratico con traccia, suggerimenti e soluzione;
- usare `activities/<blocco>/activity.md` come traccia pratica da assegnare agli studenti;
- usare `activities/<blocco>/solution.md` come soluzione guidata per docente e discussione finale;
- per i blocchi 4-12, usare `activities/<blocco>/solution.sql` come soluzione SQL del singolo blocco;
- per caricare tutto in un DBMS PostgreSQL, usare `sql/00_schema_and_all_solutions_postgres.sql`.

L'indice completo delle consegne è in `activities/README.md`.

## Build PDF

```bash
make
```

I PDF slide e i PDF attività vengono generati nelle rispettive cartelle di blocco.

Per rigenerare i sorgenti didattici prima della build:

```bash
python scripts/generate_didactic_material.py
```

Per compilare un singolo blocco:

```bash
cd slides/blocks/block04_select_sql_base
latexmk -pdf -jobname=block04_select_sql_base -interaction=nonstopmode main.tex
```

Per compilare un singolo PDF attività:

```bash
cd activities/block04_select_sql_base
latexmk -pdf -jobname=block04_select_sql_base_activity -interaction=nonstopmode main.tex
```

Per compilare i materiali aggiuntivi dei blocchi 3, 4 e 5:

```bash
make extras
```

La guida operativa per usare PostgreSQL in Docker nel blocco 3 è in:

```text
activities/block03_normalizzazione_schema/block03_normalizzazione_schema_postgresql_docker.pdf
```

Lo script di test collegato è in:

```text
activities/block03_normalizzazione_schema/postgresql_docker_test.sql
```

## Setup laboratorio PostgreSQL

Esempio con `psql`:

```bash
createdb sql_training
psql -d sql_training -f sql/01_schema_seed_postgres.sql
```

Poi usare:

```bash
psql -d sql_training -f sql/02_labs.sql
```

Il file dei laboratori contiene tracce commentate. Le soluzioni sono in `sql/03_solutions.sql` e, per blocco, in `activities/<blocco>/solution.sql`.

Per caricare schema, dati e tutte le soluzioni in un'unica esecuzione:

```bash
psql -d sql_training -f sql/00_schema_and_all_solutions_postgres.sql
```

Per un laboratorio senza installare PostgreSQL localmente, usare la guida Docker del blocco 3:

```bash
docker run --name rdsql-postgres \
  -e POSTGRES_USER=training \
  -e POSTGRES_PASSWORD=training \
  -e POSTGRES_DB=training \
  -p 5432:5432 \
  -d postgres:16

docker exec -i rdsql-postgres psql -U training -d training \
  < activities/block03_normalizzazione_schema/postgresql_docker_test.sql
```
