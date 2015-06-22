<cfsilent>
<!---
page: RecentUpdates_list.cfm

description: allows user to view / add Release Notes

revisions:

--->
<cfoutput>

<cfset request.pageID = "2812" /> 
<cfset request.pageTitleDisplay = "JFAS System Administration">

<!--- Query for dropdown --->
<cfinvoke component="#application.paths.components#dataadmin" method="getReleaseItemSortOrder" rid="#url.rid#" returnvariable="rstSortOrder">
<cfset sortOrderPlus = rstSortOrder.recordcount + 1>

<cfinvoke component="#application.paths.components#dataadmin" method="getRelease" rid="#url.rid#" returnvariable="rstRelease">

<!--- If form has been submitted --->
<cfif isDefined("form.btnSubmit")>
	
		<cfinvoke component="#application.paths.components#dataadmin" method="saveReleaseItem" formData="#form#" returnvariable="stcSaved">
		<cfif stcSaved.success>
			<cflocation url="#cgi.SCRIPT_NAME#?rID=#url.rID#&ritemid=#stcSaved.ritemid#&saved=1">
		<cfelse>
			<cfset variables.lstErrorMessages = stcSaved.errorMessages />
			<cfset variables.lstErrorFields = stcSaved.errorFields />
		</cfif>
<cfelseif isDefined("form.btnDelete")>
		<cfinvoke component="#application.paths.components#dataadmin" method="deleteReleaseItem" releaseItemID="#form.hidReleaseItemID#" returnvariable="stcDeleted">
		<cfif stcDeleted.success>
			<cflocation url="recentUpdates_list.cfm?ItemDeleted=1">
		</cfif>
</cfif>

	<cfparam name="form.txtReleaseNo" default="#rstRelease.ReleaseNo#">
	<cfparam name="form.txtReleaseName" default="#rstRelease.ReleaseName#">
	<cfparam name="form.txtReleaseDate" default="#dateFormat(rstRelease.ReleaseDate)#">
	<cfparam name="form.hidReleaseID" default="#url.rid#">
	<cfparam name="form.hidReleaseItemID" default="#url.ritemID#">
<cfparam name="variables.lstErrorMessages" default="">
<cfparam name="variables.lstErrorFIelds" default="">

<cfif url.rItemID neq 0>
	<cfinvoke component="#application.paths.components#dataadmin" method="getReleaseItem" rItemId="#url.rItemID#" returnvariable="rstReleaseItem">
	<cfparam name="form.txtItemDesc" default="#rstReleaseItem.itemDesc#">
	<cfparam name="form.cboSortOrder" default="#rstReleaseItem.SortOrder#">
	<cfparam name="form.hidOldSortOrder" default="#rstReleaseItem.SortOrder#">
<cfelse>
	<cfparam name="form.txtItemDesc" default="">
	<cfparam name="form.cboSortOrder" default="#sortOrderPlus#">
	<cfparam name="form.hidOldSortOrder" default="#sortOrderPlus#">
	
</cfif>

</cfoutput>
</cfsilent>

<!--- include header --->
<cfinclude template="#application.paths.includes#header.cfm" />
<!---<cfif isDefined("form.btnSubmit")>
	<cfdump var="#form#">
	<cfabort>
</cfif>--->

<script language="javascript">
function validateForm()
{
var strErrors = '';
trimFormTextFields(document.frmReleaseItem);
if (document.frmReleaseItem.txtItemDesc.value == '')
	{
	strErrors = strErrors + ' - You must enter an Item Description.\n';
	}
if (strErrors == '')
	{
	return true;
	}
else 
	{
	alert('The following problems have occurred. Please fix these errors to continue.\n\n' + strErrors + '\n');
	return false;
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
<form name="frmReleaseItem" action="releaseItem_edit.cfm?rid=#url.rid#&ritemid=#url.ritemid#" method="post" onSubmit="return validateForm();">
<tr>
	<td scope="row" align="right" width="20%">
		<label for="idReleaseNo">Release Number</label>
	</td>
	<td>
		<input type="text" name="txtReleaseNo" id="idReleaseNo" tabindex="#request.nextTabIndex#" value="#form.txtReleaseNo#" size="4" readonly class="inputReadonly" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td scope="row" align="right" width="20%">
		<label for="idReleaseName">Release Name</label>
	</td>
	<td>
		<input type="text" name="txtReleaseName" value="#form.txtReleaseName#" id="idReleaseName" readonly class="inputReadonly" size="20" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td scope="row" align="right" width="20%">
		<label for="idReleaseDate">Release Date</label>
	</td>
	<td>
		<input type="text" name="txtReleaseDate" id="idReleaseDate" value="#dateFormat(Form.txtReleaseDate, 'mm/dd/yyyy')#" size="15" readonly class="inputReadonly" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td scope="row" align="right" valign="top" width="20%">
		<label for="idItemDesc">* Item Description</label>
	</td>
	<td align="left">
		<textarea name="txtItemDesc" id="idItemDesc" tabindex="#request.nextTabIndex#" cols="65" rows="5" wrap="soft" onKeyDown="textCounter(this, 1000);" onKeyUp="textCounter(this, 1000);" />#form.txtItemDesc#</textarea>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td scope="row" align="right" width="20%">
		<label for="idSortOrder">Sort Order</label>
	</td>
	<td>
		<select name="cboSortOrder" id="idSortOrder" tabindex="#request.nextTabIndex#">
			<cfloop query="rstSortOrder">
				<option value="#rstSortOrder.SortOrder#" <cfif form.cboSortOrder eq rstSortOrder.SortOrder>selected</cfif>>
					#rstSortOrder.sortOrder#
				</option>
			</cfloop>
			<cfif url.ritemid is 0>
				<option value="#sortOrderPlus#" selected>#sortOrderPlus#</option>
			</cfif>
		</select>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td colspan="2" align="right">
		<input type="hidden" name="hidReleaseItemID" value="#form.hidreleaseItemID#" />
		<input type="hidden" name="hidreleaseID" value="#form.hidreleaseID#" />
		<input type="hidden" name="hidOldSortOrder" value="#form.hidOldSortOrder#" />
		<input type="submit" name="btnSubmit" value="Save" tabindex="#request.nextTabIndex#" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
		<cfif url.rItemid neq 0>
			<input type="submit" name="btnDelete" value="Delete" tabindex="#request.nextTabIndex#" /><cfset request.nextTabIndex = request.nextTabIndex + 1> 
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