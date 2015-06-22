<cfsilent>
<!---
page: ba_transfer_edit.cfm

description: data entry form... allows user to edit Budget Authorization Transfer Percentages (for reports)

revisions:

--->

<cfset request.pageID = "2460" /> 
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfset variables.baType = "CCC"> <!--- in the future, there may be other categories of BA percentages --->

<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->

<cfif isDefined("form.hidMode")> <!--- coming from form submittal --->
	
	<!--- database interaction / server-side validation --->
	<cfinvoke component="#application.paths.components#dataadmin" method="saveBATRansferPercent" formData="#form#" returnvariable="stcResults">
	<cfif stcResults.success>
		<cflocation url="#cgi.SCRIPT_NAME#?saved=yes">		
	<cfelse>
		<cfset variables.lstErrorMessages = stcResults.errorMessages>
	</cfif>
		
<cfelse> <!--- first time to form --->

	<cfset form.hidMode = "edit">
	<cfinvoke component="#application.paths.components#dataadmin" method="getBATransferPercent" baType="#variables.baType#" returnvariable="rstBATransferPercent">
	<cfset form.hidCostCatList = valuelist(rstBATransferPercent.costCatID)>
	<cfset form.hidBAtype = variables.baType>
	<cfset form.hidMode = "edit">
	
	<!--- loop through percent values, create form field for each --->
	<cfloop query="rstBATransferPercent">			
		<cfset form[costCatID & "_code"] = costCatCode>
		<cfset form[costCatID & "_desc"] = costCatDesc>
		<cfset form[costCatID & "_q1"] = q1>
		<cfset form[costCatID & "_q2"] = q2>
		<cfset form[costCatID & "_q3"] = q3>
		<cfset form[costCatID & "_q4"] = q4>
	</cfloop>
	
</cfif>

</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">


function ValidateForm(form)
{
	// trim text fields
	trimFormTextFields(form);
	strErrors= '';
	
	if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before saving.\n\n' + strErrors + '\n');
		return false
		}
	else
		return true;
}

</script>
				
<cfoutput>
<h2>#ucase(variables.baType)# Budget Auth. Transfer Percentages</h2>
</cfoutput>

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
	<cfoutput><li>Information saved successfully.&nbsp;&nbsp;Return to the <a href="#application.paths.admin#">Admin Section</a></li></cfoutput>
	</div><br />
</cfif>

	<!--- Start Form --->
	<form name="frmBAPercent"  action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" onSubmit="return ValidateForm(this);">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="BA Percentage Infrmation">
	<cfoutput>
	
	<tr>
		<th scope="col" colspan="3">Cost Category</th>
		<th scope="col">Quarter 1</th>
		<th scope="col">Quarter 2</th>
		<th scope="col">Quarter 3</th>
		<th scope="col">Quarter 4</th>
		<th></th>
	</tr>
	<cfloop list="#form.hidCostCatList#" index="costCatID">
		<tr>
			<td width="3%"></td>
			<td width="5%">
				#form[costCatID & "_code"]#
				<input type="hidden" name="#costCatID#_code" value="#form[costCatID & "_code"]#" />
			</td>
			<td width="22%">
				<label for="id_#costCatID#_q1">#form[costCatID & "_desc"]#</label>
				<input type="hidden" name="#costCatID#_desc" value="#form[costCatID & "_desc"]#" />
			</td>
			<cfloop index="q" from="1" to="4">
				<td width="15%" align="center">
					<cfif q gt 1>
						<label for="id_#costCatID#_q#q#" class="hiddenLabel">#form[costCatID & "_desc"]# Quarter #q# Transfer Percent</label>
					</cfif>
					<input type="textbox" name="#costCatID#_q#q#" id="id_#costCatID#_q#q#" value="#form[costCatID & "_q" & q]#"
					size="8" maxlength="4" onBlur="formatDecimal(this, 2);" tabindex="#request.nextTabIndex#" style="text-align:right" />
					<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</td>
			</cfloop>
			<td width="10%"><span style="color:##666666">(0.01 = 1%)</span></td>
		</tr>
	</cfloop>	
	</cfoutput>
	</table>
	
	<cfoutput>
	<input type="hidden" name="hidMode" value="#form.hidMode#" />
	<input type="hidden" name="hidCostCatList" value="#form.hidCostCatList#" />
	<input type="hidden" name="hidBAtype" value="#form.hidBAtype#" />
	<div class="buttons">
		<input name="btnSubmit" type="Submit" value="Save" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input name="btnReset" type="reset" value="Reset" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>	
		<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='#application.paths.admin#';" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</div>
	</form>
	</cfoutput>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />