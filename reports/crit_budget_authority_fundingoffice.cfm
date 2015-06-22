<!---
page: crit_budget_authority_fundingoffice.cfm

description: This template displays form criteria fields.

revisions:
04/11/2007  abai  Revised for defect 172 -- make title consistent with menu page
07/24/2007  abai  Change Funding office to DOL Region
2009-10-15	mstein	Added National Office Funding Units
--->

<h2>Budget Authority Requirements (by DOL Region)</h2>

<cfif session.roleid neq 3 and session.roleid neq 4>
	<cfset fundingOfficeFilter = 0>
<cfelse>
	<cfset fundingOfficeFilter = session.region>
</cfif>

<!--- get list of funding offices --->
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#fundingOfficeFilter#" fundingOfficeType="DOL" returnvariable="rsFundingOffices_DOL">
<cfif not listfind("3,4", session.roleid)>
	<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#fundingOfficeFilter#" fundingOfficeType="JCO" returnvariable="rsFundingOffices_JCO">
</cfif>

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">

<tr>
	<td align="right"><label for="idFundingOffice">DOL Region</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>	
		<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#">
		<cfif not listfind("3,4", session.roleid)>
			<option value="0">All Regions</option>
		</cfif>
			<cfloop query="rsFundingOffices_DOL">
				<option value="#fundingOfficeNum#"
				<cfif listfind("3,4", session.roleid)>
					<cfif fundingOfficeNum eq session.region>
					selected
					</cfif>
				</cfif>
				 />#fundingOfficeNum# - #fundingOfficeDesc#
				</option>
			</cfloop>
			<cfif not listfind("3,4", session.roleid)>
				<cfloop query="rsFundingOffices_JCO">
					<option value="#fundingOfficeNum#"/>#fundingOfficeNum# - #fundingOfficeDesc#</option>
				</cfloop>
			</cfif>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
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