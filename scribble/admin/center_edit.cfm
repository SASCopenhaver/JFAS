<cfsilent>
<!---
page: center_edit.cfm

description: allows user to view / edit Job Corps Centers

revisions:
	01-05-2007 - rroser - added three new fields to form - main center, old center name, and comments
	02-05-2007 - rroser - updated form to include center code field - required for export to filepro
--->
<cfoutput>

<cfset request.pageID = "2411" />
<cfset request.pageTitleDisplay = "JFAS System Administration">

<!--- Get Centers for Main Center drop down --->
<cfinvoke component="#application.paths.components#center" method="getCenters" returnvariable="rstCenterList">

<!--- if form has been submitted --->
<cfif isDefined("form.btnSubmit")>
	<cfinvoke component="#application.paths.components#center" method="saveCenter" centerID="#url.centerID#"
	formData="#form#" 
	returnvariable="stcSaved">
	
	<cfif stcSaved.success>
		<cflocation url="#cgi.SCRIPT_NAME#?centerID=#stcSaved.centerID#&saved=1">
	<cfelse>
		<cfset variables.lstErrorMessages = stcSaved.errorMessages />
		<cfset variables.lstErrorFields = stcSaved.errorFields />
	</cfif>

</cfif>
	
<cfif url.centerID neq 0>
	<cfinvoke component="#application.paths.components#center" method="getCenters" centerID="#url.centerID#" returnvariable="rstCenter">
		<cfparam name="form.txtCenterName" default="#rstCenter.centerName#">
		<cfparam name="form.txtCenterCode" default="#rstCenter.centerCode#">
		<cfparam name="form.txtCity" default="#rstCenter.city#">
		<cfparam name="form.cboState" default="#rstCenter.state#">
		<cfparam name="form.cboFundingOffice" default="#rstCenter.fundingOfficeNum#">
		<cfparam name="form.radStatus" default="#rstCenter.status#">
		<cfparam name="form.hidMode" default="Edit">
		<cfparam name="form.cboMainCenter" default="#rstCenter.mainCenterID#">
		<cfparam name="form.txtOldCenterName" default="#rstCenter.oldCenterName#">
		<cfparam name="form.txtComments" default="#rstCenter.comments#">
		<cfparam name="form.hidSatellite" default="#rstCenter.Satellite#">
<cfelse>
	<cfparam name="form.txtCenterName" default="">
	<cfparam name="form.txtCenterCode" default="">
	<cfparam name="form.txtCity" default="">
	<cfparam name="form.cboState" default="AL">
	<cfparam name="form.cboFundingOffice" default="1">
	<cfparam name="form.radStatus" default="1">
	<cfparam name="form.hidMode" default="Add">
	<cfparam name="form.cboMainCenter" default="">
	<cfparam name="form.txtOldCenterName" default="">
	<cfparam name="form.txtComments" default="">
	<cfparam name="form.hidSatellite" default="0">
</cfif>


	<cfparam name="variables.lstErrorMessages" default="">
	<cfparam name="variables.lstErrorFIelds" default="">

<!--- Queries for dropdown lists --->
<cfinvoke component="#application.paths.components#lookup" method="getStates" returnvariable="rstStates">
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" returnvariable="rstFundingOffices">
</cfoutput>

</cfsilent>

<!--- include header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">

