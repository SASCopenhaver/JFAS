<!---
page: updAAPP_CONTRACT_SNAPSHOT.cfm

description:	Table "AAPP_CONTRACT_SNAPSHOT" updated/refreshed from Scheduled Task
revisions:
2014-06-05	sasurikov	Page created
--->


        <cfstoredproc procedure="JFAS_SNAPSHOT_PKG.sp_updAAPP_CONTRACT_SNAPSHOT" returncode="no">
            <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="argAAPP_NUM" value="-1" null="no">
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUser_ID" value="scheduled_task" null="no">
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUpdate_Notes" value="Updated from Scheduled Task" null="no">
        </cfstoredproc>