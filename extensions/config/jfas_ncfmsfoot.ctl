options (skip=1)
LOAD DATA
truncate
INTO TABLE JFAS.footprint_ncfms_load
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"'
trailing nullcols

(     
DOCUMENT_ID     CHAR   "rtrim(:DOCUMENT_ID)",
AGENCY_CODE	CHAR   "rtrim(:AGENCY_CODE)",
FUND_CODE	CHAR   "rtrim(:FUND_CODE)",
BUDGET_YEAR	CHAR   "rtrim(:BUDGET_YEAR)",
PROGRAM_CODE  CHAR   "rtrim(:PROGRAM_CODE)",
ACTIVITY      CHAR   "rtrim(:ACTIVITY)",
STRAT_GOAL    CHAR   "rtrim(:STRAT_GOAL)",
FUNDING_ORG   CHAR   "rtrim(:FUNDING_ORG)",
MANAGING_UNIT CHAR   "rtrim(:MANAGING_UNIT)",
COST_CENTER   CHAR   "rtrim(:COST_CENTER)",
OBJECT_CLASS  CHAR   "rtrim(:OBJECT_CLASS)",
VENDOR_NAME   CHAR   "rtrim(:VENDOR_NAME)",
VENDOR_SITE_NAME  CHAR   "rtrim(:VENDOR_SITE_NAME)",
VENDOR_DUNS       CHAR   "rtrim(:VENDOR_DUNS)",
ORDERED_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:ORDERED_AMOUNT,'$',''),'(','-'),')',''),',','')",
ADVANCE_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:ADVANCE_AMOUNT,'$',''),'(','-'),')',''),',','')",
RECEIVED_AMOUNT   DECIMAL EXTERNAL "replace(replace(replace(replace(:RECEIVED_AMOUNT,'$',''),'(','-'),')',''),',','')",
BILLED_AMOUNT     DECIMAL EXTERNAL "replace(replace(replace(replace(:BILLED_AMOUNT,'$',''),'(','-'),')',''),',','')",
CANCELED_AMOUNT   DECIMAL EXTERNAL "replace(replace(replace(replace(:CANCELED_AMOUNT,'$',''),'(','-'),')',''),',','')")
