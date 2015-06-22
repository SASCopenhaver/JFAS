<!---
page: fop_batch.cfc

description: component that handles all fop batch process

revisions:
2007-01-12	yjeng	Modify sort by function under getEstCostProfileSort, case non sensitive
2007-03-18	mstein	Added function getBatchProcessList for drop-down lists on admin main page
2007-04-02	yjeng	Add function saveNewPYBudget
2007-04-19	yjeng	Modify function saveCCCNewPYBudget add system_audit
2007-05-14	yjeng	In Phase 1.2, Add adjustment type 'OTHER' for LE, SP, BA, IA,
					Add status check for batch process
2013-05-09	mstein	Added function "ExeZeroSum_OtherFOP" to handle Misc batch process with no FOPs
--->
<cfcomponent displayname="fop_batch" hint="Component that contains all general fop batch process queries and functions">
	<cffunction name="getEstFop" access="public" returntype="query" hint="Get data for Estimate FOP Batch Process Screen">
		<cfargument name="py" type="numeric" required="yes" default="">
		<cfargument name="adj_type" type="string" required="no" default="">
		<cfif arguments.adj_type eq "OTHER">
			<cfstoredproc procedure="fop_batch.prc_getotherestfop" datasource="#request.dsn#">
				<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
				<cfprocresult name="qryEstFop">
			</cfstoredproc>
		<cfelse>
			<cfstoredproc procedure="fop_batch.prc_getestfop" datasource="#request.dsn#">
				<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
				<cfprocresult name="qryEstFop">
			</cfstoredproc>
		</cfif>
		<cfreturn qryEstFop>
	</cffunction>
	<cffunction name="getEstFopSort" access="public" returntype="query" hint="Get data for Estimate FOP Batch Process Screen with sort by">
		<cfargument name="py" type="numeric" required="yes" default="">
		<cfargument name="adj_type" type="string" required="no" default="">
		<cfargument name="sortby" type="string" required="no" default="aapp_num">
		<cfargument name="sortDir" type="string" required="no" default="asc">
		<cfset var varEstFopSort=this.getEstFop(#arguments.py#, #arguments.adj_type#)>
		<cfquery name="qryEstProSort" dbtype="query">
			select	*
			from	varEstFopSort
			where	cost_cat_code!='B4'
			union
			select	*
			from	varEstFopSort
			where	cost_cat_code='B4'
			and		amount!=0
			<cfif arguments.sortby neq "aapp_num">
			order by #arguments.sortby# #arguments.sortDir#, aapp_num asc, cost_cat_code asc
			<cfelse>
			order by #arguments.sortby# #arguments.sortDir#, center_name asc, cost_cat_code asc
			</cfif>
		</cfquery>
		<cfreturn qryEstProSort>
	</cffunction>
	<cffunction name="getEstFopTotal" access="public" returntype="query" hint="Get data for Estimate Fop Batch Process Screen Total">
		<cfargument name="py" type="numeric" required="yes" default="">
		<cfset var varEstFopSort=this.getEstFop(#arguments.py#)>
		<cfquery name="qryTotal" dbtype="query">
			select	cost_cat_code, sum(amount) as amount
			from	varEstFopSort
			group by cost_cat_code
			order by cost_cat_code
		</cfquery>
		<cfreturn qryTotal>
	</cffunction>	
	<cffunction name="getEstCostProfileTotalbyCategory" access="public" returntype="query" hint="Get data for Estimate Cost Profile Screen Total">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfargument name="contract_type_code" type="string" required="no" default="">
		<cfargument name="contract_year" type="numeric" required="no" default="0">
		<cfset var varEstProSort=this.getEstCostProfileGen(#arguments.aapp#,'#arguments.contract_type_code#')>
		<cfquery name="qryTotal" dbtype="query">
			select	contract_type_code, ctype_desc_short, sum(amount) as cumValue
			from	varEstProSort
			<cfif arguments.contract_year neq 0>
			where	contract_year<=#arguments.contract_year#
			</cfif>
			group by contract_type_code, ctype_desc_short
			order by contract_type_code
		</cfquery>
		<cfquery name="qryConYear" dbtype="query">
			select	contract_type_code, ctype_desc_short, sum(amount) as funds
			from	varEstProSort
			<cfif arguments.contract_year neq 0>
			where	contract_year=#arguments.contract_year#
			</cfif>
			group by contract_type_code, ctype_desc_short
			order by contract_type_code
		</cfquery>
		<cfset n=QueryAddColumn(qryTotal,"funds",listtoarray(valuelist(qryConYear.funds)))>
		<cfreturn qryTotal>
	</cffunction>	
	<cffunction name="getEstCostProfileSummary" access="public" returntype="query" hint="Get data for Estimate Cost Profile Summary Screen">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfstoredproc procedure="contract.prc_getestcostprofilesummary" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocresult name="qryEstProSumary">
		</cfstoredproc>
		<cfreturn qryEstProSumary>
	</cffunction>
	<cffunction name="getEstCostProfileWorkload" access="public" returntype="query" hint="Get data for Estimate Cost Profile Workload">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfargument name="contract_type_code" type="string" required="yes" default="">
		<cfargument name="NewCols" type="string" required="yes" default="">
		<cfargument name="qTotal" type="query" required="yes" default="">
		<cfloop index="idx" list="#arguments.NewCols#">
			<cfquery name="qryWorkloadData" datasource="#request.dsn#">
				select	a.contract_year, a.value, b.workload_type_code, b.workload_type_desc, b.sort_order
				from	aapp_workload a, lu_workload_type b
				where	a.aapp_num=#arguments.aapp#
				and		b.contract_type_code='#arguments.contract_type_code#'
				and		a.workload_type_code=b.workload_type_code
				and		a.workload_type_code='evaluate(idx)'
				order by a.contract_year, b.sort_order
			</cfquery>
			<cfset col=queryaddcolumn(arguments.qTotal,evaluate("idx"),listtoarray(valuelist(qryWorkloadData.value)))>
		</cfloop>
		<cfreturn arguments.qTotal>
	</cffunction>
	<cffunction name="getNewPYBudget" access="public" returntype="query" hint="Get data for New PY Budget">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfargument name="py" type="numeric" required="no" default="#evaluate(request.py+1)#">
		<cfstoredproc procedure="fop_batch.prc_getnewpybudget" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocresult name="qryNexttBg">
		</cfstoredproc>
		<cfreturn qryNexttBg>
	</cffunction>
	<cffunction name="saveNewPYBudget" access="public" hint="Save data for New PY Budget">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfargument name="cost_cat_id" type="numeric" required="yes" default="">
		<cfargument name="amount" type="numeric" required="yes" default="">
		<cfstoredproc procedure="fop_batch.prc_insnewpybudget" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_cost_cat_id" value="#arguments.cost_cat_id#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_amount" value="#arguments.amount#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="getCCCNewPYBudget" access="public" returntype="struct" hint="Get data for CCC New PY Budget">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="report.prc_get_fop_ccc_rpt" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocresult resultset="1" name="rs2">
			<cfprocresult resultset="2" name="rs3">
		</cfstoredproc>
		<cfquery name="rs1" datasource="#request.dsn#">
			select	program_year
			from	ccc_worksheet
			where	aapp_num=#arguments.aapp#
			union
			select	utility.fun_getcurrntprogram_year_ccc()+1
			from	dual
			order by program_year desc
		</cfquery>
		<cfset str.rs1=rs1>
		<cfset str.rs2=rs2>
		<cfset str.rs3=rs3>
		<cfreturn str>
	</cffunction>
	<cffunction name="saveCCCNewPYBudget" access="public" returntype="struct" hint="Save data for CCC New Program Year Budget Screen">
		<cfargument name="formData" type="struct" required="yes" default="">
		<cfset stcSaveResults.success=true>
		<cfset stcSaveResults.errorMessages="">
		<cfset stcSaveResults.aappNum=request.aapp>
				<cfquery datasource="#request.dsn#">
					delete	ccc_worksheet_data
					where	aapp_num=#arguments.formData.aapp#
					and		program_year=#arguments.formData.py_ccc#
				</cfquery>
				<cfquery datasource="#request.dsn#">
					delete	ccc_worksheet
					where	aapp_num=#arguments.formData.aapp#
					and		program_year=#arguments.formData.py_ccc#
				</cfquery>
				<cfif #arguments.formData.cboStatus# gt 0>
					<cfquery datasource="#request.dsn#">
						insert into	ccc_worksheet
						(aapp_num, program_year, worksheet_status_id,ccc_comment, update_user_id, update_function)
						values
						(#arguments.formData.aapp#,#arguments.formData.py_ccc#,#arguments.formData.cboStatus#,'#trim(arguments.formData.txtComments)#','#session.userid#','#request.auditVarInsert#')
					</cfquery>
					
					<cfloop collection="#arguments.formData#" item="key">  
						<cfif findnocase("rec_",key) and len(arguments.formData[key])>
							<!---As far as I know, you must specify ALL Oracle SP or Function parameters in aproper order. --->
							<cfstoredproc procedure="fop_batch.prc_ins_ccc_worksheet_data" datasource="#request.dsn#">
								<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#listgetat(key,2,"_")#">
								<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#listgetat(key,3,"_")#">
								<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_ccc_wscc_id" value="#listgetat(key,4,"_")#">
								<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_amount" value="#iif(len(arguments.formData[key]),rereplace(arguments.formData[key],"[,]","","all"),0)#">
								<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_column" value="#listgetat(key,5,"_")#">
								<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_update_user_id" value="#session.userid#">
								<cfprocparam cfsqltype="cf_sql_char" dbvarname="p_update_function" value="#request.auditVarInsert#">
							</cfstoredproc>
						</cfif>
					</cfloop>
					<cfquery datasource="#request.dsn#">
						INSERT INTO system_audit
						(audit_id,description,user_id)
						VALUES (seq_system_audit.NEXTVAL,
						'Program Year #arguments.formData.py_ccc# AAPP #arguments.formData.aapp# CCC Budget Worksheet updated',
						'#session.userid#')				
					</cfquery>	
				</cfif>
		<cfreturn stcSaveResults>
	</cffunction>
	<cffunction name="ExeDOLFOPBatch" access="public" hint="Execute DOL FOP Batch Process">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_ins_fops" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_user_id" value="#session.userid#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="UndoDOLFOPBatch" access="public" hint="Undo DOL FOP Batch Process">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_del_fops" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_user_id" value="#session.userid#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="FinDOLFOPBatch" access="public" hint="Finalize DOL FOP Batch Process">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_fin_fops" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_user_id" value="#session.userid#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="FOPBatchStatus" access="public" returntype="numeric" hint="FOP Batch Process Status">
		<cfargument name="py" type="numeric" required="yes">
		<cfargument name="type" type="string" required="no" default="DOLFOP">
		<cfquery name="qryStatus" datasource="#request.dsn#">
			select	status
			from	batch_process_log
			where	year = #arguments.py# 
			and		process_type = '#arguments.type#'
		</cfquery>
		<cfreturn iif(len(qryStatus.status),qryStatus.status,-1)>
	</cffunction>
	
	<cffunction name="checkFMSReport" access="public" returntype="query" hint="Get any AAPPs that require recent FMS reports for CTST, but don't have them">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_checkfmsreport_vst" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="2011">
			<cfprocresult name="qryFMSnotRecent">
		</cfstoredproc>
		<cfreturn qryFMSnotRecent>
	</cffunction>

	<cffunction name="CCCFOPBatchPreview" access="public" returntype="query" hint="Preview CCC FOP Batch Process">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_getcccfoppreview" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocresult name="rs1">
		</cfstoredproc>
		<cfreturn rs1>
	</cffunction>
	<cffunction name="getCCCEstFop" access="public" returntype="query" hint="Get data for CCC FOP Batch Process Step 2 Screen">
		<cfargument name="py" type="numeric" required="yes" default="">
		<cfstoredproc procedure="fop_batch.prc_getcccestfop" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocresult name="qryEstFop">
		</cfstoredproc>
		<cfreturn qryEstFop>
	</cffunction>
	<cffunction name="ExeCCCFOPBatch" access="public" hint="Execute CCC FOP Batch Process">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_ins_ccc_fops" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_user_id" value="#session.userid#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="UndoCCCFOPBatch" access="public" hint="Undo CCC FOP Batch Process">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_del_ccc_fops" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_user_id" value="#session.userid#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="FinCCCFOPBatch" access="public" hint="Finalize CCC FOP Batch Process">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_fin_ccc_fops" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_user_id" value="#session.userid#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="ExeOtherFOPBatch" access="public" hint="Execute DOL FOP Batch Process (for Misc AAPPs)">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_ins_other_fops" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_user_id" value="#session.userid#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="ExeZeroSum_OtherFOP" access="public" hint="Execute and Finalize Batch Process (for Misc AAPPs) - no FOPs generated">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_execfinal_other_nofops" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_user_id" value="#session.userid#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="UndoOtherFOPBatch" access="public" hint="Undo DOL FOP Batch Process">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_del_other_fops" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_user_id" value="#session.userid#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="FinOtherFOPBatch" access="public" hint="Finalize DOL FOP Batch Process">
		<cfargument name="py" type="numeric" required="yes">
		<cfstoredproc procedure="fop_batch.prc_fin_other_fops" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
			<cfprocparam cfsqltype="cf_sql_varchar" dbvarname="p_user_id" value="#session.userid#">
		</cfstoredproc>
	</cffunction>
	<cffunction name="getBatchProcessStatus" access="public" returntype="query" hint="Get status for Batch Process">
		<cfargument name="py" type="numeric" required="yes" default="">
		<cfargument name="adj_type" type="string" required="yes" default="OTHER">
		<cfquery name="qryBatchStatus" datasource="#request.dsn#">
			 select	status
			 from	batch_process_log
			 where	year=#arguments.py#
			 and	process_type='#arguments.adj_type#'
		</cfquery>
		<cfreturn qryBatchStatus>
	</cffunction>	
	<cffunction name="getBatchProcessList" access="public" returntype="query" hint="Returns list of PY Batch Process from Log">
		<cfargument name="py" type="numeric" required="no">
		<cfargument name="type" type="string" required="no">
		<cfargument name="status" type="numeric" required="no">
		<cfargument name="order" type="string" required="no" default="desc">
		
		<cfquery name="qryBatchProcessList" datasource="#request.dsn#">
		select	year as py,
				process_type as processType,
				user_id as userID,
				date_processed as dateProcessed,
				status
		from	batch_process_log
		where	year > 2006
			<cfif isDefined("arguments.py")>
				and year = #arguments.py#
			</cfif>
			<cfif isDefined("arguments.type")>
				and process_type = '#ucase(arguments.type)#'
			</cfif>
			<cfif isDefined("arguments.status")>
				and status = #arguments.status#
			</cfif>
		order	by year #arguments.order#		
		</cfquery>
		
		<cfreturn qryBatchProcessList>
	
	</cffunction>
</cfcomponent>