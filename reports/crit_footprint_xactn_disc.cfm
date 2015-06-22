<cfsilent>
<!---
page: crit_footprint_xactn_disc.cfm

description: This template displays form criteria fields.

revisions:
--->
</cfsilent>

<h2>Footprint Transaction Discrepancies</h2>

<cfparam name="form.AAPP" default="">
<cfparam name="form.radReportType" default="">
<cfparam name="form.hidReportType" default="">
<cfparam name="form.radReportFormat" default="html">

<cfif session.roleid neq 3 and session.roleid neq 4>
	<cfset fundingOfficeFilter = 0>
<cfelse>
	<cfset fundingOfficeFilter = session.region>
</cfif>

<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#fundingOfficeFilter#" returnvariable="rsFundingOffices">

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for Footprint Transaction Discrepancies">

<tr>
	<td align="right">
		<input type="radio" name="radReportType" value="aapp" id="idTypeAAPP" <cfif form.radReportType is "aapp">checked</cfif> />&nbsp;
		<label for="idAAPP">AAPP No.</label></td>
	<td><cfoutput>
		<input type="text" name="AAPP" id="idAAPP" size="6" maxlength="6" value=""  />
		</cfoutput>
	</td>
</tr>
<tr><cfoutput>
	<td align="right">
		<input type="radio" name="radReportType" value="all" id="idAll" <cfif form.radReportType is "all">checked</cfif> />&nbsp;
		<label for="idAll">All AAPPs</label>
		<td><font color="##666666">&nbsp;(for footprints from Fiscal Year #evaluate(request.py - 1)# and later)</font></td>
	</td>
	</cfoutput> 
</tr>

<tr>
	<td align="right">Report Format&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>
		<input type="radio" name="radReportFormat" id="pdf" value="application/pdf" checked>&nbsp;<label for="pdf">PDF</label> &nbsp;&nbsp;
		<input type="radio" name="radReportFormat" id="html" value="html">&nbsp;<label for="html">HTML</label> &nbsp;&nbsp;
		<input type="radio" name="radReportFormat" id="excel" value="application/vnd.ms-excel" >&nbsp;<label for="excel">MS Excel</label>
		</cfoutput>
	</td>
</tr>
</table>
<cfoutput>	
<div class="buttons">
	<input type="submit" name="btnGenerateReport" value="Generate Report" />
	<input type="reset" name="btnReset" value="Reset"  onClick="javascript:window.location='report_criteria_template.cfm?rpt_id=23'" />
	<input type="button" name="btnCancel" value="Cancel" onClick="javascript:window.location='reports_main.cfm'" />
	
</div>
</cfoutput>
