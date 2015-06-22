<!---
Template: import_data.cfc
Description: This template is used for import data
Revision:
abai 		08/20/2007	Revised for adding Transaction import part (validateTransact and insertTransact).
abai 		08/27/2007	Add one fundtion import_Tracking for inserting record into import_log table
rroser		9/10/2007	Footprint/AAPP matching checks to make sure AAPP is active
rroser		9/11/2007	Added function to validate Ajustment Upload data
2008-06-19	mstein		Modified getDolarsDisc to allow parameter for max # of rows
2009-12-23	mstein		Updated getDolarsDisc (renamed getAAPPFootDisc)
						and updateDolarsDisc (renamed updateAAPPFootDisc) for NCFMS
2010-08-11	mstein		Created new AAPP Matching Routine (footprintAAPPmatching)
2013-01-31	mstein		Modified insert2110 to use CF code instead of SQL Stored Proc (for performance)
2013-08-11	mstein		Removed AAPP/Foot discrepancy functions (moved to footprint.cfc)
2013-11-18	mstein		Limited import tracking notes field to 4000 char to avoid db error
--->
<cfcomponent name="import_data" displayname="Import JFAS data" hint="Import JFAS data">


	<!--- function for validation Dolar data --->
	<cffunction name="validateDolar" returntype="query" output="false" hint="Validate Dolar Data">
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_validate_pkg.jfas_dolar_validation_pc">
				<cfprocresult name="validate_error">
		</cfstoredproc>
		<cfreturn validate_error>
	</cffunction>


	<!--- function for inserting dolar data --->
	<cffunction name="insertDolar" returntype="struct" output="false" hint="Validate Dolar Data">
		<cfset result = structNew()>
		<!--- insert data and get total records from Dolar actual table --->
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_data_pkg.jfas_dolar_insert_pc">
			<cfprocparam cfsqltype="CF_SQL_varchar" type="in" variable="userID" value="#session.userID#">
			<cfprocparam cfsqltype="CF_SQL_varchar" type="in" variable="tabname" value="footprint_load">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="out" variable="rsRecords">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="out" variable="rsStatus">
		</cfstoredproc>
		<cfset result.records = rsRecords>
		<cfset result.status = rsStatus>

		<cfreturn result>
	</cffunction>


	<!--- function for validation Equipment data --->
	<cffunction name="validateEquipment" returntype="query" output="false" hint="Validate Equipment Data">
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_validate_pkg.jfas_equip_validation_pc">
				<cfprocresult name="validate_error">
			</cfstoredproc>
		<cfreturn validate_error>
	</cffunction>

	<!--- function for validation Vehicle data --->
	<cffunction name="validateVehicle" returntype="query" output="false" hint="Validate Vehicle Data">
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_validate_pkg.jfas_vehicle_validation_pc">
				<cfprocresult name="validate_error">
		</cfstoredproc>
		<cfreturn validate_error>
	</cffunction>

	<!--- function for validation 2110 data --->
	<cffunction name="validate2110" returntype="query" output="false" hint="Validate 2110 Data">
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_validate_pkg.jfas_2110_validation_pc">
				<cfprocresult name="validate_error">
		</cfstoredproc>
		<cfreturn validate_error>
	</cffunction>

	<!--- function for validation Adjusment/Upload data --->
	<cffunction name="validateAdjustment" returntype="query" hint="Validate Adjustment/Fop Data">
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_validate_pkg.jfas_adjustment_validation_pc">
			<cfprocresult name="validate_error">
		</cfstoredproc>
		<cfreturn validate_error>
	</cffunction>

	<!--- function to preview adjustment batch upload before inserting adjustments/fops --->
	<cffunction name="previewAdjustment" returntype="query" hint="Adjustment/FOP Preview">
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_validate_pkg.jfas_adjustment_preview_pc">
			<cfprocresult name="preview_data">
		</cfstoredproc>
		<cfreturn preview_data>
	</cffunction>

	<!--- function for inserting Equipment data --->
	<cffunction name="insertEquipment" returntype="struct" output="false" hint="Validate Equipment Data">
		<cfset result = structNew()>
		<!--- insert data and get total records from Equipment actual table --->
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_data_pkg.jfas_equip_insert_pc">
			<cfprocparam cfsqltype="CF_SQL_varchar" type="in" variable="userID" value="#session.userID#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="out" variable="rsRecords">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="out" variable="rsStatus">
		</cfstoredproc>
		<cfset result.records = rsRecords>
		<cfset result.status = rsStatus>

		<cfreturn result>
	</cffunction>


	<!--- function for inserting 2110 data --->
	<cffunction name="insert2110" returntype="struct" output="true" hint="Insert FMS 2110 Data">
		<cfset result = structNew()>
		<cfset cutOffDate = '12/31/2006'>

		<cftransaction>

		<!--- get list of column names, and corresponding 2110 types and cost categories --->
		<cfquery name="qryGet2110Types" datasource="#request.dsn#">
		select	load_column, type_id, cost_cat_id
		from	center_2110_load_map
		</cfquery>

		<!--- consolidate Suuport (cat S) amounts --->
		<cfquery name="qrySumSupport" datasource="#request.dsn#">
		update	center_2110_load
		set		cum_cost_s =  cum_cost_s1 + cum_cost_s2,
				cum_conob_s = cum_conob_s1 + cum_conob_s2,
				cum_fund_s = cum_fund_s1 + cum_fund_s2,
				cum_valu_s = cum_valu_s1 + cum_valu_s2
		</cfquery>

		<!--- select all records from CENTER_2110_LOAD --->
		<cfquery name="qryGet2110Load" datasource="#request.dsn#">
		select	aapp_number, rep_date,
				MAX (last_mod_num) AS last_mod_num,
           		SUM(curr_slots) curr_slots, SUM(plan_sy_cytd) plan_sy_cytd, SUM(actl_sy_cytd) actl_sy_cytd,
				SUM(curyr_bud_a) curyr_bud_a,   SUM(plan_cytd_a) plan_cytd_a,   SUM(actl_cytd_a) actl_cytd_a,
				SUM(curyr_bud_c1) curyr_bud_c1, SUM(plan_cytd_c1) plan_cytd_c1, SUM(actl_cytd_c1) actl_cytd_c1,
				SUM(curyr_bud_c2) curyr_bud_c2, SUM(plan_cytd_c2) plan_cytd_c2, SUM(actl_cytd_c2) actl_cytd_c2,
				SUM(unvchr_reim_exp) unvchr_reim_exp, SUM(unvchr_acct_pay) unvchr_acct_pay,
				SUM(arrv_cur_yr) arrv_cur_yr, SUM(grad_cur_yr) grad_cur_yr, SUM(fes_cur_yr) fes_cur_yr,
				SUM(cum_cost_a) cum_cost_a,   SUM(cum_conob_a) cum_conob_a,   SUM(cum_fund_a) cum_fund_a,   SUM(cum_valu_a) cum_valu_a,
				SUM(cum_cost_b1) cum_cost_b1, SUM(cum_conob_b1) cum_conob_b1, SUM(cum_fund_b1) cum_fund_b1, SUM(cum_valu_b1) cum_valu_b1,
				SUM(cum_cost_b2) cum_cost_b2, SUM(cum_conob_b2) cum_conob_b2, SUM(cum_fund_b2) cum_fund_b2, SUM(cum_valu_b2) cum_valu_b2,
				SUM(cum_cost_b3) cum_cost_b3, SUM(cum_conob_b3) cum_conob_b3, SUM(cum_fund_b3) cum_fund_b3, SUM(cum_valu_b3) cum_valu_b3,
				SUM(cum_cost_b4) cum_cost_b4, SUM(cum_conob_b4) cum_conob_b4, SUM(cum_fund_b4) cum_fund_b4, SUM(cum_valu_b4) cum_valu_b4,
				SUM(cum_cost_d) cum_cost_d,   SUM(cum_conob_d) cum_conob_d,   SUM(cum_fund_d) cum_fund_d,   SUM(cum_valu_d) cum_valu_d,
				SUM(cum_cost_c1) cum_cost_c1, SUM(cum_conob_c1) cum_conob_c1, SUM(cum_fund_c1) cum_fund_c1, SUM(cum_valu_c1) cum_valu_c1,
				SUM(cum_cost_c2) cum_cost_c2, SUM(cum_conob_c2) cum_conob_c2, SUM(cum_fund_c2) cum_fund_c2, SUM(cum_valu_c2) cum_valu_c2,
				SUM(cum_cost_s) cum_cost_s,   SUM(cum_conob_s) cum_conob_s,   SUM(cum_fund_s) cum_fund_s,   SUM(cum_valu_s) cum_valu_s,
				SUM(cum_cost_tot) cum_cost_tot, SUM(cum_conob_tot) cum_conob_tot, SUM(cum_fund_tot) cum_fund_tot, SUM(cum_valu_to) cum_valu_to
		from	CENTER_2110_LOAD
		group	by aapp_number, rep_date
		order	by aapp_number, rep_date
		</cfquery>

		<!--- get record count from CENTER_2110_LOAD --->
		<cfquery name="qryGet2110LoadCount" datasource="#request.dsn#">
		select	count(aapp_number) as numRecs
		from 	center_2110_load
		</cfquery>

		<cfset recsProcessed = 0>

		<!--- loop through CENTER_2110_LOAD data --->
		<cfloop query="qryGet2110Load">

			<cfif datecompare(rep_date, cutOffDate) eq 1> <!--- if reporting date is later than 12/31/2006 --->

				<cfset recsProcessed = recsProcessed + 1>

				<!--- check for matching AAPP, reporting date in CENTER_2110_DATA --->
				<cfquery name="checkfor2110" datasource="#request.dsn#">
				select	center_2110_id
				from	center_2110_data
				where	aapp_num = #aapp_number# and
						to_char(rep_date, 'mm/dd/yyyy') = '#dateformat(rep_date,"mm/dd/yyyy")#'
				</cfquery>

				<!--- found existing report for this AAPP/Date - then delete data from CENTER_2110_DATA and CENTER_2110_AMOUNT --->
				<cfif checkfor2110.recordcount gt 0>
					<cfquery name="qryDelete2110Amount" datasource="#request.dsn#">
					delete
					from	center_2110_amount
					where	center_2110_id = #checkfor2110.center_2110_id#
					</cfquery>
					<cfquery name="qryDelete2110Data" datasource="#request.dsn#">
					delete
					from	center_2110_data
					where	center_2110_id = #checkfor2110.center_2110_id#
					</cfquery>
				</cfif>

				<!--- get new 2210_id sequence val --->
				<cfquery name="qryGet2110ID" datasource="#request.dsn#">
				select	seq_center_2100_data.NEXTVAL as new_2110_id
				from	dual
				</cfquery>

				<!--- Insert new rows in CENTER_2110_DATA --->
				<cfquery name="qryInsert2110Data" datasource="#request.dsn#">
				insert into	center_2110_data (
							center_2110_id, aapp_num,
							rep_date, mod_num,
							curr_slots, plan_sy_cytd, actl_sy_cytd,
							arrv_cur_yr, grad_cur_yr, fes_cur_yr,
							unvchr_reim_exp, unvchr_acct_pay,
							cum_cost_tot, cum_conob_tot, cum_fund_tot,
							cum_valu_to, update_user_id, update_function,
							update_time)
				values (
							#qryGet2110ID.new_2110_id#, #aapp_number#,
							'#dateFormat(rep_date, "dd-mmm-yyyy")#', #last_mod_num#,
							#curr_slots#, #plan_sy_cytd#, #actl_sy_cytd#,
							#arrv_cur_yr#, #grad_cur_yr#, #fes_cur_yr#,
							#unvchr_reim_exp#, #unvchr_acct_pay#,
							#cum_cost_tot#, #cum_conob_tot#, #cum_fund_tot#,
							#cum_valu_to#, '#session.userID#', 'I', sysdate)
				</cfquery>

				<!--- loop through columns in load_column, insert amounts --->
				<cfloop query="qryGet2110Types">

					<cfset inAmount = Evaluate("qryGet2110Load.#load_column#")>
					<cfquery name="qryInsert2110Amount" datasource="#request.dsn#">
					insert	into center_2110_amount (
							center_2110_id, type_id,
							cost_cat_id, amount,
							update_user_id, update_function, update_time)
					values	(
							#qryGet2110ID.new_2110_id#, #type_id#,
							#cost_cat_id#, #inAmount#,
							'#session.userID#', 'I', sysdate)
					</cfquery>

				</cfloop> <!---loop through money type, cost cat --->

			</cfif> <!--- reporting date is later than 12/31/2006 --->

		</cfloop> <!--- end loop through CENTER_2110_LOAD records --->

		<!--- truncate CENTER_2110_LOAD --->
		<cfquery name="qryTrunc2110Load" datasource="#request.dsn#">
		delete
		from	center_2110_load
		</cfquery>

		</cftransaction>

		<!--- audit record --->
		<cfset application.outility.insertSystemAudit (
		sectionID="2000",
		description="Center 2110 Data Imported",
		userID="#session.userID#")>

		<cfset result.records = recsProcessed>
		<cfset result.recordsRaw = qryGet2110LoadCount.numRecs>
		<cfset result.status = 1>

		<cfreturn result>
	</cffunction>



	<!--- function for inserting Vehicle data --->
	<cffunction name="insertVehicle" returntype="struct" output="false" hint="Validate Vehicle Data">
		<cfset result = structNew()>
		<!--- insert data and get total records from Vehicle actual table --->
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_data_pkg.jfas_Vehicle_insert_pc">
			<cfprocparam cfsqltype="CF_SQL_varchar" type="in" variable="userID" value="#session.userID#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="out" variable="rsRecords">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="out" variable="rsStatus">
		</cfstoredproc>
		<cfset result.records = rsRecords>
		<cfset result.status = rsStatus>

		<cfreturn result>
	</cffunction>



	<!--- Function for inserting Adjustment Batch Data --->
	<cffunction name="insertAdjustment" access="public" returntype="struct" hint="Insert Adjusments and FOPs">
		<cfset result = structNew()>
		<!--- Insert data and get recordcount --->
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_data_pkg.jfas_adjust_insert_pc">
			<cfprocparam cfsqltype="CF_SQL_varchar" type="in" variable="userID" value="#session.userID#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="out" variable="rsRecords">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="out" variable="rsStatus">
			<cfprocresult resultset="1" name="rs1">
		</cfstoredproc>
		<cfset result.records = rsRecords>
		<cfset result.status = rsStatus>
		<cfset result.query = rs1>
		<cfreturn result>
	</cffunction>


	<!--- function for validation Transaction data --->
	<cffunction name="validateTransact" returntype="query" output="false" hint="Validate Transaction Data">
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_validate_pkg.jfas_transact_validation_pc">
				<cfprocresult name="validate_error">
		</cfstoredproc>
		<cfreturn validate_error>
	</cffunction>

	<!--- function for inserting Transaction data --->
	<cffunction name="insertTransact" returntype="struct" output="false" hint="Insert Transaction Data">
		<cfset result = structNew()>
		<!--- insert data and get total records from Vehicle actual table --->
		<cfstoredproc datasource="#request.dsn#" procedure="jfas_import_data_pkg.jfas_tran_upd_ins_pc">
			<cfprocparam cfsqltype="CF_SQL_varchar" type="in" variable="userID" value="#session.userID#">
			<cfprocparam cfsqltype="CF_SQL_varchar" type="in" variable="tabname" value="footprint_xactn_load">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="out" variable="rsRecords">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="out" variable="rsStatus">
		</cfstoredproc>
		<cfset result.records = rsRecords>
		<cfset result.status = rsStatus>

		<cfreturn result>
	</cffunction>

	<!--- function for import log --->
	<cffunction name="import_tracking" output="no" hint="Insert a record for tracking import event">
		<cfargument name="import_type"	type="string"	required="true"			   >
		<cfargument name="userID" 		type="string"	required="false" default="sys">
		<cfargument name="success" 		type="numeric"	required="true"			   >
		<cfargument name="errorType" 	type="string"	required="false" default="">
		<cfargument name="note" 		type="string"	required="false" default="">

		<cfquery datasource="#request.dsn#" name="insertImportLog">
			insert into IMPORT_LOG (
				IMPORT_ID,
				IMPORT_TYPE_CODE,
				DATE_IMPORT,
				USER_ID,
				SUCCESS,
				ERROR_TYPE,
				NOTE)
			values (
				seq_import_log_id.nextval,
				'#arguments.import_type#',
				sysdate,
				'#arguments.userID#',
				#arguments.success#,
				'#arguments.errorType#',
				'#left(arguments.note,4000)#'
			)
		</cfquery>
	</cffunction>

	<cffunction name="getImportHistory" output="no" hint="Get history of data imports, including error messages">
		<cfargument name="importType"	type="string"	required="false"	default="all">
		<cfargument name="maxRecords" 	type="numeric"	required="false"	default="">

		<cfquery name="getRecordCount" datasource="#request.dsn#">
		select	count(import_id) as totalRecords
		from	import_log
		where	1=1 <cfif arguments.importType neq "all">and import_log.import_type_code = '#arguments.importType#'</cfif>
		</cfquery>

		<cfif arguments.maxRecords eq "">
			<cfset arguments.maxRecords = getRecordCount.totalRecords>
		</cfif>

		<cfquery name="qryGetImportHistory" datasource="#request.dsn#" maxrows="#arguments.maxRecords#">
		select	import_id, import_log.import_type_code, date_import,
				user_id, success, error_type, note,
				import_type_desc, #getRecordCount.totalRecords# as totalRecords
		from	import_log, lu_import_type
		where	import_log.import_type_code = lu_import_type.import_type_code
				<cfif arguments.importType neq "all">and import_log.import_type_code = '#arguments.importType#'</cfif>
		order	by	date_import desc
		</cfquery>

		<cfreturn qryGetImportHistory>
	</cffunction>

	<!--- function for Footprint/Transaction Discrepancy Report --->
	<cffunction name="FootprintXactnDisc" returntype="query">
	<cfargument name="aapp" type="numeric" required="no" default="0">
		<cfstoredproc datasource="#request.dsn#" procedure="report.prc_get_footprint_xactn_rpt">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
				<cfprocresult name="rstFootprintXactn">
		</cfstoredproc>
		<cfreturn rstFootprintXactn>
	</cffunction>


	<cffunction name="cleanImportHistory" output="false" hint="Removes old dta from import tracking table">
		<cfargument name="importType"	type="string"	required="true">
		<cfargument name="monthsRetain"	type="numeric"	required="true">

		<cfset dateCutoff = dateAdd("m",0-arguments.monthsRetain,now())>

		<cfquery name="qryCleanImportHistory" datasource="#request.dsn#">
		delete
		from	import_log
		where	upper(import_type_code) = '#ucase(arguments.importType)#' and
				date_import < '#dateformat(dateCutoff,"dd-mmm-yyyy")#'
		</cfquery>

	</cffunction>

	<cffunction name="getDataImportParams" access="public" returntype="query" hint="Retrieve Data Import Parameters">
		<cfargument name="importType" type="string" required="yes">

		<cfquery name="qryGetDataImportParams" datasource="#request.dsn#">
		select	import_param.import_type importType,
				import_type_desc importTypeDesc,
				ftp_site ftpSite,
				ftp_remote_dir ftpRemoteDir,
				ftp_port ftpPort,
				ftps_type ftpsType,
				ftp_uid ftpuID,
				ftp_pwd ftpPWD,
				jfas_share_dir jfasShareDir,
				ftp_remote_file ftpRemoteFile,
				jfas_share_file jfasShareFile
		from	import_param, lu_import_type
		where	import_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.importType#"> and
				import_param.import_type = lu_import_type.import_type_code
		</cfquery>

		<cfreturn qryGetDataImportParams>
	</cffunction>

	<cffunction name="saveDataImportParams"	access="public" hint="Save Data IMport Parameters">
		<cfargument name="formData" type="struct" required="yes">
		<cfargument name="importType" type="string" required="yes">

		<cfset arguments.formData.txtFTPpwd = trim(arguments.formData.txtFTPpwd)>
		<cfif arguments.formData.txtFTPpwd neq "">
			<!--- user entered password, need to get encryption key, and encrpyt --->
			<cfset ncfmsKey = application.outility.getSystemSetting(systemSettingCode="ncfms_key")>
			<cfset tmpPWD = encrypt(arguments.formData.txtFTPpwd,ncfmsKey)>
		</cfif>

		<cfquery name="qrySaveDataImportParams" datasource="#request.dsn#">
		update	import_param
		set		ftp_site = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formData.txtFTPsite#">,
				ftp_remote_dir = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formData.txtFTPremoteDir#">,
				ftp_port = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formData.txtFTPport#">,
				ftps_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formData.txtFTPStype#">,
				ftp_uid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formData.txtFTPuid#">,
				<cfif trim(arguments.formData.txtFTPpwd) neq "">
					ftp_pwd = '#tmpPWD#',
				</cfif>
				ftp_remote_file = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formData.txtFTPRemoteFile#">,
				jfas_share_dir = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formData.txtJFASShareDir#">,
				jfas_share_file = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formData.txtJFASShareFile#">
		where	import_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.importType#">
		</cfquery>

		<!--- log update --->
		<cfset application.outility.insertSystemAudit (
			sectionID="1000",
			description="Data Import Parameters Updated (#arguments.importType#)",
			userID="#session.userID#")>

	</cffunction>

</cfcomponent>