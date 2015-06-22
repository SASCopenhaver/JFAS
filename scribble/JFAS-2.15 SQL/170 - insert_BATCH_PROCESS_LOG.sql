--need placeholder for SPLAN process for PY14, so JFAS knows current SP PY is 2014
Insert into BATCH_PROCESS_LOG
   (YEAR, PROCESS_TYPE, USER_ID, DATE_PROCESSED, STATUS)
 Values
   (2014, 'SPLAN', 'mstein', TO_DATE('07/01/2014 00:00:00', 'MM/DD/YYYY HH24:MI:SS'), 1);
COMMIT;
