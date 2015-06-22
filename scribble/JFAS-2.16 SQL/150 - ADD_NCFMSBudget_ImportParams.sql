--SET DEFINE OFF;
-- new import type: NCFMS Budget
Insert into LU_IMPORT_TYPE
   (IMPORT_TYPE_CODE, IMPORT_TYPE_DESC, SORT_ORDER, ALLOW_UPLOAD, STATUS)
 Values
   ('NCFMSBUDG', 'NCFMS Budget Execution', 2, 0, 1);


-- new import parameters: NCFMS Budget
Insert into IMPORT_PARAM
   (IMPORT_TYPE, FTP_SITE, FTP_REMOTE_DIR, FTP_PORT, FTPS_TYPE, 
    FTP_UID, FTP_PWD, JFAS_SHARE_DIR, FTP_REMOTE_FILE, JFAS_SHARE_FILE)
 Values
   ('NCFMSBUDG', 'ncfms.dol.gov', '/beextract/', '990', 'AUTH_SSL_FTP_CONNECTION', 
    'OJCJFASDEUSER', '', '\\netshare\jfas_dev\ncfms\budg\~\\netshare\jfas_test\ncfms\budg\', 'BudgetExecutionBalancesDataExtract_glexport.csv', '\\netshare\jfas_dev\ncfms\budg\BudgetExecutionBalancesDataExtract_glexport.csv');
COMMIT;



