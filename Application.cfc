<!---
page: Application.cfc

description:

revisions:
yjeng: 02/02/2007 Add current program year and current program year ccc
2007-03-07	mstein	Adjusted order of security include and aapp request (because security now uses aapp request info)
					Added application.paths.accessRestricted for redirect
					Took out automatic redirect to reports section for regional users
2007-04-03	yjeng	add CheckrstEstFopSort1.cfm
2007-06-05	mstein	added request.py_other
2013-12-27	mstein	removed sqlloader path from request scope
--->

<cfcomponent>
<cfscript>

// make the application name depend on the location of the code, so you can have multiple copies of the code running on one server
this.name = hash(getCurrentTemplatePath());
this.ApplicationTimeout = createtimespan(1,0,0,0);
this.ClientManagement = "true";
this.LoginStorage="session";
this.sessionmanagement = "true";
// normally should be 0,4,0,0 (4 hours)
this.sessiontimeout = createtimespan(0,4,0,0);
this.scriptProtect = "false";
this.setdomainCookies = "true";
this.datasource="jfas";
param name="url.fwreinit", default=false;
param name="url.aapp", default="";
param name="url.isBackground", default="no";
param name="session.userID", default="";

// this function is called in two places: onApplicationStart, and if fwreinit=true
function setupApplication (required fwreinit = 'true') {

	param name="application.appDataLoaded", default="false";
	if (BooleanFormat(arguments.fwreinit) ) {
		application.appDataLoaded = false;
	}
	if (NOT application.appDataLoaded) {
		include "includes/applicationVariablesSetup.cfm";
	}

	if ( IsDefined("session") AND structKeyExists(session, "userPreferences")) {
		// force the session to be set up again, upon a fwreinit
		structDelete( session, "userPreferences" );
	}

	return true;
}

// on Application Start

boolean function onApplicationStart () output="false" {
	return setupApplication(true);
} // onApplicationStart

void function setupSession () {

	session.ouser = CreateObject(application.paths.dotroot & "model.cfc.user");

	var nTitlebarHeight = 20; // height of alert title bar in px
	var nHeight = 500; // max height of alert box below title, in px.  Must agree with jfas.less
	var nWidth = 450; // width of alert box in px

	// get the session announcement from the database, and resize it
	var tAnnouncement = session.ouser.getSessionAnnouncement( nHeight, nWidth );

	session.Announcement = tAnnouncement.sString;
	session.nAnnouncementHeight = tAnnouncement.nHeight + nTitlebarHeight + 30; // in px. Fudge factor at bottom, "just to be sure"
	session.nAnnouncementWidth = tAnnouncement.nWidth;  // in px

	// these are the defaults for the "debug" variables.  On Request happens after this
	session.showDebug = false;
	session.debugemails = false;

}  // onSessionStart

void function onSessionStart () {

	return setupSession();

}  // onSessionStart

</cfscript>


