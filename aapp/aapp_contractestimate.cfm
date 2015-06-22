<cfsilent>
<!---
page: aapp_contractestimate.cfm

description: display / update data for new contract estimate

revisions:
2006-12-19	yjeng	Add the display logic to this page
2007-01-17	yjeng	Do not display amount if it is 0
2007-03-23	yjeng	Add button to Future New Report

--->
<cfset request.pageID = "220" />
<cfparam name="variables.lstErrorMessages" default="" />
	<!--- retrieve data from database --->
	<cfinvoke component="#application.paths.components#aapp_budget" method="getContractEstimate" aapp="#request.aapp#" returnvariable="rstNewContractEstimate" />
	<cfquery name="dates" dbtype="query">
		select	distinct contract_year, date_start, date_end
		from	rstNewContractEstimate
	</cfquery>
	<cfquery name="infaltedTotal" dbtype="query">
		select	contract_year, years_base, inflated, contract_budget_item_id, amount, display, type_desc_code
		from	rstNewContractEstimate
		where	budget_item_desc = 'Total Inflated'
		order by bud_sort_order, contract_year
	</cfquery>
	<cfinvoke component="#application.paths.components#aapp_budget" method="getContractInput" aapp="#request.aapp#" returnvariable="rstNewContractInput" />
	<cfquery name="Total" dbtype="query">
		select	contract_year, contract_budget_item_id, amount
		from	rstNewContractInput
		where	contract_budget_item_id in (5,9,17,19)
		order by bud_sort_order, contract_year
	</cfquery>
	<cfscript>
		diffQry=querynew("");
		QueryAddColumn(diffQry,"contract_year",listtoarray(valuelist(infaltedTotal.contract_year)));
		QueryAddColumn(diffQry,"years_base",listtoarray(valuelist(infaltedTotal.years_base)));
		QueryAddColumn(diffQry,"inflated",listtoarray(valuelist(infaltedTotal.inflated)));
		QueryAddColumn(diffQry,"d_contract_budget_item_id",listtoarray(valuelist(infaltedTotal.contract_budget_item_id)));
		QueryAddColumn(diffQry,"itamount",listtoarray(valuelist(infaltedTotal.amount)));
		QueryAddColumn(diffQry,"tamount",listtoarray(valuelist(Total.amount)));
		QueryAddColumn(diffQry,"display",listtoarray(valuelist(infaltedTotal.display)));
		QueryAddColumn(diffQry,"type_desc_code",listtoarray(valuelist(infaltedTotal.type_desc_code)));
	</cfscript>
	<cfquery name="ifaward" dbtype="query">
		select	type_desc_code
		from	rstNewContractEstimate
		where	type_desc_code=2
	</cfquery>
</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">
			
<div class="ctrSubContent">
<cfoutput>
<h2>New Contract Estimates</h2>
<cfif not ifaward.recordcount>
<form name="frmReportCriteria" action="#application.paths.reportdir#reports.cfm?rpt_id=19&aapp=#request.aapp#" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
	<input name="radReportFormat" type="hidden" value="application/pdf" />
	<input name="aapp" type="hidden" value="#request.aapp#" />
	<div class="btnRight">
	<input name="action" type="submit" value="Future New Report" />
	</div>
</form>
</cfif>
</cfoutput>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTblCol">
	<tr>
		<th scope="col">&nbsp;</th>
		<cfoutput query="dates">
		<th scope="col"><strong>Year #contract_year#</strong><br/>#date_start#-<br/>#date_end#</th>
		</cfoutput>
	</tr>
	<cfoutput query="rstNewContractEstimate" group="con_sort_order">
	<tr>
		<td scope="row"><strong>#contract_type_desc_short#</strong></td>
		<td colspan="#dates.recordcount#" style="text-align:center">(#type_desc#)</td>
	</tr>
	<cfoutput group="bud_sort_order">
	<tr <cfif budget_item_desc eq "total inflated">style="font-weight:bold"<cfset showDiff="true"><cfelse><cfset showDiff="false"></cfif>>
		<td scope="row">#budget_item_desc#</td>
		<cfoutput group="contract_year">
		<td <cfif contract_year mod 2 eq 0> class="AltCol"</cfif>>
			<cfif display and amount neq 0>
				<cfif amount lt 0>-</cfif>
				$#numberformat(abs(amount),",")#
			</cfif>
		</td>
		<cfset lastrow=currentrow>
		</cfoutput>
	</tr>
	<cfif showDiff>
	<tr>
		<td scope="row">Difference from award</td>
		<cfquery name="loopDiff" dbtype="query">
			select	contract_year, years_base, inflated, ITAmount-TAmount as diffAmount, display, type_desc_code
			from	diffQry
			where	d_contract_budget_item_id=#contract_budget_item_id#
		</cfquery>
		<cfloop query="loopDiff">
		<td <cfif contract_year mod 2 eq 0> class="AltCol"</cfif>>	
			<cfif display and type_desc_code eq 2 and diffAmount neq 0>
				<cfif diffAmount lt 0>-</cfif>
				$#numberformat(abs(diffAmount),",")#
			</cfif>
		</td>	
		</cfloop>
	</tr>
	</cfif>
	</cfoutput>
	<cfif lastrow neq rstNewContractEstimate.recordcount>
	<tr>
		<td colspan="8" class="hrule"></td>
	</tr>
	</cfif>
	</cfoutput>
</table>
</div>

<!--- if validation errors exist, display them --->





<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">