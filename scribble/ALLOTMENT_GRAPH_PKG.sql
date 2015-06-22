create or replace PACKAGE ALLOTMENT_GRAPH_PKG AS
TYPE refc_Base is REF CURSOR;
--======================================================================================================================
PROCEDURE sp_getFundCat( rc_getFundCat  OUT refc_Base);
--======================================================================================================================
PROCEDURE sp_getFundingOffice( rc_getFundingOffice OUT refc_Base );
--======================================================================================================================
PROCEDURE sp_getAllotmentAmount(rc_getAllotmentAmount OUT refc_Base);
--======================================================================================================================
PROCEDURE sp_getAllotmentAsCSV(rc_getAllotmentAsCSV OUT refc_Base);
--======================================================================================================================
PROCEDURE sp_createCSV;
--======================================================================================================================
PROCEDURE sp_getFundOfficeAllotment(rc_getFundOfficeAllotment OUT refc_Base);
--======================================================================================================================
PROCEDURE sp_getGraphTest( rc_Timeline    OUT refc_Base,
                              rc_graphOPS    OUT refc_Base,
                              rc_graphCRA    OUT refc_Base,
                              rc_graphTotals OUT refc_Base);
--======================================================================================================================
PROCEDURE sp_getAAPP_Center_Contr(argVenue IN VARCHAR2 DEFAULT 'CALIFORNIA'
                                 ,rc_getAAPP_Center_Contr OUT refc_Base);
--======================================================================================================================
PROCEDURE sp_GraphFOPallocation_CSV(argAAPPnum IN NUMBER DEFAULT 4144
                               ,rc_GraphFOPallocation OUT refc_Base);
--======================================================================================================================
PROCEDURE sp_CreateAllotment(argFirstYearInPeriod IN NUMBER, 
                             argLastYearInPeriod IN NUMBER);
--======================================================================================================================
--PROCEDURE sp_selectAllotment( rc_selectAllotment  OUT refc_Base );
--==============================================================================
PROCEDURE sp_GraphFOPallocation_JSON(argAAPPnum IN NUMBER DEFAULT 4144
                               ,rc_GraphFOPallocation OUT refc_Base
                               --,rc_CostCategories     OUT refc_Base
                               );
--==============================================================================
PROCEDURE sp_test_JSON(argAAPPnum IN NUMBER DEFAULT 4144
                               ,rc_GraphFOPallocation OUT refc_Base
                               ,rc_CostCategories     OUT refc_Base
                               );
--======================================================================================================================
END ALLOTMENT_GRAPH_PKG;
/*
TEST this procedure:
--==============================================================================
DECLARE
c_Cursor1 SYS_REFCURSOR;
argAAPPnum NUMBER DEFAULT 4144;
BEGIN
    ALLOTMENT_GRAPH_PKG.sp_GraphFOPallocation_CSV(argAAPPnum, c_Cursor1);
END;

SELECT * FROM z_test_val;
*/
create or replace PACKAGE BODY ALLOTMENT_GRAPH_PKG AS
--======================================================================================================================
PROCEDURE sp_getFundCat( rc_getFundCat  OUT refc_Base) IS
BEGIN                         

OPEN rc_getFundCat FOR 
     SELECT fund_cat, fund_cat_desc
       FROM LU_FUND_CAT
      WHERE fund_cat != 'S/E'
      ORDER BY sort_order;

END sp_getFundCat;
--======================================================================================================================
PROCEDURE sp_getFundingOffice( rc_getFundingOffice OUT refc_Base ) IS
BEGIN                         
OPEN rc_getFundingOffice FOR 
     SELECT c.FUND_CAT
           ,o.FUNDING_OFFICE_NUM, o.FUNDING_OFFICE_ABBR, o.FUNDING_OFFICE_DESC
       FROM LU_FUND_CAT c, LU_FUNDING_OFFICE o
      WHERE c.FUND_CAT != 'S/E'
        AND o.FUNDING_OFFICE_NUM <= 20
      ORDER BY c.SORT_ORDER, o.SORT_ORDER;
END sp_getFundingOffice;
--======================================================================================================================
PROCEDURE sp_getAllotmentAmount(rc_getAllotmentAmount OUT refc_Base)
IS
v_CurrentPY NUMBER DEFAULT UTILITY.fun_getcurrntprogram_year;
BEGIN

OPEN rc_getAllotmentAmount FOR
SELECT fund_cat, funding_office_num, program_year, allotment_amount, grouping_id
  FROM (
           SELECT fund_cat, 
                  funding_office_num,
                  program_year,
                  SUM(allotment_amount) AS allotment_amount,
                  GROUPING_ID(fund_cat, funding_office_num) AS grouping_id--,
                  --GROUPING_ID(fund_cat)           AS group_by_fund_cat,
                  --GROUPING_ID(funding_office_num) AS group_by_funding_office_num_
          FROM ALLOTMENT
          WHERE program_year BETWEEN (v_CurrentPY-3) AND (v_CurrentPY+2)
          GROUP BY CUBE(fund_cat, funding_office_num, program_year)
          ORDER BY --allotment_amount
           FUND_CAT desc, FUNDING_OFFICE_NUM, PROGRAM_YEAR 
      )
  WHERE grouping_id IN (0,1,3)
    AND program_year IS NOT NULL
  ;

/*
     SELECT fund_cat, 
            funding_office_num,
            program_year,
            allotment_amount
    FROM ALLOTMENT
    WHERE program_year BETWEEN (v_CurrentPY-3) AND (v_CurrentPY+2)
    ORDER BY FUND_CAT desc, FUNDING_OFFICE_NUM, PROGRAM_YEAR;
*/
END sp_getAllotmentAmount;
--======================================================================================================================
PROCEDURE sp_getAllotmentAsCSV(rc_getAllotmentAsCSV OUT refc_Base)
IS  
v_CurrentPY NUMBER DEFAULT UTILITY.fun_getcurrntprogram_year;

BEGIN
  OPEN rc_getAllotmentAsCSV FOR 
    SELECT csvField
      FROM (
            SELECT 1 AS order_by, '"PY"'||','||'"ALLOT_AMOUNT"' AS csvField
              FROM DUAL
            UNION
            SELECT 2 as order_by,  to_char(program_year)||','||to_char(allotment_amount) AS csvField
              FROM ( SELECT fund_cat, 
                            funding_office_num,
                            program_year,
                            SUM(allotment_amount) AS allotment_amount,
                            GROUPING_ID(fund_cat, funding_office_num) AS grouping_id--,
                            --GROUPING_ID(fund_cat)           AS group_by_fund_cat,
                            --GROUPING_ID(funding_office_num) AS group_by_funding_office_num_
                       FROM ALLOTMENT
                      WHERE program_year BETWEEN (v_CurrentPY-3) AND (v_CurrentPY+2)
                      GROUP BY CUBE(fund_cat, funding_office_num, program_year)
                      ORDER BY --allotment_amount
                       FUND_CAT desc, FUNDING_OFFICE_NUM, PROGRAM_YEAR 
                  )
              WHERE grouping_id IN (3)
                AND program_year IS NOT NULL
                AND fund_cat IS  NULL
                AND funding_office_num IS NULL
             );

/*
v_CurrentPY NUMBER DEFAULT UTILITY.fun_getcurrntprogram_year;
v_ClobCSV CLOB DEFAULT '';

CURSOR c_CSV IS
    SELECT csvField
      FROM (
            SELECT 1 AS order_by, '"PY"'||','||'"ALLOT_AMOUNT"' AS csvField
              FROM DUAL
            UNION
            SELECT 2 as order_by,  to_char(program_year)||','||to_char(allotment_amount) AS csvField
              FROM ( SELECT fund_cat, 
                            funding_office_num,
                            program_year,
                            SUM(allotment_amount) AS allotment_amount,
                            GROUPING_ID(fund_cat, funding_office_num) AS grouping_id--,
                            --GROUPING_ID(fund_cat)           AS group_by_fund_cat,
                            --GROUPING_ID(funding_office_num) AS group_by_funding_office_num_
                       FROM ALLOTMENT
                      WHERE program_year BETWEEN (v_CurrentPY-3) AND (v_CurrentPY+2)
                      GROUP BY CUBE(fund_cat, funding_office_num, program_year)
                      ORDER BY --allotment_amount
                       FUND_CAT desc, FUNDING_OFFICE_NUM, PROGRAM_YEAR 
                  )
              WHERE grouping_id IN (3)
                AND program_year IS NOT NULL
                AND fund_cat IS  NULL
                AND funding_office_num IS NULL
             );
BEGIN
  FOR r_Record IN c_CSV
    LOOP 
      v_ClobCSV := v_ClobCSV||chr(10)||r_Record.csvField;
    END LOOP;


  OPEN rc_getAllotmentAsCSV FOR 
    SELECT v_ClobCSV
      FROM dual;
*/
END sp_getAllotmentAsCSV;
--======================================================================================================================
PROCEDURE sp_createCSV AS

v_CurrentPY NUMBER DEFAULT UTILITY.fun_getcurrntprogram_year;

CURSOR c_CSV IS
    SELECT csvField
      FROM (
            SELECT 1 AS order_by, '"PY"'||','||'"ALLOT_AMOUNT"' AS csvField
              FROM DUAL
            UNION
            SELECT 2 as order_by,  to_char(program_year)||','||to_char(allotment_amount) AS csvField
              FROM ( SELECT fund_cat, 
                            funding_office_num,
                            program_year,
                            SUM(allotment_amount) AS allotment_amount,
                            GROUPING_ID(fund_cat, funding_office_num) AS grouping_id--,
                            --GROUPING_ID(fund_cat)           AS group_by_fund_cat,
                            --GROUPING_ID(funding_office_num) AS group_by_funding_office_num_
                       FROM ALLOTMENT
                      WHERE program_year BETWEEN (v_CurrentPY-3) AND (v_CurrentPY+2)
                      GROUP BY CUBE(fund_cat, funding_office_num, program_year)
                      ORDER BY --allotment_amount
                       FUND_CAT desc, FUNDING_OFFICE_NUM, PROGRAM_YEAR 
                  )
              WHERE grouping_id IN (/*0,1,*/3)
                AND program_year IS NOT NULL
                AND fund_cat IS  NULL
                AND funding_office_num IS NULL
             );

v_file  UTL_FILE.FILE_TYPE;
vt number;
BEGIN 
  select 1 into vt from dual;


END sp_createCSV;

--======================================================================================================================
PROCEDURE sp_getFundOfficeAllotment(rc_getFundOfficeAllotment OUT refc_Base)
IS 
BEGIN
/*
delete Z_TEST_VAL;
INSERT INTO Z_TEST_VAL (   COL_NUMBER ) VALUES (1000);
commit;
*/

OPEN rc_getFundOfficeAllotment FOR
      SELECT FUND_CAT,
             FUNDING_OFFICE_NUM,
             (select FUNDING_OFFICE_DESC 
                from LU_FUNDING_OFFICE lfo
               where a.FUNDING_OFFICE_NUM = lfo.FUNDING_OFFICE_NUM) AS FUNDING_OFFICE_DESC,
             PROGRAM_YEAR,
             ALLOTMENT_AMOUNT
        FROM ALLOTMENT a
       WHERE FUND_CAT IN ('OPS')--, 'CRA')
         AND PROGRAM_YEAR = 2011
       ORDER BY FUND_CAT, FUNDING_OFFICE_NUM, PROGRAM_YEAR
       ;
END sp_getFundOfficeAllotment;
--======================================================================================================================
PROCEDURE sp_getAAPP_Center_Contr(argVenue IN VARCHAR2 DEFAULT 'CALIFORNIA'
                                 ,rc_getAAPP_Center_Contr OUT refc_Base)
AS
v_Data CLOB;
BEGIN
OPEN rc_getAAPP_Center_Contr FOR

      WITH 
      --------------------------------------------------------------------------
          JFAS_AAPP AS (select aapp.aapp_num, aapp.venue, 
                               aapp.center_id, aapp.contractor_id
                       from aapp)
      --------------------------------------------------------------------------
         ,JFAS_CENTER AS (select cr.center_id, cr.center_name
                            from CENTER cr)
      --------------------------------------------------------------------------
         ,JFAS_CONTRACTOR AS (select ct.contractor_id, ct.contractor_name
                                from CONTRACTOR ct)
      --------------------------------------------------------------------------
      SELECT j_a.aapp_num, j_a.venue, j_cen.center_name, j_con.contractor_name
        FROM JFAS_AAPP j_a, 
             JFAS_CENTER j_cen, 
             JFAS_CONTRACTOR j_con
       WHERE j_a.center_id = j_cen.center_id
         AND j_a.contractor_id = j_con.contractor_id
         AND j_a.venue = argVenue
      ORDER BY j_a.aapp_num, j_cen.center_name, j_con.contractor_name;

END sp_getAAPP_Center_Contr;
--======================================================================================================================

PROCEDURE sp_GraphFOPallocation_CSV(argAAPPnum IN NUMBER default 4144
                               ,rc_GraphFOPallocation OUT refc_Base)
IS 
--------------------------------------------------------------------------------
v_DataCSV           CLOB DEFAULT '';
v_Amount            VARCHAR2(20);
v_Cost_Cat_Code     FOP_DATASET_VIEW.COSTCATCODE%TYPE; -- VARCHAR2(6)
v_Cost_Cat_Code_CSV VARCHAR2(100) DEFAULT '';
v_PY                FOP_DATASET_VIEW.PROGRAMYEAR%TYPE; -- NUMBER
v_PY_CSV            VARCHAR2(10) DEFAULT '';
v_Counter           NUMBER;
v_NewLine           VARCHAR2(10);
--------------------------------------------------------------------------------
CURSOR c_PY IS  -- Program Year.
     SELECT DISTINCT programyear
        FROM FOP_DATASET_VIEW 
       WHERE aappnum = argAAPPnum
       ORDER BY programyear;
--------------------------------------------------------------------------------
CURSOR c_CostCatCode IS -- Cost Category Code.
      SELECT DISTINCT costcatcode
        FROM FOP_DATASET_VIEW 
       WHERE aappnum = argAAPPnum
       ORDER BY costcatcode;
--------------------------------------------------------------------------------
BEGIN
-- TEST starts:
DELETE FROM Z_TEST_VAL;
-- TEST ends.
-- 1. --------------------------------------------------------------------------
FOR r_CostCatCode IN c_CostCatCode LOOP
        v_Cost_Cat_Code := r_CostCatCode.costcatcode;    
        v_Cost_Cat_Code_CSV := v_Cost_Cat_Code_CSV||','||'"'||v_Cost_Cat_Code||'"';
END LOOP;

-- 2.1 -------------------------------------------------------------------------
FOR r_PY IN c_PY LOOP
    
    v_PY     := r_PY.programyear;
    v_PY_CSV := r_PY.programyear;
    v_NewLine:= CHR(10);
