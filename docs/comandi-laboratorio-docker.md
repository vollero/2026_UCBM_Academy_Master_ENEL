# Comandi Rapidi Laboratorio Docker/PostgreSQL

Questa pagina raccoglie i comandi da copiare e incollare durante il laboratorio.

Salvo dove indicato diversamente, i comandi `bash` vanno eseguiti dalla cartella principale della repository.

## Scaricare Il Materiale

```bash
git clone https://github.com/vollero/2026_UCBM_Academy_Master_ENEL.git
cd 2026_UCBM_Academy_Master_ENEL
```

## Avviare PostgreSQL In Docker

```bash
docker compose up -d postgres
```

```bash
docker compose ps
```

```bash
docker logs rdsql-postgres
```

## Entrare E Uscire Da psql

```bash
docker exec -it rdsql-postgres psql -U training -d training
```

Dentro `psql`:

```sql
\q
```

## Comandi psql Da Mostrare In Aula

Dentro `psql`:

```sql
\conninfo
\l
\dn
SET search_path TO training;
\dt
\d products
\d sales
\d sale_items
\pset pager off
\timing on
SELECT current_database();
SELECT current_schema();
SELECT COUNT(*) AS products_count FROM products;
SELECT * FROM products LIMIT 5;
SELECT * FROM customers LIMIT 5;
```

## Caricare O Resettare Lo Schema Di Laboratorio

```bash
docker exec -i rdsql-postgres psql -U training -d training < sql/01_schema_seed_postgres.sql
```

Controllare le tabelle:

```bash
docker exec -it rdsql-postgres psql -U training -d training
```

Dentro `psql`:

```sql
SET search_path TO training;
\dt
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM sales;
SELECT COUNT(*) FROM sale_items;
```

## Eseguire Le Tracce SQL Generali

```bash
docker exec -i rdsql-postgres psql -U training -d training < sql/02_labs.sql
```

## Eseguire Tutte Le Soluzioni SQL

```bash
docker exec -i rdsql-postgres psql -U training -d training < sql/03_solutions.sql
```

## Caricare Schema, Dati E Soluzioni In Un Solo Passaggio

```bash
docker exec -i rdsql-postgres psql -U training -d training < sql/00_schema_and_all_solutions_postgres.sql
```

## Blocco 3: Test Normalizzazione

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block03_normalizzazione_schema/postgresql_docker_test.sql
```

Entrare nel database:

```bash
docker exec -it rdsql-postgres psql -U training -d training
```

Dentro `psql`:

```sql
SET search_path TO block03_lab;
\dt
\d customers
\d products
\d sales
\d sale_items
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM sale_items;
```

Ricostruire il report iniziale:

```sql
SELECT
  s.sale_id,
  s.sale_date,
  c.customer_name,
  c.city,
  p.sku,
  p.product_name,
  si.quantity,
  si.unit_price
FROM sales AS s
JOIN customers AS c
  ON c.customer_id = s.customer_id
JOIN sale_items AS si
  ON si.sale_id = s.sale_id
JOIN products AS p
  ON p.product_id = si.product_id
ORDER BY s.sale_id, si.line_no;
```

## Blocchi 4-8: Esercitazioni Docker

Prima di ogni esercitazione, se serve ripartire da dati puliti:

```bash
docker exec -i rdsql-postgres psql -U training -d training < sql/01_schema_seed_postgres.sql
```

Blocco 4:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block04_select_sql_base/docker_exercises.sql
```

Blocco 5:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block05_join_cardinalita/docker_exercises.sql
```

Blocco 6:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block06_aggregazioni_kpi/docker_exercises.sql
```

Blocco 7:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block07_ddl_dml_transazioni/docker_exercises.sql
```

Blocco 8:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block08_subquery_set_logic/docker_exercises.sql
```

## Esempi Guidati SQL Per Blocco

Blocco 4:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block04_select_sql_base/introduzione_sql_examples.sql
```

Blocco 5:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block05_join_cardinalita/introduzione_join_examples.sql
```

Blocco 6:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block06_aggregazioni_kpi/introduzione_aggregazioni_examples.sql
```

Blocco 7:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block07_ddl_dml_transazioni/introduzione_ddl_dml_examples.sql
```

Blocco 8:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block08_subquery_set_logic/introduzione_subquery_examples.sql
```

Blocco 9:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block09_cte_viste_mantenibilita/introduzione_cte_viste_examples.sql
```

Blocco 10:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block10_window_functions/introduzione_window_examples.sql
```

Blocco 11:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block11_performance_explain_indici/introduzione_performance_examples.sql
```

Blocco 12:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block12_capstone_query_design/introduzione_capstone_examples.sql
```

## Soluzioni SQL Per Blocco

Blocco 4:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block04_select_sql_base/solution.sql
```

Blocco 5:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block05_join_cardinalita/solution.sql
```

Blocco 6:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block06_aggregazioni_kpi/solution.sql
```

Blocco 7:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block07_ddl_dml_transazioni/solution.sql
```

Blocco 8:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block08_subquery_set_logic/solution.sql
```

Blocco 9:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block09_cte_viste_mantenibilita/solution.sql
```

Blocco 10:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block10_window_functions/solution.sql
```

Blocco 11:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block11_performance_explain_indici/solution.sql
```

Blocco 12:

```bash
docker exec -i rdsql-postgres psql -U training -d training < activities/block12_capstone_query_design/solution.sql
```

## Eseguire Una Query Singola Da Terminale

```bash
docker exec -it rdsql-postgres psql -U training -d training -c "SET search_path TO training; SELECT COUNT(*) FROM products;"
```

```bash
docker exec -it rdsql-postgres psql -U training -d training -c "SET search_path TO training; SELECT category, COUNT(*) FROM products GROUP BY category ORDER BY category;"
```

## Esportare Un Risultato In CSV

```bash
docker exec -i rdsql-postgres psql -U training -d training -c "\copy (SELECT product_id, sku, product_name, category, unit_price FROM training.products ORDER BY product_id) TO STDOUT WITH CSV HEADER" > products.csv
```

## Gestione Del Container

Fermare PostgreSQL:

```bash
docker compose stop postgres
```

Riavviare PostgreSQL:

```bash
docker compose up -d postgres
```

Vedere i container attivi:

```bash
docker ps
```

Vedere anche i container fermi:

```bash
docker ps -a
```

Leggere i log:

```bash
docker logs rdsql-postgres
```

Seguire i log in tempo reale:

```bash
docker logs -f rdsql-postgres
```

Controllare l'uso delle risorse:

```bash
docker stats rdsql-postgres
```

Rimuovere container e dati del laboratorio:

```bash
docker compose down -v
```

Ripartire da zero:

```bash
docker compose down -v
docker compose up -d postgres
docker exec -i rdsql-postgres psql -U training -d training < sql/01_schema_seed_postgres.sql
```

## Problemi Comuni

Se compare `relation does not exist`, entrare in `psql` e controllare schema e tabelle:

```sql
SET search_path TO training;
\dt
```

Se la porta `5432` è occupata, modificare `docker-compose.yml`:

```yaml
ports:
  - "15432:5432"
```

Poi riavviare:

```bash
docker compose down
docker compose up -d postgres
```

Se il container non risponde:

```bash
docker compose ps
docker logs rdsql-postgres
docker compose restart postgres
```
