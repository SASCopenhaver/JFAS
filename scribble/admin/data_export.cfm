<cfsilent>
<!---
page: data_import.cfm

description: data import template

revisions:
abai 12/18/2006 Change dbusername, dbpassword, dbhostname to request variable.
abai 01/12/2007 Change it for defect #105
abai 05/24/2007 Revised for pageID
--->

<cfset request.pageID="2701">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - Data Export">
<cfset request.pageTitleDisplay = "JFAS System Administration">

</cfsilent>

<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">

<script language="javascript">
function ValidateForm(form){
  
  	form.btnSubmit.value = 'Please wait a minute for pop up - Exporting JFAS Data.';
  	form.btnSubmit.disabled = true;	
  	setTimeout('setCancelToDone()', 30000)
 
  	return true
 	
}

function setCancelToDone()
{
  document.frmDataExport.btnCancel.value = 'Done';
}

</script>
<p></p>

<h2>Data Export: JFAS to FilePro</h2>

<form name="frmDataExport" action="jfaszip.cfm" onSubmit="return ValidateForm(this);">
		
	<div>
	Click the Generate Export button below to download a current set of export files from the JFAS system. NOTE: This process may take a few minutes.<br /><br />
	</div>
	<div class="buttons">
	<input name="btnSubmit" type="submit" value="Generate Export" />
	<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='admin_main.cfm'" />
	</div>
</form>

<!--- include main footer file --->  
<cfinclude template="#application.paths.includes#footer.cfm">