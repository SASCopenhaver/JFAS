<cfsilent>
<!---
page: rcccode_list.cfm.cfm

description: allows user to view / add rcc codes. displays by fiscal year

revisions:
2007-07-24	mstein	Added in capability to have non-expiring (9999) funds
2009-03-18	mstein	Added column for ARRA (stimulus) indicator
--->

<cfset request.pageID = "2440" />
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->
<cfif not isDefined("url.fy")>
	<cfset currentFY = application.outility.getYear_byDate(yearType="F" )>
	<cfset url.fy = currentFY>
</cfif>
<!--- get current system program year --->
<cfset currentPY = application.outility.getCurrentSystemProgramYear ()>
<cfif isDefined("form.hidMode")> <!--- coming from form submittal --->

	<!--- database interaction / server-side validation --->
	<cfinvoke component="#application.paths.components#dataadmin" method="saveRCCCode" formData="#form#" returnvariable="stcResults">
	<cfif stcResults.success>
		<!--- if successful, reload as an edit page --->
		<cflocation url="#cgi.SCRIPT_NAME#?fy=#url.fy#&saved=1">
	<cfelse>
		<cfset variables.lstErrorMessages = stcResults.errorMessages>
	</cfif>

<cfelse>

	<cfset form.rccOrg = "">
	<cfset form.rccFund = "">
	<cfset form.opscra = "OPS">
	<cfset form.arra_ind = 0>
	<cfif currentPY gt url.fy>
		<cfset setPY = url.fy>
	<cfelse>
		<cfset setPY = currentPY>
	</cfif>
	<cfset form.appropPY = setPY>
	<cfset form.lastPY = setPY>
	<cfset form.fundingOfficeNum = "">
	<cfset form.proj1Code = "">
	<cfset form.hidMode = "add">
</cfif>

<!--- get list of existing rcc codes for specified fiscal year --->
<cfinvoke component="#application.paths.components#dataadmin" method="getRCCCodeList" fy="#url.fy#" returnvariable="rstRCCCodeList">
<!--- get list of distinct FYs from RCC Table --->
<cfinvoke component="#application.paths.components#dataadmin" method="getRCCfyList" returnvariable="rstRCCfyList">
<!--- get list of funding offices --->
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" returnvariable="rstFundingOffices">
<!--- get list of distinct Proj1Codes for dropdown --->
<cfinvoke component="#application.paths.components#lookup" method="getProj1Codes" returnvariable="rstProj1Codes">
</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">

function ValidateForm(form)
{
	// trim text fields
	trimFormTextFields(form);
	strErrors= '';

	if (form.hidMode.value == 'add')
		{
		// RCC Org is required
		if (form.rccOrg.value == '')
			strErrors = strErrors + '   - RCC Org must be entered.\n';

		// RCC Fund is required
		if (form.rccFund.value == '')
			strErrors = strErrors + '   - RCC Fund must be entered.\n';

		// Proj1 Code can't be "Add New"
		if (form.Proj1Code.options[document.frmAddRCC.Proj1Code.selectedIndex].value == 'Add New')
			strErrors = strErrors + '   - Project 1 Code must be entered.\n';

		if (strErrors != '')
		{
			alert('The following problems have occurred. Please fix these errors before saving.\n\n' + strErrors + '\n');
			return false
			}
		else
			return true;
		}

	else if (form.hidMode.value == 'delete')
		{
		if (confirm('Are you sure you want to delete this RCC Code? This action can not be undone.'))
			return true;
		else
			return false;
		}


}

function addProj1()
{
if (document.frmAddRCC.Proj1Code.options[document.frmAddRCC.Proj1Code.selectedIndex].value == 'Add New')
	{
	var newProj1Code = trim(prompt("Enter New Project 1 Code", ""));
	Proj1Length(newProj1Code);
	}
}

function Proj1Length(Proj1)
{
if(Proj1 == '' || Proj1 == 'null')
	{
	document.frmAddRCC.Proj1Code.selectedIndex = 0;
	}
else if(Proj1.length > 5)
	{
	var Proj1 = trim(prompt("Enter New Project 1 Code\nProject 1 Code must be 5 characters or less.", ""));
	Proj1Length(Proj1);
	}
else
	{
	setNewCode(Proj1);
	}
}

