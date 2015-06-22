LOAD DATA
truncate
INTO TABLE JFAS.vehicle_load
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"'
trailing nullcols

( 
Center_name char "rtrim(:center_name)",
REGION 	filler,
TAG  	CHAR   "rtrim(:TAG)",
MAKE 	CHAR   "rtrim(:MAKE )",
MODEL 	CHAR   "rtrim(:MODEL)",
LSE_START DATE(11) "mm/dd/yyyy",
MO_LSE_RATE 	integer external,
PURPOSE_USE 	CHAR   "rtrim(:PURPOSE_USE)",
VEH_TYPE 	CHAR   "rtrim(:VEH_TYPE)",
MO_MILAGE 	DECIMAL EXTERNAL,
MODEL_YEAR 	integer external,
FUEL_TYPE 	CHAR   "rtrim(:FUEL_TYPE)")
    
