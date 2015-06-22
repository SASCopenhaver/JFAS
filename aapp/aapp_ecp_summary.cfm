<cfsilent>
<!---
page: aapp_ecp_summary.cfm

description: display data for Estimate Cost Profile by Summary

revisions:

--->
<cfset request.pageID = "610" />
<!---Post Section--->

<!---Query Section--->
<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileSummary" aapp="#request.aapp#" returnvariable="rstEstCostProfileSummary" />
</cfsilent>

<!---Display Section--->
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">
<div class="ctrSubContent">
<h2>Estimated Cost Profile</h2>
<cfoutput>
<form name="frmReportCriteria" action="#application.paths.reportdir#reports.cfm?rpt_id=2" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
<input type="hidden" name="AAPP" value="#request.aapp#"/>
<input type="hidden" name="chkCostCat" value="#valuelist(rstEstCostProfileSummary.contract_type_code)#" />
<input type="hidden" name="radReportFormat" value="application/pdf" />
<div class="btnRight">
<input name="btnGenerateReport" type="submit" value="Print ECP Report" />
</div>
</form>
</cfoutput>
<h3>Summary</h3>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
	  <tr>
		<th scope="col">Cost Category </th>
		<cfif rstEstCostProfileSummary.contract_year neq 999>
		<th style="text-align: center">Current contract year </th>
		</cfif>
		<th style="text-align: right">Cumulative</th>
		<th style="text-align: right">Per current mod</th>
		<th style="text-align: center">Mod # </th>
	  </tr>
	  <cfoutput query="rstEstCostProfileSummary">
	  <tr<cfif currentrow mod 2> class="AltRow"</cfif>>
		<td scope="row"><a href="aapp_ecp_detail.cfm?aapp=#request.aapp#&ContractTypeCode=#contract_type_code#">#cost_cat#</a></td>
		<cfif contract_year neq 999>
		<td align="center">#contract_year#</td>
		</cfif>
		<td align="right">$#numberformat(cumulative,",")#</td>
		<td align="right">$#numberformat(per_current_mod,",")#</td>
		<td align="center">#mod_num#</td>
	  </tr>
	  </cfoutput>
</table>
</div>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">