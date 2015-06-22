<!---
page: lookup.cfc

description: component that handles all calls for reference data drop-downs, etc.

revisions:
2007-02-01	mstein	Defect 123 - Adjusted getCostCategories so that on CCC FOP screen, "A" (primary) is not a valid cost cat
2007-03-07	mstein	Added function getUserRoles
2007-07-11  abai    Added function worksheetPy
2007-07-23	mstein	Added "office type" to getFundingOffices results set
2007-08-24	mstein	Added getImportTypes
2007-09-10  abai    Added function getFootprintFY
2007-12-04	mstein	Added getVoucherTypes function
					Changed getUserRoles to getJFASUserRoles (CF 8 compatibility)
2011-06-21	mstein	Added getFundCats
--->
<cfcomponent displayname="Lookup Component" hint="Contains queries for retrieving lookup/reference data">

<cffunction name="getFundingOffices" access="public" returntype="query" hint="Returns recordset containing list of funding offices">
	<cfargument name="fundingOfficeNum" type="numeric" required="false" default="0">
	<cfargument name="fundingOfficeType" type="string" required="false" default="">
	<cfargument name="fundingOfficeTypeNot" type="string" required="false" default="">
	<cfargument name="managingUnit" type="string" required="false" default="">
	<cfargument name="includeFed" type="string" required="false" default="">

