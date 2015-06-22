create or replace PACKAGE OBLIG_ALLOC_RECON_PKG AS 
TYPE refc_Base is REF CURSOR;
--======================================================================================================================
PROCEDURE sp_getObligAllocRecon_AAPP(arg_PY                   IN FOP.PY%TYPE -- NUMBER
                                    ,arg_FundCat              IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                                    ,arg_FundingOfficeNum     IN LU_FUNDING_OFFICE.FUNDING_OFFICE_NUM%TYPE -- NUMBER
                                    ,rc_getObligAllocRecon_AAPP OUT refc_Base);
--======================================================================================================================
PROCEDURE sp_getObligAllocRecon( arg_PY                   IN FOP.PY%TYPE -- NUMBER
                                ,arg_FundCat              IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                                ,rc_getObligAllocRecon    OUT refc_Base);
--======================================================================================================================
--======================================================================================================================
FUNCTION f_calcSubAllotAmount (arg_Funding_Office_Num IN NUMBER
                              ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                              ,arg_PY IN NUMBER) RETURN NUMBER;
--======================================================================================================================
FUNCTION f_calcPYQuatAlloc_AAPP( arg_FundCat  IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                                ,arg_Qtr      IN NUMBER
                                ,arg_PY       IN NUMBER
                                ,arg_AAPP_Num IN AAPP.AAPP_NUM%TYPE -- NUMBER
                                ) RETURN NUMBER;
--======================================================================================================================
FUNCTION f_calcPYQuatAlloc(arg_Funding_Office_Num IN NUMBER
                          ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                          ,arg_Qtr IN NUMBER
                          ,arg_PY IN NUMBER) RETURN NUMBER;
--======================================================================================================================
FUNCTION f_calcNCFMSObligation(arg_Funding_Office_Num IN NUMBER
                              ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                              ,arg_PY IN NUMBER) RETURN NUMBER;
--======================================================================================================================
FUNCTION f_calcNCFMSObligation_AAPP( arg_FundCat            IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                                    ,arg_PY                 IN NUMBER
                                    ,arg_AAPP_Num           IN AAPP.AAPP_NUM%TYPE -- NUMBER
                                    ) RETURN NUMBER;
--======================================================================================================================
FUNCTION f_calcFOP(arg_Funding_Office_Num IN NUMBER
                  ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                  ,arg_PY IN NUMBER) RETURN NUMBER;
--======================================================================================================================
FUNCTION f_calcFOP_AAPP( arg_FundCat            IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                        ,arg_PY                 IN NUMBER
                        ,arg_AAPP_Num           IN AAPP.AAPP_NUM%TYPE -- NUMBER
                        ) RETURN NUMBER;
--======================================================================================================================
FUNCTION f_getAllotSource(arg_Funding_Office_Num IN NUMBER
                         ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                         ,arg_PY IN NUMBER) RETURN VARCHAR2;
--======================================================================================================================
FUNCTION f_getAllotDate(arg_Funding_Office_Num IN NUMBER
                       ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                       ,arg_PY IN NUMBER) RETURN VARCHAR2;
--======================================================================================================================
FUNCTION f_getObligDate RETURN VARCHAR2;
--======================================================================================================================
FUNCTION f_calcFOPPercent_AAPP( arg_FundCat  IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                               ,arg_PY       IN NUMBER
                               ,arg_AAPP_Num IN AAPP.AAPP_NUM%TYPE -- NUMBER
                               ) RETURN NUMBER;
--======================================================================================================================
FUNCTION f_calcFOPPercent(arg_Funding_Office_Num IN NUMBER
                         ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                         ,arg_PY IN NUMBER) RETURN NUMBER;
--======================================================================================================================
END OBLIG_ALLOC_RECON_PKG;

/* TEST call:
DELETE Z_OAR_TEST;

DECLARE
rc_getProgramYearQuarter SYS_REFCURSOR;
rc_getObligAllocRecon SYS_REFCURSOR;
arg_PY NUMBER DEFAULT 2013;
arg_FundCat VARCHAR2(4) DEFAULT 'OPS';
BEGIN
OBLIG_ALLOC_RECON_PKG.sp_getObligAllocRecon(arg_PY, arg_FundCat, rc_getProgramYearQuarter, rc_getObligAllocRecon);
END;

SELECT * FROM Z_OAR_TEST;
*/

