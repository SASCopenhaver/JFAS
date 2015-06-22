<!--- aapp_line1_ecpdetail.cfm --->
<cfoutput>
<!--- these are CF functions --->
<cfinclude template="#application.paths.includes#DataManipulationLib.cfm">
<cfinclude template="#application.paths.reportdir#reportFunctions.cfm">
<cfscript>

tGrStruct = structNew();
tGrStruct = application.ographicsUtils.graphicSetForAAPPNum( url.aapp, session.userID, "Cumulative FOP by Execution Date", "JFGFCompECP" );

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


<CFFUNCTION NAME="DisplayReport">
	<CFARGUMENT NAME="aappNum" >
	<CFARGUMENT NAME="date_executed">
	<CFARGUMENT NAME="CostCatList" required="no" default=''>

	<CFSET var vCostCatList = application.outility.buildQuotedValueList(arguments.CostCatList,"Alpha")>
	<!--- ECP data --->

	<cfquery name="qECP1">
		select
		date_start, years_option, years_base
		from aapp p
		where
		p.aapp_num = #aappNum#
	</cfquery>

	<!--- determine which year in the ECP matches the date passed in --->
	<cfset var walker = 0>
	<cfset var walker2 = 0>
	<cfset var maxyears = qECP1.years_option + qECP1.years_base>
	<cfset var aOneYear = []>
	<cfset var aECP = []>
	<cfset var startmonth = month(qECP1.date_start)>
	<cfset var startday = day(qECP1.date_start)>
	<cfset var startyear = year(qECP1.date_start)>
	<!--- date_executed is like 09/30/2014 --->
	<!--- year, month, day --->
	<cfset dtDate_Executed = CreateDate(mid(date_executed, 7, 4), mid(date_executed, 1, 2), mid(date_executed, 4, 2) )>
	<cfset dtDate_ExecutedPlus1 = DateAdd("d", 1, dtDate_Executed)>

	<cfset var qOneYear = ''>
	<!--- set up initial "0" point --->
	<cfset aECP[1] = structNew()>
	<cfset aECP[1].date_exec = DateFormat(CreateDate( startyear, startmonth, startday ), "yyyy-mm-dd")  >
	<cfset aECP[1].amt = 0  >

	<cfloop INDEX="walker" FROM = "1" TO="#maxyears#">

		<!--- only do the year that matches the one passed in --->
		<cfset testfromdb = CreateDate( startyear + 1 + ( walker - 1), startmonth, startday )>
		<cfif testfromdb EQ date_executed OR testfromdb EQ dtDate_ExecutedPlus1 >
			<cfset rep_date_exec = DateFormat(CreateDate( startyear + 1 + ( walker - 1), startmonth, startday ), "yyyy-mm-dd") >
			<cfset cmd="select	act.contract_type_code costCatCode
				, lu_cost_cat.cost_cat_id costCatID
				,contract.fun_getcumulativeamount(p.aapp_num, lu_cost_cat.cost_cat_id, #walker#) as amount
				, '#rep_date_exec#' as date_exec
				, p.aapp_num as aappNum
				from	aapp_contract_type act, aapp p, lu_cost_cat
				where	act.aapp_num = p.aapp_num and
						act.contract_type_code = lu_cost_cat.cost_cat_code and
						p.aapp_num = #aappNum#
			">
			<cfif vCostCatList NEQ ''>
				<cfset cmd &= " and lu_cost_cat.cost_cat_p_id is null and lu_cost_cat.cost_cat_code in  #vCostCatList#">
			</cfif>

			<cfset cmd &= "	order by costCatCode">

			<cfquery name="qReport">
				#preservesinglequotes(cmd)#
			</cfquery>
		</cfif>
	</cfloop> <!--- each year --->

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

	<!---<cfset nTableWidth=762> --->
	<cfset nTableWidth=986>
	<cfset na_total = 0>
	<cfset cnt= 0>

	<!--- ******************  BEGIN HTML --->
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
		<h1>ECP Details for #url.aapp# #url.date_executed#</h1>
		<table width="#nTableWidth#" cellspacing="0" border=0 cellpadding="0"><tr><td align=right>
		<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
		Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
		</font></td></tr>
		</table>
		<table width="#nTableWidth#" class="ReportColumnHeadings form3DataTbl" summary="Column Headings For FOP for Execution Date">

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
	<!-- /.form2Content -->
</cffunction> <!--- DisplayReport --->

<CFSET DisplayReport("#url.aapp#", "#url.date_executed#", "#url.CostCatList#")>
</cfoutput>

</body>
</html>
<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>

<script type="text/javascript">

    $(document).ready(function() {
    	// simply change the title in the browser
        document.title = 'JFGFCompECP';
    });

</script>

