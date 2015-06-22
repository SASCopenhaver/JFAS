create or replace FUNCTION F_GETFULLHIERARCHYPATH( argCatID IN NUMBER ) RETURN VARCHAR2 
AS 
--------------------------------------------------------------------------------
v_RtnVal VARCHAR2(1000) DEFAULT '';
v_Level  NUMBER;
--------------------------------------------------------------------------------
CURSOR c_getLevel IS
    SELECT LEVEL AS H_LEVEL, ml.SPLAN_CAT_ID, ml.SPLAN_CAT_PARENT_ID
      FROM SPLAN_CAT_MASTER_LIST ml
     START WITH ml.SPLAN_CAT_PARENT_ID = 0            
    CONNECT BY PRIOR ml.SPLAN_CAT_ID = ml.SPLAN_CAT_PARENT_ID;

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
--------------------------------------------------------------------------------  
END F_GETFULLHIERARCHYPATH;