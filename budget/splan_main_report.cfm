<!---
page: splan_main_report.cfm

description: this puts out an Excel version of the current spend plan

--->
<cfoutput>
<cfset request.pageName="SplanMain">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "JFAS System Budget">

<!--- this is all it takes to export Excel --->
<cfheader name="Content-Disposition" value="inline;filename=currentspendplan.xls">
<cfcontent type="application/msexcel">

<!--- leave header.cfm out of this, since it makes too many if statements

<cfinclude template="#application.paths.includes#header.cfm">
<cfinclude template="#application.paths.includes#jsGraphics.cfm">
--->

<!--- these is normally done by header.cfm --->
<!--- functions for displaying data in various divs --->
<cfinclude template="#application.paths.includes#headerDisplayFunctions.cfm">

<div class="detailSurround">
	<!--- the existence of this table, surrounding everything in every detail page, is compatible with JFAS 2.12 --->
	<!--- table is IN the Row --->
	<table class="table100">
	<tr>
	<td>
	<cfinclude template="#application.paths.includes#headerDisplayBudgetFunctions.cfm">
	<div class="ctrContent">


	<!--- leaves these open:
	<div class="ctrContent">
	<td>
	<tr>
	<table class="table100">
	<div class="detailSurround">
	--->

<cfinclude template = "splan_main_include.cfm">
<cfset DoSplan ('Excel')>

</cfoutput>
