<!---
page: rpt_oa_cts_annualized_content.cfm

description: OA/CTS Annualized Workload report content, included by  rpt_oa_cts_annualized.cfm

revisions:

2008-06-26	mstein	page created

--->
<!-- Begin Content Area -->
<cfoutput>
<h1>OA/CTS Annualized Workload/Cost Under Current Contracts as of #form.txtStartDate#</h1>  
<br>
<div class="formContent">
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
	<tr><td>
		Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
		</td>
	</tr> 
</table>	
	
<table width="742" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
	<tr>
		<th valign=top scope="col" title="Unit">Unit</th>
		<th valign=top scope="col" title="AAPP No.">AAPP No.</th>
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
</div>
</cfoutput>
<!-- End Content Area -->