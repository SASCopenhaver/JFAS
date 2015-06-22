<!---
page: voucher.cfc

description: component that contains functions to add, edit, view and

revisions:

--->

<cfcomponent displayname="Voucher Component" hint="Contains functions for viewing, editing and deleting vouchers">

<!-------------------------------------------------------------------------------------------------------------------------------
---------------------------Functions for Getting info from Voucher and Voucher Footprint Tables-----------------------------------
--------------------------------------------------------------------------------------------------------------------------------->

	<!--- Get the list of vouchers for a specific AAPP for the Voucher home page --->
	<cffunction name="getVoucherList" returntype="query" access="public">
		<cfargument name="aapp" type="numeric" required="yes">

		<cfquery name="qryGetVoucherList" datasource="#request.dsn#"><!---SELECT *
	    FROM( --->

			SELECT 	voucher_id as voucherID,
					voucher.voucher_num as voucherNum,
	   				voucher.version as version,
					voucher.voucher_status_id as voucherStatusID,
					voucher.voucher_type_code as voucherTypeCode,
					voucher.date_vendor_signed as dateVendoredSigned,
					voucher.date_recv_NO as dateRecvNO,
					voucher.date_recv_RO as dateRecvRO,
					case when (voucher.date_recv_NO is not null) and (voucher.date_recv_RO is not null) then
						 least(date_recv_NO, date_recv_RO)
					 when (voucher.date_recv_NO is not null) then
						 date_recv_NO
					 when (voucher.date_recv_RO is not null) then
						 date_recv_RO
					 else
						 null
					 End as dateRecv,
					voucher.date_to_acct as dateToAcct,
					voucher.date_payment_due as datePaymentDue,
					voucher.Amount_OPS as amountOPS,
					voucher.Amount_CRA as amountCRA,
					voucher.Amount_Total as amountTotal,
					case when (voucher.AMOUNT_CRA > 0) and (voucher.AMOUNT_OPS > 0) then
						 'Both'
					  when (voucher.Amount_CRA > 0) then
					  	 'CRA'
					  when (voucher.Amount_OPS > 0) then
					     'OPS'
					  else
					  	  Null
					END as OPSCRA,
					voucher.Amount_Cum_OPS as amountCumOPS,
					voucher.Amount_Cum_CRA as amountCumCRA,
					voucher.Amount_Cum_Total as amountCumTotal,
					voucher.Comments as Comments,
					lu_voucher_type.voucher_type_desc as voucherType
            		<!---RANK () OVER (PARTITION BY voucher_num ORDER BY version DESC) AS seqnumber--->
			FROM 	voucher, lu_voucher_type
			WHERE 	aapp_num = #arguments.aapp#
			AND 	lu_voucher_type.voucher_type_code = voucher.voucher_type_code
				<!---)
		WHERE seqnumber = 1--->
			ORDER BY dateRecv DESC, voucherNum DESC, version DESC nulls last
		</cfquery>

		<cfreturn qryGetVoucherList>
	</cffunction>

	<!--- Get Max Voucher Number for AAPP to make sure vouchers are in order --->
	<!--- Only for contract Vouchers, not POs --->
	<cffunction name="getMaxVoucherNum" returntype="string" access="public">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfquery name="qryGetMaxVoucherNum" datasource="#request.dsn#">
			Select	Max(Voucher_Num) as MaxVoucherNum
			From	Voucher
			Where	AAPP_Num = #arguments.AAPP#
			And		Voucher_Type_Code = 'C'
		</cfquery>
		<cfif qryGetMaxVoucherNum.recordcount gt 0>
			<cfreturn qryGetMaxVoucherNum.MaxVoucherNum>
		<cfelse>
			<cfreturn 0>
		</cfif>

	</cffunction>

	<!--- Get Cumulative amounts from previous vouchers to compare against voucher being entered --->
	<cffunction name="getCumAmounts" returntype="query" access="public">
		<cfargument name="AAPP" type="numeric" required="yes">
		<cfargument name="lastVoucherNum" type="string" required="yes">
			<cfquery name="qryGetCumAmounts" datasource="#request.dsn#">
				select	Max(Amount_Cum_OPS) as amtCumOPS,
						Max(Amount_Cum_CRA) as amtCumCRA,
						Max(Amount_Cum_Total) as amtCumTotal
				from	Voucher
				where	AAPP_Num = #arguments.aapp#
				and		Voucher_Num = '#arguments.lastVoucherNum#'
			</cfquery>

		<!---<cfquery name="qryGetFirstVoucher" datasource="#request.dsn#">
			select	Min(Voucher_ID) as VoucherID
			from	Voucher
			where	AAPP_Num = #arguments.AAPP#
		</cfquery>

		<cfif qryGetCumAmounts.recordcount gt 0>
			<cfquery name="getFirstCumAmounts" datasource="#request.dsn#">
				select  Amount_Cum_OPS as amtCumOPS,
						Amount_Cum_CRA as amtCumCRA
				from	Voucher
				where	Voucher_ID = qryGetCumAmounts
			</cfquery>

			<cfinvoke component="#application.paths.components#footprint" method="getOPSCRA" returnvariable="rstOPSCRA">
				<cfloop query="rstOPSCRA">
					<cfinvoke component="#application.paths.components#voucher" method="getPrevCharged" returnvariable="amtPrevCharged"
						VoucherNum="#qryGetVoucher.VoucherNum#"
						AAPP="#qryGetVoucher.AAPP#"
						OPSCRA="#rstOPSCRA.OPSCRA#"
						VoucherID="#qryGetFirstVoucher.VoucherID#">
					<cfset variables['amtCum' & rstOPSCRA.OPSCRA] = getFirstCumAmounts['amtCum' & rstOPSCRA.OPSCRA] + amtPrevCharged>
				</cfloop>
		<cfelse>
			<cfset amtCumOps = 0>
			<cfset amtCumCra = 0>
		</cfif>

		<cfset stcCumAmounts = StructNew()>
		<cfset stcCumAmounts.amtCumOPS = variables.amtCumOPS>
		<cfset stcCumAmounts.amtCumCRA = varialbes.amtCumCRA>--->

		<cfreturn qryGetCumAmounts>

	</cffunction>


	<!--- Get lastest version of Voucher Number for Addendum --->
	<cffunction name="getAddendumInfo" returntype="numeric" access="public">
		<cfargument name="AAPP" type="numeric" required="yes">
		<cfargument name="VoucherID" type="numeric" required="yes">

		<!--- Get this voucher's number --->
		<cfquery name="qryVoucherNum" datasource="#request.dsn#">
		Select	Voucher_Num as VoucherNum
		From	Voucher
		Where	Voucher_ID = #arguments.VoucherID#
		</cfquery>

		<!--- Get the number of the previous voucher --->
		<cfquery name="getPreviousVoucher" datasource="#request.dsn#">
		Select	MAX(Voucher_ID) as VoucherID
		From	Voucher
		Where 	Voucher_Num = '#qryVoucherNum.VoucherNum#'
		And		AAPP_Num = #arguments.AAPP#
		</cfquery>
	<cfreturn getPreviousVoucher.VoucherID>

	</cffunction>


	<cffunction name="getVoucherListDates" returntype="query" access="public" output="true" hint="Get Dates for breaking Voucher list display">
		<cfargument name="aapp" required="yes" type="numeric">
		<cfargument name="range" required="no" type="numeric" default="25">
		<!--- Source Query - list of dates of all Vouchers in **DESCENDING** order --->
		<cfquery name="qryVoucherListDates" datasource="#request.dsn#">
			Select
				case when (voucher.date_recv_NO is not null) and (voucher.date_recv_RO is not null) then
						 least(date_recv_NO, date_recv_RO)
					 when (voucher.date_recv_NO is not null) then
						 date_recv_NO
					 when (voucher.date_recv_RO is not null) then
						 date_recv_RO
					 else
						 null
					 End as dateRecv
			FROM 	voucher
			WHERE 	aapp_num = #arguments.aapp#
			ORDER BY dateRecv Desc
		</cfquery>
		<!--- Set first and last dates --->
		<cfset maxDate = qryVoucherListDates.dateRecv[1]>
		<cfset minDate = qryVoucherListDates.dateRecv[qryVoucherListDates.recordcount]>
		<!--- initialize counters for the the list of dates, and the query being returned --->
		<cfset VoucherListDatesRow = 1>
		<cfset DateBreaksRow = 1>
		<!--- create new query - which will be returned empty if there are no records --->
		<cfset qryDateBreaks = QueryNew("start, end")>

		<cfif qryVoucherListDates.recordcount gt 0>
			<cfset newRow = QueryAddRow(qryDateBreaks)><!--- Add first row to the query --->
			<cfset temp = QuerySetCell(qryDateBreaks, "start", maxDate)><!--- first start date is the latest date (1st date from the query) --->

			<cfloop condition="qryVoucherListDates.dateRecv[VoucherListDatesRow] neq minDate"><!--- if the date of the current row isn't also the last date in the query --->
				<cfset VoucherListDatesRow = Min(Evaluate(VoucherListDatesRow + arguments.range - 1), qryVoucherListDates.recordcount)><!--- Increment the row by the counter - 1 to get the next end date in this row --->
				<cfset temp = QuerySetCell(qryDateBreaks, "end", qryVoucherListDates.dateRecv[VoucherListDatesRow])><!--- Set the end date --->
					<cfloop condition="(qryVoucherListDates.dateRecv[VoucherListDatesRow] eq qryVoucherListDates.dateRecv[VoucherListDatesRow + 1]) and (VoucherListDatesRow + 1 lte qryVoucherListDates.recordcount)"><!--- if the next row (next start date) is the same date as the previous end date, go through the source query to find the first date that isn't the same for the start of the next result row --->
						<cfset VoucherListDatesRow = VoucherListDatesRow + 1>
					</cfloop>
					<cfif VoucherListDatesRow + 1 lte qryVoucherListDates.recordcount><!--- only add another row to the result query if incrementing the row of the result query wouldn't put the row number past the result query's recordcount  --->
						<cfset DateBreaksRow = DateBreaksRow + 1>
						<cfset newRow = QueryAddRow(qryDateBreaks)>
						<cfset VoucherListDatesRow = VoucherListDatesRow + 1>
						<cfset temp = QuerySetCell(qryDateBreaks, "start", qryVoucherListDates.dateRecv[VoucherListDatesRow])>
					</cfif>
			</cfloop>
			<cfset temp = QuerySetCell(qryDateBreaks, "end", minDate)><!--- Set the end date of the last row with the last row of the source query --->
		</cfif>

		<cfreturn qryDateBreaks>

	</cffunction>

	<!--- get the information for a specific voucher based on Voucher ID --->
	<cffunction name="getVoucher" returntype="query" access="public">
		<cfargument name="voucherID" type="numeric" required="no" default="0">
		<cfargument name="hidMode" type="string" required="no" default="">
		<cfquery name="qryGetVoucher" datasource="#request.dsn#">
		select		Voucher_NUM as voucherNum,
					AAPP_Num as AAPP,
					Version as version,
					Voucher_Status_ID as voucherStatus,
					voucher_type_code as voucherTypeCode,
					date_vendor_signed as dateVendorSigned,
					date_recv_NO as dateRecvNO,
					date_recv_RO as dateRecvRO,
					case when (voucher.date_recv_NO is not null) and (voucher.date_recv_RO is not null) then
						 least(date_recv_NO, date_recv_RO)
					 when (voucher.date_recv_NO is not null) then
						 date_recv_NO
					 when (voucher.date_recv_RO is not null) then
						 date_recv_RO
					 else
						 null
					 End as dateRecv,
					 case when (date_recv_NO is Null) then
						 'Regional'
					 when (date_recv_RO is Null) then
						 'National'
					 when (date_recv_NO > date_recv_RO) then
					     'Regional'
					 when (date_recv_RO > date_recv_NO) then
						  'National'
					 else
					 	 'National'
					 End as dateRecvName,
					date_to_acct as dateToAcct,
					date_payment_due as datePaymentDue,
					Amount_OPS as amountOPS,
					Amount_CRA as amountCRA,
					Amount_Total as amountTotal,
					Amount_Cum_OPS as amountCumOPS,
					Amount_Cum_CRA as amountCumCRA,
					Amount_Cum_Total as amountCumTotal,
					Comments as comments,
					<!--- added fields for cumulative amounts --->
					0 as OPS_Prev_txtAmountCharged,
					0 as CRA_Prev_txtAmountCharged,
					Enter_Date as EnterDate
		from 		voucher
		where		voucher_ID = #arguments.voucherID#
		</cfquery>
		<!--- Get OPS and CRA cum amounts from previous voucher --->
		<cfinvoke component="#application.paths.components#footprint" method="getOPSCRA" returnvariable="rstOPSCRA">
		<cfloop query="rstOPSCRA">
			<cfinvoke component="#application.paths.components#voucher" method="getPrevCharged" returnvariable="amtPrevCharged"
				VoucherNum="#qryGetVoucher.VoucherNum#"
				AAPP="#qryGetVoucher.AAPP#"
				hidMode="#arguments.hidMode#"
				OPSCRA="#rstOPSCRA.OPSCRA#"
				VoucherID="#arguments.VoucherID#">
			<!--- put amounts in fields of query above --->
			<cfset Temp = QuerySetCell(qryGetVoucher, rstOPSCRA.OPSCRA & "_Prev_txtAmountCharged", amtPrevCharged)>
		</cfloop>

		<cfreturn qryGetVoucher>

	</cffunction>
	<!--- Function to get the amounts previously charged on a voucher --->
	<cffunction name="getPrevCharged" returntype="numeric" hint="Gets amounts previously chared on vouchers to this AAPP">
		<cfargument name="VoucherNum" type="string" required="yes">
		<cfargument name="AAPP" type="numeric" required="yes">
		<cfargument name="hidMode" type="string" required="no" default="">
		<cfargument name="OPSCRA" type="string" required="yes">
		<cfargument name="VoucherID" type="numeric" required="no" default="0">

		<cfquery name="qryPrevCharged" datasource="#request.dsn#">
				select Sum(Voucher_Footprint.Amount) as AmountCharged
				From   Voucher_Footprint, Voucher, RCC_Code, Footprint
				Where  footprint.RCC_Fund = RCC_Code.RCC_Fund
				and		footprint.RCC_ORG = RCC_Code.RCC_ORG
				and		footprint.FY = RCC_Code.FY
				and		RCC_Code.OPS_CRA = '#arguments.OPSCRA#'
				and 	Voucher_footprint.Footprint_ID = Footprint.Footprint_ID
				and 	Voucher.Voucher_ID = Voucher_Footprint.Voucher_ID
				and		Voucher.Voucher_Num = '#arguments.VoucherNum#'
				and 	Voucher.AAPP_Num = #arguments.AAPP#
				<cfif arguments.hidMode neq "Add">
					and 	Voucher.Voucher_ID <> #arguments.VoucherID#
				</cfif>
			</cfquery>
		<cfif qryPrevCharged.AmountCharged is ''><!--- if the field is empty string, return zero --->
			<cfreturn 0>
		<cfelse>
			<cfreturn qryPrevCharged.AmountCharged>
		</cfif>
	</cffunction>


	<!--- Get Footprint Information for existing Voucher --->
	<cffunction name="getVoucherFootprint" returntype="query" access="public">
		<cfargument name="voucherID" type="numeric" required="yes">
		<cfargument name="ops_cra" type="string" required="no" default="">

		<cfquery name="qryGetVoucherFootprint" datasource="#request.dsn#">
		select 		Voucher_Footprint.voucher_ID as voucherID,
					Voucher_Footprint.Amount as AmountCharged,
					Voucher_Footprint.footprint_id as footprintID,
					footprint.FY as FY,
					footprint.RCC_Fund as RccFund,
					footprint.RCC_ORG as RccOrg,
					footprint.DT as DocType,
					footprint.Doc_Num as DocNum,
					footprint.OBJ_CLASS as obcl,
					Voucher_footprint.OBLIG as Oblig,
					Voucher_Footprint.Cost as Cost,
					(Voucher_footprint.oblig - Voucher_footprint.cost) as AmountAvail,
					RCC_Code.Proj1_Code as Proj1,
					RCC_Code.Proj1_Code as Proj1,case when (RCC_Code.Proj1_Code = '5JC11') or (RCC_Code.Proj1_Code = '5JC61') then
						 'REG'
					 else
						 'ADV'
					 End as REGADV,
					footprint.VENDOR as vendor,
					footprint.EIN as EIN,
					RCC_Code.OPS_CRA as OPSCRA,
					RCC_Code.Approp_PY as AppropPY,
					User_JFAS.First_Name as FirstName,
					User_JFAS.Last_Name as LastName,
					Voucher_Footprint.Update_Time as updateTime
		from		Voucher_Footprint, RCC_Code, footprint, User_JFAS
		where		Voucher_Footprint.voucher_ID = #arguments.voucherID#
		and			Voucher_Footprint.Footprint_ID = Footprint.Footprint_ID
			and		footprint.FY = RCC_Code.FY
			and		footprint.RCC_Fund = RCC_Code.RCC_Fund
			and		footprint.RCC_ORG = RCC_Code.RCC_ORG
			and		footprint.FY = RCC_Code.FY
			and		Voucher_Footprint.Update_User_ID = User_JFAS.User_ID(+)
		<cfif arguments.ops_cra neq "">
			and		RCC_Code.OPS_CRA = '#arguments.ops_cra#'
		</cfif>
		order by	OPSCRA, FY, AmountAvail
		</cfquery>

		<cfreturn qryGetVoucherFootprint>

	</cffunction>

