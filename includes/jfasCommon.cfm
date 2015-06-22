<!--- jfascommon.cfm --->
<!--- these are routines that are included in various .cfcs and .cfms --->
<!--- these are NOT remote routines --->

<cfoutput>
<cffunction name="SendDebugEmail">

	<cfargument name="contentVariable">
	<cfargument name="subject">
	<cfargument name="targetEmail">

	<cfset var ret = "">
	<cftry>
		<cfmail to="#arguments.targetEmail#" from="#application.jfas_system_email#" cc="#application.jfas_system_email#" subject='(#UCase(application.cfEnv)#) #arguments.subject# #dateformat(Now(), "mm/dd")# #timeformat(Now(), "HH:mm:ss")#' type="html">
			#arguments.contentVariable#
		</cfmail>
		<cfcatch type="any">
			<CFSET ret = "Fatal:"&#cfcatch.message#>>
		</cfcatch>
		<cffinally>
			<cfreturn ret />
		</cffinally>
	</cftry>
</cffunction>

<cffunction name="EmailScopes">

	<cfargument name="subject">
	<cfargument name="content" required="no" default="none">

	<cfset var errortext="">
	<cfsavecontent variable="errortext">
		<cfset DumpScopes(arguments.content)>
	</cfsavecontent>
	<!--- may return a Fatal: error --->
	<cfreturn SendDebugEmail(contentVariable = errortext, subject = "#arguments.subject#", targetEmail = "#application.technical_poc_email#") />
</cffunction>

<cffunction name="DumpScopes">
	<cfargument name="content" required="no" default="none">
		<!--- looking for default value --->
		<cfif arguments.content NEQ 'none'>
		#arguments.content#<br>
		</cfif>
		<cfif IsDefined("url")>
			<cfdump var="#url#" label="URL" />
		</cfif>
		<br><br>
		<cfif IsDefined("form")>
			<cfdump var="#form#" label="Form" />
		</cfif>
		<br><br>
		<cfif IsDefined("cgi")>
			<cfdump var="#cgi#" label="CGI" />
		</cfif>
		<br><br>
		<cfif IsDefined("request")>
			<cfdump var="#request#" label="Request">
		</cfif>
		<br><br>
		<cfif IsDefined("session")>
			<cfdump var="#session#" label="Session">
		</cfif>
		<br><br>
		<cfif IsDefined("application")>
			<cfdump var="#application#" label="Application">
		</cfif>
		<br><br>

</cffunction> <!--- DumpScopes --->


</cfoutput>

<!--- END of jfascommon.cfm --->


