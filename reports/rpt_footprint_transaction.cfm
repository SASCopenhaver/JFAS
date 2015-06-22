<cfsilent>
<!---
page: rpt_footprint_transaction.cfm

description: display summary report for footprint transaction info.

NOTE: Not sure why this page has two sections that are almost identical. Will have to be addressed
in the future (mstein 01/07/2010)

Revisions:
abai 10/16/2007  Revised for displaying header if there is no matching record returned.
abai 11/27/2007  Revised for CHG4400 (using numberformat instead of dollarFormat).
abai 12/11/2007  Revised for using small size font to fit some records (such as 3371).
--->
</cfsilent>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<title>#request.htmlTitleDetail#</title>
<link href="#application.paths.cssdir#jfas_report_trans.css" rel="stylesheet" type="text/css" />
</cfoutput>
</head>

<cfif isDefined("url.aapp") and isDefined("url.trans")>
	<cfset form.hidReportType = url.trans>
	<cfset form.aapp = url.aapp>
	<cfset form.radReportFormat = "application/pdf">
</cfif>

<cfif isDefined("form.hidReportType")>
	<cfif form.hidReportType eq "P">
		<cfset typeDesc = "Payments">
	<cfelseif form.hidReportType eq "O">
		<cfset typeDesc = "Obligations">
	<cfelse>
		<cfset typeDesc = "Costs">
	</cfif>
<cfelse>
	<cfset typeDesc = "">
</cfif>

<cfinvoke component="#application.paths.components#reports" method="getRptTransaction_dolars" formdata="#form#" returnvariable="rsTransaction" />
<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#form.AAPP#" returnvariable="rstGetAAPPGeneral" />

<cfset old_date = "">
<cfset new_date = "">
<CFSET ops_total = 0>
<CFSET cra_total = 0>
<CFSET ops_cum_total = 0>
<CFSET cra_cum_total = 0>
<cfset ops_cra_total = 0>
<cfset cnt=0>
<cfset change_color = "false">


<!-- Begin Content Area -->
<!-- Begin Form Header Info -->
<cfif isDefined("url.aapp") and isDefined("url.trans")>
	<!--- this code is used when called from the Reports tab under a specific AAPP --->
		<body class="form">
		<cfoutput>
		<link href="#application.paths.cssdir#jfas_report_trans.css" rel="stylesheet" type="text/css" />
		<div class="formContent">

	    <h1>
		#typeDesc# Cumulative List
		&nbsp;&nbsp;<span style="font-weight:normal;">(source: DOLAR$)</span>
		</h1>  <cfif isDefined("form.txtStartDate") and form.txtStartDate neq "" and isDefined("form.txtEndDate") and form.txtEndDate neq "">
					<h2>for transactions #form.txtStartDate# through #form.txtEndDate# </h2>
				<cfelseif isDefined("form.txtStartDate") and form.txtStartDate neq "">
					<h2>for transactions from #form.txtStartDate# </h2>
				<cfelseif isDefined("form.txtEndDate") and form.txtEndDate neq "">
					<h2>for transactions to #form.txtEndDate# </h2>
				</cfif>
		<br>
		<!--- display sub title data --->
		<table width="742" border="0" align="center" vliagn=top cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr><td width="12%" scope="row" title="AAPP No"><strong>AAPP No.:</strong></td>
				<td width="20%">#rstGetAAPPGeneral.aappNum#</td>
				<td width="25%" valign="top" scope="row" title="Program Activity"><strong>Program Activity:</strong></td>
				<td valign="top">#rstGetAAPPGeneral.programactivity#</td>
			</tr>
			<tr><td valign="top" scope="row" title="Contractor"><strong>Contractor:</strong></td>
				<td valign="top"> #rstGetAAPPGeneral.contractorname#</td>
				<td valign="top" scope="row" title="Performance Venue/Center"><strong>Performance Venue/Center:</strong></td>
				<td valign="top">#rstGetAAPPGeneral.venue# <cfif rstGetAAPPGeneral.venue neq '' and rstGetAAPPGeneral.centername neq "">/&nbsp;</cfif>#rstGetAAPPGeneral.centername#
				</td>
			</tr>
			<tr><td valign="top" scope="row" title="Contract No"><strong>Contract No.:</strong></td>
				<td valign="top">#rstGetAAPPGeneral.contractNum#</td>
				<td valign="top" scope="row" title="Performance Period"><strong>Performance Period:</strong></td>
				<td valign="top"><cfif rstGetAAPPGeneral.datestart neq "">#Dateformat(rstGetAAPPGeneral.datestart, "mm/dd/yyyy")#</cfif> <cfif rstGetAAPPGeneral.dateend neq "">to #dateFormat(rstGetAAPPGeneral.dateend, "mm/dd/yyyy")#</cfif>
				</td>
			</tr>
			<tr><td colspan="4" valign="top" align=right><br />Report run on: #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#</td></tr>
		</table>

		<!--- display data --->

		<table valig=top width="742" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
			<tr><th colspan="<cfif form.hidReportType eq "O">4<cfelse>5</cfif>"></th>
				<th colspan="2" style="text-align:center">#typeDesc#</th>
				<th colspan="3" style="text-align:center">Cumulative to Date</th>
			</tr>
			<tr>
				<th valign=top scope="col" title="Date">Date</th>
				<th valign=top scope="col" style="text-align:center" title="Footprint" width=250>Footprint</th>
				<th valign=top scope="col" style="text-align:center" title="Transaction Code">TC</th>
				<th valign=top scope="col" style="text-align:center" title="Vendor ID">Vendor ID</th>
				<cfif form.hidReportType neq "O">
				<th valign=top scope="col" style="text-align:center" title="Invoice No." width="20">Invoice No.</th>
				</cfif>
				<th valign=top scope="col" style="text-align:center" title="Opreation">Operations</th>
				<th valign=top scope="col" style="text-align:center" title="CRA CNST" nowrap>CRA-CNST</th>
				<th valign=top scope="col" style="text-align:center" title="Oprations">Operations</th>
				<th valign=top scope="col" style="text-align:center" title="CRA CNST" nowrap>CRA-CNST</th>
				<th valign=top scope="col" style="text-align:center" title="Obligation">Total</th>
			</tr>

			<cfif rstransaction.recordcount gt 0>
			 <cfloop query="rstransaction">
				<cfset new_date = dateFormat(trans_date, "mm/dd/yyyy")>

				<cfif new_date neq old_date or rstransaction.recordcount eq 1>
					<cfset cnt = 1 >
				<cfelse>
					<cfset cnt = cnt + 1>
				</cfif>

				<cfif old_date neq "" and new_date neq old_date and currentrow neq 1 >
					<tr <cfif change_color>
							class="form2AltRow"
					</cfif> >
							<td colspan="3"></td>
							<td colspan="<cfif form.hidReportType eq "O">1<cfelse>2</cfif>" nowrap>subtotal for #dateFormat(old_date, 'mm/dd/yyyy')#<!---  -- cnt: #cnt#-- change_color: #change_color# ---></td>
							<td valign=top align="right" style="border-left:1px solid ##5e84a6;"><strong>#numberFormat(ops_total, "$,")#</strong></td>
							<td valign=top align="right" style="border-right:1px solid ##5e84a6;"><strong>#numberFormat(cra_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(ops_cum_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(CRA_cum_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(ops_cra_total, "$,")#</strong></td>
					</tr>
					<cfset cra_total = 0>
					<cfset ops_total = 0>
					<cfif change_color >
						<cfset change_color = "false">
					<cfelse>
						<cfset change_color = "true">
					</cfif>
				</cfif>
				<cfif ops_cra eq "ops">
					<cfset ops_total = ops_total + AMOUNT>
					<cfset ops_cum_total = ops_cum_total + AMOUNT>
				<cfelse>
					<cfset cra_total = cra_total + AMOUNT>
					<cfset cra_cum_total = cra_cum_total + AMOUNT>
				</cfif>
				<cfset ops_cra_total = ops_cum_total + cra_cum_total>

				<tr <cfif change_color>
							class="form2AltRow"
					</cfif> >
					<td valign=top scope="row"><cfif cnt eq 1>#dateFormat(trans_date, 'mm/dd/yyyy')#</cfif><!--- --cnt: #cnt#-- change_color: #change_color# ---></td>
					<td valign=top>#footp#</td>
					<td valign=top>#XACTN_code#</td>
					<td valign=top>#EIN#</td>
					<cfif isDefined("form.hidReportType") and form.hidReportType neq "O">
					<td valign=top style="mso-number-format:\@">#INVOICE_NUM#</td>
					</cfif>
					<td valign=top style="border-left:1px solid ##5e84a6;" align="right" nowrap><cfif ops_cra eq "ops">#numberFormat(amount, "$,")#<cfelse>0</cfif></td>
					<td valign=top style="border-right:1px solid ##5e84a6;" align="right" nowrap><cfif ops_cra eq "cra">#numberformat(amount, "$,")#<cfelse>0</cfif></td>
					<td nowrap></td>
					<td nowrap></td>
					<td nowrap></td>
				</tr>

				<cfif currentRow eq rstransaction.recordcount>
					<tr <cfif change_color>
							class="form2AltRow"
					</cfif> >
							<td colspan="3"></td>
							<td colspan="<cfif form.hidReportType eq 'O'>1<cfelse>2</cfif>" nowrap>subtotal for #dateFormat(trans_date, 'mm/dd/yyyy')#</td>
							<td valign=top align="right" style="border-left:1px solid ##5e84a6;"><strong>#numberFormat(ops_total, "$,")#</strong></td>
							<td valign=top align="right" style="border-right:1px solid ##5e84a6;"><strong>#numberFormat(cra_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(ops_cum_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(CRA_cum_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(ops_cra_total, "$,")#</strong></td>
					</tr>
				</cfif>

				<cfset old_date = new_date>
		    </cfloop>

		  <cfelse>

			<tr><td colspan=11 align=center>
				<br><br>There are no matching records
				</td>
			</tr>
		  </cfif><!--- end loop of title --->
		</table>

		<!--- Begin Form Footer Info  --->
		<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
			<cfdocumentitem type="footer">
			<table align=top width=100% cellspacing="0" border=0 cellpadding="0">
				<tr>
					<td align=right valign=top>
						<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
							page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
						</font>
					</td>
				</tr>
			</table>
			</cfdocumentitem>
		</cfif>
		<!-- End Content Area -->
	  </cfoutput>
	</div>

	 </body>
