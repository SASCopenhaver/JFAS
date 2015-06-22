<cfsilent>
<!---
page: recentupdates.cfm

description: page listing release notes

revisions:
--->

<cfinvoke component="#application.paths.components#dataadmin" method="getRelease" releaselist="true" returnvariable="rstListRelease">
<cfif (not IsDefined("url.rID"))>
    <cfset url.rID = #rstListRelease.releaseID#>
	<cfinvoke component="#application.paths.components#dataadmin" method="getRelease" rID="#url.rid#" returnvariable="rstViewRelease">
<cfelseif #url.rID# eq 0>
	<cfinvoke component="#application.paths.components#dataadmin" method="getRelease" returnvariable="rstViewRelease">
<cfelse>
	<cfinvoke component="#application.paths.components#dataadmin" method="getRelease" rID="#url.rid#" returnvariable="rstViewRelease">
</cfif>

<!--- Set the search variable to false, so  you don't get the search feature in the header --->
<cfset request.includeSearch = "false">
<cfset footerpage = true>
</cfsilent>
<!--- include header --->
<cfinclude template="#application.paths.includes#header.cfm">
<cfoutput>
<table width="100%" align="center" border="0" cellspacing="0" cellpadding="0" summary="Recent Update Information">
<tr valign="top">
	<td width="150" align="left" valign="top">
		<table width="130" border="0" align="left" cellpadding="10" cellspacing="0" bgcolor="e7edf3">
			<tr valign="top">
				<td width="100%" class="contentTbl">
			     <cfloop query="rstListRelease">
				       <li>
					       <cfif #releaseID# eq #url.rID#>
                                #dateformat(releaseDate, 'mm/dd/yyyy')#
						   <cfelse>
					            <a href="recentupdates.cfm?rID=#releaseId#">#dateformat(releaseDate, 'mm/dd/yyyy')#</a>
						   </cfif>
					   </li>
			     </cfloop>
                 <cfif #url.rID# eq 0>
					<li>View all</li>
				 <cfelse>
					<li><a href="recentUpdates.cfm?rID=0">View all</a></li>
			     </cfif>
				</td>
			</tr>
		</table>
	</td>
	<td width="446" align="left" valign="top">
		  <h1>Recent Updates </h1>
         <cfset currentRelease = 0>
		     <cfloop query="rstViewRelease">
				<cfif currentRelease neq rstViewRelease.ReleaseID>
	                 <p><b>#dateformat(releaseDate, 'mm/dd/yyyy')#</b>
			         <hr align="left" width="100%" size="1" noshade>
                 </cfif>
		             <span class="contentTbl">#Replace(ReleaseItemDesc, Chr(13) & Chr(10), "<br />", "ALL")#<br><br></span>
				 </p>
				 <cfset currentRelease = rstViewRelease.ReleaseID>
		     </cfloop>
	</td>
	<td width="10">&nbsp;</td>
</tr>
</table>
</cfoutput>
<cfinclude template="#application.paths.includes#footer.cfm">
