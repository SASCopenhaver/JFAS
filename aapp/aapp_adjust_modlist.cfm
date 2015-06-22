<cfsilent>
<!---
page: aapp_adjust_modlist.cfm

description: listing for Funding Adjustment Tab, that lists by MOD

revisions:
2007-01-09	yjeng	Change mod # max length = 3
2007-01-12	mstein	Changed parameter "frompage" in form for "Add FOP/Estimated Cost" button
2007-07-27	yjeng	To current year + 1
--->
<cfset request.pageID = "330" />

<cfif isDefined("form.btnSave")> <!--- form submitted --->
	<!--- save AAPP Summary data --->
	<cfinvoke component="#application.paths.components#aapp_adjustment" method="saveModFormData" formData="#form#" returnvariable="stcAdjustmentSaveResults" />

	<cfif stcAdjustmentSaveResults.success>
		<!--- if save was successful, then redirect back to this page in edit mode --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#request.aapp#&save=1" />
	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfset variables.lstErrorMessages = stcAdjustmentSaveResults.errorMessages />
		<cfset variables.lstErrorFields = stcAdjustmentSaveResults.errorFields />
	</cfif>
<cfelse> <!--- first time viewing form --->
	<cfset SortBy="contract_year">
	<cfinvoke component="#application.paths.components#aapp" method="getAAPPCurrentContractYear" aapp="#request.aapp#" returnvariable="cy" />
	<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileSort" aapp="#request.aapp#" sortBy="#SortBy#" sortDir="desc" contract_type_code="" contract_year="#evaluate(cy+1)#" returnvariable="rstEstCostProfileSort" />
	<cfquery name="typeList" dbtype="query">
		select	distinct contract_type_code
		from	rstEstCostProfileSort
	</cfquery>
</cfif>

</cfsilent>



<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">
<script language="javascript1.1" type="text/javascript">
function clearForm () {
	var target='mod_';
	for (i=0;i<document.form1.elements.length; i++) {
		if (document.form1.elements[i].name.indexOf(target)!=-1) {
			document.form1.elements[i].value='';
		}
	}
}
function validateForm (s,t) {
	if (t=='form') {
		for (i=0;i<s.elements.length; i++) {
			if (s.elements[i].name.indexOf('mod_')!=-1) {
				if (s.elements[i].value.length > 0 && !isInteger(s.elements[i].value)) {
					s.elements[i].value='';
					s.elements[i].focus();
					return false;
				}
			}
		}
		return true;
	}
	else {
		if (s.value.length > 0 && !isInteger(s.value)) {
			alert ("Mod # need to be integer!");
			s.value='';
			return false;
		}
	}
}
</script>
<div class="ctrSubContent">
	<h2>Mods</h2>

<cfif request.statusID eq 1> <!--- for active aapp, allow user to add adjustment --->
	<div class="btnRight">
	<cfoutput>
	<form name="frmAddAdjustment" action="aapp_adjust.cfm" method="get" STYLE="DISPLAY:INLINE;">
	<input name="btnAddAdjustment" type="submit" value="Add FOP/Estimated Cost" />
	<input type="hidden" name="aapp" value="#url.aapp#" />
	<input type="hidden" name="adjustID" value="0" />
	<input type="hidden" name="frompage" value="#cgi.SCRIPT_NAME#" />
	</form>
	<form name="frmReportCriteria" action="#application.paths.reportdir#reports.cfm?rpt_id=2" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports" STYLE="DISPLAY:INLINE;">
	<input type="hidden" name="AAPP" value="#request.aapp#"/>
	<input type="hidden" name="chkCostCat" value="#valuelist(typeList.contract_type_code)#" />
	<input type="hidden" name="radReportFormat" value="application/pdf" />
	<input name="btnGenerateReport" type="submit" value="Print ECP Report" />
	</form>
	</cfoutput>
	</div>
</cfif>
<cfinclude template="#application.paths.includes#error_list.cfm">
<cfoutput>
<form name="frmModList" action="#cgi.SCRIPT_NAME#?aapp=#request.aapp#" method="post" onsubmit="return validateForm(this,'form')">
</cfoutput>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
<tr>
	<th scope="col">Contract Year</th>
	<th scope="col">Mod # </th>
	<th scope="col">Cost Category</th>
	<th scope="col">Description </th>
	<th scope="col" style="text-align:right;">Amount</th>
</tr>
<cfoutput query="rstEstCostProfileSort" group="#SortBy#">
	<cfif currentrow neq 1>
	<tr>
		<td colspan="5" class="hrule"></td>
	</tr>
	</cfif>
	<cfoutput>
	<tr<cfif currentrow mod 2> class="AltRow"</cfif>>
		<td align="center">#contract_year#</td>
		<td align="center">
			<cfif mod_num neq 0 and mod_num neq "--">
			<label for="id#request.aapp#_mod_#adjustment_id#_#contract_year#_#amount#_#fixed#" class="hiddenLabel">Mod Number Input, AAPP #request.aapp# Year #contract_year#, Contract Type #contract_type_code#</label>
			<input name="mod_#adjustment_id#_#contract_year#_#amount#_#fixed#" value="#mod_num#" size="3" maxlength="3" tabindex="#request.nextTabIndex#" id="id#request.aapp#_mod_#adjustment_id#_#contract_year#_#amount#_#fixed#" onChange="validateForm(this,'field');" <cfif request.statusid eq 0>readonly class="inputReadonly"</cfif>>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<cfelse>
			#mod_num#
			</cfif>
		</td>
		<td>#contract_type_code#</td>
		<td>
			<cfif adjustment_type_code eq "ADJ">
				<a href="aapp_adjust.cfm?aapp=#request.aapp#&adjustID=#adjustment_id#">#description#</a>
			<cfelse>
				#description#
			</cfif>
		</td>
		<td style="text-align:right;">$#numberformat(amount,",")#</td>
	</tr>
	</cfoutput>
</cfoutput>
</table>
<cfif request.statusid>
<div class="buttons">
	<input name="btnSave" type="submit" value="Save" />
	<input type="reset" name="btnReset" value="Reset"  />
	<input name="hidMode" type="hidden" value="update">
</div>
</cfif>
</form>
</div>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