<cfelse>
	<!--- when report is called from JFAS reports menu --->
	<body class="form">
	<div class="formContent">
	<cfoutput>

	  <!--- display title --->
		<h1>
		#typeDesc# Cumulative List
		&nbsp;&nbsp;<span style="font-weight:normal;">(source: DOLAR$)</span>
		</h1>  <cfif isDefined("form.txtStartDate") and form.txtStartDate neq "" and isDefined("form.txtEndDate") and form.txtEndDate neq "">
					<h2>for transactions #form.txtStartDate# through #form.txtEndDate# </h2>
				<cfelseif isDefined("form.txtStartDate") and form.txtStartDate neq "">
					<h2>for transactions from #form.txtStartDate# </h2>
				<cfelseif isDefined("form.txtEndDate") and form.txtEndDate neq "">
					<h2>for transactions to #form.txtEndDate# </h2>
				</cfif>
		<br />
		<!--- display sub title data --->
		<table width="742" border="0" align="center" vliagn=top cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr><td width="12%" scope="row" title="AAPP No"><strong>AAPP No.:</strong></td>
				<td width="20%">#rstGetAAPPGeneral.aappNum#</td>
				<td width="25%" valign="top" scope="row" title="Program Activity"><strong>Program Activity:</strong></td>
				<td valign="top">#rstGetAAPPGeneral.programactivity#</td>
			</tr>
			<tr><td valign="top" scope="row" title="Contractor"><strong>Contractor:</strong></td>
				<td valign="top"> #rstGetAAPPGeneral.contractorname#</td>
				<td valign="top" scope="row" title="Performance Venue/Center"><strong>Performance Venue/Center:</strong></td>
				<td valign="top">#rstGetAAPPGeneral.venue# <cfif rstGetAAPPGeneral.venue neq '' and rstGetAAPPGeneral.centername neq "">/</cfif>#rstGetAAPPGeneral.centername#
				</td>
			</tr>
			<tr><td valign="top" scope="row" title="Contract No"><strong>Contract No.:</strong></td>
				<td valign="top">#rstGetAAPPGeneral.contractNum#</td>
				<td valign="top" scope="row" title="Performance Period"><strong>Performance Period:</strong></td>
				<td valign="top"><cfif rstGetAAPPGeneral.datestart neq "">#Dateformat(rstGetAAPPGeneral.datestart, "mm/dd/yyyy")#</cfif> <cfif rstGetAAPPGeneral.dateend neq "">to #dateFormat(rstGetAAPPGeneral.dateend, "mm/dd/yyyy")#</cfif>
				</td>
			</tr>
			<tr><td colspan="4" valign="top" align=right><br />Report run on: #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#</td></tr>
		</table>

		<!--- display data --->
 	    <table valig=top width="742" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
			<tr><th colspan="<cfif form.hidReportType eq "O">4<cfelse>5</cfif>"></th>
				<th colspan="2" style="text-align:center">#typeDesc#</th>
				<th colspan="3" style="text-align:center">Cumulative to Date</th>
			</tr>
			<tr>
				<th valign=top scope="col" title="Date">Date</th>
				<th valign=top scope="col" style="text-align:center" title="Footprint" width=250>Footprint</th>
				<th valign=top scope="col" style="text-align:center" title="Transaction Code">TC</th>
				<th valign=top scope="col" style="text-align:center" title="Vendor ID">Vendor ID</th>
				<cfif form.hidReportType neq "O">
				<th valign=top scope="col" style="text-align:center" title="Invoice No.">Invoice No.</th>
				</cfif>
				<th valign=top scope="col" style="text-align:center" title="Opreation">Operations</th>
				<th valign=top scope="col" style="text-align:center" title="CRA CNST" nowrap>CRA-CNST</th>
				<th valign=top scope="col" style="text-align:center" title="Oprations">Operations</th>
				<th valign=top scope="col" style="text-align:center" title="CRA CNST" nowrap>CRA-CNST</th>
				<th valign=top scope="col" style="text-align:center" title="Obligation">Total</th>
			</tr>
		 <cfif rstransaction.recordcount gt 0>
			 <cfloop query="rstransaction">
				<cfset new_date = dateFormat(trans_date, "mm/dd/yyyy")>

				<cfif new_date neq old_date or rstransaction.recordcount eq 1>
					<cfset cnt = 1 >
				<cfelse>
					<cfset cnt = cnt + 1>
				</cfif>

				<cfif old_date neq "" and new_date neq old_date and currentrow neq 1 >
					<tr <cfif change_color>
							class="form2AltRow"
					</cfif> >
							<td colspan="3"></td>
							<td colspan="<cfif form.hidReportType eq "O">1<cfelse>2</cfif>" nowrap>subtotal for #dateFormat(old_date, 'mm/dd/yyyy')#<!---  -- cnt: #cnt#-- change_color: #change_color# ---></td>
							<td valign=top align="right" style="border-left:1px solid ##5e84a6;"><strong>#numberFormat(ops_total, "$,")#</strong></td>
							<td valign=top align="right" style="border-right:1px solid ##5e84a6;"><strong>#numberFormat(cra_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(ops_cum_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(CRA_cum_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(ops_cra_total, "$,")#</strong></td>
					</tr>
					<cfset cra_total = 0>
					<cfset ops_total = 0>
					<cfif change_color >
						<cfset change_color = "false">
					<cfelse>
						<cfset change_color = "true">
					</cfif>
				</cfif>
				<cfif ops_cra eq "ops">
					<cfset ops_total = ops_total + AMOUNT>
					<cfset ops_cum_total = ops_cum_total + AMOUNT>
				<cfelse>
					<cfset cra_total = cra_total + AMOUNT>
					<cfset cra_cum_total = cra_cum_total + AMOUNT>
				</cfif>
				<cfset ops_cra_total = ops_cum_total + cra_cum_total>

				<tr <cfif change_color>
							class="form2AltRow"
					</cfif> >
					<td valign=top scope="row"><cfif cnt eq 1>#dateFormat(trans_date, 'mm/dd/yyyy')#</cfif><!--- --cnt: #cnt#-- change_color: #change_color# ---></td>
					<td valign=top>#footp#</td>
					<td valign=top>#XACTN_code#</td>
					<td valign=top>#EIN#</td>
					<cfif isDefined("form.hidReportType") and form.hidReportType neq "O">
					<td valign=top style="mso-number-format:\@">#INVOICE_NUM#</td>
					</cfif>
					<td valign=top style="border-left:1px solid ##5e84a6;" align="right" nowrap><cfif ops_cra eq "ops">#numberFormat(amount, "$,")#<cfelse>0</cfif></td>
					<td valign=top style="border-right:1px solid ##5e84a6;" align="right" nowrap><cfif ops_cra eq "cra">#numberformat(amount, "$,")#<cfelse>0</cfif></td>
					<td nowrap></td>
					<td nowrap></td>
					<td nowrap></td>
				</tr>

				<cfif currentRow eq rstransaction.recordcount>
					<tr <cfif change_color>
							class="form2AltRow"
					</cfif> >
							<td colspan="3"></td>
							<td colspan="<cfif form.hidReportType eq 'O'>1<cfelse>2</cfif>" nowrap>subtotal for #dateFormat(trans_date, 'mm/dd/yyyy')#</td>
							<td valign=top align="right" style="border-left:1px solid ##5e84a6;"><strong>#numberFormat(ops_total, "$,")#</strong></td>
							<td valign=top align="right" style="border-right:1px solid ##5e84a6;"><strong>#numberFormat(cra_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(ops_cum_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(CRA_cum_total, "$,")#</strong></td>
							<td valign=top align="right"><strong>#numberFormat(ops_cra_total, "$,")#</strong></td>
					</tr>
				</cfif>

				<cfset old_date = new_date>
		    </cfloop>
		 <cfelse>

			<tr><td colspan=11 align=center>
				<br><br>There are no matching records
				</td>
			</tr>
		  </cfif><!--- end loop of title --->
		</table>

		<!-- Begin Form Footer Info  --->
		<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
			<cfdocumentitem type="footer">
			<table align=top width=100% cellspacing="0" border=0 cellpadding="0">
				<tr>
					<td align=right valign=top>
						<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
							page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
						</font>
					</td>
				</tr>
			</table>
			</cfdocumentitem>
		</cfif>
		<!-- End Content Area -->
	  </cfoutput>
	</div>

	</body>
	</html>
</cfif>
