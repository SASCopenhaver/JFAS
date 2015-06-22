<!---
page: ncfms_FileTransfer_budget.cfm

description:	scheduled task to NCFMS budget execution data into JFAS

revisions:

2015-02-23	mstein	Page created

Test page: http://devetareports.doleta.gov/cfdocs/grantee_prod/jfas/extensions/scheduledevents/ncfms_DataImport_budget.cfm?isbackground=true

--->


<cfset request.pageID = "0" />
<cfsetting requesttimeout="900">

<cfset success = 1>
<cfset lstStatusMessage = "">
<cfset lstErrorMessage = "">
<cfset dataCleanMonths = 24>

<!--- get file params --->
<cfinvoke component="#application.paths.components#file_transfer" method="getImportParams" importType="NCFMSBUDG" returnvariable="rstNCFMSParams">

<cfset jfasSysEmail = application.outility.getSystemSetting(systemSettingCode="jfas_system_email")>
<cfset emailSuccess = application.outility.getSystemSetting(systemSettingCode="dataImport_success_email")>
<cfset emailFail = application.outility.getSystemSetting(systemSettingCode="dataImport_fail_email")>
<cfset jfasTechPOC = application.outility.getSystemSetting(systemSettingCode="technical_poc_email")>

<!--- BEGIN : Status of file on shared file storage --->
<!--- Check for file in shared storage folder --->
<cfif fileExists(#rstNCFMSParams.jfas_share_file#)>
	<cfoutput>File #rstNCFMSParams.jfas_share_file# found.</cfoutput><br>
<cfelse>
	<cfset lstErrorMessage = listAppend(lstErrorMessage,"File #rstNCFMSParams.jfas_share_file# NOT found on JFAS server.","~~")>
	<cfset success = 0>
</cfif>
<!--- END: status of file --->


<cfif success>
	<!--- BEGIN: Load file into JFAS using SQL Loader --->
	<cfinvoke component="#application.paths.components#importAction" method="importAction" dsn='#request.dsn#'
				  tableName="budget_ncfms_load"
				  dataLoadPath="#application.paths.upload#"
				  fileName="jfas_NCFMSBUDG"
				  fullFilePath="#rstNCFMSParams.jfas_share_file#"
				  returnvariable="lstSQLLoaderMessage">

	<cfif lstSQLLoaderMessage eq "">
		SQL Loader executed successfully.<br>
	<cfelse>
		<cfset lstErrorMessage = listAppend(lstErrorMessage,"Error occured with SQL Loader: #lstSQLLoaderMessage#.","~~")>
		<cfset success = 0>
	</cfif>
	<!--- END: load file with SQL Loader --->
</cfif>


<!--- BEGIN: Validate / Clean Data --->
<cfif success>
	<cfinvoke component="#application.paths.components#import_data_ncfms" method="validateNCFMSBudgetLoad" returnvariable="stcValidateNCFMSBudgetLoad">
	<cfif stcValidateNCFMSBudgetLoad.lstWarningMessages eq "">
		<cfset lstStatusMessage = listAppend(lstStatusMessage,"No minor warnings detected while validating import.","~~")>
	<cfelse>
		<cfset lstStatusMessage = listAppend(lstStatusMessage,"The following minor warnings were found while validating import:<br> - #stcValidateNCFMSBudgetLoad.lstWarningMessages#","~~")>
	</cfif>
	<cfif NOT stcValidateNCFMSBudgetLoad.success>
		<!--- failed validation --->
		<cfset lstErrorMessage = listAppend(lstErrorMessage,"Import file failed validation for the following reasons:<br> - #stcValidateNCFMSBudgetLoad.lstErrorMessages#","~~")>
		<cfset success = 0>
	</cfif>
</cfif>
<!--- END: Validate / Clean Data --->



<!--- BEGIN: Import Data --->
<cfif success>
	<cfinvoke component="#application.paths.components#import_data_ncfms" method="NCFMSBudgetImport" returnvariable="stcInsertNCFMSBudget">
	<cfif stcInsertNCFMSBudget.success>
		<cfset lstStatusMessage = listAppend(lstStatusMessage,stcInsertNCFMSBudget.lstImportMessage,"~~")>
	<cfelse>
		<!--- failed validation --->
		<cfset lstErrorMessage = listAppend(lstErrorMessage,"Import failed.","~~")>
		<cfset success = 0>
	</cfif>
</cfif>
<!--- END: Import Data --->


<!--- log import results --->
<cfif success>
	<cfset logNotes = lstStatusMessage>
<cfelse>
	<cfset logNotes = lstErrorMessage>
</cfif>
<cfinvoke component="#application.paths.components#import_data" method="import_tracking"
	import_type = "NCFMSBUDG"
	user_id = "sys"
	success = "#success#"
	note = "#logNotes#">

<!--- clean out old log data --->
<cfinvoke component="#application.paths.components#import_data" method="cleanImportHistory" importType="NCFMSBUDG" monthsRetain="#dataCleanMonths#">


<cfsavecontent variable="txtDataImportResults">
	<cfoutput>
	Details:<br>
	<cfloop list="#lstStatusMessage#" index="msg" delimiters="~~">
	 - #msg#<br>
	</cfloop>
	<br>
	<cfif lstErrorMessage neq "">
		Errors:
		<cfloop list="#lstErrorMessage#" index="msg" delimiters="~~">
		 - #msg#<br>
		</cfloop>
	<cfelse>
		No critical errors occurred.
	</cfif>
	</cfoutput>
</cfsavecontent>

<br>
<cfoutput>#txtDataImportResults#</cfoutput>
<br>


<!--- send email --->
<cfif success>
	<cfmail from="#jfasSysEmail#"
		to="#emailSuccess#"
		cc="#jfasSysEmail#"
		subject="NCFMS Budget Execution Data Import :: SUCCESS :: #dateformat(now(), "yyyy-mm-dd")# #iif(application.cfEnv neq 'prod',DE(' (' & Evaluate('application.cfEnvDesc') & ')'), DE(''))#" type="html">
	#txtDataImportResults#
	</cfmail>

<cfelse>
	<cfmail from="#jfasSysEmail#"
		to="#emailFail#"
		cc="#jfasSysEmail#;#jfasTechPOC#"
		subject="NCFMS Budget Execution Data Import :: FAILURE :: #dateformat(now(), "yyyy-mm-dd")# #iif(application.cfEnv neq 'prod',DE(' (' & Evaluate('application.cfEnvDesc') & ')'), DE(''))#" type="html">
	#txtDataImportResults#
	</cfmail>

</cfif>



