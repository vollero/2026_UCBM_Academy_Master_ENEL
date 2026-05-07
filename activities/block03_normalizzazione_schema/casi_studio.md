# Blocco 3 - Casi di studio aggiuntivi

Materiale per discussione guidata in aula su normalizzazione e schema relazionale.

## Procedimento comune

1. Definire la granularità iniziale con la frase "una riga per ...".
2. Cercare duplicazioni e colonne con valori multipli.
3. Scrivere dipendenze funzionali in linguaggio naturale.
4. Separare entità stabili, eventi e relazioni molti-a-molti.
5. Decidere quali attributi sono storici e devono restare nell'evento.
6. Verificare che il report iniziale sia ricostruibile tramite join.

## Caso 1 - Segreteria corsi

Problema: una tabella iscrizioni mescola studenti, corsi, docenti ed edizioni annuali.

Tabella iniziale:

| matricola | studente | email | corso | titolo | docente |
| --- | --- | --- | --- | --- | --- |
| S01 | Sara Bianchi | sara@mail | DB101 | Database | Neri |
| S01 | Sara Bianchi | sara@mail | AI201 | AI base | Rossi |
| S02 | Marco Verdi | marco@mail | DB101 | Database | Neri |
| S03 | Luca Neri | luca@mail | NET10 | Reti | Conti |

Domande guida:

- La riga rappresenta uno studente, un corso o un'iscrizione?
- Il docente descrive il corso in generale o l'edizione di un anno?
- Che cosa succede se cambia l'email di uno studente?
- Posso creare una nuova edizione di un corso senza iscritti?

Soluzione proposta:

- `students(student_id, matricola, name, email)`
- `courses(course_id, code, title)`
- `teachers(teacher_id, name, email)`
- `course_editions(edition_id, course_id, academic_year, teacher_id)`
- `enrollments(student_id, edition_id, enrolled_at, status, grade)`

## Caso 2 - Manutenzione impianti

Problema: una tabella interventi contiene impianti, sedi, tecnici e ricambi usati.

Tabella iniziale:

| intervento | data | impianto | sede | tecnico | ricambio |
| --- | --- | --- | --- | --- | --- |
| I100 | 12/05 | COMP-01 | Roma | Bianchi | Filtro A |
| I100 | 12/05 | COMP-01 | Roma | Bianchi | Guarnizione B |
| I101 | 13/05 | PUMP-07 | Napoli | Verdi | Olio X |
| I102 | 13/05 | COMP-01 | Roma | Neri | Filtro A |

Domande guida:

- La riga rappresenta un intervento o un ricambio usato?
- Dove vanno messi sede e modello dell'impianto?
- Un intervento senza ricambi è rappresentabile?
- Il costo del ricambio deve essere il prezzo corrente o quello usato nell'intervento?

Soluzione proposta:

- `sites(site_id, name, city)`
- `assets(asset_id, asset_code, site_id, model)`
- `technicians(technician_id, name, team)`
- `maintenance_jobs(job_id, asset_id, technician_id, opened_at, closed_at, job_type)`
- `spare_parts(part_id, part_code, description)`
- `job_parts(job_id, part_id, quantity, unit_cost)`

## Caso 3 - Fatture fornitore

Problema: una tabella fatture contiene dati correnti del fornitore e dati storici della fattura.

Tabella iniziale:

| fattura | fornitore | p. IVA | articolo | quantità | prezzo |
| --- | --- | --- | --- | --- | --- |
| F-77 | Alfa Srl | IT001 | Cavo 2m | 10 | 4.50 |
| F-77 | Alfa Srl | IT001 | Router B | 2 | 120.00 |
| F-78 | Beta Spa | IT099 | Sensore A | 5 | 35.00 |
| F-79 | Alfa Srl | IT001 | Cavo 2m | 20 | 4.30 |

Domande guida:

- Il prezzo della riga è un prezzo di listino o il prezzo fatturato?
- Se il fornitore cambia indirizzo, le vecchie fatture devono cambiare?
- Dove si registra la riga fattura?
- Quali duplicazioni sono errori e quali sono snapshot storici?

Soluzione proposta:

- `suppliers(supplier_id, vat_number, current_name, current_address)`
- `products(product_id, sku, current_name, category)`
- `purchase_invoices(invoice_id, supplier_id, invoice_number, invoice_date, supplier_name_snapshot, address_snapshot)`
- `purchase_invoice_lines(invoice_id, line_no, product_id, description_snapshot, quantity, unit_price)`

