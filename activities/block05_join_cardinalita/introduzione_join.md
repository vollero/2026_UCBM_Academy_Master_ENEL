# Blocco 5 -- Gentle Introduction ai JOIN

Materiale aggiuntivo per introdurre gradualmente `JOIN`, cardinalità, `INNER JOIN`, `LEFT JOIN` e controlli di fan-out, richiamando lo schema normalizzato del blocco 3.

## Idea generale

Nel blocco 3 abbiamo separato i dati in più relazioni per evitare duplicazioni e anomalie. Nel blocco 5 impariamo a ricomporre quelle relazioni quando una domanda richiede informazioni distribuite.

Schema di riferimento:

- `customers`: una riga per cliente;
- `products`: una riga per prodotto;
- `sales`: una riga per vendita;
- `sale_items`: una riga per prodotto venduto dentro una vendita.

Domanda guida: per ogni riga vendita vogliamo mostrare data vendita, cliente, città, prodotto, quantità e prezzo applicato.

## Sintassi base

```sql
SELECT colonne
FROM tabella_1 AS t1
JOIN tabella_2 AS t2
  ON t2.chiave = t1.chiave_esterna;
```

`FROM` sceglie la tabella di partenza. `JOIN` aggiunge una tabella collegata. `ON` dichiara la condizione di collegamento. `AS` assegna alias brevi.

## Primo esempio: vendite e clienti

Problema informale: mostrare ogni vendita con il nome e la città del cliente.

Specifica:

- granularità: una riga per vendita;
- tabella base: `sales`;
- tabella collegata: `customers`;
- collegamento: `sales.customer_id` punta a `customers.customer_id`.

Soluzione:

```sql
SELECT
  s.sale_id,
  s.sale_date,
  c.customer_name,
  c.city
FROM sales AS s
JOIN customers AS c
  ON c.customer_id = s.customer_id
ORDER BY s.sale_id;
```

## Secondo esempio: vendite e righe vendita

Problema informale: mostrare le righe contenute nelle vendite.

Specifica:

- granularità: una riga per riga vendita;
- una vendita può avere molte righe vendita;
- entrando nel lato molti, il numero di righe può aumentare.

Soluzione:

```sql
SELECT
  s.sale_id,
  s.sale_date,
  si.line_no,
  si.product_id,
  si.quantity
FROM sales AS s
JOIN sale_items AS si
  ON si.sale_id = s.sale_id
ORDER BY s.sale_id, si.line_no;
```

Controllo:

```sql
SELECT COUNT(*) AS sales_rows
FROM sales;

SELECT COUNT(*) AS joined_rows
FROM sales AS s
JOIN sale_items AS si
  ON si.sale_id = s.sale_id;
```

Se una vendita contiene più prodotti, dopo il join vedremo più righe per la stessa vendita. Questo comportamento si chiama fan-out.

## Ricostruire il report iniziale

Problema informale: viene mostrata una tabella unica con cliente, vendita e prodotto. Bisogna ricostruire lo stesso contenuto partendo dallo schema normalizzato.

Specifica:

- granularità: una riga per riga vendita;
- tabella base logica: `sale_items`;
- aggiungere `sales` per data e cliente;
- aggiungere `customers` per nome e città;
- aggiungere `products` per SKU e nome prodotto.

Soluzione:

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
FROM sale_items AS si
JOIN sales AS s
  ON s.sale_id = si.sale_id
JOIN customers AS c
  ON c.customer_id = s.customer_id
JOIN products AS p
  ON p.product_id = si.product_id
ORDER BY s.sale_id, si.line_no;
```

## INNER JOIN

`INNER JOIN` conserva solo le righe che trovano una corrispondenza nella tabella collegata.

Usarlo quando:

- il collegamento è obbligatorio;
- ci aspettiamo che ogni riga abbia una riga collegata;
- una mancata corrispondenza sarebbe un'anomalia o un caso da investigare.

Esempio:

```sql
SELECT si.sale_id, si.line_no, p.product_name
FROM sale_items AS si
JOIN products AS p
  ON p.product_id = si.product_id
