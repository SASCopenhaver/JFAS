<!---
page: aapp_workload.cfc

description: component that handles workload information functions

revisions:
2006-12-19	mstein	Modified createBlankWorkloadData method to handle successors
2006-12-19	mstein	Modified saveAAPPWorkload to change successor dates based on changes to predecessor
2006-12-20	mstein	Further changes to successor date adjustments
2007-03-13	mstein	added VST slots
2008-05-19	mstein	modified adjustWorkloadLength so that when adding years, values are populated with
					previous CY values (instead of zeroes)
2008-07-03	mstein	Updated createBlankWorkloadData to fix defect (see Rel 2.3 specs)
2008-07-14	mstein	Allowed for automaict reversal of FOPs when change in end date pushes successor
					to start in next PY
2012-10-14	mstein	Update to saveAAPPWorkload so that end dates are not updated form did not have those editable
--->

<cfcomponent displayname="AAPP Workload" hint="Component that contains all general AAPP Workload functions and queries">

	<cffunction name="getWorkloadData" returntype="query" access="public" hint="returns recordset containg aapp workload data">
		<cfargument name="aapp" type="numeric" required="yes" />

		<cfquery name="qryGetWorkloadData" datasource="#request.dsn#">
		select	aapp_workload.contract_year as contractYear,
				contract.fun_getaappdate (aapp.aapp_num,aapp_yearend.contract_year,'S') yearStartDate,
				aapp_yearend.date_end as yearEndDate,
				aapp_workload.workload_type_code as workloadTypeCode,
				lu_workload_type.workload_type_desc as workloadTypeDesc,
				value,
				value as workloadValue,
				vst_slots as vstSlots,
				lu_workload_type.contract_type_code as contractTypeCode,
				sort_order as sortOrder,
				contract.fun_getcontractyeardays(aapp.aapp_num, aapp_workload.contract_year) as cyDays
		from	aapp, aapp_workload, aapp_yearend, lu_workload_type
		where	aapp.aapp_num = aapp_workload.aapp_num and
				aapp_workload.aapp_num = #arguments.aapp# and
				aapp_workload.workload_type_code = lu_workload_type.workload_type_code and
				aapp_workload.contract_year = aapp_yearend.contract_year and
				aapp_workload.aapp_num = aapp_yearend.aapp_num
		order	by aapp_workload.contract_year, sort_order
		</cfquery>

		<cfreturn qryGetWorkloadData>

	</cffunction>

	<cffunction name="getFutureNewWorkloadData" returntype="query" access="public" hint="returns recordset containg aapp / predcessor workload data">
		<cfargument name="aapp" type="numeric" required="yes" />
		<cfstoredproc procedure="report.prc_get_funew_workload_rpt" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocresult name="qryGetWorkloadData">
		</cfstoredproc>
		<cfreturn qryGetWorkloadData>
	</cffunction>

	<cffunction name="getWorkloadData_CCC" returntype="query" access="public" hint="Gets workload data for a CCC">
	<cfargument name="aapp" type="numeric" required="yes">

		<cfquery name="qryGetWorkloadData_CCC" datasource="#request.dsn#">
		select	aapp_workload.workload_type_code as workloadTypeCode,
				lu_workload_type.workload_type_desc as workloadTypeDesc,
				value
		from 	aapp_workload, lu_workload_type
		where	aapp_workload.aapp_num = #arguments.aapp# and
				aapp_workload.workload_type_code = lu_workload_type.workload_type_code

		</cfquery>

		<cfreturn qryGetWorkloadData_CCC>

	</cffunction>


	<cffunction name="createBlankWorkloadData" access="public" hint="Adjusts data in workload table based on change in contract length">
		<cfargument name="aapp" type="string" required="yes" />
		<cfargument name="newContractLength" type="numeric" required="yes" />
		<cfargument name="predaapp" type="numeric" required="yes" />
		<cfargument name="serviceTypes" type="string" required="yes" />

		<cfif arguments.predaapp eq 0>
			<cfquery name="qryGetWorkloadItems" datasource="#request.dsn#">
			select	workload_type_code, 0 as workloadValue
			from	lu_workload_type
			</cfquery>
		<cfelse>
			<!--- for successor, get values from last contract year of predecessor --->
			<cfquery name="qryGetWorkloadItems" datasource="#request.dsn#">

			select	aapp_workload.workload_type_code, value as workloadValue
			from	aapp_workload, lu_workload_type
			where	aapp_workload.aapp_num = #arguments.predaapp# and
					aapp_workload.workload_type_code = lu_workload_type.workload_type_code and
					lu_workload_type.contract_type_code in (#listqualify(arguments.serviceTypes,"'")#) and
					contract_year = (select max(contract_year)
									 from	aapp_workload
									 where	aapp_num = #arguments.predaapp#)
			union
			select	workload_type_code, 0 as workloadValue
			from	lu_workload_type
			where	lu_workload_type.contract_type_code not in (#listqualify(arguments.serviceTypes,"'")#)
			</cfquery>

			<!--- get vst slots from predecessor --->
			<cfquery name="qryGetVSTslots" datasource="#request.dsn#">
			select	vst_slots as vstSlots
			from	aapp
			where	aapp_num = #arguments.predaapp#
			</cfquery>

		</cfif>

		<cfif arguments.predaapp neq 0>
			<!--- for successor values, need to pro-rate the new value based on the length of each contract year --->

			<cfobject component="#application.paths.components#aapp" name="objAAPP">
			<!--- get length of predecessor --->
			<cfinvoke component="#objAAPP#" method="getAAPPLength" aapp="#arguments.predaapp#" returnvariable="predLength">
			<!--- get start/end dates of final year --->
			<cfinvoke component="#objAAPP#" method="getAAPPContractYears" aapp="#arguments.predaapp#" contractYear="#predLength#" returnvariable="rstPredYear">
			<!--- get length (in days) of final year of predecessor --->
			<cfset predFinalYearLength = datediff("d",rstPredYear.dateStart, rstPredYear.dateEnd)/>
		</cfif>


		<cfloop index="i" from="1" to="#arguments.newContractLength#">
			<cfloop query="qryGetWorkloadItems">
				<cfif arguments.predaapp neq 0 and workload_type_code neq "SL">
					<!--- for successor values, need to pro-rate the new value based on the length of each contract year (not SLOTS) --->
					<!--- get start/end dates of this contract year --->
					<cfinvoke component="#objAAPP#" method="getAAPPContractYears" aapp="#arguments.aapp#" contractYear="#i#" returnvariable="rstNewYear">
					<!--- get length of year --->
					<cfset curYearLength = datediff("d",rstNewYear.dateStart, rstNewYear.dateEnd)/>
					<!--- calculate adjusted amount --->
					<cfset adjustedAmount = round(workloadValue * (curYearLength/predFinalYearLength)) />
				<cfelse>
					<cfset adjustedAmount = workloadValue />
				</cfif>

				<cfquery name="qryInsertWorkloadRow" datasource="#request.dsn#">
				insert into aapp_workload (
					aapp_num,
					contract_year,
					workload_type_code,
					value,
					UPDATE_USER_ID, UPDATE_FUNCTION, UPDATE_TIME)
				values (
					#arguments.aapp#,
					#i#,
					'#workload_type_code#',
					#adjustedAmount#,
					'#session.userID#', '#request.auditVarInsert#', sysdate)
				</cfquery>
			</cfloop>
		</cfloop>

		<cfif arguments.predaapp neq 0>
			<!--- update vst slots with value from predecessor --->
			<cfquery name="qryUpdateVSTslots" datasource="#request.dsn#">
			update	aapp set
					vst_slots = #qryGetVSTslots.vstSlots#
			where	aapp_num = #arguments.aapp#
			</cfquery>
		</cfif>


	</cffunction>

	<!--- insert a row into the workload table with that AAPP num for each workload type code --->
	<cffunction name="createBlankWorkloadData_CCC" access="public" hint="Adds records into workload table for new CCC">
		<cfargument name="aapp" type="string" required="yes" />

		<cftransaction>
			<cfquery name="qryGetWorkloadTypeCode" datasource="#request.dsn#">
				select Distinct(workload_type_code)
				from aapp_workload
			</cfquery>

			<cfloop query="qryGetWorkloadTypeCode">
				<cfquery name="qryInsertCCCWorkload" datasource="#request.dsn#">
					insert into aapp_workload (
						aapp_num,
						contract_year,
						workload_type_code,
						value, UPDATE_USER_ID, UPDATE_FUNCTION, UPDATE_TIME
						)
					values (
						#arguments.aapp#,
						1,
						'#qryGetWorkloadTypeCode.workload_type_code#',
						0, '#session.userID#', '#request.auditVarInsert#', sysdate
						)
				</cfquery>
			</cfloop>
		</cftransaction>
	</cffunction>

	<cffunction name="saveAAPPWorkload" access="public" output="true" hint="Saves data from workload information form entry">
		<cfargument name="formData" type="struct" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cfif (request.budgetInputType neq "A")> <!--- end dates can only be changed if contract hasn't been awarded --->
			<!--- need to make sure that if user changed contract year end dates, --->
			<!--- that no adjustments have their effective dates within the range that was altered --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPLength" aapp="#arguments.formData.hidAAPP#" returnvariable="contractLength" />
			<cfloop index="i" from="1" to="#contractLength#"> <!--- loop through contract years --->
				<cfif form["endDate__" & i] neq form["prevDate__" & i]> <!--- if user has changed data --->
					<!--- check to see if there any adjustments whose effective date --->
					<!--- falls between the new end date, and the old one --->
					<cfquery name="qryGetAdjustments" datasource="#request.dsn#">
					select	count(adjustment_id) as numRecs
					from	adjustment
					where	aapp_num = #arguments.formData.hidAAPP# and
							(
							(date_effective > to_date('#dateformat(form["endDate__" & i], "mm/dd/yyyy")#','MM/DD/YYYY') and
							date_effective <= to_date('#dateformat(form["prevDate__" & i], "mm/dd/yyyy")#','MM/DD/YYYY'))
							or
							(date_effective > to_date('#dateformat(form["prevDate__" & i], "mm/dd/yyyy")#','MM/DD/YYYY') and
							date_effective <= to_date('#dateformat(form["endDate__" & i], "mm/dd/yyyy")#','MM/DD/YYYY'))
							)
					</cfquery>
					<cfif qryGetAdjustments.numRecs gt 0>
						<cfset success = "false" />
						<cfset errorMessages = "Some of the contract year end date changes that you have adjusted could impact " &
												"adjustments and cause them to begin in different contract years. " &
												"Please modify the effective dates of these adjustments in the adjustment section first." />
						<cfset errorFields = listAppend(errorFields, "endDate__#i#") />
					</cfif>

				</cfif>

			</cfloop>
		</cfif>

		<cfif success>

			<cftransaction>

			<!--- delete existing data --->
			<cfset temp = this.deleteAAPPWorkload(arguments.formData.hidAAPP)>

			<cfloop index="fieldName" list="#arguments.formData.fieldNames#">
				<cfif listLen(fieldName, "__") eq 3> <!--- insert workload data --->

					<cfquery name="qryInsertWorkloadRecord" datasource="#request.dsn#">
					insert into aapp_workload (
						aapp_num,
						contract_year,
						workload_type_code,
						value, UPDATE_USER_ID, UPDATE_FUNCTION, UPDATE_TIME)
					values (
						#arguments.formData.hidAAPP#,
						#listgetat(fieldName,3,"__")#,
						'#listgetat(fieldName,1,"__")#',
						#replace(arguments.formdata[fieldName], ",","","all")#, '#session.userID#', '#request.auditVarInsert#', sysdate)
					</cfquery>

				<cfelseif findNoCase("endDate",fieldName)> <!--- update year end date --->

					<cfquery name="qryUpdateYearEndDate" datasource="#request.dsn#">
					update	aapp_yearend set
							date_end = to_date('#arguments.formdata[fieldName]#','MM/DD/YYYY'),
							UPDATE_USER_ID = '#session.userID#',
							UPDATE_FUNCTION = '#request.auditVarUpdate#',
							UPDATE_TIME = sysdate
					where	aapp_num = #arguments.formData.hidAAPP# and
							contract_year = #listgetat(fieldName,2,"__")#
					</cfquery>
				</cfif>
			</cfloop>

			<!--- update VST Slots --->
			<cfquery name="qryUpdateVSTslots" datasource="#request.dsn#">
			update	aapp set
					vst_slots = #replace(arguments.formdata.txtVstSlots, ",","","all")#
			where	aapp_num = #arguments.formData.hidAAPP#
			</cfquery>

			<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#arguments.formData.hidAAPP#" returnvariable="rstAAPPSummary">
			<cfif rstAAPPSummary.succAAPPNum neq "">

				<!--- if successor exists, check to see if the user changed the --->
				<!--- contract end date. If so , need to push out the successor dates accordingly --->
				<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#rstAAPPSummary.succAAPPNum#" returnvariable="rstSuccAAPPSummary">

				<cfif datecompare(dateadd("d",1,rstAAPPSummary.dateEnd),rstSuccAAPPSummary.dateStart) neq 0> <!--- end date not adjacent to successor start date? --->
					<cfset dateChangeAmount = datediff("d",rstSuccAAPPSummary.dateStart,dateadd("d",1,rstAAPPSummary.dateEnd)) />
					<cfquery name="qryUpdateSuccessorDates" datasource="#request.dsn#">
					update	aapp set
							date_start = date_start + #dateChangeAmount#
					where	aapp_num = #rstAAPPSummary.succAAPPNum#
					</cfquery>
					<cfquery name="qryUpdateSuccessorDates" datasource="#request.dsn#">
					update	aapp_yearend set
							date_end = date_end + #dateChangeAmount#
					where	aapp_num = #rstAAPPSummary.succAAPPNum#
					</cfquery>
				</cfif>

				<!--- if changes in the end date pushed successor into next PY, reverse out FOPs
					(this functionality never implemented)
				<cfif arguments.formdata.hidAdjustCurrentFOPs neq "">
					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="reverseProgramYearFOPs"
						aapp="#arguments.formData.hidAdjustCurrentFOPs#">
				</cfif>
				--->
			</cfif>


			<cfset application.outility.insertSystemAudit (
				aapp="#arguments.formData.hidAAPP#",
				statusID="#request.statusID#",
				sectionID="100",
				description="Workload Information Updated",
				userID="#session.userID#")>

			</cftransaction>

		</cfif>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

		<cfreturn stcResults>

	</cffunction>

	<cffunction name="saveAAPPWorkload_CCC" access="public" returntype="void" hint="Saves data from CCC workload information form entry">
	<cfargument name="formData" type="struct" required="yes">

	<cfquery name="qryGetWorkloadTypes_CCC" datasource="#request.dsn#">
	select	workload_type_code as workloadTypeCode
	from	aapp_workload
	where 	aapp_num = #arguments.formData.hidAappNum#
	</cfquery>

	<cfloop query="qryGetWorkloadTypes_CCC">
		<cfquery name="qryUpdateWorkloadRecord_CCC" datasource="#request.dsn#">
			update 	aapp_workload
			set 	value = #replace(arguments.formData[workloadTypeCode & "__Value"], "," , "" , "all")#,
					UPDATE_USER_ID = '#session.userID#',
					UPDATE_FUNCTION = '#request.auditVarUpdate#',
					UPDATE_TIME = sysdate
			where 	workload_type_code = '#workloadTypeCode#'
			and		aapp_num = #arguments.formData.hidAappNum#
		</cfquery>
	</cfloop>

	<cfset application.outility.insertSystemAudit (
		aapp="#arguments.formData.hidAappNum#",
		statusID="#request.statusID#",
		sectionID="100",
		description="Workload Information Updated",
		userID="#session.userID#")>

	</cffunction>

	<cffunction name="adjustWorkloadLength" access="public" hint="Adjusts data in workload table based on change in contract length">
		<cfargument name="aapp" type="string" required="yes" />
		<cfargument name="newContractLength" type="numeric" required="yes" />

		<!--- get length of contract, based on data in workload table --->
		<cfquery name="qryGetWorkloadLength" datasource="#request.dsn#">
		select	max(contract_year) as maxYear
		from	aapp_workload
		where	aapp_num = #arguments.aapp#
		</cfquery>

		<cfif qryGetWorkloadLength.maxYear neq "">
			<cfset currentWorkloadLength = qryGetWorkloadLength.maxYear />
		<cfelse>
			<cfset currentWorkloadLength = 0 />	<!--- no workload data --->
		</cfif>

		<cfif currentWorkloadLength lt arguments.newContractLength> <!--- increasing length of workload --->


			<!--- loop through extra contract years to add records --->
			<cfloop index="i" from="#evaluate(currentWorkloadLength+1)#" to="#newContractLength#">

				<cfif currentWorkloadLength gt 0> <!--- just duplicate final year workload levels into additional years --->

					<cfquery name="qryInsertWorkloadRow" datasource="#request.dsn#">
						insert into aapp_workload (
							aapp_num,
							contract_year,
							workload_type_code,
							value, UPDATE_USER_ID, UPDATE_FUNCTION, UPDATE_TIME)
						select	aapp_num,
								#i#,
								workload_type_code,
								value,
								'#session.userID#',
								'#request.auditVarInsert#',
								sysdate
						from	aapp_workload
						where	aapp_num = #arguments.aapp# and
								contract_year = #currentWorkloadLength#
						</cfquery>

				<cfelse> <!--- no existing workload, populate with zeros --->

					<!--- get list of workload items --->
					<cfquery name="qryGetWorkloadItems" datasource="#request.dsn#">
					select	workload_type_code
					from	lu_workload_type
					</cfquery>

					<cfloop query="qryGetWorkloadItems">
						<cfquery name="qryInsertWorkloadRow" datasource="#request.dsn#">
						insert into aapp_workload (
							aapp_num,
							contract_year,
							workload_type_code,
							value, UPDATE_USER_ID, UPDATE_FUNCTION, UPDATE_TIME)
						values (
							#arguments.aapp#,
							#i#,
							'#workload_type_code#',
							0, '#session.userID#', '#request.auditVarInsert#', sysdate)
						</cfquery>
					</cfloop>

				</cfif>

			</cfloop>

		<cfelseif currentWorkloadLength gt arguments.newContractLength> <!--- shortening length of contract --->

			<!--- delete all extra years from the budget data --->
			<cfquery name="qryDeleteWorkloadRows" datasource="#request.dsn#">
			delete
			from	aapp_workload
			where	aapp_num = #arguments.aapp# and
					contract_year > #arguments.newContractLength#
			</cfquery>

		</cfif>

	</cffunction>



	<cffunction name="adjustWorkloadServiceTypes" access="public" hint="Adjusts data in workload table based on change in contract service types">
		<cfargument name="aapp" type="string" required="yes">
		<cfargument name="newServiceTypes" type="string" required="yes">

		<!--- unlike budget items, the workload data table always contains all workload types --->
		<!--- based on certain business rules, only certain types of workload items are applicable --->
		<!--- for certain service types. This function will null out any workload rows that relate --->
		<!--- to any service types not associated with this aapp --->

		<!--- blank out workload data for any service types that have been removed --->
		<cfquery name="qryBlankOutWorkloadItems" datasource="#request.dsn#">
		update	aapp_workload
		set	value = 0,
			UPDATE_USER_ID = '#session.userID#',
			UPDATE_FUNCTION = '#request.auditVarUpdate#',
			UPDATE_TIME = sysdate
		where	aapp_num = #arguments.aapp#
				<cfif arguments.newServiceTypes neq "">
					and
					workload_type_code not in (
						select workload_type_code
						from lu_workload_type
						where contract_type_code in (#listQualify(arguments.newServiceTypes,"'",",","all")#)
						)
				</cfif>
		</cfquery>

	</cffunction>



	<cffunction name="deleteAAPPWorkload" access="public" hint="Saves data from workload information form entry">
		<cfargument name="aapp" type="numeric" required="yes">

			<cfquery name="qryDeleteWorkloadData" datasource="#request.dsn#">
			delete
			from	aapp_workload
			where	aapp_num = #arguments.aapp#
			</cfquery>

	</cffunction>

	<cffunction name="slotsChange" access="public" returntype="boolean" hint="Returns boolean value to see if slot levels on this AAPP differ from predecessor">
		<cfargument name="aapp" type="numeric" required="yes">

		<cfquery name="qryGetPredecessor" datasource="#request.dsn#">
		select	pred_aapp_num predAAPP
		from	aapp
		where	aapp_num = #arguments.aapp#
		</cfquery>

		<cfquery name="qryGetSlotChanges" datasource="#request.dsn#">
		select	NVL (COUNT (a.VALUE), 1) numChanges
		from	aapp_workload a, lu_workload_type b
		where	a.aapp_num = #arguments.aapp# and
				b.contract_type_code = 'A' and
				a.workload_type_code = b.workload_type_code and
				a.VALUE NOT IN (
                	select	a.VALUE
                  	from	aapp_workload a, lu_workload_type b
                 	where	a.aapp_num = #qryGetPredecessor.predAAPP# and
							b.contract_type_code = 'A' and
							a.workload_type_code = b.workload_type_code and
							a.contract_year = contract.fun_getaapptotalcontractyear(#qryGetPredecessor.predAAPP#))
		</cfquery>

		<cfif qryGetSlotChanges.numChanges neq 0>
			<cfreturn 1>
		<cfelse>
			<cfreturn 0>
		</cfif>

	</cffunction>





</cfcomponent>