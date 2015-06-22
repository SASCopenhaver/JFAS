<!--- job_corps_allots.cfm --->
<cfsilent>
	<cfset request.pageID = "2490">
	<cfset request.pageTitleDisplay = "JFAS System Administration">
</cfsilent>

<cfinclude template="#application.paths.includes#header.cfm">

<h2>Job Corps Allotments ($)</h2>

<form name="frmJCA" id="frmJCA"><!--- JCA: Job Corps Allotments --->

        <div id="div_SaveMsg">&nbsp;</div>

        <div id="div_contentAllotData"></div>


</form>
<cfinclude template="#application.paths.includes#footer.cfm">
<cfinclude template="#application.paths.includes#job_corps_allotJS.cfm">