<!---
page: dspCriteriaTrans_ncfms.cfm

description: JFAS NCFMS Footprint Transaction Dataset Criteria display page(for use with adhoc tool) 

revisions:
2010-01-05	mstein	File Created
--->


<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.txtEndDate" default="">
<cfparam name="form.txtStartDate" default="">
<cfparam name="form.cboFY" default="">
<cfparam name="form.cboFundCat" default="">
<cfparam name="form.ckbTransType" default="">
<cfparam name="form.txtVendor" default="">
<cfset transType ="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>
<!--- get descriptions for transaction types --->
<cfinvoke component="#application.paths.components#lookup" method="getNCFMSTransTypes" transType="#form.ckbTransType#" returnvariable="rsNCFMSTransTypes">

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
	<tr valign="top">
		<td>Transaction Type(s):</td>
		<td>
			<cfloop query="rsNCFMSTransTypes">
				#xactn_type_desc#<cfif currentRow neq rsNCFMSTransTypes.recordCount>,</cfif>
			</cfloop>
		</td>
	</tr>
	<tr>
		<td>Funding Category:</td>
		<td>
			#form.radFundCat#
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