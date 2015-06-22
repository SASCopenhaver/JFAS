<!--- index.cfm --->
<cfparam name="url.jfasAction" default="home">
<cfparam name="url.applyFilter" default="">

<!--- build the variables that are in request and session --->
<cftry>
	<cfinclude template="#application.paths.includes#sessionVariableSetup.cfm">
	<cfinclude template="#application.paths.includes#jfasCommon.cfm">
	<cfcatch type="any">
		<cflocation url = "logout.htm">
	</cfcatch>
</cftry>


<!--- testing
<CFDUMP VAR="#url#" LABEL="url BEFORE in index.cfm">
<CFDUMP VAR="#session#" LABEL="session in index.cfm">
<cfdump var="#application#" label="application in index.cfm">
<CFDUMP VAR="#request#" LABEL="request BEFORE in index.cfm">
<CFDUMP VAR="#cgi#" LABEL="cgi BEFORE in index.cfm">
<cfabort>


<CFDUMP VAR="#session#" LABEL="session in index.cfm">
<CFABORT>
END of testing --->


<cfswitch expression="#url.jfasAction#">
	<cfcase value = "home">
		<!--- performs initial setup of the divs, and loads all the javascript --->
		<cfinclude template="views/home.cfm">
	</cfcase>
	<cfcase value = "deadend">
		<cfdump var="#form#" label="reached dead end">
		<cfabort>
	</cfcase>
	<cfcase value = "dumpError">
		<cfset EmailScopes('Index.cfm received jfasAction=dumpError')>
		<cfinclude template="views/home.cfm">
	</cfcase>

	<cfdefaultcase>
		<cfinclude template="views/home.cfm">
	</cfdefaultcase>
</cfswitch>

<!--- end of index.cfm --->