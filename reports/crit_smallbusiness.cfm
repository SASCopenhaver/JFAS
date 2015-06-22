<cfsilent>
<!---
page: crit_smallbusiness.cfm

description: This template displays Small Business Report form criteria fields.

revisions:
abai 10/23/2007  abai  Add Other checkbox for smb sub category.
--->
</cfsilent>

<h2>Small Business Funding</h2>

<cfparam name="form.AAPP" default="">
<cfparam name="form.txtStartDate" default="">
<cfparam name="form.txtEndDate" default="">
<cfparam name="form.ckbAgreementType" default="">
<cfparam name="form.cboOrgType" default="">
<cfparam name="form.cbofy" default="">
<cfparam name="form.ckbSmallBusType" default="">
<cfparam name="cal_year" default="#year(now())#">

<cfif session.roleid neq 3 and session.roleid neq 4>
	<cfset fundingOfficeFilter = 0>
<cfelse>
	<cfset fundingOfficeFilter = session.region>
</cfif>

<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#fundingOfficeFilter#" returnvariable="rsFundingOffices">

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">

<tr valign="top">
	<td align="right"><legend align="right">Agreement Types</legend></td>
	<td>
		<cfoutput query="rsAgreementTypes">
			<cfif agreementTypeCode neq  "CC">
				<input type="checkbox" name="ckbAgreementType" id="#agreementTypeCode#" value="'#agreementTypeCode#'" <cfif agreementTypeCode eq  "DC" or agreementTypeCode eq  "LE">checked</cfif>><label for="#agreementTypeCode#">#agreementTypeDesc#</label><br />
			</cfif>
		</cfoutput>
	</td>
</tr>

<tr>
	<td scope="row" align="right">
		<label for="idOrgType">*Organization Category</label>
	</td>

	<td>
		<select name="cboOrgType" id="idOrgType" onChange="orgTypeCheck(this.form);">
			<cfset old_org="">
			<cfset new_org="">
			<option value="">All Categories</option>
			<cfoutput query="rsOrgTypes">
				<cfset new_org=orgTypeCode>
				<cfif old_org eq "" or (old_org neq "" and new_org neq old_org)><option value="#orgTypeCode#">#orgTypeDesc#</cfif>
				<option value="#orgSubTypeCode#">&nbsp;&nbsp;-#orgSubTypeDesc#
				<cfset old_org = new_org>
			</cfoutput>
		</select>

	</td>

</tr>

<tr valign="top">
	<td align="right"><legend align="right">Small Business Subcategories</legend></td>
	<td>
		<cfoutput query="rsSmallBusinessTypes">
			<input type="checkbox" name="ckbSmallBusType" id="#smbTypeCode#" value="'#smbTypeCode#'" disabled><label for="#smbTypeCode#">#smbTypeDesc#</label><br />
		</cfoutput>
		<input type="checkbox" name="ckbSmallBusType" id="other" value="'other'" disabled><label for="other">No Subcategories Apply</label><br />
	</td>
</tr>
<tr>
	<td></td><td><hr /></td>
</tr>

<tr>
	<td align="right"><label for="idFY">Fiscal Year</label></td>

	<td>
		<select name="cboFY" id="idFY" onChange="changeDateRange(this.form);">
			<cfoutput query="rsFY">
				<option value="#fy#" <cfif fy eq #cal_year#>selected</cfif>>#fy#
			</cfoutput>
		</select>

	</td>
</tr>
<tr>
	<td align="right">OR</td>
	<td></td>
</tr>
<tr>
	<td align="right"><label for="idDate">Date Range</label></td>
	<td nowrap="nowrap">
		<cfoutput>
		<input type="text" name="txtStartDate" size="15" id="idDate" value="10/01/#cal_year-1#" onChange="changeFY(this.form);" class="datepicker" title="Select to specify first date in date range" />

		<label for="idDateEnd">&nbsp;to&nbsp;</label>
		<input type="text" name="txtEndDate" size="15" id="idDateEnd" value="09/30/#cal_year#"  onChange="changeFY(this.form);" class="datepicker" title= "Select to specify second date in Start Between range" />
		</cfoutput>
	</td>
</tr>
<tr>
	<td></td>
	<td><hr /></td>
</tr>
<tr>
	<td align="right"><label for="format_html">Report Format</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>
		<label for="format_pdf"><input type="radio" name="radReportFormat" id="format_pdf" value="application/pdf" checked>&nbsp;PDF</label> &nbsp;&nbsp;
		<label for="format_html"><input type="radio" name="radReportFormat" id="format_html" value="html">&nbsp;HTML</label> &nbsp;&nbsp;
		<label for="format_excel"><input type="radio" name="radReportFormat" id="format_excel" value="application/vnd.ms-excel">&nbsp;MS Excel</label>
		</cfoutput>
	</td>
</tr>
</table>
<cfoutput>
<div class="buttons">
	<input type="submit" name="btnGenerateReport" value="Generate Report"  />
	<input type="reset" name="btnReset" value="Reset"  onClick="javascript:window.location='report_criteria_template.cfm?rpt_id=22'" />
	<input type="button" name="btnCancel" value="Cancel"  onClick="javascript:window.location='reports_main.cfm'" />

</div>
</cfoutput>

