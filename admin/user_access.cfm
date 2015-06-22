<cfsilent>
<!---
page: useraccess_edit.cfm

description: data entry form... allows user to grant/restrict access by user role

revisions:
20150518	mstein	Updated Form to include Budget area (only editable for budg ovsight role

--->

<cfset request.pageID = "2620" />
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->

<cfif isDefined("form.hidMode")> <!--- coming from form submittal --->

	<!--- database interaction / server-side validation --->
	<cfinvoke component="#application.paths.components#user" method="saveUserAccessSettings" formData="#form#" returnvariable="stcResults">
	<cfif stcResults.success>
		<cflocation url="#cgi.SCRIPT_NAME#?saved=yes">
	<cfelse>
		<cfset variables.lstErrorMessages = stcResults.errorMessages>
	</cfif>

<cfelse> <!--- first time to form --->

	<cfset form.hidMode = "edit">
	<cfinvoke component="#application.paths.components#user" method="getUserAccessSettings" returnvariable="rstUserAccessSettings">
	<cfset form.UserRoleList = valuelist(rstUserAccessSettings.userRoleID)>
	<!--- loop through system settings, creating form fields for each --->
	<cfloop query="rstUserAccessSettings">
		<cfset form["r" & userRoleID & "_desc"] = userRoleDesc>
		<cfset form["r" & userRoleID & "_adminAccess"] = adminAccess>
		<cfset form["r" & userRoleID & "_reportsAccess"] = reportsAccess>
		<cfset form["r" & userRoleID & "_aappAccess"] = aappAccess>
        <cfset form["r" & userRoleID & "_budgetAccess"] = budgetAccess>
	</cfloop>

</cfif>

</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">


function ValidateForm(form)
{
	// trim text fields
	trimFormTextFields(form);
	strErrors= '';

	if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before saving.\n\n' + strErrors + '\n');
		return false
		}
	else
		return true;
}

</script>


<h2>User Access Controls</h2>

<!--- show error / confirmation messages --->
<cfif listLen(variables.lstErrorMessages) gt 0>
	<div class="errorList">
	<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters="~">
		<cfoutput><li>#listItem#</li></cfoutput>
	</cfloop>
	</div><br />
</cfif>
<cfif isDefined("url.saved")>
	<div class="confirmList">
	<cfoutput><li>Information saved successfully. Return to the <a href="#application.paths.admin#">Admin Section</a></li></cfoutput>
	</div><br />
</cfif>

	<!--- Start Form --->
	<form name="frmUserAccessLevel"  action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" onSubmit="return ValidateForm(this);">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Small Bus Category Information">
	<cfoutput>

	<tr>
		<th scope="col">User Role</th>
		<th scope="col">AAPP Section</th>
		<th scope="col">Reports</th>
		<th scope="col">Budget</th>
        <th scope="col">Data Administration</th>
	</tr>
	<cfloop list="#form.UserRoleList#" index="roleID">
		<tr>
			<td width="36%">
				#form["r" & roleID & "_desc"]#
				<input type="hidden" name="r#roleID#_desc" value="#form["r" & roleID & "_desc"]#" />
			</td>
			<td width="16%" align="center">
				<label for="id_r#roleID#_aappAccess" class="hiddenLabel">#form["r" & roleID & "_desc"]# AAPP Access</label>
				<input type="checkbox" name="r#roleID#_aappAccess" id="id_r#roleID#_aappAccess"	 tabindex="#request.nextTabIndex#"
				<cfif form["r" & roleID & "_aappAccess"] eq 1>checked</cfif>
				<cfif roleID eq 2>disabled</cfif> />
			</td>
			<td width="16%" align="center">
				<label for="id_r#roleID#_reportsAccess" class="hiddenLabel">#form["r" & roleID & "_desc"]# Reports Section Access</label>
				<input type="checkbox" name="r#roleID#_reportsAccess" id="id_r#roleID#_reportsAccess"	 tabindex="#request.nextTabIndex#"
				<cfif form["r" & roleID & "_reportsAccess"] eq 1>checked</cfif>
				<cfif roleID eq 2>disabled</cfif> />
			</td>
            <td width="16%" align="center">
				<label for="id_r#roleID#_budgetAccess" class="hiddenLabel">#form["r" & roleID & "_desc"]# Budget Section Access</label>
				<input type="checkbox" name="r#roleID#_budgetAccess" id="id_r#roleID#_budgetAccess"	 tabindex="#request.nextTabIndex#"
				<cfif form["r" & roleID & "_budgetAccess"] eq 1>checked</cfif>
				<cfif roleID neq 6>disabled</cfif> />
                <!--- only admin and budget oversight have access - only budg ov can be modified --->
			</td>
			<td width="16%" align="center">
				<label for="id_r#roleID#_adminAccess" class="hiddenLabel">#form["r" & roleID & "_desc"]# Data Admin Access</label>
				<input type="checkbox" name="r#roleID#_adminAccess" id="id_r#roleID#_adminAccess"	 tabindex="#request.nextTabIndex#"
				<cfif form["r" & roleID & "_adminAccess"] eq 1>checked</cfif>
				disabled />
			</td>
		</tr>
		<tr><td colspan="5" class="hrule"></td></tr>
	</cfloop>
	</cfoutput>
	</table>

	<cfoutput>
	<input type="hidden" name="hidMode" value="#form.hidMode#" />
	<input type="hidden" name="UserRoleList" value="#form.UserRoleList#" />
	<div class="buttons">
		<input name="btnSubmit" type="Submit" value="Save" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input name="btnReset" type="reset" value="Reset" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='#application.paths.admin#';" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</div>
	</form>
	</cfoutput>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />