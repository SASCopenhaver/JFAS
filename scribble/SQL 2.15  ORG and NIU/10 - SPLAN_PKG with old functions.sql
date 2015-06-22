create or replace PACKAGE SPLAN_PKG AS
TYPE refc_Base is REF CURSOR;
v_CurrentPY  NUMBER DEFAULT UTILITY.fun_getcurrntprogram_year_sp;
v_NextYearPY NUMBER DEFAULT v_CurrentPY+1;
v_Counter    NUMBER DEFAULT 0;
v_SqlCode    VARCHAR2(1000) DEFAULT 'NOERROR';
v_SqlErrm    VARCHAR2(1000) DEFAULT 'NOERROR';

--==============================================================================
PROCEDURE sp_getCurrentPY(rc_CurrentPY OUT refc_Base);
--==============================================================================
PROCEDURE sp_getListOfPY (rc_getListOfPY OUT refc_Base);
--==============================================================================
PROCEDURE sp_getApprAllot(arg_PY IN NUMBER DEFAULT v_CurrentPY
                           ,arg_UserID IN VARCHAR2 DEFAULT 'mstein'
                           ---
                           ,rc_getListOfPY      OUT refc_Base
                           ,rc_getAppropriation OUT refc_Base
                           ,rc_getAllotment     OUT refc_Base
                           ,rc_DateNCFMSloaded  OUT refc_Base
                           );
/*
-- TEST procedure:
DECLARE
rc_Cursor1 SYS_REFCURSOR;
rc_Cursor2 SYS_REFCURSOR;
rc_Cursor3 SYS_REFCURSOR;
BEGIN
    APPROPRIATION_ALLOTMENT_PKG.sp_getAppropAllot(2013, 'mstein', rc_Cursor1, rc_Cursor2, rc_Cursor3, rc_Cursor4, rc_Cursor5);
END;
*/
--==============================================================================
PROCEDURE sp_saveAppropAllot(  argPY         IN NUMBER
                              ,argUserID     IN VARCHAR2
                              ,argApprUpdSQL IN VARCHAR2
                              ,argAlltUpdSQL IN VARCHAR2);
--==============================================================================
PROCEDURE sp_getAppropriation (arg_FundCat IN VARCHAR2 DEFAULT 'ALL'
                              ,arg_PY      IN NUMBER   DEFAULT 0
                              ,rc_getAppropriation OUT refc_Base);
--==============================================================================
PROCEDURE sp_getAmountsFutureSPlan ( argUserID IN VARCHAR2
                                    ,rc_getAmount_CTR_FED_HQC OUT refc_Base     -- CENTERS, USDA, NATIONAL HQ CONTRACTS 
                                    ,rc_getAmount_GT          OUT refc_Base     -- GRAND TOTAL
                                    ,rc_getAmount_APPRP       OUT refc_Base     -- APPROPRIATION
                                    ,rc_getAmount_BBR         OUT refc_Base     -- BALANCE BEFORE RESERVE
                                    ,rc_getAmount_RES         OUT refc_Base     -- RESERVE
                                    ,rc_getAmount_BAR         OUT refc_Base     -- BALANCE AFTER RESERVE
                                    ,rc_getResPercent         OUT refc_Base     -- Reserve percentage
                                    ,rc_TransClosed           OUT refc_Base     -- Are all transaction closed?
                                    );
--==============================================================================
PROCEDURE sp_saveFutureSplan ( argUserID IN VARCHAR2 
                              ,argSplan  IN VARCHAR2);

--==============================================================================
PROCEDURE sp_getTopSplanCodes ( argsplanSectionCode IN VARCHAR2
                                 ,argPY     IN NUMBER
                                 ,argStartParentId     IN NUMBER
                                 ,rc_TopSplanCodes OUT refc_Base);
--==============================================================================
PROCEDURE sp_setNextYrSplan (argUserID IN VARCHAR2
                              ,argPY IN NUMBER
                              ,argSPNextPYRES IN NUMBER
                              ,argSPNextPYBAR IN NUMBER
                              ,rc_sqlCodes OUT refc_Base
                              );
