<!---
page: aapp_yearend.cfc

description: component that handles year-end and close-out functions

revisions:
2007-01-17	mstein
2007-01-18	rroser	allow for inserting comments on year end closeout
2007-01-23	mstein	tracking adjustment IDs for all recon and closeout activities
2007-01-23	mstein	allow for inserting comments on year-end reconciliation
2007-01-23	mstein	allow for undo of year-end reconciliation
2007-02-08	mstein	fixed defect 136 - issues with saving takeback info
2007-03-15	mstein	added function get2110ReportList
2007-03-16	mstein	modified calculateYearEndAmounts to use correct values from the CONTRACT_PERFORMANCE_REF table (instead of hardcoding)
2007-03-27	mstein	multiple changes to faciliate new closeout form - mostly affecting getCloseout, calculateCloseOut, saveCloseout
2007-04-11	mstein	fixed defect 168 - caused by two different calculations to grab latest FMS report.
2007-09-12	mstein	Added CheckModCompletion() to make sure mod numbers have been assigned thru a given contract year
					(used in determining if year-end recon can be performed)
2008-05-21	mstein	Fixed defect in getYearEndData (qc 328)
2010-10-29	mstein	Fixed defect in calculateCloseOutAmounts, when B1 had no variance
2010-12-09	mstein	Added pendingYERecon, which determines if a year-end recon is pending for an AAPP
					Took out code that updates back to 2110 tables after YE Recon and Closeout (this should not be done)
