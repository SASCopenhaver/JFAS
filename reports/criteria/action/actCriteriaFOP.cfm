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
revisions:
2007-06-05	rroser	require at least one criterion, to shrink report size & runtime
2007-06-19	rroser	trim and strip single quotes from keyword field
2007-10-4	mstein	fixed defect in cost category criteria (for A with subcats)
2009-04-01	mstein	add ARRA (stimulus) as criteria
--->

<cfparam name="variables.whereClause" default="">
<cfset form.txtKeyword = trim(replace(form.txtKeyword, "'", "", "all"))>

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
<cfif form.txtAAPPNum neq "" and not IsNumeric(form.txtAAPPNum)>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "AAPP No. must be numeric value.")>
</cfif>

<!--- require at least one formfield to be entered --->
<cfif form.txtAAPPNum eq "" 
	and form.cboFundingOffice eq "all" 
	and form.cboPY eq "all" 
	and form.cboCostCategory eq "all" 
	and form.radARRA eq "all"
	and form.txtDateStart eq "" 
	and form.txtDateEnd eq "" 
	and form.txtKeyword eq "">
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "You must enter at least one criteria.")>
</cfif>

<cfif not variables.error>

	<cfset variables.whereClause = "1 = 1">

	<!--- AAPP Number --->
	<cfif form.txtAAPPNum neq "">
		<cfset variables.whereClause = variables.whereClause & " and (AAPPNUM = '#form.txtAAPPNum#')">
	</cfif>
	<!--- funding office --->
	<cfif form.cboFundingOffice neq "all">
			<cfset variables.whereClause = variables.whereClause & " and (FUNDINGOFFICENUM in (#form.cboFundingOffice#))">
	</cfif>
	<!--- Program Year --->
	<cfif form.cboPY NEQ "all">
		<cfset variables.whereClause = variables.whereClause & " and (PROGRAMYEAR = '#form.cboPY#')"> 
	</cfif>
	
	<!--- Issue date --->	
	<cfif form.txtDateStart NEQ "" and form.txtDateEnd NEQ "">
		<cfset variables.whereClause = variables.whereClause & " and (DATEEXECUTED between to_date('#form.txtDateStart#','mm/dd/yyyy') and to_date('#form.txtDateEnd#','mm/dd/yyyy'))"> 
	<cfelseif form.txtDateStart NEQ "">
		<cfset variables.whereClause = variables.whereClause & " and (DATEEXECUTED >= to_date('#form.txtDateStart#','mm/dd/yyyy'))"> 
	<cfelseif form.txtDateEnd NEQ "">
		<cfset variables.whereClause = variables.whereClause & " and (DATEEXECUTED <= to_date('#form.txtDateEnd#','mm/dd/yyyy'))"> 
	</cfif>
	
	<!--- cost category --->
	<cfif form.cboCostCategory NEQ "all">
		<cfset variables.whereClause = variables.whereClause & " and (COSTCATIDGROUP IN (#form.cboCostCategory#))"> 
	</cfif>
	
	<!--- ARRA --->
	<cfif form.radARRA neq "All">
		<cfif form.radARRA is 1>
			<cfset variables.whereClause = variables.whereClause & " and (upper(ARRA) = 'Y')">
		<cfelseif form.radARRA is 0>		
			<cfset variables.whereClause = variables.whereClause & " and (ARRA is null)">
		</cfif>
	</cfif>

	<!--- Keyword(FOP description) --->
	<cfif form.txtKeyword NEQ "">
		<cfif  find(",", form.txtKeyword) eq 0>
			<cfset variables.whereClause = variables.whereClause & " and (upper(FOPDESCRIPTION) like '%#ucase(form.txtKeyword)#%')"> 
		<cfelse>
			<cfloop index="i" list="#form.txtKeyword#" delimiters=",">
				<cfset variables.whereClause = variables.whereClause & " and (upper(FOPDESCRIPTION) like '%#ucase(i)#%')"> 
			</cfloop>
		</cfif>
	</cfif>
</cfif>
