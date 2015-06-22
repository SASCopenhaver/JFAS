<cfsilent>
<!---
page: fpw_inflation.cfm

description: administrative page to view and set federal personnel wages inflation rates

revisions:
2011-05-23	mstein	Fixed 508 issues (release 2.8)

--->

<cfset request.pageID = "2220" />
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->
<cfset form.hidDisplayYears = 10>
<cfset form.hidFirstYear = Evaluate(dateFormat(now(), "YYYY") - 1)>
<cfset lastYear = form.hidFirstYear + form.hidDisplayYears>


<cfif isDefined("form.btnSubmit")> <!--- coming from form submittal --->
<!--- save changes/new rows to the database --->

	<cfloop index="i" from="0" to="#Evaluate(form.hidDisplayYears - 1)#">
		<cfset statusYear = Evaluate(form.hidFirstYear + i)>
		<cfparam name="form.txt_#statusYear#_status" default="0">
	</cfloop>

	<cfinvoke component="#application.paths.components#aapp_inflation" method="saveFpwInflation" formData="#form#" returnvariable="stcResults">

	<cfif stcResults.success>
		<cflocation url="#cgi.SCRIPT_NAME#?saved=true">
	</cfif>

<cfelse> <!--- first time viewing form --->


	<!--- read data from database, set up form fields --->
	<cfparam name="url.saved" default="">

	<!--- Get the records that are in the database now --->
	<cfinvoke component="#application.paths.components#aapp_inflation" method="getFpwInflation"
		firstYear="#form.hidFirstYear#"
		displayYears="#form.hidDisplayYears#"
		returnvariable="rstFpwInflation">

	<!--- loop through query results, setting variable names --->
	<cfloop query="rstFpwInflation">
		<cfset form['txt_' & year & '_calYear'] = year>
		<cfset form['txt_' & year & '_startDate'] = startDate>
		<cfset form['txt_' & year & '_planned'] = ratePlan>
		<cfset form['txt_' & year & '_actual'] = rateAct>
		<cfset form['txt_' & year & '_status'] = status>
	</cfloop>

	<!--- if there are fewer than 10 records, create new rows for the rest --->
	<cfif rstFpwInflation.recordcount lt form.hidDisplayYears>
		<cfset counter = rstFpwInflation.recordcount>
		<cfloop from="#counter#" to="#form.hidDisplayYears#" index="i">
			<cfset form['txt_' & Evaluate(form.hidFirstYear + i) & '_calYear'] = Evaluate(form.hidFirstYear + i)>
			<cfset form['txt_' & Evaluate(form.hidFirstYear + i) & '_startDate'] = '01/01/' & Evaluate(form.hidFirstYear + i)>
			<cfset form['txt_' & Evaluate(form.hidFirstYear + i) & '_planned'] = 0>
			<cfset form['txt_' & Evaluate(form.hidFirstYear + i) & '_actual'] = 0>
			<cfset form['txt_' & Evaluate(form.hidFirstYear + i) & '_status'] = 0>
			<cfset counter = counter + 1>
		</cfloop>

	</cfif>

</cfif>

</cfsilent>





<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">

function lock(status, year)
{
//alert(year);
//alert(status.checked);
//alert(document.frmFpwInflation['txt_' + year + '_status'].value);
if(status.checked == true)
	{
	document.frmFpwInflation['txt_' + year + '_startDate'].className = 'inputReadonly';
	document.frmFpwInflation['txt_' + year + '_startDate'].readOnly = 1;
	document.frmFpwInflation['txt_' + year + '_planned'].className = 'inputReadonly';
	document.frmFpwInflation['txt_' + year + '_planned'].readOnly = 1;
	document.frmFpwInflation['txt_' + year + '_actual'].className = 'inputReadonly';
	document.frmFpwInflation['txt_' + year + '_actual'].readOnly = 1;
	document['img_' + year + '_calendar'].src = "<cfoutput>#application.paths.images#clear.gif</cfoutput>";
	document['img_' + year + '_calendar'].width = "1";
	document['img_' + year + '_calendar'].height  = "1";
	}
else
	{
	document.frmFpwInflation['txt_' + year + '_startDate'].className = 'inputEditable';
	document.frmFpwInflation['txt_' + year + '_startDate'].readOnly = 0;
	document.frmFpwInflation['txt_' + year + '_planned'].className = 'inputEditable';
	document.frmFpwInflation['txt_' + year + '_planned'].readOnly = 0;
	document.frmFpwInflation['txt_' + year + '_actual'].className = 'inputEditable';
	document.frmFpwInflation['txt_' + year + '_actual'].readOnly = 0;
	document['img_' + year + '_calendar'].src = "<cfoutput>#application.paths.images#calendar_icon.gif</cfoutput>";
	document['img_' + year + '_calendar'].width = "16";
	document['img_' + year + '_calendar'].height  = "13";
	}
}

function validDate(year, date)
{
if(limitDate(year, date) != '')
	{
	alert(limitDate(year, date));
	document.frmFpwInflation['txt_' + year + '_startDate'].value = '01/01/' + year;
	}
}

