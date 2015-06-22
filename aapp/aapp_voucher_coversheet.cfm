<!---
page name: voucher_coversheet.cfm
Description:
Revision:

--->


<cfset request.pageID = "730" />
<cfsilent>

<cfoutput>

	<cfinvoke component="#application.paths.components#footprint" method="getOPSCRA" returnvariable="rstOPSCRA">
	<cfinvoke component="#application.paths.components#voucher" method="getVoucher" voucherID="#url.voucherID#" returnvariable="rstVoucher" >
	<cfinvoke component="#application.paths.components#voucher" method="getVoucherFootprint" voucherID="#url.voucherID#" returnvariable="rstFootprint">

	<cfset Variables.CRA_recordcount = 0>
	<cfset Variables.OPS_recordcount = 0>
	<cfset Variables.CRA_total = 0>
	<cfset Variables.OPS_total = 0>
	<cfset Variables.OPSCRA = rstFootprint.OPSCRA>
	<cfset Variables[rstFootprint.OPSCRA & '_recordcount'] = 0>

	<cfloop query="rstFootprint">
		<cfif Variables.OPSCRA neq rstFootprint.OPSCRA>
			<cfset Variables[rstFootprint.OPSCRA & '_recordcount'] = 0>
		</cfif>
		<cfset Variables[rstFootprint.OPSCRA & '_recordcount'] = Variables[rstFootprint.OPSCRA & '_recordcount'] + 1>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_FootprintID'] = rstFootprint.FootprintID>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_DocType'] = rstFootprint.DocType>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_DocNum'] = rstFootprint.DocNum>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_FY'] = rstFootprint.FY>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_RCCFund'] = rstFootprint.RccFund>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_RCCOrg'] = rstFootprint.RccOrg>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_Obcl'] = rstFootprint.obcl>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_Oblig'] = rstFootprint.Oblig>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_Ein'] = rstFootprint.Ein>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_Proj1'] = rstFootprint.Proj1>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_AmountCharged'] = rstFootprint.amountCharged>
		<cfset Variables[rstFootprint.OPSCRA & '_total'] =  Variables[rstFootprint.OPSCRA & '_total'] + rstFootprint.amountCharged>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_PY'] = rstFootprint.AppropPY>
		<cfset Variables[rstFootprint.OPSCRA & '_' & Variables[rstFootprint.OPSCRA & '_recordcount'] & '_REGADV'] = rstFootprint.REGADV>
		<cfset Variables.OPSCRA = rstFootprint.OPSCRA>
	</cfloop>
</cfoutput>

</cfsilent>


<cfdocument format="PDF" orientation="portrait">


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<title>#request.htmlTitleDetail#</title>
<link href="#application.paths.reportcss#" rel="stylesheet" type="text/css" />

</cfoutput>
</head>

