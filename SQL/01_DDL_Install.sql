

/*
drop table CFG_EXP_FL01;
drop table CFG_EXP_FL02;
drop table CFG_EXP_FLHE;
drop table REPORT_EXPORT;
*/



--------------------------------------------------------
--  DDL for Table CFG_EXP_FL01
--------------------------------------------------------

  CREATE TABLE "CFG_EXP_FL01" 
   (	"FLUSSO" VARCHAR2(50 BYTE), 
	"POSITION" NUMBER, 
	"FIELD" VARCHAR2(50 BYTE), 
	"TYPE" VARCHAR2(20 BYTE), 
	"FORMAT" VARCHAR2(50 BYTE)
   );
--------------------------------------------------------
--  DDL for Table CFG_EXP_FL02
--------------------------------------------------------

  CREATE TABLE "CFG_EXP_FL02" 
   (	"FLUSSO" VARCHAR2(50 BYTE), 
	"TABELLA" VARCHAR2(25 BYTE), 
	"CONDITION" VARCHAR2(255 BYTE), 
	"SEPARATOR" VARCHAR2(5 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Table CFG_EXP_FLHE
--------------------------------------------------------

  CREATE TABLE "CFG_EXP_FLHE" 
   (	"FLUSSO" VARCHAR2(50 BYTE), 
	"POSITION" NUMBER, 
	"FIELD" VARCHAR2(4000 BYTE)
   );
--------------------------------------------------------
--  DDL for Table REPORT_EXPORT
--------------------------------------------------------

  CREATE TABLE "REPORT_EXPORT" 
   (	"FLUSSO" VARCHAR2(50 BYTE), 
	"R_ID" NUMBER, 
	"RECORD" VARCHAR2(4000 BYTE)
   );
   
SET DEFINE OFF;
Insert into ALBERTOMARCIGAGLIA.CFG_EXP_FL01 (FLUSSO,POSITION,FIELD,TYPE,FORMAT) values ('REP_01',3,'DES_NOME','VARCHAR',null);
Insert into ALBERTOMARCIGAGLIA.CFG_EXP_FL01 (FLUSSO,POSITION,FIELD,TYPE,FORMAT) values ('REP_01',4,'COD_ATTIVITA','NUMBER','FM999.009');
Insert into ALBERTOMARCIGAGLIA.CFG_EXP_FL01 (FLUSSO,POSITION,FIELD,TYPE,FORMAT) values ('REP_01',1,'DES_COGNOME','VARCHAR',null);
Insert into ALBERTOMARCIGAGLIA.CFG_EXP_FL01 (FLUSSO,POSITION,FIELD,TYPE,FORMAT) values ('REP_01',2,'COD_STATO','VARCHAR',null);
Insert into ALBERTOMARCIGAGLIA.CFG_EXP_FL01 (FLUSSO,POSITION,FIELD,TYPE,FORMAT) values ('REP_01',5,'DTA_CREAZIONE','DATE','DD-MM-YYYY');

SET DEFINE OFF;
Insert into ALBERTOMARCIGAGLIA.CFG_EXP_FL02 (FLUSSO,TABELLA,CONDITION,SEPARATOR) values ('REP_01','ORAMN477NSV.IVC_ORDINE','WHERE DTA_CREAZIONE >= TRUNC(SYSDATE)-5',',');

SET DEFINE OFF;
Insert into ALBERTOMARCIGAGLIA.CFG_EXP_FLHE (FLUSSO,POSITION,FIELD) values ('REP_01',0,'HEADER');


--------------------------------------------------------
--  DDL for Function GETREPORTQUERYCONCAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "GETREPORTQUERYCONCAT" (tbl in varchar2)
return varchar2
is 
    s_sql VARCHAR2(32767);
BEGIN

    SELECT 'SELECT ''' || F.FLUSSO || ''', ROWNUM, ' ||
    LISTAGG(
    CASE WHEN F.FORMAT IS NOT NULL THEN ' TO_CHAR(' || F.FIELD || ', ''' || F.FORMAT || ''') '  ELSE F.FIELD END , 
    DECODE(C.SEPARATOR, NULL, ', ',' || ''' || C.SEPARATOR || ''' || ')
    ) WITHIN GROUP(ORDER BY F.POSITION,C.SEPARATOR ) || 
    ' FROM ' || C.TABELLA || DECODE(C.CONDITION,NULL, NULL, ' '||C.CONDITION) 
    INTO s_sql
    FROM CFG_EXP_FL01 F INNER JOIN CFG_EXP_FL02 C 
    ON F.FLUSSO =C.FLUSSO
    WHERE F.FLUSSO = tbl 
    GROUP BY F.FLUSSO, C.SEPARATOR, C.TABELLA, C.CONDITION;

    return to_char(s_sql);
END;

/
--------------------------------------------------------
--  DDL for Function GETREPORTQUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "GETREPORTQUERY" (tbl in varchar2)
return varchar2
is 
    s_sql VARCHAR2(32767);
BEGIN

SELECT 'SELECT ' || LISTAGG(
CASE WHEN F.FORMAT IS NOT NULL THEN ' TO_CHAR(' || F.FIELD || ', ''' || F.FORMAT || ''') AS  ' || F.FIELD  ELSE 
F.FIELD END , ', ') WITHIN GROUP(ORDER BY F.POSITION) || 
' FROM ' || C.TABELLA || DECODE(C.CONDITION,NULL, NULL, ' '||C.CONDITION) || ';'
INTO s_sql
FROM CFG_EXP_FL01 F INNER JOIN CFG_EXP_FL02 C 
ON F.FLUSSO =C.FLUSSO
WHERE F.FLUSSO = tbl GROUP BY F.FLUSSO, C.TABELLA, C.CONDITION;

    return s_sql;
END;

/

--------------------------------------------------------
--  DDL for Procedure SP_REP_EXPORT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SP_REP_EXPORT" (p_flusso IN VARCHAR2)
as
 a_data VARCHAR2(32767);
 n_row NUMBER;
BEGIN
    DELETE FROM REPORT_EXPORT WHERE FLUSSO = p_flusso;
    INSERT INTO REPORT_EXPORT SELECT FLUSSO, POSITION, FIELD FROM CFG_EXP_FLHE WHERE FLUSSO = p_flusso;
    a_data := 'INSERT INTO REPORT_EXPORT ' || getreportqueryconcat(p_flusso);
    --DBMS_OUTPUT.PUT_LINE(a_data);    
    execute immediate a_data;
    n_row := sql%rowcount;
    --update REPORT_EXPORT set record = record || ' ' || n_row where r_id=0;
END;

/
