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
		<!--- giving message, just in case lowerlevel routine did not --->
		<cflocation url="#application.paths.errordir#logoutwithmessage.htm">
	</cfcatch>
</cftry>

<div class="detailSurround">


	<!--- the existence of this table, surrounding everything in every detail page, is compatible with JFAS 2.12 --->
	<!--- table is IN the Row --->
	<table class="table100">
	<tr>
	<td>
	<cfset DisplayTopUI('no')>
	<!--- start of content area (ctrContent) --->
	<div class="ctrContent">
	<!--- DO NOT LEAVE EXTRA BLANK LINES IN THE CODE HERE !!!! --->
		<!--- here is a bookmark to the content --->
		<a name="pagebody"></a>
		<cfoutput>
		<!--- page title, margin is vital --->
		<h1 style="margin: 5px 0 0 0;">#request.pageTitleDisplay#</h1>
		<!--- header action button (if applicable) --->
		<cfif isDefined("variables.headerButton")>#variables.headerButton#</cfif>
		<!--- include AAPP summary information --->
		<cfif findNocase("\aapp\", CGI.PATH_TRANSLATED)>
			<!--- show contract info block (if not creating new contract --->
			<cfset headerDisplayContractInfo()>
			<!--- include information for secondary navigation (tabs) --->
			<cfset headerDisplaySecondaryNav()>
		</cfif>
		</cfoutput>
<!--- leaves these open:
<div class="ctrContent">
<td>
<tr>
<table class="table100">
<div class="detailSurround">
--->
