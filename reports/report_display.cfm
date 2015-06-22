<!---
page name: report_display.cfm
Description:
Revision:
2007-08-15	mstein	Add marginTop and marginBottom as variables, so they can be adjusted per report
2014-03-10	mstein	Set request.paths.reportcss different for PDF format (under SSL)
--->

<cfparam name="rptMarginTop" default="0.5">
<cfparam name="rptMarginBottom" default="0.5">
<cfparam name="rptMarginLeft" default="0.5">
<cfparam name="rptMarginRight" default="0.5">
<cfparam name="PDFOrientation" default="landscape">
<cfparam name="pageType" default="letter">

<cfinclude template="#application.paths.reportdir#reportFunctions.cfm">

<!--- set request level path to css - could vary by output format --->
<!--- obs  <cfset request.paths.reportcss = application.paths.reportcss> --->
<cfset request.paths.reportcss = application.urls.cssdir & 'jfas_report.css'>


<cfswitch expression="#form.radReportFormat#">
	<cfcase value="application/pdf">
		<cfset request.paths.reportcss = application.paths.reportcssPDF>
		<cfdocument format="PDF" orientation="#PDFOrientation#" pagetype="#pageType#"
			margintop="#rptMarginTop#" marginbottom="#rptMarginBottom#"
			marginleft="#rptMarginLeft#" marginright="#rptMarginRight#">
		<cfinclude template="#rptTemplate#">
		</cfdocument>
	</cfcase>
	<cfcase value="application/vnd.ms-excel">
		<cfheader name="Content-Disposition" value="inline;filename=report.xls">
		<cfcontent type="application/msexcel">
		<cfinclude template="#rptTemplate#">
	</cfcase>
	<cfdefaultcase>
		<cfinclude template="#rptTemplate#">
	</cfdefaultcase>
</cfswitch>