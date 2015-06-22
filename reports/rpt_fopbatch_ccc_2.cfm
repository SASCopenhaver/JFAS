<cfsilent>
<!---
page: rpt_fopbatch_ccc_2.cfm

description: report that previews/executes/finalizes/un-dos fop batch process for CCC contracts

revisions:

--->

<cfset request.pageID="2521">
<cfparam name="url.sortDir" default="asc">
<cfparam name="url.sortBy" default="center_name">
<cfparam name="form.py_ccc" default="#evaluate(request.py_ccc+1)#">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - FOP Batch Process (CCC)">
<cfset request.pageTitleDisplay = "FOP Batch Process for CCCs: PY #form.py_ccc#">
<!---Query Section--->
<!--- retrieve data from database --->
<cfif not isDefined("url.cache")>
	<cfinvoke component="#application.paths.components#fop_batch" method="getCCCEstFop" py="#form.py_ccc#" returnvariable="rstEstFopSort0" />
	<cfset session.rstEstFopSort1=rstEstFopSort0>
</cfif>
<cfquery name="rstEstFopSort" dbtype="query">
	select	*
	from	session.rstEstFopSort1
	order by #url.sortby# #url.sortDir#
</cfquery>
<cfquery name="rstEstFopTotal" dbtype="query">
	select	funding_office_desc, group_code, sum(amount) as amount
	from	rstEstFopSort
	group by funding_office_desc, group_code
</cfquery>
<cfquery name="rstCenter" dbtype="query">
	select	distinct center_name
	from	session.rstEstFopSort1
	order by center_name
</cfquery>
<cfset col=4>
<cfset blank_filler="NA">
<cfset rstlist = application.outility.VerticalList (
col="#col#", blank_filler="#blank_filler#", list="#valuelist(rstCenter.center_name)#"
)>
</cfsilent>
<!--- include main header file --->
<!---Display Section--->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<title>#request.htmlTitleDetail#</title>
<link href="#request.paths.reportcss#" rel="stylesheet" type="text/css" />
</cfoutput>
</head>
<body class="form">
<table border="0" cellspacing="0" cellpadding="0" align="center" width="762">
<tr>
<td>
	<!-- Begin Content Area -->
		<!-- Begin Form Header Info -->
		<div class="formContent">
			<cfoutput>
			<h1>PY #form.py_ccc# Batch Process: CCC FOP Listing </h1>

			<cfif rstEstFopSort.history_rec eq -1>
			<h1>Batch Process Status: Not Executed</h1>
			<cfelseif rstEstFopSort.history_rec eq 0>
			<h1>Batch Process Status: Executed</h1>
			<cfelseif rstEstFopSort.history_rec eq 1>
			<h1>Batch Process Status: Finalized</h1>
			</cfif>
			<h2>Report Printed #dateformat(now(),"mm/dd/yyyy")# #timeformat(now(),"hh:mm tt")#</h2>
			</cfoutput>
		</div>
</td>
</tr>
</table>

<p></p>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
<tr>
	<th style="text-align:left">Center Name</th>
	<th style="text-align:center">AAPP</th>
	<th style="text-align:center">Cost Category</th>
	<th style="text-align:center">FOP Number</th>
	<th style="text-align:right">Amount</th>
</tr>
<cfset altrow=1>
<cfset curaapp=0>
<cfoutput query="rstEstFopSort">
	<cfif curaapp neq aapp_num>
	<cfset altrow=altrow+1>
	<tr <cfif altrow mod 2>class="AltRow"</cfif>>
		<td>#center_name#</td>
		<td align="center">#aapp_num#</td>
		<cfset curaapp=aapp_num>
	<cfelse>
	<tr <cfif altrow mod 2>class="AltRow"</cfif>>
		<td></td>
		<td></td>
	</cfif>
	<td align="center">#cost_cat_code#</td>
	<td align="center">#fop_num#</td>
	<td align="right"><cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#</td>
	</tr>
</cfoutput>
</table>
<p></p>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
<tr>
	<th style="text-align:left">Agency Name</th>
	<th style="text-align:center"></th>
	<th style="text-align:center">Cost Category</th>
	<th style="text-align:center"></th>
	<th style="text-align:right">Amount</th>
</tr>
<cfset altrow=1>
<cfset curoffice=0>
<cfoutput query="rstEstFopTotal">
	<cfif curoffice neq funding_office_desc>
	<cfset altrow=altrow+1>
	<tr <cfif altrow mod 2>class="AltRow"</cfif>>
		<td>#funding_office_desc#</td>
		<td align="center"></td>
		<cfset curoffice=funding_office_desc>
	<cfelse>
	<tr <cfif altrow mod 2>class="AltRow"</cfif>>
		<td></td>
		<td></td>
	</cfif>
	<td align="center">#group_code#</td>
	<td align="center"></td>
	<td align="right"><cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#</td>
	</tr>
</cfoutput>
</table>
</body>
</html>
