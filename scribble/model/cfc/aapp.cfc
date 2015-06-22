
<!---
page: aapp.cfc

description: component that handles main aapp functions

revisions:
YEAR-MM-DD
2006-12-28	mstein	When saving AAPP Summary, check to see if chenges in date or contract length
					might affect a successor
2007-01-18	mstein	Don't recreate budget adjustments for contracts that have been migrated,
					or that have passed out of their first year
2007-02-05	mstein	if Base,Incentive fees have been unselected, need to not only zero out
					these rows in the budget (existing func), but also recalc totals (defect 132)

2007-02-08	mstein	create new function getAAPPNumListing to return abbreviated AAPP listing
					(for use on report criteria templates) - defect 137

2007-03-07	mstein	changed getContractListingHome to query view directly (faster)
2007-03-07	mstein	changed getContractListingHome to allow for new status filters: "current" and "future"
2007-03-30	mstein	adjusted getContractListingHome so that "current" filter does not return contracts past their end date

2007-05-16	mstein	added testForInactive function that checks to see if an AAPP can be made inactive
					also incorporated this into the saveAAPPSummary function
2007-06-07	mstein	defect 211 - error in testForInactive when AAPP has no FMS data (which is a possibility)
					put in temporary fix that doesn't run edit check if no FMS data exists (will clarify with JC post 1.2)
2007-06-11	mstein	defect 213 - saving AAPP summary should not re-create ecp adjustments if contract is not awarded yet
2007-07-11  abai    Added new column (Venue) into fundtion "getContractListingHome".
2007-07-12	mstein	Modified criteria in getContractListingHome for "Due for Reconciliation" filter to ignore contracts
					that were most likely reconclied in FilePro prior to go-live
2007-08-13	rroser	Modified getContractListingHome to allow regional users to see their region and CCCs
2007-09-06  abai    Add column venue into function getAAPPGeneral
2007-09-10	mstein	Added function reactivateAAPP, to reactivate AAPPs
2009-12-22	mstein  Updated getAAPPContractor for NCFMS
2011-06-20	mstein	Updated getAAPPContractor and saveAAPPContractor to remove Footprint/DocNum behavior (JFAS 2.9)
2012-01-21	mstein	Updated aappRequest to include budgetInputTye in request for creating new AAPP
2014-03-06	mstein	Updated saveAAPPContractor to allow user to add new contractors on the fly
2014-06-05	ssurikov Update Snapshot Contractor's for DOL and CCC
YEAR-MM-DD
--->

