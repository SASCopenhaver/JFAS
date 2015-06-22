<!---
page: aapp_mod.cfc

description: component that handles aapp mod functions

revisions:
2011-03-17	mstein	File created (JFAS Release 2.8)
--->
<cfcomponent displayname="aapp_mod" hint="Component that contains all queries and functions for AAPP Contract Mods">

	<cffunction name="getModListing" access="public" returntype="query" hint="Get list of mods for an AAPP">
		<cfargument name="aapp" type="numeric" required="yes">
		<cfargument name="sortBy" type="string" required="false" default="modNum">
		<cfargument name="sortDir" type="string" required="false" default="asc">

		<cfquery name="qryGetModListing" datasource="#request.dsn#">
		select	mod_id as modID,
                mod_num as modNum,
                date_issued as dateIssued,
                (select sum(funding_total)
                	from mod_funding mf
                	where mf.mod_id = mod.mod_id
                	and cost_cat_id in (select cost_cat_id from lu_cost_cat where fund_cat = 'OPS'))
				as opsFunding,
                (select sum(funding_total)
                	from mod_funding mf
                	where mf.mod_id = mod.mod_id
                	and cost_cat_id in (select cost_cat_id from lu_cost_cat where fund_cat = 'CRA'))
				as craFunding,
                (select sum(funding_total)
                	from mod_funding mf
                	where mf.mod_id = mod.mod_id) as totalFunding
        from	mod
        where	aapp_num = #arguments.aapp#
		order	by #arguments.sortBy# #arguments.sortDir#
		</cfquery>

		<cfreturn qryGetModListing>
	</cffunction>



	<cffunction name="getModData" access="public" returntype="struct" hint="Get full data for AAPP Contract Mod">
		<cfargument name="modID" type="numeric" required="true">

		<!--- get one-to-one data from MOD table --->
		<cfquery name="qryGetModData" datasource="#request.dsn#" maxrows="1">
		select	mod_id as modID,
				mod_num as modNum,
				aapp_num as aappNum,
				date_issued as dateIssued,
				update_time as dateEntered
		from	mod
		where	mod_id = #arguments.modID#
		</cfquery>

		<!--- get list of funding records from MOD_FUNDING table --->
		<cfquery name="qryGetModFundingData" datasource="#request.dsn#">
		select	mod_id as modID,
				mod_funding.cost_cat_id as costCatID,
				funding_change as fundingChange,
				funding_total as fundingTotal,
				cost_cat_desc as costCatDesc
		from	mod_funding, lu_cost_cat
		where	mod_funding.cost_cat_id = lu_cost_cat.cost_cat_id and
				mod_id = #arguments.modID#
		</cfquery>

		<cfset stcResults = StructNew()>
		<cfset stcResults.modData = qryGetModData>
		<cfset stcResults.modFundingData = qryGetModFundingData>

		<cfreturn stcResults>

	</cffunction>



	<cffunction name="getLatestModbyAAPP" access="public" returntype="struct" hint="Get latest Mod Data, for an AAPP Num">
		<cfargument name="aapp" type="numeric" required="true">

		<cfquery name="qryGetLatestModID" datasource="#request.dsn#" maxrows="1">
		select	mod_id
		from	mod
		where	aapp_num = #arguments.aapp#
		order	by mod_num desc
		</cfquery>

		<cfset stcResults = StructNew()>

		<cfif qryGetLatestModID.recordCount neq 0>
			<cfset stcResults = this.getModData(qryGetLatestModID.mod_id)>
			<cfset stcResults.results = "true">
		<cfelse>
			<cfset stcResults.results = "false">
		</cfif>

		<cfreturn stcResults>

	</cffunction>


	<cffunction name="formatModNum" access="public" returntype="string" hint="Puts Mod number into format that can be sorted">
		<cfargument name="oldModNum" type="string" required="yes">

		<cfset newModNum = "">

		<!--- starting with first character, loop through until finding non-numeric value --->
		<cfloop index="i" from="1" to="#len(arguments.oldModNum)#">
			<cfif not isnumeric(mid(arguments.oldModNum,i,1))>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfif i gt 1>
			<!--- format first segment (numeric) to be 3 digits --->
			<cfset newModNum = numberFormat(left(arguments.oldModNum,i-1),"000")>
		</cfif>
		<!-- from first non-numeric, through end of value - change to uppercase --->
		<cfset newModNum = newModNum & ucase(mid(arguments.oldModNum,i,len(arguments.oldModNum)-i+1))>

		<!--- don't allow more than 6 char --->
		<cfset newModNum = left(newModNum,6)>

		<cfreturn newModNum>
	</cffunction>


	<cffunction name="saveModData" access="public" returntype="struct" hint="Save form data (general and funding) for AAPP Contract Mod">
		<cfargument name="formData" type="struct" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">

		<cfset newModNum = formatModNum(arguments.formData.txtModNum)>

		<!--- validate data: begin --->
		<!--- check to make sure that there are no other mods for this AAPP with same mod number --->
		<cfquery name="qryCheckforDuplicate" datasource="#request.dsn#" maxrows="1">
		select	count(mod_id) as numDup
		from	mod
		where	aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.hidAAPPnum#"> and
				mod_num = '#newModNum#'
				<cfif arguments.formData.hidModID neq 0>
					and mod_id <> <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.hidModID#">
				</cfif>
		</cfquery>

		<cfif qryCheckforDuplicate.numDup gt 0>
			<cfset errorMessages = listAppend(errorMessages,"A mod with this number already exists for this AAPP.","~")>
		</cfif>
		<!--- validate data: end --->


		<cfif errorMessages eq ""><!--- if validation passed --->



			<cftransaction>
				<cfif arguments.formData.hidModID neq 0> <!--- EDIT mode --->

					<!--- update mod data --->
					<cfset temp = updateMod(arguments.formData.hidModID,arguments.formData.hidAAPPNum,newModNum,arguments.formData.txtDateIssued,session.userID)>

					<!--- delete existing funding data --->
					<cfset temp = deleteModFunding(arguments.formData.hidModID)>

					<cfset useModID = arguments.formData.hidModID>
					<cfset auditAction = "updated">

				<cfelse> <!--- INSERT mode --->

					<!--- insert mod data (receive new mod ID --->
					<cfset useModID = insertMod(arguments.formData.hidAAPPnum,newModNum,arguments.formData.txtDateIssued,session.userID)>
					<cfset auditAction = "created">

				</cfif>

				<!--- package funding data into query object --->
				<cfset qryModFundingInsert = QueryNew("modID,costCatID,fundingTotal")>
				<cfloop collection="#arguments.formData#" item="fieldName">
					<cfif findNoCase("txtFunding_",fieldName)>
						<cfset temp = QueryAddRow(qryModFundingInsert)>
						<cfset temp = QuerySetCell(qryModFundingInsert, "modID", useModID)>
						<cfset temp = QuerySetCell(qryModFundingInsert, "costCatID", listGetAt(fieldName,2,"_"))>
						<cfset temp = QuerySetCell(qryModFundingInsert, "fundingTotal", #replace(arguments.formData[fieldName],",","","all")#)>
					</cfif>
				</cfloop>
				<!--- insert mod funding data --->
				<cfset temp = insertModFunding(qryModFundingInsert, session.userID)>

				<!--- insert audit record --->
				<cfset application.outility.insertSystemAudit (
					aapp="#arguments.formData.hidAAPPnum#",
					sectionID="350",
					description="Mod #arguments.formData.txtModNum# (ID #useModID#) #auditAction#",
					userID="#session.userID#")>

			</cftransaction>

		<cfelse>
			<cfset success = "false">
		</cfif>

		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>
		<cfset stcResults.errorMessages = errorMessages>
		<cfif success>
			<cfset stcResults.modID = useModID>
		</cfif>
		<cfreturn stcResults>

	</cffunction>


	<cffunction name="insertMod" access="public" returntype="numeric" hint="Insert general data for AAPP Contract Mod">
		<cfargument name="aappNum" type="numeric" required="true">
		<cfargument name="modNum" type="string" required="true">
		<cfargument name="dateIssued" type="string" required="false">
		<cfargument name="userID" type="string" required="false" default="sys">

		<!--- get next Mod ID from db --->
		<cfquery name="qryGetNextMod" datasource="#request.dsn#">
		select seq_mod.nextval as newMod from dual
		</cfquery>
		<cfset newModID = qryGetNextMod.newMod>

		<!--- insert mod --->
		<cfquery name="qryInsertMod" datasource="#request.dsn#">
		insert into MOD	(mod_id,
						 mod_num,
						 aapp_num,
						 date_issued,
						 update_user_id,
						 update_function, update_time)
				values	(<cfqueryparam cfsqltype="cf_sql_integer" value="#newModID#">,
						 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.modNum#">,
						 <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aappNum#">,
						 <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dateIssued#">,
						 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">,
						 'I', sysdate)
		</cfquery>
		<cfreturn newModID>

	</cffunction>


	<cffunction name="deleteMod" access="public" hint="Delete AAPP Contract Mod">
		<cfargument name="modID" type="numeric" required="true">

		<cftransaction>

		<!--- get Mod Number --->
		<cfquery name="qryGetModNum" datasource="#request.dsn#">
		select	mod_num, aapp_num
		from	mod
		where	mod_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.modID#">
		</cfquery>

		<!--- delete mod funding --->
		<cfset temp = deleteModFunding(arguments.modID)>

		<!--- delete mod --->
		<cfquery name="qryDeleteMod" datasource="#request.dsn#">
		delete
		from	mod
		where	mod_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.modID#">
		</cfquery>

		<!--- insert audit record --->
		<cfset application.outility.insertSystemAudit (
			aapp="#qryGetModNum.aapp_num#",
			sectionID="350",
			description="Mod #qryGetModNum.mod_num# (ID #arguments.modID#) deleted",
			userID="#session.userID#")>

		</cftransaction>

	</cffunction>


	<cffunction name="updateMod" access="public" hint="Update general data for AAPP Contract Mod">
		<cfargument name="modID" type="numeric" required="true">
		<cfargument name="aappNum" type="numeric" required="true">
		<cfargument name="modNum" type="string" required="true">
		<cfargument name="dateIssued" type="string" required="false">
		<cfargument name="userID" type="string" required="false" default="sys">

		<cfquery name="qryUpdateMod" datasource="#request.dsn#">
		update	MOD
		set		mod_num = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.modNum#">,
				aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.aappNum#">,
				date_issued = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dateIssued#">,
				update_user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">,
				update_function = 'U',
				update_time = sysdate
		where	mod_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.modID#">
		</cfquery>


	</cffunction>


	<cffunction name="insertModFunding" access="public" hint="Insert funding data for AAPP Contract Mod">

		<cfargument name="qryFundingData" type="query" required="true">
		<cfargument name="userID" type="string" required="false" default="sys">

		<!--- layout of query expected: --->
		<!--- mod_id: numeric, id of mod --->
		<!--- cost_cat_id: numeric, value of cost category (from lu_cost_cat.cost_cat.id) --->
		<!--- funding_total: numeric, dollar amount --->

		<cfloop query="qryFundingData"> <!--- loop through each record - one per mod, and cost cat --->
			<cfquery name="insertModFunding" datasource="#request.dsn#">
			insert into mod_funding (mod_id,
									 cost_cat_id,
									 funding_total,
									 update_user_id,
									 update_function,
									 update_time)
							values	(#modId#,
									 #costCatID#,
									 #fundingTotal#,
									 '#arguments.userID#',
									 'I',
									 sysdate)
			</cfquery>
		</cfloop>

	</cffunction>


	<cffunction name="deleteModFunding" access="private" hint="Delete funding data for AAPP Contract Mod">
		<cfargument name="modID" type="numeric" required="true">

		<!--- delete mod funding --->
		<cfquery name="qryDeleteModFunding" datasource="#request.dsn#">
		delete
		from	mod_funding
		where	mod_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.modID#">
		</cfquery>

	</cffunction>







</cfcomponent>

