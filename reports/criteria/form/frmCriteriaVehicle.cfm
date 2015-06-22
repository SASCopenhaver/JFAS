<!---
page: lookup.cfc

description: JFAS Equipment Dataset Criteria Form (for use with adhoc tool) 

revisions:
--->

<cfparam name="form.cboCenter" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>

<!--- get reference data for drop-down lists --->
<cfinvoke component="#application.paths.components#center" method="getCenters" returnvariable="rstCenters">


<cfoutput>
<table width="100%" border="0" align="center" cellpadding="3" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
	<td width="18" valign="top" class="StepNumber">5.</td>
	<td colspan="2">Choose Criteria (filter)</td>
</tr>
<tr>
	<td width="18"></td>
	<td width="230" align="right"><label for="idCenter">Center</label></td>
	<td width="*">
		<select name="cboCenter" id="idCenter" tabindex="#request.nextTabIndex#">
		<option value="all">All</option>
		<cfloop query="rstCenters">
			<option value="#CenterName#"
				<cfif CenterName eq form.cboCenter>SELECTED</cfif>>#CenterName#
			</option>
		</cfloop>
		</select><cfset request.nextTabIndex=request.nextTabIndex+1>
	</td>
</tr>





</table>
</cfoutput>