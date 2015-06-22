<cfsilent>
<!---
page: rpt_fiscal_plan.cfm

description: display report for Fiscal Plan

revisions:
2007-02-20	yjeng	Attached center after performance

--->
</cfsilent>

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
			<h1>Job Corps Fiscal Plan for Center or OA/CTS Contract - Program Year #rstFiscalPlan.rs1.program_year# </h1>
			<h2>Report Printed #dateformat(now(),"mm/dd/yyyy")# #timeformat(now(),"hh:mm tt")#</h2>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
			  <tr valign="top">
				<td nowrap="nowrap">Region/AAPP Number: </td>
				<td>#rstFiscalPlan.rs1.region_desc# <strong>#rstFiscalPlan.rs1.aapp_num#</strong> </td>
				<td nowrap="nowrap">Program Services: </td>
				<td>#rstFiscalPlan.rs1.program_service#</td>
			  </tr>
			  <tr valign="top">
				<td nowrap="nowrap">Contractor: </td>
				<td>#rstFiscalPlan.rs1.contractor_name#</td>
				<td nowrap="nowrap">Performance Venue / Center: </td>
				<td>#rstFiscalPlan.rs1.venue# / #rstFiscalPlan.rs1.center_name#</td>
			  </tr>
			  <tr valign="top">
				<td nowrap="nowrap">Contract Number: </td>
				<td>#rstFiscalPlan.rs1.contract_num#</td>
				<td nowrap="nowrap">Next Procurement Action: </td>
				<td>#rstFiscalPlan.rs1.action_desc# #rstFiscalPlan.rs1.effective_date#</td>
			  </tr>
			  <tr valign="top">
				<td nowrap="nowrap">DOLAR$ Document No.: </td>
				<td>#rstFiscalPlan.rs1.doc_number#</td>
				<td nowrap="nowrap">Performance Period: </td>
				<td>#rstFiscalPlan.rs1.from_date# through #rstFiscalPlan.rs1.through_date#</td>
			  </tr>
			</table>
			<!-- End Form Header Info -->
			<table border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
			<tr>
				<th colspan="6"scope="col">
					A. AAPP Estimated Cost/Contract Funding Expected as of this Report Date<br />
					The Current Contract Completion Date at this Time is #rstFiscalPlan.rs1.completion_date#</th>
				<th></th>
			</tr>
			</cfoutput>
			<tr>
				<th colspan="3" rowspan="2" scope="col">Estimated Cost through Current Completion Date </th>
				<th rowspan="2" scope="col" width="90"><strong>AAPP Approved Amounts</strong></th>
				<th colspan="2" scope="col"><div align="center">Work Area </div></th>
				<th scope="col" width="200"><div align="center"><strong>Space for Regional Notes </strong></div></th>
			</tr>
			<tr>
				<th scope="col" width="75"><strong>Latest Mod $</strong></th>
				<th scope="col" width="75">Difference</th>
				<th></th>
			</tr>
			<cfset totalAmount=0>
			<cfoutput query="rstFiscalPlan.rs2">
			<tr <cfif currentrow mod 2>class="form2AltRow"</cfif>>
				<td scope="row">#cost_cat_code#</td>
				<td width="180">#cost_cat_desc#</td>
				<td align="right">#note#</td>
				<td align="right">$#numberformat(amount,",")#</td>
				<td>$</td>
				<td>$</td>
				<td>&nbsp;</td>
			</tr>
			<cfset therow=currentrow+1>
			<cfset totalAmount=totalAmount+amount>
			</cfoutput>
			<cfoutput>
			<tr <cfif therow mod 2>class="form2AltRow"</cfif>>
				<td scope="row">&nbsp;</td>
				<td><strong>Total Estimated Cost </strong></td>
				<td align="right">&nbsp;</td>
				<td align="right"><strong>$#numberformat(totalAmount,",")#</strong></td>
				<td><strong>$</strong></td>
				<td><strong>$</strong></td>
				<td>&nbsp;</td>
			</tr>
			</cfoutput>
			</table>
			<table border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
				<cfoutput>
				<tr>
					<th colspan="3" rowspan="2" scope="col">PY #rstFiscalPlan.rs1.program_year# Contract Funding for Cost through #rstFiscalPlan.rs1.fund_through_date# &nbsp;3/</th>
					<th rowspan="2" scope="col" width="90"><strong>AAPP Approved Amounts</strong></th>
					<th rowspan="2" scope="col" width="75"><strong>Latest Mod $ </strong></th>
					<th rowspan="2" scope="col" width="75">Difference</th>
					<th colspan="2" scope="col"><div align="center"><strong>B. Pending PY #rstFiscalPlan.rs1.program_year# Contract Funding &nbsp;4/</strong></div></th>
				</tr>
				</cfoutput>
				<tr>
					<th scope="col" width="90"><div align="right">Increase</div></th>
					<th scope="col" width="90"><div align="right">New Total </div></th>
				</tr>
				<cfset sumArray=arraynew(1)>
				<cfset sumArray[1]=0>
				<cfset sumArray[4]=0>
				<cfset sumArray[5]=0>
				<cfoutput query="rstFiscalPlan.rs3" group="cost_cat_code">
				<tr <cfif currentrow mod 2>class="form2AltRow"</cfif>>
					<td scope="row">#cost_cat_code#</td>
					<td width="180">#cost_cat_desc#</td>
					<td align="right"></td>
					<cfoutput>
					<cfif sort_by eq 2 or sort_by eq 3>
					<td align="left">$</td>
					<cfelse>
					<td align="right">$
							#numberformat(amount,",")#
					</td>
					<cfset sumArray[sort_by]=sumArray[sort_by]+amount>
					</cfif>
					</cfoutput>
				</tr>
				</cfoutput>
				<cfoutput>
				<tr class="form2AltRow">
					<td scope="row">&nbsp;</td>
					<td><strong>Totals</strong></td>
					<td align="right">&nbsp;</td>
					<td align="right"><strong>$#numberformat(sumArray[1],",")#</strong></td>
					<td><strong>$</strong></td>
					<td><strong>$</strong></td>
					<td align="right"><strong>$#numberformat(sumArray[4],",")#</strong></td>
					<td align="right"><strong>$#numberformat(sumArray[5],",")#</strong></td>
				</tr>
				</cfoutput>
		  </table>

		<table border="0" cellpadding="0" cellspacing="0" class="form2bDataTbl">
			<tr>
				<th colspan="6" scope="col">C. Contract Funding by Appropriation (Information for Contract/Fiscal Specialists) </th>
			</tr>
			<tr>
				<th scope="col">Appropriation Category </th>
				<th class="smTh" scope="col"><div align="center">A</div>
				Cum Funding through Entire Program Year </th>
				<th class="smTh" scope="col"><div align="center">B</div>
				Actual Funding Expired Accounts per DOLAR$ </th>
				<th class="smTh" scope="col"><div align="center">C (A-B)</div>
				Budgeted Funding from Active Accounts </th>
				<th class="smTh" scope="col"><div align="center">D</div>
				Actual Funding Active Accounts per DOLAR$ </th>
				<th class="smTh" scope="col"><div align="center">E (C-D)</div>
				Available Balance for this Program Year </th>
			</tr>
			<cfset theArray=arraynew(2)>
			<cfloop query="rstFiscalPlan.rs4">
				<cfset theArray[col][row1]=amount>
			</cfloop>
			<cfloop index="idx" from="1" to="2">
				<cfset theArray[3][idx]=theArray[1][idx]-theArray[2][idx]>
			</cfloop>
			<cfloop index="idx" from="1" to="2">
				<cfset theArray[5][idx]=theArray[3][idx]-theArray[4][idx]>
			</cfloop>
			<cfloop index="idx" from="1" to="5">
				<cfset theArray[idx][3]=theArray[idx][1]+theArray[idx][2]>
			</cfloop>
			<cfoutput>
			<tr>
				<td scope="row">Operation Funds </td>
				<cfloop index="idx" from="1" to="5">
				<td align="right">
					<cfif theArray[idx][1] lt 0>-</cfif>$#numberformat(abs(theArray[idx][1]),",")#
				</td>
				</cfloop>
			</tr>
			<tr class="form2bAltRow">
				<td scope="row">Cnst/Rehab/Acquisition</td>
				<cfloop index="idx" from="1" to="5">
				<td align="right">
					<cfif theArray[idx][2] lt 0>-</cfif>$#numberformat(abs(theArray[idx][2]),",")#
				</td>
				</cfloop>
			</tr>
			<tr>
				<td scope="row"><strong>Total</strong></td>
				<cfloop index="idx" from="1" to="5">
				<td align="right">
					<strong><cfif theArray[idx][3] lt 0>-</cfif>$#numberformat(abs(theArray[idx][3]),",")#</strong>
				</td>
				</cfloop>
			</tr>
			</cfoutput>
		</table>
	    <!-- Begin Form Footer Info -->
		<cfoutput>
		<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
			<cfdocumentitem type="footer">
				<table width=100% cellspacing="0" border=0 cellpadding="0">
					<tr>
						<td>
							<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
								1/ Also see estimated cost profiles for Center Operations and OA/CTS expense, as applicable.<br />
								2/ Estimated cost amount for GSA Vehicles is approximation for ballpark guidance only.<br />
								3/ Current contract completion date or end of PY #rstFiscalPlan.rs1.program_year#, whichever is first.  N/A if contract begins later.<br />
								4/ Applies when new contract or option year will start later on, but prior to end of PY #rstFiscalPlan.rs1.program_year#; otherwise N/A.<br />
							</font>
						</td>
						<td align=right>
							<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
								page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
							</font>
						</td>
					</tr>
				</table>
			</cfdocumentitem>
		<cfelse>
			<div class="footnotes">
				<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
					1/ Also see estimated cost profiles for Center Operations and OA/CTS expense, as applicable.<br />
					2/ Estimated cost amount for GSA Vehicles is approximation for ballpark guidance only.<br />
					3/ Current contract completion date or end of PY #rstFiscalPlan.rs1.program_year#, whichever is first.  N/A if contract begins later.<br />
					4/ Applies when new contract or option year will start later on, but prior to end of PY #rstFiscalPlan.rs1.program_year#; otherwise N/A.<br />
				</font>
			</div>
		</cfif>
		</cfoutput>
	    <!-- End Form Footer Info -->
        </div>
		<!-- End Content Area -->
</td>
</tr>
</table>
</body>
</html>