<!--- on Request Start --->
<cffunction name="onRequestStart" returntype="boolean" output="false">
	<cfargument type="String" name="targetPage" required="true" />
	<cfsilent>
	<cfif BooleanFormat(url.fwreinit) OR NOT structKeyExists(session, "userPreferences")>
		<!--- force a reinitialization of the application variables --->
		<cfset setupApplication(true)>
		<cfset onSessionStart()>
	</cfif>
	<!--- set request.dsn for historical reasons.  Used in various .cfc's --->
	<cfset request.dsn="jfas">
	<!--- belldr 4/15/2014 - if there is a url parameter changing the status of these parameters, set the session related session variable.  Otherwise, leave the session variable alone --->
	<!--- name of allow debug output Param is "showDebug" for backwards capability--->
	<cfif structKeyExists (url, 'showDebug') >
		<cfif BooleanFormat(url.ShowDebug) >
			<cfset session.showDebug = true>
		<cfelse>
			<cfset session.showDebug = false>
		</cfif>
	</cfif>

	<cfif structKeyExists (url, 'debugemails') >
		<cfif BooleanFormat(url.debugemails) >
			<cfset session.debugemails = true>
		<cfelse>
			<cfset session.debugemails = false>
		</cfif>
	</cfif>

	<!--- belldr 11/25/2013 make cfsetting follow session variable --->
	<cfoutput><cfsetting showdebugoutput="#session.showDebug#" ></cfoutput>

	</cfsilent>

	<cfif NOT BooleanFormat(isBackground) >

		<!--- this section is for FOREGROUND requests, i.e. non-ajax --->
		<!--- * * * these seem to be session-level things * * * --->
		<!--- this url.session_id is NOT A CF sessionID (no underscore in that variable name) for us.  It is a "sessionID" in common.sessions_cf, known by P:\\grantee_prod\application.cfm --->
		<cfif isDefined("url.session_id")>
			<!--- User has just logged IN from EBSS --->
			<cfif NOT (structKeyExists(session, "ouser"))>
				<!--- start a CF session for this user --->
				<cfset onSessionStart()>
			</cfif>
			<!--- set session.userID, session.userPreferences, etc, based on the login from EBSS --->
			<!--- this is NOT an ajax call --->
			<!--- this component is "permanently" in the session scope.  Set the session variables for this user, from Oracle --->
			<cfset session.ouser.ClearUserPreferences()>

			<cfset session.ouser.loginUser(EBSSsession_ID: "#url.session_id#")>
			<cftry>
			<cflocation url="#application.paths.root#">
			<cfcatch>
			</cfcatch>
			</cftry>
		</cfif> <!--- isDefined("url.session_id") --->

		<!--- this is looking at a CF session.  An ajax call should set url.IsBackground, so this should NOT be called --->
		<cfif session.userID eq "">
			<!--- this could be a timeout if the browser is left up over night --->
			<!--- clear the session information about the user --->
			<cfset temp = structDelete(session,"userPreferences")>
			<!--- close the user window --->
			<a href="#application.paths.root#logout.htm">It appears your session has timed out. Please log in again.</a>
		</cfif>

		<cfif isdefined("url.logout")>
			<!--- force a logout --->
			<!--- this writes from session.userPreferences to the Oracle database --->
			<!--- clear the session information about the user --->
			<cfset session.userID = "">
			<!--- this works, except if session is not defined --->
			<cftry>
				<cfset temp = structDelete(session,"userPreferences")>
			<cfcatch>
			</cfcatch>
			</cftry>
			<!--- close the user window --->
			<cflocation url="#application.paths.root#logout.htm">
		</cfif>

		<!--- set REQUEST??? variables for user access level, based on role.  Why not use session variables ? --->
		<cftry>
			<cfset rstUserAccessSettings 	= session.ouser.getUserAccessSettings(roleID:"#session.roleID#")>
			<cfset request.aappAccess		= rstUserAccessSettings.aappAccess>
			<cfset request.adminAccess		= rstUserAccessSettings.adminAccess>
			<cfset request.budgetAccess		= rstUserAccessSettings.budgetAccess>
			<cfset request.reportsAccess	= rstUserAccessSettings.reportsAccess>
			<cfcatch>
				<!--- show user a "JFAS System Problem" page --->
				<cflocation url="#application.paths.root#problem.htm">
			</cfcatch>
		</cftry>
		<!--- if user is not from JobCorp national office, direct to reports section
		<cfif (session.roleID gt 2) and (not findNocase("\reports\", CGI.path_translated))>
			<cflocation url="#application.paths.reports#">
		</cfif>--->
		<!--- form.quickaapp is defined when coming from a quick search for an aapp number --->
		<cfif isDefined("form.quickaapp")>
			<cfset url.aapp = form.quickaapp>
			<!--- set request variables for the particular aapp in url.aapp --->
			<cftry>
			<!--- this is an invoke, because there are a lot of scoped variables in there --->
			<cfinvoke component="#application.paths.components#aapp" method="aappRequest" aapp="#url.aapp#">
			<cfcatch>
			</cfcatch>
			</cftry>
		<!--- belldr 05/13/2014 changed from cgi.path_info, which does not show up on local CF server --->
		<cfelseif findNocase("\aapp\", CGI.path_translated)>
			<!--- set request variables for the particular aapp in url.aapp --->
			<cftry>
			<!--- this is an invoke, because there are a lot of scoped variables in there --->
			<cfinvoke component="#application.paths.components#aapp" method="aappRequest" aapp="#url.aapp#">
			<cfcatch>
			</cfcatch>
			</cftry>
		</cfif>

		<!--- ensure user is logged in, and has permission for the folder being accessed --->
		<cftry>
		<cfinclude template="#application.paths.includes#security.cfm">
		<cfcatch>
		</cfcatch>
		</cftry>

		<!--- determine whether search is included in header --->
		<cfset request.includeSearch = "true">

		<cfset request.nextTabIndex=1 />
		<cfset request.auditVarInsert = "I"/>
		<cfset request.auditVarUpdate = "U"/>
		<cfset request.auditVarDelete = "D"/>

		<!--- page specific properties -- set defaults here --->
		<cfset request.htmlTitleBase = "JFAS">
		<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
		<cfset request.pageTitleDisplay = "">
		<cfset request.pageID="0">
		<cfset request.pageHelpID = "">

		<!--- Get Current Program Year--->
		<cfset tpy = application.olookup.getRequestPY()>
		<cfset request.py			= "#tpy.py#">
		<cfset request.py_ccc		= "#tpy.py_ccc#">
		<cfset request.py_other		= "#tpy.py_other#">
        <cfset request.py_splan		= "#tpy.py_splan#">
		<cfset request.voiddate		= "#tpy.voiddate#">

		<!--- Clear unwanted session variable (specific case for a report ??? --->
		<cfinclude template="#application.paths.includes#CheckrstEstFopSort1.cfm">

	</cfif> <!--- url.isBackground NEQ 'no' --->

	<cfreturn true>

</cffunction> <!--- onRequestStart --->


<cffunction name="onRequestEnd" output="true">

	<!--- include file with debug output --->
	<cfif session.showDebug>
		<cfinclude template="#application.paths.includes#debugOutput.cfm" />
	</cfif>

</cffunction>


<cffunction name="onSessionEnd" returntype="void" output="false">
	<cfargument name="SessionScope" required="True" />
    <cfargument name="AppScope" required="False" />

	<cfset var nothing=1>
</cffunction>

<cffunction name="onError" returntype="void" output="true">
	<cfargument name="Exception" required="true"/>
	<cfargument name="EventName" type="String" required="false" default="" />
	<cfparam name="session.showDebug" default=false>

	<cfset var errortest="">

	<!--- here you can make dev show you the same error a user should see, by setting 1 EQ 0 --->
	<cfif (1 EQ 1 and
		(session.showDebug or (StructkeyExists(application, "cfEnv") AND application.cfEnv EQ "dev"))) >

		<!--- this is DEV. Dump to the screen --->
		<cfdump var="#arguments.exception#" label="Exception in application.onError">
		<cfdump var="#arguments.eventName#" label="eventName in application.onError">

	<cfelse>

		<!--- send an email --->
		<cfif arguments.Exception.Type is not "coldfusion.runtime.AbortException" and arguments.EventName is not "onRequestStart">

			<!--- log the error (using email, only?)  --->
			<!--- cflog file="myapperrorlog" test="#arguments.exception.message#"> --->

			<cfif NOT structKeyExists(session, "userid")>
				<!--- this is a timeout.  Just tell the user he is logged out.  No email to anyone. --->
				<cftry>
					<cflocation url="#application.paths.root#timeout.htm">
					<cfcatch>
					</cfcatch>
				</cftry>
			</cfif>

			<cfset var subject = "JFAS Error #iif(application.cfEnv neq 'prod',DE(' (' & Evaluate('application.cfEnvDesc') & ')'), DE(''))#">

			<cfsavecontent variable="errortext">
				<cfoutput>
					<table>
					<tr>
						<td><strong>JFAS Error:  </strong></td>
						<td>http://#cgi.server_name##cgi.script_name#?#cgi.query_string#</td>
					</tr>
					<tr>
						<td><strong>Time:  </strong></td>
						<td>#dateFormat(now(), "short")# #timeFormat(now(), "short")#</td>
					</tr>
					<tr>
						<td><strong>User: </strong></td>
						<td><CFIF structKeyExists(session, "userid")>#session.userid#<cfelse>no session.userid</cfif></td>
					</tr>
					<tr>
						<td><strong>Full Name: </strong></td>
						<td><CFIF structKeyExists(session, "fullname")>#session.fullname#<cfelse>&nbsp;</cfif></td>
					</tr>
					<tr>
						<td><strong>Email: </strong></td>
						<td><CFIF structKeyExists(session, "emailaddress")>#session.emailaddress#<cfelse>&nbsp;</cfif></td>
					</tr>
					<tr>
						<td><strong>Region: </strong></td>
						<td><CFIF structKeyExists(session, "Region")>#session.Region#<cfelse>&nbsp;</cfif></td>
					</tr>
					<tr>
						<td><strong>RoleDesc: </strong></td>
						<td><CFIF structKeyExists(session, "RoleDesc")>#session.RoleDesc#<cfelse>&nbsp;</cfif></td>
					</tr>
					<tr>
						<td><strong>Roleid: </strong></td>
						<td><CFIF structKeyExists(session, "Roleid")>#session.Roleid#<cfelse>&nbsp;</cfif></td>
					</tr>
					<tr>
						<td><strong>Referrer: </strong></td>
						<td>#cgi.HTTP_REFERER#</td>
					</tr>
					<tr>
						<td><strong>Message: </strong></td>
						<td>#arguments.exception.Message#</td>
					</tr>
					<cfif ArrayLen(arguments.exception.TagContext) neq 0>
						<cfset i=1>
						<cfloop index="i" from="1" to="#Arraylen(arguments.exception.TagContext)#">
							<tr>
								<td><strong>Template: </strong></td>
								<td>#arguments.exception.TagContext[i].template#, Line #arguments.exception.TagContext[i].Line#</td>
							</tr>
						<cfset i = i + 1>
						</cfloop>
					</cfif>

					<cfif isDefined("arguments.exception.sql")>
						<tr>
							<td><strong>SQL: </strong></td>
							<td>#arguments.exception.sql#</td>
						</tr>
					</cfif>
					<tr>
						<td><strong>Exception Type: </strong></td>
						<td>#arguments.exception.Type#</td>
					</tr>
					<tr>
						<td><strong>Event Name: </strong></td>
						<td>#arguments.EventName#</td>

					</tr>

					</table>

					<cfdump var="#arguments.exception#" label="Error">
					<cfparam name="form">
					<cfdump var="#form#" label="Form">
					<cfdump var="#url#" label="URL">

					<CFIF structKeyExists(session, "userpreferences")>
						<cfdump var="#session.userpreferences#" label="Session.userpreferences">
					</cfif>
					<cfdump var="#request#" label="Request">
					<!--- <cfdump var="#application#" label="Application"> --->
					<cfdump var="#cgi#" label="CGI" />
					<BR>End<BR>

				</cfoutput>
 			</cfsavecontent>
			<!--- mail a notice of the error --->


			<cfmail
				to		= "#application.technical_poc_email#"
				cc		= "#application.jfas_system_email#"
				subject	= "#subject#"
				from	= "#application.jfas_system_email#">

				<cfmailpart type="html">
					#errortext#
				</cfmailpart>

			</cfmail>

			<cfif arguments.EventName eq ''>
				<!--- fatal error ... show user ""we are working about it" screen.  This MUST log out, NOT go to the Home Screen, to avoid an infinite loop --->
				<cftry>
					<cflocation url="#application.paths.error#">
					<cfcatch>
					</cfcatch>
				</cftry>
			</cfif>
		</cfif> <!--- arguments.Exception.Type is not "coldfusion.runtime.AbortException" ... --->

	</cfif> <!--- NOT dev --->

</cffunction> <!--- onError --->

<cfscript>
/**
* @hint I return a model structure for session.userPreferences.tMyFilterNow.  The structure is put into the application scope, in onApplicationStart
*/
public struct function DefineDefaultFilter (
	)

	output			= "false"
	{
// names of preference fields in the filter form (if there, otherwise NotAFilter)

	var tReturn = structNew();
	var tFilter = structNew();

	// this MUST be all caps
	var slRequiredDefinedFilters = "HOME_CONTRACTSTATUSFILTER,HOME_AGREEMENTTYPEFILTER,HOME_FUNDINGOFFICEFILTER,HOME_STATEFILTER,HOME_SERVICETYPEFILTER,HOME_FILTERSEARCHWORD,HOME_CONTRACTSTARTDATE1,HOME_CONTRACTSTARTDATE2,HOME_CONTRACTENDDATE1,HOME_CONTRACTENDDATE2";

	// These are the field names in the frmHomeFilter form that correspond to the slRequiredDefinedFilters
	var slFilterFormNames = "cboContractStatusFilter,cboAgreementTypeFilter,cboFundingOfficeFilter,cboStateFilter,cboServiceTypeFilter,home_filterSearchWord,home_ContractStartDate1,home_ContractStartDate2,home_ContractEndDate1,home_ContractEndDate2";

	for (var walker = 1; walker LE ListLen(slRequiredDefinedFilters); walker += 1) {
		// all default values are '', and allow overwrite
		structInsert(tFilter, ListGetAt(slRequiredDefinedFilters, walker), '', 1);
	}
	tReturn.tFilter = tFilter;
	tReturn.slRequiredDefinedFilters = slRequiredDefinedFilters;
	tReturn.slFilterFormNames = slFilterFormNames;
	return tReturn;

} // DefineDefaultFilter

public struct function DefineDefaultSplanDisplaySettings (
	)

	output			= "false"
	{
	var tReturn = structNew();
	var tSettings = structNew();

	// this MUST be all caps
	var slRequiredDisplaySettings = "PY,RADSPENDINGBREAKDOWN,RADSAVESETTINGS,TODATE,CUSTOMDATE";
	for (var walker = 1; walker LE ListLen(slRequiredDisplaySettings); walker += 1) {
		// all default values are '', and allow overwrite
		structInsert(tSettings, ListGetAt(slRequiredDisplaySettings, walker), '', 1);
	}
	tReturn.tSettings = tSettings;
	tReturn.slRequiredDisplaySettings = slRequiredDisplaySettings;
	return tReturn;

} // DefineDefaultSplanDisplaySettings

// this is called in a few places in Application.cfc
// this is CF, NOT JS
public boolean function BooleanFormat (sTry) {

	if (YesNoFormat(arguments.sTry) EQ 'Yes') {
		return true;
	}
	else {
		return false;
	}

} // BooleanFormat


</cfscript>
</cfcomponent>






