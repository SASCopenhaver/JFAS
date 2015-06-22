<cfsilent>
<!---
page:

description:

revisions:
2007-10-17	mstein	fixed missing parenthesis, and missing dollar signs
abai 11/26/2007: 	Revised for CHG4400 (using numberformat() instead of dollarformat())
--->
</cfsilent>

<cfif form.cboFundingOffice neq 0>
	<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#form.cboFundingOffice#" returnvariable="rsFundingOffice">
<cfelse>
	<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeType="FED" returnvariable="rsFundingOffice">
</cfif>
<cfset rsCurrentPY = application.outility.getCurrentSystemProgramYear_CCC (	)>
<cfset rsCurrentQuarterNum = application.outility.GetCurrentQuarterNum ( quarter_type="P" )>

<cfset ops_total = 0>
<cfset ops_percent = 0>
<cfset cra_total = 0>
<cfset cra_percent = 0>
<cfset py = rsCurrentPY>
<cfset current_py = 0>
<cfset old_fundingoffice = "">
<cfset new_fundingoffice = "">

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

<cfoutput>

	<cfloop query="rsFundingOffice">
		<cfset new_fundingoffice = fundingOfficeNum>
		<cfinvoke component="#application.paths.components#reports" method="getRptCCCBaTransfer" fundingOfficeNum="#new_fundingoffice#" returnvariable="rsCCCBaTransfer" />

		<!-- Begin Content Area -->
		<!-- Begin Form Header Info -->
		<div class="formContent">

			<!--- initial it for each loop time --->
			<cfset ops_total = 0>
			<cfset ops_percent = 0>
			<cfset cra_total = 0>
			<cfset cra_percent = 0>
			<cfset cnt = 1>

			<!--- break page --->
			<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf" and currentRow gt 1 and new_fundingoffice neq old_fundingoffice>
				<cfdocumentitem type="pagebreak" />
			<cfelse>
				<br><br>
			</cfif>

			<h1>CCC Budget Transfer Requirements - Program Year #rsCurrentPY#</h1>
			<h2>Report Printed #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#</h2>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr valign="top">
				<td width="52%" align="right">Funding Office: for #rsFundingOffice.fundingOfficeDesc#</td>
				<td width="5%">
				<td width="43%">Quarter: #rsCurrentQuarterNum#</td>
			</tr>
			</table>
			<!-- End Form Header Info -->

			<table border="0" valign=top cellpadding="0" cellspacing="0" class="form1DataTbl">
			<tr>
				<th colspan="3" scope="col" title="Cost Category">Cost Category </th>
				<th scope="col" style="text-align:center" title="Annual Budget"><strong>Annual Budget</strong></th>
				<th scope="col" style="text-align:center" title="BA Transfer Requirement"><strong>BA Transfer Requirement</strong></th>
				<th></th>
			</tr>

			<tr>
				<td>I.</td>
				<td colspan="5">Operational Funds (Non-Cnst/Rehab)</td>
			</tr>

			<cfloop query=rsCCCBaTransfer.rsCCCBA_OPS_1>
			<tr <cfif currentRow mod 2>class="form2AltRow"</cfif>>
				<td width="5%"></td>
				<td width="3%">#COST_CAT_CODE#.</td>
				<td width="*">#COST_CAT_DESC#</td>
				<td width="15%" align="right">#numberFormat(a_mount, "$,.99")#</td>
				<td width="15%" align="right">#numberFormat(a_mount*TRANSFER_PERCENT, "$,.99")#</td>
				<td width="5%"></td>
			</tr>
			<cfset ops_total = ops_total + a_mount>
			<cfset ops_percent = ops_percent + a_mount*TRANSFER_PERCENT>
			</cfloop>
			<tr><td colspan="6" class="hrule"></td></tr>
			<tr>
				<td></td>
				<td colspan="2"><strong>Total Operational Funding</strong></td>
				<td align="right"><strong>#numberformat(ops_total, "$,.99")#</strong></td>
				<td align="right"><strong>#numberFOrmat(ops_percent, "$,.99")#</strong></td>
				<td></td>
			</tr>
			<tr><td colspan="6">&nbsp;</td></tr>

			<tr>
				<td>II.</td>
				<td colspan="5">Cnst/Facility Rehab Funds (B1)</td>
			</tr>
			<cfloop query="rsCCCBaTransfer.rsCCCBA_CRA_1">
				<cfif cnt eq 1>
					<cfset current_py = PY - 2>
				<cfelseif cnt eq 2>
					<cfset current_py = PY  - 1>
				<cfelse>
					<cfset current_py = PY>
				</cfif>

			<tr <cfif currentRow mod 2>class="form2AltRow"</cfif>>
				<td></td>
				<td colspan="2">PY #current_py# Appropriation (<cfif evaluate(right(current_py, 1)+1) gt 9>0<cfelse>#right(current_py, 1)+1#</cfif>/<cfif evaluate(right(current_py, 1)+3) gte 10>#right(evaluate(right(current_py, 1)+3),1)#)<cfelse>#right(current_py, 1)+3#)</cfif></td>
				<td align="right">#numberFormat(a_mount, "$,.99")#</td>
				<td align="right">#numberformat(a_mount*TRANSFER_PERCENT, "$,.99")#</td>
				<td></td>
			</tr>
				<cfset cnt = cnt + 1>
				<cfset cra_total = cra_total + a_mount>
				<cfset cra_percent = cra_percent + a_mount*TRANSFER_PERCENT>
			</cfloop>

			<tr><td colspan="6" class="hrule"></td></tr>
			<tr>
				<td></td>
				<td colspan="2"><strong>Total Cnst/Rehab Funding</strong></td>
				<td align="right"><strong>#numberFormat(cra_total, "$,.99")#</strong></td>
				<td align="right"><strong>#numberFormat(cra_percent,"$,.99")#</strong></td>
				<td></td>
			</tr>
			</table>

		</div>
		<!-- End Content Area -->
		<cfset old_fundingoffice = new_fundingoffice>
	</cfloop>

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
</body>
</html>

