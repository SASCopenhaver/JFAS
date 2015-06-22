<cfsilent>
<!---
page: aapp_setup_ccc.cfm

description: Add or Edit CCC information

revisions:
12/18/2006	rroser	added asterisks by required fields
12/20/2006	rroser	Cancel button will only appear on new CCC
04/18/2007	rroser	Save button will not appear for national read-only users
2007-10-16	mstein	Removed "are you sure you want to de-activate..." message if user is admin
2007-10-22	mstein	Made Funding Office uneditable for existing CCCs. Only editable when creating new CCC.
--->

<cfif url.aapp eq 0>
	<cfset request.pageID = "116" /> <!--- creating new aapp --->
<cfelse> <!--- editing exiting aapp --->
	<cfset request.pageID = "115" />
</cfif>


<!--- param all the variables, so it won't cause an error on the first run --->
<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default=""><!--- required for data entry forms --->
<cfparam name="form.txtAapp" default="">
<cfparam name="form.cboFundingOffice" default="">
<cfparam name="form.radStatus" default="1">
<cfparam name="form.cboCenter" default="">
<cfparam name="form.cboState" default="">
<cfparam name="form.txtContractNum" default="">
<cfparam name="url.hidMode" default="edit">
<cfparam name="form.hidMode" default="#url.hidMode#">
<cfparam name="optionVal" default="">
<cfparam name="url.saved" default="0">
<cfparam name="request.statusid" default="1">


<cfif isDefined("url.reactivateAAPP")> <!--- user is re-activating AAPP --->
	<cfinvoke component="#application.paths.components#aapp" method="reactivateAAPP" aapp="#request.aapp#" />
	<cflocation url="#cgi.SCRIPT_NAME#?aapp=#request.aapp#&reactivate=1" />
</cfif>

<cfif isDefined("form.btnSubmit")> <!--- coming from form submittal --->
	<!--- database interaction / server-side validation --->
	<cfinvoke component="#application.paths.components#aapp" method="saveAAPPsummary_CCC" formData="#form#" returnvariable="stcAAPPSaveResults_CCC" />
	<cfif stcAAPPSaveResults_CCC.success>
		<cflocation url="aapp_setup_ccc.cfm?aapp=#form.txtAAPP#&saved=1&hidMode=edit" /><!--- redirect --->
	<cfelse>
		<cfset lstErrorMessages = stcAAPPSaveResults_CCC.errorMessages>
		<cfset lstErrorFields = stcAAPPSaveResults_CCC.errorFields>
	</cfif>

<cfelse> <!--- first time viewing form --->
	<!--- read data from database, set up form fields --->
	<cfif url.aapp neq 0><!--- if they're editing, not adding, the aapp num will be in the url --->
	<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral_CCC" returnvariable="qryAAPPResults_CCC"
	aapp = "#url.aapp#"><!--- look up the aapp and set the values to populate the form --->
		<cfoutput query="qryAAPPResults_CCC">
			<cfset form.txtAAPP = aappNum>
			<cfset form.cboFundingOffice = fundingOfficeNum>
			<cfset form.radStatus = contractStatusID>
			<cfset form.cboCenter = "#centerID#__#state#">
			<cfset form.cboState = state>
			<cfset form.txtContractNum = contractNum>
			<cfif not listfind("1,2", session.roleID)><!--- if the user role is not able to edit AAPPs, set to read-only, otherwise, set to edit--->
				<cfset form.hidMode = "readonly">
			<cfelse>
				<cfset form.hidMode = "edit">
			</cfif>
		</cfoutput>
	</cfif>
</cfif>

<!--- perform queries to retrieve reference data to populate drop-down lists --->
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices"
fundingOfficeType = "FED"
returnvariable="rstFundingOffices" />

<cfinvoke component="#application.paths.components#center" method="getCenters"
fundingOfficeType = "FED"
returnvariable="rstCenters">

<cfinvoke component="#application.paths.components#lookup" method="getStates" returnvariable="rstStates" />

