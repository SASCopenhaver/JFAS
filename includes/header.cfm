<!---
page: header.cfm - THIS IS ONLY WITH ALL THE DETAIL PAGES, not the Home page

This presents a header that will scroll off the page to the top
2013-12-12	dbellenger	convert to work with bootstrap environment
--->
<!--- header.cfm (this file) is called only for non-home-page pages --->
<!--- detect if session may have timed out --->
<cftry>
	<cfsilent>
	<!--- get page properties --->
	<cfinvoke component="#application.paths.components#page" method="getPageProperties" pageID="#request.pageID#" returnvariable="rstPageProperties">

	<cfset request.pageSectionID		= rstPageProperties.sectionID />
	<cfset request.parentSectionID		= rstPageProperties.parentID />
	<cfset request.pageHelpID 			= rstPageProperties.helpID />

	</cfsilent>

	<!--- functions for displaying data in various divs --->
	<cfinclude template="#application.paths.includes#headerDisplayFunctions.cfm">


<!--- begin HTML (bootstrap)--->
<!--- set up header for detail page. Set up doctype, load css libraries. Includes <body> tag. --->
<!--- styled in jfas.less to be below the navbar --->
<!--- override styles in jfas.less, to be below header, NOT home header to be below the navbar --->

	<cfset DisplayHTMLSetup('no')>
	<cfcatch type="any">
		<cfif NOT structKeyExists(session, "userid")>
			<!--- this is a timeout.  Just tell the user he is logged out.  No email to anyone. --->
			<cftry>
			<cflocation url="#application.paths.root#timeout.htm">
				<cfcatch>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- giving error message, just in case lowerlevel routine did not --->
		<cflocation url="#application.paths.errordir#error.htm">
	</cfcatch>
</cftry>

<div class="detailSurround">


	<!--- the existence of this table, surrounding everything in every detail page, is compatible with JFAS 2.12 --->
	<!--- table is IN the Row --->
	<table class="table100">
	<tr>
	<td>
	<cfset DisplayTopUI('no')>


	<!--- COMMENT OUT THIS NEW WAY, UNTIL DO STYLING
	<cfoutput>
	<cfif findNocase("\budget\", CGI.PATH_TRANSLATED)>
		<!--- BUDGET --->
		<!--- start of content area (budgetContent) --->
		<div class="budgetContent">
		<!--- DO NOT LEAVE EXTRA BLANK LINES IN THE CODE HERE !!!! --->
			<!--- here is a bookmark to the content --->
			<a name="pagebody"></a>

			<!--- include BUDGET summary information --->
			<!--- show contract info block (if not creating new contract).  This includes the <h1> Title for the summary --->



			<cfset headerDisplayBudgetInfo( request.pageName )>
			<!--- include information for secondary navigation (tabs) --->
			<cfset headerDisplayBudgetSecondaryNav( request.pageName )>
		<!--- leaves these open:
		<div class="budgetContent">
		<td>
		<tr>
		<table class="table100">
		<div class="detailSurround">
		--->

	<cfelse>
		<!--- NOT BUDGET --->
		<!--- start of content area (ctrContent) --->
		<div class="ctrContent">
		<!--- DO NOT LEAVE EXTRA BLANK LINES IN THE CODE HERE !!!! --->
			<!--- here is a bookmark to the content --->
			<a name="pagebody"></a>

			<!--- include AAPP summary information --->
			<cfif findNocase("\aapp\", CGI.PATH_TRANSLATED)>
				<!--- show contract info block (if not creating new contract).  This includes the <h1> Title for the summary --->
				<cfset headerDisplayContractInfo()>
				<!--- include information for secondary navigation (tabs) --->
				<cfset headerDisplaySecondaryNav()>
			</cfif>
		<!--- leaves these open:
		<div class="ctrContent">
		<td>
		<tr>
		<table class="table100">
		<div class="detailSurround">
		--->
	</cfif>
	</cfoutput>

	END of comment out the new way --->

	<!--- HERE IS THE OLD WAY --->

	<!--- start of content area (ctrContent) --->
	<div class="ctrContent">
	<!--- DO NOT LEAVE EXTRA BLANK LINES IN THE CODE HERE !!!! --->
		<!--- here is a bookmark to the content --->
		<a name="pagebody"></a>
		<cfoutput>
		<!--- comment out OBSOLETE ? belldr 10/26/2014
		<!--- page title, top margin is vital --->
		<h1 style="margin: 5px 0 0 0;">#request.pageTitleDisplay#</h1>
		<!--- header action button (if applicable) --->
		<cfif isDefined("variables.headerButton")>#variables.headerButton#</cfif>
		END of comment out --->

		<!--- include AAPP summary information --->
		<cfif findNocase("\aapp\", CGI.PATH_TRANSLATED)>
			<!--- show contract info block (if not creating new contract).  This includes the <h1> Title for the summary --->
			<cfset headerDisplayContractInfo()>
			<!--- include information for secondary navigation (tabs) --->
			<cfset headerDisplaySecondaryNav()>
		</cfif>

		<!--- include BUDGET summary information --->
		<cfif findNocase("\budget\", CGI.PATH_TRANSLATED)>
			<!--- show contract info block (if not creating new contract).  This includes the <h1> Title for the summary --->
			<cfset headerDisplayBudgetInfo( request.pageName )>
			<!--- include information for secondary navigation (tabs) --->
			<cfset headerDisplayBudgetSecondaryNav( request.pageName )>

		</cfif>
		</cfoutput>
	<!--- leaves these open:
	<div class="ctrContent">
	<td>
	<tr>
	<table class="table100">
	<div class="detailSurround">
	--->

	<!--- END of the old way --->




