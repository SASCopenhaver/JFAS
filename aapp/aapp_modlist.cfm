<cfsilent>
<!---
page: aapp_modlist.cfm

description: listing of AAPP funding mods

revisions:
2011-03-18	mstein	page created
--->

<cfset request.pageID = "350" />
<cfparam name="url.sortby" default="modNum">
<cfparam name="url.sortDir" default="asc">

<cfinvoke component="#application.paths.components#aapp_mod"
	method="getModListing"
	aapp="#url.aapp#"
	sortBy="#url.sortBy#"
	sortDir="#url.sortDir#"
	returnvariable="rstModList">
</cfsilent>


<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">
			
			
			
<div class="ctrSubContent">
	<h2>Contract Mod Funding Totals</h2>
	 
		<cfif request.statusID eq 1>
			<!--- button to enter new mod data (if aapp is active) --->
			<div class="btnRight">
			<cfoutput>
			<form name="frmAddMod" action="aapp_mod_details.cfm" method="get">
			<input name="btnAddMod" type="submit" value="Add Mod" />
			<input type="hidden" name="aapp" value="#url.aapp#" />
			<input type="hidden" name="modID" value="0" />
			<input type="hidden" name="frompage" value="#cgi.SCRIPT_NAME#" />
			</form>
			</cfoutput>
			</div>
		</cfif>
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
		<tr>
			<cfoutput>
			<th scope="col"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=modNum&sortDir=<cfif url.sortBy is 'modNum' and url.sortDir is 'asc'>desc<cfelse>asc</cfif>">Mod Number</a></th>
			<th scope="col"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=dateIssued&sortDir=<cfif url.sortBy is 'dateIssued' and url.sortDir is 'asc'>desc<cfelse>asc</cfif>">Date Issued</a></th>
			<th scope="col" style="text-align:right;"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=opsFunding&sortDir=<cfif url.sortBy is 'opsFunding' and url.sortDir is 'asc'>desc<cfelse>asc</cfif>">OPS Funding</a></th>
			<th scope="col" style="text-align:right;"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=craFunding&sortDir=<cfif url.sortBy is 'craFunding' and url.sortDir is 'asc'>desc<cfelse>asc</cfif>">CRA Funding</a></th>
			<th scope="col" style="text-align:right;"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=totalFunding&sortDir=<cfif url.sortBy is 'totalFunding' and url.sortDir is 'asc'>desc<cfelse>asc</cfif>">Total Funding</a></th>
			</cfoutput>
		</tr>
		<cfoutput query="rstModList">
			<tr <cfif currentrow mod 2>class="AltRow"</cfif>>
				<td width="20%"><a href="aapp_mod_details.cfm?aapp=#url.aapp#&modID=#modID#&frompage=#CGI.SCRIPT_NAME#">#modNum#</a></td>
				<td width="20%">#dateFormat(dateIssued, "mm/dd/yyyy")#</td>
				<td width="20%" align="right">$#numberFormat(opsFunding)#</td>
				<td width="20%" align="right">$#numberFormat(craFunding)#</td>
				<td width="20%" align="right">$#numberFormat(totalFunding)#</td>
			</tr>
		</cfoutput>
		<cfif rstModList.recordCount eq 0>
			<tr>
				<td colspan="5" align="center" valign="middle" height="50">
					<cfoutput>
					No mod information has been entered for this AAPP.
					<cfif request.statusID eq 1>
						Click <a href="aapp_mod_details.cfm?aapp=#url.aapp#&modID=0&frompage=#CGI.SCRIPT_NAME#" title="Add a Mod">here</a> to add a mod.</td>
					</cfif>
					</cfoutput>
			</tr>
		</cfif>
			  
		</table>
	</div>

</div>



<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