<cfcomponent displayname="AAPP" hint="Component that contains all general contract queries and functions">

	<cffunction name="getAAPPGeneral" hint="get general info about AAPP for one or many AAPPs" returntype="query" access="public">
		<cfargument name="aapp" type="numeric" required="yes" default="0">
		<cfargument name="status" type="string" required="no" default="">

		<cfquery name="qryGetAAPPGeneral" >
		select	aappNum,
				predAAPPNum,
				succAAPPNum,
				agreementTypeCode,
				agreementTypeDesc,
				programActivity,
				dateStart,
				dateEnd,
				venue,
				curContractYear,
				yearsBase,
				yearsOption,
				lastReconYear,
				contractStatusID,
				contractStatusDesc,
				centerID,
				centerName,
				fundingOfficeNum,
				fundingOfficeDesc,
				contractNum,
				contractorName,
				budgetInputType
		from	AAPP_CONTRACT_SNAPSHOT
		where	1 = 1
		<cfif arguments.aapp neq 0>
			and aappNum = #arguments.aapp#
		</cfif>
		<cfif arguments.status neq "">
			and contractStatusID = #arguments.status#
		</cfif>
		</cfquery>

		<cfreturn qryGetAAPPGeneral>

	</cffunction>


	<cffunction name="getAAPPGeneral_CCC" hint="get general info about CCC for one or many CCCs" returntype="query" access="public">
		<cfargument name="aapp" type="numeric" required="no" default="0">

		<cfquery name="qryGetAAPPGeneral_CCC" >
		select aapp_num as aappNum,
				center_id as centerID,
				funding_office_num as fundingOfficeNum,
				state_abbr as state,
				contract_status_id as contractStatusID,
				contract_num as contractNum
		from AAPP
		where aapp_num = #arguments.aapp#
		</cfquery>

		<cfreturn qryGetAAPPGeneral_CCC>

	</cffunction>

	<cffunction name="getAAPPNumListing" access="public" returntype="query" hint="Returns a list of AAPP Numbers, used on Report Templates">
		<cfargument name="status" type="numeric" required="no">
		<cfargument name="fundingOfficeNum" type="numeric" required="no">
		<cfargument name="agreementType" type="string" required="no">

		<cfquery name="qryGetAAPPNumListing" >
		select	aapp_num aappNum
		from	aapp
		where	1 = 1
			<cfif isDefined("arguments.status")>
				and contract_status_id = #arguments.status#
			</cfif>
			<cfif isDefined("arguments.fundingOfficeNum")>
				and (funding_office_num = #arguments.fundingOfficeNum# or agreement_Type_code = 'CC')
			</cfif>
			<cfif isDefined("arguments.agreementType")>
				and agreement_type_code in (#listqualify(arguments.agreementType, "'")#)
			</cfif>
		order by aappNum
		</cfquery>

		<cfreturn qryGetAAPPNumListing>
	</cffunction>

	<cffunction name="aappRequest" access="public" returntype="void" hint="Function runs for every request in aapp folder">
		<cfargument name="aapp" type="numeric" required="yes">

		<cfset request.aapp = arguments.aapp>

		<cfif arguments.aapp eq 0> <!--- new aapp --->

			<!--- set some default request variables --->
			<cfset request.agreementTypeCode = url.radAgreementType>
			<cfset request.dateEnd = "">
			<cfset request.curContractYear = "">
			<cfset request.statusID=1>
			<cfset request.budgetInputType = "F">
			<cfif isdefined("url.predaapp")>
				<cfset request.predAAPPNum = url.predaapp>
			<cfelse>
				<cfset request.predAAPPNum = "">
			</cfif>


		<cfelse> <!--- existing aapp --->

			<!--- get general aapp data to display in header --->
			<cfset rstAAPPHeaderInfo = this.getAAPPGeneral(arguments.aapp)>
			<!--- set request variables for aapp --->
			<cfset request.agreementTypeCode = rstAAPPHeaderInfo.agreementTypeCode>
			<cfset request.contractorName = rstAAPPHeaderInfo.contractorName>
			<cfset request.centerName = rstAAPPHeaderInfo.centerName>
			<cfset request.dateStart = rstAAPPHeaderInfo.dateStart>
			<cfset request.dateEnd = rstAAPPHeaderInfo.dateEnd>
			<cfset request.contractNum = rstAAPPHeaderInfo.contractNum>
			<cfset request.fundingOfficeDesc = rstAAPPHeaderInfo.fundingOfficeDesc>
			<cfset request.fundingOfficeNum = rstAAPPHeaderInfo.fundingOfficeNum>
			<cfset request.curContractYear = rstAAPPHeaderInfo.curContractYear>
			<cfset request.predAAPPNum = rstAAPPHeaderInfo.predAAPPNum>
			<cfset request.succAAPPNum = rstAAPPHeaderInfo.succAAPPNum>
			<cfset request.statusID = rstAAPPHeaderInfo.contractStatusID>
			<cfset request.budgetInputType = rstAAPPHeaderInfo.budgetInputType>
		</cfif>

	</cffunction>

	<cffunction name="isValidAAPP" returntype="boolean" access="public" hint="Determines whether aapp number is valid or not">
		<cfargument name="aapp" type="string" required="yes">

		<!--- check to make sure aapp exists in aapp table --->
		<cfset rstAAPPCheck = this.getAAPPGeneral(arguments.aapp)>
		<cfif rstAAPPCheck.recordCount gt 0>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>

	</cffunction>

	<cffunction name="getAAPPLength" hint="Gets length of AAPP" returntype="numeric" access="public">
		<cfargument name="aapp" type="numeric" required="yes">

		<cfquery name="qryGetAAPPLength" >
		select	years_option + years_base as contractLength
		from	aapp
		where	aapp_num = #arguments.aapp#
		</cfquery>

		<cfreturn qryGetAAPPLength.contractLength>

	</cffunction>


	<cffunction name="getAAPPContractYears" returntype="query" access="public" hint="Returns query with year num, start date, and end date" >
		<cfargument name="aapp" type="numeric" required="yes">
		<cfargument name="contractYear" type="numeric" required="no">

		<cfset aappLength = this.getAAPPLength(arguments.aapp) />

		<cfquery name="qryGetAAPPContractYears" >
		select	yearList.contractYear,
				contract.fun_getaappdate (a.aapp_num,  yearList.contractYear, 'S') dateStart,
				contract.fun_getaappdate (a.aapp_num, yearList.contractYear, 'E') dateEnd,
				case when contractYear <= years_base then 'B' else 'O' end yearType
		from	aapp a,
				(SELECT LEVEL contractYear
 			 	FROM DUAL
			 	CONNECT BY LEVEL <= #aappLength#) yearList
		where aapp_num = #arguments.aapp#
			<cfif isDefined("arguments.contractYear")>
				and contractYear = #arguments.contractYear#
			</cfif>
		</cfquery>

		<cfreturn qryGetAAPPContractYears>
	</cffunction>


	<cffunction name="getAAPPServiceTypes" hint="Gets list of service types for an AAPP (contract or grant)" returntype="string" access="public">
		<cfargument name="aapp" type="numeric" required="yes">

		<cfquery name="qryGetAAPPServiceTypes" >
		select	contract_type_code
		from	aapp_contract_type
		where	aapp_num = #arguments.aapp#
		</cfquery>

		<cfreturn valuelist(qryGetAAPPServiceTypes.contract_type_code)>

	</cffunction>

	<cffunction name="getAAPPCurrentContractYear" hint="Gets current contract year of an AAPP" returntype="numeric" access="public">
		<cfargument name="aapp" type="numeric" required="yes">

		<cfquery name="qryCurrentContractYear" >
		select	contract.fun_getcurrntcontract_year(#arguments.aapp#) as currentYear
		from	dual
		</cfquery>

		<cfreturn qryCurrentContractYear.currentYear>

	</cffunction>

	<cffunction name="getAAPPContractYear_byDate" hint="Gets contract year of an AAPP, based on date" returntype="numeric" access="public">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfargument name="testDate" type="date" required="yes">

		<cfset rstContractYears = this.getAAPPContractYears(arguments.aapp) />
		<cfloop query="rstContractYears">
			<!--- is contract year end date greater than or equal to test date? Then capture year num --->
			<cfif datecompare(dateEnd, arguments.testDate) neq -1>
				<cfset returnYear = contractYear>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfreturn returnYear>

	</cffunction>


	<cffunction name="getAAPPSummary" hint="Get AAPP data for Summary Screen" returntype="query" access="public">
		<cfargument name="aapp" type="numeric" required="yes">

		<!--- get basic data for aapp --->
		<cfquery name="qryGetAAPPSummary"  maxrows="1">
		select	funding_office_num as fundingOfficeNum,
				contract_status_id as statusID,
				agreement_type_code as agreementTypeCode,
				'' as serviceTypes,
				other_type_desc as otherTypeDesc,
				center_id as centerID,
				state_abbr as state,
				venue as venue,
				competition_code as competitionCode,
				smb_setaside_id as setAsideID,
				date_start as dateStart,
				'' as dateEnd,
				years_base as yearsBase,
				years_option as yearsOption,
				cotr as cotr,
				comments as comments,
				pred_aapp_num as predAAPPNum,
				'' as latestFOPID
		from	aapp
		where	aapp_num = #arguments.aapp#
		</cfquery>

		<!--- get list of service types --->
		<cfquery name="qryGetServiceTypes" >
		select	contract_type_code
		from	aapp_contract_type
		where	aapp_num =  #arguments.aapp#
		</cfquery>

		<!--- get list of base,incentive fees
		<cfquery name="qryGetBIServiceTypes" >
		select	contract_type_code
		from	aapp_bi_fees
		where	aapp_num =  #arguments.aapp#
		</cfquery>
		--->

		<!--- get contract end date --->
		<cfquery name="qryGetEndDate"  maxrows="1">
		select	max(date_end) as dateEnd
		from	aapp_yearend
		where	aapp_num = #arguments.aapp#
		order	by contract_year desc
		</cfquery>

		<!--- get latest FOP --->
		<cfquery name="qryGetLatestFOP"  maxrows="1">
		select	max(fop_id) as latestFOPID
		from	fop
		where	aapp_num = #arguments.aapp#
		</cfquery>

		<cfset temp = querysetcell(qryGetAAPPSummary,"serviceTypes",valuelist(qryGetServiceTypes.contract_type_code))>
		<!---
		<cfset temp = querysetcell(qryGetAAPPSummary,"BIFees",valuelist(qryGetBIServiceTypes.contract_type_code))>
		--->
		<cfif qryGetEndDate.dateEnd neq "">
			<cfset temp = querysetcell(qryGetAAPPSummary,"dateEnd",qryGetEndDate.dateEnd)>
		</cfif>
		<cfif qryGetLatestFOP.latestFOPID neq "">
			<cfset temp = querysetcell(qryGetAAPPSummary,"latestFOPID",qryGetLatestFOP.latestFOPID)>
		</cfif>

		<cfreturn qryGetAAPPSummary>

	</cffunction>


	<cffunction name="saveAAPPSummary" access="public" returntype="struct" hint="saves data content from AAPP summary form">
		<cfargument name="formData" type="struct" required="yes">

		<cfset success = "true">
		<cfset createAdjustments = "false">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<!--- server-side validation checks --->
		<cfif arguments.formData.hidAAPP eq 0> <!--- new AAPP validation --->

			<!--- check to make sure user entered valid AAPP number --->
			<!--- (doesn't already exist in db) --->
			<cfquery name="qryCheckAAPPMask" >
			select	count(aapp_num) as numRecs
			from	aapp
			where	aapp_num = #arguments.formData.txtAAPP#
			</cfquery>

			<!--- if aapp already exists, set success to false, return error message --->
			<cfif qryCheckAAPPMask.numRecs gt 0>
				<cfset success = "false">
				<cfset errorMessages = listAppend(errorMessages,"This AAPP series has already been used, please choose another.","~")>
				<cfset errorFields = listAppend(errorFields,"txtAAPP")>
			</cfif>

			<cfset validAAPPNum = arguments.formData.txtAAPP>

		<cfelse> <!--- existing aapp validation --->
			<!--- TO - DO: make sure service types weren't taken away that already have adjustments --->
			<!--- make sure start date wasn't moved later than any existing adjustment effective dates (or FOP dates) --->
			<!--- make sure contract length... something something --->

			<!--- if user is making AAPP inactive, check to see if that can be done --->
			<cfif arguments.formData.radStatus eq 0>
				<cfset lstInactiveMessages = this.testForInactive(arguments.formData.hidAAPP)>
				<cfif listLen(lstInactiveMessages,"~") gt 0>
					<cfset success = "false">
					<cfloop list="#lstInactiveMessages#" index="msg" delimiters="~">
						<cfset errorMessages = listAppend(errorMessages,msg,"~")>
					</cfloop>
					<cfset errorFields = listAppend(errorFields,"radStatus")>
				</cfif>
			</cfif>

			<cfset validAAPPNum = arguments.formData.hidAAPP>
		</cfif>

		<cfif success> <!--- if validation passed --->

			<cftransaction>

			<cfif arguments.formData.hidAAPP eq 0> <!--- new AAPP --->

				<!--- insert summary data in aapp table --->
				<cfquery name="qryInsertAAPP" >
				insert	into aapp (
					aapp_num,
					pred_aapp_num,
					center_id,
					funding_office_num,
					state_abbr,
					venue,
					contract_status_id,
					agreement_type_code,
					other_type_desc,
					competition_code,
					smb_setaside_id,
					date_start,
					years_base,
					years_option,
					cotr,
					comments,
					vst_slots,
					update_user_id,
					update_function,
					update_time)
				values (
					#validAAPPNum#,
					<cfif arguments.formData.hidPredAAPP neq "">#arguments.formData.hidPredAAPP#<cfelse>null</cfif>,
					<cfif arguments.formData.cboCenter neq "">#listgetat(arguments.formData.cboCenter,1,"__")#<cfelse>null</cfif>,
					#arguments.formData.cboFundingOffice#,
					<cfif arguments.formData.cboState neq "">'#left(arguments.formData.cboState,2)#'<cfelse>null</cfif>,
					<cfif arguments.formData.txtVenue neq "">'#arguments.formData.txtVenue#'<cfelse>null</cfif>,
					#arguments.formData.radStatus#,
					'#arguments.formData.cboAgreement#',
					<cfif isDefined("arguments.formData.txtOtherTypeDesc") and arguments.formData.txtOtherTypeDesc neq "">'#arguments.formData.txtOtherTypeDesc#'<cfelse>null</cfif>,
					<cfif isDefined("arguments.formData.cboCompetition") and arguments.formData.cboCompetition neq "">'#arguments.formData.cboCompetition#'<cfelse>null</cfif>,
					<cfif isDefined("arguments.formData.cboSetAside") and arguments.formData.cboSetAside neq "">#arguments.formData.cboSetAside#<cfelse>null</cfif>,
					<cfif arguments.formData.txtDateStart neq "">to_date('#arguments.formData.txtDateStart#', 'MM/DD/YYYY')<cfelse>null</cfif>,
					<cfif isDefined("arguments.formData.radYearsBase") and arguments.formData.radYearsBase neq "">#arguments.formData.radYearsBase#<cfelse>null</cfif>,
					<cfif isDefined("arguments.formData.radYearsOption") and arguments.formData.radYearsOption neq "">#arguments.formData.radYearsOption#<cfelse>null</cfif>,
					<cfif arguments.formData.txtCOTR neq "">'#arguments.formData.txtCOTR#'<cfelse>null</cfif>,
					<cfif arguments.formData.txtComments neq "">'#arguments.formData.txtComments#'<cfelse>null</cfif>,
					0,
					'#session.userID#',
					'#request.auditVarInsert#',
					sysdate
					)
				</cfquery>

				<cfset application.outility.insertSystemAudit (
					aapp="#validAAPPNum#",
					statusID="#arguments.formData.radStatus#",
					sectionID="100",
					description="AAPP created",
					userID="#session.userID#")>


				<!--- insert new rows in contract type, year end, workload and budget tables (for contracts and grants only) --->
				<cfif listFindNoCase("DC,GR", arguments.formData.cboAgreement)>
					<cfset newContractLength = arguments.formData.radYearsBase + arguments.formData.radYearsOption />
					<cfset createAdjustments = "true" />

					<!--- insert service types in child table --->
					<cfloop index="serviceType" list="#arguments.formData.ckbServiceTypes#">
						<cfset temp = insertServiceType(validAAPPNum, serviceType, arguments.formData.hidPredAAPP)>
					</cfloop>

					<cfset temp = this.createContractYearData(validAAPPNum,newContractLength,arguments.formData.txtDateStart)>
					<cfinvoke component="#application.paths.components#aapp_workload" method="createBlankWorkloadData"
						aapp="#validAAPPNum#"
						newContractLength="#newContractLength#"
						predaapp="#iif(arguments.formData.hidPredAAPP eq "",0,arguments.formData.hidPredAAPP)#"
						serviceTypes="#arguments.formData.ckbServiceTypes#">
					<cfinvoke component="#application.paths.components#aapp" method="createBlankBudget"
						aapp="#validAAPPNum#"
						newContractLength="#newContractLength#"
						serviceTypes="#arguments.formData.ckbServiceTypes#">

				</cfif>


			<cfelse> <!--- existing aapp --->


				<!--- update summary data in aapp table --->
				<cfquery name="qryUpdateAAPPSummary" >
				update	aapp
				set		center_id = <cfif arguments.formData.cboCenter neq "">#listgetat(arguments.formData.cboCenter,1,"__")#<cfelse>null</cfif>,
						<cfif isDefined("arguments.formData.cboFundingOffice")>
							funding_office_num = #arguments.formData.cboFundingOffice#,
						</cfif>
						state_abbr = <cfif arguments.formData.cboState neq "">'#left(arguments.formData.cboState,2)#'<cfelse>null</cfif>,
						venue = <cfif arguments.formData.txtVenue neq "">'#arguments.formData.txtVenue#'<cfelse>null</cfif>,
						contract_status_id = #arguments.formData.radStatus#,
						agreement_type_code = '#arguments.formData.cboAgreement#',
						other_type_desc = <cfif isDefined("arguments.formData.txtOtherTypeDesc") and arguments.formData.txtOtherTypeDesc neq "">'#arguments.formData.txtOtherTypeDesc#'<cfelse>null</cfif>,
						competition_code = <cfif isDefined("arguments.formData.cboCompetition") and arguments.formData.cboCompetition neq "">'#arguments.formData.cboCompetition#'<cfelse>null</cfif>,
						smb_setaside_id = <cfif isDefined("arguments.formData.cboSetAside") and arguments.formData.cboSetAside neq "">#arguments.formData.cboSetAside#<cfelse>null</cfif>,
						<cfif isDefined("arguments.formData.txtDateStart")>
							date_start = <cfif arguments.formData.txtDateStart neq "">to_date('#arguments.formData.txtDateStart#', 'MM/DD/YYYY')<cfelse>null</cfif>,
						</cfif>
						<cfif isDefined("arguments.formData.radYearsBase")>
							years_base = <cfif arguments.formData.radYearsBase neq "">#arguments.formData.radYearsBase#<cfelse>null</cfif>,
						</cfif>
						<cfif isDefined("arguments.formData.radYearsOption")>
							years_option =  <cfif arguments.formData.radYearsOption neq "">#arguments.formData.radYearsOption#<cfelse>null</cfif>,
						</cfif>
						cotr = <cfif arguments.formData.txtCOTR neq "">'#arguments.formData.txtCOTR#'<cfelse>null</cfif>,
						comments = <cfif arguments.formData.txtComments neq "">'#arguments.formData.txtComments#'<cfelse>null</cfif>,
						update_user_id = '#session.userID#',
						update_function = '#request.auditVarUpdate#',
						update_time = sysdate
				where	aapp_num = #validAAPPNum#
				</cfquery>


				<!--- check for data changes in fields that affect budget / workload --->
				<cfif listFindNoCase("DC,GR",arguments.formData.cboAgreement)>

					<cfset newContractLength = arguments.formData.radYearsBase + arguments.formData.radYearsOption>

					<!--- need to see if budget data exists or not. If not, create blank --->
					<!--- this could occur if orig record only had "Other", but then user added A, C1, etc --->
					<cfquery name="qryCheckforFutureBudget" >
					select	count(*) as numRecs
					from	aapp_contract_future
					where	aapp_num = #validAAPPNum#
					</cfquery>

					<cfquery name="qryCheckforContractAwardRecs" >
					select	count(*) as numRecs
					from	aapp_contract_award
					where	aapp_num = #validAAPPNum#
					</cfquery>

					<cfif (qryCheckforFutureBudget.numRecs eq 0) or (qryCheckforContractAwardRecs.numRecs eq 0)>
						<cfinvoke component="#application.paths.components#aapp" method="createBlankBudget"
							aapp="#validAAPPNum#"
							newContractLength="#newContractLength#"
							serviceTypes="#arguments.formData.ckbServiceTypes#">
					</cfif>

					<!--- check to see if contract year end data should be changed --->
					<cfif isDefined("arguments.formData.txtDateStart") and (arguments.formData.txtDateStart neq arguments.formData.hidDateStart)>
						<cfset temp = this.createContractYearData(validAAPPNum,newContractLength,arguments.formData.txtDateStart)>
					<cfelse>
						<cfif newContractLength neq arguments.formData.hidContractLength>
							<cfset temp = this.adjustContractYearData(validAAPPNum,arguments.formData.hidContractLength,newContractLength)>
						</cfif>
					</cfif>

					<!--- if start date, or length of contract changed --->
					<cfif (isDefined("arguments.formData.txtDateStart") and (arguments.formData.txtDateStart neq arguments.formData.hidDateStart)) or
						(newContractLength neq arguments.formData.hidContractLength)>

						<!--- if successor exists, need to change dates to be inline with new end date of this contract --->
						<cfquery name="qryGetSuccessor" >
						select	aapp_num as succAAPPNum,
								date_start as succDateStart
						from	aapp
						where	pred_aapp_num = #validAAPPNum#
						</cfquery>

						<cfif qryGetSuccessor.recordcount neq 0>

							<!--- get new end date of contract being edited --->
							<cfquery name="qryGetEndDate" >
							select	max(date_end) as AAPPendDate
							from	aapp_yearend
							where	aapp_num = #validAAPPNum#
							</cfquery>

							<cfif datecompare(dateadd("d",1,qryGetEndDate.AAPPendDate),qryGetSuccessor.succDateStart) neq 0> <!--- end date not adjacent to successor start date? --->
								<cfset dateChangeAmount = datediff("d",qryGetSuccessor.succDateStart,dateadd("d",1,qryGetEndDate.AAPPendDate)) />
								<cfquery name="qryUpdateSuccessorDates" >
								update	aapp set
										date_start = date_start + #dateChangeAmount#
								where	aapp_num = #qryGetSuccessor.succAAPPNum#
								</cfquery>
								<cfquery name="qryUpdateSuccessorDates" >
								update	aapp_yearend set
										date_end = date_end + #dateChangeAmount#
								where	aapp_num = #qryGetSuccessor.succAAPPNum#
								</cfquery>
							</cfif>

						</cfif>
					</cfif>

					<!--- did length of contract change? --->
					<cfif newContractLength neq arguments.formData.hidContractLength>

						<cfset createAdjustments = "true" />

						<!--- then adjust workload length --->
						<cfinvoke component="#application.paths.components#aapp_workload" method="adjustWorkloadLength"
							aapp="#validAAPPNum#"
							newContractLength="#newContractLength#">

						<!--- adjust length of onGoing adustments --->
						<cfinvoke component="#application.paths.components#aapp_adjustment" method="adjustOngoingEstimates"
							aapp="#validAAPPNum#"
							oldContractLength="#arguments.formData.hidContractLength#"
							newContractLength="#newContractLength#">

						<!--- then adjust budget length --->
						<cfinvoke component="#application.paths.components#aapp" method="adjustBudgetLength"
							aapp="#validAAPPNum#"
							newContractLength="#newContractLength#">

					</cfif>


					<!--- did service types change? (ignore "other")--->
					<cfset oldServiceTypes = listSort(replace(arguments.formData.hidServiceTypes,"OT","","all"),"textNoCase")>
					<cfset newServiceTypes = listSort(replace(arguments.formData.ckbServiceTypes,"OT","","all"),"textNoCase")>
					<cfif oldServiceTypes neq newServiceTypes>

						<!--- update contents of aapp_contract_type --->
						<!--- loop through new list, insert any that were not previously checked --->
						<cfloop list="#newServiceTypes#" index="newST">
							<cfif NOT listFindNoCase(oldServiceTypes, newST)>
								<cfset temp = insertServiceType(validAAPPNum, newST, arguments.formData.hidPredAAPP)>
							</cfif>
						</cfloop>
						<!--- loop through old list, delete any that were just removed --->
						<cfloop list="#oldServiceTypes#" index="oldST">
							<cfif NOT listFindNoCase(newServiceTypes, oldST)>
								<cfset temp = deleteServiceType(validAAPPNum, oldST)>
							</cfif>
						</cfloop>


						<!--- then adjust workload columns --->
						<cfset createAdjustments = "true" />
						<cfinvoke component="#application.paths.components#aapp_workload" method="adjustWorkloadServiceTypes"
							aapp="#validAAPPNum#"
							newServiceTypes="#newServiceTypes#">

						<!--- then adjust budget service types --->
						<cfinvoke component="#application.paths.components#aapp" method="adjustBudgetServiceTypes"
							aapp="#validAAPPNum#"
							newServiceTypes="#newServiceTypes#">

					</cfif>


					<!--- change to the number of base years (even without change in contract length) requires adjustment changes --->
					<cfif (arguments.formData.radYearsBase neq arguments.formData.hidYearsBase)>
						<cfset createAdjustments = "true" />
					</cfif>

				</cfif> <!--- check for data changes in fields that affect budget / workload --->

				<cfset application.outility.insertSystemAudit (
					aapp="#validAAPPNum#",
					statusID="#arguments.formData.radStatus#",
					sectionID="100",
					description="AAPP Summary information updated",
					userID="#session.userID#")>

				<!--- were changes made to this AAPP that require current PY FOPs to be reversed?
				 (this functionality never implemented)
				<cfif arguments.formData.hidAdjustCurrentFOPs neq "">
					<cfinvoke component="#application.paths.components#aapp_adjustment"
						method="reverseProgramYearFOPs"
						aapp="#arguments.formData.hidAdjustCurrentFOPs#">
				</cfif>
				--->


			</cfif> <!--- existing app, or new ? --->

			<cfif listFindNoCase("DC,GR",arguments.formData.cboAgreement)>

				<!--- create/re-create all initial budget adjustments based on aapp_budget --->
				<!--- only run if within first contract year --->
				<cfif (request.curContractYear lte 1) and (createAdjustments)>

					<!--- mstein: need to make sure this AAPP has been awarded --->
					<!--- (otherwise, no adjustments are written) --->
					<cfquery name="qryBudgetStatusCheck" >
					select	budget_input_type
					from	aapp
					where	aapp_num = #validAAPPNum#
					</cfquery>
					<!--- mstein: need to make sure this is not an AAPP that was migrated with --->
					<!--- award package adjustments already (do not re-create) --->
					<cfquery name="qryMigrateCheck" >
					select	aapp_num
					from	aapp_migration
					where	aapp_num=#validAAPPNum#
					and		award_package=1
					</cfquery>


					<cfif (qryMigrateCheck.recordcount eq 0) and (qryBudgetStatusCheck.budget_input_type neq "F")>
						<cfinvoke component="#application.paths.components#aapp_adjustment" method="createInitialBudgetAdjustments" aapp="#validAAPPNum#" />
					</cfif>
				</cfif>
			</cfif>
			

    	<cfstoredproc procedure="JFAS_SNAPSHOT_PKG.sp_updAAPP_CONTRACT_SNAPSHOT" returncode="no">
			<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="argAAPP_NUM" value="#validAAPPNum#" null="no">
			<cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUser_ID" value="#session.userid#" null="no">
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUpdate_Notes" value="Modified from AAPP Setup" null="no">
		</cfstoredproc>
         


			</cftransaction>
		</cfif>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfif success>
			<cfset stcResults.aappNum = validAAPPNum>
		</cfif>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>


		<cfreturn stcResults>

	</cffunction>


	<cffunction name="insertServiceType" hint="Insert row in AAPP_CONTRACT_TYPE" returntype="void" access="public">
	<cfargument name="aappNum" type="numeric" required="yes">
	<cfargument name="serviceType" type="string" required="yes">
	<cfargument name="predAAPPnum" type="string" required="no">

		<cfset inputType = 'I'>

		<cfif isDefined("arguments.predAAPPNum") and arguments.predAAPPNum neq "">
			<!--- if predecessor num is passed in, check to see if this service type exists for that pred --->
			<cfquery name="qryCheckPredServiceType" >
			select contract_type_code
			from	aapp_contract_type
			where	aapp_num = '#arguments.predAAPPNum#' and
					contract_type_code = '#arguments.serviceType#'
			</cfquery>

			<cfif qryCheckPredServiceType.recordCount>
				<cfset inputType = 'P'>
			</cfif>
		</cfif>

		<cfquery name="qryInsertServiceType" >
		insert into aapp_contract_type (aapp_num,
			contract_type_code,
			input_future_type_code,
			update_user_id,
			update_function,
			update_time)
		values (
			#arguments.AAPPNum#,
			'#arguments.serviceType#',
			'#inputType#',
			'#session.userID#',
			'#request.auditVarInsert#',
			sysdate)
		</cfquery>


	</cffunction>

	<cffunction name="deleteServiceType" hint="delete row from AAPP_CONTRACT_TYPE" returntype="void" access="public">
	<cfargument name="aappNum" type="numeric" required="yes">
	<cfargument name="serviceType" type="string" required="yes">

		<cfquery name="qryCheckPredServiceType" >
		delete
		from	aapp_contract_type
		where	aapp_num = '#arguments.aappNum#' and
				contract_type_code = '#arguments.serviceType#'
		</cfquery>

	</cffunction>



	<cffunction name="saveAAPPsummary_CCC" hint="Save data for CCC" returntype="struct" access="public">
    	
                <cfargument name="formData" type="struct" required="yes">
                <!--- set up return fields --->
                <cfset success = "true">
                <cfset errorMessages = "">
                <cfset errorFields = "">
        
        <cftransaction>        
        
                <cfif arguments.formData.hidMode is "new">
        
                    <!--- check to make sure user entered valid AAPP number --->
                    <!--- (last 3 digits can't match last 3 digits of any existing aapp --->
                    <cfquery name="qryCheckAAPPMask" >
                    select	count(aapp_num) as numRecs
                    from	aapp
                    where	mod(aapp_num,1000) = #evaluate(arguments.formData.txtAAPP mod 1000)#
                    </cfquery>
                    <cfif qryCheckAAPPMask.numRecs gt 0>
                        <cfset success = "false">
                        <cfset errorMessages = listAppend(errorMessages,"This AAPP series has already been used, please choose another.","~")>
                        <cfset errorFields = listAppend(errorFields,"txtAAPP")>
                    </cfif>
        
                    <cfif success>
                        <cfquery name="qryInsertCCC" >
                        insert	into aapp (
                                    aapp_num,
                                    center_id,
                                    funding_office_num,
                                    state_abbr,
                                    contract_num,
                                    contract_status_id,
                                    agreement_type_code,
                                    org_type_code,
                                    org_subtype_code, UPDATE_USER_ID, UPDATE_FUNCTION, UPDATE_TIME
                                    )
                                values (
                                    #arguments.formData.txtAAPP#,
                                    #listgetat(arguments.formData.cboCenter,1,"__")#,
                                    #arguments.formData.cboFundingOffice#,
                                    '#left(arguments.formData.cboState, 2)#',
                                    '#arguments.formData.txtContractNum#',
                                    #arguments.formData.radStatus#,
                                    '#arguments.formData.hidAgreementTypeCode#',
                                    '#arguments.formData.hidOrgTypeCode#',
                                    '#arguments.formData.hidOrgSubTypeCode#', '#session.userID#', '#request.auditVarInsert#', sysdate
                                    )
                        </cfquery>
        
                        <cfinvoke component="#application.paths.components#aapp_workload" method="createBlankWorkloadData_CCC"
                        aapp="#arguments.formData.txtAAPP#">
                        
                        <cfset application.outility.insertSystemAudit (
								aapp="#arguments.formData.txtAAPP#",
								statusID="#arguments.formData.radStatus#",
								sectionID="100",
								description="AAPP created",
								userID="#session.userID#")>
                    </cfif>
            <cfelse>
        
                <!--- if user is making AAPP inactive, check to see if that can be done --->
                <cfif arguments.formData.radStatus eq 0>
                    <cfset lstInactiveMessages = this.testForInactive(arguments.formData.txtAAPP)>
                    <cfif listLen(lstInactiveMessages,"~") gt 0>
                        <cfset success = "false">
                        <cfloop list="#lstInactiveMessages#" index="msg" delimiters="~">
                            <cfset errorMessages = listAppend(errorMessages,msg,"~")>
                        </cfloop>
                        <cfset errorFields = listAppend(errorFields,"radStatus")>
                    </cfif>
                </cfif>
        
                <cfif success>
                    <cfquery name="qryUpdateCCC" >
                    update AAPP
                    set center_id = #listgetat(arguments.formData.cboCenter,1,"__")#,
                            funding_office_num = #arguments.formData.cboFundingOffice#,
                            state_abbr = '#left(arguments.formData.cboState,2)#',
                            contract_num = '#arguments.formData.txtContractNum#',
                            contract_status_id = #arguments.formData.radStatus#,
                            agreement_type_code = '#arguments.formData.hidAgreementTypeCode#',
                            org_type_code = '#arguments.formData.hidOrgTypeCode#',
                            org_subtype_code = '#arguments.formData.hidOrgSubTypeCode#',
                            UPDATE_USER_ID = '#session.userID#',
                            UPDATE_FUNCTION = '#request.auditVarUpdate#',
                            UPDATE_TIME = sysdate
                    where aapp_num = #arguments.formData.txtAAPP#
                    </cfquery>
                    
                    <cfset application.outility.insertSystemAudit (
							  aapp="#arguments.formData.txtAAPP#",
							  statusID="#arguments.formData.radStatus#",
							  sectionID="100",
							  description="AAPP Summary information updated",
							  userID="#session.userID#")>
                    
                </cfif>
            </cfif>
            
            <cfstoredproc procedure="JFAS_SNAPSHOT_PKG.sp_updAAPP_CONTRACT_SNAPSHOT" returncode="no">
                <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="argAAPP_NUM" value="#arguments.formData.txtAAPP#" null="no">
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUser_ID" value="#session.userid#" null="no">
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUpdate_Notes" value="Modified from AAPP Setup" null="no">
            </cfstoredproc>
            
            
        </cftransaction>
                 <!--- set up structure to return --->
                <cfset stcResults = StructNew()>
                <cfset stcResults.success = success>
                <cfif success>
                    <cfset stcResults.aappNum = arguments.formData.txtAAPP>
                </cfif>
                <cfset stcResults.errorMessages = errorMessages>
                <cfset stcResults.errorFields = errorFields>
        
        
                <cfreturn stcResults>

	</cffunction>

	<cffunction name="getAAPPContractor" hint="Get data for AAPP Contractor Tab" returntype="query" access="public">
		<cfargument name="aapp" type="numeric" required="yes">

		<cfquery name="qryGetAAPPContractor" >
		select	contract_num as contractNum,
				contractor_id as contractorID,
				org_type_code as orgTypeCode,
				org_subtype_code as orgSubTypeCode,
				'' as smbTypeCode,
				'' as docNumList
		from	aapp
		where	aapp_num =  #arguments.aapp#
		</cfquery>

		<!--- get list of Small Business Codes --->
		<cfquery name="qryGetAAPPSmbTypeCodes" >
		select	distinct smb_type_code
		from	aapp_smb_type
		where	aapp_num = #arguments.aapp#
		</cfquery>

		<!--- get list of Documetn Numbers for this AAPP --->
		<cfquery name="qryGetDocNums" >
		select	distinct doc_num
		from	footprint_ncfms
		where	aapp_num = #arguments.aapp#
		</cfquery>

		<!--- populate cell in query --->
		<cfset temp = querySetCell(qryGetAAPPContractor, "smbTypeCode", valuelist(qryGetAAPPSmbTypeCodes.smb_type_code))>
		<cfset temp = querySetCell(qryGetAAPPContractor, "docNumList", valuelist(qryGetDocNums.doc_num))>
		<cfreturn qryGetAAPPContractor>

	</cffunction>


	<cffunction name="saveAAPPContractor" access="public" output="true" hint="Saves data from contractor information form entry">
		<cfargument name="formData" type="struct" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cfif success>

			<cftransaction>

					<!--- did user specify a new contractor? need to check if it exists, and if not - add it before saving the form data --->
                    <cfif arguments.formData.cboContractor eq "~new">
        
                        <!--- new contractor - need to check if this name exists in contractor table already --->
                        <cfinvoke component="#application.paths.components#contractor" method="getContractors"
                                contractorName="#arguments.formData.hidNewContractorName#" status="active" returnvariable="rstExistingContractor">
        
                        <cfif rstExistingContractor.recordCount neq 0> <!--- contractor already exists, use that ID --->
                            <cfset contractorID = rstExistingContractor.contractorID>
                        <cfelse> <!--- insert new contractor, get new ID back --->
                            <cfinvoke component="#application.paths.components#contractor" method="insertContractor"
                                        ContractorName="#arguments.formData.hidNewContractorName#"
                                        status="1"
                                        returnvariable="contractorID">
                        </cfif>
                    <cfelse> <!--- not adding new contractor, use ID from form submission --->
                        <cfset contractorID = arguments.formData.cboContractor>
                    </cfif>
        
                    <cfquery name="qryUpdateContractorInfo" >
                    update	aapp
                    set		contract_num = <cfif arguments.formData.txtContractNum neq "">'#arguments.formData.txtContractNum#'<cfelse>null</cfif>,
                            contractor_id = <cfif contractorID neq "">#contractorID#<cfelse>null</cfif>,
                            org_type_code = <cfif arguments.formData.cboOrgType neq "">'#listGetAt(arguments.formData.cboOrgType,1,"-")#'<cfelse>null</cfif>,
                            org_subtype_code = <cfif listlen(arguments.formData.cboOrgType,"-") eq 2>'#listGetAt(arguments.formData.cboOrgType,2,"-")#'<cfelse>null</cfif>,
                            update_user_id = '#session.userID#',
                            update_function = '#request.auditVarUpdate#',
                            update_time = sysdate
                    where	aapp_num = #arguments.formData.hidAAPP#
                    </cfquery>
        
                    <cfquery name="delSmallBusInfo" >
                    delete
                    from	aapp_smb_type
                    where	aapp_num = #arguments.formData.hidAAPP#
                    </cfquery>
        
                    <cfif isDefined("arguments.formData.ckbSmallBusType") and (arguments.formData.ckbSmallBusType neq "")>
                        <cfloop from="1" to="#ListLen(arguments.formData.ckbSmallBusType)#" index="counter">
                            <cfquery name="insSmallBusInfo" >
                            insert into aapp_smb_type
                            (aapp_num,
                                smb_type_code,
                                UPDATE_USER_ID,
                                UPDATE_FUNCTION,
                                UPDATE_TIME)
                            values
                            (#arguments.formData.hidAAPP#,
                                '#listgetat(arguments.formData.ckbSmallBusType,counter,",")#',
                                '#session.userID#',
                                '#request.auditVarInsert#',
                                sysdate)
                            </cfquery>
                        </cfloop>
                    </cfif>
        
                    <cfif isDefined("arguments.formData.ckbDelDocNum") and (arguments.formData.ckbDelDocNum neq "")>
                        <cfloop list="#arguments.formData.ckbDelDocNum#" index="ListItem">
                            <cfinvoke component="#application.paths.components#footprint" method="severAAPPLink"
                                docNum="#ListItem#"
                                aappNum="#arguments.formData.hidAAPP#" />
                        </cfloop>
                    </cfif>
        
                    <!--- Log Audit table: --->
                    <cfset application.outility.insertSystemAudit (
                              sectionID="130",
                              description="Contractor Information Updated",
                              userID="#session.userID#")>
                    <!--- Update Snapshot Contractor's information --->
                    <cfstoredproc procedure="JFAS_SNAPSHOT_PKG.sp_updAAPP_CONTRACT_SNAPSHOT" returncode="no">
                        <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="argAAPP_NUM" value="#arguments.formData.hidAAPP#" null="no">
                        <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUser_ID" value="#session.userid#" null="no">
                        <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="argUpdate_Notes" value="Updated from Contractor Info" null="no">
                    </cfstoredproc>

			</cftransaction>

		</cfif>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

		<cfreturn stcResults>

	</cffunction>


	<cffunction name="createContractYearData" access="public" hint="Creates new records in AAPP_YEAREND based on start date and contract length">
		<cfargument name="aapp" type="string" required="yes" />
		<cfargument name="newContractLength" type="numeric" required="yes" />
		<cfargument name="dateStart" type="date" required="yes" />

		<cfquery name="qryDeleteCY" >
		delete
		from	aapp_yearend
		where	aapp_num = #aapp#
		</cfquery>

		<!--- insert new contract year end dates --->
		<cfloop index="i" from="1" to="#newContractLength#">
			<!--- end date will be 1 year from current day - 1 day (but need to account for leap year) --->
			<cfif month(arguments.dateStart) eq 3 and day(arguments.dateStart) eq 1>
				<cfif isDate("2/29/" & year(arguments.dateStart) + i)>
					<cfset nextEndDate = "2/29/" & year(arguments.dateStart) + i />
				<cfelse>
					<cfset nextEndDate = "2/28/" & year(arguments.dateStart) + i />
				</cfif>
			<cfelse>
				<cfset nextEndDate = dateAdd("d",-1, dateAdd("yyyy",i,arguments.dateStart)) />
			</cfif>
			<cfquery name="qryInsertCY" >
			insert into aapp_yearend (
				aapp_num,
				contract_year,
				date_end,
				update_user_id,
				update_function,
				update_time)
			values (
				#arguments.aapp#,
				#i#,
				to_date('#dateformat(nextEndDate, "mm/dd/yyyy")#','MM/DD/YYYY'),
				'#session.userID#',
				'#request.auditVarInsert#',
				sysdate)
			</cfquery>
		</cfloop>


	</cffunction>

	<cffunction name="adjustContractYearData" access="public" hint="Creates new records in AAPP_YEAREND based on start date and contract length">
		<cfargument name="aapp" type="string" required="yes" />
		<cfargument name="oldContractLength" type="numeric" required="yes" />
		<cfargument name="newContractLength" type="numeric" required="yes" />

		<cfif arguments.oldContractLength gt arguments.newContractLength> <!--- contract shortened --->

			<!--- delete extra year end data --->
			<cfquery name="qryDeleteExtraYears" >
			delete
			from	aapp_yearend
			where	aapp_num = #arguments.aapp# and
					contract_year > #arguments.newContractlength#
			</cfquery>

		<cfelseif arguments.oldContractLength lt arguments.newContractLength> <!--- contract extended --->

			<!--- get last contract year end date --->
			<cfquery name="qryGetContractEndDate" >
			select	max(date_end) as dateEnd
			from	aapp_yearend
			where	aapp_num = #arguments.aapp#
			</cfquery>

			<cfset tempDateStart = dateadd("d",1,qryGetContractEndDate.dateEnd) />

			<!--- insert new contract year end dates --->
			<cfloop index="i" from="1" to="#evaluate(arguments.newContractLength-arguments.oldContractLength)#">
				<!--- end date will be 1 year from current day - 1 day (but need to account for leap year) --->
				<cfif month(tempDateStart) eq 3 and day(tempDateStart) eq 1>
					<cfif isDate("2/29/" & year(tempDateStart) + i)>
						<cfset nextEndDate = "2/29/" & year(tempDateStart) + i />
					<cfelse>
						<cfset nextEndDate = "2/28/" & year(tempDateStart) + i />
					</cfif>
				<cfelse>
					<cfset nextEndDate = dateAdd("d",-1, dateAdd("yyyy",i,tempDateStart)) />
				</cfif>
				<cfquery name="qryInsertCY" >
				insert into aapp_yearend (
					aapp_num,
					contract_year,
					date_end,
					update_user_id,
					update_function,
					update_time)
				values (
					#arguments.aapp#,
					#evaluate(i+arguments.oldContractLength)#,
					to_date('#dateformat(nextEndDate, "mm/dd/yyyy")#','MM/DD/YYYY'),
					'#session.userID#',
					'#request.auditVarInsert#',
					sysdate)
				</cfquery>
			</cfloop>

		</cfif>

	</cffunction>



	<!--- next 4 functions... move to aapp_budget component? --->
	<cffunction name="createBlankBudget" access="public" hint="Creates blank rows in budget table based on service types and contract length">
		<cfargument name="aapp" type="string" required="yes">
		<cfargument name="newContractLength" type="numeric" required="yes">
		<cfargument name="serviceTypes" type="string" required="yes">


		<!--- get appropriate budget items --->
		<cfquery name="qryGetBudgetItems" >
		select	contract_budget_item_id, future_display, award_display
		from	i_contract_budget_item
		where	contract_type_code in (#listQualify(arguments.serviceTypes,"'",",","all")#)
		</cfquery>

		<cfloop index="i" from="1" to="#arguments.newContractLength#">
			<cfloop query="qryGetBudgetItems">

				<!--- future item ? --->
				<cfif future_display>
					<cfquery name="qryInsertFutureBudgetItem" >
					insert into aapp_contract_future (
						aapp_num,
						contract_year,
						contract_budget_item_id,
						amount,
						update_user_id,
						update_function,
						update_time)
					values (
						#arguments.aapp#,
						#i#,
						#contract_budget_item_id#,
						0,
						'#session.userID#',
						'#request.auditVarInsert#',
						sysdate)
					</cfquery>
				</cfif>

				<!--- award item ? --->
				<cfif award_display>
					<cfquery name="qryInsertAwardBudgetItem" >
					insert into aapp_contract_award (
						aapp_num,
						contract_year,
						contract_budget_item_id,
						amount,
						update_user_id,
						update_function,
						update_time)
					values (
						#arguments.aapp#,
						#i#,
						#contract_budget_item_id#,
						0,
						'#session.userID#',
						'#request.auditVarInsert#',
						sysdate)
					</cfquery>
				</cfif>

			</cfloop>
		</cfloop>

	</cffunction>

	<cffunction name="adjustBudgetLength" access="public" hint="Adjusts data in budget table based on change in contract length">
		<cfargument name="aapp" type="string" required="yes" />
		<cfargument name="newContractLength" type="numeric" required="yes" />

		<!--- get length of contract --->
		<cfquery name="qryGetBudgetLength" >
		select	max(contract_year) as maxYear
		from	aapp_contract_future
		where	aapp_num = #arguments.aapp#
		</cfquery>


		<cfif qryGetBudgetLength.maxYear lt arguments.newContractLength> <!--- increasing length of budget --->

			<!--- get list of budget items for the future contract --->
			<cfquery name="qryGetFutureBudgetItems" >
			select	distinct contract_budget_item_id
			from	aapp_contract_future
			where	aapp_num = #arguments.aapp#
			</cfquery>

			<!--- loop through extra contract years to add records --->
			<cfloop index="i" from="#evaluate(qryGetBudgetLength.maxYear+1)#" to="#newContractLength#">
				<cfloop query="qryGetFutureBudgetItems">
					<cfquery name="qryInsertFutureBudgetRow" >
					insert into aapp_contract_future (
						aapp_num,
						contract_year,
						contract_budget_item_id,
						amount,
						update_user_id,
						update_function,
						update_time)
					values (
						#arguments.aapp#,
						#i#,
						#contract_budget_item_id#,
						0,
						'#session.userID#',
						'#request.auditVarInsert#',
						sysdate)
					</cfquery>
				</cfloop>
			</cfloop>

			<!--- get list of budget items for the award contract --->
			<cfquery name="qryGetAwardBudgetItems" >
			select	distinct contract_budget_item_id
			from	aapp_contract_award
			where	aapp_num = #arguments.aapp#
			</cfquery>

			<!--- loop through extra contract years to add records --->
			<cfloop index="i" from="#evaluate(qryGetBudgetLength.maxYear+1)#" to="#newContractLength#">
				<cfloop query="qryGetAwardBudgetItems">
					<cfquery name="qryInsertAwardBudgetRow" >
					insert into aapp_contract_award (
						aapp_num,
						contract_year,
						contract_budget_item_id,
						amount,
						update_user_id,
						update_function,
						update_time)
					values (
						#arguments.aapp#,
						#i#,
						#contract_budget_item_id#,
						0,
						'#session.userID#',
						'#request.auditVarInsert#',
						sysdate)
					</cfquery>
				</cfloop>
			</cfloop>

		<cfelseif qryGetBudgetLength.maxYear gt arguments.newContractLength> <!--- shortening length of contract --->

			<!--- delete all extra years from the budget data --->
			<cfquery name="qryDeleteFutureBudgetRows" >
			delete
			from	aapp_contract_future
			where	aapp_num = #arguments.aapp# and
					contract_year > #arguments.newContractLength#
			</cfquery>

			<cfquery name="qryDeleteAwardBudgetRows" >
			delete
			from	aapp_contract_award
			where	aapp_num = #arguments.aapp# and
					contract_year > #arguments.newContractLength#
			</cfquery>

		</cfif>

	</cffunction>


	<cffunction name="adjustBudgetServiceTypes" access="public" hint="Adjusts data in budget table based on change in contract service types">
		<cfargument name="aapp" type="string" required="yes">
		<cfargument name="newServiceTypes" type="string" required="yes">

		<!--- get existing list of service types from budget data --->
		<cfquery name="qryGetBudgetServiceTypes" >
		select	distinct contract_type_code
		from	aapp_contract_future inner join i_contract_budget_item on
					(aapp_contract_future.contract_budget_item_id = i_contract_budget_item.contract_budget_item_id)
		where	aapp_num = #arguments.aapp#
		order	by contract_type_code
		</cfquery>

		<cfset oldServiceTypes = valueList(qryGetBudgetServiceTypes.contract_type_code)>

		<!--- if list of new Service Types is different --->
		<cfif oldServiceTypes neq arguments.newServiceTypes>

			<!--- delete future budget data for any service types that have been removed --->
			<cfquery name="qryDeleteBudgetItems" >
			delete
			from	aapp_contract_future
			where	aapp_num = #arguments.aapp#
					<cfif arguments.newServiceTypes neq "">
						and
						contract_budget_item_id not in (
							select contract_budget_item_id
							from i_contract_budget_item
							where contract_type_code in (#listQualify(arguments.newServiceTypes,"'",",","all")#)
							)
					</cfif>
			</cfquery>

			<!--- delete award budget data for any service types that have been removed --->
			<cfquery name="qryDeleteBudgetItems" >
			delete
			from	aapp_contract_award
			where	aapp_num = #arguments.aapp#
					<cfif arguments.newServiceTypes neq "">
						and
						contract_budget_item_id not in (
							select contract_budget_item_id
							from i_contract_budget_item
							where contract_type_code in (#listQualify(arguments.newServiceTypes,"'",",","all")#)
							)
					</cfif>
			</cfquery>

			<!--- get length of budget, based on data n budget table --->
			<cfquery name="qryGetBudgetLength" >
			select	max(contract_year) as maxYear
			from	aapp_yearend
			where	aapp_num = #arguments.aapp#
			</cfquery>

			<cfif qryGetBudgetLength.maxYear neq "">
				<cfset currentBudgetLength = qryGetBudgetLength.maxYear />
			<cfelse>
				<cfset currentBudgetLength = 0 />	<!--- no workload data --->
			</cfif>

			<!--- loop through new service types --->
			<cfloop index="serviceType" list="#arguments.newServiceTypes#">
				<!--- if new service type not found in existing budget data, then insert rows --->
				<cfif not listFindNoCase(oldServiceTypes,serviceType)>
					<!--- get associate budget items for this type --->
					<cfquery name="qryGetBudgetItems" >
					select	contract_budget_item_id, future_display, award_display
					from	i_contract_budget_item
					where	contract_type_code = '#serviceType#'
					</cfquery>

					<!--- insert blank rows in budget data for this type --->
					<cfloop index="i" from="1" to="#currentBudgetLength#">
						<cfloop query="qryGetBudgetItems">

							<!--- does item belong in future budget? --->
							<cfif future_display>
								<cfquery name="qryInsertBudgetRow" >
								insert into aapp_contract_future (
									aapp_num,
									contract_year,
									contract_budget_item_id,
									amount,
									update_user_id,
									update_function,
									update_time)
								values (
									#arguments.aapp#,
									#i#,
									#contract_budget_item_id#,
									0,
									'#session.userID#',
									'#request.auditVarInsert#',
									sysdate)
								</cfquery>
							</cfif>

							<!--- does item belong in award budget? --->
							<cfif award_display>
								<cfquery name="qryInsertBudgetRow" >
								insert into aapp_contract_award (
									aapp_num,
									contract_year,
									contract_budget_item_id,
									amount,
									update_user_id,
									update_function,
									update_time)
								values (
									#arguments.aapp#,
									#i#,
									#contract_budget_item_id#,
									0,
									'#session.userID#',
									'#request.auditVarInsert#',
									sysdate)
								</cfquery>
							</cfif>

						</cfloop> <!--- budget items --->
					</cfloop> <!--- contract years --->

				</cfif> <!--- if new service type added to list --->

			</cfloop> <!--- loop through new service types --->

		</cfif>

	</cffunction>

	<!--- no longer tracking these fields
	<cffunction name="adjustBudgetBIFees" access="public" hint="Adjusts data in budget table based on change in contract base/incentive fees">
		<cfargument name="aapp" type="string" required="yes">
		<cfargument name="newBIFees" type="string" required="yes">

		<!--- set any BI fees to 0 for any contract types not selected on summary page --->
		<cfquery name="qryBlankBudgetBIItems" >
		update	aapp_budget
		set		amount = 0,
				update_user_id = '#session.userID#',
				update_function = '#request.auditVarUpdate#',
				update_time = sysdate
		where	aapp_num = #arguments.aapp# and
				contract_budget_item_id in (
					select	contract_budget_item_id
					from	i_contract_budget_item
					where	budget_item_code in ('BF','IF')
							<cfif arguments.newBIFees neq "">
								and contract_type_code not in (#listQualify(arguments.newBIFees,"'",",","all")#)
							</cfif>
					)
		</cfquery>

		<!--- get contract length --->
		<cfset contractLen = this.getAAPPLength(arguments.aapp)>

		<!--- loop through Cent Ops, CTS to recalc totals now that fees have been zeroed --->
		<cfloop list="A,C2" index="sType">
			<cfloop index="i" from="1" to="#contractLen#">
				<cfquery name="qryRecalcBudgetTotal" >
				update	aapp_budget
				set		amount =
							(select sum(amount)
							 from	aapp_budget
							 where	aapp_num = #arguments.aapp# and
							 		contract_year = #i# and
									contract_budget_item_id in
										(
										select	contract_budget_item_id
										from	i_contract_budget_item
										where	budget_item_code in ('DR','IR','IF','BF') and
												contract_type_code = '#sType#'
										)
							),
						update_user_id = '#session.userID#',
						update_function = '#request.auditVarUpdate#',
						update_time = sysdate
				where	aapp_num = #arguments.aapp# and
						contract_year = #i# and
						contract_budget_item_id in
							(
							select	contract_budget_item_id
							from	i_contract_budget_item
							where	budget_item_code = 'TO'
									and contract_type_code = '#sType#'
							)
				</cfquery>
			</cfloop>
		</cfloop>

	</cffunction>
	--->

	<cffunction name="testForInactive" access="public" returntype="string" hint="Determines whether an AAPP can be made inactive or not">
		<cfargument name="aapp" type="numeric" required="yes">

		<cfset lstMessages = "">
		<!--- get aapp info --->
		<cfset rstAAPPInfo = this.getAAPPGeneral(#arguments.aapp#)>

		<!--- A. Did the contract end in the current (or later) PY? (only contracts and grants have end dates)--->
		<cfif listFindNoCase("DC,GR",rstAAPPInfo.agreementTypeCode)>

			<!--- get current PY start date --->
			<cfset currentPYStart = application.outility.getProgramYearDate (
			py="#request.py#", type="S"
			)>
			<cfif rstAAPPInfo.dateEnd neq "" and dateCompare(rstAAPPInfo.dateEnd, currentPYStart) gte 0>
				<cfset lstMessages = listAppend(lstMessages, "This AAPP can not be made inactive because its end date is later than the start of the current Program Year.","~")>
			</cfif>
			<!---<cfoutput>A. End Date: #dateformat(rstAAPPInfo.dateEnd, "mm/dd/yyyy")#--#dateformat(currentPYStart, "mm/dd/yyyy")#</cfoutput><br>--->
		</cfif>

		<!--- B. Does the AAPP have any FOPs from the current PY? (all AAPP types) --->
			<!--- get FOPs for current year --->
			<cfinvoke component="#application.paths.components#aapp_adjustment" method="getFOPList" aapp="#arguments.aapp#" returnvariable="rstFOPs">
			<cfquery name="qryCurrentPYFOPs" dbtype="query">
			select	count(*) as numRecs
			from	rstFOPs
			where	programYear = #request.py#
			</cfquery>
			<cfif qryCurrentPYFOPs.numRecs gt 0>
				<cfset lstMessages = listAppend(lstMessages, "This AAPP can not be made inactive because it has FOPs from the current Program Year.","~")>
			</cfif>
			<!---<cfoutput>B. #qryCurrentPYFOPs.numRecs#</cfoutput><br>--->

		<!--- C. Does this AAPP have any FOPs CRA (B1) funds that are active (last 2 PYs)?  (CCCs only) --->
		<cfif listFindNoCase("CC",rstAAPPInfo.agreementTypeCode)>
			<!--- get B1 FOPs from last 2 PYs --->
			<cfquery name="qryCurrent_CRA_FOPs" dbtype="query">
			select	sum(amount) as netFOP
			from	rstFOPs
			where	pyCRAbudget >= #request.py#-2
			</cfquery>
			<cfif (qryCurrent_CRA_FOPs.recordCount gt 0) and (qryCurrent_CRA_FOPs.netFOP neq 0)>
				<cfset lstMessages = listAppend(lstMessages, "This AAPP can not be made inactive because it has recent CRA (B1) FOPs.","~")>
			</cfif>
			<!---<cfoutput>C. #qryCurrent_CRA_FOPs.recordCount#--#qryCurrent_CRA_FOPs.netFOP#</cfoutput><br>--->
		</cfif>

		<!--- D. Any active footprints?--->
			<!--- check for footprints from this aapp, that haven't expired, with obligation > 0 --->
			<cfquery name="qryCheckActiveFootprints" >
			select	count(footprint_id) as numRecs
			from	footprint_ncfms
			where	aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#"> and
					oblig > 0 and
					approp_exp_py >= #request.py#
			</cfquery>
			<cfif (qryCheckActiveFootprints.numRecs gt 0)>
				<cfset lstMessages = listAppend(lstMessages, "This AAPP can not be made inactive because it still has active footprints.","~")>
			</cfif>
			<!---<cfoutput>D. #qryCheckActiveFootprints.numRecs#</cfoutput><br>--->


		<!--- E. Any footprints with money left (payments < obglig) from the last 5 years --->
			<!--- check for footprints from this aapp, that have expired within the past 5 years, --->
			<!--- where payments is not equal to obligations --->
			<cfquery name="qryCheckPaymentFootprints" >
			select	count(footprint_id) as numRecs
			from	footprint, RCC_Code
			where	footprint.RCC_Fund = RCC_Code.RCC_Fund and
					aapp_num = #arguments.aapp# and
					oblig > 0 and
					payment < oblig and
					last_oblig_py >= #request.py#-5
			</cfquery>
			<cfif (qryCheckActiveFootprints.numRecs gt 0)>
				<cfset lstMessages = listAppend(lstMessages, "This AAPP can not be made inactive because there are footprints with pending payments.","~")>
			</cfif>
			<!---<cfoutput>E. #qryCheckActiveFootprints.numRecs#</cfoutput><br>--->


		<!--- F. Contract ended after start of last PY, and FMS doesn't match FOP (needs close-out) --->
		<!--- (contracts and grants only) --->
		<cfif listFindNoCase("DC,GR",rstAAPPInfo.agreementTypeCode)>

			<!--- get start date of last PY --->
			<cfset previousPYStart = application.outility.getProgramYearDate (
			py="#evaluate(request.py-1)#", type="S"
			)>

			<!--- if contract ended after start of last PY, then continue with checks --->
			<cfif rstAAPPInfo.dateEnd neq "" and dateCompare(rstAAPPInfo.dateEnd, previousPYStart) gte 0>

				<!--- first, check to see if this AAPP has and FMS data (if not, then skip this step) --->
				<cfquery name="qryCheckforFMS" >
				select count(aapp_num) as numRecs
				from	center_2110_data
				where	aapp_num = #arguments.aapp#
				</cfquery>

				<cfif qryCheckforFMS.numRecs gt 0> <!--- proceed with edit check --->
					<!--- get cumul obs for B1 --->
					<cfinvoke component="#application.paths.components#aapp_yearend" method="get2110TotalCosts" aapp="#arguments.aapp#" costCatID="2"
						returnvariable="rstB1_2110">

					<!--- get total cumul obs from same 2110 report--->
					<cfquery name="qryGetTotalObs" >
					select	cum_conob_tot as cumTotalOb
					from	center_2110_data
					where	center_2110_id = #rstB1_2110.reportID#
					</cfquery>

					<!--- get cumul FOP amounts --->
					<cfinvoke component="#application.paths.components#aapp_adjustment" method="getCumulativeFOPAmounts" aapp="#arguments.aapp#"
						returnvariable="rstFOPCumAmounts">

					<cfquery name="qryTotalB1FOP" dbtype="query">
					select	sum(totalFOPAmount) as totalB1Sum
					from	rstFOPCumAmounts
					where	costCatID = 2
					</cfquery>

					<cfquery name="qryTotalFOP" dbtype="query">
					select	sum(totalFOPAmount) as totalSum
					from	rstFOPCumAmounts
					</cfquery>


					<!--- if total OBS doesn't match total FOPS, or total B1 doesn't match B1 FOPs, log error --->
					<cfif (rstB1_2110.cumContractOblig neq qryTotalB1FOP.totalB1Sum) or
						(qryGetTotalObs.cumTotalOb neq qryTotalFOP.totalSum)>
							<cfset lstMessages = listAppend(lstMessages, "This AAPP can not be made inactive because the FOPs do not match the contractor obligations (close-out required).","~")>
					</cfif>
					<!---<cfoutput>F. #rstB1_2110.cumContractOblig#--#qryTotalB1FOP.totalB1Sum#</cfoutput><br>--->
					<!---<cfoutput>F. #qryGetTotalObs.cumTotalOb#--#qryTotalFOP.totalSum#</cfoutput><br><br>--->

				</cfif> <!--- any FMS data existing? --->

			</cfif>

		</cfif>

		<cfreturn lstMessages>

	</cffunction>

	<cffunction name="reactivateAAPP" access="public" output="false" returntype="void" hint="reactivates inactive AAPP">
		<cfargument name="aapp" type="numeric" required="yes">

		<cfquery name="qryReactivateAAPP" >
		update	aapp
		set		contract_status_id = 1,
				update_user_id = '#session.userID#',
				update_function = '#request.auditVarUpdate#',
				update_time = sysdate
		where	aapp_num = #arguments.aapp#
		</cfquery>

			<cfset application.outility.insertSystemAudit (
			aapp="#arguments.aapp#",
			statusID="1",
			sectionID="100",
			description="AAPP reactivated",
			userID="#session.userID#")>

	</cffunction>

</cfcomponent>