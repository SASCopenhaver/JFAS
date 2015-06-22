
<cfif form.cboFundingOffice neq 0>
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#form.cboFundingOffice#" returnvariable="rsFundingOffice">
</cfif>

<cfset a_percent = 0>
<cfset b2_percent = 0>
<cfset b3_percent = 0>
<cfset b4_percent = 0>
<cfset c1_percent = 0>
<cfset c2_percent = 0>
<cfset d_percent = 0>
<cfset s_percent = 0>
<cfset new_code = "">
<cfset old_code = "">
<cfset line_break = "false">

<cfloop query="rsPY_ccc_worksheet.rsCCC_Percent">
	<cfif COST_CAT_ID eq 1>
		<cfset a_percent = TRANSFER_PERCENT>
	<cfelseif COST_CAT_ID eq 3>
		<cfset b2_percent = TRANSFER_PERCENT>
	<cfelseif COST_CAT_ID eq 4>
		<cfset b3_percent = TRANSFER_PERCENT>
	<cfelseif COST_CAT_ID eq 5>
		<cfset b4_percent = TRANSFER_PERCENT>
	<cfelseif COST_CAT_ID eq 6>
		<cfset c1_percent = TRANSFER_PERCENT>
	<cfelseif COST_CAT_ID eq 7>
		<cfset c2_percent = TRANSFER_PERCENT>
	<cfelseif COST_CAT_ID eq 8>
		<cfset d_percent = TRANSFER_PERCENT>
	<cfelseif COST_CAT_ID eq 9>
		<cfset s_percent = TRANSFER_PERCENT>
	</cfif>
</cfloop>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<title>#request.htmlTitleDetail#</title>
<cfif not isDefined("url.aapp")>
<link href="#request.paths.reportcss#" rel="stylesheet" type="text/css" />
</cfif>
</cfoutput>
</head>

<body class="form">
<table width="742" border="1" cellpadding="0" cellspacing="0" class="formHdrInfo">
<cfoutput>
<tr valign="bottom">
	<td colspan="2">PY #form.cboPY# CCC Budget Worksheet for:</td>
	<td colspan="2">#rsFundingOffice.fundingOfficeDesc#</td>
	<td>#dateFormat(now(), 'mm/dd/yyyy')#</td>
</tr>
</table>

<p></p>
<table width="780" border="1" cellpadding="0" cellspacing="0" class="form1DataTbl">
<tr>
	<td width=300 valign=top><strong>Cost Category</strong></td>
	<td align="center" width=120><strong>Requested By<br> Agency</strong></td>
	<td align="center" width=120><strong>&nbsp;&nbsp;Dept Labor&nbsp;&nbsp;<br> Adjustment</td>
	<td align="center" width=120><strong>Initial Amount<br>Approved</strong></td>
	<td align="center" width=120><strong>&nbsp;Anticipated&nbsp;<br>First Qtr<br>Transfer</strong></td>
</tr>
</cfoutput>

<cfif rsPY_ccc_worksheet.rsCCC_py_worksheet.recordcount gt 0>
	<cfoutput query="rsPY_ccc_worksheet.rsCCC_py_worksheet">
	<cfset new_code = cost_cat_code>
	<cfif currentRow gt 1 and find("C", new_code) gt 0 and find("B", old_code) gt 0>
		<cfset line_break = "true">
	</cfif>

	<cfif  line_break>
		<tr>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<cfset line_break = "false">
	</cfif>
	<tr <cfif currentrow mod 2 and len(cost_cat_id)>class="form2AltRow"</cfif>>
		<td nowrap>
			<cfif not len(cost_cat_id)>
				<strong>#cost_cat_desc#</strong>
			<cfelse>
				#cost_cat_desc#
			</cfif>
		</td>
		<td align="right">
			<cfif  not len(cost_cat_id)>
				<strong>#numberformat(proposed)#</strong>
			<cfelse>
				#numberformat(proposed)#
			</cfif>
		</td>
		<td align="right">
			<cfif  not len(cost_cat_id)>
				<strong>#numberformat(dol_adjusted)#</strong>
			<cfelse>
				#numberformat(dol_adjusted)#
			</cfif>
		</td>
		<td align="right">
			<cfif  not len(cost_cat_id)>
				<strong>#numberformat(amount_final)#</strong>
			<cfelse>
				#numberformat(amount_final)#
			</cfif>
		</td>
		<td align="right">&nbsp;
			<cfif cost_cat_code eq "A" and not len(cost_cat_id)>
				<cfif not len(cost_cat_id)>
					<strong>#numberFOrmat(round(amount_final*a_percent))#</strong>
				<cfelse>
					#numberFOrmat(round(amount_final*a_percent))#
				</cfif>
			<cfelseif cost_cat_code eq "B2">
				<cfif not len(cost_cat_id)>
					<strong>#numberFOrmat(round(amount_final*b2_percent))#</strong>
				<cfelse>
					#numberFOrmat(round(amount_final*b2_percent))#
				</cfif>
			<cfelseif cost_cat_code eq "B3">
				<cfif not len(cost_cat_id)>
					<strong>#numberFOrmat(round(amount_final*b3_percent))#</strong>
				<cfelse>
					#numberFOrmat(round(amount_final*b3_percent))#
				</cfif>
			<cfelseif cost_cat_code eq "B4">
				<cfif not len(cost_cat_id)>
					<strong>#numberFOrmat(round(amount_final*b4_percent))#</strong>
				<cfelse>
					#numberFOrmat(round(amount_final*b4_percent))#
				</cfif>
			<cfelseif cost_cat_code eq "C1">
				<cfif not len(cost_cat_id)>
					<strong>#numberFOrmat(round(amount_final*c1_percent))#</strong>
				<cfelse>
					#numberFOrmat(round(amount_final*c1_percent))#
				</cfif>
			<cfelseif cost_cat_code eq "C2">
				<cfif not len(cost_cat_id)>
					<strong>#numberFOrmat(round(amount_final*c2_percent))#</strong>
				<cfelse>
					#numberFOrmat(round(amount_final*c2_percent))#
				</cfif>
			<cfelseif cost_cat_code eq "D">
				<cfif not len(cost_cat_id)>
					<strong>#numberFOrmat(round(amount_final*d_percent))#</strong>
				<cfelse>
					#numberFOrmat(round(amount_final*d_percent))#
				</cfif>
			<cfelseif cost_cat_code eq "S">
				<cfif not len(cost_cat_id)>
					<strong>#numberFOrmat(round(amount_final*s_percent))#</strong>
				<cfelse>
					#numberFOrmat(round(amount_final*s_percent))#
				</cfif>
			</cfif>
		</td>
	</tr>

	<cfif  not len(cost_cat_id)>
		<tr>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td align="right">&nbsp;</td>
		</tr>
		<cfset line_break = "false">
	</cfif>
	<cfset old_code = new_code>
	</cfoutput>

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
	</cfoutput>
<cfelse>
	<tr><td colspan="4">There is no data match your criteria</td></tr>
</cfif>
</table>
</body>
</html>

