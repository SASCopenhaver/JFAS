<!---
Template: import_data_mnlxactn.cfc
Description: This template is used for the import of manual transaction data

Revision:
2010-08-06	mstein		File created
--->
<cfcomponent name="import_data_mnlxactn" displayname="Import Manual Transaction Data into JFAS" hint="Import Manual Transaction Data into JFAS">

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

	<!--- function validate Manual Transaction Upload --->
	<cffunction name="validateMnlXactn" returntype="string" output="false" hint="Validate Manual Transaction Upload">

		<cfset lstErrorMessages = "">

		<!--- get date range covered by XLS upload --->
		<cfset dateRange_start = application.outility.getSystemSetting(systemSettingCode="mnlxactn_start")>
		<cfset dateRange_end = application.outility.getSystemSetting(systemSettingCode="mnlxactn_end")>
		<!--- select all records from load table (within allowable date range, ignore $0 transactions) --->
		<cfquery name="qryGettransactionLoad" datasource="#request.dsn#">
		select	*
		from	FOOTPRINT_MNLXACTN_LOAD
		where	xactn_date >= '#dateformat(dateRange_start,"dd-mmm-yyyy")#' and
				xactn_date <= '#dateformat(dateRange_end,"dd-mmm-yyyy")#' and
				(ops <> 0 or cra <> 0 or se <> 0 or ops_arra <> 0 or cra_arra <> 0 or se_arra <> 0)
		</cfquery>

		<!--- loop through records --->
		<cfloop query="qryGettransactionLoad">

			<cfset lstMissingFields = "">
			<!--- check for required fields --->
			<cfif doc_type eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Document Type')>
			</cfif>
			<cfif fy eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Document FY')>
			</cfif>
			<cfif doc_num eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Document Number')>
			</cfif>
			<cfif agency_id eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Agency ID')>
			</cfif>
			<cfif fund eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Fund')>
			</cfif>
			<cfif budget_yr eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Budget Year')>
			</cfif>
			<cfif prog_code eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Program')>
			</cfif>
			<cfif activity eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Activity')>
			</cfif>
			<cfif strat_goal eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Strategic Goal')>
			</cfif>
			<cfif funding_org eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Funding Organization')>
			</cfif>
			<cfif managing_unit eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Managing Unit')>
			</cfif>
			<cfif cost_ctr eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Cost Center')>
			</cfif>
			<cfif obj_class_code eq "">
				<cfset lstMissingFields = listAppend(lstMissingFields, 'Object Class')>
			</cfif>
			<cfif lstMissingFields neq "">
				<cfset lstErrorMessages =  listAppend(lstErrorMessages,"Row #currentrow# (doc num #doc_num#) Missing fields: " & lstMissingFields,"~")>
			</cfif>

			<!--- check to make sure there is one non-zero value in all OPS/CRA/S&E fields --->
			<cfset AmountList = ops & "," & cra & "," & se & "," & ops_arra & "," & cra_arra & "," & se_arra>
			<cfset numAmounts = ListValueCountNoCase(AmountList,"0")>
			<cfif numAmounts lt 5>
				<cfset lstErrorMessages = listAppend(lstErrorMessages,"Row #currentrow# (doc num #doc_num#) has more than one non-zero dollar amount.","~")>
			<cfelse>
				<!--- if row has only one non-zero amount, make sure it doesn't conflict with the ARRA designation --->
				<!--- check to make sure field hasn't been designated as ARRA, but has no ARRA values --->
				<cfif (left(fund,4) eq "0182") and (ops_arra + cra_arra + se_arra eq 0)>
					<cfset lstErrorMessages = listAppend(lstErrorMessages,"Row #currentrow# (doc num #doc_num#) Treasury code designates as ARRA, but no ARRA dollar amounts are populated.","~")>
				<cfelseif (left(fund,4) neq "0182") and (ops_arra + cra_arra + se_arra gt 0)>
					<cfset lstErrorMessages = listAppend(lstErrorMessages,"Row #currentrow# (doc num #doc_num#) Treasury code designates as non-ARRA, but ARRA dollar amounts are populated.","~")>
				</cfif>
			</cfif>

		</cfloop>

		<cfreturn lstErrorMessages>
	</cffunction>


	<!--- function to clean manual transaction load data (until this can be done in sql loader) --->
	<cffunction name="cleanMnlXactn" returntype="void" output="false" hint="Clean up Manual Transaction Data">
		<cfset lstCurrFields = "ops,cra,se,ops_arra,cra_arra,se_arra">

		<cfloop list="#lstCurrFields#" index="fieldName">
			<cfquery name="qryCleanMnlXactn" datasource="#request.dsn#">
			update	footprint_mnlxactn_load
			set		#fieldName# = replace(replace(replace(replace(replace(#fieldName#, '.00',''), ')',''), '(','-'), ',',''), '$','')
			</cfquery>
		</cfloop>

	</cffunction>



	<cffunction name="insertMnlXactn" returntype="string" output="true" hint="Inserts Manual Transaction Data">
		<cfargument name="xactntype" type="string" required="yes">


		<!--- order of tasks: --->
		<!--- 1. Clean out all transactions within date range covered by XLS upload(from system settings) --->
		<!--- 2. Grab all records from transaction load table (raw XLS upload) within date range --->
		<!--- 3. Perform necessary transformations on data from XLS to JFAS XACTN format --->
		<!--- 4. Insert transaction in FOOTPRINT_XACTN_NCFMS --->
		<!--- 5. Roll up all transactions to footprint level, with SUM of obligation amount --->
		<!--- 6. Step through each footprint, and either update or insert in FOOTPRINT_NCFMS --->
		<!--- 7. Delete all post migration footprints in FOOTPRINT_NCFMS that were not touched by this process--->

		<!--- NOTE: For Release 2.7, this code has been changd to only allow OBLIGATION upload --->

		<cfset lstInfoMessages 		= "">
		<cfset insertedTransactions	= 0>
		<cfset insertedFootprints	= 0>
		<cfset updatedFootprints	= 0>
		<cfset deletedFootprints	= 0>

		<cfset dateRange_start = application.outility.getSystemSetting(systemSettingCode="mnlxactn_start")>
		<cfset dateRange_end = application.outility.getSystemSetting(systemSettingCode="mnlxactn_end")>
		<cftransaction>
		<!--- get info about current state of transaction table --->
		<cfquery name="qryGetInfo" datasource="#request.dsn#">
		select
		(select count(*) from footprint_mnlxactn_load) as totalXactnsRaw,
		(select count(*) from footprint_mnlxactn_load where xactn_date >= '#dateformat(dateRange_start,"dd-mmm-yyyy")#' and xactn_date <= '#dateformat(dateRange_end,"dd-mmm-yyyy")#') as totalXactnstoLoad,
		(select count(*) from footprint_xactn_ncfms) as totalXactns,
		(select count(*) from footprint_xactn_ncfms where creation_date >= '#dateformat(dateRange_start,"dd-mmm-yyyy")#' and creation_date <= '#dateformat(dateRange_end,"dd-mmm-yyyy")#' and xactn_type = '#arguments.xactntype#') as totalPostDolarsXactns
		from dual
		</cfquery>

		<!--- clean out all transactions within range coverend by XLS upload (from system settings) --->
		<cfquery name="qryCleanXactn" datasource="#request.dsn#">
		delete
		from	footprint_xactn_ncfms
		where	creation_date >= '#dateformat(dateRange_start,"dd-mmm-yyyy")#' and
				creation_date <= '#dateformat(dateRange_end,"dd-mmm-yyyy")#' and
				xactn_type = '#arguments.xactntype#'
		</cfquery>

		<cfset lstInfoMessages = listAppend(lstInfoMessages,"#numberformat(qryGetInfo.totalXactns)# transactions currently in JFAS transaction table.","~")>
		<cfset lstInfoMessages = listAppend(lstInfoMessages,"#numberformat(qryGetInfo.totalPostDolarsXactns)# #arguments.xactntype# records deleted (between #dateformat(dateRange_start,"mm/dd/yyyy")# and #dateformat(dateRange_end,"mm/dd/yyyy")#).","~")>
		<cfset lstInfoMessages = listAppend(lstInfoMessages,"#qryGetInfo.totalXactnsRaw# total transactions found in uploaded file.","~")>
		<cfset lstInfoMessages = listAppend(lstInfoMessages,"#qryGetInfo.totalXactnstoLoad# new transactions (with dates between #dateformat(dateRange_start,"mm/dd/yyyy")# and #dateformat(dateRange_end,"mm/dd/yyyy")#) will be loaded.","~")>


		<!--- select all rows from transaction load table --->
		<cfquery name="qryGetRawTransactions" datasource="#request.dsn#">
		select	*
		from	FOOTPRINT_MNLXACTN_LOAD
		where	xactn_date >= '#dateformat(dateRange_start,"dd-mmm-yyyy")#' and
				xactn_date <= '#dateformat(dateRange_end,"dd-mmm-yyyy")#' and
				(ops <> 0 or cra <> 0 or se <> 0 or ops_arra <> 0 or cra_arra <> 0 or se_arra <> 0)
		</cfquery>

		<!--- get import_id for last transaction import --->
		<cfquery name="qryGetImportID" datasource="#request.dsn#">
		select	nvl(max(import_id),9999) as lastImportID
        from    import_log
        where   upper(import_type_code) = 'MNLXACTN'
		</cfquery>

		<!--- loop through rows --->
		<cfloop query="qryGetRawTransactions">

			<!--- if object class ends with "79", this is late fee / interest --->
			<cfif right(obj_class_code,2) eq "79">
				<cfset newFeeIndicator = 1>
			<cfelse>
				<cfset newFeeIndicator = 0>
			</cfif>

			<!--- pull appropriation FY, expiration FY from fund code --->
			<cfset newAppropFY = get4digitYear(mid(fund, 5, 2))>
			<cfif isNumeric(mid(fund, 7, 2))>
				<cfset newExpireFY = get4digitYear(mid(fund, 7, 2))>
			<cfelse>
				<cfset newExpireFY = 9999>
			</cfif>

			<!--- calculate appropriation PY, expiration PY --->
			<cfset FYdiff = newExpireFY - newAppropFY>
			<cfset newExpirePY = newExpireFY - 1>
			<cfswitch expression="#FYdiff#">
				<cfcase value="0,2">
					<cfset newAppropPY = newAppropFY - 1>
				</cfcase>
				<cfdefaultcase>
					<cfset newAppropPY = newAppropFY>
				</cfdefaultcase>
			</cfswitch>

			<!--- if the TAFS Code is 0182, then this is ARRA --->
			<cfset newTAFScode = mid(fund, 1, 4)>
			<cfif newTAFScode eq "0182">
				<cfset newARRAindicator = 1>
			<cfelse>
				<cfset newARRAindicator = 0>
			</cfif>

			<!--- determine fund category --->
			<cfif (ops neq 0) or (ops_arra neq 0)>
				<cfset newFundCat = "OPS">
			<cfelseif (cra neq 0) or (cra_arra neq 0)>
				<cfset newFundCat = "CRA">
			<cfelse>
				<cfset newFundCat = "S/E">
			</cfif>

			<!--- set agency code --->
			<cfif agency_id eq "05">
				<cfset newAgencyCode = "1630">
			<cfelseif agency_id eq "26">
				<cfset newAgencyCode = "1631">
			</cfif>

			<!--- no blank vendor TIN --->
			<cfif len(vendor_tin) eq 0>
				<cfset newVendorTIN = "..">
			<cfelse>
				<cfset newVendorTIN = vendor_tin>
			</cfif>

			<!--- build account ID --->
			<cfset newAccountID = agency_id & fund & budget_yr & prog_code & activity & strat_goal & funding_org & managing_unit>

			<cfset newAmount = ops + cra + se + ops_arra + cra_arra + se_arra>

			<cfquery name="qryInsertTransaction" datasource="#request.dsn#">
			insert	into footprint_xactn_ncfms
					(xactn_id, agency_code, doc_type, fy,
					 doc_num, account_id, agency_id,
					 budget_yr, approp_code, prog_proj,
					 activity, sub_activity, funding_org,
					 managing_unit, cost_center_code, obj_class_code,
					 creation_date, effective_date,
					 vendor_name, vendor_tin,
					 amount, xactn_type,
					 approp_fy, approp_exp_fy, approp_py, approp_exp_py,
					 fund_cat, latefee_intrst_ind, arra_ind,
					 tafs_code, date_create, update_user_id,
					 update_function, update_time, data_source)
			values	(seq_xactn_ncfms.nextval, '#newAgencyCode#', '#doc_type#', #get4digitYear(fy)#,
					 '#doc_num#', '#newAccountID#', '#agency_id#',
					 #budget_yr#, '#fund#', '#prog_code#',
					 '#activity#', '#strat_goal#','#funding_org#',
					 '#managing_unit#', '#cost_ctr#','#obj_class_code#',
					 '#dateFormat(xactn_date, "dd-mmm-yyyy")#', '#dateFormat(xactn_date, "dd-mmm-yyyy")#',
					 '#vendor_name#', '#newVendorTIN#',
					 #newAmount#, '#arguments.xactntype#',
					 #newAppropFY#, #newExpireFY#, #newAppropPY#, #newExpirePY#,
					 '#newFundCat#', #newFeeIndicator#, #newARRAindicator#,
					 '#newTAFScode#', sysdate, '#session.userid#',
					 'I', sysdate, 'UPL')
			</cfquery>
			<cfset insertedTransactions = insertedTransactions + 1>

		</cfloop>

		<cfset lstInfoMessages = listAppend(lstInfoMessages,"#insertedTransactions# transactions successfully loaded.<br>","~")>


		<!--- query to roll up all transactions to footprint level --->
		<!--- leaving out all footprints that were not impacted by the recent transaction upload --->
		<cfquery name="qryRollupTransactions" datasource="#request.dsn#">
		select	doc_num, fy, doc_type,
				account_id, agency_code, tafs_code,
				cost_center_code, fund_cat, latefee_intrst_ind,
				vendor_tin, arra_ind, approp_fy,
				approp_exp_fy, approp_py, approp_exp_py,
				vendor_name, obj_class_code,
				sum(amount) as obligAmount
		from	footprint_xactn_ncfms
		where	xactn_type = 'OBL'
		group	by	doc_num, fy, doc_type,
					account_id, agency_code, tafs_code,
					cost_center_code, fund_cat, latefee_intrst_ind,
					vendor_tin, arra_ind, approp_fy,
					approp_exp_fy, approp_py, approp_exp_py,
					vendor_name, obj_class_code
		</cfquery>

		<cfset lstInfoMessages = listappend(lstInfoMessages,"Entire transaction table rolls up to #qryRollupTransactions.recordCount# footprints.","~~")>

		<!--- loop through results --->
		<cfloop query="qryRollupTransactions">

			<!--- check to see if record exists in footprint table or not --->
			<cfquery name="qryCheckForFootprint" datasource="#request.dsn#">
			select	footprint_id, oblig, payment, cost
			from	footprint_ncfms
			where	DOC_TYPE = '#doc_type#' and
					DOC_FY = '#fy#' and
					DOC_NUM = '#doc_num#' and
					ACCOUNT_ID = '#account_id#' and
					LATEFEE_INTRST_IND = #LATEFEE_INTRST_IND# and
					VENDOR_TIN = '#VENDOR_TIN#' and
					OBJ_CLASS_CODE = '#obj_class_code#' and
					ARRA_IND = #ARRA_IND# and
					COST_CENTER_CODE = '#cost_center_code#'
			</cfquery>


			<cfif qryCheckForFootprint.recordcount eq 1> <!--- footprint already exists --->

				<!--- if record existed, and rolled up amounts are different from existing, then perform an update --->

				<!--- update existing footprint with current import ID (to reflect that it was referenced) --->
				<!--- if obligation amount is different, then update amount and update_date --->
				<cfquery name="qryUpdateFootprint" datasource="#request.dsn#">
				update	footprint_ncfms
				set		import_id = #qryGetImportID.lastImportID#
						<cfif (qryCheckForFootprint.oblig neq obligAmount)>
							,
							oblig = #obligAmount#,
							update_date = sysdate
						</cfif>
				where	footprint_id = #qryCheckForFootprint.footprint_id#
				</cfquery>

				<cfif (qryCheckForFootprint.oblig neq obligAmount)>
					<cfset updatedFootprints = updatedFootprints + 1>
				</cfif>

			<cfelseif qryCheckForFootprint.recordcount eq 0>
				<!--- if record did not exist, then do an insert --->

				<!--- get next footprint ID --->
				<cfquery name="qryGetFootID" datasource="#request.dsn#">
				select seq_footprint_ncfms.nextval as footID from dual
				</cfquery>

				<!--- get funding office number, based on last 3 chars of cost center --->
				<cfquery name="qryGetFundingOffice" datasource="#request.dsn#" maxrows="1">
				select	funding_office_num
				from	lu_cost_center
				where	cost_center_code like '%#right(cost_center_code,3)#'
				</cfquery>

				<cfquery name="qryInsertFootprint" datasource="#request.dsn#">
				Insert into FOOTPRINT_NCFMS
					(FOOTPRINT_ID, DOC_TYPE, DOC_FY, DOC_NUM,
					ACCOUNT_ID, AGENCY_CODE,
					TAFS_CODE, APPROP_FY, APPROP_EXP_FY,
					APPROP_PY, APPROP_EXP_PY, FUNDING_OFFICE_NUM,
					COST_CENTER_CODE, FUND_CAT, LATEFEE_INTRST_IND,
					VENDOR_TIN, VENDOR_NAME, OBJ_CLASS_CODE,
					ARRA_IND, OBLIG,
					SOURCE_IND, IMPORT_ID, UPDATE_USER_ID)
				Values
					(#qryGetFootID.footID#, '#doc_type#', #fy#, '#doc_num#',
					'#account_id#', '#agency_code#',
					'#tafs_code#', #approp_fy#, #approp_exp_fy#,
					 #approp_py#, #approp_exp_py#, #qryGetFundingOffice.funding_office_num#,
					'#cost_center_code#', '#fund_cat#', '#latefee_intrst_ind#',
					'#vendor_tin#',
					<cfif vendor_name eq "">null<cfelse>'#vendor_name#'</cfif>,
					'#obj_class_code#',
					'#arra_ind#', #obligAmount#,
					1, #qryGetImportID.lastImportID#, 'dataload')
				</cfquery>

				<cfset insertedFootprints = insertedFootprints + 1>

			</cfif>

		</cfloop>

		<!--- check to see how many post-migration footprint records were not reflected in latest upload --->
		<cfquery name="qryCheckforDelete" datasource="#request.dsn#">
		select	count(*) as numRecs
		from	footprint_ncfms
		where	source_ind  > 0 and
				import_id <> #qryGetImportID.lastImportID#
		</cfquery>

		<cfset deletedFootprints = qryCheckforDelete.numRecs>


		<cfquery name="qryDeleteFootprint" datasource="#request.dsn#">
		delete
		from	footprint_ncfms
		where	source_ind  > 0 and
				import_id <> #qryGetImportID.lastImportID#
		</cfquery>

		<cfset lstInfoMessages = listappend(lstInfoMessages,"Loaded transactions resulted in #insertedFootprints# new footprints being inserted.","~~")>
		<cfset lstInfoMessages = listappend(lstInfoMessages,"Loaded transactions resulted in #updatedFootprints# existing footprints being updated (updates are only made if dollar amounts differ).","~~")>
		<cfset lstInfoMessages = listappend(lstInfoMessages,"#deletedFootprints# existing footprints were deleted because they are not referenced in the transaction table.","~~")>


		</cftransaction>

		<cfreturn lstInfoMessages>
	</cffunction>

</cfcomponent>