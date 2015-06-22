<cfsilent>
<!---
page: aapp_adjust_fop.cfm

description: listing for Funding Adjustment Tab, that lists by FOP

revisions:
2007-01-11	rroser	allow filtering of FOP list, and sorting of filtered list
2008-06-09	mstein	All FOPs now linked to Adjustment Details page, even system-generated
2014-03-23	mstein	Added total row at bottom
--->

<cfset request.pageID = "320" />

<!--- temporary kluge until tabs are re-organized --->
<!--- default page for "Budget Changes" main tab is FOP listing (this page) --->
<!--- but not all users that have access to Budget Changes have access to FOP Listing --->
<!--- so - take all non Admin and Budget Unit staff to Footprint/Contractor Page (all access) --->
<cfif not listFind("1,2", session.roleID)>
	<cflocation url="aapp_foot_list.cfm?aapp=#url.aapp#">
</cfif>

<cfparam name="url.sortBy" default="costCatCode" />
<cfparam name="url.sortDir" default="asc">
<cfif isDefined("url.CostCat")>
	<cfset form.hidFilterCostCat = url.CostCat>
<cfelse>
	<cfparam name="form.hidFilterCostCat" default="All">
</cfif>
<cfinvoke component="#application.paths.components#aapp_adjustment"
	method="getFOPList"
	aapp="#url.aapp#"
	sortBy="#url.sortBy#"
	sortDir="#url.sortDir#"
	returnvariable="rstFOPList">
	
<cfif rstFOPList.recordcount GT 0>
	<cfquery dbtype="query" name="qryFOPpy">
	select	distinct(programYear)
	from	rstFOPList
	order	by programYear desc
	</cfquery>
	<cfif isDefined("url.py")>
		<cfset form.hidFilterPY = url.py>
	<cfelse>
		<cfparam name="form.hidFilterPY" default="#qryFOPpy.programYear#">
	</cfif>
	
	<cfquery dbtype="query" name="qryFOPCostCatCode">
	select	distinct(costCatCode), costCatDesc
	from	rstFOPList
	</cfquery>
	
	<cfquery dbtype="query" name="qryFOPfiltered">
	select	*
	from	rstFOPList
	where	1=1
		<cfif form.hidFilterPY neq "All">
		and programYear = #form.hidFilterPY#
		</cfif>
		<cfif form.hidFilterCostCat neq "All">
		and 	costCatCode = '#form.hidFilterCostCat#'
		</cfif>
	</cfquery>
</cfif>
</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">
<script language="javascript">
function setFilter(field){
if(field == document.frmFilterFOP.cboPYFilter)
	{
	document.frmFilterFOP.hidFilterPY.value = field.value;
	}
else if(field == document.frmFilterFOP.cboCostCodeFilter)
	{
	document.frmFilterFOP.hidFilterCostCat.value = field.value;
	}
}
</script>		
			
<div class="ctrSubContent">
	<h2>FOPs</h2>
	<cfinclude template="#application.paths.includes#showAdjustmentButton.cfm">
<cfif rstFOPlist.recordcount gt 0>	
<br />
<br />
	<div class="btnLeft">
<cfoutput>
	<form name="frmFilterFOP" action="#CGI.SCRIPT_NAME#?aapp=#url.aapp#" method="post">
		<label for="idPYFilter" class="hiddenLabel">Program Year</label>
		<select name="cboPYFilter" id="idPYFilter" onchange="setFilter(this);">
			<cfloop query="qryFOPpy">
				<option value="#programYear#" <cfif programYear eq form.hidFilterPY>selected</cfif>>#programYear#</option>
			</cfloop>
			<option value="all" <cfif form.hidFilterPY is "All">selected</cfif>>All</option>			
		</select>
		<label for="idCostCodeFilter" class="hiddenLabel">Cost Category</label>
		<select name="cboCostCodeFilter" id="idCostCodeFilter" onchange="setFilter(this);">
			<cfloop query="qryFOPCostCatCode">
				<option value="#costCatCode#"<cfif costCatCode is form.hidFilterCostCat>selected</cfif>>#costCatCode# - #costCatDesc#</option>
			</cfloop>
			<option value="All" <cfif form.hidFilterCostCat is "All">selected</cfif>>All Cost Categories</option>
		</select>
		<input type="hidden" name="hidFilterPY" value="#form.hidFilterPY#" />
		<input type="hidden" name="hidFilterCostCat" value="#form.hidFilterCostCat#" />
		<input type="submit" name="btnFilter" value="Go" />
	</form>
		</cfoutput>
	</div>
