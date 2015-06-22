<cfsilent>
<!---
page: edituser.cfm

description: Edit permissions of an existing user

revisions:
2007-02-09	mstein	508 issues - use of fieldset tag
2007-03-07	mstein	MAde user role radio buttons dynamic, based on LU_USER_ROLE

--->

<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfparam name="form.btnSubmit" default="">
<cfif not isDefined("form.hidMode")>
	<cfif isDefined("url.id")><!--- if the id is in they url, they're editing --->
		<cfset form.hidMode = 'edit'>
		<cfset form.txtUserId = url.id>
	<cfelse><!--- otherwise, they're adding --->
		<cfset form.hidMode = 'add'>
	</cfif>
</cfif>

<cfparam name="strUpdateResults.success" default=""> 

<cfif form.hidMode eq 'add'>
	<cfset request.pageID = "2610" />
<cfelse>
	<cfset request.pageID = "2611" />
</cfif>
 
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->

<cfif form.btnSubmit is "Save"> <!--- coming from form submittal --->
	<!--- database interaction / server-side validation --->
	<cfinvoke component="#application.paths.components#user" method="saveJFASUserData" formData="#form#" >
		<!--- if successful, reload as an edit page --->
		<cflocation url="#cgi.SCRIPT_NAME#?id=#form.txtUserId#&saved=1">
</cfif>

<!--- read data from database, set up form fields --->
<cfif form.hidMode is 'edit'>
	<!--- if it's an edit page - query for info based on text of form field, rather than url --->
	<cfinvoke component="#application.paths.components#user" method="GetJfasUserList" userId="#form.txtUserId#" 
	returnvariable="rstUserData">
	<!--- set results as form fields --->
	<cfset form.txtUserId = rstUserData.userId>
	<cfset form.txtlastName = rstUserData.lastName>
	<cfset form.txtFirstName = rstUserData.firstName>
	<cfset form.txtEmail = rstUserData.email>
	<cfset form.hidStatus = rstUserData.status>
	<cfset form.hidRoleId = rstUserData.roleId>
</cfif>

<cfinvoke component="#application.paths.components#lookup" method="getJFASUserRoles" returnvariable="rstUserRoles">
</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">
//prevent user from editing their own permissions
function radioReadOnly(Cntrl)
{
	if (Cntrl.name == 'radRole')
	{
		if (document.frmEditUser.hidRoleId.value != '')
		{
			document.frmEditUser.radRole[document.frmEditUser.hidRoleId.value-1].checked = 1;
			alert('You cannot lower your own permissions.');
		}
	}
	if (Cntrl.name == 'radStatus')
	{
		if(document.frmEditUser.hidStatus.value != '')
			{
				document.frmEditUser.radStatus[0].checked = 1;
				alert('You cannot make your account inactive while logged in.');
			}
		
	}
		 
}
//pop up window to verify user
//but only if they've entered something
function verifyId(id)
{
if(id != '')
	{
	id = trim(id);
	newWin = window.open("checkid.cfm?id="+id, "verifyUser",'status=no,toolbar=no,menubar=no,location=no,scrollbars=no,resizable=no,width=325,height=190');
	}
else
	alert('Please enter a user id to be verified.');
}
//before submitting form to save, make sure there's something in the last name field, 
//so they can't submit an empty form
function checkLastName()
{
if (document.frmEditUser.txtLastName.value != '')
	{
	return true;
	}
else 
	{
	alert('Please select a user to add to the JFAS system.');
	return false;
	}
}

function clearAdd()
{
document.frmEditUser.txtLastName.value = '';
document.frmEditUser.txtFirstName.value = '';
document.frmEditUser.txtEmail.value = '';
document.frmEditUser.txtUserId.value = '';
document.frmEditUser.txtUserId.style.border = '2px inset #ffffff';
document.frmEditUser.txtUserId.readOnly = 0;
}
</script>
				
<cfif form.hidMode is 'edit'>
	<h2>Edit User</h2>
	<cfset form.hidIdStyle = 'readOnly'><!--- if they're editing, don't allow them to change the user name in the form field --->
<cfelseif form.hidMode is 'add'>
	<h2>Add User</h2>
</cfif>	

	<!--- if validation errors exist, display them --->
