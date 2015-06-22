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
2007-06-05	rroser	require at least one criteria be entered
2007-06-18	rroser	add document number as criteria
2007-06-18	rroser	added "Trim" function to txtAAPNum and Trim and Replace function to txtDocNum fields -
					otherwise will search on blank spaces, single and double quotes
2009-03-19	mstein	add ARRA (stimulus) as criteria
2009-04-14	mstein	add IAC as criteria
--->
<cfparam name="variables.whereClause" default="">
<cfset form.txtDocNum = trim(replace(replace(form.txtDocNum, '"', '', 'all'), "'", "", "all"))>
<cfset form.txtAAPPNum = Trim(form.txtAAPPNum)>

<cfif form.txtAAPPNum neq "" and not IsNumeric(form.txtAAPPNum)>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "AAPP No. must be numeric value.")>
</cfif>

<cfset form.txtIAC = replace(form.txtIAC, " ", "", "all")>
<cfset tmpIAC = replace(form.txtIAC, ',', '', 'all')>

<cfif tmpIAC neq "" and not IsNumeric(tmpIAC)>
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "IAC must only contain numeric values and commas.")>
</cfif>

<!--- require at least one criteria --->
<cfif form.txtAAPPNum eq ""
	and form.txtDocNum eq ""
	and form.cboFundingOffice eq "all"
	and form.cboFY eq "All"
	and form.radOPSCRA eq "All"
	and form.txtIAC eq ""
	and form.radARRA eq "All"
	and form.radFunds eq "All"
	and form.cboProj1 eq "All"
	and form.radStatus eq "All">
	<cfset variables.error = "true">
	<cfset variables.lstErrorMessage = listAppend(variables.lstErrorMessage, "You must enter at least one criteria.")>
</cfif>

<cfif not variables.error>

	<cfset variables.whereClause = "1 = 1">

	<!--- AAPP Number --->
	<cfif form.txtAAPPNum neq "">
		<cfset variables.whereClause = variables.whereClause & " and (AAPP = '#form.txtAAPPNum#')">
	</cfif>
	<!--- funding office --->
	<cfif form.cboFundingOffice neq "all">
			<cfset variables.whereClause = variables.whereClause & " and (FUNDINGOFFICENUM in (#form.cboFundingOffice#))">
	</cfif>
	<!--- FY --->
	<cfif form.cboFY neq "All">
		<cfset variables.whereClause = variables.whereClause & " and (FY = '#form.cboFY#')">
	</cfif>
	<!--- Doc Num --->
	<cfif form.txtDocNum neq "">
		<cfset variables.whereClause = variables.whereClause & "and (DOCNUM = '#form.txtDocNum#')">
	</cfif>
	<!--- OPS/CRA --->
	<cfif form.radOPSCRA neq "All">
		<cfif form.radOPSCRA is "OPS">
			<cfset variables.whereClause = variables.whereClause & " and (OPSCRA = 'OPS')">
		<cfelseif form.radOPSCRA is "CRA">
			<cfset variables.whereClause = variables.whereClause & " and (OPSCRA = 'CRA')">
		</cfif>
	</cfif>
	<!--- IAC --->
	<cfif form.txtIAC neq "">
		<!---<cfset variables.whereClause = variables.whereClause & "and (IAC in ('#replace(form.txtIAC,",","','","all")#'))">--->
		<cfset variables.whereClause = variables.whereClause & "and (IAC in (#listQualify(form.txtIAC,"'",",","all")#))">
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
	<!--- Proj 1 --->
	<cfif form.cboProj1 neq "All">
		<cfset variables.whereClause = variables.whereClause & " and (Proj1Code = '#form.cboProj1#')">
	</cfif>
	<!--- Status --->
	<cfif form.radStatus neq "All">
		<cfset currentPY = application.outility.getCurrentSystemProgramYear ()>
		<cfif form.radStatus is 1>
			<cfset variables.whereClause = variables.whereClause & " and (LastObligPY >= '#currentPY#')">
		<cfelseif form.radStatus is 0>
			<cfset variables.whereClause = variables.whereClause & " and (LastObligPY < '#currentPY#')">
		</cfif>
	</cfif>

</cfif>
