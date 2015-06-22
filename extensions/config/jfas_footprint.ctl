LOAD DATA
truncate
INTO TABLE JFAS.footprint_load
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"'
trailing nullcols

(     
FY   INTEGER EXTERNAL,
RCC_FUND   CHAR   "rtrim(:RCC_FUND)",
IAC   CHAR   "rtrim(:IAC)",
RCC_ORG   CHAR   "rtrim(:RCC_ORG)",
DT   CHAR   "rtrim(:DT)",
DOC_NUM   CHAR   "rtrim(:DOC_NUM)",
OBJ_CLASS   CHAR   "rtrim(:OBJ_CLASS)",
OBLIG   DECIMAL EXTERNAL,
PAYMENT   DECIMAL EXTERNAL,
COST   DECIMAL EXTERNAL,
EIN   CHAR   "rtrim(:EIN)",
VENDOR   CHAR   "rtrim(:VENDOR)",
STATE   CHAR   "rtrim(:STATE)")
