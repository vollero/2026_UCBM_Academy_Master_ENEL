# Blocco 7 - DDL, DML e transazioni

## 1. Problema in forma informale
Il product manager chiede una nuova tabella per audit prezzi e un aggiornamento controllato di alcuni prodotti. La consegna richiede procedura e controlli, non solo l'istruzione finale.

## 2. Specifica corretta del problema
- input: tabella `products` e categoria scelta;
- output: tabella audit, righe inserite, aggiornamento controllato e verifica;
- vincolo: tutto deve avvenire dentro una transazione;
- vincolo: la soluzione deve poter essere annullata con `ROLLBACK` durante il test.

## 3. Definizione della soluzione
1. creare tabella audit con riferimenti al prodotto;
2. selezionare i prodotti candidati prima dell'update;
3. aggiornare con `RETURNING`;
4. scegliere `ROLLBACK` in laboratorio oppure `COMMIT` solo dopo verifica.

## 4. Implementazione completa o artefatto atteso
Soluzione caricabile nel container PostgreSQL Docker dopo lo schema di laboratorio.

```sql
SET search_path TO training;

BEGIN;

SELECT product_id, sku, unit_price
FROM products
WHERE category = 'accessories' AND active
ORDER BY product_id;

CREATE TABLE IF NOT EXISTS product_price_audit (
    audit_id bigserial PRIMARY KEY,
    product_id integer NOT NULL REFERENCES products(product_id),
    old_price numeric(10,2) NOT NULL,
    new_price numeric(10,2) NOT NULL,
    reason text NOT NULL,
    changed_at timestamp NOT NULL DEFAULT now()
);


WITH candidates AS (
    SELECT product_id, unit_price AS old_price,
           round(unit_price * 1.05, 2) AS new_price
    FROM products
    WHERE category = 'accessories' AND active
), changed AS (
    UPDATE products p
    SET unit_price = c.new_price
    FROM candidates c
    WHERE c.product_id = p.product_id
    RETURNING p.product_id, c.old_price, p.unit_price AS new_price
)
INSERT INTO product_price_audit(product_id, old_price, new_price, reason)
SELECT product_id, old_price, new_price, 'annual price review'
FROM changed;

SELECT * FROM product_price_audit ORDER BY audit_id DESC;

ROLLBACK;
```

## 5. Criteri di verifica
- la modifica è preceduta da una query di selezione equivalente;
- il numero di righe modificate è atteso;
- la transazione termina con una decisione esplicita;
- gli effetti sono verificati con query successive.

## 6. Checkpoint
- una modifica dati senza pre-controllo non è una soluzione didattica accettabile;
- la transazione rende esplicito il momento in cui ci si assume responsabilità;
- DDL e DML vanno trattati come parte del modello operativo.
