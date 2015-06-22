<!---
frmCriteriaFOP.cfm

description: JFAS FOP Dataset Criteria Form (for use with adhoc tool)

revisions:
2007-04-17	mstein	Defect 174 - need to sort Program Years descending
2009-04-01	mstein	add ARRA (stimulus) as criteria
2010-07-01	mstein	Changed Funding Office and Cost Category from drop-down lists to checkboxes
--->


<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.cboPY" default="">
<cfparam name="form.cboCostCategory" default="all">
<cfparam name="form.radARRA" default="All">
<cfparam name="form.cboFundingOffice" default="all">
<cfparam name="form.txtDateStart" default="">
<cfparam name="form.txtDateEnd" default="">
<cfparam name="form.txtKeyword" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>

<!--- get reference data for drop-down lists --->
<cfinvoke component="#application.paths.components#lookup" method="getPY" sortDir="desc" returnvariable="rsPY">
<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" returnvariable="rsCostCategories">
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" returnvariable="rsFundingOffices">

<cfoutput>
<script>
function checkAll(formField)
// automatically selects appropriate transaction types based on user selection
// of obligations, payments, or cost
{

	myField = formField.form[formField.name];
	for (i=1; i < myField.length; i++) {

		if (myField[0].checked) //'All" is checked, so unselect and disable remaining
			{
			myField[i].checked = 0;
			myField[i].disabled = 1;
			}
		else
			myField[i].disabled = 0;
	}
}
</script>


<table width="100%" border="0" align="center" cellpadding="3" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
	<td width="18" valign="top" class="StepNumber">5.</td>
	<td colspan="2">Choose Criteria (filter)</td>
</tr>
<tr>
	<td></td>
	<td align="right"><label for="idtxtAAPPNum">AAPP No.:</label></td>
	<td>
		<input type="text" name="txtAAPPNum" id="idtxtAAPPNum" value="#form.txtAAPPNum#" size="12" maxlength="12"  accesskey="l" tabindex="#request.NextTabIndex#"><cfset request.NextTabIndex=request.NextTabIndex+1>
	</td>
</tr>

<tr valign="top">
	<td width="18"></td>
	<td width="230" align="right"><label for="idFundingOffice">Funding Office</label></td>
	<td width="*">
		<input type="checkbox" name="cboFundingOffice" value="all" id="idFundingOffice_all" tabindex="#request.nextTabIndex#" onClick="checkAll(this);"
				<cfif listFind(form.cboFundingOffice,"all")>checked</cfif>>
		<label for="idFundingOffice_all">All Funding Offices</label><br>
		<cfset request.nextTabIndex=request.nextTabIndex+1>

		<cfloop query="rsFundingOffices">
			<input type="checkbox" name="cboFundingOffice" value="#fundingOfficeNum#" id="idFundingOffice_#fundingOfficeNum#" tabindex="#request.nextTabIndex#"
				<cfif listFind(form.cboFundingOffice,"all")>
					disabled
				<cfelse>
					<cfif listFind(form.cboFundingOffice,fundingOfficeNum)>checked</cfif>
				</cfif>
				>
			<label for="idFundingOffice_#fundingOfficeNum#">#fundingOfficeNum# - #fundingOfficeDesc#</label><br>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		</cfloop>
	</td>
</tr>

<tr>
	<td></td>
	<td align="right"><label for="idPY">Program Year</label></td>
	<td>
		<select name="cboPY" id="idPY" tabindex="#request.nextTabIndex#" accesskey="p">
			<option value="all">All</option>
			<cfloop query="rsPY">
				<option value="#PY#"
					<cfif PY eq form.cboPY>SELECTED</cfif>>#PY#</option>
			</cfloop>
		</select>
		<cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>
