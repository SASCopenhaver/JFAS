<cfsilent>
<!---
page: Contractor_edit.cfm

description: allows user to view / edit Job Corps Contractors

revisions:

--->
<cfoutput>

<cfset request.pageID = "2421" />
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfif isDefined("form.btnSubmit")>
	<cfinvoke component="#application.paths.components#Contractor" method="saveContractor" ContractorID="#url.ContractorID#"
	formData="#form#" 
	returnvariable="stcSaved">
	
	<cfif stcSaved.success>
		<cflocation url="#cgi.SCRIPT_NAME#?ContractorID=#stcSaved.ContractorID#&saved=1">
	<cfelse>
		<cfset variables.lstErrorMessages = stcSaved.errorMessages />
		<cfset variables.lstErrorFields = stcSaved.errorFields />
	</cfif>

</cfif>
	
<cfif url.ContractorID neq 0>
	<cfinvoke component="#application.paths.components#Contractor" method="getContractors" status="all" ContractorID="#url.ContractorID#" returnvariable="rstContractor">
		<cfparam name="form.txtContractorName" default="#rstContractor.ContractorName#">
		<cfparam name="form.radStatus" default="#rstContractor.status#">
		<cfparam name="form.hidMode" default="Edit">
<cfelse>
	<cfparam name="form.txtContractorName" default="">
	<cfparam name="form.radStatus" default="1">
	<cfparam name="form.hidMode" default="Add">
</cfif>


	<cfparam name="variables.lstErrorMessages" default="">
	<cfparam name="variables.lstErrorFIelds" default="">

</cfoutput>

</cfsilent>

<!--- include header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">


	
function formValidation()
{
var strErrors = ''
if(document.frmContractor.txtContractorName.value == '')
	{
	strErrors = strErrors + ' - You must enter a Contractor name.';
	}
if(strErrors == '')
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

<cfoutput>

<h2>#form.hidMode# Contractor</h2>
	<cfif variables.lstErrorMessages neq ''>
		<div class="errorList">
		<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters=",">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div><br />
	</cfif>
	<cfif isDefined("url.saved")>
		<div class="confirmList">
		<cfoutput><li>Information saved successfully.  Return to <a href="contractor_list.cfm">contractor list</a>.</li></cfoutput>
		</div><br />
	</cfif>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<form name="frmContractor" action="#cgi.SCRIPT_NAME#?ContractorID=#url.ContractorID#" method="post" onsubmit="return formValidation();">
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="ContractorName">* Contractor Name</label>
		</td>
		<td>
			<input type="text" name="txtContractorName" id="ContractorName" maxlength="50" value="#form.txtContractorName#" tabindex="#request.nextTabIndex#"<cfif listFindNoCase(variables.lstErrorFields,"txtContractorName")>class="errorField"</cfif>>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="status">* Status</label>
		</td>
		<td>
			<input type="radio" name="radStatus" tabindex="#request.nextTabIndex#" id="status" value="1" <cfif form.radStatus eq 1>checked</cfif>>&nbsp;<label for="status">Active</label>&nbsp;&nbsp;&nbsp;<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="radio" name="radStatus" tabindex="#request.nextTabIndex#" id="inactive" value="0" <cfif form.radStatus eq 0>checked</cfif>>&nbsp;<label for="inactive">Inactive</label>	 
		</td>
	</tr>
	<tr>
		<td width="20%">
		</td>
		<td>
			<input type="hidden" name="hidMode" tabindex="#request.nextTabIndex#" value="#form.hidMode#" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="submit" name="btnSubmit" tabindex="#request.nextTabIndex#" value="Save" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="reset" name="btnReset" tabindex="#request.nextTabIndex#" value="Reset" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="button" name="btnCancel" tabindex="#request.nextTabIndex#" value="Cancel" onclick="location.href='contractor_list.cfm'" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
</form>
</table>

</cfoutput>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">