-- 2.2 -------------------------------------------------------------------------
    FOR r_CostCatCode IN c_CostCatCode LOOP
         
         v_Cost_Cat_Code := r_CostCatCode.costcatcode;
        
        SELECT Count(*)
                INTO v_Counter
                FROM FOP_DATASET_VIEW
               WHERE aappnum     = argAAPPnum
                 AND programyear = v_PY
                 AND costcatcode = v_Cost_Cat_Code;

        CASE v_Counter
            WHEN 0 THEN v_Amount := v_NewLine||v_PY_CSV||','||'0';
            ELSE 
                  SELECT v_NewLine||v_PY_CSV||','||NVL(TO_CHAR(SUM(amount)),'0')
                    INTO v_Amount
                    FROM FOP_DATASET_VIEW 
                   WHERE aappnum     = argAAPPnum
                     AND programyear = v_PY
                     AND costcatcode = v_Cost_Cat_Code;
        END CASE;  
        
        v_DataCSV := v_DataCSV||v_Amount;
        v_PY_CSV := NULL;
        v_NewLine:= NULL;

    END LOOP; -- end of c_CostCatCode
END LOOP; -- end of c_PY
  
v_Cost_Cat_Code_CSV := '"PY"'||v_Cost_Cat_Code_CSV;

v_DataCSV := v_Cost_Cat_Code_CSV||v_DataCSV;

-- TEST starts:
INSERT INTO Z_TEST_VAL (COL_CLOB) VALUES (v_DataCSV);
COMMIT;
-- TEST ends.
OPEN rc_GraphFOPallocation FOR
  SELECT v_DataCSV AS datumCSV
    FROM dual;

END sp_GraphFOPallocation_CSV;
--==============================================================================
PROCEDURE sp_GraphFOPallocation_JSON(argAAPPnum IN NUMBER DEFAULT 4144
                               ,rc_GraphFOPallocation OUT refc_Base
                               --,rc_CostCategories     OUT refc_Base
                               )
IS

BEGIN
OPEN rc_GraphFOPallocation FOR
      WITH 
           pivot_data AS (SELECT programyear AS PY, costcatcode, amount
                            from FOP_DATASET_VIEW
                           where aappnum = argAAPPnum
                           order by programyear)
      SELECT * FROM pivot_data
      PIVOT
      (
          SUM(amount)
          FOR costcatcode
          IN ('A' AS A,'B1' AS B1,'B2' AS B2,'B3' AS B3,'B4' AS B4,'C1' AS C1,'C2' AS C2,'D' AS D,'S' AS S)
      );
/*
OPEN rc_CostCategories FOR
      SELECT DISTINCT costcatcode
        FROM FOP_DATASET_VIEW 
       WHERE aappnum = argAAPPnum
       ORDER BY costcatcode;
*/
END  sp_GraphFOPallocation_JSON;
--==============================================================================
--==============================================================================
PROCEDURE sp_test_JSON(argAAPPnum IN NUMBER DEFAULT 4144
                               ,rc_GraphFOPallocation OUT refc_Base
                               ,rc_CostCategories     OUT refc_Base
                               )
IS

BEGIN
OPEN rc_GraphFOPallocation FOR
      WITH 
           pivot_data AS (SELECT aappnum, programyear AS PY, costcatcode, amount
                            from FOP_DATASET_VIEW
                           where aappnum = argAAPPnum
                           order by programyear)
      SELECT * FROM pivot_data
      PIVOT
      (
          SUM(amount)
          FOR costcatcode
          IN ('A' AS A,'B1' AS B1,'B2' AS B2,'B3' AS B3,'B4' AS B4,'C1' AS C1,'C2' AS C2,'D' AS D,'S' AS S)
      );

OPEN rc_CostCategories FOR
      SELECT DISTINCT costcatcode, costcatdesc
        FROM FOP_DATASET_VIEW 
       WHERE aappnum = argAAPPnum
       ORDER BY costcatcode;

END  sp_test_JSON;
--==============================================================================
--======================================================================================================================

/*
PROCEDURE sp_getAllotmentGraph(rc_getFundCat  OUT refc_Base
                              ,rc_getFundingOffice OUT refc_Base
                              ,rc_getAllotmentAmount OUT refc_Base)
IS 
v_CurrentPY NUMBER DEFAULT UTILITY.fun_getcurrntprogram_year;
BEGIN
--------------------------------------------------------------------------------
OPEN rc_getFundingOffice FOR 
     SELECT c.FUND_CAT
           ,o.FUNDING_OFFICE_NUM, o.FUNDING_OFFICE_ABBR, o.FUNDING_OFFICE_DESC
       FROM LU_FUND_CAT c, LU_FUNDING_OFFICE o
      WHERE c.FUND_CAT != 'S/E'
        AND o.FUNDING_OFFICE_NUM <= 20
      ORDER BY c.SORT_ORDER, o.SORT_ORDER;
--------------------------------------------------------------------------------
OPEN rc_getFundingOffice FOR 
     SELECT c.FUND_CAT
           ,o.FUNDING_OFFICE_NUM, o.FUNDING_OFFICE_ABBR, o.FUNDING_OFFICE_DESC
       FROM LU_FUND_CAT c, LU_FUNDING_OFFICE o
      WHERE c.FUND_CAT != 'S/E'
        AND o.FUNDING_OFFICE_NUM <= 20
      ORDER BY c.SORT_ORDER, o.SORT_ORDER;
--------------------------------------------------------------------------------
OPEN rc_getAllotmentAmount FOR
     SELECT fund_cat, 
            funding_office_num,
            program_year,
            allotment_amount
    FROM ALLOTMENT
    where program_year between (v_CurrentPY-3) and (v_CurrentPY+2)
    ORDER BY FUNDING_OFFICE_NUM, PROGRAM_YEAR, FUND_CAT desc;
--------------------------------------------------------------------------------
END sp_getAllotmentGraph;
*/
--======================================================================================================================
PROCEDURE sp_CreateAllotment(argFirstYearInPeriod IN NUMBER, 
                             argLastYearInPeriod  IN NUMBER) AS
--!!!!!
-- COMMENTS:
-- Procedure is called from “sp_selectAllotment”.
-- Based on the period specified by arguments, procedure creates records (if they were not created previously) in table 
-- “ALLOTMENT”. Column “ALLOTMENT_AMOUNT” receives default value – “0” dollars.
-- Records must be created for the following categories: CRA - Construction, and OPS - Operations.
-- Funding offices are limited as well - see WHERE clause of the "CURSOR c_Funding_Office".
--!!!!!
-- VARIABLE declaration: -----------------------------------------------------------------------------------------------
v_FirstYearInPeriod  NUMBER DEFAULT argFirstYearInPeriod;
v_LastYearInPeriod   NUMBER DEFAULT argLastYearInPeriod;
v_Period             VARCHAR2(200);
 
v_Fund_Cat      LU_FUND_CAT.FUND_CAT%TYPE;      -- VARCHAR2(4)
v_Funding_Office_Num  LU_FUNDING_OFFICE.FUNDING_OFFICE_NUM%TYPE;  -- NUMBER
v_Program_Year  VARCHAR2(4);

v_Counter NUMBER DEFAULT 0;

-- CURSOR declaration: -------------------------------------------------------------------------------------------------
CURSOR c_Fund_Cat IS
  SELECT FUND_CAT, FUND_CAT_DESC
    FROM LU_FUND_CAT
   WHERE FUND_CAT != 'S/E'
   ORDER BY SORT_ORDER;
 
CURSOR c_Funding_Office IS
  SELECT FUNDING_OFFICE_NUM, FUNDING_OFFICE_ABBR, FUNDING_OFFICE_DESC
    FROM LU_FUNDING_OFFICE
   WHERE FUNDING_OFFICE_NUM <= 20
   ORDER BY SORT_ORDER;
 
CURSOR c_ProgramYears IS
  SELECT column_value
    FROM table( JFAS.f_ConvertStringToListOfVals(v_Period,','))
    ORDER BY column_value;
 
