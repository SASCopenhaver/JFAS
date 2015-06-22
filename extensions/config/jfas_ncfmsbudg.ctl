options (skip=1)
LOAD DATA
truncate
INTO TABLE JFAS.budget_ncfms_load
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"'
trailing nullcols

(     
AGENCY_CODE	CHAR   "rtrim(:AGENCY_CODE)",
FUND_CODE	CHAR   "rtrim(:FUND_CODE)",
BUDGET_YEAR	CHAR   "rtrim(:BUDGET_YEAR)",
PROGRAM_CODE  CHAR   "rtrim(:PROGRAM_CODE)",
ACTIVITY      CHAR   "rtrim(:ACTIVITY)",
STRAT_GOAL    CHAR   "rtrim(:STRAT_GOAL)",
FUNDING_ORG   CHAR   "rtrim(:FUNDING_ORG)",
MANAGING_UNIT CHAR   "rtrim(:MANAGING_UNIT)",
APPROPRIATION_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:APPROPRIATION_AMOUNT,'$',''),'(','-'),')',''),',','')",
PERM_TEMP_REDUCTIONS    DECIMAL EXTERNAL "replace(replace(replace(replace(:PERM_TEMP_REDUCTIONS,'$',''),'(','-'),')',''),',','')",
AUTH_TEMP_UNAVAILABLE    DECIMAL EXTERNAL "replace(replace(replace(replace(:AUTH_TEMP_UNAVAILABLE,'$',''),'(','-'),')',''),',','')",
TRANSFERS_IN_OUT    DECIMAL EXTERNAL "replace(replace(replace(replace(:TRANSFERS_IN_OUT,'$',''),'(','-'),')',''),',','')",
ANTICIPATED_COLLECTIONS    DECIMAL EXTERNAL "replace(replace(replace(replace(:ANTICIPATED_COLLECTIONS,'$',''),'(','-'),')',''),',','')",
TOTAL_BUDGET_AUTHORITY    DECIMAL EXTERNAL "replace(replace(replace(replace(:TOTAL_BUDGET_AUTHORITY,'$',''),'(','-'),')',''),',','')",
PY_CARRYFORWARD_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:PY_CARRYFORWARD_AMOUNT,'$',''),'(','-'),')',''),',','')",
CY_APPROPRIATION_ORIG_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:CY_APPROPRIATION_ORIG_AMOUNT,'$',''),'(','-'),')',''),',','')",
CY_APPROPRIATION_BALANCE    DECIMAL EXTERNAL "replace(replace(replace(replace(:CY_APPROPRIATION_BALANCE,'$',''),'(','-'),')',''),',','')",
APPROPRIATION_BALANCE_TB    DECIMAL EXTERNAL "replace(replace(replace(replace(:APPROPRIATION_BALANCE_TB,'$',''),'(','-'),')',''),',','')",
CY_APPORTIONMENT_ORIG_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:CY_APPORTIONMENT_ORIG_AMOUNT,'$',''),'(','-'),')',''),',','')",
CY_APPORTIONMENT_BALANCE    DECIMAL EXTERNAL "replace(replace(replace(replace(:CY_APPORTIONMENT_BALANCE,'$',''),'(','-'),')',''),',','')",
APPORTIONMENT_BALANCE_TB    DECIMAL EXTERNAL "replace(replace(replace(replace(:APPORTIONMENT_BALANCE_TB,'$',''),'(','-'),')',''),',','')",
CY_ALLOTMENT_ORIG_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:CY_ALLOTMENT_ORIG_AMOUNT,'$',''),'(','-'),')',''),',','')",
CY_ALLOTMENT_BALANCE    DECIMAL EXTERNAL "replace(replace(replace(replace(:CY_ALLOTMENT_BALANCE,'$',''),'(','-'),')',''),',','')",
ALLOTMENT_BALANCE_TB    DECIMAL EXTERNAL "replace(replace(replace(replace(:ALLOTMENT_BALANCE_TB,'$',''),'(','-'),')',''),',','')",
CY_SUBALLOTMENT_ORIG_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:CY_SUBALLOTMENT_ORIG_AMOUNT,'$',''),'(','-'),')',''),',','')",
CY_SUBALLOTMENT_BALANCE    DECIMAL EXTERNAL "replace(replace(replace(replace(:CY_SUBALLOTMENT_BALANCE,'$',''),'(','-'),')',''),',','')",
SUBALLOTMENT_BALANCE_TB    DECIMAL EXTERNAL "replace(replace(replace(replace(:SUBALLOTMENT_BALANCE_TB,'$',''),'(','-'),')',''),',','')",
CY_ALLOCATION_ORIG_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:CY_ALLOCATION_ORIG_AMOUNT,'$',''),'(','-'),')',''),',','')",
COMMITMENT_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:COMMITMENT_AMOUNT,'$',''),'(','-'),')',''),',','')",
OBLIGATION_AMOUNT    DECIMAL EXTERNAL "replace(replace(replace(replace(:OBLIGATION_AMOUNT,'$',''),'(','-'),')',''),',','')",
ALLOCATION_BALANCE_TB    DECIMAL EXTERNAL "replace(replace(replace(replace(:ALLOCATION_BALANCE_TB,'$',''),'(','-'),')',''),',','')"
)
