# Blocco 2 - Chiavi, domini e integrità

## 1. Problema in forma informale
Riprendendo il modello del blocco 1, il responsabile dati chiede che il database rifiuti errori comuni prima che arrivino nei report.

## 2. Specifica corretta del problema
- input: relazioni candidate del blocco 1;
- output: chiavi primarie, chiavi candidate, chiavi esterne, domini e vincoli;
- vincolo: distinguere regole implementabili subito e regole da gestire a livello applicativo;
- vincolo: ogni `NULL` deve avere una motivazione di dominio.

## 3. Definizione della soluzione
1. usare surrogate key per riferimenti stabili quando la chiave naturale può cambiare;
2. conservare `UNIQUE` su email, SKU o codici esterni quando il business lo richiede;
3. rendere obbligatorie le relazioni senza cui il fatto non esiste;
4. decidere politiche conservative per cancellazioni di fatti storici.

## 4. Implementazione completa o artefatto atteso
Per questo blocco l'implementazione è un artefatto di modellazione, non uno script SQL.

- `customers`: PK `customer_id`, UNIQUE `email`, `country NOT NULL`
- `products`: PK `product_id`, UNIQUE `sku`, `unit_price >= 0`
- `orders`: PK `order_id`, FK obbligatoria verso `customers`
- `order_items`: FK verso `orders` e `products`, `quantity > 0`
- `shipments`: FK verso `orders`, `delivered_at` opzionale fino alla consegna

## 5. Criteri di verifica
- ogni relazione ha una chiave primaria non ambigua;
- le chiavi esterne riflettono relazioni obbligatorie o opzionali;
- i domini impediscono valori fuori significato;
- le decisioni su cancellazione e storia sono documentate.

## 6. Checkpoint
- un vincolo non è burocrazia: è una frase del dominio resa controllabile;
- una chiave surrogate semplifica i join, ma non protegge da duplicati business;
- `NULL` va usato per informazione assente, non per indecisione progettuale.