/

create or replace PACKAGE BODY OBLIG_ALLOC_RECON_PKG AS
--======================================================================================================================
PROCEDURE sp_getObligAllocRecon_AAPP(arg_PY                     IN FOP.PY%TYPE -- NUMBER
                                    ,arg_FundCat                IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                                    ,arg_FundingOfficeNum       IN LU_FUNDING_OFFICE.FUNDING_OFFICE_NUM%TYPE -- NUMBER
                                    ,rc_getObligAllocRecon_AAPP OUT refc_Base) 
AS

v_Qtr NUMBER; -- Quater

BEGIN
--......................................................................................................................
IF arg_PY != UTILITY.fun_GetCurrntProgram_Year THEN
  v_Qtr := 4;
ELSE  
  v_Qtr := UTILITY.fun_get_quarter (NULL, 'P');
END IF;
--......................................................................................................................
OPEN rc_getObligAllocRecon_AAPP FOR
    SELECT arg_PY           AS py
          ,v_Qtr            AS qrtr
          ,f_getObligDate() AS obligDate
          ,arg_FundCat      AS fundCat
          ,(select lfc.fund_cat_desc 
             from LU_FUND_CAT lfc
            where lfc.fund_cat = arg_FundCat)   AS fundCatDesc
          ,arg_FundingOfficeNum    AS fundingOfficeNum
          ,lfo.funding_office_desc AS fundingOfficeDesc
          ,NVL(c.center_name, ' ') AS centerName
          ,NVL(a.venue, ' ')       AS venue
          ,aapp_program_activity(a.aapp_num,'S') AS programActivity
          ,a.aapp_num              AS aappNum 
          ,a.date_start            AS dateStart
          ,(select MAX (date_end)
              from aapp_yearend
             where aapp_yearend.aapp_num = a.aapp_num) AS dateEnd
          --------------------------------------------------------------------------------------------------------------
          ,f_calcPYQuatAlloc_AAPP(arg_FundCat, v_Qtr, arg_PY, a.aapp_num ) AS allocation
          --------------------------------------------------------------------------------------------------------------
          ,f_calcFOP_AAPP( arg_FundCat, arg_PY, a.aapp_num)                AS fopAmount
          --------------------------------------------------------------------------------------------------------------
          ,f_calcFOP_AAPP(arg_FundCat, arg_PY, a.aapp_num)
           -
           f_calcPYQuatAlloc_AAPP(arg_FundCat, v_Qtr, arg_PY, a.aapp_num)  AS diffFOPAllocat
          --------------------------------------------------------------------------------------------------------------
          ,f_calcNCFMSObligation_AAPP(arg_FundCat, arg_PY, a.aapp_num)     AS oblig
          --------------------------------------------------------------------------------------------------------------
          ,f_calcFOPPercent_AAPP(arg_FundCat, arg_PY, a.aapp_num)          AS fopPercent
          --------------------------------------------------------------------------------------------------------------
          --,f_calcPYQuatAlloc_AAPP(arg_FundCat, v_Qtr, arg_PY, a.aapp_num)
          ,f_calcFOP_AAPP(arg_FundCat, arg_PY, a.aapp_num)
           -
           f_calcNCFMSObligation_AAPP(arg_FundCat, arg_PY, a.aapp_num)     AS diffFOPOblig
          --------------------------------------------------------------------------------------------------------------
      FROM AAPP a
          ,LU_FUNDING_OFFICE lfo
          ,CENTER c
     WHERE a.funding_office_num = arg_FundingOfficeNum
       AND a.funding_office_num = lfo.funding_office_num
       AND a.center_id = c.center_id(+)
       AND (-- FOP:
              (select Count(*)
                 from FOP f1
                where f1.aapp_num = a.aapp_num
                  and f1.funding_office_num = a.funding_office_num
                  and f1.py = arg_PY
                  ) > 0  
              OR
              -- FOOTPRINT_NCFMS:
              (select Count(*)
                 from FOOTPRINT_NCFMS fn1
                where fn1.aapp_num = a.aapp_num
                  and fn1.funding_office_num = a.funding_office_num
                  and fn1.approp_py = arg_PY
                  and fn1.fund_cat = arg_FundCat
              ) > 0
            );
