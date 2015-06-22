<cfsilent>
<!---
page: aapp_adjust_ec.cfm

description: listing for Funding Adjustment Tab, that lists by adjustment

revisions:
2007-01-18	mstein	Changed getAdjustmentList to return contract year - changed page to display
2008-06-09	mstein	All adjustments now linked to Adjustment Details page, even system-generated
2008-07-03	mstein	Display message if no records returned
--->
<cfset request.pageID = "310" />
<cfparam name="url.sortby" default="costCatCode">
<cfparam name="url.sortDir" default="asc">

<cfinvoke component="#application.paths.components#aapp_adjustment"
	method="getAdjustmentList"
	aapp="#url.aapp#"
	sortBY="#url.sortBy#"
	sortDir="#url.sortDir#"
	returnvariable="rstAdjustmentList">
</cfsilent>


<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">


			
			
			
<div class="ctrSubContent">
	<h2>Estimated Cost Adjustments</h2>
	
		<cfinclude template="#application.paths.includes#showAdjustmentButton.cfm">
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
		<tr>
			<cfoutput>
			<th scope="col"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=costCatCode&sortDir=<cfif url.sortBy is 'costCatCode' and url.sortDir is 'asc'>desc<cfelse>asc</cfif>">Cost Category</a></th>
			<th scope="col"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=contractYear&sortDir=<cfif url.sortBy is 'contractYear' and url.sortDir is 'asc'>desc<cfelse>asc</cfif>">Contract Year</a></th>
			<th scope="col" align="right"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=description&sortDir=<cfif url.sortBy is 'description' and url.sortDir is 'asc'>desc<cfelse>asc</cfif>">Description</a></th>
			<th scope="col" align="right"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=ongoing&sortDir=<cfif url.sortBy is 'ongoing' and url.sortDir is 'asc'>desc<cfelse>asc</cfif>">Ongoing?</a></th>
			</cfoutput>
		</tr>
		<cfset tempVal = "">
		<cfoutput query="rstAdjustmentList">
			<cfif (currentRow neq 1) and
				   (not listFindNoCase("dateEffective,description",url.sortBy)) and
				   (tempVal neq evaluate(#url.sortby#))>
				<tr>
					<td colspan="4" class="hrule"></td>
				</tr>
			</cfif>

			<tr <cfif currentrow mod 2>class="AltRow"</cfif>>
				<td width="15%">#costCatCode#</td>
				<td width="15%">#contractYear#</td>
				<td width="*" scope="row">
					<a href="aapp_adjust.cfm?aapp=#url.aapp#&adjustID=#adjustmentID#&frompage=#CGI.SCRIPT_NAME#">#description#</a>
				</td>
				<td width="10%">#ongoing#</td>
			</tr>
			<cfset tempVal = evaluate(#url.sortby#) />
		</cfoutput>
		<cfif rstAdjustmentList.recordCount eq 0>
			<tr>
				<td colspan="4" align="center" valign="middle" height="50">No Estimated Cost Adjustments exist for this AAPP.</td>
			</tr>
		</cfif>
			  
		</table>
	</div>

</div>



<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

