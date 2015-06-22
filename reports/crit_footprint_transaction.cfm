<cfsilent>
<!---
page: crit_footprint_transaction.cfm

description: This template displays form criteria fields.

revisions:
2008-06-09	mstein	Added "Document Number" to the criteria
2010-01-07	mstein	Added "Data Source" to criteria
2014-04-18	mstein	Disable NCFMS option, default source to DOLAR$
--->
</cfsilent>

<h2>Footprint Transactions: <cfif isDefined("request.trans_type") and request.trans_type eq "O">Obligations<cfelseif isDefined("request.trans_type") and request.trans_type eq "P">Payments<cfelse>Costs</cfif></h2>

<cfparam name="form.AAPP" default="">
<cfparam name="form.txtStartDate" default="">
<cfparam name="form.txtEndDate" default="">
<cfparam name="form.txtStartDate1" default="">
<cfparam name="form.txtEndDate1" default="">
<cfparam name="form.txtDocNumber" default="">
<cfparam name="form.radDataSource" default="">
<cfparam name="form.hidReportType" default="">

<!---
<cfif session.roleid neq 3 and session.roleid neq 4>
	<cfset fundingOfficeFilter = 0>
<cfelse>
	<cfset fundingOfficeFilter = session.region>
</cfif>

<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#fundingOfficeFilter#" returnvariable="rsFundingOffices">
--->

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">

<tr>
	<td align="right"><label for="idAAPP">AAPP No.</label></td>
	<td><cfoutput>
		<input type="text" name="AAPP" id="idAAPP" size="6" maxlength="6" value="" tabindex="#request.nextTabIndex#" />
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td align="right"><label for="idDate">Date Range</label></td>
	<td nowrap="nowrap">
	<cfoutput>
		<input type="text" name="txtStartDate" size="15" id="idDate" tabindex="#request.nextTabIndex#" class="datepicker" title="Select to specify first date in date range"/>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>

		<label for="idDateEnd">and</label>
		<input type="text" name="txtEndDate" size="15" id="idDateEnd" tabindex="#request.nextTabIndex#" class="datepicker" title="Select to specify second date in date range" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</cfoutput>
	</td>
</tr>

<tr>
	<td align="right"><label for="idDocNumber">Document No.</label></td>
	<td><cfoutput>
		<input type="text" name="txtDocNumber" id="idDocNumber" size="14" maxlength="10" value="" tabindex="#request.nextTabIndex#" />
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>

<tr>
	<td align="right"><label for="idDataSource_NCFMS">Data source</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>
		<label for="idDataSource_NCFMS"><input type="radio" name="radDataSource" id="idDataSource_NCFMS" value="NCFMS" tabindex="#request.nextTabIndex#" disabled>&nbsp;NCFMS</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<label for="idDataSource_DOLAR$"><input type="radio" name="radDataSource" id="idDataSource_DOLAR$" value="DOLAR$" tabindex="#request.nextTabIndex#" checked>&nbsp;DOLAR$</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<span style="font-size: x-small;">Note: NCFMS Transaction Data not available at this time.</span>
		</cfoutput>
	</td>
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
<input type="hidden" name="hidReportType" value="#request.trans_type#">
<div class="buttons">
	<input type="submit" name="btnGenerateReport" value="Generate Report" />
	<input type="reset" name="btnReset" value="Reset"  onClick="javascript:window.location='report_criteria_template.cfm?rpt_id=21&trans=#request.trans_type#'" />
	<input type="button" name="btnCancel" value="Cancel" onClick="javascript:window.location='reports_main.cfm'" />

</div>
</cfoutput>