--......................................................................................................................
END sp_getObligAllocRecon_AAPP;

--======================================================================================================================
PROCEDURE sp_getObligAllocRecon( arg_PY                   IN FOP.PY%TYPE -- NUMBER
                                ,arg_FundCat              IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                                ,rc_getObligAllocRecon    OUT refc_Base) AS
------------------------------------------------------------------------------------------------------------------------
v_PY NUMBER DEFAULT UTILITY.fun_GetCurrntProgram_Year;
v_Qtr NUMBER; -- Quater
v_fundCatDesc LU_FUND_CAT.FUND_CAT_DESC%TYPE; -- VARCHAR2(25)
------------------------------------------------------------------------------------------------------------------------
BEGIN
--......................................................................................................................
IF arg_PY IS NOT NULL AND arg_PY != 0 THEN
  v_PY := arg_PY;
END IF;
--......................................................................................................................
IF v_PY != UTILITY.fun_GetCurrntProgram_Year THEN
  v_Qtr := 4;
ELSE  
  v_Qtr := UTILITY.fun_get_quarter (NULL, 'P');
END IF;
--......................................................................................................................
SELECT FUND_CAT_DESC
  INTO v_fundCatDesc
  FROM LU_FUND_CAT
 WHERE FUND_CAT = arg_FundCat;