--==============================================================================
--==============================================================================
FUNCTION f_getAmountFOP_Summary( argSummaryCode IN VARCHAR2 DEFAULT 'RESERVE'
                                ,argPY          IN NUMBER   DEFAULT NULL
                                ,argDateFrom    IN VARCHAR2 DEFAULT NULL
                                ,argDateTo      IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
--==============================================================================
/*
FUNCTION f_getTransactionAmount( argHierarchyLevel IN NUMBER
                                ,argPY             IN NUMBER DEFAULT UTILITY.fun_getCurrntProgram_Year
                                ,argCat_Parent_ID  IN NUMBER
                                ,argCat_ID         IN NUMBER
                                --,argTrans_Code     IN VARCHAR2 
                                ) RETURN NUMBER;
*/
--==============================================================================
-- OLD VERSION:
--FUNCTION f_getNoteNextYear(argLevel IN NUMBER, argSplanCatID IN NUMBER) RETURN VARCHAR2;

-- UPDATED VERSION:
FUNCTION f_getNoteNextYear(argNextYearPY IN NUMBER, argSPLAN_CAT_ID IN NUMBER) RETURN VARCHAR2;
--==============================================================================
FUNCTION f_getL3_SPLAN_CAT_ID(argLevel IN NUMBER
                             ,argPath  IN VARCHAR2) RETURN NUMBER;
--==============================================================================
FUNCTION f_getAmountFOPNextPY(argCatID IN NUMBER) RETURN VARCHAR2;
--==============================================================================
/* this is old procedure, re-written and re-named to f_getAmountFOPNextPY
FUNCTION f_getFOPAmount_NextPY (argLevel IN NUMBER
                               ,argCostCatID IN NUMBER
                               ,argPath  IN VARCHAR2) RETURN VARCHAR2;
*/
--==============================================================================
FUNCTION f_getFormatedCatDesc(argPath  IN VARCHAR2,
                              argSortOrder IN NUMBER,
                              argSplanCatDesc IN VARCHAR2) RETURN VARCHAR2;
--==============================================================================
FUNCTION f_getFullHieratchyPath(--argLevel IN NUMBER, 
                       --argPath  IN VARCHAR2,
                       argCatID IN NUMBER
                       --argParentCatID IN NUMBER
                       ) RETURN VARCHAR2;
--==============================================================================
FUNCTION f_getFullHieratchyPath_2(argCatID IN NUMBER) RETURN VARCHAR2;
--==============================================================================
--FUNCTION f_getFullPathFromVIEW(argCatID IN NUMBER) RETURN VARCHAR2;
--==============================================================================
END SPLAN_PKG;

--------------------------------------------------------------------------------
-- NOTES: Run the following scripts to restore records before procedure was successfully executed.
/*
DELETE SPLAN_TRANS_DET WHERE UPDATE_USER = 'sas';
DELETE SPLAN_TRANS WHERE UPDATE_USER = 'sas';

UPDATE FOP
  SET SPLAN_TRANS_DET_ID = NULL
  WHERE UPDATE_USER_ID = 'sas';

DELETE BATCH_PROCESS_LOG WHERE YEAR = 2015 AND PROCESS_TYPE = 'SPLAN';

Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (73,5,'50123',2015,'Some notes A','mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (74,6,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (75,7,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (76,8,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (77,9,'789100',2015,'Some notes  B4','mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (78,10,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (79,11,'1013560',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (80,12,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (81,13,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (82,15,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (83,21,'1245210',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (84,22,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (85,23,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (86,24,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (87,25,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (88,26,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (89,27,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (90,28,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (91,29,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (92,30,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (93,31,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (94,32,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (95,33,'120000',2015,' Some notes c','mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (96,34,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (97,35,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (98,36,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (99,37,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (100,38,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (101,39,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (102,40,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (103,41,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));
Insert into SPLAN_TRANS_FUTURE (RECORD_ID,SPLAN_CAT_ID,AMOUNT,PY,TRANS_NOTE,CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE) values (104,42,'0',2015,null,'mstein',to_date('23-MAR-15','DD-MON-RR'),'mstein',to_date('23-MAR-15','DD-MON-RR'));

DELETE SPLAN_TRANS_FUTURE WHERE PY=2016;

--*/
/
create or replace PACKAGE BODY SPLAN_PKG AS
--==============================================================================
PROCEDURE sp_getCurrentPY(rc_CurrentPY OUT refc_Base) IS
BEGIN 
OPEN rc_CurrentPY FOR 
      SELECT v_CurrentPY AS CURRENT_PY, v_NextYearPY AS NEXT_YEAR_PY
        FROM dual;
END sp_getCurrentPY;
--==============================================================================
PROCEDURE sp_getListOfPY (rc_getListOfPY OUT refc_Base) AS

BEGIN
  OPEN rc_getListOfPY FOR 
  SELECT v_CurrentPY-6 + LEVEL AS PY_LIST -- to test, use 2014 in stead of v_CurrentPY.
    FROM DUAL
    CONNECT BY LEVEL <= 11;

END sp_getListOfPY;
--==============================================================================
PROCEDURE sp_getApprAllot(arg_PY IN NUMBER DEFAULT v_CurrentPY
                           ,arg_UserID IN VARCHAR2 DEFAULT 'mstein'
                           ---
                           ,rc_getListOfPY      OUT refc_Base
                           ,rc_getAppropriation OUT refc_Base
                           ,rc_getAllotment     OUT refc_Base
                           ,rc_DateNCFMSloaded  OUT refc_Base
                           ) 
IS
-- VARIABLEs declaration:
v_Fund_Cat            LU_FUND_CAT.FUND_CAT%TYPE;                  -- VARCHAR2(4)
v_Funding_Office_Num  LU_FUNDING_OFFICE.FUNDING_OFFICE_NUM%TYPE;  -- NUMBER

v_NCFMSload VARCHAR2(100);
v_NCFMSloadSum NUMBER;

-- CURSORs declaration:
CURSOR c_Fund_Cat IS
  SELECT FUND_CAT, FUND_CAT_DESC, SORT_ORDER -- SORT_ORDER=1 --> 'OPS', SORT_ORDER=2 --> 'CRA'
    FROM LU_FUND_CAT
   WHERE FUND_CAT != 'S/E'
   ORDER BY SORT_ORDER;

CURSOR c_Funding_Office IS
  SELECT FUNDING_OFFICE_NUM, FUNDING_OFFICE_ABBR, FUNDING_OFFICE_DESC, DECODE(SORT_ORDER, 30, 19, SORT_ORDER) AS ADJUSTED_SORT_ORDER 
    FROM LU_FUNDING_OFFICE
   WHERE FUNDING_OFFICE_NUM <= 30
   ORDER BY ADJUSTED_SORT_ORDER;

BEGIN
--------------------------------------------------------------------------------
-- I. List of PYs represents v_CurrentPY-5 years, v_CurrentPY, and v_CurrentPY+5 years:
 OPEN rc_getListOfPY FOR 
    SELECT v_CurrentPY-6 + LEVEL AS PY_LIST -- to test SQL, use 2014 instead of v_CurrentPY.
      FROM DUAL
      CONNECT BY LEVEL <= 11;


--II: 
-- II.1 Make sure that records exist for the PY (PY value is in arg_PY)
      FOR r_Fund_Cat IN c_Fund_Cat LOOP
          v_Fund_Cat := r_Fund_Cat.FUND_CAT;

-- APPROPRIATION:
              MERGE INTO APPROPRIATION ap
                    USING (select v_Fund_Cat as d_Fund_Cat
                             from dual d)
                       ON (    ap.FUND_CAT = d_Fund_Cat
                           AND ap.PY = arg_PY )
              WHEN NOT MATCHED THEN 
                    INSERT (ap.APPROP_ID, ap.FUND_CAT, ap.PY, ap.AMOUNT, ap.CREATE_USER, ap.UPDATE_USER) 
                    VALUES (SEQ_APPROPRIATION.nextval, v_Fund_Cat, arg_PY, 0, arg_UserID, arg_UserID);
          
-- APPROPRIATION NCFMS:
              MERGE INTO APPROPRIATION_NCFMS ap
                    USING (select v_Fund_Cat as d_Fund_Cat
                             from dual d)
                       ON (    ap.FUND_CAT = d_Fund_Cat
                           AND ap.PY = arg_PY )
              WHEN NOT MATCHED THEN 
                    INSERT (ap.FUND_CAT, ap.PY, ap.AMOUNT, ap.CREATE_USER, ap.UPDATE_USER) 
                    VALUES (v_Fund_Cat, arg_PY, 0, arg_UserID, arg_UserID);         
--------------------------------------------------------------------------------
-- II.2          
          FOR r_Funding_Office IN c_Funding_Office LOOP
              v_Funding_Office_Num := r_Funding_Office.FUNDING_OFFICE_NUM;
                
-- ALLOTMENT:   
                    MERGE INTO ALLOTMENT al
                          USING (select v_Fund_Cat           as d_Fund_Cat,
                                        v_Funding_Office_Num as d_Funding_Office_Num
                                  from dual d)
                          ON (   al.FUND_CAT = d_Fund_Cat
                             AND al.FUNDING_OFFICE_NUM = d_Funding_Office_Num
                             AND al.PY = arg_PY )
                    WHEN NOT MATCHED THEN -- If records do not exist, then create them: 
                          INSERT (al.ALLOT_ID, al.FUND_CAT, al.FUNDING_OFFICE_NUM, al.PY, al.CREATE_USER, al.UPDATE_USER)
                          VALUES (seq_ALLOTMENT.nextval, v_Fund_Cat, v_Funding_Office_Num, arg_PY, arg_UserID, arg_UserID);
                
-- ALLOTMENT_NCFMS:
                    MERGE INTO ALLOTMENT_NCFMS al
                          USING (select v_Fund_Cat           as d_Fund_Cat,
                                        v_Funding_Office_Num as d_Funding_Office_Num
                                  from dual d)
                          ON (   al.FUND_CAT = d_Fund_Cat
                             AND al.FUNDING_OFFICE_NUM = d_Funding_Office_Num
                             AND al.PY = arg_PY )
                    WHEN NOT MATCHED THEN -- If records do not exist, then create them: 
                          INSERT (al.FUND_CAT, al.FUNDING_OFFICE_NUM, al.PY, al.CREATE_USER, al.UPDATE_USER)
                          VALUES (v_Fund_Cat, v_Funding_Office_Num, arg_PY, arg_UserID, arg_UserID);

          END LOOP;    -- end of c_Funding_Office
      END LOOP;        -- end of c_Fund_Cat
      COMMIT;
-------------------------------------------------------------------------------- 
-- III. Prepare output for APPROPRIATION: 
  OPEN rc_getAppropriation FOR
          SELECT aa.APPROP_ID,
                 fc.fund_cat AS APPR_FUND_CAT, 
                 UPPER(fc.fund_cat_desc) AS APPR_fund_cat_desc, 
                 aa.py AS APPR_PY, 
                 TRIM(TO_CHAR(aa.AMOUNT, '999,999,999,999')) AS APPR_AMOUNT, 
                 TRIM(TO_CHAR(an.AMOUNT, '999,999,999,999')) AS APPR_AMOUNT_NCFMS
          FROM APPROPRIATION aa
              ,APPROPRIATION_NCFMS an
              ,LU_FUND_CAT fc
         WHERE aa.fund_cat = an.fund_cat
           AND aa.fund_cat = fc.fund_cat
           AND fc.fund_cat != 'S/E'
           AND aa.py = an.py
           AND aa.PY = arg_PY
        ORDER BY fc.FUND_CAT DESC;

--------------------------------------------------------------------------------
-- IV. Prepare output for ALLOTMENT:
  OPEN rc_getAllotment FOR
      SELECT ALLOT_ID, FUND_CAT, FUNDING_OFFICE_NUM, FUNDING_OFFICE_DESC, PY,
             Q1_AMOUNT, Q2_AMOUNT,  Q3_AMOUNT, Q4_AMOUNT, QT_AMOUNT,
             Q1_AMOUNT_NCFMS, Q2_AMOUNT_NCFMS, Q3_AMOUNT_NCFMS, Q4_AMOUNT_NCFMS, QT_AMOUNT_NCFMS
      FROM(
        --// This part of SQL statement generates calculations of totals for each Funding Office per each quarter.
        --// It is the first row in the output for the page 'Budget Appropriation / Allotment'.
        --// Value '71' in line for 'FUNDING_OFFICE_NUM' is used just to separate Allotment from the rest of the Funding Offices 
         SELECT 0 AS ALLOT_ID,
                v.FUND_CAT, 
                TO_NUMBER(DECODE( to_char(v.FUND_CAT), '0', '71', to_char(v.FUNDING_OFFICE_NUM) )) AS FUNDING_OFFICE_NUM,
                --v.FUNDING_OFFICE_NUM,
                'Allotment' AS FUNDING_OFFICE_DESC, 
                v.PY,  
                TRIM(TO_CHAR(Q1_AMOUNT, '999,999,999,999')) AS Q1_AMOUNT, 
                TRIM(TO_CHAR(Q2_AMOUNT, '999,999,999,999')) AS Q2_AMOUNT, 
                TRIM(TO_CHAR(Q3_AMOUNT, '999,999,999,999')) AS Q3_AMOUNT, 
                TRIM(TO_CHAR(Q4_AMOUNT, '999,999,999,999')) AS Q4_AMOUNT, 
                TRIM(TO_CHAR(QT_AMOUNT, '999,999,999,999')) AS QT_AMOUNT,
                --------------
                TRIM(TO_CHAR(Q1_AMOUNT_NCFMS, '999,999,999,999')) AS Q1_AMOUNT_NCFMS, 
                TRIM(TO_CHAR(Q2_AMOUNT_NCFMS, '999,999,999,999')) AS Q2_AMOUNT_NCFMS, 
                TRIM(TO_CHAR(Q3_AMOUNT_NCFMS, '999,999,999,999')) AS Q3_AMOUNT_NCFMS, 
                TRIM(TO_CHAR(Q4_AMOUNT_NCFMS, '999,999,999,999')) AS Q4_AMOUNT_NCFMS, 
                TRIM(TO_CHAR(QT_AMOUNT_NCFMS, '999,999,999,999')) AS QT_AMOUNT_NCFMS,
                --------------
                1 AS ADJUSTED_SORT_ORDER                         
          FROM (                                                                                   
                        SELECT al.FUND_CAT, 
                               SUM(al.FUNDING_OFFICE_NUM) AS FUNDING_OFFICE_NUM,
                               al.PY,
                               -----------------------------
                               Round(SUM(al.Q1_AMOUNT)) AS Q1_AMOUNT,                                               
                               Round(SUM(al.Q2_AMOUNT)) AS Q2_AMOUNT,                                              
                               Round(SUM(al.Q3_AMOUNT)) AS Q3_AMOUNT,                                              
                               Round(SUM(al.Q4_AMOUNT)) AS Q4_AMOUNT,                                             
                               Round(SUM(al.Q1_AMOUNT))+Round(SUM(al.Q2_AMOUNT))+Round(SUM(al.Q3_AMOUNT))+Round(SUM(al.Q4_AMOUNT)) AS QT_AMOUNT,   
                               ------------------------------
                               Round(SUM(an.Q1_AMOUNT)) AS Q1_AMOUNT_NCFMS,                                               
                               Round(SUM(an.Q2_AMOUNT)) AS Q2_AMOUNT_NCFMS,                                              
                               Round(SUM(an.Q3_AMOUNT)) AS Q3_AMOUNT_NCFMS,                                              
                               Round(SUM(an.Q4_AMOUNT)) AS Q4_AMOUNT_NCFMS,                                             
                               Round(SUM(an.Q1_AMOUNT))+Round(SUM(an.Q2_AMOUNT))+Round(SUM(an.Q3_AMOUNT))+Round(SUM(an.Q4_AMOUNT)) AS QT_AMOUNT_NCFMS                         
                          FROM ALLOTMENT al, 
                               ALLOTMENT_NCFMS an                                                            
                         WHERE al.PY = an.PY(+) 
                           AND al.FUND_CAT = an.FUND_CAT(+)
                           AND al.FUNDING_OFFICE_NUM = an.FUNDING_OFFICE_NUM(+)
                         GROUP BY al.FUND_CAT, al.PY
                    ) v                                                                               
              UNION ALL ---------------------------------------------------------------------------------------------------------
              --// This part of SQL statement generates individual rows for each Fundinf Office per quarter.
                SELECT al.ALLOT_ID,
                       al.FUND_CAT, 
                       al.FUNDING_OFFICE_NUM, 
                       TRIM(REPLACE(fo.FUNDING_OFFICE_DESC, 'Region', '')) AS FUNDING_OFFICE_DESC, 
                       al.PY,
                       --------------------------
                       TRIM(TO_CHAR(al.Q1_AMOUNT, '999,999,999,999')) AS Q1_AMOUNT, 
                       TRIM(TO_CHAR(al.Q2_AMOUNT, '999,999,999,999')) AS Q2_AMOUNT, 
                       TRIM(TO_CHAR(al.Q3_AMOUNT, '999,999,999,999')) AS Q3_AMOUNT, 
                       TRIM(TO_CHAR(al.Q4_AMOUNT, '999,999,999,999')) AS Q4_AMOUNT, 
                       TRIM(TO_CHAR(al.Q1_AMOUNT+al.Q2_AMOUNT+al.Q3_AMOUNT+al.Q4_AMOUNT, '999,999,999,999'))  AS QT_AMOUNT,
                       -------------------------
                       TRIM(TO_CHAR(an.Q1_AMOUNT, '999,999,999,999')) AS Q1_AMOUNT_NCFMS, 
                       TRIM(TO_CHAR(an.Q2_AMOUNT, '999,999,999,999')) AS Q2_AMOUNT_NCFMS, 
                       TRIM(TO_CHAR(an.Q3_AMOUNT, '999,999,999,999')) AS Q3_AMOUNT_NCFMS, 
                       TRIM(TO_CHAR(an.Q4_AMOUNT, '999,999,999,999')) AS Q4_AMOUNT_NCFMS, 
                       TRIM(TO_CHAR(an.Q1_AMOUNT+an.Q2_AMOUNT+an.Q3_AMOUNT+an.Q4_AMOUNT, '999,999,999,999'))  AS QT_AMOUNT_NCFMS,
                       -------------------------
                       DECODE(al.FUNDING_OFFICE_NUM, 30, 19, al.FUNDING_OFFICE_NUM)+1 AS ADJUSTED_SORT_ORDER
                  FROM ALLOTMENT al,
                       ALLOTMENT_NCFMS an,
                       LU_FUNDING_OFFICE fo                            
                 WHERE al.PY= an.PY(+)
                   AND al.FUND_CAT = an.FUND_CAT(+)
                   AND al.FUNDING_OFFICE_NUM = an.FUNDING_OFFICE_NUM(+)
                   AND fo.FUNDING_OFFICE_NUM = al.FUNDING_OFFICE_NUM 
                 ORDER BY ADJUSTED_SORT_ORDER
      ) 
      WHERE PY = arg_PY 
        AND FUND_CAT IN (SELECT FUND_CAT
                           FROM LU_FUND_CAT
                          WHERE FUND_CAT != 'S/E');
--------------------------------------------------------------------------------
SELECT SUM(Q1_AMOUNT)+SUM(Q2_AMOUNT)+SUM(Q3_AMOUNT)+SUM(Q4_AMOUNT)
  INTO v_NCFMSloadSum
  FROM ALLOTMENT_NCFMS
 WHERE PY=arg_PY;

IF v_NCFMSloadSum IS NULL OR v_NCFMSloadSum = 0 THEN
  v_NCFMSload := 'Data from NCFMS as of '||to_char(sysdate, 'mm/dd/yyyy, hh:mi')||' for the selected year was not loaded.'; 
ELSE
    SELECT to_char(Max(create_date), 'mm/dd/yyyy, hh:mi') 
      INTO v_NCFMSload
      FROM ALLOTMENT_NCFMS
     WHERE PY = arg_PY;
    
    v_NCFMSload := 'Data from NCFMS as of '||v_NCFMSload||'.';
END IF;

OPEN rc_DateNCFMSloaded FOR
SELECT v_NCFMSload AS NCFMS_LOAD_MSG
  FROM dual;
--------------------------------------------------------------------------------
END sp_getApprAllot;
--==============================================================================

PROCEDURE sp_saveAppropAllot(  argPY         IN NUMBER
                              ,argUserID     IN VARCHAR2
                              ,argApprUpdSQL IN VARCHAR2  --APPR:1_123^2_987^  
                              ,argAlltUpdSQL IN VARCHAR2) -- ALLT:1_1_1000000^1_2_2000000^1_3_1000000^1_4_2000000^
IS 
--------------------------------------------------------------------------------
v_ApprUpdSQL VARCHAR2(4000) DEFAULT SUBSTR(argApprUpdSQL,6); -- REMOVE 'APPR:' from the string
v_AlltUpdSQL VARCHAR2(4000) DEFAULT SUBSTR(argAlltUpdSQL,6);
v_Pos        NUMBER DEFAULT 0;
v_PosDel     NUMBER DEFAULT 0; -- "^" Delimeter position
v_ID         NUMBER;
v_Amnt       NUMBER;
v_Q          NUMBER;
v_Counter    NUMBER DEFAULT 0;
--------------------------------------------------------------------------------
BEGIN
--- APPROPRIATION --------------------------------------------------------------
SELECT INSTR(v_ApprUpdSQL, '^') INTO v_PosDel FROM DUAL;

 WHILE (v_PosDel > 0 OR v_PosDel IS NOT NULL) LOOP
    SELECT INSTR(v_ApprUpdSQL, '_') INTO v_Pos FROM DUAL;                       --
    SELECT SUBSTR(v_ApprUpdSQL, 1, v_Pos-1) INTO v_ID FROM DUAL;

    SELECT SUBSTR(v_ApprUpdSQL, v_Pos+1) INTO v_ApprUpdSQL FROM DUAL;
    SELECT INSTR(v_ApprUpdSQL, '^') INTO v_Pos FROM DUAL;
    SELECT SUBSTR(v_ApprUpdSQL, 1, v_Pos-1) INTO v_Amnt FROM DUAL;

    UPDATE APPROPRIATION
       SET AMOUNT = v_Amnt,
           UPDATE_USER = argUserID,
           UPDATE_DATE = SYSDATE
     WHERE APPROP_ID = v_ID;
     
     SELECT SUBSTR(v_ApprUpdSQL, v_Pos+1) INTO v_ApprUpdSQL FROM DUAL;
     SELECT INSTR(v_ApprUpdSQL, '^') INTO v_PosDel FROM DUAL;
  END LOOP;
--------------------------------------------------------------------------------  
--- ALLOTMENT ------------------------------------------------------------------
-- ALLT:1_1_1000000^1_2_2000000^1_3_1000000^1_4_2000000^
-- 1_2_2000000^  -  1-ALLOPT_ID; 2-Second Quarter, it determines column name, in this case "Q2_AMOUNT";  2000000 - Amount that updates column "Q2_AMOUNT".
SELECT INSTR(v_AlltUpdSQL, '^') INTO v_PosDel FROM DUAL;
--  Ex. of the FIRST ITERRATION:

 WHILE (v_PosDel > 0 OR v_PosDel IS NOT NULL) LOOP
    SELECT INSTR(v_AlltUpdSQL, '_') INTO v_Pos FROM DUAL;                       --
    SELECT SUBSTR(v_AlltUpdSQL, 1, v_Pos-1) INTO v_ID FROM DUAL;
    SELECT SUBSTR(v_AlltUpdSQL, v_Pos+1) INTO v_AlltUpdSQL FROM DUAL;
    --
    SELECT INSTR(v_AlltUpdSQL, '_') INTO v_Pos FROM DUAL;                       --
    SELECT SUBSTR(v_AlltUpdSQL, 1, v_Pos-1) INTO v_Q FROM DUAL;
    SELECT SUBSTR(v_AlltUpdSQL, v_Pos+1) INTO v_AlltUpdSQL FROM DUAL;
    --
    SELECT INSTR(v_AlltUpdSQL, '^') INTO v_Pos FROM DUAL;
    SELECT SUBSTR(v_AlltUpdSQL, 1, v_Pos-1) INTO v_Amnt FROM DUAL;
    SELECT SUBSTR(v_AlltUpdSQL, v_Pos+1) INTO v_AlltUpdSQL FROM DUAL;

  
    IF v_Q = 1 THEN
        SELECT Count(*) INTO v_Counter FROM ALLOTMENT WHERE ALLOT_ID = v_ID AND Q1_AMOUNT = v_Amnt;
        IF v_Counter = 0 THEN
          UPDATE ALLOTMENT SET Q1_AMOUNT = v_Amnt, UPDATE_USER = argUserID, UPDATE_DATE = SYSDATE
           WHERE ALLOT_ID = v_ID;
        END IF;
    ELSIF v_Q = 2 THEN
        SELECT Count(*) INTO v_Counter FROM ALLOTMENT WHERE ALLOT_ID = v_ID AND Q2_AMOUNT = v_Amnt;
        IF v_Counter = 0 THEN
          UPDATE ALLOTMENT SET Q2_AMOUNT = v_Amnt, UPDATE_USER = argUserID, UPDATE_DATE = SYSDATE 
           WHERE ALLOT_ID = v_ID;
        END IF;
    ELSIF v_Q = 3 THEN
        SELECT Count(*) INTO v_Counter FROM ALLOTMENT WHERE ALLOT_ID = v_ID AND Q3_AMOUNT = v_Amnt;
        IF v_Counter = 0 THEN
          UPDATE ALLOTMENT SET Q3_AMOUNT = v_Amnt, UPDATE_USER = argUserID, UPDATE_DATE = SYSDATE 
           WHERE ALLOT_ID = v_ID;
        END IF;
    ELSIF v_Q = 4 THEN
        
        SELECT Count(*) INTO v_Counter FROM ALLOTMENT WHERE ALLOT_ID = v_ID AND Q4_AMOUNT = v_Amnt;
        IF v_Counter = 0 THEN
          UPDATE ALLOTMENT SET Q4_AMOUNT = v_Amnt, UPDATE_USER = argUserID, UPDATE_DATE = SYSDATE
           WHERE ALLOT_ID = v_ID;
        END IF;
    END IF;
    
    SELECT INSTR(v_AlltUpdSQL, '^') INTO v_PosDel FROM DUAL;
 END LOOP;
 
--------------------------------------------------------------------------------
 COMMIT;

END sp_saveAppropAllot;
--==============================================================================

PROCEDURE sp_getAppropriation (arg_FundCat IN VARCHAR2 DEFAULT 'ALL'
                              ,arg_PY      IN NUMBER   DEFAULT 0
                              ,rc_getAppropriation OUT refc_Base)

IS
--------------------------------------------------------------------------------
v_SQL VARCHAR2(1000) DEFAULT 
'SELECT APPROP_ID, FUND_CAT, PY, AMOUNT FROM APPROPRIATION WHERE 1=1 ';
v_Where_FundCat VARCHAR2(100);
v_Where_PY      VARCHAR2(100);
--------------------------------------------------------------------------------
BEGIN

-- I.
      IF arg_FundCat != 'ALL' THEN
          v_Where_FundCat := ' AND FUND_CAT = '''||arg_FundCat||''' ';
          v_SQL := v_SQL||v_Where_FundCat;
      END IF;
      
-- II.
      IF arg_PY != 0 THEN
          v_Where_PY := ' AND PY = '||arg_PY||' ';
          v_SQL := v_SQL||v_Where_PY;
      END IF;
      
-- III.
      OPEN rc_getAppropriation FOR v_SQL;


END sp_getAppropriation;
--==============================================================================
PROCEDURE sp_getAmountsFutureSPlan ( argUserID IN VARCHAR2
                                    ,rc_getAmount_CTR_FED_HQC OUT refc_Base     -- CTR- CENTERS, FED- USDA, HQC- NATIONAL HQ CONTRACTS 
                                    ,rc_getAmount_GT          OUT refc_Base     -- GT- GRAND TOTAL
                                    ,rc_getAmount_APPRP       OUT refc_Base     -- APPRP- APPROPRIATION
                                    ,rc_getAmount_BBR         OUT refc_Base     -- BBR- BALANCE BEFORE RESERVE
                                    ,rc_getAmount_RES         OUT refc_Base     -- RES- RESERVE
                                    ,rc_getAmount_BAR         OUT refc_Base     -- BAR- BALANCE AFTER RESERVE
                                    ,rc_getResPercent         OUT refc_Base     -- Reserve percentage
                                    ,rc_TransClosed           OUT refc_Base     -- Are all transaction closed?
                                    )
IS 
v_Counter NUMBER DEFAULT 0;
-----------------------------------
-- GT stands for GRAND TOTAL.
v_GT_CurrentPY NUMBER;
v_GT_FOP       NUMBER;
v_GT_NextPY    NUMBER;
-----------------------------------
-- APPRP stands for APPROPRIATION
v_APPRP_CurrentPY NUMBER;
v_APPRP_FOP       NUMBER;
v_APPRP_NextPY    NUMBER;
-----------------------------------
-- BBR stands for BALANCE BEFORE RESERVE
v_BBR_CurrentPY NUMBER;
v_BBR_FOP       NUMBER;
v_BBR_NextPY    NUMBER;
-----------------------------------
-- RES stands for RESERVE
v_RES_CurrentPY NUMBER;
v_RES_FOP       NUMBER;
v_RES_NextPY    NUMBER;
v_RES_Percentage NUMBER;
-----------------------------------
-- BAR stands for BALANCE AFTER RESERVE
v_BAR_CurrentPY NUMBER;
v_BAR_FOP       NUMBER;
v_BAR_NextPY    NUMBER;
-----------------------------------
CURSOR c_getSplanCat_NextPY IS
  SELECT RECORD_ID, SPLAN_CAT_ID, PY
    FROM SPLAN_CAT 
   WHERE PY = v_NextYearPY;
   
-----------------------------------
BEGIN
--------------------------------------------------------------------------------
-- Remove records that could have been removed in another procedures from SPLAN_CAT, but remains in SPLAN_TRANS_FUTURE: 

DELETE SPLAN_TRANS_FUTURE stf
 WHERE stf.SPLAN_CAT_ID NOT IN (select sc.SPLAN_CAT_ID
                                  from SPLAN_CAT sc
                                 where sc.PY = stf.PY
                                   and sc.PY = v_NextYearPY);

--------------------------------------------------------------------------------
-- Make sure that records that were added into SPLAN_CAT inserted into SPLAN_TRANS_FUTURE:
FOR r_Record IN c_getSplanCat_NextPY
LOOP
    SELECT Count(*)
      INTO v_Counter
      FROM SPLAN_TRANS_FUTURE stf
     WHERE stf.PY = v_NextYearPY
       AND stf.SPLAN_CAT_ID = r_Record.SPLAN_CAT_ID;
    ---------
    IF v_Counter = 0 THEN
          INSERT INTO SPLAN_TRANS_FUTURE ( RECORD_ID, SPLAN_CAT_ID, AMOUNT, PY, TRANS_NOTE,
                                           CREATE_USER, CREATE_DATE, UPDATE_USER, UPDATE_DATE)
          VALUES (SEQ_SPLAN_TRANS_FUTURE.nextval, r_Record.SPLAN_CAT_ID, 0, v_NextYearPY, NULL,
                  argUserID, SYSDATE, argUserID, SYSDATE );
    END IF;
END LOOP;
COMMIT;
--------------------------------------------------------------------------------
OPEN rc_getAmount_CTR_FED_HQC FOR -- CENTERS, USDA, NATIONAL HQ CONTRACTS:
        -- NOTE: pseudocolumn SYS_CONNECT_BY_PATH() returns string with the leading "," (',3,56,789')
        --       removing "," by SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2), gives this result: '3,56,789'
--------------------------------------------------------------------------------
-- The following SQL retrieves data applicable to: 'CTR' -	CENTERS, 'FED' - USDA, 'HQC' - NATIONAL HQ CENTERS.
        SELECT SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, '_'), 2) AS PATH,
               SPLAN_PKG.f_getFullHieratchyPath(ml.SPLAN_CAT_ID) AS FULL_PATH,
               LEVEL AS H_LEVEL, 
               DECODE (LEVEL, 1, SPLAN_PKG.f_getL3_SPLAN_CAT_ID(LEVEL, SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2)), ml.SPLAN_CAT_ID ) AS SPLAN_CAT_ID,
               ml.SPLAN_CAT_ID AS SPLAN_CAT_ID_ORG,
               ml.SPLAN_CAT_PARENT_ID, 
               -----------------
               DECODE (LEVEL, 3, SPLAN_PKG.f_getFormatedCatDesc(SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2), ml.SORT_ORDER, ml.SPLAN_CAT_DESC), 
                              ml.SPLAN_CAT_DESC)  AS SPLAN_CAT_DESC,
               --// LPAD(' ', LEVEL*2)||ml.SPLAN_CAT_DESC AS SPLAN_CAT_DESC,
               ----------------
               -- SPLAN_PKG.f_getNoteNextYear(LEVEL, ml.SPLAN_CAT_ID) AS NOTE_NEXT_YEAR_PY,
               SPLAN_PKG.f_getNoteNextYear(v_NextYearPY, ml.SPLAN_CAT_ID) AS NOTE_NEXT_YEAR_PY,
               -----------------
               ml.SPLAN_SECTION_CODE,
               -----------------------------------------------------------------
               (SELECT TRIM( TO_CHAR(SUM(std.amount),'999,999,999,999') )
                  FROM SPLAN_TRANS st
                      ,SPLAN_TRANS_DET std
                 WHERE st.splan_trans_id = std.splan_trans_id
                   AND st.py = v_CurrentPY
                   AND std.splan_cat_id IN ( select column_value 
                                              --from table(JFAS.f_ConvertStringToListOfVals ( SPLAN_PKG.f_getFullHieratchyPath(ml.SPLAN_CAT_ID), ',' )) ) ) AS AMOUNT_AS_OF_TODAY,
                                              --from table(JFAS.f_ConvertStringToListOfVals ( SPLAN_PKG.f_getFullPathFromVIEW(ml.SPLAN_CAT_ID), ',' )) ) ) AS AMOUNT_AS_OF_TODAY,
                                              from table(JFAS.f_ConvertStringToListOfVals ( SPLAN_PKG.f_getFullHieratchyPath(ml.SPLAN_CAT_ID), ',' ))  ) )  AS AMOUNT_AS_OF_TODAY,
               -----------------------------------------------------------------
               SPLAN_PKG.f_getAmountFOPNextPY(ml.SPLAN_CAT_ID) AS AMOUNT_NEXT_YEAR_FOP,
               -----------------------------------------------------------------
               (SELECT TRIM( TO_CHAR(SUM(stf.AMOUNT),'999,999,999,999') )
                  FROM SPLAN_TRANS_FUTURE stf
                 WHERE stf.PY = v_NextYearPY
                   AND stf.SPLAN_CAT_ID IN ( select column_value 
                                               --from table(JFAS.f_ConvertStringToListOfVals ( SPLAN_PKG.f_getFullHieratchyPath(ml.SPLAN_CAT_ID), ',' )) ) )  AS AMOUNT_NEXT_YEAR_PY 
                                               --from table(JFAS.f_ConvertStringToListOfVals ( SPLAN_PKG.f_getFullPathFromVIEW(ml.SPLAN_CAT_ID), ',' )) ) )  AS AMOUNT_NEXT_YEAR_PY
                                               from table(JFAS.f_ConvertStringToListOfVals ( SPLAN_PKG.f_getFullHieratchyPath(ml.SPLAN_CAT_ID), ',' ))  ) )  AS AMOUNT_NEXT_YEAR_PY
               -----------------------------------------------------------------
          FROM SPLAN_CAT_MASTER_LIST ml
         WHERE ml.SPLAN_SECTION_CODE NOT IN ('SUM')     
           AND ml.SPLAN_CAT_DESC NOT LIKE ('CATEGORY%')                --//Line excludes "CATEGORIES" that created for hierarchical data structure.
           AND ml.SPLAN_CAT_DESC NOT LIKE ('SUBCATEGORY%')             --//Line excludes "SUBCATEGORIES" that created for hierarchical data structure.
                                                                       --//None of them have to be shown on the screen.
           AND ml.SPLAN_CAT_ID IN (
                                  ----------------------------------------------
                                  -- Selects Sub-Categories (LEVEL=3):
                                  -- (1-st SQL)
                                  SELECT t1.SPLAN_CAT_ID 
                                    FROM SPLAN_CAT t1
                                   WHERE t1.PY =v_NextYearPY 
                                  UNION
                                  -- Selects Categories (LEVEL=2) based on selected Sub-Categories:
                                  -- (2-nd SQL)
                                  SELECT DISTINCT t2.SPLAN_CAT_PARENT_ID
                                    FROM SPLAN_CAT_MASTER_LIST t2
                                   WHERE t2.SPLAN_CAT_ID IN ( -- (1-st SQL)
                                                               SELECT t1.SPLAN_CAT_ID 
                                                                 FROM SPLAN_CAT t1 
                                                                WHERE t1.PY = v_NextYearPY) 
                                  UNION
                                  -- Selects Sections (LEVEL=1) based on Sub-Categories and Categories:
                                  -- (3-rd SQL)
                                  SELECT DISTINCT t3.SPLAN_CAT_PARENT_ID
                                    FROM SPLAN_CAT_MASTER_LIST t3
                                   WHERE t3.SPLAN_CAT_ID IN ( -- (2-nd SQL)
                                                              SELECT DISTINCT t2.SPLAN_CAT_PARENT_ID
                                                                FROM SPLAN_CAT_MASTER_LIST t2
                                                               WHERE t2.SPLAN_CAT_ID IN ( -- (1-st SQL)
                                                                                           SELECT t1.SPLAN_CAT_ID 
                                                                                             FROM SPLAN_CAT t1
                                                                                            WHERE t1.PY = v_NextYearPY))
                                  ----------------------------------------------
                                 )
        START WITH SPLAN_CAT_PARENT_ID = 0            
        CONNECT BY NOCYCLE PRIOR SPLAN_CAT_ID = SPLAN_CAT_PARENT_ID
        ORDER SIBLINGS BY SORT_ORDER;
-- End of the portion of SQL that retrievs data applicable to: 'CTR' -	CENTERS, 'FED' - USDA, 'HQC' - NATIONAL HQ CENTERS.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- GRAND TOTAL -----------------------------------------------------------------
-- 1:
------/*
/*SELECT SUM(std.amount)
  INTO v_GT_CurrentPY
  FROM SPLAN_TRANS st
      ,SPLAN_TRANS_DET std
 WHERE st.splan_trans_id = std.splan_trans_id
   AND st.py = v_CurrentPY;
*/
-------*/

-- 2:
SELECT SUM(f.AMOUNT)
  INTO v_GT_FOP
  FROM FOP f
WHERE f.py = v_NextYearPY and
       aapp_num not in (select aapp_num
                        from AAPP
                        where splan_cat_id in (select splan_cat_id
                                               from splan_cat_master_list
                                               where upper(summary_code) in ('RESERVE', 'BARESERVE'))
                        );
-- 3:
SELECT SUM(AMOUNT)
  INTO v_GT_NextPY
  FROM SPLAN_TRANS_FUTURE 
 WHERE PY = v_NextYearPY;

OPEN rc_getAmount_GT FOR 
    SELECT SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2) AS PATH, 
           LEVEL AS H_LEVEL, 
           DECODE (LEVEL, 1, SPLAN_PKG.f_getL3_SPLAN_CAT_ID(LEVEL, SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2)),
                          ml.SPLAN_CAT_ID ) AS SPLAN_CAT_ID,
           ml.SPLAN_CAT_ID AS SPLAN_CAT_ID_ORG,
           ml.SPLAN_CAT_PARENT_ID, 
           -----------------
           --LPAD(' ', LEVEL*2)||ml.SPLAN_CAT_DESC AS SPLAN_CAT_DESC,
           ml.SPLAN_CAT_DESC,
           -----------------
           --'' AS NOTE_CURRENT_PY,
           '' AS NOTE_NEXT_YEAR_PY,
           --SORT_ORDER, 
           ml.SPLAN_SECTION_CODE,
           --v_CurrentPY AS CURRENT_PY,
           --v_NextYearPY AS NEXT_YEAR_PY,
           -----------------------------
           '' AS AMOUNT_AS_OF_TODAY, --TRIM(TO_CHAR(v_GT_CurrentPY, '999,999,999,999')) AS AMOUNT_AS_OF_TODAY,
           TRIM(TO_CHAR(v_GT_FOP,       '999,999,999,999')) AS AMOUNT_NEXT_YEAR_FOP,
           TRIM(TO_CHAR(v_GT_NextPY,    '999,999,999,999')) AS AMOUNT_NEXT_YEAR_PY
           -----------------------------
      FROM SPLAN_CAT_MASTER_LIST ml
     WHERE ml.SPLAN_SECTION_CODE = 'SUM'
       AND UPPER(ml.SPLAN_CAT_DESC) LIKE UPPER('%GRAND TOTAL%')
    START WITH ml.SPLAN_CAT_PARENT_ID = 0            
    CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID; --ORDER SIBLINGS BY SORT_ORDER;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- APPROPRIATION ---------------------------------------------------------------
-- 1:
SELECT SUM(AMOUNT)
  INTO v_APPRP_CurrentPY
  FROM APPROPRIATION
 WHERE PY = v_CurrentPY
   AND FUND_CAT = 'OPS';
 
--SELECT SUM(AMOUNT)
--  INTO v_APPRP_FOP 
--  FROM APPROPRIATION
-- WHERE PY = v_NextYearPY;

-- 2, 3:
SELECT Count(*)
  INTO v_Counter
  FROM APPROPRIATION
 WHERE PY = v_NextYearPY
   AND FUND_CAT = 'OPS';
IF v_Counter = 0 THEN
  v_APPRP_NextPY := 0;
  v_APPRP_FOP := 0;
ELSE
  SELECT SUM(AMOUNT)
    INTO v_APPRP_NextPY
    FROM APPROPRIATION
   WHERE PY = v_NextYearPY
     AND FUND_CAT = 'OPS';
     
   v_APPRP_FOP := v_APPRP_NextPY;
   
END IF;

OPEN rc_getAmount_APPRP FOR
    SELECT SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2) AS PATH, 
           LEVEL AS H_LEVEL, 
           ml.SPLAN_CAT_ID AS SPLAN_CAT_ID,
           DECODE (LEVEL, 1, SPLAN_PKG.f_getL3_SPLAN_CAT_ID(LEVEL, SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2)),
                          ml.SPLAN_CAT_ID ) AS SPLAN_CAT_ID,
           --ml.SPLAN_CAT_ID,
           ml.SPLAN_CAT_PARENT_ID, 
           -----------------
           --LPAD(' ', LEVEL*2)||ml.SPLAN_CAT_DESC AS SPLAN_CAT_DESC,
           ml.SPLAN_CAT_DESC,
           -----------------
           --'' AS NOTE_CURRENT_PY,
           '' AS NOTE_NEXT_YEAR_PY,
           --SORT_ORDER, 
           ml.SPLAN_SECTION_CODE,
           --v_CurrentPY AS CURRENT_PY,
           --v_NextYearPY AS NEXT_YEAR_PY,
           -----------------------------
           TRIM(TO_CHAR(v_APPRP_CurrentPY, '999,999,999,999')) AS AMOUNT_AS_OF_TODAY,
           TRIM(TO_CHAR(v_APPRP_FOP,       '999,999,999,999')) AS AMOUNT_NEXT_YEAR_FOP,
           TRIM(TO_CHAR(v_APPRP_NextPY,    '999,999,999,999')) AS AMOUNT_NEXT_YEAR_PY 
           -----------------------------
      FROM SPLAN_CAT_MASTER_LIST ml
     WHERE ml.SPLAN_SECTION_CODE = 'SUM'
       AND UPPER(ml.SPLAN_CAT_DESC) LIKE UPPER('%APPROPRIATION%')
    START WITH ml.SPLAN_CAT_PARENT_ID = 0            
    CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID; --ORDER SIBLINGS BY SORT_ORDER;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- BALANCE BEFORE RESERVE ------------------------------------------------------
-- BBR stands for BALANCE BEFORE RESERVE
-- 1:
-----/*
----v_BBR_CurrentPY := v_APPRP_CurrentPY - v_GT_CurrentPY;
------*/
-- 2:
v_BBR_FOP := v_APPRP_NextPY - v_GT_FOP;
-- 3:
v_BBR_NextPY := v_APPRP_NextPY - v_GT_NextPY;

OPEN rc_getAmount_BBR FOR
    SELECT SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2) AS PATH, 
           LEVEL AS H_LEVEL, 
           DECODE (LEVEL, 1, SPLAN_PKG.f_getL3_SPLAN_CAT_ID(LEVEL, SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2)),
                          ml.SPLAN_CAT_ID ) AS SPLAN_CAT_ID,
           ml.SPLAN_CAT_ID AS SPLAN_CAT_ID_ORG,
           ml.SPLAN_CAT_PARENT_ID, 
           -----------------
           --LPAD(' ', LEVEL*2)||ml.SPLAN_CAT_DESC AS SPLAN_CAT_DESC,
           ml.SPLAN_CAT_DESC,
           -----------------
           --'' AS NOTE_CURRENT_PY,
           '' AS NOTE_NEXT_YEAR_PY,
           --SORT_ORDER, 
           ml.SPLAN_SECTION_CODE,
           --v_CurrentPY AS CURRENT_PY,
           --v_NextYearPY AS NEXT_YEAR_PY,
           ------------------
           TRIM(TO_CHAR('', '999,999,999,999')) AS AMOUNT_AS_OF_TODAY, -- v_BBR_CurrentPY  
           TRIM(TO_CHAR(v_BBR_FOP,       '999,999,999,999')) AS AMOUNT_NEXT_YEAR_FOP,
           TRIM(TO_CHAR(v_BBR_NextPY,    '999,999,999,999')) AS AMOUNT_NEXT_YEAR_PY 
           ------------------
      FROM SPLAN_CAT_MASTER_LIST ml
     WHERE ml.SPLAN_SECTION_CODE = 'SUM'
       AND UPPER(ml.SPLAN_CAT_DESC) LIKE UPPER('%BALANCE BEFORE RESERVE%')
    START WITH ml.SPLAN_CAT_PARENT_ID = 0            
    CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID; --ORDER SIBLINGS BY SORT_ORDER;

--------------------------------------------------------------------------------
-------------------------------------------------------------------------------- 
-- RESERVE --------------------------------------------------------------------- 
SELECT ss.VALUE
  INTO v_RES_Percentage
  FROM SYSTEM_SETTING ss
 WHERE ss.SYSTEM_SETTING_CODE = 'spend_plan_reserve_percentage';
-- 1:
----------------/*
SELECT SUM(std.AMOUNT)
  INTO v_RES_CurrentPY
  FROM SPLAN_TRANS st
      ,SPLAN_TRANS_DET std
 WHERE std.SPLAN_TRANS_ID = st.SPLAN_TRANS_ID
   AND st.PY = v_CurrentPY;
---------------*/
-- 2:
SELECT f_getAmountFOP_Summary( 'RESERVE', v_NextYearPY, NULL, NULL)
  INTO v_RES_FOP 
  FROM DUAL;
-- 3:
SELECT ROUND(v_APPRP_NextPY*v_RES_Percentage/100)
  INTO v_RES_NextPY 
  FROM DUAL; 

OPEN rc_getAmount_RES FOR
    SELECT SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2) AS PATH, 
           LEVEL AS H_LEVEL, 
           DECODE (LEVEL, 1, SPLAN_PKG.f_getL3_SPLAN_CAT_ID(LEVEL, SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2)),
                          ml.SPLAN_CAT_ID ) AS SPLAN_CAT_ID,
           ml.SPLAN_CAT_ID AS SPLAN_CAT_ID_ORG,
           ml.SPLAN_CAT_PARENT_ID, 
           -----------------
           --LPAD(' ', LEVEL*2)||ml.SPLAN_CAT_DESC AS SPLAN_CAT_DESC,
           ml.SPLAN_CAT_DESC||' (0'||v_RES_Percentage||'% of appropriation)' AS SPLAN_CAT_DESC,
           -----------------
           --'' AS NOTE_CURRENT_PY,
           '' AS NOTE_NEXT_YEAR_PY,
           --SORT_ORDER, 
           ml.SPLAN_SECTION_CODE,
           --v_CurrentPY AS CURRENT_PY,
           --v_NextYearPY AS NEXT_YEAR_PY,
           ------------------
           TRIM(TO_CHAR('',           '999,999,999,999')) AS AMOUNT_AS_OF_TODAY,
           TRIM(TO_CHAR(v_RES_FOP,    '999,999,999,999')) AS AMOUNT_NEXT_YEAR_FOP,
           TRIM(TO_CHAR(v_RES_NextPY, '999,999,999,999')) AS AMOUNT_NEXT_YEAR_PY 
           ------------------
      FROM SPLAN_CAT_MASTER_LIST ml
     WHERE ml.SPLAN_SECTION_CODE = 'SUM'
       AND UPPER(ml.SPLAN_CAT_DESC) IN  ('RESERVE')--,'CATEGORY RESERVE','SUBCATEGORY RESERVE' )
    START WITH ml.SPLAN_CAT_PARENT_ID = 0            
    CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID; --ORDER SIBLINGS BY SORT_ORDER;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- BALANCE AFTER RESERVE:
v_BAR_CurrentPY := v_APPRP_CurrentPY - (v_GT_CurrentPY + v_RES_CurrentPY) ;

SELECT f_getAmountFOP_Summary( 'BARESERVE', v_NextYearPY, NULL, NULL)
  INTO v_BAR_FOP       
  FROM DUAL;
  
v_BAR_NextPY := v_APPRP_NextPY - (v_GT_NextPY + v_RES_NextPY) ;

OPEN rc_getAmount_BAR FOR
    SELECT SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2) AS PATH, 
           LEVEL AS H_LEVEL, 
           DECODE (LEVEL, 1, SPLAN_PKG.f_getL3_SPLAN_CAT_ID(LEVEL, SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2)),
                          ml.SPLAN_CAT_ID ) AS SPLAN_CAT_ID,
           ml.SPLAN_CAT_ID AS SPLAN_CAT_ID_ORG,
           ml.SPLAN_CAT_PARENT_ID, 
           -----------------
           --LPAD(' ', LEVEL*2)||ml.SPLAN_CAT_DESC AS SPLAN_CAT_DESC,
           ml.SPLAN_CAT_DESC,
           -----------------
           --'' AS NOTE_CURRENT_PY,
           '' AS NOTE_NEXT_YEAR_PY,
           --SORT_ORDER, 
           ml.SPLAN_SECTION_CODE,
           v_CurrentPY AS CURRENT_PY,
           v_NextYearPY AS NEXT_YEAR_PY,
           ------------------
           TRIM(TO_CHAR('', '999,999,999,999')) AS AMOUNT_AS_OF_TODAY, --v_BAR_CurrentPY  
           TRIM(TO_CHAR(v_BAR_FOP,       '999,999,999,999')) AS AMOUNT_NEXT_YEAR_FOP,
           TRIM(TO_CHAR(v_BAR_NextPY,    '999,999,999,999')) AS AMOUNT_NEXT_YEAR_PY 
           ------------------
      FROM SPLAN_CAT_MASTER_LIST ml
     WHERE ml.SPLAN_SECTION_CODE = 'SUM'
       AND UPPER(ml.SPLAN_CAT_DESC) LIKE ('%BALANCE AFTER RESERVE%' )
    START WITH ml.SPLAN_CAT_PARENT_ID = 0            
    CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID; --ORDER SIBLINGS BY SORT_ORDER;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
OPEN rc_getResPercent FOR 
SELECT ss.VALUE AS RES_PERCENT 
  FROM SYSTEM_SETTING ss
 WHERE ss.SYSTEM_SETTING_CODE = 'spend_plan_reserve_percentage';

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 'YES' all tansactions are closed.
-- 'NO'  at least one is not closed.

SELECT Count(*) INTO v_Counter
  FROM SPLAN_TRANS
 WHERE TRANS_STATUS_CODE = 'O'
   AND PY = v_CurrentPY;

IF v_Counter = 0 THEN
    SELECT Count(*) INTO v_Counter
      FROM BATCH_PROCESS_LOG
     WHERE YEAR = v_NextYearPY
       AND STATUS != 1;
       
    IF v_Counter = 0 THEN
        OPEN rc_TransClosed FOR
        SELECT 'YES' AS TRANS_CLOSED FROM DUAL;
    ELSE
        OPEN rc_TransClosed FOR
        SELECT 'NO' AS TRANS_CLOSED FROM DUAL;
    END IF;
    
ELSE
    OPEN rc_TransClosed FOR 
    SELECT 'NO' AS TRANS_CLOSED FROM DUAL;
END IF;


--==============================================================================
END sp_getAmountsFutureSPlan;

--==============================================================================
PROCEDURE sp_saveFutureSplan ( argUserID IN VARCHAR2 
                              ,argSplan  IN VARCHAR2)
IS
v_Pos NUMBER DEFAULT 0;
v_Splan VARCHAR2(4000) DEFAULT argSplan;
v_SplanCatID NUMBER DEFAULT 0;
v_Amount NUMBER DEFAULT 0;
v_Note SPLAN_TRANS_FUTURE.TRANS_NOTE%TYPE DEFAULT '';
BEGIN
  -- '5_0_NOVAL^6_0_NOVAL^7_0_NOVAL'
    SELECT INSTR(v_Splan,'_') 
      INTO v_Pos -- 2
      FROM DUAL;
    
      WHILE v_Pos!= 0 LOOP
          SELECT SUBSTR(v_Splan, 1, v_Pos-1)
            INTO v_SplanCatID -- 5
            FROM DUAL;
          
          SELECT SUBSTR(v_Splan, v_Pos+1 )
            INTO v_Splan -- '0_NOVAL^6_0_NOVAL^7_0_NOVAL'
            FROM DUAL;
        
          SELECT INSTR(v_Splan,'_')
            INTO v_Pos --2
            FROM DUAL; 
          
          SELECT SUBSTR(v_Splan, 1, v_Pos-1)
            INTO v_Amount -- 0
            FROM DUAL;
          
          SELECT SUBSTR(v_Splan, v_Pos+1 )
            INTO v_Splan -- 'NOVAL^6_0_NOVAL^7_0_NOVAL'
            FROM DUAL; 
          
          SELECT INSTR(v_Splan,'^')
            INTO v_Pos --2
            FROM DUAL;          

          SELECT SUBSTR(v_Splan, 1, v_Pos-1)
            INTO v_Note -- 0
            FROM DUAL;        
          if v_Note = 'NOVAL' then v_Note := NULL; end if;  
          
          SELECT SUBSTR(v_Splan, v_Pos+1 )
            INTO v_Splan -- 'NOVAL^6_0_NOVAL^7_0_NOVAL'
            FROM DUAL; 
          ----------------------------------------------------------------------        
          UPDATE SPLAN_TRANS_FUTURE stf
             SET AMOUNT = TO_NUMBER(v_Amount)
                ,TRANS_NOTE = v_Note
                ,UPDATE_USER = argUserID
                ,UPDATE_DATE = SYSDATE
           WHERE SPLAN_CAT_ID = v_SplanCatID;
          ----------------------------------------------------------------------
          SELECT INSTR(v_Splan,'_') 
            INTO v_Pos -- 2
            FROM DUAL;
      END LOOP;
      COMMIT;

END sp_saveFutureSplan;
--==============================================================================

PROCEDURE sp_getTopSplanCodes ( argsplanSectionCode IN VARCHAR2
                                 ,argPY     IN NUMBER
                                 ,argStartParentId     IN NUMBER
                                 ,rc_TopSplanCodes OUT refc_Base)

IS

BEGIN
	OPEN rc_TopSplanCodes FOR

	SELECT  hierarchylevel, splancatid, splancatidorg, SPLAN_CAT_PARENT_ID, splancatdesc, splancatdescwithprefix, splansectioncode, costcatid, transdisplay, transassoc, reportdisplay, SORT_ORDER, PATH
FROM (
               SELECT LEVEL                  AS hierarchylevel,
               DECODE(ml.SPLAN_CAT_ID, 1, (select ml2.SPLAN_CAT_ID
                                             from SPLAN_CAT_MASTER_LIST ml2
                                            where ml2.SPLAN_CAT_DESC LIKE ('CATEGORY CENTERS'))
                                            ,ml.SPLAN_CAT_ID) AS splancatid,
                                            --where (ml2.SPLAN_CAT_DESC LIKE ('CATEGORY CENTERS') OR ml2.SPLAN_CAT_DESC LIKE ('SUBCATEGORY USDA') ) )
                                            --,ml.SPLAN_CAT_ID) AS splancatid,
               ml.SPLAN_CAT_ID        AS splancatidorg,
               ml.SPLAN_CAT_PARENT_ID,
               LPAD(' ', LEVEL*2)||ml.SPLAN_CAT_DESC AS splancatdesc,
               --ml.SPLAN_CAT_DESC      AS splancatdesc,
               DECODE (LEVEL, 3, SPLAN_PKG_DON.f_getFormatedCatDesc(SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2), ml.SORT_ORDER, ml.SPLAN_CAT_DESC), ml.SPLAN_CAT_DESC)  AS splancatdescwithprefix,
               --ml.SPLAN_CAT_NOTE, --ml.COST_CAT_ID,
               ml.SPLAN_SECTION_CODE  AS splansectioncode,
               ml.COST_CAT_ID		  AS costcatid,
               ml.TRANS_DISPLAY       AS transdisplay,
               ml.TRANS_ASSOC         AS transassoc,
               ml.REPORT_DISPLAY      AS reportdisplay,
               ml.SORT_ORDER,
               SUBSTR(SYS_CONNECT_BY_PATH(ml.SPLAN_CAT_ID, ','), 2) AS PATH
          FROM SPLAN_CAT_MASTER_LIST ml
         WHERE --ml.SPLAN_CAT_DESC NOT LIKE ('CATEGORY%')
                --AND ml.SPLAN_CAT_DESC NOT LIKE ('SUBCATEGORY%')
				--AND 
        (ml.SPLAN_SECTION_CODE = argsplanSectionCode OR argsplanSectionCode = 'all')

            START WITH ml.SPLAN_CAT_PARENT_ID = argStartParentID
            CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID
            ORDER SIBLINGS BY ml.SORT_ORDER
) v
WHERE  SPLAN_CAT_PARENT_ID = 0 OR v.splancatidorg IN (
                                  -- Selects Sub-Categories (LEVEL=3):
                                  -- (1-st SQL)
                                  SELECT t1.SPLAN_CAT_ID
                                    FROM SPLAN_CAT t1
                                   WHERE (t1.PY = argPY OR argPY = 0)
                                  UNION
                                  -- Selects Categories (LEVEL=2) based on selected Sub-Categories:
                                  -- (2-nd SQL)
                                  SELECT DISTINCT t2.SPLAN_CAT_PARENT_ID
                                    FROM SPLAN_CAT_MASTER_LIST t2
                                   WHERE t2.SPLAN_CAT_ID IN ( -- (1-st SQL)
                                                               SELECT t1.SPLAN_CAT_ID
                                                                 FROM SPLAN_CAT t1
                                                                WHERE (t1.PY = argPY OR argPY = 0)) --v_NextYearPY)
                                  UNION
                                  -- Selects Sections (LEVEL=1) based on Sub-Categories and Categories:
                                  -- (3-rd SQL)
                                  SELECT DISTINCT t3.SPLAN_CAT_PARENT_ID
                                    FROM SPLAN_CAT_MASTER_LIST t3
                                   WHERE t3.SPLAN_CAT_ID IN ( -- (2-nd SQL)
                                                              SELECT DISTINCT t2.SPLAN_CAT_PARENT_ID
                                                                FROM SPLAN_CAT_MASTER_LIST t2
                                                               WHERE t2.SPLAN_CAT_ID IN ( -- (1-st SQL)
                                                                                           SELECT t1.SPLAN_CAT_ID
                                                                                             FROM SPLAN_CAT t1
                                                                                            WHERE (t1.PY = argPY OR argPY = 0))) -- v_NextYearPY))
);




END sp_getTopSplanCodes;
--==============================================================================
PROCEDURE sp_setNextYrSplan (argUserID IN VARCHAR2
                            ,argPY IN NUMBER
                            ,argSPNextPYRES IN NUMBER
                            ,argSPNextPYBAR IN NUMBER
                            ,rc_sqlCodes OUT refc_Base
                            )
IS
--------------------------------------------------------------------------------
v_SplanTransID    NUMBER DEFAULT 9999; 
v_SplanTransDetID NUMBER DEFAULT 8888; 
v_SplanCatID      NUMBER DEFAULT 7777;
v_OfficeType      VARCHAR2(10);

v_AmntRES NUMBER; -- RESERVE Amount
v_AmntBAR NUMBER; -- BALANCE AFTER RESERVE Amount
v_SplanCatID_RES NUMBER;
v_SplanCatID_BAR NUMBER;

--------------------------------------------------------------------------------
CURSOR c_getTransFuture IS
SELECT SPLAN_CAT_ID, AMOUNT, PY, TRANS_NOTE
  FROM SPLAN_TRANS_FUTURE
 WHERE PY = argPY;
--------------------------------------------------------------------------------
BEGIN
    SAVEPOINT spStarts;

    -- Loop through all records in SPLAN_TRANS_FUTURE, and for each record ...
    FOR r_getTransFuture IN c_getTransFuture LOOP
    
    v_SplanTransID    := SEQ_SPLAN_TRANS.nextval;
    v_SplanTransDetID := SEQ_SPLAN_TRANS_DET.nextval;
  
-- 1. Write transaction to SPLAN_TRANS:
            INSERT INTO SPLAN_TRANS ( SPLAN_TRANS_ID, TRANS_DATE, TRANS_DESC, PY, TRANS_NOTE, 
                                      TRANS_STATUS_CODE, TRANS_TYPE_CODE,
                                      CREATE_USER,CREATE_DATE,UPDATE_USER,UPDATE_DATE )
            VALUES (v_SplanTransID, SYSDATE, 'Initial spend plan amount', r_getTransFuture.PY, r_getTransFuture.TRANS_NOTE,
                    'O', 'INIT', 
                    argUserID, SYSDATE, argUserID, SYSDATE);
        
-- 2. Write transaction detail to SPLAN_TRANS_DET
            INSERT INTO SPLAN_TRANS_DET (SPLAN_TRANS_DET_ID,SPLAN_TRANS_ID, SPLAN_CAT_ID, AMOUNT, 
                                         CREATE_DATE, UPDATE_DATE, CREATE_USER, UPDATE_USER )
            VALUES (v_SplanTransDetID, v_SplanTransID, r_getTransFuture.SPLAN_CAT_ID, r_getTransFuture.AMOUNT,
                    SYSDATE, SYSDATE, argUserID, argUserID);
      
-- 3. For each SPLAN_TRANS_DET – populate the detail ID into FOP.SPLAN_TRANS_DET_ID column for all appropriate FOPs.
        -- 3.a 
            v_SplanCatID := r_getTransFuture.SPLAN_CAT_ID;
  
        -- 3.b
            SELECT DECODE(SPLAN_SECTION_CODE, --if
                                              'CTR', 
                                              --then
                                              'DOL', 
                                              --else
                                              SPLAN_SECTION_CODE )
              INTO v_OfficeType
              FROM SPLAN_CAT_MASTER_LIST
             WHERE SPLAN_CAT_ID = v_SplanCatID;
      
        -- 3.c      
            IF v_OfficeType = 'DOL' THEN
                  UPDATE FOP
                     SET SPLAN_TRANS_DET_ID = v_SplanTransDetID
                        ,UPDATE_USER_ID = argUserID
                        ,UPDATE_TIME = SYSDATE
                   WHERE ADJUSTMENT_TYPE_CODE = 'BP'
                     AND FOP_ID IN (SELECT f.FOP_ID 
                                      FROM FOP f
                                          ,LU_FUNDING_OFFICE fo
                                     WHERE f.PY = r_getTransFuture.PY
                                       AND fo.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM 
                                       AND fo.OFFICE_TYPE = v_OfficeType
                                       AND f.COST_CAT_ID IN (select ml.COST_CAT_ID
                                                               from SPLAN_CAT_MASTER_LIST ml
                                                              where ml.SPLAN_CAT_ID = v_SplanCatID));
                                                              
            ELSIF v_OfficeType = 'FED' THEN
                  UPDATE FOP
                     SET SPLAN_TRANS_DET_ID = v_SplanTransDetID
                        ,UPDATE_USER_ID = argUserID
                        ,UPDATE_TIME = SYSDATE
                   WHERE ADJUSTMENT_TYPE_CODE = 'BP'
                     AND FOP_ID IN (SELECT f.FOP_ID
                                      FROM FOP f
                                          ,LU_FUNDING_OFFICE fo
                                     WHERE f.PY = r_getTransFuture.PY
                                       AND fo.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM 
                                       AND fo.OFFICE_TYPE = v_OfficeType);              
            
            ELSIF v_OfficeType = 'HQC' THEN
                  UPDATE FOP
                     SET SPLAN_TRANS_DET_ID = v_SplanTransDetID
                        ,UPDATE_USER_ID = argUserID
                        ,UPDATE_TIME = SYSDATE
                   WHERE ADJUSTMENT_TYPE_CODE = 'BP'
                     AND FOP_ID IN (SELECT f.FOP_ID
                                      FROM FOP f
                                     WHERE f.PY = r_getTransFuture.PY
                                       AND f.AAPP_NUM IN (SELECT aa.AAPP_NUM 
                                                            FROM AAPP aa 
                                                           WHERE aa.SPLAN_CAT_ID IN (select ml.SPLAN_CAT_ID
                                                                                       from SPLAN_CAT_MASTER_LIST ml
                                                                                      where ml.SPLAN_CAT_ID = v_SplanCatID)));          
            END IF;

    END LOOP;

-- 4. Creating transaction for the RESERVE 
-- Change calculation
      SELECT f_getAmountFOP_Summary( 'RESERVE', v_NextYearPY, NULL, NULL)
        INTO v_AmntRES 
        FROM DUAL;

      SELECT SPLAN_CAT_ID
        INTO v_SplanCatID_RES
        FROM SPLAN_CAT_MASTER_LIST
       WHERE SUMMARY_CODE = 'RESERVE';

      v_SplanTransID := SEQ_SPLAN_TRANS.nextval;
    
      INSERT INTO SPLAN_TRANS ( SPLAN_TRANS_ID, TRANS_DATE, TRANS_DESC, PY,
                                TRANS_NOTE, TRANS_STATUS_CODE, TRANS_TYPE_CODE,
                                CREATE_USER, CREATE_DATE, UPDATE_USER, UPDATE_DATE )
      VALUES ( v_SplanTransID, SYSDATE, 'Initial spend plan amount', v_NextYearPY, 
               NULL, 'O', 'INIT', argUserID, SYSDATE, argUserID, SYSDATE);

      v_SplanTransDetID := SEQ_SPLAN_TRANS_DET.nextval;

      INSERT INTO SPLAN_TRANS_DET ( SPLAN_TRANS_DET_ID, SPLAN_TRANS_ID, SPLAN_CAT_ID, AMOUNT,
                                    CREATE_DATE, UPDATE_DATE, CREATE_USER, UPDATE_USER )
      VALUES ( v_SplanTransDetID, v_SplanTransID, v_SplanCatID_RES,  argSPNextPYRES,
               SYSDATE, SYSDATE, argUserID, argUserID);

                  UPDATE FOP
                     SET SPLAN_TRANS_DET_ID = v_SplanTransDetID
                        ,UPDATE_USER_ID = argUserID
                        ,UPDATE_TIME = SYSDATE
                   WHERE ADJUSTMENT_TYPE_CODE = 'BP'
                     AND FOP_ID IN (SELECT f.FOP_ID
                                      FROM FOP f
                                     WHERE f.PY = v_NextYearPY
                                       AND f.AAPP_NUM IN (SELECT aa.AAPP_NUM 
                                                            FROM AAPP aa 
                                                           WHERE aa.SPLAN_CAT_ID IN (select ml.SPLAN_CAT_ID
                                                                                       from SPLAN_CAT_MASTER_LIST ml
                                                                                      where ml.SPLAN_CAT_ID = v_SplanCatID_RES)));  


-- 5. Creating transaction for the BALANCE AFTER RESERVE:
-- Change calculation
      SELECT f_getAmountFOP_Summary( 'BARESERVE', v_NextYearPY, NULL, NULL)
        INTO v_AmntBAR 
        FROM DUAL;

      SELECT SPLAN_CAT_ID
        INTO v_SplanCatID_BAR
        FROM SPLAN_CAT_MASTER_LIST
       WHERE SUMMARY_CODE = 'BARESERVE';

      v_SplanTransID := SEQ_SPLAN_TRANS.nextval;

      INSERT INTO SPLAN_TRANS ( SPLAN_TRANS_ID, TRANS_DATE, TRANS_DESC, PY,
                                TRANS_NOTE, TRANS_STATUS_CODE, TRANS_TYPE_CODE,
                                CREATE_USER, CREATE_DATE, UPDATE_USER, UPDATE_DATE )
      VALUES ( v_SplanTransID, SYSDATE, 'Initial spend plan amount', v_NextYearPY,
               NULL, 'O', 'INIT', argUserID, SYSDATE, argUserID, SYSDATE);

      v_SplanTransDetID := SEQ_SPLAN_TRANS_DET.nextval;

      INSERT INTO SPLAN_TRANS_DET ( SPLAN_TRANS_DET_ID, SPLAN_TRANS_ID, SPLAN_CAT_ID, AMOUNT,
                                   CREATE_DATE, UPDATE_DATE, CREATE_USER, UPDATE_USER )
      VALUES ( v_SplanTransDetID, v_SplanTransID, v_SplanCatID_BAR, argSPNextPYBAR,
               SYSDATE, SYSDATE, argUserID, argUserID);


                  UPDATE FOP
                     SET SPLAN_TRANS_DET_ID = v_SplanTransDetID
                        ,UPDATE_USER_ID = argUserID
                        ,UPDATE_TIME = SYSDATE
                   WHERE ADJUSTMENT_TYPE_CODE = 'BP'
                     AND FOP_ID IN (SELECT f.FOP_ID
                                      FROM FOP f
                                     WHERE f.PY = v_NextYearPY
                                       AND f.AAPP_NUM IN (SELECT aa.AAPP_NUM 
                                                            FROM AAPP aa 
                                                           WHERE aa.SPLAN_CAT_ID IN (select ml.SPLAN_CAT_ID
                                                                                       from SPLAN_CAT_MASTER_LIST ml
                                                                                      where ml.SPLAN_CAT_ID = v_SplanCatID_BAR)));  

-- 6. Create record in BATCH_PROCESS_LOG for SPLAN and new PY, with status of 1
       INSERT INTO BATCH_PROCESS_LOG (YEAR, PROCESS_TYPE, USER_ID, DATE_PROCESSED, STATUS, VST_ALLOCATION_PER )
       VALUES ( argPY, 'SPLAN', argUserID, SYSDATE, 1, NULL);    

-- 7. Create new set of records based on the existing ones for the next year:
INSERT INTO SPLAN_CAT ( RECORD_ID, SPLAN_CAT_ID, PY, 
                        CREATE_USER, CREATE_DATE, UPDATE_USER, UPDATE_DATE )
SELECT seq_SPLAN_CAT.nextval, SPLAN_CAT_ID, PY+1, argUserID, sysdate, argUserID, sysdate 
FROM SPLAN_CAT
where PY = argPY;
/*
INSERT INTO SPLAN_TRANS_FUTURE t1 (t1.RECORD_ID, t1.SPLAN_CAT_ID, t1.AMOUNT, t1.PY, 
                                   t1.TRANS_NOTE, t1.CREATE_USER, t1.CREATE_DATE, t1.UPDATE_USER, t1.UPDATE_DATE )
 SELECT SEQ_SPLAN_TRANS_FUTURE.nextval, t2.SPLAN_CAT_ID, 0, t2.PY+1, NULL, argUserID, SYSDATE, argUserID, SYSDATE
   FROM SPLAN_TRANS_FUTURE t2
  WHERE PY = argPY;
*/
-- 8.	Clean out all records from SPLAN_TRANS_FUTURE   
    DELETE SPLAN_TRANS_FUTURE
     WHERE PY = argPY;

-- 9. 
INSERT INTO SYSTEM_AUDIT (AUDIT_ID, AAPP_NUM, CONTRACT_STATUS_ID, FOP_ID, ADJUSTMENT_ID,
                          AAPP_SECTION_ID, DESCRIPTION, USER_ID, UPDATE_DATE )
 SELECT SEQ_SYSTEM_AUDIT.nextval, NULL, NULL, NULL, NULL, NULL, 'Next year SPEND PLAN is created', argUserID, SYSDATE
  FROM dual;



   COMMIT;
  
OPEN rc_sqlCodes FOR
--select 1 from dual;
SELECT v_SqlCode AS SQL_CODE, v_SqlErrm AS SQL_ERRM
  FROM DUAL;
--------------------------------------------------------------------------------
EXCEPTION
  WHEN OTHERS THEN
    v_SqlCode := SQLCODE;
    v_SqlErrm := SQLERRM;
  ROLLBACK TO spStarts;
  RETURN;
--------------------------------------------------------------------------------
END sp_setNextYrSplan;
--==============================================================================
--==============================================================================
FUNCTION f_getAmountFOP_Summary( argSummaryCode IN VARCHAR2 DEFAULT 'RESERVE'
                                ,argPY          IN NUMBER   DEFAULT NULL
                                ,argDateFrom    IN VARCHAR2 DEFAULT NULL
                                ,argDateTo      IN VARCHAR2 DEFAULT NULL) RETURN NUMBER
IS
v_RtnVal NUMBER;
v_DateFrom DATE DEFAULT TO_DATE(argDateFrom,'MM-DD-YYYY');
v_DateTo   DATE DEFAULT TO_DATE(argDateTo,  'MM-DD-YYYY');
BEGIN

IF argDateFrom IS NULL THEN
      SELECT Min(date_executed) INTO v_DateFrom FROM FOP;
END IF;

IF argDateTo IS NULL THEN
      SELECT Max(date_executed) INTO v_DateTo FROM FOP;
END IF;

    SELECT SUM(fop.amount)
      INTO v_RtnVal
      FROM fop, aapp, splan_cat_master_list
     WHERE fop.aapp_num = aapp.aapp_num 
       AND aapp.splan_cat_id = splan_cat_master_list.splan_cat_id 
       AND Upper(summary_code) = argSummaryCode --'RESERVE' 
       AND fop.py IN (select DECODE(argPY, /*if*/NULL, /*then*/(select distinct f.PY from fop f), /*else*/argPY )
                        from dual)  -- (2014)
       AND trunc(fop.date_executed) >= v_DateFrom -- to_date('1/1/2015','MM-DD-YYYY') 
       AND trunc(fop.date_executed) <= v_DateTo -- to_date('3/12/2015','MM-DD-YYYY')
       ;
    
    RETURN v_RtnVal;
    
END f_getAmountFOP_Summary;
--==============================================================================
--==============================================================================
/*
FUNCTION f_getTransactionAmount( argHierarchyLevel IN NUMBER
                                ,argPY             IN NUMBER DEFAULT UTILITY.fun_getCurrntProgram_Year
                                ,argCat_Parent_ID  IN NUMBER
                                ,argCat_ID         IN NUMBER
                                --,argTrans_Code     IN VARCHAR2 
                                ) RETURN NUMBER
IS
v_Amount VARCHAR2(100) DEFAULT 0;
BEGIN
--------------------------------------------------------------------------------
-- Amount calculation for CURRENT_PY begins:
IF argPY = v_CurrentPY THEN
      -- LEVEL 3:---------------------------------------------------------------
      IF argHierarchyLevel = 3 THEN
      -- The same code applies to argTrans_Code = 'INIT' and argTrans_Code = 'TRNS'
                SELECT SUM(std.amount)
                -- May consider the this, it is more descriptive, but result is the same: 
                -- SELECT DECODE(argTrans_Code, 'INIT', std.amount, 'TRNS', SUM(std.amount))
                -- 'INIT' has one record; 'TRNS' may have several.
                  INTO v_Amount
                  FROM SPLAN_TRANS st
                      ,SPLAN_TRANS_DET std
                 WHERE st.splan_trans_id = std.splan_trans_id
                   AND st.py = argPY
                   --AND st.trans_type_code = argTrans_Code
                   AND std.splan_cat_id = argCat_ID;

      -- LEVEL 2:---------------------------------------------------------------
      ELSIF argHierarchyLevel = 2 THEN
       -- The same code applies to argTrans_Code = 'INIT' and argTrans_Code = 'TRNS'
                SELECT SUM(std.amount)
                  INTO v_Amount
                  FROM SPLAN_TRANS st
                      ,SPLAN_TRANS_DET std
                 WHERE st.splan_trans_id = std.splan_trans_id
                   AND st.py = argPY
                   --AND st.trans_type_code = argTrans_Code
                   AND std.splan_cat_id IN ( -- SQL below retrieves SPLAN_CAT_ID that belong to categories for LEVEL=3:
                                            SELECT SPLAN_CAT_ID
                                              FROM SPLAN_CAT_MASTER_LIST
                                             WHERE SPLAN_CAT_PARENT_ID = argCat_ID); 
      -- LEVEL 1:---------------------------------------------------------------
      ELSIF argHierarchyLevel = 1 THEN
                SELECT SUM(std.amount)
                  INTO v_Amount
                  FROM SPLAN_TRANS st
                      ,SPLAN_TRANS_DET std
                 WHERE st.splan_trans_id = std.splan_trans_id
                   AND st.py = argPY
                   --AND st.trans_type_code = argTrans_Code
                   AND std.splan_cat_id IN ( -- SQL below retrievs SPLAN_CAT_ID that belong to categories for LEVEL=3:
                                            SELECT SPLAN_CAT_ID
                                              FROM SPLAN_CAT_MASTER_LIST
                                             WHERE SPLAN_CAT_PARENT_ID IN ( -- SQL below retrievs SPLAN_CAT_ID that belong to categories for LEVEL=2:
                                                                            SELECT SPLAN_CAT_ID
                                                                              FROM SPLAN_CAT_MASTER_LIST
                                                                             WHERE SPLAN_CAT_PARENT_ID = argCat_ID ));
      END IF; -- end of argHierarchyLevel
END IF; -- end of argPY
-- Amount calculation for CURRENT_PY ends.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Amount calculation for NEXT_YEAR_PY begins:
IF argPY = v_NextYearPY THEN
      -- LEVEL=3 ---------------------------------------------------------------
      IF argHierarchyLevel = 3 THEN
              SELECT Count(*)
                INTO v_Counter
                FROM SPLAN_TRANS_FUTURE
               WHERE SPLAN_CAT_ID = argCat_ID;
              IF v_Counter = 0 THEN 
                 v_Amount := 0;
              ELSE
                  SELECT stf.AMOUNT
                    INTO v_Amount
                    FROM SPLAN_TRANS_FUTURE stf
                   WHERE stf.SPLAN_CAT_ID = argCat_ID;
              END IF;
      -- LEVEL = 2 -------------------------------------------------------------
      ELSIF argHierarchyLevel = 2 THEN
              SELECT SUM(stf.AMOUNT)
                INTO v_Amount
                FROM SPLAN_TRANS_FUTURE stf
               WHERE stf.SPLAN_CAT_ID IN ( -- SQL below retrievs SPLAN_CAT_ID (LEVEL=3) that belong to categories for LEVEL=2:
                                          SELECT ml3.SPLAN_CAT_ID
                                            FROM SPLAN_CAT_MASTER_LIST ml3
                                           WHERE ml3.SPLAN_CAT_PARENT_ID = argCat_ID);              
      -- LEVEL = 1 -------------------------------------------------------------
      ELSIF argHierarchyLevel = 1 THEN
              SELECT SUM(stf.AMOUNT)
                INTO v_Amount
                FROM SPLAN_TRANS_FUTURE stf
               WHERE stf.SPLAN_CAT_ID IN  ( -- SQL below retrievs SPLAN_CAT_ID that belong to categories for LEVEL=3:
                                            SELECT SPLAN_CAT_ID
                                              FROM SPLAN_CAT_MASTER_LIST
                                             WHERE SPLAN_CAT_PARENT_ID IN ( -- SQL below retrievs SPLAN_CAT_ID that belong to categories for LEVEL=2:
                                                                            SELECT SPLAN_CAT_ID
                                                                              FROM SPLAN_CAT_MASTER_LIST
                                                                             WHERE SPLAN_CAT_PARENT_ID = argCat_ID ));
      END IF;
END IF;
-- Amount calculation for NEXT_YEAR_PY ends.
--------------------------------------------------------------------------------
  SELECT NVL(v_Amount, 0 )
    INTO v_Amount
    FROM DUAL;

  RETURN v_Amount;

END f_getTransactionAmount;
*/
--==============================================================================
/* OLD VERSION:
FUNCTION f_getNoteNextYear(argLevel      IN NUMBER
                          ,argSplanCatID IN NUMBER) RETURN VARCHAR2
IS
v_RtnVal VARCHAR2(1000);
v_L3_SplanCatID NUMBER;
v_Counter NUMBER;
BEGIN
  IF argLevel = 1 THEN
              SELECT Count(*)
                INTO v_Counter
                FROM SPLAN_CAT_MASTER_LIST ml
               WHERE LEVEL = 2
               START WITH ml.SPLAN_CAT_PARENT_ID = argSplanCatID            
             CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID;
              
              IF v_Counter = 1 THEN
                  SELECT stf.TRANS_NOTE
                    INTO v_RtnVal
                    FROM SPLAN_TRANS_FUTURE stf
                   WHERE stf.SPLAN_CAT_ID = ( SELECT ml.SPLAN_CAT_ID
                                                FROM SPLAN_CAT_MASTER_LIST ml
                                               WHERE LEVEL = 2
                                               START WITH ml.SPLAN_CAT_PARENT_ID = argSplanCatID            
                                             CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID);
             END IF;
  --ELSIF argLevel = 2 THEN
  ELSIF argLevel = 3 THEN
    SELECT stf.TRANS_NOTE
      INTO v_RtnVal
      FROM SPLAN_TRANS_FUTURE stf
     WHERE stf.SPLAN_CAT_ID = argSplanCatID;
  END IF;
  
  RETURN v_RtnVal;
  
END f_getNoteNextYear;
*/
-- UPDATED VERSION:
FUNCTION f_getNoteNextYear(argNextYearPY IN NUMBER, argSPLAN_CAT_ID IN NUMBER) RETURN VARCHAR2
IS
v_RtnVal VARCHAR2(1000) DEFAULT '';
v_Counter NUMBER DEFAULT 0;
BEGIN
    SELECT Count(*)
      INTO v_Counter
      FROM SPLAN_TRANS_FUTURE
     WHERE PY = argNextYearPY
       AND SPLAN_CAT_ID = argSPLAN_CAT_ID;
    
    IF v_Counter != 0 THEN
        SELECT TRANS_NOTE 
          INTO v_RtnVal
          FROM SPLAN_TRANS_FUTURE
         WHERE PY = argNextYearPY
           AND SPLAN_CAT_ID = argSPLAN_CAT_ID;
    END IF;

    RETURN v_RtnVal;

END f_getNoteNextYear;
--==============================================================================
FUNCTION f_getL3_SPLAN_CAT_ID(argLevel IN NUMBER
                             ,argPath  IN VARCHAR2) RETURN NUMBER
-- f_getL3_SPLAN_CAT_ID this name means: get ID of the LEVEL 3 record when argLevel != 3
IS
v_RtnVal    NUMBER;
v_SectionID NUMBER;
v_CatID     NUMBER;
v_SubCatID  NUMBER;
v_Str       VARCHAR2(10) DEFAULT argPath;
v_Pos       NUMBER;
v_Counter   NUMBER;
BEGIN

-- Ex: v_Str = '3,16,2'
SELECT INSTR(v_Str,',') INTO v_Pos FROM DUAL;                                   -- v_Pos = 2
IF v_Pos = 0 THEN
    SELECT TO_NUMBER(argPath) INTO v_SectionID FROM DUAL;
ELSE 
    SELECT TO_NUMBER(SUBSTR(v_Str, 1, v_Pos-1)) INTO v_SectionID FROM DUAL;     -- v_CatID = 3
    SELECT SUBSTR(v_Str, v_Pos+1)               INTO v_Str FROM DUAL;           -- v_Str = 16,2
    SELECT INSTR(v_Str,',')                     INTO v_Pos FROM DUAL;           -- v_Pos = 3
    SELECT TO_NUMBER(SUBSTR(v_Str, 1, v_Pos-1)) INTO v_CatID FROM DUAL;         -- v_CatID = 16
    SELECT TO_NUMBER(SUBSTR(v_Str, v_Pos+1))    INTO v_SubCatID FROM DUAL;      -- v_SubCatID = 2
END IF;

  IF argLevel = 1 THEN
          -- The following SQL retrieves and counts records related to the Section which ID is determined above.
          SELECT Count(*)
            INTO v_Counter
            FROM SPLAN_CAT_MASTER_LIST t3
           WHERE t3.SPLAN_CAT_PARENT_ID IN (SELECT t2.SPLAN_CAT_ID
                                              FROM SPLAN_CAT_MASTER_LIST t2
                                             WHERE t2.SPLAN_CAT_PARENT_ID = v_SectionID);
          
          IF v_Counter = 1 THEN
                  SELECT t3.SPLAN_CAT_ID
                    INTO v_SubCatID
                    FROM SPLAN_CAT_MASTER_LIST t3
                   WHERE t3.SPLAN_CAT_PARENT_ID IN (SELECT t2.SPLAN_CAT_ID
                                                      FROM SPLAN_CAT_MASTER_LIST t2
                                                     WHERE t2.SPLAN_CAT_PARENT_ID = v_SectionID);
                  v_RtnVal := v_SubCatID;
          ELSE 
                  v_RtnVal := TO_NUMBER(argPath);
          END IF;
  ELSE -- LEVEL != 1
          v_RtnVal := v_SubCatID;
  END IF;

  RETURN v_RtnVal;
  
END f_getL3_SPLAN_CAT_ID;
--==============================================================================

FUNCTION f_getAmountFOPNextPY(argCatID IN NUMBER) RETURN VARCHAR2
IS
v_RtnVal    VARCHAR2(100);
v_Amount    NUMBER;
v_Level     NUMBER;
v_SplanSectionCode VARCHAR2(10);
v_CostCatID NUMBER;
v_ListOfCatIDs VARCHAR2(1000);
--------------------------------------------------------------------------------
CURSOR c_getRecordData IS
    SELECT LEVEL AS H_LEVEL, ml.SPLAN_CAT_ID, ml.COST_CAT_ID, ml.SPLAN_SECTION_CODE
      FROM SPLAN_CAT_MASTER_LIST ml
     START WITH ml.SPLAN_CAT_PARENT_ID = 0            
    CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID;
--------------------------------------------------------------------------------
BEGIN

FOR r_getRecordData IN c_getRecordData
LOOP
    IF r_getRecordData.SPLAN_CAT_ID = argCatID THEN
        v_Level     := r_getRecordData.H_LEVEL;
        v_CostCatID := r_getRecordData.COST_CAT_ID;
        v_SplanSectionCode := r_getRecordData.SPLAN_SECTION_CODE;
        EXIT;
    END IF;
END LOOP;

/*
SELECT SPLAN_PKG.f_getFullHieratchyPath( argCatID )
  INTO v_ListOfCatIDs
  FROM dual;
*/
--/*
SELECT FULL_PATH
  INTO v_ListOfCatIDs
  FROM SPLAN_CAT_MASTER_LIST_VIEW
 WHERE SPLAN_CAT_ID = argCatID;
--*/

IF v_SplanSectionCode = 'CTR' THEN

        SELECT SUM(f.AMOUNT) INTO v_Amount
          FROM FOP f
              ,LU_FUNDING_OFFICE fo
         WHERE f.PY = v_NextYearPY
           AND fo.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM 
           AND fo.OFFICE_TYPE = 'DOL'
           AND f.COST_CAT_ID IN (select ml.COST_CAT_ID
                                   from SPLAN_CAT_MASTER_LIST ml
                                  where ml.SPLAN_CAT_ID IN ( select column_value 
                                                               from table(JFAS.f_ConvertStringToListOfVals ( v_ListOfCatIDs, ',' )) ) 
                                );

ELSIF v_SplanSectionCode = 'FED' THEN
        SELECT SUM(f.AMOUNT) INTO v_Amount
          FROM FOP f
              ,LU_FUNDING_OFFICE fo
         WHERE f.PY = v_NextYearPY
           AND fo.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM --: 30,40,50,60
           AND fo.OFFICE_TYPE = v_SplanSectionCode ; --'FED'
           
ELSIF v_SplanSectionCode = 'HQC' THEN
        SELECT SUM(f.AMOUNT) INTO v_Amount
          FROM FOP f
         WHERE f.PY = v_NextYearPY
           AND f.AAPP_NUM IN (SELECT aa.AAPP_NUM 
                                FROM AAPP aa 
                               WHERE aa.SPLAN_CAT_ID IN (select column_value 
                                                           from table(JFAS.f_ConvertStringToListOfVals ( v_ListOfCatIDs, ',' ))  
                                                        )
                             );
/*
ELSIF v_SplanSectionCode = 'HQC' THEN
        SELECT SUM(f.AMOUNT) INTO v_Amount
          FROM FOP f
         WHERE f.PY = v_NextYearPY
           AND f.AAPP_NUM IN (SELECT aa.AAPP_NUM 
                                FROM AAPP aa 
                               WHERE aa.SPLAN_CAT_ID IN (select ml.SPLAN_CAT_ID
                                                           from SPLAN_CAT_MASTER_LIST ml
                                                          where ml.SPLAN_CAT_ID IN ( select column_value 
                                                                                       from table(JFAS.f_ConvertStringToListOfVals ( v_ListOfCatIDs, ',' )) 
                                                                                    ) 
                                                        )
                             );      
*/
END IF;
--------------------------------------------------------------------------------
  SELECT TRIM( NVL(TO_CHAR(v_Amount, '999,999,999,999'),'0')) 
    INTO v_RtnVal
    FROM DUAL;
    
  RETURN v_RtnVal;

END f_getAmountFOPNextPY;

--==============================================================================
FUNCTION f_getFormatedCatDesc(argPath  IN VARCHAR2,
                              argSortOrder IN NUMBER,
                              argSplanCatDesc IN VARCHAR2
                              ) RETURN VARCHAR2
IS 
v_RtnVal   VARCHAR2(100);
v_ParentID VARCHAR2(10);
BEGIN
  SELECT SUBSTR(argPath, 1, INSTR(argPath,',')-1)
    INTO v_ParentID
    FROM DUAL;
  IF v_ParentID = 3 THEN
    SELECT CHR(96+argSortOrder)||'. '||argSplanCatDesc
      INTO v_RtnVal
      FROM DUAL;
  ELSE
    v_RtnVal := argSplanCatDesc;
  END IF;
  

  RETURN v_RtnVal;
END f_getFormatedCatDesc;
--==============================================================================
FUNCTION f_getFullHieratchyPath(--argLevel IN NUMBER, 
                       --argPath  IN VARCHAR2,
                       argCatID IN NUMBER
                       --argParentCatID IN NUMBER
                       ) RETURN VARCHAR2
IS 
--------------------------------------------------------------------------------
v_RtnVal VARCHAR2(1000) DEFAULT '';
v_Level  NUMBER;

CURSOR c_getLevel IS
    SELECT LEVEL AS H_LEVEL, ml.SPLAN_CAT_ID, ml.SPLAN_CAT_PARENT_ID
      FROM SPLAN_CAT_MASTER_LIST ml
     START WITH ml.SPLAN_CAT_PARENT_ID = 0            
    CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID;

-- LEVEL 2:
CURSOR c_FullPath_Level2 IS
  SELECT ml2.SPLAN_CAT_ID
    FROM SPLAN_CAT_MASTER_LIST ml2
   WHERE ml2.SPLAN_CAT_PARENT_ID = argCatID;

-- LEVEL 1:
CURSOR c_FullPath_Level1 IS
  SELECT ml3.SPLAN_CAT_ID
  FROM SPLAN_CAT_MASTER_LIST ml3
 WHERE ml3.SPLAN_CAT_PARENT_ID IN ( SELECT ml2.SPLAN_CAT_ID
                                      FROM SPLAN_CAT_MASTER_LIST ml2
                                     WHERE ml2.SPLAN_CAT_PARENT_ID = argCatID);
--------------------------------------------------------------------------------
BEGIN
--------------------------------------------------------------------------------
FOR r_getLevel IN c_getLevel
LOOP
    IF r_getLevel.SPLAN_CAT_ID = argCatID THEN
        v_Level := r_getLevel.H_LEVEL;
        EXIT;
    END IF;
END LOOP;
--------------------------------------------------------------------------------
      IF v_Level = 3 THEN
          v_RtnVal := TO_CHAR(argCatID);
      ELSIF v_Level = 2 THEN
          FOR r_FullPath_Level2 IN c_FullPath_Level2
          LOOP
              v_RtnVal := v_RtnVal||TO_CHAR(r_FullPath_Level2.SPLAN_CAT_ID)||',';
          END LOOP;
          v_RtnVal := TO_CHAR(argCatID)||','||v_RtnVal;
          v_RtnVal := SUBSTR(v_RtnVal, 1, Length(v_RtnVal)-1);
          
      ELSIF v_Level = 1 THEN
          FOR r_FullPath_Level1 IN c_FullPath_Level1
          LOOP
              v_RtnVal := v_RtnVal||TO_CHAR(r_FullPath_Level1.SPLAN_CAT_ID)||',';
          END LOOP;
          v_RtnVal := TO_CHAR(argCatID)||','||v_RtnVal;
          v_RtnVal := SUBSTR(v_RtnVal, 1, Length(v_RtnVal)-1);      
      END IF;

  RETURN v_RtnVal;
END f_getFullHieratchyPath;
--==============================================================================
FUNCTION f_getFullHieratchyPath_2(argCatID IN NUMBER) RETURN VARCHAR2
-- Function calculates full path regardless of 3 level hierarchies.
 
IS
v_RtnVal VARCHAR2(1000) DEFAULT '';
v_CatID VARCHAR2(100);
--------------------------------------------------------------------------------
CURSOR c_AllCatIDs IS
SELECT TO_CHAR(v.SPLAN_CAT_ID) AS CAT_ID
  FROM SPLAN_CAT_MASTER_LIST_VIEW v;
--------------------------------------------------------------------------------
CURSOR c_CatIDs IS
SELECT TO_CHAR(v.SPLAN_CAT_ID) AS CAT_ID
  FROM SPLAN_CAT_MASTER_LIST_VIEW v
WHERE PATH LIKE  TO_CHAR(argCatID)||',%' -- if PATH starts from the value of argCatID
      OR                       -- or 
      PATH LIKE '%,'||TO_CHAR(argCatID)||',%'; -- if PATH has value of argCatID within the string.
--------------------------------------------------------------------------------
BEGIN
IF argCatID = 0 THEN
      FOR r_AllCatIDs IN c_AllCatIDs 
      LOOP
          v_CatID := r_AllCatIDs.CAT_ID;
          v_RtnVal := v_RtnVal||','||v_CatID;
      END LOOP;   
    
ELSE
      FOR r_CatIDs IN c_CatIDs 
      LOOP
          v_CatID := r_CatIDs.CAT_ID;
          v_RtnVal := v_RtnVal||','||v_CatID;
      END LOOP;
END IF;

  SELECT SUBSTR(v_RtnVal,2)
    INTO v_RtnVal
    FROM DUAL;
    
  RETURN v_RtnVal;

END f_getFullHieratchyPath_2;
--==============================================================================
/*
FUNCTION f_getFullPathFromVIEW(argCatID IN NUMBER) RETURN VARCHAR2
IS
v_RtnVal VARCHAR2(1000);
BEGIN
  SELECT m.FULL_PATH 
    INTO v_RtnVal
    FROM SPLAN_CAT_MASTER_LIST_VIEW m 
   WHERE m.splan_cat_id = argCatID;

  RETURN v_RtnVal;

END f_getFullPathFromVIEW;
*/

--==============================================================================
/* this is old procedure, re-written and re-named to f_getAmountFOPNextPY
FUNCTION f_getFOPAmount_NextPY (argLevel IN NUMBER
                               ,argCostCatID IN NUMBER
                               ,argPath IN VARCHAR2) RETURN VARCHAR2 
IS
--------------------------------------------------------------------------------
v_RtnVal    VARCHAR2(20);
v_SectionID NUMBER; -- 1-CENTERS; 2-USDA; 3-NATIONAL HQ.
v_CatID     NUMBER;
v_SubCatID  NUMBER;
v_Str       VARCHAR2(10) DEFAULT argPath;
v_Pos       NUMBER;
v_Counter   NUMBER;

v_Amount NUMBER DEFAULT 0;
--------------------------------------------------------------------------------
BEGIN
SELECT INSTR(v_Str,',') INTO v_Pos FROM DUAL;  
IF v_Pos = 0 THEN
    SELECT TO_NUMBER(argPath) INTO v_SectionID FROM DUAL;
ELSE 
    SELECT TO_NUMBER(SUBSTR(v_Str, 1, v_Pos-1)) INTO v_SectionID FROM DUAL;
    SELECT SUBSTR(v_Str, v_Pos+1)               INTO v_Str FROM DUAL;                         
    SELECT INSTR(v_Str,',')                     INTO v_Pos FROM DUAL;                               
    SELECT TO_NUMBER(SUBSTR(v_Str, 1, v_Pos-1)) INTO v_CatID FROM DUAL;         
    SELECT TO_NUMBER(SUBSTR(v_Str, v_Pos+1))    INTO v_SubCatID FROM DUAL;         
END IF;

IF v_SectionID = 1 AND argLevel = 3 THEN  -- CENTERS
    SELECT SUM(f.AMOUNT) INTO v_Amount
      FROM FOP f
          ,LU_FUNDING_OFFICE fo
     WHERE f.PY = v_NextYearPY
       AND fo.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
       AND fo.OFFICE_TYPE = 'DOL'
       AND f.COST_CAT_ID = argCostCatID;
--//////////////////////////////////////////////////////////////////////////////       
ELSIF v_SectionID = 1 AND argLevel = 1 THEN -- CENTERS
    SELECT SUM(f.AMOUNT) INTO v_Amount
      FROM FOP f
          ,LU_FUNDING_OFFICE fo
     WHERE f.PY = v_NextYearPY
       AND fo.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
       AND fo.OFFICE_TYPE = 'DOL'
       ;
--//////////////////////////////////////////////////////////////////////////////
ELSIF v_SectionID = 2 THEN
    SELECT SUM(f.AMOUNT) INTO v_Amount
      FROM FOP f
          ,LU_FUNDING_OFFICE fo
     WHERE f.PY = v_NextYearPY
       AND fo.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
       AND fo.OFFICE_TYPE = 'FED';

--// REVIEW this calculation for level 1, 2, 3       
ELSIF v_SectionID = 3 THEN
    SELECT SUM(f.AMOUNT) INTO v_Amount
      FROM FOP f
     WHERE f.PY = v_NextYearPY
       AND f.AAPP_NUM IN (SELECT aa.AAPP_NUM 
                            FROM AAPP aa 
                           WHERE aa.SPLAN_CAT_ID = v_SubCatID);
END IF;
--------------------------------------------------------------------------------
  SELECT TRIM( NVL(TO_CHAR(v_Amount, '999,999,999,999'),'0')) 
    INTO v_RtnVal
    FROM DUAL;
    
  RETURN v_RtnVal;

END f_getFOPAmount_NextPY;

 this is old procedure, re-written and re-named to f_getAmountFOPNextPY

*/

--==============================================================================
END SPLAN_PKG;