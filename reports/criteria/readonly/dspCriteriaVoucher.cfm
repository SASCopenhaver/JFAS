
<cfparam name="form.cboFundingOffice" default="">
<cfparam name="form.cboAgreementType" default="">
<cfparam name="form.cboServiceType" default="">
<cfparam name="form.Status" default="Y">
<cfparam name="form.txtContractor" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>
<!--- get display version of form criteria --->
<cfif form.radObligationType neq "all">
	<cfinvoke component="#application.paths.components#lookup" method="getVoucherTypes" voucherTypeCode="#form.radObligationType#" returnvariable="rsVoucherType">
</cfif>


<cfoutput>
<table width="100%" border="0" align="center" class="criteriaCellDisplay" cellpadding="0" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
		<tr>
		<td width="30%">
			AAPP No.:
		</td>
		<td width="70%">#form.txtAAPPNum#</td>
	</tr>
	<tr>
		<td nowrap>Date Vendor Signed:&nbsp;</td>
		<td>
			<cfif form.txtDateStart neq "" or form.txtDateEnd neq "">
				<cfif form.txtDateStart neq "">
					#form.txtDateStart#
				</cfif>
				<cfif form.txtDateEnd neq "">
					<cfif form.txtDateStart neq "">
						to 
					<cfelse>
						No later than
					</cfif>
					#form.txtDateEnd#
				<cfelse>
					to present
				</cfif>
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td>OPS/CRA:</td>
		<td>
			#form.radOPSCRA#
		</td>
	</tr>
	<tr>
		<td>Obligation Type:</td>
		<td>
			<cfif form.radObligationType neq "all">
				#rsVoucherType.voucherTypeDesc#
			<cfelse>
				All
			</cfif>
			
		</td>
	</tr>
</table>
</cfoutput>