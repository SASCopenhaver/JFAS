<!--- rebuild_snapshots.cfm --->

<cfswitch expression="#argSnapshotName#">
	<cfcase value="AAPP_CONTRACT_SNAPSHOT">
    	<cfstoredproc procedure="JFAS_SNAPSHOT_PKG.sp_updAAPP_CONTRACT_SNAPSHOT" returncode="no">
			<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="argAAPP_NUM" value="-1" null="no">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUser_ID" value="#session.userid#" null="no">
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUpdate_Notes" value="Rebuild from Admin" null="no">
		</cfstoredproc>
        
        <cfset local.CallFile = "admin_main.cfm">
        
	</cfcase>
    <cfdefaultcase></cfdefaultcase>
</cfswitch>

<cflocation url="#local.CallFile#">