<!--- 		'(' || funding_office_abbr || ')' || substr('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;', 1, 6 * (5 - length(funding_office_abbr)))  ||funding_office_desc   AS fundingOfficeAbbrDesc,
--->
	<cfquery name="qryGetFundingOffices" >
	select  funding_office_num as fundingOfficeNum,
	substr(funding_office_abbr, 1, 3) as fundingOfficeAbbr,
	funding_office_desc as fundingOfficeDesc,

	SUBSTR(funding_office_abbr, 1, 3) || '&nbsp;-&nbsp;' || funding_office_desc AS fundingOfficeAbbrDesc,

	region_num as regionNum,
	office_type as officeType,
	sort_order as sortOrder,
	small_purch_aapp_num as smallPurchAAPP,
	late_fee_aapp_num as lateFeeAAPP,
	managing_unit as managingUnit
	from    lu_funding_office
	where	1=1
	<cfif arguments.fundingOfficeNum neq 0>  /* want a specific office */
		<cfif includeFed EQ ''>
			and funding_office_num = #arguments.fundingOfficeNum#
		<cfelse>
			and (funding_office_num = #arguments.fundingOfficeNum# OR office_type = 'FED')
		</cfif>
	</cfif>
	<cfif arguments.fundingOfficeType neq ""> /* want a specific type of office */
		and office_type = '#arguments.fundingOfficeType#'
	</cfif>
	<cfif arguments.fundingOfficeTypeNot neq ""> /* want everything BUT a specific type */
		and office_type <> '#arguments.fundingOfficeTypeNot#'
	</cfif>
	<cfif arguments.managingUnit neq "">
		and managing_unit = '#arguments.managingUnit#' /* want a specific managing unit */
	</cfif>
	order 	by sort_order
	</cfquery>

	<cfreturn qryGetFundingOffices>
</cffunction>

<cffunction name="getRegions" access="public" returntype="query" hint="Returns recordset containing region list">
	<cfargument name="regionNum" type="numeric" required="false" default="0">

	<cfquery name="qryGetRegions" >
	select	region_num as regionNum,
			region_desc as regionDesc
	from	lu_region
	<cfif arguments.regionNum neq 0>
		where region_num = #arguments.regionNum#
	</cfif>
	order 	by region_num
	</cfquery>

	<cfreturn qryGetRegions>
</cffunction>

<cffunction name="getStates" access="public" returntype="query" hint="Returns recordset containing state list">
	<cfargument name="state" type="string" required="false" default="">
	<cfargument name="sortBy" type="string" required="false" default="name">

	<cfquery name="qryGetStates" >
	select	state_abbr as state,
			state_name as stateName,
			region_num as regionNum
	from	lu_state
	<cfif arguments.state neq "">
		where state_abbr = '#arguments.state#'
	</cfif>
	<cfswitch expression="#arguments.sortBy#">
		<cfcase value="abbr">
			order by state_abbr
		</cfcase>
		<cfdefaultcase>
			order by state_name
		</cfdefaultcase>
	</cfswitch>

	</cfquery>

	<cfreturn qryGetStates>
</cffunction>

<cffunction name="getAgreementTypes" access="public" returntype="query" hint="Returns recordset containing region list">
	<cfargument name="agreementTypeCode" type="string" required="false" default="">

	<cfquery name="qryGetAgreementTypes" >
	select	agreement_type_code as agreementTypeCode,
			agreement_type_desc as agreementTypeDesc,
			agreement_type_abbr as agreementTypeAbbr,

			SUBSTR(agreement_type_abbr, 1, 3) || '&nbsp;-&nbsp;' || agreement_type_desc AS agreementTypeAbbrDesc,

			sort_order as sortOrder
	from	lu_agreement_type
	<cfif arguments.agreementTypeCode neq "">
		where agreement_type_code = '#arguments.agreementTypeCode#'
	</cfif>
	order 	by sort_order
	</cfquery>

	<cfreturn qryGetAgreementTypes>
</cffunction>

<cffunction name="getServiceTypes" access="public" returntype="query" hint="Returns recordset contract/service types">
	<cfargument name="contractTypeCode" type="string" required="false" default="">
	<cfargument name="displayType" type="string" required="false" default="">

	<cfquery name="qryGetServiceTypes" >
	select	contract_type_code as contractTypeCode,
			contract_type_desc_short as contractTypeShortDesc,
			contract_type_desc_long as contractTypeLongDesc,

			CASE TRIM(contract_type_desc_short)
				WHEN 'CTR OPS'
					THEN contract_type_desc_short || '&nbsp;-&nbsp;' || contract_type_desc_long
				ELSE
					SUBSTR(contract_type_desc_short, 1, 3) || '&nbsp;-&nbsp;' || contract_type_desc_long
			END AS contractTypeAbbrDesc,

			sort_order as sortOrder
	from	lu_contract_type
	where 1=1
	<cfif arguments.contractTypeCode neq "">
		and contract_type_code = '#arguments.contractTypeCode#'
	</cfif>
	<cfswitch expression="#arguments.displayType#">
		<cfcase value="summary">
			and summary_type_display = 1
		</cfcase>
		<cfcase value="BIfees">
			and summary_bi_display = 1
		</cfcase>
		<cfcase value="budget">
			and budget_display = 1
		</cfcase>
		<cfcase value="ecp">
			and ecp_display = 1
		</cfcase>
	</cfswitch>
	order 	by sort_order
	</cfquery>

	<cfreturn qryGetServiceTypes>
</cffunction>

<cffunction name="getCompetitionTypes" access="public" returntype="query" hint="Returns recordset containing competition types">
	<cfargument name="competitionCode" type="string" required="false" default="">

	<cfquery name="qryGetCompetitionTypes" >
	select	competition_code as competitionCode,
			competition_desc as competitionDesc,
			sort_order as sortOrder
	from	lu_competition
	<cfif arguments.competitionCode neq "">
		and competition_code = '#arguments.competitionCode#'
	</cfif>
	order 	by sort_order
	</cfquery>

	<cfreturn qryGetCompetitionTypes>
</cffunction>


<cffunction name="getSetAsideTypes" access="public" returntype="query" hint="Returns recordset containing list of set-aside types">
	<cfargument name="setasideID" type="numeric" required="false" default="0">

	<cfquery name="qryGetSetAsideTypes" >
	select	smb_setaside_id as setasideID,
			smb_setaside_desc as setasideDesc,
			sort_order as sortOrder
	from	lu_smb_setaside
	<cfif arguments.setasideID neq "0">
		where smb_setaside_id = #arguments.setasideID#
	</cfif>
	order 	by sort_order
	</cfquery>

	<cfreturn qryGetSetAsideTypes>
</cffunction>

<cffunction name="getWorkloadTypes" access="public" returntype="query" hint="Returns recordset containing list of workload types">
	<cfargument name="workloadTypeCode" type="numeric" required="false" default="0">

	<cfquery name="qryGetWorkloadTypes" >
	select	workload_type_code as workLoadTypeCode,
			workload_type_desc as workloadTypeDesc,
			sort_order,
			contract_type_code as contractTypeCode
	from	lu_workload_type
	<cfif arguments.workloadTypeCode neq "0">
		where workload_type_code = #arguments.workloadTypeCode#
	</cfif>
	order 	by sort_order
	</cfquery>

	<cfreturn qryGetWorkloadTypes>
</cffunction>

<cffunction name="getOrganizationTypes" access="public" returntype="query" hint="Returns recordset containing list of organization categories">
	<cfargument name="catView" type="string" required="yes">

	<cfswitch expression="#arguments.catView#">
		<cfcase value="primary">
			<!--- list of primary org types --->
		</cfcase>
		<cfcase value="secondary">
			<!--- list of secondary org types --->
		</cfcase>
		<cfcase value="combo">
			<!--- combined list of primary/secondary org types --->
			<cfquery name="qryGetOrgTypes" >
			select	lu_org_subtype.org_subtype_code as orgSubTypeCode,
					lu_org_subtype.org_type_desc as orgSubTypeDesc,
					lu_org_subtype.sort_order as subSortOrder,
					lu_org_type.org_type_code as orgTypeCode,
					lu_org_type.org_type_desc as orgTypeDesc,
					lu_org_type.sort_order as sortOrder
			from	lu_org_subtype, lu_org_type
			where	lu_org_subtype.org_type_code = lu_org_type.org_type_code
			order	by sortOrder, subSortOrder
			</cfquery>

		</cfcase>
	</cfswitch>

	<cfreturn qryGetOrgTypes />
</cffunction>

<cffunction name="getSmallBusTypes" access="public" returntype="query" hint="Returns recordset containing list of small business categories">

	<cfquery name="qryGetSmallBusTypes" >
	select	smb_type_code as smbTypeCode,
			smb_type_desc as smbTypeDesc,
			sort_order	 as sortOrder
	from	lu_smb_type
	order	by sortOrder
	</cfquery>

	<cfreturn qryGetSmallBusTypes /	>
</cffunction>

<cffunction name="getCostCategories" access="public" returntype="query" hint="Returns recordset containing list of small business categories">
	<cfargument name="costCatID" type="numeric" required="no">
	<cfargument name="costCatCode" type="string" required="no">
	<cfargument name="displayFormat" type="string" required="no" default="primary" />
	<cfargument name="status" type="string" required="no" default="all" />

	<!--- display Formats: --->
	<!--- primary: top level cats, A, B1, B2, ... through S --->
	<!--- ecpOnly: A,C1,C2,S --->
	<!--- cccFOP: for CCC FOP form A, A-01, A-02 (all A sub cats), B1, B2, through S --->

	<cfquery name="qryGetCostCategories" >
	select	cost_cat_id as costCatID,
			cost_cat_p_id as catParentID,
			cost_cat_code as costCatCode,
			cost_cat_desc as costCatDesc,
			contract_type_code as contractTypeCode
	from	lu_cost_cat
		<cfswitch expression="#arguments.displayFormat#">
			<cfcase value="primary">
				where	cost_cat_p_id is null
			</cfcase>
			<cfcase value="ecpOnly">
				where	cost_cat_p_id is null and
						contract_type_code is not null
			</cfcase>
			<cfcase value="cccFOP">
				where	(cost_cat_p_id is null or
						cost_cat_p_id = 1) and
						cost_cat_id <> 1
			</cfcase>
		</cfswitch>
		<cfif isDefined("arguments.costCatID")>
			and cost_cat_id = '#arguments.costCatID#'
		</cfif>
		<cfif isDefined("arguments.costCatCode")>
			and cost_cat_code = '#arguments.costCatCode#'
		</cfif>
	<cfif arguments.status eq "active">
		and status = 1
	<cfelseif arguments.status eq "inactive">
		and status = 0
	</cfif>
	order	by cost_cat_code
	</cfquery>

	<cfreturn qryGetCostCategories />
</cffunction>

<cffunction name="getPY" access="public" returntype="query" hint="Get FOP Program Year">
	<cfargument name="sortDir" type="string" required="no" default="asc">

	<cfquery  name="qryPY">
		select  distinct PY
		from 	FOP
		<cfif arguments.sortDir neq "asc">
		order 	by PY #arguments.sortDir#
		</cfif>
	</cfquery>

	<cfreturn qryPY>
</cffunction>

<cffunction name="getPastPY" access="public" returntype="query" hint="Get Program Years That have VST Reports">
	<cfargument name="sortDir" type="string" required="no" default="desc">
	<cfquery name="qryGetPastPY" >
		select 		distinct PY
		from 		VST_Report_History
		order by	PY #arguments.sortDir#
	</cfquery>

	<cfreturn qryGetPastPY>
</cffunction>

<cffunction name="getAAPPRef" access="public" returntype="numeric" hint="Returns AAPP Reference">
	<cfargument name="refType" type="string" required="yes">

	<cfquery name="qryAAPPRef" >
	select  aapp_num
	from 	aapp_doc_ref
	where	upper(ref_type_code) = '#ucase(arguments.refType)#'
	</cfquery>

	<cfreturn qryAAPPRef.aapp_num>
</cffunction>

<cffunction name="getJFASUserRoles" access="public" returntype="query" hint="Returns list of user roles">
	<cfargument name="roleID" type="numeric" required="no">
	<cfargument name="sortByID" type="numeric" required="no">

	<cfquery name="qryUserRoles" >
	select  user_role_id as roleID,
			user_role_desc as roleDesc,
			user_role_cd as roleCd
	from 	lu_user_role
	<cfif isDefined("arguments.roleID")>
		where	user_role_id = #arguments.roleID#
	</cfif>
	<cfif isDefined("arguments.sortByID")>
		order	by user_role_id
	<cfelse>
		order	by sort_number
	</cfif>
	</cfquery>

	<cfreturn qryUserRoles>
</cffunction>


<cffunction name="getProj1Codes" access="public" returntype="query" hint="Returns list of all Proj1 Codes">

	<cfquery name="qryGetProj1Codes" >
		Select 	Distinct Proj1_Code as Proj1Code
		from	RCC_Code
		order by Proj1Code nulls first
	</cfquery>

	<cfreturn qryGetProj1Codes>
</cffunction>

<cffunction name="getWorksheetPY" access="public" returntype="query" hint="Returns distinct PY in ccc_worksheet table">
	<cfquery  name="qyrGetWorksheetPy">
		select distinct PROGRAM_YEAR as py
		from CCC_WORKSHEET
		union
		select utility.fun_getcurrntprogram_year_ccc as py
		from dual
		order by 1 desc
	</cfquery>

	<cfreturn qyrGetWorksheetPy>
</cffunction>

<cffunction name="getImportTypes" access="public" returntype="query" hint="Returns list (or single) data import process type">
	<cfargument name="importType" type="string" required="no">

	<cfquery name="getImportType" >
	select	import_type_code as importTypeCode,
			import_type_desc as importTypeDesc
	from	lu_import_type
	<cfif isDefined("arguments.importType")>
		where import_type_code = '#arguments.importType#'
	</cfif>
	order	by sort_order
	</cfquery>

	<cfreturn getImportType>
</cffunction>

<cffunction name="getFootprintFY" access="public" returntype="query" hint="Returns Footprint disctinct FY">
	<cfquery  name="qryFootprintFY">
		select distinct approp_fy as fy
		from footprint_ncfms
		order by fy desc
	</cfquery>
	<cfreturn qryFootprintFY>
</cffunction>

<cffunction name="getNCFMSTransTypes" access="public" returntype="query" hint="Returns list of NCFMS transaction types">
	<cfargument name="transArea" type="string" required="no" default="" hint="oblig, payment, cost">
	<cfargument name="transType" type="string" required="no" default="" hint="pass in one or more transaction types">
	<cfargument name="usedOnly" type="boolean" required="no" default="0" hint="only grab transactions types that are currently part of JFAS calculations">

	<cfquery  name="qryTransTypes">
	select	xactn_type, xactn_type_desc, oblig, payment, cost, sort_order
	from	lu_xactn_type_ncfms
	where	1=1
		<cfif arguments.transArea eq "O">
			and oblig = 1
		</cfif>
		<cfif arguments.transArea eq "P">
			and payment = 1
		</cfif>
		<cfif arguments.transArea eq "C">
			and cost = 1
		</cfif>
		<cfif arguments.transType neq "">
			and xactn_type in (#listQualify(arguments.transType,"'",",","all")#)
		</cfif>
		<cfif arguments.usedOnly>
			and (oblig=1 or payment=1 or cost=1)
		</cfif>
	order by sort_order
	</cfquery>
	<cfreturn qryTransTypes>

</cffunction>



<cffunction name="getVoucherTypes" access="public" returntype="query" hint="Returns Footprint disctinct FY">
	<cfargument name="voucherTypeCode" type="string" required="false" default="">

	<cfquery name="qryGetVoucherTypes" >
	select	voucher_type_code as voucherTypeCode,
			voucher_type_desc as voucherTypeDesc
	from	lu_voucher_type
	<cfif arguments.voucherTypeCode neq "">
		where voucher_type_code = '#arguments.voucherTypeCode#'
	</cfif>
	order 	by sort_order
	</cfquery>

	<cfreturn qryGetVoucherTypes>
</cffunction>

<cffunction name="getFutureInputTypes" access="public" returntype="query" hint="Input Types for Contract Future Budget">
	<cfargument name="futureInputTypeCode" type="string" required="false" default="">

	<cfquery name="qryGetFutureInputTypes" >
	select	input_future_type_code as inputFutureTypeCode,
			input_future_type_desc as inputFutureTypeDesc
	from	lu_future_input_type
	<cfif arguments.futureInputTypeCode neq "">
		where input_future_type_code = '#arguments.futureInputTypeCode#'
	</cfif>
	order 	by sort_order
	</cfquery>

	<cfreturn qryGetFutureInputTypes>
</cffunction>

<cffunction name="getFundCats" access="public" returntype="query" hint="Returns Funding Categories">
	<cfargument name="fundCat" type="string" required="false" default="">

	<cfquery name="qryGetFundCate" >
	select	fund_cat as fundCat,
			fund_cat_desc as fundCatDesc
	from	lu_fund_cat
	<cfif len(arguments.fundCat)>
		where fund_cat = '#arguments.fundCat#'
	</cfif>
	order 	by sort_order
	</cfquery>

	<cfreturn qryGetFundCate>
</cffunction>

<cffunction name="getRequestPY" access="public" returntype="query" hint="I get current program year based on current date">
	<cfset var py = ''>
	<cfquery name="py">
		select  utility.fun_getcurrntprogram_year() as py,
				utility.fun_getcurrntprogram_year_ccc() as py_ccc,
				utility.fun_getcurrntprogram_year_oth() as py_other,
                utility.fun_getcurrntprogram_year_sp() as py_splan,
				fop_batch.fun_voiddate() as voiddate
		from	dual
	</cfquery>
	<cfreturn py />

</cffunction>

</cfcomponent>