--......................................................................................................................
OPEN rc_getObligAllocRecon FOR 

                         SELECT  v_PY          AS py
                                ,v_Qtr         AS qrtr
                                ,arg_FundCat   AS fundCat
                                ,v_fundCatDesc AS fundCatDesc
                                ----------------------------------------------------------------------------------------
                                ,f_getAllotSource(lfo.funding_office_num, arg_FundCat, v_PY)              AS allotSource
                                ----------------------------------------------------------------------------------------
                                ,f_getAllotDate(lfo.funding_office_num, arg_FundCat, v_PY)                AS allotdate
                                ----------------------------------------------------------------------------------------                                                                
                                ,f_getObligDate()                                                         AS obligDate
                                ----------------------------------------------------------------------------------------
                                ,lfo.funding_office_num                                                   AS fundingOfficeNum
                                ,lfo.funding_office_desc                                                  AS fundingOfficeDesc
                                 ----------------------------------------------------------------------------------
                                ,(select Count(*)
                                    from AAPP a1
                                        ,AAPP_CONTRACT_TYPE act1
                                   where a1.funding_office_num = lfo.funding_office_num
                                     and a1.aapp_num = act1.aapp_num
                                     and act1.contract_type_code = 'A'
                                     and ( 
                                            (select Count(*)
                                               from FOP f2
                                              where f2.py = v_PY
                                                and f2.aapp_num = a1.aapp_num) > 0
                                            or 
                                            (select Count(*)
                                               from FOOTPRINT_NCFMS fn2
                                              where fn2.approp_py = v_PY
                                                and fn2.aapp_num = a1.aapp_num) > 0
                                         )
                                  )                                                                AS aappCount_ctrops --"Centers",
                                 ----------------------------------------------------------------------------------
                                ,(select Count(Distinct(a1.aapp_num))
                                    from AAPP a1
                                        ,AAPP_CONTRACT_TYPE act1
                                   where a1.funding_office_num = lfo.funding_office_num
                                     and a1.aapp_num = act1.aapp_num
                                     and act1.contract_type_code in ('C1', 'C2')
                                     and ( 
                                            (select Count(*)
                                               from FOP f2
                                              where f2.py = v_PY
                                                and f2.aapp_num = a1.aapp_num) > 0
                                            or 
                                            (select Count(*)
                                               from FOOTPRINT_NCFMS fn2
                                              where fn2.approp_py = v_PY
                                                and fn2.aapp_num = a1.aapp_num) > 0
                                         )
                                   )                                                               AS aappCount_oacts  --"O/A, CTS",
                                 ----------------------------------------------------------------------------------
                                ,(select Count(*)
                                    from AAPP a1
                                   where a1.funding_office_num = lfo.funding_office_num
                                     and a1.aapp_num NOT IN (select act2.aapp_num 
                                                               from AAPP_CONTRACT_TYPE act2 
                                                              where act2.CONTRACT_TYPE_CODE in ('A', 'C1', 'C2'))
                                     and ( 
                                            (select Count(*)
                                               from FOP f2
                                              where f2.py = v_PY
                                                and f2.aapp_num = a1.aapp_num) > 0
                                            or 
                                            (select Count(*)
                                               from FOOTPRINT_NCFMS fn2
                                              where fn2.approp_py = v_PY
                                                and fn2.aapp_num = a1.aapp_num) > 0
                                         )
                                  )                                                                  AS aappCount_other -- "Other",
                                 ----------------------------------------------------------------------------------
                                ,f_calcSubAllotAmount (lfo.funding_office_num, arg_FundCat, v_PY)    AS subAllotment    --"PY Sub-allotment (JFAS)",
                                 ----------------------------------------------------------------------------------
                                ,f_calcPYQuatAlloc(lfo.funding_office_num,arg_FundCat,v_Qtr, v_PY)   AS allocation      --"PY Cum. Quat. Alloc.",
                                 ----------------------------------------------------------------------------------
                                ,f_calcSubAllotAmount (lfo.funding_office_num,  arg_FundCat, v_PY) 
                                 - 
                                 f_calcPYQuatAlloc(lfo.funding_office_num, arg_FundCat, v_Qtr, v_PY) AS diffAllotAllocat--"Diff.",
                                 ----------------------------------------------------------------------------------
                                ,f_calcNCFMSObligation(lfo.funding_office_num, arg_FundCat, v_PY)    AS oblig           --"Obligation (NCFMS)",
                                 ----------------------------------------------------------------------------------
                                ,f_calcFOP(lfo.funding_office_num, arg_FundCat, v_PY)                AS fopAmount       --"FOP (JFAS)",
                                 ---------------------------------------------------------------------------------- 
                                ,f_calcFOPPercent(lfo.funding_office_num, arg_FundCat, v_PY)         AS fopPercent      --"FOP % vs Obl",
                                 ----------------------------------------------------------------------------------
                                ,f_calcFOP(lfo.funding_office_num, arg_FundCat, v_PY)
                                 -
                                 f_calcPYQuatAlloc(lfo.funding_office_num,arg_FundCat,v_Qtr, v_PY)   AS diffFOPAllocat    --"FOP Diff (vs Allocation)"
                                 ----------------------------------------------------------------------------------
                            FROM LU_FUNDING_OFFICE lfo
                           WHERE  (select count(*)
                                    from FOP f1
                                   where f1.funding_office_num = lfo.funding_office_num
                                     and f1.py = v_PY) > 0
                                  OR
                                  (select count(*)
                                     from footprint_ncfms fn1
                                    where fn1.funding_office_num = lfo.funding_office_num
                                      and fn1.approp_py = v_PY) > 0
                            ORDER BY lfo.sort_order;

END sp_getObligAllocRecon;

--======================================================================================================================
FUNCTION f_calcFOPPercent( arg_Funding_Office_Num IN NUMBER
                          ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                          ,arg_PY IN NUMBER) RETURN NUMBER
AS 
v_RtnVal    NUMBER DEFAULT 0;
v_CalcNCFMS NUMBER DEFAULT 0;
v_CalcFOP   NUMBER DEFAULT 0;
BEGIN
    SELECT Round(f_calcNCFMSObligation(arg_Funding_Office_Num, arg_FundCat, arg_PY), 1)
      INTO v_CalcNCFMS
      FROM dual;
    
    SELECT f_calcFOP(arg_Funding_Office_Num, arg_FundCat, arg_PY)
      INTO v_CalcFOP
      FROM dual;
    
    IF v_CalcFOP IS NULL OR v_CalcFOP = 0 THEN
      v_RtnVal := 0;
    ELSE
      SELECT Round(v_CalcNCFMS*100/v_CalcFOP, 1)
        INTO v_RtnVal
        FROM dual;
    END IF;

    RETURN v_RtnVal;

END f_calcFOPPercent;

--======================================================================================================================
FUNCTION f_calcFOPPercent_AAPP(arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                              ,arg_PY IN NUMBER
                              ,arg_AAPP_Num IN AAPP.AAPP_NUM%TYPE -- NUMBER
                              ) RETURN NUMBER
