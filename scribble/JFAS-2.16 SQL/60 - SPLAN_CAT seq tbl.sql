CREATE SEQUENCE  "JFAS"."SEQ_SPLAN_CAT"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1010 CACHE 20 NOORDER  NOCYCLE ;

--------------------------------------------------------
--  File created - Monday-April-13-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table SPLAN_CAT
--------------------------------------------------------

  CREATE TABLE "JFAS"."SPLAN_CAT" 
   (	"RECORD_ID" NUMBER, 
	"SPLAN_CAT_ID" NUMBER, 
	"PY" NUMBER, 
	"CREATE_USER" VARCHAR2(20) DEFAULT 'mstaein', 
	"CREATE_DATE" DATE DEFAULT SYSDATE, 
	"UPDATE_USER" VARCHAR2(20) DEFAULT 'mstein', 
	"UPDATE_DATE" DATE DEFAULT SYSDATE
   ) ;
--REM INSERTING into JFAS.SPLAN_CAT
--SET DEFINE OFF;

Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (746,5,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (747,7,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (748,8,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (749,9,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (750,10,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (751,11,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (752,12,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (753,13,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (754,15,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (755,21,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (756,22,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (757,23,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (758,24,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (759,25,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (760,26,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (761,27,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (762,28,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (763,29,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (764,30,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (765,31,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (766,32,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (767,33,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (768,34,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (769,35,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (770,37,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (771,38,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (772,39,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (773,40,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (774,41,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (775,42,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (776,43,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (777,45,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (778,400,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (779,401,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (780,402,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (781,403,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (782,404,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (783,405,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (784,406,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (785,407,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (786,408,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (787,409,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (788,410,2015,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (691,400,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (692,401,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (693,402,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (694,403,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (695,404,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (696,405,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (697,406,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (698,407,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (699,408,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (700,409,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (701,410,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (712,5,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (713,7,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (714,8,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (715,9,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (716,10,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (717,11,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (718,12,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (719,13,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (720,15,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (721,21,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (722,22,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (723,23,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (724,24,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (725,25,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (726,26,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (727,27,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (728,28,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (729,29,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (730,30,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (731,31,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (732,32,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (733,33,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (734,34,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (735,35,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (737,37,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (738,38,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (739,39,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (740,40,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (741,41,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (742,42,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (743,43,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));
Insert into JFAS.SPLAN_CAT (RECORD_ID,SPLAN_CAT_ID,PY,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (744,45,2014,'sys',to_date('12-APR-15','DD-MON-RR'),'sys',to_date('12-APR-15','DD-MON-RR'));

--------------------------------------------------------
--  DDL for Index SPLAN_CAT_PK_2
--------------------------------------------------------

  CREATE UNIQUE INDEX "JFAS"."SPLAN_CAT_PK_2" ON "JFAS"."SPLAN_CAT" ("RECORD_ID") 
  ;
--------------------------------------------------------
--  DDL for Index SPLAN_CAT_2_UK1
--------------------------------------------------------

  CREATE UNIQUE INDEX "JFAS"."SPLAN_CAT_2_UK1" ON "JFAS"."SPLAN_CAT" ("SPLAN_CAT_ID", "PY") 
  ;
--------------------------------------------------------
--  Constraints for Table SPLAN_CAT
--------------------------------------------------------

  ALTER TABLE "JFAS"."SPLAN_CAT" ADD CONSTRAINT "SPLAN_CAT_PK_2" PRIMARY KEY ("RECORD_ID") ENABLE;
  ALTER TABLE "JFAS"."SPLAN_CAT" MODIFY ("UPDATE_DATE" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_CAT" MODIFY ("UPDATE_USER" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_CAT" MODIFY ("CREATE_DATE" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_CAT" MODIFY ("CREATE_USER" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_CAT" MODIFY ("PY" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_CAT" MODIFY ("SPLAN_CAT_ID" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_CAT" MODIFY ("RECORD_ID" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."SPLAN_CAT" ADD CONSTRAINT "SPLAN_CAT_2_UK1" UNIQUE ("SPLAN_CAT_ID", "PY") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table SPLAN_CAT
--------------------------------------------------------

  ALTER TABLE "JFAS"."SPLAN_CAT" ADD CONSTRAINT "SPLAN_CAT_FK1" FOREIGN KEY ("SPLAN_CAT_ID")
	  REFERENCES "JFAS"."SPLAN_CAT_MASTER_LIST" ("SPLAN_CAT_ID") ENABLE;
