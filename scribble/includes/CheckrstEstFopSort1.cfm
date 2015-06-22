<cfsilent>
<!---
page: CheckrstEstFopSort1.cfm

description: use this template to remove unwanted session variables

revisions:
2007-04-10	yjeng	Add report page for session.rstEstFopSort1
--->

<!--- Delete Session variable set in fopbatch pages if not in fopbatch process--->
<cfif isDefined("session.rstEstFopSort1")
	and not findnocase("\admin\fopbatch_",cgi.path_translated)
	and not findnocase("\reports\",cgi.path_translated)>
	<cflock timeout=20 scope="Session" type="Exclusive">
	   <cfset StructDelete(Session, "rstEstFopSort1")>
	</cflock>
</cfif>

</cfsilent>