   
   CREATE SEQUENCE  "JFAS"."SEQ_SPLAN_TRANS_FUTURE"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 475 CACHE 20 NOORDER  NOCYCLE ;
   
--------------------------------------------------------
--  File created - Wednesday-April-08-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table SPLAN_TRANS_FUTURE
--------------------------------------------------------

  CREATE TABLE "JFAS"."SPLAN_TRANS_FUTURE" 
   (	"RECORD_ID" NUMBER, 
	"SPLAN_CAT_ID" NUMBER, 
	"AMOUNT" VARCHAR2(20) DEFAULT 0, 
	"PY" NUMBER, 
	"TRANS_NOTE" VARCHAR2(1000), 
	"CREATE_USER" VARCHAR2(20) DEFAULT 'sys', 
	"CREATE_DATE" DATE DEFAULT SYSDATE, 
	"UPDATE_USER" VARCHAR2(20) DEFAULT 'sys', 
	"UPDATE_DATE" DATE DEFAULT SYSDATE
   ) ;
--------------------------------------------------------
--  DDL for Index SPLAN_TRANS_FUTURE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "JFAS"."SPLAN_TRANS_FUTURE_PK" ON "JFAS"."SPLAN_TRANS_FUTURE" ("RECORD_ID") 
  ;
--------------------------------------------------------
--  DDL for Index SPLAN_TRANS_FUTURE_UK1
--------------------------------------------------------

  CREATE UNIQUE INDEX "JFAS"."SPLAN_TRANS_FUTURE_UK1" ON "JFAS"."SPLAN_TRANS_FUTURE" ("SPLAN_CAT_ID", "PY") 
  ;
--------------------------------------------------------
--  Constraints for Table SPLAN_TRANS_FUTURE
--------------------------------------------------------

  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" ADD CONSTRAINT "SPLAN_TRANS_FUTURE_PK" PRIMARY KEY ("RECORD_ID") ENABLE;
  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" MODIFY ("UPDATE_DATE" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" MODIFY ("UPDATE_USER" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" MODIFY ("CREATE_DATE" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" MODIFY ("CREATE_USER" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" MODIFY ("PY" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" MODIFY ("AMOUNT" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" MODIFY ("SPLAN_CAT_ID" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" MODIFY ("RECORD_ID" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" ADD CONSTRAINT "SPLAN_TRANS_FUTURE_UK1" UNIQUE ("SPLAN_CAT_ID", "PY") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table SPLAN_TRANS_FUTURE
--------------------------------------------------------

  ALTER TABLE "JFAS"."SPLAN_TRANS_FUTURE" ADD CONSTRAINT "SPLAN_TRANS_FUTURE_FK1" FOREIGN KEY ("SPLAN_CAT_ID")
	  REFERENCES "JFAS"."SPLAN_CAT_MASTER_LIST" ("SPLAN_CAT_ID") ENABLE;