<!---	<cffunction name="getPreviousVersions" returntype="query" access="public">
		<cfargument name="aapp" required="yes" type="numeric">
		<cfargument name="version" required="yes" type="numeric">
		<cfargument name="voucherNum" required="yes" type="numeric">


		<cfquery name="qryGetPreviousVersion" datasource="#request.dsn#">
		select 	voucher_ID as voucherID,
				version as version
		from	voucher
		where	aapp_num = #arguments.aapp#
		and		voucher_Num = #arguments.voucherNum#
		order by	version DESC
		</cfquery>

		<cfreturn qryGetPreviousVersion>

	</cffunction>--->

<!-------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------Save Voucher Function-------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveVoucher" access="public" returntype="struct" hint="Saves voucher data">
		<cfargument name="formData" type="struct" required="yes">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfargument name="voucherID" type="numeric" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<!--- Check to make sure it's not a duplicate voucher/version number --->
		<cfif arguments.voucherID eq 0>
			<cfquery name="checkVoucherNum" datasource="#request.dsn#">
				select	Voucher_ID
				from	Voucher
				where	Voucher_Num = '#ucase(arguments.formData.txtVoucherNum)#'
				<cfif arguments.formData.hidVersion neq ''>
					and		Version = '#ucase(arguments.formData.hidVersion)#'
				</cfif>
				and 	AAPP_Num = #arguments.aapp#
			</cfquery>
			<cfif checkVoucherNum.recordcount neq 0>
				<cfset success = "false">
				<cfset errorMessages = 'A Voucher with that number and version already exists.'>
				<cfset errorFields = 'txtVoucherNum,hidVersion'>
			</cfif>
		</cfif>

		<cfif success>

			<!--- If it's a new Voucher --->
			<cfif arguments.voucherID eq 0>
			<cftransaction>
				<!--- Insert the Voucher --->
				<cfinvoke component="#application.paths.components#voucher" method="insertVoucher" returnvariable="newVoucherID"
					aapp="#arguments.aapp#"
					voucherNum="#arguments.formData.txtVoucherNum#"
					version="#arguments.formData.hidVersion#"
					voucherType="#arguments.formData.hidVoucherType#"
					dateVendorSigned = "#DateFormat(arguments.formData.txtDateVendorSigned, 'mm/dd/yyyy')#"
					dateRecvNO = '#arguments.formData.txtDateRecvNO#'
					dateRecvRO = '#arguments.formData.txtDateRecvRO#'
					dateToAcct = "#DateFormat(arguments.formData.txtDateToAcct, 'mm/dd/yyyy')#"
					datePaymentDue = "#DateFormat(arguments.formData.txtDatePaymentDue, 'mm/dd/yyyy')#"
					AmountOPS = "#replace(arguments.formData.txtOPS, ',', '', 'all')#"
					AmountCRA = "#replace(arguments.formData.txtCRA, ',', '', 'all')#"
					AmountTotal = "#replace(arguments.formData.txtTotal, ',', '', 'all')#"
					AmountOpsCum = "#replace(arguments.formData.txtOPSCum, ',', '', 'all')#"
					AmountCRACum = "#replace(arguments.formData.txtCRACum, ',', '', 'all')#"
					AmountTotalCum = "#replace(arguments.formData.txtTotalCum, ',', '', 'all')#"
					Comments = '#arguments.formData.txtComments#'
				/>

				<!--- Then insert the Voucher Footprints --->
				<cfinvoke component="#application.paths.components#footprint" method="getOPSCRA" returnvariable="rstOPSCRA">

				<cfloop query="rstOPSCRA">
					<cfloop from="1" to="#arguments.formData[rstOPSCRA.OPSCRA & '_recordcount']#" index="i">
						<cfif arguments.formData[rstOPSCRA.OPSCRA & '_' & i & '_txtAmountCharged'] neq 0>
							<cfinvoke component="#application.paths.components#voucher" method="insertVoucherFootprint"
								voucherID="#newVoucherID#"
								aapp="#arguments.aapp#"
								footprintID="#arguments.formData[rstOPSCRA.OPSCRA & '_' & i & '_hidFootprintID']#"
								amount="#replace(arguments.formData[rstOPSCRA.OPSCRA & '_' & i & '_txtAmountCharged'], ',', '', 'all')#"
								cost="#replace(arguments.formData[rstOPSCRA.OPSCRA & '_' & i & '_hidCost'], ',', '', 'all')#"
								oblig="#replace(arguments.formData[rstOPSCRA.OPSCRA & '_' & i & '_hidOblig'], ',', '', 'all')#"
									>
						</cfif>
					</cfloop>
					<!--- System Audit --->
					<cfset application.outility.insertSystemAudit (
						aapp="#arguments.aapp#",
						statusID="1",
						sectionID="700",
						description="Footprints for Voucher #newVoucherID# inserted",
						userID="#session.userID#")>
				</cfloop>
			</cftransaction>
			<cfelse>
			<!--- User is editing an existing voucher --->
			<cftransaction>
				<!--- Update the Voucher Information --->
				<cfinvoke component="#application.paths.components#voucher" method="updateVoucher"
					aapp="#arguments.aapp#"
					voucherNum="#arguments.formData.txtVoucherNum#"
					version="#arguments.formData.hidVersion#"
					voucherID="#arguments.voucherID#"
					voucherType="#arguments.formData.hidVoucherType#"
					dateVendorSigned = "#DateFormat(arguments.formData.txtDateVendorSigned, 'mm/dd/yyyy')#"
					dateRecvNO = '#arguments.formData.txtDateRecvNO#'
					dateRecvRO = '#arguments.formData.txtDateRecvRO#'
					dateToAcct = "#DateFormat(arguments.formData.txtDateToAcct, 'mm/dd/yyyy')#"
					datePaymentDue = "#DateFormat(arguments.formData.txtDatePaymentDue, 'mm/dd/yyyy')#"
					AmountOPS = "#replace(arguments.formData.txtOPS, ',', '', 'all')#"
					AmountCRA = "#replace(arguments.formData.txtCRA, ',', '', 'all')#"
					AmountTotal = "#replace(arguments.formData.txtTotal, ',', '', 'all')#"
					AmountOpsCum = "#replace(arguments.formData.txtOPSCum, ',', '', 'all')#"
					AmountCRACum = "#replace(arguments.formData.txtCRACum, ',', '', 'all')#"
					AmountTotalCum = "#replace(arguments.formData.txtTotalCum, ',', '', 'all')#"
					Comments = '#arguments.formData.txtComments#'
				/>

				<!--- Delete previous Voucher Footprint Information --->
				<cfinvoke component="#application.paths.components#voucher" method="deleteVoucherFootprint"
					voucherID="#arguments.voucherID#"
					aapp="#arguments.aapp#"
				/>


				<!--- Insert new Voucher Footprint Information --->
				<cfinvoke component="#application.paths.components#footprint" method="getOPSCRA" returnvariable="rstOPSCRA">

				<cfloop query="rstOPSCRA">
					<cfif arguments.formData[rstOPSCRA.OPSCRA & '_recordcount'] gt 0>
						<cfloop from="1" to="#arguments.formData[rstOPSCRA.OPSCRA & '_recordcount']#" index="i">
							<cfif arguments.formData[rstOPSCRA.OPSCRA & '_' & i & '_txtAmountCharged'] neq 0>
								<cfinvoke component="#application.paths.components#voucher" method="insertVoucherFootprint"
									voucherID="#arguments.voucherID#"
									aapp="#arguments.aapp#"
									footprintID="#arguments.formData[rstOPSCRA.OPSCRA & '_' & i & '_hidFootprintID']#"
									amount="#replace(arguments.formData[rstOPSCRA.OPSCRA & '_' & i & '_txtAmountCharged'], ',', '', 'all')#"
									cost="#replace(arguments.formData[rstOPSCRA.OPSCRA & '_' & i & '_hidCost'], ',', '', 'all')#"
									oblig="#replace(arguments.formData[rstOPSCRA.OPSCRA & '_' & i & '_hidOblig'], ',', '', 'all')#"
										>
							</cfif>
						</cfloop>
						<!--- System Audit --->
						<cfset application.outility.insertSystemAudit (
							aapp="#arguments.aapp#",
							statusID="1",
							sectionID="700",
							description="Footprints for Voucher #arguments.voucherID# inserted",
							userID="#session.userID#")>
					</cfif>
				</cfloop>




			</cftransaction>
			</cfif>
		</cfif>

		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfif success>
			<cfif isDefined("newVoucherID")>
				<cfset stcResults.voucherID = newVoucherID>
			<cfelse>
				<cfset stcResults.voucherID = arguments.voucherID>
			</cfif>
		</cfif>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

	<cfreturn stcResults>

	</cffunction>
