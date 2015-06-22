<cfsilent>
<!---
page: setaside_list.cfm.cfm

description: list of setaside categories to edit, or button to add a new category

revisions:

--->

<cfset request.pageID = "2450" /> 
<cfset request.pageTitleDisplay = "JFAS System Administration">

<!--- get list of SMB Setasides --->
<cfinvoke component="#application.paths.components#dataadmin" method="getSetAsideTypes" returnvariable="rstSetAsideTypes">
</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />
				
<h2>Small Business Set Aside Categories</h2>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Table used for layout">
<tr>
	<td>
		<cfoutput>Displaying 1-#rstSetAsideTypes.recordcount# of #rstSetAsideTypes.recordcount# categories</cfoutput>
	</td>
	<form name="frmAddCategory" action="setaside_edit.cfm" method="get">
	<td align="right"><!--- submit info to edituser page for adding new user --->
		<cfoutput>
		<input type="hidden" name="setAsideID" value="0" />
		<input type="submit" name="btnSubmit" value="Add New Category" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfoutput>
	</td>
	</form>
</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Display list of SMB Categories">
<tr>
	<th scope="col" style="text-align:left">Sort</th>
	<th scope="col" style="text-align:left">Description</th>
</tr>		
	<cfoutput query="rstSetAsideTypes">
	<tr valign="top" <cfif not (currentRow mod 2)>class="AltRow"</cfif>>
		<td>#sortOrder#</td>
		<td><a href="setaside_edit.cfm?setAsideID=#setasideID#">#setasideDesc#</a></td>
	</tr>
	</cfoutput>
</table>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />