<!---
page: aapp_adjustment.cfc

description: component that handles all adjustment/fop functions

revisions:
2006-12-17	mstein	rewrite of function saveAdjustmentFormData() to change the way adjustment form works
2006-12-17	mstein	adjustments to handleAdjustmentFunction as part of above rewrite
2007-01-11	rroser	FOP list - select CostCatDesc, and when sorting by FOP description, change to upper case
2007-01-17	mstein	Changed getCumulativeFOPAmounts() to return blank rows when no FOPs exist in cost cat
2007-01-18	mstein	Changed getAdjustmentList() to return contract year
2007-03-20	mstein	Changed updateAdjustment() to set fullCyAmount to null if passed in as blank
2007-09-12	mstein	Modified deleteAdjustment() to also delete cost. Added deleteFOP()
2007-10-10	mstein	Modified DeleteFOP to null out adjustment.fop_id
					Added adjustment_id to getFOP (used in deletion check)
2008-03-18	mstein	Modified all get and set adjustment functions to include new ARRA_IND column (stimulus funds)
2011-04-06	mstein	Modified insertAdjustmentCost and updateAdjustmentCost to remove default "-1" amount - causing defect
2011-12-09	mstein	Modified getCumulativeFOPAmounts to include Cost Category Description, and to order by cost cat code
2012-02-17	mstein	Modified saveAdjustmentFormData to endsure that bi/fee indicator is passed to InsertAdjustment, and UpdateAdjustment
2014-03-29	mstein	Added function getTotalFOPAmount
--->
<cfcomponent displayname="AAPP Adjustments" hint="Component that contains all general AAPP Adjustment functions and methods">


