<!---splan_future_controller.cfm--->
<cfif NOT isDefined("URL.actionMode")>
	<cfset actionMode = "INIT">
</cfif>
<cfswitch expression="#actionMode#">
    <!--- Initial process --->
    <cfcase value="INIT">
		<cfset session.anyChanges = "CHANGES_NO">
        <cflocation url="splan_future.cfm?actionMode=INIT">
    </cfcase>
	<!--- Saving Future Spend Plan (onClick btnSave) --->
    <cfcase value="saveFutureSplan">
 		<!---
        <cfloop index="indSplan"
        	    list="#urlSplan#"   
                delimiters="^">
             <cfset updateString = #indSplan#&"^">
             <cfset saveFutureSplan = application.ospend_plan.f_saveFutureSplan(argUserID:"#urlUserID#", argSplan:"#updateString#")>
        </cfloop>
        --->
        <cfset session.anyChanges = "CHANGES_YES">
        <cflocation url="splan_future.cfm">
        
    </cfcase>
    
    <!--- Calling procedure to create Next Year Spend Plan --->
    <cfcase value="setNextYearSplan">
 
  
  	    <cfset session.anyChanges = "CHANGES_YES">
        <cfset setNextYearSplan = application.ospend_plan.f_setNextYearSplan(argUserID:"#urlUserID#",
																			 argPY:"#argPY#",
																			 argSPNextPYRES:"#argSPNextPYRES#",
																			 argSPNextPYBAR:"#argSPNextPYBAR#")>
         <!---TEST: <cfdump var="#setNextYearSplan#"><cfabort>--->
                                                                             
         <!--- Going back to the screen "Spend Plan" --->
		<cfset session.ouser.DeleteMySplanDisplaySetting( session.userid, "PERM" )>
		<cfset session.ouser.CreateDefaultSplanDisplaySetting ()>
		
        <cflocation url="splan_main.cfm">

    </cfcase>
    
    <!--- If variable "actionMode" would not be defined, or if it would not have any value ... --->
	<cfdefaultcase>
    	Just Checking... Something does not look right...  Variable "actionMode" does not have any value. <br />Call developers.
    </cfdefaultcase>
   
    
    
    
</cfswitch>