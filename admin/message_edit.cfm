<cfsilent>
<!---
page: message_edit.cfm

description: allows user to add / edit user alert message

revisions:
2014-11-15	mstein	page created
--->
<cfset request.pageID = "2630" />
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfset messageType="WElCOME">

<!--- if form has been submitted --->
<cfif isDefined("form.btnSubmit")>
	<cfinvoke component="#application.paths.components#user" method="saveMessageAlert" formData="#form#">
	<cflocation url="#cgi.SCRIPT_NAME#?&saved=1">
<cfelse> <!--- first time to the form --->
	<cfinvoke component="#application.paths.components#user" method="getMessageAlert" messageType="#messageType#" returnvariable="qryMessageAlert">
	<cfset form.radStatus = qryMessageAlert.status>
	<cfset form.txtMessageText = qryMessageAlert.messageText>
	<cfset form.hidMessageType = qryMessageAlert.messageType>
</cfif>
	
</cfsilent>


<!--- include header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">

	
function formValidation()
{
var strErrors = ''
trimFormTextFields(document.frmMessage);

// can't save blank message with status of "on"
if((document.frmMessage.txtMessageText.value == '') && (document.frmMessage.radStatus[0].checked))
	strErrors = strErrors + ' - Message text is required when the status is set to "On".\n';

if (strErrors == '') {
	// re-enable textarea before form submission
	document.frmMessage.txtMessageText.disabled = 0;
	return true;
	}
else {
	alert('The following problems have occurred. Please fix these errors to continue.\n\n' + strErrors + '\n');
	return false;
	}
}

function setTextboxEdit()
{
// determine enabled/disabled status of text area
if (document.frmMessage.radStatus[0].checked)
	document.frmMessage.txtMessageText.disabled = 0;
else
	document.frmMessage.txtMessageText.disabled = 1;
}

</script>

<cfoutput>

<h2>User Alert Messages</h2>
	
	<cfif isDefined("url.saved")>
		<div class="confirmList">
		<cfoutput><li>Information saved successfully. &nbsp;Return to the <a href="<cfoutput>#application.paths.admin#</cfoutput>">Admin Section</a></li></cfoutput>
		</div><br />
	</cfif>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<form name="frmMessage" action="#cgi.SCRIPT_NAME#" method="post" onsubmit="return formValidation();">
	
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="status">Message Status</label>
		</td>
		<td>
			<input type="radio" name="radStatus" id="status" value="1" tabindex="#request.nextTabIndex#"
				onclick="setTextboxEdit();"
				<cfif form.radStatus eq 1>checked</cfif>
				>&nbsp;<label for="status">On</label>&nbsp;&nbsp;&nbsp;<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="radio" name="radStatus" id="off" value="0" tabindex="#request.nextTabIndex#"
				onclick="setTextboxEdit();"
				<cfif form.radStatus neq 1>checked</cfif>
				>&nbsp;<label for="off">Off</label>	 
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" valign="top">
			<label for="idMessageText">Message</label>
		</td>
		<td>
			<textarea name="txtMessageText" id="idMessage" tabindex="#request.nextTabIndex#"
				cols="65" rows="15" wrap="soft" style="font-size: small;"
				onKeyDown="textCounter(this, 1000);" onKeyUp="textCounter(this, 1000);">#form.txtMessageText#</textarea>
		</td>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</tr>

	<tr>
		<td width="20%">
		</td>
		<td>
			<input type="hidden" name="hidMessageType" value="#messageType#" />
			<input type="submit" name="btnSubmit" value="Save" tabindex="#request.nextTabIndex#" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#" onclick="location.href='admin_main.cfm'" />
		</td>
	</tr>
</form>
</table>

</cfoutput>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

<script>
setTextboxEdit();
</script>