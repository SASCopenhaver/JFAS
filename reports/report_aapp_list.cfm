<!---
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

<cfparam name="url.SortBy" default="aappNum">
<cfparam name="url.SortDir" default="asc">

<cfparam name="rptMarginTop" default="0.5">
<cfparam name="rptMarginBottom" default="0.5">
<cfparam name="rptMarginLeft" default="0.5">
<cfparam name="rptMarginRight" default="0.5">
<cfparam name="PDFOrientation" default="landscape">
<cfparam name="pageType" default="letter">
<cfparam name="form.radReportFormat" default="application/pdf">

<cfinclude template="#application.paths.reportdir#reportFunctions.cfm">

<cffunction name="DisplayPrintColumnHeadings">
	<!--- display Column Headings --->
	<table width="100%" class="ReportColumnHeadings" summary="Column Headings for list of AAPPs">
	<tr>

		<th scope="col" width="6%">AAPP</th>
		<th scope="col" width="6%">Fund</th>
		<th scope="col" width="22%">Center</th>
		<th scope="col" width="22%">Activity</th>
		<th scope="col" width="16%">Contractor</th>
		<th scope="col" width="12%">Contract No.</th>
		<th scope="col" width="8%">Start</th>
		<th scope="col" width="8%">End</th>
	</tr>
	</table> <!--- column headings --->
</cffunction> <!--- DisplayColumnHeadings --->

<cfset request.paths.reportcss = application.paths.reportcssPDF>
<cfoutput>

<cfset na_total = 0>
<cfset cnt= 0>
<!--- get the current filter information from session scope --->
<cfscript>
// CF supports named arguments just like JS!

responseStruct = application.oaapp_home.CFSessionDisplayDataColumnsGuts(
	formDataIn:session.userpreferences.tmyfilternow
	, textOnly:1						// integer (1 = true, 0 = false).  This sets class to form3DataTbl, sTRClass = form3AltRow
	, roleID:#session.roleID#			// integer
	, region:#session.region#			// integer
	, sortBy:url.SortBy
	, sortDir:url.SortDir
	) ;

sColumnsOfData	= responseStruct.SCOLUMNSOFDATA;
sFilterHTML		= responseStruct.SFILTERHTML;
</cfscript>
</cfoutput>


<cfdocument format="PDF" orientation="#PDFOrientation#" pagetype="#pageType#"
	margintop="#rptMarginTop#" marginbottom="#rptMarginBottom#"
	marginleft="#rptMarginLeft#" marginright="#rptMarginRight#">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<title>AAPP List</title>
</cfoutput>
</head>


<body class="form">

<cfdocumentsection>
<!-- Begin Content Area -->
<cfoutput>

<style>
<cfinclude template="#application.paths.reportcss#">
</style>

<div class="formContent">
	<h1>JFAS AAPP Listing</h1>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
	<tr><td align=center>#sFilterHTML#</td></tr>
	</table>
	<table width=100% cellspacing="0" border=0 cellpadding="0"><tr><td align=right>
	<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
	Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
	</font></td></tr>
	</table>
	<br />
	<cfset DisplayPrintColumnHeadings()>
	#sColumnsOfData#
	</br>

</div>
<!-- /.formContent -->

<!-- Begin Form Footer Info -->
<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
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
<!-- End footer Area -->


</cfoutput>

<!-- End Content Area -->

</cfdocumentsection>

</body>
</html>

</cfdocument>
