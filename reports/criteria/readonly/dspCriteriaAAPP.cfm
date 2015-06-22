
<cfparam name="form.cboFundingOffice" default="all">
<cfparam name="form.cboAgreementType" default="">
<cfparam name="form.cboServiceType" default="">
<cfparam name="form.Status" default="Y">
<cfparam name="form.txtContractor" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>
<!--- get display version of form criteria --->
<cfif form.cboFundingOffice neq "all">
	<cfset fundOfficeDisplay = "">
	<cfloop list="#form.cboFundingOffice#" index="i">
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#i#" returnvariable="rsFundingOffice">
		<cfset fundOfficeDisplay = fundOfficeDisplay & rsFundingOffice.fundingOfficeDesc & "<br>">
	</cfloop>
</cfif>
<cfif form.cboAgreementType	 neq "all">
	<cfinvoke component="#application.paths.components#lookup" method="getAgreementTypes" agreementTypeCode="#form.cboAgreementType#" returnvariable="rsAgreementType">
</cfif>
<cfif form.cboServiceType neq "all">
	<cfinvoke component="#application.paths.components#lookup" method="getServiceTypes" contractTypeCode="#form.cboServiceType#" returnvariable="rsServiceType">
</cfif>

<cfoutput>
<table width="100%" border="0" align="center" class="criteriaCellDisplay" cellpadding="0" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr valign="top">
		<td width="25%">
			Funding Office:
		</td>
		<td width="75%">
			<cfif form.cboFundingOffice neq "all">
				#fundOfficeDisplay#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td nowrap>Agreement Type:&nbsp;</td>
		<td>
			<cfif form.cboAgreementType	neq "all">
				#rsAgreementType.agreementTypeDesc#
			<cfelse>
				All
			</cfif>
			
		</td>
	</tr>
	<tr>
		<td>Service Type:</td>
		<td>
			<cfif #form.cboServiceType#	 neq "all">
				#rsServiceType.contractTypeLongDesc#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td>Status:</td>
		<td>
			<cfif form.Status eq 1>
				Active
			<cfelseif form.Status eq 0>
				Inactive
			<cfelse>
				All
			</cfif>
			
		</td>
	</tr>
	<tr>
		<td>Contractor:</td>
		<td>
			#form.txtContractor#
			
		</td>
	</tr>
</table>
</cfoutput>