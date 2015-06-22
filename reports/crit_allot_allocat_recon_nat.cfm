<!---
page: crit_allot_allocat_recon_nat.cfm.cfm

description: criteria page for Allotment / Obligation / Allocation Reconciliation (National View) Report

revisions:
2014-03-10	mstein	Page created
--->

<h2>Allotment / Obligation / Allocation Reconciliation (National View)</h2>
<cfoutput>
<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Criteria for Report">
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
	<td align="right"><fieldset><legend align="right">Funding Category</legend></td>
	<td></td>
	<td>
		<cfoutput><!--- default to all --->
		<input type="radio" name="radFundingCat" id="idFundingCatOPS" value="OPS" tabindex="#request.nextTabIndex#" checked/>
		<label for="idFundingCatOPS">OPS</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1> 
		&nbsp;
		<input type="radio" name="radFundingCat" id="idFundingCatCRA" value="CRA" tabindex="#request.nextTabIndex#"/>
		<label for="idFundingCatCRA">CRA</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfoutput>
		</fieldset>
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