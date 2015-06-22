<!--- aapp_line1_fopdetail.cfm --->
<cfoutput>
<!--- these are CF functions --->
<cfinclude template="#application.paths.includes#DataManipulationLib.cfm">
<cfinclude template="#application.paths.reportdir#reportFunctions.cfm">

<cfscript>

tGrStruct = structNew();
tGrStruct = application.ographicsUtils.graphicSetForAAPPNum( url.aapp, session.userID, "Cumulative FOP by Execution Date", "JFGFCompFOP" );

sClass='form3DataTbl';
sTRClass = 'form3AltRow';

</cfscript>

<cffunction name="DisplayPrintColumnHeadings">
	<!--- display Column Headings --->
	<tr>
	<th scope="col" width="8%" style="text-align:left">PY</th>
	<th scope="col" width="8%" style="text-align:right">Fop No.</th>
	<th scope="col" width="8%" style="text-align:left">Cost<br>Category</th>
	<th scope="col" width="30%" style="text-align:left">Purpose</th>
	<th scope="col" width="8%" style="text-align:left">Date<br>Issued</th>
	<th scope="col" width="12%" style="text-align:right">Amount</th>
	<!---
	<th scope="col" width="8%" style="text-align:left">User</th>
	<th scope="col" width="10%" style="text-align:left">Time</th>
	<th scope="col" width="8%" style="text-align:left">Function</th>
	--->
	</tr>
</cffunction> <!--- DisplayColumnHeadings --->

