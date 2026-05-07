# Blocco 7 -- Esercitazioni Docker

    Tema: CREATE TABLE, INSERT, UPDATE, DELETE, RETURNING, ROLLBACK

    Caricare lo schema:

    ```bash
    docker exec -i rdsql-postgres psql -U training -d training < sql/01_schema_seed_postgres.sql
    ```

    Eseguire le soluzioni:

    ```bash
    docker exec -i rdsql-postgres psql -U training -d training < activities/block07_ddl_dml_transazioni/docker_exercises.sql
    ```

    ## Rappresentazione tabellare

    Tabella o vista di riferimento: `products`

    | product_id | sku | category | unit_price | active |
| --- | --- | --- | --- | --- |
| 4 | KEY-MECH | accessories | 99.00 | true |
| 5 | MOU-WL | accessories | 39.00 | true |
| 7 | BAG-15 | accessories | 79.00 | true |
| 12 | HEAD-ANC | accessories | 179.00 | true |

    ## Esercizio 1 -- Audit prezzi

        Problema informale: Creare una tabella di audit prezzi con riferimento al prodotto.

        Soluzione:

        ```sql
        CREATE TABLE IF NOT EXISTS product_price_audit (
  audit_id bigserial PRIMARY KEY,
  product_id integer NOT NULL REFERENCES products(product_id),
  old_price numeric(10, 2) NOT NULL,
  new_price numeric(10, 2) NOT NULL,
  changed_at timestamp NOT NULL DEFAULT now()
);
        ```

## Esercizio 2 -- Update controllato

        Problema informale: Dentro una transazione, aumentare del 5% gli accessori attivi e mostrare le righe modificate.

        Soluzione:

        ```sql
        BEGIN;

UPDATE products
SET unit_price = round(unit_price * 1.05, 2)
WHERE category = 'accessories'
  AND active = true
RETURNING product_id, sku, unit_price;

ROLLBACK;
        ```

## Esercizio 3 -- Inserimento di test

        Problema informale: Inserire un prodotto di test dentro una transazione e annullare la modifica.

        Soluzione:

        ```sql
        BEGIN;

INSERT INTO products (product_id, sku, product_name, category, unit_price, active)
VALUES (1000, 'LAB-SVC', 'Laboratory Service', 'services', 250.00, true)
RETURNING product_id, sku, product_name;

ROLLBACK;
        ```
