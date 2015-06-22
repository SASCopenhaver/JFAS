<!---
page: crit_fop_allocations.cfm

description: criteria page for FOP Listing Report

revisions:
2007-02-09	mstein	508 issues - use of fieldset tag
2007-07-23	mstein	Allow Regional Office users access to CCCs
2009-03-19	mstein	Add ARRA (stimulus) as criteria
--->
<h2>FOP Listing</h2>
<cfoutput>
<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Criteria for FOP listing Report">
<tr valign="top">
	<td align="right"><fieldset><legend align="right">Status</legend></td>
	<td></td>
	<td>
		<cfoutput><!--- default to all --->
		<input type="radio" name="radStatus" id="idStatus" value="1" tabindex="#request.nextTabIndex#"/>
		<label for="idStatus">Active</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		&nbsp;
		<input type="radio" name="radStatus" value="0" id="idStatusInactive" tabindex="#request.nextTabIndex#"/>
		<label for="idStatusInactive">Inactive</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		&nbsp;
		<input type="radio" name="radStatus" value="all" id="idStatusAll"  tabindex="#request.nextTabIndex#" checked/>
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
		<cfoutput>	<!--- loop through funding office query - required --->
		<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#">
			<option value="all">Select Funding Office</option>
				<cfloop query="rstFundingOffices">
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
<tr>
	<td align="right"><label for="idPY">Program Year</label></td>
	<td></td>
	<td>
		<cfoutput>	<!--- loop through all PYs in system --->
		<select name="cboPY" id="idPY" tabindex="#request.nextTabIndex#">
			<option value="all">All Program Years</option>
			<cfloop query="rstPY">
			<option value="#PY#">#PY#
			</option>
			</cfloop>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr valign="top">
	<td align="right"><fieldset><legend align="right">ARRA</legend></td>
	<td></td>
	<td>
		<input type="radio" name="radARRA" id="idARRA_all" value="All" tabindex="#request.nextTabIndex#" checked />&nbsp;<label for="idARRA_all">All</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input type="radio" name="radARRA" id="idARRA_1" value="1" tabindex="#request.nextTabIndex#" />&nbsp;<label for="idARRA_1">Yes</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input type="radio" name="radARRA" id="idARRA_0" value="0" tabindex="#request.nextTabIndex#"/>&nbsp;<label for="idARRA_0">No</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</fieldset>
	</td>
</tr>
<tr>
	<td align="right"><label for="idDate">Date Range</label></td>
	<td></td>
	<td nowrap="nowrap">
		<input type="text" name="txtStartDate" size="15" id="idDate"
		tabindex="#request.nextTabIndex#" class="datepicker" title="Select to specify first date in date range"/>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>

		<label for="idDateEnd">And</label>
		<input type="text" name="txtEndDate" size="15" id="idDateEnd" tabindex="#request.nextTabIndex#" class="datepicker" title="Select to specify second date in Start Between range" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>

	</td>
</tr>
<tr valign="top">
	<td align="right"><fieldset><legend align="right">Report Format</legend></td>
	<td></td>
	<td>
		<input type="radio" name="radReportFormat" id="format_pdf" value="application/pdf" tabindex="#request.nextTabIndex#" checked />&nbsp;<label for="format_pdf">PDF</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input type="radio" name="radReportFormat" id="format_html" value="html" tabindex="#request.nextTabIndex#" />&nbsp;<label for="format_html">HTML</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input type="radio" name="radReportFormat" id="format_excel" value="application/vnd.ms-excel" tabindex="#request.nextTabIndex#"/>&nbsp;<label for="format_excel">MS Excel</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</fieldset>
	</td>
</tr>
</table>
<div class="buttons">
	<input type="submit" name="btnGenerateReport" value="Generate Report" tabindex="#request.nextTabIndex#" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#" onclick="javascript:window.location='#application.paths.reports#'"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1><!--- cancel returns to main reports page --->
</div>
</cfoutput>