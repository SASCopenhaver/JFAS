<!---
page: aapp_budget.cfc

description: component that handles aapp budget, new contract info, new contract estimates

revisions:
2007-07-05	mstein	Changed saveContractInput function so that it calls the createInitialBudgetAdjustments method
					of the adjustment component, instead of the contract.prc_updadjcostbaseyear proc, which
					was resulting in defect 224
2008-05-01	mstein	Removed existing contract input/contract estimate functions and replaced them to coincide
					with seperation of future new and award package entry
2014-03-29	mstein	Revised Allocation functions (for AAPP Allocation form) to handle quarterly values
2014-06-05	sasurikov Update Snapshot table from Contract Award
--->
<cfcomponent displayname="aapp_budget" hint="Component that contains all general contract queries and functions">

	<cffunction name="getFutureNewContractEstimates" access="public" returntype="query" hint="Get data for Future New Contract Estimates tab">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfstoredproc procedure="contract.prc_getFutureNewContractEst" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocresult name="getFutureNewContractEstimate">
		</cfstoredproc>
		<cfreturn getFutureNewContractEstimate>
	</cffunction>

	<cffunction name="saveFutureContractInput" access="public" returntype="struct" hint="Save data for Future Contract Input Screen">
		<cfargument name="formData" type="struct" required="yes" default="">
		<cfset stcContractInputSaveResults.success=true>
		<cfset stcContractInputSaveResults.errorMessages="">
		<cfset stcContractInputSaveResults.aappNum=request.aapp>
		<cftry>
			<cftransaction>
				<cfquery datasource="#request.dsn#">
					delete	aapp_contract_future
					where	aapp_num=#request.aapp#
				</cfquery>

				<!--- get list of editable line item types for future contracts --->
				<!--- make sure to remove "or future_edit = 0" before going to prod --->
				<cfquery name="qryGetFutureEditable" datasource="#request.dsn#">
				select	contract_budget_item_id
				from	i_contract_budget_item
				where	future_edit = 1
				</cfquery>
				<cfset lstEditableLineItems = valuelist(qryGetFutureEditable.contract_budget_item_id)>
				<cfloop collection="#arguments.formData#" item="key">
					<cfif findnocase("rec_",key)>

						<!--- depending on input type in this service type, write amount from form, or zeros --->
						<cfset conSort = listgetat(key,4,"_")>
						<cfif listFind(lstEditableLineItems, listgetat(key,5,"_")) and
							((arguments.formData["input_type_" & conSort] eq "A") or
							((arguments.formData["input_type_" & conSort] eq "I") and
								(listgetat(key,3,"_") eq 1)))>
							<cfset lineAmount = iif(len(arguments.formData[key]),rereplace(arguments.formData[key],"[^0-9]","","all"),0)>
						<cfelse>
							<cfset lineAmount = 0>
						</cfif>
						<cfquery datasource="#request.dsn#">
							insert into aapp_contract_future
							(aapp_num, contract_year, contract_budget_item_id, amount, update_user_id, update_function)
							values
							(#listgetat(key,2,"_")#,#listgetat(key,3,"_")#,#listgetat(key,5,"_")#,#lineAmount#,'#session.userid#','#request.auditVarInsert#')
						</cfquery>
					</cfif>
				</cfloop>

				<!--- update input type column in aapp_contract_type --->
				<cfloop list="#arguments.formData.hidConSortList#" index="i">
					<cfquery name="qryGetContractCode" datasource="#request.dsn#">
					select	contract_type_code
					from	lu_contract_type
					where	sort_order = #i#
					</cfquery>

					<cfquery name="qryUpdateInputType" datasource="#request.dsn#">
					update	aapp_contract_type
					set		input_future_type_code = '#arguments.formData["input_type_" & i]#'
					where	aapp_num = #request.aapp# and
							contract_type_code = '#qryGetContractCode.contract_type_code#'
					</cfquery>

				</cfloop>

				<!--- log update --->
				<cfset application.outility.insertSystemAudit (
					aapp="#request.aapp#",
					statusID="1",
					sectionID="200",
					description="AAPP Future New Contract Estimate updated",
					userID="#session.userID#")>

			</cftransaction>

			<cfcatch type="database">
				<cfset stcContractInputSaveResults.success=false>
				<cfset stcContractInputSaveResults.errorMessages="Fail Save to Database.">
			</cfcatch>

		</cftry>
		<cfreturn stcContractInputSaveResults>
	</cffunction>


	<!--- Actual New Contract Award: BEGIN --->

	<cffunction name="getContractAwardInfo" access="public" returntype="query" hint="Get data for Actual New Contract Award tab">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfstoredproc procedure="contract.prc_getContractAward" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocresult name="getContractAwardInfo">
		</cfstoredproc>
		<cfreturn getContractAwardInfo>
	</cffunction>

	<cffunction name="saveContractAwardInput" access="public" returntype="struct" hint="Save data for Actual New Contract Award Screen">
		<cfargument name="formData" type="struct" required="yes" default="">
		<cfset stcContractInputSaveResults.success=true>
		<cfset stcContractInputSaveResults.errorMessages="">
		<cfset stcContractInputSaveResults.aappNum=request.aapp>
		<cftry>
			<cftransaction>
				<cfquery datasource="#request.dsn#">
					delete	aapp_contract_award
					where	aapp_num=#request.aapp#
				</cfquery>
				<cfloop collection="#arguments.formData#" item="key">
					<cfif findnocase("rec_",key)>
						<!--- depending on input type in this service type, write amount from form, or zeros --->
						<cfset conSort = listgetat(key,4,"_")>
						<cfset lineAmount = iif(len(arguments.formData[key]),rereplace(arguments.formData[key],"[^0-9]","","all"),0)>

						<cfquery datasource="#request.dsn#">
							insert into aapp_contract_award
							(aapp_num, contract_year, contract_budget_item_id, amount, update_user_id, update_function)
							values (
                            		#listgetat(key,2,"_")#,
                                    #listgetat(key,3,"_")#,
                                    #listgetat(key,5,"_")#,
                                    #lineAmount#,
                                    '#session.userid#',
                                    '#request.auditVarInsert#'
                                   )
						</cfquery>
					</cfif>
				</cfloop>

				<cfquery datasource="#request.dsn#">
				update	aapp
				set		budget_input_type='A'
				where	aapp_num=#request.aapp#
				</cfquery>

				<!--- log update --->
				<cfset application.outility.insertSystemAudit (
					aapp="#request.aapp#",
					statusID="1",
					sectionID="200",
					description="AAPP Contract Award Package data updated",
					userID="#session.userID#")>

				<!--- recreate all budget related adjustment records --->
				<cfinvoke component="#application.paths.components#aapp_adjustment" method="createInitialBudgetAdjustments" aapp="#request.aapp#" />
			
            	<cfstoredproc procedure="JFAS_SNAPSHOT_PKG.sp_updAAPP_CONTRACT_SNAPSHOT" returncode="no">
                    <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="argAAPP_NUM" value="#request.aapp#" null="no">
                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUser_ID" value="#session.userid#" null="no">
                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUpdate_Notes" value="Updated from Contract Award" null="no">
                </cfstoredproc>
            
            
			</cftransaction>

			<cfcatch type="database">
				<cfset stcContractInputSaveResults.success=false>
				<cfset stcContractInputSaveResults.errorMessages="Fail Save to Database.">
			</cfcatch>

		</cftry>
		<cfreturn stcContractInputSaveResults>
	</cffunction>
	<!--- Actual New Contract Award: END --->



	<cffunction name="getFutureNewHeader" access="public" returntype="query" hint="Get data for Future New Header">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfstoredproc procedure="report.prc_get_future_new_rpt" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocresult name="getHeader">
		</cfstoredproc>
		<cfreturn getHeader>
	</cffunction>


	<cffunction name="getPYAllocation" access="public" returntype="numeric" hint="Get PY Allocation Amount">
		<cfargument name="aapp" type="numeric" required="true">
		<cfargument name="py" type="numeric" required="true">
		<cfargument name="fundCat" type="string" required="true">
		<cfargument name="qtr" type="numeric" required="true">

		<cfquery name="qryGetAllocation" datasource="#request.dsn#">
		select	nvl(amount,0) as amount
		from	aapp_py_allocation
		where	aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#"> and
				py = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.py#"> and
				upper(fund_cat) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.fundCat)#"> and
				qtr = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.qtr#">
		</cfquery>

		<cfif qryGetAllocation.recordcount eq 0>
			<cfreturn 0>
		<cfelse>
			<cfreturn qryGetAllocation.amount>
		</cfif>

	</cffunction>


	<cffunction name="insertPYAllocation" access="public" hint="Insert PY Allocation Amount">
		<cfargument name="aapp" type="numeric" required="true">
		<cfargument name="py" type="numeric" required="true">
		<cfargument name="fundCat" type="string" required="true">
		<cfargument name="qtr" type="numeric" required="true">
		<cfargument name="amount" type="numeric" required="false" default="0">

		<cfquery name="qryInsertAllocation" datasource="#request.dsn#">
		insert	into aapp_py_allocation
				(aapp_num, py, fund_cat, qtr, amount,
				 update_user_id)
		values
				(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#">,
				 <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.py#">,
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.fundCat)#">,
				 <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.qtr#">,
				 <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.amount#">,
				 '#session.userID#')
		</cfquery>

	</cffunction>


	<cffunction name="getPYAllocationData" access="public" returntype="struct" hint="Get data for AAPP PY Allocation Form">
		<cfargument name="aapp" type="numeric" required="true">

		<cfset stcPYAllocationData = structNew()>
		<cfset stcPYAllocationData.lstFundCat = "OPS,CRA">
		<cfset lstPYs = "">

		<!--- determine PY range to display on form - depends on AAPP type --->
		<!--- get aapp type, start/end dates --->
		<cfquery name="qryGetAAPPStartEnd" datasource="#request.dsn#">
		select	agreement_type_code aappType,
				date_start dateStart,
				(select max(date_end)
				 from aapp_yearend
				 where aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#">) as dateEnd
		from	aapp
		where	aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#">
		</cfquery>
		<!--- get current system PY --->
		<cfset currentPY = application.outility.getCurrentSystemProgramYear ()>

		<!--- for DOL contract, use start and end dates, and base PYs on that --->
		<cfif qryGetAAPPStartEnd.aappType eq 'DC' or qryGetAAPPStartEnd.aappType eq 'GR'>
			<!--- get start PY --->
			<cfset startPY = application.outility.getYear_byDate(yearType="P", baseDate="#qryGetAAPPStartEnd.dateStart#")>

			<!--- get end PY --->
			<cfset endPY = application.outility.getYear_byDate(yearType="P", baseDate="#qryGetAAPPStartEnd.dateEnd#")>

		<cfelse> <!--- not a DOL contract: may have start date, won't have end date --->
			<cfif qryGetAAPPStartEnd.dateStart neq ""> <!--- start date exists, determine PY --->

				<cfset startPYtemp = application.outility.getYear_byDate(yearType="P", baseDate="#qryGetAAPPStartEnd.dateStart#")>

				<cfset startPY = max(startPYtemp, currentPY - 3)> <!--- use PY of start date, or current PY - 3, whichever is later --->
			<cfelse>
				<cfset startPY = currentPY - 3> <!--- no start date, use current - 3 --->
			</cfif>
			<cfset endPY = currentPY + 3> <!--- for end date, use current + 3 --->
		</cfif>

		<cfset stcPYAllocationData.startPY = startPY>
		<cfset stcPYAllocationData.endPY = endPY>

		<!--- determine which PYs are editable --->
		<!--- current PY is always editable --->
		<cfset stcPYAllocationData.lstEditablePY = currentPY>
		<!--- if current date is within 1 week of the previous PY end date, then the previous PY is editable --->
		<cfset lastPYendDate = application.outility.getProgramYearDate (
		py="#evaluate(currentPY-1)#", type="E"
		)>
		<cfif dateDiff("ww", lastPYendDate, now()) lte 10>
			<cfset stcPYAllocationData.lstEditablePY = listAppend(stcPYAllocationData.lstEditablePY, #evaluate(currentPY-1)#)>
		</cfif>
		<!--- if current date is within X number of days of the next PY start date, then the next PY is editable --->
		<!--- this window is based on the "Batch Process Availability Window" system setting --->
		<cfset nextPYstartDate = application.outility.getProgramYearDate(py="#evaluate(currentPY+1)#", type="S")>
		<cfset nextPYwindow = application.outility.GetSystemSetting(systemSettingCode="batchprocess_window" )>
		<cfif dateDiff("d", now(), nextPYstartDate) lte nextPYwindow>
			<cfset stcPYAllocationData.lstEditablePY = listAppend(stcPYAllocationData.lstEditablePY, #evaluate(currentPY+1)#)>
		</cfif>


		<!--- loop through PYs --->
		<cfloop from="#startPY#" to="#endPY#" index="py">

			<cfset stcPYAllocationData["total_" & py] = 0>
			<cfset stcPYAllocationData["fopTotal_" & py] = 0>
			<cfset stcPYAllocationData["obligTotal_" & py] = 0>

			<cfloop list="#stcPYAllocationData.lstFundCat#" index="cat">

				<cfif cat eq "OPS">
					<!--- get OPS amounts --->
					<cfset stcPYAllocationData["subtotal_" & py & "_OPS"] = 0>
					<cfloop from="1" to="4" index="qtr">
						<!--- get allocation amount, set field value --->
						<cfset tempVal = getPYAllocation(arguments.aapp, py, cat, qtr)>
						<cfset stcPYAllocationData["amount_" & py & "_" & cat & "_" & qtr] = tempVal>
						<cfset stcPYAllocationData["subtotal_" & py & "_OPS"] = stcPYAllocationData["subtotal_" & py & "_OPS"] + stcPYAllocationData["amount_" & py & "_" & cat & "_" & qtr]>
					</cfloop>
				<cfelseif cat eq "CRA">
					<cfset qtr=0> <!--- CRA amounts are not quarterly --->
					<cfset tempVal = getPYAllocation(arguments.aapp, py, cat, qtr)>
					<cfset stcPYAllocationData["amount_" & py & "_" & cat & "_" & qtr] = tempVal>
				</cfif>

				<!--- get FOP total --->
				<cfinvoke component="#application.paths.components#aapp_adjustment" method="getTotalFOPAmount" aapp="#arguments.aapp#" py="#py#" fundCat="#cat#" returnvariable="fopTotal">
				<cfset stcPYAllocationData["fop_" & py & "_" & cat] = fopTotal>

				<!--- get ncfms obligation total --->
				<cfinvoke component="#application.paths.components#footprint" method="getFOOTFunding"
						  	aapp="#arguments.aapp#" py="#py#" fundCat="#cat#" returnvariable="obligTotal">
				<cfset stcPYAllocationData["oblig_" & py & "_" & cat] = obligTotal>


			</cfloop>

			<cfset stcPYAllocationData["total_" & py] = stcPYAllocationData["subtotal_" & py & "_OPS"] + stcPYAllocationData["amount_" & py & "_CRA_0"]>
			<cfset stcPYAllocationData["fopTotal_" & py] = stcPYAllocationData["fop_" & py & "_OPS"] + stcPYAllocationData["fop_" & py & "_CRA"]>
			<cfset stcPYAllocationData["obligTotal_" & py] = stcPYAllocationData["oblig_" & py & "_OPS"] + stcPYAllocationData["oblig_" & py & "_CRA"]>
			<cfset lstPYs = listAppend(lstPYs, py)>

		</cfloop>

		<cfset stcPYAllocationData.lstPYs = lstPYs>
		<cfreturn stcPYAllocationData>

	</cffunction>


	<cffunction name="savePYAllocationData" access="public" hint="Save data from AAPP PY Allocation Form">
		<cfargument name="formData" type="struct" required="true">

		<cftransaction>

		<!--- delete all existing data --->
		<cfquery name="qryDeleteAllocationData" datasource="#request.dsn#">
		delete
		from	aapp_py_allocation
		where	aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.hidAAPP#">
		</cfquery>

		<!--- loop from start PY to end PY --->
		<cfloop from="#arguments.formData.startPY#" to="#arguments.formData.endPY#" index="py">

			<!--- loop through fund cats --->
			<cfloop list="#arguments.formData.lstFundCat#" index="cat">

				<cfif cat eq "OPS">
					<cfloop from="1" to="4" index="qtr">
						<!--- insert OPS qtr amount --->
						<cfset cleanVal = replace(arguments.formData["amount_" & py & "_" & cat & "_" & qtr],",","","all")>
						<cfset temp = insertPYAllocation(arguments.formData.hidAAPP,py,cat,qtr,cleanVal)>
					</cfloop>

				<cfelse> <!--- insert OPS qtr amount --->
					<cfset cleanVal = replace(arguments.formData["amount_" & py & "_" & cat & "_0"],",","","all")>
					<cfset temp = insertPYAllocation(arguments.formData.hidAAPP,py,cat,0,cleanVal)>
				</cfif>

			</cfloop> <!--- fund cats --->

		</cfloop> <!--- PYs --->

		<!--- log update --->
		<cfset application.outility.insertSystemAudit (
			aapp="#request.aapp#",
			statusID="1",
			sectionID="100",
			description="AAPP PY Allocation Data Updated",
			userID="#session.userID#")>





		</cftransaction>

	</cffunction>


</cfcomponent>

