<cfsilent>
<!---
page: RecentUpdates_list.cfm

description: allows user to view / add Release Notes

revisions:

--->
<cfoutput>

<cfset request.pageID = "2811" />
<cfset request.pageTitleDisplay = "JFAS System Administration">

<!--- If form has been submitted --->
<cfif isDefined("url.action")>
	<cfif url.action eq "Save">
		<cfinvoke component="#application.paths.components#dataadmin" method="saveRelease" formData="#form#" returnvariable="stcSaved">

		<cfif stcSaved.success>
			<cflocation url="#cgi.SCRIPT_NAME#?rID=#stcSaved.rID#&saved=1">
		<cfelse>
			<cfset variables.lstErrorMessages = stcSaved.errorMessages />
			<cfset variables.lstErrorFields = stcSaved.errorFields />
		</cfif>
	<cfelseif url.action eq "Delete">
		<cfinvoke component="#application.paths.components#dataadmin" method="deleteRelease" releaseID="#form.hidReleaseID#" returnvariable="stcDeleted">
		<cfif stcDeleted.success>
			<cflocation url="recentUpdates_list.cfm?Deleted=1">
		</cfif>
	</cfif>
</cfif>

<cfparam name="url.rid" default="0">
<cfparam name="form.hidReleaseID" default="#url.rid#">
<cfparam name="variables.lstErrorMessages" default="">
<cfparam name="variables.lstErrorFIelds" default="">

<cfif url.rid neq 0>
	<cfinvoke component="#application.paths.components#dataadmin" method="getRelease" rid="#url.rid#" returnvariable="rstRelease">
	<cfparam name="form.txtReleaseNo" default="#rstRelease.ReleaseNo#">
	<cfparam name="form.txtReleaseName" default="#rstRelease.ReleaseName#">
	<cfparam name="form.txtReleaseDate" default="#DateFormat(rstRelease.ReleaseDate, 'mm/dd/yyyy')#">
<cfelse>
	<cfparam name="form.txtReleaseNo" default="">
	<cfparam name="form.txtReleaseName" default="">
	<cfparam name="form.txtReleaseDate" default="">
</cfif>



</cfoutput>
</cfsilent>

<!--- include header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">
function validateForm(act)
{
var strErrors = '';
trimFormTextFields(document.frmRelease);
if (document.frmRelease.txtReleaseNo.value == '')
	{
	strErrors = strErrors + ' - You must enter a Release Number.\n';
	}
if (document.frmRelease.txtReleaseDate.value == '')
	{
	strErrors = strErrors + ' - You must enter a Release Date.\n';
	}
else if (!Checkdate(document.frmRelease.txtReleaseDate.value))
	{
	strErrors = strErrors + ' - Release Date must be valid and in the format mm/dd/yyyy.\n';
	}
if (strErrors == '')
	{
	if (act == 'Delete')
		{
		var answer = confirm("You are about to delete this release and all of its Release Items.\nContinue?")
		if (answer)
			{
			<cfoutput>
			document.frmRelease.action = "release_edit.cfm?rID=#url.rid#&action=Delete";
			</cfoutput>
			document.frmRelease.submit();
			}
		}
	else if (act == 'Save')
		{
		<cfoutput>
		document.frmRelease.action = "release_edit.cfm?rID=#url.rid#&action=Save";
		</cfoutput>
		document.frmRelease.submit();
		}
	}
else
	{
	alert('The following problems have occurred. Please fix these errors to continue.\n\n' + strErrors + '\n');
	}
}
</script>

<h2>Recent Updates</h2>
<cfoutput>
	<cfif variables.lstErrorMessages neq ''>
		<div class="errorList">
		<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters=",">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div><br />
	</cfif>
	<cfif isDefined("url.saved")>
		<div class="confirmList">
		<cfoutput><li>Information saved successfully.  Return to <a href="recentUpdates_list.cfm">recent updates list</a>.</li></cfoutput>
		</div><br />
	</cfif>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<form name="frmRelease" action="release_edit.cfm?rID=#url.rid#" method="post">
<input type="hidden" name="hidReleaseId" value="#url.rid#" />
<tr>
	<td scope="row" align="right" width="20%">
		<label for="idReleaseNo">* Release Number</label>
	</td>
	<td>
		<input type="text" name="txtReleaseNo" id="idReleaseNo" value="#form.txtReleaseNo#" tabindex="#request.nextTabIndex#" size="7" maxlength="8" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td scope="row" align="right" width="20%">
		<label for="idReleaseName">Release Name</label>
	</td>
	<td>
		<input type="text" name="txtReleaseName" id="idReleaseName" value="#form.txtReleaseName#" tabindex="#request.nextTabIndex#" size="20" maxlength="100" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td scope="row" align="right" width="20%">
		<label for="idReleaseDate">* Release Date</label>
	</td>
	<td>
		<input type="text" name="txtReleaseDate" id="idReleaseDate" value="#DateFormat(form.txtReleaseDate, 'mm/dd/yyyy')#" tabindex="#request.nextTabIndex#" size="15" maxlength="15"  class = "datepicker" title= "Select to specify ReleaseDate"/>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td colspan="2" align="right">
		<input type="button" name="btnSubmit" value="Save" tabindex="#request.nextTabIndex#" onclick="validateForm('Save')" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
		<cfif url.rid neq 0>
			<input type="button" name="btnDelete" value="Delete" tabindex="#request.nextTabIndex#" onclick="validateForm('Delete')" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfif>
		<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#" onclick="location.href='RecentUpdates_list.cfm'" />
	</td>
</tr>
</form>
</table>
</cfoutput>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">