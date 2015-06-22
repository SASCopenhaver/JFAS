<cfsilent>
<!---
page: RecentUpdates_list.cfm

description: allows user to view / add Release Notes

revisions:

--->

	<cfset request.pageID = "2810" />
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfinvoke component="#application.paths.components#dataadmin" method="getRelease" returnvariable="allRelease">


</cfsilent>
<!--- include header --->
<cfinclude template="#application.paths.includes#header.cfm" />
<cfoutput>
<table width="100%" cellpadding="0" cellspacing="0" summary="Table used for layout">
<tr>
	<td align="left">
		<h2>Recent Updates</h2>
	</td>
	<form name="frmNewRelease" action="release_edit.cfm?rid=0" method="post">
		<td align="right">
			<input type="submit" name="btnNewRelease" value="Add a New Release" style="font-family:Arial, Helvetica, sans-serif; font-size:0.7em;" />
		</td>
	</form>
</tr>
</table>
<cfif isDefined("url.deleted")>
		<div class="confirmList">
		<cfoutput><li>Release has been deleted.</cfoutput>
		</div><br />
<cfelseif isDefined("url.itemDeleted")>
	<div class="confirmList">
		<cfoutput><li>Release item has been deleted.</cfoutput>
		</div><br />
</cfif>

<table width="100%" cellpadding="0" cellspacing="0"  class="contentTbl" summary="Table used for layout">
<cfif allRelease.recordcount is 0>
	<tr>
		<td align="center">
		There is currently no information on recent updates.
		</td>
	</tr>
<cfelse>
	<cfset currentRelease = 0>
	<cfset rowCount = 1>
	<cfloop query="allRelease">
		<cfif currentRelease neq ReleaseID>
			<cfif currentRelease neq 0>
			<tr>
				<td colspan="2">
				 <hr />
				</td>
			</tr>
			</cfif>
		<tr>
			<td colspan="2">
				<a href="release_edit.cfm?rId=#releaseID#">JFAS Release #ReleaseNo#<cfif ReleaseName neq ''> - #releaseName#</cfif></a>
			</td>
		</tr>
		</cfif>
		<cfif ReleaseItemDesc neq ''>
		<tr <cfif (rowCount mod 2)>class="AltRow"</cfif>>
			<td width="15"></td>
			<td>
				<a href="releaseItem_edit.cfm?rId=#releaseID#&rItemID=#releaseItemID#" style="font-weight:500">#Replace(ReleaseItemDesc, Chr(13) & Chr(10), "<br />", "ALL")#</a>
			</td>
		</tr>
		</cfif>
		<cfset nextRow = allRelease.currentRow + 1>
		<cfif allRelease[ "ReleaseID" ][ currentRow ] neq allRelease[ "ReleaseID"][nextRow]>
		<cfset rowCount = rowCount+ 1>
		<tr <cfif (rowCount mod 2)>class="AltRow"</cfif>>
				<td width="15"></td>
				<td>
					<a href="releaseItem_edit.cfm?rId=#releaseID#&rItemID=0" style="font-weight:500">+ Add New Release Item</a>
				</td>
		</tr>
		</cfif>

		<cfset rowCount = rowCount + 1>
		<cfset currentRelease = ReleaseID>
	</cfloop>

</cfif>
</table>
</cfoutput>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">