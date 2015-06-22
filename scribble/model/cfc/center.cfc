<!---
	revisions:
	01-05-2007 - rroser - updated queries to handle three new fields - main center, old center name, and comments
	02-05-2007 - rroser - updated queries to handle center code
--->

<cfcomponent displayname="Centers" hint="contains all methods, functios related to job corps centers">

	<cffunction name="getCenters" access="public" returntype="query">
		<cfargument name="centerID" type="numeric" required="no" default="0">
		<cfargument name="fundingOfficeType" type="string" required="no" default="">
		<cfargument name="centerName" type="string" required="no" default="">
		<cfargument name="centerCode" type="string" required="no" default="">
		<cfquery name="qryGetCenters" datasource="#request.dsn#">
		select	center_id as centerID,
				center_name as centerName,
				center.funding_office_num as fundingOfficeNum,
				funding_office_desc as fundingOfficeDesc,
				ccc_num as cccNum,
				center.state_abbr as state,
				state_name as stateName,
				city as city,
				status as status,
				main_center_id as mainCenterID,
				center_name_old as oldCenterName,
				comments as comments,
				center_code as centerCode,
				'' as satellite
		from	center inner join lu_funding_office on
				(center.funding_office_num = lu_funding_office.funding_office_num)
					inner join lu_state on
					(center.state_abbr = lu_state.state_abbr)
		<cfif arguments.centerID neq 0>
			where center_id = #arguments.centerid#
		</cfif>
		<cfif arguments.fundingOfficeType neq "">
			where lu_funding_office.office_type = '#arguments.fundingOfficeType#'
		</cfif>
		<cfif arguments.centerName neq "">
			where upper(center_name) = '#ucase(arguments.centerName)#'
		</cfif>
		<cfif arguments.centerCode neq "">
			where upper(Center_Code) = '#ucase(arguments.centerCode)#'
		</cfif>
		order	by upper(centerName)
		</cfquery>
		<cfif arguments.centerID neq 0>
			<cfquery name="qrySatellite" datasource="#request.dsn#">
				select	*
				from	Center
				where 	main_center_ID = #arguments.centerID#
			</cfquery>
			<cfset temp = QuerySetCell(qryGetCenters, 'satellite', qrySatellite.recordcount)>
		</cfif>

		<cfreturn qryGetCenters>
	</cffunction>

	<cffunction name="getCenterID" access="public" returntype="query">
		<cfargument name="centerName" type="string" required="no" default="">

		<cfquery name="qryGetCenterID" datasource="#request.dsn#">
			select	center_id as centerID
			from	center
		<cfif arguments.centerName neq ''>
			where	center_Name = '#arguments.centerName#'
		</cfif>
		</cfquery>

		<cfreturn qryGetCenterID>
	</cffunction>

	<cffunction name="filterCenterList" access="public" returntype="query">
		<cfargument name="range" required="no" default="25">
		<cfargument name="centerID" type="numeric" required="no" default="0">
		<cfargument name="fundingOfficeType" type="string" required="no" default="">

		<cfinvoke component="#application.paths.components#center" method="getCenters" centerID="#arguments.centerID#"
		fundingOfficeType="#arguments.fundingOfficeType#" returnvariable="rstCenters">

		<cfset qryCenterBreaks = QueryNew("start, end")>
		<cfif rstCenters.recordcount neq 0>
			<cfset breaks = ceiling(rstCenters.recordcount/arguments.range)>
		</cfif>

		<cfset newRow = QueryAddRow(qryCenterBreaks, breaks)>
		<cfloop from="1" to="#breaks#" index="i">
			<!--- set starting center --->
			<cfset Variables['start_' & i] = rstCenters.centerName[(i*arguments.range) - (arguments.range - 1)]>
			<!--- set ending center --->
			<cfif rstCenters.recordcount lt i*arguments.range>
				<cfset Variables['end_' & i] = rstCenters.centerName[rstCenters.recordcount]>
			<cfelse>
				<cfset Variables['end_' & i] = rstCenters.centerName[i*arguments.range]>
			</cfif>
			<!--- set up query --->
			<cfset temp = QuerySetCell(qryCenterBreaks, "start", Variables['start_' & i], i)>
			<cfset temp = QuerySetCell(qryCenterBreaks, "end", Variables['end_' & i], i)>
		</cfloop>

		<cfreturn qryCenterBreaks>
	</cffunction>

	<cffunction name="saveCenter" access="public" returntype="struct">
		<cfargument name="formData" type="struct" required="yes">
		<cfargument name="centerID" type="numeric" required="yes">


		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cfif arguments.centerID eq 0>
			<cfinvoke component="#application.paths.components#center" method="getCenters" centerName="#arguments.formData.txtCenterName#" returnvariable="rstCenters" >
			<cfif rstCenters.recordcount gt 0>
				<cfset errorMessages = listAppend(errorMessages, "A center with that name already exists", ",")>
				<cfset errorFields = listAppend(errorFields, "txtCenterName", ",")>
				<cfset success = "false">
			</cfif>
			<cfinvoke component="#application.paths.components#center" method="getCenters" centerCode="#arguments.formData.txtCenterCode#" returnvariable="rstCenters" >
			<cfif rstCenters.recordcount gt 0>
				<cfset errorMessages = listAppend(errorMessages, "A center with that abbreviation already exists", ",")>
				<cfset errorFields = listAppend(errorFields, "txtCenterCode", ",")>
				<cfset success = "false">
			</cfif>
		<cfelse>
			<cfinvoke component="#application.paths.components#center" method="getCenters" centerName="#arguments.formData.txtCenterName#" returnvariable="rstCenters" >
			<cfquery name="qryCenterCheck" dbtype="query">
				Select	*
				From	rstCenters
				Where 	centerID <> #arguments.centerID#
			</cfquery>
			<cfif qryCenterCheck.recordcount gt 0>
				<cfset errorMessages = listAppend(errorMessages, "A center with that name already exists", ",")>
				<cfset errorFields = listAppend(errorFields, "txtCenterName", ",")>
				<cfset success = "false">
			</cfif>
			<cfinvoke component="#application.paths.components#center" method="getCenters" centerCode="#arguments.formData.txtCenterCode#" returnvariable="rstCenterCode" >
			<cfquery name="qryCenterCodeCheck" dbtype="query">
				Select	*
				From	rstCenterCode
				Where 	centerID <> #arguments.centerID#
			</cfquery>
			<cfif qryCenterCodeCheck.recordcount gt 0>
				<cfset errorMessages = listAppend(errorMessages, "A center with that abbreviation already exists", ",")>
				<cfset errorFields = listAppend(errorFields, "txtCenterCode", ",")>
				<cfset success = "false">
			</cfif>

		</cfif>

		<cfif success>
			<cfif arguments.centerID eq 0>
				<cfinvoke component="#application.paths.components#center" method="insertCenter"
				centerName="#arguments.formData.txtCenterName#"
				city="#arguments.formData.txtCity#"
				state="#arguments.formData.cboState#"
				fundingOfficeNum="#arguments.formData.cboFundingOffice#"
				status="#arguments.formData.radStatus#"
				mainCenter="#arguments.formData.cboMainCenter#"
				oldCenterName="#arguments.formData.txtOldCenterName#"
				comments="#arguments.formData.txtComments#"
				centerCode="#arguments.formData.txtCenterCode#"
				returnvariable="newCenterID"
				>
			<cfelse>
				<cfinvoke component="#application.paths.components#center" method="updateCenter"
				centerID="#arguments.centerID#"
				centerName="#arguments.formData.txtCenterName#"
				city="#arguments.formData.txtCity#"
				state="#arguments.formData.cboState#"
				fundingOfficeNum="#arguments.formData.cboFundingOffice#"
				status="#arguments.formData.radStatus#"
				mainCenter="#arguments.formData.cboMainCenter#"
				oldCenterName="#arguments.formData.txtOldCenterName#"
				comments="#arguments.formData.txtComments#"
				centerCode="#arguments.formData.txtCenterCode#"
				>
			</cfif>
		</cfif>

		<cfset stcResults = StructNew()>
			<cfset stcResults.success = success>
			<cfif success>
				<cfif isDefined("newCenterID")>
					<cfset stcResults.centerID = newCenterID>
				<cfelse>
					<cfset stcResults.centerID = arguments.centerID>
				</cfif>
			<cfelse>
				<cfset stcResults.errorMessages = errorMessages>
				<cfset stcResults.errorFields = errorFields>
			</cfif>

		<cfreturn stcResults>


	</cffunction>

	<cffunction name="updateCenter" access="public" output="false">
		<cfargument name="centerID" required="yes" type="numeric">
		<cfargument name="centerName" required="yes" type="string">
		<cfargument name="city" required="no" default="">
		<cfargument name="state" required="yes" type="string">
		<cfargument name="fundingOfficeNum" required="yes" type="numeric">
		<cfargument name="status" required="yes" type="numeric">
		<cfargument name="mainCenter" required="no" type="numeric" default="0">
		<cfargument name="oldCenterName" required="no" type="string" default="">
		<cfargument name="comments" required="no" type="string" default="">
		<cfargument name="centerCode" required="yes" type="string">

	<cftransaction>
		<cfquery name="qryUpdateCenter" datasource="#request.dsn#">
		update	center
		set		Center_Name = '#arguments.centerName#',
				city = 	'#arguments.city#',
				State_Abbr = '#arguments.state#',
				Funding_Office_Num = #arguments.fundingOfficeNum#,
				Status = #arguments.status#,
				<cfif arguments.mainCenter neq 0>
				main_center_ID = #arguments.mainCenter#,
				<cfelse>
				main_center_ID = NULL,
				</cfif>
				center_name_old = '#arguments.oldCenterName#',
				comments = '#arguments.comments#',
				center_code = '#arguments.centerCode#',
				update_user_id = '#session.userid#',
				update_function = '#request.auditvarupdate#',
				update_time = sysdate
		where	center_ID = #arguments.centerID#

		</cfquery>

	<cfset application.outility.insertSystemAudit (
			Description="Update Center #arguments.centerName#",
			userID="#session.userID#")>

	</cftransaction>

	</cffunction>

	<cffunction name="insertCenter" access="public" returntype="numeric">
		<cfargument name="centerName" required="yes" type="string">
		<cfargument name="city" required="no" default="">
		<cfargument name="state" required="yes" type="string">
		<cfargument name="fundingOfficeNum" required="yes" type="numeric">
		<cfargument name="status" required="yes" type="numeric">
		<cfargument name="mainCenter" required="no" type="numeric" default="0">
		<cfargument name="oldCenterName" required="no" type="string" default="">
		<cfargument name="comments" required="no" type="string" default="">
		<cfargument name="centerCode" required="yes" type="string">

	<cftransaction>
		<cfquery name="getNextCenterID" datasource="#request.dsn#">
			select 	SEQ_Center.nextval as nextCenterID
			from	dual
		</cfquery>

		<cfquery name="qryInsertCenter" datasource="#request.dsn#">
			Insert into	Center (
					Center_ID,
					Center_Name,
					City,
					State_Abbr,
					Funding_Office_Num,
					Status,
					Update_User_ID,
					Update_Function,
					Update_Time,
					Main_Center_ID,
					Center_Name_Old,
					Comments,
					Center_Code
					)
				Values(
					#getNextCenterID.nextCenterID#,
					'#arguments.centerName#',
					'#arguments.city#',
					'#arguments.state#',
					#arguments.fundingOfficeNum#,
					#arguments.status#,
					'#session.userID#',
					'#request.auditvarinsert#',
					sysdate,
					<cfif arguments.mainCenter neq 0>
					'#arguments.mainCenter#',
					<cfelse>
					NULL,
					</cfif>
					'#arguments.oldCenterName#',
					'#arguments.comments#',
					'#arguments.centerCode#'
					)
		</cfquery>

	<cfset application.outility.insertSystemAudit (
			Description="Insert Center #arguments.centerName#",
			userID="#session.userID#")>

	</cftransaction>

	<cfreturn getNextCenterID.nextCenterID>

	</cffunction>

</cfcomponent>