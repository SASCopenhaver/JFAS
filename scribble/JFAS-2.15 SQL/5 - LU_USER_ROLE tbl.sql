--------------------------------------------------------
--  File created - Tuesday-April-21-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table LU_USER_ROLE
--------------------------------------------------------
ALTER TABLE JFAS.LU_USER_ROLE ADD USER_ROLE_CD varchar2(10);
--------------------------------------------------------
UPDATE LU_USER_ROLE SET USER_ROLE_CD = 'BUDUNIT' WHERE USER_ROLE_ID = 1;
UPDATE LU_USER_ROLE SET USER_ROLE_CD = 'ADMIN' WHERE USER_ROLE_ID = 2;
UPDATE LU_USER_ROLE SET USER_ROLE_CD = 'ROUSER' WHERE USER_ROLE_ID = 3;
UPDATE LU_USER_ROLE SET USER_ROLE_CD = 'ROADMIN' WHERE USER_ROLE_ID = 4;
UPDATE LU_USER_ROLE SET USER_ROLE_CD = 'NO' WHERE USER_ROLE_ID = 5;
Insert into JFAS.LU_USER_ROLE (USER_ROLE_ID,USER_ROLE_DESC,SORT_NUMBER,USER_ROLE_CD) values (6,'Budget Oversight',6,'BUDOVER');
COMMIT;
