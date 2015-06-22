--------------------------------------------------------
--  File created - Sunday-April-19-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table ALLOTMENT_NCFMS
--------------------------------------------------------

  CREATE TABLE "JFAS"."ALLOTMENT_NCFMS" 
   (	"FUND_CAT" VARCHAR2(4), 
	"FUNDING_OFFICE_NUM" NUMBER, 
	"PY" NUMBER, 
	"Q1_AMOUNT" NUMBER DEFAULT 0, 
	"Q2_AMOUNT" NUMBER DEFAULT 0, 
	"Q3_AMOUNT" NUMBER DEFAULT 0, 
	"Q4_AMOUNT" NUMBER DEFAULT 0, 
	"CREATE_USER" VARCHAR2(20) DEFAULT 'sysnull', 
	"CREATE_DATE" DATE DEFAULT SYSDATE, 
	"UPDATE_USER" VARCHAR2(20) DEFAULT 'sysnull', 
	"UPDATE_DATE" DATE DEFAULT SYSDATE
   ) ;
--------------------------------------------------------
--  DDL for Index ALLOTMENT_NCFMS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "JFAS"."ALLOTMENT_NCFMS_PK" ON "JFAS"."ALLOTMENT_NCFMS" ("FUND_CAT", "FUNDING_OFFICE_NUM", "PY") 
  ;
--------------------------------------------------------
--  Constraints for Table ALLOTMENT_NCFMS
--------------------------------------------------------

  ALTER TABLE "JFAS"."ALLOTMENT_NCFMS" ADD CONSTRAINT "ALLOTMENT_NCFMS_PK" PRIMARY KEY ("FUND_CAT", "FUNDING_OFFICE_NUM", "PY") ENABLE;
  ALTER TABLE "JFAS"."ALLOTMENT_NCFMS" MODIFY ("PY" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."ALLOTMENT_NCFMS" MODIFY ("FUNDING_OFFICE_NUM" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."ALLOTMENT_NCFMS" MODIFY ("FUND_CAT" NOT NULL ENABLE);
