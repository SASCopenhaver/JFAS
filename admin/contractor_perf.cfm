<cfsilent>
<!---
page: Contractor_edit.cfm

description: allows user to view / edit Job Corps Contractors

revisions:
	02-05-2007 - rroser - added Low OBS Takeback Rate field
--->
<cfoutput>

<cfset request.pageID = "2430" />
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfif isDefined("form.btnSubmit")>
	<cfinvoke component="#application.paths.components#contractor" method="saveContractorPerf" formData="#form#">
	<cflocation url="#cgi.SCRIPT_NAME#?saved=1">
</cfif>
	
<cfinvoke component="#application.paths.components#contractor" method="getContractorPerf" returnvariable="rstContractorPerf">

<cfset form.txtPerfRating = rstContractorPerf.PerfRating>
<cfset form.txtROPerExel = rstContractorPerf.ROPerExel>
<cfset form.txtROPerReg = rstContractorPerf.ROPerReg>
<cfset form.txtROCapReg = rstContractorPerf.ROCapReg>
<cfset form.txtROPerOACTS = rstContractorPerf.ROPerOACTS>
<cfset form.txtROCapOACTS = rstContractorPerf.ROCapOACTS>
<cfset form.txtLowOBS = rstContractorPerf.lowOBS>

	<cfparam name="variables.lstErrorMessages" default="">
	<cfparam name="variables.lstErrorFields" default="">

</cfoutput>

</cfsilent>

<!--- include header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">

function decFormat(textfield,numPlaces)
{
if(textfield.value != '' && !isNaN(stripCharsInBag(textfield.value, ",")) && textfield.value >= 0)
	{
	formatDecimal(textfield,numPlaces);
	numLimit(textfield, 100);
	}
else if(isNaN(stripCharsInBag(textfield.value, ",")))
	{
	textfield.value = '';
	alert('The value of this field must be number.\n');
	textfield.focus();
	}
else if(textfield.value < 0)
	{
	textfield.value = '';
	alert('The value of this field must be a positive number.\n');
	textfield.focus();
	}	
}

function numFormat(textfield,numberRestrict,forceZero)
{
if(textfield.value != '' && !isNaN(stripCharsInBag(textfield.value, ",")) && textfield.value >= 0)
	{
	formatNum(textfield,numberRestrict,forceZero);
	}
else if(isNaN(stripCharsInBag(textfield.value, ",")))
	{
	textfield.value = '';
	alert('The value of this field must be number.\n');
	textfield.focus();
	}
else if(textfield.value < 0)
	{
	textfield.value = '';
	alert('The value of this field must be a positive number.\n');
	textfield.focus();
	}	
}	

function numLimit(textfield, limit)
{
if(textfield.value > limit)
	{
	alert('The value of this field cannot be greater than 100.\n');
	textfield.value = '';
	textfield.focus();	
	}
}

