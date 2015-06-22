<cfsilent>
<!---
page:

description:

revisions:


--->
<cfset request.pageID = "1120" />
<cfinvoke component="#application.paths.components#aapp_budget" method="getFutureNewHeader" aapp="#url.aapp#" returnvariable="rstFNH" />
<cfinvoke component="#application.paths.components#aapp_budget" method="getFutureNewContractEstimates" aapp="#url.aapp#" returnvariable="varBaseEst" />
<cfquery name="rstBPEC" dbtype="query">
	select	contract_type_desc_short, con_sort_order,
			contract_budget_item_id,
			'Reimbursable/FF Expense' as row_desc,
			1 as row_sort_order,
			sum(amount) as amount
	from	varBaseEst
	where	contract_budget_item_id in (1,11,19,21)<!---Reimbursable--->
	and		years_base >= contract_year
	group by contract_type_desc_short, con_sort_order,
			 contract_budget_item_id
	union
	select	contract_type_desc_short, con_sort_order,
			contract_budget_item_id,
			'Base/Avg Incentive Fee' as row_desc,
			2 as row_sort_order,
			sum(amount) as amount
	from	varBaseEst
	where	contract_budget_item_id in (7,16,23)<!---Incentive Fee--->
	and		years_base >= contract_year
	group by contract_type_desc_short, con_sort_order,
			 contract_budget_item_id
	union
	select	contract_type_desc_short, con_sort_order,
			contract_budget_item_id,
			'Total Estimated Cost' as row_desc,
			3 as row_sort_order,
			sum(amount) as amount
	from	varBaseEst
	where	contract_budget_item_id in (5,9,17,19)<!---Total--->
	and		years_base >= contract_year
	group by contract_type_desc_short, con_sort_order,
			 contract_budget_item_id
</cfquery>
<!---
<cfquery name="ops" datasource="#request.dsn#">
	select	contract.fun_getconestratio(#url.aapp#) as rate
	from	dual
</cfquery>
--->
<cfquery name="rstA" dbtype="query">
	select	contract_year,
			contract_budget_item_id,
			contract_type_desc_short,
			contract_type_code,
			amount,
			omb_rate,
			input_future_type_code,
			input_future_type_desc,
			ratio
	from	varBaseEst
	where	contract_budget_item_id in (1,7)
	order by contract_year, contract_budget_item_id
</cfquery>
<cfquery name="rstC1" dbtype="query">
	select	contract_year,
			contract_budget_item_id,
			contract_type_desc_short,
			contract_type_code,
			amount,
			omb_rate,
			input_future_type_code,
			input_future_type_desc,
			ratio
	from	varBaseEst
	where	contract_budget_item_id in (21,23)
	order by contract_year, contract_budget_item_id
</cfquery>
<cfquery name="rstC2" dbtype="query">
	select	contract_year,
			contract_budget_item_id,
			contract_type_desc_short,
			contract_type_code,
			amount,
			omb_rate,
			input_future_type_code,
			input_future_type_desc,
			ratio
	from	varBaseEst
	where	contract_budget_item_id in (11,16)
	order by contract_year, contract_budget_item_id
</cfquery>
<cfquery name="rstS" dbtype="query">
	select	contract_year,
			contract_budget_item_id,
			contract_type_desc_short,
			contract_type_code,
			amount,
			omb_rate,
			input_future_type_code,
			input_future_type_desc,
			ratio
	from	varBaseEst
	where	contract_budget_item_id = 19
	order by contract_year, contract_budget_item_id
</cfquery>

<cfinvoke component="#application.paths.components#aapp_workload" method="getFutureNewWorkloadData" aapp="#url.aapp#" returnvariable="rstWorkload" />
<cfquery name="total_rstBPEC" dbtype="query">
	select	row_desc, sum(amount) as amount
	from	rstBPEC
	group by row_desc
	order by row_sort_order
</cfquery>
<!---Crosstab--->
<cfset crosstab_bpec = application.outility.Crosstab (
qry="#rstBPEC#", col="row_desc", col_sort="row_sort_order", row="contract_type_desc_short", row_sort="con_sort_order", val="amount", corner="Base Period Estimated Costs"
)>

<cfset crosstab = application.outility.Crosstab (
qry="#rstWorkload#", col="workloadtypedesc", col_sort="sortorder", row="contractyear", row_sort="contractyear", val="workloadValue", corner="Workload Levels"
)>
</cfsilent>


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
	<!-- Begin Content Area -->
	<!-- Begin Form Header Info -->
	<div class="formContent">
	<h1>Profile of Future New Regional Job Corps Contract</h1>
	<h2>Report Printed #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#</h2>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
	<tr valign="top">
		<td width="3%">A.</td>
		<td width="25%">Region / AAPP No.</td>
		<td width="25%">#rstFNH.region_desc#</td>
		<td width="47%">#rstFNH.aapp_num#</td>
	</tr>
	<tr valign="top">
		<td>B.</td>
		<td>Program Activity</td>
		<td colspan="2">#rstFNH.program_service#</td>
	</tr>
	<tr valign="top">
		<td>C.</td>
		<td>Procurement:</td>
		<td>Type of Contract:</td>
		<td>#rstFNH.type_of_contract#</td>
	</tr>
	<tr valign="top">
		<td></td>
		<td></td>
		<td>Set-Aside:</td>
		<td>#rstFNH.set_aside#</td>
	</tr>
	<tr valign="top">
		<td>D.</td>
		<td>Performance Period:</td>
		<td>#dateformat(rstFNH.base_year_date_start,"mm/dd/yyyy")# - #dateformat(rstFNH.base_year_date_end,"mm/dd/yyyy")#</td>
		<td>
			#rstFNH.years_option# Option Year<cfif rstFNH.years_option gt 1>s</cfif>
		</td>
	</tr>
	<cfif rstFNH.pred_aapp_num>
	<tr valign="top">
		<td>E.</td>
		<td>Predecessor Contract:</td>
		<td>#rstFNH.contractor_name#</td>
		<td>#rstFNH.contract_num#</td>
	</tr>
	<tr valign="top">
		<td></td>
		<td>End Date / Days in Final Year</td>
		<td>#dateformat(rstFNH.pred_cnt_date_end,"mm/dd/yyyy")#</td>
		<td>#rstFNH.pred_cnt_days# (#rstFNH.full_year_percent#% Full Year)</td>
	</tr>
	<cfelse>
	<tr valign="top">
		<td>E.</td>
		<td>Predecessor Contract:</td>
		<td>none</td>
		<td></td>
	</tr>
	<tr valign="top">
		<td></td>
		<td>End Date / Days in Final Year</td>
		<td></td>
		<td></td>
	</tr>
	</cfif>
	</table>

	<!-- End Form Header Info -->
	<!-- Workload Info -->
	<!---Crosstab Presentation--->
	<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">

	<cfloop index="idx_row" from="1" to="#arraylen(crosstab)#">
		<tr <cfif idx_row mod 2>class="form2AltRow"</cfif>>
		<cfloop index="idx_col" from="1" to="#arraylen(crosstab[idx_row])#">
			<cfif idx_row eq 1>
				<cfif idx_col eq 1>
					<th scope="col" width="3%">F.</th>
					<th scope="col" width="*" nowrap="nowrap">#crosstab[idx_row][idx_col]#</th>
				<cfelse>
					<th scope="col" width="17%" style="text-align:right">#crosstab[idx_row][idx_col]#</th>
				</cfif>
			<cfelse>
				<cfif idx_col eq 1>
					<td></td>
					<td nowrap="nowrap">
						<cfif #crosstab[idx_row][idx_col]#>
							New Contract Year #crosstab[idx_row][idx_col]#
						<cfelse>
							Predecessor 1/
						</cfif>
					</td>
				<cfelse>
					<td align="right">#crosstab[idx_row][idx_col]#</td>
				</cfif>
			</cfif>
		</cfloop>
		</tr>
	</cfloop>
	</table>
	<p></p>
	<!-- Base Period Estimated Costs -->
	<!---Crosstab Presentation--->
	<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
	<cfloop index="idx_row" from="1" to="#arraylen(crosstab_bpec)#">
		<tr <cfif idx_row mod 2>class="form2AltRow"</cfif>>
		<cfloop index="idx_col" from="1" to="#arraylen(crosstab_bpec[idx_row])#">
			<cfif idx_row eq 1>
				<cfif idx_col eq 1>
					<th scope="col" width="3%">G.</th>
					<th scope="col" width="*">#crosstab_bpec[idx_row][idx_col]#</th>
				<cfelse>
					<th scope="col" width="17%" style="text-align:center">#crosstab_bpec[idx_row][idx_col]#</th>
				</cfif>
			<cfelse>
				<cfif idx_col eq 1>
					<td></td>
					<td>#crosstab_bpec[idx_row][idx_col]#</td>
				<cfelse>
					<td align="right">
						<cfif len(crosstab_bpec[idx_row][idx_col])>
							<cfif crosstab_bpec[idx_row][idx_col] lt 0>-</cfif>$#numberformat(abs(crosstab_bpec[idx_row][idx_col]),",")#
						</cfif>
					</td>
				</cfif>
			</cfif>
		</cfloop>
		</tr>
	</cfloop>
		<tr>
			<td colspan="5" class="hrule"></td>
		</tr>
		<tr>
			<td></td>
			<td>Total</td>
			<cfloop query="total_rstBPEC">
			<td align="right">
				<cfif len(amount)>
					<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#
				</cfif>
			</td>
			</cfloop>
		</tr>
	</table>
</cfoutput>
<cfset MyChr=71>


<cfif rstA.recordcount>
<cfquery name="pred" datasource="#request.dsn#">
	select	contract.fun_getpredecessorbaseamount(#rstFNH.pred_aapp_num#,#rstFNH.aapp_num#,'#rstA.contract_type_code#') as amount
	from	dual
</cfquery>
<cfset MyChr=MyChr+1>
	<p></p>
	<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
	<cfoutput>
	<tr>
		<th scope="col" width="3%" valign="top">#Chr(MyChr)#.</th>
		<th scope="col" width="30%" valign="top">
			Yearly #rstA.contract_type_desc_short# $<br />
			<span style="font-weight:normal">Source: #rstA.input_future_type_desc#</span>
		</th>
		<th scope="col" width="17%" valign="bottom" style="text-align:center">Reimbursable</th>
		<th scope="col" width="17%" valign="bottom" style="text-align:center">Base/Avg<br />Incentive Fee</th>
		<th scope="col" width="11%" valign="bottom" style="text-align:center">(%)</th>
		<th scope="col" width="11%" valign="bottom" style="text-align:center">OMB Infl %</th>
	</tr>
	<cfif rstFNH.pred_aapp_num>
	<tr>
		<td></td>
		<td>Predecessor 1/</td>
		<td align="right">
			<cfif len(pred.amount)>
				<cfif pred.amount lt 0>-</cfif>$#numberformat(abs(pred.amount),",")#
			</cfif>
		</td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	</cfif>
	</cfoutput>
	<cfoutput query="rstA" group="contract_year">
	<tr <cfif evaluate(contract_year+1) mod 2>class="form2AltRow"</cfif>>
		<td></td>
		<td>New Contract Year #contract_year#</td>
		<cfoutput>
		<td align="right">
			<cfif len(amount)>
				<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#
			</cfif>
		</td>
		</cfoutput>
		<td align="center">
				#numberformat(ratio*10000/100,".00")#
		</td>
		<td align="center">
			<cfif (input_future_type_code eq "A") or (input_future_type_code eq "I" and contract_year eq 1)>
				N/A
			<cfelse>
				#numberformat((omb_rate-1)*100,".00")#
			</cfif>
		</td>
	</tr>
	</cfoutput>
	</table>
</cfif>




<cfif rstC1.recordcount>
<cfquery name="pred" datasource="#request.dsn#">
	select	contract.fun_getpredecessorbaseamount(#rstFNH.pred_aapp_num#,#rstFNH.aapp_num#,'#rstC1.contract_type_code#') as amount
	from	dual
</cfquery>
<cfset MyChr=MyChr+1>
	<p></p>
	<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
	<cfoutput>
	<tr>
		<th scope="col" width="3%" valign="top">#Chr(MyChr)#.</th>
		<th scope="col" width="30%" valign="top">
			Yearly #rstC1.contract_type_desc_short# $<br />
			<span style="font-weight:normal">Source: #rstC1.input_future_type_desc#</span>
		</th>
		<th scope="col" width="17%" valign="bottom" style="text-align:center">Reimbursable</th>
		<th scope="col" width="17%" valign="bottom" style="text-align:center">Base/Avg<br />Incentive Fee</th>
		<th scope="col" width="11%" valign="bottom" style="text-align:center">(%)</th>
		<th scope="col" width="11%" valign="bottom" style="text-align:center">OMB Infl %</th>
	</tr>
	<cfif rstFNH.pred_aapp_num>
	<tr>
		<td></td>
		<td>Predecessor 1/</td>
		<td align="right">
			<cfif len(pred.amount)>
				<cfif pred.amount lt 0>-</cfif>$#numberformat(abs(pred.amount),",")#
			</cfif>
		</td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	</cfif>
	</cfoutput>
	<cfoutput query="rstC1" group="contract_year">
	<tr <cfif evaluate(contract_year+1) mod 2>class="form2AltRow"</cfif>>
		<td></td>
		<td>New Contract Year #contract_year#</td>
		<cfoutput>
		<td align="right">
			<cfif len(amount)>
				<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#
			</cfif>
		</td>
		</cfoutput>
		<td align="center">
			#numberformat(ratio*10000/100,".00")#
		</td>
		<td align="center">
			<cfif (input_future_type_code eq "A") or (input_future_type_code eq "I" and contract_year eq 1)>
				N/A
			<cfelse>
				#numberformat((omb_rate-1)*100,".00")#
			</cfif>
		</td>
	</tr>
	</cfoutput>
	</table>
</cfif>


<cfif rstC2.recordcount>
<cfquery name="pred" datasource="#request.dsn#">
	select	contract.fun_getpredecessorbaseamount(#rstFNH.pred_aapp_num#,#rstFNH.aapp_num#,'#rstC2.contract_type_code#') as amount
	from	dual
</cfquery>
<cfset MyChr=MyChr+1>
	<p></p>
	<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
	<cfoutput>
	<tr>
		<th scope="col" width="3%" valign="top">#Chr(MyChr)#.</th>
		<th scope="col" width="30%" valign="top">
			Yearly #rstC2.contract_type_desc_short# $<br />
			<span style="font-weight:normal">Source: #rstC2.input_future_type_desc#</span>
		</th>
		<th scope="col" width="17%" valign="bottom" style="text-align:center">Reimbursable</th>
		<th scope="col" width="17%" valign="bottom" style="text-align:center">Base/Avg<br />Incentive Fee</th>
		<th scope="col" width="11%" valign="bottom" style="text-align:center">(%)</th>
		<th scope="col" width="11%" valign="bottom" style="text-align:center">OMB Infl %</th>
	</tr>
	<cfif rstFNH.pred_aapp_num>
	<tr>
		<td></td>
		<td>Predecessor 1/</td>
		<td align="right">
			<cfif len(pred.amount)>
				<cfif pred.amount lt 0>-</cfif>$#numberformat(abs(pred.amount),",")#
			</cfif>
		</td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	</cfif>
	</cfoutput>
	<cfoutput query="rstC2" group="contract_year">
	<tr <cfif evaluate(contract_year+1) mod 2>class="form2AltRow"</cfif>>
		<td></td>
		<td>New Contract Year #contract_year#</td>
		<cfoutput>
		<td align="right">
			<cfif len(amount)>
				<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#
			</cfif>
		</td>
		</cfoutput>
		<td align="center">
			#numberformat(ratio*10000/100,".00")#
		</td>
		<td align="center">
			<cfif (input_future_type_code eq "A") or (input_future_type_code eq "I" and contract_year eq 1)>
				N/A
			<cfelse>
				#numberformat((omb_rate-1)*100,".00")#
			</cfif>
		</td>
	</tr>
	</cfoutput>
	</table>
</cfif>



<cfif rstS.recordcount>
<cfquery name="pred" datasource="#request.dsn#">
	select	contract.fun_getpredecessorbaseamount(#rstFNH.pred_aapp_num#,#rstFNH.aapp_num#,'#rstS.contract_type_code#') as amount
	from	dual
</cfquery>
<cfset MyChr=MyChr+1>
	<p></p>
	<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
	<cfoutput>
	<tr>
		<th scope="col" width="3%" valign="top">#Chr(MyChr)#.</th>
		<th scope="col" width="30%" valign="top">
			Yearly #rstS.contract_type_desc_short# $<br />
			<span style="font-weight:normal">Source: #rstS.input_future_type_desc#</span>
		</th>
		<th scope="col" width="17%" valign="bottom" style="text-align:center">Total</th>
		<th scope="col" width="17%" valign="bottom" style="text-align:center"></th>
		<th scope="col" width="11%" valign="bottom" style="text-align:center"></th>
		<th scope="col" width="11%" valign="bottom" style="text-align:center">OMB Infl %</th>
	</tr>
	<cfif rstFNH.pred_aapp_num>
	<tr>
		<td></td>
		<td>Predecessor 1/</td>
		<td align="right">
			<cfif len(pred.amount)>
				<cfif pred.amount lt 0>-</cfif>$#numberformat(abs(pred.amount),",")#
			</cfif>
		</td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	</cfif>
	</cfoutput>
	<cfoutput query="rstS" group="contract_year">
	<tr <cfif evaluate(contract_year+1) mod 2>class="form2AltRow"</cfif>>
		<td></td>
		<td>New Contract Year #contract_year#</td>
		<cfoutput>
		<td align="right">
			<cfif len(amount)>
				<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#
			</cfif>
		</td>
		</cfoutput>
		<td></td>
		<td></td>
		<td align="center">
			<cfif (input_future_type_code eq "A") or (input_future_type_code eq "I" and contract_year eq 1)>
				N/A
			<cfelse>
				#numberformat((omb_rate-1)*100,".00")#
			</cfif>
		</td>
	</tr>
	</cfoutput>
	</table>
</cfif>
	<p>
	<cfoutput>
	<cfif rstFNH.pred_aapp_num>
	1/ Final contract year of predecessor contract, having #rstFNH.pred_cnt_days# days.
	</cfif>
	</cfoutput>
	</p>
	</div>
	<!-- End Content Area -->
</body>
</html>

