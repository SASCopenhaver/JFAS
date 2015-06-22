<!--- job_corps_allots.cfm --->
<cfsilent>
	<cfset request.pageID = "2490">
	<cfset request.pageTitleDisplay = "JFAS System Administration">
</cfsilent>

<cfinclude template="#application.paths.includes#header.cfm">

<h2>Job Corps Allotments ($)</h2>

<form name="frmJCA" id="frmJCA"><!--- JCA: Job Corps Allotments --->

<!---<cfif isDefined("url.saved")>
	<div class="confirmList">
	<cfoutput><li>Information saved successfully.&nbsp;&nbsp;Return to the <a href="#application.paths.admin#">Admin Section</a></li></cfoutput>
	</div><br />
</cfif>--->
        <div id="div_SaveMsg">&nbsp;</div>
        
        <div id="div_contentAllotData"></div>
        
        <!---<script type="text/javascript" src="#application.urlstart#code.jquery.com/jquery-1.10.2.min.js"></script>--->
       <!--- <cfoutput>
		<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>
        </cfoutput>--->
        <!---<cfinclude template="#application.paths.includes#job_corps_allotJS.cfm">--->

</form>
<cfinclude template="#application.paths.includes#footer.cfm">
<cfinclude template="#application.paths.includes#job_corps_allotJS.cfm">