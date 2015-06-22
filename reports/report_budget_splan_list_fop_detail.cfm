<!---
page name: report_budget_splan_list_fop_detail.cfm 2/10/2015

based on
report_aapp_list.cfm
reports/reports.cfm?rpt_id=4&aapp=2352
	which includes ...
	<cfinvoke component="#application.paths.components#reports" method="getFopList" formdata="#form#" returnvariable="rstFopList" />
	<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#form.AAPP#" returnvariable="rstGetAAPPGeneral" />
	<cfset rptTemplate="rpt_fop_aapp.cfm">

rpt_fop_aapp.cfm


Here is writeup for report_aapp_list.cfm , descsribing structure of that program
page name: report_aapp_list.cfm  - based on report_display.cfm
Description:	Displays the AAPP list from the home page
author:	Don Bellenger 03/12/2014

This collapses the large hierarchy described here, for the Budget Status Report
reports_main
	link to report_criteria_template.cfm?rpt_id=13
		has <form> to sumbit to reports.cfm

reports.cfm
	sets rptTemplate=rpt_budget_status.cfm
	includes report_display.cfm (so its parameters are available in report_display.cfm)

report_display.cfm  (model for this report)
	sets margin parameters
	sets pointer to request.paths.reportcss
	contains <cfdocument>
	<cfinclude #rptTemplate# = rpt_budget_status.cfm>
	contains </ctdocument>

rpt_budget_status.cfm
	calls related methods to get the data
	contains <!DOCTYPE html>
	<title>
	<link to reportcss>

	<body class="form"
	<cfoutput>

	// content area
	 <cfdocumentitem type="pagebreak">

	<cfdocumentsection>
	<style>
	<cfinclude template="#application.paths.reportcss#">
	</style>
	<cfinclude template="rpt_budget_status_content.cfm">
	</cfdocumentsection>

	<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
		<cfdocumentitem type="footer">

	</cfoutput>
	</body>
	</html>

rpt_budget_status_content.cfm
	<cfoutput>
	<div class="formContent">
	<h1>Program Year #rsCurrentPY# Budget Status Report for #rsFundingOffice.fundingOfficeDesc#</h1>
	<br>
	<table class="formHDRInfo"> etc.
--->

<cfset request.pageID="0">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "Reports">

<cfsetting requestTimeout = "900">

<cfparam name="url.splanTransIdList" default="">
<cfparam name="url.splanCatIdList" default="">
<cfparam name="url.PY" default="2013">
<cfparam name="url.SplanCatDesc" default="">

<cfparam name="rptMarginTop" default="0.5">
<cfparam name="rptMarginBottom" default="0.5">
<cfparam name="rptMarginLeft" default="0.5">
<cfparam name="rptMarginRight" default="0.5">
<cfparam name="PDFOrientation" default="landscape">
<cfparam name="pageType" default="letter">
<cfparam name="form.radReportFormat" default="application/pdf">

<!--- testing --->
<cfset form.radReportFormat = "">

<!--- get MakeCSSForPDF() --->
<cfinclude template="#application.paths.reportdir#reportFunctions.cfm">

<!--- GET THE DATA --->
<cfset tData = {}>
<cfset tData = application.oSplan.getSplanListFopDetails ( splanTransDetIdList = url.splanTransDetIdList, splanCatIdList = url.splanCatIdList , SortBy = 'fopnum' ) />

<cfset aData = duplicate( tData.aRet )>

<!--- get lookup data for code codes --->
<cfquery name="qCostCat">
	select cost_cat_id AS costCatId, cost_cat_code AS costCatCode from lu_cost_cat
</cfquery>
<cfset slcostcatid = valuelist( qCostCat.costCatId )>
<cfset slcostcatcode = valuelist( qCostCat.costCatCode )>

<cffunction name="DisplayPrintColumnHeadings">
	<!--- display Column Headings --->
	<tr>

		<th scope="col" width="4%" style="text-align:center" >PY</th>
		<th scope="col" width="4%" style="text-align:right" >FOP No.</th>
		<th scope="col" width="4%" style="text-align:right" >AAPP No.</th>
		<th scope="col" width="10%" style="text-align:right" >Program Activity</th>
		<th scope="col" width="15%" style="text-align:right" >Performance Venue/Center</th>
		<th scope="col" width="12%" style="text-align:right" >Contractor</th>
		<th scope="col" width="12%" style="text-align:right" >Contract No.</th>
		<th scope="col" width="4%">Cost Cat.</th>
		<th scope="col" width="4%">ARRA</th>
		<th scope="col" width="6%">Date Issued</th>
		<th scope="col" width="5%" style="text-align:right" >Amount</th>
		<th scope="col" width="*">Purpose</th>
	</tr>
