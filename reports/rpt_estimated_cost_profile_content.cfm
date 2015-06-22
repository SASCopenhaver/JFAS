<!---
page: rpt_estimated_cost_profile_content.cfm

description: estimated cost profile report content, included by  rpt_estimated_cost_profile.cfm

revisions:

2008-06-25	mstein	page created
2009-06-03	mstein	added "APR" column in bottom summary section
2014-03-29	mstein	Formatted APR column as text in Excel (to prevent rounding)
--->

<table border="0" cellspacing="0" cellpadding="0" align="center" width="762">
	<tr>
		<td align="center">
			<!-- Begin Content Area -->
			<h1>Job Corps AAPP Estimated Cost Profile</h1>
			<cfoutput>
			<h2>Actual/Approved $ Amounts as of #dateformat(now(),"mm/dd/yyyy")#</h2>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="display report header info.">
				<tr valign="top">
					<td width=10% nowrap="nowrap" title="Region" scope="row"><strong>Region:</strong></td> 
					<td width=20% >#rstRptEstCostProfile.region_desc#</td>
					<td width=20% title="Program Activity"  scope="row"><strong>Program Activity:</strong></td>
					<td> #rstRptEstCostProfile.program_service#</td>
				</tr>
				<tr>
					<td title="AAPP No." scope="row"><strong>AAPP No.:</strong> </td>
					<td>#rstRptEstCostProfile.aapp_num#</td>
					<td nowrap="nowrap" title="Performance Venue/Center" scope="row"><strong>Performance Venue/Center:</strong></td>
					<td> #rstRptEstCostProfile.venue# / #rstRptEstCostProfile.center_name#</td>
				</tr>
				<tr valign="top">
					<td nowrap="nowrap" title="Contractor" scope="row"><strong>Contractor:</strong> </td>
					<td>#rstRptEstCostProfile.contractor_name#</td>
					<td nowrap scope="row" title="Contract No."><strong>Contract No.:</strong></td>
					<td>#rstRptEstCostProfile.contract_num#</td>
				</tr>
				<tr><td colspan="4" align="right" title="status">#rstRptEstCostProfile.status#</td></tr>
			</table>
			</cfoutput>
			<!-- End Form Header Info -->
			<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
				<tr>
					<th colspan="2" scope="col" title="Cost Category" width="15%">Cost Category </th>
					<th scope="col" title="Status" width="7%"><strong>Status</strong></th>
					<th scope="col" title="Mod No." width="10%"><strong>Mod No. </strong></th>
					<th scope="col" title="Contract Year" width="10%"><strong>Contract Year </strong></th>
					<th scope="col" title="Ongoing Expense" width="10%"><strong>Ongoing Expense </strong></th>
					<th scope="col" title="Amount" width="11%"><strong>Amount </strong></th>
					<th scope="col" width="275" title="Comments"><strong>Comments</strong></th>
					<th></th>
				</tr>
				<cfset amountExec=0>
				<cfset currMod="0">
				<cfset therow=0>
				<cfoutput query="qryEstCostProfileSort" group="contract_year">
				<cfif currentrow neq 1>
				<tr>
					<td colspan="9" class="hrule"></td>
				</tr>
				</cfif>
				<cfoutput>
				<cfif len(mod_num)>
					<cfset amountExec=amountExec+amount>
					<cfif mod_num gt currMod>
						<cfset currMod=mod_num>
					</cfif>
				</cfif>
				<cfif not (amount eq 0 and mod_num eq "--")>
				<cfset therow=therow+1>
				<tr<cfif therow mod 2> class="formAltRow"</cfif>>
					<td scope="row" width="3%">#contract_type_code#</td>
					<td width="12%">#ctype_desc_short#</td>
					<td width="7%">#status#</td>
					<td>#mod_num#</td>
					<td>#contract_year#</td>
					<td>#ongoing#</td>
					<td align="right">
						<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#
					</td>
					<td>#description#</td>
					<td>
					<cfif status eq "PEND" and cy ge contract_year>1/</cfif>
					</td>
				</tr>
				</cfif>
				</cfoutput>
				</cfoutput>
			</table>
			
			<!-- Begin Form Footer Info -->
			<table border="0" cellpadding="0" cellspacing="0" class="form1ftr">
				<tr>
					<th scope="col">Contract Year</th>
					<th scope="col">Start</th>
					<th scope="col">End</th>
					<cfoutput query="qryWorkloadTitle">
					<th style="text-align: center">#workload_type_desc#</th>
					</cfoutput>
					<th style="text-align: right">Year's Funds </th>
					<th style="text-align: right">Cumulative</th>
					<cfif NOT listFind("20,25",rstRptEstCostProfile.funding_Office_num)>
						<th style="text-align: right">APR <span style="font-weight:normal">2/</span></th>
					</cfif>
				</tr>
				<cfset cumValue=0>
				<cfset mycol="contract_year">
				<cfoutput query="qryTotal">
				<cfset cumValue=cumValue+funds>
				<cfset theYear=contract_year>
				<tr<cfif contract_year eq cy> style="font-weight:bold"</cfif>>
					<td>Year #evaluate(mycol)#:</td>
					<td>#date_start#</td>
					<td>#date_end#</td>
					<cfloop query="qryWorkloadData">
					<cfif theYear eq contract_year>
					<td align="center">#numberformat(value,",")#</td>
					</cfif>
					</cfloop>
					<td align="right">$#numberformat(funds,",")#</td>
					<td align="right">$#numberformat(cumValue,",")#</td>
					<!--- display APR%, NOTE: mso-function is so Excel won't round --->
					<cfif NOT listFind("20,25",rstRptEstCostProfile.funding_Office_num)>
						<td align="right" style='mso-number-format:"\@";'><cfif contract_year gt base_year>#numberformat(omb_rate,"0.000")#%</cfif></td>
					</cfif>
				</tr>
				</cfoutput>
				<cfoutput>
				<tr valign="top">
					<td colspan="#evaluate(3+qryWorkloadTitle.recordcount)#" scope="row" align="left">
						<span style="font-size:x-small">
						1/ Approved for current year, but mod not yet received in National Office<br />
						<cfif NOT listFind("20,25",rstRptEstCostProfile.funding_Office_num)>
						2/ APR based on PY in which contract year begins. APR adjusted if preceding<br />&nbsp;&nbsp;&nbsp;&nbsp;contract year is less than 365 days</span>
						</cfif>
					</td>
					<td align="right"><strong>Per current mod (###currMod#):</strong></td>
					<td align="right"><strong>$#numberformat(amountExec,",")#</strong></td>
					<cfif NOT listFind("20,25",rstRptEstCostProfile.funding_Office_num)>
						<td></td>
					</cfif>
				</tr>
				</cfoutput> 	
			</table>
			
			<cfoutput>
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
				<!-- End Form Footer Info --> 
			</cfif>
			</cfoutput>
			<!-- End Content Area -->	
		</td>
	</tr>
</table>