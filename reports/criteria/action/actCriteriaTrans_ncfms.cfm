
<!---
page: actCriteriaTrans_ncfms.cfm

description: JFAS NCFMS Footprint Transaction Dataset Criteria Form (for use with adhoc tool) 

revisions:
2010-01-05	mstein	File Created
--->

<cfparam name="variables.whereClause" default="">
<cfset form.txtAAPPNum = Trim(form.txtAAPPNum)>

<!--- require at least one criteria --->
<cfif form.txtAAPPNum eq ""
	and form.txtVendor eq ""
	and form.txtStartDate eq ""
	and form.txtEndDate eq ""
	and form.radFundCat eq "All"
	and form.ckbTransType eq ""
	and form.cboFY eq "">
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "You must enter at least one criteria.")>	
</cfif>
<!--- check if aapp is numeric --->
<cfif form.txtAAPPNum neq "" and not IsNumeric(form.txtAAPPNum)>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "AAPP No. must be numeric value.")>
</cfif>
<!--- check if start date and end date format correctly --->
<cfif isDefined("form.txtStartDate") and form.txtStartDate neq "" and not isDate(form.txtStartDate)>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "First Date in Date Range must be a date formated as mm/dd/yyyy.")>
</cfif>
<cfif isDefined("form.txtEndDate") and form.txtEndDate neq "" and not isDate(form.txtEndDate)>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "Second Date in Date Range must be a date formated as mm/dd/yyyy.")>
</cfif>
<!--- check if select one transaction type --->
<cfif not isDefined("form.ckbTransType")>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "At least one Transaction Type must be selected.")>
</cfif>


<cfif not variables.error>

	<cfset variables.whereClause = "1 = 1">

	<!--- AAPP Number --->
	<cfif form.txtAAPPNum neq "">
		<cfset variables.whereClause = variables.whereClause & " and (AAPPNUM = '#form.txtAAPPNum#')">
	</cfif>
	<!--- Footprint Fiscal Year --->
	<cfif isDefined("form.cboFY") and form.cboFY neq "">
		<cfset variables.whereClause = variables.whereClause & " and (appropfy = '#form.cboFY#')">
	</cfif>
	<!--- Transaction Date --->
	<cfif form.txtStartDate neq "" and form.txtEndDate neq "">
		<cfset variables.whereClause = variables.whereClause & " and (creationDate between to_date('#form.txtStartDate#', 'mm/dd/yyyy') and to_date('#form.txtEndDate#', 'mm/dd/yyyy'))">
	<cfelseif form.txtStartDate neq "">
		<cfset variables.whereClause = variables.whereClause & " and (creationDate >= to_date('#form.txtStartDate#', 'mm/dd/yyyy'))">
	<cfelseif form.txtEndDate neq "">
		<cfset variables.whereClause = variables.whereClause & " and (creationDate <= to_date('#form.txtEndDate#', 'mm/dd/yyyy'))">
	</cfif>
	<!--- Transaction Type--->
	<cfset variables.whereClause = variables.whereClause & "and (xactnTypeCode in (#listQualify(form.ckbTransType,"'",",","all")#))">
	
	
	<!--- Funding Category--->
	<cfif form.radFundCat neq "All">
		<cfset variables.whereClause = variables.whereClause & " and (upper(fundcat) = '#ucase(form.radFundCat)#')">
	</cfif>
	
	<!--- Vendor --->
	<cfif form.txtVendor neq "">
		<cfset variables.whereClause = variables.whereClause & "and (upper(vendorname) like '%#Ucase(form.txtVendor)#%')">
	</cfif>
</cfif>
