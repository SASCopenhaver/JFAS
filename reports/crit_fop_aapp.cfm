<!---
page: crit_fop_aapp.cfm

description: criteria page for FOP Allocations (by AAPP) Report

revisions:
2007-02-09	mstein	508 issues - use of fieldset tag
2007-04-11  abai  Revised for defect 172 -- make title consistent with menu page
--->

<h2>FOP Allocations (by AAPP)</h2>
<cfoutput>
<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">
<tr>
	<td width="25%" align="right"><label for="idAAPP">AAPP No.</label></td>
	<td></td>
	<td width="75%">
		<input type="text" name="AAPP" id="idAAPP" size="6" maxlength="6" tabindex="#request.nextTabIndex#"/>
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
	<td align="right"><fieldset><legend align="right">Report Format</legend></td>
	<td></td>
	<td><!--- format defaults to PDF --->
		<label for="format_pdf"><input type="radio" name="radReportFormat" id="format_pdf" value="application/pdf" tabindex="#request.nextTabIndex#" checked />&nbsp;PDF</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<label for="format_html"><input type="radio" name="radReportFormat" id="format_html" value="html" tabindex="#request.nextTabIndex#"/>&nbsp;HTML</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<label for="format_excel"><input type="radio" name="radReportFormat" id="format_excel" value="application/vnd.ms-excel" tabindex="#request.nextTabIndex#"/>&nbsp;MS Excel</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</fieldset>
	</td>
</tr>
</table>
<div class="buttons"><!--- on submit, check to make sure AAPP exists --->
	<input type="submit" name="btnGenerateReport" value="Generate Report" tabindex="#request.nextTabIndex#" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#"  onclick="javascript:window.location='#application.paths.reports#'" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1><!--- on Cancel, return to reports page --->
</div>
</cfoutput>