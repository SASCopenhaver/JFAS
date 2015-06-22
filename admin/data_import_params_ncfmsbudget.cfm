<cfsilent>
<!---
page: data_import_params.cfm

description: Edit data import parameters (NCFMS Budget Execution Balances)

revisions:
2015-02-23	mstein	Page created

--->

<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfset request.pageID = "2320" />
 
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->

<cfif isDefined("form.btnSave")> <!--- coming from form submittal --->
	<!--- database interaction / server-side validation --->
	<cfinvoke component="#application.paths.components#import_data" method="saveDataImportParams" importType="NCFMSBUDG" formData="#form#" >
	<cflocation url="#cgi.SCRIPT_NAME#?saved=1">
<cfelse>
	<cfinvoke component="#application.paths.components#import_data" method="getDataImportParams" importType="NCFMSBUDG" returnvariable="rstDataImportParams">
	<!--- set results as form fields --->
	<cfloop list="#rstDataImportParams.columnList#" index="fieldName">
		<cfset form[#fieldName#] = rstDataImportParams[#fieldName#]>
	</cfloop>
</cfif>
<cfdump var="#rstDataImportParams#"><br><br>
</cfsilent>




<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">
function verifyPassword(pwd)
{
if(pwd != '')
	{
	id = trim(id);
	newWin = window.open("checkpassword.cfm?pwd="+pwd, "verifyPassword",'status=no,toolbar=no,menubar=no,location=no,scrollbars=no,resizable=no,width=325,height=190');
	}
else
	alert('Please enter a password to be verified.');
}


function validateForm (s) {
	return true;
}

</script>
				
<h2>Data Import Parameters: NCFMS Budget Execution Balances</h2>

<!--- if validation errors exist, display them --->
<cfif isDefined("url.saved")>
	<div class="confirmList">
		<li>Your changes have been saved.&nbsp;&nbsp;Return to the <a href="<cfoutput>#application.paths.admin#</cfoutput>">Admin Section</a>.</li>
	</div><br />
</cfif>

	
	<!--- Start Form --->
	<form name="frmEditUser"  action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" onSubmit="return validateForm(this);">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Data Import Parameters">
	<cfoutput>
	<tr valign="top">
		<td align="right" width="200">
			<label for="idFTPsite">FTP Site</label>
		</td>
		<td width="*">
			<input type="text" id="idFTPsite" name="txtFTPsite" value="#form.ftpSite#" size="50" maxlength="150" tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td align="right">
			<label for="idFTPRemoteDir">FTP Directory</label>
		</td>
		<td>
			<input type="text" id="idFTPRemoteDir" name="txtFTPRemoteDir" value="#form.ftpRemoteDir#" size="50" maxlength="100" tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td align="right">
			<label for="idFTPport">FTP Port</label>
		</td>
		<td>
			<input type="text" id="idFTPport" name="txtFTPport" value="#form.ftpPort#" size="8" maxlength="4" tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td align="right">
			<label for="idFTPStype">FTP Type</label>
		</td>
		<td>
			<input type="text" id="idFTPStype" name="txtFTPStype" value="#form.ftpsType#" size="30" maxlength="30" tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td align="right">
			<label for="idFTPuid">FTP Username</label>
		</td>
		<td>
			<input type="text" id="idFTPuid" name="txtFTPuid" value="#form.ftpUID#" size="20" maxlength="20" tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td align="right">
			<label for="idFTPpwd">FTP Password</label>
		</td>
		<td>
			<input type="password" id="idFTPpwd" name="txtFTPpwd" size="20" maxlength="50" tabindex="#request.nextTabIndex#">
			&nbsp; (leave blank to keep existing password)
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>	
	<tr>
		<td align="right">
			<label for="idFTPremoteFile">FTP Target File</label>
		</td>
		<td>
			<input type="text" id="idFTPremoteFile" name="txtFTPremoteFile" value="#form.ftpRemoteFile#" size="50" maxlength="100" tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td align="right">
			<label for="idJFASShareDir">JFAS Shared Directory</label>
		</td>
		<td>
			<input type="text" id="idJFASShareDir" name="txtJFASShareDir" value="#form.jfasShareDir#" size="75" maxlength="150" tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td align="right">
			<label for="idJFASShareFile">JFAS Shared File</label>
		</td>
		<td>
			<input type="text" id="idJFASShareFile" name="txtJFASShareFile" value="#form.jfasShareFile#" size="75" maxlength="150" tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	</cfoutput>
	</table>
	
	<cfoutput>
	<div class="buttons">
		<input name="btnSave" type="Submit" value="Save" tabindex="#request.nextTabIndex#">
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input name="btnReset" type="reset" value="Reset" tabindex="#request.nextTabIndex#">
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input name="btnCancel" type="button" value="Cancel" 
			onclick="javascript:window.location='<cfoutput>#application.paths.admin#</cfoutput>'" 
			tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</div>
	</cfoutput>
	</form>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />
