<!---

aapp_note.cfc

revisions:
2009-10-13	mstein	page created
--->

<cfcomponent displayname="aapp_note" hint="contains all methods, functions related to AAPP Notes">

	<cffunction name="getAAPPNote" access="public" returntype="query" hint="Gets AAPP note, or list of notes">
		<cfargument name="aapp" type="numeric" required="no" default="0">
		<cfargument name="aappNoteID" type="numeric" required="no" default="0">
		<cfargument name="userID" type="string" required="no" default="">
		<cfargument name="status" type="string" required="no" default="1">

		<cfquery name="qryGetAAPPnotes" datasource="#request.dsn#">
		select	aapp_note_id, note, aapp_num,
				aapp_note.update_user_id, aapp_note.update_time,
				last_name, first_name
		from	aapp_note, user_jfas
		where	aapp_note.update_user_id = user_jfas.user_id (+)
		<cfif arguments.aappNoteID neq 0>
			and aapp_note_id = #arguments.aappNoteID#
		</cfif>
		<cfif arguments.aapp neq 0>
			and aapp_num = #arguments.aapp#
		</cfif>
		<cfif arguments.userID neq "">
			and update_user_id = '#arguments.userID#'
		</cfif>
		<cfif arguments.status eq "1">
			and status = 1
		</cfif>
		order	by aapp_note.update_time desc
		</cfquery>

		<cfreturn qryGetAAPPnotes>
	</cffunction>

	<cffunction name="getAAPPNoteCount" access="public" returntype="numeric" hint="Gets number of notes for this AAPP">
		<cfargument name="aapp" type="numeric" required="no" default="0">
		<cfargument name="status" type="string" required="no" default="1">

		<cfquery name="qryGetAAPPnoteCount" datasource="#request.dsn#">
		select	count(aapp_note_id) as numRecs
		from	aapp_note
		where	aapp_num = #arguments.aapp#
		<cfif arguments.status eq "1">
			and status = 1
		</cfif>
		</cfquery>

		<cfreturn qryGetAAPPnoteCount.numRecs>
	</cffunction>


	<cffunction name="saveAAPPnote" access="public" returntype="struct" hint="handles AAPP note form submission">
		<cfargument name="formData" type="struct" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cfif arguments.formData.hidMode eq "add">

			<cfif trim(arguments.formData.txtNote) eq "">
				<cfset errorMessages = listAppend(errorMessages, "Note text must be provided", ",")>
				<cfset errorFields = listAppend(errorFields, "txtNote", ",")>
				<cfset success = "false">
			</cfif>

			<cfif success>
				<cfinvoke component="#application.paths.components#aapp_note" method="insertAAPPNote"
					aappNum="#arguments.formData.hidAAPP#"
					note="#arguments.formData.txtNote#"
					userID="#session.userid#">
			</cfif>

		<cfelseif arguments.formData.hidMode eq "delete">

			<cfinvoke component="#application.paths.components#aapp_note" method="deleteAAPPNote"
				aappNoteID="#arguments.formData.hidAAPPnoteID#"
				aappNum="#arguments.formData.hidAAPP#"
				userID="#session.userid#">
		</cfif>


		<cfset stcResults = StructNew()>
			<cfset stcResults.success = success>
			<cfif not success>
				<cfset stcResults.errorMessages = errorMessages>
				<cfset stcResults.errorFields = errorFields>
			</cfif>

		<cfreturn stcResults>

	</cffunction>


	<cffunction name="insertAAPPNote" access="public" returntype="void">
		<cfargument name="aappNum" required="yes" type="numeric">
		<cfargument name="note" required="yes">
		<cfargument name="userID" required="no" type="string">

		<cftransaction>

		<cfquery name="qryInsertAAPPnote" datasource="#request.dsn#">
			Insert into	aapp_note (
					aapp_note_id,
					note,
					aapp_num,
					update_user_id,
					update_time)
				Values(
					seq_aapp_note.nextVal,
					'#arguments.note#',
					#arguments.aappNum#,
					'#arguments.userID#',
					sysdate)
		</cfquery>

		<cfset application.outility.insertSystemAudit (
			Description="Insert AAPP Note",
			userID="#arguments.userID#",
			aapp="#arguments.aappNum#")>

		</cftransaction>

	</cffunction>

	<cffunction name="deleteAAPPNote" access="public" returntype="void" hint="deactivates AAPP Note">
		<cfargument name="aappNoteID" required="yes" type="numeric">
		<cfargument name="aappNum" required="yes" type="numeric">
		<cfargument name="userID" required="no" type="string">

		<cftransaction>

		<cfquery name="qryDeleteAAPPnote" datasource="#request.dsn#">
		update	aapp_note
		set		status = 0
		where	aapp_note_id = #arguments.aappNoteID# and
				aapp_num = #arguments.aappNum#
		</cfquery>

	<cfset application.outility.insertSystemAudit (
			Description="Removed AAPP Note #arguments.aappNoteID# (AAPP #arguments.aappNum#)",
			userID="#arguments.userID#",
			aappNum="#arguments.aappNum#")>

		</cftransaction>

	</cffunction>

</cfcomponent>