------------------------------------------------------------------------------------------------------------------------
BEGIN
   -- 1: Build comma delimited string of selected years.
   FOR i IN v_FirstYearInPeriod..v_LastYearInPeriod LOOP
      IF i = v_FirstYearInPeriod THEN
          v_Period := TO_CHAR(i);
      ELSE
          v_Period := v_Period||','||TO_CHAR(i);
      END IF;
   END LOOP;
   -- Ex: v_Period = '2008,2009,2010,2011'.
 
   -- 2: Create records in the table “ALLOTMENT” if records with the specified years do not exist.
      FOR r_Fund_Cat IN c_Fund_Cat LOOP
          v_Fund_Cat := r_Fund_Cat.FUND_CAT;
         
          FOR r_Funding_Office IN c_Funding_Office LOOP
              v_Funding_Office_Num := r_Funding_Office.FUNDING_OFFICE_NUM;
             
             FOR r_ProgramYears IN c_ProgramYears LOOP
                 v_Program_Year := r_ProgramYears.column_value;
                 
                SELECT Count(*) 
                  INTO v_Counter
                  FROM ALLOTMENT a
                 WHERE a.fund_cat = v_Fund_Cat
                   AND a.funding_office_num = v_Funding_Office_Num
                   AND a.program_year = v_Program_Year;

                  IF v_Counter = 0 THEN 
                    INSERT INTO ALLOTMENT
                    ( FUND_CAT, FUNDING_OFFICE_NUM, PROGRAM_YEAR, ALLOTMENT_AMOUNT, NCFMS_UPDATED,
                      UPDATE_USER_ID, UPDATE_FUNCTION, UPDATE_TIME )
                    VALUES (v_Fund_Cat, v_Funding_Office_Num, v_Program_Year, 0, 'N', 'mstein', 'I', sysdate);
                  END IF;
             END LOOP; -- end of c_ProgramYears
          END LOOP;    -- end of c_Funding_Office
      END LOOP;        -- end of c_Fund_Cat
    
      COMMIT;
   
END sp_CreateAllotment;
--======================================================================================================================
 
PROCEDURE sp_getGraphTest( rc_Timeline    OUT refc_Base,
                              rc_graphOPS    OUT refc_Base,
                              rc_graphCRA    OUT refc_Base,
                              rc_graphTotals OUT refc_Base)
--Comments: IF argFirstYearInPeriod = '2010'
--          AND argLastYearInPeriod = '2015' THEN Period would be: '2010,2011,2012,2013,2014,2015'.
--          At the same time PY (argLastYearInPeriod) could not be greater than "Current Program Year" + 1.
--
-- Example: Program Year 13 (PY13)  07/01/2013 - 06/30/2014.
IS
-- VARIABLE declaration: -----------------------------------------------------------------------------------------------
v_CurrentPY           NUMBER DEFAULT UTILITY.fun_getcurrntprogram_year;
v_FirstYearInPeriod   NUMBER; -- DEFAULT argFirstYearInPeriod;
v_LastYearInPeriod    NUMBER; -- DEFAULT argLastYearInPeriod;

v_Allotment_Amount    ALLOTMENT.ALLOTMENT_AMOUNT%TYPE; --NUMBER;
v_NSFMS_Updated       ALLOTMENT.NCFMS_UPDATED%TYPE;    --VARCHAR(1)

v_FundingOfficeFullName VARCHAR2(100);
--v_FundOfficeNumItaration   VARCHAR2(50);
v_SQL                 CLOB; --VARCHAR2(4000);
v_SQL_DATA            CLOB; --VARCHAR2(4000);
v_SQL_TOTAL           CLOB; --VARCHAR2(4000);
 
v_OrderBy NUMBER DEFAULT 1;
v_OrderByCRA NUMBER;

v_RowNum NUMBER DEFAULT 0;

v_RendomNum NUMBER DEFAULT TRUNC(DBMS_RANDOM.VALUE(1,1000));

v_Fund_Cat_In_Loop LU_FUND_CAT.FUND_CAT%TYPE; -- VARCHAR2(4)
------------------------------------------------------------------------------------------------------------------------
TYPE cRef_Allotment IS REF CURSOR;
TYPE rRef_Allotment IS RECORD(COL_ROWNUM NUMBER, 
                              COL_LEVEL NUMBER, 
                              FUND_CAT VARCHAR2(50 BYTE), 
                              FUND_OFFICE_NUM VARCHAR2(50 BYTE), 
                              FULL_NAME VARCHAR2(50 BYTE), 
                              YEAR_MINUS_7 VARCHAR2(20 BYTE), 
                              NCFMS_UPD_MINUS_7 VARCHAR2(1 BYTE), 
                              YEAR_MINUS_6 VARCHAR2(20 BYTE), 
                              NCFMS_UPD_MINUS_6 VARCHAR2(20 BYTE), 
                              YEAR_MINUS_5 VARCHAR2(20 BYTE), 
                              NCFMS_UPD_MINUS_5 VARCHAR2(1 BYTE), 
                              YEAR_MINUS_4 VARCHAR2(20 BYTE), 
                              NCFMS_UPD_MINUS_4 VARCHAR2(20 BYTE), 
                              YEAR_MINUS_3 VARCHAR2(20 BYTE), 
                              NCFMS_UPD_MINUS_3 VARCHAR2(1 BYTE), 
                              YEAR_MINUS_2 VARCHAR2(20 BYTE), 
                              NCFMS_UPD_MINUS_2 VARCHAR2(20 BYTE), 
                              YEAR_MINUS_1 VARCHAR2(20 BYTE), 
                              NCFMS_UPD_MINUS_1 VARCHAR2(1 BYTE), 
                              YEAR_MINUS_0 VARCHAR2(20 BYTE), 
                              NCFMS_UPD_MINUS_0 VARCHAR2(20 BYTE), 
                              YEAR_PLUS_1 VARCHAR2(20 BYTE), 
                              NCFMS_UPD_PLUS_1 VARCHAR2(1 BYTE), 
                              YEAR_PLUS_2 VARCHAR2(20 BYTE), 
                              NCFMS_UPD_PLUS_2 VARCHAR2(20 BYTE), 
                              ORDER_BY NUMBER);
c_Allotment cRef_Allotment;
r_Allotment rRef_Allotment;
-- CURSOR declaration: -------------------------------------------------------------------------------------------------
CURSOR c_Fund_Cat IS
  SELECT FUND_CAT, FUND_CAT_DESC
    FROM LU_FUND_CAT
   WHERE FUND_CAT != 'S/E'
   ORDER BY SORT_ORDER;

CURSOR c_FundCatAndOffice IS
SELECT c.FUND_CAT
      ,o.FUNDING_OFFICE_NUM, o.FUNDING_OFFICE_ABBR, o.FUNDING_OFFICE_DESC
  FROM LU_FUND_CAT c
      ,LU_FUNDING_OFFICE o
WHERE c.FUND_CAT != 'S/E'
   AND o.FUNDING_OFFICE_NUM <= 20
ORDER BY c.SORT_ORDER, o.SORT_ORDER;

CURSOR c_FundCatAndOffice2 IS
SELECT c.FUND_CAT
      ,o.FUNDING_OFFICE_NUM, o.FUNDING_OFFICE_ABBR, o.FUNDING_OFFICE_DESC
  FROM LU_FUND_CAT c
      ,LU_FUNDING_OFFICE o
WHERE c.FUND_CAT != 'S/E'
   AND o.FUNDING_OFFICE_NUM <= 20
   AND c.fund_cat = v_Fund_Cat_In_Loop
ORDER BY c.SORT_ORDER, o.SORT_ORDER;
------------------------------------------------------------------------------------------------------------------------
BEGIN

v_FirstYearInPeriod := v_CurrentPY-7;
v_LastYearInPeriod  := v_CurrentPY+2;

  -- 1: Checking if records have to be created.
  sp_CreateAllotment(v_FirstYearInPeriod, v_LastYearInPeriod);
