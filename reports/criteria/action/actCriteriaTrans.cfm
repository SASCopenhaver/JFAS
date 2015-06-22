<!---
Validation 

variables:
boolean variables.error
string variables.lstErrorMessage

check for errors, if there is an error set 
variables.error equal to true and add the message 
to the error message list
--->

<!---
Where Clause

variables:
string variables.whereClause

set the where clause that you want to use as your filter criteria

do not use "where" and do not start your statement with "and"
--->

<!---
page: actCriteriaTrans.cfm

description: JFAS Footprint Transaction Dataset Criteria Form (for use with adhoc tool) 

revisions:
2007-10-16  abai    Revised for displaying form criteria correctly
--->

<cfparam name="variables.whereClause" default="">
<cfset form.txtAAPPNum = Trim(form.txtAAPPNum)>

<!--- require at least one criteria --->
<cfif form.txtAAPPNum eq ""
	and form.txtVendor eq ""
	and form.txtStartDate eq ""
	and form.txtEndDate eq ""
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
<cfif not isDefined("form.ckbTransTypeO") and not isDefined("form.ckbTransTypeP") and not isDefined("form.ckbTransTypeC")>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "At least one Transaction Type must be selected.")>
</cfif>
<!--- check if select one funding type --->
<cfif not isDefined("form.ckbFundingTypeCRA") and not isDefined("form.ckbFundingTypeOPS")>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "At least one Funding Type must be selected.")>
</cfif>

<cfif not variables.error>

	<cfset variables.whereClause = "1 = 1">

	<!--- AAPP Number --->
	<cfif form.txtAAPPNum neq "">
		<cfset variables.whereClause = variables.whereClause & " and (AAPPNUM = '#form.txtAAPPNum#')">
	</cfif>
	<!--- Footprint Fiscal Year --->
	<cfif isDefined("form.cboFY") and form.cboFY neq "">
		<cfset variables.whereClause = variables.whereClause & " and (fy = '#form.cboFY#')">
	</cfif>
	<!--- Transaction Date --->
	<cfif form.txtStartDate neq "" and form.txtEndDate neq "">
		<cfset variables.whereClause = variables.whereClause & " and (DATE_XACTN between to_date('#form.txtStartDate#', 'mm/dd/yyyy') and to_date('#form.txtEndDate#', 'mm/dd/yyyy'))">
	<cfelseif form.txtStartDate neq "">
		<cfset variables.whereClause = variables.whereClause & " and (DATE_XACTN >= to_date('#form.txtStartDate#', 'mm/dd/yyyy'))">
	<cfelseif form.txtEndDate neq "">
		<cfset variables.whereClause = variables.whereClause & " and (DATE_XACTN <= to_date('#form.txtEndDate#', 'mm/dd/yyyy'))">
	</cfif>
	<!--- Transaction Type--->
	<cfset transType = "">
	<cfif isDefined("form.ckbTransTypeO") and form.ckbTransTypeO neq "">
		<cfset transType = transType & "'#form.ckbTransTypeO#'">
	</cfif>
	<cfif isDefined("form.ckbTransTypeP") and form.ckbTransTypeP neq "">
		<cfif transType eq "">
			<cfset transType = transType & "'#form.ckbTransTypeP#'">
		<cfelse>
			<cfset transType = transType & ",'#form.ckbTransTypeP#'">
		</cfif>
	</cfif>
	<cfif isDefined("form.ckbTransTypeC") and form.ckbTransTypeC neq "">
		<cfif transType eq "">
			<cfset transType = transType & "'#form.ckbTransTypeC#'">
		<cfelse>
			<cfset transType = transType & ",'#form.ckbTransTypeC#'">
		</cfif>
	</cfif> 
	<cfif transType neq "">
		<cfset variables.whereClause = variables.whereClause & " and (XACTN_TYPE_DESC in (#transType#))">
	</cfif>
	<!--- Funding Type--->
	<cfif isDefined("form.ckbFundingTypeCRA") and  form.ckbFundingTypeCRA neq "" and (not isDefined("form.ckbFundingTypeOPS"))>
		<cfset variables.whereClause = variables.whereClause & " and (OPS_CRA = 'CRA')">
	<cfelseif isDefined("form.ckbFundingTypeOPS") and form.ckbFundingTypeOPS neq "" and (not isDefined("form.ckbFundingTypeCRA"))>
		<cfset variables.whereClause = variables.whereClause & " and (OPS_CRA = 'OPS')">
	</cfif>
	<!--- Vendor --->
	<cfif form.txtVendor neq "">
		<cfset variables.whereClause = variables.whereClause & "and (upper(VENDOR) like '%#Ucase(form.txtVendor)#%')">
	</cfif>
</cfif>
