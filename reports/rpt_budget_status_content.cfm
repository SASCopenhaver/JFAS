<!---
page: rpt_budget_status_content.cfm

description: budget status report content, included by  rpt_budget_status.cfm

revisions:

2008-06-25	mstein	page created

--->
<!-- Begin Content Area -->
<cfoutput>
<div class="formContent">
<h1>Program Year #rsCurrentPY# Budget Status Report for #rsFundingOffice.fundingOfficeDesc#</h1>  
		
<br>						
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
	<tr><td>
		Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
		</td>
	</tr> 
</table>	
		
<table width="742" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
	<tr>
		<th colspan="7">&nbsp;</th>
		<th colspan="4" scope="col" title="Status of Active Funds" style="text-align:center">Status of Active Funds</th>
		<th colspan="2" scope="col" title="Unspent Obligations" style="text-align:center">Unspent Obligations</th>
	</tr>
	<tr>
		<th valign=top scope="col" title="AAPP No">AAPP No.</th>
		<th valign=top scope="col" title="Program/Activity">Program Activity</th>
		<th valign=top scope="col" title="Contractor/Contract No">Contractor/ <br>Contract No.</th>
		<th valign=top scope="col" title="Total Performance Period">Total Performance Period</th>
		<th>&nbsp;</th>
		<th valign=top scope="col" title="Approved Cumml Funds in AAPP/FOP">Approved Cumul Funds in AAPP/FOP</th>
		<th valign=top scope="col" title="Obligations from Expired Accounts">Obligations from Expired Accounts</th>
		<th valign=top scope="col" title="Approved in AAPP/FOP">$s Approved in AAPP/FOP</th>
		<th valign=top scope="col" title="Current Obligations">Current Obligations</th>
		<th valign=top scope="col" title="percent">As %</th>
		<th valign=top scope="col" title="Remaining Balance">Remaining Balance</th>
		<th valign=top scope="col" title="Expired Accounts">Expired Accounts</th>
		<th valign=top scope="col" title="Active Accounts">Active Accounts</th>
				
	</tr>
				
	<cfloop query="rsBudgetStatus">
	<tr <cfif currentrow mod 2>class="form2AltRow"</cfif>>
		<td valign=top scope="row">#AAPPNum#</td>
		<td valign=top>#programactivity#<br>Venue: #VENUE#</td>
		<td valign=top>#contractorname#<br>#contractnumber#</td>
		<td valign=top>#DateFOrmat(DATESTART, 'mm/dd/yyyy')#<br>
			#DateFOrmat(DATEEND, 'mm/dd/yyyy')#
		</td>
		<td valign=top align="right">OPS: <br>CRA: <br>TOT:</td>
		<td align=right valign=top>
			#numberFormat(fundingcummops)#<br>#numberFormat(fundingcummcra)#<br>#numberFormat(fundingcummtotal)#<br>&nbsp;
		</td>
		<td align=right valign=top style="border-right:1px solid ##5e84a6;">
			#numberFormat(fundingexpiredops)#<br>#numberFormat(fundingexpiredcra)#<br>&nbsp;
		</td>
		<Td align=right valign=top>
			#numberFormat(fundingactiveops)#<br>#numberFormat(fundingactivecra)#<br>&nbsp;
		</Td>
		<td align=right valign=top>
			#numberFormat(currentOblgOps)#<br>#numberFormat(currentOblgCra)#<br>&nbsp;
		</td>
		<td align=right valign=top>
			#numberFormat(actFundsPercentOps)#<br>#numberFormat(actFundsPercentCra)#<br>&nbsp;
		</td>
		<td align=right valign=top style="border-right:1px solid ##5e84a6;">
			#numberFormat(remainingBalanceOps)#<br>#numberFormat(remainingBalanceCra)#<br>&nbsp;
		</td>
		<td align=right valign=top>
			#numberFormat(unspentExpiredOps)#<br>#numberFormat(unspentExpiredCra)#<br>&nbsp;
		</td>
		<td align=right valign=top>
			#numberFormat(unspentActiveOps)#<br>#numberFormat(unspentActiveCra)#<br>&nbsp;
		</td>
	</tr>
	
	<cfset fundingcummcra_total = fundingcummcra_total + fundingcummcra>
	<cfset fundingcummops_total = fundingcummops_total + fundingcummops>
	<cfset fundingexpiredcra_total = fundingexpiredcra_total + fundingexpiredcra>
	<cfset fundingexpiredops_total = fundingexpiredops_total + fundingexpiredops>
	<cfset fundingactivecra_total = fundingactivecra_total + fundingactivecra>
	<cfset fundingactiveops_total = fundingactiveops_total + fundingactiveops>
	<cfset currentOblgCra_total = currentOblgCra_total + currentOblgCra>
	<cfset currentOblgops_total = currentOblgops_total + currentOblgops>
	<cfset remainingBalanceCra_total = remainingBalanceCra_total + remainingBalanceCra>
	<cfset remainingBalanceops_total = remainingBalanceops_total + remainingBalanceops>
	<cfset unspentExpiredCra_total = unspentExpiredCra_total + unspentExpiredCra>
	<cfset unspentExpiredops_total = unspentExpiredops_total + unspentExpiredops>
	<cfset unspentActiveCra_total = unspentActiveCra_total + unspentActiveCra>
	<cfset unspentActiveops_total = unspentActiveops_total + unspentActiveops>
	<cfset total = total + fundingcummtotal>
	
	</cfloop><!--- end of loop for budget status --->
			
	<!--- display region total --->	
	<tr>
		<td colspan=4 align=center valign=top scope="row"><strong>Total for #rsFundingOffice.fundingOfficeDesc#</strong></td>
		<td valign=top align="right"><strong>OPA:<br>CRA:<br>TOT:</strong></td>
		<td align=right valign=top>
			<strong>
				#numberFormat(fundingcummops_total)#<br>
				#numberFormat(fundingcummcra_total)#<br>
				#numberFormat(total)#<br>&nbsp;
			</strong>
		</td>
		<td align=right valign=top style="border-right:1px solid ##5e84a6;">
			<strong>
				#numberFormat(fundingexpiredops_total)#<br>
				#numberFormat(fundingexpiredcra_total)#<br>&nbsp;
			</strong>
		</td>
		<td align=right valign=top>
			<strong>
				#numberFormat(fundingactiveops_total)#<br>
				#numberFormat(fundingactivecra_total)#<br>&nbsp;
			</strong>
		</td>
		<td align=right valign=top>
			<strong>
				#numberFormat(currentOblgops_total)#<br>
				#numberFormat(currentOblgCra_total)#<br>&nbsp;
			</strong>
		</td>
		<td align=right valign=top>
			<cfif fundingactiveops_total neq "" and fundingactiveops_total neq 0>
				<strong>#round(currentOblgops_total/fundingactiveops_total*100)#</strong>
			<cfelse>
			&nbsp;
			</cfif><br>
			<cfif fundingactivecra_total neq "" and fundingactivecra_total neq 0>
				<strong>#round(currentOblgCra_total/fundingactivecra_total*100)#</strong>
			<cfelse>
				&nbsp;
			</cfif>
		</td>
		<td align=right valign=top style="border-right:1px solid ##5e84a6;">
			<strong>
				#numberFormat(remainingBalanceops_total)#<br>
				#numberFormat(remainingBalanceCra_total)#<br>&nbsp;
			</strong>
		</td>
		<td align=right valign=top>
			<strong>
				#numberFormat(unspentExpiredops_total)#<br>
				#numberFormat(unspentExpiredCra_total)#<br>&nbsp;
			</strong>
		</td>
		<td align=right valign=top>
			<strong>
				#numberFormat(unspentActiveops_total)#<br>
				#numberFormat(unspentActiveCra_total)#<br>&nbsp;
			</strong>
		</td>
	</tr>
	
	<!--- display national total --->		
	<cfset fundingcummcra_na_total = fundingcummcra_na_total + fundingcummcra_total>
	<cfset fundingcummops_na_total = fundingcummops_na_total + fundingcummops_total>
	<cfset fundingexpiredcra_na_total = fundingexpiredcra_na_total + fundingexpiredcra_total>
	<cfset fundingexpiredops_na_total = fundingexpiredops_na_total + fundingexpiredops_total>
	<cfset fundingactivecra_na_total = fundingactivecra_na_total + fundingactivecra_total>
	<cfset fundingactiveops_na_total = fundingactiveops_na_total + fundingactiveops_total>
	<cfset currentOblgCra_na_total = currentOblgCra_na_total + currentOblgCra_total>
	<cfset currentOblgops_na_total = currentOblgops_na_total + currentOblgops_total>
	<cfset remainingBalanceCra_na_total = remainingBalanceCra_na_total + remainingBalanceCra_total>
	<cfset remainingBalanceops_na_total = remainingBalanceops_na_total + remainingBalanceops_total>
	<cfset unspentExpiredCra_na_total = unspentExpiredCra_na_total + unspentExpiredCra_total>
	<cfset unspentExpiredops_na_total = unspentExpiredops_na_total + unspentExpiredops_total>
	<cfset unspentActiveCra_na_total = unspentActiveCra_na_total + unspentActiveCra_total>
	<cfset unspentActiveops_na_total = unspentActiveops_na_total + unspentActiveops_na_total>
	<cfset na_total = na_total + total>
	
	<cfif  cnt eq 8>
	<tr>
		<td colspan=4 align=center valign=top scope="row"><strong>Total for national</strong></td>
		<td valign=top><strong>Ops:<br>Cra:<br>Tot:</strong></td>
		<td align=right valign=top>
			<strong>
				#numberFormat(fundingcummops_na_total)#<br>
				#numberFormat(fundingcummcra_na_total)#<br>
				#numberFormat(na_total)#<br>&nbsp;
			</strong>
		</td>
		<td align=right valign=top style="border-right:1px solid ##5e84a6;">
			<strong>
				#numberFormat(fundingexpiredops_na_total)#<br>
				#numberFormat(fundingexpiredcra_na_total)#<br>&nbsp;
			</strong>
		</td>
		<td align=right valign=top>
			<strong>
				#numberFormat(fundingactiveops_na_total)#<br>
				#numberFormat(fundingactivecra_na_total)#<br>&nbsp;
			</strong>
		</td>
		<td align=right valign=top>
			<strong>
				#numberFormat(currentOblgops_na_total)#<br>
				#numberFormat(currentOblgCra_na_total)#<br>&nbsp;
			</strong>
		</td>
		<td align=right valign=top>
			<cfif fundingactiveops_na_total neq "" and fundingactiveops_na_total neq 0>
				<strong>#round(currentOblgops_na_total/fundingactiveops_na_total*100)#</strong>
			<cfelse>
			&nbsp;
			</cfif><br>
			<cfif fundingactivecra_na_total neq "" and fundingactivecra_na_total neq 0>
				<strong>#round(currentOblgCra_na_total/fundingactivecra_na_total*100)#</strong>
			<cfelse>
				&nbsp;
			</cfif>
		</td>
		<td align=right valign=top style="border-right:1px solid ##5e84a6;">
			<strong>
				#numberFormat(remainingBalanceops_na_total)#<br>
				#numberFormat(remainingBalanceCra_na_total)#<br>
			</strong>
		</td>
		<td align=right valign=top>
			<strong>
				#numberFormat(unspentExpiredops_na_total)#<br>
				#numberFormat(unspentExpiredCra_na_total)#<br>
			</strong>
		</td>
		<td align=right valign=top>
			<strong>
				#numberFormat(unspentActiveops_na_total)#<br>
				#numberFormat(unspentActiveCra_na_total)#<br>
			</strong>
		</td>
	</tr>
	</cfif>
</table>
</div>
</cfoutput>

<!-- End Content Area -->