<!---
page: crit_budget_authority_requirements.cfm

description: criteria form for budget auth reqmts report

revisions:
2007-02-09	mstein	508 issues - use of fieldset tag
2007-04-11  abai 	Revised for defect 172 -- make title consistent with menu page
2007-07-23	mstein	Adjusted funding office drop-down to allow access by regional users to CCCs
--->

<h2>Budget Authority Requirements (by AAPP)</h2>

<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" returnvariable="rsFundingOffices">
<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">

<tr valign="top">
	<td align="right"><fieldset><legend align="right">Status</legend>&nbsp;&nbsp;&nbsp;</td>
	<td></td>
	<td>
		<cfoutput>
		<input type="radio" name="radStatus" id="idStatus" value="1" tabindex="#request.nextTabIndex#" checked/>
		<label for="idStatus">Active</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1> 
		&nbsp;
		<input type="radio" name="radStatus" value="0" id="idStatusInactive" tabindex="#request.nextTabIndex#"/>
		<label for="idStatusInactive">Inactive</label>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		&nbsp;
		<input type="radio" name="radStatus" value="all" id="idStatusAll"  tabindex="#request.nextTabIndex#"/>
		<label for="idStatusAll">All</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfoutput>
		</fieldset>
	</td>
</tr>
<tr>
	<td align="right"><label for="idFundingOffice">Funding Office</label></td>
	<td></td>
	<td>
		<cfoutput>	
		<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#">
			<option value="all">Select Funding Office</option>
				<cfloop query="rsFundingOffices">
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
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
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