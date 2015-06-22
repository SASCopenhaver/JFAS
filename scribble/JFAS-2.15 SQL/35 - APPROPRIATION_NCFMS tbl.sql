
  CREATE TABLE "JFAS"."APPROPRIATION_NCFMS" 
   (	"FUND_CAT" VARCHAR2(4), 
	"PY" NUMBER, 
	"AMOUNT" NUMBER DEFAULT 0, 
	"CREATE_USER" VARCHAR2(20) DEFAULT 'sysnull', 
	"CREATE_DATE" DATE DEFAULT SYSDATE, 
	"UPDATE_USER" VARCHAR2(20) DEFAULT 'sysnull', 
	"UPDATE_DATE" DATE DEFAULT SYSDATE
   ) ;

  CREATE UNIQUE INDEX "JFAS"."APPROPRIATION_NCFMS_PK" ON "JFAS"."APPROPRIATION_NCFMS" ("FUND_CAT", "PY");
  ALTER TABLE "JFAS"."APPROPRIATION_NCFMS" ADD CONSTRAINT "APPROPRIATION_NCFMS_PK" PRIMARY KEY ("FUND_CAT", "PY") ENABLE;
  ALTER TABLE "JFAS"."APPROPRIATION_NCFMS" MODIFY ("PY" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."APPROPRIATION_NCFMS" MODIFY ("FUND_CAT" NOT NULL ENABLE);