function setNewCode(newProj1Code)
{
document.frmAddRCC.Proj1Code.options[<cfoutput>#rstProj1Codes.recordcount#</cfoutput>].value = newProj1Code.toUpperCase();
document.frmAddRCC.Proj1Code.options[<cfoutput>#rstProj1Codes.recordcount#</cfoutput>].text = newProj1Code.toUpperCase();5
document.frmAddRCC.Proj1Code.options[<cfoutput>#rstProj1Codes.recordcount#</cfoutput> + 1] = new Option('Add New','Add New');
document.frmAddRCC.Proj1Code.selectedIndex = <cfoutput>#rstProj1Codes.recordcount#</cfoutput>;
}

</script>

<h2>RCC Codes</h2>
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
	<cfoutput><li>Information Saved Successfully. Return to the <a href="<cfoutput>#application.paths.admin#</cfoutput>">Admin Section</a></li></cfoutput>
	</div><br />
</cfif>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Table used for layout">
<tr>
	<cfoutput>
	<form name="frmFilterbyFY" action="#cgi.SCRIPT_NAME#?fy=#url.fy#" method="get">
	<td align="right">

		<label for="idFYfilter">Fiscal Year</label>:
		<select name="fy" id="idFYfilter" tabindex="#request.nextTabIndex#">
			<cfset tempFY=0>
			<cfloop query="rstRCCfyList">
				<option value="#fy#" <cfif fy eq url.fy>selected</cfif>>#fy#</option>
				<cfset tempFY=fy>
			</cfloop>
			<option value="#evaluate(tempFY+1)#" <cfif (tempFY+1) eq url.fy>selected</cfif>>#evaluate(tempFY+1)#</option>
		</select>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input type="submit" name="btnSubmit" value="Go" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>

	</td>
	</form>
	</cfoutput>
</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Display list of SMB Categories">
<tr>
	<th scope="col">FY</th>
	<th scope="col">RCC Org</th>
	<th scope="col">RCC Fund</th>
	<th scope="col">OPS/CRA</th>
	<th scope="col">ARRA?</th>
	<th scope="col">Approp. PY</th>
	<th scope="col">Last Oblig PY</th>
	<th scope="col">Funding Office</th>
	<th scope="col">Project 1 Code</th>
	<th></th>
</tr>
	<cfoutput query="rstRCCCodeList">
		<form action="#cgi.SCRIPT_NAME#?fy=#url.fy#" method="post" onsubmit="return ValidateForm(this);">
		<tr <cfif not (currentRow mod 2)>class="AltRow"</cfif>>
			<td align="center">#url.fy#</td>
			<td align="center">#rccOrg#</td>
			<td align="center">#rccFund#</td>
			<td align="center">#opscra#</td>
			<td align="center"><cfif arra_ind>Yes</cfif></td>
			<td align="center">#appropPY#</td>
			<td align="center"><cfif lastPY eq 9999><span style="color:##999999">no expiration</span><cfelse>#lastPY#</cfif></td>
			<td align="center">#fundingOfficeNum#</td>
			<td align="center">#proj1Code#</td>
			<td>
				<cfif not rccUsed>
					<input type="image" name="btnSubmit" tabindex="#request.nextTabIndex#" alt="Delete this RCC Code"
					src="#application.paths.images#delete_icon.gif" height="13" width="13" />
					<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</cfif>
			</td>
		</tr>
		<input type="hidden" name="rccOrg" value="#rccOrg#" />
		<input type="hidden" name="rccFund" value="#rccFund#" />
		<input type="hidden" name="fy" value="#fy#" />
		<input type="hidden" name="hidMode" value="delete" />

		</form>
	</cfoutput>

	<cfoutput>
	<form name="frmAddRCC" action="#cgi.SCRIPT_NAME#?fy=#url.fy#" method="post" onsubmit="return ValidateForm(this);">
		<tr <cfif not ((rstRCCCodeList.recordcount + 1) mod 2)>class="AltRow"</cfif>>
			<td align="center">#url.fy#</td>
			<td align="center">
				<label for="idrccOrg" class="hiddenLabel">RCC Org</label>
				<input type="text" name="rccOrg" value="#form.rccOrg#" id="idrccOrg" size="6" maxlength="4" tabindex="#request.nexttabindex#"
				onBlur="this.value = this.value.toUpperCase();"/>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
			<td align="center">
				<label for="idrccFund" class="hiddenLabel">RCC Fund</label>
				<input type="text" name="rccFund" value="#form.rccFund#" id="idrccFund" size="6" maxlength="4" tabindex="#request.nexttabindex#"
				onBlur="this.value = this.value.toUpperCase();" />
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
			<td align="center">
				<label for="idOpsCra" class="hiddenLabel">OPS/CRA</label>
				<select name="opscra" id="idOpsCra" tabindex="#request.nexttabindex#" />
				<option value="OPS" <cfif form.opscra eq "OPS">selected</cfif>>OPS</option>
				<option value="CRA" <cfif form.opscra eq "CRA">selected</cfif>>CRA</option>
				</select>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
			<td align="center">
				<label for="idARRA_ind" class="hiddenLabel">ARRA?</label>
				<select name="arra_ind" id="idARRA_ind" tabindex="#request.nexttabindex#" />
				<option value="0" <cfif form.arra_ind eq 0>selected</cfif>>No</option>
				<option value="1" <cfif form.arra_ind eq 1>selected</cfif>>Yes</option>
				</select>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
			<td align="center">
				<label for="idAppropPY" class="hiddenLabel">Appropriation PY</label>
				<select name="appropPY" id="idAppropPY" tabindex="#request.nexttabindex#" />
				<cfloop index="pyItem" from="#min(url.fy,evaluate(currentPY-3))#" to="#evaluate(currentPY+3)#">
					<option value="#pyItem#" <cfif form.appropPY eq pyItem>selected</cfif>>#pyItem#</option>
				</cfloop>
				</select>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
			<td align="center">
				<label for="idLastPY" class="hiddenLabel">Last Obligation PY</label>
				<select name="lastPY" id="idLastPY" tabindex="#request.nexttabindex#" />
				<cfloop index="pyItem" from="#min(url.fy,evaluate(currentPY-3))#" to="#evaluate(currentPY+3)#">
					<option value="#pyItem#" <cfif form.lastPY eq pyItem>selected</cfif>>#pyItem#</option>
				</cfloop>
				<option value="9999" <cfif form.lastPY eq 9999>selected</cfif>>no expiration</option>
				</select>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
			<td align="center">
				<label for="idFundingOfficeNum" class="hiddenLabel">Last Obligation PY</label>
				<select name="fundingOfficeNum" id="idFundingOfficeNum" tabindex="#request.nexttabindex#" />
				<cfloop query="rstFundingOffices">
					<option value="#fundingOfficeNum#" <cfif form.fundingOfficeNum eq fundingOfficeNum>selected</cfif>>#fundingOfficeNum#</option>
				</cfloop>
				</select>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
			<td align="center">
				<label for="idProj1Code" class="hiddenLabel">Project 1 Code</label>
				<select name="Proj1Code" id="idProj1Code" tabindex="#request.nexttabindex#" onChange="addProj1();">
					<cfloop query="rstProj1Codes">
						<option value="#Proj1Code#"<cfif form.Proj1Code is Proj1Code>selected</cfif>>#Proj1Code#</option>
					</cfloop>
					<option value="Add New">Add New</option>
				</select>

				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
			<td width="50">
				<input type="hidden" name="hidMode" value="add" />
				<input type="hidden" name="fy" value="#url.fy#" />
				<input type="submit" name="btnSubmit" value="Add" tabindex="#request.nexttabindex#" />
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</tr>
		</form>
		</cfoutput>
</table>

<cfif form.hidMode eq "add">
<script>document.frmAddRCC.rccOrg.focus();</script>
</cfif>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />