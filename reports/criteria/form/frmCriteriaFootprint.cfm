<!---
page: frmCriteriaFootprint.cfm

description: JFAS Footprint Dataset Criteria Form (for use with adhoc tool) 

revisions:

2007-06-18	rroser	add document number as criteria
2009-03-19	mstein	add ARRA (stimulus) as criteria
2009-04-14	mstein	add IAC as criteria
2010-07-01	mstein	Changed Funding Office from drop-down lists to checkboxes

--->


<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.cboFundingOffice" default="all">
<cfparam name="form.txtDocNum" default="">
<cfparam name="form.txtIAC" default="">
<cfparam name="form.radARRA" default="All">
<cfparam name="form.radFunds" default="All">
<cfparam name="form.radOPSCRA" default="All">
<cfparam name="form.cboProj1" default="All">
<cfparam name="form.cboFY" default="All">
<cfparam name="form.radStatus" default="All">
<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>

<!--- get reference data for drop-down lists --->
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeTypeNot="FED" returnvariable="rsFundingOffices">
<cfinvoke component="#application.paths.components#lookup" method="getProj1Codes" returnvariable="rstProj1Codes">
<cfquery name="qryFY" datasource="#request.dsn#">
	Select 	Distinct(FY)
	From	Footprint_Dataset_View
	Order By FY DESC
</cfquery>

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
		<input type="text" name="txtAAPPNum" id="idtxtAAPPNum" value="#form.txtAAPPNum#" size="20" maxlength="12" tabindex="#request.NextTabIndex#"><cfset request.NextTabIndex=request.NextTabIndex+1>
	</td>
</tr>
<tr valign="top"><!--- Funding Office --->
	<td width="18"></td>
	<td width="230" align="right"><label for="idFundingOffice">Funding Office:</label></td>
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
<tr><!--- FY --->
	<td width="18"></td>
	<td width="230" align="right"><label for="idFY">FY:</label></td>
	<td>
		<select name="cboFY" id="idFY" tabindex="#request.nextTabIndex#">
		<option value="All">All</option>
		<cfloop query="qryFY">
			<option value="#FY#"
				<cfif FY eq form.cboFY>SELECTED</cfif>>#FY#
			</option>
		</cfloop>
		</select><cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>
<tr><!--- Document Number --->
	<td></td>
	<td  align="right"><label for="idtxtDocNum">Document No:</label></td>
	<td>
		<input type="text" name="txtDocNum" id="idtxtDocNum" value="#form.txtDocNum#" size="12" maxlength="12" tabindex="#request.NextTabIndex#"><cfset request.NextTabIndex=request.NextTabIndex+1>
	</td>
</tr>
<tr><!--- OPS/CRA --->
	<td width="18"></td>
	<td width="230" align="right"><label for="idOPSCRA">Funding Category:</label></td>
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
<tr valign="middle"><!--- IAC --->
	<td width="18"></td>
	<td width="230" align="right"><label for="idtxtIAC">IAC:</label></td>
	<td>
		<input type="text" name="txtIAC" id="idtxtIAC" value="#form.txtIAC#" size="16" maxlength="30" tabindex="#request.NextTabIndex#"><cfset request.NextTabIndex=request.NextTabIndex+1>
		&nbsp;&nbsp;(separate multiple values with commas)
	</td>
</tr>
<tr><!--- ARRA --->
	<td width="18"></td>
	<td width="230" align="right" valign="top"><label for="idARRA">ARRA:</label></td>
	<td>
		<input type="radio" name="radARRA" id="idARRA_all" tabindex="#request.nextTabIndex#" value="All"
			<cfif form.radARRA is "All">checked="checked"</cfif> /><label for="idARRA_all">All&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radARRA" id="idARRA_yes" tabindex="#request.nextTabIndex#" value="1"
			<cfif form.radARRA eq 1>checked="checked"</cfif> /><label for="idARRA_yes">Yes&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radARRA" id="idARRA_no" tabindex="#request.nextTabIndex#" value="0"
			<cfif form.radARRA eq 0>checked="checked"</cfif> /><label for="idARRA_no">No&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>
<tr><!--- Funds Available --->
	<td width="18"></td>
	<td width="230" align="right"><label for="idFunds">Funds Available:</label></td>
	<td>	
		<input type="radio" name="radFunds" id="idFunds_all" tabindex="#request.nextTabIndex#" value="All"
			<cfif form.radFunds is "All">checked="checked"</cfif>/><label for="idFunds_all">All&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radFunds" id="idFunds_yes" value="1" tabindex="#request.nextTabIndex#"
			<cfif form.radFunds is "1">checked="checked"</cfif> /><label for="idFunds_yes">Funds Available&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radFunds" id="idFunds_no" value="0" tabindex="#request.nextTabIndex#"
			<cfif form.radFunds is "0">checked="checked"</cfif>/><label for="idFunds_no">No Funds Available</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>
<tr><!--- Proj 1 --->
	<td width="18"></td>
	<td width="230" align="right"><label for="idProj1">Project 1 Code:</label></td>
	<td>	
		<select name="cboProj1" id="idProj1" tabindex="#request.nextTabIndex#" >
		<option value="All">All</option>
		<cfloop query="rstProj1Codes">
			<option value="#Proj1Code#"
				<cfif Proj1Code eq form.cboProj1>SELECTED</cfif>>#Proj1Code#
			</option>
		</cfloop>
		</select><cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>
<tr><!--- Status --->
	<td width="18"></td>
	<td width="230" align="right"><label for="idStatus">Status:</label></td>
	<td>
		<input type="radio" name="radStatus" id="idStatus_all" tabindex="#request.nextTabIndex#" value="All"
			<cfif form.radStatus is "All">checked="checked"</cfif> /><label for="idStatus_all">All&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radStatus" id="idStatus_yes" tabindex="#request.nextTabIndex#" value="1"
			<cfif form.radStatus is 1>checked="checked"</cfif> /><label for="idStatus_yes">Active&nbsp;&nbsp;</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		<input type="radio" name="radStatus" id="idStatus_no" tabindex="#request.nextTabIndex#" value="0"
			<cfif form.radStatus is 0>checked="checked"</cfif> /><label for="idStatus_no">Inactive</label>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>





</table>
</cfoutput>