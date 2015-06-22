create or replace PACKAGE ZZZ_SPLAN_TRANS_SETUP AS 
--==============================================================================
TYPE refc_Base is REF CURSOR;

v_TRANS_TYPE_CODE VARCHAR2(4) DEFAULT 'INIT';
v_SplanTransID    NUMBER;
v_SplanTransDetID NUMBER;
v_RandomNumber    NUMBER;
--==============================================================================
PROCEDURE sp_setUp_Init_Trans( argUserID IN VARCHAR2 
                              ,argPY     IN NUMBER
                              --,rc_Cursor OUT refc_Base
                              );
--============================================================================== 
PROCEDURE sp_setUp_Routine_Trans ( argUserID     IN VARCHAR2
                                  ,argPY         IN NUMBER
                                  ,argCatID_From IN NUMBER
                                  ,argCatID_To   IN NUMBER
                                  ,argAmount     IN NUMBER);
--==============================================================================
PROCEDURE sp_setUp_Future_Trans ( argUserID IN VARCHAR2 
                                 ,argPY     IN NUMBER);
--==============================================================================
END ZZZ_SPLAN_TRANS_SETUP;

/*
SELECT H_LEVEL, SPLAN_CAT_ID, SPLAN_CAT_PARENT_ID, SPLAN_CAT_DESC, SPLAN_CAT_NOTE, COST_CAT_ID, SORT_ORDER
FROM (
        SELECT LEVEL AS H_LEVEL, sc.SPLAN_CAT_ID, sc.SPLAN_CAT_PARENT_ID, 
                LPAD(' ', LEVEL*2)|| sc.SPLAN_CAT_DESC AS SPLAN_CAT_DESC, 
                sc.SPLAN_CAT_NOTE, sc.COST_CAT_ID, sc.SORT_ORDER
          FROM SPLAN_CAT sc
        START WITH sc.SPLAN_CAT_PARENT_ID = 0
        CONNECT BY PRIOR sc.SPLAN_CAT_ID = sc.SPLAN_CAT_PARENT_ID
        ORDER SIBLINGS BY sc.SORT_ORDER
    ) v
--WHERE H_LEVEL = 3
*/
/*
DECLARE
v_UserID VARCHAR2(20) DEFAULT 'mstein';
v_PY NUMBER DEFAULT 2014;
--c_Cursor1 SYS_REFCURSOR;
BEGIN
    SPLAN_TRANS_SETUP.sp_setUp_Init_Trans(v_UserID, v_PY);
END;
*/
/*
DECLARE
v_UserID VARCHAR2(20) DEFAULT 'mstein';
v_PY NUMBER DEFAULT 2014;
v_CatID_From NUMBER DEFAULT 5;
v_CatID_To   NUMBER DEFAULT 22;
v_Amount NUMBER DEFAULT 500000;
--c_Cursor1 SYS_REFCURSOR;
BEGIN
    SPLAN_TRANS_SETUP.sp_setUp_Routine_Trans(v_UserID, v_PY, v_CatID_From, v_CatID_To, v_Amount);
END;
*/

