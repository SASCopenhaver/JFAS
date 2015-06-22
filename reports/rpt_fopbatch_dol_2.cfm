<cfsilent>
<!---
page: rpt_fopbatch_dol_2.cfm

description: report that previews/executes/finalizes/un-dos fop batch process for DOL contracts

revisions:

--->

<cfset request.pageID="2511">
<cfparam name="url.sortDir" default="asc">
<cfparam name="url.sortBy" default="aapp_num">
<cfparam name="url.py" default="#evaluate(request.py+1)#">
<cfparam name="form.py" default="#url.py#">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - FOP Batch Process (DOL)">
<cfset request.pageTitleDisplay = "FOP Batch Process for DOL Contracts: PY #form.py#">
<cfsetting requestTimeout = "900">
<!---Query Section--->
<!--- retrieve data from database --->
<cfif not isDefined("url.cache")>
	<cfinvoke component="#application.paths.components#fop_batch" method="getEstFopSort" py="#form.py#" sortBy="#url.sortBy#" sortDir="#url.sortDir#" returnvariable="rstEstFopSort0" />
	<cfset session.rstEstFopSort1=rstEstFopSort0>
</cfif>
<cfset vst_msg="Note: There are certain AAPPs on this page for which the latest FMS report date is earlier than 03/31/#form.py#. A current FMS report is required for calculation of the CTST allocation. The FOP Batch Process can not be executed until this problem has been fixed.">
<cfquery name="rstEstFopSort" dbtype="query">
	select	*
	from	session.rstEstFopSort1
<cfif #url.sortby# neq "aapp_num">
	order by #url.sortby# #url.sortDir#, aapp_num asc, cost_cat_code asc
<cfelse>
	order by #url.sortby# #url.sortDir#, center_name asc, cost_cat_code asc
</cfif>
</cfquery>
<cfquery name="rstEstFopTotal" dbtype="query">
	select	cost_cat_code, sum(amount) as amount
	from	rstEstFopSort
	where	cost_cat_code!='B4'
	group by cost_cat_code
	union
	select	cost_cat_code, sum(amount) as amount
	from	rstEstFopSort
	where	cost_cat_code='B4'
	and		amount!=-1
	group by cost_cat_code
	order by cost_cat_code
</cfquery>
<cfquery name="vst_err" dbtype="query">
	select	aapp_num
	from	rstEstFopSort
	where	cost_cat_code='B4'
	and		amount=-1
</cfquery>

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
			<h1>PY #form.py# Batch Process: DOL FOP Listing </h1>

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
	<th style="text-align:center">AAPP</th>
	<th style="text-align:left">Center</th>
	<th style="text-align:center">Cost Category</th>
	<th style="text-align:center">FOP Number</th>
	<th style="text-align:right">Amount</th>
</tr>
<cfset same_aapp=0>
<cfset altrow=-1>
<cfoutput query="rstEstFopSort">
	<cfif same_aapp neq aapp_num>
		<cfset altrow=altrow+1>
	</cfif>
<tr <cfif altrow mod 2>class="form2AltRow"</cfif>>
	<cfif same_aapp eq aapp_num>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	<cfelse>
	<cfset same_aapp=aapp_num>
		<td align="center">#aapp_num#</td>
		<td>#center_name#</td>
	</cfif>
	<td align="center">
		#cost_cat_code#
	</td>
	<td align="center">#fop_num#</td>
	<td align="right">
		<cfif cost_cat_code eq "B4" and listfind(valuelist(vst_err.aapp_num),aapp_num)>
			NA
		<cfelseif cost_cat_code eq "B4" and not listfind(valuelist(vst_err.aapp_num),aapp_num)>
			<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#</td>
		<cfelse>
			<!--- mstein 2007-03-30 --->
			<cfif amount eq "">
				0
			<cfelse>
				<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#
			</cfif>
		</cfif>
	</td>
</tr>
</cfoutput>
<tr>
	<td colspan="5">&nbsp;</td>
</tr>
<tr>
	<td colspan="5" class="hrule"></td>
</tr>
<cfoutput query="rstEstFopTotal">
<tr>
	<td colspan="2">
	<cfif currentrow eq 1>
		<strong>Totals by Cost Category</strong>
	<cfelse>
		&nbsp;
	</cfif>
	</td>
	<td align="center"><strong>#cost_cat_code#</strong></td>
	<td align="center"></td>
	<td align="right">
		<strong>
		<!--- mstein 2007-03-30 --->
		<cfif amount eq "">
			0
		<cfelse>
			<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#
		</cfif>
		</strong></td>
</tr>
</cfoutput>
</table>
