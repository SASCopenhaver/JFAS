<cfsilent>
<!---
page: data_import_log.cfm

description: Displays history of data imports

revisions:
2011-01-07	mstein	Page created
--->

<cfset request.pageID = "2315" /> 
<cfset request.pageTitleDisplay = "JFAS System Administration">

<cfparam name="url.maxRecords" default="30">
<cfparam name="url.importType" default="all">

<!--- get import history --->
<cfinvoke component="#application.paths.components#import_data" method="getImportHistory"
	importType="#url.importType#" maxRecords="#url.maxRecords#"  returnvariable="rstImportHistory">

<!--- get lookup of import types --->
<cfinvoke component="#application.paths.components#dataadmin" method="getImportTypeInfo" returnvariable="rstImportTypeInfo">

</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

				
	
				
<!--- Start Output --->	



<table width="100%" summary="Table used for layout">
<cfoutput>
<tr>
	<td><h2>Data Import History</h2></td>	
	
	<td class="dataTblCol" align="right">
		<cfif rstImportHistory.recordcount neq 0>
			Showing #min(url.maxRecords,rstImportHistory.totalRecords)# of #rstImportHistory.totalRecords# records
			<cfif rstImportHistory.recordcount neq rstImportHistory.totalRecords>
				&nbsp;|&nbsp;<a href="#cgi.SCRIPT_NAME#?maxRecords=#rstImportHistory.totalRecords#&importType=#url.importType#">Show All</a>
			</cfif>
		</cfif>
	</td>
	
	<!---
	<form name="frmImportType" action="#cgi.SCRIPT_NAME#" method="get">
	<td align="right">
		<!--- drop-down list for import types --->
		<label for="idImportType">Data Import Type</label>:
		<select name="importType" id="idImportType" tabindex="#request.nextTabIndex#">
			<cfloop query="rstImportTypeInfo">
				<option value="#importTypeCode#" <cfif importTypeCode eq url.importType>selected</cfif>>#importTypeDesc#</option>
			</cfloop>
		</select>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input type="submit" name="btnSubmit" value="Go" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		
	</td>
	</form>
	--->
	
</tr>
</cfoutput>
</table>
	
	
<!--- start data output ---> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<tr valign="bottom">
	<th scope="row">Date</th>
	<th>Import Type</th>
	<th>User</th>
	<th>Success</th>
	<th>Error Type</th>
	<th>Notes</th>
</tr>
		
<cfif rstImportHistory.recordcount is 0><!--- if there aren't any imports of this type --->
	
	<tr>
		<td colspan="10" align="center">
		<br /><br />
		There are no recorded imports of this type. Return to the <a href="<cfoutput>#application.paths.admin#</cfoutput>">Admin Section</a>.
		<br /><br /><br /></td>
	</tr>

<cfelse><!--- output records --->

	<cfoutput query="rstImportHistory">
		<tr valign="top" <cfif (currentRow mod 2) is 0>class="AltRow"</cfif>>
			<td align="center">#dateFormat(date_import, "mm/dd/yyyy")#, #timeFormat(date_import)#</td>
			<td align="center">#import_type_desc#</td>
			<td align="center">#user_id#</td>
			<td align="center"><cfif success>Yes<cfelse><span style="color:red;">No</span></cfif></td>
			<td>#error_type#</td>
			<td>#replace(note,"~","<BR />","all")#</td>
		</tr>
	</cfoutput>

</cfif>
</table>



<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />