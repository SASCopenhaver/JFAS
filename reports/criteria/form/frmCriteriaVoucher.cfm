<!--- Voucher Dataset Criteria Form (for use with adhoc tool) --->

<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.txtDateStart" default="">
<cfparam name="form.txtDateEnd" default="">
<cfparam name="form.radOPSCRA" default="All">
<cfparam name="form.radObligationType" default="All">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>

<!--- get reference data for drop-down lists --->
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" returnvariable="rsFundingOffices">

<cfset nextTabIndex = 1>

<cfoutput>
<table width="100%" border="0" align="center" cellpadding="3" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
	<td width="18" valign="top" class="StepNumber">5.</td>
	<td colspan="2">Choose Criteria (filter)</td>
</tr>
<tr><!--- AAPP No. --->
	<td></td>
	<td align="right"><label for="idtxtAAPPNum">AAPP No.:</label></td>
	<td>
		<input type="text" name="txtAAPPNum" id="idtxtAAPPNum" value="#form.txtAAPPNum#" size="12" maxlength="12"  accesskey="l" tabindex="#request.NextTabIndex#"><cfset request.NextTabIndex=request.NextTabIndex+1>
	</td>
</tr>
<tr><!--- Date Vendor Signed --->
	<td></td>
	<td align="right" valign="top"><label for="idDateStart">Date Vendor Signed:</label></td>
	<td>
		<input type="text" size="12" name="txtDateStart" id="idDateStart" value="#form.txtDateStart#"
				accesskey="s" tabindex="#request.nextTabIndex#" maxlength="10" class="datepicker" title="Select to specify start issue date"><cfset request.nextTabIndex=#request.nextTabIndex#+1>
		&nbsp;&nbsp;<label for="idDateEnd">to</label>
		<input type="text" size="12" name="txtDateEnd" id="idDateEnd" value="#form.txtDateEnd#"
				accesskey="e" tabindex="#request.nextTabIndex#" maxlength="10" class="datepicker" title="Select to specify end issue date"><cfset request.nextTabIndex=#request.nextTabIndex#+1>
				&nbsp;&nbsp;(mm/dd/yyyy - leave blank to return all)
	</td>
</tr>
<tr><!--- OPS/CRA --->
	<td width="18"></td>
	<td width="230" align="right" valign="top"><label for="idOPSCRA">Funding Category:</label></td>
	<td>
		<input type="radio" name="radOPSCRA" id="idOPSCRA_all" tabindex="#request.nextTabIndex#" value="All"
			<cfif form.radOPSCRA is "All">checked="checked"</cfif> /><label for="idOPSCRA_all">All&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radOPSCRA" id="idOPSCRA_ops" tabindex="#request.nextTabIndex#" value="OPS"
			<cfif form.radOPSCRA is "OPS">checked="checked"</cfif> /><label for="idOPSCRA_ops">OPS&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radOPSCRA" id="idOPSCRA_cra" tabindex="#request.nextTabIndex#" value="CRA"
			<cfif form.radOPSCRA is "CRA">checked="checked"</cfif> /><label for="idOPSCRA_cra">CRA&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>
<tr><!--- Contract/Purchase Order --->
	<td width="18"></td>
	<td width="230" align="right" valign="top"><label for="idObligationType">Obligation Type:</label></td>
	<td>
		<input type="radio" name="radObligationType" id="idObligationType_all" tabindex="#request.nextTabIndex#" value="All"
			<cfif form.radObligationType is "All">checked="checked"</cfif> /><label for="idObligationType_all">All&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radObligationType" id="idObligationType_contract" tabindex="#request.nextTabIndex#" value="C"
			<cfif form.radObligationType is "C">checked="checked"</cfif> /><label for="idObligationType_contract">Contract&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radObligationType" id="idObligationType_po" tabindex="#request.nextTabIndex#" value="P"
			<cfif form.radObligationType is "P">checked="checked"</cfif> /><label for="idObligationType_po">Purchase Order&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>

</table>
</cfoutput>