<!-------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------Functions for Changing Voucher Table----------------------------------------
--------------------------------------------------------------------------------------------------------------------------------->

	<!--- Insert a new Voucher --->
	<cffunction name="insertVoucher" access="public" returntype="numeric" hint="Insert data into Voucher table">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfargument name="VoucherNum" type="string" required="yes">
		<cfargument name="version" type="string" required="no" default="">
		<cfargument name="voucherType" type="string" required="yes">
		<cfargument name="dateVendorSigned" type="date" required="no" default="">
		<cfargument name="dateRecvNO" type="string" required="no" default=''>
		<cfargument name="dateRecvRO" type="string" required="no" default=''>
		<cfargument name="dateToAcct" type="date" required="no" default="">
		<cfargument name="datePaymentDue" type="date" required="no">
		<cfargument name="amountOPS" type="numeric" required="no">
		<cfargument name="amountCRA" type="numeric" required="no">
		<cfargument name="amountTotal" type="numeric" required="no">
		<cfargument name="amountOPSCum" type="numeric" required="no">
		<cfargument name="amountCRACum" type="numeric" required="no">
		<cfargument name="amountTotalCum" type="numeric" required="no">
		<cfargument name="comments" type="string" required="no">

			<cfquery name="qryVoucherID" datasource="#request.dsn#">
				select SEQ_Voucher.nextval AS nextVoucherID
				FROM	dual
			</cfquery>

			<cfquery name="qryInsertVoucher" datasource="#request.dsn#">
				insert into voucher
						(
						Voucher_ID,
						AAPP_Num,
						Voucher_Num,
						Version,
						Voucher_Status_ID,
						Voucher_Type_Code,
						Date_Vendor_Signed,
						Date_Recv_NO,
						Date_Recv_RO,
						Date_To_Acct,
						Date_Payment_Due,
						Amount_OPS,
						Amount_CRA,
						Amount_Total,
						Amount_Cum_OPS,
						Amount_Cum_CRA,
						Amount_Cum_Total,
						Comments,
						Update_User_ID,
						Update_Function,
						Update_Time,
						Enter_Date
						)
				values
						(
						#qryVoucherID.nextVoucherID#,
						#arguments.AAPP#,
						'#ucase(arguments.voucherNum)#',
						'#ucase(arguments.version)#',
						1,
						'#arguments.voucherType#',
						to_date('#arguments.dateVendorSigned#', 'MM/DD/YYYY'),
						<cfif arguments.dateRecvNO neq ''>
							to_date('#arguments.dateRecvNO#', 'MM/DD/YYYY'),
						<cfelse>
							'',
						</cfif>
						<cfif arguments.dateRecvRO neq ''>
							to_date('#arguments.dateRecvRO#', 'MM/DD/YYYY'),
						<cfelse>
							'',
						</cfif>
						to_date('#arguments.dateToAcct#', 'MM/DD/YYYY'),
						to_date('#arguments.datePaymentDue#', 'MM/DD/YYYY'),
						#replace(arguments.AmountOPS, ",", "", "all")#,
						#replace(arguments.AmountCRA, ",", "", "all")#,
						#replace(arguments.AmountTotal, ",", "", "all")#,
						<cfif arguments.voucherType neq "P">
							#replace(arguments.AmountOPSCum, ",", "", "all")#,
							#replace(arguments.AmountCRACum, ",", "", "all")#,
							#replace(arguments.AmountTotalCum, ",", "", "all")#,
						<cfelse>
							NULL,
							NULL,
							NULL,
						</cfif>
						'#arguments.comments#',
						'#session.userID#',
						'#request.auditVarInsert#',
						sysdate,
						sysdate
						)
			</cfquery>
			<!--- System Audit --->
			<cfset application.outility.insertSystemAudit (
					aapp="#arguments.aapp#",
					statusID="1",
					sectionID="700",
					description="Voucher #ucase(arguments.voucherNum)##ucase(arguments.version)# created",
					userID="#session.userID#")>


		<cfreturn qryVoucherID.nextVoucherID>

	</cffunction>


	<!--- Update an existing Voucher --->
	<cffunction name="updateVoucher" access="public" hint="Update Data in Voucher table">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfargument name="voucherNum" type="string" required="yes">
		<cfargument name="version" type="string" required="yes">
		<cfargument name="voucherID" type="numeric" required="yes">
		<cfargument name="voucherType" type="string" required="yes">
		<cfargument name="dateVendorSigned" type="date" required="no" default="">
		<cfargument name="dateRecvNO" type="string" required="no" default=''>
		<cfargument name="dateRecvRO" type="string" required="no" default=''>
		<cfargument name="dateToAcct" type="date" required="no" default="">
		<cfargument name="datePaymentDue" type="date" required="no" default="">
		<cfargument name="AmountOPS" type="numeric" required="no" default="0">
		<cfargument name="AmountCRA" type="numeric" required="no" default="0">
		<cfargument name="AmountTotal" type="numeric" required="no" default="0">
		<cfargument name="AmountOpsCum" type="numeric" required="no" default="0">
		<cfargument name="AmountCRACum" type="numeric" required="no" default="0">
		<cfargument name="AmountTotalCum" type="numeric" required="no" default="0">
		<cfargument name="Comments" type="string" required="no" default="">

			<cfquery name="qryUpdateVoucher" datasource="#request.dsn#">
			update 	voucher
			set 	Date_Vendor_Signed = to_date('#arguments.dateVendorSigned#', 'MM/DD/YYYY'),
					<cfif arguments.dateRecvNO neq ''>
						Date_Recv_NO = to_date('#arguments.dateRecvNO#', 'MM/DD/YYYY'),
					<cfelse>
						Date_Recv_NO = '',
					</cfif>
					<cfif arguments.dateRecvRO neq ''>
						Date_Recv_RO = to_date('#arguments.dateRecvRO#', 'MM/DD/YYYY'),
					<cfelse>
						Date_Recv_RO = '',
					</cfif>
					Date_To_Acct = to_date('#arguments.dateToAcct#', 'MM/DD/YYYY'),
					Date_Payment_Due = to_date('#arguments.datePaymentDue#', 'MM/DD/YYYY'),
					Amount_OPS = #replace(arguments.AmountOPS, ",", "", "all")#,
					Amount_CRA = #replace(arguments.AmountCRA, ",", "", "all")#,
					Amount_Total = #replace(arguments.AmountTotal, ",", "", "all")#,
					<cfif arguments.voucherType neq "P">
						Amount_Cum_Ops = #replace(arguments.AmountOpsCum, ",", "", "all")#,
						Amount_Cum_CRA = #replace(arguments.AmountCRACum, ",", "", "all")#,
						Amount_Cum_Total = #replace(arguments.AmountTotalCum, ",", "", "all")#,
					<cfelse>
						Amount_Cum_Ops = NULL,
						Amount_Cum_CRA = NULL,
						Amount_Cum_Total = NULL,
					</cfif>
					Comments = '#arguments.Comments#',
					Update_User_ID = '#session.userID#',
					Update_Function = '#request.auditVarUpdate#',
					Update_Time = sysdate
			where 	voucher_ID = #arguments.voucherID#
			</cfquery>

			<!--- System Audit --->
			<cfset application.outility.insertSystemAudit (
					aapp="#arguments.aapp#",
					statusID="1",
					sectionID="700",
					description="Voucher #arguments.VoucherNum##arguments.version# updated",
					userID="#session.userID#")>

			<cfreturn>

	</cffunction>

