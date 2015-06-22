   CREATE SEQUENCE  "JFAS"."SEQ_ALLOTMENT"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 34170 CACHE 20 NOORDER  NOCYCLE ;

DROP TABLE "JFAS"."ALLOTMENT";
--------------------------------------------------------
--  File created - Tuesday-April-07-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table ALLOTMENT
--------------------------------------------------------

  CREATE TABLE "JFAS"."ALLOTMENT" 
   (	"ALLOT_ID" NUMBER, 
	"FUND_CAT" VARCHAR2(4), 
	"FUNDING_OFFICE_NUM" NUMBER, 
	"PY" NUMBER, 
	"Q1_AMOUNT" NUMBER DEFAULT 0, 
	"Q2_AMOUNT" NUMBER DEFAULT 0, 
	"Q3_AMOUNT" NUMBER DEFAULT 0, 
	"Q4_AMOUNT" NUMBER DEFAULT 0, 
	"CREATE_USER" VARCHAR2(20) DEFAULT 'mstein', 
	"CREATE_DATE" DATE DEFAULT SYSDATE, 
	"UPDATE_USER" VARCHAR2(20) DEFAULT 'mstein', 
	"UPDATE_DATE" DATE DEFAULT SYSDATE
   ) ;

   COMMENT ON COLUMN "JFAS"."ALLOTMENT"."ALLOT_ID" IS 'Number generated by SEQ_ALLOTMENT
';
   COMMENT ON COLUMN "JFAS"."ALLOTMENT"."FUND_CAT" IS 'Funding category.  Source: LU_FUND_CAT.  Use only CRA Construction and OPS Operations.';
   COMMENT ON COLUMN "JFAS"."ALLOTMENT"."FUNDING_OFFICE_NUM" IS 'Funding Office aka Regions. Source: LU_FUNDING_OFFICE. Use only Funding Office Numbers 1,2,3,4,5,6, and 20.';
--------------------------------------------------------
--  DDL for Index ALLOTMENT_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "JFAS"."ALLOTMENT_PK" ON "JFAS"."ALLOTMENT" ("ALLOT_ID") 
  ;
--------------------------------------------------------
--  Constraints for Table ALLOTMENT
--------------------------------------------------------

  ALTER TABLE "JFAS"."ALLOTMENT" ADD CONSTRAINT "ALLOTMENT_PK" PRIMARY KEY ("ALLOT_ID") ENABLE;
  ALTER TABLE "JFAS"."ALLOTMENT" MODIFY ("ALLOT_ID" NOT NULL ENABLE);
--------------------------------------------------------
--  Ref Constraints for Table ALLOTMENT
--------------------------------------------------------

  ALTER TABLE "JFAS"."ALLOTMENT" ADD CONSTRAINT "ALLOTMENT_FK1" FOREIGN KEY ("FUND_CAT", "PY")
	  REFERENCES "JFAS"."APPROPRIATION" ("FUND_CAT", "PY") ENABLE;
  ALTER TABLE "JFAS"."ALLOTMENT" ADD CONSTRAINT "ALLOTMENT_FK2" FOREIGN KEY ("FUNDING_OFFICE_NUM")
	  REFERENCES "JFAS"."LU_FUNDING_OFFICE" ("FUNDING_OFFICE_NUM") ENABLE;
