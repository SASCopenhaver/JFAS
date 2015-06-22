<cfsilent>
<!---
page: aapp_workload_ccc.cfm

description: View and edit workload information for CCCs

revisions:

--->

<cfset request.pageID = "125" /> 
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->
<cfparam name="url.saved" default="0">
<cfparam name="rstAappWorkloadCCC.recordcount" default="">

<cfif isDefined("form.btnSubmit")> <!--- coming from form submittal --->
	<!--- database interaction / server-side validation --->
	<cfinvoke component="#application.paths.components#aapp_workload" method="saveAAPPWorkload_CCC" formData="#form#">
	<cfoutput><!--- redirect to same page with url.saved --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&radAgreementType=CC&saved=1">
	</cfoutput>

<cfelse> <!--- first time viewing form --->	
	<!--- read data from database, set up form fields --->

</cfif>
<!--- if they're just coming into the page, get the information from the database --->
<cfinvoke component="#application.paths.components#aapp_workload" method="getWorkloadData_CCC" aapp="#url.aapp#" 
returnvariable="rstAappWorkloadCCC">


<!--- preform queries to retrieve reference data to populate drop-down lists --->
</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />
<script language="javascript">
function ValidateForm()
{//loop through the input fields, stripping out commas and checking to make sure they're all numeric before submitting
var strErrors = '';
for(var i = 1; i <= <cfoutput>#rstAappWorkloadCCC.recordcount#</cfoutput>; i++)
	{
	var workload = stripCharsInBag(document.frmAAPPWorkload_CCC.elements[i].value, ",");
	if(isNaN(workload))
		{
		strErrors = strErrors + 'Not a number';
		}
	}
if(strErrors != '')
	{
	return false;
	}
else
	{
	return true;
	}
}
</script>				
<div class="ctrSubContent">
	<h2>Workload Information</h2>
	<!--- if they've just saved, show confirmation --->
	<cfif url.saved is 1>
		<div class="confirmList">
			<li>Your changes have been saved.</li>
		</div><br />
	</cfif>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<cfoutput>
	<form name="frmAAPPWorkload_CCC" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&radAgreementType=CC" method="post" onSubmit="return ValidateForm(this);" />
	<input type="hidden" name="hidAappNum" value="#url.aapp#" />
	</cfoutput>
		<tr>
		<cfloop query="rstAappWorkloadCCC"><!--- loop through the workload types to display headers --->
			<th scope="col" style="text-align:left" width="15%">
			<cfoutput>#workloadTypeDesc#</cfoutput>
			</th>
		</cfloop>
		</tr>
		<tr>
		<cfloop query="rstAappWorkloadCCC"><!--- loop through the workload types to display formfields --->
			<td style="text-align:left">
			<cfoutput>
			<input type="text" size="7" name="#workloadTypeCode#__Value" value="#numberformat(value)#" maxlength="6" style="text-align:right"
			<cfif request.statusid is 0>
				readonly class="inputReadonly"
			</cfif>
			onBlur="formatNum(this,2,1);" tabindex="#request.nextTabIndex#" /><!--- when they leave the field, check to make sure it's a number  --->
			</cfoutput>															<!--- if it's not, replace with a zero --->
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
		</tr>
	</table>
	<cfif request.statusid NEQ 0>
	<div class="buttons">
		<input name="btnSubmit" type="Submit" value="Save" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>		
		<input name="btnReset" type="reset" value="Reset" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</div>
	</cfif>
	</form>
</div>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />