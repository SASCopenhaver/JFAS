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


<cfif (form.txtDateStart neq "" and (not isDate(form.txtDateStart) or len(form.txtDateStart) neq 10)) or
		(form.txtDateEnd neq "" and (not isDate(form.txtDateEnd) or len(form.txtDateEnd) neq 10))>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "Modification Date range must be entered in format mm/dd/yyyy.")>
<cfelseif (form.txtDateStart neq "" and form.txtDateEnd neq "")>
	<cfif dateCompare(form.txtDateStart,form.txtDateEnd) eq 1>
		<cfset variables.error = "true">
		<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "From date must be earlier than To date in Date Issued range.")>
	</cfif>
</cfif>
<cfif form.txtAAPPNum neq "" and not IsNumeric(form.txtAAPPNum)>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "AAPP No. must be numeric value.")>
</cfif>

<cfif not variables.error>

	<cfset variables.whereClause = "1 = 1">

	<!--- AAPP Number --->
	<cfif form.txtAAPPNum neq "">
		<cfset variables.whereClause = variables.whereClause & " and (AAPPNO = '#form.txtAAPPNum#')">
	</cfif>
	
	<!--- Modification date --->	
	<cfif form.txtDateStart NEQ "" and form.txtDateEnd NEQ "">
		<cfset variables.whereClause = variables.whereClause & " and (MODDATE between to_date('#form.txtDateStart#','mm/dd/yyyy') and to_date('#form.txtDateEnd#','mm/dd/yyyy'))"> 
	<cfelseif form.txtDateStart NEQ "">
		<cfset variables.whereClause = variables.whereClause & " and (MODDATE >= to_date('#form.txtDateStart#','mm/dd/yyyy'))"> 
	<cfelseif form.txtDateEnd NEQ "">
		<cfset variables.whereClause = variables.whereClause & " and (MODDATE <= to_date('#form.txtDateEnd#','mm/dd/yyyy'))"> 
	</cfif>
	
	<!--- User Name --->
	<cfif form.cboUserName NEQ "all">
		<cfset variables.whereClause = variables.whereClause & " and (userID = '#form.cboUserName#')"> 
	</cfif>

</cfif>