</cfif>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
		<tr>
			<cfoutput>
			<th scope="col"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=costCatCode&sortDir=<cfif url.sortBy is 'costCatCode' and url.sortDir is 'asc'>desc<cfelse>asc</cfif><cfif rstFOPList.recordcount neq 0><cfif form.hidFilterPY neq qryFOPpy.programYear>&py=#form.hidFilterPY#</cfif><cfif form.hidFilterCostCat neq 'All'>&costCat=#form.hidFilterCostCat#</cfif></cfif>">Cost Category</a></th>
			<th scope="col"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=programYear&sortDir=<cfif url.sortBy is 'programYear' and url.sortDir is 'asc'>desc<cfelse>asc</cfif><cfif rstFOPList.recordcount neq 0><cfif form.hidFilterPY neq qryFOPpy.programYear>&py=#form.hidFilterPY#</cfif><cfif form.hidFilterCostCat neq 'All'>&costCat=#form.hidFilterCostCat#</cfif></cfif>">Program Year</a></th>
			<th scope="col"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=fopNum&sortDir=<cfif url.sortBy is 'fopNum' and url.sortDir is 'asc'>desc<cfelse>asc</cfif><cfif rstFOPList.recordcount neq 0><cfif form.hidFilterPY neq qryFOPpy.programYear>&py=#form.hidFilterPY#</cfif><cfif form.hidFilterCostCat neq 'All'>&costCat=#form.hidFilterCostCat#</cfif></cfif>">FOP##</a></th>
			<th scope="col"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=description&sortDir=<cfif url.sortBy is 'description' and url.sortDir is 'asc'>desc<cfelse>asc</cfif><cfif rstFOPList.recordcount neq 0><cfif form.hidFilterPY neq qryFOPpy.programYear>&py=#form.hidFilterPY#</cfif><cfif form.hidFilterCostCat neq 'All'>&costCat=#form.hidFilterCostCat#</cfif></cfif>">Description</a></th>			
			<th scope="col" style="text-align:right;"><a href="#CGI.SCRIPT_NAME#?aapp=#url.aapp#&sortBy=amount&sortDir=<cfif url.sortBy is 'amount' and url.sortDir is 'asc'>desc<cfelse>asc</cfif><cfif rstFOPList.recordcount neq 0><cfif form.hidFilterPY neq qryFOPpy.programYear>&py=#form.hidFilterPY#</cfif><cfif form.hidFilterCostCat neq 'All'>&costCat=#form.hidFilterCostCat#</cfif></cfif>">Amount</a></th>
			</cfoutput>
		</tr>
		<cfset tempVal = "" />
<cfif rstFOPList.recordcount neq 0>
	<cfif qryFOPfiltered.recordcount eq 0>
	<tr>
		<td colspan="5" align="center">
			No FOPs match your current search criteria.
		</td>
	</tr>
	<cfelse>
		<cfset fopTotal = 0>
		<cfoutput query="qryFOPfiltered">
			<cfif (currentRow neq 1) and
				   (listFindNoCase("costCatCode,programYear",url.sortBy)) and
				   (tempVal neq evaluate(#url.sortby#))>
				<tr>
					<td colspan="5" class="hrule"></td>
				</tr>
			</cfif>

			<tr <cfif currentrow mod 2>class="AltRow"</cfif>>
				<td width="15%">#costCatCode#</td>
				<td width="15%">#programYear#</td>
				<td width="8%">#FOPNum#</td>
				<td width="*" scope="row">
					<a href="aapp_adjust.cfm?aapp=#url.aapp#&fopID=#fopID#">#description#</a>
				</td>
				<td width="15%" align="right">#numberformat(amount,"$9,999")#</td>
			</tr>
			<cfset tempVal = evaluate(#url.sortby#) />
			<cfset fopTotal = fopTotal + amount>
			
		</cfoutput>
		<!--- show total --->
		<tr>
			<td></td>
			<td></td>
			<td></td>
			<td><strong>Total</strong></td>
			<td align="right"><Cfoutput><strong>#numberformat(fopTotal,"$9,999")#</strong></cfoutput></td>
		</tr>
	</cfif>	  
<cfelse>
	<tr>
		<td colspan="5" align="center">
			There are currently no FOPs for this AAPP.
		</td>
	</tr>
</cfif>
		</table>
	</div>

</div>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

