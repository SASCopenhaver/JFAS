<cfsilent>
<!---
page: crit_estimated_fiscal_plan.cfm

description: criteria page for fiscal plan report

revisions:
2006-12-27	yjeng	If user click cancel button, go back to report main page
2007-02-09	mstein	508 issues - use of fieldset tag
--->
</cfsilent>

<h2>Fiscal Plan</h2>
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
<tr valign="top">
	<td align="right"><fieldset><legend align="right">Report Format</legend></td>
	<td></td>
	<td>
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
<div class="buttons">
	<input type="submit" name="btnGenerateReport" value="Generate Report" tabindex="#request.nextTabIndex#"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#"  onclick="javascript:window.location='#application.paths.reports#'" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
</div>
</cfoutput>