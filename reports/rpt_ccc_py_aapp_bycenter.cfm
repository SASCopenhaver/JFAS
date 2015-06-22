<cfsilent>
<!---
page: rpt_ccc_aapp_bycenter.cfm

description: display Program Year Initial CCC Budget (by Center)

revisions:
2007-10-17	mstein	Added PY length proration note at top
2014-07-01	mstein	Modified code to resolve defect - kluge to allow PDF format from AAPP section (should be redone)
--->

<cfset request.pageID = "510" />
<cfset aapp_num = 0>
<cfset py = 0>
<cfparam name="form.radReportFormat" default = "application/pdf">

<cfif isDefined("form.cboAAPP")>
	<cfset aapp_num = mid(form.cboAAPP, 1, find('-',form.cboAAPP)-1)>
<cfelseif isDefined("url.aapp")>
	<cfset aapp_num = url.aapp>
</cfif>
<cfif isDefined("url.py")>
	<cfset py = #url.py#>
<cfelseif isDefined("form.cbopy")>
	<cfset py = #form.cboPy#>
</cfif>

<cfinvoke component="#application.paths.components#fop_batch" method="getCCCNewPYBudget" aapp="#aapp_num#" py="#PY#" returnvariable="rst" />
<cfquery datasource="#request.dsn#" name="getCenterName">
	select CENTER_NAME
	from center c, aapp a
	where c.CENTER_ID = a.CENTER_ID and a.aapp_num = #aapp_num#
</cfquery>
<cfquery name="group_a" dbtype="query">
	select	*
	from	rst.rs2
	where	cost_cat_code='A'
</cfquery>
<cfquery name="group_b" dbtype="query">
	select	*
	from	rst.rs2
	where	cost_cat_code in ('B2','B3','B4')
</cfquery>
<cfquery name="group_c1" dbtype="query">
	select	*
	from	rst.rs2
	where	cost_cat_code='C1'
</cfquery>
<cfquery name="group_c2" dbtype="query">
	select	*
	from	rst.rs2
	where	cost_cat_code='C2'
</cfquery>
<cfquery name="group_s" dbtype="query">
	select	*
	from	rst.rs2
	where	cost_cat_code='S'
</cfquery>
<cfquery name="group_sum" dbtype="query">
	select	cost_cat_id, sum(amount_py_base) as amount
	from	rst.rs2
	where	amount_py_base is not null
	and		cost_cat_id is not null
	group by cost_cat_id
</cfquery>
<cfquery name="fstatus" dbtype="query">
	<cfif py lt evaluate(request.py_ccc+1)>
		select	1 as ro
		from	rst.rs3
		<cfelse>
		select	checked as ro
		from	rst.rs3
		where	worksheet_status_id=4
	</cfif>
</cfquery>

</cfsilent>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<title>#request.htmlTitleDetail#</title>
<cfif isDefined("form.cboAAPP")>
<link href="#request.paths.reportcss#" rel="stylesheet" type="text/css" />
</cfif>
</cfoutput>
</head>


