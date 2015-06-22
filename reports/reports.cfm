<cfsilent>
<!---
page: reports.cfm

description: container page for reports

revisions:
12/20/2006 - rroser - Defect # 20 - added getAAPPGeneral method to FOP Allocations (by AAPP) report
05/15/2007 - abai  - add new case 13, and 17
05/30/2007 - yjeng - add new case 18
06/01/2007 - rroser - add new case 19 - Future New
2007-08-15	mstein	Add marginTop and marginBottom as variables, so they can be adjusted per report
2007-08-29  abai	Add case 21
2007-11-27	rroser	add case 24 outyear report
2008-05-01	mstein	Added Workload Change List report
2008-06-19	mstein	Added Printable version of AAPP/DOLAR$ discrepancy list
2011-04-19	mstein	Took component calls out of CloseOut report section (put in rpt_ page)
2014-03-09	mstein	Added Recon Reports (JFAS 2.13)
--->
<cfset request.pageID="0">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "Reports">
<cfsetting requestTimeout = "900">

<!--- default seetings for margins, page size, and orientation --->
<!--- only need to include cfset if report differs from these defaults --->
<!---
rptMarginTop = 0.5
rptMarginBottom = 0.5
rptMarginLeft = 0.5
rptMarginRight = 0.5
PDFOrientation = landscape
pageType = letter
--->

