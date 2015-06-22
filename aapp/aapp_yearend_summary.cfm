<!---
page: aapp_yearend_summary.cfm

description: lists summary of year end reconciliations and closeout activities for an aapp

revisions:
2007-01-04	yjeng	Remove the debug output
2007-03-16	mstein	Used new function get2110ReportList to speed up display of page
2007-05-16	rroser	allow all users to see reports that exist, but only admin users to execute
2010-11-12	mstein	Updated business rules that determine if user can execute Year-End Recon, or Close-out
					Used to be based on end date of contract - now user is forced to complete recons before doing close-out
--->
<cfsilent>

<cfif datecompare(request.dateEnd, now()) eq 1>
	<cfset request.pageID = "410" />
<cfelse>
	<cfset request.pageID = "411" />
</cfif>

<!--- get existing year-end recon data --->
<cfinvoke component="#application.paths.components#aapp_yearend" method="getYearEndListing" aapp="#url.aapp#" returnvariable="rstYearEndListing">

<!--- get existing close-out data --->
<cfinvoke component="#application.paths.components#aapp_yearend" method="getCloseOutListing" aapp="#url.aapp#" mode="existing" returnvariable="rstCloseOutListing">

<!--- check for existence of FMS data for this AAPP --->
<cfinvoke component="#application.paths.components#aapp_yearend" method="get2110ReportList" aapp="#url.aapp#" returnvariable="rst2110ReportList">

<!--- get current contract length --->
<cfinvoke component="#application.paths.components#aapp_yearend" method="pendingYERecon" aapp="#url.aapp#" returnvariable="pendingCY">

<!--- get max recon performed so far --->
<cfquery name="qryGetMaxCY" dbtype="query">
select	max(contractYear) as maxYear
from	rstYearEndListing
</cfquery>

<!--- Display link to preview Year-End Reconciliation, if: --->
<!--- 1. User has appropriate permissions --->
<!--- 2. There is FMS Data in the system for this AAPP --->
<!--- 3. The AAPP has a Year-End Recon Pending --->
<cfif listFind('1,2', session.roleId, ",") and
	  (rst2110ReportList.recordCount gt 0) and
	  (pendingCY gt 0)>
	<!--- then display link --->
	<cfset displayNew_YE_link = 1>
<cfelse>
	<!--- YE recon can not be previewed --->
	<cfset displayNew_YE_link = 0>
</cfif>

</cfsilent>


<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">
				
			
<div class="ctrSubContent">
	<h2>Year-End Reconciliation Summary</h2>	
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
		<tr>
			<th width="15%" scope="col" style="text-align:center;">Contract Year</th>	
			<th width="40%" scope="col" style="text-align:center;">Date Executed</th>
			<th width="45%"></th>
		</tr>
		
		<!--- display list of executed Year-End Reconciliations --->
		<cfoutput query="rstYearEndListing">
			<tr <cfif not currentRow mod 2>class="AltRow"</cfif>>
				<td scope="row" align="center">#contractYear#</td>  
				<td align="center">#dateFormat(dateRecon, "mm/dd/yyyy")#</td>
				<td align="right"><a href="aapp_yearend.cfm?aapp=#url.aapp#&contractYear=#contractYear#">View >></a></td>		
			</tr>	
		</cfoutput>
			<cfif rstYearEndListing.recordcount is 0 and not displayNew_YE_link>
				<tr>
					<td colspan="3" style="text-align:center"><br />There are no year-end reconciliation records to display.<br /><br /></td>
				</tr>
			</cfif>

		<!--- Display link to execute Year-End Reconciliation --->
		<cfif displayNew_YE_link>
			<cfoutput>
			<tr <cfif not ((rstYearEndListing.recordCount + 1) mod 2)>class="AltRow"</cfif>>
				<td scope="row" align="center">#pendingCY#</td>  
				<td></td>
				<td align="right">
					<a href="aapp_yearend.cfm?aapp=#url.aapp#&contractYear=#pendingCY#">Preview Year-End Reconciliation >></a>
				</td>
			</tr>
			</cfoutput>
		<cfelseif rst2110ReportList.recordCount eq 0>
			<tr>
				<td colspan="3" style="text-align:center">
					<br />
					There is no FMS data in the system for this AAPP. Reconciliation can not be executed.
					<br /><br />
				</td> 
			</tr>
			 
		</cfif>		
		</table>
		
		
		<!--- if Year-End Recon is not pending, and contract end date has passed --->
		<cfif (not displayNew_YE_link) and datecompare(request.dateEnd, now()) lt 1> 
			<br /><br />
			<h2>Contract Close-out Summary</h2>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
			<tr>
				<th width="15%" scope="col" style="text-align:center;">Close-out No.</th>	
				<th width="40%" scope="col" style="text-align:center;">Date Executed</th>
				<th width="45%"></th>
			</tr>
			
			<cfoutput query="rstCloseOutListing">
				<tr <cfif not currentRow mod 2>class="AltRow"</cfif>>
					<td scope="row" align="center">#currentRow#</td> 
					<td align="center">#dateFormat(dateCloseout, "mm/dd/yyyy")#</td>
					<td align="right"><a href="aapp_closeout.cfm?aapp=#url.aapp#&closeoutID=#closeoutID#">View >></a></td>		
				</tr>	
			</cfoutput>
			<cfif rstCloseOutListing.recordcount is 0 and not listFind('1,2', session.roleId, ",")>
				<tr>
					<td colspan="3" style="text-align:center"><br />There are no close out records to display.<br /><br /></td>
				</tr>
			</cfif>
			<cfif listFind('1,2', session.roleId, ",")>
				<cfif (request.succAAPPnum neq "") and (rst2110ReportList.recordCount gt 0)> <!--- can only do close-out if successor exists --->
					
					<cfif request.statusID eq 1> <!--- show row for next closeout --->
						<cfoutput>
						<tr <cfif not ((rstCloseOutListing.recordCount + 1) mod 2)>class="AltRow"</cfif>>
							<td scope="row" align="center">#evaluate(rstCloseOutListing.recordcount + 1)#</td> 
							<td></td>
							<td align="right"><a href="aapp_closeout.cfm?aapp=#url.aapp#&closeoutID=0">Preview Close-out >></a></td>		
						</tr>
						</cfoutput>
					<cfelse>
						<tr>
						<td colspan="3" style="text-align:center"><br />There are no close out records to display.<br /><br /></td>
					</tr>
					</cfif>
					
				<cfelseif request.succAAPPnum eq ""> <!--- no successor --->				
					<tr>
						<td colspan="3" style="text-align:center"><br />There is no successor in place. Close-out cannot be executed.<br /><br /></td>
					</tr>			
				
				<cfelseif rst2110ReportList.recordCount eq 0> <!--- no FMS data --->				
					<tr>
						<td colspan="3" style="text-align:center"><br />There is no FMS data in the system for this AAPP. Close-out cannot be executed.<br /><br /></td>
					</tr>			
	
				</cfif>
			</cfif>
			
			</table>
		</cfif> <!---show close-out section? --->

	</div>
	
</div>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