var arrStateRegion = new Array;
	<cfoutput query="rstStates">
	arrStateRegion[#evaluate(currentrow-1)#] = '#regionNum#';
	</cfoutput>
	
function formValidation()
{
var strErrors = ''
if(document.frmCenter.txtCenterName.value == '')
	{
	strErrors = strErrors + ' - You must enter a center name.\n';
	}
if(document.frmCenter.txtCenterCode.value == '')
	{
	strErrors = strErrors + ' - You must enter a center abbreviation.\n';
	}
if(document.frmCenter.cboMainCenter.options[document.frmCenter.cboMainCenter.selectedIndex].text == document.frmCenter.txtCenterName.value.toUpperCase())
	{
	strErrors = strErrors + ' - The main center cannot be the same as the satellite center.\n';
	}
if(strErrors == '')
	{
	if(document.frmCenter.cboFundingOffice.selectedIndex <= 5)
		{
		if(arrStateRegion[document.frmCenter.cboState.selectedIndex] != document.frmCenter.cboFundingOffice.options[document.frmCenter.cboFundingOffice.selectedIndex].value)
			{
			var check = confirm('The state you have selected is not in the selected funding office.\n Continue?');
			if(check)
				{
				if(document.frmCenter.cboMainCenter.disabled == true)
					{
					document.frmCenter.cboMainCenter.disabled = false;
					}
				return true;
				}
			else
				{
				return false;
				}
			}
		else
			{
			if(document.frmCenter.cboMainCenter.disabled == true)
				{
				document.frmCenter.cboMainCenter.disabled = false;
				}
			return true;
			}
		}
	else 
		{
		if(document.frmCenter.cboMainCenter.disabled == true)
			{
			document.frmCenter.cboMainCenter.disabled = false;
			}
		return true;
		}
	}
else
	{
	alert('The following problems have occurred. Please fix these errors to continue.\n\n' + strErrors + '\n');
	return false;
	}
}

</script>

<cfoutput>

<h2>#form.hidMode# Center</h2>
	<cfif variables.lstErrorMessages neq ''>
		<div class="errorList">
		<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters=",">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div><br />
	</cfif>
	<cfif isDefined("url.saved")>
		<div class="confirmList">
		<cfoutput><li>Information saved successfully.  Return to <a href="center_list.cfm">center list</a>.</li></cfoutput>
		</div><br />
	</cfif>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<form name="frmCenter" action="#cgi.SCRIPT_NAME#?centerID=#url.centerID#" method="post" onsubmit="return formValidation();">
	<input type="hidden" name="hidSatellite" value="#form.hidSatellite#" />
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="centerName">* Center Name</label>
		</td>
		<td>
			<input type="text" name="txtCenterName" id="centerName" maxlength="80" value="#form.txtCenterName#" tabindex="#request.nextTabIndex#"<cfif listFindNoCase(variables.lstErrorFields,"txtCenterName")>class="errorField"</cfif>>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="centerCode">* Center Abbreviation</label>
		</td>
		<td>
			<input type="text" name="txtCenterCode" id="centerCode" maxlength="4" value="#form.txtCenterCode#" tabindex="#request.nextTabIndex#"<cfif listFindNoCase(variables.lstErrorFields,"txtCenterCode")>class="errorField"</cfif>>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="city">City</label>
		</td>
		<td>
			<input type="text" name="txtCity" id="city" value="#form.txtCity#" maxlength="80" tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="state">* State</label>
		</td>
		<td>
			<select name="cboState" id="state" tabindex="#request.nextTabIndex#">
				<cfloop query="rstStates">
					<option value="#state#" <cfif form.cboState eq state>selected</cfif>>
						#state#
					</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="fundingOffice">* Funding Office</label>
		</td>
		<td>	
			<select name="cboFundingOffice" id="fundingOffice" tabindex="#request.nextTabIndex#">
				<cfloop query="rstFundingOffices">
					<option value="#fundingOfficeNum#" <cfif form.cboFundingOffice eq fundingOfficeNum>selected</cfif> >
						#fundingOfficeNum# - #fundingOfficeDesc#
					</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="idMain">Main Center</label>
		</td>
		<td>
			<select name="cboMainCenter" id="idMain" tabindex="#request.nextTabIndex#" <cfif form.hidSatellite neq 0>disabled</cfif> >
				<option value="0"></option>
				<cfloop query="rstCenterList">
					<option value="#CenterID#" <cfif form.cboMainCenter eq CenterID>selected</cfif>>
						#CenterName#
					</option>
				</cfloop>
			</select> <font color="##999999">(if satellite)</font>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="idOldName">Old Center Name</label>
		</td>
		<td>
			<input type="text" name="txtOldCenterName" id="idOldName" maxlength="80" value="#form.txtOldCenterName#" tabindex="#request.nextTabIndex#">
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="20%">
			<label for="status">* Status</label>
		</td>
		<td>
			<input type="radio" name="radStatus" id="status" value="1" tabindex="#request.nextTabIndex#" <cfif form.radStatus eq 1>checked</cfif>>&nbsp;<label for="status">Active</label>&nbsp;&nbsp;&nbsp;<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="radio" name="radStatus" id="inactive" value="0" tabindex="#request.nextTabIndex#" <cfif form.radStatus eq 0>checked</cfif>>&nbsp;<label for="inactive">Inactive</label>	 
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="20%" valign="top">
			<label for="idcomments">Comments</label>
		</td>
		<td>
			<textarea name="txtComments" id="idcomments" tabindex="#request.nextTabIndex#" cols="35" rows="3" wrap="soft" onKeyDown="textCounter(this, 100);" onKeyUp="textCounter(this, 100);">#form.txtComments#</textarea>
		</td>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</tr>
	<tr>
		<td width="20%">
		</td>
		<td>
			<input type="hidden" name="hidMode" value="#form.hidMode#" />
			<input type="submit" name="btnSubmit" value="Save" tabindex="#request.nextTabIndex#" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#" onclick="location.href='center_list.cfm'" />
		</td>
	</tr>
</form>
</table>

</cfoutput>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">