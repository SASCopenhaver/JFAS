<cfsilent>
<!---
page: center_list.cfm

description: allows user to view / add Job Corps Centers

revisions:
2011-05-23	mstein	Fixed 508 issues (release 2.8)
--->

	<cfset request.pageID = "2410" /> 
<cfset request.pageTitleDisplay = "JFAS System Administration">
	<cfparam name="form.filterRange" default="25">
	<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->
	
	<cfinvoke component="#application.paths.components#center" method="getCenters" returnvariable="rstCenters">
	
	<cfinvoke component="#application.paths.components#center" method="filterCenterList" returnvariable="rstCenterBreaks" range="#form.filterRange#">
	
	<cfif rstCenterBreaks.recordcount gt 0>
		<cfparam name="form.cboCenterFilter" default="1">
		<cfloop query="rstCenterBreaks">
			<cfset form['start_' & currentrow] = start>
			<cfset form['end_' & currentrow] = end>
		</cfloop>
		<cfif form.cboCenterFilter neq 0>
			<cfquery name="rstCenters" dbtype="query">
				Select	*
				From	rstCenters
				Where	upper(centerName) between '#ucase(form['start_' & form.cboCenterFilter])#' and '#ucase(form['end_' & form.cboCenterFilter])#'
			</cfquery>
		</cfif>
	</cfif> 
	
</cfsilent>
<!--- include header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<h2>Centers</h2>

<table width="100%" cellpadding="0" cellspacing="0"  class="contentTbl" summary="Table used for layout">
	<cfoutput>
	<tr align="left">	
		<form name="frmFilterCenters" action="#cgi.SCRIPT_NAME#" method="post">
		<td>
			<label for="idCenterFilter" class="hiddenLabel">Select Center Range</label>
			<select name="cboCenterFilter" id="idCenterFilter">
				<cfloop query="rstCenterBreaks">
					<option value="#currentrow#" <cfif form.cboCenterFilter eq currentrow>selected</cfif>>
						#form['start_' & currentrow]# - #form['end_' & currentrow]#
					</option>
				</cfloop>
				<option value="0" <cfif form.cboCenterFilter eq 0>selected</cfif>>
				All Centers
				</option>
			</select>
			<input type="submit" name="btnSubmit" value="Go" />
		</td>
		</form>
		<form name="frmNewCenter" action="center_edit.cfm?centerID=0" method="post">
		<td align="right">
			<input type="hidden" name="hidMode" value="Add" />
			<input type="submit" name="btnAddCenter" value="Add New Center" />
		</td>
		</form>
	</tr>
	</cfoutput>
</table>
<cfoutput>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Display list of Centers">
<tr>
	<th scope="col" style="text-align:left">Name</th>
	<th scope="col" style="text-align:left">City</th>
	<th scope="col" style="text-align:left">State</th>
	<th scope="col" style="text-align:left">Funding Office</th>
	<th scope="col" style="text-align:left">Status</th>
</tr>		
<cfloop query="rstCenters">
<tr <cfif not (currentRow mod 2)>class="AltRow"</cfif>>
	<td><a href="center_edit.cfm?centerID=#centerID#">#centerName#</a></td>
	<td>#city#</td>
	<td>#state#</td>
	<td>#fundingOfficeNum# - #fundingOfficeDesc#</td>
	<td><cfif status eq 1>Active<cfelse>Inactive</cfif></td>
</tr>
</cfloop>
</table>

</cfoutput>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">