# Blocco 7 -- Gentle Introduction: DDL, DML e transazioni

    Finora abbiamo letto dati. Ora dobbiamo creare tabelle, inserire righe, aggiornare valori e annullare modifiche non corrette.

    Le query dei blocchi precedenti diventano strumenti di controllo prima e dopo una modifica.

    ## Sintassi essenziale

    ```sql
    BEGIN;

SELECT ... FROM tabella WHERE condizione;

UPDATE tabella
SET colonna = nuovo_valore
WHERE condizione
RETURNING colonne;

ROLLBACK;
    ```

    ## Come leggere la sintassi

    - `CREATE TABLE` definisce una struttura.
- `INSERT` aggiunge righe.
- `UPDATE` modifica righe esistenti.
- `DELETE` cancella righe.
- `BEGIN`, `COMMIT`, `ROLLBACK` delimitano una transazione.

## Ciclo sicuro di una modifica

1. Leggere le righe candidate con una `SELECT`.
2. Controllare conteggio e valori.
3. Aprire una transazione con `BEGIN`.
4. Eseguire `INSERT`, `UPDATE` o `DELETE`.
5. Usare `RETURNING` per vedere cosa è cambiato.
6. Concludere con `ROLLBACK` in test o `COMMIT` se la modifica deve restare.

## DDL: progettare prima di creare

- Il tipo della colonna limita i valori ammessi.
- `PRIMARY KEY` identifica una riga.
- `REFERENCES` mantiene il collegamento con una tabella padre.
- `CHECK` rende esplicite regole di dominio.
- `DEFAULT` assegna un valore quando l'utente non lo specifica.

    ## Creare una tabella di audit

```sql
CREATE TABLE IF NOT EXISTS product_price_audit (
  audit_id bigserial PRIMARY KEY,
  product_id integer NOT NULL REFERENCES products(product_id),
  old_price numeric(10, 2) NOT NULL,
  new_price numeric(10, 2) NOT NULL,
  reason text NOT NULL DEFAULT 'not specified',
  changed_at timestamp NOT NULL DEFAULT now()
);
```

## Aggiornamento controllato con rollback

```sql
BEGIN;

SELECT product_id, sku, unit_price
FROM products
WHERE category = 'accessories' AND active = true
ORDER BY product_id;

UPDATE products
SET unit_price = round(unit_price * 1.05, 2)
WHERE category = 'accessories' AND active = true
RETURNING product_id, sku, unit_price;

ROLLBACK;
```

## Inserimento controllato

```sql
BEGIN;

INSERT INTO products (product_id, sku, product_name, category, unit_price, active)
VALUES (1000, 'LAB-SVC', 'Laboratory Service', 'services', 250.00, true)
RETURNING product_id, sku, product_name;

ROLLBACK;
```

## Cancellazione controllata

```sql
BEGIN;

SELECT product_id, sku
FROM products
WHERE sku = 'LAB-SVC';

DELETE FROM products
WHERE sku = 'LAB-SVC'
RETURNING product_id, sku, product_name;

ROLLBACK;
```

    ## Esercizio con rappresentazione tabellare

    | product_id | sku | category | unit_price |
| --- | --- | --- | --- |
| 4 | KEY-MECH | accessories | 99.00 |
| 5 | MOU-WL | accessories | 39.00 |
| 7 | BAG-15 | accessories | 79.00 |

    Richiesta: Data la tabella prodotti, costruire una procedura SQL che aumenti del 5% i prodotti accessori attivi, mostri le righe cambiate e permetta rollback.

    ## Errori frequenti

    - eseguire `UPDATE` o `DELETE` senza `WHERE`;
- non contare le righe candidate prima della modifica;
- fare test senza transazione;
- dimenticare vincoli di chiave e vincoli di dominio;
- non usare `RETURNING` quando serve vedere cosa è cambiato.
