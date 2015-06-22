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


<cfif not variables.error>

	<cfset variables.whereClause = "1 = 1">

	<!--- funding office --->
	<cfif form.cboFundingOffice neq "all">
			<cfset variables.whereClause = variables.whereClause & " and (FUNDINGOFFICENUM in (#form.cboFundingOffice#))">
	</cfif>
	
	<!--- agreement type --->	
	<cfif form.cboAgreementType NEQ "all">
		<cfset variables.whereClause = variables.whereClause & " and (AGREEMENTTYPECODE = '#form.cboAgreementType#')"> 
	</cfif>
	
	<!--- sevice type --->
	<cfif form.cboServiceType NEQ "all">
		<cfset variables.whereClause = variables.whereClause & " and (SERVICETYPELIST like '%#form.cboServiceType#%')"> 
	</cfif>
	
	<!--- status--->
	<cfif form.Status neq "all">
		<cfset variables.whereClause = variables.whereClause & " and (CONTRACTSTATUSID = '#form.Status#')"> 
	</cfif>
	
	<cfif form.txtContractor neq "">
		<cfset variables.whereClause = variables.whereClause & " and (upper(contractorname) like '%#ucase(form.txtContractor)#%')"> 
	</cfif>
</cfif>