## Caso 4 - Biblioteca

Problema: una tabella prestiti mescola lettori, libri, copie fisiche e autori.

Tabella iniziale:

| prestito | lettore | ISBN | titolo | autore | copia |
| --- | --- | --- | --- | --- | --- |
| P01 | Sara | 978-1 | SQL Base | Neri | C001 |
| P02 | Marco | 978-1 | SQL Base | Neri | C002 |
| P03 | Sara | 978-2 | Data Model | Rossi; Conti | C010 |
| P04 | Luca | 978-3 | Python | Verdi | C011 |

Domande guida:

- ISBN identifica il libro o la copia fisica?
- Come rappresento un libro con più autori?
- Posso registrare una copia non ancora prestata?
- Cosa descrive davvero la data di restituzione?

Soluzione proposta:

- `readers(reader_id, fiscal_code, name, email)`
- `books(book_id, isbn, title, publisher)`
- `authors(author_id, name)`
- `book_authors(book_id, author_id, author_order)`
- `book_copies(copy_id, book_id, barcode, shelf, status)`
- `loans(loan_id, copy_id, reader_id, borrowed_at, returned_at)`

## Caso 5 - Energia

Problema: una tabella consumi mensili mescola clienti, POD, contatori, contratti, tariffe e letture.

Tabella iniziale:

| mese | cliente | POD | contatore | tariffa | kWh |
| --- | --- | --- | --- | --- | --- |
| 2026-01 | Enel Plant A | IT001E | M-77 | BTA6 | 18420 |
| 2026-02 | Enel Plant A | IT001E | M-77 | BTA6 | 17610 |
| 2026-01 | Store Roma | IT009E | M-90 | BTA3 | 2480 |
| 2026-01 | Store Roma | IT010E | M-91 | BTA3 | 1930 |

Domande guida:

- La riga rappresenta un cliente, un POD, un contratto o una lettura?
- Un cliente può avere più punti di fornitura?
- Che cosa succede se un contatore viene sostituito?
- Una tariffa cambiata oggi deve modificare le letture passate?

Soluzione proposta:

- `customers(customer_id, name, segment)`
- `supply_points(supply_point_id, pod, address, voltage, status)`
- `meters(meter_id, serial_number, model, accuracy_class)`
- `meter_installations(installation_id, supply_point_id, meter_id, installed_from, installed_to)`
- `tariff_plans(tariff_id, code, description, valid_from, valid_to)`
- `supply_contracts(contract_id, customer_id, supply_point_id, tariff_id, start_date, end_date)`
- `energy_readings(reading_id, installation_id, month, kwh, quality)`

## Caso 6 - Monitoraggio ambientale

Problema: una tabella misure orarie mescola stazioni, sensori, parametri ambientali e osservazioni.

Tabella iniziale:

| timestamp | stazione | comune | sensore | parametro | valore |
| --- | --- | --- | --- | --- | --- |
| 10:00 | RM-Centro | Roma | S-101 | PM10 | 42 |
| 11:00 | RM-Centro | Roma | S-101 | PM10 | 45 |
| 10:00 | RM-Centro | Roma | S-202 | NO2 | 31 |
| 10:00 | VT-Nord | Viterbo | S-301 | PM10 | 28 |

Domande guida:

- La riga rappresenta una stazione, un sensore o una misura?
- Dove vanno unità di misura e soglia normativa?
- Un sensore può essere spostato da una stazione a un'altra?
- Una calibrazione modifica il sensore o la misura già registrata?

Soluzione proposta:

- `monitoring_stations(station_id, code, municipality, latitude, longitude)`
- `sensors(sensor_id, serial_number, model, manufacturer)`
- `environmental_parameters(parameter_id, code, name, unit, limit_value)`
- `sensor_installations(installation_id, station_id, sensor_id, parameter_id, installed_from, installed_to)`
- `sensor_calibrations(calibration_id, sensor_id, calibrated_at, result)`
- `measurements(measurement_id, installation_id, measured_at, value, quality_flag)`

## Sintesi

- La normalizzazione parte dalla granularità e dalle dipendenze.
- Ogni tabella dovrebbe avere una frase chiara: "una riga per ...".
- Le tabelle ponte emergono quando due entità sono molti-a-molti.
- Gli attributi storici vanno dichiarati: possono restare nell'evento anche se duplicano dati correnti.
- Una soluzione è buona se elimina anomalie senza perdere fatti necessari.