<!-------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------Functions for Voucher_Footprint Table--------------------------------------
-------------------------------------------------------------------------------------------------------------------------------->


	<!--- Insert new footprints associated with a voucher --->
	<cffunction name="insertVoucherFootprint" access="public" returntype="void">
		<cfargument name="aapp" required="yes" type="numeric">
		<cfargument name="VoucherID" required="yes" type="numeric">
		<cfargument name="FootprintID" required="yes" type="numeric">
		<cfargument name="Amount" required="yes" type="numeric">

		<cfinvoke component="#application.paths.components#footprint" method="getOPSCRA" returnvariable="rstOPSCRA">

				<cfquery name="qryInsertVoucherFootprint" datasource="#request.dsn#">
							insert into Voucher_Footprint
								(
								Voucher_ID,
								Footprint_ID,
								Amount,
								Update_User_ID,
								Update_Function,
								Update_Time,
								Cost,
								Oblig
								)
							values
								(
								#arguments.voucherID#,
								#arguments.FootprintID#,
								#arguments.Amount#,
								'#session.userID#',
								'#request.auditVarInsert#',
								sysdate,
								#arguments.Cost#,
								#arguments.Oblig#
								)
						</cfquery>



	</cffunction>

	<!--- Delete the footprints associated with a voucher  --->
	<cffunction name="deleteVoucherFootprint" access="public" returntype="void">
		<cfargument name="voucherID" type="numeric" required="yes">
		<cfargument name="aapp" type="numeric" required="yes">

		<cfquery name="qryDelVoucherFootprint" datasource="#request.dsn#">
			delete
			from		Voucher_Footprint
			where		voucher_ID = #arguments.voucherID#
		</cfquery>

		<!--- System Audit --->
		<cfset application.outility.insertSystemAudit (
			aapp="#arguments.aapp#",
			statusID="1",
			sectionID="700",
			description="Footprints for Voucher #arguments.voucherID# deleted",
			userID="#session.userID#")>

	<cfreturn>

	</cffunction>


	<!--- Edit an existing voucher --->
	<cffunction name="editVoucher" access="public" returntype="struct">
	<cfargument name="formData" type="struct" required="yes">
	<cfargument name="voucherID" type="numeric" required="yes">

	<cfset success = "true">
	<cfset errorMessages = "">
	<cfset errorFields = "">

	<!--- update information in voucher table --->
	<cfinvoke component="#application.paths.components#voucher" method="updateVoucher" formData="#arguments.formData#"
	voucherID="#arguments.voucherID#" returnvariable="stcUpdateVoucher">
	<cfif stcUpdateVoucher.success>
		<!--- delete footprints previously associated with voucher --->
		<cfinvoke component="#application.paths.components#voucher" method="deleteVoucherFootprint" voucherID="#arguments.voucherID#"
		returnvariable="stcDelVoucher">
			<cfif stcDelVoucher.success>
				<!--- insert new footprints associated with voucher --->
				<cfinvoke component="#application.paths.components#voucher" method="insertVoucherFootprint"
				formData="#arguments.formData#" voucherID="#arguments.VoucherID#" returnvariable="stcInsertVoucherFootprints">
			<cfelse>
				<cfset success = false>
			</cfif>
	<cfelse>
		<cfset success = false>
	</cfif>

	<cfset stcResults = StructNew()>
	<cfset stcResults.success = success>
	<cfset stcResults.errorMessages = errorMessages>
	<cfset stcResults.errorFields = errorFields>

	<cfreturn stcResults>

	</cffunction>

</cfcomponent>