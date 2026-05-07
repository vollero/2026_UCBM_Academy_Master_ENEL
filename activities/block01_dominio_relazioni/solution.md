# Soluzione - Blocco 1 - Dal dominio alle relazioni

## Strategia
1. partire dalla tabella unica e indicare quali colonne si ripetono;
2. separare prodotti, clienti, vendite, righe vendita e movimenti di magazzino;
3. usare identificatori per collegare righe vendita a prodotto e vendita;
4. distinguere prezzo di listino e prezzo effettivo della vendita;
5. validare lo schema con casi come prodotto mai venduto e vendita con più prodotti.

## Soluzione completa
- `customers`: `customer_id`, nome, città, email; una riga per cliente
- `products`: `product_id`, SKU, nome, categoria, prezzo di listino; una riga per prodotto
- `sales`: `sale_id`, cliente, data vendita; una riga per vendita
- `sale_items`: vendita, prodotto, quantità, prezzo effettivo; una riga per prodotto venduto
- `stock_movements`: prodotto, data, variazione, causale; una riga per movimento di magazzino

## Perché la soluzione è corretta
- ogni relazione ha una granularità dichiarata;
- ogni attributo appartiene al fatto corretto;
- ogni cardinalità è spiegabile con una frase di dominio;
- le assunzioni sono scritte e verificabili con un domain expert.

## Errori da discutere
- modellare direttamente il report richiesto dal manager;
- mettere più valori nella stessa cella, ad esempio tre prodotti in una colonna;
- confondere "cliente" con "ordine del cliente";
- non distinguere fatti correnti e fatti storici.

## Checkpoint
- se una riga non ha una definizione chiara, la relazione non è pronta;
- se una colonna contiene una lista, probabilmente manca una relazione;
- se una cardinalità non si riesce a dire a voce, va chiarita prima di passare a SQL.