</cfsilent>
<cfinclude template="#application.paths.includes#header.cfm" /><!--- include main header --->
<script language="javascript">
function checkCenter(form)
{
	//	when center is changed, if not blank,
	//	auto pop state

	centerVal = form.cboCenter.options[form.cboCenter.selectedIndex].value;
	if (centerVal != '')
		{
		form.cboState.value = centerVal.substr(centerVal.indexOf('__')+2,2);
		}
	else
		{
		form.cboState.selectedIndex = 0;
		}
}

function checkActive(status)
{
	// stop user from creating a new CCC as inactive
	if(document.frmCCC.radStatus[1].checked = 1)
	{
	document.frmCCC.radStatus[0].checked = 1;
	alert('You cannot create a contract as inactive');
	}
}

function warnActive(status)
{	//warn a user before they save a contract as inactive
if(document.frmCCC.radStatus[1].checked = 1)
	{
	<cfif session.roleID neq 2>
		alert('Are you sure you want to make this AAPP inactive? This action can not be undone.');
	</cfif>
	}
}

function makeInactive(status)
{
if(document.frmCCC.radStatus[0].checked = 1)
	{
	document.frmCCC.radStatus[1].checked = 1;
	alert('You cannot edit an inactive contract.');
	}
}

function validateCCC() //validate the form
{
trimFormTextFields(document.frmCCC);
strErrors = '';
	if (document.frmCCC.txtAAPP.value == '')
		{
		strErrors = strErrors + '   - You must enter an AAPP number.\n';
		}
	else if(isNaN(document.frmCCC.txtAAPP.value))
		{
		strErrors = strErrors + '   -  AAPP must be a number.\n';
		}
	else if (!isInteger(document.frmCCC.txtAAPP.value) || document.frmCCC.txtAAPP.value <= 0) //if it's not a postive whole number, stop them
		{
		strErrors = strErrors + '   - AAPP must be a positive integer.\n';
		}
	if(document.frmCCC.cboFundingOffice.selectedIndex == 0)
		{
		strErrors = strErrors + '   - You must choose a Funding Office.\n';
		}
	if(document.frmCCC.cboCenter.selectedIndex == 0)
		{
		strErrors = strErrors + '   - You must choose a Center.\n';
		}
	if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before continuing.\n\n' + strErrors + '\n');
		return false;
		}
	else
		{											//enable the state field before submitting,
		document.frmCCC.cboState.disabled = false;  //otherwise the field won't be submitted
		document.frmCCC.cboFundingOffice.disabled = false;
		return true;
		}
}
</script>
<div class="ctrSubContent">
	<h2>CCC Setup</h2>

	<!--- if validation errors exist, display them --->
	<cfif listLen(lstErrorMessages) neq 0>
		<div class="errorList">
			<cfloop index="listItem" list="#lstErrorMessages#" delimiters="~">
				<cfoutput><li>#listItem#</li></cfoutput>
			</cfloop>
			</div><br />
	</cfif>

	<cfif url.saved is 1>
		<div class="confirmList">
			<li>Your changes have been saved.</li>
		</div><br />
	</cfif>
	<form name="frmCCC" action="<cfoutput>#cgi.script_name#?radAgreementType=CC&aapp=#url.aapp#&hidMode=#form.hidMode#</cfoutput>" method="post" onSubmit="return validateCCC(this.form);"  />
	<input type="hidden" name="hidAgreementTypeCode" value="CC" />
	<input type="hidden" name="hidOrgTypeCode" value="GOV" />
	<input type="hidden" name="hidOrgSubTypeCode" value="GOVFED" />
	<input type="hidden" name="hidMode" value="<cfoutput>#form.hidMode#</cfoutput>" />
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Add or Edit CCC Information">
	<cfif form.hidMode eq "new"><!--- don't show the aapp num for editing --->
		<tr>
			<td style="text-align:right">
				<label for="idAAPP">*AAPP Number</label>
			</td>
			<td>
				<input type="text" name="txtAAPP" size="6" maxlength="5" id="idAAPP" value="<cfoutput>#form.txtAAPP#</cfoutput>"
				tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>"
				<cfif listFindNoCase(lstErrorFields, "txtAAPP", "~")>
					class="errorField"<!--- if this field has an error, highlight it in red --->
				</cfif> />
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</tr>
	<cfelse>
		<input type="hidden" name="txtAAPP" value="<cfoutput>#url.aapp#</cfoutput>" />
	</cfif>
	<tr>
		<td style="text-align:right">
			<label for="idFundOff">*Funding Office</label>
		</td>
		<td>
			<cfoutput>
			<select name="cboFundingOffice" id="idFundOff" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>"
			<cfif request.statusid is 0 or form.hidMode neq "new"> disabled</cfif> />
				<option value="">Choose</option>
				<cfloop query="rstFundingOffices">
					<option value="#fundingOfficeNum#" <cfif fundingOfficeNum eq form.cboFundingOffice>selected</cfif>>
						#fundingOfficeNum# - #fundingOfficeDesc#
					</option>
				</cfloop>
			</select>
			</cfoutput>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td style="text-align:right">
			<label for="idActive">*Status</label>
		</td>
		<td>
			<input type="radio" name="radStatus" id="idActive" value="1" <cfif form.hidMode is "readonly">disabled</cfif>
			<cfif form.radStatus is 1>
				checked="checked"
			</cfif>
			<cfif request.statusid is 0>
				onClick="makeInactive(this);"
			</cfif>
			tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />&nbsp;&nbsp;<label for="idActive">Active</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="radio" name="radStatus" id="idInactive" value="0" <cfif form.radStatus is 0>checked</cfif><cfif form.hidMode is "readonly">disabled</cfif>
			<cfif form.hidMode is "new">
					onClick="checkActive(this);"
			<cfelseif form.radStatus neq 0>
					onClick="warnActive(this);"
			</cfif>
			tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />&nbsp;&nbsp;<label for="idInactive">Inactive</label>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td style="text-align:right"><label for="idAgreementType">Type of Agreement</label></td>
		<td><input type="text" name="txtAgreementType" id="idAgreementType" value="Interagency Agreement" size="25" readonly class="inputReadonly" />
	</tr>
	<tr>
		<td style="text-align:right"><label for="idCenter">*Center</label></td>
		<td>
			<cfoutput>
			<select name="cboCenter" id="idCenter" tabindex="#request.nextTabIndex#"  onChange="checkCenter(this.form);" <cfif request.statusid is 0 or form.hidMode is "readonly"> disabled</cfif>>
				<option value="">Choose</option>
				<cfloop query="rstCenters">
					<cfset optionVal = "#centerID#__#state#">
					<option value="#optionVal#"
						<cfif optionVal eq form.cboCenter>selected</cfif>>
						#centerName#</option>
				</cfloop>
			</select>
			</cfoutput>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>		</td>
	</tr>
	<tr>
		<td style="text-align:right">
			<label for="idState">State</label>		</td>
		<cfoutput>
		<td style="text-align:left;">
			<!--- drop-down list of states --->
			<select name="cboState" id="idState" tabindex="#request.nextTabIndex#" disabled>
				<option value="">Choose</option>
				<cfloop query="rstStates">
					<option value="#state#"
						<cfif state eq form.cboState>selected</cfif>>
						#stateName#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>
	<tr>
		<td style="text-align:right"><label for="idAgreementNum">Agreement Number</label></td>
		<td>
			<input type="text" name="txtContractNum" size="25" value="<cfoutput>#form.txtContractNum#</cfoutput>"
			id="idAgreementNum" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" maxlength="50"  <cfif request.statusid is 0 or form.hidMode is "readonly"> readonly class="inputReadonly"</cfif> />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td style="text-align:right"><label for="idOrgCategory">Organization Category</label></td>
		<td>
			<input type="text" name="txtOrgCategory" value="Federal Government" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" readonly class="inputReadonly" size="25" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</tr>
	</table>
	<cfif request.statusid is 1 and form.hidMode neq "readonly">
	<div class="buttons">
		<input name="btnSubmit" type="submit" value="Save" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<!---<input name="btnReset" type="reset" value="Reset" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />--->
		<input name="btnClear" type="button" value="Reset" onClick="window.location.href=window.location.href"  tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />

		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<cfif url.hidMode is "new">
		<input name="btnCancel" type="button" value="Cancel" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" onClick="javascript:window.location='<cfoutput>#application.paths.root#</cfoutput>'" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfif>
	</div>
	</cfif>
</form>
</div>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />