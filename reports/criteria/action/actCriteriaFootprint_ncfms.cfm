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
2010-01-05	mstein	file created
--->
<cfparam name="variables.whereClause" default="">
<cfset form.txtDocNum = trim(replace(replace(form.txtDocNum, '"', '', 'all'), "'", "", "all"))>
<cfset form.txtAAPPNum = Trim(form.txtAAPPNum)>

<cfif form.txtAAPPNum neq "" and not IsNumeric(form.txtAAPPNum)>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "AAPP No. must be numeric value.")>
</cfif>


<!--- require at least one criteria --->
<cfif form.txtAAPPNum eq ""
	and form.txtDocNum eq ""
	and form.cboFundingOffice eq "all"
	and form.cboFY eq "All"
	and form.radFundCat eq "All"
	and form.radARRA eq "All"
	and form.radFunds eq "All"
	and form.radStatus eq "All">
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "You must enter at least one criteria.")>
</cfif>

<cfif not variables.error>

	<cfset variables.whereClause = "1 = 1">

	<!--- AAPP Number --->
	<cfif form.txtAAPPNum neq "">
		<cfset variables.whereClause = variables.whereClause & " and (aappNum = #form.txtAAPPNum#)">
	</cfif>
	<!--- funding office --->
	<cfif form.cboFundingOffice neq "all">
		<cfset variables.whereClause = variables.whereClause & " and (FUNDINGOFFICENUM in (#form.cboFundingOffice#))">
	</cfif>
	<!--- FY --->
	<cfif form.cboFY neq "All">
		<cfset variables.whereClause = variables.whereClause & " and (appropfy = '#form.cboFY#')">
	</cfif>
	<!--- FY --->
	<cfif form.cboPY neq "All">
		<cfset variables.whereClause = variables.whereClause & " and (approppy = '#form.cboPY#')">
	</cfif>
	<!--- Doc Num --->
	<cfif form.txtDocNum neq "">
		<cfset variables.whereClause = variables.whereClause & "and (upper(docnum) = '#ucase(form.txtDocNum)#')">
	</cfif>
	<!--- OPS/CRA --->
	<cfif form.radFundCat neq "All">
		<cfset variables.whereClause = variables.whereClause & " and (upper(fundcat) = '#ucase(form.radFundCat)#')">
	</cfif>
	<!--- ARRA --->
	<cfif form.radARRA neq "All">
		<cfif form.radARRA is 1>
			<cfset variables.whereClause = variables.whereClause & " and (upper(ARRA) = 'Y')">
		<cfelseif form.radARRA is 0>
			<cfset variables.whereClause = variables.whereClause & " and (ARRA is null)">
		</cfif>
	</cfif>
	<!--- Funds Available --->
	<cfif form.radFunds neq "All">
		<cfif form.radFunds is 1>
			<cfset variables.whereClause = variables.whereClause & " and (AVAIL > 0)">
		<cfelseif form.radFunds is 0>
			<cfset variables.whereClause = variables.whereClause & " and (AVAIL = 0)">
		</cfif>
	</cfif>
	<!--- Status --->
	<cfif form.radStatus neq "All">
		<cfset currentPY = application.outility.getCurrentSystemProgramYear ()>
		<cfif form.radStatus is 1>
			<cfset variables.whereClause = variables.whereClause & " and (expirePY >= '#currentPY#')">
		<cfelseif form.radStatus is 0>
			<cfset variables.whereClause = variables.whereClause & " and (expirePY < '#currentPY#')">
		</cfif>
	</cfif>

</cfif>
