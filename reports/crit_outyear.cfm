<!---
page: crit_outyear.cfm

description: criteria form for outyear funding report

revisions:
--->

<h2>Out Year Funding Requirements</h2>

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">

		<cfoutput>

<tr valign="top">
	<td width="25%" align="right"><legend align="right">Cost Category</legend></td>
	<td></td>
	<td width="75%">
		<cfloop query="rstCostCat">
			<input type="checkbox" name="chkCostCat" value="#contractTypeCode#" id="idCostCat_#contractTypeCode#" tabindex="#request.nextTabIndex#" checked="checked"/>
			<label for="idCostCat_#contractTypeCode#">#contractTypeCode#</label>&nbsp;&nbsp;
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfloop>
	</td>
</tr>
<tr>
	<td align="right"><label for="idFundingOffice">Funding Office</label></td>
	<td></td>
	<td>	
		<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#">
			<option value="0">All Funding Offices</option>
				<cfloop query="rstFundingOffice">
					<!--- for regional role, show appropriate region, plus all CCCs --->
					<cfif (not listFind("3,4", session.roleID, ",")) or
						(listFind("3,4", session.roleID, ",") and (regionNum eq session.region or officeType eq "FED"))>
					
						<option value="#fundingOfficeNum#"
						<cfif session.roleid is 3 or session.roleid is 4>
							<cfif fundingOfficeNum eq session.region>
							selected
							</cfif>
						</cfif>
						 />#fundingOfficeDesc#
						</option>
					
					</cfif>
				</cfloop>
		</select>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>

<tr valign="top">
	<td align="right"><legend align="right">Report Format</legend></td>
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
	</td>
</tr>
		</cfoutput>
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