function formValidation(form)
{
trimFormTextFields(document.frmContractorPerf);
var strErrors = ''
if(document.frmContractorPerf.txtPerfRating.value == '')
	{
	strErrors = strErrors + ' - You must enter a Performance rating threshold.\n';
	}
if(document.frmContractorPerf.txtROPerExel.value == '')
	{
	strErrors = strErrors + ' - You must enter a Rollover cap percentage for contractors ABOVE\nperformance rating threshold (Center Operations)\n';
	}
if(document.frmContractorPerf.txtROPerReg.value == '')
	{
	strErrors = strErrors + ' - You must enter a Rollover cap percentage for contractors BELOW\nperformance rating threshold (Center Operations)\n';
	}
if(document.frmContractorPerf.txtROCapReg.value =='')
	{
	strErrors = strErrors + ' - You must enter a Rollover cap amount ($) for contractors BELOW\nperformance rating threshold (Center Operations)\n';
	}
if(document.frmContractorPerf.txtROPerOACTS.value =='')
	{
	strErrors = strErrors + ' - You must enter a Rollover cap percentage for OA/CTS.\n';
	}
if(document.frmContractorPerf.txtROCapOACTS.value =='')
	{
	strErrors = strErrors + ' - You must enter a Rollover cap amount ($) for OA/CTS.\n';
	}
if(document.frmContractorPerf.txtLowOBS.value =='')
	{
	strErrors = strErrors + ' - You must enter a Low OBS Takeback Rate.\n';
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

<h2>Contractor Performance Ratings and Rollover Rates</h2>
	<cfif variables.lstErrorMessages neq ''>
		<div class="errorList">
		<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters=",">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div><br />
	</cfif>
	<cfif isDefined("url.saved")>
		<div class="confirmList">
		<cfoutput><li>Information saved successfully. Return to <a href="#application.paths.admin#">Admin Section</a>.</li></cfoutput>
		</div><br />
	</cfif>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<form name="frmContractorPerf" action="#cgi.SCRIPT_NAME#" method="post" onsubmit="return formValidation(this.form);">
	<tr>
		<td scope="row" align="right" width="55%">
			<label for="idRating">* Performance rating threshold</label>
		</td>
		<td>
			&nbsp;&nbsp;&nbsp;<input type="text" name="txtPerfRating" id="idRating" size="12" maxlength="4" value="#trim(numberFormat(form.txtPerfRating, "99.9"))#" tabindex="#request.nextTabIndex#" style="text-align:right" onblur="decFormat(this, 1);">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="55%">
			<label for="idROPerExel">* Rollover cap percentage for contractors ABOVE<br />performance rating threshold (Center Operations)</label>
		</td>
		<td>
			&nbsp;&nbsp;&nbsp;<input type="text" name="txtROPerExel" id="idROPerExel" tabindex="#request.nextTabIndex#" value="#trim(numberFormat(form.txtROPerExel, ".99"))#" size="12" maxlength="4" style="text-align:right" onblur="decFormat(this, 2);" />
			<span style="color:##666666">(0.01 = 1%)</span>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="55%">
			<label for="idROPerReg">* Rollover cap percentage for contractors BELOW<br />performance rating threshold (Center Operations)</label>
		</td>
		<td>
			&nbsp;&nbsp;&nbsp;<input type="text" name="txtROPerReg" value="#trim(numberFormat(form.txtROPerReg, ".99"))#" id="idROPerReg" tabindex="#request.nextTabIndex#" size="12" maxlength="4" style="text-align:right" onblur="decFormat(this, 2);" />
			<span style="color:##666666">(0.01 = 1%)</span>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="55%">
			<label for="idROCapReg">* Rollover cap amount ($) for contractors BELOW<br />performance rating threshold (Center Operations)</label>
		</td>
		<td>
			$ <input type="text" name="txtROCapReg" value="#trim(numberFormat(form.txtROCapReg, "9,999,999"))#" id="idROCapReg" tabindex="#request.nextTabIndex#" size="12" maxlength="10" style="text-align:right" onblur="numFormat(this,2,1);" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="55%">
			<label for="idROPerOACTS">* Rollover cap percentage for OA/CTS</label>	
		</td>
		<td>
			&nbsp;&nbsp;&nbsp;<input type="text" name="txtROPerOACTS" value="#trim(numberFormat(form.txtROPerOACTS, ".99"))#" id="idROPerOACTS" tabindex="#request.nextTabIndex#" size="12" maxlength="4" style="text-align:right" onblur="decFormat(this,2);"  />
			<span style="color:##666666">(0.01 = 1%)</span>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="55%">
			<label for="idROCapOACTS">* Rollover cap amount ($) for OA/CTS</label>
		</td>
		<td>
			$ <input type="text" name="txtROCapOACTS" value="#trim(numberFormat(form.txtROCapOACTS, "9,999,999"))#" id="idROCapOACTS" tabindex="#request.nextTabIndex#" size="12" maxlength="10" style="text-align:right" onblur="numFormat(this,2,1);" /> 
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td scope="row" align="right" width="55%">
			<label for="idlowOBS">* Low OBS Takeback Rate</label>	
		</td>
		<td>
			&nbsp;&nbsp;&nbsp;<input type="text" name="txtLowOBS" value="#trim(numberFormat(form.txtLowOBS, ".99"))#" id="idLowOBS" tabindex="#request.nextTabIndex#" size="12" maxlength="4" style="text-align:right" onblur="decFormat(this,2);"  />
			<span style="color:##666666">(0.01 = 1%)</span>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
		<td width="55%">
		</td>
		<td>
			<input type="submit" name="btnSubmit" tabindex="#request.nextTabIndex#" value="Save" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="reset" name="btnReset" tabindex="#request.nextTabIndex#" value="Reset" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="button" name="btnCancel" tabindex="#request.nextTabIndex#" value="Cancel" onclick="location.href='admin_main.cfm'" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
</form>
</table>

</cfoutput>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">