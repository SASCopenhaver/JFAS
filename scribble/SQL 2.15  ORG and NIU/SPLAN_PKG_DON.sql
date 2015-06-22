create or replace PACKAGE SPLAN_PKG_DON AS 
  -- Public type declarations
TYPE refc_Base is REF CURSOR;
--==============================================================================
PROCEDURE sp_getTopSplanCodes ( argsplanSectionCode IN VARCHAR2
                                 ,argPY     IN NUMBER
                                 ,argStartParentId     IN NUMBER
                                 ,rc_TopSplanCodes OUT refc_Base);
--==============================================================================
FUNCTION f_getL3_SPLAN_CAT_ID(argLevel IN NUMBER
                             ,argPath  IN VARCHAR2) RETURN NUMBER;
--==============================================================================
FUNCTION f_getFormatedCatDesc(argPath  IN VARCHAR2,
                              argSortOrder IN NUMBER,
                              argSplanCatDesc IN VARCHAR2) RETURN VARCHAR2;
--==============================================================================
END SPLAN_PKG_DON;

/

create or replace PACKAGE BODY SPLAN_PKG_DON AS

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


END SPLAN_PKG_DON;