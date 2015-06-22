
<cfparam name="form.cboFundingOffice" default="">
<cfparam name="form.cboAgreementType" default="">
<cfparam name="form.cboServiceType" default="">
<cfparam name="form.Status" default="Y">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>
<!--- get display version of form criteria --->
<cfif form.cboCenter neq "all">
	<cfinvoke component="#application.paths.components#center" method="getCenters" centerName="#form.cboCenter#" returnvariable="rstCenters">
</cfif>


<cfoutput>
<table width="100%" border="0" align="center" class="criteriaCellDisplay" cellpadding="0" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
		<td width="15%" nowrap>
			Center:&nbsp;
		</td>
		<td width="85%">
			<cfif form.cboCenter neq "all">
				#rstCenters.CenterName#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	
</table>
</cfoutput>