/*
--=============================================================================================
-- I. Two tables were created:	
-- 		SPLAN_CAT_MASTER_LIST - to keep hierarchical structure of CATEGORIES.
--		To see that, run SQL below:
SELECT SUBSTR(SYS_CONNECT_BY_PATH(SPLAN_CAT_ID, ','), 2) AS PATH,
LEVEL AS H_LEVEL, ml.SPLAN_CAT_ID, ml.SPLAN_CAT_PARENT_ID, 
                LPAD(' ', LEVEL*2)|| ml.SPLAN_CAT_DESC AS SPLAN_CAT_DESC 
               ,ml.SPLAN_CAT_NOTE, ml.COST_CAT_ID , ml.SORT_ORDER
  FROM SPLAN_CAT_MASTER_LIST ml
 START WITH ml.SPLAN_CAT_PARENT_ID = 0
CONNECT BY NOCYCLE PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID
ORDER SIBLINGS BY ml.SORT_ORDER;

-- 	SPLAN_CAT_2 - to keep ONLY SUB-CATEGORIES applicable to a given year.

--=============================================================================================
-- II. Years
-- II.1:	2012 - "Original" list of categories, no changes.

-- II.2.1:	2013 -	Category "Field Operation Support" received another sub-category - "Master-Blaster" SPLAN_CAT_ID=139, SPLAN_CAT_PARENT_ID=16
-- II.2.2:			Category "Health Program" lost "Disability Support" SPLAN_CAT_ID=27, SPLAN_CAT_PARENT_ID=16

-- II.3:	2014 -  Category "Student Pay benefits" SPLAN_CAT_ID=20, SPLAN_CAT_PARENT_ID=3 along with all sub-categories was removed.

-- To see changes in the list of Categories/Sub-categories for different years, run SQL below.

SET SERVEROUTPUT ON;
DECLARE
v_PY NUMBER DEFAULT 2012; -- 2013 2014;
c_RefCursor SYS_REFCURSOR;
BEGIN
      --OPEN c_RefCursor FOR
      FOR v_Record IN 
      (
            SELECT LEVEL, v.SPLAN_CAT_ID, v.SPLAN_CAT_PARENT_ID, LPAD(' ', LEVEL*2)|| cml.SPLAN_CAT_DESC AS SPLAN_CAT_DESC 
              FROM ( 
                      SELECT sc.SPLAN_CAT_ID, sc.SPLAN_CAT_PARENT_ID
                        FROM SPLAN_CAT_2 sc
                       WHERE sc.PY = v_PY
                      UNION 
                      SELECT ml.SPLAN_CAT_ID, ml.SPLAN_CAT_PARENT_ID
                        FROM SPLAN_CAT_MASTER_LIST ml
                       WHERE ml.SPLAN_CAT_ID IN (SELECT  sc.SPLAN_CAT_PARENT_ID
                                                          FROM SPLAN_CAT_2 sc
                                                         WHERE sc.PY = v_PY)
                      UNION
                      SELECT ml.SPLAN_CAT_ID, ml.SPLAN_CAT_PARENT_ID
                        FROM SPLAN_CAT_MASTER_LIST ml
                       WHERE ml.SPLAN_CAT_ID IN (SELECT ml.SPLAN_CAT_PARENT_ID
                                                    FROM SPLAN_CAT_MASTER_LIST ml
                                                   WHERE ml.SPLAN_CAT_ID IN (SELECT  sc.SPLAN_CAT_PARENT_ID
                                                                                      FROM SPLAN_CAT_2 sc
                                                                                     WHERE sc.PY = v_PY))
                  ) v,
                  SPLAN_CAT_MASTER_LIST cml
              WHERE cml.SPLAN_CAT_ID = v.SPLAN_CAT_ID
                AND cml.SPLAN_CAT_PARENT_ID = v.SPLAN_CAT_PARENT_ID
              START WITH cml.SPLAN_CAT_PARENT_ID = 0
            CONNECT BY NOCYCLE PRIOR cml.SPLAN_CAT_ID = cml.SPLAN_CAT_PARENT_ID
              ORDER SIBLINGS BY cml.SORT_ORDER
      )
      LOOP
        --DBMS_OUTPUT.PUT_LINE(v_Record.SPLAN_CAT_ID||' |  '||v_Record.SPLAN_CAT_PARENT_ID||'  |  '|| v_Record.SPLAN_CAT_DESC);
        DBMS_OUTPUT.PUT_LINE(v_Record.SPLAN_CAT_DESC);
      END LOOP;
END;
*/


create or replace PACKAGE BODY ZZZ_SPLAN_TRANS_SETUP AS
--==============================================================================
PROCEDURE sp_setUp_Init_Trans( argUserID IN VARCHAR2 
                              ,argPY IN NUMBER
                              --,rc_Cursor OUT refc_Base
                              )
IS
--------------------------------------------------------------------------------
CURSOR c_getCategories IS
        SELECT --H_LEVEL, 
               SPLAN_CAT_ID
               --, SPLAN_CAT_PARENT_ID, SPLAN_CAT_DESC, SPLAN_CAT_NOTE, COST_CAT_ID, SORT_ORDER
        FROM ( SELECT LEVEL AS H_LEVEL, sc.SPLAN_CAT_ID, sc.SPLAN_CAT_PARENT_ID, 
                        LPAD(' ', LEVEL*2)|| sc.SPLAN_CAT_DESC AS SPLAN_CAT_DESC, 
                        sc.SPLAN_CAT_NOTE, sc.COST_CAT_ID, sc.SORT_ORDER
                  FROM SPLAN_CAT sc
                START WITH sc.SPLAN_CAT_PARENT_ID = 0
                CONNECT BY PRIOR sc.SPLAN_CAT_ID = sc.SPLAN_CAT_PARENT_ID
                ORDER SIBLINGS BY sc.SORT_ORDER ) 
        WHERE H_LEVEL = 3;

v_Counter NUMBER;
--------------------------------------------------------------------------------
BEGIN
--delete SPLAN_TRANS; delete SPLAN_TRANS_DET; commit;

  SELECT Count(*) 
    INTO v_Counter 
    FROM SPLAN_TRANS
   WHERE PY = argPY;

IF v_Counter = 0 THEN 
          FOR r_getCategories IN c_getCategories LOOP
            ----------------------------------------------------------------------------
            select SEQ_SPLAN_TRANS.nextval     into v_SplanTransID    from dual;
            select SEQ_SPLAN_TRANS_DET.nextval into v_SplanTransDetID from dual;
            select Round(dbms_random.value(100000000, 299999999), -3) into v_RandomNumber from dual;
            ----------------------------------------------------------------------------
        
            INSERT INTO SPLAN_TRANS ( SPLAN_TRANS_ID, TRANS_DATE, TRANS_DESC, PY, TRANS_NOTE,
                                      TRANS_STATUS_CODE,TRANS_TYPE_CODE,
                                      CREATE_USER, CREATE_DATE,
                                      UPDATE_USER, UPDATE_DATE)
                VALUES ( v_SplanTransID, SYSDATE, 'Init Transaction', argPY, 'Note for initial transaction', 'O', v_TRANS_TYPE_CODE,
                         argUserID, SYSDATE,
                         argUserID, SYSDATE);
        
            ----------------------------------------------------------------------------
         
            INSERT INTO SPLAN_TRANS_DET ( SPLAN_TRANS_DET_ID, SPLAN_TRANS_ID, SPLAN_CAT_ID, AMOUNT,
                                          CREATE_USER, CREATE_DATE, 
                                          UPDATE_USER, UPDATE_DATE )
                 VALUES ( v_SplanTransDetID, v_SplanTransID, r_getCategories.SPLAN_CAT_ID, v_RandomNumber,
                          argUserID, SYSDATE,
                          argUserID, SYSDATE);
        
            ----------------------------------------------------------------------------
          END LOOP;
          COMMIT;
END IF;
END sp_setUp_Init_Trans;
--==============================================================================

PROCEDURE sp_setUp_Routine_Trans ( argUserID     IN VARCHAR2
                                  ,argPY         IN NUMBER
                                  ,argCatID_From IN NUMBER
                                  ,argCatID_To   IN NUMBER
                                  ,argAmount     IN NUMBER)
IS 
BEGIN
    ----------------------------------------------------------------------------
    select SEQ_SPLAN_TRANS.nextval     into v_SplanTransID    from dual;
    --select Round(dbms_random.value(1000000, 1999999), -3) into v_RandomNumber from dual;
    v_TRANS_TYPE_CODE := 'TRNS';
    ----------------------------------------------------------------------------
    INSERT INTO SPLAN_TRANS ( SPLAN_TRANS_ID, TRANS_DATE, TRANS_DESC, PY, TRANS_NOTE, TRANS_STATUS_CODE, TRANS_TYPE_CODE,
                              CREATE_USER, CREATE_DATE,
                              UPDATE_USER, UPDATE_DATE )
    VALUES ( v_SplanTransID, SYSDATE, 'Trans from... to...', argPY, 'Trans note', 'O', v_TRANS_TYPE_CODE,
             argUserID, SYSDATE,
             argUserID, SYSDATE);
    ----------------------------------------------------------------------------

    select SEQ_SPLAN_TRANS_DET.nextval into v_SplanTransDetID from dual;
    
    INSERT INTO SPLAN_TRANS_DET ( SPLAN_TRANS_DET_ID, SPLAN_TRANS_ID, SPLAN_CAT_ID, AMOUNT, 
                                  CREATE_DATE, UPDATE_DATE,
                                  CREATE_USER, UPDATE_USER)
         VALUES ( v_SplanTransDetID, v_SplanTransID, argCatID_From, argAmount*(-1), 
                  SYSDATE, SYSDATE,
                  argUserID, argUserID);

    ----------------------------------------------------------------------------
    select SEQ_SPLAN_TRANS_DET.nextval into v_SplanTransDetID from dual;
    
    INSERT INTO SPLAN_TRANS_DET ( SPLAN_TRANS_DET_ID, SPLAN_TRANS_ID, SPLAN_CAT_ID, AMOUNT, 
                                  CREATE_DATE, UPDATE_DATE,
                                  CREATE_USER, UPDATE_USER)
         VALUES ( v_SplanTransDetID, v_SplanTransID, argCatID_To, argAmount, 
                  SYSDATE, SYSDATE,
                  argUserID, argUserID);   

    ----------------------------------------------------------------------------
    COMMIT;
