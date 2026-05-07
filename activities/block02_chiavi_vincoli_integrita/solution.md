# Soluzione - Blocco 2 - Chiavi, domini e integrità

## Strategia
1. usare surrogate key per riferimenti stabili quando la chiave naturale può cambiare;
2. conservare `UNIQUE` su email, SKU o codici esterni quando il business lo richiede;
3. rendere obbligatorie le relazioni senza cui il fatto non esiste;
4. decidere politiche conservative per cancellazioni di fatti storici.

## Soluzione completa
- `customers`: PK `customer_id`, UNIQUE `email`, `country NOT NULL`
- `products`: PK `product_id`, UNIQUE `sku`, `unit_price >= 0`
- `orders`: PK `order_id`, FK obbligatoria verso `customers`
- `order_items`: FK verso `orders` e `products`, `quantity > 0`
- `shipments`: FK verso `orders`, `delivered_at` opzionale fino alla consegna

## Perché la soluzione è corretta
- ogni relazione ha una chiave primaria non ambigua;
- le chiavi esterne riflettono relazioni obbligatorie o opzionali;
- i domini impediscono valori fuori significato;
- le decisioni su cancellazione e storia sono documentate.

## Errori da discutere
- lasciare tutto nullable per evitare decisioni;
- usare un campo descrittivo come chiave primaria;
- affidare tutte le regole al codice applicativo;
- introdurre una chiave surrogate e dimenticare l'unicita business.

## Checkpoint
- un vincolo non è burocrazia: è una frase del dominio resa controllabile;
- una chiave surrogate semplifica i join, ma non protegge da duplicati business;
- `NULL` va usato per informazione assente, non per indecisione progettuale.
