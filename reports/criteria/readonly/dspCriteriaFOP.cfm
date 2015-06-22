
<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.cboPY" default="">
<cfparam name="form.cboCostCategory" default="">
<cfparam name="form.radARRA" default="">
<cfparam name="form.txtDateStart" default="">
<cfparam name="form.txtDateEnd" default="">
<cfparam name="form.txtKeyword" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>
<!--- get display version of form criteria --->
<cfif form.cboCostCategory neq "all">
	<cfset costCatDisplay = "">
	<cfloop list="#form.cboCostCategory#" index="i">
		<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" costCatID="#i#" returnvariable="rsCostCategory">
		<cfset costCatDisplay = costCatDisplay & rsCostCategory.costCatCode & ", ">
	</cfloop>
	<cfset costCatDisplay = left(costCatDisplay, len(costCatDisplay)-2)>
</cfif>
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
		<td width="75%">#form.txtAAPPNum#</td>
	</tr>
	<tr valign="top">
		<td nowrap>Funding Office:&nbsp;</td>
		<td>
			<cfif form.cboFundingOffice neq "all">
				#fundOfficeDisplay#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td>Program Year:</td>
		<td>
			<cfif form.cboPY neq "all">
				#form.cboPY#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td>Cost Category:</td>
		<td>
			<cfif #form.cboCostCategory# neq "all">
				#costCatDisplay#
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
		<td>Date Issued:</td>
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
		<td>
			Keyword:
		</td>
		<td>#form.txtKeyword#</td>
	</tr>
</table>
</cfoutput>