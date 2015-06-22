
<cfcomponent displayname="splan_approp_allot">
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
    
    <cffunction name="f_getCurrentPY" access="remote" returntype="any" returnformat="plain" output="false" hint="Function returns Current Program Year (PY)">
        	<cfstoredproc procedure="SPLAN_PKG.sp_getCurrentPY" returncode="false">
            	
            	<cfprocresult name="spr_getCurrentPY" resultset="1">
            </cfstoredproc>
            
            <cfreturn spr_getCurrentPY>
    </cffunction>    
    <!--- ------ --->
    
    <cffunction name="f_getAmountsFutureSPlan" access="remote" returntype="any" returnformat="plain" output="false" hint="Function returns calculation to create future PY.">
    	<cfargument name="argUserID" type="string"  required="no">
        
        <cfstoredproc procedure="SPLAN_PKG.sp_getAmountsFutureSPlan" returncode="no">
        	<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argUserID#">
            <cfset var strucSplanFutureAmnt = structNew()>
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_CTR_FED_HQC" resultset="1"> <!--- CENTERS, USDA, NATIONAL HQ CONTRACTS  --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_GT"          resultset="2"> <!--- GRAND TOTAL --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_APPRP"   	resultset="3"> <!--- APPROPRIATION --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_BBR" 	   	resultset="4"> <!--- BALANCE BEFORE RESERVE --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_RES" 	   	resultset="5"> <!--- RESERVE --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_BAR" 	   	resultset="6"> <!--- BALANCE AFTER RESERVE --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getResPercent" 	   	resultset="7"> <!--- Reserve percentage --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getTransClosed"		resultset="8"> <!--- Are all transaction closed? --->
        </cfstoredproc>
        
         <cfreturn strucSplanFutureAmnt /> 
    </cffunction>
    <!--- ------ --->
	<cffunction name="f_saveFutureSplan" access="remote" returntype="any" returnformat="plain" output="false" 
    			hint="Function saves Allocated amounts and Notes for Future PY.">
          <cfargument name="argUserID" type="string"  required="no">
          <cfargument name="argSplan"  type="string"  required="no">
          
          <cfstoredproc procedure="SPLAN_PKG.sp_saveFutureSplan" returncode="no">
				<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argUserID#" >
                <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argSplan#" >
          </cfstoredproc>
	</cffunction>
    <!--- ------ --->
    <cffunction name="f_setNextYearSplan" access="remote" returntype="any" returnformat="plain" output="false" hint="Function sets initial transactions for the Next Year.">
          
          <cfargument name="argUserID" type="string"  required="yes">
          <cfargument name="argPY"     type="numeric" required="yes">
          <cfargument name="argSPNextPYRES" type="numeric" required="yes">
          <cfargument name="argSPNextPYBAR" type="numeric" required="yes">
          
          <cfstoredproc procedure="SPLAN_PKG.sp_setNextYrSplan" returncode="no">
          		<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argUserID#" >
                <cfprocparam cfsqltype="cf_sql_integer" value="#arguments.argPY#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#arguments.argSPNextPYRES#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#arguments.argSPNextPYBAR#">
                
                <cfprocresult name="spr_NextYrSplan" resultset="1">
          </cfstoredproc>

    	  <cfreturn spr_NextYrSplan /> 
            
    </cffunction>
    <!--- ------ --->
</cfcomponent>
