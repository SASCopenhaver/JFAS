ALTER TABLE SYSTEM_SETTING RENAME TO ZZZ_SYSTEM_SETTING;
ALTER TABLE USER_JFAS RENAME TO ZZZ_USER_JFAS;
ALTER TABLE USER_LOGIN RENAME TO ZZZ_USER_LOGIN;
ALTER TABLE USER_PREFERENCE RENAME TO ZZZ_USER_PREFERENCE;
ALTER TABLE IMPORT_PARAM RENAME TO ZZZ_IMPORT_PARAM;



ALTER TABLE ZZZ_TEST_VAL RENAME TO Z_TEST_VAL;







ALTER VIEW EQUIPMENT_DATASET_VIEW  COMPILE;