AS 
v_RtnVal    NUMBER DEFAULT 0;
v_CalcNCFMS NUMBER DEFAULT 0;
v_CalcFOP   NUMBER DEFAULT 0;
BEGIN
    SELECT Round(f_calcNCFMSObligation_AAPP(arg_FundCat, arg_PY, arg_AAPP_Num), 1)
      INTO v_CalcNCFMS
      FROM dual;
    
    SELECT f_calcFOP_AAPP(arg_FundCat, arg_PY, arg_AAPP_Num)
      INTO v_CalcFOP
      FROM dual;
    
    IF v_CalcFOP IS NULL OR v_CalcFOP = 0 THEN
      v_RtnVal := 0;
    ELSE
      SELECT Round(v_CalcNCFMS*100/v_CalcFOP, 1)
        INTO v_RtnVal
        FROM dual;
    END IF;

    RETURN v_RtnVal;

END f_calcFOPPercent_AAPP;
--======================================================================================================================
FUNCTION f_getObligDate RETURN VARCHAR2
AS
v_RtnVal VARCHAR2(10) DEFAULT '07/04/1776';
BEGIN
         SELECT TO_CHAR(MAX(update_date), 'MM/DD/YYYY')
           INTO v_RtnVal
           FROM FOOTPRINT_NCFMS fn;
         
         RETURN NVL(v_RtnVal, '07/04/1776');
         
END f_getObligDate;
--======================================================================================================================
FUNCTION f_getAllotDate(arg_Funding_Office_Num IN NUMBER
                       ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                       ,arg_PY IN NUMBER) RETURN VARCHAR2
AS
v_RtnVal VARCHAR2(10) DEFAULT '07/04/1776';
BEGIN
  SELECT TO_CHAR(UPDATE_DATE, 'MM/DD/YYYY')
    INTO v_RtnVal
    FROM ALLOTMENT
   WHERE funding_office_num = arg_Funding_Office_Num
     AND fund_cat = arg_FundCat
     AND PY = arg_PY;

  RETURN NVL(v_RtnVal, '07/04/1776');
END f_getAllotDate;
--======================================================================================================================
FUNCTION f_getAllotSource(arg_Funding_Office_Num IN NUMBER
                         ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                         ,arg_PY IN NUMBER) RETURN VARCHAR2
AS
v_RtnVal VARCHAR2(10);
v_CountAllot NUMBER DEFAULT 0;
v_CountAllotNCFMS NUMBER DEFAULT 0;
BEGIN

SELECT Count(*)
  INTO v_CountAllot
  FROM ALLOTMENT
 WHERE FUNDING_OFFICE_NUM = arg_Funding_Office_Num
   AND FUND_CAT = arg_FundCat
   AND PY = arg_PY;

SELECT Count(*)
  INTO v_CountAllotNCFMS
  FROM ALLOTMENT_NCFMS
 WHERE FUNDING_OFFICE_NUM = arg_Funding_Office_Num
   AND FUND_CAT = arg_FundCat
   AND PY = arg_PY;

SELECT DECODE(v_CountAllot + v_CountAllotNCFMS, 'NCFMS', 'JFAS')
 INTO v_RtnVal
 FROM DUAL;


/*
  SELECT DECODE(ncfms_updated, 'Y', 'NCFMS', 'JFAS')
    INTO v_RtnVal
    FROM ALLOTMENT
   WHERE funding_office_num = arg_Funding_Office_Num
     AND fund_cat = arg_FundCat
     AND PY = arg_PY;
*/
  RETURN NVL(v_RtnVal, '');
END f_getAllotSource;
--======================================================================================================================
FUNCTION f_calcSubAllotAmount (arg_Funding_Office_Num IN NUMBER
                              ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                              ,arg_PY IN NUMBER) RETURN NUMBER
AS
v_RtnVal NUMBER DEFAULT 0;
BEGIN

    SELECT Q1_AMOUNT+Q2_AMOUNT+Q3_AMOUNT+Q4_AMOUNT
      INTO v_RtnVal
      FROM ALLOTMENT 
     WHERE funding_office_num = arg_Funding_Office_Num
       AND PY = arg_PY
       AND fund_cat = arg_FundCat;
