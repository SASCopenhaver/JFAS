<cfsilent>
<!---
page: aapp_deleteunfunded.cfm

description: Allows the user to delete an unfunded AAPP

revisions:

--->

<cfset request.pageID = "2470" /> 
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->

<cfif isDefined("form.hidMode")> <!--- coming from form submittal --->
	
	<!--- database interaction / server-side validation --->
	<cfinvoke component="#application.paths.components#dataadmin" method="deleteUnfundedAAPP" aappNum="#listfirst(form.cboAAPPNum,"~~")#" returnvariable="stcResults">
	<cfif stcResults.success>
		<cflocation url="#cgi.SCRIPT_NAME#?saved=yes">		
	<cfelse>
		<cfset variables.lstErrorMessages = stcResults.errorMessages>
	</cfif>
		
<cfelse> <!--- first time to form --->

	<!--- set up form fields --->
	<cfset form.hidMode = "edit">
	<cfset form.cboAAPPNum = "">
	<cfset form.txtProgramActivity = "">
	<cfset form.txtCenterName = "">
	<cfset form.txtDateStart = "">
	
</cfif>

<!--- get list of unfunded AAPPs --->
<cfinvoke component="#application.paths.components#dataadmin" method="getUnfundedAAPPs" returnvariable="rstUnfundedAAPP">
</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">

function showAAPPInfo(form)
{
	// populate form fields based on user's selection of AAPP number
	form.txtProgramActivity.value = '';
	form.txtDateStart.value = '';
	form.txtCenterName.value = '';
	
	myOptVal = form.cboAAPPNum.options[form.cboAAPPNum.selectedIndex].value; 			
	arrAAPPInfo = myOptVal.split('~~'); 
	form.txtProgramActivity.value = arrAAPPInfo[1];
	form.txtDateStart.value = arrAAPPInfo[2];
	form.txtCenterName.value = arrAAPPInfo[3];
}

function ValidateForm(form)
{
	
	// trim text fields
	trimFormTextFields(form);
	strErrors= '';
	
	// description is required
	if (form.cboAAPPNum.selectedIndex == 0)
		strErrors = strErrors + '   - Please select an AAPP Number.\n';
		
	if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before saving.\n\n' + strErrors + '\n');
		return false
		}
	else
		{
		if (confirm('Are you sure you want to delete AAPP ' + form.cboAAPPNum.options[form.cboAAPPNum.selectedIndex].text + '? This action can not be undone.'))
			return true
		else
			return false;
		}
		
	
}

</script>
				

<h2>Remove an Unfunded AAPP</h2>

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
	<cfoutput><li>AAPP successfully deleted.&nbsp;&nbsp;Return to the <a href="#application.paths.admin#">Admin Section</a></li></cfoutput>
	</div><br />
</cfif>

	
	<!--- Start Form --->
	<form name="frmDeleteAAPP"  action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" onSubmit="return ValidateForm(this);">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Data form for deleting unfunded AAPPs">
	<cfoutput>
	<tr>
		<td align="right">
			<label for="idAAPPNum">AAPP No.:</label>
		</td>
		<td>
			<select name="cboAAPPNum" id="idAAPPNum" onchange="showAAPPInfo(this.form);" tabindex="#request.nextTabIndex#">
				<option value="">Select an AAPP...</option>
				<cfloop query="rstUnfundedAAPP">
					<option value="#aappNum#~~#programActivity#~~#dateformat(dateStart, "mm/dd/yyyy")#~~#centerName#">#aappNum#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr valign="top">
		<td align="right">
			<label for="idProgramActivity">Program Activity:</label>
		</td>
		<td>
			<textarea id="idProgramActivity" name="txtProgramActivity" tabindex="#request.nextTabIndex#" readonly class="inputReadonly"
			rows="3" cols="65">#form.txtProgramActivity#</textarea>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td align="right">
			<label for="idCenterName">Center:</label>
		</td>
		<td>
			<input type="text" id="idCenterName" name="txtCenterName" value="#form.txtCenterName#" size="40"
			readonly class="inputReadonly"tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td align="right">
			<label for="idDateStart">Start Date:</label>
		</td>
		<td>
			<input type="text" id="idDateStart" name="txtDateStart" value="#form.txtDateStart#" size="12"
			readonly class="inputReadonly"tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
		
	</cfoutput>
	</table>
	
	<cfoutput>
	<input type="hidden" name="hidMode" value="#form.hidMode#" />
	<div class="buttons">
		<input name="btnSubmit" type="Submit" value="Delete AAPP" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input name="btnReset" type="button" value="Reset" tabindex="#request.nextTabIndex#" onClick="window.location.href='#cgi.SCRIPT_NAME#';" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='#application.paths.admin#'" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</div>
	</form>
	</cfoutput>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />