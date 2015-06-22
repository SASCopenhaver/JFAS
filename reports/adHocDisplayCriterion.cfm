<cfoutput>
<table width="100%" border="0" cellpadding="0" 
	<cfif isDefined("url.format") and url.format eq "application/pdf">class="criteriaSummary"
	<cfelse> class="adHocFormDesc"</cfif>
	cellspacing="0" summary="Display report information">
	
	<tr><td>&nbsp;</td></tr>
	<tr>
		<td width="10%" valign="top">Criteria:</td>	
		<td width="60%">
			<cfset variables.obCriteria = session.adHocReport.getDataset().getCriteria()>
			<!--- insert include from the path passed into the tag and the filename in the database --->
			<cfinclude template="criteria/readonly/#variables.obCriteria.getReadOnlyFileName()#">
		</td>
		<td width="30%" align="right" valign="top">Total number of records retrieved: <strong>#qryGetAdHocResults.recordcount#</strong></td>
	</tr>
</table>
</cfoutput><br>