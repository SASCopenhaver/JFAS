<cfsilent>
<!---
page: crit_ccc_py_worksheet.cfm

description: This template displays form criteria fields.

revisions:
abai: 03/28/2007  Revised for defect 139 -- change "all program years" to" select program year"
abai: 03/30/2007  Revised for defect 139 -- change "all funding office" to "select funding office" and disabled button if there is no PY list.
abai: 04/11/2007  Revised for defect 172 -- make title consistent with menu page
--->
</cfsilent>

<h2>Program Year Initial CCC Budget (by Agency)</h2>

<cfparam name="form.cboFundingOffice" default="0">
<cfparam name="form.cboPY" default="0">

<cfinvoke component="#application.paths.components#Reports" method="getCCC_py_worksheet_PyList" returnvariable="rsPyList">

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">

<tr>
	<td align="right"><label for="idPY">Program Year&nbsp;&nbsp;&nbsp;</label></td>
	<td>
		<cfoutput>	<!--- loop through all PYs in system --->
		<select name="cboPY" id="idPY" tabindex="#request.nextTabIndex#">
			<option value="0">Select Program Year</option>
			<cfloop query="rsPyList">
			<option value="#PY#">#PY#
			</option>
			</cfloop>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td align="right"><label for="idFundingOffice">Funding Office</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>	
		<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#">
			<option value="0">Select Funding Office</option>
				<cfloop query="rsFundingOffices">
					<option value="#fundingOfficeNum#"
					<cfif session.roleid is 3>
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
	<input type="submit" name="btnGenerateReport" value="<cfif rsPyList.recordcount eq 0>No Data<cfelse>Generate Report</cfif>" <cfif rsPyList.recordcount eq 0>disabled</cfif> tabindex="#request.nextTabIndex#" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#" onClick="javascript:window.location='reports_main.cfm'" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</cfoutput>
</div>
<!--- <script>
	checkAAPPCenter(0);
</script> --->