2010-12-14	mstein	Release 2.7 - deactivation of some automatic close-out features (neagtive FOPs, ECP adjustments)
2011-02-28	mstein	Release 2.8 - Changes to formulas, and how adjustments are generated. See 2.8 specs for more details.
2011-04-12	mstein	Release 2.7.1 - fixed defect in pendingYERecon - close-out records being hidden if last year-end recon wasn't executed
2011-12-22	mstein	Updated getCloseOutData to resolve ambiguous column name
2014-06-05	sasurikov Update Snapshot table from Year/End Reconciliation
--->
<cfcomponent displayname="AAPP Year-End Closeout Component" hint="Component that handles year-end reconciliation and close-out functions">

	<cffunction name="getYearEndListing" access="public" returntype="query" hint="Gets high-level listing of existing year-end recon records">
		<cfargument name="aapp" type="numeric" required="no" />

		<!--- get list of contract recons that exist in the database --->
		<cfquery name="qryYearEndListing" datasource="#request.dsn#">
		select	aapp_num as aappNum,
				contract_year as contractYear,
				update_time as dateRecon
		from	aapp_yearend_recon
		where	aapp_num = #arguments.aapp#
		order	by aapp_num, contract_year
		</cfquery>

		<cfreturn qryYearEndListing>

	</cffunction>

	<cffunction name="pendingYERecon" access="public" returntype="numeric" hint="Determines if a Year-End Recon is pending for this AAPP, and which year">
		<cfargument name="aapp" type="numeric" required="yes" />

		<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#arguments.aapp#" returnvariable="rstAAPPGeneral">
		<cfinvoke component="#application.paths.components#aapp" method="getAAPPLength" aapp="#arguments.aapp#" returnvariable="contractLength">

		<!--- check for existence of close-out records --->
		<cfset rstCloseOutRecs = this.getCloseOutListing(arguments.aapp)>

		<!--- Returns: --->
		<!---   -1:  Contract Not eligible for YE (various reasons) --->
		<!---    0:  Not eligible, because it is all caught up --->
		<!--- GT 0:  Eligible, and pending for this year (the value returned) --->

		<cfif (not listfind("DC,GR",rstAAPPGeneral.agreementTypeCode)) or
			  (datediff("yyyy",rstAAPPGeneral.dateEnd, now()) gte 3) or
			  (rstAAPPGeneral.curContractYear lte 1)>
			  <!--- AAPP is not Contract or Grant --->
			  <!--- AAPP ended over 3 years ago --->
			  <!--- AAPP has not completed its first contract year --->
			<cfreturn -1>

		<cfelseif (rstAAPPGeneral.lastReconYear gte (rstAAPPGeneral.curContractYear - 1)) or
				  (rstAAPPGeneral.lastReconYear gte (contractLength - 1)) or
				  (rstCloseOutRecs.recordCount gt 0)>
				  <!--- Last recon is from current contract year - 1 (recons are all caught up) ...OR --->
				  <!--- The last year that was reconciled is greater than or =  [contract length - 1] (no YE recon for final contract year - that's a close-out) --->
				  <!--- AAPP has had close-out already (prior to new business rules) --->
			<cfreturn 0>

		<cfelse>
			<!--- YE Recon is pending, --->

			<cfif datecompare(rstAAPPGeneral.dateEnd,now()) eq -1>
				<!--- if contract has ended, return next to last CY (contract length - 1) --->
				<cfreturn contractLength - 1>

			<cfelse>
				<!--- otherwise, return the current contract year - 1 --->
				<cfreturn rstAAPPGeneral.curContractYear - 1>
			</cfif>
		</cfif>

	</cffunction>



	<cffunction name="get2110ReportList" access="public" returntype="query" hint="Gets list of Center 2110 (FMS) reports">
		<cfargument name="aapp" type="numeric" required="yes" />

		<!--- need to determine what the latest reporting date is that should be used when selecting 2110 data --->
		<cfquery name="qryGet2110ReportList" datasource="#request.dsn#">
		select	center_2110_id as reportID,
				aapp_num as aappNum,
				rep_date as reportDate
		from	center_2110_data
		where	aapp_num = #arguments.aapp#
		order by rep_date
		</cfquery>

		<cfreturn qryGet2110ReportList>

	</cffunction>

	<cffunction name="get2110TotalCosts" access="public" returntype="query" hint="Gets cost cat level costs for an aapp based on contract year">
		<cfargument name="aapp" type="numeric" required="yes" />
		<cfargument name="contractYear" type="numeric" required="no" />
		<cfargument name="costCatID" type="numeric" required="no" />

		<!--- need to determine what the latest reporting date is that should be used when selecting 2110 data --->
		<cfinvoke component="#application.paths.components#aapp" method="getAAPPContractYears" aapp="#arguments.aapp#" returnvariable="rstContractYearData">
		<cfif isDefined("arguments.contractYear")>
			<cfquery name="qryGetYearEndDate" dbtype="query">
			select	dateEnd as maxEndDate
			from	rstContractYearData
			where	contractYear = #arguments.contractYear#
			</cfquery>
			<cfset cYear = arguments.contractYear />
			<!--- contract year may not always end at end of the month... --->
			<!--- so add one month, subtract one day to get max FMS reporting date --->
			<cfset maxReportingDate = dateadd("d",-1,dateadd("m",1,qryGetYearEndDate.maxEndDate)) />
		</cfif>


		<cfquery name="qryGet2110Amounts" datasource="#request.dsn#">
		select	center_2110_id as reportID,
				cost_cat_id as costCatID,
				cost_cat_code as costCatCode,
				cost_cat_desc as costCatDesc,
				max(cumContractCost) as cumContractCost,
				max(cumContractFunding) as cumContractFunding,
				max(cumContractValue) as cumContractValue,
				max(cumContractOblig) as cumContractOblig,
				max(contractYearBudget) as contractYearBudget,
				max(contractYearExpensePlanned) as contractYearExpensePlanned,
				max(contractYearExpenseActual) as contractYearExpenseActual
		from
			(select	center_2110_id, center_2110_amount.cost_cat_id, cost_cat_code, cost_cat_desc,
				case when type_id = 1 then amount end as cumContractCost,
				case when type_id = 2 then amount end as cumContractFunding,
				case when type_id = 3 then amount end as cumContractValue,
				case when type_id = 4 then amount end as cumContractOblig,
				case when type_id = 5 then amount end as contractYearBudget,
				case when type_id = 6 then amount end as contractYearExpensePlanned,
				case when type_id = 7 then amount end as contractYearExpenseActual
				from	center_2110_amount, lu_cost_cat
				where	center_2110_amount.cost_cat_id = lu_cost_cat.cost_cat_id and
						center_2110_id in (select center_2110_id from center_2110_data where aapp_num = #arguments.aapp#) and
						center_2110_id in (select center_2110_id from center_2110_data where
											rep_date =
												(select	max(rep_date)
												from	center_2110_data
												where	aapp_num = #arguments.aapp#
												<cfif isDefined("arguments.contractYear")>
												and rep_date <= to_date('#dateformat(maxReportingDate,"mm/dd/yyyy")#', 'MM/DD/YYYY')
												</cfif>
												)
											)
						<cfif isDefined("arguments.costCatID")>
							and center_2110_amount.cost_cat_id = #arguments.costCatID#
						</cfif>
			)
		group by center_2110_id, cost_cat_id, cost_cat_code, cost_cat_desc
		order by cost_cat_id
		</cfquery>

		<cfif isDefined("arguments.contractYear")> <!--- if contract year specified, join with Est Cost Profile Data --->

			<!--- get cum contract estimates from ECP --->
			<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileTotalbyCategory" aapp="#arguments.aapp#"
				contract_year="#cYear#" returnvariable="rstEstCostProfileTotal" />



			<cfquery name="qryGetYearEndCombined" dbtype="query">
			select *
			from	qryGet2110Amounts, rstEstCostProfileTotal
			where	qryGet2110Amounts.costCatCode = rstEstCostProfileTotal.contract_type_code
			</cfquery>

			<cfreturn qryGetYearEndCombined />

		<cfelse>

			<cfreturn qryGet2110Amounts>
		</cfif>


	</cffunction>

	<cffunction name="getYearEndData" access="public" returntype="query" hint="Gets data to populate Year End Data Form">
		<cfargument name="aapp" type="numeric" required="yes" />
		<cfargument name="contractYear" type="numeric" required="yes" />

		<!--- first of all, determine whether this is going to display existing data --->
		<!--- or projections for a pending reconciliation --->

		<!--- check to see if this year's data exists in recon table --->
		<cfquery name="qryCheckYear" datasource="#request.dsn#">
		select	aapp_num
		from	aapp_yearend_recon
		where	aapp_num = #arguments.aapp# and
				contract_year = #arguments.contractYear#
		</cfquery>

		<cfif qryCheckYear.recordCount gt 0>
			<!--- existing year-end reconciliation --->
			<cfquery name="qryGetAAPPYearEnd" datasource="#request.dsn#">
			select	aapp_yearend_recon.aapp_num as aappNum,
					aapp_yearend_recon.contract_year as contractYear,
					aapp_yearend_recon_amount.cost_cat_id as costCatID,
					lu_cost_cat.cost_cat_code as costCatCode,
					perf_rating_weighted as perfRatingWeighted,
					perf_rating_seg1 as perfRatingSeg1,
					perf_rating_seg2 as perfRatingSeg2,
					date_seg1_start as dateSeg1Start,
					date_seg1_end as dateSeg1End,
					date_seg2_start as dateSeg2Start,
					date_seg2_end as dateSeg2End,
					sy_planned as SYplanned,
					sy_actual as SYactual,
					sy_costper as SYcostPer,
					lowobs_rate as lowOBSrate,
					lowobs_target as lowOBStarget,
					lowobs_takeback as lowOBStakeback,
					lowobs_deficiency as lowOBSdeficiency,
					under_run as underrun,
					roll_over as actualRollover,
					excess_underrun as excessUnderrun,
					take_back as takeback,
					cum_cont_value as cumContractValueEstimate,
					cum_cont_cost as cumContractCost,
					cy_budget as contractYearBudget,
					roll_over_rate as rolloverRate,
					roll_over_cap as rolloverCap,
					net_rollover as netRollover,
					aapp_yearend_recon.contract_year_start_date as contractYearStartDate,
					aapp_yearend_recon.contract_year_end_date as contractYearEndDate,
					aapp_yearend_recon.date_2110_report as reportingDate,
					comments as comments,
					cost_cat_desc as costCatDesc,
					form_version as formVersion
			from	aapp_yearend_recon, aapp_yearend_recon_amount, lu_cost_cat
			where	aapp_yearend_recon.aapp_num = #arguments.aapp# and
					aapp_yearend_recon.contract_year = #arguments.contractYear# and
					aapp_yearend_recon_amount.cost_cat_id = lu_cost_cat.cost_cat_id and
					aapp_yearend_recon.aapp_num = aapp_yearend_recon_amount.aapp_num and
					aapp_yearend_recon.contract_year = aapp_yearend_recon_amount.contract_year
			order	by aapp_yearend_recon_amount.cost_cat_id
			</cfquery>


		<cfelse> <!--- user is performing a new year-end recon --->

			<!--- make sure this is valid year to be reconciling --->
			<cfquery name="qryGetRecon" datasource="#request.dsn#" maxrows="1">
			select	max(contract_year) as maxRecon
			from	aapp_yearend_recon
			where	aapp_num = #arguments.aapp#
			</cfquery>
			<cfif qryGetRecon.maxRecon eq "">
				<cfset nextCY = 1 />
			<cfelse>
				<cfset nextCY = qryGetRecon.maxRecon + 1 />
			</cfif>

			<!--- get latest version number of Year-end Recon form --->
			<cfset formVersion = application.outility.getFormVersion (
			formType="YEAREND"
			)>

			<cfinvoke component="#application.paths.components#aapp" method="getAAPPLength" aapp="#arguments.aapp#" returnvariable="contractLength" />
			<cfif (arguments.contractYear gte nextCY) and (arguments.contractYear lt contractLength)>

				<!--- pending year-end recon... need to get projected underruns --->
				<!--- get list of service types (only need to get this data from 2110 tables) --->
				<cfinvoke component="#application.paths.components#aapp" method="getAAPPServiceTypes"
					aapp="#url.aapp#" returnvariable="lstServiceTypes">
				<!--- remove Support, Other --->
				<cfset lstServiceTypes = replaceNoCase(replaceNoCase(lstserviceTypes, "S",""),"OT","")>

				<!--- get the report date to use --->
				<cfinvoke component="#application.paths.components#aapp" method="getAAPPContractYears"
					aapp="#arguments.aapp#" contractYear="#arguments.contractYear#" returnvariable="rstContractYearData">

				<cfset contractYearStartDate = rstContractYearData.dateStart />
				<cfset contractYearEndDate = rstContractYearData.dateEnd />
				<!--- contract year may not always end at end of the month... --->
				<!--- so add one month, subtract one day to get max FMS reporting date --->
				<cfset maxReportingDate = dateadd("d",-1,dateadd("m",1,rstContractYearData.dateEnd)) />

				<!--- get applicable figures from 2110 data --->
				<cfquery name="qryGet2110Report" datasource="#request.dsn#">
				select	center_2110_id as reportID,
						plan_sy_cytd as SYplanned,
						actl_sy_cytd as SYactual,
						rep_date as reportingDate,
						'' as rollover
				from	center_2110_data
				where	aapp_num = #arguments.aapp# and
						rep_date =
							(select	max(rep_date)
							from	center_2110_data
							where	aapp_num = #arguments.aapp# and
									rep_date <= to_date('#dateformat(maxReportingDate,"mm/dd/yyyy")#', 'MM/DD/YYYY'))
				</cfquery>


				<!--- get the 2110 costs associated with this contract year --->
				<cfset qryGet2110Amounts = this.get2110TotalCosts(arguments.aapp,arguments.contractYear) />

				<cfquery name="qryGetAAPPYearEnd" dbtype="query">
				select	qryGet2110Report.reportID,
						costCatID,
						costCatCode,
						costCatDesc,
						reportingDate,
						'' as perfRatingSeg1,
						'' as perfRatingSeg2,
						'' as perfRatingWeighted,
						'' as dateSeg1Start,
						'' as dateSeg1End,
						'' as dateSeg2Start,
						'' as dateSeg2End,
						SYactual,
						SYplanned,
						'' as SYcostPer,
						'' as lowOBSrate,
						0 as lowOBStarget,
						cumContractValue,
						cumContractCost,
						funds as contractYearBudget,
						contractYearExpenseActual,
						cumValue as cumContractValueEstimate,
						'' as underrun,
						0 as lowOBStakeback,
						0 as lowOBSdeficiency,
						0 as netRollover,
						'' as rolloverRate,
						'' as rolloverCap,
						'' as actualRollover,
						'' as excessUnderrun,
						'' as takeback,
						'#contractYearStartDate#' as contractYearStartDate,
						'#contractYearEndDate#' as contractYearEndDate,
						'' as comments,
						#formVersion# as formVersion
				from	qryGet2110Report, qryGet2110Amounts
				where	qryGet2110Report.reportID = qryGet2110Amounts.reportID and
						costCatCode in (#listQualify(lstServiceTypes,"'")#)
				</cfquery>


			<cfelse>

				<cflocation url="#application.paths.root#">

			</cfif><!--- is this a valid contract year --->



		</cfif> <!--- existing, or pending? --->

		<cfreturn qryGetAAPPYearEnd />
	</cffunction>



	<cffunction name="calculateYearEndAmounts" access="public" returntype="struct" hint="Takes raw year end data, calculates rollovers/takebacks">
		<cfargument name="aapp" type="numeric" required="yes"/>
		<cfargument name="formData" type="struct" required="yes"/>

		<!--- get contractor performance info from database --->
		<cfset rstContractorPerformanceRef = this.getContractorPerformanceRef()>
		<cfset formData.A_lowOBSRate = rstContractorPerformanceRef.lowOBStakebackRate/>

		<!--- remove commas from numeric values --->
		<cfloop collection="#formData#" item="i">
			<cfif i neq "hidServiceTypes">
				<cfset formData[i] = replaceNoCase(formData[i],",","","all")>
			</cfif>
		</cfloop>


		<cfloop index="sType" list="#form.hidServiceTypes#">

			<cfset formData[sType & "_underrun"] = formData[sType & "_cumContractValueEstimate"] - formData[sType & "_cumContractCost"]  />

			<cfif sType eq "A"> <!--- OPS specific fields --->

				<!--- determine Segment 1, 2 dates - need to split Contract Year across Program years--->
				<cfset form.hidSeg1_StartDate = formData.hidContractYearStartDate>
				<cfset formData.hidSeg1_EndDate = "6/30/">
				<cfif month(formData.hidContractYearStartDate) lt 7>
					<cfset formData.hidSeg1_EndDate = formData.hidSeg1_EndDate & year(formData.hidContractYearStartDate)/>
				<cfelse>
					<cfset formData.hidSeg1_EndDate = formData.hidSeg1_EndDate & year(formData.hidContractYearStartDate)+1/>
				</cfif>

				<cfif dateCompare(formData.hidSeg1_EndDate, form.hidContractYearEndDate) eq 1>
					<cfset formData.hidSeg1_EndDate = form.hidContractYearEndDate>
				</cfif>

				<cfset formData.hidSeg2_StartDate = dateadd("d",1,formData.hidSeg1_EndDate)>
				<cfset formData.hidSeg2_EndDate = form.hidContractYearEndDate>

				<!--- Weighted performance rating --->
				<cfif formData.A_perfRatingSeg1 neq "" and formData.A_perfRatingSeg2 neq "">
					<cfset Seg1_length = dateDiff("d",formData.hidSeg1_StartDate,formData.hidSeg1_EndDate)+1>
					<cfset Seg2_length = dateDiff("d",formData.hidSeg2_StartDate,formData.hidSeg2_EndDate)+1>
					<cfset formData.A_perfRatingWeighted = round(((Seg1_length * formData.A_perfRatingSeg1) +
							(Seg2_length * formData.A_perfRatingSeg2)) / (Seg1_length + Seg2_length ) * 10) / 10>
				<cfelse>
					<cfset formData.A_perfRatingWeighted = ""/>
				</cfif>

				<!--- Capacity Utilization --->
				<cfif formData.A_SYactual eq 0 or formData.A_SYplanned eq 0>
					<cfset formData.A_capUtilization = 0 />
				<cfelse>
					<cfset formData.A_capUtilization = formData.A_SYactual/formData.A_SYplanned />
				</cfif>

				<!--- Planned Cost / SY --->
				<cfif formData.A_SYplanned eq 0>
					<cfset formData.A_SYcostPer = 0 />
				<cfelse>
					<cfset formData.A_SYcostPer = round(formData.A_contractYearBudget/formData.A_SYplanned) />
				</cfif>

				<!--- SY Shortfall --->
				<cfset formData.A_SYshortfall = formData.A_SYplanned-formData.A_SYactual/>

				<!--- if cap utlization > 98%, then no low OBS takeback target --->
				<cfif formData.A_capUtilization lt .98>
					<cfset formData.A_lowOBStarget = round((1-formData.A_capUtilization)*formData.A_contractYearBudget*formData.A_lowOBSRate) />
				<cfelse>
					<cfset formData.A_lowOBStarget = 0 />
				</cfif>

				<!--- Low OBS Takeback, OBS Deficiency, Net Rollover --->
				<cfif formData.A_underrun gt 0>
					<cfset formData.A_lowOBStakeback = min(formData.A_underrun,formData.A_lowOBStarget) />
					<cfset formData.A_netRollover = formData.A_underrun - formData.A_lowOBStakeback />
					<cfset formData.A_lowOBSdeficiency = formData.A_lowOBStarget - formData.A_lowOBStakeback />
				<cfelse>
					<cfset formData.A_lowOBStakeback = 0 />
					<cfset formData.A_netRollover = 0 />
					<cfset formData.A_lowOBSdeficiency = formData.A_lowOBStarget />
				</cfif>

				<!--- determine rollover rate/amount based on performance --->
				<cfif formData.A_perfRatingSeg1 neq "" and formData.A_perfRatingSeg2 neq "">
					<cfif formData.A_perfRatingWeighted lt rstContractorPerformanceRef.perfRatingExel>
						<!--- less than excellent performance --->
						<cfset formData.A_rolloverRate = rstContractorPerformanceRef.roPercentReg />
						<cfset formData.A_rolloverCap = min(rstContractorPerformanceRef.roCapAmountReg,formData.A_rolloverRate*formData.A_contractYearBudget) />
					<cfelse>
						<!--- excellent performance --->
						<cfset formData.A_rolloverRate = rstContractorPerformanceRef.roPercentExel />
						<cfset formData.A_rolloverCap = round(formData.A_rolloverRate*formData.A_contractYearBudget) />
					</cfif>

					<cfif formData.A_underrun - formData.A_lowOBStakeback lte formData.A_rolloverCap>
						<cfset formData.A_excessUnderrun = 0/>
					<cfelse>
						<cfset formData.A_excessUnderrun = formData.A_underrun - formData.A_lowOBStakeback - formData.A_rolloverCap/>
					</cfif>

					<cfset formData.A_takeback = formData.A_lowOBStakeback + formData.A_excessUnderrun/>
					<cfset formData.A_actualrollover = formData.A_underrun - formData.A_takeback/>

				<cfelse>
					<cfset formData.A_rolloverRate = "" />
					<cfset formData.A_rolloverCap = "" />
					<cfset formData.A_takeback = "" />
					<cfset formData.A_actualrollover = "" />
				</cfif>

			<cfelse> <!--- C1, C2 --->

				<cfset formData[sType & "_rolloverRate"] = rstContractorPerformanceRef.roPercentOACTS />
				<cfset formData[sType & "_rolloverCap"] = min(rstContractorPerformanceRef.roCapAmountOACTS,(round(formData[sType & "_rolloverRate"]*formData[sType & "_contractYearBudget"]))) />
				<cfif formData[sType & "_underrun"] lte formData[sType & "_rolloverCap"]>
					<cfset formData[sType & "_excessUnderrun"] = 0 />
				<cfelse>
					<cfset formData[sType & "_excessUnderrun"] = formData[sType & "_underrun"] - formData[sType & "_rolloverCap"] />
				</cfif>

				<cfset formData[sType & "_takeback"] = formData[sType & "_excessUnderrun"]>
				<cfset formData[sType & "_actualrollover"] = formData[sType & "_underrun"] - formData[sType & "_takeback"]/>

			</cfif> <!--- center ops / C1,2 calculations --->

		</cfloop>

		<!--- if C1 and C2 exist for this contract, need to add one more set of fields to handle C1+C2 --->
		<!--- Removed for JFAS 2.8
		<cfif listContainsNoCase(form.hidServiceTypes,"C1") and listContainsNoCase(form.hidServiceTypes,"C2")>

			<cfif not listContainsNoCase(form.hidServiceTypes,"C1C2")>
				<cfset form.hidServiceTypes = listAppend(form.hidServiceTypes,"C1C2")/>
			</cfif>

			<cfset formData.C1C2_costCatDesc = "O/A + CTS">
			<cfset formData.C1C2_cumContractValueEstimate = formData.C1_cumContractValueEstimate + formData.C2_cumContractValueEstimate>
			<cfset formData.C1C2_cumContractCost = formData.C1_cumContractCost + formData.C2_cumContractCost>
			<cfset formData.C1C2_underrun = formData.C1_underrun + formData.C2_underrun>
			<cfset formData.C1C2_contractYearBudget = formData.C1_contractYearBudget + formData.C2_contractYearBudget >
			<cfset formData.C1C2_rolloverRate = rstContractorPerformanceRef.roPercentOACTS />
			<cfset formData.C1C2_rolloverCap = formData.C1_rolloverCap + formData.C2_rolloverCap />
			<cfif formData.C1C2_underrun lte formData.C1C2_rolloverCap>
				<cfset formData.C1C2_excessUnderrun = 0 />
			<cfelse>
				<cfset formData.C1C2_excessUnderrun = formData.C1C2_underrun - formData.C1C2_rolloverCap />
			</cfif>
			<cfif formData.C1_excessUnderrun gte formData.C1C2_excessUnderrun>
				<cfset formData.C1_excessUnderrunTakeback = formData.C1C2_excessUnderrun/>
			<cfelse>
				<cfset formData.C1_excessUnderrunTakeback = formData.C1_excessUnderrun/>
			</cfif>
			<cfif formData.C2_excessUnderrun gte formData.C1C2_excessUnderrun>
				<cfset formData.C2_excessUnderrunTakeback = formData.C1C2_excessUnderrun/>
			<cfelse>
				<cfset formData.C2_excessUnderrunTakeback = formData.C2_excessUnderrun/>
			</cfif>
			<cfset formData.C1_takeback = C1_excessUnderrunTakeback/>
			<cfset formData.C2_takeback = C2_excessUnderrunTakeback/>

			<cfset formData.C1C2_actualrollover = formData.C1C2_underrun - C1C2_excessUnderrun />
			<cfif (formData.C1_underrun lte 0) and (formData.C2_underrun lte 0)>
				<cfset formData.C1_actualrollover = formData.C1_underrun/>
				<cfset formData.C2_actualrollover = formData.C2_underrun/>
			<cfelseif (formData.C1_underrun lte 0) and (formData.C1C2_underrun gte 0)>
				<cfset formData.C1_actualrollover = 0/>
				<cfset formData.C2_actualrollover = formData.C1C2_actualrollover/>
			<cfelseif (formData.C1_underrun lte 0) and (formData.C1C2_underrun lte 0)>
				<cfset formData.C1_actualrollover = formData.C1C2_actualrollover/>
				<cfset formData.C2_actualrollover = 0/>
			<cfelseif (formData.C2_underrun lte 0) and (formData.C1C2_underrun gte 0)>
				<cfset formData.C1_actualrollover = formData.C1C2_actualrollover/>
				<cfset formData.C2_actualrollover = 0/>
			<cfelseif (formData.C2_underrun lte 0) and (formData.C1C2_underrun lte 0)>
				<cfset formData.C1_actualrollover = 0/>
				<cfset formData.C2_actualrollover = formData.C1C2_actualrollover/>
			</cfif>
		</cfif>
		--->

		<cfreturn formData/>

	</cffunction>



	<cffunction name="saveYearEndData" access="public" returntype="struct" hint="Commits Year End Recon to the database">
		<cfargument name="formData" type="struct" required="yes"/>

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">
		<cfset totalTakeBack = 0/>

		<!--- remove C1C2 from list of service types
		<cfset formData.hidServiceTypes = replace(formData.hidServiceTypes, "C1C2", "", "all")>--->

		<cftransaction>
        
                <!--- insert year-end parent record --->
                <cfquery name="qryInsertReconDetails" datasource="#request.dsn#">
                insert	into aapp_yearend_recon (
                        aapp_num,
                        contract_year,
                        contract_year_start_date,
                        contract_year_end_date,
                        date_2110_report,
                        comments,
                        form_version,
                        update_user_id,
                        update_function,
                        update_time)
                values	(
                        #arguments.formData.hidaapp#,
                        #arguments.formData.hidContractYear#,
                        to_date('#dateformat(arguments.formData.hidContractYearStartDate, "mm/dd/yyyy")#', 'MM/DD/YYYY'),
                        to_date('#dateformat(arguments.formData.hidContractYearEndDate, "mm/dd/yyyy")#', 'MM/DD/YYYY'),
                        to_date('#dateformat(arguments.formData.hidReportingDate, "mm/dd/yyyy")#', 'MM/DD/YYYY'),
                        '#txtComments#',
                        #arguments.formData.hidFormVersion#,
                        '#session.userID#',
                        '#request.auditVarInsert#',
                        sysdate)
                </cfquery>
        
                <!--- loop through service types --->
                <cfloop index="sType" list="#formData.hidServiceTypes#">
        
                    <cfset takebackAmount = replace(arguments.formData[sType & "_takeback"],",","","all")/>
                    <cfset rolloverAmount = replace(arguments.formData[sType & "_actualRollover"],",","","all")/>
                    <cfset lowOBStakebackAmount = 0>
        
                    <!--- get cost cat id --->
                    <cfinvoke component="#application.paths.components#lookup" method="getCostCategories" costCatCode="#sType#" returnvariable="rstCostCat"/>
        
        
                    <!--- take back? --->
                    <cfif takebackAmount gt 0>
        
                        <!--- get current program year --->
                        <cfset currentPY = application.outility.getCurrentSystemProgramYear (	)>
        
                        <cfif sType eq "A">
        
                            <cfset lowOBStakebackAmount = replace(arguments.formData[sType & "_lowOBStakeback"],",","","all")/>
                            <cfset excessUnderrunTakeback = takebackAmount - lowOBStakebackAmount>
        
                            <cfif lowOBStakebackAmount gt 0> <!--- low OBS takeback? --->
        
                                <!--- write negative FOP record --->
                                <cfinvoke component="#application.paths.components#aapp_adjustment"
                                    method="insertFOP"
                                    aapp="#arguments.formData.hidaapp#"
                                    description="Low OBS Takeback, Year #arguments.formData.hidContractYear#"
                                    programYear="#currentPY#"
                                    amount="#evaluate(0-lowOBStakebackAmount)#"
                                    costCatID="#rstCostCat.costCatID#"
                                    adjustmentType="YE"
                                    returnvariable="lowOBS_FOPid" />
        
                                <!--- write negative adjustment --->
                                <cfinvoke component="#application.paths.components#aapp_adjustment"
                                    method="insertAdjustment"
                                    aapp="#arguments.formData.hidaapp#"
                                    description="Low OBS Takeback, Year #arguments.formData.hidContractYear#"
                                    includeECP="1"
                                    modRequired="1"
                                    ongoing="0"
                                    currentCost="#evaluate(0-lowOBStakebackAmount)#"
                                    fullCost="#evaluate(0-lowOBStakebackAmount)#"
                                    costCat="#rstCostCat.costCatID#"
                                    adjustmentType="YE"
                                    returnvariable="lowobs_AdjID">
                                <cfinvoke component="#application.paths.components#aapp_adjustment"
                                    method="insertAdjustmentCost"
                                    adjustmentID="#lowobs_AdjID#"
                                    contractYear="#arguments.formData.hidContractYear#"
                                    amount="#evaluate(0-lowOBStakebackAmount)#"
                                    fixed="1">
                            </cfif>
        
                            <cfif excessUnderrunTakeback gt 0> <!--- excess underrun takeback? --->
                                <!--- write negative FOP record --->
                                <cfinvoke component="#application.paths.components#aapp_adjustment"
                                    method="insertFOP"
                                    aapp="#arguments.formData.hidaapp#"
                                    description="Year-end Recon, Year #arguments.formData.hidContractYear#"
                                    programYear="#currentPY#"
                                    amount="#evaluate(0-excessUnderrunTakeback)#"
                                    costCatID="#rstCostCat.costCatID#"
                                    adjustmentType="YE"
                                    returnvariable="excess_FOPid" />
        
                                <!--- write negative adjustment --->
                                <cfinvoke component="#application.paths.components#aapp_adjustment"
                                    method="insertAdjustment"
                                    aapp="#arguments.formData.hidaapp#"
                                    description="Year-end Recon, Year #arguments.formData.hidContractYear#"
                                    includeECP="1"
                                    modRequired="1"
                                    ongoing="0"
                                    currentCost="#evaluate(0-excessUnderrunTakeback)#"
                                    fullCost="#evaluate(0-excessUnderrunTakeback)#"
                                    costCat="#rstCostCat.costCatID#"
                                    adjustmentType="YE"
                                    returnvariable="excess_AdjID">
                                <cfinvoke component="#application.paths.components#aapp_adjustment"
                                    method="insertAdjustmentCost"
                                    adjustmentID="#excess_AdjID#"
                                    contractYear="#arguments.formData.hidContractYear#"
                                    amount="#evaluate(0-excessUnderrunTakeback)#"
                                    fixed="1">
                            </cfif>
        
                        <cfelse>  <!--- C1, C2 --->
        
                            <!--- write negative FOP record --->
                            <cfinvoke component="#application.paths.components#aapp_adjustment"
                                method="insertFOP"
                                aapp="#arguments.formData.hidaapp#"
                                description="Year-end Recon, Year #arguments.formData.hidContractYear#"
                                programYear="#currentPY#"
                                amount="#evaluate(0-takebackAmount)#"
                                costCatID="#rstCostCat.costCatID#"
                                adjustmentType="YE"
                                returnvariable="takeback_FOPid" />
        
                            <!--- write negative adjustment --->
                            <cfinvoke component="#application.paths.components#aapp_adjustment"
                                method="insertAdjustment"
                                aapp="#arguments.formData.hidaapp#"
                                description="Year-end Recon, Year #arguments.formData.hidContractYear#"
                                includeECP="1"
                                modRequired="1"
                                ongoing="0"
                                currentCost="#evaluate(0-takebackAmount)#"
                                fullCost="#evaluate(0-takebackAmount)#"
                                costCat="#rstCostCat.costCatID#"
                                adjustmentType="YE"
                                returnvariable="takeback_AdjID">
                            <cfinvoke component="#application.paths.components#aapp_adjustment"
                                method="insertAdjustmentCost"
                                adjustmentID="#takeback_AdjID#"
                                contractYear="#arguments.formData.hidContractYear#"
                                amount="#evaluate(0-takebackAmount)#"
                                fixed="1">
        
                        </cfif>
        
                        <!--- keep running total of takeback amounts --->
                        <cfset totalTakeBack = totalTakeback + takebackAmount/>
        
                    </cfif> <!--- end of takebacks --->
        
        
                    <!--- non-zero rollover? --->
                    <cfif rolloverAmount neq 0>
        
                        <!--- write adjustment to contract year being closed out --->
                        <cfinvoke component="#application.paths.components#aapp_adjustment"
                            method="insertAdjustment"
                            aapp="#arguments.formData.hidaapp#"
                            description="Variance Adjustment, Year #arguments.formData.hidContractYear# Reconciliation"
                            includeECP="1"
                            modRequired="0"
                            ongoing="0"
                            currentCost="#evaluate(0-rolloverAmount)#"
                            fullCost="#evaluate(0-rolloverAmount)#"
                            costCat="#rstCostCat.costCatID#"
                            adjustmentType="YE"
                            returnvariable="current_rollover_newAdjID">
                        <cfinvoke component="#application.paths.components#aapp_adjustment"
                            method="insertAdjustmentCost"
                            adjustmentID="#current_rollover_newAdjID#"
                            contractYear="#arguments.formData.hidContractYear#"
                            amount="#evaluate(0-rolloverAmount)#"
                            fixed="1">
        
                        <!--- write adjustment to next contract year --->
                        <cfinvoke component="#application.paths.components#aapp_adjustment"
                            method="insertAdjustment"
                            aapp="#arguments.formData.hidaapp#"
                            description="Variance Adjustment, Year #arguments.formData.hidContractYear# Reconciliation"
                            includeECP="1"
                            modRequired="0"
                            ongoing="0"
                            currentCost="#rolloverAmount#"
                            fullCost="#rolloverAmount#"
                            costCat="#rstCostCat.costCatID#"
                            adjustmentType="YE"
                            returnvariable="next_rollover_newAdjID">
                        <cfinvoke component="#application.paths.components#aapp_adjustment"
                            method="insertAdjustmentCost"
                            adjustmentID="#next_rollover_newAdjID#"
                            contractYear="#evaluate(arguments.formData.hidContractYear+1)#"
                            amount="#rolloverAmount#"
                            fixed="1">
        
                    </cfif> <!--- rollover? --->
        
                    <!--- log all details to year end recon tables --->
                    <cfquery name="qryInsertReconDetails" datasource="#request.dsn#">
                    insert	into aapp_yearend_recon_amount (
                            aapp_num,
                            contract_year,
                            cost_cat_id,
                            <cfif sType eq "A">
                                perf_rating_weighted,
                                perf_rating_seg1,
                                perf_rating_seg2,
                                date_seg1_start,
                                date_seg1_end,
                                date_seg2_start,
                                date_seg2_end,
                                sy_planned,
                                sy_actual,
                                sy_costper,
                                lowobs_rate,
                                lowobs_target,
                                lowobs_takeback,
                                lowobs_deficiency,
                                net_rollover,
                            </cfif>
                            under_run,
                            excess_underrun,
                            roll_over,
                            take_back,
                            <cfif takebackAmount gt 0 and isDefined("takeback_FOPid")>takeback_fop_id,</cfif>
                            <cfif takebackAmount gt 0 and isDefined("takeback_ADJid")>takeback_adj_id,</cfif>
                            <cfif isDefined("lowOBStakebackAmount") and lowOBStakebackAmount gt 0 and isDefined("lowOBS_FOPid")>takeback_obs_fop_id,</cfif>
                            <cfif isDefined("lowOBStakebackAmount") and lowOBStakebackAmount gt 0 and isDefined("lowobs_AdjID")>takeback_obs_adj_id,</cfif>
                            <cfif isDefined("excessUnderrunTakeback") and excessUnderrunTakeback gt 0 and isDefined("excess_FOPid")>takeback_underrun_fop_id,</cfif>
                            <cfif isDefined("excessUnderrunTakeback") and excessUnderrunTakeback gt 0 and isDefined("excess_Adjid")>takeback_underrun_adj_id,</cfif>
                            <cfif takebackAmount gt 0 and isDefined("takeback_newAdjID")>takeback_adj_id,</cfif>
                            <cfif rolloverAmount neq 0 and isDefined("current_rollover_newAdjID")>rollover_curr_adj_id,</cfif>
                            <cfif rolloverAmount neq 0 and isDefined("next_rollover_newAdjID")>rollover_next_adj_id,</cfif>
                            cum_cont_value,
                            cum_cont_cost,
                            cy_budget,
                            roll_over_rate,
                            roll_over_cap,
                            update_user_id,
                            update_function,
                            update_time)
                    values	(
                            #arguments.formData.hidaapp#,
                            #arguments.formData.hidContractYear#,
                            #rstCostCat.costCatID#,
                            <cfif sType eq "A">
                                #replace(arguments.formData.A_perfRatingWeighted, ",", "", "all")#,
                                #replace(arguments.formData.A_perfRatingSeg1, ",", "", "all")#,
                                #replace(arguments.formData.A_perfRatingSeg2, ",", "", "all")#,
                                to_date('#dateformat(arguments.formData.hidSeg1_StartDate, "mm/dd/yyyy")#', 'MM/DD/YYYY'),
                                to_date('#dateformat(arguments.formData.hidSeg1_EndDate, "mm/dd/yyyy")#', 'MM/DD/YYYY'),
                                to_date('#dateformat(arguments.formData.hidSeg2_StartDate, "mm/dd/yyyy")#', 'MM/DD/YYYY'),
                                to_date('#dateformat(arguments.formData.hidSeg2_EndDate, "mm/dd/yyyy")#', 'MM/DD/YYYY'),
                                #replace(arguments.formData.A_SYplanned, ",", "", "all")#,
                                #replace(arguments.formData.A_SYactual, ",", "", "all")#,
                                #replace(arguments.formData.A_SYcostper, ",", "", "all")#,
                                #arguments.formData.A_lowOBSrate#,
                                #replace(arguments.formData.A_lowOBStarget, ",", "", "all")#,
                                #replace(arguments.formData.A_lowOBStakeback, ",", "", "all")#,
                                #replace(arguments.formData.A_lowOBSdeficiency, ",", "", "all")#,
                                #replace(arguments.formData[sType & "_netRollover"],",","","all")#,
                            </cfif>
                            #replace(arguments.formData[sType & "_underrun"],",","","all")#,
                            #replace(arguments.formData[sType & "_excessUnderrun"],",","","all")#,
                            #rolloverAmount#,
                            #takebackAmount#,
                            <cfif takebackAmount gt 0 and isDefined("takeback_FOPid")>#takeback_FOPid#,</cfif>
                            <cfif takebackAmount gt 0 and isDefined("takeback_ADJid")>#takeback_ADJid#,</cfif>
                            <cfif isDefined("lowOBStakebackAmount") and lowOBStakebackAmount gt 0 and isDefined("lowOBS_FOPid")>#lowOBS_FOPid#,</cfif>
                            <cfif isDefined("lowOBStakebackAmount") and lowOBStakebackAmount gt 0 and isDefined("lowOBS_Adjid")>#lowOBS_Adjid#,</cfif>
                            <cfif isDefined("excessUnderrunTakeback") and excessUnderrunTakeback gt 0 and isDefined("excess_FOPid")>#excess_FOPid#,</cfif>
                            <cfif isDefined("excessUnderrunTakeback") and excessUnderrunTakeback gt 0 and isDefined("excess_Adjid")>#excess_Adjid#,</cfif>
                            <cfif rolloverAmount neq 0 and isDefined("current_rollover_newAdjID")>#current_rollover_newAdjID#,</cfif>
                            <cfif rolloverAmount neq 0 and isDefined("next_rollover_newAdjID")>#next_rollover_newAdjID#,</cfif>
                            #replace(arguments.formData[sType & "_cumContractValueEstimate"],",","","all")#,
                            #replace(arguments.formData[sType & "_cumContractCost"],",","","all")#,
                            #replace(arguments.formData[sType & "_contractYearBudget"],",","","all")#,
                            #arguments.formData[sType & "_rolloverRate"]#,
                            #replace(arguments.formData[sType & "_rolloverCap"],",","","all")#,
                            '#session.userID#',
                            '#request.auditVarInsert#',
                            sysdate)
                    </cfquery>
        
        
                </cfloop>
        
        
                <!--- if takeback, write positive FOP record (for DOL contingency contract)
                    as of JFAS 2.8, this code has been disabled
        
                <cfif totalTakeback gt 0>
                    <!--- get AAPP Num of NO Contingency Account --->
                    <cfinvoke component="#application.paths.components#lookup" method="getAAPPRef" refType="HQ_CONTING_OPS" returnvariable="HQaapp"/>
                    <cfinvoke component="#application.paths.components#lookup" method="getCostCategories" costCatCode="S" returnvariable="rstCostCat"/>
        
                    <cfinvoke component="#application.paths.components#aapp_adjustment"
                        method="insertFOP"
                        aapp="#HQaapp#"
                        description="Year-end Underrun, Year #arguments.formData.hidContractYear#, AAPP No: #arguments.formData.hidaapp#"
                        programYear="#currentPY#"
                        amount="#totalTakeback#"
                        costCatID="#rstCostCat.costCatID#"
                        adjustmentType="YE"
                        returnvariable="hq_newFOPid" />
        
                    <!--- record HQ FOP ID --->
                    <cfquery name="qryUpdateYearEnd" datasource="#request.dsn#">
                    update	aapp_yearend_recon_amount
                    set		takeback_hq_fop_id = #hq_newFOPid#
                    where	aapp_num = #arguments.formData.hidaapp# and
                            contract_year = #arguments.formData.hidContractYear#
                    </cfquery>
        
                </cfif>  --->
        
                <!--- insert system audit record --->
                <cfset application.outility.insertSystemAudit (
                    aapp="#arguments.formData.hidaapp#",
                    statusID="#request.statusID#",
                    sectionID="400",
                    description="Year-end Reconcililation Performed, Contract Year #arguments.formData.hidContractYear#",
                    userID="#session.userID#")>

               <cfstoredproc procedure="JFAS_SNAPSHOT_PKG.sp_updAAPP_CONTRACT_SNAPSHOT" returncode="no">
                    <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="argAAPP_NUM" value="#arguments.formData.hidaapp#" null="no">
                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUser_ID" value="#session.userid#" null="no">
                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUpdate_Notes" value="Updated from Year-End Reconciliation" null="no">
                </cfstoredproc>				

		</cftransaction>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew() />
		<cfset stcResults.success = success />
		<cfset stcResults.errorMessages = errorMessages />
		<cfset stcResults.errorFields = errorFields />

		<cfreturn stcResults>
	</cffunction>


	<cffunction name="deleteYearEndData" access="public" returntype="void" hint="removes the records associated with a particular year=end recon">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfargument name="contractYear" type="numeric" required="yes">

		<!--- NOTE: As of Release 2.8, this ability to "Undo a Reconciliation" is not available. May be temprorary --->

		<cftransaction>
		<!--- need to get all adjustment IDs for all recon records --->
		<cfquery name="qryGetReconadjustments" datasource="#request.dsn#">
		select	takeback_fop_id,
				takeback_obs_fop_id,
				takeback_underrun_fop_id,
				takeback_hq_fop_id,
				takeback_adj_id,
				takeback_obs_adj_id,
				takeback_underrun_adj_id,
				rollover_curr_adj_id,
				rollover_next_adj_id
		from	aapp_yearend_recon_amount
		where	aapp_num = #arguments.aapp# and
				contract_year = #arguments.contractYear#
		</cfquery>

		<!--- build list of adjustment IDs --->
		<cfset lstDeleteAdjIDs = "">
		<cfset lstDeleteAdjIDs = listAppend(lstDeleteAdjIDs,valuelist(qryGetReconadjustments.takeback_adj_id)) >
		<cfset lstDeleteAdjIDs = listAppend(lstDeleteAdjIDs,valuelist(qryGetReconadjustments.takeback_obs_adj_id)) >
		<cfset lstDeleteAdjIDs = listAppend(lstDeleteAdjIDs,valuelist(qryGetReconadjustments.takeback_underrun_adj_id)) >
		<cfset lstDeleteAdjIDs = listAppend(lstDeleteAdjIDs,valuelist(qryGetReconadjustments.rollover_curr_adj_id)) >
		<cfset lstDeleteAdjIDs = listAppend(lstDeleteAdjIDs,valuelist(qryGetReconadjustments.rollover_next_adj_id)) >

		<cfset lstDeleteFOPIDs = "">
		<cfset lstDeleteFOPIDs = listAppend(lstDeleteFOPIDs,valuelist(qryGetReconadjustments.takeback_fop_id)) >
		<cfset lstDeleteFOPIDs = listAppend(lstDeleteFOPIDs,valuelist(qryGetReconadjustments.takeback_obs_fop_id)) >
		<cfset lstDeleteFOPIDs = listAppend(lstDeleteFOPIDs,valuelist(qryGetReconadjustments.takeback_underrun_fop_id)) >
		<cfset lstDeleteFOPIDs = listAppend(lstDeleteFOPIDs,valuelist(qryGetReconadjustments.takeback_hq_fop_id)) >

		<!--- delete records from yearend recon tables --->
		<cfquery name="qryDeleteReconAmount" datasource="#request.dsn#">
		delete
		from	aapp_yearend_recon_amount
		where	aapp_num = #arguments.aapp# and
				contract_year = #arguments.contractYear#
		</cfquery>
		<cfquery name="qryDeleteRecon" datasource="#request.dsn#">
		delete
		from	aapp_yearend_recon
		where	aapp_num = #arguments.aapp# and
				contract_year = #arguments.contractYear#
		</cfquery>

		<cfif listLen(lstDeleteAdjIDs) gt 0>

			<cfloop list="#lstDeleteAdjIDs#" index="adjID">

				<!--- delete all adjustment cost records --->
				<cfquery name="qryDeleteAdjustmentCost" datasource="#request.dsn#">
				delete
				from	adjustment_cost
				where	adjustment_id = #adjID#
				</cfquery>

				<!--- delete all adjustment records --->
				<cfquery name="qryDeleteAdjustment" datasource="#request.dsn#">
				delete
				from	adjustment
				where	adjustment_id = #adjID#
				</cfquery>

			</cfloop>

		</cfif>

		<cfif listLen(lstDeleteFOPIDs) gt 0>

			<cfloop list="#lstDeleteFOPIDs#" index="fopID">

				<!--- set all FOP amounts to zero (can't delete them) --->
				<cfquery name="qryZeroFOPAmounts" datasource="#request.dsn#">
				update	fop	set
						amount = 0,
						update_user_id = '#session.userID#',
						update_function = '#request.auditVarUpdate#',
						update_time = sysdate
				where	fop_id = #fopID#
				</cfquery>

			</cfloop>

		</cfif>

		<!--- insert system audit record --->
	<cfset application.outility.insertSystemAudit (
			aapp="#arguments.aapp#",
			statusID="#request.statusID#",
			sectionID="400",
			description="Year-end Reconcililation Removed, Contract Year #arguments.contractYear#",
			userID="#session.userID#")>

		</cftransaction>

	</cffunction>



	<cffunction name="getContractorPerformanceRef" access="public" returntype="query" hint="Returns query with contractor performance rating info">

		<cfquery name="qryContractorPerformanceRef" datasource="#request.dsn#" maxrows="1">
		select	perf_rating_good as perfRatingGood,
				perf_rating_exel as perfRatingExel,
				ro_percent_reg as roPercentReg,
				ro_percent_good as roPercentGood,
				ro_percent_exel as roPercentExel,
				ro_cap_amount_reg as roCapAmountReg,
				ro_cap_amount_good as roCapAmountGood,
				ro_percent_oacts as roPercentOACTS,
				ro_cap_amount_oacts as roCapAmountOACTS,
				lowobs_takeback_rate as lowOBStakebackRate
		from	contract_performance_ref
		</cfquery>

		<cfreturn qryContractorPerformanceRef>

	</cffunction>



	<cffunction name="getCloseOutListing" access="public" returntype="query" hint="Gets high-level listing of existing year-end recon records">
		<cfargument name="aapp" type="numeric" required="yes" />
		<cfargument name="mode" type="string" required="no" default="existing" />

		<!--- pull existing closeout data from database (might not exist) --->
		<cfquery name="qryCloseOutData" datasource="#request.dsn#">
		select	aapp_closeout.aapp_closeout_id as closeoutID,
				to_date(aapp_closeout.update_time) as dateCloseout
		from	aapp_closeout
		where	aapp_num = #arguments.aapp#
		order	by  aapp_closeout.aapp_closeout_id
		</cfquery>

		<cfreturn qryCloseOutData>

	</cffunction>



	<cffunction name="getCloseOutData" access="public" returntype="struct" hint="Gets data to populate Close Out Data Form">
		<cfargument name="aapp" type="numeric" required="yes" />
		<cfargument name="closeoutID" type="numeric" required="no" default="0" />

		<cfset stcCloseOutData = StructNew()>

		<!--- first of all, determine whether this is going to display existing data --->
		<!--- or projections for a pending close-out --->
		<cfif arguments.closeoutID neq 0> <!--- existing closeout record, pull from database --->

			<!--- query aapp closeout tables to get data to populate form --->
			<cfquery name="qryGetCloseOutData" datasource="#request.dsn#" maxrows="1">
			select	takeback_ops_amount as hqOPStakeback,
					takeback_cra_amount as hqCRAtakeback,
					footfund_total,
					footfund_total_ops,
					footfund_total_cra,
					footfund_active_ops,
					footfund_active_cra,
					footfund_expired_ops,
					footfund_expired_cra,
					footfundchange_total,
					footfundchange_total_ops,
					footfundchange_total_cra,
					footfundchange_active_ops,
					footfundchange_active_cra,
					footfundchange_expired_ops,
					footfundchange_expired_cra,
					comments,
					update_time as closeoutDate,
					form_version as formVersion,
					mod_num as mod_num
			from	aapp_closeout
			where	aapp_closeout.aapp_num = #arguments.aapp# and
					aapp_closeout.aapp_closeout_id = #arguments.closeoutID#
			</cfquery>


			<cfquery name="qryGetCloseOutAmounts" datasource="#request.dsn#">
			select	date_2110_report as reportingDate,
					cost_cat_code as costCatCode,
					cost_cat_desc as costCatDesc,
					aapp_closeout_amount.cost_cat_id as costCatID,
					cum_cont_oblig as contractorFinal,
					cum_fop_amount as budgetAuth,
					cum_cont_oblig - cum_fop_amount as FMSFOPvariance,
					fop_amount as fopChangeAmount,
					fop_carryover_amount as rollover,
					hq_adjust_amount as hqAdjustment,
					nvl(cum_ecp_value,0) as cumulativeECP,
					nvl(cum_ecp_value,0) - cum_fop_amount as ECPFOPvariance,
					cum_cont_oblig - nvl(cum_ecp_value,0) as FMSECPvariance,
					ecp_adjust_amount as ECPadjustment,
					mod_funding as modFunding,
					cum_fop_amount - mod_funding as FOPMODvariance
			from	aapp_closeout, aapp_closeout_amount, lu_cost_cat
			where	aapp_closeout.aapp_closeout_id = #arguments.closeoutID# and
					aapp_closeout.aapp_closeout_id = aapp_closeout_amount.aapp_closeout_id and
					aapp_closeout_amount.cost_cat_id = lu_cost_cat.cost_cat_id
			order	by cost_cat_code
			</cfquery>

			<cfset stcCloseOutData.rstFOPRecords = qryGetCloseOutAmounts>

			<cfset stcCloseOutData.foot_funding_ops_total = qryGetCloseOutData.footfund_total_ops>
			<cfset stcCloseOutData.foot_funding_cra_total = qryGetCloseOutData.footfund_total_cra>
			<cfset stcCloseOutData.foot_funding_total = qryGetCloseOutData.footfund_total>
			<cfset stcCloseOutData.foot_funding_ops_active = qryGetCloseOutData.footfund_active_ops>
			<cfset stcCloseOutData.foot_funding_cra_active = qryGetCloseOutData.footfund_active_cra>
			<cfset stcCloseOutData.foot_funding_ops_expired = qryGetCloseOutData.footfund_expired_ops>
			<cfset stcCloseOutData.foot_funding_cra_expired = qryGetCloseOutData.footfund_expired_cra>
			<cfset stcCloseOutData.foot_funding_change_ops_total = qryGetCloseOutData.footfundchange_total_ops>
			<cfset stcCloseOutData.foot_funding_change_cra_total = qryGetCloseOutData.footfundchange_total_cra>
			<cfset stcCloseOutData.foot_funding_change_total = qryGetCloseOutData.footfundchange_total>
			<cfset stcCloseOutData.foot_funding_change_ops_active = qryGetCloseOutData.footfundchange_active_ops>
			<cfset stcCloseOutData.foot_funding_change_cra_active = qryGetCloseOutData.footfundchange_active_cra>
			<cfset stcCloseOutData.foot_funding_change_ops_expired = qryGetCloseOutData.footfundchange_expired_ops>
			<cfset stcCloseOutData.foot_funding_change_cra_expired = qryGetCloseOutData.footfundchange_expired_cra>

			<cfset stcCloseOutData.hqOPStakeback = qryGetCloseOutData.hqOPStakeback>
			<cfset stcCloseOutData.hqCRAtakeback = qryGetCloseOutData.hqCRAtakeback>
			<cfset stcCloseOutData.comments = qryGetCloseOutData.comments>
			<cfset stcCloseOutData.closeOutDate = qryGetCloseOutData.closeOutDate>
			<cfset stcCloseOutData.formVersion = qryGetCloseOutData.formVersion>
			<cfset stcCloseOutData.mod_num = qryGetCloseOutData.mod_num>


		<cfelse> <!--- closeoutID = 0, pending close-out, get values from 2110 data --->

			<!--- multi-step process --->
			<!--- 1. Get general AAPP info --->
			<!--- 2. Get lastest FMS data (per cost category) --->
			<!--- 3. Get lastest FOP data (per cost category) --->
			<!--- 4. Get lastest MOD data (per cost category - but may not exist) --->
			<!--- 5. Get lastest ECP data (for certain cost categories - depends on ECP) --->

			<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#arguments.aapp#" returnvariable="rstAAPPGeneral"/>

			<!--- is contract due for close-out (past end date)? --->
			<cfif datecompare(rstAAPPGeneral.dateEnd, now()) gt -2>

				<!--- get latest version number of Year-end Recon form --->
				<cfset formVersion = application.outility.getFormVersion ( formType="CLOSE" )>

				<!--- FMS / FOP / ECP / MOD DATA Grab: BEGIN --->

				<!--- get 2110 / ECP data --->
				<cfquery name="qryGet2110Report" datasource="#request.dsn#">
				select	center_2110_id as reportID,
						rep_date as reportingDate
				from	center_2110_data
				where	aapp_num = #arguments.aapp# and
						rep_date =
							(select	max(rep_date)
							from	center_2110_data
							where	aapp_num = #arguments.aapp#)
				</cfquery>


				<!--- get the 2110 costs associated with this contract year --->
				<cfset qryGet2110Amounts = this.get2110TotalCosts(arguments.aapp) />
				<!--- consolidate the 2110 data --->
				<cfquery name="qryGetCloseOut" dbtype="query">
				select	qryGet2110Report.reportID,
						costCatID,
						costCatCode,
						costCatDesc,
						reportingDate,
						cumContractOblig as contractorFinal
				from	qryGet2110Report, qryGet2110Amounts
				where	qryGet2110Report.reportID = qryGet2110Amounts.reportID
				</cfquery>
				<!---<cfdump var="#qryGetCloseOut#" label="qryGetCloseOut">--->

				<!--- get cumulative FOP data --->
				<cfinvoke component="#application.paths.components#aapp_adjustment" method="getCumulativeFOPAmounts" aapp="#arguments.aapp#" returnvariable="qryFOPTotals">

				<!--- join FMS and FOP queries --->
				<cfquery name="qryGetCloseOut_FOP" dbtype="query">
				select	reportID,
						qryGetCloseOut.costCatID,
						qryGetCloseOut.costCatCode,
						qryFOPTotals.costCatDesc,
						reportingDate,
						contractorFinal,
						totalFOPAmount as budgetAuth,
						contractorFinal - totalFOPAmount as FMSFOPvariance,
						0 as cumulativeECP,
						'' as ECPFOPvariance,
						'' as FMSECPvariance,
						'' as ECPadjustment,
						'' as fopChangeAmount,
						'' as rollover,
						'' as hqAdjustment,
						'' as modFunding,
						'' as FOPMODvariance
				from	qryGetCloseOut, qryFOPTotals
				where	qryGetCloseOut.costCatID = qryFOPTotals.costCatID
				</cfquery>

				<!--- get latest mod funding data (may not exist) --->
				<cfinvoke component="#application.paths.components#aapp_mod" method="getLatestModbyAAPP" aapp="#arguments.aapp#" returnvariable="stcModFunding">
				<cfif stcModFunding.results>
					<cfset stcCloseOutData.mod_num = stcModFunding.modData.modNum>
					<cfset rowCount = 1>
					<cfloop query="qryGetCloseOut_FOP">
						<!--- loop through results, get cumulative ECP value --->
						<cfquery name="qryGetFunding" dbtype="query">
						select	fundingTotal
						from	stcModFunding.modFundingData
						where	costCatID = #costCatID#
						</cfquery>
						<!--- set column values for Mod Funding, and FMS/MOD variance --->
						<cfset temp = QuerySetCell(qryGetCloseOut_FOP,"modFunding",qryGetFunding.fundingTotal,rowCount)>
						<cfset temp = QuerySetCell(qryGetCloseOut_FOP,"FOPMODvariance",evaluate(budgetAuth - qryGetFunding.fundingTotal),rowCount)>
						<cfset rowCount = rowCount + 1>
					</cfloop>
				<cfelse>
					<cfset stcCloseOutData.mod_num = ''>
				</cfif>


				<!--- get ECP cumulative values (may only exist in A, C1, C2, S - depends on contract) --->
				<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileSummary" aapp="#arguments.aapp#" returnvariable="qryCumulativeECP" />

				<cfset rowCount = 1>
				<cfloop query="qryGetCloseOut_FOP">
					<!--- loop through results, get cumulative ECP value --->
					<cfquery name="qryGetCumECP" dbtype="query">
					select	cumulative
					from	qryCumulativeECP
					where	contract_type_code = '#costCatCode#'
					</cfquery>
					<!--- set column values for ECP cumulateive, and ECP/FOP variance --->
					<cfif qryGetCumECP.cumulative neq ''>
						<cfset temp = QuerySetCell(qryGetCloseOut_FOP,"cumulativeECP",qryGetCumECP.cumulative,rowCount)>
						<cfset temp = QuerySetCell(qryGetCloseOut_FOP,"ECPFOPvariance",evaluate(qryGetCumECP.cumulative-budgetAuth),rowCount)>
						<cfset temp = QuerySetCell(qryGetCloseOut_FOP,"FMSECPvariance",evaluate(contractorFinal - qryGetCumECP.cumulative),rowCount)>
					</cfif>
					<cfset rowCount = rowCount + 1>
				</cfloop>
				<!---<cfdump var="#qryGetCloseOut_FOP#" label="qryGetCloseOut_FOP">--->

				<cfset stcCloseOutData.rstFOPRecords = qryGetCloseOut_FOP>
				<!--- FMS / FOP / ECP / MOD DATA Grab: END --->

				<!--- FUNDING (DOLAR$) DATA Grab: BEGIN --->
				<cfobject component="#application.paths.components#footprint" name="objFootprint">
				<cfset stcCloseOutData.foot_funding_ops_total = objFootprint.getFOOTFunding(arguments.aapp,"OPS")>
				<cfset stcCloseOutData.foot_funding_cra_total = objFootprint.getFOOTFunding(arguments.aapp,"CRA")>
				<cfset stcCloseOutData.foot_funding_total = objFootprint.getFOOTFunding(arguments.aapp)>
				<cfset stcCloseOutData.foot_funding_ops_active = objFootprint.getFOOTFunding(arguments.aapp, "OPS", "active")>
				<cfset stcCloseOutData.foot_funding_cra_active = objFootprint.getFOOTFunding(arguments.aapp, "CRA", "active")>
				<cfset stcCloseOutData.foot_funding_ops_expired = objFootprint.getFOOTFunding(arguments.aapp, "OPS", "expired")>
				<cfset stcCloseOutData.foot_funding_cra_expired = objFootprint.getFOOTFunding(arguments.aapp, "CRA", "expired")>
				<cfset stcCloseOutData.foot_funding_change_ops_total = "">
				<cfset stcCloseOutData.foot_funding_change_cra_total = "">
				<cfset stcCloseOutData.foot_funding_change_total = "">
				<cfset stcCloseOutData.foot_funding_change_ops_active = "">
				<cfset stcCloseOutData.foot_funding_change_cra_active = "">
				<cfset stcCloseOutData.foot_funding_change_ops_expired = "">
				<cfset stcCloseOutData.foot_funding_change_cra_expired = "">

				<cfset stcCloseOutData.hqOPStakeback = "">
				<cfset stcCloseOutData.hqCRAtakeback = "">
				<cfset stcCloseOutData.comments = "">
				<cfset stcCloseOutData.closeOutDate = now()>
				<cfset stcCloseOutData.formVersion = formVersion>
				<!--- FUNDING (DOLAR$) DATA Grab: END --->

			<cfelse>
				<!--- not due for close-out, send user to home page (invalid navigation) --->
				<cflocation url="#application.paths.root#"/>
			</cfif>

		</cfif> <!--- existing close-out data, or pending? --->

		<cfreturn stcCloseOutData />

	</cffunction>



	<cffunction name="calculateCloseOutAmounts" access="public" returntype="struct" hint="Performs calculations for AAPP Close-out form">
		<cfargument name="closeoutStruct" type="struct" required="yes" />

		<!--- get complete list of cost cats (may need to create some blank rows) --->
		<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" displayFormat="primary" returnvariable="rstCostCats"/>
		<cfset lstAllCostCats = valuelist(rstCostCats.costCatCode)/>

		<!--- remove commas from numeric values --->
		<cfloop collection="#arguments.closeoutStruct#" item="i">
			<cfif not listFindNoCase("hidCostCategories,hidContractTypes,hidCarryoverCats",i)>
				<cfset arguments.closeoutStruct[i] = replaceNoCase(arguments.closeoutStruct[i],",","","all")>
			</cfif>
		</cfloop>

		<cfset arguments.closeoutStruct.hqTakeBack_ops = 0 />
		<cfset arguments.closeoutStruct.hqtakeBack_cra = 0 />
		<cfset contractorFinalTotal = 0>
		<cfset contractorFinalTotal_ops = 0>

		<!--- loop through, calculate values --->
		<cfloop index="costCat" list="#lstAllCostCats#">
			<cfif not listFindNoCase(arguments.closeoutStruct.hidCostCategories, costCat)> <!--- no cost info in this category from FOPs, add blank row in form --->
				<cfset arguments.closeoutStruct[costCat & "_costCatCode"] = costCat/>
				<cfset arguments.closeoutStruct[costCat & "_contractorFinal"] = 0/>
				<cfset arguments.closeoutStruct[costCat & "_budgetAuth"] = 0/>
				<cfset arguments.closeoutStruct[costCat & "_fopChangeAmount"] = 0/>
				<cfset arguments.closeoutStruct[costCat & "_rollover"] = ""/>
				<cfset arguments.closeoutStruct[costCat & "_hqAdjustment"] = 0/>

			<cfelse>

				<!--- FMS/FOP Variance --->
				<cfset arguments.closeoutStruct[costCat & "_FMSFOPvariance"] = arguments.closeoutStruct[costCat & "_contractorFinal"] - arguments.closeoutStruct[costCat & "_budgetAuth"]>

				<!--- FOP CHANGE AMOUNT --->
				<!--- if FMS/FOP variance is zero (even) or positive (over-run), then FOP amount = variance --->
				<cfif arguments.closeoutStruct[costCat & "_FMSFOPvariance"] gte 0>
					<cfset arguments.closeoutStruct[costCat & "_fopChangeAmount"] = arguments.closeoutStruct[costCat & "_FMSFOPvariance"]>
				<cfelse> <!--- otherwise (under-run), set default value to 0 --->
					<cfset arguments.closeoutStruct[costCat & "_fopChangeAmount"] = 0>
				</cfif>

				<!--- FOPporTUNITY (carryover) --->
				<!--- always $0 by default --->
				<cfset arguments.closeoutStruct[costCat & "_rollover"] = 0>

				<!--- NATIONAL OFFICE ADJUSTMENT --->
				<!--- equal to (0 -(FOP Amount + Rollover) --->
				<!--- Under present business rules (form ver 2) , default will be inverse of FOP amount (if over-run), $0 (if under-run)--->
				<cfset arguments.closeoutStruct[costCat & "_hqAdjustment"] = 0 - (arguments.closeoutStruct[costCat & "_fopChangeAmount"] + arguments.closeoutStruct[costCat & "_rollover"])>



				<!--- ECP adjustments --->
				<cfif listFindNoCase(arguments.closeoutStruct.hidContractTypes,costCat)>

					<!--- FMS/ECP Variance --->
					<cfset arguments.closeoutStruct[costCat & "_FMSECPvariance"] = arguments.closeoutStruct[costCat & "_contractorFinal"] - arguments.closeoutStruct[costCat & "_cumulativeECP"]>

					<cfif arguments.closeoutStruct[costCat & "_FMSECPvariance"] gte 0>
						<cfset arguments.closeoutStruct[costCat & "_ECPadjustment"] = arguments.closeoutStruct[costCat & "_FMSECPvariance"]>
					<cfelse>
						<cfset arguments.closeoutStruct[costCat & "_ECPadjustment"] = 0>
					</cfif>
				</cfif>
			</cfif>

			<!--- keep running total of contractor obs (for use in foot funding section below) --->
			<cfset contractorFinalTotal = contractorFinalTotal + arguments.closeoutStruct[costCat & "_contractorFinal"]>
			<cfif not listFindNoCase("B1",costCat)>
				<cfset contractorFinalTotal_ops = contractorFinalTotal_ops + arguments.closeoutStruct[costCat & "_contractorFinal"]>
			</cfif>
		</cfloop>

		<cfif arguments.closeoutStruct.B1_hqAdjustment neq "">
			<cfset arguments.closeoutStruct.hqtakeBack_cra = arguments.closeoutStruct.B1_hqAdjustment />	<!--- CRA takeback --->
		<cfelse>
			<cfset arguments.closeoutStruct.hqtakeBack_cra = 0>
		</cfif>

		<!--- calculate Indicated Funding Changes --->
		<cfset arguments.closeoutStruct.txtFootFundingChangeOPSTotal = contractorFinalTotal_ops - arguments.closeoutStruct.txtFootFundingOpsTotal>
		<cfset arguments.closeoutStruct.txtFootFundingChangeCRATotal = contractorFinalTotal - contractorFinalTotal_ops - arguments.closeoutStruct.txtFootFundingCRATotal>
		<cfset arguments.closeoutStruct.txtFootFundingChangeTotal = arguments.closeoutStruct.txtFootFundingChangeOPSTotal + arguments.closeoutStruct.txtFootFundingChangeCRATotal>

		<!--- if change is positive, assign change amount to active funds --->
		<!--- if change is negative, assign as much as possible to Active, wihtout reducing it below 0, --->
		<!--- then assign the rest to Inactive --->
		<cfset arguments.closeoutStruct.txtFootFundingChangeOPSExpired = 0>
		<cfset arguments.closeoutStruct.txtFootFundingChangeOPSActive = 0>
		<cfset arguments.closeoutStruct.txtFootFundingChangeCRAExpired = 0>
		<cfset arguments.closeoutStruct.txtFootFundingChangeCRAActive = 0>

		<cfif arguments.closeoutStruct.txtFootFundingChangeOPSTotal gt 0>
			<cfset arguments.closeoutStruct.txtFootFundingChangeOPSActive = arguments.closeoutStruct.txtFootFundingChangeOPSTotal>
		<cfelseif arguments.closeoutStruct.txtFootFundingChangeOPSTotal lt 0>
			<cfif abs(arguments.closeoutStruct.txtFootFundingChangeOPSTotal) lte arguments.closeoutStruct.txtFootFundingOPSActive>
				<cfset arguments.closeoutStruct.txtFootFundingChangeOPSActive = arguments.closeoutStruct.txtFootFundingChangeOPSTotal>
			<cfelse>
				<cfset arguments.closeoutStruct.txtFootFundingChangeOPSActive = 0-arguments.closeoutStruct.txtFootFundingOPSActive>
				<cfset arguments.closeoutStruct.txtFootFundingChangeOPSExpired = arguments.closeoutStruct.txtFootFundingChangeOPSTotal + arguments.closeoutStruct.txtFootFundingOPSActive>
			</cfif>
		</cfif>

		<cfif arguments.closeoutStruct.txtFootFundingChangeCRATotal gt 0>
			<cfset arguments.closeoutStruct.txtFootFundingChangeCRAActive = arguments.closeoutStruct.txtFootFundingChangeCRATotal>
		<cfelseif arguments.closeoutStruct.txtFootFundingChangeCRATotal lt 0>
			<cfif abs(arguments.closeoutStruct.txtFootFundingChangeCRATotal) lte arguments.closeoutStruct.txtFootFundingCRAActive>
				<cfset arguments.closeoutStruct.txtFootFundingChangeCRAActive = arguments.closeoutStruct.txtFootFundingChangeCRATotal>
			<cfelse>
				<cfset arguments.closeoutStruct.txtFootFundingChangeCRAActive = 0-arguments.closeoutStruct.txtFootFundingCRAActive>
				<cfset arguments.closeoutStruct.txtFootFundingChangeCRAExpired = arguments.closeoutStruct.txtFootFundingChangeCRATotal + arguments.closeoutStruct.txtFootFundingCRAActive>
			</cfif>
		</cfif>

		<cfset arguments.closeoutStruct.hidCostCategories = lstAllCostCats/>

		<cfreturn arguments.closeoutStruct />
	</cffunction>



	<cffunction name="saveCloseoutData" access="public" returntype="struct" hint="Finalizes Closeout process, writes adjustments">
		<cfargument name="formData" type="struct" required="yes" />

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cfset OPScontingTotal = 0>

		<!--- check to make sure that a successor is in place --->
		<!--- if not, send user back to home page (invalid navigation) --->
		<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#arguments.formData.hidAAPP#" returnvariable="rstAAPPGeneral">
		<cfinvoke component="#application.paths.components#aapp" method="getAAPPLength" aapp="#arguments.formData.hidAAPP#" returnvariable="AAPPlength">

		<!--- remove commas from all numeric fields --->
		<cfloop collection="#formData#" item="i">
			<cfif not listFindNoCase("hidCostCategories,hidContractTypes,txtComments", i)>
				<cfset arguments.formData[i] = replaceNoCase(formData[i],",","","all")>
			</cfif>
		</cfloop>

		<cfif rstAAPPGeneral.succAAPPNum eq ""> <!--- no successor, no closeout!!! --->
			<cfset success = "false">
			<cfset errorMessages = listAppend(errorMessages, "This AAPP does not have a successor in place yet.", "~~")>

		<cfelse> <!--- ok to proceed with closeout --->

			<cftransaction>

			<!--- get current system PY --->
			<cfset currentPY = request.py>

			<!--- get ECP data (needed for ECP adjustments)
			<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileSummary" aapp="#arguments.formData.hidAAPP#" returnvariable="rstEstCostProfileSummary" />
			<cfdump var="#rstEstCostProfileSummary#">--->


			<!--- FOP for CRA HQ Contingency Takeback (if overrun in B1) --->
			<cfif arguments.formData.hqtakeBack_cra neq 0>

				<cfset newCRA_FOPid = "null">
				<!--- this function temporarily removed in JFAS 2.7 (Dec 2010) --->
				<!---
				<!--- Get HQ Contingency CRA account --->
				<cfinvoke component="#application.paths.components#lookup" method="getAAPPRef" refType="HQ_CONTING_CRA" returnvariable="HQaapp_CRA"/>
				<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" costCatCode="B1" returnvariable="rstCostCat"/>

				<cfinvoke component="#application.paths.components#aapp_adjustment"
					method="insertFOP"
					aapp="#HQaapp_CRA#"
					description="Contract Closeout Reconciliation: AAPP #arguments.formData.hidAAPP#"
					programYear="#currentPY#"
					amount="#arguments.formData.hqtakeBack_cra#"
					costCatID="#rstCostCat.costCatID#"
					adjustmentType="CO"
					returnvariable="newCRA_FOPid" />
				--->

			</cfif>


			<!--- FOP for OPS HQ Contingency Takeback (if variance) --->
			<cfif arguments.formData.hqTakeBack_ops neq 0>

				<cfset newOPS_FOPid = "null">
				<!--- this function temporarily removed in JFAS 2.7 (Dec 2010) --->
				<!---
				<!--- get HQ Contingency OPS account --->
				<cfinvoke component="#application.paths.components#lookup" method="getAAPPRef" refType="HQ_CONTING_OPS" returnvariable="HQaapp_OPS"/>
				<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" costCatCode="S" returnvariable="rstCostCat"/>

				<cfinvoke component="#application.paths.components#aapp_adjustment"
					method="insertFOP"
					aapp="#HQaapp_OPS#"
					description="Contract Closeout Reconciliation: AAPP #arguments.formData.hidAAPP#"
					programYear="#currentPY#"
					amount="#arguments.formData.hqTakeBack_ops#"
					costCatID="#rstCostCat.costCatID#"
					adjustmentType="CO"
					returnvariable="newOPS_FOPid" />
				--->

			</cfif>


			<!--- next closeout seq --->
			<cfquery name="qryGetVal" datasource="#request.dsn#">
			select	seq_closeout.nextval as newCloseoutID
			from	dual
			</cfquery>

			<!--- write initial close out record --->
			<cfquery name="qryInsertCloseout" datasource="#request.dsn#">
			insert into aapp_closeout (
				aapp_closeout_id,
				aapp_num,
				date_2110_report,
				takeback_ops_amount,
				takeback_ops_fop_id,
				takeback_cra_amount,
				takeback_cra_fop_id,
				footfund_total,
				footfund_total_ops,
				footfund_total_cra,
				footfund_active_ops,
				footfund_active_cra,
				footfund_expired_ops,
				footfund_expired_cra,
				footfundchange_total,
				footfundchange_total_ops,
				footfundchange_total_cra,
				footfundchange_active_ops,
				footfundchange_active_cra,
				footfundchange_expired_ops,
				footfundchange_expired_cra,
				comments,
				form_version,
				mod_num,
				update_user_id,
				update_function,
				update_time)
			values (
				#qryGetVal.newCloseoutID#,
				#arguments.formData.hidAAPP#,
				to_date('#dateformat(arguments.formData.hidReportingDate, "mm/dd/yyyy")#', 'MM/DD/YYYY'),
				<cfif arguments.formData.hqTakeBack_ops neq 0>
					#arguments.formData.hqTakeBack_ops#,
					#newOPS_FOPid#,
				<cfelse>
					0,null,
				</cfif>
				<cfif arguments.formData.hqtakeBack_cra neq 0>
					#arguments.formData.hqTakeBack_cra#,
					#newCRA_FOPid#,
				<cfelse>
					0,null,
				</cfif>
				#arguments.formData.txtFootFundingTotal#,
				#arguments.formData.txtFootFundingOPSTotal#,
				#arguments.formData.txtFootFundingCRATotal#,
				#arguments.formData.txtFootFundingOPSActive#,
				#arguments.formData.txtFootFundingCRAActive#,
				#arguments.formData.txtFootFundingOPSExpired#,
				#arguments.formData.txtFootFundingCRAExpired#,
				#arguments.formData.txtFootFundingChangeTotal#,
				#arguments.formData.txtFootFundingChangeOPSTotal#,
				#arguments.formData.txtFootFundingChangeCRATotal#,
				#arguments.formData.txtFootFundingChangeOPSActive#,
				#arguments.formData.txtFootFundingChangeCRAActive#,
				#arguments.formData.txtFootFundingChangeOPSExpired#,
				#arguments.formData.txtFootFundingChangeCRAExpired#,
				'#arguments.formData.txtComments#',
				'#arguments.formData.hidFormVersion#',
				'#arguments.formData.hidModNum#',
				'#session.userID#',
				'#request.auditVarInsert#',
				sysdate)
			</cfquery>


			<cfloop index="costCat" list="#arguments.formData.hidCostCategories#"> <!--- loop through cost categories --->

				<!--- get appropriate cost cat id --->
				<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" costCatCode="#costCat#" returnvariable="rstCostCat"/>

				<cfif (arguments.formData[costCat & "_fopChangeAmount"] neq 0)> <!--- if there's a variance in this cost cat --->

					<!--- write FOP amount to closing contract to zero out variance in this cost cat --->
					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertFOP"
						aapp="#arguments.formData.hidAAPP#"
						description="Contract Closeout Reconciliation"
						programYear="#currentPY#"
						amount="#arguments.formData[costCat & "_fopChangeAmount"]#"
						costCatID="#rstCostCat.costCatID#"
						adjustmentType="CO"
						returnvariable="newFOPid" />


					<cfif arguments.formData[costCat & "_rollover"] neq 0>

						<!--- FOP offset to successor contract --->
						<cfinvoke component="#application.paths.components#aapp_adjustment"
							method="insertFOP"
							aapp="#rstAAPPGeneral.succAAPPNum#"
							description="Contract Closeout Reconciliation: Carry over from AAPP #arguments.formData.hidAAPP#"
							programYear="#currentPY#"
							amount="#arguments.formData[costCat & "_rollover"]#"
							costCatID="#rstCostCat.costCatID#"
							adjustmentType="CO"
							returnvariable="carryOver_FOPid" />

					</cfif> <!--- carry over eligible? --->

				</cfif> <!--- FOP variance? --->


				<cfif listFindNoCase(arguments.formData.hidContractTypes,costCat)>

					<cfset newECPAdjID = "null">

					<cfif arguments.formData[costCat & "_ECPadjustment"] neq 0>

						<!--- if contractor obligation does not match ECP, --->
						<!--- write final year contract adjustment to closing contract --->
						<cfinvoke component="#application.paths.components#aapp_adjustment"
							method="insertAdjustment"
							aapp="#arguments.formData.hidaapp#"
							description="Contract Closeout Reconciliation"
							includeECP="1"
							modRequired="1"
							ongoing="0"
							currentCost="#arguments.formData[costCat & "_ECPadjustment"]#"
							fullCost="#arguments.formData[costCat & "_ECPadjustment"]#"
							costCat="#rstCostCat.costCatID#"
							adjustmentType="CO"
							returnvariable="newECPAdjID">
						<cfinvoke component="#application.paths.components#aapp_adjustment"
							method="insertAdjustmentCost"
							adjustmentID="#newECPAdjID#"
							contractYear="#AAPPLength#"
							amount="#arguments.formData[costCat & "_ECPadjustment"]#"
							fixed="1">
					</cfif> <!--- if there is variance between ECP and 2110 --->

				</cfif> <!--- if ECP cost category --->

				<!--- write child closeout record (per cost category) --->
				<cfquery name="qryInserCloseoutAmount" datasource="#request.dsn#">
				insert into aapp_closeout_amount (
					aapp_closeout_id,
					cost_cat_id,
					cum_cont_oblig,
					cum_fop_amount,
					fop_amount,
					fop_id,
					fop_carryover_amount,
					fop_carryover_id,
					hq_adjust_amount,
					<cfif listFindNoCase(arguments.formData.hidContractTypes,costCat)>
						closeout_adjustment_id,
						cum_ecp_value,
						ecp_adjust_amount,
					</cfif>
					<cfif arguments.formData.hidModNum neq "">mod_funding,</cfif>
					update_user_id,
					update_function,
					update_time)
				values (
					#qryGetVal.newCloseoutID#,
					#rstCostCat.costCatID#,
					#arguments.formData[costCat & "_contractorFinal"]#,
					#arguments.formData[costCat & "_budgetAuth"]#,
					<cfif arguments.formData[costCat & "_fopChangeAmount"] neq 0>
						#arguments.formData[costCat & "_fopChangeAmount"]#,
						#newFOPid#,
						<cfif arguments.formData[costCat & "_rollover"] neq 0>
							#arguments.formData[costCat & "_rollover"]#,
							#carryOver_FOPid#,
						<cfelse>
							0,
							null,
						</cfif>
						#arguments.formData[costCat & "_hqAdjustment"]#,
					<cfelse>
						0,
						null,
						0,
						null,
						0,
					</cfif>
					<cfif listFindNoCase(arguments.formData.hidContractTypes,costCat)>
						#newECPAdjID#,
						#arguments.formData[costCat & "_cumulativeECP"]#,
						#arguments.formData[costCat & "_ECPadjustment"]#,
					</cfif>
					<cfif arguments.formData.hidModNum neq "">#arguments.formData[costCat & "_modFunding"]#,</cfif>
					'#session.userID#',
					'#request.auditVarInsert#',
					sysdate)
				</cfquery>


			</cfloop> <!--- loop through cost categories --->


			<!--- insert system audit record --->
			<cfset application.outility.insertSystemAudit (
				aapp="#arguments.formData.hidaapp#",
				statusID="#request.statusID#",
				sectionID="400",
				description="Contract Close-out Performed",
				userID="#session.userID#")>

			</cftransaction>

		</cfif> <!--- if close out is applicable --->



		<!--- set up structure to return --->
		<cfset stcResults = StructNew() />
		<cfset stcResults.success = success />
		<cfset stcResults.closeOutId = qryGetVal.newCloseoutID />
		<cfset stcResults.errorMessages = errorMessages />
		<cfset stcResults.errorFields = errorFields />

		<cfreturn stcResults>

	</cffunction>

	<cffunction name="CheckModCompletion" access="public" returntype="boolean" hint="Checks to see if all adj for a contract year have mod nums">
		<cfargument name="aapp" type="numeric" required="yes" />
		<cfargument name="contractYear" type="numeric" required="no" />

		<cfset modsComplete = 0>

		<cfquery name="qryGetAdjustmentsWithoutMods" datasource="#request.dsn#">
		select	count(adjustment_cost.adjustment_id) as numrecs
		from	adjustment_cost, adjustment
		where	adjustment_cost.adjustment_id = adjustment.adjustment_id and
				adjustment.aapp_num = #arguments.aapp# and
				adjustment.mod_required = 1 and
				adjustment_cost.mod_num is null
				<cfif isDefined("arguments.contractYear")>
					and adjustment_cost.contract_year <= #arguments.contractYear#
				</cfif>
		</cfquery>

		<cfif qryGetAdjustmentsWithoutMods.numRecs eq 0>
			<cfset modsComplete = 1>
		</cfif>

		<cfreturn modsComplete>
	</cffunction>

	<cffunction name="GetNumofPYs" access="public" returntype="numeric" hint="checks to see how many PYs in CY">
		<cfargument name="CYStartDate" type="date" required="yes">
		<cfargument name="CYEndDate" type="date" required="yes">

		<cfquery name="qryGetPYs" datasource="#request.dsn#">
		Select utility.fun_get_year(to_date('#arguments.CYStartDate#', 'MM/DD/YYYY'), 'P') as StartPY,
			   utility.fun_get_year(to_date('#arguments.CYEndDate#', 'MM/DD/YYYY'), 'P') as EndPY
		From Dual
		</cfquery>

		<cfset NumOfPys = qryGetPYs.EndPY - qryGetPYs.StartPY>

		<cfreturn NumOfPys>
	</cffunction>



</cfcomponent>