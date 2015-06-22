--------------------------------------------------------
--  File created - Friday-May-29-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table LU_CODE
--------------------------------------------------------

  CREATE TABLE "LU_CODE" 
   (	"CODE_ID" NUMBER, 
	"CODE_TYPE" VARCHAR2(100), 
	"CODE" VARCHAR2(20), 
	"CODE_DESC" VARCHAR2(100), 
	"NOTE" VARCHAR2(1000), 
	"SORT_ORDER" VARCHAR2(20)
   ) ;
REM INSERTING into LU_CODE
SET DEFINE OFF;
Insert into LU_CODE (CODE_ID,CODE_TYPE,CODE,CODE_DESC,NOTE,SORT_ORDER) values (420,'TRANS_STATUS_CODE','O','Open','O- -for OPEN.  Table: SPLAN_TRANS; column: TRANS_STATUS.','1');
Insert into LU_CODE (CODE_ID,CODE_TYPE,CODE,CODE_DESC,NOTE,SORT_ORDER) values (421,'TRANS_STATUS_CODE','C','Closed','C- for CLOSED. Table: SPLAN_TRANS; column: TRANS_STATUS.','2');
Insert into LU_CODE (CODE_ID,CODE_TYPE,CODE,CODE_DESC,NOTE,SORT_ORDER) values (422,'TRANS_TYPE_CODE','TRNS','Regular','Table: SPLAN_TRANS; column: TRANS_CODE. TRNS - transaction amount within a year.','2');
Insert into LU_CODE (CODE_ID,CODE_TYPE,CODE,CODE_DESC,NOTE,SORT_ORDER) values (480,'TRANS_TYPE_CODE','INIT','Initial','Table: SPLAN_TRANS; column: TRANS_CODE. INIT - Initial transaction amount.','1');
Insert into LU_CODE (CODE_ID,CODE_TYPE,CODE,CODE_DESC,NOTE,SORT_ORDER) values (900,'TRANS_TYPE_CODE','FUTR',null,'FUTR - future transaction amount','3');
Insert into LU_CODE (CODE_ID,CODE_TYPE,CODE,CODE_DESC,NOTE,SORT_ORDER) values (901,'SPLAN_SECTIONS','CTR','CENTERS',null,'1');
Insert into LU_CODE (CODE_ID,CODE_TYPE,CODE,CODE_DESC,NOTE,SORT_ORDER) values (902,'SPLAN_SECTIONS','FED','USDA',null,'2');
Insert into LU_CODE (CODE_ID,CODE_TYPE,CODE,CODE_DESC,NOTE,SORT_ORDER) values (903,'SPLAN_SECTIONS','HQC','NATIONAL HQ CENTERS',null,'3');
Insert into LU_CODE (CODE_ID,CODE_TYPE,CODE,CODE_DESC,NOTE,SORT_ORDER) values (904,'SPLAN_SECTIONS','SUM','SUMMARY',null,'4');
--------------------------------------------------------
--  DDL for Index LU_CODE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "LU_CODE_PK" ON "LU_CODE" ("CODE_ID") 
  ;
--------------------------------------------------------
--  DDL for Index LU_CODE_UK1
--------------------------------------------------------

  CREATE UNIQUE INDEX "LU_CODE_UK1" ON "LU_CODE" ("CODE") 
  ;
--------------------------------------------------------
--  Constraints for Table LU_CODE
--------------------------------------------------------

  ALTER TABLE "LU_CODE" MODIFY ("CODE_ID" NOT NULL ENABLE);
  ALTER TABLE "LU_CODE" ADD CONSTRAINT "LU_CODE_PK" PRIMARY KEY ("CODE_ID") ENABLE;
  ALTER TABLE "LU_CODE" ADD CONSTRAINT "LU_CODE_UK1" UNIQUE ("CODE") ENABLE;
