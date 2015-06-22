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
	<cfif form.cboCenter neq "all">
			<cfset variables.whereClause = variables.whereClause & " and (Center = '#form.cboCenter#')">
	</cfif>
	
</cfif>
