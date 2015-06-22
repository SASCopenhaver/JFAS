
<cfcomponent displayname="approp_allot">
<!---<cfcomponent displayname="splan_approp_allot">--->
    <!--- ------ --->
    
    <cffunction name="f_getAppropAllot" access="remote" returntype="any" returnformat="plain" output="no" hint="Retrieves Budget Appropriation and Allotments amounts">

		    <cfargument name="arg_PY"     type="numeric" required="no">
    		<cfargument name="arg_UserID" type="string"  required="no">

    		<cfstoredproc procedure="APPROP_ALLOT_PKG.sp_getApprAllot" returncode="no">
            	<cfprocparam cfsqltype="cf_sql_numeric" value="#arguments.arg_PY#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.arg_UserID#">

            	<cfset var strucAppropAllot = structNew()>
                
                <cfprocresult name="strucAppropAllot.spr_getListOfPY" 	   resultset="1"> 
                <cfprocresult name="strucAppropAllot.spr_getAppropriation" resultset="2">
                <cfprocresult name="strucAppropAllot.spr_getAllotment" 	   resultset="3">
                <cfprocresult name="strucAppropAllot.spr_getDateNCFMSloaded"  resultset="4">
                
            </cfstoredproc>

            <cfreturn strucAppropAllot />
    </cffunction>
    <!--- ------ --->
    
	<cffunction name="f_saveAppropAllot" access="remote" returntype="any" returnformat="plain" output="no">
			<cfargument name="argPY" 		 type="numeric" required="no">
            <cfargument name="argUserID" 	 type="string"  required="no">
            <cfargument name="argApprUpdSQL" type="string"  required="no">
            <cfargument name="argAlltUpdSQL" type="string"  required="no">
            
            <cfstoredproc procedure="APPROP_ALLOT_PKG.sp_saveAppropAllot" returncode="no">
            	<cfprocparam cfsqltype="cf_sql_numeric" value="#arguments.argPY#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argUserID#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argApprUpdSQL#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argAlltUpdSQL#">
            </cfstoredproc>

	</cffunction>
    <!--- ------ --->
    
    <cffunction name="getAppropriation" access="remote" returntype="any" returnformat="plain" output="no" 
    			hint="Function returns Appropriation data. Arguments are optional.">
             		
                    <cfargument name="fundCat" type="string" default="ALL" >
                	<cfargument name="PY" 	   type="numeric" default="0">
                
                <cfstoredproc procedure="APPROP_ALLOT_PKG.sp_getAppropriation" returncode="no">
                	<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.fundCat#" >
                    <cfprocparam cfsqltype="cf_sql_numeric" value="#arguments.PY#"      >
                    
                    <cfprocresult name="spr_getAppropriation" resultset="1">
                </cfstoredproc>
                
                <cfreturn spr_getAppropriation />    
    
    </cffunction>
    <!--- ------ --->
</cfcomponent>
