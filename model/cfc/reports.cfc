<!---
page: reports.cfc

description: Component that handles database calls for reports

revisions:
2007-07-12	mstein	adjusted getRptFootPrint_contractor so that if AAPP number is specified, all other criteria is ignored.
2007-08-07  abai	change program activity using short name
2007-08-30  abai    add new function getRptTransaction
2007-09-17  abai 	add new function getRptSmallbusiness
2007-10-16	rroser	truncate dateexecuted for comparison in FOP listing report
2007-10-17  abai    Add new column XACTN_code in function getRptTransaction() and correct smallbusiness report
2007-10-23  abai    Revised getRptSmallbusiness() funciton to allow the user not select smallbusines sub category.
2008-06-09	mstein	Revised getRptTransaction() to allow filtering by doc number
2009-03-19	mstein	Added ARRA to criteria in getFOPList
2010-01-04	mstein	Updated getRptSmallbusiness for NCFMS (point to FOOTPRINT_NCFMS table)
2010-01-06	mstein	Removed group by and added aapp criteria in footprint subquery for DOLAR$ footprint contractor report
2010-01-06	mstein	Added new NCFMS specific function for Footprint / Contractor Report
2014-10-23	mstein	Modified getFOPAllocation_Reconciliation to exclude CCCs from report
--->



