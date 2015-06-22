<!---
page: crit_oa_cts_annualized.cfm

description: This template displays form criteria fields.

revisions:
abai 05/24/2007  Revised for changing title.
--->

<cfparam name="txtStartDate" default="#dateformat(now(), 'mm/dd/yyyy')#">

<h2>OA/CTS Annualized Workload/Cost Under Current Contracts</h2>

<cfif session.roleid neq 3 and session.roleid neq 4>
	<cfset fundingOfficeFilter = 0>
<cfelse>
	<cfset fundingOfficeFilter = session.region>
</cfif>

<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#fundingOfficeFilter#" fundingOfficeType="DOL" returnvariable="rsFundingOffices">

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">

<tr>
	<td align="right"><label for="idFundingOffice">DOL Region</label>&nbsp;&nbsp;</td>
	<td>
		<cfoutput>
		<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#">
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<option value="0">All Regions</option>
		</cfif>
				<cfloop query="rsFundingOffices">
					<option value="#fundingOfficeNum#"
					<cfif session.roleid is 3 or session.roleid is 4>
						<cfif fundingOfficeNum eq session.region>
						selected
						</cfif>
					</cfif>
					 />#fundingOfficeDesc#
					</option>
				</cfloop>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td align="right"><label for="idDate">As of Date</label>&nbsp;&nbsp;</td>
	<td nowrap="nowrap">
	<cfoutput>
		<input type="text" name="txtStartDate" size="15" id="idDate"
		tabindex="#request.nextTabIndex#" onChange="fprint_aapp_fund(this.form);" value="#dateFormat(now(), 'mm/dd/yyyy')#" readonly />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>

	</cfoutput>
	</td>

</tr>
<tr>
	<td align="right"><label for="format_html">Report Format</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>
		<label for="format_pdf"><input type="radio" name="radReportFormat" id="format_pdf" value="application/pdf" tabindex="#request.nextTabIndex#" checked>&nbsp;PDF</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<label for="format_html"><input type="radio" name="radReportFormat" id="format_html" value="html" tabindex="#request.nextTabIndex#">&nbsp;HTML</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<label for="format_excel"><input type="radio" name="radReportFormat" id="format_excel" value="application/vnd.ms-excel" tabindex="#request.nextTabIndex#">&nbsp;MS Excel</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfoutput>
	</td>
</tr>
</table>
<div class="buttons">
	<cfoutput>
	<input type="submit" name="btnGenerateReport" value="Generate Report" tabindex="#request.nextTabIndex#" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#" onClick="javascript:window.location='reports_main.cfm'" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</cfoutput>
</div>