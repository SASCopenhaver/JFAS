<!---
page: contractor.cfc

description: component that handles contractor/vendor related functions

revisions:
2011-07-20	mstein	Added VendorSearch function

--->

<cfcomponent displayname="Contractors" hint="contains all methods, functios related to job corps contractors">

	<cffunction name="getContractors" access="public" returntype="query">
		<cfargument name="contractorID" type="numeric" required="no" default="0">
		<cfargument name="status" type="string" required="no" default="active">
		<cfargument name="contractorName" type="string" required="no" default="">

		<cfquery name="qryGetContractors" datasource="#request.dsn#">
		select	contractor_id as contractorID,
				contractor_name as contractorName,
				status
		from	contractor
		where	1=1
		<cfif contractorID neq 0>
			and contractor_id = #arguments.contractorID#
		</cfif>
		<cfif status eq "active">
			and status = 1
		</cfif>
		<cfif arguments.contractorName neq "">
			and upper(contractor_name) = '#ucase(arguments.contractorName)#'
		</cfif>
		order by upper(contractor_name)
		</cfquery>

		<cfreturn qryGetContractors>
	</cffunction>

	<cffunction name="filterContractorList" access="public" returntype="query">
		<cfargument name="range" type="numeric" required="no" default="25">

		<cfinvoke component="#application.paths.components#contractor" method="getContractors" status="all" returnvariable="rstContractors">

			<cfset qryContractorBreaks = QueryNew("start, end")>
		<cfif rstContractors.recordcount neq 0>
			<cfset breaks = ceiling(rstContractors.recordcount/arguments.range)>
		</cfif>

		<cfset newRow = QueryAddRow(qryContractorBreaks, breaks)>
		<cfloop from="1" to="#breaks#" index="i">
			<!--- set starting Contractor --->
			<cfset Variables['start_' & i] = rstContractors.ContractorName[(i*arguments.range) - (arguments.range - 1)]>
			<!--- set ending Contractor --->
			<cfif rstContractors.recordcount lt i*arguments.range>
				<cfset Variables['end_' & i] = rstContractors.ContractorName[rstContractors.recordcount]>
			<cfelse>
				<cfset Variables['end_' & i] = rstContractors.ContractorName[i*arguments.range]>
			</cfif>
			<!--- set up query --->
			<cfset temp = QuerySetCell(qryContractorBreaks, "start", Variables['start_' & i], i)>
			<cfset temp = QuerySetCell(qryContractorBreaks, "end", Variables['end_' & i], i)>
		</cfloop>

		<cfreturn qryContractorBreaks>
	</cffunction>

	<cffunction name="saveContractor" access="public" returntype="struct">
		<cfargument name="formData" type="struct" required="yes">
		<cfargument name="ContractorID" type="numeric" required="yes">


		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cfif arguments.ContractorID eq 0>
			<cfinvoke component="#application.paths.components#contractor" method="getContractors" ContractorName="#arguments.formData.txtContractorName#" returnvariable="rstContractors" >
			<cfif rstContractors.recordcount gt 0>
				<cfset errorMessages = listAppend(errorMessages, "A contractor with that name already exists", ",")>
				<cfset errorFields = listAppend(errorFields, "txtContractorName", ",")>
				<cfset success = "false">
			</cfif>
		<cfelse>
			<cfinvoke component="#application.paths.components#Contractor" method="getContractors" ContractorName="#arguments.formData.txtContractorName#" returnvariable="rstContractors" >
			<cfquery name="qryContractorCheck" dbtype="query">
				Select	*
				From	rstContractors
				Where 	upper(ContractorID) <> #ucase(arguments.ContractorID)#
			</cfquery>

			<cfif qryContractorCheck.recordcount gt 0>
				<cfset errorMessages = listAppend(errorMessages, "A Contractor with that name already exists", ",")>
				<cfset errorFields = listAppend(errorFields, "txtContractorName", ",")>
				<cfset success = "false">
			</cfif>
		</cfif>

		<cfif success>
			<cfif arguments.ContractorID eq 0>
				<cfinvoke component="#application.paths.components#Contractor" method="insertContractor"
				ContractorName="#arguments.formData.txtContractorName#"
				status="#arguments.formData.radStatus#"
				returnvariable="newContractorID"
				>
			<cfelse>
				<cfinvoke component="#application.paths.components#Contractor" method="updateContractor"
				ContractorID="#arguments.ContractorID#"
				ContractorName="#arguments.formData.txtContractorName#"
				status="#arguments.formData.radStatus#"
				>
			</cfif>
		</cfif>

		<cfset stcResults = StructNew()>
			<cfset stcResults.success = success>
			<cfif success>
				<cfif isDefined("newContractorID")>
					<cfset stcResults.ContractorID = newContractorID>
				<cfelse>
					<cfset stcResults.ContractorID = arguments.ContractorID>
				</cfif>
			<cfelse>
				<cfset stcResults.errorMessages = errorMessages>
				<cfset stcResults.errorFields = errorFields>
			</cfif>

		<cfreturn stcResults>


	</cffunction>

	<cffunction name="updateContractor" access="public" output="false">
		<cfargument name="ContractorID" required="yes" type="numeric">
		<cfargument name="ContractorName" required="yes" type="string">
		<cfargument name="status" required="yes" type="numeric">

	<cftransaction>
		<cfquery name="qryUpdateContractor" datasource="#request.dsn#">
		update	Contractor
		set		Contractor_Name = '#arguments.ContractorName#',
				Status = #arguments.status#,
				update_user_id = '#session.userid#',
				update_function = '#request.auditvarupdate#',
				update_time = sysdate
		where	Contractor_ID = #arguments.ContractorID#

		</cfquery>

	<cfset application.outility.insertSystemAudit (
			Description="Update Contractor #arguments.contractorName#",
			userID="#session.userID#")>

	</cftransaction>

	</cffunction>

	<cffunction name="insertContractor" access="public" returntype="numeric">
		<cfargument name="ContractorName" required="yes" type="string">
		<cfargument name="status" required="yes" type="numeric">

	<cftransaction>
		<cfquery name="getNextContractorID" datasource="#request.dsn#">
			select 	SEQ_Contractor.nextval as nextContractorID
			from	dual
		</cfquery>

		<cfquery name="qryInsertContractor" datasource="#request.dsn#">
			Insert into	Contractor (
					Contractor_ID,
					Contractor_Name,
					Status,
					Update_User_ID,
					Update_Function,
					Update_Time
					)
				Values(
					#getNextContractorID.nextContractorID#,
					'#arguments.ContractorName#',
					#arguments.status#,
					'#session.userID#',
					'#request.auditvarinsert#',
					sysdate
					)
		</cfquery>

	<cfset application.outility.insertSystemAudit (
			Description="Insert Contractor #arguments.contractorName#",
			userID="#session.userID#")>

	</cftransaction>

	<cfreturn getNextContractorID.nextContractorID>

	</cffunction>

	<cffunction name="getContractorPerf" access="public" returntype="query">

			<cfquery name="qryGetContractorPerf" datasource="#request.dsn#">
				select 	Perf_Rating_Exel as PerfRating,
						RO_Percent_Exel as ROPerExel,
						RO_Percent_Reg as ROPerReg,
						RO_Cap_Amount_Reg as ROCapReg,
						RO_Percent_OACTS as ROPerOACTS,
						RO_Cap_Amount_OACTS as ROCapOACTS,
						LowOBS_Takeback_Rate as lowOBS
				from	Contract_Performance_Ref
			</cfquery>

		<cfreturn qryGetContractorPerf>

	</cffunction>

	<cffunction name="saveContractorPerf" access="public" returntype="void">
		<cfargument name="formData" type="struct" required="yes">
		<cftransaction>
			<cfquery name="qrySaveContractorPerf" datasource="#request.dsn#">
				Update	Contract_Performance_Ref
				Set		Perf_Rating_Exel = #arguments.formData.txtPerfRating#,
						RO_Percent_Exel = #arguments.formData.txtROPerExel#,
						RO_Percent_Reg = #arguments.formData.txtROPerReg#,
						RO_Cap_Amount_Reg = #replace(arguments.formData.txtROCapReg, ",", "", "all")#,
						RO_Percent_OACTS = #arguments.formData.txtROPerOACTS#,
						RO_Cap_Amount_OACTS = #replace(arguments.formData.txtROCapOACTS, ",", "", "all")#,
						LowOBS_Takeback_Rate = #arguments.formData.txtLowOBS#
			</cfquery>

	<cfset application.outility.insertSystemAudit (
			description="Update Contractor Performance Ratings",
			userID="#session.userID#")>
		</cftransaction>
	</cffunction>


	<cffunction name="vendorSearch" access="public" returntype="query" hint="Search for vendors/contractors">
		<cfargument name="searchName" type="string" required="true" default="">
		<cfargument name="searchID" type="string" required="true" default="">
		<cfargument name="searchContents" type="string" required="true" default="footprint">

		<cfif arguments.searchContents eq "footprint">
			<cfquery name="qryVendorSearch" datasource="#request.dsn#">
			select	distinct vendor_name as vendorName, vendor_tin as vendorID
			from	footprint_ncfms
			where	1=1
					<cfif arguments.searchName neq "">
						and upper(vendor_name) like '#ucase(arguments.searchName)#%'
					</cfif>
					<cfif arguments.searchID neq "">
						and upper(vendor_tin) like '#ucase(arguments.searchID)#%'
					</cfif>
			order	by vendorName
			</cfquery>
		<cfelseif arguments.searchContents eq "contractorref">
			<cfquery name="qryVendorSearch" datasource="#request.dsn#">
			select	contractor_name as vendorName
			from	contractor
			where	upper(contractor_name) like '#ucase(arguments.searchName)#%'
			order	by vendorName
			</cfquery>
		</cfif>

		<cfreturn qryVendorSearch>

	</cffunction>
    
     

</cfcomponent>