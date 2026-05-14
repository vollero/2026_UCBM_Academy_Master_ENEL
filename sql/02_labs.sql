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
-- Blocco 9 - Architettura dati containerizzata con DBMS
-- ============================================================
-- Usare lo stack dedicato:
-- docker compose -f docker-compose.ticketing.yml up -d
-- docker exec -i rdsql-ticket-postgres psql -U training -d training < sql/ticket_architecture_schema.sql
--
-- 9.1 Descrivere i servizi: collector simulato, PostgreSQL, Metabase.
-- 9.2 Distinguere dati raw, dati curati e viste di dashboard.
-- 9.3 Verificare chiavi e vincoli dello schema ticketing.
-- 9.4 Eseguire una query di controllo tra support_tickets_raw e support_tickets.
-- 9.5 Eseguire il collector manualmente con ticket_collector_tick.sql.
-- 9.6 Extra: proporre una nuova tabella o vista senza rompere la dashboard.

-- ============================================================
-- Blocco 10 - Query SQL per dashboard Metabase
-- ============================================================
-- 10.1 Costruire una scheda KPI con volume, arretrato e ticket critici.
-- 10.2 Costruire un andamento giornaliero da dashboard_daily_flow.
-- 10.3 Costruire una distribuzione per priorita e stato.
-- 10.4 Calcolare tempi medi di risoluzione per priorita e regione.
-- 10.5 Calcolare ranking delle categorie e media mobile a 3 giorni.
-- 10.6 Extra: trasformare una query in domanda parametrica Metabase.

-- ============================================================
-- Blocco 11 - Performance di un DBMS per dashboard
-- ============================================================
-- 11.1 Usare EXPLAIN su una query filtrata per date e stato.
-- 11.2 Creare indici coerenti con i filtri usati dalla dashboard.
-- 11.3 Confrontare piano prima e dopo un indice composito.
-- 11.4 Creare un indice parziale per ticket aperti e critici.
-- 11.5 Costruire e aggiornare una vista materializzata di KPI giornalieri.
-- 11.6 Extra: discutere quando un indice o una materialized view peggiora il sistema.

-- ============================================================
-- Blocco 12 - Capstone architettura DBMS e dashboard
-- ============================================================
-- 12.1 Avviare l'intera architettura containerizzata.
-- 12.2 Caricare schema, dati iniziali e simulazione collector.
-- 12.3 Collegare Metabase a PostgreSQL.
-- 12.4 Costruire almeno quattro card SQL: KPI, trend, distribuzione e dettaglio.
-- 12.5 Definire due query di controllo per verificare coerenza raw/curated.
-- 12.6 Generare un carico storico con ticket_load_generate.sql.
-- 12.7 Confrontare EXPLAIN prima/dopo gli indici con ticket_index_tradeoff.sql.
-- 12.8 Discutere trade-off: lettura dashboard, costo scrittura, spazio e manutenzione.
-- 12.9 Extra: documentare una variante architetturale replicabile.
