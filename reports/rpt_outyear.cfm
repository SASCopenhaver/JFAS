<cfsilent>
<!---
page: rpt_outyear.cfm

description: display report for outyear funding, based on cost category

Revision:
2008-06-25	mstein	Added CFDOCUMENTSECTION, and broke out content to cfinclude to deal with page breaks and conent being cut off (CF bug)

--->
<cfif form.cboFundingOffice neq 0><!--- If the report is not for all funding offices --->
	<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#form.cboFundingOffice#" returnvariable="rsFundingOffice">
	<!--- get the name of the funding office for the header --->
</cfif>
<cfset rsCurrentPY = application.outility.getCurrentSystemProgramYear ()>

<!--- get the current program office for the header --->

<!--- set the variables for totals/subtotals to zero --->
<cfset PY0total = 0>
<cfset PY1total = 0>
<cfset PY2total = 0>
<cfset PY3total = 0>
<cfset PY0sum = 0>
<cfset PY1sum = 0>
<cfset PY2sum = 0>
<cfset PY3sum = 0>
</cfsilent>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<title>#request.htmlTitleDetail#</title>
<link href="#request.paths.reportcss#" rel="stylesheet" type="text/css" />
</cfoutput>
</head>


<body class="form">
<!---<table border="0" cellspacing="0" cellpadding="0" align="center" width="742">
<tr>
<td>--->




			<cfloop list="#form.chkCostCat#" index="i"><!--- Loop through the list of cost categories submitted in form --->
				<cfinvoke component="#application.paths.components#lookup" method="getServiceTypes" contractTypeCode="#i#" returnvariable="rstContractTypeCode"><!--- get the description from the cost category code --->

				<!---
				yes, one more include file for this report.
				the use of the extra include, AND cfdocumentsection tags AND repeated inclusion
				of style sheet is a workaround due to a bug in CFDOCUMENT that causes page
				content to be cut off when using the <cfdocumentitem  type="pagebreak" />
				item for page breaks --->
				<cfif form.radReportFormat eq "application/pdf">
					<cfdocumentsection marginright="0.35" marginleft="0.35">
					<style>
					<cfinclude template="#application.paths.reportcss#">
					</style>
					<cfinclude template="rpt_outyear_content.cfm">
					</cfdocumentsection>
				<cfelse>
					<cfinclude template="rpt_outyear_content.cfm">
				</cfif>



				<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf" and i neq listlast(form.chkCostCat)>
					<cfdocumentitem type="pagebreak" />
				</cfif>
			</cfloop>






<!-- End Content Area -->
<!---</td>
</tr>
</table>--->

</body>
</html>


<!---<cfoutput>
<cfloop list="#form.chkCostCat#" index="i">
	<cfdump var=#evaluate("rstOutyear_#i#")#>
</cfloop>
</cfoutput>--->