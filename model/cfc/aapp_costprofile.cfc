<!---
page: aapp_costprofile.cfc

description: component that handles all adjustment/cost profile

revisions:
2007-01-12	yjeng	Modify sort by function under getEstCostProfileSort, case non sensitive
2012-03-05	mstein	Added getFeeTotalbyAAPP to retrieve Fee amounts
--->

<cfcomponent displayname="aapp_costprofile" hint="Component that contains all general cost profile queries and functions">

	<cffunction name="getEstCostProfileGen" access="public" returntype="query" hint="Get data for Estimate Cost Profile Screen">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfargument name="contract_type_code" type="string" required="no" default="">
		<cfargument name="adjustment_id" type="numeric" required="no" default="0">
		<cfargument name="contract_year" type="numeric" required="no" default="0">
		<cfstoredproc procedure="contract.prc_getestcostprofile" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocparam cfsqltype="cf_sql_char" dbvarname="p_contract_type_code" value="#arguments.contract_type_code#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_adjustment_id" value="#arguments.adjustment_id#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_contract_year" value="#arguments.contract_year#">
			<cfprocresult name="qryEstProGen">
		</cfstoredproc>
		<cfreturn qryEstProGen>
	</cffunction>
    
	<cffunction name="getEstCostProfileSort" access="public" returntype="query" hint="Get data for Estimate Cost Profile Screen with sort by">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfargument name="contract_type_code" type="string" required="no" default="">
		<cfargument name="adjustment_id" type="numeric" required="no" default="0">
		<cfargument name="sortby" type="string" required="no" default="contract_year">
		<cfargument name="sortDir" type="string" required="no" default="asc">
		<cfargument name="contract_year" type="numeric" required="no" default="0">
		<cfset var varEstProSort=this.getEstCostProfileGen(#arguments.aapp#,'#arguments.contract_type_code#',#arguments.adjustment_id#)>
        
        <!---SAS Test: --->
		<!---<cfdump var="#varEstProSort#"><cfabort>--->
        
		<cfquery name="qryEstProSort" dbtype="query">
			<!---Original code; "*" is replaced by the list of columns: select *, upper(description) as u_desc --->
            select	adjustment_id, mod_num, contract_type_code,modNum, description, ongoing, ctype_desc_short, contract_year, date_start,
					date_end, amount, status, fixed, adjustment_type_code, by_year_order, omb_rate, base_year, upper(description) as u_desc
			from	varEstProSort
			<cfif arguments.contract_year gt 0>
			where	contract_year <= #arguments.contract_year#
			</cfif>
			<cfif arguments.sortby neq "contract_year">
			order by #arguments.sortby# #arguments.sortDir#, contract_year asc, contract_type_code asc, by_year_order asc
			<cfelse>
			order by #arguments.sortby# #arguments.sortDir#, contract_type_code asc, by_year_order asc
			</cfif>
		</cfquery>
		<cfreturn qryEstProSort>
	</cffunction>
	<cffunction name="getEstCostProfileTotal" access="public" returntype="query" hint="Get data for Estimate Cost Profile Screen Total">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfargument name="contract_type_code" type="string" required="no" default="">
		<cfargument name="sortby" type="string" required="no" default="contract_year">
		<cfargument name="sortDir" type="string" required="no" default="asc">
		<cfargument name="contract_year" type="numeric" required="no" default="0">
		<cfset var varEstProSort=this.getEstCostProfileGen(#arguments.aapp#,'#arguments.contract_type_code#')>
		<cfset var varCumulativeArray=ArrayNew(1)>
		<cfset var varFund=0>
		<cfset var varCount=0>
		<cfquery name="qryTotal" dbtype="query">
			select	contract_year, date_start, date_end, contract_type_code, ctype_desc_short, sum(amount) as funds
			from	varEstProSort
			<cfif arguments.contract_year neq 0>
			where	contract_year=#arguments.contract_year#
			</cfif>
			group by contract_year, date_start, date_end, contract_type_code, ctype_desc_short
			order by contract_type_code, contract_year
		</cfquery>
		
		<cfloop query="qryTotal">
			<cfset varCount=varCount+1>
			<cfset varFund=varFund+funds>
			<cfset varCumulativeArray[varCount]=varFund>
		</cfloop>
		<cfset n=QueryAddColumn(qryTotal,"cumValue",varCumulativeArray)>
		<cfreturn qryTotal>
	</cffunction>	
	<cffunction name="getEstCostProfileTotalbyCategory" access="public" returntype="query" hint="Get data for Estimate Cost Profile Screen Total">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfargument name="contract_type_code" type="string" required="no" default="">
		<cfargument name="contract_year" type="numeric" required="no" default="0">
		<cfset var varEstProSort=this.getEstCostProfileGen(#arguments.aapp#,'#arguments.contract_type_code#')>
		<cfquery name="qryTotal" dbtype="query">
			select	contract_type_code, ctype_desc_short, sum(amount) as cumValue
			from	varEstProSort
			<cfif arguments.contract_year neq 0>
			where	contract_year<=#arguments.contract_year#
			</cfif>
			group by contract_type_code, ctype_desc_short
			order by contract_type_code
		</cfquery>
		<cfquery name="qryConYear" dbtype="query">
			select	contract_type_code, ctype_desc_short, sum(amount) as funds
			from	varEstProSort
			<cfif arguments.contract_year neq 0>
			where	contract_year=#arguments.contract_year#
			</cfif>
			group by contract_type_code, ctype_desc_short
			order by contract_type_code
		</cfquery>
		<cfset n=QueryAddColumn(qryTotal,"funds",listtoarray(valuelist(qryConYear.funds)))>
		<cfreturn qryTotal>
	</cffunction>	
	<cffunction name="getEstCostProfileSummary" access="public" returntype="query" hint="Get data for Estimate Cost Profile Summary Screen">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfstoredproc procedure="contract.prc_getestcostprofilesummary" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocresult name="qryEstProSumary">
		</cfstoredproc>
		<cfreturn qryEstProSumary>
	</cffunction>
	<cffunction name="getEstCostProfileWorkload" access="public" returntype="query" hint="Get data for Estimate Cost Profile Workload">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfargument name="contract_type_code" type="string" required="yes" default="">
		<cfargument name="NewCols" type="string" required="yes" default="">
		<cfargument name="qTotal" type="query" required="yes" default="">
		<cfloop index="idx" list="#arguments.NewCols#">
			<cfquery name="qryWorkloadData" datasource="#request.dsn#">
				select	a.contract_year, a.value, b.workload_type_code, b.workload_type_desc, b.sort_order
				from	aapp_workload a, lu_workload_type b
				where	a.aapp_num=#arguments.aapp#
				and		b.contract_type_code='#arguments.contract_type_code#'
				and		a.workload_type_code=b.workload_type_code
				and		a.workload_type_code='evaluate(idx)'
				order by a.contract_year, b.sort_order
			</cfquery>
			<cfset col=queryaddcolumn(arguments.qTotal,evaluate("idx"),listtoarray(valuelist(qryWorkloadData.value)))>
		</cfloop>
		<cfreturn arguments.qTotal>
	</cffunction>
	
	<cffunction name="getFeeTotalbyAAPP" access="public" returntype="numeric" hint="Returns total Fee Amount for AAPP (optionally by contract year)">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfargument name="contract_year" type="numeric" required="no">
		<cfargument name="cost_cat_id" type="numeric" required="no">
		
		<cfquery name="qryFeeTotalbyAAPP" datasource="#request.dsn#">
		select	nvl(sum(amount),0) as FeeTotal
		from	adjustment_cost
		where	adjustment_id in 
				(select adjustment_id
				from adjustment
				where aapp_num = #arguments.aapp#
				and bi_fee_required = 1
				<cfif isDefined("arguments.cost_cat_id")>
					and cost_cat_id = #arguments.cost_cat_id#
				</cfif>)
		<cfif isDefined("arguments.contract_year")>
			and contract_year = #arguments.contract_year#
		</cfif>
		</cfquery>
		
		<cfreturn qryFeeTotalbyAAPP.FeeTotal>		
	
	</cffunction>
</cfcomponent>