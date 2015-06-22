<!--- aapp_line1_fmsdetail.cfm --->
<cfoutput>
<!--- these are CF functions --->
<cfinclude template="#application.paths.includes#DataManipulationLib.cfm">
<cfscript>

tGrStruct = structNew();
tGrStruct = application.ographicsUtils.graphicSetForAAPPNum( url.aapp, session.userID, "Cumulative FMS by Execution Date", "JFG LINE1FMS" );

sClass='form3DataTbl';
sTRClass = 'form3AltRow';
</cfscript>

<cffunction name="DisplayPrintColumnHeadings">
	<!--- display Column Headings --->
	<tr>
	<th scope="col" width="10%" style="text-align:left">Cost<br>Category</th>
	<th scope="col" width="10%" style="text-align:right">Amount</th>
	<th scope="col" width="70%" style="text-align:right">&nbsp;</th>
	</tr>
</cffunction> <!--- DisplayColumnHeadings --->


<cffunction name="localUrl" >
	   <cfargument name="file" />
	   <cfset var fpath = ExpandPath(file)>
	   <cfset var f="">
	   <cfset f = createObject("java", "java.io.File")>
	   <cfset f.init(fpath)>
	   <cfreturn f.toUrl().toString()>
</cffunction>


<CFFUNCTION NAME="DisplayReport">
	<CFARGUMENT NAME="aappNum" >
	<CFARGUMENT NAME="date_executed">
	<CFARGUMENT NAME="CostCatList" required="no" default=''>

	<CFSET var vCostCatList = application.outility.buildQuotedValueList(arguments.CostCatList,"Alpha")>

	<!--- url.date_executed is like 09/30/2014 --->
	<!--- year, month, day --->
	<cfset dtDate_Executed = CreateDate(mid(date_executed, 7, 4), mid(date_executed, 1, 2), mid(date_executed, 4, 2) )>
	<cfset rep_date_exec = DateFormat(dtDate_Executed, "yyyy-mm-dd") >
	<cfset var cmd="select
			rep_date,
			TO_CHAR(rep_date, 'YYYY-MM-DD') AS date_exec,
			amount,
			lu.cost_cat_code as costCatCode
		from
			center_2110_data c2d,
			center_2110_amount c2a,
			lu_cost_cat lu
		where
			c2d.center_2110_id = c2a.center_2110_id
			and amount <> 0
			and c2a.type_id = 1
			and c2d.aapp_num = #aappNum#
			and rep_date = #dtDate_Executed#
			and lu.cost_cat_id = c2a.cost_cat_id">
	<cfif vCostCatList NEQ ''>
		<cfset cmd &= " and lu.cost_cat_p_id is null and lu.cost_cat_code in  #vCostCatList#">
	</cfif>
	<cfset cmd &= "	order by rep_date, cost_cat_code">

	<cfquery name="qReport">
		#preservesinglequotes(cmd)#
	</cfquery>

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
		<h1>FMS Details for #url.aapp# #url.date_executed#</h1>
		<table width="762" cellspacing="0" border=0 cellpadding="0"><tr><td align=right>
		<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
		Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
		</font></td></tr>
		</table>
		<table width="762" class="ReportColumnHeadings form3DataTbl" summary="Column Headings For FOP for Execution Date">

		<cfset DisplayPrintColumnHeadings()>
		<cfset nAmountTotal = 0>

		<cfloop query = "qReport">
			<cfset nAmountTotal += amount>
			<tr>
			<td width="10%" style="text-align:left">#costcatcode#</td>
			<td width="10%" style="text-align:right" >#NumberFormat(amount, '$,.99')#</td>
			<td width="80%" style="text-align:right" >&nbsp;</td>
			</tr>
		</cfloop>
		<tr>
		<td colspan="1" align="right">Total</td>
		<td style="text-align:right" width="10%">#NumberFormat(nAmountTotal, '$,.99')#</td>
		<td width="80%" style="text-align:right" >&nbsp;</td>

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
    	// simply change the title in the browser
        document.title = 'JFG LINE1FMS';
    });

</script>

