<cfsilent>
<!---
page: data_import_mnlxactn.cfm

description: data import form for manual transaction upload

revisions:
2010-08-04	mstein	page created
--->


<cfset request.pageID="2306">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - Data Import">
<cfset request.pageTitleDisplay = "JFAS System Administration">

<cfsetting requestTimeout = "1800">

<cfparam name="form.hidDataType" default="#url.datatype#">
<cfparam name="form.hidMode" default="#url.mode#">
<cfparam name="Attributes.result" default="">
<cfparam name="lstMessage" default="">
<cfparam name="tableName" default="">
<cfparam name="status" default="">
<cfparam name="result" default="0">

<cfinvoke component="#application.paths.components#lookup" method="getImportTypes" importType="#form.hidDataType#" returnvariable="rstImportType">
<cfset dateRange_start = application.outility.getSystemSetting(systemSettingCode="mnlxactn_start")>
<cfset dateRange_end = application.outility.getSystemSetting(systemSettingCode="mnlxactn_end")>

<cfset importDesc = #rstImportType.importTypeDesc# />
<cfset tableName="FOOTPRINT_MNLXACTN_LOAD">

</cfsilent>

<cfif isDefined("form.btnSubmit")>

	<!--- call component to upload file and import data--->
	<cfinvoke component="#application.paths.components#importAction" method="importAction"
			  tableName='#tableName#'
			  dsn='#request.dsn#'
			  dataLoadPath='#application.paths.upload#'
			  formName="filDataImport"
			  fileName='jfas_#hidDataType#'
			  returnvariable="lstSQLLoaderMessage">


	<!--- get upload result --->
	 <cfif lstSQLLoaderMessage eq ""> <!--- no errors ocurred from sql loader --->
		<cfinvoke component="#application.paths.components#import_data_mnlxactn" method="cleanMnlXactn">
		<cfinvoke component="#application.paths.components#import_data_mnlxactn" method="validateMnlXactn" returnvariable="lstValidateMessages">


		<cfif lstValidateMessages eq ""> <!--- validation did not fail --->
			<!--- insert transaction data in table, roll up to footprint --->
			<cfinvoke component="#application.paths.components#import_data_mnlxactn" method="insertMnlXactn" xactntype="#form.radTransType#" returnvariable="lstInfoMessages">
			<!--- run AAPP matching --->
			<cfinvoke component="#application.paths.components#import_data" method="footprintAAPPmatching" returnvariable="lstMatchingMessages">
			<cfset form.hidMode = "success">
			<cfset resultNotes = left(lstInfoMessages & "~" & lstMatchingMessages,4000)>
			<cfinvoke component="#application.paths.components#import_data"
				method="import_tracking"
				import_type="MNLXACTN"
				success="1"
				userID="#session.userID#"
				note="#resultNotes#">

		<cfelse> <!--- validation failed --->
			<cfset form.hidMode = "error_level_2">
			<cfinvoke component="#application.paths.components#import_data"
				method="import_tracking"
				import_type="MNLXACTN"
				success="0"
				userID="#session.userID#"
				errorType="Data Validation Error">
		</cfif>

	<cfelse> <!--- sql loader failed --->
		<cfset form.hidMode = "error_level_1">
		<cfinvoke component="#application.paths.components#import_data"
				method="import_tracking"
				import_type="MNLXACTN"
				success="0"
				userID="#session.userID#"
				errorType="SQL Loader Error">
	</cfif>


</cfif>

<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">

<cfoutput>
<script language="javascript">
function ValidateForm(form){
  strErrors= '';

  if (form.filDataImport.value == '')
  		strErrors = strErrors + '   - The upload file must be provided.\n';
  else{
  	EXPextension = form.filDataImport.value.substring(form.filDataImport.value.length-4, form.filDataImport.value.length);
  	EXPextension = EXPextension.toUpperCase();
  	//alert(EXPextension);
  	if (EXPextension != '' && EXPextension != '.TXT' && EXPextension != '.CSV'  && EXPextension != '.DAT')
		strErrors = strErrors + '   - The upload file must be text format (.txt or .csv, or .dat).\n';
  }

  if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before uploading.\n\n' + strErrors + '\n');
		return false
		}
  else {
  	form.btnSubmit.value = 'Please wait - Uploading File.';
  	form.btnClear.disabled = true;
  	form.btnCancel.disabled = true;
  	return true
  }

}
</script>

<p></p>

<h2>Data Import: #importDesc#</h2>
</cfoutput>


