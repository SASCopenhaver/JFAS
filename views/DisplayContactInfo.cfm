<cfsilent>
<!--- DisplayContactInfo.cfm --->
<!--- Set the search variable to false, so  you don't get the search feature in the header --->
<cfset request.includeSearch = "false">
<cfset footerpage = true>
<cfset rstHelpdesk = application.outility.getPOCs ( contactType="helpdesk" )>
<cfset rstProgram = application.outility.getPOCs ( contactType="program" )>

</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<h1>Contact Information</h1>
<div class="contentTbl">
<cfoutput>
<cfif rstProgram.program_poc_name neq ''>
	<strong>For Program related questions, contact:</strong>
	<cfif rstProgram.program_poc_organization neq ''><br>
		#rstProgram.program_poc_organization#
	</cfif>
	<cfif rstProgram.program_poc_name neq ''><br>
		#rstProgram.program_poc_name#
	</cfif>
	<cfif rstProgram.program_poc_title neq ''><br>
		#rstProgram.program_poc_title#
	</cfif>
	<cfif rstProgram.program_poc_phone neq ''><br>
		Phone:&nbsp;#rstProgram.program_poc_phone#
	</cfif>
	<cfif rstProgram.program_poc_fax neq ''><br>
		Fax:&nbsp;#rstProgram.program_poc_fax#
	</cfif>
	<cfif rstProgram.program_poc_email neq ''><br>
		<a href="mailto:#rstProgram.program_poc_email#">#rstProgram.program_poc_email#</a>
	</cfif>
	<br>
	<br>
</cfif>
<cfif rstHelpdesk.helpdesk_poc_name neq ''>
<strong>For technical assistance, contact:</strong>
<cfif rsthelpdesk.helpdesk_poc_organization neq ''><br>
		#rsthelpdesk.helpdesk_poc_organization#
	</cfif>
	<cfif rsthelpdesk.helpdesk_poc_name neq ''><br>
		#rsthelpdesk.helpdesk_poc_name#
	</cfif>
	<cfif rsthelpdesk.helpdesk_poc_title neq ''><br>
		#rsthelpdesk.helpdesk_poc_title#
	</cfif>
	<cfif rsthelpdesk.helpdesk_poc_phone neq ''><br>
		Phone:&nbsp;#rsthelpdesk.helpdesk_poc_phone#
	</cfif>
	<cfif rsthelpdesk.helpdesk_poc_fax neq ''><br>
		Fax:&nbsp;#rsthelpdesk.helpdesk_poc_fax#
	</cfif>
	<cfif rsthelpdesk.helpdesk_poc_email neq ''><br>
		<a href="mailto:#rsthelpdesk.helpdesk_poc_email#">#rsthelpdesk.helpdesk_poc_email#</a>
	</cfif>
</cfif>

</cfoutput>
</div>


<cfinclude template="#application.paths.includes#footer.cfm" />