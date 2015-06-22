<cfsilent>
<!---
page: aapp_foot_listing.cfm

description: listing of AAPP funding mods

revisions:
2011-03-18	mstein	page created
2013-08-16	mstein	Updated for NCFMS integration. Removed references to transaction data
--->

<cfset request.pageID = "361" />

<cfif url.footprintID eq 0>
	<cflocation url="aapp_foot_list.cfm?aapp=#url.aapp#">
</cfif>

<!--- get footprint information --->
<cfinvoke component="#application.paths.components#footprint" method="getFootprintDetails" returnvariable="rstFootprintDetails"
	footprintID = "#url.footprintID#">


<!--- footprint has been deleted --->
<cfif rstFootprintDetails.recordCount eq 0>
	<cflocation url="aapp_foot_list.cfm?aapp=#url.aapp#">
</cfif>

</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">



<div class="ctrSubContent">
	<h2>Footprint Details</h2>
	
	<table width="98%" border="0" cellpadding="0" cellspacing="0" class="readOnlyDataTbl">
	<cfoutput query="rstFootprintDetails">
		<tr>
			<td>Document ID:</td>
			<td colspan="2">#docID#</td>
		</tr>
		<tr>
			<td width="20%">Fund Category:</td>
			<td>#fundCat#</td>
		</tr>
		<tr>
			<td>Vendor:</td>
			<td>#vendorName# (#vendorDuns#)</td>
		</tr>
		<tr>
			<td>Funding Office:</td>
			<td>#fundingOfficeNum# - #fundingOfficeDesc#</td>
		</tr>
		<tr>
			<td>Fund Code:</td>
			<td>#fundCode#</td>
		</tr>
		<tr>
			<td>Program Code:</td>
			<td>#programCode#</td>
		</tr>
		<tr>
			<td>Managing Unit:</td>
			<td>#managingUnit#</td>
		</tr>
		<tr>
			<td>Cost Center:</td>
			<td>#costCenter#</td>
		</tr>
		<tr>
			<td>Object Class:</td>
			<td>#objectClass#</td>
		</tr>
		<tr>
			<td>Obligation:</td>
			<td>#numberformat(oblig,"$9,999.99")#</td>
		</tr>
		<tr>
			<td>Payment:</td>
			<td>#numberformat(payment,"$9,999.99")#</td>
		</tr>
		<tr>
			<td>Cost:</td>
			<td>#numberformat(cost,"$9,999.99")#</td>
		</tr>
	</cfoutput>
	<tr>
		<td colspan="2" valign="bottom" height="40">
			<cfoutput><a href="aapp_foot_list.cfm?aapp=#url.aapp#"><< Return to Footprint Listing</a></cfoutput>
		</td>
	</tr>
	</table>
	<br>
			

</div>


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

