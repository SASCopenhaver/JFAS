<cfsilent>
<!---
page: aapp_ecp_detail.cfm

description: display data for Estimate Cost Profile by Cost Categories

revisions:
2007-01-12	yjeng	Modify sort by function under getEstCostProfileSort, case non sensitive
2007-01-18	yjeng	Do not display amount if it is 0
2007-01-25	yjeng	Do not display the row  if amount is 0 and mod not require
2007-08-14	mstein	Changed business rules so that "Per Current Mod" amount and max mod number
					are not restricted to current contrat year or earlier
2007-10-17	rroser	change mod number sorting to treat mod numbers as numeric rather than text string
2012-03-03	mstein	Adjusted formatting of ECP amount to prevent wrapping with negative sign
--->
<cfset request.pageID = "620" />
<cfparam name="url.sortDir" default="asc">
<cfparam name="url.sortBy" default="contract_year">
<!---Post Section--->

<!---Query Section--->
<!--- retrieve data from database --->
<cfinvoke component="#application.paths.components#page" method="getSecondLevelTabsDyn" sectionID="600" returnvariable="rstSecondLevelTabs">
<cfquery name="TabInfoCode" dbtype="query">
	select	sectionName, contract_type_code
	from	rstSecondLevelTabs
	where	sectionID > 0
</cfquery>
<cfparam name="url.ContractTypeCode" default="#TabInfoCode.contract_type_code#">
<cfinvoke component="#application.paths.components#aapp_costprofile" 
		  method="getEstCostProfileSort" 
          aapp="#request.aapp#" 
          sortBy="#url.sortBy#" 
          sortDir="#url.sortDir#" 
          contract_type_code="#url.ContractTypeCode#" 
          returnvariable="rstEstCostProfileSort" />
<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileTotal" aapp="#request.aapp#" contract_type_code="#url.ContractTypeCode#" returnvariable="rstEstCostProfileTotal" />

<cfquery name="TabInfoName" dbtype="query">
	select	sectionName, contract_type_code
	from	rstSecondLevelTabs
	where	contract_type_code='#url.ContractTypeCode#'
</cfquery>

<cfinvoke component="#application.paths.components#aapp" method="getAAPPCurrentContractYear" aapp="#request.aapp#" returnvariable="cy" />

<cfquery name="qryWorkloadData" datasource="#request.dsn#">
	select	a.contract_year, a.value, b.workload_type_code, b.workload_type_desc, b.sort_order
	from	aapp_workload a, lu_workload_type b
	where	a.aapp_num=#request.aapp#
	and		b.contract_type_code='#url.ContractTypeCode#'
	and		a.workload_type_code=b.workload_type_code
	order by a.contract_year, b.sort_order
</cfquery>
<cfquery name="qryWorkloadTitle" dbtype="query">
	select	distinct workload_type_code, workload_type_desc 
	from	qryWorkloadData
	order by sort_order
</cfquery>

</cfsilent>

