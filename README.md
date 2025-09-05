**REPORT DB**  
Il presente crea una struttura PL/SLQ in cui configurare un flusso da esportare, l'applicativo .Net permette di elaborare il flusso e creare il file.

**PL/SQL**  
Nella cartella SQL è presente uno script che crea  
<ins>Tabelle</ins>  
* CFG_EXP_FL01 nomi delle colonne da esportare, l'ordinamento, il tipo e il formato
* CFG_EXP_FL02 nome della tabella da esportare, eventuale clausola WHERE/ORDER BY, separatore del file
* CFG_EXP_FLHE eventuale Header
* REPORT_EXPORT tabella finale contenente il flusso in formato testuale

<ins>Funzioni</ins>  
* GETREPORTQUERYCONCAT  
In: nome del report  
Out: stringa contenente la query da eseguire per ottenere il report sottoforma di un'unica riga con separatore specifico

* GETREPORTQUERY
In: nome del report  
Out: stringa contenente la query da eseguire per ottenere il reporto sottoforma di recordset senza separatore

<ins>Procedure</ins>   
* SP_REP_EXPORT 
In: nome del report  
Popola la tabella REPORT_EXPORT eseguendo la query da GETREPORTQUERYCONCAT

**.NET**
L'applicativo prende in input come argomento il nom del report ed esegue SP_REP_EXPORT.
Verifica la presenza della cartella OUTPUT_REPORT nella root del progetto e nel caso la crea.
Esporta nella cartella il flusso nominato come NOMEREPORT DataOra .csv

E' presente un file app.config contenente la stringa di connessione e il nome della cartella di output.



