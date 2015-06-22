<cfsilent>
<!---
page: setaside_edit.cfm

description: Edit atrributes of an SMB Setaside Category

revisions:

--->

<cfset request.pageID = "2451" /> 
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->

<cfif isDefined("form.hidMode")> <!--- coming from form submittal --->
	
	<!--- database interaction / server-side validation --->
	<cfinvoke component="#application.paths.components#dataadmin" method="saveSetAsideData" formData="#form#" returnvariable="stcResults">
	<cfif stcResults.success>
		<cfif form.hidMode neq "delete">
			<!--- if successful, reload as an edit page --->
			<cflocation url="#cgi.SCRIPT_NAME#?setasideid=#stcResults.SMBid#&saved=1">
		<cfelse>
			<cflocation url="setaside_list.cfm">
		</cfif>
		
	</cfif>
		
<cfelse> <!--- first time to form --->

	<cfif url.setasideid eq 0> <!--- new category --->
		<cfset form.hidMode = "add">
		<cfset form.txtDescription = "">
		<cfset form.txtSortOrder = "1000">
		<cfset form.hidSMBused = 0>
	<cfelse> <!--- existing category --->
		<cfinvoke component="#application.paths.components#dataadmin" method="getSetAside" setasideid="#url.setasideid#" returnvariable="rstSetAsideData">
		<cfset form.hidMode = "edit">
		<cfset form.txtDescription = rstSetAsideData.setasideDesc>
		<cfset form.txtSortOrder = rstSetAsideData.sortOrder>
		<cfset form.hidSMBused = rstSetAsideData.SMBused >
	</cfif>

	
</cfif>

</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">

function deleteCategory(form)
{
	form.hidMode.value = 'delete';
	form.submit();
}

function ValidateForm(form)
{
	// trim text fields
	trimFormTextFields(form);
	strErrors= '';
	
	// description is required
	if (form.txtDescription.value == '')
		strErrors = strErrors + '   - Description must be entered.\n';
		
	// sort order is required
	if (form.txtSortOrder.value == '')
		strErrors = strErrors + '   - Sort Order must be entered.\n';
	else
		if (isNaN(form.txtSortOrder.value))
			strErrors = strErrors + '   - Sort Order must be numeric.\n';
	
	if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before saving.\n\n' + strErrors + '\n');
		return false
		}
	else
		return true;
}

</script>
				

<h2><cfif form.hidMode eq 'edit'>Edit<cfelse>Add</cfif> Small Business Category</h2>

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
	<cfoutput><li>Information saved successfully. Return to <a href="setaside_list.cfm">Category List</a></li></cfoutput>
	</div><br />
</cfif>

	
	<!--- Start Form --->
	<form name="frmEditCategory"  action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" onSubmit="return ValidateForm(this);">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Small Bus Category Information">
	<cfoutput>
	
	<tr valign="top">
		<td align="right">
			<label for="idDescription">Description</label>
		</td>
		<td>
			<input type="text" id="idDescription" name="txtDescription" value="#form.txtDescription#" maxlength="35" size="40"
			<cfif form.hidSMBused gt 0>readonly class="inputReadonly"</cfif> tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr valign="top">
		<td align="right">
			<label for="idSortOrder">Sort Order</label>
		</td>
		<td>
			<input type="text" id="idSortOrder" name="txtSortOrder" value="#form.txtSortOrder#" maxlength="3" size="4" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>		
	</cfoutput>
	</table>
	
	<cfoutput>
	<input type="hidden" name="hidMode" value="#form.hidMode#" />
	<input type="hidden" name="hidSetAsideID" value="#url.setasideID#" />
	<div class="buttons">
		<input name="btnSubmit" type="Submit" value="Save" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input name="btnReset" type="button" value="Reset" tabindex="#request.nextTabIndex#" onClick="window.location.href='#cgi.SCRIPT_NAME#?setasideid=#url.setasideid#';" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<cfif form.hidMode eq "edit">
			<input name="btnDelete" type="button" value="Delete" tabindex="#request.nextTabIndex#" onClick="deleteCategory(this.form);"
				<cfif form.hidSMBused gt 0> disabled </cfif> />		
		</cfif>
		<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='setaside_list.cfm'" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</div>
	</form>
	</cfoutput>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />