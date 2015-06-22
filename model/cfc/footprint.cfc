<!---
page: footprint.cfc

description: component that footprint functions

revisions:
2007-03-21	mstein	Added function getFOOTFunding
2009-12-22	mstein	Updated severAAPPLink for NCFMS

Functions:
getFootprintList: used for footprint listing tab
getFootprintCount: returns count of footprints for an AAPP
getFundCodes: get list of distinct fund codes for an AAPP
getProgramCodes: get list of distinct program codes for an AAPP
getDocNumbers: gets list of doc numbers for an AAPP
getVendorNames: get list of vendor names for an AAPP
getFootprintDetails: get full information for a specific footprint
getTransactionList: get list of transactions that meet certain criteria
--->

<cfcomponent displayname="Footprint Component" hint="Contains selecting footprints">
	
	<cffunction name="getFootprintList" hint="get Footprints based on criteria" returntype="query" access="public">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfargument name="fundCat" type="string" required="yes" default="">
		<cfargument name="docNum" type="string" required="yes" default="">
		<cfargument name="docNum_searchType" type="string" required="yes" default="exact">
		<cfargument name="fundCode" type="string" required="yes" default="">
		<cfargument name="programCode" type="string" required="yes" default="">
		<cfargument name="programCode_short" type="string" required="yes" default="">
		<cfargument name="vendorName" type="string" required="yes" default="">
		<cfargument name="vendorName_searchType" type="string" required="yes" default="exact">
		<cfargument name="sortBy" type="string" required="no">
		<cfargument name="sortDir" type="string" required="no">

		<cfquery name="qryGetFootprintList" datasource="#request.dsn#">
		select		footprint_id as footprintID,
					fund_cat as fundCat,
					doc_type as docType,
					doc_fy as docFY,
					doc_num as docNum,
					doc_type || ' ' || substr(doc_fy,3,2) || ' ' || doc_num as docID,
					fund_code as fundCode,
					program_code as programCode,
					substr(program_code,length(program_code)-6,6) as programCode_short,
					vendor_name as vendorName,
					fo.funding_office_num as fundingOfficeNum,
					fo.funding_office_desc as fundingOfficeDesc,
					cost_center as costCenter,
					object_class as objectClass,
					oblig, cost, payment
		from		footprint_ncfms fp, lu_funding_office fo
		where		fp.funding_office_num = fo.funding_office_num
		<cfif len(arguments.aapp)>
			and		aapp_num =  #arguments.aapp#
		</cfif>
		<cfif len(arguments.fundCat)>
			and		fund_cat =  '#arguments.fundCat#'
		</cfif>
		<cfif len(arguments.docNum)>
			<cfif arguments.docNum_searchType eq "exact">
				and upper(doc_num) = '#ucase(arguments.docNum)#'
			<cfelse>
				and upper(doc_num) LIKE '#ucase(arguments.docNum)#%'
			</cfif>
		</cfif>
		<cfif len(arguments.fundCode)>
			and		fund_code =  '#arguments.fundCode#'
		</cfif>
		<cfif len(arguments.programCode)>
			and		program_code =  '#arguments.programCode#'
		</cfif>
		<cfif len(arguments.programCode_short)>
			and		substr(program_code,length(program_code)-6,6) =  '#arguments.programCode_short#'
		</cfif>
		<cfif len(arguments.vendorName)>
			<cfif arguments.vendorName_searchType eq "exact">
				and upper(vendor_name) = '#ucase(arguments.vendorName)#'
			<cfelse>
				and upper(vendor_name) LIKE '#ucase(arguments.vendorName)#%'
			</cfif>
		</cfif>
		order by #arguments.sortBy# #arguments.sortDir#, fundCat, docID, fundCode, programCode
		</cfquery>
	
		<cfreturn qryGetFootprintList>
		
	</cffunction>
	
	
	<cffunction name="getFootprintCount" hint="get Footprint count for an AAPP" returntype="numeric" access="public">
		<cfargument name="aapp" type="numeric" required="yes">
		
		<cfquery name="qryGetFootprintCount" datasource="#request.dsn#">
		select	count(footprint_id) as numFP
		from	footprint_ncfms
		where	aapp_num =  #arguments.aapp#
		</cfquery>
		
		<cfreturn qryGetFootprintCount.numFP>	
	
	</cffunction>
		
	
		
	
	<cffunction name="getDocNumbers" access="public" returntype="query" hint="get list of unique Document Numbers from NCFMS footprints">
		<cfargument name="aapp" type="numeric" required="no">
		
		<cfquery name="qryGetDocNums" datasource="#request.dsn#" >
		select distinct doc_num as docNum
		from footprint_ncfms
		<cfif isdefined("arguments.aapp")>
			where aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#">
		</cfif>
		order by docNum
		</cfquery>
		
		<cfreturn qryGetDocNums>
	</cffunction>
	
	
	<cffunction name="getVendorNames" access="public" returntype="query" hint="get list of unique Vendor Names from NCFMS footprints">
		<cfargument name="aapp" type="numeric" required="no">
		
		<cfquery name="qryGetVendorNames" datasource="#request.dsn#" >
		select distinct vendor_name as vendorName
		from footprint_ncfms
		<cfif isdefined("arguments.aapp")>
			where aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#">
		</cfif>
		order by vendorName
		</cfquery>
		
		<cfreturn qryGetVendorNames>
	</cffunction>
	
	
	<cffunction name="getFootprintDetails" access="public" returntype="query" hint="Return full set of details for a footprint">
		<cfargument name="footprintID" type="numeric" required="true">
		
		<!--- get footprint data --->
		<cfquery name="qryGetFootprintInfo" datasource="#request.dsn#" maxrows="1">
		select		footprint_id as footprintID,
					fund_cat as fundCat,
					doc_type as docType,
					doc_fy as docFY,
					doc_num as docNum,
					doc_type || ' ' || substr(doc_fy,3,2) || ' ' || doc_num as docID,
					fund_code as fundCode,
					program_code as programCode,
					substr(program_code,length(program_code)-6,6) as programCode_short,
					vendor_duns as vendorDuns,
					vendor_name as vendorName,
					fp.managing_unit as managingUnit,
					fo.funding_office_num as fundingOfficeNum,
					fo.funding_office_desc as fundingOfficeDesc,
					cost_center as costCenter,
					object_class as objectClass,
					oblig, cost, payment
		from		footprint_ncfms fp, lu_funding_office fo
		where		fp.funding_office_num = fo.funding_office_num and
					footprint_id =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.footprintID#">
		</cfquery>
		
		<cfreturn qryGetFootprintInfo>		
		 
	</cffunction>
	
	
	<!--- 
	<cffunction name="getXactnDetails" access="public" returntype="query" hint="Get all details about a specific transaction">
		<cfargument name="xactnID" type="numeric" required="true">
		<cfargument name="statusID" type="numeric" required="false" default="1">
		
		<!--- get all transaction details from either transaction or transaction log (if deleted) table --->
		<cfquery name="qryXactnDetails" datasource="#request.dsn#">
		select	fund_cat as fundCat,
				doc_type as docType,
				fy as docFY,
				doc_num as docNum,
				doc_type || ' ' || substr(fy,3,2) || ' ' || doc_num as docID,
				vendor_name as vendorName,
				vendor_duns as vendorID,
				lfo.funding_office_num as fundingOfficeNum,
				lfo.funding_office_desc as fundingOfficeDesc,
				account_id as accountID,
				fx.cost_center_code as costCenter,
				obj_class_code as objectClass,
				lx.xactn_type as xactnType,
				lx.xactn_type_desc as xactnTypeDesc,
				creation_date as xactnDate,
				xactn_desc as xactnDesc,
				amount,
				mod_num as modNum,
				invoice_num as invoiceNum,
				fx.date_create as dateCreate,
				<cfif arguments.xactnStatus eq 1>
					decode (fx.update_function,
					  'I', 'Insert',
					  'U', 'Update',
					  'D', 'Delete')
					as updateFunction,
					fx.update_time as updateTime,
					fx.update_user_id as updateUser,
					'' as xactnComments,
					1 as xactnStatus,
				<cfelse>
					decode (fx.log_action,
					  'I', 'Insert',
					  'U', 'Update',
					  'D', 'Delete')
					as updateFunction,
					fx.log_date as updateTime,
					fx.log_user_id as updateUser,
					log_comment as xactnComments,
					0 as xactnStatus,
				</cfif>
				decode (fx.data_source,
                  'MIG', 'Migration',
                  'UPL', 'XLS Upload',
                  'MNL', 'Data Entry')
             	as dataSource
		from	<cfif arguments.xactnStatus eq 1>
					footprint_xactn_ncfms
				<cfelse>
					footprint_xactn_ncfms_log
				</cfif> fx,
				lu_cost_center lcc,
				lu_funding_office lfo,
				lu_xactn_type_ncfms lx
		where	xactn_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.xactnID#"> and
				lcc.cost_center_code =  fx.cost_center_code and
				lcc.funding_office_num = lfo.funding_Office_num and
				fx.xactn_type = lx.xactn_type
		</cfquery>
		
		<cfreturn qryXactnDetails>	
	</cffunction>
	--->
	
	
	<cffunction name="severAAPPlink" access="public" output="false" hint="Breaks link between footprint and AAPP">
		<cfargument name="docNum" type="string" required="true">
		<cfargument name="aappNum" type="numeric" required="true">
		
		<cfquery name="qryseverAAPPLink" datasource="#request.dsn#">
		update	footprint_ncfms
		set		aapp_num = null,
				update_date = sysdate,
				update_user_id = '#session.userID#'
		where	doc_num = '#arguments.docNum#' and
				aapp_num = #arguments.aappNum#
		</cfquery>
	
	</cffunction>

	
	
	<cffunction name="getXactnTypes" access="public" returntype="query" hint="Get list of NCFMS Document Types">
		
		<cfquery name="qryGetDocTypes" datasource="#request.dsn#">
		select	doc_type as docType,
				doc_type_desc as docTypeDesc,
				doc_source as docSource,
				small_purchase as smallPurchase					
		from	lu_doc_type_ncfms
		order	by sort_order, doc_type
		</cfquery>	
		
		<cfreturn qryGetDocTypes>
	</cffunction>
	
	
	<cffunction name="getFundCodes" access="public" returntype="query" hint="get list of Footprint Fund Codes">
		<cfargument name="aapp" type="numeric" required="no">
		
		<cfif not isDefined("arguments.aapp")>
			<!--- get list of fund codes from lookup table 	--->
			<cfquery name="qryGetFundCodes" datasource="#request.dsn#">
			select	fund_code as fundCode,
					fund_cat as fundCat,
					arra_ind as arraInd					
			from	lu_fund_code
			order	by fund_code
			</cfquery>	
		<cfelse>
			<!--- if aapp specified, pull list of funding codes from that aapp's footprints --->
			<cfquery name="qryGetFundCodes" datasource="#request.dsn#" >
			select distinct fund_code as fundCode
			from footprint_ncfms
			where aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#">
			order by fundCode
			</cfquery>
		</cfif>
		
		<cfreturn qryGetFundCodes>
	</cffunction>
	

	<cffunction name="getProgramCodes" access="public" returntype="query" hint="get list Footprint Program Codes">
		<cfargument name="aapp" type="numeric" required="no">
		<cfargument name="displayType" type="string" required="yes" default="long">
		
		<cfif not isDefined("arguments.aapp")>
			<!--- get list of program codes from lookup table 	--->
			<cfquery name="qryGetProgramCodes" datasource="#request.dsn#">
			select
				<cfif arguments.displayType eq "short">
					substr(program_code,length(program_code)-6,6)
				<cfelse>
					program_code
				</cfif>	 as programCode,
					fund_cat as fundCat,
					arra_ind as arraInd					
			from	lu_program_code
			order	by programCode
			</cfquery>	
		<cfelse>
			<!--- if aapp specified, pull list of program codes from that aapp's footprints --->
			<cfquery name="qryGetProgramCodes" datasource="#request.dsn#" >
			select
				<cfif arguments.displayType eq "short">
					distinct substr(program_code,length(program_code)-6,6)
				<cfelse>
					distinct program_code
				</cfif>
					 as programCode
			from footprint_ncfms
			where aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aapp#">
			order by programCode
			</cfquery>
		</cfif>
	
		<cfreturn qryGetProgramCodes>
	</cffunction>
	
	
	<cffunction name="getDocTypes" access="public" returntype="query" hint="Get list of NCFMS Document Types">
		<cfargument name="filter" type="string" required="false">
		
		<cfquery name="qryGetDocTypes" datasource="#request.dsn#">
		select	doc_type as docType,
				doc_type_desc as docTypeDesc,
				doc_source as docSource,
				small_purchase as smallPurchase,
				sort_order as sortOrder					
		from	lu_doc_type_ncfms
				<cfif isDefined("arguments.filter")>
					where 1=1
					<cfif arguments.filter eq "allowImport">
						and import = 1
					</cfif>
				</cfif>
		order	by sortOrder, doc_type
		</cfquery>	
		
		<cfreturn qryGetDocTypes>
	</cffunction>
	
	<cffunction name="getAgencyIDs" access="public" returntype="string" hint="Get list of NCFMS OJC Agency IDs">
		
		<cfset lstAgencyIDs = "26,05">		
		<cfreturn lstAgencyIDs>
	</cffunction>
	
	<cffunction name="getActivityCodes" access="public" returntype="query" hint="Get list of NCFMS Activity Codes">
		
		<cfquery name="qryGetActivityCodes" datasource="#request.dsn#">
		select	activity_code as activityCode					
		from	lu_activity_code
		order	by sort_order, activity_code
		</cfquery>	
		
		<cfreturn qryGetActivityCodes>
	</cffunction>
	
	<cffunction name="getStrategicGoals" access="public" returntype="query" hint="Get list of NCFMS Strategic Goals">
		
		<cfquery name="qryGetStrategicGoals" datasource="#request.dsn#">
		select	strategic_goal as strategicGoal					
		from	lu_strategic_goal
		order	by sort_order, strategic_goal
		</cfquery>	
		
		<cfreturn qryGetStrategicGoals>
	</cffunction>
	
	<cffunction name="getFundingOrgs" access="public" returntype="query" hint="Get list of NCFMS Funding Orgs">
		
		<cfquery name="qryGetFundingOrgs" datasource="#request.dsn#">
		select	funding_org as fundingOrg					
		from	lu_funding_org
		order	by sort_order, funding_org
		</cfquery>	
		
		<cfreturn qryGetFundingOrgs>
	</cffunction>
	
	<cffunction name="getManagingUnits" access="public" returntype="query" hint="Get list of NCFMS managing Units">
		
		<cfquery name="qryGetManagingUnits" datasource="#request.dsn#">
		select	managing_unit_code as mngUnitCode,
				managing_unit_desc as mngUnitDesc,
				funding_office_num as fundingOfficeNum
		from	lu_managing_unit
		order	by fundingOfficeNum
		</cfquery>	
		
		<cfreturn qryGetManagingUnits>
	</cffunction>
	
	
	<cffunction name="getCostCenters" access="public" returntype="query" hint="Get list of NCFMS Cost Centers">
		
		<cfquery name="getCostCenters" datasource="#request.dsn#">
		select	cost_center_code as costCenterCode,
				cost_center_desc as costCenterDesc,
				funding_office_num as fundingOfficeNum					
		from	lu_cost_center
		order	by funding_office_num, cost_center_code
		</cfquery>	
		
		<cfreturn getCostCenters>
	</cffunction>
	
	
	<cffunction name="getObjectClasses" access="public" returntype="query" hint="Get list of NCFMS Object Class Codes">
		
		<cfquery name="getObjectClasses" datasource="#request.dsn#">
		select	obj_class_code as objClassCode,
				sort_order as sortOrder					
		from	lu_obj_class
		order	by sortOrder, objClassCode
		</cfquery>	
		
		<cfreturn getObjectClasses>
	</cffunction>
	
	
	<cffunction name="getFootprintFYs" access="public" returntype="query" hint="Get list of FYs from footprint table">
		
		<cfquery name="qryGetFootFYs" datasource="#request.dsn#">
		select	distinct(appropfy)
		from	footprint_ncfms_dataset
		order	by appropfy
		</cfquery>	
		
		<cfreturn qryGetFootFYs>
	</cffunction>
	
	<cffunction name="getFootprintPYs" access="public" returntype="query" hint="Get list of PYs from footprint table">
		
		<cfquery name="qryGetFootPYs" datasource="#request.dsn#">
		select	distinct(approppy)
		from	footprint_ncfms_dataset
		order	by approppy
		</cfquery>	
		
		<cfreturn qryGetFootPYs>
	</cffunction>
	
	
	
	
	<!--- also needs to be updated when voucher module is re-written. Ok for now. --->
	<cffunction name="getOPSCRA" access="public" returntype="query">
		<cfquery name="qryOPSCRA" datasource="#request.dsn#" >
			SELECT Distinct(upper(OPS_CRA)) as OPSCRA
			FROM RCC_CODE
		</cfquery>
		<cfreturn qryOPSCRA>
	</cffunction> 
	
	<!--- also needs to be updated when voucher module is re-written. Ok for now. --->
	<cffunction name="getValidDocNum" access="public" returntype="query">
		<cfargument name="aapp" required="yes" type="numeric">
		<cfargument name="qryType" required="no" type="string" default="voucher">
		
		<cfquery name="qryValidDocNum" datasource="#request.dsn#">
			Select	Distinct(Doc_Num) as DocNum
			From	Footprint
			Where 	Aapp_Num = #arguments.aapp#
			<cfif arguments.qryType is "voucher">
			and		footprint.FY > (#request.PY# - 5)
			and 	footprint.oblig - footprint.cost > 0
			</cfif>
		</cfquery>
		
		<cfreturn qryValidDocNum>
	</cffunction>
	
	
	<cffunction name="getFOOTFunding" access="public" returntype="numeric" hint="Gets foot funding total based on specified criteria">
		<cfargument name="aapp" type="numeric" required="no">		
		<cfargument name="fundCat" type="string" required="no">
		<cfargument name="status" type="string" required="no" hint="active,expired">
		<cfargument name="fundType" type="string" required="no" default="oblig" hint="oblig,payment,cost">
		<cfargument name="docNum" type="string" required="no">
		<cfargument name="fy" type="numeric" required="no">
		<cfargument name="py" type="numeric" required="no">
		
		<!--- query to get total FOOT funding --->
		<cfquery name="qryGetFOOTFunding" datasource="#request.dsn#">
		select	<cfswitch expression="#arguments.fundType#">
				<cfcase value="cost">
					sum(cost) as amount
				</cfcase>
				<cfcase value="payment">
					sum(payment) as amount
				</cfcase>
				<cfdefaultcase>
					sum(oblig) as amount
				</cfdefaultcase>
				</cfswitch>
		from	footprint_ncfms
		where	1=1
			<cfif isDefined("arguments.aapp")>
				and aapp_num = #arguments.aapp#
			</cfif>
			<cfif isDefined("arguments.docNum")>
				and upper(doc_num) = '#ucase(arguments.docNum)#'
			</cfif>
			<cfif isDefined("arguments.fundCat")>
				and upper(fund_cat) = '#ucase(arguments.fundCat)#'
			</cfif>
			<cfif isDefined("arguments.status")>
				<cfif arguments.status eq "expired">
					and approp_exp_py < #request.py#
				<cfelseif arguments.status eq "active">
					and approp_exp_py >= #request.py#
				</cfif>					
			</cfif>
			<cfif isDefined("arguments.fy")>
				and approp_fy = #arguments.fy#
			</cfif>
			<cfif isDefined("arguments.py")>
				and approp_py = #arguments.py#
			</cfif>
		group by aapp_num
			<cfif isDefined("arguments.fundCat")>, fund_cat</cfif>
		</cfquery>
		
		<cfif (qryGetFOOTFunding.amount eq "") or (qryGetFOOTFunding.recordcount eq 0)>
			<cfreturn 0>
		<cfelse>
			<cfreturn qryGetFOOTFunding.amount>
		</cfif>		
		
	</cffunction>
	
	
	<cffunction name="footprintAAPPmatching" returntype="struct" output="false" hint="Runs auto-matching between footprints and AAPPs">
	
		<cfset lstInfoMessages			= "">
		<cfset numUnmatchedFootprints 	= 0>
		<cfset numFootprintsMatched		= 0>
		<cfset numMatchIgnored			= 0>
		<cfset numIgnored				= 0>
		<cfset success					= 1>
		<cfset lstMultDocMatch_AAPP		= "">
		<cfset lstMultDocMatch_Cont		= "">
		
		
		<cfset natlOfficeTransportVendor 	= "CITIBANK">
		<cfset natlOfficeFundingNums 		= "20">	
		
		<!--- get list of small purchase Doc Types --->
		<cfquery name="qryGetSmallPurchDocTypes" datasource="#request.dsn#">
		select	doc_type
		from    lu_doc_type_ncfms
		where   small_purchase = 1     	
		</cfquery>		
		<cfset lstDocTypes_SmallPurchase 	= valueList(qryGetSmallPurchDocTypes.doc_type)>
		
		
		<!--- select all footprint records without an AAPP association --->
		<cfquery name="qryGetUnmatchedFootprint" datasource="#request.dsn#">
		select	footprint_id, doc_type, doc_num,
				fund_cat, latefee_intrst_ind, arra_ind,
				oblig, vendor_name, vendor_duns,
				footprint_ncfms.funding_office_num, late_fee_aapp_num, small_purch_aapp_num
		from    footprint_ncfms, lu_funding_office
		where   footprint_ncfms.funding_office_num = lu_funding_office.funding_office_num and
				aapp_num is null
		order   by footprint_id        	
		</cfquery>
		
		
		<!--- loop through records --->
		<cfloop query="qryGetUnmatchedFootprint">			
			<cfset newAAPP = "">
	
			<cfif newAAPP eq "">	
				<!--- Late Fee / Interest --->
				<!--- Use late fee AAPP Num in results set (if not null) --->
				<cfif latefee_intrst_ind eq "1">
					
					<cfif late_fee_aapp_num neq "">
						<cfset newAAPP = late_fee_aapp_num>
					<cfelse>
						<cfset newAAPP = "noMatch">
						<cfset lstInfoMessages = listAppend(lstInfoMessages,"Warning: Late fee identified, but no late fee AAPP found for funding office #funding_office_num#","~")>
					</cfif>
				
				</cfif>
			</cfif> <!--- late fee --->
			
			
			<cfif newAAPP eq "">
				<!--- is there a similar footprint that already has an AAPP associated? --->
				<!--- match by Doc Number, Late Fee/Interest Indicator --->
				<cfquery name="qryFindMatchedRecord" datasource="#request.dsn#">
				select	distinct aapp_num
				from	footprint_ncfms
				where	aapp_num is not null and
						upper(doc_num) = '#ucase(doc_num)#' and
						latefee_intrst_ind = #latefee_intrst_ind#
				</cfquery>
				
				<cfif qryFindMatchedRecord.recordCount gt 0>
					<cfif qryFindMatchedRecord.recordCount eq 1>
						<!--- one AAPP found, use this --->
						<cfset newAAPP = qryFindMatchedRecord.aapp_num>
					<cfelse>
						<!--- more than one AAPP found, report issue, do not assign --->
						<cfset newAAPP = "noMatch">
						<cfif NOT listFindNoCase(lstMultDocMatch_AAPP,doc_num)> <!--- only display this once per doc number --->
							<cfset lstInfoMessages = listAppend(lstInfoMessages,"Warning: Found multiple AAPP matches for doc #doc_num#. No association made.","~")>
							<cfset lstMultDocMatch_AAPP = listAppend(lstMultDocMatch_AAPP,doc_num)>
						</cfif>
					</cfif>
				</cfif>
				
			</cfif> <!--- similar matches --->
			
			
			<cfif newAAPP eq "">
				<!--- ARRA, S/E --->
				<!--- Look in AAPP_DOC_REF for "ARRA_NO_SE" record --->
				<cfif listFind(natlOfficeFundingNums, funding_office_num) and (arra_ind eq "1") and (fund_cat eq "S/E")>
					
					<cfquery name="qryFindARRA_SE" datasource="#request.dsn#">
					select	aapp_num
					from	aapp_doc_ref
					where	upper(ref_type_code) = 'ARRA_NO_SE' and
							aapp_num is not null
					</cfquery>
					
					<cfif qryFindARRA_SE.recordCount eq 1>
						<cfset newAAPP = qryFindARRA_SE.aapp_num>
					<cfelse>
						<cfset newAAPP = "noMatch">
						<cfset lstInfoMessages = listAppend(lstInfoMessages,"Warning: No National Office ARRA S/E AAPP Found.","~")>
					</cfif>
				
				</cfif> 			
			</cfif> <!--- N.O. ARRA S/E --->
			
			
			
			<cfif newAAPP eq "">
				<!--- National Office, ARRA, CRA --->
				<!--- Look in AAPP_DOC_REF for "ARRA_NO_CRA" record --->
				<cfif listFind(natlOfficeFundingNums, funding_office_num) and (arra_ind eq "1") and (fund_cat eq "CRA")>
				
					<cfquery name="qryFindARRA_CRA" datasource="#request.dsn#">
					select	aapp_num
					from	aapp_doc_ref
					where	upper(ref_type_code) = 'ARRA_NO_CRA' and
							aapp_num is not null
					</cfquery>
					
					<cfif qryFindARRA_CRA.recordCount eq 1>
						<cfset newAAPP = qryFindARRA_CRA.aapp_num>
					<cfelse>
						<cfset newAAPP = "noMatch">
						<cfset lstInfoMessages = listAppend(lstInfoMessages,"Warning: No National Office ARRA CRA AAPP Found.","~")>
					</cfif>
				
				</cfif> 				
			</cfif> <!--- N.O. ARRA CRA --->
			
			
			<cfif newAAPP eq "">
				<!--- National Office Transportation (National Office, vendor = "CITIBANK") --->
				<cfif listFind(natlOfficeFundingNums, funding_office_num) and (fund_cat eq "OPS") and (ucase(vendor_name) eq ucase(natlOfficeTransportVendor))>
								
					<cfquery name="qryFind_NOTRANS" datasource="#request.dsn#" maxrows="1">
					select	aapp_num
					from	aapp_doc_ref
					where	upper(ref_type_code) = 'NOTRANS' and
							aapp_num is not null
					</cfquery>
						
					<cfif qryFind_NOTRANS.recordCount eq 1>
						<cfset newAAPP = qryFind_NOTRANS.aapp_num>
					<cfelse>
						<cfset newAAPP = "noMatch">
						<cfset lstInfoMessages = listAppend(lstInfoMessages,"Warning: No National Office Transportation AAPP Found.","~")>
					</cfif>
				
				</cfif> 				
			</cfif> <!--- N.O. Transportation --->
			
			
			<cfif newAAPP eq "">
				<!--- if there is one AAPP that has a contract number that exactly matches the document number, then associate --->
				<cfif left(doc_num,3) eq "DOL">
					<!--- also look for matches without the DOL prefix --->
					<cfset subDocNum = right(doc_num,len(doc_num)-3)>
				</cfif>
				<cfquery name="qryFind_ContractNumMatch" datasource="#request.dsn#">
				select	distinct aapp_num
				from	aapp
				where	upper(contract_num) = upper('#doc_num#')
						<cfif left(doc_num,3) eq "DOL">
							or upper(contract_num) = upper('#subDocNum#')
						</cfif>
				</cfquery>
						
				<cfif qryFind_ContractNumMatch.recordCount eq 1>
					<cfset newAAPP = qryFind_ContractNumMatch.aapp_num>
				<cfelseif qryFind_ContractNumMatch.recordCount gt 1>
					<cfset newAAPP = "noMatch">
					<cfif NOT listFindNoCase(lstMultDocMatch_Cont,doc_num)> <!--- only display this once per doc number --->
						<cfset lstInfoMessages = listAppend(lstInfoMessages,"Warning: Multiple AAPPs found with matching CONTRACT Number: #doc_num#. No association made.","~")>
						<cfset lstMultDocMatch_Cont = listAppend(lstMultDocMatch_Cont,doc_num)>
					</cfif>
				</cfif>
			</cfif>				

			
			<!--- if AAPP number has been determined, then update footprint record --->
			<cfif newAAPP neq "" and newAAPP neq "noMatch">
				
				<cfquery name="qryUpdateFootprint" datasource="#request.dsn#">
				update	footprint_ncfms
				set		aapp_num = #newAAPP#,
						update_date = sysdate,
						update_user_id = 'aappMatching'
				where	footprint_id = #footprint_id#
				</cfquery>
				
				<cfset numFootprintsMatched = numFootprintsMatched + 1>
			
			<cfelse>
				<cfif newAAPP eq ""> <!--- record did not match any rule --->
					<cfset numIgnored = numIgnored + 1>
				<cfelseif newAAPP eq "noMatch"> <!--- record matched rule, but AAPP not found --->
					<cfset numMatchIgnored = numMatchIgnored + 1>
				</cfif>
			</cfif>	
		
		</cfloop>
		
		<cfset lstInfoMessages = listAppend(lstInfoMessages,"Process began with #qryGetUnmatchedFootprint.recordcount# footprint records without AAPP association.","~")>
		<cfset lstInfoMessages = listAppend(lstInfoMessages,"#numFootprintsMatched# footprint records were associated with AAPPs as a result of this process.","~")>
		<cfif numMatchIgnored><cfset lstInfoMessages = listAppend(lstInfoMessages,"#numMatchIgnored# footprint records satisfied criteria, but were not associated (see output above).","~")></cfif>
		<cfif numIgnored><cfset lstInfoMessages = listAppend(lstInfoMessages,"#numIgnored# footprint records did not satisfy matching criteria.","~")></cfif>
		<cfset lstInfoMessages = listAppend(lstInfoMessages,"#evaluate(qryGetUnmatchedFootprint.recordcount - numFootprintsMatched)# footprint records still without AAPP association.","~")>
		
		<cfset strResults.success = success>
		<cfset strResults.lstInfoMessages = lstInfoMessages>
		<cfreturn strResults>
	
	</cffunction>
	
	
	<cffunction name="getAAPPFootDisc" access="public" returntype="struct" hint="Return list of doc numbers in footprint_ncfms without associated aapp numbers">
		<cfargument name="maxRecords" type="numeric" required="no" default="-1">
		
		<cfset strResults = structNew()>
		
		<!--- updated for NCFMS --->
		<cfquery name="qryGetAAPPFootDisc_count" datasource="#request.dsn#" maxrows="#arguments.maxRecords#">
		select	count (distinct doc_num) numRecs
		from	footprint_ncfms
		where	aapp_num is null and
				latefee_intrst_ind = 0
		</cfquery>
		
		<!--- updated for NCFMS --->
		<cfquery name="qryGetAAPPFootDisc" datasource="#request.dsn#" maxrows="#arguments.maxRecords#">
		select	doc_num as docNum,
				max(funding_office_num) fundingOfficeNum,
				max(vendor_name) as vendorName
		from	footprint_ncfms
		where	aapp_num is null
		group	by doc_num
		order	by doc_num
		</cfquery>
		
		<cfset strResults.totalRecords = qryGetAAPPFootDisc_count.numRecs>
		<cfset strResults.rstFootprintDisc = qryGetAAPPFootDisc>
		
		<cfreturn strResults>	
	</cffunction>
	
	
	<!--- Function for updating unmatched document numbers in FOOTPRINT_NCFMS --->
	<cffunction name="updateAAPPFootDisc" access="public" returntype="struct">
		<cfargument name="FormData" type="struct" required="yes">
		
		<cfset lstErrorMessages = "">
		<cfset lstErrorFields = "">
		<cfset success = 1>
		
		<cftransaction>
			<!--- loop through list of form fields passed in --->
			<cfloop list="#arguments.FormData.FieldNames#" index="listitem">
				<cfif findnocase("aappNum__", listitem)>
					<cfif form[listitem] NEQ "">
						<cfset AAPPNum = trim(form[listitem])>				
						<!--- check to make sure AAPP number entered exists in JFAS, is active, and is not a CCC --->
						<cfquery name="qryCheckforValidAAPP" datasource="#request.dsn#">
						select	aapp_num
						from	aapp
						where	aapp_num = #AAPPNum# and
								contract_status_id = 1 and
								agreement_type_code <> 'CC'
						</cfquery>
						<cfif not qryCheckforValidAAPP.recordcount>
							<cfset lstErrorMessages = listappend(lstErrorMessages,"#AAPPNum# is not a valid, active AAPP.","~~")>
							<cfset lstErrorFields = listAppend(lstErrorFields, "#listitem#", "~")>
							<cfset success = 0>
						<cfelse>
							<!--- associate aapp with this document number (non-late fee) --->
							<cfset docNum = listgetat(listitem,2,"__")>
							<cfquery name="UpdateFootprint" datasource="#request.dsn#">
							update	footprint_ncfms
							set		aapp_num = #AAPPNum#, 
									update_user_id = '#session.userID#',
									update_date = sysdate
							where	doc_num = '#docNum#' and
									latefee_intrst_ind = 0
							</cfquery>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
		
		</cftransaction>
		
		<cfset strFootprintDiscResults = StructNew()>
			<cfset strFootprintDiscResults.lstErrorMessages = lstErrorMessages>
			<cfset strFootprintDiscResults.lstErrorFields = lstErrorFields>
			<cfset strFootprintDiscResults.success = success>
		<cfreturn strFootprintDiscResults>
	
	</cffunction>
	
</cfcomponent>