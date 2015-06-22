
<!---
page: aapp_summary.cfc

description: component that handles functiosn for aapp_summary page

revisions:
22011-12-02	mstein	page created
--->

<cfcomponent displayname="AAPP Summary" hint="Component that handles functiosn for aapp_summary page">
	
	<cffunction name="getAAPPOverview" hint="get general info about AAPP for AAPP Summary page" returntype="struct" access="public">
		<cfargument name="aapp" type="numeric" required="yes">
		
		<!--- Notes:
		
		"~dnd~" is an indicator for "do not display" - a cue to the calling page that the field does not apply
		
		--->
		
		<cfset stcAAPPSummary = structNew()>
		
		<!--- get general AAPP info --->
		<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#arguments.aapp#" returnvariable="rstAAPPGeneral">
		<cfset bolContractGrant = iif(rstAAPPGeneral.agreementTypeCode eq "DC" or rstAAPPGeneral.agreementTypeCode eq "GR",1,0)>
		<!--- structure that is populated/returned:
		AAPPnumber
		StatusDesc
		AgreementTypeDesc
		ProgramActivity
		Latest2110ReportDate
		ECPthroughCY
		FOPthroughPY
		FundingThroughMod
		currentContractYear
		rstScheduleWorkload (query)
			ContractYear
			CYDateStart
			CYDateEnd
			CYnumDays
			CYslots
			CYarrivals
			CYgrads
			CYEnrollees
			CYtype
		rstContractFunding
		rstFOPAmounts
		rstECPSummary (query)
		stcModFunding
		rstRecentActivity (query)
			RAdate
			RAdesc
			RAuser
		--->	
		
		<cfset stcAAPPSummary.aappNum = arguments.aapp>
		<cfset stcAAPPSummary.currentContractYear = rstAAPPGeneral.curContractYear>
		<cfset stcAAPPSummary.yearsBase = rstAAPPGeneral.yearsBase>
		<cfset stcAAPPSummary.agreementTypeDesc = rstAAPPGeneral.agreementTypeDesc>
		<cfset stcAAPPSummary.programActivity = rstAAPPGeneral.programActivity>
		
		<!--- Status: for active contracts and grants, display "Future, Awarded, Inactive"... for all others, just Active/Inactive --->
		<cfif rstAAPPGeneral.contractStatusID eq 0 or (not bolContractGrant)>
			<!--- inactive, or non-contracts --->
			<cfset stcAAPPSummary.statusDesc = rstAAPPGeneral.contractStatusDesc>
		<cfelse>
			
			<cfif rstAAPPGeneral.budgetInputType eq "A">
				<!--- active contracts, either awarded, or expired (can be both active and expired at the same time) --->
				<cfif datecompare(rstAAPPGeneral.dateEnd,now(),"d") lt 0>
					<cfset stcAAPPSummary.statusDesc = "Expired">
				<cfelse>
					<cfset stcAAPPSummary.statusDesc = "Awarded">
				</cfif>  
			<cfelse>
				<cfset stcAAPPSummary.statusDesc = "Future">
			</cfif>
		</cfif>
		
		<!--- get latest 2110 report date --->
		<cfif bolContractGrant>
			<cfquery name="qryLatest2110Date" datasource="#request.dsn#">
			select	max(rep_date) as last2110
			from	center_2110_data
			where	aapp_num = #arguments.aapp#
			</cfquery>
			<cfif qryLatest2110Date.last2110 neq "">
				<cfset stcAAPPSummary.Latest2110ReportDate = qryLatest2110Date.last2110>
			<cfelse>
				<cfset stcAAPPSummary.Latest2110ReportDate = "(no reports found)">
			</cfif>
		</cfif>
		
		<!--- Contract year / Workload info (contracts/grants only)  --->
		<cfif bolContractGrant>
			<cfinvoke component="#application.paths.components#aapp_workload" method="getWorkloadData" aapp="#arguments.aapp#" returnvariable="rstAAPPWorkload" />
			<cfset rstScheduleWorkload = QueryNew("ContractYear,CYDateStart,CYDateEnd,CYnumDays,CYslots,CYarrivals,CYgrads,CYEnrollees,CYtype",
													"Integer,Date,Date,Integer,Integer,Integer,Integer,Integer,VarChar")>
			<cfset tempYear = 0>
			<cfloop query="rstAAPPWorkload">
				<cfif contractYear neq tempYear>
					<!---
					ContractYear
					CYDateStart
					CYDateEnd
					CYnumDays
					CYslots
					CYarrivals
					CYgrads
					CYEnrollees
					CYtype
					--->
					<cfset temp = QueryAddRow(rstScheduleWorkload)>
					<cfset Temp = QuerySetCell(rstScheduleWorkload, "ContractYear", contractYear)>
					<cfset Temp = QuerySetCell(rstScheduleWorkload, "CYDateStart", yearStartDate)>
					<cfset Temp = QuerySetCell(rstScheduleWorkload, "CYDateEnd", yearEndDate)>
					<cfset Temp = QuerySetCell(rstScheduleWorkload, "CYnumDays", cyDays)>
					<cfif contractYear lte stcAAPPSummary.yearsBase>
						<cfset Temp = QuerySetCell(rstScheduleWorkload, "CYtype", "(base)")>
					<cfelseif cyDays lt 365>
						<cfset Temp = QuerySetCell(rstScheduleWorkload, "CYtype", "*partial")>
					</cfif>
				</cfif>
				<cfif workloadTypeCode eq "SL"><cfset Temp = QuerySetCell(rstScheduleWorkload, "CYslots", workloadValue)></cfif>
				<cfif workloadTypeCode eq "GR"><cfset Temp = QuerySetCell(rstScheduleWorkload, "CYgrads", workloadValue)></cfif>
				<cfif workloadTypeCode eq "AR"><cfset Temp = QuerySetCell(rstScheduleWorkload, "CYarrivals", workloadValue)></cfif>
				<cfif workloadTypeCode eq "FE"><cfset Temp = QuerySetCell(rstScheduleWorkload, "CYEnrollees", workloadValue)></cfif>				
				<cfset tempYear = contractYear>
			</cfloop>
			<cfset stcAAPPSummary.rstScheduleWorkload = rstScheduleWorkload>					
		<cfelseif rstAAPPGeneral.agreementTypeCode eq "CC">
			<!--- CCCs just show workload levels (single row, no contract years) --->
			<cfinvoke component="#application.paths.components#aapp_workload" method="getWorkloadData_CCC" aapp="#arguments.aapp#" returnvariable="rstAAPPWorkloadCCC">
			<cfset rstScheduleWorkload = QueryNew("CYslots,CYarrivals,CYgrads,CYEnrollees","Integer,Integer,Integer,Integer")>
			<cfset temp = QueryAddRow(rstScheduleWorkload)>
			<cfloop query="rstAAPPWorkloadCCC">
				<cfif workloadTypeCode eq "SL"><cfset Temp = QuerySetCell(rstScheduleWorkload, "CYslots", value)></cfif>
				<cfif workloadTypeCode eq "GR"><cfset Temp = QuerySetCell(rstScheduleWorkload, "CYgrads", value)></cfif>
				<cfif workloadTypeCode eq "AR"><cfset Temp = QuerySetCell(rstScheduleWorkload, "CYarrivals", value)></cfif>
				<cfif workloadTypeCode eq "FE"><cfset Temp = QuerySetCell(rstScheduleWorkload, "CYEnrollees", value)></cfif>
			</cfloop>
			<cfset stcAAPPSummary.rstScheduleWorkload = rstScheduleWorkload>
		</cfif>
		
		<!--- ECP / FOP / Mod Totals (one query to handle all - columns depend on contract type/status)--->			
		<!--- Cumulative FOP Totals (for all AAPPs) --->
		<cfinvoke component="#application.paths.components#aapp_adjustment" method="getCumulativeFOPAmounts" aapp="#arguments.aapp#" rollupCCC="1" returnvariable="rstFOPAmounts">
		<cfset stcAAPPSummary.rstContractFunding = rstFOPAmounts>		
		
		<!--- ECP Information (for awarded contracts/grants only) --->
		<cfif bolContractGrant and rstAAPPGeneral.budgetInputType eq "A">
			<!--- get cumulative ECP amounts per cost cat --->
			<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileSummary" aapp="#arguments.aapp#" returnvariable="rstECPSummary">
			<cfif rstECPSummary.recordCount>
				<!--- if ECP results found, create a new blank column in the existing funding dataset for this --->
				<cfset temp = QueryAddColumn(stcAAPPSummary.rstContractFunding,"ECPAmount","Integer", ArrayNew(1))>
				<!--- loop through existing Funding query, and populate with appropriate value from ECP query --->
				<cfloop query="stcAAPPSummary.rstContractFunding">
					<!--- get associated values from ECP query --->
					<cfquery name="temp" dbtype="query">
					select cumulative from rstECPSummary where contract_type_code = '#costCatCode#'
					</cfquery>
					<cfset temp = QuerySetCell(stcAAPPSummary.rstContractFunding,"ECPAmount",temp.cumulative,#currentRow#)>
				</cfloop>
			</cfif>
		</cfif>
		
		<!--- Mod Funding Totals (for awarded contracts/grants only) --->
		<cfif bolContractGrant and rstAAPPGeneral.budgetInputType eq "A">
			<!--- get Mod Funding Data (amounts from latest mod) --->
			<cfinvoke component="#application.paths.components#aapp_mod" method="getLatestModbyAAPP" aapp="#arguments.aapp#" returnvariable="stcModFunding">
			
				<!--- if Mod Funsing records found results found, create new blank columns in the existing funding dataset for this --->
				<cfset temp = QueryAddColumn(stcAAPPSummary.rstContractFunding,"ModFundingAmount","Integer", ArrayNew(1))>
				<cfset temp = QueryAddColumn(stcAAPPSummary.rstContractFunding,"ModNumber","Integer", ArrayNew(1))>
				<!--- loop through existing Funding query, and populate with appropriate value from ECP query --->
				<cfloop query="stcAAPPSummary.rstContractFunding">
					<!--- get associated values from ECP query --->
					<cfif stcModFunding.results>
						<cfquery name="temp" dbtype="query">
						select fundingTotal from stcModFunding.ModFundingData where costCatID = #costCatID#
						</cfquery>
						<cfset tempModVal = temp.fundingTotal>
						<cfset tempModNum = stcModFunding.ModData.modNum>
					<cfelse>
						<cfset tempModVal = 0>
						<cfset tempModNum = 0>
					</cfif>
					<cfset temp = QuerySetCell(stcAAPPSummary.rstContractFunding,"ModFundingAmount",tempModVal,#currentRow#)>
					<cfset temp = QuerySetCell(stcAAPPSummary.rstContractFunding,"ModNumber",tempModNum,#currentRow#)>
				</cfloop>
			
			
		</cfif>	
		
		<!--- contract obligation, FOP, and allocation amounts (for awarded contracts/grants only) --->
		<cfif bolContractGrant and rstAAPPGeneral.budgetInputType eq "A">
		
			<cfquery name="qryGetOblig_FOP_Allocation" datasource="#request.dsn#">
			select
			(select nvl(sum(oblig),0)
			 from footprint_ncfms
			 where	aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#"> and
			 		fund_cat ='OPS' and
					approp_py = #request.py#) as ops_oblig,
			(select nvl(sum(oblig),0)
			 from footprint_ncfms
			 where	aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#"> and
			 		fund_cat ='CRA' and
			 		approp_py = #request.py#) as cra_oblig,
			(select nvl(sum(amount),0)
			 from fop, lu_cost_cat lcc
			 where	fop.cost_cat_id = lcc.cost_cat_id and
			 		aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#"> and
					fund_cat ='OPS' and
					py = #request.py#) as ops_fop,
			(select nvl(sum(amount),0)
			 from fop, lu_cost_cat lcc
			 where	fop.cost_cat_id = lcc.cost_cat_id and
			 		aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#"> and
					fund_cat ='CRA' and
					py = #request.py#) as cra_fop,
			(select nvl(sum(amount),0)
			 from aapp_py_allocation
			 where	aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#"> and
			 		fund_cat ='OPS' and
					py = #request.py#) as ops_allocat,
			(select nvl(sum(amount),0)
			 from aapp_py_allocation
			 where	aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#"> and
			 		fund_cat ='CRA' and
					py = #request.py#) as cra_allocat,
					0 as ops_oblig_fop_diff,
					0 as cra_oblig_fop_diff,
					0 as ops_oblig_fop_percent,
					0 as cra_oblig_fop_percent					
			from dual
			</cfquery>
			
			<cfset temp = QuerySetCell(qryGetOblig_FOP_Allocation,"ops_oblig_fop_diff",qryGetOblig_FOP_Allocation.ops_fop - qryGetOblig_FOP_Allocation.ops_oblig)>
			<cfset temp = QuerySetCell(qryGetOblig_FOP_Allocation,"cra_oblig_fop_diff",qryGetOblig_FOP_Allocation.cra_fop - qryGetOblig_FOP_Allocation.cra_oblig)>
			<cfif qryGetOblig_FOP_Allocation.ops_fop neq 0>
				<cfset temp = QuerySetCell(qryGetOblig_FOP_Allocation,"ops_oblig_fop_percent",(qryGetOblig_FOP_Allocation.ops_oblig/qryGetOblig_FOP_Allocation.ops_fop)*100)>
			<cfelse>
				<cfset temp = QuerySetCell(qryGetOblig_FOP_Allocation,"ops_oblig_fop_percent",0)>
			</cfif><cfif qryGetOblig_FOP_Allocation.cra_fop neq 0>
				<cfset temp = QuerySetCell(qryGetOblig_FOP_Allocation,"cra_oblig_fop_percent",(qryGetOblig_FOP_Allocation.cra_oblig/qryGetOblig_FOP_Allocation.cra_fop)*100)>
			<cfelse>
				<cfset temp = QuerySetCell(qryGetOblig_FOP_Allocation,"cra_oblig_fop_percent",0)>
			</cfif>
			<cfset stcAAPPSummary.rstReconciliation = qryGetOblig_FOP_Allocation>
		</cfif>
				
		
		<cfreturn stcAAPPSummary>
	</cffunction>
	
	
	
</cfcomponent>