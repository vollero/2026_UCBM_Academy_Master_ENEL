# Blocco 8 - Subquery e logica insiemistica

## 1. Problema in forma informale
Marketing e operations chiedono segmenti particolari: clienti con ordini sopra media, prodotti mai venduti, clienti senza ticket e ordini senza pagamento.

## 2. Specifica corretta del problema
- input: tabelle e vista `order_revenue`;
- output: query con subquery o operatori insiemistici coerenti con la frase;
- vincolo: usare `NOT EXISTS` per assenze quando ci sono possibili `NULL`;
- vincolo: motivare la scelta tra join, subquery e operatore insiemistico.

## 3. Definizione della soluzione
1. partire dal soggetto della domanda;
2. scrivere la subquery interna separatamente quando non è correlata;
3. trasformare "non hanno" in `NOT EXISTS`;
4. usare `EXCEPT` per differenze esplicite tra insiemi.

## 4. Implementazione completa o artefatto atteso
Soluzione caricabile nel container PostgreSQL Docker dopo lo schema di laboratorio.

```sql
SET search_path TO training;

SELECT c.customer_id, c.full_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM order_revenue r
    WHERE r.customer_id = c.customer_id
      AND r.status NOT IN ('cancelled', 'refunded')
      AND r.gross_revenue > (
          SELECT avg(gross_revenue)
          FROM order_revenue
          WHERE status NOT IN ('cancelled', 'refunded')
      )
)
ORDER BY c.full_name;


SELECT p.product_id, p.sku, p.product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
)
ORDER BY p.sku;

SELECT customer_id
FROM customers
EXCEPT
SELECT DISTINCT customer_id
FROM support_tickets
ORDER BY customer_id;
```

## 5. Criteri di verifica
- il soggetto della query esterna è chiaro;
- il quantificatore business è espresso dalla clausola corretta;
- la subquery è testabile anche da sola quando possibile;
- `NULL` e assenze sono gestiti intenzionalmente.

## 6. Checkpoint
- subquery e insiemi servono quando la domanda parla di esistenza, assenza o confronto;
- `EXISTS` legge la domanda come "c'è almeno una riga?";
- le assenze vanno trattate con cura per non confondere `NULL` e mancata corrispondenza.