<cfif isDefined("url.rpt_id") and isDefined("form.radReportFormat")>
	<cfswitch expression="#url.rpt_id#">
		<cfcase value="1">
		<!---Report: Budget Authority Requirements by AAPP--->
			<cfinvoke component="#application.paths.components#reports" method="getRptBudgetAuth" formdata="#form#" returnvariable="rsBudgetAuth" />
			<cfset rptTemplate="rpt_budget_authority_requirements.cfm">

		</cfcase>
		<cfcase value="2">
		<!---Report: Estimated Cost Profile--->
			<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileSort" aapp="#form.aapp#" sortBy="contract_type_code" sortDir="asc" returnvariable="rstEstCostProfileSort" />
			<cfinvoke component="#application.paths.components#reports" method="getRptEstCostProfile" aapp="#form.aapp#" returnvariable="rstRptEstCostProfile" />
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPCurrentContractYear" aapp="#form.aapp#" returnvariable="cy" />
			<cfset rptTemplate="rpt_estimated_cost_profile.cfm">
			<cfset PDFOrientation = "portrait"> 

		</cfcase>
		<cfcase value="3">
		<!---Report: Fiscal Plan--->
			<cfinvoke component="#application.paths.components#reports" method="getRptFiscalPlan" aapp="#form.aapp#" returnvariable="rstFiscalPlan" />
			<cfset rptTemplate="rpt_fiscal_plan.cfm">
			<cfset PDFOrientation = "portrait"> 
			<cfset rptMarginBottom = "1.0">
			
		</cfcase>	
		<cfcase value="4">
		<!---Report: FOP Allocations (by AAPP)--->
			<cfinvoke component="#application.paths.components#reports" method="getFopList" formdata="#form#" returnvariable="rstFopList" />
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#form.AAPP#" returnvariable="rstGetAAPPGeneral" />
			<cfset rptTemplate="rpt_fop_aapp.cfm">

		</cfcase>
		<cfcase value="5">
		<!---Report: FOP Listing--->
			<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#form.cboFundingOffice#"  returnvariable="rstFundingOffices">
			<cfinvoke component="#application.paths.components#reports" method="getFopList" formdata="#form#" returnvariable="rstFopList" />
			<cfset rptTemplate="rpt_fop_allocations.cfm">

		</cfcase>
		<cfcase value="6">
		<!---Report: Budget Authority Requirements by Funding Office--->
			<cfinvoke component="#application.paths.components#reports" method="getRptBudgetAuthFundingOffice" fundingOfficeNum="#form.cboFundingOffice#" returnvariable="rsBudgetAuthFundsOffice" />
			<cfset rptTemplate="rpt_budget_authority_fundingoffice.cfm"> 

		</cfcase>
		<cfcase value="7">
		<!---Report: Footprint/contractor report--->
			<cfif isDefined("form.radDataSource") and form.radDataSource eq "DOLAR$">
				<!--- if user has requested DOLAR$ as the source --->
				<cfinvoke component="#application.paths.components#reports" method="getRptFootprint_contractor_dolars"
						  formdata="#form#"
						  returnvariable="rsFootprintContractor_dolars" />
				<cfset rptTemplate="rpt_footprint_contract.cfm">
			<cfelse> <!--- default source is NCFMS --->
				<cfinvoke component="#application.paths.components#reports" method="getRptFootprint_contractor_ncfms"
						  formdata="#form#"
						  returnvariable="rsFootprintContractor_ncfms" />
				<cfset rptTemplate="rpt_footprint_contract_ncfms.cfm">
			</cfif>			
			<cfset PDFOrientation = "landscape"> 

		</cfcase>	
		<cfcase value="8">
		<!---Report: CCC BA Transfer report--->
			<!--- <cfinvoke component="#application.paths.components#reports" method="getRptCCCBaTransfer" fundingOfficeNum="#form.cboFundingOffice#" returnvariable="rsCCCBaTransfer" /> --->
			<cfset rptTemplate="rpt_ccc_ba_transfer.cfm">
			<cfset PDFOrientation = "portrait"> 

		</cfcase>
		<cfcase value="9">
		<!---Report: Program Operating Plan Detail report--->
			<cfinvoke component="#application.paths.components#reports" method="getRptProgop_detail" formdata="#form#" returnvariable="rsProgop_detail" />
			<cfset rptTemplate="rpt_progop_detail.cfm">

		</cfcase>	
		<cfcase value="10">
		<!---Report: FOP CCC Budget report--->
			<cfinvoke component="#application.paths.components#reports" method="getRptFOP_ccc_budget" formdata="#form#" returnvariable="rsFOP_CCC_Budget" />
			<cfset rptTemplate="rpt_ccc_py_budget.cfm">
			<cfset PDFOrientation = "portrait"> 

		</cfcase>
		<cfcase value="11">
		<!---Report: Program Year Initial CCC Budget report--->
			<cfinvoke component="#application.paths.components#reports" method="getRptPY_ccc_worksheet" formdata="#form#" returnvariable="rsPY_ccc_worksheet" />
			<cfset rptTemplate="rpt_ccc_py_worksheet.cfm">
			<cfset PDFOrientation = "portrait"> 

		</cfcase>
		<!---Report: VST Worksheet report--->
		<cfcase value="12">
			<cfset rptTemplate="rpt_vst_worksheet.cfm">
			<cfset url.aapp = form.aapp>
			<cfset url.py = form.cboPY>
			<cfset PDFOrientation = "portrait"> 

		</cfcase>
		<!---Report: Budget Status--->
		<cfcase value="13">
			<!--- <cfinvoke component="#application.paths.components#reports" method="getRptBudgetStatus" formdata="#form#" returnvariable="rsBudgetStatus" /> --->
			<cfset rptTemplate="rpt_budget_status.cfm">

		</cfcase>
		<cfcase value="14">
		<!---Report: Contract Close Out--->
			<cfset rptTemplate="rpt_closeout.cfm">
			<cfset PDFOrientation = "portrait"> 

		</cfcase>
		<cfcase value="15">
		<!---Report: Fop batch process DOL--->
			<cfset rptTemplate="rpt_fopbatch_dol_2.cfm">
			<cfset PDFOrientation = "portrait"> 

		</cfcase>					
		<cfcase value="16">
		<!---Report: Fop batch process CCC--->
			<cfset rptTemplate="rpt_fopbatch_ccc_2.cfm">
			<cfset PDFOrientation = "portrait"> 

		</cfcase>
		<cfcase value="17">
		<!---Report: OA/CTS Annualized Workload/Cost Under Current Contracts--->
			<!--- <cfinvoke component="#application.paths.components#reports" method="getRptOa_cts_annualized_cost" formdata="#form#" returnvariable="rs_oa_cts_annualized_cost" /> --->
			<cfset rptTemplate="rpt_oa_cts_annualized.cfm">

		</cfcase>		
		<cfcase value="18">
		<!---Report: Fop batch process CCC--->
			<cfset rptTemplate="rpt_fopbatch_other_2.cfm">
			<cfset PDFOrientation = "portrait"> 

		</cfcase>		
		<cfcase value="19">
		<!---Report: Future NEw--->
			<cfset rptTemplate="rpt_future_new.cfm">
			<cfset PDFOrientation = "portrait"> 

		</cfcase>
		<cfcase value="20">
		<!---Report: Program Year Initial CCC Budget (by Center)--->
			<cfset rptTemplate="rpt_ccc_py_aapp_bycenter.cfm">
			<cfset PDFOrientation = "portrait"> 
			
		</cfcase>
		<cfcase value="21">
		<!---Report: footprint Transaction--->
			<cfif isDefined("form.radDataSource") and form.radDataSource eq "DOLAR$">
				<cfset rptTemplate="rpt_footprint_transaction.cfm">
			<cfelse>
				<cfset rptTemplate="rpt_footprint_transaction_ncfms.cfm">
			</cfif>
			
			<cfset rptMarginLeft = "0.25">
			<cfset rptMarginRight = "0.25">

		</cfcase>
		<cfcase value="22">
		<!---Report: Small Business Funding report--->
			<cfset rptTemplate="rpt_smallbusiness.cfm">

		</cfcase>
		<cfcase value="23">
		<!--- Report: Footprint/Transaction discrepancy --->
		<cfif form.radReportType is "AAPP">
			<cfinvoke component="#application.paths.components#import_data" method="FootprintXactnDisc" returnvariable="rstFootprintXactn" aapp="#form.aapp#">
		<cfelse>
			<cfinvoke component="#application.paths.components#import_data" method="FootprintXactnDisc" returnvariable="rstFootprintXactn" aapp="0">
		</cfif>
			<cfset rptTemplate="rpt_footprint_xactn_disc.cfm">
			
		</cfcase>		
		<cfcase value="24">
			<!---Report: Outyear Report--->
			<cfloop list="#form.chkCostCat#" index="i">
				<cfinvoke component="#application.paths.components#reports" method="getOutyearRpt" fundingOfficeNum="#form.cboFundingOffice#" costCat="#i#" returnvariable="rstOutyear_#i#" />
			</cfloop>
			<cfset rptTemplate="rpt_outyear.cfm">

		</cfcase>
		
		<cfcase value="25">
			<!---Report: Workload Change List --->
			<cfif form.cboFundingOffice neq "All">
				<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#form.cboFundingOffice#"  returnvariable="rstFundingOffices">
			</cfif>
			<!--- get list of workload type descriptions to display in report header --->
			<cfinvoke component="#application.paths.components#lookup" method="getWorkloadTypes" returnvariable="rstWorkloadTypes">
			<cfquery name="qryGetWLDesc" dbtype="query">
			select	workloadTypeDesc
			from	rstWorkloadTypes
			where	workloadTypeCode in (#listqualify(form.ckbWorkload,"'")#)
			</cfquery>
			<cfset variables.lstWorkloadTypeDesc = valuelist(qryGetWLDesc.workloadTypeDesc,", ")>
				
			<cfinvoke component="#application.paths.components#reports" method="getWorkloadChangeList"
				fundingOfficeNum="#form.cboFundingOffice#"
				lstWorkloadTypes="#form.ckbWorkload#"
				returnvariable="rstWorkLoadChange" />
			<cfset rptTemplate="rpt_workload_change.cfm">
		</cfcase>
		
		<cfcase value="26">
			<!---Report: Printable Version of AAPP / NCFMS Fotprint Discrepancy List --->
			<cfinvoke component="#application.paths.components#footprint" method="getAAPPFootDisc"
				returnvariable="strAAPPFootDisc">
			<cfset rptTemplate="rpt_footprint_disc.cfm">
		</cfcase>
		
		<cfcase value="27">
			<!--- NCFMS / FOP Reconciliation --->
			<cfinvoke component="#application.paths.components#reports" method="getNCFMSFOP_Reconciliation"
				py = "#form.cboPY#"
				fundingOfficeNum = "#form.cboFundingOffice#"
				status = "#form.radStatus#"
				returnvariable="rstNCFMSFOP_Reconciliation">
				
			<cfset rptTemplate="rpt_ncfms_fop_recon.cfm">
		</cfcase>
		
		<cfcase value="28">
			<!--- FOP / Allocation Reconciliation --->
			<cfinvoke component="#application.paths.components#reports" method="getFOPAllocation_Reconciliation"
				py = "#form.cboPY#"
				fundingOfficeNum = "#form.cboFundingOffice#"
				status = "#form.radStatus#"
				returnvariable="rstFOPAllocation_Reconciliation">
			<cfset rptTemplate="rpt_fop_allocat_recon.cfm">
		</cfcase>
		
		<cfcase value="29">
			<!--- Allotment / Obligation / Allocation Recon (National) --->
			<cfinvoke component="#application.paths.components#reports" method="getAllotAllocation_Recon_Nat"
				py = "#form.cboPY#"
				fundingCat = "#form.radfundingCat#"
				returnvariable="rstAllotAlloc_ReconNat">
			<cfset rptTemplate="rpt_allot_allocat_recon_nat.cfm">
		</cfcase>
		<cfcase value="30">
			<!--- Allotment / Obligation / Allocation Recon (AAPP) --->
			<cfinvoke component="#application.paths.components#reports" method="getNCFMSAllocation_Recon_AAPP"
				py = "#form.cboPY#"
				fundingOfficeNum = "#form.cboFundingOffice#"
				fundingCat = "#form.radfundingCat#"
				returnvariable="rstNCFMSAllocation_Recon_AAPP">
			<cfset rptTemplate="rpt_ncfms_allocat_fop_recon_aapp.cfm">
		</cfcase>
			
	</cfswitch>
</cfif>
</cfsilent>
<!---Include reports body pages--->
<cfinclude template="report_display.cfm">
