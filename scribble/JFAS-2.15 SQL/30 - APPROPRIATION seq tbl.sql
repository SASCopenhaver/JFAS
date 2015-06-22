

CREATE SEQUENCE  "JFAS"."SEQ_APPROPRIATION"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 4450 CACHE 20 NOORDER  NOCYCLE ;


-- APPROPRIATION:
  CREATE TABLE "JFAS"."APPROPRIATION" 
   (	"APPROP_ID" NUMBER, 
	"FUND_CAT" VARCHAR2(4), 
	"PY" NUMBER, 
	"AMOUNT" NUMBER DEFAULT 0, 
	"CREATE_USER" VARCHAR2(20) DEFAULT 'mstein', 
	"CREATE_DATE" DATE DEFAULT SYSDATE, 
	"UPDATE_USER" VARCHAR2(20) DEFAULT 'mstein', 
	"UPDATE_DATE" DATE DEFAULT SYSDATE
   ) ;

   COMMENT ON COLUMN "JFAS"."APPROPRIATION"."APPROP_ID" IS 'Column is populated by sequence SEQ_APPROPRIATION';
--------------------------------------------------------
--  DDL for Index APPROPRIATION_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "JFAS"."APPROPRIATION_PK" ON "JFAS"."APPROPRIATION" ("APPROP_ID");
--------------------------------------------------------
--  DDL for Index APPROPRIATION_UK1
--------------------------------------------------------

  CREATE UNIQUE INDEX "JFAS"."APPROPRIATION_UK1" ON "JFAS"."APPROPRIATION" ("FUND_CAT", "PY") 
  ;
--------------------------------------------------------
--  Constraints for Table APPROPRIATION
--------------------------------------------------------

  ALTER TABLE "JFAS"."APPROPRIATION" ADD CONSTRAINT "APPROPRIATION_UK1" UNIQUE ("FUND_CAT", "PY") ENABLE;
  ALTER TABLE "JFAS"."APPROPRIATION" ADD CONSTRAINT "APPROPRIATION_PK" PRIMARY KEY ("APPROP_ID") ENABLE;
  ALTER TABLE "JFAS"."APPROPRIATION" MODIFY ("APPROP_ID" NOT NULL ENABLE);
--------------------------------------------------------
--  Ref Constraints for Table APPROPRIATION
--------------------------------------------------------

  ALTER TABLE "JFAS"."APPROPRIATION" ADD CONSTRAINT "APPROPRIATION_FK1" FOREIGN KEY ("FUND_CAT")
	  REFERENCES "JFAS"."LU_FUND_CAT" ("FUND_CAT") ENABLE;


-- insert initial records - update to include
Insert into JFAS.APPROPRIATION (APPROP_ID, FUND_CAT, PY, AMOUNT, CREATE_USER, CREATE_DATE, UPDATE_USER, UPDATE_DATE)
Values (SEQ_APPROPRIATION.nextval, 'OPS', 2014, 1578008000, 'sys', SYSDATE, 'sys', SYSDATE);

Insert into JFAS.APPROPRIATION (APPROP_ID, FUND_CAT, PY, AMOUNT, CREATE_USER, CREATE_DATE, UPDATE_USER, UPDATE_DATE)
Values (SEQ_APPROPRIATION.nextval, 'CRA', 2014, 80000000, 'sys', SYSDATE, 'sys', SYSDATE);
COMMIT;

