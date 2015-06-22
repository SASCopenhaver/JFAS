<cfsilent>
<!---
page: rpt_budget_status.cfm

description: display summary report for Budget Status based on funding office.

revisions:

2008-06-25	mstein	Added CFDOCUMENTSECTION, and broke out content to cfinclude to deal with page breaks and conent being cut off (CF bug)

--->
</cfsilent>

<cfif form.cboFundingOffice neq 0>
	<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#form.cboFundingOffice#" returnvariable="rsFundingOffice">
<cfelse>
	<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeTypeNot="FED" returnvariable="rsFundingOffice">
</cfif>
<cfset rsCurrentPY = application.outility.getCurrentSystemProgramYear (	)>

<cfset fundingcummcra_na_total = 0>
<cfset fundingcummops_na_total = 0>
<cfset fundingexpiredcra_na_total = 0>
<cfset fundingexpiredops_na_total = 0>
<cfset fundingactivecra_na_total = 0>
<cfset fundingactiveops_na_total = 0>
<cfset currentOblgCra_na_total = 0>
<cfset currentOblgops_na_total = 0>
<cfset remainingBalanceCra_na_total = 0>
<cfset remainingBalanceops_na_total = 0>
<cfset unspentExpiredCra_na_total = 0>
<cfset unspentExpiredops_na_total = 0>
<cfset unspentActiveCra_na_total = 0>
<cfset unspentActiveops_na_total = 0>
<cfset na_total = 0>
<cfset cnt= 0>

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
<cfoutput>
<cfloop query="rsFundingOffice">
	<cfset new_fundingoffice = fundingOfficeNum>
	<cfset cnt = cnt + 1>
	<cfinvoke component="#application.paths.components#reports" method="getRptBudgetStatus" fundingOfficeNum="#new_fundingoffice#" returnvariable="rsBudgetStatus" />

	<!--- initialize for each loop --->
	<cfset fundingcummcra_total = 0>
	<cfset fundingcummops_total = 0>
	<cfset fundingexpiredcra_total = 0>
	<cfset fundingexpiredops_total = 0>
	<cfset fundingactivecra_total = 0>
	<cfset fundingactiveops_total = 0>
	<cfset currentOblgCra_total = 0>
	<cfset currentOblgops_total = 0>
	<cfset remainingBalanceCra_total = 0>
	<cfset remainingBalanceops_total = 0>
	<cfset unspentExpiredCra_total = 0>
	<cfset unspentExpiredops_total = 0>
	<cfset unspentActiveCra_total = 0>
	<cfset unspentActiveops_total = 0>
	<cfset total = 0>

	<!-- Begin Content Area -->


		<!--- break page --->
		<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf" and currentRow gt 1 and new_fundingoffice neq old_fundingoffice>
			<cfdocumentitem type="pagebreak" />
		<cfelse>
			<br><br>
		</cfif>

		<!---
		yes, one more include file for this report.
		the use of the extra include, AND cfdocumentsection tags AND repeated inclusion
		of style sheet is a workaround due to a bug in CFDOCUMENT that causes page
		content to be cut off when using the <cfdocumentitem  type="pagebreak" />
		item for page breaks --->
		<cfif form.radReportFormat eq "application/pdf">
			<cfdocumentsection>
			<style>
			<cfinclude template="#application.paths.reportcss#">
			</style>
			<cfinclude template="rpt_budget_status_content.cfm">
			</cfdocumentsection>
		<cfelse>
			<cfinclude template="rpt_budget_status_content.cfm">
		</cfif>

		<cfset old_fundingoffice = new_fundingoffice>

</cfloop><!--- end of loop funding office --->

<!-- Begin Form Footer Info -->
<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
	<cfdocumentitem type="footer">
		<table width=100% cellspacing="0" border=0 cellpadding="0">
		<tr>
			<td align=right>
				<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
					page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
				</font>
			</td>
		</tr>
		</table>

	</cfdocumentitem>
</cfif>
<!-- End footer Area -->
</cfoutput>
</body>
</html>
