
<!---
frmCriteriaAAPP.cfm

description: JFAS AAPP Dataset Criteria Form (for use with adhoc tool) 

revisions:
2010-07-01	mstein	Changed Funding Office from drop-down lists to checkboxes
--->


<cfparam name="form.cboFundingOffice" default="all">
<cfparam name="form.cboAgreementType" default="">
<cfparam name="form.cboServiceType" default="">
<cfparam name="form.Status" default="Y">
<cfparam name="form.txtContractor" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>

<!--- get reference data for drop-down lists --->
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" returnvariable="rsFundingOffices">
<cfinvoke component="#application.paths.components#lookup" method="getAgreementTypes" returnvariable="rsAgreementTypes">
<cfinvoke component="#application.paths.components#lookup" method="getServiceTypes" returnvariable="rsServiceTypes">

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
	<td align="right"><label for="idAgreementType">Agreement Type</label></td>
	<td>
		<select name="cboAgreementType" id="idAgreementType" tabindex="#request.nextTabIndex#" accesskey="p">
			<option value="all">All</option>
			<cfloop query="rsAgreementTypes">
				<option value="#agreementTypeCode#" <cfif agreementTypeCode eq form.cboAgreementType>SELECTED</cfif>>#agreementTypeDesc#</option>
			</cfloop>	
		</select>
		<cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>
<tr>
	<td></td>
	<td align="right"><label for="idServiceType">Service Type</label></td>
	<td>
		<select name="cboServiceType" id="idServiceType" tabindex="#request.nextTabIndex#" accesskey="p">
			<option value="all">All</option>
			<cfloop query="rsServiceTypes">
				<option value="#contractTypeCode#"
					<cfif contractTypeCode eq form.cboServiceType>SELECTED</cfif>>#contractTypeShortDesc#</option>
			</cfloop>	
		</select>
		<cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>
<tr>
	<td></td>
	<td align="right"><label for="idStatus">Status:</label></td>
	<td>
		<select name="status" size="1" id="idStatus" tabindex="#request.nextTabIndex#">
			<option value="all">All
			<option value="1" selected>Active 
			<option value="0">Inactive
		</select><cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>
<tr>
	<td></td>
	<td align="right"><label for="idContractor">Contractor:</label></td>
	<td>
		<input type="text" name="txtContractor" id="idContractor" value="#form.txtContractor#" size=20 maxlength="50" tabindex="#request.nextTabIndex#">
	</td>
</tr>
</table>
</cfoutput>