<CFFUNCTION NAME="DisplayReport">
	<CFARGUMENT NAME="aappNum" >
	<CFARGUMENT NAME="date_executed">
	<CFARGUMENT NAME="CostCatList" required="no" default=''>

	<CFSET var vCostCatList = application.outility.buildQuotedValueList(arguments.CostCatList,"Alpha")>

	<!--- copied the SQL that generates the FOP_DATASET_VIEW, and modified to add more fields, and restrictions --->
	<cfset var cmd="SELECT f.py AS programyear,
		  f.fop_id AS fopid,
		  f.fop_num AS fopnum,
		  f.aapp_num AS aappnum,
		  a.contract_status_id AS contractstatusid,
		  a.date_start AS datestart,
		  (SELECT MAX (date_end)
			 FROM aapp_yearend
			WHERE aapp_yearend.aapp_num = a.aapp_num)
			 AS dateend,
		  aapp_program_activity (a.aapp_num) AS programactivity,
		  aapp_program_activity (a.aapp_num, 'S') AS program_activity_short,
		  a.center_id AS centerid,
		  c.center_name AS centername,
		  a.venue AS venue,
		  f.funding_office_num AS fundingofficenum,
		  lo.funding_office_desc AS fundingofficedesc,
		  ct.contractor_name AS contractorname,
		  a.contract_num AS contractnum,
		  f.cost_cat_id AS costcatid,
		  lc.cost_cat_desc AS costcatdesc,
		  f.date_executed AS dateexecuted,
		  f.amount AS amount,
		  f.fop_description AS fopdescription,
		  f.back_loc AS backuploc,
		  lc.cost_cat_code costcatcode,
		  CASE
			 WHEN lc.cost_cat_p_id IS NULL THEN lc.cost_cat_code
			 ELSE lc2.cost_cat_code
		  END
			 AS costcatcodegroup,
		  CASE
			 WHEN lc.cost_cat_p_id IS NULL THEN lc.cost_cat_id
			 ELSE lc.cost_cat_p_id
		  END
			 AS costcatidgroup,
		  CASE WHEN f.arra_ind = 1 THEN 'Y' ELSE '' END AS arra,

		  TO_CHAR(f.update_time, 'MM/DD/YYYY HH:MI:SS') AS updatetime,
		  f.update_user_id as updateuserid,
		  f.update_function as updatefunction

	 FROM fop f,
		  aapp a,
		  center c,
		  contractor ct,
		  lu_cost_cat lc,
		  lu_funding_office lo,
		  lu_cost_cat lc2
	WHERE     f.aapp_num = a.aapp_num
		  AND a.center_id = c.center_id(+)
		  AND a.contractor_id = ct.contractor_id(+)
		  AND f.cost_cat_id = lc.cost_cat_id
		  AND lc.cost_cat_p_id = lc2.cost_cat_id(+)
		  AND f.funding_office_num = lo.funding_office_num

		  AND f.aapp_num = #url.aapp#
		  AND TO_CHAR(f.date_executed, 'MM/DD/YYYY') = '#url.date_executed#'
	">
	<cfif vCostCatList NEQ ''>
		<cfset cmd &= " and lc.cost_cat_p_id is null and lc.cost_cat_code in  #vCostCatList#">
	</cfif>
	<cfset cmd &= "order by lc.cost_cat_code">

	<cfquery name="qReport">
		#preservesinglequotes(cmd)#
	</cfquery>

	<!---
	<cfdump var="#qReport#">
	<cfabort>
	--->

	<!--- based on reports/report_aapp_list.cfm ... see that file for notes --->
	<cfset request.pageID="0">
	<cfset request.htmlTitleDetail = "#tGrStruct.tRepPar.sWindowName#">
	<cfset request.pageTitleDisplay = "Reports">

	<cfsetting requestTimeout = "900">

	<cfparam name="rptMarginTop" default="0.5">
	<cfparam name="rptMarginBottom" default="0.5">
	<cfparam name="rptMarginLeft" default="0.5">
	<cfparam name="rptMarginRight" default="0.5">
	<cfparam name="PDFOrientation" default="landscape">
	<cfparam name="pageType" default="letter">
	<cfparam name="form.radReportFormat" default="application/pdf">


	<cfset na_total = 0>
	<cfset cnt= 0>

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>#request.htmlTitleDetail#</title>
	</head>


	<body class="form">

	<!-- Begin Content Area -->

	<link href="#application.urls.cssdir#jfas_report.css" rel="stylesheet" type="text/css" />

	<div class="form2Content">
		<h1>FOP Details for #url.aapp# #url.date_executed#</h1>
		<table width=100% cellspacing="0" border=0 cellpadding="0"><tr><td align=right>
		<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
		Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
		</font></td></tr>
		</table>
		<table width="100%" class="ReportColumnHeadings form3DataTbl" summary="Column Headings For FOP for Execution Date">

		<cfset DisplayPrintColumnHeadings()>
		<cfset nAmountTotal = 0>

		<cfloop query = "qReport">
			<cfset nAmountTotal += amount>
			<tr>
			<td width="8%" style="text-align:left">#programyear#</td>
			<td width="8%" style="text-align:right">#fopnum#</td>
			<td width="8%" style="text-align:left">#costcatcode#</td>
			<td width="30%" style="text-align:left">#fopdescription#</td>
			<td width="8%" style="text-align:left">#dateformat(dateexecuted, "mm/dd/yyyy")#</td>
			<td width="12%" style="text-align:right" >#NumberFormat(amount, '$,.99')#</td>
			<!---
			<td width="8%" style="text-align:left">#updateuserid#</td>
			<td width="10%" style="text-align:left">#updatetime#</td>
			<td width="8%" style="text-align:left">#updatefunction#</td>
			--->
			</tr>
		</cfloop>
		<tr>
		<td colspan="4">&nbsp;</td>
		<td >Total</td>
		<td style="text-align:right" width="15%">#NumberFormat(nAmountTotal, '$,.99')#</td>

		</tr>
		</table>
		</br>

	</div>
	<!-- /.formContent -->
</cffunction> <!--- DisplayReport --->

<CFSET DisplayReport("#url.aapp#", "#url.date_executed#", "#url.CostCatList#")>
</cfoutput>

</body>
</html>
<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>

<script type="text/javascript">

    $(document).ready(function() {
        document.title = 'JFGFCompFOP';
    });

</script>