</cffunction> <!--- DisplayColumnHeadings --->

<cfset request.paths.reportcss = application.paths.reportcssPDF>
<cfoutput>

<cfset na_total = 0>
<cfset cnt= 0>

</cfoutput>
<!--- ******  BEGIN HTML --->

<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
<!---
<cfdocument format="PDF" orientation="#PDFOrientation#" pagetype="#pageType#"
	margintop="#rptMarginTop#" marginbottom="#rptMarginBottom#"
	marginleft="#rptMarginLeft#" marginright="#rptMarginRight#">
	--->
</cfif>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<title>FOP List</title>
</cfoutput>
</head>


<body class="form">
<table name="reportOutside" border="0" cellspacing="0" cellpadding="0" align="center" width="762">
<tr>
<td>

<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
<!---
<cfdocumentsection>
--->
</cfif>

<cfoutput>

<style>
<cfinclude template="#application.paths.reportcss#">
</style>

<!-- Begin Content Area -->

<div class="formContent">
	<!-- begin Header Block -->
	<h1>FOP Allocations for Spend Plan Transaction SP #url.splanTransIdList#</h1>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
	<tr><td align=center>PY #url.PY# - Category #url.SplanCatDesc#</td></tr>
	</table>

	<table width=100% cellspacing="0" border=0 cellpadding="0"><tr><td align=right>
	<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
	Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
	</font></td></tr>
	</table>
	<br />
	<!-- End Header Block -->

	<!--- start form1DataTbl to contain the column headings and data --->

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
	<cfset DisplayPrintColumnHeadings()>
	<cfif arrayLen(aData) eq 0>
		<tr>
			<td colspan="6" style="text-align:center">
				<br />
				<br />
				<br />
				There are no matching records.
			</td>
		</tr>

	<cfelse>

		<!--- there are records to show  --->
		<cfset fopTotal = 0>
		<cfloop index="currentRow" from = "1" to = "#arrayLen(aData)#">

			<cfset costCatCode =  ListGetAt( slCostCatCode, ListFindNoCase ( slCostCatId, aData[currentRow].costcatid ))>

			<tr <cfif currentrow mod 2>class="formAltRow"</cfif>>

				<td >#aData[currentRow].PY#</td>
				<td >#aData[currentRow].fopnum#</td>
				<td >#aData[currentRow].fopaapp#</td>
				<td >#aData[currentRow].program_activity_short#</td>
				<td >#aData[currentRow].venue# #aData[currentRow].centername#</td>
				<td >#aData[currentRow].contractorname#</td>
				<td >#aData[currentRow].contractnum#</td>
				<td >#costCatCode#</td>
				<td >#aData[currentRow].arra#</td>
			<td >#dateformat(aData[currentRow].fopdateexecuted, "mm/dd/yyyy")#</td>
				<td style="text-align:right" >#numberformat(aData[currentRow].fopamount,  "$,")#</td>
				<td >#aData[currentRow].fopdescription#</td>

			</tr>
			<cfif IsNumeric(aData[currentRow].fopamount)><cfset fopTotal += aData[currentRow].fopamount></cfif>
		</cfloop>
		<tr style="font-weight: bold;">
			<td colspan="9" >&nbsp;</td>

			<td style="valign: bottom;">Total</td>
			<td style="valign: bottom;text-align: right">#NumberFormat(fopTotal,  "$,")#</td>
			<td></td>
		</tr>

	</cfif> <!--- there are records to show --->
	</table> <!--- form1DataTbl --->
	</br>

</div>
<!-- /.formContent -->

<!-- Begin Form Footer Info -->
<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
	<!--- it is a PDF.  Show page into --->
	<cfdocumentitem type="footer">
	<table width=100% cellspacing="0" border=0 cellpadding="0">
		<tr>
		<td align=right>
			<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
				page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
			</font>
		</td>
		</tr>
	</table>
</cfdocumentitem>
</cfif>
<!-- End Form Footer Info -->
</cfoutput>
</td>
</tr>
</table> <!--- reportOutside --->
</body>
</html>
