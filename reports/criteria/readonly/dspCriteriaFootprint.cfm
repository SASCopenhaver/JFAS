<!---
revisions:
2007-06-18	rroser	add txtDocNum field
2007-06-18	rroser	added "Trim" function to txtAAPNum and txtDocNum fields - blank spaces will cause to display incorrectly
2009-03-19	mstein	add ARRA (stimulus) as criteria
2009-04-14	mstein	add IAC as criteria
--->

<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.cboFundingOffice" default="all">
<cfparam name="form.radFunds" default="">
<cfparam name="form.radOPSCRA" default="">
<cfparam name="form.txtIAC" default="">
<cfparam name="form.radARRA" default="">
<cfparam name="form.cboFY" default="">
<cfparam name="form.cboProj1" default="">
<cfparam name="form.radStatus" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>
<!--- get display version of form criteria --->
<cfif form.cboFundingOffice neq "all">
	<cfset fundOfficeDisplay = "">
	<cfloop list="#form.cboFundingOffice#" index="i">
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#i#" returnvariable="rsFundingOffice">
		<cfset fundOfficeDisplay = fundOfficeDisplay & rsFundingOffice.fundingOfficeDesc & "<br>">
	</cfloop>
</cfif>

<cfoutput>
<table width="100%" border="0" align="center" class="criteriaCellDisplay" cellpadding="0" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
		<td width="25%">
			AAPP No.:
		</td>
		<td width="75%">
			<cfif Trim(form.txtAAPPNum) neq "">
				#form.txtAAPPNum#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr valign="top">
		<td>Funding Office:</td>
		<td>
			<cfif form.cboFundingOffice neq "all">
				#fundOfficeDisplay#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td>FY:</td>
		<td>
			#form.cboFY#
		</td>
	</tr>
	<tr>
		<td>Document No:</td>
		<td>
			<cfif Trim(form.txtDocNum) neq "">
				#form.txtDocNum#
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
		<td>IAC:</td>
		<td>
			<cfif form.txtIAC neq "">
				#form.txtIAC#
			<cfelse>
				All
			</cfif>
		</td>
	
	</tr>
	<tr>
		<td nowrap>ARRA:&nbsp;</td>
		<td>
			<cfif form.radARRA neq "All">
				<cfif form.radARRA is 1>
					Yes
				<cfelseif form.radARRA is 0>
					No
				</cfif>
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td nowrap>Funds Available:&nbsp;</td>
		<td>
			<cfif form.radFunds neq "All">
				<cfif form.radFunds is 1>
					Yes
				<cfelseif form.radFunds is 0>
					No
				</cfif>
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td>Project 1 Code:</td>
		<td>
			#form.cboProj1#
		</td>
	</tr>
	<tr>
		<td>Status:</td>
		<td>
			<cfif form.radStatus neq "All">
				<cfif form.radStatus is 1>
					Active
				<cfelseif form.radStatus is 0>
					Inactive
				</cfif>
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	
</table>
</cfoutput>