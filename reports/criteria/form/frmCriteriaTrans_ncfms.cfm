<!---
page: frmCriteriaTrans_ncfms.cfm

description: JFAS NCFMS Footprint Transaction Dataset Criteria Form (for use with adhoc tool)

revisions:
2010-01-05	mstein	File Created
2011-08-11	mstein	No longer defaulting FY to current year
2011-08-19	mstein	Adding missing label tags (508 review)
--->

<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.txtEndDate" default="">
<cfparam name="form.txtStartDate" default="">
<cfparam name="form.cboFY" default="">
<cfparam name="form.radFundCat" default="All">
<cfparam name="form.ckbTransType" default="">
<cfparam name="form.txtVendor" default="">
<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>


<script>

function selectTransTypes(form, area)
// automatically selects appropriate transaction types based on user selection
// of obligations, payments, or cost
{
	for (i=0; i < form.ckbTransType.length; i++) {
		form.ckbTransType[i].checked = 0;
		myType = form.ckbTransType[i].value;
		if (area == 'All') form.ckbTransType[i].checked = 1;
		if (area == 'O' && (myType == 'UDO' || myType == 'ACC' || myType == 'ADV' || myType == 'PE' || myType == 'UPE' || myType == 'OBL'))
			form.ckbTransType[i].checked = 1;
		if (area == 'P' && (myType == 'ADV' || myType == 'PE' || myType == 'PAY'))
			form.ckbTransType[i].checked = 1;
		if (area == 'C' && (myType == 'PE' || myType == 'UPE' || myType == 'CST'))
			form.ckbTransType[i].checked = 1;
	}
}

</script>

<!--- get reference data for drop-down lists --->
<cfquery name="rsFY" datasource="#request.dsn#">
select 	distinct(appropfy)
from	footprint_ncfms_dataset
order	by 1
</cfquery>
<cfinvoke component="#application.paths.components#lookup" method="getNCFMSTransTypes" returnvariable="rsNCFMSTransTypes">

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
		<input type="text" name="txtAAPPNum" id="idtxtAAPPNum" value="#form.txtAAPPNum#" size="20" maxlength="12">
	</td>
</tr>
<tr><!--- FY --->
	<td></td>
	<td align="right"><label for="idFY">Footprint Fiscal Year</label></td>
	<td>
		<select name="cboFY" id="idFY">
			<option value="">All
			<cfloop query="rsFY">
				<option value="#appropfy#">#appropfy#
			</cfloop>
		</select>
	</td>
</tr>
<tr><!---Transaction Date --->
	<td width="18"></td>
	<td width="230" align="right" valign="top"><label for="idDate">Transaction Date Range:</label></td>
	<td>
		<input type="text" name="txtStartDate" size="15" id="idDate" value="#form.txtStartDate#" class="datepicker"/>

		<label for="idDateEnd">&nbsp;to&nbsp;</label>
		<input type="text" name="txtEndDate" size="15" id="idDateEnd" value="#form.txtEndDate#" class="datepicker" />

	</td>
</tr>

<tr><!---Transaction type: UDO, ADV, etc... --->
	<td width="18"></td>
	<td width="230" align="right" valign="top">
		<label for="idTT">Transaction Type(s):</label>
		<br /><br />
		Click any of the following links to&nbsp;&nbsp;<br />
		automatically select the appropriate&nbsp;&nbsp;<br />
		transaction types associated with&nbsp;&nbsp;<br />
		<a href="javascript:selectTransTypes(document.frmSelectCriteria,'O');">Obligations</a>,
		<a href="javascript:selectTransTypes(document.frmSelectCriteria,'P');">Payments</a>, or
		<a href="javascript:selectTransTypes(document.frmSelectCriteria,'C');">Costs</a>.&nbsp;&nbsp;<br /><br />
		Select <a href="javascript:selectTransTypes(document.frmSelectCriteria,'All');">All</a> transaction types.
		</td>
	<td>
		<cfloop query="rsNCFMSTransTypes">
			<input type="checkbox" name="ckbTransType" id="idTT#xactn_type#" value="#xactn_type#" <cfif listfind(form.ckbTransType,xactn_type)>checked</cfif>/>
			&nbsp;<label for="idTT#xactn_type#">#xactn_type_desc#</label><br />
		</cfloop>
		</td>
</tr>

<tr><!--- Funding Category --->
	<td width="18"></td>
	<td width="230" align="right"><label for="idFundCat">Funding Category:</label></td>
	<td>
		<input type="radio" name="radFundCat" id="idFundCat_all" tabindex="#request.nextTabIndex#" value="All"
			<cfif form.radFundCat is "All">checked="checked"</cfif> /><label for="idFundCat_all">All&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radFundCat" id="idFundCat_ops" tabindex="#request.nextTabIndex#" value="OPS"
			<cfif form.radFundCat is "OPS">checked="checked"</cfif> /><label for="idFundCat_ops">OPS&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radFundCat" id="idFundCat_cra" tabindex="#request.nextTabIndex#" value="CRA"
			<cfif form.radFundCat is "CRA">checked="checked"</cfif> /><label for="idFundCat_cra">CRA&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radFundCat" id="idFundCat_se" tabindex="#request.nextTabIndex#" value="S/E"
			<cfif form.radFundCat is "S/E">checked="checked"</cfif> /><label for="idFundCat_se">S&E</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>

<tr><!--- Vendor--->
	<td width="18"></td>
	<td width="230" align="right" valign="top"><label for="idtxtVendor">Vendor:</label></td>
	<td>
		<input type="text" name="txtVendor" id="idtxtVendor" value="#form.txtVendor#" size="20" maxlength="55">
	</td>
</tr>

</table>
</cfoutput>