function limitDate(year, date)
{
var strErrors = '';
if(date != '' && Checkdate(date))
	{
	var startDate = new Date('01/01/' + year);
	var endDate = new Date('12/31/' + year);
	var effDate = new Date(date);
	if (effDate < startDate || effDate > endDate)
		{
		strErrors = year + ' Effective Date must be between 01/01/' + year + ' and 12/31/' + year + '.\n';
		}
	}
else
	{
	strErrors = year + ' Effective Date must be valid and in the format mm/dd/yyyy.\n';
	}
return strErrors;
}

function validateForm(form)
{
var strErrors = '';
trimFormTextFields(form);
for (var i=<cfoutput>#form.hidFirstYear#</cfoutput>; i < <cfoutput>#lastYear#</cfoutput>; i++)
	{
	if(limitDate(i, document.frmFpwInflation['txt_' + i + '_startDate'].value) != '')
		{
		strErrors = strErrors + ' - ' + limitDate(i, document.frmFpwInflation['txt_' + i + '_startDate'].value);
		}
	if(document.frmFpwInflation['txt_' + i + '_planned'].value == '')
		{
		strErrors = strErrors + ' - ' + i + ' Planned Pay Increase must be entered.\n';
		}
	if(document.frmFpwInflation['txt_' + i + '_actual'].value == '')
		{
		strErrors = strErrors + ' - ' + i + ' Actual Pay Increase must be entered.\n';
		}
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

	<h2>Federal Personnel Inflation Rates</h2>
<cfoutput>

	<!--- If they submitted without errors, let them know it was saved --->
	<cfif url.saved is "true">
	<div class="confirmList">
	<li>Your changes have been saved.&nbsp;&nbsp;Return to the <a href="#application.paths.admin#">Admin Section</a>.
	</li>
	</div><br />
	</cfif>

	<!--- Start Display Table --->


<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<form name="frmFpwInflation" action="#cgi.SCRIPT_NAME#" method="post" onsubmit="return validateForm(this);" >
	<tr align="center">
		<th scope="row"><br />
			Calendar Year
		</th>
		<th><br />
			Effective Date
		</th>
		<th>
			Planned Pay Increase<br />Per OMB
		</th>
		<th>
			Actual Pay Increase<br />Per Congress
		</th>
		<th><br />
			Locked
		</th>
	</tr>


<!--- loop to show records --->
<cfset rowYear = form.hidFirstYear>
<cfloop index="i" from="0" to="#Evaluate(form.hidDisplayYears - 1)#">
<!--- add i to firstdate to get the start date --->
	<tr <cfif rowYear MOD 2> class="AltRow"</cfif>><!--- alternate row shading based on CalYear --->
		<td scope="row" align="center">
			#form['txt_' & rowYear & '_calYear']#
			<input type="hidden" name="txt_#rowYear#_calYear" value="#form['txt_' & rowYear & '_calYear']#" />
		</td>
		<td align="center"><label for="id#rowYear#StartDate" class="hiddenLabel">Start Date</label>
			<input type="text" name="txt_#rowYear#_startDate" id="id#rowYear#StartDate" size="12" maxlength="10" value="#dateFormat(form['txt_' & rowYear & '_startDate'], "mm/dd/yyyy")#" <cfif form['txt_' & rowYear & '_status'] is 1>readonly class="inputReadonly" <cfelse> class="datepicker" title="Select to specify effective date"  </cfif> onBlur="validDate('#rowYear#', this.value);" tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		<td align="center"><label for="id#rowYear#planned" class="hiddenLabel">Planned</label>
			<input type="text" name="txt_#rowYear#_planned" id="id#rowYear#planned" size="7" maxlength="6" style="text-align:right" value="#trim(numberFormat(form['txt_' & rowYear & '_planned'], 9.999))#" onblur="formatDecimal(this,3);" <cfif form['txt_' & rowYear & '_status'] is 1>readonly class="inputReadonly"</cfif>  tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		<td align="center"><label for="id#rowYear#Actual" class="hiddenLabel">Actual</label>
			<input type="text" name="txt_#rowYear#_actual" id="id#rowYear#actual" size="7" maxlength="6" style="text-align:right" value="#trim(numberFormat(form['txt_' & rowYear & '_actual'], 9.999))#" onblur="formatDecimal(this,3);" <cfif form['txt_' & rowYear & '_status'] is 1>readonly class="inputReadonly"</cfif>  tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		<td align="center"><label for="id#rowYear#Status" class="hiddenLabel">Status</label>
			<input type="checkbox" name="txt_#rowYear#_status" id="id#rowYear#Status" onClick="lock(this, '#rowYear#');" <cfif form['txt_' & rowYear & '_status'] is 1>checked</cfif>  tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<cfset rowYear = rowYear + 1>
</cfloop>
<input type="hidden" name="hidFirstYear" value="#form.hidFirstYear#" /><!--- submit the first date from the query --->
<input type="hidden" name="hidDisplayYears" value="#form.hidDisplayYears#" />
	<tr>
		<td colspan="5" align="right">
			<input name="btnSubmit" type="submit" value="Save" tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input name="btnReset" type="reset" value="Reset"  tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input name="btnCancel" type="button" value="Cancel" onclick="javascript:window.location='#application.paths.admin#'" tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
</form>
</table>
</cfoutput>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />