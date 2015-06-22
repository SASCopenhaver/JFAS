--------------------------------------------------------
--  File created - Monday-April-13-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View SPLAN_CAT_MASTER_LIST_VIEW
--------------------------------------------------------

  CREATE OR REPLACE VIEW "JFAS"."SPLAN_CAT_MASTER_LIST_VIEW" ("NTH_POS", "SPLAN_CAT_ID", "SPLAN_CAT_PARENT_ID", "PATH", "FULL_PATH") AS 
  SELECT LEVEL AS NTH_POS, 
                  SPLAN_CAT_ID, 
                  SPLAN_CAT_PARENT_ID,  
                  SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2)||',' AS PATH
                  ,SPLAN_PKG.f_getFullHieratchyPath(SPLAN_CAT_ID) AS FULL_PATH
  FROM SPLAN_CAT_MASTER_LIST ml
 WHERE ml.SPLAN_SECTION_CODE != 'SUM'
  START WITH SPLAN_CAT_PARENT_ID = 0           
  CONNECT BY NOCYCLE PRIOR SPLAN_CAT_ID = SPLAN_CAT_PARENT_ID;
REM INSERTING into JFAS.SPLAN_CAT_MASTER_LIST_VIEW
SET DEFINE OFF;
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (1,1,0,'1,','1,5,7,8,9,10,11,12,13');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (2,4,1,'1,4,','4,5,7,8,9,10,11,12,13');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,5,4,'1,4,5,','5');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,7,4,'1,4,7,','7');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,8,4,'1,4,8,','8');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,9,4,'1,4,9,','9');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,10,4,'1,4,10,','10');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,11,4,'1,4,11,','11');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,12,4,'1,4,12,','12');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,13,4,'1,4,13,','13');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (1,2,0,'2,','2,15');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (2,14,2,'2,14,','14,15');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,15,14,'2,14,15,','15');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (1,3,0,'3,','3,400,401,402,403,404,405,406,407,408,409,410,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,37,38,39,40,41,42,43,45');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (2,16,3,'3,16,','16,400,21,22,23,24,25,26');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,21,16,'3,16,21,','21');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,22,16,'3,16,22,','22');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,23,16,'3,16,23,','23');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,24,16,'3,16,24,','24');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,25,16,'3,16,25,','25');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,26,16,'3,16,26,','26');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,400,16,'3,16,400,','400');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (2,17,3,'3,17,','17,27,28,29,30');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,27,17,'3,17,27,','27');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,28,17,'3,17,28,','28');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,29,17,'3,17,29,','29');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,30,17,'3,17,30,','30');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (2,18,3,'3,18,','18,401,402,403,404,405,406,407,408,409,410,31,32,33,34,35');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,31,18,'3,18,31,','31');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,32,18,'3,18,32,','32');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,33,18,'3,18,33,','33');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,34,18,'3,18,34,','34');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,35,18,'3,18,35,','35');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,401,18,'3,18,401,','401');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,402,18,'3,18,402,','402');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,403,18,'3,18,403,','403');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,404,18,'3,18,404,','404');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,405,18,'3,18,405,','405');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,406,18,'3,18,406,','406');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,407,18,'3,18,407,','407');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,408,18,'3,18,408,','408');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,409,18,'3,18,409,','409');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,410,18,'3,18,410,','410');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (2,19,3,'3,19,','19,40,41,42');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,40,19,'3,19,40,','40');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,41,19,'3,19,41,','41');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,42,19,'3,19,42,','42');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (2,20,3,'3,20,','20,43,45');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,43,20,'3,20,43,','43');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,45,20,'3,20,45,','45');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (2,36,3,'3,36,','36,37,38,39');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,37,36,'3,36,37,','37');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,38,36,'3,36,38,','38');
Insert into JFAS.SPLAN_CAT_MASTER_LIST_VIEW (NTH_POS,SPLAN_CAT_ID,SPLAN_CAT_PARENT_ID,PATH,FULL_PATH) values (3,39,36,'3,36,39,','39');


--===================
--------------------------------------------------------
--  File created - Monday-April-13-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View SPLAN_CAT_MASTER_LIST_VIEW_2
--------------------------------------------------------

  CREATE OR REPLACE VIEW "JFAS"."SPLAN_CAT_MASTER_LIST_VIEW_2" ("NTH_POS", "SPLAN_CAT_ID", "SPLAN_CAT_PARENT_ID", "PATH") AS 
  SELECT LEVEL AS NTH_POS, 
                  SPLAN_CAT_ID, 
                  SPLAN_CAT_PARENT_ID,  
                  SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2)||',' AS PATH
                  --SPLAN_PKG.f_getFullHieratchyPath(SPLAN_CAT_ID) AS FULL_PATH
  FROM SPLAN_CAT_MASTER_LIST_2 ml
 WHERE ml.SPLAN_SECTION_CODE != 'SUM'
  START WITH SPLAN_CAT_PARENT_ID = 0           
  CONNECT BY NOCYCLE PRIOR SPLAN_CAT_ID = SPLAN_CAT_PARENT_ID
  ORDER SIBLINGS BY SORT_ORDER;
REM INSERTING into JFAS.SPLAN_CAT_MASTER_LIST_VIEW_2
SET DEFINE OFF;



