# Blocco 1 - Dal dominio alle relazioni

## 1. Problema in forma informale
Un piccolo negozio gestisce magazzino e vendite con un foglio unico. Ogni riga registra una vendita e contiene data, cliente, prodotto, categoria, prezzo, quantità e giacenza stimata. Il foglio funziona finché i dati sono pochi, ma appena crescono emergono duplicazioni e incoerenze.

## 2. Specifica corretta del problema
- input: tabella unica `vendite_magazzino` con dati cliente, prodotto, vendita e stock;
- output: riorganizzazione in più tabelle collegate;
- vincolo: ogni tabella deve rappresentare un solo tipo di informazione;
- vincolo: l'informazione del foglio iniziale deve essere ricostruibile tramite collegamenti;
- vincolo: scrivere la granularità di ogni tabella con la formula "una riga per ...".

## 3. Definizione della soluzione
1. partire dalla tabella unica e indicare quali colonne si ripetono;
2. separare prodotti, clienti, vendite, righe vendita e movimenti di magazzino;
3. usare identificatori per collegare righe vendita a prodotto e vendita;
4. distinguere prezzo di listino e prezzo effettivo della vendita;
5. validare lo schema con casi come prodotto mai venduto e vendita con più prodotti.

## 4. Implementazione completa o artefatto atteso
Per questo blocco l'implementazione è un artefatto di modellazione, non uno script SQL.

- `customers`: `customer_id`, nome, città, email; una riga per cliente
- `products`: `product_id`, SKU, nome, categoria, prezzo di listino; una riga per prodotto
- `sales`: `sale_id`, cliente, data vendita; una riga per vendita
- `sale_items`: vendita, prodotto, quantità, prezzo effettivo; una riga per prodotto venduto
- `stock_movements`: prodotto, data, variazione, causale; una riga per movimento di magazzino

## 5. Criteri di verifica
- ogni relazione ha una granularità dichiarata;
- ogni attributo appartiene al fatto corretto;
- ogni cardinalità è spiegabile con una frase di dominio;
- le assunzioni sono scritte e verificabili con un domain expert.

## 6. Checkpoint
- se una riga non ha una definizione chiara, la relazione non è pronta;
- se una colonna contiene una lista, probabilmente manca una relazione;
- se una cardinalità non si riesce a dire a voce, va chiarita prima di passare a SQL.
