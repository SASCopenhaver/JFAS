<cfsilent>
<!---
page: Contractor_list.cfm

description: allows user to view / add Job Corps Contractors

revisions:
2011-05-23	mstein	Fixed 508 issues (release 2.8)
--->

	<cfset request.pageID = "2420" /> 
	<cfset request.pageTitleDisplay = "JFAS System Administration">
	<cfparam name="form.filterRange" default="25">
	<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->
	
	<cfinvoke component="#application.paths.components#contractor" method="getContractors" status="all" returnvariable="rstContractors">
	
	<cfinvoke component="#application.paths.components#contractor" method="filterContractorList" 
	range="#form.filterRange#" 
	returnvariable="rstContractorBreaks">
	
	<cfif rstContractorBreaks.recordcount gt 0>
		<cfparam name="form.cboContractorFilter" default="1">
		<cfloop query="rstContractorBreaks">
			<cfset form['start_' & currentrow] = start>
			<cfset form['end_' & currentrow] = end>
		</cfloop>
		<cfif form.cboContractorFilter neq 0>
			<cfquery name="rstContractors" dbtype="query">
				Select	*
				From	rstContractors
				Where	upper(ContractorName) between '#ucase(form['start_' & form.cboContractorFilter])#' and '#ucase(form['end_' & form.cboContractorFilter])#'
			</cfquery>
		</cfif>
	</cfif> 
	
</cfsilent>
<!--- include header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<h2>Contractors</h2>
<cfoutput>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Table used for layout">
<tr>
	<form name="frmFilterContractors" action="#cgi.SCRIPT_NAME#" method="post">
		<td style="text-align:left">
			<label for="idContractorFilter" class="hiddenLabel">Select Contractor Range</label>
			<select name="cboContractorFilter" id="idContractorFilter">
				<cfloop query="rstContractorBreaks">
					<option value="#currentrow#" <cfif form.cboContractorFilter eq currentrow>selected</cfif>>
						#form['start_' & currentrow]# &nbsp;&nbsp;-&nbsp;&nbsp; #form['end_' & currentrow]#
					</option>
				</cfloop>
				<option value="0" <cfif form.cboContractorFilter eq 0>selected</cfif>>
				All Contractors
				</option>
			</select>
			<input type="submit" name="btnSubmit" value="Go" />
		</td>
	</form>
	<form name="frmNewContractor" action="Contractor_edit.cfm?ContractorID=0" method="post">
		<td align="right">
			<input type="hidden" name="hidMode" value="Add" />
			<input type="submit" name="btnAddContractor" value="Add New Contractor" />
		</td>
	</form>
</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Display list of Contractors">
<tr>
	<th scope="col" style="text-align:left">Name</th>
	<th scope="col" style="text-align:left">Status</th>
</tr>		
<cfloop query="rstContractors">
<tr <cfif not (currentRow mod 2)>class="AltRow"</cfif>>
	<td><a href="Contractor_edit.cfm?ContractorID=#ContractorID#">#ContractorName#</a></td>
	<td><cfif status eq 1>Active<cfelse>Inactive</cfif></td>
</tr>
</cfloop>
</table>

</cfoutput>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">