--/*
-- BEGIN: The following is a code until Oracle will be updated to 11g.
-- 1:
v_RowNum := v_RowNum+1;
-- 2:
INSERT INTO ALLOTMENT_OUTPUT (RANDOM_NUMBER,  COL_ROWNUM, COL_LEVEL,  FUND_CAT, FUND_OFFICE_NUM,  FULL_NAME,
                              YEAR_MINUS_7, NCFMS_UPD_MINUS_7,
                              YEAR_MINUS_6, NCFMS_UPD_MINUS_6,
                              YEAR_MINUS_5, NCFMS_UPD_MINUS_5,
                              YEAR_MINUS_4, NCFMS_UPD_MINUS_4,
                              YEAR_MINUS_3, NCFMS_UPD_MINUS_3,
                              YEAR_MINUS_2, NCFMS_UPD_MINUS_2,
                              YEAR_MINUS_1, NCFMS_UPD_MINUS_1,
                              YEAR_MINUS_0, NCFMS_UPD_MINUS_0,
                              YEAR_PLUS_1,  NCFMS_UPD_PLUS_1,
                              YEAR_PLUS_2,  NCFMS_UPD_PLUS_2,
                              ORDER_BY)
                       VALUES(v_RendomNum, v_RowNum, 1, 'TBL_HEADER', NULL, 'FULL_NAME', 
                              v_CurrentPY-7, NULL,-- YEAR_MINUS_7, NCFMS_UPD_MINUS_7,
                              v_CurrentPY-6, NULL,-- YEAR_MINUS_6, NCFMS_UPD_MINUS_6,
                              v_CurrentPY-5, NULL,-- YEAR_MINUS_5, NCFMS_UPD_MINUS_5,
                              v_CurrentPY-4, NULL,-- YEAR_MINUS_4, NCFMS_UPD_MINUS_4,
                              v_CurrentPY-3, NULL,-- YEAR_MINUS_3, NCFMS_UPD_MINUS_3,
                              v_CurrentPY-2, NULL,-- YEAR_MINUS_2, NCFMS_UPD_MINUS_2,
                              v_CurrentPY-1, NULL,-- YEAR_MINUS_1, NCFMS_UPD_MINUS_1,
                              v_CurrentPY,   NULL, -- YEAR_MINUS_0, NCFMS_UPD_MINUS_0,
                              v_CurrentPY+1, NULL,-- YEAR_PLUS_1,  NCFMS_UPD_PLUS_1,
                              v_CurrentPY+2, NULL,-- YEAR_PLUS_2,  NCFMS_UPD_PLUS_2,
                              NULL -- ORDER_BY
                             );
COMMIT;
-- 3:
v_RowNum := v_RowNum+1;

-- 4:
SELECT FUND_CAT--, FUND_CAT_DESC
  INTO v_Fund_Cat_In_Loop -- This variable value is 'OPS'
  FROM LU_FUND_CAT
 WHERE SORT_ORDER = 1; 

-- 5:
FOR r_Fund_Cat IN c_Fund_Cat LOOP
  -- 5.1
  IF r_Fund_Cat.FUND_CAT = v_Fund_Cat_In_Loop THEN
        -- 5.1.1
        -- This "INSERT" for creating a name ("OPERATIONS") for Funding Category on the screen:
        INSERT INTO ALLOTMENT_OUTPUT (RANDOM_NUMBER,  COL_ROWNUM, COL_LEVEL,  FUND_CAT, FUND_OFFICE_NUM,  FULL_NAME)
             VALUES(v_RendomNum, v_RowNum, 2, r_Fund_Cat.FUND_CAT, r_Fund_Cat.FUND_CAT, r_Fund_Cat.FUND_CAT_DESC);
        --COMMIT;
        
        -- 5.1.2
        v_RowNum := v_RowNum+1; 
        
        -- 5.1.3
        FOR r_FundCatAndOffice IN c_FundCatAndOffice2 LOOP
                  
                  INSERT INTO ALLOTMENT_OUTPUT (RANDOM_NUMBER,  COL_ROWNUM, COL_LEVEL,  FUND_CAT, FUND_OFFICE_NUM,  FULL_NAME,
                                                YEAR_MINUS_7, NCFMS_UPD_MINUS_7,
                                                YEAR_MINUS_6, NCFMS_UPD_MINUS_6,
                                                YEAR_MINUS_5, NCFMS_UPD_MINUS_5,
                                                YEAR_MINUS_4, NCFMS_UPD_MINUS_4,
                                                YEAR_MINUS_3, NCFMS_UPD_MINUS_3,
                                                YEAR_MINUS_2, NCFMS_UPD_MINUS_2,
                                                YEAR_MINUS_1, NCFMS_UPD_MINUS_1,
                                                YEAR_MINUS_0, NCFMS_UPD_MINUS_0,
                                                YEAR_PLUS_1,  NCFMS_UPD_PLUS_1,
                                                YEAR_PLUS_2,  NCFMS_UPD_PLUS_2,
                                                ORDER_BY)
                                         VALUES(v_RendomNum, v_RowNum, 3, r_Fund_Cat.FUND_CAT, r_FundCatAndOffice.FUNDING_OFFICE_NUM, r_FundCatAndOffice.FUNDING_OFFICE_DESC, 
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-7),                           -- YEAR_MINUS_7, 
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-7),                           -- NCFMS_UPD_MINUS_7,
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-6),                           -- YEAR_MINUS_6, 
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-6),                           -- NCFMS_UPD_MINUS_6,
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-5),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-5),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-4),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-4),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-3),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-3),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-2),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-2),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-1),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-1),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY+1),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY+1),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY+2),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY+2),
                                                ------------------------------------------------------------------------
                                                NULL -- ORDER_BY
                                               );
                  v_RowNum := v_RowNum+1; 
                    
        
        
        END LOOP; -- end of "FOR r_FundCatAndOffice IN c_FundCatAndOffice LOOP"
        ---COMMIT;
        
        -- Subtotal calculation:
        INSERT INTO ALLOTMENT_OUTPUT (RANDOM_NUMBER,  COL_ROWNUM, COL_LEVEL,  FUND_CAT, FUND_OFFICE_NUM,  FULL_NAME,
                              YEAR_MINUS_7, NCFMS_UPD_MINUS_7,
                              YEAR_MINUS_6, NCFMS_UPD_MINUS_6,
                              YEAR_MINUS_5, NCFMS_UPD_MINUS_5,
                              YEAR_MINUS_4, NCFMS_UPD_MINUS_4,
                              YEAR_MINUS_3, NCFMS_UPD_MINUS_3,
                              YEAR_MINUS_2, NCFMS_UPD_MINUS_2,
                              YEAR_MINUS_1, NCFMS_UPD_MINUS_1,
                              YEAR_MINUS_0, NCFMS_UPD_MINUS_0,
                              YEAR_PLUS_1,  NCFMS_UPD_PLUS_1,
                              YEAR_PLUS_2,  NCFMS_UPD_PLUS_2,
                              ORDER_BY)
                       VALUES(v_RendomNum, v_RowNum, 4, r_Fund_Cat.FUND_CAT, r_Fund_Cat.FUND_CAT, 'Subtotal '||Initcap(r_Fund_Cat.FUND_CAT_DESC), 
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-7), NULL,                                              -- YEAR_MINUS_7, NCFMS_UPD_MINUS_7,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-6), NULL,                                              -- YEAR_MINUS_6, NCFMS_UPD_MINUS_6,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-5), NULL,                                              -- YEAR_MINUS_5, NCFMS_UPD_MINUS_5,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-4), NULL,                                              -- YEAR_MINUS_4, NCFMS_UPD_MINUS_4,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-3), NULL,                                              -- YEAR_MINUS_3, NCFMS_UPD_MINUS_3,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-2), NULL,                                              -- YEAR_MINUS_2, NCFMS_UPD_MINUS_2,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-1), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY+1), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY+2), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              NULL -- ORDER_BY
                             );
        v_RowNum := v_RowNum+1;
        
  -- 5.2
  ELSE 
        v_Fund_Cat_In_Loop := r_Fund_Cat.FUND_CAT;
        
        -- 5.2.1
        -- This "INSERT" for creating a name ("OPERATIONS") for Funding Category on the screen:
        INSERT INTO ALLOTMENT_OUTPUT (RANDOM_NUMBER,  COL_ROWNUM, COL_LEVEL,  FUND_CAT, FUND_OFFICE_NUM,  FULL_NAME)
             VALUES(v_RendomNum, v_RowNum, 2, r_Fund_Cat.FUND_CAT, r_Fund_Cat.FUND_CAT, r_Fund_Cat.FUND_CAT_DESC);
        --COMMIT;
        
        -- 5.2.2
        v_RowNum := v_RowNum+1; 
        
        -- 5.2.3
        FOR r_FundCatAndOffice IN c_FundCatAndOffice2 LOOP
                  
                  INSERT INTO ALLOTMENT_OUTPUT (RANDOM_NUMBER,  COL_ROWNUM, COL_LEVEL,  FUND_CAT, FUND_OFFICE_NUM,  FULL_NAME,
                                                YEAR_MINUS_7, NCFMS_UPD_MINUS_7,
                                                YEAR_MINUS_6, NCFMS_UPD_MINUS_6,
                                                YEAR_MINUS_5, NCFMS_UPD_MINUS_5,
                                                YEAR_MINUS_4, NCFMS_UPD_MINUS_4,
                                                YEAR_MINUS_3, NCFMS_UPD_MINUS_3,
                                                YEAR_MINUS_2, NCFMS_UPD_MINUS_2,
                                                YEAR_MINUS_1, NCFMS_UPD_MINUS_1,
                                                YEAR_MINUS_0, NCFMS_UPD_MINUS_0,
                                                YEAR_PLUS_1,  NCFMS_UPD_PLUS_1,
                                                YEAR_PLUS_2,  NCFMS_UPD_PLUS_2,
                                                ORDER_BY)
                                         VALUES(v_RendomNum, v_RowNum, 3, r_Fund_Cat.FUND_CAT, r_FundCatAndOffice.FUNDING_OFFICE_NUM, r_FundCatAndOffice.FUNDING_OFFICE_DESC, 
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-7),                           -- YEAR_MINUS_7, 
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-7),                           -- NCFMS_UPD_MINUS_7,
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-6),                           -- YEAR_MINUS_6, 
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-6),                           -- NCFMS_UPD_MINUS_6,
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-5),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-5),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-4),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-4),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-3),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-3),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-2),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-2),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-1),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY-1),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY+1),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY+1),
                                                ------------------------------------------------------------------------
                                                (select allotment_amount
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY+2),
                                                (select ncfms_updated
                                                   from ALLOTMENT
                                                  where fund_cat = v_Fund_Cat_In_Loop
                                                    and funding_office_num = r_FundCatAndOffice.funding_office_num
                                                    and program_year = v_CurrentPY+2),
                                                ------------------------------------------------------------------------
                                                NULL -- ORDER_BY
                                               );
                  v_RowNum := v_RowNum+1; 
                    
        
        
        END LOOP; -- end of "FOR r_FundCatAndOffice IN c_FundCatAndOffice LOOP"
        ---COMMIT;
        
        -- Subtotal calculation:
        INSERT INTO ALLOTMENT_OUTPUT (RANDOM_NUMBER,  COL_ROWNUM, COL_LEVEL,  FUND_CAT, FUND_OFFICE_NUM,  FULL_NAME,
                              YEAR_MINUS_7, NCFMS_UPD_MINUS_7,
                              YEAR_MINUS_6, NCFMS_UPD_MINUS_6,
                              YEAR_MINUS_5, NCFMS_UPD_MINUS_5,
                              YEAR_MINUS_4, NCFMS_UPD_MINUS_4,
                              YEAR_MINUS_3, NCFMS_UPD_MINUS_3,
                              YEAR_MINUS_2, NCFMS_UPD_MINUS_2,
                              YEAR_MINUS_1, NCFMS_UPD_MINUS_1,
                              YEAR_MINUS_0, NCFMS_UPD_MINUS_0,
                              YEAR_PLUS_1,  NCFMS_UPD_PLUS_1,
                              YEAR_PLUS_2,  NCFMS_UPD_PLUS_2,
                              ORDER_BY)
                       VALUES(v_RendomNum, v_RowNum, 4, r_Fund_Cat.FUND_CAT, r_Fund_Cat.FUND_CAT, 'Subtotal '||Initcap(r_Fund_Cat.FUND_CAT_DESC), 
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-7), NULL,                                              -- YEAR_MINUS_7, NCFMS_UPD_MINUS_7,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-6), NULL,                                              -- YEAR_MINUS_6, NCFMS_UPD_MINUS_6,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-5), NULL,                                              -- YEAR_MINUS_5, NCFMS_UPD_MINUS_5,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-4), NULL,                                              -- YEAR_MINUS_4, NCFMS_UPD_MINUS_4,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-3), NULL,                                              -- YEAR_MINUS_3, NCFMS_UPD_MINUS_3,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-2), NULL,                                              -- YEAR_MINUS_2, NCFMS_UPD_MINUS_2,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY-1), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY+1), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where fund_cat = r_Fund_Cat.FUND_CAT
                                  and PROGRAM_YEAR = v_CurrentPY+2), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              NULL -- ORDER_BY
                             );
        v_RowNum := v_RowNum+1;
  END IF; -- END OF 5.1 AND 5.2
  
END LOOP; -- end of "FOR r_Fund_Cat IN c_Fund_Cat LOOP"

v_RowNum := v_RowNum+1;

INSERT INTO ALLOTMENT_OUTPUT (RANDOM_NUMBER,  COL_ROWNUM, COL_LEVEL,  FUND_CAT, FUND_OFFICE_NUM,  FULL_NAME,
                              YEAR_MINUS_7, NCFMS_UPD_MINUS_7,
                              YEAR_MINUS_6, NCFMS_UPD_MINUS_6,
                              YEAR_MINUS_5, NCFMS_UPD_MINUS_5,
                              YEAR_MINUS_4, NCFMS_UPD_MINUS_4,
                              YEAR_MINUS_3, NCFMS_UPD_MINUS_3,
                              YEAR_MINUS_2, NCFMS_UPD_MINUS_2,
                              YEAR_MINUS_1, NCFMS_UPD_MINUS_1,
                              YEAR_MINUS_0, NCFMS_UPD_MINUS_0,
                              YEAR_PLUS_1,  NCFMS_UPD_PLUS_1,
                              YEAR_PLUS_2,  NCFMS_UPD_PLUS_2,
                              ORDER_BY)
                       VALUES(v_RendomNum, v_RowNum, 4, 'ATOTAL', 'TOTAL', 'TOTAL:', 
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where PROGRAM_YEAR = v_CurrentPY-7), NULL,                                              -- YEAR_MINUS_7, NCFMS_UPD_MINUS_7,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where PROGRAM_YEAR = v_CurrentPY-6), NULL,                                              -- YEAR_MINUS_6, NCFMS_UPD_MINUS_6,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where PROGRAM_YEAR = v_CurrentPY-5), NULL,                                              -- YEAR_MINUS_5, NCFMS_UPD_MINUS_5,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where PROGRAM_YEAR = v_CurrentPY-4), NULL,                                              -- YEAR_MINUS_4, NCFMS_UPD_MINUS_4,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where PROGRAM_YEAR = v_CurrentPY-3), NULL,                                              -- YEAR_MINUS_3, NCFMS_UPD_MINUS_3,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where PROGRAM_YEAR = v_CurrentPY-2), NULL,                                              -- YEAR_MINUS_2, NCFMS_UPD_MINUS_2,
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where PROGRAM_YEAR = v_CurrentPY-1), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where PROGRAM_YEAR = v_CurrentPY), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where PROGRAM_YEAR = v_CurrentPY+1), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              (select Sum(allotment_amount)
                                 from ALLOTMENT
                                where PROGRAM_YEAR = v_CurrentPY+2), NULL,                                              
                              ------------------------------------------------------------------------------------------
                              NULL -- ORDER_BY
                             );
COMMIT;


OPEN rc_Timeline FOR SELECT --FUND_CAT
                              --,NVL(FUND_OFFICE_NUM,' ') AS FUND_OFFICE_NUM
                              --,FULL_NAME
                              NVL(YEAR_MINUS_3,' ')      AS YEAR_MINUS_3
                              ,NVL(YEAR_MINUS_2,' ')      AS YEAR_MINUS_2
                              ,NVL(YEAR_MINUS_1,' ')      AS YEAR_MINUS_1
                              ,NVL(YEAR_MINUS_0,' ')      AS YEAR_MINUS_0
                              ,NVL(YEAR_PLUS_1,' ')       AS YEAR_PLUS_1
                              ,NVL(YEAR_PLUS_2,' ')       AS YEAR_PLUS_2
                         FROM ALLOTMENT_OUTPUT
                        WHERE RANDOM_NUMBER = v_RendomNum
                          AND COL_LEVEL = 1;

OPEN rc_graphOPS FOR SELECT  FUND_CAT
                            ,NVL(FUND_OFFICE_NUM,' ') AS FUND_OFFICE_NUM
                            ,FULL_NAME
                            ,NVL(YEAR_MINUS_3,' ')      AS YEAR_MINUS_3
                            ,NVL(YEAR_MINUS_2,' ')      AS YEAR_MINUS_2
                            ,NVL(YEAR_MINUS_1,' ')      AS YEAR_MINUS_1
                            ,NVL(YEAR_MINUS_0,' ')      AS YEAR_MINUS_0
                            ,NVL(YEAR_PLUS_1,' ')       AS YEAR_PLUS_1
                            ,NVL(YEAR_PLUS_2,' ')       AS YEAR_PLUS_2
                       FROM ALLOTMENT_OUTPUT
                      WHERE RANDOM_NUMBER = v_RendomNum
                        AND COL_LEVEL = 3
                        AND FUND_CAT = 'OPS'
                       ORDER BY FUND_CAT DESC, COL_ROWNUM, COL_LEVEL;

OPEN rc_graphCRA FOR SELECT  FUND_CAT
                            ,NVL(FUND_OFFICE_NUM,' ') AS FUND_OFFICE_NUM
                            ,FULL_NAME
                            ,NVL(YEAR_MINUS_3,' ')      AS YEAR_MINUS_3
                            ,NVL(YEAR_MINUS_2,' ')      AS YEAR_MINUS_2
                            ,NVL(YEAR_MINUS_1,' ')      AS YEAR_MINUS_1
                            ,NVL(YEAR_MINUS_0,' ')      AS YEAR_MINUS_0
                            ,NVL(YEAR_PLUS_1,' ')       AS YEAR_PLUS_1
                            ,NVL(YEAR_PLUS_2,' ')       AS YEAR_PLUS_2
                       FROM ALLOTMENT_OUTPUT
                      WHERE RANDOM_NUMBER = v_RendomNum
                        AND COL_LEVEL = 3
                        AND FUND_CAT = 'CRA'
                       ORDER BY FUND_CAT DESC, COL_ROWNUM, COL_LEVEL;

OPEN rc_graphTotals FOR SELECT FUND_CAT
                              ,FULL_NAME
                              ,NVL(YEAR_MINUS_3,' ')      AS YEAR_MINUS_3
                              ,NVL(YEAR_MINUS_2,' ')      AS YEAR_MINUS_2
                              ,NVL(YEAR_MINUS_1,' ')      AS YEAR_MINUS_1
                              ,NVL(YEAR_MINUS_0,' ')      AS YEAR_MINUS_0
                              ,NVL(YEAR_PLUS_1,' ')       AS YEAR_PLUS_1
                              ,NVL(YEAR_PLUS_2,' ')       AS YEAR_PLUS_2
                         FROM ALLOTMENT_OUTPUT a1
                        WHERE RANDOM_NUMBER = v_RendomNum
                          AND COL_LEVEL = 4
                        ORDER BY FUND_CAT DESC, COL_ROWNUM, COL_LEVEL;

--DELETE FROM ALLOTMENT_OUTPUT WHERE RANDOM_NUMBER = v_RendomNum;
COMMIT;
------------------------------------------------------------------------------------------------------------------------
END sp_getGraphTest;
--======================================================================================================================


END ALLOTMENT_GRAPH_PKG;

--================================================================================

--------------------------------------------------------
--  File created - Tuesday-July-15-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table ALLOTMENT
--------------------------------------------------------

  CREATE TABLE "JFAS"."ALLOTMENT" 
   (	"FUND_CAT" VARCHAR2(4 BYTE), 
	"FUNDING_OFFICE_NUM" NUMBER, 
	"PROGRAM_YEAR" VARCHAR2(4 BYTE), 
	"ALLOTMENT_AMOUNT" NUMBER DEFAULT 0, 
	"NCFMS_UPDATED" VARCHAR2(1 BYTE) DEFAULT 'N', 
	"UPDATE_USER_ID" VARCHAR2(20 BYTE), 
	"UPDATE_FUNCTION" CHAR(1 BYTE), 
	"UPDATE_TIME" DATE DEFAULT SYSDATE
   ) ;

   COMMENT ON COLUMN "JFAS"."ALLOTMENT"."FUND_CAT" IS 'Funding category.  Source: LU_FUND_CAT.  Use only ‘CRA’ – Construction and ‘OPS’ – Operations.';
   COMMENT ON COLUMN "JFAS"."ALLOTMENT"."FUNDING_OFFICE_NUM" IS 'Funding Office aka Regions. Source: LU_FUNDING_OFFICE. Use only Funding Office Numbers – 1,2,3,4,5,6, and 20.';
   COMMENT ON COLUMN "JFAS"."ALLOTMENT"."PROGRAM_YEAR" IS 'Program Year:  from 07/01/XXXX to 06/30/XXXX +1. Ex: PY13 – 07/01/2013 – 06/30/2014.';
   COMMENT ON COLUMN "JFAS"."ALLOTMENT"."ALLOTMENT_AMOUNT" IS 'Number that represents allotment amount. ';
   COMMENT ON COLUMN "JFAS"."ALLOTMENT"."NCFMS_UPDATED" IS 'Possible values: “Y” – Yes, record was updated based on the amount received from NCFMS; “N” – No, record was not updated, it is a default value.';
   COMMENT ON COLUMN "JFAS"."ALLOTMENT"."UPDATE_FUNCTION" IS '"I" for insert, "U" for update';
   COMMENT ON TABLE "JFAS"."ALLOTMENT"  IS 'Stores allotment amount per funding categories per region.';
REM INSERTING into JFAS.ALLOTMENT
SET DEFINE OFF;
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',1,'2006',94051694,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',1,'2007',85947620,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',1,'2008',82729193,'N','mstein','U',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',1,'2009',87657680,'N','mstein','U',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',1,'2010',96789012,'N','mstein','U',to_date('08-JUL-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',1,'2011',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',1,'2012',96537159,'Y','mstein','U',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',1,'2013',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',1,'2014',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',1,'2015',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',2,'2006',97407599,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',2,'2007',81300130,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',2,'2008',94152205,'N','mstein','U',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',2,'2009',81912100,'N','mstein','U',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',2,'2010',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',2,'2011',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',2,'2012',97583042,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',2,'2013',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',2,'2014',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',2,'2015',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',3,'2006',86485004,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',3,'2007',86177687,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',3,'2008',94404209,'N','mstein','U',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',3,'2009',91460802,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',3,'2010',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',3,'2011',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',3,'2012',83390828,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',3,'2013',456465,'N','mstein','U',to_date('13-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',3,'2014',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',3,'2015',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',4,'2006',92535985,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',4,'2007',84327878,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',4,'2008',90103545,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',4,'2009',94511810,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',4,'2010',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',4,'2011',1234567,'N','mstein','U',to_date('12-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',4,'2012',81039168,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',4,'2013',84925234,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',4,'2014',89795556,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',4,'2015',20000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',5,'2006',83078563,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',5,'2007',80757453,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',5,'2008',84973901,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',5,'2009',92553705,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',5,'2010',85462347,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',5,'2011',98563053,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',5,'2012',92165287,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',5,'2013',97214306,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',5,'2014',83577718,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',5,'2015',20000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',6,'2006',91173046,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',6,'2007',94530466,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',6,'2008',88915533,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',6,'2009',89940708,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',6,'2010',92909757,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',6,'2011',80914222,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',6,'2012',80593598,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',6,'2013',96911607,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',6,'2014',88176390,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',6,'2015',20000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',20,'2006',89833633,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',20,'2007',97442522,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',20,'2008',95156801,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',20,'2009',91664255,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',20,'2010',81193666,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',20,'2011',85992804,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',20,'2012',88266803,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',20,'2013',92048970,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',20,'2014',82330934,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('OPS',20,'2015',20000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',1,'2006',94410205,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',1,'2007',98446766,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',1,'2008',86225364,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',1,'2009',84947761,'N','mstein','U',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',1,'2010',84990663,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',1,'2011',84950137,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',1,'2012',85839818,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',1,'2013',91136747,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',1,'2014',82569941,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',1,'2015',10000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',2,'2006',92708194,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',2,'2007',98650291,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',2,'2008',84391994,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',2,'2009',97981927,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',2,'2010',83633847,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',2,'2011',0,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',2,'2012',81568326,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',2,'2013',93331536,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',2,'2014',83118938,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',2,'2015',20000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',3,'2006',89849284,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',3,'2007',93129583,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',3,'2008',82239485,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',3,'2009',98279935,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',3,'2010',85345444,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',3,'2011',95793903,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',3,'2012',90777762,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',3,'2013',92703423,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',3,'2014',86118900,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',3,'2015',20000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',4,'2006',95788360,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',4,'2007',91345366,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',4,'2008',92806422,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',4,'2009',87304835,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',4,'2010',87963910,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',4,'2011',84909114,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',4,'2012',85788417,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',4,'2013',97113048,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',4,'2014',83204970,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',4,'2015',20000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',5,'2006',88527855,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',5,'2007',97012864,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',5,'2008',86667213,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',5,'2009',91485474,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',5,'2010',83648902,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',5,'2011',92560047,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',5,'2012',85306216,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',5,'2013',98575525,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',5,'2014',81545455,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',5,'2015',20000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',6,'2006',85422689,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',6,'2007',91401959,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',6,'2008',91774058,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',6,'2009',98275739,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',6,'2010',82513539,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',6,'2011',94323249,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',6,'2012',88232289,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',6,'2013',87546738,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',6,'2014',97394413,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',6,'2015',20000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',20,'2006',98124836,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',20,'2007',86187967,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',20,'2008',92150189,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',20,'2009',92344264,'N','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',20,'2010',81736121,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',20,'2011',96336029,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',20,'2012',97756560,'Y','mstein','I',to_date('03-APR-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',20,'2013',93144653,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',20,'2014',80100657,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
Insert into JFAS.ALLOTMENT (FUND_CAT,FUNDING_OFFICE_NUM,PROGRAM_YEAR,ALLOTMENT_AMOUNT,NCFMS_UPDATED,UPDATE_USER_ID,UPDATE_FUNCTION,UPDATE_TIME) values ('CRA',20,'2015',20000000,'N','mstein','U',to_date('02-MAY-14','DD-MON-RR'));
--------------------------------------------------------
--  DDL for Index ALLOTMENTS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "JFAS"."ALLOTMENTS_PK" ON "JFAS"."ALLOTMENT" ("FUND_CAT", "FUNDING_OFFICE_NUM", "PROGRAM_YEAR") 
  ;
--------------------------------------------------------
--  Constraints for Table ALLOTMENT
--------------------------------------------------------

  ALTER TABLE "JFAS"."ALLOTMENT" ADD CONSTRAINT "ALLOTMENTS_PK" PRIMARY KEY ("FUND_CAT", "FUNDING_OFFICE_NUM", "PROGRAM_YEAR") ENABLE;
  ALTER TABLE "JFAS"."ALLOTMENT" MODIFY ("ALLOTMENT_AMOUNT" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."ALLOTMENT" MODIFY ("PROGRAM_YEAR" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."ALLOTMENT" MODIFY ("FUNDING_OFFICE_NUM" NOT NULL ENABLE);
  ALTER TABLE "JFAS"."ALLOTMENT" MODIFY ("FUND_CAT" NOT NULL ENABLE);

  
 --===========================================================
 CREATE TABLE "JFAS"."ALLOTMENT_OUTPUT" 
   (	"RANDOM_NUMBER" NUMBER, 
	"COL_ROWNUM" NUMBER, 
	"COL_LEVEL" NUMBER, 
	"FUND_CAT" VARCHAR2(50 BYTE), 
	"FUND_OFFICE_NUM" VARCHAR2(50 BYTE), 
	"FULL_NAME" VARCHAR2(50 BYTE), 
	"YEAR_MINUS_7" VARCHAR2(20 BYTE), 
	"NCFMS_UPD_MINUS_7" VARCHAR2(1 BYTE), 
	"YEAR_MINUS_6" VARCHAR2(20 BYTE), 
	"NCFMS_UPD_MINUS_6" VARCHAR2(20 BYTE), 
	"YEAR_MINUS_5" VARCHAR2(20 BYTE), 
	"NCFMS_UPD_MINUS_5" VARCHAR2(1 BYTE), 
	"YEAR_MINUS_4" VARCHAR2(20 BYTE), 
	"NCFMS_UPD_MINUS_4" VARCHAR2(20 BYTE), 
	"YEAR_MINUS_3" VARCHAR2(20 BYTE), 
	"NCFMS_UPD_MINUS_3" VARCHAR2(1 BYTE), 
	"YEAR_MINUS_2" VARCHAR2(20 BYTE), 
	"NCFMS_UPD_MINUS_2" VARCHAR2(20 BYTE), 
	"YEAR_MINUS_1" VARCHAR2(20 BYTE), 
	"NCFMS_UPD_MINUS_1" VARCHAR2(1 BYTE), 
	"YEAR_MINUS_0" VARCHAR2(20 BYTE), 
	"NCFMS_UPD_MINUS_0" VARCHAR2(20 BYTE), 
	"YEAR_PLUS_1" VARCHAR2(20 BYTE), 
	"NCFMS_UPD_PLUS_1" VARCHAR2(1 BYTE), 
	"YEAR_PLUS_2" VARCHAR2(20 BYTE), 
	"NCFMS_UPD_PLUS_2" VARCHAR2(20 BYTE), 
	"ORDER_BY" NUMBER
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "JFAS_DATA" ;

 
 
 