/*
    SELECT SUM(al1.allotment_amount)
      INTO v_RtnVal
      FROM ALLOTMENT al1
     WHERE al1.funding_office_num = arg_Funding_Office_Num
       AND al1.program_year = arg_PY
       AND al1.fund_cat = arg_FundCat;
*/
    IF v_RtnVal IS NULL THEN
      v_RtnVal := 0;
    END IF;
    
    RETURN v_RtnVal;
  
END f_calcSubAllotAmount;
--======================================================================================================================
FUNCTION f_calcPYQuatAlloc_AAPP( arg_FundCat  IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                                ,arg_Qtr      IN NUMBER
                                ,arg_PY       IN NUMBER
                                ,arg_AAPP_Num IN AAPP.AAPP_NUM%TYPE -- NUMBER
                                ) RETURN NUMBER
AS
v_RtnVal NUMBER DEFAULT 0;
BEGIN

    SELECT SUM(apa.amount)
      INTO v_RtnVal
      FROM AAPP_PY_ALLOCATION apa
          ,AAPP a
     WHERE a.aapp_num = arg_AAPP_Num
       AND a.aapp_num = apa.aapp_num
       AND apa.fund_cat = arg_FundCat
       AND apa.qtr <= arg_Qtr
       AND apa.py = arg_PY
       /*
       AND ( 
              (select Count(*)
                 from FOP f1
                where f1.py = arg_PY
                  and f1.aapp_num = a.aapp_num) > 0
              or 
              (select Count(*)
                 from FOOTPRINT_NCFMS fn1
                where fn1.approp_py = arg_PY
                  and fn1.aapp_num = a.aapp_num) > 0
           )*/
          ;
    
    IF v_RtnVal IS NULL THEN
      v_RtnVal := 0;
    END IF;
    
    RETURN v_RtnVal;
    
END f_calcPYQuatAlloc_AAPP;
--======================================================================================================================
FUNCTION f_calcPYQuatAlloc(arg_Funding_Office_Num IN NUMBER
                          ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                          ,arg_Qtr IN NUMBER
                          ,arg_PY IN NUMBER) RETURN NUMBER
AS
v_RtnVal NUMBER DEFAULT 0;
BEGIN

    SELECT SUM(apa.amount)
      INTO v_RtnVal
      FROM AAPP_PY_ALLOCATION apa
          ,AAPP a
     WHERE a.aapp_num = apa.aapp_num
       AND a.funding_office_num = arg_Funding_Office_Num
       AND apa.fund_cat = arg_FundCat
       AND apa.qtr <= arg_Qtr
       AND apa.py = arg_PY
       AND ( 
              (select Count(*)
                 from FOP f1
                where f1.py = arg_PY
                  and f1.aapp_num = a.aapp_num) > 0
              or 
              (select Count(*)
                 from FOOTPRINT_NCFMS fn1
                where fn1.approp_py = arg_PY
                  and fn1.aapp_num = a.aapp_num) > 0
           );
    
    IF v_RtnVal IS NULL THEN
      v_RtnVal := 0;
    END IF;
    
    RETURN v_RtnVal;
    
END f_calcPYQuatAlloc;
--======================================================================================================================
FUNCTION f_calcNCFMSObligation_AAPP( arg_FundCat            IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                                    ,arg_PY                 IN NUMBER
                                    ,arg_AAPP_Num           IN AAPP.AAPP_NUM%TYPE -- NUMBER
                                    ) RETURN NUMBER
AS
v_RtnVal NUMBER;
BEGIN
         SELECT SUM(fn.oblig)
           INTO v_RtnVal
           FROM FOOTPRINT_NCFMS fn,
                AAPP a
          WHERE a.aapp_num = arg_AAPP_Num
            AND a.aapp_num = fn.aapp_num
            AND fn.fund_cat = arg_FundCat
            AND fn.approp_py = arg_PY
            /*
            AND ( 
                  (select Count(*)
                     from FOP f1
                    where f1.py = arg_PY
                      and f1.aapp_num = a.aapp_num) > 0
                  or 
                  (select Count(*)
                     from FOOTPRINT_NCFMS fn1
                    where fn1.approp_py = arg_PY
                      and fn1.aapp_num = a.aapp_num) > 0
               )
               */
               ;
 
      IF v_RtnVal IS NULL THEN
        v_RtnVal := 0;
      END IF;
      
      RETURN v_RtnVal;
  