END sp_setUp_Routine_Trans;                                
--==============================================================================
PROCEDURE sp_setUp_Future_Trans ( argUserID IN VARCHAR2 
                                 ,argPY     IN NUMBER)
IS
--------------------------------------------------------------------------------
CURSOR c_getCategories IS
        SELECT --H_LEVEL, 
               SPLAN_CAT_ID
               --, SPLAN_CAT_PARENT_ID, SPLAN_CAT_DESC, SPLAN_CAT_NOTE, COST_CAT_ID, SORT_ORDER
        FROM ( SELECT LEVEL AS H_LEVEL, sc.SPLAN_CAT_ID, sc.SPLAN_CAT_PARENT_ID, 
                        LPAD(' ', LEVEL*2)|| sc.SPLAN_CAT_DESC AS SPLAN_CAT_DESC, 
                        sc.SPLAN_CAT_NOTE, sc.COST_CAT_ID, sc.SORT_ORDER
                  FROM SPLAN_CAT sc
                START WITH sc.SPLAN_CAT_PARENT_ID = 0
                CONNECT BY PRIOR sc.SPLAN_CAT_ID = sc.SPLAN_CAT_PARENT_ID
                ORDER SIBLINGS BY sc.SORT_ORDER ) 
        WHERE H_LEVEL = 3;

v_Counter NUMBER;
--------------------------------------------------------------------------------
BEGIN
  SELECT Count(*) 
    INTO v_Counter 
    FROM SPLAN_TRANS_FUTURE
   WHERE PY = argPY;
IF v_Counter = 0 THEN 
          FOR r_getCategories IN c_getCategories LOOP
            ----------------------------------------------------------------------------
            select SEQ_SPLAN_TRANS.nextval     into v_SplanTransID    from dual;
            select Round(dbms_random.value(100000000, 299999999), -3) into v_RandomNumber from dual;
            ----------------------------------------------------------------------------
            INSERT INTO SPLAN_TRANS_FUTURE (SPLAN_TRANS_FUTURE_ID, SPLAN_CAT_ID, AMOUNT, PY, TRANS_NOTE,
                                            CREATE_USER, CREATE_DATE,
                                            UPDATE_USER, UPDATE_DATE)
                 VALUES (v_SplanTransID, r_getCategories.SPLAN_CAT_ID, v_RandomNumber, argPY, 'Note for Future PY',
                         argUserID, SYSDATE,
                         argUserID, SYSDATE); 
            ----------------------------------------------------------------------------
            INSERT INTO SPLAN_CAT_I_PY ( SPLAN_CAT_ID, PY,
                                          CREATE_USER, CREATE_DATE, 
                                          UPDATE_USER, UPDATE_DATE )
                 VALUES ( r_getCategories.SPLAN_CAT_ID, argPY,
                          argUserID, SYSDATE,
                          argUserID, SYSDATE);
            ----------------------------------------------------------------------------
          END LOOP;
          COMMIT;
END IF;
--------------------------------------------------------------------------------
END sp_setUp_Future_Trans;
--==============================================================================
END ZZZ_SPLAN_TRANS_SETUP;