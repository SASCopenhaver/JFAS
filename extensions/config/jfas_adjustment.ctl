Options (Skip=1)
LOAD DATA 
truncate
INTO TABLE JFAS.adjustment_load
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"'
trailing nullcols

( 
AAPP_NUM 	integer external,
DESCRIPTION char "rtrim(:DESCRIPTION)",
COST_CAT_CODE char "rtrim(rtrim(upper(:COST_CAT_CODE))||'  '||rtrim(:COST_SUB_CAT))", 		
COST_SUB_CAT  char "rtrim(:COST_SUB_CAT)",
DATE_EFFECTIVE DATE(11) "mm/dd/yyyy",
MOD_REQUIRED   char "rtrim(upper(:MOD_REQUIRED))",
BI_FEE_REQUIRED Char "rtrim(upper(:BI_FEE_REQUIRED))",
ONGOING        Char "rtrim(upper(:ONGOING))",
COST_FULL_CY        DECIMAL EXTERNAL,
COST_CURRENT_CY    DECIMAL EXTERNAL,
PY_CRA_BUDGET    INTEGER EXTERNAL,    
FOP_Amount			DECIMAL EXTERNAL,      
BACK_LOC     CHAR  "rtrim(:BACK_LOC)",
ROW_Num	 	integer "SEQ_adjustment_upload.nextval")
    
