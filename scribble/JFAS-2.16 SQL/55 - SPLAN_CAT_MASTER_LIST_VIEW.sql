--------------------------------------------------------
--  File created - Monday-April-13-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View SPLAN_CAT_MASTER_LIST_VIEW
--------------------------------------------------------

  
  CREATE OR REPLACE FORCE VIEW "JFAS"."SPLAN_CAT_MASTER_LIST_VIEW" ("NTH_POS", "SPLAN_CAT_ID", "SPLAN_CAT_PARENT_ID", "PATH", "FULL_PATH") AS 
  SELECT LEVEL AS NTH_POS, 
                  SPLAN_CAT_ID, 
                  SPLAN_CAT_PARENT_ID,  
                  SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2)||',' AS PATH
                  ,F_GETFULLHIERARCHYPATH(SPLAN_CAT_ID) AS FULL_PATH
  FROM SPLAN_CAT_MASTER_LIST ml
 WHERE ml.SPLAN_SECTION_CODE != 'SUM'
  START WITH SPLAN_CAT_PARENT_ID = 0           
  CONNECT BY PRIOR SPLAN_CAT_ID = SPLAN_CAT_PARENT_ID;
/