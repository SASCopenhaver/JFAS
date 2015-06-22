<!--- 
Template: import_data_ncfms.cfc
Description: This template is used for the import of ncfms data

Revision:
2013-08-04	mstein	file created (ncfms footprint only)
2013-12-5	mstein	fixed scoping issue with getNCFMSFundCat
--->

<cfcomponent name="import_data_ncfms" displayname="Import of NCFMS Data into JFAS" hint="Import of NCFMS Data into JFAS">
	
	<cffunction name="get4digitYear" returntype="string">
		<cfargument name="yearVal" type="numeric">	
		<cfif yearVal lt 1000>
			<cfif yearVal gt 50>
				<cfreturn 1900 + yearVal>
			<cfelse>
				<cfreturn 2000 + yearVal>
			</cfif>
		</cfif>
	</cffunction>

		
	
	<cffunction name="validateNCFMSFootLoad" returntype="struct" output="false" hint="Validates NCFMS Foot Load prior to import, returns validation messages.">
		
		<cfset success = 1>
		<cfset lstErrorMessages = "">
		<cfset lstWarningMessages = "">
				
		<!--- WARNING LEVEL VALIDATION: look for validation errors that will cause alerts, but not halt import --->
		<!--- remove records that will not be imported --->
		
		<!--- NON-Job Corps records found (and deleted) --->
		<cfquery name="qryDetermineOJCAgency" datasource="#request.dsn#">
		select	count(document_id) as numRecs
		from	FOOTPRINT_NCFMS_LOAD
		where	agency_code	<> 26
		</cfquery>
		
		<cfif qryDetermineOJCAgency.numRecs gt 0>
			<cfset lstWarningMessages = listAppend(lstWarningMessages,"WARNING: There are #qryDetermineOJCAgency.numRecs# non-Job Corps agency records included. These will not be imported.","~~")>	
			<!--- delete these --->
			<cfquery name="qryDeleteNonOJCAgency" datasource="#request.dsn#">
			delete
			from	FOOTPRINT_NCFMS_LOAD
			where	agency_code	<> 26
			</cfquery>
		</cfif>
		
		<!--- import includes doc types NOT on the approved list --->
		<cfquery name="qryValidDocTypes" datasource="#request.dsn#">
		select	distinct substr(document_id,1,2) as docType
		from	FOOTPRINT_NCFMS_LOAD
		where	substr(document_id,1,2) not in (select doc_type from lu_doc_type_ncfms)
		</cfquery>
		
		<cfif qryValidDocTypes.recordCount gt 0>
			<cfset lstWarningMessages = listAppend(lstWarningMessages,"WARNING: Records found with doc types that are not on the import list (#ValueList(qryValidDocTypes.docType)#). These will not be imported.","~~")>	
			<!--- delete these --->
			<cfquery name="qryDeleteInvalidDocTypes" datasource="#request.dsn#">
			delete
			from	FOOTPRINT_NCFMS_LOAD
			where	substr(document_id,1,2) not in (select doc_type from lu_doc_type_ncfms)
			</cfquery>
		</cfif>			
		
		<!--- funding office can't be determined based on managing unit, cost center--->
		<cfquery name="qryDetermineFundingOffice" datasource="#request.dsn#">
		select	document_id, managing_unit, fund_code
		from	FOOTPRINT_NCFMS_LOAD
		where	cost_center not in (select cost_center_code from lu_cost_center) and
				managing_unit not in (select managing_unit_code from lu_managing_unit)
		</cfquery>
		<cfif qryDetermineFundingOffice.recordCount gt 0>
			<cfset lstWarningMessages = listAppend(lstWarningMessages,"WARNING: There are 2 document IDs for which the funding office can not be determined - will be left blank (#ValueList(qryDetermineFundingOffice.document_id)#).","~~")>
		</cfif>			
		<!--- WARNING LEVEL VALIDATION: End --->
		
		
		<!--- ERROR LEVEL VALIDATION: look for validation errors that will halt import --->
		<!--- document ID + fund code is NOT unique --->
		<cfquery name="qryFindDuplicateKey" datasource="#request.dsn#">
		select	document_id, fund_code
		from	(select document_id, fund_code, count(*) as numrecs
				from footprint_ncfms_load
				group by document_id, fund_code)
		where numrecs > 1
		</cfquery>		
		<cfif qryFindDuplicateKey.recordCount gt 0>
			<cfset success = 0>
			<cfloop query="qryFindDuplicateKey">
				<cfset lstErrorMessages = listAppend(lstErrorMessages,"ERROR: Duplicate records found with same Document ID and Fund Code combination (#document_id# / #fund_code#). Import aborted.","~~")>	
			</cfloop>		
		</cfif>
		
		<!--- fund cat can NOT be determined --->
		<cfquery name="qryCheckforFundCat" datasource="#request.dsn#">
		select	distinct fund_code, program_code
		from	footprint_ncfms_load
		order	by fund_code, program_code
		</cfquery>
		<cfloop query="qryCheckforFundCat">
			<cfset newFundCat = this.getNCFMSFundCat(qryCheckforFundCat.program_code, qryCheckforFundCat.fund_code)>
			<cfif newFundCat eq 0>
				<cfset success = 0>
				<cfset lstErrorMessages = listAppend(lstErrorMessages,"ERROR: Funding Category cannot be determined (Program Code: #program_code#, Fund Code: #fund_code#). Import aborted.","~~")>	
			</cfif>
		</cfloop>		
		<!--- ERROR LEVEL VALIDATION: end --->
		
		
		<cfset strResults = StructNew()>
		<cfset strResults.lstErrorMessages = lstErrorMessages>
		<cfset strResults.lstWarningMessages = lstWarningMessages>
		<cfset strResults.success = success>
		<cfreturn strResults>
	
	</cffunction>
	
	
	
	<cffunction name="getNCFMSFundCat" returntype="string" output="false" hint="Determines fund category based on program code and fund code.">
		<cfargument name="programCode" type="string" required="true">
		<cfargument name="fundCode" type="string" required="false" default="0">
		
		<cfset fundCat = "0">
		
		<!--- determine funding category (OPS, CRA, S&E) --->
		<!--- for newer account lines, this can be found in chars 5-7 or the program code --->
		<!--- for  older account lines, this must be done using a lookup to a fundcode/program code table --->
		<cfswitch expression="#mid(arguments.programCode,5,3)#">
			<cfcase value="OPS">
				<cfset fundCat = "OPS">
			</cfcase>
			<cfcase value="CRA">
				<cfset fundCat = "CRA">
			</cfcase>
			<cfcase value="ADM">
				<cfset fundCat = "S/E">
			</cfcase>
			<cfdefaultcase>
				<!--- older account line, must use lookup table to determine fund cat --->
				<cfquery name="qryGetFundCat" datasource="#request.dsn#" maxrows="1">
				select	fund_cat
				from	i_fundprogram_fundcat
				where	fund_code = '#arguments.fundCode#' and
						program_code = '#arguments.programCode#'
				</cfquery>			
				<cfif qryGetFundCat.recordCount>
					<cfset fundCat =  qryGetFundCat.fund_cat>
				</cfif>
			</cfdefaultcase>		
		</cfswitch>	
	
		<cfreturn fundCat>
	</cffunction>
	
	
	<cffunction name="NCFMSFootInsertUpdate" returntype="string" output="false" hint="Inserts or Updates Footprint Record">
		<cfargument name="strFootRec" type="struct" required="yes">
		
		<!--- check to see if this document ID + fund code exists in footprint table already --->
		<cfquery name="qryCheckforDocID" datasource="#request.dsn#">
		select	count(footprint_id) as numRecs
		from	footprint_ncfms
		where	document_id = '#arguments.strFootRec.documentID#' and
				fund_code = '#arguments.strFootRec.fundCode#'
		</cfquery>
		
		<cfif qryCheckforDocID.numRecs eq 0>
			<!--- document ID not found, need to INSERT --->
			
			<!--- get new footprint ID --->
			<cfquery name="qryGetFootprintSeq" datasource="#request.dsn#">
			select	seq_footprint_ncfms.nextVal as newID
			from	dual	
			</cfquery>
			
			<cfquery name="qryInsertFootprint" datasource="#request.dsn#">
			insert into	footprint_ncfms
				(footprint_id, document_id,
				 doc_type, doc_fy,
				 doc_num, agency_code, fund_code,
				 budget_year, program_code, activity,
				 strat_goal, funding_org, managing_unit,
				 cost_center, object_class, approp_fy,
				 approp_exp_fy, approp_py, approp_exp_py,
				 <cfif isDefined("arguments.strFootRec.fundingOfficeNum")>funding_office_num,</cfif>
				 fund_cat, latefee_intrst_ind,
				 vendor_duns, vendor_name, arra_ind,
				 oblig, payment, cost,
				 create_date, update_date, update_flag)
			values
				(#qryGetFootprintSeq.newID#, '#arguments.strFootRec.documentID#',
				 '#arguments.strFootRec.docType#', #arguments.strFootRec.docFY#,
				'#arguments.strFootRec.docNum#', '#arguments.strFootRec.agencyCode#', '#arguments.strFootRec.fundCode#',
				#arguments.strFootRec.budgetYear#, '#arguments.strFootRec.programCode#', '#arguments.strFootRec.activity#',
				'#arguments.strFootRec.stratGoal#', '#arguments.strFootRec.fundingOrg#', '#arguments.strFootRec.managingUnit#',
				'#arguments.strFootRec.costCenter#', '#arguments.strFootRec.objectClass#', #arguments.strFootRec.appropFY#,
				#arguments.strFootRec.expireFY#, #arguments.strFootRec.appropPY#, #arguments.strFootRec.expirePY#,
				 <cfif isDefined("arguments.strFootRec.fundingOfficeNum")>#arguments.strFootRec.fundingOfficeNum#,</cfif>
				'#arguments.strFootRec.fundCat#', #arguments.strFootRec.feeIndicator#,
				'#arguments.strFootRec.vendorDUNS#', '#arguments.strFootRec.vendorName#', #arguments.strFootRec.ARRAindicator#,
				#arguments.strFootRec.oblig#, #arguments.strFootRec.payment#, #arguments.strFootRec.cost#,
				sysdate, sysdate, 1)
			</cfquery>
			<cfset updateType = "INS">
					
		<cfelse>
			<!--- UPDATE --->
			<cfquery name="qryInsertFootprint" datasource="#request.dsn#">
			update	footprint_ncfms
			set		doc_type = '#arguments.strFootRec.docType#',
					doc_fy = #arguments.strFootRec.docFY#,
					doc_num = '#arguments.strFootRec.docNum#',
					agency_code = '#arguments.strFootRec.agencyCode#',
					budget_year = #arguments.strFootRec.budgetYear#,
					program_code = '#arguments.strFootRec.programCode#',
					activity = '#arguments.strFootRec.activity#',
					strat_goal = '#arguments.strFootRec.stratGoal#',
					funding_org = '#arguments.strFootRec.fundingOrg#',
					managing_unit = '#arguments.strFootRec.managingUnit#',
					cost_center = '#arguments.strFootRec.costCenter#',
					object_class = '#arguments.strFootRec.objectClass#',
					approp_fy = #arguments.strFootRec.appropFY#,
					approp_exp_fy = #arguments.strFootRec.expireFY#,
					approp_py = #arguments.strFootRec.appropPY#,
					approp_exp_py = #arguments.strFootRec.expirePY#,
					<cfif isDefined("arguments.strFootRec.fundingOfficeNum")>funding_office_num = #arguments.strFootRec.fundingOfficeNum#,</cfif>
					fund_cat = '#arguments.strFootRec.fundCat#',
					latefee_intrst_ind = #arguments.strFootRec.feeIndicator#,
					vendor_duns = '#arguments.strFootRec.vendorDUNS#',
					vendor_name = '#arguments.strFootRec.vendorName#',
					arra_ind = #arguments.strFootRec.ARRAindicator#,
					oblig = #arguments.strFootRec.oblig#,
					payment = #arguments.strFootRec.payment#,
					cost = #arguments.strFootRec.cost#,
					update_date = sysdate,
					update_flag = 1
			where	document_id = '#arguments.strFootRec.documentID#' and
					fund_code = '#arguments.strFootRec.fundCode#'
			</cfquery>
			<cfset updateType = "UPD">
		</cfif>
		
		<cfreturn updateType>
	</cffunction>
	
	
	
	<cffunction name="NCFMSFootCleanUp" returntype="numeric" output="true" hint="Deletes Footprint Records from JFAS that were not included in import">
		
		<cfquery name="qryGetRecordCountforDeletion" datasource="#request.dsn#">
		select	count(footprint_id) as numRecs
		from	footprint_ncfms
		where	update_flag = 0
		</cfquery>
		
		<cfset numRecsDeleted = qryGetRecordCountforDeletion.numRecs>
		
		<cfquery name="qryDeleteFootprint" datasource="#request.dsn#">
		delete
		from	footprint_ncfms
		where	update_flag = 0
		</cfquery>
		
		<cfquery name="qryUpdateFlag" datasource="#request.dsn#">
		update	footprint_ncfms
		set		update_flag = 0
		</cfquery>
		
		<cfreturn numRecsDeleted>		
	</cffunction>

	
	
	
	<cffunction name="NCFMSFootImport" returntype="struct" output="true" hint="Transforms, Imports, and Matches NCFMS Footprint Records">
		<cfargument name="userID" required="false" default="sys">
		
		<cfset lstImportMessage 		= "">
		<cfset insertedFootprints	= 0>
		<cfset updatedFootprints	= 0>
		<cfset deletedFootprints	= 0>
		<cfset ignoredFootprints	= 0>
		<cfset success				= 1>
		<cfset strResults = StructNew()>
		
		<cftransaction>
		<!--- get info about current state of transaction table --->
		<cfquery name="qryGetInfo" datasource="#request.dsn#">
		select	
		(select count(*) from footprint_ncfms_load) as totalFootLoad,
		(select count(*) from footprint_ncfms) as totalFootExisting,
		(select count(*) from footprint_ncfms where aapp_num is null) as totalFootUnmatched
		from dual
		</cfquery>		
		
		<cfset lstImportMessage = listAppend(lstImportMessage,"#qryGetInfo.totalFootLoad# total records ready to load after validation/cleaning.","~~")>
		<cfset lstImportMessage = listAppend(lstImportMessage,"#numberformat(qryGetInfo.totalFootExisting)# records currently in NCFMS Footprint table.","~~")>
		<cfset lstImportMessage = listAppend(lstImportMessage,"#qryGetInfo.totalFootUnmatched# records in NCFMS footprint table without associated AAPP number.","~~")>
			
		
		<!--- select all rows from NCFMS FOOT load table --->
		<cfquery name="qryGetRawFootprints" datasource="#request.dsn#">
		select	*
		from	footprint_ncfms_load
		order	by document_id
		</cfquery>
		
		
		<!--- loop through rows --->
		<cfloop query="qryGetRawFootprints">
		
			<cfset strNewFoot = StructNew()>
			<cfset validFoot = 1>
		
			<!--- set up fields for insert/update in real footprint table --->
			<cfset strNewFoot.documentID = document_id>
			<cfset strNewFoot.docType = mid(document_id,1,2)>
			<cfset strNewFoot.docFY =  get4digitYear(mid(document_id,3,2))>			
			<!--- doc num is from character 5, through the end of the ID, minus last 3 suffix. replace spaces with underscores --->
			<cfset tmpDocNum = mid(document_id,5,len(document_id)-7)>
			<cfset strNewFoot.docNum = replace( replace(tmpDocNum," ","_","all"),"-","_","all")> 
			<cfset strNewFoot.agencyCode = agency_code>
			<cfset strNewFoot.fundCode = fund_code>
			<cfset strNewFoot.budgetYear = budget_year>
			<cfset strNewFoot.programCode = program_code>
			<cfset strNewFoot.activity = activity>
			<cfset strNewFoot.stratGoal = strat_goal>
			<cfset strNewFoot.fundingOrg = funding_org>
			<cfset strNewFoot.managingUnit = managing_unit>
			<cfset strNewFoot.costCenter = cost_center>
			<cfset strNewFoot.objectClass = object_class>
			
			<!--- pull appropriation FY, expiration FY from fund code --->
			<cfset strNewFoot.appropFY = get4digitYear(mid(fund_code, 5, 2))>
			<cfif isNumeric(mid(fund_code, 7, 2))>
				<cfset strNewFoot.expireFY = get4digitYear(mid(fund_code, 7, 2))>
			<cfelse>
				<cfset strNewFoot.expireFY = 9999>
			</cfif>
			
			<!--- calculate appropriation PY, expiration PY --->
			<cfset FYdiff = strNewFoot.expireFY - strNewFoot.appropFY>
			<cfset strNewFoot.expirePY = strNewFoot.expireFY - 1>
			<cfswitch expression="#FYdiff#">
				<cfcase value="0,2">
					<cfset strNewFoot.appropPY = strNewFoot.appropFY - 1>			
				</cfcase>
				<cfdefaultcase>
					<cfset strNewFoot.appropPY = strNewFoot.appropFY>
				</cfdefaultcase>
			</cfswitch>
			
			<!--- determine funding office number --->
			<cfset tmpFudingOfficeNum = this.getFootprintFundingOffice(managing_unit,cost_center)>
			<cfif tmpFudingOfficeNum neq -1>
				<cfset strNewFoot.fundingOfficeNum = tmpFudingOfficeNum>
			</cfif>
			<!---
			<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" managingUnit="#managing_unit#" costCenter="#cost_center#" returnvariable="qryFundingOffice">
			<cfset strNewFoot.fundingOfficeNum = qryFundingOffice.fundingOfficeNum>
			--->
			
			<!--- determine fund category --->
			<cfset strNewFoot.fundCat = this.getNCFMSFundCat(strNewFoot.programCode, strNewFoot.fundCode)>
			<cfif strNewFoot.fundCat eq 0>
				<cfset lstImportMessage = listappend(lstImportMessage,"WARNING: Funding category could not be determined: fund code: #strNewFoot.fundCode# , program code: #strNewFoot.programCode#  .","~~")>
			<cfelseif strNewFoot.fundCat eq "S/E">
				<cfset validFoot = 0>
			</cfif>			
			
			<!--- if object class ends with "79", this is late fee / interest --->
			<cfset strNewFoot.feeIndicator = iif(right(object_class,2) eq "79",1,0)>
			
			<!--- vendor information --->
			<cfset strNewFoot.vendorDUNS = vendor_duns>
			<cfset strNewFoot.vendorName = vendor_name>			
			
			<!--- set ARRA flag (if the TAFS Code is 0182) --->
			<cfset strNewFoot.ARRAindicator = iif(mid(fund_code, 1, 4) eq "0182",1,0)>
			
			<cfset strNewFoot.oblig = ordered_amount - canceled_amount>
			<cfset strNewFoot.payment = advance_amount + billed_amount>
			<cfset strNewFoot.cost = received_amount>
			
			<cfif validFoot>
				<!--- INSERT or UPDATE Footprint --->
				<cfset insertUpdateType = this.NCFMSFootInsertUpdate(strNewFoot)>
				<cfif insertUpdateType eq "INS">
					<cfset insertedFootprints = insertedFootprints + 1>
				<cfelse>
					<cfset updatedFootprints = updatedFootprints + 1>
				</cfif>
			<cfelse>
				<cfset ignoredFootprints = ignoredFootprints + 1>
			</cfif>		
		</cfloop> <!--- loop through records in footprint_ncfms_load --->
		
		<!--- delete footprint records that were not updated (did not exist in extract --->
		<cfset deletedFootprints = this.NCFMSFootCleanUp()>		
		
		<cfset lstImportMessage = listappend(lstImportMessage,"Loaded footprint records resulted in #insertedFootprints# new footprints being inserted.","~~")>
		<cfset lstImportMessage = listappend(lstImportMessage,"Loaded footprint records resulted in #updatedFootprints# existing footprints being updated.","~~")>
		<cfset lstImportMessage = listappend(lstImportMessage,"#ignoredFootprints# footprint records were ignored, and not inserted.","~~")>
		<cfset lstImportMessage = listappend(lstImportMessage,"#deletedFootprints# existing footprints were deleted because they did not exist in the latest import file.","~~")>
		
		<!--- associate new footprints with JFAS AAPPs --->
		<cfinvoke component="#application.paths.components#footprint" method="footprintAAPPmatching" returnvariable="strMatchingResults">
		<cfif strMatchingResults.success>
			<cfset lstImportMessage = listappend(lstImportMessage,strMatchingResults.lstInfoMessages,"~~")>
		</cfif>		

		</cftransaction>
		
		<cfset strResults.success = success>
		<cfset strResults.lstImportMessage = lstImportMessage>
		
		<cfreturn strResults>	
	</cffunction>
	
	
	
	<cffunction name="getFootprintFundingOffice" returntype="numeric" output="false" hint="Returns funding office based on managing unit and cost center">
		<cfargument name="managingUnit" type="string" required="true">
		<cfargument name="costCenter" type="string" required="true">
		
		<cfset fundingOfficeNum = -1>
		
		<!--- check for managing unit in lookup table --->
		<cfquery name="qryGetFObyManagingUnit" datasource="#request.dsn#" maxrows="1">
		select	funding_office_num
		from	lu_managing_unit
		where	managing_unit_code = '#arguments.managingUnit#'
		</cfquery>
		
		<cfif qryGetFObyManagingUnit.recordCount>
			<!--- if managing unit found, use this funding office --->
			<cfset fundingOfficeNum = qryGetFObyManagingUnit.funding_office_num>
		<cfelse>
				<!--- check for cost center in lookup table --->
				<cfquery name="qryGetFObyCostCenter" datasource="#request.dsn#" maxrows="1">
				select	funding_office_num
				from	lu_cost_center
				where	cost_center_code = '#arguments.costCenter#'
				</cfquery>
				<!--- if cost center found, use this funding office --->
				<cfif qryGetFObyCostCenter.recordCount>
					<cfset fundingOfficeNum = qryGetFObyCostCenter.funding_office_num>
				</cfif>		
		</cfif>
		
		<cfreturn fundingOfficeNum>		
	
	</cffunction>
	
	
	
</cfcomponent>