<cfswitch expression="#form.hidMode#">
<cfcase value="upload">
	<cfoutput>
	<div>
	To import the transaction spreadsheet, please follow the steps below:
	<ul style="margin-top:5px;">
		<li>Open up the original Excel spreadsheet (xls) file. If you need to make any changes, be sure to save the file before proceeding.</li>
		<li>Open the tab that contains the data that you would like to import
		(note: spreadsheet may have multiple tabs).</li>
		<li>Remove all rows at the top of the spreadsheet that do NOT contain data. This includes column headings.</li>
		<li>From the File menu, click "Save As..."</li>
		<li>Once on the "Save As" dialog box, find the "Save as type..." drop-down list and select "CSV (Comma delimited) (*.cvs)".</li>
		<li>Click "Save".</li>
			<ul>
				<li>If prompted about multiple sheets not being supported, click "OK".</li>
				<li>If prompted about certain features not being supported in CSV format, click "Yes".</li>
			</ul>
		<li style="margin-top:5px;">Close the file in Excel. If prompted to save changes, click "No". </li>
		<li>Using the "Browse..." button below, locate the newly generated CSV file on your local or network drive.</li>
		<li>Identify the transaction type.</li>
		<li>Click the "Import File" button.</li>
	</ul>

	NOTE: This process will delete all transactions in JFAS with dates between <b>#dateformat(dateRange_start, "mm/dd/yyyy")#</b> and
	<b>#dateformat(dateRange_end, "mm/dd/yyyy")#</b>, and replace them with the contents of this uploaded file. This date range can be modified
	in the System Settings admin page.<br /><br />

	NOTE: This process may take a few minutes.<br /><br />
	</div>
	<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Upload Data File">

	<form name="frmDataImport" action="#cgi.SCRIPT_NAME#?datatype=#url.datatype#&mode=#url.mode#&requesttimeout=5000" method="post" enctype="multipart/form-data" onSubmit="return ValidateForm(this);">
	</cfoutput>
	<tr>
		<td align="right" width="25%"><label for="idDataImport">File to Import:</label>&nbsp;&nbsp;&nbsp;</td>
		<td><input type="file" name="filDataImport" id="idDataImport" /></td>
	</tr>
	<tr valign="top">
		<td align="right"><label for="idTransType_OBL">Transaction Type:</label>&nbsp;&nbsp;&nbsp;</td>
		<td>
			<input type="radio" name="radTransType" value="OBL" id="idTransType_OBL" checked="checked" />
			<label for="idTransType_OBL">Obligation</label>
			<br />
			<input type="radio" name="radTransType" value="PAY" id="idTransType_PAY" disabled />
			<label for="idTransType_PAY">Payment</label>
			<br />
			<input type="radio" name="radTransType" value="CST" id="idTransType_CST" disabled />
			<label for="idTransType_CST">Cost</label>
			<br />
		</td>
	</tr>

	</table>
	<div class="buttons">
	<cfoutput>
	<input type="hidden" name="hidDataType" value="#form.hidDataType#">
	<input type="hidden" name="hidMode" value="#form.hidMode#">
	</cfoutput>
	<input name="btnSubmit" type="submit" value="Import File" /><!--- onClick="this.value='Please wait - uploading file'" --->
	<input name="btnClear" type="reset" value="Reset" />
	<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='admin_main.cfm'" />
	</div>
	</form>

</cfcase> <!--- mode = "upload" --->

<cfcase value="error_level_1"> <!--- sql loader failed --->
	<div>
	<cfoutput>
	The following errors occured when trying to import the #importDesc# data file:
	</div>

	<p></p>
	<div class="errorList">
	<table>
		<tr>
			<td>
			#lstSQLLoaderMessage#
			</td>
		</tr>
	</table>

	</div>

	<p></p>
	<div>
	Return to <a href="#application.paths.admin#">Admin</a>.
	</cfoutput>
	</div>
</cfcase>


<cfcase value="error_level_2"> <!--- data validation failed --->
	<cfoutput>
	<div>
	The following errors occured when trying to import the #importDesc# data file:
	</div>

	<p></p>
	<div class="errorList">
	<cfloop list="#lstValidateMessages#" index="errorItem" delimiters="~">
		#errorItem#<br>
	</cfloop>
	</div>
	<p></p>

	<div>
	Return to <a href="#application.paths.admin#">Admin</a>.
	</div>
	</cfoutput>
</cfcase>


<cfcase value="success">
	<br />
	<div>
	<cfoutput>
	<b>Transaction Import Process:</b><br />
	<cfloop list="#lstInfoMessages#" index="listItem" delimiters="~">
		#listItem#<br>
	</cfloop>
	<br />
	The #importDesc# data import process was successful.<br><br>

	<br />
	<b>AAPP Association Process:</b><br />
	<cfloop list="#lstMatchingMessages#" index="listItem" delimiters="~">
		#listItem#<br>
	</cfloop>

	<br />
	View and Edit the <a href="data_footprint_match.cfm">Discrepancy Listing</a> page<br /><br />


	Return to <a href="#application.paths.admin#">Admin</a>.

	</cfoutput>
	</div>
</cfcase>

</cfswitch>

<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">