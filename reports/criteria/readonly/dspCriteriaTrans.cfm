<!---
page: dspCriteriaTrans.cfm

description: JFAS Footprint Transaction Dataset Criteria display page(for use with adhoc tool) 

revisions:
2007-06-18	rroser	added "Trim" function to txtAAPNum and txtDocNum fields - blank spaces will cause to display incorrectly
2007-10-16  abai    Revised for displaying form criteria correctly
--->


<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.txtEndDate" default="">
<cfparam name="form.txtStartDate" default="">
<cfparam name="form.cboFY" default="">
<cfparam name="form.ckbTransTypeO" default="">
<cfparam name="form.ckbTransTypeP" default="">
<cfparam name="form.ckbTransTypeC" default=""> 
<cfparam name="form.ckbFundingTypeOPS" default="">
<cfparam name="form.ckbFundingTypeCRA" default="">
<cfparam name="form.txtVendor" default="">
<cfset transType ="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>

<cfoutput>
<table width="100%" border="0" align="center" class="criteriaCellDisplay" cellpadding="0" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
		<td width="30%">
			AAPP No.:
		</td>
		<td width="70%">
			<cfif isDefined("form.txtAAPPNum")>
				#form.txtAAPPNum#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td width="37%">
			Footprint Fiscal Year:
		</td>
		<td width="63%">
			<cfif isDefined("form.cboFY") and form.cboFY NEQ "">
				#form.cboFY#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td nowrap>Transaction Date Range:&nbsp;</td>
		<td>
			<cfif isdefined("form.txtStartDate") and form.txtStartDate neq "" and isDefined("form.txtEndDate") and form.txtEndDate neq "">
				#form.txtStartDate# through #form.txtEndDate#
			<cfelseif isdefined("form.txtStartDate") and form.txtStartDate neq "" and form.txtEndDate eq "">
				#form.txtStartDate# to now
			</cfif>
		</td>
	</tr>
	<tr>
		<td>Transaction Type:</td>
		<td>
			<cfif isDefined("form.ckbTransTypeO") and form.ckbTransTypeO neq "">
				<cfset transType = transType & "#form.ckbTransTypeO#s">
			</cfif>
			<cfif isDefined("form.ckbTransTypeP") and form.ckbTransTypeP neq "">
				<cfif transType eq "">
					<cfset transType = transType & "#form.ckbTransTypeP#s">
				<cfelse>
					<cfset transType = transType & ", #form.ckbTransTypeP#s">
				</cfif>
			</cfif>
			<cfif isDefined("form.ckbTransTypeC") and form.ckbTransTypeC neq "">
				<cfif transType eq "">
					<cfset transType = transType & "#form.ckbTransTypeC#s">
				<cfelse>
					<cfset transType = transType & ", #form.ckbTransTypeC#s">
				</cfif>
			</cfif>
			<cfif transType neq "">
				#transType#
			<cfelse>
				&nbsp;
			</cfif>
		</td>
	</tr>
	<tr>
		<td>Funding Type:</td>
		<td>
			<cfif isDefined("form.ckbFundingTypeOPS") and isDefined("form.ckbFundingTypeCRA") and form.ckbFundingTypeOPS neq "" and form.ckbFundingTypeCRA neq "">
				#form.ckbFundingTypeOPS#, #form.ckbFundingTypeCRA#
			<cfelseif isDefined("form.ckbFundingTypeOPS") and form.ckbFundingTypeOPS neq "">
				#form.ckbFundingTypeOPS#
			<cfelseif isDefined("form.ckbFundingTypeCRA") and form.ckbFundingTypeCRA neq "">
				#form.ckbFundingTypeCRA#
			<cfelse>
				&nbsp;
			</cfif>
		</td>
	
	</tr>
	<tr>
		<td>Vendor:</td>
		<td>
			<cfif isDefined("form.txtVendor")>
				#form.txtVendor#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	
</table>
</cfoutput>