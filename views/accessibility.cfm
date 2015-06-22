<!--- accessibility.cfm --->

<cfsilent>
<!--- Set the search variable to false, so  you don't get the search feature in the header --->
<cfset request.includeSearch = "false">
<cfset footerpage = true>
<cfset rstAccess = application.outility.getPOCs ( contactType="access" )>
</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<h1>Accessibility Information </h1>
<div class="contentTbl">
<cfoutput>
If you are unable to access some of the information contained on this website because of its format or other features, please
contact the <cfif rstAccess.access_poc_title neq ''>#rstAccess.access_poc_title#,</cfif>
<cfif rstAccess.access_poc_name neq ''>#rstAccess.access_poc_name#</cfif>
<cfif rstAccess.access_poc_phone neq ''>at #rstAccess.access_poc_phone#</cfif><cfif rstAccess.access_poc_fax neq ''>,
fax #rstAccess.access_poc_fax#</cfif><cfif rstAccess.access_poc_email neq ''>,
or email <a href="mailto:#rstAccess.access_poc_email#">#rstAccess.access_poc_email#</a></cfif>.
Your request will be referred to the
appropriate Department of Labor office responsible for providing assistance to you in this regard. The office will respond
promptly to you by providing you with alternate means for accessing this website. To help us serve you better, please provide us
with a description of your disability and your contact information so we can reach you if questions arise while identifying or
addressing a solution to your request.
</cfoutput>
</div>

<cfinclude template="#application.paths.includes#footer.cfm" />

<!--- END of accessibility.cfm --->
