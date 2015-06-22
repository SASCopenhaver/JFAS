LOAD DATA
truncate
INTO TABLE JFAS.FOOTPRINT_MNLXACTN_LOAD
WHEN (XACTN_DATE <> '')
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"'
trailing nullcols
(     
XACTN_DATE   DATE "mm/dd/yyyy",
TREASURY_SYMBOL   CHAR   "rtrim(:TREASURY_SYMBOL)",
DOC_TYPE   CHAR   "rtrim(:DOC_TYPE)",
FY   CHAR   "rtrim(:FY)",
DOC_NUM   CHAR   "rtrim(:DOC_NUM)",
VENDOR_NAME   CHAR   "rtrim(:VENDOR_NAME)",
VENDOR_TIN   CHAR   "rtrim(:VENDOR_TIN)",
MOD_NUM   CHAR   "rtrim(:MOD_NUM)",
REGION   CHAR   "rtrim(:REGION)",
REGION_NUM   CHAR   "rtrim(:REGION_NUM)",
CENTER_NAME   CHAR   "rtrim(:CENTER_NAME)",
AGENCY_ID   CHAR   "rtrim(:AGENCY_ID)",
FUND   CHAR   "rtrim(:FUND)",
BUDGET_YR   CHAR   "rtrim(:BUDGET_YR)",
PROG_CODE   CHAR   "rtrim(:PROG_CODE)",
ACTIVITY   CHAR   "rtrim(:ACTIVITY)",
STRAT_GOAL   CHAR   "rtrim(:STRAT_GOAL)",
FUNDING_ORG   CHAR   "rtrim(:FUNDING_ORG)",
MANAGING_UNIT   CHAR   "rtrim(:MANAGING_UNIT)",
COST_CTR   CHAR   "rtrim(:COST_CTR)",
OBJ_CLASS_CODE   CHAR   "rtrim(:OBJ_CLASS_CODE)",
blank_1	FILLER CHAR,
blank_2	FILLER CHAR,
blank_3	FILLER CHAR,
OPS  CHAR   "rtrim(:OPS)",
CRA   CHAR   "rtrim(:CRA)",
SE   CHAR   "rtrim(:SE)",
OPS_ARRA   CHAR  "rtrim(:OPS_ARRA)",
CRA_ARRA   CHAR   "rtrim(:CRA_ARRA)",
SE_ARRA   CHAR   "rtrim(:SE_ARRA)")