<cfif isDefined("form.cboAAPP")><!--- AAPP coming from form.cboAAPP - display it from report section --->
	<body class="form">

		<div class="formContent">
		<cfoutput>
		<h1>Program Year #py# Budget Worksheet for Center #getCenterName.CENTER_NAME# (AAPP #aapp_num#)</h1>
		<h2>Report Printed #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#</h2>
		</cfoutput>

		<cfoutput>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="Display Report header data">
			<tr>
				<td>
					Inflation allowance for federal personnel: #numberformat(evaluate((rst.rs3.fed_rate-1)*100),".00")#%<br />
					Inflation allowance for other expenses: #numberformat(evaluate((rst.rs3.omb_rate-1)*100),".00")#%<br />
					<!---
					Inflation allowance for vehicle expenses: #numberformat(evaluate((rst.rs3.omb_b3_rate-1)*100),".00")#%
					--->
				</td>
			</tr>
		</table>
		</cfoutput>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form1DataTbl" summary="display report data">
		<cfoutput>
		<tr>
			<th scope="col" width="*" valign=bottom>Cost Category</th>
			<th scope="col" width="14%" style="text-align:center" valign=bottom>PY #evaluate(py-1)# Baseline</th>
			<th scope="col" width="14%" style="text-align:center" valign=bottom>PY #py# Target</th>
			<th scope="col" width="14%" style="text-align:center" valign=bottom>PY #py# CCC Agency Proposal</th>
			<th scope="col" width="14%" style="text-align:center" valign=bottom>DOL Adjustment</th>
			<th scope="col" width="14%" style="text-align:center" valign=bottom>PY #py# Final Approved Budget Amount</th>
		</tr>
		</cfoutput>

		<!---Group A--->
		<cfoutput query="group_a">
		<cfif not len(cost_cat_id)>
		<tr>
			<td colspan="6" class="hrule"></td>
		</tr>
		</cfif>

		<tr <cfif group_a.currentrow mod 2 and len(cost_cat_id)>class="form2AltRow"</cfif>>
			<td>
				<cfif not len(cost_cat_id)>
					<strong>#cost_cat_desc#</strong>
				<cfelse>
					#cost_cat_desc#
				</cfif>
			</td>
			<td align="right">
				#numberformat(amount_py_base,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_inflated,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_proposed,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_dol_adjusted,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_final,'$,')#
			</td>
		</tr>
		</cfoutput>
		<tr>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<cfoutput query="group_b">
		<tr class="form2AltRow">
			<td>
				#cost_cat_desc#
			</td>
			<td align="right">
				#numberformat(amount_py_base,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_inflated,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_proposed,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_dol_adjusted,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_final,'$,')#
			</td>
		</tr>
		</cfoutput>
		<tr>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<cfoutput query="group_c1">
		<tr class="form2AltRow">
			<td>
				#cost_cat_desc#
			</td>
			<td align="right">
				#numberformat(amount_py_base,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_inflated,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_proposed,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_dol_adjusted,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_final,'$,')#
			</td>
		</tr>
		</cfoutput>
		<tr>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<cfoutput query="group_c2">
		<tr class="form2AltRow">
			<td>
				#cost_cat_desc#
			</td>
			<td align="right">
				#numberformat(amount_py_base,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_inflated,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_proposed,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_dol_adjusted,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_final,'$,')#
			</td>
		</tr>
		</cfoutput>
		<tr>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<cfoutput query="group_s">
		<tr class="form2AltRow">
			<td>
				#cost_cat_desc#
			</td>
			<td align="right">
				#numberformat(amount_py_base,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_inflated,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_proposed,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_dol_adjusted,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_final,'$,')#
			</td>
		</tr>
		</cfoutput>
		</table>

		<!--- display comments and status --->
		<cfoutput>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form1DataTbl" summary="display report comments and status">
		<tr>
			<td colspan="2" class="hrule" height="10"></td>
		</tr>
		<tr valign="top">
			<td width="10%"><strong>Comments:</strong></td>
			<td>#REreplace(rst.rs3.ccc_comment, chr(13), '<BR>', 'all')#</td>
		</tr>
		<tr>
			<td colspan="2" class="hrule"></td>
		</tr>
		<tr>
			<td><strong>Status:</strong></td>
			<td>
				<cfloop query="rst.rs3">
					<cfif checked eq 1>#worksheet_status_desc#</cfif>
				</cfloop>
			</td>
		</tr>
		</table>
		</cfoutput>

		</div>

		<cfoutput>
		<!-- Begin Form Footer Info -->
		<cfif (isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf")>
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
	</body>

<cfelse><!---  aapp coming from URL - display it from form section --->

	<cfdocument format="PDF" pagetype="letter" orientation="portrait">

		<!--- this is one report that is generated in PDF format from outside of the reports section --->
		<cfset request.paths.reportcss = application.paths.reportcssPDF>

		<cfoutput>
			<link href="#request.paths.reportcss#" rel="stylesheet" type="text/css" />
		</cfoutput>

		<body class="form">

		<div class="formContent">
		<cfoutput>
		<h1>Program Year #py# Budget Worksheet for Center #getCenterName.CENTER_NAME# (AAPP #aapp_num#)</h1>
		<h2>Report Printed #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#</h2>
		</cfoutput>

		<cfoutput>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="Display Report header data">
			<tr>
				<td>
					Inflation allowance for federal personnel: #numberformat(evaluate((rst.rs3.fed_rate-1)*100),".00")#%<br />
					Inflation allowance for other expenses: #numberformat(evaluate((rst.rs3.omb_rate-1)*100),".00")#%<br />
					<cfif rst.rs3.prorate_factor neq 1> <!--- if prev PY, or next PY is leap year, show proration factor --->
						Proration factor for differences in Program Year length: #rst.rs3.prorate_factor#<br />
					</cfif>
					<!---
					Inflation allowance for vehicle expenses: #numberformat(evaluate((rst.rs3.omb_b3_rate-1)*100),".00")#%
					--->
				</td>
			</tr>
		</table>
		</cfoutput>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form1DataTbl" summary="display report data">
		<cfoutput>
		<tr>
			<th scope="col" width="*" valign=bottom>Cost Category</th>
			<th scope="col" width="14%" style="text-align:center" valign=bottom>PY #evaluate(py-1)# Baseline</th>
			<th scope="col" width="14%" style="text-align:center" valign=bottom>PY #py# Target</th>
			<th scope="col" width="14%" style="text-align:center" valign=bottom>PY #py# CCC Agency Proposal</th>
			<th scope="col" width="14%" style="text-align:center" valign=bottom>DOL Adjustment</th>
			<th scope="col" width="14%" style="text-align:center" valign=bottom>PY #py# Final Approved Budget Amount</th>
		</tr>
		</cfoutput>

		<!---Group A--->
		<cfoutput query="group_a">
		<cfif not len(cost_cat_id)>
		<tr>
			<td colspan="6" class="hrule"></td>
		</tr>
		</cfif>

		<tr <cfif group_a.currentrow mod 2 and len(cost_cat_id)>class="form2AltRow"</cfif>>
			<td>
				<cfif not len(cost_cat_id)>
					<strong>#cost_cat_desc#</strong>
				<cfelse>
					#cost_cat_desc#
				</cfif>
			</td>
			<td align="right">#numberformat(amount_py_base,'$,')#</td>
			<td align="right">#numberformat(amount_py_inflated,'$,')#</td>
			<td align="right">#numberformat(amount_py_proposed,'$,')#</td>
			<td align="right">#numberformat(amount_dol_adjusted,'$,')#</td>
			<td align="right">#numberformat(amount_final,'$,')#</td>
		</tr>
		</cfoutput>
		<tr>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<cfoutput query="group_b">
		<tr class="form2AltRow">
			<td>
				#cost_cat_desc#
			</td>
			<td align="right">
				#numberformat(amount_py_base,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_inflated,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_proposed,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_dol_adjusted,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_final,'$,')#
			</td>
		</tr>
		</cfoutput>
		<tr>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<cfoutput query="group_c1">
		<tr class="form2AltRow">
			<td>
				#cost_cat_desc#
			</td>
			<td align="right">
				#numberformat(amount_py_base,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_inflated,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_proposed,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_dol_adjusted,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_final,'$,')#
			</td>
		</tr>
		</cfoutput>
		<tr>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<cfoutput query="group_c2">
		<tr class="form2AltRow">
			<td>
				#cost_cat_desc#
			</td>
			<td align="right">
				#numberformat(amount_py_base,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_inflated,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_proposed,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_dol_adjusted,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_final,'$,')#
			</td>
		</tr>
		</cfoutput>
		<tr>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<cfoutput query="group_s">
		<tr class="form2AltRow">
			<td>
				#cost_cat_desc#
			</td>
			<td align="right">
				#numberformat(amount_py_base,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_inflated,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_py_proposed,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_dol_adjusted,'$,')#
			</td>
			<td align="right">
				#numberformat(amount_final,'$,')#
			</td>
		</tr>
		</cfoutput>
		</table>

		<!--- display comments and status --->
		<cfoutput>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form1DataTbl" summary="display report comments and status">
		<tr>
			<td colspan="2" class="hrule" height="10"></td>
		</tr>
		<tr valign="top">
			<td width="10%"><strong>Comments:</strong></td>
			<td>#REreplace(rst.rs3.ccc_comment, chr(13), '<BR>', 'all')#</td>
		</tr>
		<tr>
			<td colspan="2" class="hrule"></td>
		</tr>
		<tr>
			<td><strong>Status:</strong></td>
			<td>
				<cfloop query="rst.rs3">
					<cfif checked eq 1>#worksheet_status_desc#</cfif>
				</cfloop>
			</td>
		</tr>
		</table>
		</cfoutput>

		</div>

		<!--- display footer --->
		<cfoutput>
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
		</cfoutput>
	</BODY>
	</cfdocument>


</cfif> <!--- is aapp coming from form.cboAAPP, or url? --->
