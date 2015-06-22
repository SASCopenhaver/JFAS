<!---
page name: report_budget_splan_list_fop_sum.cfm 2/10/2015

This corresponds to the Splan Transaction List

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

<!--- get MakeCSSForPDF() --->
<cfinclude template="#application.paths.reportdir#reportFunctions.cfm">

<!--- GET THE PARAMETERS FROM THE TRANSACTION PAGE --->

<cfset tSessionPars = duplicate ( session.tsplanlistformdata )>

<!--- convert empty strings to undefined --->
<cfset tPars = OnlyDefined (tSessionPars)>


<cfparam name="rptMarginTop" default="0.5">
<cfparam name="rptMarginBottom" default="0.5">
<cfparam name="rptMarginLeft" default="0.5">
<cfparam name="rptMarginRight" default="0.5">
<cfparam name="PDFOrientation" default="landscape">
<cfparam name="pageType" default="letter">

<cfparam name="radReportFormat" default="application/vnd.ms-excel">

<!--- GET THE DATA --->
<cfset tData = {}>

<cfset tData = application.oSplan.getSplanListFopSum ( argumentCollection: "#tPars#" ) />
<!---
<cfset tData = application.oSplan.getSplanListFopSum ( py = tPars.py, splanCatIdList = tPars.splanCatIdList , SortBy = tPars.sortBy, sortDir = tPars.sortDir, startDate = tPars.startDate, endDate = tPars.EndDate ) />
--->

<cfset aData = duplicate( tData.aRet )>

<!---
<cfdump var=#aData# label = "aData">
<cfabort>
--->

<!--- get lookup data for category AND status --->
<cfquery name="qCostCat">
	select cost_cat_id AS costCatId, cost_cat_code AS costCatCode from lu_cost_cat
</cfquery>
<cfset slcostcatid = valuelist( qCostCat.costCatId )>
<cfset slcostcatcode = valuelist( qCostCat.costCatCode )>

<cffunction name="DisplayPrintColumnHeadings">
	<!--- display Column Headings --->
	<tr>

		<th scope="col" width="10%" >Date</th>
		<th scope="col" width="10%" >Trans</th>
		<th scope="col" width="*">Description</th>
		<th scope="col" width="20%">Category</th>
		<th scope="col" width="16%" style="text-align:right" >Amount</th>
		<th scope="col" width="16%" style="text-align:right" >FOP Amount</th>
		<th scope="col" width="8%">Status</th>
	</tr>
</cffunction> <!--- DisplayColumnHeadings --->

<cfset request.paths.reportcss = application.paths.reportcssPDF>

<!---
<cfswitch expression="#arguments.radReportFormat#">
	<cfcase value="application/pdf">
		<cfset request.paths.reportcss = application.paths.reportcssPDF>
		<cfdocument format="PDF" orientation="#PDFOrientation#" pagetype="#pageType#"
			margintop="#rptMarginTop#" marginbottom="#rptMarginBottom#"
			marginleft="#rptMarginLeft#" marginright="#rptMarginRight#">
	</cfcase>
	<cfcase value="application/vnd.ms-excel">
		<cfheader name="Content-Disposition" value="inline;filename=report.xls">
		<cfcontent type="application/msexcel">
	</cfcase>
</cfswitch>
--->






<cfoutput>

<cfset na_total = 0>
<cfset cnt= 0>

</cfoutput>
<!--- ******  BEGIN HTML --->


<!--- this is all it takes to export Excel --->
<cfheader name="Content-Disposition" value="inline;filename=splantransactions.xls">
<cfcontent type="application/msexcel">


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
	<h1>Spend Plan Transactions</h1>
	<!---
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
	<tr><td align=center>PY #tPars.PY# - Category #tPars.SplanCatDesc#</td></tr>
	</table>
	--->

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
		<cfset amountTotal = 0>
		<cfset foramountTotal = 0>
		<cfloop index="currentRow" from = "1" to = "#arrayLen(aData)#">

			<cfif len( aData[currentRow].amount ) gt 0 AND ( aData[currentRow].amount GT .5 OR aData[currentRow].amount LE -.5)>
				<cfset sAmount = "#numberformat(aData[currentRow].amount,  "$-,")#">
			<cfelse>
				<cfset sAmount = "&nbsp;">
			</cfif>

			<cfif len( aData[currentRow].fopamount ) gt 0 AND ( aData[currentRow].fopamount GT .5 OR aData[currentRow].fopamount LE -.5)>
				<cfset sFopamount = "#numberformat(aData[currentRow].fopamount,  "$-,")#">
			<cfelse>
				<cfset sFopamount = "&nbsp;">
			</cfif>

			<tr <cfif currentrow mod 2>class="AltRow"</cfif>>

				<td >#DateFormat(aData[currentRow].transdate, "mm/dd/yyyy")#</td>
				<td >SP #NumberFormat (aData[currentRow].splanTransID )#</td>
				<td >#aData[currentRow].transdesc#</td>
				<td >#aData[currentRow].splancatdesc#</td>
				<td style="text-align:right" >#sAmount#</td>
				<td style="text-align:right" >#sFopamount#</td>
				<td >#aData[currentRow].transstatusdesc#</td>

			</tr>
			<cfif IsNumeric(aData[currentRow].amount)><cfset amountTotal += aData[currentRow].amount></cfif>
			<cfif IsNumeric(aData[currentRow].fopamount)><cfset foramountTotal += aData[currentRow].fopamount></cfif>
		</cfloop>
		<tr style="font-weight: bold;">
			<td colspan="3" >&nbsp;</td>

			<td style="valign: bottom;">Total</td>
			<td style="valign: bottom;text-align: right">#NumberFormat(amountTotal,  "$-,")#</td>
			<td style="valign: bottom;text-align: right">#NumberFormat(foramountTotal,  "$-,")#</td>
			<td></td>
		</tr>

	</cfif> <!--- there are records to show --->
	</table> <!--- form1DataTbl --->
	</br>

</div>
<!-- /.formContent -->

<!-- Begin Form Footer Info -->
<cfif isDefined("arguments.radReportFormat") and arguments.radReportFormat eq "application/pdf">
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