<tr valign="top">
	<td></td>
	<td align="right"><label for="idCostCategory">Cost Category</label></td>
	<td>
		<input type="checkbox" name="cboCostCategory" value="all" id="idCostCategory_all" tabindex="#request.nextTabIndex#" onClick="checkAll(this);"
				<cfif listFind(form.cboCostCategory,"all")>checked</cfif>>
		<label for="idCostCategory_all">All Cost Categories</label><br>
		<cfset request.nextTabIndex=request.nextTabIndex+1>

		<cfloop query="rsCostCategories">
			<input type="checkbox" name="cboCostCategory" value="#costCatID#" id="idCostCategory_#costCatID#" tabindex="#request.nextTabIndex#"
				<cfif listFind(form.cboCostCategory,"all")>
					disabled
				<cfelse>
					<cfif listFind(form.cboCostCategory,costCatID)>checked</cfif>
				</cfif>
				>
			<label for="idCostCategory_#costCatID#">#costCatCode# - #costCatDesc#</label><br>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		</cfloop>
	</td>
</tr>
<tr><!--- ARRA --->
	<td width="18"></td>
	<td width="230" align="right" valign="top"><label for="idARRA_all">ARRA:</label></td>
	<td>
		<input type="radio" name="radARRA" id="idARRA" tabindex="#request.nextTabIndex#" value="All" <cfif form.radARRA is "All">checked="checked"</cfif> /><label for="idARRA">All&nbsp;&nbsp;</label>
		<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radARRA" tabindex="#request.nextTabIndex#" value="1" id="idARRA_yes" <cfif form.radARRA eq 1>checked="checked"</cfif> /><label for="idARRA_yes">Yes&nbsp;&nbsp;</label>
		<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radARRA" tabindex="#request.nextTabIndex#" value="0" id="idARRA_no" <cfif form.radARRA eq 0>checked="checked"</cfif> /><label for="idARRA_no">No</label>
		<cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>
<tr>
	<td></td>
	<td align="right" valign="top"><label for="idDateStart">Date Issued:</label></td>
	<td>

	<!--- comment out old way
		<input type="text" size="12" name="txtDateStart" id="idDateStart" value="#form.txtDateStart#"
				accesskey="s" tabindex="#request.nextTabIndex#" maxlength="10" ><cfset request.nextTabIndex=#request.nextTabIndex#+1>
				<a href="javascript:MS_ShowFieldPopCalendar(document.frmSelectCriteria.txtDateStart, 'M/D/Y')">
				<img src="#application.paths.images#calendar_icon.gif" border="0"
				alt="Select to specify start issue date" width="16" height="13" /></a>
		&nbsp;&nbsp;<label for="idDateEnd">to</label>
		<input type="text" size="12" name="txtDateEnd" id="idDateEnd" value="#form.txtDateEnd#"
				accesskey="e" tabindex="#request.nextTabIndex#" maxlength="10"><cfset request.nextTabIndex=#request.nextTabIndex#+1>
				<a href="javascript:MS_ShowFieldPopCalendar(document.frmSelectCriteria.txtDateEnd, 'M/D/Y')">
				<img src="#application.paths.images#calendar_icon.gif" border="0"
				alt="Select to specify end issue date" width="16" height="13" /></a>
				&nbsp;&nbsp;(mm/dd/yyyy - leave blank to return all)
		end of comment out old way --->

		<input type="text" size="12" name="txtDateStart" id="idDateStart"
				value="#form.txtDateStart#"	accesskey="s" tabindex="#request.nextTabIndex#"
				maxlength="10"
				class="datepicker" title="Select to specify start issue date"><cfset request.nextTabIndex=#request.nextTabIndex#+1>
		&nbsp;&nbsp;<label for="idDateEnd">to</label>
		<input type="text" size="12" name="txtDateEnd" id="idDateEnd"
				value="#form.txtDateEnd#" accesskey="e" tabindex="#request.nextTabIndex#"
				maxlength="10"
				class="datepicker" title="Select to specify end issue date"><cfset request.nextTabIndex=#request.nextTabIndex#+1>
				&nbsp;&nbsp;(mm/dd/yyyy - leave blank to return all)

	</td>
</tr>
<tr>
	<td></td>
	<td align="right"><label for="idKeyword">Keyword:</label></td>
	<td>
		<input type="text" name="txtKeyword" id="idKeyword" value="#form.txtKeyword#" size="40" maxlength="50"  accesskey="k" tabindex="#request.NextTabIndex#"><cfset request.NextTabIndex=request.NextTabIndex+1>
	</td>
</tr>
</table>
</cfoutput>