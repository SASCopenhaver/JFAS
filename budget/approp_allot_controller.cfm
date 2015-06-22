<!---approp_allot_controller.cfm--->
<cfif NOT isDefined("URL.actionMode")>
	<cfset actionMode = "Init">
</cfif>

<cfswitch expression="#actionMode#">
	<!--- ............... --->
    <cfcase value="Init">
    	<cfset tPY = application.oSplan.getSplanPY() />
        <cfset nCurrentPY = tPY.aRet[1].PY />
		<cfset session.selectedPY = nCurrentPY /> 
        <cfset session.anyChanges = "CHANGES_NO">
        <cflocation url="approp_allot.cfm?actionMode=Init">
    </cfcase>
    <!--- ............... --->
    <cfcase value="anotherPY">
       	<cfset session.selectedPY = #selectedPY# />
        <cfset session.anyChanges = "CHANGES_NO">
        <cflocation url="approp_allot.cfm?actionMode=anotherPY">
    </cfcase>
	<!--- ............... --->

    <cfcase value="saveApprAllt">
    	<cfset session.selectedPY = #URL.urlPY# />
        <cfset session.anyChanges = "CHANGES_YES">
        <cfset strucAppropAllot = application.oapprop_allot.f_saveAppropAllot(argPY:"#URL.urlPY#", 
																			  argUserID:"#urlUserID#", 
																			  argApprUpdSQL:"#urlApprUpdSQL#",
																			  argAlltUpdSQL:"#urlAlltUpdSQL#")>
        <cflocation url="approp_allot.cfm?actionMode=anotherPY">
    </cfcase>
    <!--- ............... --->

    <cfcase value="getFormattedExcelReport">
    	<cfset session.anyChanges = "CHANGES_NO">
        <cfset session.selectedPY = #selectedPY# />
    	<cflocation url="approp_allot_excel.cfm?">
    </cfcase>
    <!--- ............... --->

    <cfcase value="getRawApprop">
    	<cfset session.anyChanges = "CHANGES_NO">
        <cfset session.selectedPY = #selectedPY# />
    	<cflocation url="approp_excel_raw.cfm?">
    </cfcase>
    <!--- ............... --->
    
    <cfcase value="getRawAllot">
    	<cfset session.anyChanges = "CHANGES_NO">
        <cfset session.selectedPY = #selectedPY# />
    	<cflocation url="allot_excel_raw.cfm?">
    </cfcase>
    <!--- ............... --->
    
	<cfdefaultcase>
    	Just Checking... Something does not look right...
    </cfdefaultcase>
</cfswitch>





