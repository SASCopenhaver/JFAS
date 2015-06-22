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
<cfparam name="variables.whereClause" default="">

<!--- validate AAPP no --->
<cfif form.txtAAPPNum neq "" and not IsNumeric(form.txtAAPPNum)>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "AAPP No. must be numeric value.")>
</cfif>
<!--- validate Vendor Signed Date Range --->
<cfif (form.txtDateStart neq "" and (not isDate(form.txtDateStart) or len(form.txtDateStart) neq 10)) or
		(form.txtDateEnd neq "" and (not isDate(form.txtDateEnd) or len(form.txtDateEnd) neq 10))>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "Date Issued range must be entered in format mm/dd/yyyy.")>
<cfelseif (form.txtDateStart neq "" and form.txtDateEnd neq "")>
	<cfif dateCompare(form.txtDateStart,form.txtDateEnd) eq 1>
		<cfset variables.error = "true">
		<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "From date must be earlier than To date in Date Issued range.")>
	</cfif>
</cfif>

<!--- require at least one formfield to be entered --->
<cfif form.txtAAPPNum eq ""  
	and form.txtDateStart eq "" 
	and form.txtDateEnd eq "" 
	and form.radOPSCRA eq "All"
	and form.radObligationType eq "All">
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "You must enter at least one criteria.")>
</cfif>

<cfif not variables.error>

	<cfset variables.whereClause = "1 = 1">
	
	<!--- AAPP Number --->
	<cfif form.txtAAPPNum neq "">
		<cfset variables.whereClause = variables.whereClause & " and (AAPPNUM = '#form.txtAAPPNum#')">
	</cfif>
		
	<!--- Vendor Signed Date --->	
	<cfif form.txtDateStart NEQ "" and form.txtDateEnd NEQ "">
		<cfset variables.whereClause = variables.whereClause & " and (dateVendorSigned between to_date('#form.txtDateStart#','mm/dd/yyyy') and to_date('#form.txtDateEnd#','mm/dd/yyyy'))"> 
	<cfelseif form.txtDateStart NEQ "">
		<cfset variables.whereClause = variables.whereClause & " and (dateVendorSigned >= to_date('#form.txtDateStart#','mm/dd/yyyy'))"> 
	<cfelseif form.txtDateEnd NEQ "">
		<cfset variables.whereClause = variables.whereClause & " and (dateVendorSigned <= to_date('#form.txtDateEnd#','mm/dd/yyyy'))"> 
	</cfif>
	
	<!--- OPS/CRA --->
	<cfif form.radOPSCRA neq "All">
		<cfif form.radOPSCRA is "OPS">
			<cfset variables.whereClause = variables.whereClause & " and (opsThisInvoice != 0)">
		<cfelseif form.radOPSCRA is "CRA">
			<cfset variables.whereClause = variables.whereClause & " and (craThisInvoice != 0)">
		</cfif>
	</cfif>
	
	<!--- Contract / Purchase Order --->
	<cfif form.radObligationType neq "All">
		<cfset variables.whereClause = variables.whereClause & " and (obligationTypeCode = '#form.radObligationType#')">
	</cfif>
</cfif>
