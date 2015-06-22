<!---
page: crit_fop_allocat_recon.cfm

description: criteria page for FOP / Allocation Reconciliation Report

revisions:
2013-09-02	mstein	Page created
2014-10-23	mstein	Modified display of funding office (no longer showing CCCs, so removed that logic)
--->

<h2>PY Contract Allocation / FOP Reconciliation </h2>
<cfoutput>
<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Criteria for Report">
<tr valign="top">
	<td align="right"><fieldset><legend align="right">Status</legend></td>
	<td></td>
	<td>
		<cfoutput><!--- default to all --->
		<input type="radio" name="radStatus" id="idStatus" value="1" tabindex="#request.nextTabIndex#" checked/>
		<label for="idStatus">Active</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1> 
		&nbsp;
		<input type="radio" name="radStatus" value="0" id="idStatusInactive" tabindex="#request.nextTabIndex#"/>
		<label for="idStatusInactive">Inactive</label>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		&nbsp;
		<input type="radio" name="radStatus" value="all" id="idStatusAll"  tabindex="#request.nextTabIndex#" />
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
			<cfloop query="rstFundingOffices">					
					<!--- for regional role, show appropriate region, plus all CCCs --->
					<cfif (not listFind("3,4", session.roleID, ",")) or (listFind("3,4", session.roleID, ",") and (regionNum eq session.region))>
						
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