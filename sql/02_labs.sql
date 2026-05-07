-- Relational Databases & SQL - tracce laboratori SQL
-- I blocchi 1-3 sono laboratori di modellazione nelle rispettive slide PDF.
-- Prima eseguire: sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- ============================================================
-- Blocco 4 - Prime query SQL
-- ============================================================
-- 4.1 Esplorare tabelle e colonne del dataset.
-- 4.2 Mostrare i prodotti attivi ordinati dal prezzo piu alto.
-- 4.3 Mostrare i clienti italiani oppure iscritti a febbraio 2025.
-- 4.4 Mostrare gli ordini non conclusi: pending, cancelled, refunded.
-- 4.5 Calcolare il netto di ogni riga ordine:
--     quantity * unit_price * (1 - discount_pct / 100).
-- 4.6 Trovare spedizioni non ancora consegnate.
-- 4.7 Extra: costruire una colonna price_band con CASE.

-- ============================================================
-- Blocco 5 - JOIN e cardinalita
-- ============================================================
-- 5.1 Unire ordini, clienti e vista order_revenue.
-- 5.2 Elencare tutti i clienti con numero ordini e ricavo totale, inclusi clienti senza ordini.
-- 5.3 Trovare prodotti mai venduti.
-- 5.4 Elencare spedizioni con cliente, paese e giorni di consegna.
-- 5.5 Mostrare il rischio fan-out: ordini + righe ordine + ticket.
-- 5.6 Correggere il fan-out aggregando prima di fare JOIN.

-- ============================================================
-- Blocco 6 - Aggregazioni e KPI
-- ============================================================
-- 6.1 Ricavo mensile per canale.
-- 6.2 Ricavo per paese escludendo cancelled e refunded.
-- 6.3 Segmenti con almeno 2 ordini validi: numero ordini, ricavo, AOV.
-- 6.4 Quantita e ricavo per categoria prodotto.
-- 6.5 Tempo medio di risoluzione ticket per priorita.
-- 6.6 Extra: usare FILTER per contare stati ordine diversi nella stessa query.

-- ============================================================
-- Blocco 7 - DDL, DML e transazioni
-- ============================================================
-- 7.1 Esplorare tabelle e colonne tramite information_schema.
-- 7.2 Identificare primary key, foreign key e vincoli CHECK nello schema.
-- 7.3 Creare una tabella temporanea per annotazioni corso.
-- 7.4 Inserire righe valide e ragionare su righe non valide.
-- 7.5 Inserire un nuovo ordine dentro una transazione e verificarlo.
-- 7.6 Eseguire UPDATE FROM usando una tabella temporanea di variazioni prezzo.
-- 7.7 Provare INSERT ... ON CONFLICT su una tabella temporanea.
-- 7.8 Cancellare in modo controllato dati temporanei con DELETE ... RETURNING.

-- ============================================================
-- Blocco 8 - Subquery e logica insiemistica
-- ============================================================
-- 8.1 Clienti con almeno un ordine sopra il ricavo medio di tutti gli ordini.
-- 8.2 Prodotti venduti almeno una volta a clienti enterprise.
-- 8.3 Clienti senza ordini completed o shipped.
-- 8.4 Ordini con ricavo superiore alla media ordini dello stesso cliente.
-- 8.5 Riscrivere una query IN come EXISTS.
-- 8.6 Usare UNION ALL per costruire un elenco eventi cliente: ordini e ticket.
-- 8.7 Extra: spiegare perche NOT IN e NULL sono una combinazione pericolosa.

-- ============================================================
-- Blocco 9 - CTE, viste e query mantenibili
-- ============================================================
-- 9.1 Separare in CTE: righe nette, ordini validi, ricavo mensile.
-- 9.2 Costruire un calendario mensile con generate_series.
-- 9.3 Fare LEFT JOIN tra calendario e ricavo per includere mesi senza vendite.
-- 9.4 Usare una CTE per isolare i clienti top e poi dettagliare i loro ordini.
-- 9.5 Creare una vista di reporting che non espone email.
-- 9.6 Extra: creare una CTE ricorsiva che genera i numeri da 1 a 12.

-- ============================================================
-- Blocco 10 - Window function
-- ============================================================
-- 10.1 Classificare gli ordini per ricavo dentro ogni paese.
-- 10.2 Calcolare ricavo cumulato mese per mese.
-- 10.3 Per ogni cliente, mostrare ordine corrente, ordine precedente e giorni intercorsi.
-- 10.4 Calcolare media mobile a 3 mesi del ricavo.
-- 10.5 Top 2 prodotti per ricavo dentro ogni categoria.
-- 10.6 Gap analysis: clienti con piu di 45 giorni tra due ordini.

-- ============================================================
-- Blocco 11 - Performance, EXPLAIN e indici
-- ============================================================
-- 11.1 Usare EXPLAIN su una query filtrata per date.
-- 11.2 Creare un indice su orders(order_date) e confrontare il piano.
-- 11.3 Creare un indice composito per customer_id + order_date.
-- 11.4 Creare un indice parziale sugli ordini validi.
-- 11.5 Riscrivere un filtro non sargable in forma sargable.
-- 11.6 Extra: discutere quando un indice peggiora il sistema.

-- ============================================================
-- Blocco 12 - Capstone
-- ============================================================
-- 12.1 Customer 360: ordini, ricavo, ultimo ordine, ticket aperti, rank cliente.
-- 12.2 Product portfolio: quantita, ricavo, rank per categoria, stock stimato.
-- 12.3 Delivery & Support: spedizioni aperte o consegnate oltre 5 giorni con ticket.
-- 12.4 Dashboard mensile: ricavo, ordini, AOV, crescita mese su mese, cumulato.
-- 12.5 Aggiungere due query di controllo per la traccia scelta.
-- 12.6 Extra: trasformare una query finale in vista materializzata.