END f_calcNCFMSObligation_AAPP;
--======================================================================================================================

FUNCTION f_calcNCFMSObligation(arg_Funding_Office_Num IN NUMBER
                              ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                              ,arg_PY IN NUMBER) RETURN NUMBER
AS
v_RtnVal NUMBER;
BEGIN
         SELECT SUM(fn.oblig)
           INTO v_RtnVal
           FROM FOOTPRINT_NCFMS fn,
                AAPP a
          WHERE a.aapp_num = fn.aapp_num
            AND fn.fund_cat = arg_FundCat
            AND fn.approp_py = arg_PY
            AND a.funding_office_num = arg_Funding_Office_Num
            AND ( 
                  (select Count(*)
                     from FOP f1
                    where f1.py = arg_PY
                      and f1.aapp_num = a.aapp_num) > 0
                  or 
                  (select Count(*)
                     from FOOTPRINT_NCFMS fn1
                    where fn1.approp_py = arg_PY
                      and fn1.aapp_num = a.aapp_num) > 0
               );
 
      IF v_RtnVal IS NULL THEN
        v_RtnVal := 0;
      END IF;
      
      RETURN v_RtnVal;
  
END f_calcNCFMSObligation;
--======================================================================================================================
FUNCTION f_calcFOP_AAPP( arg_FundCat            IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                        ,arg_PY                 IN NUMBER
                        ,arg_AAPP_Num           IN AAPP.AAPP_NUM%TYPE -- NUMBER
                        ) RETURN NUMBER
AS
v_RtnVal NUMBER;
BEGIN

     SELECT SUM(f.amount)
       INTO v_RtnVal
       FROM FOP f
           ,AAPP a
           ,LU_COST_CAT lcc
      WHERE a.aapp_num = arg_AAPP_Num
        AND a.aapp_num = f.aapp_num
        AND f.py = arg_PY
        AND f.cost_cat_id = lcc.cost_cat_id
        AND lcc.fund_cat = arg_FundCat
        /*
        AND ( 
                (select Count(*)
                   from FOP f2
                  where f2.py = arg_PY
                    and f2.aapp_num = a.aapp_num) > 0
                or 
                (select Count(*)
                   from FOOTPRINT_NCFMS fn2
                  where fn2.approp_py = arg_PY
                    and fn2.aapp_num = a.aapp_num) > 0
             )
        */
        ;

      IF v_RtnVal IS NULL THEN
        v_RtnVal := 0;
      END IF;

  RETURN v_RtnVal;

END f_calcFOP_AAPP;
--======================================================================================================================
FUNCTION f_calcFOP(arg_Funding_Office_Num IN NUMBER
                  ,arg_FundCat IN LU_FUND_CAT.FUND_CAT%TYPE -- VARCHAR2(4)
                  ,arg_PY IN NUMBER) RETURN NUMBER
AS
v_RtnVal NUMBER;
BEGIN

     SELECT SUM(f.amount)
       INTO v_RtnVal
       FROM FOP f
           ,AAPP a
           ,LU_COST_CAT lcc
      WHERE a.aapp_num = f.aapp_num
        AND f.py = arg_PY
        AND a.funding_office_num = arg_Funding_Office_Num
        AND f.cost_cat_id = lcc.cost_cat_id
        AND lcc.fund_cat = arg_FundCat
        AND ( 
                (select Count(*)
                   from FOP f2
                  where f2.py = arg_PY
                    and f2.aapp_num = a.aapp_num) > 0
                or 
                (select Count(*)
                   from FOOTPRINT_NCFMS fn2
                  where fn2.approp_py = arg_PY
                    and fn2.aapp_num = a.aapp_num) > 0
             );

      IF v_RtnVal IS NULL THEN
        v_RtnVal := 0;
      END IF;

  RETURN v_RtnVal;

END f_calcFOP;
--======================================================================================================================

END OBLIG_ALLOC_RECON_PKG;
