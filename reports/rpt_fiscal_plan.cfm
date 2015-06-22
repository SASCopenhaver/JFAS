<cfsilent>
<!---
page: rpt_fiscal_plan.cfm

description: display report for Fiscal Plan

revisions:
2007-02-20	yjeng	Attached center after performance
2013-08-19	mstein	Changed "DOLAR$" to "NCFMS"

--->
<cfset obj = application.outility>
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
			<h1>Job Corps Fiscal Plan for Center or OA/CTS Contract <!--- - Program Year #rstFiscalPlan.rs1.program_year# ---> </h1>
			<h2 style="font-weight:normal;">Report Printed #dateformat(now(),"mm/dd/yyyy")# #timeformat(now(),"hh:mm tt")#</h2>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="display header info.">
			  <tr valign="top">
				<td width="18%" nowrap="nowrap" title="Region/AAPP No." scope="row"><strong>Region/AAPP No.:</strong> </td>
				<td width="17%">#rstFiscalPlan.rs1.region_desc# &nbsp;<strong>#rstFiscalPlan.rs1.aapp_num#</strong> </td>
				<td width="23%" nowrap="nowrap" title="Program Services" scope="row"><strong>Program Services:</strong> </td>
				<td width="42%">#rstFiscalPlan.rs1.program_service#</td>
			  </tr>
			  <tr valign="top">
				<td nowrap="nowrap" title="Contractor" scope="row"><strong>Contractor:</strong> </td>
				<td>#rstFiscalPlan.rs1.contractor_name#</td>
				<td nowrap="nowrap" title="Performance Venue/Center" scope="row"><strong>Performance Venue/Center:</strong> </td>
				<td>
					<cfif len(rstFiscalPlan.rs1.venue) and len(rstFiscalPlan.rs1.center_name)>
						#rstFiscalPlan.rs1.venue#/#rstFiscalPlan.rs1.center_name#
					<cfelse>
						#rstFiscalPlan.rs1.venue##rstFiscalPlan.rs1.center_name#
					</cfif>
				</td>
			  </tr>
			  <tr valign="top">
				<td nowrap="nowrap" title="Contract No." scope="row"><strong>Contract No.:</strong> </td>
				<td>#rstFiscalPlan.rs1.contract_num#</td>
				<td nowrap="nowrap" title="Next Procurement Action" scope="row"><strong>Next Procurement Action:</strong> </td>
				<td>#rstFiscalPlan.rs1.action_desc# #rstFiscalPlan.rs1.effective_date#</td>
			  </tr>
			  <tr valign="top">
				<td nowrap="nowrap" title="NCFMS Document No." scope="row"><strong>NCFMS Doc No.:</strong> </td>
				<td>#rstFiscalPlan.rs1.doc_number#</td>
				<td nowrap="nowrap" title="Performance Period" scope="row"><strong>Total Performance Period:</strong> </td>
				<td>#rstFiscalPlan.rs1.from_date# &nbsp;<strong>through Final End Date of</strong>&nbsp; #rstFiscalPlan.rs1.final_date#</td>
			  </tr>
			</table>
			<!-- End Form Header Info -->
			<table border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
			<tr>
				<th colspan="4" scope="col" rowspan="2" style="vertical-align:top;border-right:1px solid ##ffffff;">
					A. AAPP-Approved Estimated Cost and Contract Funding As of This Report Date.<br /><br />
					<div style="margin-left:1em;">Current Contract Completion Date: <span style="font-weight:normal">#rstFiscalPlan.rs1.completion_date#</span></div>
				</th>
				<th colspan="3">B. AAPP Data for Next Routine ECP/Contract Funding Mod  4/</th>
			</tr>
			<tr>
				<th colspan="3" scope="col">
					<div style="margin-left:1em;">Mod Purpose: <span style="font-weight:normal">#rstFiscalPlan.rs1.mod_purpose#
					</span></div>
				</th>
			</tr>
			<tr>
				<th colspan="4" style="vertical-align:top;border-right:1px solid ##ffffff;">

				</th>
				<th colspan="3">
					<div style="margin-left:1em;">Earliest Mod Issue Date: <span style="font-weight:normal">#rstFiscalPlan.rs1.mod_issue_date#</span>&nbsp;&nbsp;5/</div>
				</th>
			</tr>
			</cfoutput>
			<tr>
				<th colspan="3" scope="col" title="Estimated Cost through Current Completion Date">Estimated Cost through Current Completion Date </th>
				<th scope="col" title="AAPP Approved Amounts" style="text-align:right;border-right:1px solid #ffffff;">A-1. AAPP Approved Amounts</th>
				<th scope="col" title="Estimated Cost Change" style="text-align:right;">B-1. Estimated Cost Change</th>
				<th scope="col" title="New Estimated Cost Total" style="text-align:right;border-right:1px solid #ffffff;">B-3. New<br />Estimated<br /> Cost Total</th>
				<th title="User Notes" style="border-top:1px solid #ffffff;"><div align="center">User Notes</div></th>
			</tr>
			<cfquery name="sum_col_a1" dbtype="query">
				select	sum(amount) as amount
				from	rstFiscalPlan.rs2
			</cfquery>
			<cfquery name="sum_col_c" dbtype="query">
				select	sum(amount) as amount
				from	rstFiscalPlan.rs3
				where	sort_by = 4
			</cfquery>
			<cfset totalAmount=arraynew(1)>
			<cfset totalAmount[1]=0>
			<cfset totalAmount[2]=0>
			<cfset totalAmount[3]=0>
			<cfoutput query="rstFiscalPlan.rs2">
			<tr <cfif currentrow mod 2>class="form2AltRow"</cfif>>
				<td width="15" scope="row"><strong>#cost_cat_code#</strong></td>
				<td width="150"><strong>#cost_cat_desc#</strong></td>
				<td width="15" align="right">#note#</td>
				<td width="120" align="right" style="border-right:1px solid ##5e84a6;">#obj.formatString(amount,"dollar",'','&nbsp;')#</td>
				<td width="140" align="right"> #obj.formatString(est_cost_change,"dollar",'','&nbsp;')#</td>
				<td width="140" align="right" style="border-right:1px solid ##5e84a6;"> #obj.formatString(new_est_cost_total,"dollar",'','&nbsp;')#</td>
				<cfif currentrow eq 1>
				<td rowspan="#rstFiscalPlan.rs2.recordcount#" valign="top" style="background-color:##FFFFFF">
					<cfif len(rstFiscalPlan.rs1.users_note)>
						#rstFiscalPlan.rs1.users_note#
						<br />
					</cfif>
					<cfif rstFiscalPlan.rs1.case_num eq 1 and sum_col_a1.amount neq sum_col_c.amount>
						AAPP ECP different from AAPP FOP.
						<br />
					</cfif>
					<img src="#application.paths.images#clear.gif" width="1" height="1" hspace="70" alt="" />
				</td>
				</cfif>
			</tr>
			<cfset therow=currentrow+1>
			<cfset totalAmount[1]=totalAmount[1]+#obj.formatString(amount,"int",'',"0")#>
			<cfset totalAmount[2]=totalAmount[2]+#obj.formatString(est_cost_change,"int",'',"0")#>
			<cfset totalAmount[3]=totalAmount[3]+#obj.formatString(new_est_cost_total,"int",'',"0")#>
			</cfoutput>
			<cfoutput>
			<tr <cfif therow mod 2>class="form2AltRow"</cfif>>
				<td scope="row">&nbsp;</td>
				<td><strong>Total Estimated Cost </strong></td>
				<td align="right">&nbsp;</td>
				<td align="right" style="border-right:1px solid ##5e84a6;"><strong>#obj.formatString(totalAmount[1],"dollar",'','&nbsp;')#</strong></td>
				<td align="right"><strong>#obj.formatString(totalAmount[2],"dollar",'','&nbsp;')#</strong></td>
				<td align="right" style="border-right:1px solid ##5e84a6;"><strong>#obj.formatString(totalAmount[3],"dollar",'','&nbsp;')#</strong></td>
				<td></td>
			</tr>
			</cfoutput>
			<!---</table>
			<table border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">--->
				<cfoutput>
				<tr>
					<th colspan="3" scope="col">PY #rstFiscalPlan.rs1.program_year# Contract Funding for Cost through #dateformat(rstFiscalPlan.rs1.action_date,"mm/dd/yyyy")# &nbsp;3/</th>
					<th scope="col" style="text-align:right;border-right:1px solid ##ffffff;"><strong>A-2. AAPP Approved Amounts</strong></th>
					<th scope="col" style="text-align:right;">B-2. Contract Funding Change</th>
					<th scope="col" style="text-align:right;border-right:1px solid ##ffffff;">B-4. New Total<br /> Contract<br /> Funding</th>
					<th scope="col" style="text-align:right;">C. Maximum Funding Approved Through<br />PY #rstFiscalPlan.rs1.program_year# &nbsp;&nbsp;6/</strong></div></th>
				</tr>
				<!---
				<tr>
					<th scope="col"><div align="center">Pending Changes (i)</div></th>
					<th scope="col"><div align="center">Cum Through PY #rstFiscalPlan.rs1.program_year# (j)</div></th>
				</tr>
				--->
				</cfoutput>
				<cfset sumArray=arraynew(1)>
				<cfset sumArray[1]=0>
				<cfset sumArray[2]=0>
				<cfset sumArray[3]=0>
				<cfset sumArray[4]=0>
				<cfset therow=1>
				<cfoutput query="rstFiscalPlan.rs3" group="cost_cat_code">
					<tr <cfif therow mod 2>class="form2AltRow"</cfif>>
						<td width="15" scope="row"><strong>#cost_cat_code#</strong></td>
						<td width="150"><strong>#cost_cat_desc#</strong></td>
						<td width="15" align="right"></td>
						<cfoutput>
								<td align="right" <cfif listFind("1,3",sort_by)>style="border-right:1px solid ##5e84a6;"</cfif>>
									<cfset useAmount = amount>
									<!--- displayed amount in column A-2 can never exceed amount in column C --->
									<cfif sort_by eq 1 and amount neq "" and amount[currentRow+3] neq "">
										<cfset useAmount = min(amount, amount[currentRow+3])>
									</cfif>
									<cfset useAmount = obj.formatString(useAmount,"int",'',"0")>
									#obj.formatString(useAmount,"dollar",'','&nbsp;')#
								</td>
						<cfset sumArray[sort_by]=sumArray[sort_by]+useAmount>
						</cfoutput>
					</tr>
					<cfset therow=therow+1>
				</cfoutput>
				<cfoutput>
				<tr <cfif therow mod 2>class="form2AltRow"</cfif>>
					<td scope="row">&nbsp;</td>
					<td><strong>Totals</strong></td>
					<td align="right">&nbsp;</td>
					<td align="right" style="border-right:1px solid ##5e84a6;"><strong>#obj.formatString(sumArray[1],"dollar",'','&nbsp;')#</strong></td>
					<td align="right"><strong>#obj.formatString(sumArray[2],"dollar",'','&nbsp;')#</strong></td>
					<td align="right" style="border-right:1px solid ##5e84a6;"><strong>#obj.formatString(sumArray[3],"dollar",'','&nbsp;')#</strong></td>
					<td align="right"><strong>#obj.formatString(sumArray[4],"dollar",'','&nbsp;')#</strong></td>
				</tr>
				</cfoutput>
		  </table>

		<table border="0" cellpadding="0" cellspacing="0" class="form2bDataTbl">
			<tr>
				<th colspan="6" scope="col">D. Contract Funding by Appropriation (Information for Contract/Fiscal Specialists) </th>
			</tr>
			<tr>
				<th scope="col">Appropriation Category </th>
				<th class="smTh" scope="col" style="text-align:center;">D-1<br />
				Cum Funding through Entire Program Year </th>
				<th class="smTh" scope="col" style="text-align:center;">D-2<br />
				Actual Funding Expired Accounts per NCFMS </th>
				<th class="smTh" scope="col" style="text-align:center;">D-3 (D-1 - D-2)<br />
				Budgeted Funding from Active Accounts </th>
				<th class="smTh" scope="col" style="text-align:center;">D-4<br />
				Actual Funding Active Accounts per NCFMS </th>
				<th class="smTh" scope="col" style="text-align:center;">D-5 (D-3 - D-4)<br />
				Available Balance for this Program Year </th>
			</tr>
			<cfset theArray=arraynew(2)>
			<cfloop query="rstFiscalPlan.rs4">
				<cfset theArray[col][row1]=amount>
			</cfloop>
			<cfloop index="idx" from="1" to="2">
				<cfset theArray[3][idx]=obj.formatString(theArray[1][idx],"int",'',"0")-obj.formatString(theArray[2][idx],"int",'',"0")>
			</cfloop>
			<cfloop index="idx" from="1" to="2">
				<cfset theArray[5][idx]=obj.formatString(theArray[3][idx],"int",'',"0")-obj.formatString(theArray[4][idx],"int",'',"0")>
			</cfloop>
			<cfloop index="idx" from="1" to="5">
				<cfset theArray[idx][3]=obj.formatString(theArray[idx][1],"int",'',"0")+obj.formatString(theArray[idx][2],"int",'',"0")>
			</cfloop>
			<cfoutput>
			<tr>
				<td scope="row">Operation Funds </td>
				<cfloop index="idx" from="1" to="5">
				<td align="right">
					#obj.formatString(theArray[idx][1],"dollar",'','&nbsp;')#
				</td>
				</cfloop>
			</tr>
			<tr class="form2bAltRow">
				<td scope="row">Cnst/Rehab/Acquisition</td>
				<cfloop index="idx" from="1" to="5">
				<td align="right">
					#obj.formatString(theArray[idx][2],"dollar",'','&nbsp;')#
				</td>
				</cfloop>
			</tr>
			<tr>
				<td scope="row"><strong>Total</strong></td>
				<cfloop index="idx" from="1" to="5">
				<td align="right">
					<strong>#obj.formatString(theArray[idx][3],"dollar",'','&nbsp;')#</strong>
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
								1/ &nbsp;Also see estimated cost profiles (ECP's) for Center Operations, OA, CTS, and Support as applicable.	<br />
								2/ &nbsp;Estimated cost amount for Vehicle Amortization is a formula-generated approximation of anticipated costs through current contract end date.	<br />
								3/ &nbsp;Current contract completion date or depletion date of current Agency Allocation, whichever occurs first.	<br />
								4/ &nbsp;New Total amounts in Section B (B-3 and B-4) accurately reflect AAPP approvals.  Change amounts (columns B-1 and B-2) are accurate if current contract estimated cost and<br />
								&nbsp;&nbsp;&nbsp;&nbsp;funding agree with amounts in Section A (columns A-1 and A-2). Otherwise, Change Amounts will need to be adjusted for correct agreement with Approved New Totals<br />
								5/ &nbsp;Based on dates when Agency Allocations become available.  If this date falls on July 1, funds from the new PY are needed.<br />
								6/ &nbsp;These amounts may not be exceeded until the start of the next Program Year
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
					1/ &nbsp;Also see estimated cost profiles (ECP's) for Center Operations, OA, CTS, and Support as applicable.	<br />
					2/ &nbsp;Estimated cost amount for Vehicle Amortization is a formula-generated approximation of anticipated costs through current contract end date.	<br />
					3/ &nbsp;Current contract completion date or depletion date of current Agency Allocation, whichever occurs first.	<br />
					4/ &nbsp;New Total amounts in Section B (B-3 and B-4) accurately reflect AAPP approvals.  Change amounts (columns B-1 and B-2) are accurate if current contract estimated cost and<br />
					&nbsp;&nbsp;&nbsp;&nbsp;funding agree with amounts in Section A (columns A-1 and A-2). Otherwise, Change Amounts will need to be adjusted for correct agreement with Approved New Totals<br />
					5/ &nbsp;Based on dates when Agency Allocations become available.  If this date falls on July 1, funds from the new PY are needed.<br />
					6/ &nbsp;These amounts may not be exceeded until the start of the next Program Year
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
