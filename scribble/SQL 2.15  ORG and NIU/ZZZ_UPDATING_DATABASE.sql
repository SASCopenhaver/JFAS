create or replace PACKAGE ZZZ_UPDATING_DATABASE 
AS 
--==============================================================================
PROCEDURE sp_RenameTbls_AddPrefix;
--==============================================================================
PROCEDURE sp_RenameTbls_RemovePrefix;
--==============================================================================
PROCEDURE sp_RecompileViews;
--==============================================================================
END ZZZ_UPDATING_DATABASE;

/*
DECLARE
BEGIN
-- 1:
-- ZZZ_UPDATING_DATABASE.sp_RenameTbls_AddPrefix; --run BEFORE database update.
---
-- 2:
-- ZZZ_UPDATING_DATABASE.sp_RenameTbls_RemovePrefix -- run AFTER database update.
---
-- 3:
-- ZZZ_UPDATING_DATABASE.sp_RecompileViews;
END;
*/


/


create or replace PACKAGE BODY ZZZ_UPDATING_DATABASE AS
--==============================================================================

PROCEDURE sp_RenameTbls_AddPrefix
IS 
v_Prefix VARCHAR(10) DEFAULT 'ZZZ_';
BEGIN

    FOR t IN ( SELECT table_name
                 FROM USER_TABLES
                WHERE table_name IN ('SYSTEM_SETTING'
                                    ,'USER_JFAS'
                                    ,'USER_LOGIN'
                                    ,'USER_PREFERENCE'
                                    ,'IMPORT_PARAM')
             )
    LOOP
       EXECUTE IMMEDIATE 'ALTER TABLE '||t.table_name||' RENAME TO '||v_Prefix||t.table_name;
    END LOOP;
    
END sp_RenameTbls_AddPrefix;
--==============================================================================

PROCEDURE sp_RenameTbls_RemovePrefix
IS
v_Prefix VARCHAR(10) := 'ZZZ_';
v_RenamedTbl VARCHAR(50);
BEGIN
    FOR t IN ( SELECT table_name
                 FROM USER_TABLES
                WHERE table_name IN (v_Prefix||'SYSTEM_SETTING'
                                    ,v_Prefix||'USER_JFAS'
                                    ,v_Prefix||'USER_LOGIN'
                                    ,v_Prefix||'USER_PREFERENCE'
                                    ,v_Prefix||'IMPORT_PARAM')
             )
    LOOP
       SELECT Substr(t.table_name,5)
         INTO v_RenamedTbl
         FROM DUAL;
       
       EXECUTE IMMEDIATE 'ALTER TABLE '||t.table_name||' RENAME TO '||v_RenamedTbl;
    END LOOP;
END sp_RenameTbls_RemovePrefix;
--==============================================================================

PROCEDURE sp_RecompileViews
IS
BEGIN
    FOR v IN (SELECT OBJECT_NAME
                FROM SYS.USER_OBJECTS
               WHERE object_type = 'VIEW')
    LOOP
      EXECUTE IMMEDIATE 'ALTER VIEW '||v.OBJECT_NAME||' COMPILE';
    END LOOP;

END sp_RecompileViews;
--==============================================================================
END ZZZ_UPDATING_DATABASE;