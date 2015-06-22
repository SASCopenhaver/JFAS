--  SQL Loader Control File Automaticlly Generated on Auguest  24, 2007 15:58:18
--  for table FOOTPRINT_XACTN_LOAD created by JFAS
LOAD DATA
truncate
INTO TABLE FOOTPRINT_XACTN_LOAD
FIELDS TERMINATED BY X'03' OPTIONALLY ENCLOSED BY '"'
(
FY   position(1:4),
 RCC_FUND   position(6:9) ,
IAC   position(11:13) ,
 RCC_ORG   position (15:18) ,
          DT   position (20:21) ,
          DOC_NUM   position (23:32) ,
          OBJ_CLASS   position(34:37) ,
          XACTN_CODE  position(39:42) ,
          INVOICE_NUM  position (44:73) ,
          DATE_XACTN  position (75:82) DATE "yyyymmdd",
          AMOUNT  position (84:100) ,
          EIN  position (102:113) ,
          VENDOR  position (115:169) ,
          STATE  position (171:172) 
)
