DELETE from SYSTEM_SETTING
WHERE	SYSTEM_SETTING_CODE = 'spend_plan_reserve_percentage';

Insert into SYSTEM_SETTING
   (SYSTEM_SETTING_CODE, VALUE, DATA_TYPE, LOCKED, REQUIRED, 
    SORT_ORDER, SYSTEM_SETTING_DESC, UPDATE_USER_ID, UPDATE_FUNCTION, UPDATE_TIME, 
    ADMIN_DISPLAY)
 Values
   ('spend_plan_reserve_percentage', '0.500', 'rate', 0, 1, 
    501, 'Spend Plan Reserve Percentage', 'mstein', 'I', sysdate,1);
COMMIT;
