<!---
page: crit_workload change.cfm

description: criteria form for workload change list report

revisions:
2008-05-01	mstein	page created
--->

<h2>Workload Change List</h2>

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">

<tr>
	<td align="right"><label for="idFundingOffice">Funding Office</label></td>
	<td></td>
	<td>
		<cfoutput>	
		<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#">
			<option value="all">All Funding Offices</option>
			<cfloop query="rsFundingOffices">
				<option value="#fundingOfficeNum#"/>#fundingOfficeDesc#</option>
			</cfloop>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>

<tr valign="top">
	<td align="right"><label for="idWorkloadTypes">Look for changes in</label></td>
	<td></td>
	<td>
		<cfoutput query="rsWorkloadTypes">	
		<input type="checkbox" name="ckbWorkload" id="idWorkload_#workLoadTypeCode#"
			value="#workLoadTypeCode#" tabindex="#request.nextTabIndex#"
		<cfif workLoadTypeCode eq "SL">checked</cfif>
		>
		<label for="idWorkload_#workLoadTypeCode#">#workloadTypeDesc#</label><br />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfoutput>
	</td>
</tr>

<tr valign="top">
	<td align="right"><fieldset><legend align="right">Report Format</legend></td>
	<td></td>
	<td>
		<cfoutput>
		<label for="format_pdf"><input type="radio" name="radReportFormat" id="format_pdf" value="application/pdf" tabindex="#request.nextTabIndex#" checked>&nbsp;PDF</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<label for="format_html"><input type="radio" name="radReportFormat" id="format_html" value="html" tabindex="#request.nextTabIndex#">&nbsp;HTML</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<label for="format_excel"><input type="radio" name="radReportFormat" id="format_excel" value="application/vnd.ms-excel" tabindex="#request.nextTabIndex#">&nbsp;MS Excel</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfoutput>
		</fieldset>
	</td>
</tr>
</table>
<div class="buttons">
	<cfoutput>
	<input type="submit" name="btnGenerateReport" value="Generate Report" tabindex="#request.nextTabIndex#" onclick="return validateForm(this.form);"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#" onClick="javascript:window.location='reports_main.cfm'" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</cfoutput>
</div>