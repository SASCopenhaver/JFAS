-- script for new Budget oversight role, including application/section access and AAPP tab access


-- USER_ROLE_ACCESS: controls access to JFAS sections by role

--add new BUDGET_ACCESS column
ALTER TABLE USER_ROLE_ACCESS
 ADD (BUDGET_ACCESS  NUMBER  DEFAULT 0  NOT NULL);

-- set default values forother ACCESS columns (had not been done before)
ALTER TABLE USER_ROLE_ACCESS MODIFY(USER_ROLE_ID  DEFAULT 0);
ALTER TABLE USER_ROLE_ACCESS MODIFY(AAPP_ACCESS  DEFAULT 0);
ALTER TABLE USER_ROLE_ACCESS MODIFY(REPORTS_ACCESS  DEFAULT 0);
ALTER TABLE USER_ROLE_ACCESS MODIFY(ADMIN_ACCESS  DEFAULT 0);

-- insert record for new Budget Oversight
Insert into USER_ROLE_ACCESS
   (USER_ROLE_ID, AAPP_ACCESS, REPORTS_ACCESS, ADMIN_ACCESS, UPDATE_USER_ID, 
    UPDATE_FUNCTION, UPDATE_TIME, BUDGET_ACCESS)
 Values
   (6, 1, 1, 0, 'sys', 'U', sysdate, 1);

--update row for Admin role (giving access to Budget Section)
Update USER_ROLE_ACCESS
set     BUDGET_ACCESS = 1
Where USER_ROLE_ID = 2;


----------------------------------------------------------
-- AAPP_SECTION_ROLE: controls access to AAPP section tabs and subtabs by role

-- Add appropriate records for access to tabs and subtabs (duplicate access from Nat Office role)
INSERT INTO AAPP_SECTION_ROLE ( AAPP_SECTION_ID, USER_ROLE_ID )
SELECT AAPP_SECTION_ID, 6 
 FROM AAPP_SECTION_ROLE 
 WHERE USER_ROLE_ID = 5;




COMMIT;
