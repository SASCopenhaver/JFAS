<cfsilent>
<cfinvoke component="#application.paths.components#user" method="VerifyNewUser" userId="#url.id#" 
		returnvariable="stcVerifyResults">
</cfsilent>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<link href="#application.paths.css#" rel="stylesheet" type="text/css" />
</cfoutput>
<script language="javascript">
function acceptUser(lastName, firstName, email, id)
{
window.opener.document.frmEditUser.txtLastName.value = lastName;
window.opener.document.frmEditUser.txtFirstName.value = firstName;
window.opener.document.frmEditUser.txtEmail.value = email;
window.opener.document.frmEditUser.txtUserId.value = id;
window.opener.document.frmEditUser.txtUserId.style.border = '1px solid #999999';
window.opener.document.frmEditUser.txtUserId.readOnly = 1;
window.close(this);

}

function cancelUser()
{
window.opener.document.frmEditUser.txtUserId.value = '';
window.close(this);
}
</script>

<title>Verify EBSS User Information</title>
</head>

<body onLoad="window.focus();" >
<table width="100%" bgcolor="white">
<tr>
<td>
<h2>Verify EBSS User Information</h2>
<cfif stcVerifyResults.success>
<cfoutput>
<table width="100%" border="0" cellspacing="0" class="contentTbl" summary="User Information to be added to JFAS user list">
<tr>
	<td width="29%" nowrap="nowrap">
		<div align="right">Last Name:&nbsp;&nbsp;</div></td>
	<td width="71%">
		#stcVerifyResults.lastName#	</td>
</tr>
<tr>
	<td nowrap="nowrap">
		<div align="right">First Name:&nbsp;&nbsp;</div></td>
	<td>
		#stcVerifyResults.firstName#	</td>
</tr>
<tr>
	<td nowrap="nowrap">
		<div align="right">Email:&nbsp;&nbsp; </div></td>
	<td nowrap="nowrap">
		#stcVerifyResults.email#	</td>
</tr>
</table>
<form name="frmVerifyUser" method="post">
	<input type="hidden" name="lastName" value="#stcVerifyResults.lastName#" />
	<input type="hidden" name="firstName" value="#stcVerifyResults.firstName#" />
	<input type="hidden" name="email" value="#stcVerifyResults.email#" />
	<input type="hidden" name="id" value="#url.id#" />
</cfoutput>
<div class="buttons">
<input type="button" name="Accept" value="Accept" onClick="acceptUser(document.frmVerifyUser.lastName.value, document.frmVerifyUser.firstName.value, document.frmVerifyUser.email.value, document.frmVerifyUser.id.value);" tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
<input type="button" name="Cancel" value="Cancel" onClick="cancelUser();" tabindex="#request.nextTabIndex#" />
</div>
</form>
<cfelse>
	<div class="errorList">
		<cfloop index="listItem" list="#stcVerifyResults.errorMsg#" delimiters="~">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
	</div><br />
	<a href="javascript:cancelUser();" class="contentTbl">Close Window</a>
</cfif>
</td>
</tr>
</table>
</body>
</html>
