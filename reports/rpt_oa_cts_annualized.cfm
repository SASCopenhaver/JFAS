<cfsilent>
<!---
page: rpt_oa_cts_annualized.cfm
description: display summary report for Job Core OA/CTS Annualized Workload/Cost Under current contacts based on funding office (unit).
Revision:
2007-07-23	mstein	Removed word "Region" from total line (already included in database field)
2007-11-09	mstein	Fixed defect in National Total line (defect 295)
2008-06-25	mstein	Added CFDOCUMENTSECTION, and broke out content to cfinclude to deal with page breaks and conent being cut off (CF bug)

--->
</cfsilent>

<cfset arrvs_na_total = 0>
<cfset oa_funds_na_total = 0>
<cfset grads_na_total = 0>
<cfset cts_funds_na_total = 0>
<cfset fes_na_total = 0>
<cfset cnt = 0>

<cfif form.cboFundingOffice neq 0>
	<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#form.cboFundingOffice#" returnvariable="rsFundingOffice">
<cfelse>
	<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeType="DOL" returnvariable="rsFundingOffice">
</cfif>

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
<cfoutput>
<cfloop query="rsFundingOffice">
	<cfset new_fundingoffice = fundingOfficeNum>
	<cfset cnt = cnt + 1>

	<cfinvoke component="#application.paths.components#reports" method="getRptOa_cts_annualized_cost" fundingOfficeNum="#new_fundingoffice#" date_asof="#form.txtStartDate#" returnvariable="rs_oa_cts_annualized_cost" />

	<!--- initialize for each loop --->
	<cfset arrvs_total = 0>
	<cfset oa_funds_total = 0>
	<cfset grads_total = 0>
	<cfset cts_funds_total = 0>
	<cfset fes_total = 0>


		<!--- break page --->
		<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf" and currentRow gt 1 and new_fundingoffice neq old_fundingoffice>
			<cfdocumentitem type="pagebreak" />
		<cfelse>
			<br><br>
		</cfif>

		<!---
		yes, one more include file for this report.
		the use of the extra include, AND cfdocumentsection tags AND repeated inclusion
		of style sheet is a workaround due to a bug in CFDOCUMENT that causes page
		content to be cut off when using the <cfdocumentitem  type="pagebreak" />
		item for page breaks --->
		<cfif form.radReportFormat eq "application/pdf">
			<cfdocumentsection>
			<link href="#request.paths.reportcss#" rel="stylesheet" type="text/css" />
			<cfinclude template="rpt_oa_cts_annualized_content.cfm">
			</cfdocumentsection>
		<cfelse>
			<cfinclude template="rpt_oa_cts_annualized_content.cfm">
		</cfif>

		<!---<!-- Begin Content Area -->
		<h1>OA/CTS Annualized Workload/Cost Under Current Contracts as of #form.txtStartDate#</h1>
		<br>

		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr><td>
				Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
				</td>
			</tr>
		</table>

		<table width="742" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
			<tr>
				<th valign=top scope="col" title="Unit & AAPP No." colspan="2">Unit &<br>AAPP No.</th>
				<th valign=top scope="col" title="Program/Activity">Program Activity</th>
				<th valign=top scope="col" title="Contractor & Contract No.">Contractor/<br>Contract No.</th>
				<th valign=top scope="col" title="Current Contract Year">Current Contract Year</th>
				<th valign=top scope="col" title="Annualized Q/A Workload." colspan="2">Annualized O/A Workload/$s</th>
				<th valign=top scope="col" title="Annualized CTS Workload" colspan="4">Annualized <br>CTS Workload/$s</th>
			</tr>
			<cfloop query="rs_oa_cts_annualized_cost">
			<tr <cfif currentrow mod 2>class="form2AltRow"</cfif>>
				<td valign=top>#FUNDING_OFFICE_NUM#</td>
				<td valign=top>#AAPP_NUM#</td>
				<td valign=top>#programActivity#</td>
				<td valign=top>#CONTRACTOR_NAME#<br>#CONTRACT_NUM#</td>
				<td valign=top>
				<cfif DATE_START neq "" and minYearEndDate neq "">
					<cfif dateCompare(DATE_START, minYearEndDate) gt 0 >
						#dateFormat(DATE_START, 'mm/dd/yyyy')#
					<cfelse>
						#dateFormat(minYearEndDate, 'mm/dd/yyyy')#
					</cfif><br>#dateFormat(endDate, 'mm/dd/yyyy')#
				</cfif>&nbsp;
				</td>
				<td valign=top align=right>Arrvs:<br>Funds:	</td>
				<td valign=top align=right>#numberFormat(arrvs)#<br>#numberFormat(oa_funds)#</td>
				<td valign=top>Grads:<br>Funds:</td>
				<td valign=top align=right>#numberFormat(grads)#<br>#numberFormat(cts_funds)#</td>
				<td valign=top>FES:</td>
				<td valign=top align=right>#numberFormat(fes)#</td>
			</tr>
			<cfset arrvs_total = arrvs_total + arrvs>
			<cfset oa_funds_total = oa_funds_total + oa_funds>
			<cfset grads_total = grads_total + grads>
			<cfset cts_funds_total = cts_funds_total + cts_funds>
			<cfset fes_total = fes_total + fes>

			</cfloop><!--- end of loop for  rs_oa_cts_annualized_cost--->

			<!--- display region total --->
			<tr>
				<td valign=top colspan="5">
					<strong>#rsFundingOffice.fundingOfficeDesc# Total</strong>
				</td>
				<td valign=top align=right><strong>Arrvs:<br>Funds:</strong>	</td>
				<td valign=top align=right><strong>#numberFormat(arrvs_total)#<br>#numberFormat(oa_funds_total)#</strong></td>
				<td valign=top><strong>Grads:<br>Funds:</strong></td>
				<td valign=top align=right><strong>#numberFormat(grads_total)#<br>#numberFormat(cts_funds_total)#</strong></td>
				<td valign=top><strong>FES:</strong></td>
				<td valign=top align=right><strong>#numberFormat(fes_total)#</strong></td>
			</tr>

			<cfset arrvs_na_total = arrvs_na_total + arrvs_total>
			<cfset oa_funds_na_total = oa_funds_na_total + oa_funds_total>
			<cfset grads_na_total = grads_na_total + grads_total>
			<cfset cts_funds_na_total = cts_funds_na_total + cts_funds_total>
			<cfset fes_na_total = fes_na_total + fes_total>

			<!--- display national total --->
			<cfif cnt eq 6>

				<tr>
					<td valign=top colspan="5">
						<strong>National Total</strong>
					</td>
					<td valign=top align=right><strong>Arrvs:<br>Funds:</strong></td>
					<td valign=top align=right><strong>#numberFormat(arrvs_na_total)#<br>#numberFormat(oa_funds_na_total)#</strong></td>
					<td valign=top><strong>Grads:<br>Funds:</strong></td>
					<td valign=top align=right><strong>#numberFormat(grads_na_total)#<br>#numberFormat(cts_funds_na_total)#</strong></td>
					<td valign=top><strong>FES:</strong></td>
					<td valign=top align=right><strong>#numberFormat(fes_na_total)#</strong></td>
				</tr>
			</cfif>
		</table>

		<!-- End Content Area -->--->

		<cfset old_fundingoffice = new_fundingoffice>
</cfloop><!--- end of loop funding offices --->

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
</body>
</html>