<cffunction name="getAdjustmentList" access="public" returntype="query" hint="Lists AAPP Adjustments for Estimated Costs tab">
	<cfargument name="aapp" type="numeric" required="yes" />
	<cfargument name="sortby" type="string" required="no" default="costCatCode" />
	<cfargument name="sortDir" type="string" required="no" default="asc">

	<!--- get list of adjustments --->
	<cfquery name="qryGetAdjustmentList_EC" datasource="#request.dsn#">
	select	adjustment_id as adjustmentID,
			cost_cat_code as costCatCode,
			adjustment.adjustment_type_code as adjustmentTypeCode,
			date_effective as dateEffective,
			(select min(contract_year)
			 	from adjustment_cost
			 	where adjustment.ADJUSTMENT_ID = adjustment_cost.adjustment_id)
				as contractYear,
			adjustment.description,
			case
			when ongoing = 1 then 'Yes'
			else 'No'
			end
			as ongoing,
			lu_adjustment_type.sort_order
	from	adjustment, lu_cost_cat, lu_adjustment_type
	where	aapp_num = #arguments.aapp# and
			adjustment.cost_cat_id = lu_cost_cat.cost_cat_id and
			adjustment.adjustment_type_code = lu_adjustment_type.adjustment_type_code
	order	by
			<cfif isDefined("arguments.sortBy")>
				<cfif arguments.sortBy is 'description'>
				upper(#arguments.sortBy#) #arguments.sortDir#,
				<cfelse>
				#arguments.sortBy# #arguments.sortDir#,
				</cfif>
			</cfif>
			costCatCode, contractYear, lu_adjustment_type.sort_order, description
	</cfquery>

	<cfreturn qryGetAdjustmentList_EC>

</cffunction>

<cffunction name="getFOPList" access="public" returntype="query" hint="Lists FOPs for AAPP or Funding Office">
	<cfargument name="aapp" type="numeric" required="no" default="0">
	<cfargument name="fundingOfficeNum" type="numeric" required="no" default="0">
	<cfargument name="sortBy" type="string" required="no" default="costCatCode">
	<cfargument name="sortDir" type="string" required="no" default="asc">
	<cfargument name="py" type="numeric" required="no">

	<!--- get list of adjustments --->
	<cfquery name="qryGetFOPList" datasource="#request.dsn#">
	select	fop.fop_id as FOPID,
			fop_num as FOPNum,
			cost_cat_code as costCatCode,
			lu_cost_cat.cost_cat_desc as costCatDesc,
			py as programYear,
			fop_description as description,
			amount,
			adjustment_id as adjustmentID,
			fop.adjustment_type_code as adjustmentTypeCode,
			fop.py_cra_budget as pyCRAbudget
	from	fop, lu_cost_cat, adjustment
	where	fop.cost_cat_id = lu_cost_cat.cost_cat_id and
			fop.fop_id = adjustment.fop_id (+)
	<cfif arguments.aapp neq 0>
		and fop.aapp_num = #arguments.aapp#
	<cfelseif arguments.fundingOfficeNum neq 0>
		and fop.funding_office_num = #arguments.fundingOfficeNum#)
	</cfif>
	<cfif isDefined("arguments.py")>
		and fop.py = #arguments.py#
	</cfif>
	order	by
			<cfif isDefined("arguments.sortBy")>
				<cfif arguments.sortBy is 'description'>
				upper(#arguments.sortBy#) #arguments.sortDir#,
				<cfelse>
				#arguments.sortBy# #arguments.sortDir#,
				</cfif>
			</cfif>
			cost_cat_code, py, fop_num
	</cfquery>

	<cfreturn qryGetFOPList>

</cffunction>

<cffunction name="getModList" access="public" returntype="query" hint="Lists AAPP Adjustments for Estimated Costs / Mods form">
	<cfargument name="aapp" type="numeric" required="yes">

	<!--- get list of adjustments --->
	<cfquery name="qryGetModList" datasource="#request.dsn#">
	select	adjustment.adjustment_id as adjustmentID,
			mod_num modNum,
			contract_year contractYear,
			cost_cat_code costCatCode,
			adjustment.description,
			amount amount,
			lu_adjustment_type.sort_order,
			fixed
	from	adjustment, adjustment_cost, lu_cost_cat, lu_adjustment_type
	where	aapp_num=#url.aapp# and
			adjustment.adjustment_id = adjustment_cost.adjustment_id and
			adjustment.cost_cat_id = lu_cost_cat.cost_cat_id and
			adjustment.adjustment_type_code = lu_adjustment_type.adjustment_type_code
	order	by contract_year desc, cost_cat_code, lu_adjustment_type.sort_order
	</cfquery>

	<cfreturn qryGetModList>

</cffunction>

<cffunction name="createInitialBudgetAdjustments" access="public" output="true" hint="Creates Initial Budget Adjustments based on Contract Input">
	<cfargument name="aapp" type="numeric" required="yes">


	<!--- delete existing initial budget adjustments --->
	<!--- TODO: add trigger--->
	<cfquery name="qryDeleteAdjustmentCosts" datasource="#request.dsn#">
	delete
	from	adjustment_cost
	where	adjustment_id in
			(select adjustment_id from adjustment
			where aapp_num = #arguments.aapp# and
			adjustment_type_code in ('IBR','IBF','IBT'))
	</cfquery>
	<cfquery name="qryDeleteAdjustments" datasource="#request.dsn#">
	delete
	from	adjustment
	where	aapp_num = #arguments.aapp# and
			adjustment_type_code in ('IBR','IBF','IBT')
	</cfquery>

	<!--- TODO: use method from aapp_contract_award component --->
	<cfquery name="rstContractInput" datasource="#request.dsn#">
	select	contract_year, amount, i_contract_budget_item.contract_type_code, budget_item_code,
			ADD_MONTHS (aapp.date_start,12 * (contract_year - 1)) date_start, cost_cat_id
	from	aapp, aapp_contract_award, i_contract_budget_item, lu_cost_cat
	where	aapp.aapp_num = #arguments.aapp# and
			aapp.aapp_num = aapp_contract_award.aapp_num and
			aapp_contract_award.contract_budget_item_id = i_contract_budget_item.contract_budget_item_id and
			i_contract_budget_item.contract_type_code = lu_cost_cat.cost_cat_code
	order	by i_contract_budget_item.contract_type_code
	</cfquery>

	<cfinvoke component="#application.paths.components#aapp" method="getAAPPSummary" aapp="#arguments.aapp#" returnvariable="rstAAPPSummary">
	<cfset lstServiceTypes = rstAAPPSummary.serviceTypes />
	<!---<cfset lstBIFees = rstAAPPSummary.BIFees />--->
	<cfset yearsBase = rstAAPPSummary.yearsBase />
	<cfset aappLength = rstAAPPSummary.yearsBase + rstAAPPSummary.yearsOption />

	<!--- loop through service types --->
	<cfloop index="serviceType" list="#lstServiceTypes#">
		<cfset newReimbursableAdjID = "">

		<cfswitch expression="#serviceType#">
		<cfcase value="A,C1,C2"> <!--- if type is OPS or CTS --->
			<cfloop index="i" from="1" to="#aappLength#"> <!--- loop through contract years --->

					<!--- get start date for this contract year --->
					<cfquery name="qryGetStartDate" dbtype="query">
					select	cost_cat_id, date_start as dateStart
					from	rstContractInput
					where	contract_year = #i# and
							contract_type_code = '#serviceType#'
					</cfquery>

					<!--- add Base/Incentive Fee adjustments --->
					<!--- get total fee for this service type, and contract year --->
					<cfquery name="qryGetTotalFee" dbtype="query">
					select	sum(amount) as totalFee
					from	rstContractInput
					where	contract_year = #i# and
							contract_type_code = '#serviceType#' and
							budget_item_code in ('BF','IF')
					</cfquery>

					<!--- insert adjustment, and adjustment cost for fee for this contract year --->
					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertAdjustment"
						aapp="#arguments.aapp#"
						description="Base/Incentive Fee"
						includeECP="1"
						modRequired="1"
						biFee="1"
						ongoing="0"
						currentCost="#qryGetTotalFee.totalFee#"
						fullCost="#qryGetTotalFee.totalFee#"
						costCat="#qryGetStartDate.cost_cat_id#"
						adjustmentType="IBF"
						returnvariable="newFeeAdjID">
					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertAdjustmentCost"
						adjustmentID="#newFeeAdjID#"
						contractYear="#i#"
						amount="#qryGetTotalFee.totalFee#"
						modnum="#iif(i lte yearsBase,0,-2)#"
						fixed="1">

				<cfif i lte yearsBase> <!--- if current year is base year --->

					<!--- get total reimbursables for this service type, and contract year --->
					<cfquery name="qryGetTotalReim" dbtype="query">
					select	sum(amount) as totalReim
					from	rstContractInput
					where	contract_year = #i# and
							contract_type_code = '#serviceType#' and
							budget_item_code in ('DR','IR')
					</cfquery>

					<!--- insert adjustment (if this is the last base year, then adjustment is ongoing) --->
					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertAdjustment"
						aapp="#arguments.aapp#"
						description="Initial Budget (Reimbursable)"
						includeECP="1"
						modRequired="1"
						ongoing="#iif(i eq yearsBase,1,0)#"
						currentCost="#qryGetTotalReim.totalReim#"
						fullCost="#qryGetTotalReim.totalReim#"
						costCat="#qryGetStartDate.cost_cat_id#"
						adjustmentType="IBR"
						returnvariable="newReimbursableAdjID">

					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertAdjustmentCost"
						adjustmentID="#newReimbursableAdjID#"
						contractYear="#i#"
						amount="#qryGetTotalReim.totalReim#"
						modNum="0"
						fixed="1">

				<cfelse> <!--- option year --->
					<!--- insert blank adjustment cost for reimbursables --->
					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertAdjustmentCost"
						adjustmentID="#newReimbursableAdjID#"
						contractYear="#i#"
						fixed="0">

				</cfif> <!--- base or option year? --->



			</cfloop> <!--- end: loop through contract years --->
		</cfcase>

		<cfcase value="S"><!--- else, if type Support --->
			<cfloop index="i" from="1" to="#aappLength#"> <!--- loop through contract years --->

				<!--- get start date for this contract year --->
				<cfquery name="qryGetStartDate" dbtype="query">
				select	cost_cat_id, date_start as dateStart
				from	rstContractInput
				where	contract_year = #i# and
						contract_type_code = '#serviceType#'
				</cfquery>

				<cfif i lte yearsBase> <!--- if current year is base year --->

					<!--- get total for this service type, and contract year --->
					<cfquery name="qryGetTotal" dbtype="query">
					select	sum(amount) as total
					from	rstContractInput
					where	contract_year = #i# and
							contract_type_code = '#serviceType#' and
							budget_item_code = 'TO'
					</cfquery>

					<!--- insert adjustment (if this is the last base year, then adjustment is ongoing) --->
					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertAdjustment"
						aapp="#arguments.aapp#"
						description="Initial Budget"
						includeECP="1"
						modRequired="1"
						ongoing="#iif(i eq yearsBase,1,0)#"
						currentCost="#qryGetTotal.total#"
						fullCost="#qryGetTotal.total#"
						costCat="#qryGetStartDate.cost_cat_id#"
						adjustmentType="IBT"
						returnvariable="newTotalAdjID">

					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertAdjustmentCost"
						adjustmentID="#newTotalAdjID#"
						contractYear="#i#"
						amount="#qryGetTotal.total#"
						modNum="0"
						fixed="1">

				<cfelse> <!--- option year --->
					<!--- insert blank adjustment cost for reimbursables --->
					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertAdjustmentCost"
						adjustmentID="#newTotalAdjID#"
						contractYear="#i#"
						fixed="0">

				</cfif> <!--- base or option year? --->

			</cfloop> <!--- end: loop through contract years --->

		</cfcase>

		</cfswitch> <!--- end: what service type? --->


	</cfloop> <!--- end: loop through service types --->


</cffunction>


<cffunction name="getAdjustmentFormData" access="public" returntype="query" hint="returns query with correct data form fields for adjustment/fop">
	<cfargument name="adjustID" type="numeric" required="no" />
	<cfargument name="fopID" type="numeric" required="no" />

	<cfif isDefined("arguments.fopID")> <!--- FOP ID has been specified --->
		<cfset rstAdjustmentFormData = this.getFOP(arguments.fopID)> <!--- get FOP data --->

	<cfelse> <!--- adjustment has been specified --->
		<cfset rstAdjustmentFormData = this.getAdjustment(arguments.adjustID)> <!--- get adjustment data --->

	</cfif> <!--- fop, or adjustment? --->

	<cfreturn rstAdjustmentFormData />
</cffunction>



<cffunction name="getAdjustment" access="public" returntype="query" hint="Gets all data for an adjustment record">
	<cfargument name="adjustID" type="numeric" required="yes" />

	<cfquery name="qryGetAdjustment" datasource="#request.dsn#">
	select	adjustment.adjustment_id as adjustmentID,
			adjustment.aapp_num as aappNum,
			adjustment.description,
			date_effective as dateEffective,
			include_ecp as includeECP,
			adjustment.arra_ind as arra_ind,
			mod_required as modRequired,
			bi_fee_required as BIFees,
			ongoing,
			cost_current_cy as costCurrentCY,
			cost_full_cy as costFullCY,
			adjustment.cost_cat_id as costCatID,
			cost_cat_desc as costCatDesc,
			adjustment.adjustment_type_code as adjustmentTypeCode,
			(select	max(mod_num)
			 	from	adjustment_cost
			 	where	adjustment.adjustment_id = adjustment_cost.adjustment_id)
			as latestMod,
			adjustment.fop_id as fopID,
			fop_num as fopNum,
			py as programYear,
			amount as FOPAmount,
			back_loc as backupLoc
	from	adjustment, lu_cost_cat, fop
	where	adjustment.adjustment_id = #arguments.adjustID# and
			adjustment.cost_cat_id = lu_cost_cat.cost_cat_id and
			adjustment.fop_id = fop.fop_id (+)
	</cfquery>

	<cfreturn qryGetAdjustment />
</cffunction>

<cffunction name="getFOP" access="public" returntype="query" hint="Gets all data for an FOP record">
	<cfargument name="fopID" type="numeric" required="yes" />

	<cfquery name="qryGetFOP" datasource="#request.dsn#">
	select	fop.fop_id as fopID,
			fop.aapp_num as aappNum,
			fop_num as fopNum,
			py as programYear,
			fop_description as Description,
			amount as fopAmount,
			back_loc as backupLoc,
			fop.cost_cat_id as costCatID,
			fop.arra_ind as arra_ind,
			py_cra_budget as programYearCRA,
			date_effective_fop as dateEffectiveFOP,
			amount_next_py as fopAmountNextPY,
			fop.adjustment_type_code as adjustmentTypeCode,
			date_executed as dateExectued,
			adjustment_id as adjustmentID
	from	fop, adjustment
	where	fop.fop_id = #arguments.fopID# and
			fop.fop_id = adjustment.fop_id(+)
	</cfquery>

	<cfreturn qryGetFOP />
</cffunction>


<cffunction name="saveAdjustmentFormData" access="public" returntype="struct" hint="Saves all Adjustment and FOP data (if applicable)">
	<cfargument name="formData" type="struct" required="yes" />

	<cfset success = "true">
	<cfset errorMessages = "">
	<cfset errorFields = "">

	<!--- handle ARRA checkbox --->
	<cfif isdefined("arguments.formData.ckbARRA")>
		<cfset frmARRA_ind = 1>
	<cfelse>
		<cfset frmARRA_ind = 0>
	</cfif>

	<cftransaction>

	<cfswitch expression="#arguments.formData.hidDisplayType#">

	<cfcase value="adjfop"> <!--- new adjustment / FOP --->

		<cfif isDefined("arguments.formData.ckbIncludeECP") and (arguments.formData.txtCostInitialCY neq 0)
			and (arguments.formData.txtCostFullCY neq 0)>
			<!--- estimated cost? determines whether records are added to adjustment tables --->



			<!--- insert record into Adjustment table --->
			<cfinvoke component="#application.paths.components#aapp_adjustment"
				method="insertAdjustment"
				aapp="#arguments.formData.hidaapp#"
				description="#arguments.formData.txtDescription#"
				effectiveDate="#arguments.formData.txtDateEffective#"
				includeECP="#arguments.formData.ckbIncludeECP#"
				arra_ind="#frmARRA_ind#"
				biFee="#arguments.formData.radBIFees#"
				modRequired="#arguments.formData.radModRequired#"
				ongoing="#arguments.formData.radOngoing#"
				currentCost="#replace(arguments.formData.txtCostInitialCY,",","","all")#"
				fullCost="#replace(arguments.formData.txtCostFullCY,",","","all")#"
				costCat="#arguments.formData.cboCostCat#"
				adjustmentType="ADJ"
				returnvariable="newAdjID">

			<cfset adjustID = newAdjID /> <!--- capture auto-generated adjustment ID --->

			<!--- insert records into adjustment_cost table --->
			<!--- adjustment will always be written for initial contract year --->
			<!--- if expense is ongoing, then adjustment records will be written for out years --->

			<!--- get initial impacted contract year, based on effective date--->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPContractYear_byDate"
				aapp="#arguments.formData.hidaapp#"
				testDate="#arguments.formData.txtDateEffective#" returnvariable="initialYear">

			<!--- insert initial cost adjustment --->
			<cfinvoke component="#application.paths.components#aapp_adjustment"
				method="insertAdjustmentCost"
				adjustmentID="#adjustID#"
				contractYear="#initialYear#"
				amount="#replace(arguments.formData.txtCostInitialCY,",","","all")#"
				fixed="1">

			<cfif arguments.formData.radOngoing> <!--- if this is an ongoing expense, write blank cost records for out years --->
				<!--- get contract length --->
				<cfinvoke component="#application.paths.components#aapp" method="getAAPPLength"
				aapp="#arguments.formData.hidaapp#" returnvariable="contractLength">

				<!--- loop through remaining years, write blank cost records --->
				<cfloop index="i" from="#evaluate(initialYear+1)#" to="#contractLength#">
					<!--- insert cost adjustment row --->
					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertAdjustmentCost"
						adjustmentID="#adjustID#"
						contractYear="#i#"
						fixed="0">
				</cfloop>
			</cfif>

			<cfset recordType = "adjust" />
			<cfset recordID = adjustID />

		</cfif> <!--- add to estimated cost profile? --->

		<cfif arguments.formData.txtFOPAmount neq "" and arguments.formData.txtFOPAmount neq 0> <!--- record FOP --->

			<cflock name="newFOP" timeout="60">
			<!--- insert FOP record, get back new ID --->
			<cfinvoke component="#application.paths.components#aapp_adjustment"
					method="insertFOP"
					aapp="#arguments.formData.hidaapp#"
					description="#arguments.formData.txtDescription#"
					programYear="#arguments.formData.txtProgramYear#"
					amount="#replace(arguments.formData.txtFOPAmount,",","","all")#"
					backupLoc="#arguments.formData.txtBackupLoc#"
					costCatID="#arguments.formData.cboCostCat#"
					arra_ind="#frmARRA_ind#"
					adjustmentType="ADJ"
					returnvariable="newFOPid" />
			</cflock>

			<cfif isDefined("arguments.formData.ckbIncludeECP") and (arguments.formData.txtCostInitialCY neq 0)
				and (arguments.formData.txtCostFullCY neq 0)>
				<!--- update adjustment record to associate this FOP ID --->
				<cfquery name="qryAssociateFOP" datasource="#request.dsn#">
				update	adjustment
				set		fop_id = #newFOPid#
				where	adjustment_id = #adjustID#
				</cfquery>
			<cfelse>
				<cfset recordType = "fop" />
				<cfset recordID = newFOPid />
			</cfif>

		</cfif>

	</cfcase>

	<cfcase value="adj"> <!--- user has submitted ADJUSTMENT data entry form in edit mode --->

		<cfset recordType = "adjust" />
		<cfset recordID = arguments.formData.hidAdjustID />

		<!--- first of all, delete all adjustment cost records (they will be put back if applicable) --->
		<cfset temp = this.deleteAdjustmentCost(arguments.formData.hidAdjustID) />
		<!--- first, check to see if this is still an adjustment (still in ECP) --->

		<!--- update adjustment, and adjustment cost info --->
		<cfinvoke component="#application.paths.components#aapp_adjustment"
			method="updateAdjustment"
			adjustmentID="#arguments.formData.hidAdjustID#"
			description="#arguments.formData.txtDescription#"
			arra_ind="#frmARRA_ind#"
			effectiveDate="#arguments.formData.txtDateEffective#"
			biFee="#arguments.formData.radBIFees#"
			modRequired="#arguments.formData.radModRequired#"
			ongoing="#arguments.formData.radOngoing#"
			currentCost="#replace(arguments.formData.txtCostInitialCY,",","","all")#"
			fullCost="#replace(arguments.formData.txtCostFullCY,",","","all")#"
			costCat="#arguments.formData.cboCostCat#" />

		<!--- get initial impacted contract year, based on effective date--->
		<cfinvoke component="#application.paths.components#aapp" method="getAAPPContractYear_byDate"
			aapp="#arguments.formData.hidaapp#"
			testDate="#arguments.formData.txtDateEffective#" returnvariable="initialYear">

		<!--- insert initial cost adjustment --->
		<cfinvoke component="#application.paths.components#aapp_adjustment"
			method="insertAdjustmentCost"
			adjustmentID="#arguments.formData.hidAdjustID#"
			contractYear="#initialYear#"
			amount="#replace(arguments.formData.txtCostInitialCY,",","","all")#"
			fixed="1">

		<cfif arguments.formData.radOngoing> <!--- if this is an ongoing expense, write blank cost records for out years --->
			<!--- get contract length --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPLength"
			aapp="#arguments.formData.hidaapp#" returnvariable="contractLength">

			<!--- loop through remaining years, write blank cost records --->
			<cfloop index="i" from="#evaluate(initialYear+1)#" to="#contractLength#">
				<!--- insert cost adjustment row --->
				<cfinvoke component="#application.paths.components#aapp_adjustment"
					method="insertAdjustmentCost"
					adjustmentID="#arguments.formData.hidAdjustID#"
					contractYear="#i#"
					fixed="0">
			</cfloop>
		</cfif>
	</cfcase> <!--- adj: editing ADJUSTMENT record --->

	<cfcase value="fop">

		<cfset recordType = "fop" />

		<cfif form.hidMode eq "add">

			<cfif isDefined("arguments.formData.txtFOPAmountNextPY")> <!--- CCC --->
				<cflock name="newFOP" timeout="60">
				<!--- insert FOP record, get back new ID --->
				<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertFOP"
						aapp="#arguments.formData.hidaapp#"
						description="#arguments.formData.txtDescription#"
						programYear="#arguments.formData.txtProgramYear#"
						programYearCRA="#arguments.formData.cboProgramYearCRA#"
						amount="#replace(arguments.formData.txtFOPAmount,",","","all")#"
						amountNextPY="#replace(arguments.formData.txtFOPAmountNextPY,",","","all")#"
						effectiveDateFOP="#arguments.formData.txtDateEffectiveFOP#"
						backupLoc="#arguments.formData.txtBackupLoc#"
						costCatID="#arguments.formData.cboCostCat#"
						arra_ind="#frmARRA_ind#"
						adjustmentType="ADJ"
						returnvariable="newFOPid" />
				</cflock>
			<cfelse>
				<cflock name="newFOP" timeout="60">
				<!--- insert FOP record, get back new ID --->
				<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertFOP"
						aapp="#arguments.formData.hidaapp#"
						description="#arguments.formData.txtDescription#"
						programYear="#arguments.formData.txtProgramYear#"
						amount="#replace(arguments.formData.txtFOPAmount,",","","all")#"
						backupLoc="#arguments.formData.txtBackupLoc#"
						costCatID="#arguments.formData.cboCostCat#"
						arra_ind="#frmARRA_ind#"
						adjustmentType="ADJ"
						returnvariable="newFOPid" />
				</cflock>
			</cfif>


			<cfset recordID = newFOPid />

		<cfelseif form.hidMode eq "edit">
			<!--- user updating existing FOP record --->
			<cfif isDefined("arguments.formData.txtFOPAmountNextPY")> <!--- CCC --->
				<cfinvoke component="#application.paths.components#aapp_adjustment"
					method="updateFOP"
					fopID="#arguments.formData.hidfopID#"
					description="#arguments.formData.txtDescription#"
					costCatID="#arguments.formData.cboCostCat#"
					arra_ind="#frmARRA_ind#"
					programYearCRA="#arguments.formData.cboProgramYearCRA#"
					effectiveDateFOP="#arguments.formData.txtDateEffectiveFOP#"
					amount="#replace(arguments.formData.txtFOPAmount,",","","all")#"
					amountNextPY="#replace(arguments.formData.txtFOPAmountNextPY,",","","all")#"
					backupLoc="#arguments.formData.txtBackupLoc#"/>
			<cfelse>
				<cfinvoke component="#application.paths.components#aapp_adjustment"
					method="updateFOP"
					fopID="#arguments.formData.hidfopID#"
					description="#arguments.formData.txtDescription#"
					costCatID="#arguments.formData.cboCostCat#"
					arra_ind="#frmARRA_ind#"
					amount="#replace(arguments.formData.txtFOPAmount,",","","all")#"
					backupLoc="#arguments.formData.txtBackupLoc#"/>
			</cfif>

			<cfset recordID = arguments.formData.hidFOPID />

		</cfif> <!--- FOP mode = edit --->

	</cfcase> <!--- FOP (only) mode --->
	</cfswitch>

	</cftransaction>


	<!--- set up structure to return --->
	<cfset stcResults = StructNew() />
	<cfset stcResults.success = success />
	<cfset stcResults.errorMessages = errorMessages />
	<cfset stcResults.errorFields = errorFields />
	<cfset stcResults.recordType = recordType />
	<cfset stcResults.recordID = recordID />

	<cfreturn stcResults>

</cffunction>

<cffunction name="saveModFormData" access="public" hint="Saves data entry from Mod form listing">
	<cfargument name="formData" type="struct" required="yes" />

	<cfset success = "true">
	<cfset errorMessages = "">
	<cfset errorFields = "">

	<cfloop collection="#arguments.formData#" item="key">
		<cfif findnocase("mod_",key)>
			<cfif len(arguments.formData[key])>
			<cfinvoke component="#application.paths.components#aapp_adjustment"
							method="updateAdjustmentCost"
							adjustmentID="#listgetat(key,2,"_")#"
							contractYear="#listgetat(key,3,"_")#"
							amount="#listgetat(key,4,"_")#"
							modnum="#arguments.formData[key]#"
							fixed="#listgetat(key,5,"_")#">
			<cfelse>
			<cfinvoke component="#application.paths.components#aapp_adjustment"
							method="updateAdjustmentCost"
							adjustmentID="#listgetat(key,2,"_")#"
							contractYear="#listgetat(key,3,"_")#"
							fixed="#listgetat(key,5,"_")#">
			</cfif>
		</cfif>
	</cfloop>

	<!--- set up structure to return --->
	<cfset stcResults = StructNew() />
	<cfset stcResults.success = success />
	<cfset stcResults.errorMessages = errorMessages />
	<cfset stcResults.errorFields = errorFields />

	<cfreturn stcResults />

</cffunction>


<cffunction name="insertAdjustment" access="public" returntype="numeric" hint="Inserts record into adjustment table">
	<cfargument name="aapp" type="numeric" required="yes" />
	<cfargument name="description" type="string" required="yes" />
	<cfargument name="effectiveDate" type="string" required="no" default="" />
	<cfargument name="includeECP" type="numeric" required="yes" />
	<cfargument name="modRequired" type="numeric" required="yes" />
	<cfargument name="biFee" type="numeric" required="no" default="0" />
	<cfargument name="ongoing" type="numeric" required="yes" />
	<cfargument name="currentCost" type="numeric" required="yes" />
	<cfargument name="fullCost" type="string" required="no" default="" />
	<cfargument name="adjustmentType" type="string" required="no" default="ADJ" />
	<cfargument name="costCat" type="numeric" required="yes" />
	<cfargument name="arra_ind" type="numeric" required="no" default="0" />
	<cfargument name="fopID" type="numeric" required="no" default="0" />

	<!--- get next adjustment ID --->
	<cfquery name="qryGetNewID" datasource="#request.dsn#">
	select	seq_adjustment.nextVal as newAdjustID
	from	dual
	</cfquery>

	<cfquery name="qryInsertAdjustment" datasource="#request.dsn#">
	insert into adjustment (
		adjustment_id,
		aapp_num,
		description,
		<cfif arguments.effectiveDate neq "">date_effective,</cfif>
		include_ecp,
		mod_required,
		bi_fee_required,
		ongoing,
		cost_current_cy,
		<cfif arguments.fullCost neq "">cost_full_cy,</cfif>
		<cfif arguments.fopID neq 0>fop_id,</cfif>
		cost_cat_id,
		arra_ind,
		adjustment_type_code,
		update_user_id,
		update_function,
		update_time)
	values (
		#qryGetNewID.newAdjustID#,
		#arguments.aapp#,
		'#arguments.description#',
		<cfif arguments.effectiveDate neq "">to_date('#arguments.effectiveDate#', 'MM/DD/YYYY'),</cfif>
		#arguments.includeECP#,
		#arguments.modRequired#,
		#arguments.biFee#,
		#arguments.ongoing#,
		#arguments.currentCost#,
		<cfif arguments.fullCost neq "">#arguments.fullCost#,</cfif>
		<cfif arguments.fopID neq 0>#arguments.fopID#,</cfif>
		#arguments.costCat#,
		#arguments.arra_ind#,
		'#arguments.adjustmentType#',
		'#session.userID#',
		'#request.auditVarInsert#',
		sysdate)
	</cfquery>

	<cfset application.outility.insertSystemAudit (
		aapp="#arguments.aapp#",
		statusID="#request.statusID#",
		sectionID="300",
		description="Adjustment Created",
		adjustID="#qryGetNewID.newAdjustID#",
		userID="#session.userID#")>

	<cfreturn qryGetNewID.newAdjustID>
</cffunction>


<cffunction name="updateAdjustment" access="public" hint="Updates record in adjustment table">
	<cfargument name="adjustmentID" type="numeric" required="yes" />
	<cfargument name="description" type="string" required="no" />
	<cfargument name="effectiveDate" type="string" required="no" />
	<cfargument name="includeECP" type="numeric" required="no" />
	<cfargument name="modRequired" type="numeric" required="no" />
	<cfargument name="biFee" type="numeric" required="no" />
	<cfargument name="ongoing" type="numeric" required="no" />
	<cfargument name="currentCost" type="numeric" required="no" />
	<cfargument name="fullCost" type="string" required="no" default="" />
	<cfargument name="adjustmentType" type="string" required="no" />
	<cfargument name="costCat" type="numeric" required="no" />
	<cfargument name="arra_ind" type="numeric" required="no" />

	<!--- update adjustment info (only setting adjustment ID below for SQL structure) --->
	<cfquery name="qryUpateAdjustment" datasource="#request.dsn#">
	update	adjustment set adjustment_id = #arguments.adjustmentID#,
		update_user_id = '#session.userID#',
		update_function = '#request.auditVarUpdate#',
		update_time = sysdate
		<cfif isDefined("arguments.description")>, description = '#arguments.description#'</cfif>
		<cfif isDefined("arguments.effectiveDate")>, date_effective = to_date('#arguments.effectiveDate#', 'MM/DD/YYYY')</cfif>
		<cfif isDefined("arguments.includeECP")>, include_ecp = #arguments.includeECP#</cfif>
		<cfif isDefined("arguments.modRequired")>, mod_required = #arguments.modRequired#</cfif>
		<cfif isDefined("arguments.biFee")>, bi_fee_required = #arguments.biFee#</cfif>
		<cfif isDefined("arguments.ongoing")>, ongoing = #arguments.ongoing#</cfif>
		<cfif isDefined("arguments.currentCost")>, cost_current_cy = #arguments.currentCost#</cfif>
		<cfif isDefined("arguments.fullCost") and arguments.fullCost neq "">, cost_full_cy = #arguments.fullCost#<cfelse>, cost_full_cy = null</cfif>
		<cfif isDefined("arguments.costCat")>, cost_cat_id = #arguments.costCat#</cfif>
		<cfif isDefined("arguments.adjustmentType")>, adjustment_type_code = '#arguments.adjustmentType#'</cfif>
	where	adjustment_id = #arguments.adjustmentID#
	</cfquery>

	<cfquery name="qryGetAAPP" datasource="#request.dsn#">
	select	aapp_num
	from	adjustment
	where	adjustment_id = #arguments.adjustmentID#
	</cfquery>

	<cfset application.outility.insertSystemAudit (
		aapp="#qryGetAAPP.aapp_num#",
		statusID="#request.statusID#",
		sectionID="300",
		description="Adjustment Updated",
		adjustID="#arguments.adjustmentID#",
		userID="#session.userID#")>

</cffunction>


<cffunction name="deleteAdjustment" access="public" hint="Deletes record from adjustment table">
	<cfargument name="adjustmentID" type="numeric" required="yes" />

	<!--- delete adjustment cost record --->
	<cfquery name="qryDeleteAdjustmentCost" datasource="#request.dsn#">
	delete
	from	adjustment_cost
	where	adjustment_id = #arguments.adjustmentID#
	</cfquery>

	<!--- delete adjustment record --->
	<cfquery name="qryDeleteAdjustment" datasource="#request.dsn#">
	delete
	from	adjustment
	where	adjustment_id = #arguments.adjustmentID#
	</cfquery>

</cffunction>



<cffunction name="insertAdjustmentCost" access="public" hint="Inserts record into adjustment cost table">
	<cfargument name="adjustmentID" type="numeric" required="yes" />
	<cfargument name="contractYear" type="numeric" required="yes" />
	<cfargument name="amount" type="numeric" required="no"/>
	<cfargument name="modNum" type="numeric" required="no" default="-2" />
	<cfargument name="fixed" type="numeric" required="yes" />

	<cfquery name="qryInsertAdjustment" datasource="#request.dsn#">
	insert into adjustment_cost (
		adjustment_id,
		contract_year,
		fixed
		<cfif isDefined("arguments.amount")>,amount</cfif>
		<cfif arguments.modNum neq -2>,mod_num</cfif>,
		update_user_id,
		update_function,
		update_time)
	values (
		#arguments.adjustmentID#,
		#arguments.contractYear#,
		#arguments.fixed#,
		<cfif isDefined("arguments.amount")>#arguments.amount#,</cfif>
		<cfif arguments.modNum neq -2>#arguments.modNum#,</cfif>
		'#session.userID#',
		'#request.auditVarInsert#',
		sysdate)
	</cfquery>

</cffunction>

<cffunction name="updateAdjustmentCost" access="public" hint="Updates record into adjustment cost table">
	<cfargument name="adjustmentID" type="numeric" required="yes" />
	<cfargument name="contractYear" type="numeric" required="yes" />
	<cfargument name="amount" type="numeric" required="no"/>
	<cfargument name="modNum" type="numeric" required="no" default="-2" />
	<cfargument name="fixed" type="numeric" required="yes" />

	<cfquery name="qryInsertAdjustment" datasource="#request.dsn#">
		update	adjustment_cost
		set		<cfif arguments.modNum lt 0 and arguments.fixed eq 0>
					mod_num=null,
					amount=null,
				<cfelseif arguments.modNum lt 0 and arguments.fixed eq 1>
					mod_num=null,
				<cfelseif arguments.modNum gte 0 and arguments.fixed eq 0>
					mod_num=#arguments.modNum#,
					amount=#arguments.amount#,
				<cfelseif arguments.modNum gte 0 and arguments.fixed eq 1>
					mod_num=#arguments.modNum#,
				</cfif>
				update_user_id='#session.userid#',
				update_function='#request.auditVarUpdate#',
				update_time = sysdate
		where	adjustment_id=#arguments.adjustmentID#
		and		contract_year=#arguments.contractYear#
	</cfquery>

</cffunction>


<cffunction name="deleteAdjustmentCost" access="public" hint="Deletes record from adjustment cost table">
	<cfargument name="adjustmentID" type="numeric" required="yes" />
	<cfargument name="contractYear" type="numeric" required="no" />

	<!--- delete adjustment cost record --->
	<cfquery name="qryDeleteAdjustmentCost" datasource="#request.dsn#">
	delete
	from	adjustment_cost
	where	adjustment_id = #arguments.adjustmentID#
			<cfif isDefined("arguments.contractYear")>
				and contractYear = #arguments.contractYear#
			</cfif>
	</cfquery>

</cffunction>

<cffunction name="insertFOP" access="public" hint="Inserts record into FOP table">
	<cfargument name="aapp" type="numeric" required="yes" />
	<cfargument name="programYear" type="numeric" required="yes" />
	<cfargument name="description" type="string" required="yes" />
	<cfargument name="amount" type="numeric" required="yes" />
	<cfargument name="backupLoc" type="string" required="no" default="" />
	<cfargument name="costCatID" type="numeric" required="yes" />
	<cfargument name="arra_ind" type="numeric" required="no" default="0" />
	<cfargument name="adjustmentType" type="string" required="yes" />
	<cfargument name="amountNextPY" type="string" required="no" />
	<cfargument name="programYearCRA" type="string" required="no" />
	<cfargument name="effectiveDateFOP" type="string" required="no" />
	<cfargument name="fundingOfficeNum" type="numeric" required="no" />

	<cfif isDefined("arguments.fundingOfficeNum")>
		<cfset foNum = arguments.fundingOfficeNum>
	<cfelse>
		<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#arguments.aapp#" returnvariable="rstAAPPInfo">
		<cfset foNum = rstAAPPInfo.fundingOfficeNum>
	</cfif>
	<cfset newFOPNum = this.getNewFOPNum(foNum,arguments.programYear) />

	<!--- get next FOP ID --->
	<cfquery name="qryGetNewID" datasource="#request.dsn#">
	select	seq_fop.nextVal as newFOPID
	from	dual
	</cfquery>

	<cfquery name="qryInsertFOP" datasource="#request.dsn#">
	insert into FOP (
		fop_id,
		fop_num,
		py,
		fop_description,
		amount,
		cost_cat_id,
		arra_ind,
		aapp_num,
		adjustment_type_code,
		date_executed,
		back_loc,
		amount_next_py,
		py_cra_budget,
		date_effective_fop,
		funding_office_num,
		update_user_id,
		update_function,
		update_time)
	values (
		#qryGetNewID.newFOPID#,
		#newFOPNum#,
		#arguments.programYear#,
		'#arguments.description#',
		#arguments.amount#,
		#arguments.costCatID#,
		#arguments.arra_ind#,
		#arguments.aapp#,
		'#arguments.adjustmentType#',
		sysdate,
		'#arguments.backupLoc#',
		<cfif isDefined("arguments.amountNextPY") and arguments.amountNextPY neq "">#arguments.amountNextPY#<cfelse>null</cfif>,
		<cfif isDefined("arguments.programYearCRA") and (arguments.programYearCRA neq "")>#arguments.programYearCRA#<cfelse>null</cfif>,
		<cfif isDefined("arguments.effectiveDateFOP")>to_date('#arguments.effectiveDateFOP#', 'MM/DD/YYYY')<cfelse>null</cfif>,
		#foNum#,
		'#session.userID#',
		'#request.auditVarInsert#',
		sysdate)
	</cfquery>

	<cfset application.outility.insertSystemAudit (
		aapp="#arguments.aapp#",
		statusID="#request.statusID#",
		sectionID="300",
		description="FOP Created",
		fopID="#qryGetNewID.newFOPID#",
		userID="#session.userID#")>

	<cfreturn qryGetNewID.newFOPID />

</cffunction>

<cffunction name="updateFOP" access="public" hint="Updates record in FOP table">
	<cfargument name="fopID" type="numeric" required="yes" />
	<cfargument name="description" type="string" required="yes" />
	<cfargument name="amount" type="numeric" required="yes" />
	<cfargument name="backupLoc" type="string" required="no" default="" />
	<cfargument name="costCatID" type="numeric" required="no" />
	<cfargument name="arra_ind" type="numeric" required="no" />
	<cfargument name="amountNextPY" type="string" required="no" />
	<cfargument name="programYearCRA" type="string" required="no" />
	<cfargument name="effectiveDateFOP" type="string" required="no" />


	<cfquery name="qryUpdateFOP" datasource="#request.dsn#">
	update FOP set
		fop_description = '#arguments.description#',
		amount = #arguments.amount#,
		<cfif isDefined("arguments.costCatID")>cost_cat_id = #arguments.costCatID#,</cfif>
		back_loc = '#arguments.backupLoc#',
		amount_next_py = <cfif isDefined("arguments.amountNextPY") and arguments.amountNextPY neq "">#arguments.amountNextPY#<cfelse>null</cfif>,
		py_cra_budget = <cfif isDefined("arguments.programYearCRA") and (arguments.programYearCRA neq "")>#arguments.programYearCRA#<cfelse>null</cfif>,
		date_effective_fop = <cfif isDefined("arguments.effectiveDateFOP")>to_date('#arguments.effectiveDateFOP#', 'MM/DD/YYYY')<cfelse>null</cfif>,
		update_user_id = '#session.userID#',
		update_function = '#request.auditVarUpdate#',
		update_time = sysdate
	where	fop_id = #arguments.fopID#
	</cfquery>

	<cfquery name="qryGetAAPP" datasource="#request.dsn#">
	select	aapp_num
	from	fop
	where	fop_id = #arguments.fopID#
	</cfquery>

	<cfset application.outility.insertSystemAudit (
		aapp="#qryGetAAPP.aapp_num#",
		statusID="#request.statusID#",
		sectionID="300",
		description="FOP Updated",
		fopID="#arguments.fopID#",
		userID="#session.userID#")>

</cffunction>

<cffunction name="deleteFOP" access="public" returntype="void" hint="Deletes FOP record">
	<cfargument name="fopID" type="numeric" required="yes">

	<cfquery name="qryDeleteFOPAssoc" datasource="#request.dsn#">
	update	adjustment
	set fop_id = null
	where	fop_id = #arguments.fopID#
	</cfquery>

	<cfquery name="qryDeleteFOP" datasource="#request.dsn#">
	delete
	from 	fop
	where	fop_id = #arguments.fopID#
	</cfquery>

</cffunction>

<cffunction name="getNewFOPNum" access="public" returntype="numeric" hint="Determines next available FOP number">
	<cfargument name="regionNum" type="numeric" required="yes" />
	<cfargument name="programYear" type="numeric" required="yes" />

	<!--- get largest existing FOP num for specified region, and program year --->
	<cfquery name="qryGetMaxFOPNum" datasource="#request.dsn#">
	select	max(fop_num) as maxFOP
	from	fop
	where	py = #arguments.programYear# and
			fop.funding_office_num = #arguments.regionNum#
	</cfquery>

	<cfif qryGetMaxFOPNum.maxFOP eq "">
		<cfset newFOP = 1 />
	<cfelse>
		<cfset newFOP = qryGetMaxFOPNum.maxFOP + 1 />
	</cfif>

	<cfreturn newFOP />

</cffunction>

<cffunction name="adjustOngoingEstimates" access="public" returntype="void" hint="Adjusts records in Adjustment Cost table based on change in contract length">
	<cfargument name="aapp" type="numeric" required="yes" />
	<cfargument name="oldContractLength" type="numeric" required="yes" />
	<cfargument name="newContractLength" type="numeric" required="yes" />

	<cfif newContractLength lt oldContractLength>
		<!--- if new length is less than old length, remove extra records --->

		<cfquery name="qryDeleteExtraAdjustmentCost" datasource="#request.dsn#">
		delete
		from	adjustment_cost
		where	adjustment_id in (select adjustment_id
								  from adjustment
								  where aapp_num = #arguments.aapp#)
				and
				contract_year > #arguments.newContractLength#
		</cfquery>

		<!--- if any of those adjustments were single year adjustments, --->
		<!--- need to remove adjustment record as well --->
		<cfquery name="qryDeleteOrphanAdjustments" datasource="#request.dsn#">
		delete
		from	adjustment
		where	aapp_num = #arguments.aapp# and
				adjustment_id not in (select adjustment_id from adjustment_cost)
		</cfquery>

	<cfelseif newContractLength gt oldContractLength>
		<!--- if new length is greater than old length --->
		<!--- retrieve all ongoing adjustments --->
		<cfquery name="qryGetOngoingAdjustments" datasource="#request.dsn#">
		select	adjustment_id as adjustID
		from	adjustment
		where	aapp_num = #arguments.aapp# and
				ongoing = 1
		</cfquery>

		<!--- and create additional contract yeat costs (blank) --->
		<cfloop query="qryGetOngoingAdjustments">
			<cfloop index="i" from="#evaluate(arguments.oldContractLength+1)#" to="#arguments.newContractLength#">
				<cfinvoke component="#application.paths.components#aapp_adjustment"
							method="insertAdjustmentCost"
							adjustmentID="#adjustID#"
							contractYear="#i#"
							fixed="0">
			</cfloop>
		</cfloop>

	</cfif>


</cffunction>

<cffunction name="handleAdjustmentFunction" access="public" returntype="struct" hint="Performs dup/reverse/move of adjustment record">
	<cfargument name="formData" type="struct" required="yes" />

	<cfset success = "true">
	<cfset errorMessages = "">
	<cfset errorFields = "">

	<cfset itemType = arguments.formData.hidItemType & "ID" />
	<cfset itemID = 0 />
	<cfset addlURLParams = "&actionType=#arguments.formData.hidActionType#" />


	<!--- first check is to make sure that AAPP num entered is valid/active --->
	<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#arguments.formData.txtAAPP#" returnvariable="rstAAPPResults" />

	<cfif rstAAPPResults.recordcount eq 0> <!--- no such AAPP --->
		<cfset success = "false" />
		<cfset errorMessages = listAppend(errorMessages,"<b>#arguments.formData.txtAAPP#</b> is not a valid AAPP Number.","~")>
		<cfset errorFields = listAppend(errorFields,"txtAAPP")>
	<cfelse>
		<cfif rstAAPPResults.contractStatusID eq 0> <!--- AAPP is inactive --->
			<cfset success = "false" />
			<cfset errorMessages = listAppend(errorMessages,"AAPP <b>#arguments.formData.txtAAPP#</b> is inactive. Please choose a different AAPP Number.","~")>
			<cfset errorFields = listAppend(errorFields,"txtAAPP")>
		</cfif>
	</cfif>

	<cfif success>

		<cfswitch expression="#arguments.formData.hidActionType#">
			<cfcase value="add_diff">
				<cfset itemID = 0 />
			</cfcase>
			<cfcase value="dup_diff,rev_diff">
				<cfset itemID = 0 />
				<cfset addlURLParams = addlURLParams & "&from" & arguments.formData.hidItemType & "=" & arguments.formData.hidItemID />
			</cfcase>
			<cfcase value="mov_diff">
				<!--- nedd to make sure that AAPP being moved TO is in the same Funding Office as one being moved FROM --->
				<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral"
					aapp="#arguments.formData.hidFromAAPP#" returnvariable="rstFromAAPPResults" />
				<cfif rstAAPPResults.fundingOfficeNum neq rstFromAAPPResults.fundingOfficeNum>
					<cfset success = "false" />
					<cfset errorMessages = listAppend(errorMessages,"FOPs can only be moved between AAPPs in the same Region / Funding Office.","~")>
					<cfset errorFields = listAppend(errorFields,"txtAAPP")>
				<cfelse>
					<cfset itemID = arguments.formData.hidItemID />
					<cfset addlURLParams = addlURLParams & "&save=yes" />
					<!--- update AAPP for this FOP --->
					<cfquery name="qryUpdateAdjustmentAAPP" datasource="#request.dsn#">
					update	fop
					set aapp_num = #arguments.formData.txtAAPP#
					where	fop_id = #itemID#
					</cfquery>
				</cfif>
			</cfcase>
		</cfswitch>

		<!--- if user is trying to copy adjustment >> to AAPP without ECP, need to set form to FOP mode --->
		<cfif itemType eq "adjustID">
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#arguments.formData.txtAAPP#" returnvariable="rstAAPPInfo">
			<cfif not listFindNoCase("DC,GR", rstAAPPInfo.agreementTypeCode)>
				<cfset itemType = "fopID"/>
			</cfif>
		</cfif>

	</cfif>


	<!--- set up structure to return --->
	<cfset stcResults = StructNew() />
	<cfset stcResults.success = success />
	<cfset stcResults.errorMessages = errorMessages />
	<cfset stcResults.errorFields = errorFields />

	<cfset stcResults.itemType = itemType />
	<cfset stcResults.itemID = itemID />
	<cfset stcResults.addlURLParams = addlURLParams />


	<cfreturn stcResults />

</cffunction>

<cffunction name="getECPVals" access="public" hint="Get all ECP Cost Cats and Values for AAPP" returntype="query">
	<cfargument name="aapp" type="numeric" required="yes">

	<cfquery name="qryGetECPVals" datasource="#request.dsn#">
	select	act.contract_type_code costCatCode, lu_cost_cat.cost_cat_id costCatID,
			contract.fun_getcumulativeamount(p.aapp_num, lu_cost_cat.cost_cat_id, years_option + years_base) as cumECPTotal
	from	aapp_contract_type act, aapp p, lu_cost_cat
	where	act.aapp_num = p.aapp_num and
			act.contract_type_code = lu_cost_cat.cost_cat_code and
			p.aapp_num = #arguments.aapp#
	</cfquery>

	<cfreturn qryGetECPVals>
</cffunction>

<cffunction name="getCumulativeFOPAmounts" access="public" returntype="query" hint="Returns query with cumulative FOPs through a given program year">
	<cfargument name="aapp" type="numeric" required="yes" />
	<cfargument name="programYear" type="numeric" required="no" />
	<cfargument name="costCatID" type="numeric" required="no">
	<cfargument name="rollUpCCC" type="boolean" required="no" default="0" hint="If true, then all CCC OPS cats will be rolled to single row">

	<!--- query the FOP table to get cumulative totals for FOPs --->
	<!--- update: added union to bring back zero total rows for --->
	<!--- 		  cost cats that don't have any FOPs existing --->
	<cfquery name="qryCumulativeFOPAmounts" datasource="#request.dsn#">
	select	sum(amount) as totalFOPAmount,
			lu_cost_cat.cost_cat_id as costCatID,
			cost_cat_code as costCatCode,
			cost_cat_desc as costCatDesc
	from	fop, lu_cost_cat
	where	aapp_num = #arguments.aapp# and
			fop.cost_cat_id = lu_cost_cat.cost_cat_id
			<cfif isDefined("arguments.programYear")>
				and py <= #arguments.programYear#
			</cfif>
			<cfif isDefined("arguments.costCatID")>
				and lu_cost_cat.cost_cat_id = #arguments.costCatID#
			</cfif>
	group	by lu_cost_cat.cost_cat_id, cost_cat_code, cost_cat_desc

	union

		select	0 as totalFOPAmount,
				cost_cat_id as costCatID,
				cost_cat_code as costCatCode,
				cost_cat_desc as cosCatDesc
		from	lu_cost_cat
		where	cost_cat_p_id is null and
				<cfif isDefined("arguments.costCatID")>
					cost_cat_id = #arguments.costCatID# and
				</cfif>
				cost_cat_id not in
					(select	distinct cost_cat_id
					 from	fop
					 where	aapp_num = #arguments.aapp#
					 <cfif isDefined("arguments.programYear")>
						and py <= #arguments.programYear#
					</cfif>)
	order by costCatCode
	</cfquery>

	<cfif arguments.rollUpCCC>
		<cfquery name="temp1" dbtype="query">
		select	sum(totalFOPAmount) sumFOP
		from	qryCumulativeFOPAmounts
		where	costCatCode like 'A%'
		</cfquery>
		<cfloop query="qryCumulativeFOPAmounts">
			<cfif costCatCode eq "A">
				<cfset temp = querySetCell(qryCumulativeFOPAmounts,"totalFOPAmount",temp1.sumFOP,currentRow)>
			</cfif>
		</cfloop>
		<cfquery name="qryCumulativeFOPAmounts" dbtype="query">
		select	*
		from	qryCumulativeFOPAmounts
		where	costCatID <= 9
		</cfquery>

	</cfif>

	<cfreturn qryCumulativeFOPAmounts>

</cffunction>

<cffunction name="getTotalFOPAmount" access="public" returntype="numeric" hint="Returns FOP sum for given AAPP, PY, Fund Cat, Cost Cat">
	<cfargument name="aapp" type="numeric" required="no">
	<cfargument name="py" type="numeric" required="no">
	<cfargument name="fundCat" type="string" required="no">
	<cfargument name="costCatID" type="numeric" required="no">

	<cfquery name="getFOPTotal" datasource="#request.dsn#">
	select	nvl(sum(amount),0) fopSum
	from	fop
	where	1 = 1
		<cfif isDefined("arguments.aapp")>
			AND aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#">
		</cfif>
		<cfif isDefined("arguments.py")>
			AND py = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.py#">
		</cfif>
		<cfif isDefined("arguments.fundCat")>
			AND cost_cat_id in
				(select cost_cat_id
				 from lu_cost_cat
				 where upper(fund_cat) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.fundCat)#">
				)
		</cfif>
		<cfif isDefined("arguments.costCatID")>
			AND cost_cat_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.costCatID#">
		</cfif>
	</cfquery>

	<cfreturn getFOPTotal.fopSum>

</cffunction>


<cffunction name="getMinMaxAdjustmentDate" access="public" returntype="string" hint="Returns the earliest/latest adjustment effective date">
	<cfargument name="aapp" type="numeric" required="yes">
	<cfargument name="minMax" type="string" required="no" default="min">

	<cfquery name="qryGetMinMaxAdustmentDate" datasource="#request.dsn#">
	select 	#arguments.minMax#(date_effective) as minMaxDate
	from	adjustment
	where	aapp_num = #arguments.aapp#
	</cfquery>

	<cfreturn qryGetMinMaxAdustmentDate.minMaxDate>

</cffunction>

<cffunction name="getMinOptionYear" access="public" returntype="numeric" hint="Returns the minimum number of option years allowable (based on adjustments, mods">
	<cfargument name="aapp" type="numeric" required="yes">

	<cfset maxYear_1 = -1>
	<cfset maxYear_2 = -1>

	<!--- first, get the highest contract year number that has a mod number associated with it --->
	<cfquery name="qryGetHighestModYear" datasource="#request.dsn#">
	select	max(contract_year) as tmpMaxYear_1
	from	adjustment_cost, adjustment
	where	adjustment.adjustment_id = adjustment_cost.adjustment_id and
			adjustment.aapp_num = #arguments.aapp# and
			adjustment_type_code not in ('IBR','IBF','IBT') and
			mod_num is not null
	</cfquery>

	<cfif qryGetHighestModYear.tmpMaxYear_1 neq "">
		<cfset maxYear_1 = qryGetHighestModYear.tmpMaxYear_1>
	</cfif>


	<!--- then, get the latest adjustment effective date --->
	<cfquery name="qryGetLatestEffectiveDate" datasource="#request.dsn#">
	select	max(date_effective) as maxDate
	from	adjustment
	where	adjustment.aapp_num = #arguments.aapp#
	</cfquery>

	<cfif qryGetLatestEffectiveDate.maxDate neq "">

		<!--- get the contract year associated with the latest effective date --->
		<cfquery name="qryGetLatestEffectiveYear" datasource="#request.dsn#">
		select	contract.fun_get_cy_of_date(#arguments.aapp#,'#dateformat(qryGetLatestEffectiveDate.maxDate, "dd-mmm-yyyy")#') as tmpMaxYear_2
		from	dual
		</cfquery>

		<cfset maxYear_2 = qryGetLatestEffectiveYear.tmpMaxYear_2>

	</cfif>


	<!--- get the highest between the two --->
	<cfset maxYear = max(maxYear_1, maxYear_2)>

	<cfreturn maxYear>

</cffunction>

<cffunction name="reverseProgramYearFOPs" access="public" returntype="void" hint="Reverses out all FOPs on an AAPP for a given PY">
	<cfargument name="aapp" type="numeric" required="yes">
	<cfargument name="py" type="numeric" required="no" default="#request.py#">

	<!--- get all FOP totals for the AAPP, by cost cat --->
	<cfquery name="qryGetFOPTotalsbyCat" datasource="#request.dsn#">
	select	cost_cat_id, sum(amount) as fopTotal
	from	fop
	where	aapp_num = #arguments.aapp# and
			py = #arguments.py#
	group	by cost_cat_id
	</cfquery>

	<cfloop query="qryGetFOPTotalsbyCat">
		<cfif fopTotal neq 0>
			<!--- for all cost cats in the current PY that have a non-zero Net, --->
			<!--- create offsetting FOPs --->
			<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="insertFOP"
						aapp="#arguments.aapp#"
						programYear="#arguments.py#"
						description = "Contract start delayed to future PY. Current PY funds are deleted."
						amount="#evaluate(-1 * fopTotal)#"
						costCatID="#cost_cat_id#"
						adjustmentType="ADJ">
		</cfif>
	</cfloop>

</cffunction>

</cfcomponent>

