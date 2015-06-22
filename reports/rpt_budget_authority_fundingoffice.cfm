<cfsilent>
<!---
page: rpt_budget_authority_fundingoffice.cfm

description: display summary report for Budget Authority Requirements based on funding office.
abai 11/26/2007: 	Revised for CHG4400 (using numberFormat instead of dollarFormat)
--->
</cfsilent>

<cfset OPS_cumu_Total = 0>
<cfset CRA_cumu_Total = 0>

<cfif form.cboFundingOffice neq 0>
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#form.cboFundingOffice#" returnvariable="rsFundingOffice">
</cfif>
<cfset rsCurrentPY = application.outility.getCurrentSystemProgramYear (	)>

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
			<h1>Budget Authority Requirements <cfif form.cboFundingOffice neq 0> for #rsFundingOffice.fundingOfficeDesc#</cfif></h1>
			<h2>Program Year #rsCurrentPY# </h2>

			<br>

			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr><td>
				Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
				</td>
			</tr>
			</table>

			<table width="742" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
				<tr>
					<th width=10% valign=top scope="col" title="Unit">Unit</th>
					<th width=25% colspan=2 valign=top scope="col" style="text-align:center" title="Operations Funds">Operations Funds</th>
					<th width=25% colspan=2 valign=top scope="col" style="text-align:center" title="CRA Funds">CRA Funds</th>
					<th width=5%>&nbsp;</th>
					<th valign=top scope="col" title="Last FOPx No.">Last&nbsp;&nbsp;FOP&nbsp;&nbsp;No.</th>
				</tr>
				<cfif rsBudgetAuthFundsOffice.recordcount gt 0>
					<cfloop query="rsBudgetAuthFundsOffice">
					<tr <cfif currentrow mod 2>class="form2AltRow"</cfif>>
						<td valign=top scope="row">#FUNDING_OFFICE_NUM#</td>
						<td valign=top align="right">#numberFormat(OPS_funds, "$,.99")#</td>
						<td width=5%>&nbsp;</td>
						<td valign=top align="right">#numberFormat(CRA_funds, "$,.99")#</td>
						<td width=5%>&nbsp;</td>
						<td width=5%>&nbsp;</td>
						<td valign=top>#py#&nbsp;&nbsp;#FUNDING_OFFICE_NUM#&nbsp;&nbsp;#max_fop_num#</td>
					</tr>
					<cfif OPS_funds neq "">
					<cfset OPS_cumu_Total = OPS_cumu_Total + OPS_funds>
					</cfif>
					<cfif CRA_funds neq "">
					<cfset CRA_cumu_Total = CRA_cumu_Total + CRA_funds>
					</cfif>
					</cfloop>

					<!--- show up only if the user is not region person --->
					<cfif session.roleid neq 3>
						<tr>
							<td valign=top><strong>Total</strong></td>
							<td valign=top align="right"><strong>#numberFormat(OPS_cumu_Total, "$,.99")#</strong></td>
							<td width=5%>&nbsp;</td>
							<td valign=top align="right"><strong>#numberFormat(CRA_cumu_Total, "$,.99")#</strong></td>
							<td width=5%>&nbsp;</td>
							<td valign=top colspan="2">&nbsp;</td>
						</tr>
					</cfif>
				<cfelse>
					<tr><td colspan=10 align=center><br><br>There are no matching records</td></tr>
				</cfif>
			</table>


			</cfoutput>
		</div>
	    <!-- Begin Form Footer Info -->

	    <cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
			<cfdocumentitem type="footer">
				<cfoutput>
				<table width=100% cellspacing="0" border=0 cellpadding="0">
				<tr>
					<td align=right>
						<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
							page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
						</font>
					</td>
				</tr>
				</table>
				</cfoutput>
			</cfdocumentitem>
		</cfif>


		<!-- End Content Area -->
</td>
</tr>
</table>
</body>
</html>