<!---Display Section--->
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">
<div class="ctrSubContent">
<h2>Estimated Cost Profile</h2>
<cfoutput>
<form name="frmReportCriteria" action="#application.paths.reportdir#reports.cfm?rpt_id=2" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
<input type="hidden" name="AAPP" value="#request.aapp#"/>
<input type="hidden" name="chkCostCat" value="#rstEstCostProfileSort.contract_type_code#" />
<input type="hidden" name="radReportFormat" value="application/pdf" />
<div class="btnRight">
<input name="btnGenerateReport" type="submit" value="Print" />
</div>
</form>
</cfoutput>
<cfoutput>
<h3>#TabInfoName.sectionName#</h3>
</cfoutput>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
	<tr>
		<cfoutput>
		<th scope="col" style="text-align: center"><a href="#cgi.script_name#?aapp=#request.aapp#&ContractTypeCode=#url.ContractTypeCode#&sortBy=modnum<cfif url.sortBy eq "modnum">&sortDir=<cfif url.sortDir eq "asc">desc<cfelse>asc</cfif></cfif>">Mod ## </a></th>
		<th scope="col"><a href="#cgi.script_name#?aapp=#request.aapp#&ContractTypeCode=#url.ContractTypeCode#&sortBy=contract_type_code<cfif url.sortBy eq "contract_type_code">&sortDir=<cfif url.sortDir eq "asc">desc<cfelse>asc</cfif></cfif>">Cost Category</a></th>
		<th scope="col"><a href="#cgi.script_name#?aapp=#request.aapp#&ContractTypeCode=#url.ContractTypeCode#&sortBy=u_desc<cfif url.sortBy eq "u_desc">&sortDir=<cfif url.sortDir eq "asc">desc<cfelse>asc</cfif></cfif>">Description</a></th>
		<th scope="col"><a href="#cgi.script_name#?aapp=#request.aapp#&ContractTypeCode=#url.ContractTypeCode#&sortBy=ongoing<cfif url.sortBy eq "ongoing">&sortDir=<cfif url.sortDir eq "asc">desc<cfelse>asc</cfif></cfif>">Ongoing?</a></th>
		<th scope="col" style="text-align: right"><a href="#cgi.script_name#?aapp=#request.aapp#&ContractTypeCode=#url.ContractTypeCode#&sortBy=contract_year<cfif url.sortBy eq "contract_year">&sortDir=<cfif url.sortDir eq "asc">desc<cfelse>asc</cfif></cfif>">Contract year</a></th>
		<th scope="col" style="text-align: right"><a href="#cgi.script_name#?aapp=#request.aapp#&ContractTypeCode=#url.ContractTypeCode#&sortBy=amount<cfif url.sortBy eq "amount">&sortDir=<cfif url.sortDir eq "asc">desc<cfelse>asc</cfif></cfif>">Amount</a></th>
		<th scope="col"><a href="#cgi.script_name#?aapp=#request.aapp#&ContractTypeCode=#url.ContractTypeCode#&sortBy=status<cfif url.sortBy eq "status">&sortDir=<cfif url.sortDir eq "asc">desc<cfelse>asc</cfif></cfif>">Status</a></th>
		</cfoutput>
	</tr>
	<cfset amountExec=0>
	<cfset currMod="0">
	<cfset therow=0>
    
    <!--- SAS TEST starts--->
   <!---<cfdump var="#rstEstCostProfileSort#"><cfabort>--->
    <!--- SAS test ends--->
    
	<cfoutput query="rstEstCostProfileSort" group="#url.sortBy#">
		<cfif currentrow neq 1 and url.sortBy neq "amount">
		<tr>
			<td colspan="7" class="hrule"></td>
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
                        <tr<cfif therow mod 2> class="AltRow"</cfif>>
                            <td align="center">#mod_num#</td>
                            <td>#contract_type_code#</td>
                            <td>#description#</td>
                            <td>#ongoing#</td>
                            <td align="center">#contract_year#</td>
                            <td align="right" nowrap>#numberformat(amount,"$9,999")#</td>
                            <td>#status#</td>
                        </tr>
                </cfif>
		</cfoutput>
	</cfoutput>
</table>
<p></p>
<cfoutput>
<h3>#TabInfoName.sectionName# Totals</h3>
</cfoutput>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
	<tr>
		<th scope="col">Contract Year</th>
		<th scope="col">Start</th>
		<th scope="col">End</th>
		<cfoutput query="qryWorkloadTitle">
		<th style="text-align: center">#workload_type_desc#</th>
		</cfoutput>
		<th style="text-align: right">Year's Funds</th>
		<th style="text-align: right">Cumulative</th>
	</tr>
	<cfset mycol="contract_year">
	<cfoutput query="rstEstCostProfileTotal">
	<cfset theYear=contract_year>
	<tr<cfif currentrow mod 2> class="AltRow"</cfif> <cfif contract_year eq cy> style="font-weight:bold"</cfif>>
		<td>Year #evaluate(mycol)#:</td>
		<td>#date_start#</td>
		<td>#date_end#</td>
		<cfloop query="qryWorkloadData">
			<cfif theYear eq contract_year>
				<td align="center">#numberformat(value,",")#</td>
			</cfif>
		</cfloop>
		<td align="right">
			<cfif funds lt 0>-</cfif>
			$#numberformat(abs(funds),",")#
		</td>
		<td align="right">
			<cfif cumValue lt 0>-</cfif>
			$#numberformat(abs(cumValue),",")#
		</td>
	</tr>
	</cfoutput>
	<cfoutput>
	<tr style="font-weight:bold">
		<td><cfif cy neq 999>Current Year: #cy#</cfif></td>
		<td></td>
		<td></td>
		<cfloop query="qryWorkloadTitle">
		<td></td>
		</cfloop>
		<td align="right">Per current mod (###currMod#):</td>
		<td align="right">
			<cfif amountExec lt 0>-</cfif>
			$#numberformat(abs(amountExec),",")#
		</td>
	</tr>
	</cfoutput>
</table>	
</div>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">