<cfif strUpdateResults.success is true or isDefined("url.saved")>
	<div class="confirmList">
		<li>Information Saved Successfully. Return to the <a href="users.cfm">user list</a>.
		</li>
	</div><br />
</cfif>
	
	<!--- Start Form --->
	<form name="frmEditUser"  action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" onSubmit="return checkLastName();">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="User Information">
	<cfoutput>
	<input type="hidden" name="hidMode" value="#form.hidMode#" />
	<tr valign="top">
		<td align="right">
			<label for="userid">User ID</label>
		</td>
		<td>
			<!--- if they're editing, the field is populated and readOnly, otherwise it's blank and editable --->
			<input type="text" id="userid" name="txtUserId" <cfif form.hidMode is "edit">value="#form.txtUserId#"</cfif> size="17" maxlength="20" <cfif form.hidIdStyle is 'readOnly'>readonly class="inputReadonly"</cfif> tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<cfif form.hidMode is "add"><!--- if they're adding, show icon to check user id against EBSS --->
				<a href="javascript:verifyId(document.frmEditUser.txtUserId.value)" tabindex="#request.nextTabIndex#"><img src="#application.paths.images#verifyuser_icon.gif" border="0" alt="check that the user id is valid" width="20" height="16" align="absmiddle" /></a>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</cfif>
		</td>
	</tr>		
	<tr valign="top">
		<td align="right">
			<label for="lastname">Last Name</label>
		</td>
		<td>
			<input type="text" id="lastname" name="txtLastName" <cfif form.hidMode is "edit">value="#form.txtLastName#"</cfif> size="25" readonly class="inputReadonly" />
		</td>
	</tr>	
	<tr valign="top">
		<td align="right">
			<label for="firstname">First Name</label>
		</td>
		<td>
			<input type="text" id="firstname" name="txtFirstName" <cfif form.hidMode is "edit">value="#form.txtFirstName#"</cfif> size="25" readonly class="inputReadonly" />
		</td>
	</tr>	
	<tr valign="top">
		<td align="right">
			<label for="email">Email</label>
		</td>
		<td>
			<input type="text" id="email" name="txtEmail" <cfif form.hidMode is "edit">value="#form.txtEmail#"</cfif> size="30" readonly class="inputReadonly" />
		</td>
	</tr>
	
	<tr valign="top">
		<td align="right">
			<fieldset><legend align="right">Role</legend>
		</td>
		<td>
			<cfloop query="rstUserRoles">
				<input type="radio" id="role#roleID#" name="radRole" value="#roleID#" <cfif #form.hidRoleId# eq roleID>checked</cfif> <cfif session.userid is form.txtUserId>onClick="radioReadOnly(this);"</cfif> tabindex="#request.nextTabIndex#" />&nbsp;&nbsp;
				<label for="role#roleID#">#roleDesc#</label><br />
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</cfloop> 
			</fieldset>
		</td>
	</tr>	
	<tr valign="top">
		<td align="right">
			<fieldset><legend align="right">Status</legend>
		</td>
		<td>
			<input type="radio" id="status1" name="radStatus" value="1" <cfif #form.hidStatus# is 1>checked</cfif> <cfif session.userid is form.txtUserId>onClick="radioReadOnly(this);"</cfif>tabindex="#request.nextTabIndex#" />&nbsp;&nbsp;<label for="status1">Active</label><br />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="radio" id="status2" name="radStatus" value="0" <cfif #form.hidStatus# is 0>checked</cfif> <cfif session.userid is form.txtUserId>onClick="radioReadOnly(this);"</cfif>tabindex="#request.nextTabIndex#" />&nbsp;&nbsp;<label for="status2">Inactive</label>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>	
			<input type="hidden" name="hidStatus" value="#form.hidStatus#" />
			</fieldset>
		</td>
	</tr>	
	</cfoutput>
	</table>
	<div class="buttons">
		<input name="btnSubmit" type="Submit" value="Save" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
				<cfif form.hidMode is "add">
					<input name="btnReset" type="button" value="Reset" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" onClick="clearAdd()" />
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
				<cfelse>
					<input name="btnReset" type="reset" value="Reset" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</cfif>
		<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='<cfoutput>users.cfm</cfoutput>'" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</div>
	</form>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />
