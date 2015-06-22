<!---
page: dataadmin.cfc

description: component that handles misc data admin functions

revisions:
2009-03-18	mstein	Updated RCC functions to add ARRA (stimulus) indicator field
2009-12-22	mstein	Update getImportTypeInfo for NCFMS (later reversed out)
2014-06-05	sasurikov Update Snapshot table from Remove an Unfunded AAPP
--->
<cfcomponent displayname="DataAdmin" hint="contains all methods, functions related to JFAS Misc Data Admin Section">

	<cffunction name="getSetAsideTypes" access="public" returntype="query" hint="Returns recordset containing list of set-aside types">
		<cfargument name="setasideID" type="numeric" required="false" default="0">

		<!--- used for admin listing --->
		<cfquery name="qryGetSetAsideTypes" datasource="#request.dsn#">
		select	smb_setaside_id as setasideID,
				smb_setaside_desc as setasideDesc,
				sort_order as sortOrder
		from	lu_smb_setaside
		<cfif arguments.setasideID neq "0">
			where smb_setaside_id = #arguments.setasideID#
		</cfif>
		order 	by sort_order, smb_setaside_desc
		</cfquery>

		<cfreturn qryGetSetAsideTypes>
	</cffunction>

	<cffunction name="getSetAside" access="public" returntype="query" hint="Returns recordset containing data about one setaside cat">
		<cfargument name="setasideID" type="numeric" required="true">

		<cfquery name="qryGetSetAside" datasource="#request.dsn#">
		select	smb_setaside_id as setasideID,
				smb_setaside_desc as setasideDesc,
				sort_order as sortOrder,
				(select count(aapp_num)
				 from	aapp a
				 where	a.smb_setaside_id = lu_smb_setaside.smb_setaside_id)
				 smbUsed
		from	lu_smb_setaside
		where smb_setaside_id = #arguments.setasideID#
		</cfquery>

		<cfreturn qryGetSetAside>
	</cffunction>

	<cffunction name="saveSetAsideData" access="public" returntype="struct" hint="Handles Setaside Data entry Form actions">
		<cfargument name="formData" type="struct" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<!--- determine if this is insert or update --->
		<cfif arguments.formData.hidMode eq "add">
			<cfset SMBid = this.insertSetAside(arguments.formData.txtDescription,arguments.formData.txtSortOrder)>
		<cfelseif arguments.formData.hidMode eq "edit">
			<cfset SMBid = arguments.formData.hidSetasideID>
			<cfset temp = this.updateSetAside(arguments.formData.hidSetAsideID, arguments.formData.txtDescription, arguments.formData.txtSortOrder)>
		<cfelseif arguments.formData.hidMode eq "delete">
			<cfset SMBid = arguments.formData.hidSetasideID>
			<cfset temp = this.deleteSetAside(arguments.formData.hidSetAsideID)>
		</cfif>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>
		<cfset stcResults.SMBid = SMBid>

		<cfreturn stcResults>

	</cffunction>

	<cffunction name="insertSetAside" access="public" returntype="numeric" hint="Inserts record into lu_smb_setaside">
		<cfargument name="description" type="string" required="true">
		<cfargument name="sortOrder" type="numeric" required="false" default="1000">

		<cftransaction>
		<cfquery name="qryGetSMBID" datasource="#request.dsn#">
		select	seq_lu_smb_setaside.nextval as nextSMBid
		from	dual
		</cfquery>

		<cfquery name="qryInsertSetAside" datasource="#request.dsn#">
		insert into lu_smb_setaside (
			smb_setaside_id,
			smb_setaside_desc,
			sort_order)
		values (
			#qryGetSMBID.nextSMBid#,
			'#arguments.description#',
			#arguments.sortOrder#)
		</cfquery>

	<cfset application.outility.insertSystemAudit (
					description="Small Business Setaside Category Added: #arguments.description#",
					userID="#session.userID#")>
		</cftransaction>

		<cfreturn qryGetSMBID.nextSMBid>

	</cffunction>

	<cffunction name="updateSetAside" access="public" returntype="void" hint="Updates Setaside Category">
		<cfargument name="setasideID" type="numeric" required="true">
		<cfargument name="description" type="string" required="true">
		<cfargument name="sortOrder" type="numeric" required="true">

		<cftransaction>
		<cfquery name="qryGetSetAsideTypes" datasource="#request.dsn#">
		update	lu_smb_setaside
		set		sort_order = #arguments.sortOrder#,
				smb_setaside_desc = '#arguments.description#'
		where	smb_setaside_id = #arguments.setasideID#
		</cfquery>

		<cfset application.outility.insertSystemAudit (
					description="Small Business Setaside Category Updated: #arguments.description#",
					userID="#session.userID#")>
		</cftransaction>

	</cffunction>

	<cffunction name="deleteSetAside" access="public" returntype="void" hint="Deletes Setaside Category">
		<cfargument name="setasideID" type="numeric" required="true">

		<cftransaction>
		<cfquery name="qryGetSetAsideTypes" datasource="#request.dsn#">
		select	smb_setaside_desc as description
		from	lu_smb_setaside
		where	smb_setaside_id = #arguments.setasideID#
		</cfquery>

		<cfquery name="qryDeleteSetAsideTypes" datasource="#request.dsn#">
		delete
		from	lu_smb_setaside
		where	smb_setaside_id = #arguments.setasideID#
		</cfquery>

		<cfset application.outility.insertSystemAudit (
					description="Small Business Setaside Category Deleted: #qryGetSetAsideTypes.description#",
					userID="#session.userID#")>
		</cftransaction>
	</cffunction>

	<cffunction name="getUnfundedAAPPs" access="public" returntype="query" hint="Gets list of AAPPs that have no associated FOPs">

		<cfquery name="getUnfundedAAPPs" datasource="#request.dsn#">
		select	aapp.aapp_num aappNum,
				aapp_program_activity(aapp.aapp_num) as programActivity,
				date_start dateStart,
				center_name as centerName
		from	aapp, center, fop
		where	aapp.center_id = center.center_id (+) and
				aapp.aapp_num = fop.aapp_num (+) and
				fop.aapp_num is null
		order	by aappNum
		</cfquery>

		<cfreturn getUnfundedAAPPs>
	</cffunction>

	<cffunction name="deleteUnfundedAAPP" access="public" returntype="struct" hint="Deletes AAPP">
		<cfargument name="aappNum" type="numeric" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<!--- just to make sure this AAPP has no FOPs at time of deletion --->
		<cfquery name="verifyUnfundedAAPP" datasource="#request.dsn#">
		select	fop_id
		from	fop
		where	aapp_num = #arguments.aappNum#
		</cfquery>

		<cfif verifyUnfundedAAPP.recordcount> <!--- fop records exist, can not delete --->

			<cfset success = "false">
			<cfset errorMessages = listAppend(errorMessages,"This AAPP has associated FOP records. It can not be deleted.","~")>
			<cfset errorFields = listAppend(errorFields,"txtAAPPNum")>

		<cfelse>		 <!--- delete AAPP --->

			<cftransaction>
					<!--- call stpred procedure to delete AAPP --->
                    <cfstoredproc procedure="p_delete_aapp_unfunded" datasource="#request.dsn#">
                        <cfprocparam cfsqltype="cf_sql_integer" dbvarname="p_aapp_num" value="#arguments.aappNum#">
                    </cfstoredproc>
        
                    <cfset application.outility.insertSystemAudit (
                            description="AAPP #arguments.aappNum# deleted.",
                            userID="#session.userID#")>
			</cftransaction>

		</cfif>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

		<cfreturn stcResults>

	</cffunction>

	<cffunction name="getSystemSettingInfo" access="public" returntype="query" hint="returns recordset containing contents of system settings table">
		<cfargument name="systemSettingCode" type="string" required="no">
		<cfargument name="getHidden" type="boolean" required="true" default="0">

		<cfquery name="qrySystemSettings" datasource="#request.dsn#">
		select	system_setting_code systemSettingCode,
				system_setting_desc systemSettingDesc,
				value as systemSetting,
				required,
				locked,
				data_type dataType,
				sort_order sortOrder
		from	system_setting
		where 	1 = 1
		<cfif not arguments.getHidden>
			and admin_display = 1
		</cfif>
		<cfif isDefined("arguments.systemSettingCode")>
			and system_setting_code = '#arguments.systemSettingCode#'
		</cfif>
		order	by sort_order
		</cfquery>

		<cfreturn qrySystemSettings>

	</cffunction>


	<cffunction name="saveSystemSetting" access="public" returntype="struct" hint="handles saving of system setting data admin form">
		<cfargument name="formData" type="struct" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cftransaction>
		<!--- loop through list of form fields --->
		<cfloop list="#arguments.formData.hidFieldList#" index="settingCode" delimiters="~~">
			<!--- update value in table, as long as setting is not locked" --->
			<cfif not(arguments.formData[settingCode & "~~locked"])>

				<!--- remove commas if numeric value --->
				<cfif listFind("int_pos, rate", arguments.formData[settingCode & "~~datatype"])>
					<cfset updateVal = replaceNoCase(arguments.formData[settingCode], ",", "", "all")>
				<cfelse>
					<cfset updateVal = arguments.formData[settingCode]>
				</cfif>

				<cfset temp = this.updateSystemSetting(settingCode,updateVal)>
			</cfif>
		</cfloop>

		<cfset application.outility.insertSystemAudit (
					description="System Settings Updated",
					userID="#session.userID#")>

		</cftransaction>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

		<cfreturn stcResults>

	</cffunction>


	<cffunction name="updateSystemSetting" access="public" returntype="void" hint="updates single system setting value">
		<cfargument name="systemSettingCode" type="string" required="yes">
		<cfargument name="systemSettingValue" type="string" required="yes">

		<cfquery name="qryUpdateSystemSetting" datasource="#request.dsn#">
		update	system_setting
		set		value = <cfif arguments.systemSettingValue neq "">'#arguments.systemSettingValue#'<cfelse>null</cfif>,
				update_user_id = '#session.userID#',
				update_function = '#request.auditVarUpdate#',
				update_time = sysdate
		where	system_setting_code = '#arguments.systemSettingCode#'
		</cfquery>

	</cffunction>

	<cffunction name="getRCCCodeList" access="public" returntype="query" hint="Gets list of RCC Codes">
		<cfargument name="rccOrg" type="string" required="no">
		<cfargument name="rccFund" type="string" required="no">
		<cfargument name="fy" type="numeric" required="no">

		<cfquery name="qryRCCCodeList" datasource="#request.dsn#">
		select	rcc_org as rccOrg,
				rcc_fund as rccFund,
				fy,
				ops_cra as opscra,
				arra_ind as arra_ind,
				approp_py as appropPY,
				last_oblig_py as lastPY,
				funding_office_num as fundingOfficeNum,
				proj1_code as proj1Code,
				(select count(footprint_id)
				from footprint f
				where f.fy = r.fy and
					  f.rcc_org = r.rcc_org and
					  f.rcc_fund = r.rcc_fund) as rccUsed

		from	rcc_code r
		where	1=1
			<cfif isDefined("arguments.rccOrg")>
				and rcc_org = '#arguments.rccOrg#'
			</cfif>
			<cfif isDefined("arguments.rccFund")>
				and rcc_fund = '#arguments.rccFund#'
			</cfif>
			<cfif isDefined("arguments.fy")>
				and fy = '#arguments.fy#'
			</cfif>
		order by fy, rcc_org, rcc_fund
		</cfquery>

		<cfreturn qryRCCCodeList>
	</cffunction>

	<cffunction name="getRCCfyList" access="public" returntype="query" hint="Gets list of distinct FYs from RCC Codes table">

		<cfquery name="qryRCCfyList" datasource="#request.dsn#">
		select	distinct fy
		from	rcc_code
		order by fy
		</cfquery>

		<cfreturn qryRCCfyList>
	</cffunction>


	<cffunction name="saveRCCCode" access="public" returntype="struct" hint="handles saving of RCC code data admin form">
		<cfargument name="formData" type="struct" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">


		<cfif arguments.formData.hidMode eq "add">

			<!--- check to make sure this rcc code doesn't already exist --->
			<cfquery name="qryCheckRCC" datasource="#request.dsn#">
			select	fy
			from	rcc_code
			where	fy = #arguments.formData.fy# and
					rcc_org = '#arguments.formData.rccOrg#' and
					rcc_fund = '#arguments.formData.rccFund#'
			</cfquery>

			<cfif qryCheckRCC.recordcount> <!--- rcc code already exists, can not insert --->

				<cfset success = "false">
				<cfset errorMessages = listAppend(errorMessages,"This RCC Code already exists.","~")>

			<cfelse>

				<cftransaction>

				<cfinvoke method="insertRccCode"
						fy="#arguments.formData.fy#"
						rccOrg="#arguments.formData.rccOrg#"
						rccFund="#arguments.formData.rccFund#"
						opscra="#arguments.formData.opscra#"
						arra_ind="#arguments.formData.arra_ind#"
						appropPY="#arguments.formData.appropPY#"
						lastPY="#arguments.formData.lastPY#"
						fundingOfficeNum="#arguments.formData.fundingOfficeNum#"
						proj1Code="#arguments.formData.proj1Code#">

				<cfset application.outility.insertSystemAudit (
							description="RCC Code Inserted",
							userID="#session.userID#")>

				</cftransaction>
			</cfif>


		<cfelseif arguments.formData.hidMode eq "delete">

			<!--- check to make sure this rcc code isn't related to footprint records --->
			<cfquery name="qryCheckRCCFootprint" datasource="#request.dsn#">
			select	footprint_id
			from	footprint
			where	fy = #arguments.formData.fy# and
					rcc_org = '#arguments.formData.rccOrg#' and
					rcc_fund = '#arguments.formData.rccFund#'
			</cfquery>

			<cfif qryCheckRCCFootprint.recordcount> <!--- rcc code exists in footprint table, can not delete --->

				<cfset success = "false">
				<cfset errorMessages = listAppend(errorMessages,"This RCC Code is related to footprint records. It can not be deleted.","~")>

			<cfelse>

				<cftransaction>

				<cfinvoke method="deleteRccCode"
						fy="#arguments.formData.fy#"
						rccOrg="#arguments.formData.rccOrg#"
						rccFund="#arguments.formData.rccFund#">

				<cfset application.outility.insertSystemAudit (
							description="RCC Code Deleted",
							userID="#session.userID#")>

				</cftransaction>
			</cfif>

		</cfif> <!--- add or delete mode? --->


		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

		<cfreturn stcResults>

	</cffunction>


	<cffunction name="insertRCCCode" access="public" returntype="void" hint="Inserts new RCC Code">
		<cfargument name="fy" type="numeric" required="yes">
		<cfargument name="rccOrg" type="string" required="yes">
		<cfargument name="rccFund" type="string" required="yes">
		<cfargument name="opscra" type="string" required="yes">
		<cfargument name="arra_ind" type="numeric" required="no" default="0">
		<cfargument name="appropPY" type="numeric" required="yes">
		<cfargument name="lastPY" type="numeric" required="yes">
		<cfargument name="fundingOfficeNum" type="numeric" required="yes">
		<cfargument name="proj1Code" type="string" required="no">

		<cfquery name="qryInsertRCCCode" datasource="#request.dsn#">
		insert into rcc_code (
			fy,
			rcc_org,
			rcc_fund,
			ops_cra,
			arra_ind,
			approp_py,
			last_oblig_py,
			funding_office_num,
			<cfif isDefined("arguments.proj1Code")>proj1_code,</cfif>
			update_user_id,
			update_function,
			update_time)
		values (
			#arguments.fy#,
			'#arguments.rccOrg#',
			'#arguments.rccFund#',
			'#arguments.opscra#',
			#arguments.arra_ind#,
			#arguments.appropPY#,
			#arguments.lastPY#,
			#arguments.fundingOfficeNum#,
			<cfif isDefined("arguments.proj1Code")>'#arguments.proj1Code#',</cfif>
			'#session.userID#',
			'#request.auditVarInsert#',
			sysdate)
		</cfquery>

	</cffunction>


	<cffunction name="deleteRCCCode" access="public" returntype="void" hint="Deletes RCC Code">
		<cfargument name="fy" type="numeric" required="yes">
		<cfargument name="rccOrg" type="string" required="yes">
		<cfargument name="rccFund" type="string" required="yes">

		<cfquery name="qryDeleteRCCCode" datasource="#request.dsn#">
		delete
		from	rcc_code
		where	rcc_org = '#arguments.rccOrg#'
				and rcc_fund = '#arguments.rccFund#'
				and fy = '#arguments.fy#'
		</cfquery>

	</cffunction>

	<cffunction name="getBATransferPercent" access="public" returntype="query" hint="Gets list of (or individual) BA transfer percentages">
		<cfargument name="baType" type="string" required="yes">
		<cfargument name="costCatID" type="numeric" required="no">

		<cfquery name="qryGetBATransferPercent" datasource="#request.dsn#">
		select t.cost_cat_id as costCatID,
		max(q1) as q1,
		max(q2) as q2,
		max(q3) as q3,
		max(q4) as q4,
		cost_cat_code as costCatCode,
		cost_cat_desc as costCatDesc
		from
			(
			select cost_cat_id,
			case when quarter = 1 then transfer_percent end as Q1,
			case when quarter = 2 then transfer_percent end as Q2,
			case when quarter = 3 then transfer_percent end as Q3,
			case when quarter = 4 then transfer_percent end as Q4
			from ba_transfer_percent
			where type='#arguments.baType#'
			<cfif isDefined("arguments.costCatID")>
				and cost_cat_id = #arguments.costCatID#
			</cfif>
			) t,
			lu_cost_cat
		where t.cost_cat_id = lu_cost_cat.cost_cat_id
		group by t.cost_cat_id, cost_cat_code, cost_cat_desc
		order by cost_cat_code
		</cfquery>

		<cfreturn qryGetBATransferPercent>
	</cffunction>

	<cffunction name="saveBATRansferPercent" access="public" returntype="struct" hint="Saves results from BA Transfer Percent form">
		<cfargument name="formData" type="struct" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cftransaction>
		<!--- loop through list of form fields --->
		<cfloop list="#arguments.formData.hidCostCatList#" index="costCatID">
			<cfloop index="q" from="1" to="4">
				<!--- update value in table --->
				<cfset temp = this.updateTransferPercent(arguments.formData.hidBAtype,costCatID,q,arguments.formData[costCatID & "_q" & q])>
			</cfloop>
		</cfloop>

		<cfset application.outility.insertSystemAudit (
					description="BA Transfer Percentages Updated",
					userID="#session.userID#")>

		</cftransaction>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

		<cfreturn stcResults>

	</cffunction>


	<cffunction name="updateTransferPercent" access="public" returntype="void" hint="updates single ba transfer percent value">
		<cfargument name="baType" type="string" required="yes">
		<cfargument name="costCatID" type="numeric" required="yes">
		<cfargument name="quarter" type="numeric" required="yes">
		<cfargument name="percent" type="numeric" required="yes">


		<cfquery name="qryUpdateTransferPercent" datasource="#request.dsn#">
		update	ba_transfer_percent
		set		transfer_percent = #arguments.percent#,
				update_user_id = '#session.userID#',
				update_function = '#request.auditVarUpdate#',
				update_time = sysdate
		where	cost_cat_id = #arguments.costCatID# and
				quarter = #arguments.quarter# and
				type = '#arguments.baType#'
		</cfquery>

	</cffunction>

<!------------------------------------->
<!--- Release Notes admin functions --->
<!------------------------------------->

	<!--- Get Release Information --->
	<cffunction name="getRelease" access="public" returntype="query">
		<cfargument name="rID" type="numeric" required="no" default="0">
		<cfargument name="rItemID" type="numeric" required="no" default="0">
		<cfargument name="releaseList" type="string" required="no" default="false">

		<cfquery name="qryGetRelease" datasource="#request.dsn#">
			Select LU_Release.RELEASE_ID as releaseID,
				   LU_Release.RELEASE_NUMBER as releaseNo,
				   LU_Release.RELEASE_NAME as ReleaseName,
				   LU_Release.RELEASE_DATE as ReleaseDate<cfif not arguments.releaseList>,
				   Release_Note.RELEASE_NOTE_ID as ReleaseItemID,
				   Release_Note.RELEASE_ITEM_DESCRIPTION as ReleaseItemDesc,
				   Release_Note.Sort_Order as SortOrder</cfif>
			FROM   <cfif not arguments.releaseList>Release_Note,</cfif> LU_Release
			<cfif not arguments.releaseList>
				Where  LU_Release.Release_ID = Release_Note.Release_ID(+)
				<cfif arguments.rID neq 0>
					and LU_Release.Release_ID = #arguments.rID#
				</cfif>
				<cfif arguments.rItemID neq	0>
					and Release_Note.Release_Note_ID = #arguments.rItemID#
				</cfif>
			</cfif>
			Order By LU_Release.Release_Date DESC<cfif not arguments.releaseList>, Release_Note.Sort_Order ASC  </cfif>
		</cfquery>
	<cfreturn qryGetRelease>
	</cffunction>


	<!--- Save release --->
	<cffunction name="saveRelease" access="public" returntype="struct" hint="save release information">
		<cfargument name="formData" type="struct" required="yes">
		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cfif arguments.formData.hidReleaseID is 0>
			<cfinvoke component="#application.paths.components#dataadmin" method="insertRelease" returnvariable="insertStruct"
			ReleaseNo="#arguments.formData.txtReleaseNo#"
			ReleaseName="#arguments.formData.txtReleaseName#"
			ReleaseDate="#DateFormat(arguments.formData.txtReleaseDate,'mm/dd/yyyy')#">

			<cfset success = insertStruct.success>
			<cfset rid = insertStruct.rid>
			<cfset errorMessages = insertStruct.errorMessages>
			<cfset errorFields = insertStruct.errorFields>

		<cfelse>
			<cfinvoke component="#application.paths.components#dataadmin" method="updateRelease"
			ReleaseId="#arguments.formData.hidReleaseID#"
			ReleaseNo="#arguments.formData.txtReleaseNo#"
			ReleaseName="#arguments.formData.txtReleaseName#"
			ReleaseDate="#dateFormat(arguments.formData.txtReleaseDate, 'MM/DD/YYYY')#" returnvariable="updateStruct">

			<cfset success = updateStruct.success>
			<cfset rid = updateStruct.rid>
			<cfset errorMessages = updateStruct.errorMessages>
			<cfset errorFields = updateStruct.errorFields>

		</cfif>


		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.rid = rid>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

	<cfreturn stcResults>

	</cffunction>

	<!--- Insert a new Release --->
	<cffunction name="insertRelease" access="public" returntype="struct" hint="Insert a new Release">
		<cfargument name="ReleaseNo" type="string" required="yes">
		<cfargument name="ReleaseName" type="string" required="yes">
		<cfargument name="ReleaseDate" type="date" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cftransaction>
			<cfquery name="getNextReleaseID" datasource="#request.dsn#">
			select seq_release_id.nextval AS nextReleaseID
					FROM	dual
			</cfquery>

			<cfquery name="qrySaveRelease" datasource="#request.dsn#">
			insert into LU_Release
				(Release_ID,
				Release_number,
				Release_Name,
				Release_Date,
				Update_User_ID,
				Update_Function,
				Update_Time)
			Values
				(#getNextReleaseID.nextReleaseID#,
				 '#arguments.ReleaseNo#',
				 '#arguments.ReleaseName#',
				 to_date('#arguments.ReleaseDate#', 'MM/DD/YYYY'),
				 '#session.userID#',
				 '#request.auditvarinsert#',
				 sysdate)
			</cfquery>

			<cfset application.outility.insertSystemAudit (
			Description="Insert Release #arguments.ReleaseNo#",
			userID="#session.userID#")>
		</cftransaction>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.rid = getNextReleaseID.nextReleaseID>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

	<cfreturn stcResults>

	</cffunction>

	<!--- Update an existing Release --->
	<cffunction name="updateRelease" access="public" returntype="struct" hint="Update an existing Release">
		<cfargument name="ReleaseID" type="numeric" required="yes">
		<cfargument name="ReleaseNo" type="string" required="yes">
		<cfargument name="ReleaseName" type="string" required="yes">
		<cfargument name="ReleaseDate" type="date" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cftransaction>
			<cfquery name="qryUpdateRelease" datasource="#request.dsn#">
				update lu_release
				set Release_Number = '#arguments.ReleaseNo#',
					Release_Name = '#arguments.ReleaseName#',
					Release_Date  = to_date('#arguments.ReleaseDate#', 'MM/DD/YYYY'),
					update_user_id = '#session.userid#',
					update_function = '#request.auditvarupdate#',
					update_time = sysdate
				where Release_ID = #arguments.ReleaseID#
			</cfquery>

			<cfset application.outility.insertSystemAudit (
			Description="Update Release #arguments.ReleaseNo#",
			userID="#session.userID#")>
		</cftransaction>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.rid = arguments.ReleaseID>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

	<cfreturn stcResults>

	</cffunction>

	<!--- Delete Release and all of its Release Items --->
	<cffunction name="deleteRelease" access="public" returntype="struct">
		<cfargument name="releaseID" type="numeric" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<!--- get all notes for this release --->
		<cfinvoke component="#application.paths.components#dataadmin" method="getRelease" rId="#arguments.releaseID#" returnvariable="rstReleaseNotes">

		<!--- delete all notes for this release --->
		<cfif rstReleaseNotes.ReleaseItemID neq ''><!--- don't call this function if release doesn't have notes --->
			<cfloop query="rstReleaseNotes">
				<cfinvoke component="#application.paths.components#dataadmin" method="deleteReleaseItem" releaseItemID="#rstReleaseNotes.ReleaseItemID#" returnvariable="rstDelete">
			</cfloop>
		</cfif>


		<!--- delete the release --->

		<cftransaction>
		<cfquery name="deleteRelease" datasource="#request.dsn#">
			delete from LU_release
			where Release_ID = #arguments.releaseID#
		</cfquery>

		<cfset application.outility.insertSystemAudit (
			Description="Deleted Release",
			userID="#session.userID#")>
		</cftransaction>

		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

	<cfreturn stcResults>
	</cffunction>

	<!--- Get A Release Item --->
	<cffunction name="getReleaseItem" access="public" returntype="query" hint="Get information for specific release item">
		<cfargument name="rItemID" type="numeric" required="yes">

		<cfquery name="qryGetReleaseItem" datasource="#request.dsn#">
		select 	release_note.Release_Item_Description as itemDesc,
				release_note.release_id as releaseID,
				release_note.sort_order as sortOrder,
				lu_release.release_number as releaseNo,
				lu_release.release_name as releaseName,
				lu_release.release_date as releaseDate
		from	release_note, lu_release
		where 	release_note.release_note_id = #arguments.rItemID#
		and		release_note.release_id = lu_release.release_id
		</cfquery>

	<cfreturn qryGetReleaseItem>
	</cffunction>

	<!--- Get the sort order --->
	<cffunction name="getReleaseItemSortOrder" access="public" returntype="query">
		<cfargument name="rid" type="numeric" required="yes">

		<cfquery name="qryReleaseItemSortOrder" datasource="#request.dsn#">
			select 	Sort_Order as sortOrder
			from	Release_Note
			where	Release_ID = #arguments.rid#
			Order by	sort_order
		</cfquery>

		<cfreturn qryReleaseItemSortOrder>
	</cffunction>

	<!--- Save a release Item --->
	<cffunction name="saveReleaseItem" access="public" returntype="struct">
		<cfargument name="formData" type="struct" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cftransaction>
			<cfif arguments.formData.hidReleaseItemID is 0>
				<cfinvoke component="#application.paths.components#dataadmin" method="insertReleaseItem" returnvariable="stcInsertReleaseItem"
					ReleaseID="#arguments.formData.hidReleaseID#"
					ReleaseItemDesc="#arguments.formData.txtItemDesc#"
					SortOrder="#arguments.formData.cboSortOrder#">
				<cfif stcInsertReleaseItem.success>
					<cfset rItemID = stcInsertReleaseItem.rItemID>
				<cfelse>
					<cfset rItemID = arguments.formData.hidRItemID>
					<cfset success = "false">
					<cfset errorMessages = stcInsertReleaseItem.errorMessages>
					<cfset errorFields = stcInsertReleaseItem.errorFields>
				</cfif>

			<cfelse>
				<cfinvoke component="#application.paths.components#dataadmin" method="updateReleaseItem" returnvariable="updateReleaseItem"
					ReleaseItemID="#arguments.formData.hidReleaseItemID#"
					ReleaseItemDesc="#arguments.formData.txtItemDesc#"
					sortOrder="#arguments.formData.cboSortOrder#">

					<cfset rItemID = arguments.formData.hidReleaseItemID>
				<cfif not updateReleaseItem.success>
					<cfset success = "false">
					<cfset errorMessages = insertReleaseItem.errorMessages>
					<cfset errorFields = insertReleaseItem.errorFields>
				</cfif>

			</cfif>

			<cfif arguments.formData.cboSortOrder neq arguments.formData.hidOldSortOrder>
				<!--- update sort order if changed --->
				<cfinvoke component="#application.paths.components#dataadmin" method="ReleaseSortOrder"
					rId="#arguments.formData.hidReleaseID#"
					ReleaseItemID="#rItemID#"
					rItemSortOrder="#arguments.formData.cboSortOrder#"
					rItemSortOrderOld="#arguments.formData.hidOldSortOrder#">
			</cfif>
		</cftransaction>

		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.rItemid = rItemID>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

	<cfreturn stcResults>

	</cffunction>
	<!--- Insert New Release Item --->
	<cffunction name="insertReleaseItem" access="public" returntype="struct">
		<cfargument name="ReleaseID" type="numeric" required="yes">
		<cfargument name="ReleaseItemDesc" type="string" required="yes">
		<cfargument name="SortOrder" type="numeric" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cfquery name="qryGetReleaseItemID" datasource="#request.dsn#">
			select seq_release_note.nextval AS nextReleaseItemID
				FROM	dual
		</cfquery>

		<cfset rItemId = qryGetReleaseItemID.nextReleaseItemID>


			<cfquery name="qryInsertReleaseItem" datasource="#request.dsn#">
				Insert into Release_Note
					(Release_ID,
					Release_Note_ID,
					Release_Item_Description,
					Sort_Order,
					Update_User_ID,
					Update_Function,
					Update_Time)
				Values
					(#arguments.ReleaseID#,
					#qryGetReleaseItemID.nextReleaseItemID#,
					'#arguments.ReleaseItemDesc#',
					#arguments.SortOrder#,
					'#session.userID#',
					'#request.auditvarinsert#',
					sysdate)
			</cfquery>

	<cfset application.outility.insertSystemAudit (
			Description="Insert Release Item for Release #arguments.ReleaseID#",
			userID="#session.userID#")>


		<!--- set up structure to return --->
		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.rItemid = rItemID>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

	<cfreturn stcResults>
	</cffunction>

	<!--- Update existing Release Item --->
	<cffunction name="updateReleaseItem" access="public" returntype="struct">
		<cfargument name="releaseItemID" type="numeric" required="yes">
		<cfargument name="releaseItemDesc" type="string" required="yes">
		<cfargument name="sortOrder" type="numeric" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">


		<cfquery name="qryUpdateReleaseItem" datasource="#request.dsn#">
			update Release_Note
			set Release_Item_Description = '#arguments.ReleaseItemDesc#',
				Sort_Order = #arguments.sortOrder#,
				update_user_id = '#session.userid#',
				update_function = '#request.auditvarupdate#',
				update_time = sysdate
			where Release_Note_Id = #arguments.releaseItemID#
		</cfquery>

		<cfset rItemId = arguments.ReleaseItemID>

		<cfset application.outility.insertSystemAudit (
			Description="Update Release Item #arguments.ReleaseItemID#",
			userID="#session.userID#")>



		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.rItemid = rItemID>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>

	<cfreturn stcResults>
	</cffunction>

	<!--- Delete Release Item --->
	<cffunction name="deleteReleaseItem" access="public" returntype="struct">
		<cfargument name="releaseItemID" type="numeric" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cfquery name="qryDeleteReleaseItem" datasource="#request.dsn#">
		Delete from Release_Note
		Where	Release_Note_Id = #arguments.releaseItemID#
		</cfquery>

		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.errorMessages = errorMessages>
		<cfset stcResults.errorFields = errorFields>
	<cfreturn stcResults>
	</cffunction>

	<!--- Release Item Sort Order --->
	<cffunction name="ReleaseSortOrder" access="public">
		<cfargument name="rId" type="numeric" required="yes">
		<cfargument name="releaseItemId" type="numeric" required="yes">
		<cfargument name="rItemSortOrder" type="numeric" required="yes">
		<cfargument name="rItemSortOrderOld" type="numeric" required="yes">

		<cfquery name="getSortOrder" datasource="#request.dsn#">
			select 	release_note_id as rItemID,
				   	sort_order as oldSortOrder
			from	release_note
			where 	release_id = #arguments.rid#
			and		release_note_id <> #arguments.releaseItemID#
			<cfif arguments.rItemSortOrder lt arguments.rItemSortOrderOld>
				and 	sort_order >= #arguments.rItemSortOrder#
			<cfelse>
				and		sort_order <= #arguments.rItemSortOrder#
			</cfif>
			order by	sort_order <cfif arguments.rItemSortOrder gt arguments.rItemSortOrderOld> DESC</cfif>
		</cfquery>

		<cfset newSortOrder = arguments.rItemSortOrder>

		<cfloop query="getSortOrder">
			<cfif arguments.rItemSortOrder lt arguments.rItemSortOrderOld>
				<cfset newSortOrder = newSortOrder + 1>
			<cfelse>
				<cfset newSortOrder = newSortOrder - 1>
			</cfif>
			<cfquery name="adjustSortOrder" datasource="#request.dsn#">
				update  release_note
				set		sort_order = #newSortOrder#
				where	release_note_id = #rItemID#
			</cfquery>
		</cfloop>

	</cffunction>

	<cffunction name="getImportTypeInfo" access="public" returntype="query" hint="Returns list (or single) data import process type, with history info">
		<cfargument name="importType" type="string" required="no">
		<cfargument name="status" type="numeric" required="no">

		<cfquery name="qryGetImportInfo" datasource="#request.dsn#">
		SELECT	import_type_code importTypeCode,
				import_type_desc importTypeDesc,
				sort_order,
				allow_upload,
				 (SELECT MAX (date_import)
					FROM import_log
				   WHERE lu_import_type.import_type_code =
										  import_log.import_type_code
					 AND success = 1) datelastsuccess,
				 (SELECT MAX (date_import)
					FROM import_log
				   WHERE lu_import_type.import_type_code =
											 import_log.import_type_code
					 AND success = 0) datelastfail
		FROM	lu_import_type
		WHERE	1 = 1
				<cfif isDefined("arguments.status")>
					and status = #arguments.status#
				</cfif>
		ORDER	BY sort_order
		</cfquery>

		<cfreturn qryGetImportInfo>

	</cffunction>

	<cffunction name="f_getJfasSnapshot" access="remote" returntype="any" returnformat="plain" output="false" hint="Returns records from table 'JFAS_SNAPSHOT'">
    	<cfstoredproc procedure="JFAS.JFAS_SNAPSHOT_PKG.sp_getJfasSnapshot" returncode="no">
        		<cfprocresult name="spr_getJfasSnapshot" resultset="1">
		</cfstoredproc>	
        <!---<cfdump var="#spr_getJfasSnapshot#"><cfabort>--->
        <cfreturn spr_getJfasSnapshot>
    </cffunction>
				 


</cfcomponent>