<cfcomponent displayname="reports" hint="Component that contains all reports queries and functions">
	<cffunction name="getRptFiscalPlan" access="public" returntype="struct" hint="Get data for Fiscal Plan">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfstoredproc procedure="report.prc_get_fiscal_plan_rpt" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocresult resultset="1" name="rs1">
			<cfprocresult resultset="2" name="rs2">
			<cfprocresult resultset="3" name="rs3">
			<cfprocresult resultset="4" name="rs4">
		</cfstoredproc>
		<cfset str.rs1=rs1>
		<cfset str.rs2=rs2>
		<cfset str.rs3=rs3>
		<cfset str.rs4=rs4>
		<cfreturn str>
	</cffunction>

	<cffunction name="getRptEstCostProfile" access="public" returntype="query" hint="Get header for Estimat Cost Profile">
		<cfargument name="aapp" type="numeric" required="yes" default="">
		<cfstoredproc procedure="report.prc_get_est_cost_rpt" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
			<cfprocresult name="qryEstPro">
		</cfstoredproc>
		<cfreturn qryEstPro>
	</cffunction>

	<!--- get budget auth report data  --->
	<cffunction name="getRptBudgetAuth" returntype="query" hint="Get Budget Authority Report Data">
		<cfargument name="formData" required="yes" type="struct">

		<cfstoredproc procedure="report.prc_get_bud_auth_aapp_rpt" datasource="#request.dsn#">
			<cfprocparam cfsqltype="CF_SQL_CHAR" dbvarname="p_status" value="#arguments.formData.radStatus#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_fundofficenum" value="#arguments.formData.cboFundingOffice#">
			<cfprocresult name="qryGetBudgetAuthData">
		</cfstoredproc>

		<cfreturn qryGetBudgetAuthData>
	</cffunction>

	<!--- Get data on FOPs, either for list of all FOPs or for specific AAPP --->
	<cffunction name="getFopList" returntype="query" hint="Get FOP Listing">
		<cfargument name="formData" required="yes" type="struct">
		<cfquery name="qryGetFopList" datasource="#request.dsn#">
		select 	programyear,
				fopnum,
				aappnum,
				programactivity,
				PROGRAM_ACTIVITY_SHORT,
				fundingofficedesc,
				venue,
				centername,
				contractorname,
				contractnum,
				costcatcode,
				costcatcodegroup,
				dateexecuted,
				amount,
				datestart,
				dateend,
				fopdescription,
				contractstatusid,
				arra
		from	fop_dataset_view
		where 	1=1
			<cfif isDefined("arguments.formData.aapp")><!--- AAPP is only defined for listing by AAPP --->
				and aappnum = #arguments.formData.aapp#
			</cfif>
			<cfif isDefined("arguments.formData.cboFundingOffice") and arguments.formData.cboFundingOffice neq ''><!--- cboFundingOffice only defined for FOP Listing --->
				and fundingofficenum = #arguments.formData.cboFundingOffice#
			</cfif>
			<cfif isDefined("arguments.formData.radStatus")><!--- radStatus only defined for FOP listing --->
				<cfif arguments.formData.radstatus neq "all">
					and	contractstatusid = #arguments.formData.radstatus#
				</cfif>
			</cfif>
			<cfif isDefined("arguments.formData.radARRA")><!--- radARRA only defined for FOP listing --->
				and 2=2
				<cfif arguments.formData.radARRA eq "1">
					and	upper(arra) = 'Y'
				<cfelseif arguments.formData.radARRA eq "0">
					and	arra is null
				</cfif>
			</cfif>
			<cfif arguments.formData.cboPY neq "all"><!--- cboPY defined for both --->
				and	programyear = #arguments.formData.cboPY#
			</cfif>
			<cfif isDefined("arguments.formData.txtStartDate") and isDefined("arguments.formData.txtEndDate")><!--- dates only defined for FOP listing --->
				<cfif arguments.formData.txtStartDate neq '' and arguments.formData.txtEndDate neq ''>
					and trunc(dateexecuted, 'DDD') >= to_date('#arguments.formData.txtStartDate#', 'MM/DD/YYYY')
					and trunc(dateexecuted, 'DDD') <= to_date('#arguments.formData.txtEndDate#', 'MM/DD/YYYY')
				</cfif>
			</cfif>
		order	by <cfif isDefined("arguments.formData.aapp")>costcatcodegroup, </cfif>programyear, fopnum<!--- only order by costcatcodegroup if listing for AAPP --->
		</cfquery>
		<cfreturn qryGetFopList>
	</cffunction>

		<!--- get VST report data  --->
		<cffunction name="getVstRpt" returntype="query" hint="Get VST Report Data">
			<cfargument name="aapp" required="yes" type="numeric">
			<cfargument name="py" required="yes" type="numeric">

			<cfstoredproc procedure="report.prc_get_fop_vst_rpt" datasource="#request.dsn#">
				<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aapp#">
				<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_program_year" value="#arguments.py#">
				<cfprocresult name="qryVstRst">
			</cfstoredproc>
			<cfreturn qryVstRst>
		</cffunction>

	<!---add it on 02/08/2007: get funding office Budget Authority Requirements by funding office --->
	<cffunction name="getRptBudgetAuthFundingOffice" returntype="query" hint="get funding office Budget Authority Requirements data">
			<cfargument name="fundingOfficeNum" required="yes" type="numeric">

			<cfstoredproc procedure="report.prc_get_bar_fundingOff_rpt" datasource="#request.dsn#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_fundingofficeNo" value="#arguments.fundingOfficeNum#">
			<cfprocresult name="qryGetBudgetAuthFunding">
			</cfstoredproc>

			<cfreturn qryGetBudgetAuthFunding>
	</cffunction>

	<cffunction name="getRptFootPrint_contractor_dolars" returntype="query" hint="Get Footprint/Contractor report information (legacy - DOLAR$)">
		<cfargument name="formData" type="struct" required="yes">

		<cfquery datasource="#request.dsn#" name="qryGetfprint_contractor">
			SELECT a.aapp_num, aapp_program_activity (a.aapp_num,'S') AS prog_services,
				   a.venue, center_name, a.contract_num,
				   a.date_start AS datestart, y.dateend,
				   c.contractor_name, x.dt, x.COST, x.oblig, x.doc_num, x.fy,
			                   x.rcc, x.obj_class,
			                   x.unspent_balance, x.payment,
			                   x.unpaid_balance, x.ops_cra,
			                   x.py, x.last_oblig_py
			FROM aapp a, contractor c, center,
				 (SELECT y.aapp_num, MAX (y.date_end) AS dateend
				  FROM aapp_yearend y
				  GROUP BY y.aapp_num) y,
				 (SELECT   fp.aapp_num, fp.dt, fp.COST, fp.oblig, fp.doc_num, fp.fy,
			                  fp.rcc_org || fp.rcc_fund AS rcc, fp.obj_class,
			                  (fp.oblig - fp.COST) AS unspent_balance, fp.payment,
			                  (fp.oblig - fp.payment) AS unpaid_balance, r.ops_cra,
			                  r.approp_py AS py, r.last_oblig_py
			      FROM footprint fp, rcc_code r
			      WHERE fp.rcc_fund = r.rcc_fund
			              AND fp.rcc_org = r.rcc_org
			              AND fp.fy = r.fy
						  <cfif isDefined("arguments.formData.aapp") and arguments.formData.aapp neq "">
						  	  AND fp.aapp_num = #arguments.formData.aapp#
						  </cfif>
				  ) x
		     WHERE a.aapp_num = y.aapp_num (+)
			      	  AND a.contractor_id = c.contractor_id(+)
			      	  and a.aapp_num = x.aapp_num(+)
					  and a.center_id = center.center_id (+)
			      	 <!--- if AAPP was specified, then filter by that (and ignore all other criteria --->
					 <cfif isDefined("arguments.formData.aapp") and arguments.formData.aapp neq "">
						and a.aapp_num = #arguments.formData.aapp#
					 <cfelse> <!--- AAPP num not specified --->
					 	<cfif isDefined("arguments.formData.cboFundingOffice") and arguments.formData.cboFundingOffice neq "0">
						 	and a.funding_office_num = #arguments.formData.cboFundingOffice#
						</cfif>
						<cfif isDefined("arguments.formData.cboAgreementType") and arguments.formData.cboAgreementType neq "0">
						 	and a.agreement_type_code = '#arguments.formData.cboAgreementType#'
						</cfif>
						<!--- filter by status --->
						<cfif arguments.formData.radStatus eq 1>
							and a.contract_status_id = 1
						 <cfelseif arguments.formData.radStatus eq 0>
							and a.contract_status_id = 0
						 </cfif>
						<!--- check if start dates--->
						<cfif isDefined("arguments.formData.txtStartDate") and isDefined("arguments.formData.txtEndDate") and arguments.formData.txtStartDate neq "" and arguments.formData.txtEndDate neq "">
						    and a.date_start >= to_date('#arguments.formData.txtStartDate#', 'mm/dd/yyyy')
						    and a.date_start <= to_date('#arguments.formData.txtEndDate#', 'mm/dd/yyyy')
						<cfelseif isDefined("arguments.formData.txtStartDate") and arguments.formData.txtStartDate neq "">
							and a.date_start >= to_date('#arguments.formData.txtStartDate#', 'mm/dd/yyyy')
						<cfelseif isDefined("arguments.formData.txtEndDate") and arguments.formData.txtEndDate neq "">
							and a.date_start <= to_date('#arguments.formData.txtEndDate#', 'mm/dd/yyyy')
						</cfif>
						<!--- check end dates --->
						<cfif isDefined("arguments.formData.txtStartDate1") and isDefined("arguments.formData.txtEndDate1") and arguments.formData.txtStartDate1 neq "" and arguments.formData.txtEndDate1 neq "">
						    and y.dateend >= to_date('#arguments.formData.txtStartDate1#', 'mm/dd/yyyy')
						    and y.dateend <= to_date('#arguments.formData.txtEndDate1#', 'mm/dd/yyyy')
						<cfelseif isDefined("arguments.formData.txtStartDate1") and arguments.formData.txtStartDate1 neq "">
							and y.dateend >= to_date('#arguments.formData.txtStartDate1#', 'mm/dd/yyyy')
						<cfelseif isDefined("arguments.formData.txtEndDate1") and arguments.formData.txtEndDate1 neq "">
							and y.dateend <= to_date('#arguments.formData.txtEndDate1#', 'mm/dd/yyyy')
						</cfif>
					 </cfif>
			ORDER BY a.aapp_num, upper(x.ops_cra) DESC, x.fy, x.py, x.unpaid_balance
		</cfquery>

		<cfreturn qryGetfprint_contractor>
	</cffunction>

	<!--- added 2010-01-05 for NCFMS integration --->
	<cffunction name="getRptFootPrint_contractor_ncfms" returntype="query" hint="Get Footprint/Contractor report information (NCFMS)">
		<cfargument name="formData" type="struct" required="yes">

		<cfquery datasource="#request.dsn#" name="qryGetfprint_contractor">
			SELECT  a.aapp_num, aapp_program_activity (a.aapp_num,'S') AS prog_services,
				    a.venue, center_name, a.contract_num,
				    a.date_start AS datestart, y.dateend,
				    c.contractor_name,
					x.doc_type, x.doc_num, x.doc_fy,
					x.approp_fy, x.approp_py, x.approp_exp_py,
					x.fund_code, x.program_code,
					x.funding_office_num, x.fund_cat, x.latefee, x.arra,
					x.oblig, x.cost, x.payment, x.unspent_balance, x.unpaid_balance
			FROM aapp a, contractor c, center,
				 (SELECT y.aapp_num, MAX (y.date_end) AS dateend
				  FROM aapp_yearend y
				  GROUP BY y.aapp_num) y,
				 (SELECT	aapp_num, doc_type, doc_fy, doc_num,
				 			approp_fy, approp_py, approp_exp_py,
				 			funding_office_num, fund_cat,
							fund_code, program_code,
							CASE WHEN latefee_intrst_ind = 1 THEN 'Yes' END latefee,
          					CASE WHEN arra_ind = 1 THEN 'Yes' END arra,
							oblig, cost, payment,
							(oblig - cost) as unspent_balance,
							(oblig - payment) as unpaid_balance
			      FROM footprint_ncfms fpn
			      <cfif isDefined("arguments.formData.aapp") and arguments.formData.aapp neq "">
					  WHERE fpn.aapp_num = #arguments.formData.aapp#
				  </cfif>
				  )x
		     WHERE	a.aapp_num = y.aapp_num (+)
			      	AND a.contractor_id = c.contractor_id(+)
			      	and a.aapp_num = x.aapp_num(+)
					and a.center_id = center.center_id (+)
			      	<!--- if AAPP was specified, then filter by that (and ignore all other criteria --->
					<cfif isDefined("arguments.formData.aapp") and arguments.formData.aapp neq "">
						and a.aapp_num = #arguments.formData.aapp#
					<cfelse> <!--- AAPP num not specified --->
						<cfif isDefined("arguments.formData.cboFundingOffice") and arguments.formData.cboFundingOffice neq "0">
							and a.funding_office_num = #arguments.formData.cboFundingOffice#
						</cfif>
						<cfif isDefined("arguments.formData.cboAgreementType") and arguments.formData.cboAgreementType neq "0">
							and a.agreement_type_code = '#arguments.formData.cboAgreementType#'
						</cfif>
						<!--- filter by status --->
						<cfif arguments.formData.radStatus eq 1>
							and a.contract_status_id = 1
						 <cfelseif arguments.formData.radStatus eq 0>
							and a.contract_status_id = 0
						 </cfif>
						<!--- check if start dates--->
						<cfif isDefined("arguments.formData.txtStartDate") and isDefined("arguments.formData.txtEndDate") and arguments.formData.txtStartDate neq "" and arguments.formData.txtEndDate neq "">
							and a.date_start >= to_date('#arguments.formData.txtStartDate#', 'mm/dd/yyyy')
							and a.date_start <= to_date('#arguments.formData.txtEndDate#', 'mm/dd/yyyy')
						<cfelseif isDefined("arguments.formData.txtStartDate") and arguments.formData.txtStartDate neq "">
							and a.date_start >= to_date('#arguments.formData.txtStartDate#', 'mm/dd/yyyy')
						<cfelseif isDefined("arguments.formData.txtEndDate") and arguments.formData.txtEndDate neq "">
							and a.date_start <= to_date('#arguments.formData.txtEndDate#', 'mm/dd/yyyy')
						</cfif>
						<!--- check end dates --->
						<cfif isDefined("arguments.formData.txtStartDate1") and isDefined("arguments.formData.txtEndDate1") and arguments.formData.txtStartDate1 neq "" and arguments.formData.txtEndDate1 neq "">
							and y.dateend >= to_date('#arguments.formData.txtStartDate1#', 'mm/dd/yyyy')
							and y.dateend <= to_date('#arguments.formData.txtEndDate1#', 'mm/dd/yyyy')
						<cfelseif isDefined("arguments.formData.txtStartDate1") and arguments.formData.txtStartDate1 neq "">
							and y.dateend >= to_date('#arguments.formData.txtStartDate1#', 'mm/dd/yyyy')
						<cfelseif isDefined("arguments.formData.txtEndDate1") and arguments.formData.txtEndDate1 neq "">
							and y.dateend <= to_date('#arguments.formData.txtEndDate1#', 'mm/dd/yyyy')
						</cfif>
					 </cfif> <!--- aapp num specified? --->
			ORDER BY a.aapp_num, upper(x.fund_cat) DESC, x.approp_fy, x.approp_py, x.unpaid_balance
		</cfquery>

		<cfreturn qryGetfprint_contractor>
	</cffunction>

	<!--- Add it on 02/26/2007: get CCC BA Transfer Requirements report info --->
	<cffunction name="getRptCCCBaTransfer" access="public" returntype="struct" hint="Get data for CCC transfer">
		<cfargument name="fundingOfficeNum" type="numeric" required="yes" default="">

			<cfstoredproc procedure="report.prc_get_CCC_ba_tra_rpt" datasource="#request.dsn#">
				<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_fund_office_no" value="#arguments.fundingOfficeNum#">
				<cfprocresult resultset="1" name="rsCCCBA_OPS_1">
				<cfprocresult resultset="2" name="rsCCCBA_CRA_1">
			</cfstoredproc>
			<cfset str.rsCCCBA_OPS_1 = rsCCCBA_OPS_1>
			<cfset str.rsCCCBA_CRA_1 = rsCCCBA_CRA_1>

		<cfreturn str>
	</cffunction>

	<!--- add it on 03/02/2007: get AAPPs,centers for all FED type for Program Operating plan detail --->
	<cffunction name="getFED_AAPPS_centers" returntype="struct" hint="Get all AAPPs, Centers in FED funding office">
		<cfstoredproc procedure="report.prc_get_progop_detail_list_rpt" datasource="#request.dsn#">
			<!--- this in parameter is useless, but need a IN parameter to run package --->
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_in" type="IN" value="0">
			<cfprocresult resultset="1" name="rsprogop_detail_aapps">
			<cfprocresult resultset="2" name="rsprogop_detail_center">
		</cfstoredproc>

		<cfset str.rsprogop_detail_aapps = rsprogop_detail_aapps>
		<cfset str.rsprogop_detail_centers = rsprogop_detail_center>

		<cfreturn str>
	</cffunction>

	<!--- add it on 03/05/2007: Get Program Operating Plan Detail information --->
	<cffunction name="getRptProgop_detail" returntype="query" hint="Get Program Operating Plan Detail information">
		<cfargument name="formData" type="struct" required="yes">

		<cfif arguments.formData.cboAAPP neq 0>
			<cfset arguments.formData.cboAAPP = left(arguments.formData.cboAAPP,find("-", arguments.formData.cboAAPP)-1)>
		</cfif>
		<cfif arguments.formData.cboCenter neq 0>
			<cfset arguments.formData.cboCenter = left(arguments.formData.cboCenter,find("-", arguments.formData.cboCenter)-1)>
		</cfif>

		<cfstoredproc procedure="report.prc_get_progop_detail_data_rpt" datasource="#request.dsn#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="IN" dbvarname="p_py" Value="#arguments.formData.cboPY#">
			<cfprocparam cfsqltype="cf_sql_integer" type="IN" dbvarname="p_aapp" value="#arguments.formData.cboAAPP#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="IN" dbvarname="p_center" value="#arguments.formData.cboCenter#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="IN" dbvarname="p_fundofficenum" value="#arguments.formData.cboFundingOffice#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="IN" dbvarname="p_dol_region" value="#arguments.formData.cboDolRegion#">

			<cfprocresult name="rsprogop_detail">
		</cfstoredproc>

		<cfreturn rsprogop_detail>
	</cffunction>

	<!--- add it on 03/13/2007 --->
	<cffunction name="getRptFOP_ccc_budget" returntype="query" hint="Get FOP CCC Budget information">
		<cfargument name="formData" type="struct" required="yes">

		<cfif arguments.formData.cboAAPP neq 0>
			<cfset arguments.formData.cboAAPP = left(arguments.formData.cboAAPP,find("-", arguments.formData.cboAAPP)-1)>
		</cfif>
		<cfif arguments.formData.cboCenter neq 0>
			<cfset arguments.formData.cboCenter = left(arguments.formData.cboCenter,find("-", arguments.formData.cboCenter)-1)>
		</cfif>

		<cfstoredproc procedure="report.prc_get_fop_ccc_bud_rpt" datasource="#request.dsn#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="IN" dbvarname="p_py" Value="#arguments.formData.cboPY#">
			<cfprocparam cfsqltype="cf_sql_integer" type="IN" dbvarname="p_aapp" value="#arguments.formData.cboAAPP#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="IN" dbvarname="p_center" value="#arguments.formData.cboCenter#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="IN" dbvarname="p_fundofficenum" value="#arguments.formData.cboFundingOffice#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" type="IN" dbvarname="p_dol_region" value="#arguments.formData.cboDolRegion#">

			<cfprocresult name="rsFop_ccc_bud">
		</cfstoredproc>

		<cfreturn rsFop_ccc_bud>
	</cffunction>
	<!--- add it on 03/19/2007: Get Program Year list and worksheet data for Program Year Initial CCC Budget--->
	<cffunction name="getCCC_py_worksheet_PyList" returntype="query" hint="Get Distinct Program year Initial CCC budget PY List">
		<cfquery name="qryGetCCC_PY_worksheet_PY" datasource="#request.dsn#">
			select distinct PROGRAM_YEAR as PY
			from CCC_WORKSHEET_DATA
			order by PROGRAM_YEAR desc
		</cfquery>
		<cfreturn qryGetCCC_PY_worksheet_PY>
	</cffunction>
	<cffunction name="getRptPY_ccc_worksheet" returntype="struct" hint="Get Program Year Initial CCC Budget data">
		<cfargument name="formData" type="struct">
		<cfstoredproc procedure="report.prc_get_ccc_py_worksheet_rpt" datasource="#request.dsn#">
			<!--- this in parameter is useless, but need a IN parameter to run package --->
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_fundingofficenum" type="IN" value="#arguments.formData.cboFundingOffice#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_py" type="IN" value="#arguments.formData.cboPY#">
			<cfprocresult resultset="1" name="rsCCC_py_worksheet">
			<cfprocresult resultset="2" name="rsCCC_Percent">
		</cfstoredproc>
		<cfset str.rsCCC_py_worksheet = rsCCC_py_worksheet>
		<cfset str.rsCCC_Percent = rsCCC_Percent>

		<cfreturn str>
	</cffunction>

	<!--- Add it on 05/16/2007 --->
	<cffunction name="getRptBudgetStatus" returntype="query" hint="Get data fpr Budget Status report">
		<cfargument name="fundingOfficeNum" type="numeric" required="yes">

		<cfstoredproc datasource="#request.dsn#" procedure="report.prc_get_budget_status_rpt">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="p_fundingofficenum" value="#arguments.fundingOfficeNum#">
			<cfprocresult name="rsBudgetStatus">
		</cfstoredproc>

		<cfreturn rsBudgetStatus>
	</cffunction>
	<cffunction name="getRptOa_cts_annualized_cost" returntype="query" hint="Get data for Job Corps OA/CTS Annualized Workload/Cost">
		<cfargument name="fundingOfficeNum" type="numeric" required="yes">
		<cfargument name="date_asof" type="date" required="yes">

		<cfstoredproc datasource="#request.dsn#" procedure="report.prc_get_oa_cts_annualized_rpt">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="p_fundingofficenum" value="#arguments.fundingOfficeNum#">
			<cfprocparam cfsqltype="CF_SQL_DATE" variable="p_date_asof" value="#dateFormat(arguments.date_asof, 'mm/dd/yyyy')#">
			<cfprocresult name="rs_oa_cts_annualized_cost">
		</cfstoredproc>

		<cfreturn rs_oa_cts_annualized_cost>
	</cffunction>

	<!--- Transaction --->
	<cffunction name="getRptTransaction_dolars" returntype="query" hint="Get Transaction data (from DOLAR$ data)">
		<cfargument name="formData" required="true" type="struct">

		<!--- <cfstoredproc datasource="#request.dsn#" procedure="report.prc_get_transaction_rpt">
			<cfprocparam cfsqltype="CF_SQL_CHAR" variable="p_report_type" value="#arguments.formData.hidReportType#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="p_aapp" value="#arguments.formData.aapp#">
			<cfprocresult name="rsTransaction">
		</cfstoredproc> --->

		<cfquery datasource="#request.dsn#" name="qryTransaction">
			select f.DATE_XACTN as trans_date, f.dt||f.doc_num||f.fy||f.rcc_org||f.rcc_fund||f.OBJ_CLASS as footp,
    		       f.AMOUNT, f.EIN, f.VENDOR,f.INVOICE_NUM, r.ops_cra as ops_cra, f.XACTN_code
    		from FOOTPRINT_XACTN f,
    		     (select XACTN_CODE from XACTN_CODE_TYPE where XACTN_TYPE = '#arguments.formData.hidReportType#') x,
                 (select  f.fy, f.rcc_org, f.rcc_fund, f.dt, f.doc_num, f.OBJ_CLASS, r.OPS_CRA
            		from footprint f, rcc_code r
            		where aapp_num = #arguments.formData.aapp# and
            		      f.RCC_FUND = r.RCC_FUND and
            		      f.RCC_ORG = r.RCC_ORG and
            		      f.fy = r.FY
            		order by f.fy, f.rcc_org, f.rcc_fund, f.dt, f.doc_num, f.OBJ_CLASS) r
    		where f.fy = r.fy and
    		      f.RCC_FUND = r.rcc_fund and
    		      f.rcc_org = r.rcc_org and
    		      f.dt = r.dt and
    		      f.doc_num = r.doc_num and
    		      f.obj_class = r.obj_class  and
    		      f.XACTN_code = x.XACTN_CODE
				<!--- check if start dates--->
				<cfif isDefined("arguments.formData.txtStartDate") and isDefined("arguments.formData.txtEndDate") and arguments.formData.txtStartDate neq "" and arguments.formData.txtEndDate neq "">
					    and (f.DATE_XACTN between to_date('#arguments.formData.txtStartDate#', 'mm/dd/yyyy')
					    	and to_date('#arguments.formData.txtEndDate#', 'mm/dd/yyyy'))
				<cfelseif isDefined("arguments.formData.txtStartDate") and arguments.formData.txtStartDate neq "">
					and f.DATE_XACTN >= to_date('#arguments.formData.txtStartDate#', 'mm/dd/yyyy')
				<cfelseif isDefined("arguments.formData.txtEndDate") and arguments.formData.txtEndDate neq "">
					and f.DATE_XACTN <= to_date('#arguments.formData.txtEndDate#', 'mm/dd/yyyy')
				</cfif>
				<!--- has document number been specified? --->
				<cfif isDefined("arguments.formData.txtDocNumber") and arguments.formData.txtDocNumber neq "">
					and upper(f.doc_num) = '#ucase(arguments.formData.txtDocNumber)#'
				</cfif>
    		order by 1,2
		</cfquery>

		<cfreturn qryTransaction>
	</cffunction>

	<cffunction name="getRptTransaction_ncfms" returntype="query" hint="Get Transaction data (from NCFMS data)">
		<cfargument name="formData" required="true" type="struct">

		<cfswitch expression="#arguments.formData.hidReportType#">
			<cfcase value="O">
				<cfset transColumn = "OBLIG">
			</cfcase>
			<cfcase value="P">
				<cfset transColumn = "PAYMENT">
			</cfcase>
			<cfdefaultcase>
				<cfset transColumn = "COST">
			</cfdefaultcase>
		</cfswitch>

		<cfquery datasource="#request.dsn#" name="qryTransaction">
		select	fxn.creation_date as trans_date,
				fxn.doc_type,
				fxn.fy as doc_fy,
				fxn.doc_num,
				fxn.account_id,
				fxn.cost_center_code as cost_center,
				fxn.xactn_type,
				fxn.vendor_duns,
				fxn.invoice_num,
				fxn.amount,
				fxn.fund_cat
		from	footprint_xactn_ncfms fxn, footprint_ncfms fn, lu_xactn_type_ncfms luxt
		where	fxn.footprint_id = fn.footprint_id and
				fxn.fund_cat in ('OPS','CRA') and
				fxn.xactn_type = luxt.xactn_type and
				luxt.#transColumn# = 1 and
				fn.aapp_num = #arguments.formData.aapp#

				<!--- if user specified start and/or end dates--->
				<cfif isDefined("arguments.formData.txtStartDate") and isDefined("arguments.formData.txtEndDate") and arguments.formData.txtStartDate neq "" and arguments.formData.txtEndDate neq "">
					    and (fxn.creation_date between to_date('#arguments.formData.txtStartDate#', 'mm/dd/yyyy')
					    	and to_date('#arguments.formData.txtEndDate#', 'mm/dd/yyyy'))
				<cfelseif isDefined("arguments.formData.txtStartDate") and arguments.formData.txtStartDate neq "">
					and fxn.creation_date >= to_date('#arguments.formData.txtStartDate#', 'mm/dd/yyyy')
				<cfelseif isDefined("arguments.formData.txtEndDate") and arguments.formData.txtEndDate neq "">
					and fxn.creation_date <= to_date('#arguments.formData.txtEndDate#', 'mm/dd/yyyy')
				</cfif>
				<!--- has document number been specified? --->
				<cfif isDefined("arguments.formData.txtDocNumber") and arguments.formData.txtDocNumber neq "">
					and upper(fxn.doc_num) = '#ucase(arguments.formData.txtDocNumber)#'
				</cfif>
    		order by trans_date, fxn.doc_type, fxn.doc_num
		</cfquery>

		<cfreturn qryTransaction>
	</cffunction>

	<!--- Small business --->
	<cffunction name="getRptSmallbusiness" access="public" returntype="query" hint="Get Small Business information">
		<cfargument name="formData" type="struct" required="true">
		<cfargument name="region" type="string" default="no">

		<cfif arguments.formData.cboOrgType eq "FPSMALL" and Not isDefined("arguments.formData.ckbSmallBusType")>
			<cfset arguments.formData.ckbSmallBusType = "">
		</cfif>

		<cfquery datasource="#request.dsn#" name="rs_smallbusiness_recordset">
			select distinct p.aapp_num, p.FUNDING_OFFICE_NUM, p.VENUE, p.ORG_TYPE_DESC,
		       p.DATE_START, p.CENTER_NAME, p.CONTRACTOR_NAME, p.CONTRACT_NUM, p.programActivity,
		       y.date_end,
		       tr.amount amount,
		       p.SMB_TYPE_Code
		       from
        		     (select distinct fn.aapp_num, sum(fxn.amount) amount
                      from  footprint_ncfms fn, footprint_xactn_ncfms fxn, lu_xactn_type_ncfms xn
                      where fxn.xactn_type = xn.xactn_type and
                            xn.oblig = 1 and
                            fxn.footprint_id = fn.footprint_id and
							fxn.creation_date between to_date('#arguments.formData.txtStartDate#',  'mm/dd/yyyy') and
												 to_date('#arguments.formData.txtEndDate#',  'mm/dd/yyyy') and
                            fn.AAPP_NUM is not null
                      group by fn.aapp_num
					 ) tr,


        		     (SELECT  distinct yr.aapp_num, MAX (yr.date_end) over (partition by yr.aapp_num order by yr.aapp_num) date_end
        		      FROM aapp_yearend yr
        		      ) y,

        		     (SELECT distinct a.aapp_num, a.date_start,a.FUNDING_OFFICE_NUM, a.ORG_SUBTYPE_CODE, a.ORG_TYPE_CODE, a.CONTRACT_NUM, a.VENUE,
							ce.CENTER_NAME, c.CONTRACTOR_NAME, o.ORG_TYPE_DESC,
        			    	aapp_program_activity(a.aapp_num, 'S') programActivity,
							<cfif isDefined("arguments.formData.cboOrgType") and arguments.formData.cboOrgType eq "FPSMALL"  and arguments.formData.ckbSmallBusType neq "">
							 (select get_smb_type(a.aapp_num, '#Rereplace(PreserveSingleQuotes(arguments.formData.ckbSmallBusType), "'", "''", "ALL")#')
						       from dual) SMB_TYPE_Code
							<cfelse>
							  	case when o.ORG_SUBTYPE_CODE = 'FPSMALL' then
							  	   		 (select get_smb_type(a.aapp_num, '')
						       			  from dual)
							  	     else
							  	       ''
							  	end SMB_TYPE_Code
							</cfif>
        		      FROM aapp a, contractor c,  center ce, LU_ORG_SUBTYPE o
						   <cfif isDefined("arguments.formData.cboOrgType") and (arguments.formData.cboOrgType eq "FPSMALL" or arguments.formData.cboOrgType eq "FP")>
							,AAPP_SMB_TYPE s
						   </cfif>
        		      where a.CENTER_ID = ce.CENTER_ID(+)
        			    and a.CONTRACTOR_ID = c.CONTRACTOR_ID (+)
        			    and a.ORG_SUBTYPE_CODE = o.ORG_SUBTYPE_CODE(+)
        			    and a.AGREEMENT_TYPE_CODE in (#PreserveSingleQuotes(arguments.formData.ckbAgreementType)#)
        		        <cfif isDefined("arguments.formData.cboOrgType") and (arguments.formData.cboOrgType eq "FPSMALL" or arguments.formData.cboOrgType eq "FP")>
							<cfif arguments.formData.cboOrgType eq "FPSMALL"  and arguments.formData.ckbSmallBusType neq "">
								and a.ORG_SUBTYPE_CODE = '#arguments.formData.cboOrgType#'
								and a.aapp_num = s.aapp_num(+)
								and (s.SMB_TYPE_CODE in (#PreserveSingleQuotes(arguments.formData.ckbSmallBusType)#)

								<cfif arguments.formData.cboOrgType eq "FPSMALL" and Find("other", arguments.formData.ckbSmallBusType) gt 0>
									or a.aapp_num not in (select aapp_num from AAPP_SMB_TYPE)
								</cfif>)
							<cfelse>
								<cfif isDefined("arguments.formData.cboOrgType") and arguments.formData.cboOrgType eq "FPSMALL">
								and a.ORG_SUBTYPE_CODE = '#arguments.formData.cboOrgType#'
								<cfelse>
								and a.ORG_TYPE_CODE = '#arguments.formData.cboOrgType#'
								</cfif>
								and a.aapp_num = s.aapp_num(+)
							</cfif>
        			    <cfelseif arguments.formData.cboOrgType neq "">
							<cfif arguments.formData.cboOrgType eq "GOV" or arguments.formData.cboOrgType eq "NP" or arguments.formData.cboOrgType eq "FP">
								and (a.ORG_TYPE_CODE = '#arguments.formData.cboOrgType#')
							<cfelse>
								and (a.ORG_SUBTYPE_CODE = '#arguments.formData.cboOrgType#')
							</cfif>
						</cfif>
						<cfif isDefined("arguments.region") and arguments.region eq "yes">
							and a.FUNDING_OFFICE_NUM <= 6
						</cfif>

        		     ) p
        		where
        		      p.AAPP_NUM = y.AAPP_NUM(+) and
        		      p.aapp_num = tr.aapp_num(+)
					<cfif isDefined("arguments.formData.txtEndDate") and arguments.formData.txtEndDate neq "">
					  and (p.date_start <= to_date('#arguments.formData.txtEndDate#',  'mm/dd/yyyy') or  p.date_start  is null)
					</cfif>
					<cfif isDefined("arguments.formData.txtStartDate") and arguments.formData.txtStartDate neq "">
					  and (y.DATE_END >= to_date('#arguments.formData.txtStartDate#', 'mm/dd/yyyy') or y.DATE_END is null)
				    </cfif>

				order by  p.ORG_TYPE_DESC,p.CONTRACTOR_NAME, p.aapp_num
		</cfquery>

		<cfreturn rs_smallbusiness_recordset>
	</cffunction>

	<!--- Outyear report query --->
	<cffunction name="getOutyearRpt" returntype="query" access="public">
		<cfargument name="costCat" type="string" required="yes">
		<cfargument name="fundingOfficeNum" type="numeric" required="no" default="0">

		<cfstoredproc datasource="#request.dsn#" procedure="report.prc_get_outyear_rpt">
			<cfprocparam cfsqltype="cf_sql_varchar" variable="p_serv_type" value="#arguments.costCat#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="p_fund_off" value="#arguments.fundingOfficeNum#">
			<cfprocresult name="qryGetOutyearRpt">
		</cfstoredproc>

		<cfreturn qryGetOutyearRpt>
	</cffunction>

	<!--- Workload Change List report query --->
	<cffunction name="getWorkloadChangeList" returntype="query" access="public">
		<cfargument name="fundingOfficeNum" type="string" required="yes">
		<cfargument name="lstWorkloadTypes" type="string" required="yes">

		<cfquery name="rstWorkloadChange" datasource="#request.dsn#">
		select a.funding_office_num fundingOfficeNum,
            a.aapp_num aappNum,
            aapp_program_activity(a.aapp_num,'S') programActivity,
            --aapp_contract_types(a.aapp_num) contractTypes,
            venue,
            center_name centerName,
            date_start as dateStart,
           (SELECT MAX (ye.date_end)
             FROM aapp_yearend ye
             WHERE ye.aapp_num = a.aapp_num) AS dateEnd,
            contract_year contractYear,
            (select value from aapp_workload where
                aapp_num = a.aapp_num and
                workload_type_code = 'SL' and
                contract_year = y.contract_year) as slots,
            (select value from aapp_workload where
                aapp_num = a.aapp_num and
                workload_type_code = 'AR' and
                contract_year = y.contract_year) as arrivals,
            (select value from aapp_workload where
                aapp_num = a.aapp_num and
                workload_type_code = 'GR' and
                contract_year = y.contract_year) as grads,
            (select value from aapp_workload where
                aapp_num = a.aapp_num and
                workload_type_code = 'FE' and
                contract_year = y.contract_year) as enrollees
        from aapp a, center c, aapp_yearend y
        where a.center_id = c.center_id(+) and
              a.contract_status_id = 1 and
              a.aapp_num = y.aapp_num and
              a.aapp_num in
              (select a1.aapp_num
              from aapp a1, aapp_yearend ay1,
                (select aapp_num,
                    (select avg(value)
                    from aapp_workload
                    where aapp_num = a1.aapp_num
                         and workload_type_code = 'SL') as slots_average,
                    (select avg(value)
                    from aapp_workload
                    where aapp_num = a1.aapp_num
                         and workload_type_code = 'AR') as arrivals_average,
                    (select avg(value)
                    from aapp_workload
                    where aapp_num = a1.aapp_num
                         and workload_type_code = 'GR') as grads_average,
                    (select avg(value)
                    from aapp_workload
                    where aapp_num = a1.aapp_num
                         and workload_type_code = 'FE') as enrollees_average
                    from aapp a1) ay_avg
                    where a1.aapp_num = ay1.aapp_num  and
                    a1.aapp_num = ay_avg.aapp_num and
                        (1=2
                          <cfif listFindnoCase(arguments.lstWorkloadTypes, "SL")>
							  or
							  slots_average <> (select value from aapp_workload where
												aapp_num = a1.aapp_num and
													workload_type_code = 'SL' and
												contract_year = ay1.contract_year)
                          </cfif>
						  <cfif listFindnoCase(arguments.lstWorkloadTypes, "AR")>
							  or
							  arrivals_average <> (select value from aapp_workload where
												aapp_num = a1.aapp_num and
													workload_type_code = 'AR' and
												contract_year = ay1.contract_year)
                          </cfif>
						  <cfif listFindnoCase(arguments.lstWorkloadTypes, "GR")>
							  or
							  grads_average <> (select value from aapp_workload where
												aapp_num = a1.aapp_num and
													workload_type_code = 'GR' and
												contract_year = ay1.contract_year)
                          </cfif>
						  <cfif listFindnoCase(arguments.lstWorkloadTypes, "FE")>
							  or
							  enrollees_average <> (select value from aapp_workload where
												aapp_num = a1.aapp_num and
													workload_type_code = 'FE' and
												contract_year = ay1.contract_year)

                          </cfif>
                          ))

			<cfif arguments.fundingOfficeNum neq "all">
				and a.funding_office_num = #arguments.fundingOfficeNum#
			</cfif>
        order by a.aapp_num, contract_year
		</cfquery>


		<cfreturn rstWorkloadChange>
	</cffunction>

	<cffunction name="getNCFMSFOP_Reconciliation" returntype="query" access="public">
		<cfargument name="py" type="numeric" required="yes">
		<cfargument name="fundingOfficeNum" type="string" required="no" default="all">
		<cfargument name="status" type="string" required="no" default="all">

		<cfquery name="qryNCFMSFOP_Reconciliation" datasource="#request.dsn#">
		select	aappSubQ.*,
				nvl(ncfmsSubQ.obligTotal,0) as obligTotal,
				nvl(fopSubQ.fopTotal,0) as fopTotal
		from
				(select aappNum, programActivity, venue, centerName, contractorName,
						contractNum, dateStart, dateEnd, fundingOfficeNum, contractStatusID, fund_cat, sort_order as fundSort
				 from	aapp_contract_snapshot, lu_fund_cat
				 where	fundingOfficeNum = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fundingOfficeNum#"> and
						fund_cat <> 'S/E'
						<cfif arguments.status neq "all">
							and contractStatusID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.status#">
						</cfif>) aappSubQ,
				(select	aapp_num, fund_cat, nvl(sum(oblig),0) as obligTotal
				 from	footprint_ncfms
				 where	funding_office_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fundingOfficeNum#"> and
						approp_py = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.py#">
				 group	by aapp_num, fund_cat) ncfmsSubQ,
		 		(select	aapp_num, fund_cat, nvl(sum(amount),0) as fopTotal
				 from	fop, lu_cost_cat lcc
				 where	py = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.py#"> and
						fop.cost_cat_id = lcc.cost_cat_id
				group	by aapp_num, fund_cat order by 1) fopSubQ
		 where	aappSubQ.aappNum = ncfmsSubQ.aapp_num (+) and
				aappSubQ.fund_cat = ncfmsSubQ.fund_cat (+) and
				aappSubQ.aappNum = fopSubQ.aapp_num (+) and
				aappSubQ.fund_cat = fopSubQ.fund_cat (+)
		order	by aappNum, fundsort
		</cfquery>

		<cfreturn qryNCFMSFOP_Reconciliation>
	</cffunction>

	<cffunction name="getFOPAllocation_Reconciliation" returntype="query" access="public">
		<cfargument name="py" type="numeric" required="yes">
		<cfargument name="status" type="string" required="no" default="all">
		<cfargument name="fundingOfficeNum" type="string" required="no" default="all">
		<cfargument name="condition" type="string" required="false" default="none">

		<!--- get current PY --->
		<cfset currentPY = application.outility.getCurrentSystemProgramYear()>
		<cfif arguments.py eq currentPY>
			<!--- if PY passed in is same as current PY, determine current quarter --->
			<cfset currentQtr = application.outility.getQuarter(yearType="PROG" )>

			<cfset qtr = currentQtr>
		<cfelse> <!--- otherwise qtr = 4 (use full year amount) --->
			<cfset qtr = 4>
		</cfif>

		<cfquery name="qryFOPAllocation_Reconciliation" datasource="#request.dsn#">
		select	aappSubQ.*,
                nvl(allocationSubQ.PYallocation,0) as PYallocation,
                nvl(fopSubQ.fopTotal,0) as fopTotal
        from
                (select aappNum, programActivity, venue, centerName, contractorName,
                        contractNum, dateStart, dateEnd, fundingOfficeNum, contractStatusID, fund_cat, sort_order as fundSort
                 from	aapp_contract_snapshot, lu_fund_cat
                 where  agreementTypeCode <> 'CC' and
                 		fund_cat <> 'S/E'
				 		 <cfif arguments.fundingOfficeNum neq "all">
						 	and fundingOfficeNum = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fundingOfficeNum#">
                        </cfif>
                        <cfif arguments.status neq "all">
							and contractStatusID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.status#">
						</cfif>) aappSubQ,
                (select		aapp_num, fund_cat, sum(amount) as PYallocation
                 from   	aapp_py_allocation
                 where  	py = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.py#"> AND
				 			qtr <= <cfqueryparam cfsqltype="cf_sql_integer" value="#qtr#">
                 			group by aapp_num, fund_cat
                 			) allocationSubQ,
                 (select	fop.aapp_num, fund_cat, nvl(sum(amount),0) as fopTotal
                 from		fop, lu_cost_cat lcc, aapp
                 where    	py = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.py#"> and
                        	fop.cost_cat_id = lcc.cost_cat_id and
                        	fop.aapp_num = aapp.aapp_num and
                        	aapp.agreement_type_code <> 'CC'
                 group		by fop.aapp_num, fund_cat order by 1
				 			) fopSubQ
         where	aappSubQ.aappNum = allocationSubQ.aapp_num (+) and
                aappSubQ.fund_cat = allocationSubQ.fund_cat (+) and
                aappSubQ.aappNum = fopSubQ.aapp_num (+) and
                aappSubQ.fund_cat = fopSubQ.fund_cat (+)
        order   by aappNum, fundsort
		</cfquery>

		<cfif arguments.condition eq "fop_gt_allocation">

			<!--- filter query above to return only records where FOPs exceed allocation --->
			<cfquery name="qryFOPAllocation_Reconciliation" dbtype="query">
			select	*
			from	qryFOPAllocation_Reconciliation
			where	fopTotal > PYallocation
			</cfquery>

		</cfif>

		<cfreturn qryFOPAllocation_Reconciliation>
	</cffunction>


	<cffunction name="getAllotAllocation_Recon_Nat" returntype="query" access="public">
		<cfargument name="py" type="numeric" required="yes">
		<cfargument name="fundingCat" type="string" required="yes">

        <cfstoredproc procedure="JFAS.OBLIG_ALLOC_RECON_PKG.sp_getObligAllocRecon" returncode="false">
            <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_PY"      value="#arguments.py#">
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_FundCat" value="#arguments.fundingCat#">
			<cfprocresult name="qryAllotAllocation_Recon_Nat" resultset="1">
       </cfstoredproc>

		<cfreturn qryAllotAllocation_Recon_Nat>
	</cffunction>


	<cffunction name="getNCFMSAllocation_Recon_AAPP" returntype="query" access="public">
		<cfargument name="py" type="numeric" required="yes">
		<cfargument name="fundingCat" type="string" required="yes">
		<cfargument name="fundingOfficeNum" type="string" required="yes">

		<cfstoredproc procedure="JFAS.OBLIG_ALLOC_RECON_PKG.sp_getObligAllocRecon_AAPP" returncode="false">
            <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_PY"      value="#arguments.py#">
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_FundCat" value="#arguments.fundingCat#">
            <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_FundingOfficeNum" value="#arguments.fundingOfficeNum#">
            <cfprocresult name="qryNCFMSAllocation_Recon_AAPP" resultset="1">
       </cfstoredproc>

		<cfreturn qryNCFMSAllocation_Recon_AAPP>
	</cffunction>



	<cffunction name="getWorkloadChangeList_old" returntype="query" access="public">
		<cfargument name="fundingOfficeNum" type="string" required="yes">

		<cfstoredproc datasource="#request.dsn#" procedure="report.prc_get_workload_change_rpt">
			<cfprocresult name="rstWorkloadChange">
		</cfstoredproc>

		<cfif arguments.fundingOfficeNum neq "all">
			<cfquery name="rstWorkloadChange" dbtype="query">
			select *
			from	rstWorkloadChange
			where 	fundingOfficeNum = #arguments.fundingOfficeNum#
			</cfquery>
		</cfif>

		<cfreturn rstWorkloadChange>
	</cffunction>

</cfcomponent>