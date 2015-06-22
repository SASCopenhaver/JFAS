<!---
page: security.cfc

description: include file that takes care of security functions

revisions:
2007-03-07	mstein	check to see if regional user is viewing an AAPP from a different region
2007-07-23	mstein	allow regional office user access to CCCs
2011-12-02	mstein	changed aapp_summary to aapp_setup
--->

<cfif findNocase("\cfc", CGI.PATH_TRANSLATED) or
	  findNocase("\includes", CGI.PATH_TRANSLATED)>
	<!--- if someone is trying to access the non-content pages directly, kick them out --->
	<cflocation url="#application.paths.root#">
</cfif>

<cfif isDefined("form.btnSubmit")> <!--- form has been submitted --->
	<!--- make sure form has not been submitted from another server --->
	<cfif not len(cgi.http_referer) OR not findnocase(cgi.http_host, cgi.http_referer)>
		<cflocation url="#application.paths.root#">
	</cfif>
</cfif>

<!--- security for aapp folder --->
<cfif findNocase("\aapp\", CGI.PATH_TRANSLATED)>

	<cfset validRequest="true">

	<!--- make sure user has access to be in this folder --->
	<cfif not request.aappAccess>
		<cflocation url="#application.paths.accessRestricted#">
	</cfif>

	<!--- check that aapp exists in url, and that it is valid --->
	<cfif not isdefined("url.aapp")>
		<cfset validRequest="false">
	<cfelse>
		<cfif url.aapp eq 0>
			<cfif not findnocase("aapp_setup.cfm", cgi.SCRIPT_NAME) and not findnocase("aapp_setup_ccc.cfm", cgi.SCRIPT_NAME)>
				<cfset validRequest="false">
			</cfif>
		<cfelse>
			<cfinvoke component="#application.paths.components#aapp" method="isValidAAPP" aapp="#url.aapp#" returnvariable="isValid">
			<cfif not isValid>
				<cfset validRequest="false">
			</cfif>
		</cfif>
	</cfif>

	<cfif listfind("3,4", session.roleID) and (request.fundingOfficeNum neq session.region) and (request.agreementTypeCode neq "CC")>
		<!--- if regional user is trying to view AAPP in another region  --->
		<cfset validRequest="false">
	</cfif>

	<cfif not validRequest>
		<cflocation url="#application.paths.root#">
	</cfif>

</cfif>


<!--- security for reports folder --->
<cfif findNocase("\reports\", CGI.PATH_TRANSLATED)>

	<!--- make sure user has access to be in this folder --->
	<cfif not request.reportsAccess>
		<cflocation url="#application.paths.accessRestricted#">
	</cfif>

</cfif>

<!--- security for reports folder --->
<cfif findNocase("\admin\", CGI.PATH_TRANSLATED)>

	<!--- make sure user has access to be in this folder --->
	<cfif not request.adminAccess>
		<cflocation url="#application.paths.accessRestricted#">
	</cfif>

</cfif>

