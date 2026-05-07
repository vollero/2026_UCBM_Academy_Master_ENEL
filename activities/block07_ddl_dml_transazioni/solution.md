# Soluzione - Blocco 7 - DDL, DML e transazioni

## Strategia
1. creare tabella audit con riferimenti al prodotto;
2. selezionare i prodotti candidati prima dell'update;
3. aggiornare con `RETURNING`;
4. scegliere `ROLLBACK` in laboratorio oppure `COMMIT` solo dopo verifica.

## Soluzione completa
```sql
SET search_path TO training;

BEGIN;

SELECT product_id, sku, unit_price
FROM products
WHERE category = 'Sensors' AND active
ORDER BY product_id;

CREATE TABLE IF NOT EXISTS product_price_audit (
    audit_id bigserial PRIMARY KEY,
    product_id bigint NOT NULL REFERENCES products(product_id),
    old_price numeric(10,2) NOT NULL,
    new_price numeric(10,2) NOT NULL,
    changed_at timestamp NOT NULL DEFAULT now()
);


WITH candidates AS (
    SELECT product_id, unit_price AS old_price,
           round(unit_price * 1.05, 2) AS new_price
    FROM products
    WHERE category = 'Sensors' AND active
), changed AS (
    UPDATE products p
    SET unit_price = c.new_price
    FROM candidates c
    WHERE c.product_id = p.product_id
    RETURNING p.product_id, c.old_price, p.unit_price AS new_price
)
INSERT INTO product_price_audit(product_id, old_price, new_price)
SELECT product_id, old_price, new_price
FROM changed;

SELECT * FROM product_price_audit ORDER BY audit_id DESC;

ROLLBACK;
```

## Perché la soluzione è corretta
- la modifica è preceduta da una query di selezione equivalente;
- il numero di righe modificate è atteso;
- la transazione termina con una decisione esplicita;
- gli effetti sono verificati con query successive.

## Errori da discutere
- eseguire `UPDATE` o `DELETE` senza `WHERE`;
- non controllare quante righe saranno modificate;
- confondere test con modifica definitiva;
- non registrare modifiche business rilevanti;
- aggiungere vincoli senza verificare i dati esistenti.

## Checkpoint
- una modifica dati senza pre-controllo non è una soluzione didattica accettabile;
- la transazione rende esplicito il momento in cui ci si assume responsabilità;
- DDL e DML vanno trattati come parte del modello operativo.
