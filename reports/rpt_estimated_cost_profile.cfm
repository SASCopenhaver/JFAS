<cfsilent>
<!---
page: rpt_estimated_cost_profile.cfm

description: display report for Estimate Cost Profile by Cost Categories

revisions:
2007-01-10	yjeng	Change /1 to 1/, also check if cost category in table
2007-01-12	yjeng	Add nowrap to region
2007-01-17	yjeng	Do not display the row  if amount is 0 and mod not require
2007-01-25	yjeng	Fix page break in PDF
2007-02-20	yjeng	Add Performance Venue / Center
2007-07-24  abai    Reformat report header info and add title attribute into <td> tag
2007-08-07  abai    Make header font bold
2007-08-14	mstein	Changed business rules so that "Per Current Mod" amount and max mod number
					are not restricted to current contract year or earlier
2008-06-25	mstein	Added CFDOCUMENTSECTION, and broke out content to cfinclude to deal with page breaks and conent being cut off (CF bug)
--->
</cfsilent>


<!---Display Section--->
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
<!--- loop through cost categories --->
<cfloop index="idx" list="#form.chkCostCat#">
	<cfquery name="qryContractTypeCode" dbtype="query">
		select	distinct contract_type_code
		from	rstEstCostProfileSort
		order by contract_type_code desc
	</cfquery>
	<cfquery name="qryEstCostProfileSort" dbtype="query">
		select	*
		from	rstEstCostProfileSort
		where	contract_type_code='#idx#'
	</cfquery>
	<cfquery name="qryTotal" dbtype="query">
		select	contract_year, date_start, date_end, omb_rate, base_year, sum(amount) as funds
		from	qryEstCostProfileSort
		group by contract_year, date_start, date_end, omb_rate, base_year
		order by contract_year
	</cfquery>
	<cfquery name="qryWorkloadData" datasource="#request.dsn#">
		select	a.contract_year, a.value, b.workload_type_code, b.workload_type_desc, b.sort_order
		from	aapp_workload a, lu_workload_type b
		where	a.aapp_num=#form.aapp#
		and		b.contract_type_code='#idx#'
		and		a.workload_type_code=b.workload_type_code
		order by a.contract_year, b.sort_order
	</cfquery>
	<cfquery name="qryWorkloadTitle" dbtype="query">
		select	distinct workload_type_code, workload_type_desc
		from	qryWorkloadData
		order by sort_order
	</cfquery>

	<cfif qryEstCostProfileSort.recordcount>

			<cfinclude template="rpt_estimated_cost_profile_content.cfm">

	<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf" and idx neq listlast(form.chkCostCat) and idx neq qryContractTypeCode.contract_type_code>
			<!--- insert page breaks between sections (cost categories) --->
		<cfdocumentitem  type="pagebreak" />
	</cfif>

	</cfif>
</cfloop>
</body>
</html>

