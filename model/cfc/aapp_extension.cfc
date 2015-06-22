<!---
page: aapp_extension.cfc

description: component that handles aapp contract extension forms/operations

revisions:
2011-12-22	mstein	page created
2013-05-06	mstein	Fixed bug related to contract extensions (2.11.0, JFAS-90)
2013-06-13	mstein	Fixed bug when clicking "do not create FOPs..." (2.11.0, JFAS-91)
2014-06-05	ssurikov Update Snapshot Contract Extension information
2014-10-30	mstein	Updated step 2 - do not allow user to remove final CY if contract is one year long
--->

<cfcomponent displayname="aapp_extension" hint="Component that contains all contract extension queries and functions">

	<cffunction name="contractExtensionHandler" access="public" returntype="struct" hint="Interactions with Contract extension page">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfargument name="formData" type="struct" required="false">

		<!---
			formStep :		step moving to
			formStepPrev :	step coming from
			incEnabled : boolean - can extension be done?
			decEnabled : boolean - can shortening be done?
			extMode :	extension / termination, possible values: INC/DEC
			extSubMode :	method of extension, termination. possible values:
							INC-ADD	increade, add a year
							INC-EXT increase, extend final year
							DEC-DEL decrease, delete final year
							DEC-SHR decrease, shorten final year
			currentContractLength
			newContractLength
			currentFinalYearStartDate : current start of final conctract year
			currentFinalEndDate : current end date of final contract year
			newFinalEndDate :	end date of modified year
			stcFundingAdjustments :
		--->

		<cfif not isDefined("arguments.formData")>
			<cfset extForm = StructNew()>
			<cfset extForm.formStep = 1>
			<cfset extForm.formStepPrev = 0>
			<cfset extForm.incEnabled = 0>
			<cfset extForm.decEnabled = 0>
			<cfset extForm.extMode = "">
		<cfelse>
			<cfset extForm = arguments.formData>
		</cfif>

		<cfset extForm.lstErrorMessages = "">
		<cfset extForm.success = 0>
		<cfset vehicleCostCat = "B3">
		<cfset vehicleCostCatID = 4>

		<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#arguments.aapp#" returnvariable="rstAAPPGeneral">
		<cfset extForm.currentContractLength = rstAAPPGeneral.yearsBase + rstAAPPGeneral.yearsOption>
		<cfset extForm.currentFinalEndDate = rstAAPPGeneral.dateEnd>

		<cfset pyStartDate = application.outility.getProgramYearDate (
		py="#request.py#", type="S"
		)>
		<cfset pyEndDate = application.outility.getProgramYearDate (
		py="#request.py#", type="E"
		)>

		<cfquery name="qryGetFinalYearStartDate" datasource="#request.dsn#">
		select utility.fun_cnt_date(#arguments.aapp#,#extForm.currentContractLength#,'S') as startDate from dual
		</cfquery>
		<cfset extForm.currentFinalYearStartDate = qryGetFinalYearStartDate.startDate>

		<cfswitch expression="#extForm.formStep#">
			<cfcase value="1"> <!--- extending or shortening? --->
				<!--- initial form load, determines what operations INC/DEC are allowed --->

				<cfif rstAAPPGeneral.budgetInputType neq "A">
					<!--- has contract been awarded yet? If not, then contract length should be changed through AAPP setup --->
					<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"This contract has not been awarded yet - all changes should be made through the AAPP Setup page.","~")>

				<cfelse>

					<cfif rstAAPPGeneral.succAAPPNum neq ""> <!--- does successor exist? If so - check to see if it's awarded--->
						<cfquery name="qryGetSuccessorBudgetStatus" datasource="#request.dsn#">
						select budget_input_type from aapp where aapp_num = #rstAAPPGeneral.succAAPPNum#
						</cfquery>
					</cfif>

					<cfif rstAAPPGeneral.succAAPPNum neq "" and qryGetSuccessorBudgetStatus.budget_input_type eq "A">
						<!--- if successor exists, has that been awarded? If so, no changes allowed --->
						<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"The successor contract has been awarded - no changes to this contract's length are allowed.","~")>

					<cfelse>

						<!--- extension is allowed if: number of base years is less than 5 OR final contract year is less than full year --->
						<cfquery name="qryGetFinalYearLength" datasource="#request.dsn#">
						select contract.fun_getcontractyeardays(#arguments.aapp#,#extForm.currentContractLength#) as finalYearDays from dual
						</cfquery>
						<cfif (rstAAPPGeneral.yearsOption lt 5) OR (qryGetFinalYearLength.finalYearDays LT 365)>
							<cfset extForm.incEnabled = 1>
						</cfif>

						<!--- shortening is allowed if: contract end date is greater than or equal to current PY start date --->
						<cfif datecompare(rstAAPPGeneral.dateEnd,pyStartDate) gte 0>
							<cfset extForm.decEnabled = 1>
						</cfif>
						<cfif (not extForm.incEnabled) and (not extForm.decEnabled)>
							<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"The length of this contract can not be modified.","~")>
						</cfif>

					</cfif>
				</cfif>

			</cfcase>


			<cfcase value="2"> <!--- adding/removing a year, or extending/shortening --->
				<!--- user has determined whether they are increasing or decreasing, now they are presented with options --->
				<!--- and existing final year dates and length --->
				<cfif Not IsDefined("extForm.extMode")>
					<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"Please specify whether you wish to extend or shorten the contract.","~")>
				</cfif>

				<cfif extForm.lstErrorMessages eq "">

					<cfif extForm.extMode eq "INC"> <!--- extending --->
						<cfset extForm.extSubMode = "INC-ADD">
						<cfset extForm.addYearEnabled = 0>
						<cfset extForm.extendYearEnabled = 0>

						<!--- can user add additional year? If option years < 5 --->
						<cfif rstAAPPGeneral.yearsOption lt 5>
							<cfset extForm.addYearEnabled = 1>
						</cfif>

						<!--- can user extend final year? if year is less than 365 --->
						<cfquery name="qryGetFinalYearLength" datasource="#request.dsn#">
						select contract.fun_getcontractyeardays(#arguments.aapp#,#extForm.currentContractLength#) as finalYearDays from dual
						</cfquery>
						<cfif qryGetFinalYearLength.finalYearDays LT 365>
							<cfset extForm.extendYearEnabled = 1>
						</cfif>

					<cfelse> <!--- shortening --->
						<cfset extForm.extSubMode = "DEC-DEL">
						<cfset extForm.removeYearEnabled = 0>
						<cfset extForm.shortenYearEnabled = 0>

						<!--- can user remove final contract year? If start date is equal to or greater than current PY start date,
							and contract is longer than one year --->
						<cfif (datecompare(extForm.currentFinalYearStartDate,pyStartDate) gte 0) and (extForm.currentContractLength gt 1)>
							<cfset extForm.removeYearEnabled = 1>
						<cfelse>	
							<cfset extForm.extSubMode = "DEC-SHR">
						</cfif>

						<!--- can user shorten final contract year? If end date is greater than or equal to current PY start date --->
						<cfif datecompare(rstAAPPGeneral.dateEnd,pyStartDate) gte 0>
							<cfset extForm.shortenYearEnabled = 1>
						</cfif>
					</cfif>
				</cfif> <!--- errors? --->

			</cfcase>

			<cfcase value="3"> <!--- preview/specify amounts of changes --->

				<!--- error checking --->
				<cfif extForm.extSubMode eq "INC-ADD" and extForm.newFinalEndDate_add eq "">
					<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"Please specify end date of new contract year.","~")>
				<cfelseif extForm.extSubMode eq "INC-EXT" and extForm.newFinalEndDate_ext eq "">
					<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"Please specify new end date of final contract year.","~")>
				<cfelseif extForm.extSubMode eq "DEC-SHR" and extForm.newFinalEndDate_shr eq "">
					<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"Please specify new end date of final contract year.","~")>
				</cfif>

				<cfset finalYearStartDate = extForm.currentFinalYearStartDate>
				<cfset finalYearEndDate_current = extForm.currentFinalEndDate>
				<cfset numDays_current = replace(extForm.numDaysFinalYear," days","")>

				<cfswitch expression="#extForm.extSubMode#">
					<cfcase value="INC-ADD">
						<cfset finalYearStartDate = extForm.finalYearStartDate_add>
						<cfset finalYearEndDate_new = extForm.newFinalEndDate_add>
						<cfset numDays_new = replace(extForm.numDaysYear_add," days","")>
						<cfset extForm.newContractLength = 	extForm.currentContractLength + 1>
					</cfcase>
					<cfcase value="INC-EXT">
						<cfset finalYearEndDate_new = extForm.newFinalEndDate_ext>
						<cfset numDays_new = replace(extForm.numDaysYear_ext," days","")>
						<cfset extForm.newContractLength = 	extForm.currentContractLength>
					</cfcase>
					<cfcase value="DEC-DEL">
						<cfset finalYearEndDate_new = dateadd("d",-1,finalYearStartDate)>
						<cfset extForm.newContractLength = 	extForm.currentContractLength - 1>
					</cfcase>
					<cfcase value="DEC-SHR">
						<cfset finalYearEndDate_new = extForm.newFinalEndDate_shr>
						<cfset numDays_new = replace(extForm.numDaysYear_shr," days","")>
						<cfset extForm.newContractLength = 	extForm.currentContractLength>
					</cfcase>
				</cfswitch>

				<!--- error checking --->
				<cfif extForm.extSubMode eq "INC-EXT" or extForm.extSubMode eq "DEC-SHR">
					<!--- if lengthening/shortening ensure that ECP adjustments for that CY either (1) all have mods, (2) all do not have mods --->
					<!--- need to check two types of adjustments - those that started before the final year (early), and those that started in the final year (finals) --->
					<cfquery name="qryGetModStatus" datasource="#request.dsn#">
					select
						(select    max(mod_num)
						 from    adjustment_cost
						 where    adjustment_id in (select adjustment_id from adjustment where aapp_num = #arguments.aapp#)
								and contract_year = #extForm.currentContractLength#
								and fixed = 0)
						 as maxMod_nonFinal,
						 (select    count(adjustment_id)
						 from    adjustment_cost
						 where    adjustment_id in (select adjustment_id from adjustment where aapp_num = #arguments.aapp#)
								and contract_year = #extForm.currentContractLength#
								and fixed = 0
								and mod_num is null)
						as nullMods_nonFinal,
					   (select count(*) from
							(
							select * from
							(
							select adjustment_id, max(mod_num),  min(contract_year) as start_year
							from adjustment_cost
							where adjustment_id in (select adjustment_id from adjustment where aapp_num = #arguments.aapp# and ongoing=1)
							group by adjustment_id)
							where start_year = #extForm.currentContractLength#
							))
						as finalYearOngoing,
						(select count(*) from
							(
							select * from
							(
							select adjustment_id, max(mod_num) modNum,  min(contract_year) as start_year
							from adjustment_cost
							where adjustment_id in (select adjustment_id from adjustment where aapp_num = #arguments.aapp# and ongoing=1)
							group by adjustment_id)
							where start_year = #extForm.currentContractLength#
							and modNum is not null
							))
						finalYearOngoing_wMod
						from dual
					</cfquery>

					<cfset extForm.modsExist = 0>
					<cfif qryGetModStatus.maxMod_nonFinal neq ""> <!--- did final year mods show for the early adjustments? --->
						<cfif qryGetModStatus.nullMods_nonFinal eq 0>
							<!--- no null mods among the early - still good to go --->
							<cfset extForm.modsExist = 1>
						<cfelse>
							<!--- there is a mix of mods/no mods - can't proceed --->
							<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"In order to extend or shorten final contract year, all ongoing adjustments must have same mod status.","~")>
						</cfif>
					</cfif>

					<!--- if there were final year ongoing adjustments (not typical), need to do a further check to make sure: --->
					<!--- all of them have mods for the final year --->
					<!--- and if so, all of the early adjustments (above) have mods as well --->
					<cfif qryGetModStatus.finalYearOngoing gt 0 and extForm.lstErrorMessages eq "">
						<!--- are there any final year adj without mods? --->
						<cfif qryGetModStatus.finalYearOngoing_wMod lt qryGetModStatus.finalYearOngoing>
							<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"There are final year ongoing adjustments that do not have mod numbers.","~")>
						<cfelse> <!--- all finals have mods - check to see if early do as well --->
							<cfif extForm.modsExist eq 0>
								<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"There are final year ongoing adjustments on this contract. In this situation, all final year adjustments must have mod numbers.","~")>
							</cfif>
						</cfif>
					</cfif>

				</cfif> <!--- if lengthening/shortening --->

				<cfif extForm.extSubMode eq "DEC-DEL" or extForm.extSubMode eq "DEC-SHR">
					<!--- if shortening contract, make sure there are no adjustments existing with an effective date later than the new end date --->
					<cfquery name="qryGetOrphanedAdjustments" datasource="#request.dsn#">
					select	count(*) numRecs
					from	adjustment
					where	aapp_num = #arguments.aapp# and
							date_effective > '#dateformat(finalYearEndDate_new,'dd-mmm-yyyy')#'
					</cfquery>

					<cfif qryGetOrphanedAdjustments.numRecs gt 0>
						<cfset extForm.lstErrorMessages = listAppend(extForm.lstErrorMessages,"There are adjustments that have effective dates in the part of the contract that is being removed. Please revise.","~")>
					</cfif>
				</cfif>


				<!--- if no errors --->
				<cfif extForm.lstErrorMessages eq "">

					<!--- get list of service types --->
					<cfinvoke component="#application.paths.components#aapp" method="getAAPPServiceTypes" aapp="#arguments.aapp#" returnvariable="lstServiceTypes">
					<cfset extForm.lstServiceTypes = lstServiceTypes>
					
					<!--- determine Fee percentage --->
					<cfset feeTypeVar = iif(listFindNoCase(lstServiceTypes,"A"),de("future_fee_percentage_co"),de("future_fee_percentage_so"))>
					<cfset feePercent = application.outility.getSystemSetting(systemSettingCode="#feeTypeVar#")>
					<cfset extForm.feePercent = feePercent>

					<!--- does final contract year overlap with current Program Year (determines if FOP changes are necessary) --->
					<cfif datecompare(finalYearStartDate,pyEndDate) eq 1> <!--- final year start date is greater than PY end --->
						<cfset PYoverlap = 0>
					<cfelse>
						<cfset PYoverlap = 1>
					</cfif>

					<!--- set scenario code --->
					<cfif extForm.extSubMode eq "INC-ADD">
						<cfif PYoverlap>
							<cfset extForm.scenCode = "add_py">
						<cfelse>
							<cfset extForm.scenCode = "add">
						</cfif>

					<cfelseif extForm.extSubMode eq "INC-EXT">
						<cfif PYoverlap>
							<!--- final year overlaps with PY, but did change in end date happen outside PY? --->
							<cfif datecompare(finalYearEndDate_current,pyEndDate) gte 0>
								<cfset extForm.scenCode = "ext">
							<cfelse>
								<cfset extForm.scenCode = "ext_py">
							</cfif>
						<cfelse>
							<cfset extForm.scenCode = "ext">
						</cfif>

					<cfelseif extForm.extSubMode eq "DEC-DEL">
						<cfif PYoverlap>
							<cfset extForm.scenCode = "del_py">
						<cfelse>
							<cfset extForm.scenCode = "del">
						</cfif>

					<cfelseif extForm.extSubMode eq "DEC-SHR">
						<cfif PYoverlap>
							<!--- final year overlaps with PY, but did change in end date happen outside PY? --->
							<cfif datecompare(finalYearEndDate_new,pyEndDate) gte 0>
								<cfset extForm.scenCode = "shr">
							<cfelse>
								<cfset extForm.scenCode = "shr_py">
							</cfif>
						<cfelse>
							<cfset extForm.scenCode = "shr">
						</cfif>
					</cfif>

					<cfif FindNoCase("_py",extForm.scenCode)>
						<cfset extForm.impactsPY = 1>
					<cfelse>
						<cfset extForm.impactsPY = 0>
					</cfif>

					<!--- for older O/A contracts, Fee was not broken out. For those, will just show $0 for fee, and allow edits --->
					<!--- need to check, if contract includes O/A, if there are any Fee adjustments --->
					<cfif listFindNoCase(lstServiceTypes,"C1")>
						<cfset extForm.OAFeeExists = 0>
						<cfquery name="qryCheckforOAFee" datasource="#request.dsn#">
						select	count(adjustment_id) numRecs
						from	adjustment
						where	aapp_num = #arguments.aapp#
								and cost_cat_id = 6
								and bi_fee_required = 1
						</cfquery>
						<cfif qryCheckforOAFee.numRecs gt 0>
							<cfset extForm.OAFeeExists = 1>
						</cfif>
					</cfif>


					<!--- loop through contract types --->
					<cfloop list="#lstServiceTypes#" index="costCat">

						<cfset extForm[costCat & "_costCat"] = costCat>
						<cfinvoke component="#application.paths.components#lookup" method="getServiceTypes" contractTypeCode="#costCat#" returnvariable="rstServiceTypes">
						<cfset extForm[costCat & "_costCatDesc"] = rstServiceTypes.contractTypeShortDesc>
						<!--- get cost cat ID, Desc that goes with cost cat code --->
						<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" costCatCode="#costCat#" returnvariable="rstCostCategories">



						<!--- determine the amount of funding in final contract year to be used as basis for adjustments --->
						<cfif extForm.extSubMode eq "DEC-DEL">
							<!--- if final year is being deleted, then just use the final CY ECP amount --->
							<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileTotal" aapp="#arguments.aapp#"
								contract_type_code="#costCat#" contract_year="#extForm.currentContractLength#" returnvariable="rstEstCostProfileTotal" />
							<cfset extForm[costCat & "_R_currentECP"] = iif(rstEstCostProfileTotal.recordcount,rstEstCostProfileTotal.funds,0)>
						<cfelse>
							<!--- for all other operations, must use the effective final year ongoing amount --->
							<!--- this will be ECP amount for all adjustments that started prior to final year --->
							<!--- and "full CY amount" for all adjustments that started in final year --->
							<cfquery name="qryGetBaseAmount" datasource="#request.dsn#">
							select contract.fun_getpredecessorbaseamount(#arguments.aapp#,#arguments.aapp#,'#costCat#') as OngoingBaseAmount from dual
							</cfquery>
							<cfset extForm[costCat & "_R_currentECP"] = qryGetBaseAmount.OngoingBaseAmount>
						</cfif>

						<!--- determine adjustment to final contract year ECP amount --->
						<cfswitch expression="#extForm.scenCode#">
							<cfcase value="add,add_py">
								<cfset ombRate = application.outility.getOMBInflationRate (
								effectDate="#finalYearStartDate#", costcat="#costCat#"
								)>
								<!--- new amount (total amount for new contract year) --->
								<!--- current final year amount * inflation rate * (length of new final year/length of current final year) --->
								<cfset extForm[costCat & "_R_newECP"] = extForm[costCat & "_R_currentECP"] * ombRate * (numDays_new/numDays_current)>
							</cfcase>
							<cfcase value="ext,ext_py,shr,shr_py">
								<!--- extending or shortening: new amount = [(new final year length/current final year length)-1] * current final year amount --->
								<cfset extForm[costCat & "_R_newECP"] = extForm[costCat & "_R_currentECP"] * ((numDays_new/numDays_current)-1)>
							</cfcase>
							<cfcase value="del,del_py">
								<!--- final contract year ECP amounts will be removed, so just show inverse --->
								<cfset extForm[costCat & "_R_newECP"] = -1 * extForm[costCat & "_R_currentECP"]>
							</cfcase>
						</cfswitch>

						<!--- determine Fee adjustment (for year deletion - set to $0) --->
						<!--- if "S" - $0 --->
						<!--- also - for OA contracts with no existing fee breakoout, set to $0 - but will be editable to user on form --->
						<cfif (costCat eq "S") or (costCat eq "C1" and (not extForm.OAFeeExists)) or (extForm.extSubMode eq "DEC-DEL")>
							<cfset extForm[costCat & "_F_newECP"] = 0>
						<cfelse>
							<!--- for shortening/extending year - use total Fee amount for that year and pro-rate it --->
							<cfif (extForm.extSubMode eq "INC-EXT" or extForm.extSubMode eq "DEC-SHR")>
								<cfset extForm[costCat & "_F_newECP"] = extForm[costCat & "_R_newECP"]*(extForm.feePercent/100)>
								<cfinvoke component="#application.paths.components#aapp_costprofile" method="getFeeTotalbyAAPP"
									aapp="#arguments.aapp#" contract_year="#extForm.currentContractLength#" cost_cat_id="#rstCostCategories.costCatID#" returnvariable="FeeTotal">
								<cfset extForm[costCat & "_F_newECP"] = FeeTotal * ((numDays_new/numDays_current)-1)>
							<cfelse>
								<!--- if adding new year, just use percentage of Reimbursable amount --->
								<cfset extForm[costCat & "_F_newECP"] = extForm[costCat & "_R_newECP"]*(extForm.feePercent/100)>
							</cfif>
						</cfif>

						<!--- round ECP values --->
						<cfset extForm[costCat & "_R_currentECP"] = round(extForm[costCat & "_R_currentECP"])>
						<cfset extForm[costCat & "_R_newECP"] = round(extForm[costCat & "_R_newECP"])>
						<cfset extForm[costCat & "_F_newECP"] = round(extForm[costCat & "_F_newECP"])>

						<!--- determine adjustment to FOP amount (this AAPP) --->
						<cfswitch expression="#extForm.scenCode#">
							<cfcase value="add,ext,del,shr">
								<cfset prorate = 0>
							</cfcase>
							<cfcase value="add_py">
								<cfif datecompare(finalYearEndDate_new,pyEndDate) lte 0>
									<!--- if end date of new contract year is within PY, then FOP amount = ECP amount --->
									<cfset prorate = 1>
								<cfelse>
									<!--- otherwise, need to prorate ECP amount based on number of CY days in PY --->
									<cfset prorate = (datediff("d",finalYearStartDate,pyEndDate)+1)/numDays_new>
								</cfif>
							</cfcase>
							<cfcase value="ext_py">
								<cfif datecompare(finalYearEndDate_new,pyEndDate) lte 0>
									<!--- if end date of new contract year is within PY, then FOP amount = ECP amount --->
									<cfset prorate = 1>
								<cfelse>
									<!--- otherwise, need to prorate ECP amount based on number of CY days in PY --->
									<cfset prorate = datediff("d",finalYearEndDate_current,pyEndDate)/datediff("d",finalYearEndDate_current,finalYearEndDate_new)>
								</cfif>
							</cfcase>
							<cfcase value="del_py">
								<!--- deleting a contract year, part of which is in the current PY --->
								<!--- need to take ECP amount of year being deleted, and prorate it based on the number of days up to PY end --->
								<cfset prorate = (datediff("d",finalYearStartDate,pyEndDate)+1)/numDays_current>
							</cfcase>
							<cfcase value="shr_py">
								<!--- shortening contract year, part of which is in the current PY --->
								<cfif datecompare(finalYearEndDate_current,pyEndDate) lte 0>
									<!--- if old end date was within PY as well, then FOP adjustment will equal ECP adjustment --->
									<cfset prorate = 1>
								<cfelse>
									<!--- if old end date was after PY end, then need to take amount of ECP adjustment, and prorate it --->
									<!--- based on length of reduction, vs amount that is in current PY --->
									<cfset prorate = datediff("d",finalYearEndDate_new,pyEndDate)/datediff("d",finalYearEndDate_new,finalYearEndDate_current)>
								</cfif>
							</cfcase>
						</cfswitch>
						<cfset extForm[costCat & "_R_newFOP"] = extForm[costCat & "_R_newECP"] * prorate>

						<!---- amount of Fee FOP adjustment (for Supt contracts, or for OA contracts with no existing fee breakoout, set to $0) --->
						<cfif (costCat eq "S") or (costCat eq "C1" and (not extForm.OAFeeExists))>
							<cfset extForm[costCat & "_F_newFOP"] = 0>
						<cfelse>
							<cfset extForm[costCat & "_F_newFOP"] = extForm[costCat & "_F_newECP"] * prorate>
						</cfif>

						<!--- round FOP values --->
						<cfset extForm[costCat & "_R_newFOP"] = round(extForm[costCat & "_R_newFOP"])>
						<cfset extForm[costCat & "_F_newFOP"] = round(extForm[costCat & "_F_newFOP"])>

						<!--- determine adjustment to FOP amount (successor AAPP) --->
						<cfset extForm.succAAPPnum = rstAAPPGeneral.succAAPPNum>
						<cfif (extForm.succAAPPnum neq "") and extForm.impactsPY> <!--- if successor exists, and extention/shortening affects this PY --->
							<!--- if successor exists, and extention/shortening affects this PY --->
							<!--- FOP is equal to the inverse of the FOPs against the current contract (reimbursable + fee) --->
							<cfset extForm[costCat & "_newSuccFOP"] = -1 * (extForm[costCat & "_R_newFOP"] + extForm[costCat & "_F_newFOP"])>

						<cfelse> <!--- no successor, or successor in later PY - no FOP needed --->
							<cfset extForm[costCat & "_newSuccFOP"] = 0>
						</cfif>

						<!--- determine cumulative FOP for successor (alert will show if adjustment will bring cumulative below $0 --->
						<cfif (extForm.succAAPPnum neq "") and extForm.impactsPY> <!--- if successor exists, and extention/shortening affects this PY --->
							<cfinvoke component="#application.paths.components#aapp_adjustment" method="getCumulativeFOPAmounts" aapp="#extForm.succAAPPnum#" costCatID="#rstCostCategories.costCatID#" returnvariable="rstCumulativeFOPAmounts">
							<cfset extForm[costCat & "_succFOPCum"] = rstCumulativeFOPAmounts.totalFOPAmount>
						<cfelse>
							<cfset extForm[costCat & "_succFOPCum"] = 0>
						</cfif>


					</cfloop>

					<!--- B3 --->
					<cfset extForm.VEH_costCat = vehicleCostCat>
					<cfinvoke component="#application.paths.components#lookup" method="getServiceTypes" contractTypeCode="#vehicleCostCat#" returnvariable="rstServiceTypes">
					<cfset extForm.VEH_costCatDesc = rstServiceTypes.contractTypeShortDesc>
					<cfset extForm.VEH_newFOP = 0>
					<cfset extForm.VEH_newSuccFOP = 0>
					<cfset extForm.VEH_succFOPCum = 0>
					<cfif (extForm.succAAPPnum neq "")>
						<cfinvoke component="#application.paths.components#aapp_adjustment" method="getCumulativeFOPAmounts" aapp="#extForm.succAAPPnum#" costCatID="#vehicleCostCatID#" returnvariable="rstCumulativeFOPAmounts">
						<cfset extForm.VEH_succFOPCum = rstCumulativeFOPAmounts.totalFOPAmount>
					</cfif>

					<!---  if extending/shortening final year --->
					<cfif (extForm.extSubMode eq "INC-EXT" or extForm.extSubMode eq "DEC-SHR")>
						<cfif qryGetModStatus.finalYearOngoing gt 0> <!--- and there are ongoing adj that start in that year --->
							<!--- get list of those adjustments --->
							<cfquery name="qryGetFinalYearOngoingAdj" datasource="#request.dsn#">
							select	*
							from
								(
								select	a.adjustment_id, description, cost_full_cy, cost_cat_code, min(contract_year) as startYear
								from	adjustment a, adjustment_cost ac, lu_cost_cat lcc
								where 	a.adjustment_id = ac.adjustment_id
										and	a.cost_cat_id = lcc.cost_cat_id
										and	aapp_num = #arguments.aapp#
										and	ongoing = 1
								group by a.adjustment_id, description, cost_full_cy, cost_cat_code
								order by cost_cat_code, a.adjustment_id
								)
							where startYear = #extForm.currentContractLength#
							</cfquery>

							<cfset extForm.lstOngoingFinal = valuelist(qryGetFinalYearOngoingAdj.adjustment_id)>
							<cfloop query="qryGetFinalYearOngoingAdj">
								<!--- loop through adjustments, set form field values --->
								<cfset extForm[adjustment_id & "_costCat"] = cost_cat_code>
								<cfset extForm[adjustment_id & "_desc"] = description>
								<cfset extForm[adjustment_id & "_CurrentFullCYAmount"] = cost_full_cy>
								<cfset extForm[adjustment_id & "_NewFullCYAmount"] = round(cost_full_cy * (numDays_new/numDays_current))>
							</cfloop>
						<cfelse>
							<cfset extForm.lstOngoingFinal = "">
						</cfif>
					</cfif> <!--- ext/shrt and final year ongoing adj? --->

					<cfset extForm.newFinalEndDate = finalYearEndDate_new>


					<!--- if contract has O/A or CTS service type, display prorated Arrivals, Grads, Former Enrollees (if not deleting year) --->
					<cfif extForm.extSubMode neq "DEC-DEL" and (listFindNoCase(lstServiceTypes,"C1") or listFindNoCase(lstServiceTypes,"C2"))>

						<!--- get Arrivals, Grads, Former Enrollees amounts from final year --->
						<cfquery name="qryGetFinalYearWorkload" datasource="#request.dsn#">
						select	value, aapp_workload.workload_type_code, workload_type_desc
						from	aapp_workload, lu_workload_type
						where	aapp_workload.workload_type_code = lu_workload_type.workload_type_code and
								aapp_num = #arguments.aapp# and
								contract_year = #extForm.currentContractLength# and
								aapp_workload.workload_type_code in ('AR','FE','GR') and
								value is not null
						</cfquery>
						<cfset extForm.lstWorkloadFinal = valuelist(qryGetFinalYearWorkload.workload_type_code)>

						<!--- for each workload level that applies to this contract, show current amount, change, and new amount --->
						<cfloop query="qryGetFinalYearWorkload">
							<cfset extForm[workload_type_code & "_WL_label"] = workload_type_desc>
							<cfset extForm[workload_type_code & "_WL_currentAmount"] = value>
							<cfif extForm.extSubMode eq "INC-ADD"> <!--- add new year --->
								<cfset extForm[workload_type_code & "_WL_change"] = round(value * (numDays_new/numDays_current))>
								<cfset extForm[workload_type_code & "_WL_newAmount"] = extForm[workload_type_code & "_WL_change"]>
							<cfelse> <!--- increase or decrease final CY --->
								<cfset extForm[workload_type_code & "_WL_change"] = round(value * ((numDays_new/numDays_current)-1))>
								<cfset extForm[workload_type_code & "_WL_newAmount"] = value + extForm[workload_type_code & "_WL_change"]>
							</cfif>
						</cfloop>

					</cfif> <!--- calculate changes to workload levels --->


				<cfelse> <!--- errors occured --->
					<cfset extForm.formStep = 2>
					<cfset extForm.formStepPrev = 1>

				</cfif>

			</cfcase>

			<cfcase value="4"> <!--- collect form contents, execute extension --->

				<cftransaction>

				<cfif extForm.extSubMode eq "INC-ADD" or extForm.extSubMode eq "DEC-DEL"> <!--- was year added or deleted? --->
					<!--- all automatic changes to AAPP as a result of adding/deleting a year --->
					<!--- update # option years in AAPP table --->
					<cfquery name="qryUpdateOptionYears" datasource="#request.dsn#">
					update	aapp
					set		years_option = #evaluate(extForm.newContractLength - rstAAPPGeneral.yearsBase)#
					where	aapp_num = #arguments.aapp#
					</cfquery>

					<!--- AAPP_YEAREND --->
					<cfinvoke component="#application.paths.components#aapp" method="adjustContractYearData"
						aapp="#arguments.aapp#" oldContractLength="#extForm.currentContractLength#" newContractLength="#extForm.newContractLength#">

					<!--- Workload --->
					<cfinvoke component="#application.paths.components#aapp_workload" method="adjustWorkloadLength"
							aapp="#arguments.aapp#" newContractLength="#extForm.newContractLength#">

					<!--- BUDGET --->
					<cfinvoke component="#application.paths.components#aapp" method="adjustBudgetLength"
						aapp="#arguments.aapp#" newContractLength="#extForm.newContractLength#">

					<!--- Estimated Cost Profile --->
					<cfinvoke component="#application.paths.components#aapp_adjustment" method="adjustOngoingEstimates"
							aapp="#arguments.aapp#" oldContractLength="#extForm.currentContractLength#" newContractLength="#extForm.newContractLength#">


				</cfif>

				<!--- set new end date on current contract --->
				<cfquery name="qrySetEndDate" datasource="#request.dsn#">
				update	aapp_yearend
				set		date_end = '#dateformat(extForm.newFinalEndDate,"dd-mmm-yyyy")#'
				where	aapp_num = #arguments.aapp# and
						contract_year = #extForm.newContractLength#
				</cfquery>

				<!--- if successor exists, need to update start date, and all year_end dates --->
				<cfif (rstAAPPGeneral.succAAPPnum neq "")>
					<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#rstAAPPGeneral.succAAPPnum#" returnvariable="rstSuccAAPPSummary">

					<cfif datecompare(dateadd("d",1,extForm.newFinalEndDate),rstSuccAAPPSummary.dateStart) neq 0> <!--- end date not adjacent to successor start date? --->
						<cfset dateChangeAmount = datediff("d",rstSuccAAPPSummary.dateStart,dateadd("d",1,extForm.newFinalEndDate))>
						<cfset newSuccStartDate = dateadd("d",1,extForm.newFinalEndDate)>
						<!--- update successor start date --->
						<cfquery name="qryUpdateSuccessorDates" datasource="#request.dsn#">
						update	aapp set
								date_start = '#dateformat(newSuccStartDate,"dd-mmm-yyyy")#'
						where	aapp_num = #rstAAPPGeneral.succAAPPnum#
						</cfquery>
						<!--- for all successor contract years, move the CY end dates by dateChangeAmount --->
						<cfquery name="qryUpdateSuccessorDates" datasource="#request.dsn#">
						update	aapp_yearend set
								date_end = date_end + #dateChangeAmount#
						where	aapp_num = #rstAAPPGeneral.succAAPPnum#
						</cfquery>

						<!--- this could have caused an issue with leap years --->
						<!--- years that had been 366 need to be shortened to 365, and vice versa --->
						<cfquery name="qryGetCYendDates" datasource="#request.dsn#">
						select	contract_year, date_end
						from	aapp_yearend
						where	aapp_num = #rstAAPPGeneral.succAAPPnum#
						order	by contract_year
						</cfquery>
						<cfset CYstartDate = newSuccStartDate>
						<cfloop query="qryGetCYendDates">
							<!--- check length of CY --->
							<cfset CYlength = datediff("d",CYstartDate,date_end)>
							<cfset fullYearEndDate = dateadd("d",-1,dateadd("yyyy",1,CYstartDate))>
							<cfif (CYlength gte 360) and (dateCompare(fullYearEndDate,date_end) neq 0)>
								<!--- if length is greater than 360 (assume full year intent), and end date is not one calendar year from start date --->
								<!--- update CY end date --->
								<cfquery name="qryUpdateSuccessorDates" datasource="#request.dsn#">
								update	aapp_yearend set
										date_end = '#dateformat(fullYearEndDate,"dd-mmm-yyyy")#'
								where	aapp_num = #rstAAPPGeneral.succAAPPnum# and
										contract_year = #contract_year#
								</cfquery>
								<cfset CYstartDate = dateadd("d",1,fullYearEndDate)> <!--- use this as the next CY start date --->
							<cfelse>
								<cfset CYstartDate = dateadd("d",1,date_end)> <!--- use this as the next CY start date --->
							</cfif> <!--- if end date is not one calendar year from start date (on 365/366 day year) --->
						</cfloop>

					</cfif> <!--- if successor start date was adjacent to pred end date --->

				</cfif> <!--- successor exists --->

				<!--- determine label for operation (for use in adjustment, fop, and audit log descriptions) --->
				<cfif extForm.extMode eq "INC">
					<cfset tmpDesc = "Extended">
				<cfelse>
					<cfset tmpDesc = "Shortened">
				</cfif>

				<cfif not isDefined("extForm.ckbNoCreate")>
					<!--- create cost/funding adjustments --->
					<!--- loop through cost categories --->
					<cfloop list="#extForm.lstServiceTypes#" index="costCat">

						<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" costCatCode="#costCat#" returnvariable="rstCostCategories">

						<!--- set ECP/FOP descriptions --->
						<cfif extForm.extMode eq "INC"> <!-- extending contract --->
							<cfset newecp_r_desc = "Extension - Reimbursable #dateformat(rstAAPPGeneral.dateEnd,"mm/dd/yyyy")# to #dateformat(extForm.newFinalEndDate,"mm/dd/yyyy")#">
							<cfset newecp_f_desc = "Extension - Fee #dateformat(rstAAPPGeneral.dateEnd,"mm/dd/yyyy")# to #dateformat(extForm.newFinalEndDate,"mm/dd/yyyy")#">
							<cfset newfop_r_desc = "Extension - Reimbursable #dateformat(rstAAPPGeneral.dateEnd,"mm/dd/yyyy")# to #dateformat(extForm.newFinalEndDate,"mm/dd/yyyy")#">
							<cfset newfop_f_desc = "Extension - Fee">
							<cfset newsuccfop_desc = "Predecessor Extension">
							<cfset vehnewfop_desc = "Extension">
							<cfset vehnewsuccfop_desc = "Predecessor Extension">

						<cfelse> <!-- shortening contract --->
							<cfif extForm.extSubMode eq "DEC-DEL">
								<cfset newfop_r_desc = "Remove Final CY - Reimbursable">
								<cfset newfop_f_desc = "Remove Final CY - Fee">
								<cfset vehnewfop_desc = "Remove Final CY">
							<cfelse>
								<cfset newecp_r_desc = "Contract Year Shortened - Reimbursable">
								<cfset newecp_f_desc = "Contract Year Shortened - Fee">
								<cfset newfop_r_desc = "Contract Year Shortened - Reimbursable">
								<cfset newfop_f_desc = "Contract Year Shortened - Fee">
								<cfset vehnewfop_desc = "Contract Year Shortened">
							</cfif>
							<cfset newsuccfop_desc = "New Contract Start Date">
							<cfset vehnewsuccfop_desc = "New Contract Start Date">
						</cfif>

						<!--- ECP Adjustment (REIMBURSABLE): if extending/shortening, and mods exist --->
						<cfif (extForm.extSubMode eq "INC-EXT" or extForm.extSubMode eq "DEC-SHR") and extForm.modsExist>
							<cfif extForm[costCat & "_R_newECP"] neq 0 and extForm[costCat & "_R_newECP"] neq "">
								<cfset newECPCost = replace(extForm[costCat & "_R_newECP"],",","","all")> <!--- remove commas --->
								<!--- create one time REIMBURSABLE adjustment, with 1 cost record --->
								<cfinvoke component="#application.paths.components#aapp_adjustment" method="insertAdjustment"
									aapp="#arguments.aapp#"
									description="#newecp_r_desc#"
									includeECP="1"
									modRequired="1"
									ongoing="0"
									currentCost="#newECPCost#"
									costCat="#rstCostCategories.costCatID#"
									returnvariable="newAdjustID">
								<cfinvoke component="#application.paths.components#aapp_adjustment" method="insertAdjustmentCost"
									adjustmentID="#newAdjustID#"
									contractYear="#extForm.newContractLength#"
									amount="#newECPCost#"
									fixed="1">
							</cfif>
						</cfif>

						<!--- ECP Adjustment (FEE) : Perform in all cases except for deleting contract year --->
						<!--- create one time FEE adjustment, with 1 cost record --->
						<cfif extForm.extSubMode neq "DEC-DEL" and extForm[costCat & "_F_newECP"] neq 0 and extForm[costCat & "_F_newECP"] neq "">
							<cfset newECPCost = replace(extForm[costCat & "_F_newECP"],",","","all")>
							<cfinvoke component="#application.paths.components#aapp_adjustment" method="insertAdjustment"
								aapp="#arguments.aapp#"
								description="#newecp_f_desc#"
								includeECP="1"
								biFee="1"
								modRequired="1"
								ongoing="0"
								currentCost="#newECPCost#"
								costCat="#rstCostCategories.costCatID#"
								returnvariable="newAdjustID">
							<cfinvoke component="#application.paths.components#aapp_adjustment" method="insertAdjustmentCost"
								adjustmentID="#newAdjustID#"
								contractYear="#extForm.newContractLength#"
								amount="#newECPCost#"
								fixed="1">
						</cfif>

						<!--- FOPs (current AAPP) --->
						<cfif extForm[costCat & "_R_newFOP"] neq 0 and extForm[costCat & "_R_newFOP"] neq "">
							<cfset newFOPCost = replace(extForm[costCat & "_R_newFOP"],",","","all")>
							<cfinvoke component="#application.paths.components#aapp_adjustment" method="insertFOP"
								aapp="#arguments.aapp#"
								programYear="#request.py#"
								description="#newfop_r_desc#"
								amount="#newFOPCost#"
								costCatID="#rstCostCategories.costCatID#"
								adjustmentType="ADJ"
								fundingOfficeNum="#rstAAPPGeneral.fundingOfficeNum#">
						</cfif>
						<cfif extForm[costCat & "_F_newFOP"] neq 0 and extForm[costCat & "_F_newFOP"] neq "">
							<cfset newFOPCost = replace(extForm[costCat & "_F_newFOP"],",","","all")>
							<cfinvoke component="#application.paths.components#aapp_adjustment" method="insertFOP"
								aapp="#arguments.aapp#"
								programYear="#request.py#"
								description="#newfop_f_desc#"
								amount="#newFOPCost#"
								costCatID="#rstCostCategories.costCatID#"
								adjustmentType="ADJ"
								fundingOfficeNum="#rstAAPPGeneral.fundingOfficeNum#">
						</cfif>

						<!--- FOPs (successor AAPP) --->
						<cfif rstAAPPGeneral.succAAPPnum neq "" and extForm[costCat & "_newSuccFOP"] neq 0 and extForm[costCat & "_newSuccFOP"] neq "">
							<cfset newFOPCost = replace(extForm[costCat & "_newSuccFOP"],",","","all")>
							<cfinvoke component="#application.paths.components#aapp_adjustment" method="insertFOP"
								aapp="#rstAAPPGeneral.succAAPPnum#"
								programYear="#request.py#"
								description="#newsuccfop_desc#"
								amount="#newFOPCost#"
								costCatID="#rstCostCategories.costCatID#"
								adjustmentType="ADJ"
								fundingOfficeNum="#rstAAPPGeneral.fundingOfficeNum#">
						</cfif>
					</cfloop><!--- loop through cost cats --->

					<!--- B3 --->
					<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" costCatCode="#extForm.VEH_costCat#" returnvariable="rstCostCategories">
					<cfif extForm.VEH_newFOP neq 0 and extForm.VEH_newFOP neq "">
						<cfset newFOPCost = replace(extForm.VEH_newFOP,",","","all")>
						<cfinvoke component="#application.paths.components#aapp_adjustment" method="insertFOP"
							aapp="#arguments.aapp#"
							programYear="#request.py#"
							description="#vehnewfop_desc#"
							amount="#newFOPCost#"
							costCatID="#rstCostCategories.costCatID#"
							adjustmentType="ADJ"
							fundingOfficeNum="#rstAAPPGeneral.fundingOfficeNum#">
					</cfif>
					<cfif extForm.VEH_newSuccFOP neq 0 and extForm.VEH_newSuccFOP neq "">
						<cfset newFOPCost = replace(extForm.VEH_newSuccFOP,",","","all")>
						<cfinvoke component="#application.paths.components#aapp_adjustment" method="insertFOP"
							aapp="#rstAAPPGeneral.succAAPPnum#"
							programYear="#request.py#"
							description="#vehnewsuccfop_desc#"
							amount="#newFOPCost#"
							costCatID="#rstCostCategories.costCatID#"
							adjustmentType="ADJ"
							fundingOfficeNum="#rstAAPPGeneral.fundingOfficeNum#">
					</cfif>

				</cfif> <!--- did user click the "DO NOT CREATE" checkbox? --->

				<!--- update Full CY amount for ongoing adjustments that started in final year --->
				<cfif (extForm.extSubMode eq "INC-EXT" or extForm.extSubMode eq "DEC-SHR") and extForm.lstOngoingFinal neq "">
					<cfloop list="#extForm.lstOngoingFinal#" index="ai">
						<cfset newCYCost = replace(extForm[ai & "_newFullCYAmount"],",","","all")>
						<!--- update the full CY amount for each adjustment --->
						<cfquery name="qryUpdateFullCYAmount" datasource="#request.dsn#">
						update	adjustment
						set		cost_full_cy = #newCYCost#
						where	adjustment_id = #ai#
						</cfquery>
					</cfloop>
				</cfif>

				<!--- changes to workload levels (O/A, CTS only)--->
				<cfif isDefined("extForm.lstWorkloadFinal")>
					<cfloop list="#extForm.lstWorkloadFinal#" index="wl">
						<!--- loop through workload levels, and update final year values (rows for new year already created above)--->
						<cfset newWLlevel = replace(extForm[WL & "_WL_newAmount"],",","","all")>
						<cfquery name="qryUpdateWLlevels" datasource="#request.dsn#">
						update	aapp_workload
						set		value = #newWLlevel#,
								update_function = 'U',
								update_time = sysdate,
								update_user_id = '#session.userID#'
						where	aapp_num = #arguments.aapp# and
								workload_type_code = '#ucase(wl)#' and
								contract_year = #extForm.newContractLength#
						</cfquery>
					</cfloop>
				</cfif>


				<!--- audit record --->
				<cfset application.outility.insertSystemAudit (
					aapp="#arguments.aapp#",
					statusID="#request.statusID#",
					sectionID="300",
					description="Contract #tmpDesc#",
					userID="#session.userID#")>
				<cfset extForm.success = 1>

   				<!--- update snapshot table to reflect new end date --->
                <cfstoredproc procedure="JFAS_SNAPSHOT_PKG.sp_updAAPP_CONTRACT_SNAPSHOT" returncode="no">
                    <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="argAAPP_NUM" value="#arguments.aapp#" null="no">
                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUser_ID" value="#session.userid#" null="no">
                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUpdate_Notes" value="Updated from Contract Extension" null="no">
                </cfstoredproc>
                
                <cfif rstAAPPGeneral.succAAPPNum neq "">
					<!--- if successor is impacted, need to update snapshot table for that AAPP as well --->
					<cfstoredproc procedure="JFAS_SNAPSHOT_PKG.sp_updAAPP_CONTRACT_SNAPSHOT" returncode="no">
	                    <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="argAAPP_NUM" value="#rstAAPPGeneral.succAAPPNum#" null="no">
	                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUser_ID" value="#session.userid#" null="no">
	                    <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUpdate_Notes" value="Updated from Contract Extension (of predecessor)" null="no">
	                </cfstoredproc>
				</cfif>

				</cftransaction>
			</cfcase>
		</cfswitch> <!--- form step --->
		<cfreturn extForm>
	</cffunction>
</cfcomponent>