ORDER BY si.sale_id, si.line_no;
```

## LEFT JOIN

`LEFT JOIN` conserva tutte le righe della tabella di sinistra, anche quando non esiste una corrispondenza nella tabella di destra.

Usarlo quando:

- il collegamento è opzionale;
- vogliamo mantenere anche righe senza dettaglio collegato;
- vogliamo cercare casi mancanti, come prodotti mai venduti o clienti senza vendite.

Prodotti mai venduti:

```sql
SELECT
  p.product_id,
  p.sku,
  p.product_name
FROM products AS p
LEFT JOIN sale_items AS si
  ON si.product_id = p.product_id
WHERE si.sale_id IS NULL
ORDER BY p.product_id;
```

Clienti senza vendite:

```sql
SELECT
  c.customer_id,
  c.customer_name,
  c.city
FROM customers AS c
LEFT JOIN sales AS s
  ON s.customer_id = c.customer_id
WHERE s.sale_id IS NULL
ORDER BY c.customer_id;
```

## Collegamenti opzionali: spedizioni

Problema informale: alcune vendite sono già state spedite, altre no. Vogliamo mostrare le vendite senza spedizione.

Specifica:

- granularità: una riga per vendita non spedita;
- tabella base: `sales`;
- collegamento opzionale: `shipments`;
- cercare i casi in cui la spedizione non esiste.

Soluzione:

```sql
SELECT
  s.sale_id,
  s.sale_date,
  c.customer_name
FROM sales AS s
JOIN customers AS c
  ON c.customer_id = s.customer_id
LEFT JOIN shipments AS sh
  ON sh.sale_id = s.sale_id
WHERE sh.shipment_id IS NULL
ORDER BY s.sale_id;
```

## Errore frequente: join senza condizione

Da evitare:

```sql
SELECT s.sale_id, c.customer_name
FROM sales AS s
JOIN customers AS c
  ON true;
```

Ogni vendita viene combinata con ogni cliente. Il risultato può avere molte righe, ma quelle righe non rappresentano collegamenti reali.

Forma corretta:

```sql
SELECT s.sale_id, c.customer_name
FROM sales AS s
JOIN customers AS c
  ON c.customer_id = s.customer_id;
```

## Query costruita per passaggi

Domanda: mostrare ogni riga vendita con cliente, prodotto e importo della riga.

Passo 1: granularità. Una riga per riga vendita.

Passo 2: tabella base.

```sql
SELECT *
FROM sale_items;
```

Passo 3: aggiungere vendita, cliente e prodotto.

```sql
SELECT
  si.sale_id,
  si.line_no,
  c.customer_name,
  p.product_name,
  si.quantity,
  si.unit_price,
  si.quantity * si.unit_price AS line_amount
FROM sale_items AS si
JOIN sales AS s
  ON s.sale_id = si.sale_id
JOIN customers AS c
  ON c.customer_id = s.customer_id
JOIN products AS p
  ON p.product_id = si.product_id
ORDER BY si.sale_id, si.line_no;
```

## Esercizi brevi con soluzione

Esercizio A: mostrare tutte le vendite con cliente e città.

```sql
SELECT s.sale_id, s.sale_date, c.customer_name, c.city
FROM sales AS s
JOIN customers AS c
  ON c.customer_id = s.customer_id
ORDER BY s.sale_id;
```

Esercizio B: mostrare tutte le righe vendita con nome prodotto e quantità.

```sql
SELECT si.sale_id, si.line_no, p.product_name, si.quantity
FROM sale_items AS si
JOIN products AS p
  ON p.product_id = si.product_id
ORDER BY si.sale_id, si.line_no;
```

Esercizio C: mostrare i clienti che non hanno vendite.

```sql
SELECT c.customer_id, c.customer_name, c.city
FROM customers AS c
LEFT JOIN sales AS s
  ON s.customer_id = c.customer_id
WHERE s.sale_id IS NULL
ORDER BY c.customer_id;
```

## Checklist

- La granularità del risultato è dichiarata?
- La tabella base corrisponde alla granularità desiderata?
- Ogni `JOIN` ha una condizione `ON` esplicita?
- Il tipo di join riflette un collegamento obbligatorio o opzionale?
- Il fan-out è previsto e controllato?
- Le colonne sono qualificate con alias leggibili?