<body class="form">
<table border="0" bordercolor="00FF00" cellspacing="0" cellpadding="0" align="center" width="762">
<tr>
	<td>
	<!-- Begin Content Area -->
		<!-- Begin Form Header Info -->
	<div class="form2Content">
		<cfoutput>
		<h3 style="font-size:36px">Job Corps Regional Office Voucher Transmittal for AAPP #url.aapp#</h3>
		<h4 style="font-size:30px">Region #request.fundingofficenum# - #request.fundingofficedesc#</h4>
		<br />
		<br />
		<br />
		<table width="70%" bordercolor="CC6666" border="0" cellpadding="0" cellspacing="0" class="formLDataTbl">
		<tr>
			<td width="15%" style="font-size:24px" nowrap="nowrap" >
				Vendor Name
			</td>
			<td width="15%" style="font-size:24px" nowrap="nowrap">
				#rstFootprint.vendor#
			</td>
		</tr>
		<tr>
			<td width="15%" style="font-size:24px">
				<cfif rstVoucher.voucherTypeCode is "C">Contract<cfelse>PO</cfif> Number
			</td>
			<td width="15%" style="font-size:24px">
				<cfif rstVoucher.voucherTypeCode is "C">#request.contractNum#<cfelse>#rstVoucher.VoucherNum##rstVoucher.Version#</cfif>
			</td>
		</tr>
		<cfif rstVoucher.voucherTypeCode eq "C">
		</tr>
			<td width="15%" style="font-size:24px">
				Voucher Number
			</td>
			<td width="15%" style="font-size:24px">
				#rstVoucher.VoucherNum##rstVoucher.Version#
		</tr>
		</cfif>

		</table>

				<br /><br />
			<cfloop query="rstOPSCRA">
				<cfif Variables[rstOPSCRA.OPSCRA & '_recordcount'] gt 0>
				<br /><br />
					<h4 style="text-align:left; font-size:32px">#rstOPSCRA.OPSCRA# Footprints</h4>
					<table width="100%" border="0" cellspacing="0" cellpadding="0" class="formLDataTbl">
						<tr>
						<th style="font-size:24px">
							<br />FY
						</th>
						<th style="font-size:24px">
							Doc<br />Type
						</th>
						<th style="font-size:24px">
							Doc<br />Number
						</th>
						<th style="font-size:24px">
							<br />RCC Code
						</th>
						<th style="font-size:24px">
							<br />OBCL
						</th>
						<th style="font-size:24px">
							<br />Proj 1
						</th>
						<th style="font-size:24px">
							Vendor<br />EIN
						</th>
						<th style="font-size:24px">
							&nbsp;&nbsp;&nbsp;Amount<br />&nbsp;&nbsp;&nbsp;Charged
						</th>
					</tr>
					<cfloop from="1" to="#Variables[rstOPSCRA.OPSCRA & '_recordcount']#" index="i">
						<tr valign="top" <cfif not (i mod 2)>class="formAltRow"</cfif>>
							<td nowrap="nowrap" style="font-size:24px">
								#Variables[rstOPSCRA.OPSCRA & '_' & i & '_FY']#
							</td>
							<td nowrap="nowrap" style="font-size:24px">
								#Variables[rstOPSCRA.OPSCRA & '_' & i & '_DocType']#
							</td>
							<td nowrap="nowrap" style="font-size:24px">
								#Variables[rstOPSCRA.OPSCRA & '_' & i & '_DocNum']#
							</td>
							<td nowrap="nowrap" style="font-size:24px">
								#Variables[rstOPSCRA.OPSCRA & '_' & i & '_RccOrg']##Variables[rstOPSCRA.OPSCRA & '_' & i & '_RccFund']#
							</td>
							<td nowrap="nowrap" style="font-size:24px">
								#Variables[rstOPSCRA.OPSCRA & '_' & i & '_Obcl']#
							</td>
							<td nowrap="nowrap" style="font-size:24px">
								#Variables[rstOPSCRA.OPSCRA & '_' & i & '_Proj1']#
							</td>
							<td nowrap="nowrap" style="font-size:24px">
								#Variables[rstOPSCRA.OPSCRA & '_' & i & '_Ein']#
							</td>
							<td nowrap="nowrap" align="right" style="font-size:24px">
								#DollarFormat(Variables[rstOPSCRA.OPSCRA & '_' & i & '_AmountCharged'])#
							</td>
						</tr>
						<tr valign="top" <cfif not (i mod 2)>class="formAltRow"</cfif>>
							<td colspan="6" style="text-align:right" style="font-size:24px">
								JC Cat/PY
							</td>
							<td nowrap="nowrap" style="font-size:24px">
								#rstOPSCRA.OPSCRA# #Variables[rstOPSCRA.OPSCRA & '_' & i & '_PY']# #Variables[rstOPSCRA.OPSCRA & '_' & i & '_REGADV']#
							</td>
							<td>&nbsp;

							</td>
						</tr>
				</cfloop>
					</table>
			</cfif>
		</cfloop>
		<br />
		<br />
		<br />
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="formLDataTbl">
			<tr>
				<th colspan="3"  style="text-align:left;font-size:24px;">
					<br />Summary
				</th>
			</tr>
			<tr class="formAltRow">
				<td colspan="2" style="font-size:24px;font-weight:bold" width="50%">
					Total Amount Vouchered
				</td>
				<td style="text-align:right;font-size:24px;font-weight:bold" width="50%">
					#DollarFormat(Variables.CRA_total + Variables.OPS_total)#
				</td>
			</tr>
			<tr>
				<td colspan="2" style="font-size:24px" width="50%">
					Date Invoice Received in #rstVoucher.dateRecvName# Office
				</td>
				<td style="font-size:24px" width="50%">
					#dateFormat(rstVoucher.dateRecv, "mm/dd/yyyy")#
				</td>
			</tr>
			<tr class="formAltRow">
				<td colspan="2" style="font-size:24px" width="50%">
					Deadline for Payment to Avoid Late Fees
				</td>
				<td style="font-size:24px" width="50%">
					#dateFormat(rstVoucher.datePaymentDue, "mm/dd/yyyy")#
				</td>
			</tr>
			<tr>
				<td colspan="3">&nbsp;

				</td>
			</tr>
			<tr>
				<td style="font-size:24px;vertical-align:bottom" nowrap="nowrap">
					To Div of Accounting By:&nbsp;&nbsp;
				</td>
				<td style="font-size:24px;vertical-align:bottom" >
					__________________________________________________
				</td>
				<td style="font-size:24px; vertical-align:bottom">
					<u>#dateFormat(now(), "mm/dd/yyyy")#</u>
				</td>
			</tr>
			<tr>
				<td style="text-align:right">&nbsp;

				</td>
				<td style="font-size:24px">
					Signature
				</td>
				<td style="font-size:24px">
					Date
				</td>
			</tr>
		</table>
		</cfoutput>
	</div>

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

	</td>
</tr>
</table>
</body>
</html>



</cfdocument>