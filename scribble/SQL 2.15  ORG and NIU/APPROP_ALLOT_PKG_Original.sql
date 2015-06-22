create or replace PACKAGE APPROP_ALLOT_PKG AS
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
                           ,arg_UserID IN VARCHAR2 DEFAULT 'sys'
                           ---
                           ,rc_getListOfPY      OUT refc_Base
                           ,rc_getAppropriation OUT refc_Base
                           ,rc_getAllotment     OUT refc_Base
                           ,rc_DateNCFMSloaded  OUT refc_Base
                           );
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
END APPROP_ALLOT_PKG;

/

create or replace PACKAGE BODY APPROP_ALLOT_PKG AS
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
                           ,arg_UserID IN VARCHAR2 DEFAULT 'sys'
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

--==============================================================================
END APPROP_ALLOT_PKG;