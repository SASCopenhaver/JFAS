<cfsilent>
<!---
page: reports_main.cfm

description: root page of reports section

revisions:
2007-03-20	mstein	grouped reports into sections
2007-04-11  abai 	Revised for defect 169 (indent the Reports' features and prefix them with a hyphen)
2007-04-11  abai  	Revised for defect 172 -- make title consistent with menu page
2007-05-15  abai  	add new case 13, and 17
2007-07-11  abai  	add new case 20.
2007-07-23	mstein	Allow Regional Office users access to CCC specific reports
2007-08-29  abai	add transaction part.
2007-11-27	mstein	Allow Regional Office users access to AdHoc Report Builder
2011-11-21	mstein	Disabled Fiscal Plan
2011-12-06	mstein	Reenabled Fiscal Plan
2013-09-01	mstein	Disabled transaction reports (NCFMS integration)
2013-12-30	mstein	Fixed header display issue
2014-11-17	mstein	Hid link to Small Business Funding report
--->
<cfset request.pageID="1000">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "Reports">

</cfsilent>


<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">
<script>
function reportUnavailable(reportType,reportDesc)
{
	alertMessage = 'The ' + reportDesc + ' is temporarily unavailable.';
	alert(alertMessage);
}
</script>
<p></p>

<h2>Budget Authority Requirements</h2>
<div>
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=1">Budget Authority Requirements (by AAPP)</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=6">Budget Authority Requirements (by DOL Region)</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=13">Budget Status</a><br />
<br />
</div>

<h2>Reconciliation Reports</h2>
<div>
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=29">Allotment / Obligation / Allocation Reconciliation Report (National View)</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=30">JFAS Obligation / Allocation / FOP Reconciliation Report (Contract View)</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=27">NCFMS Obligation / FOP Reconciliation</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=28">PY Contract Allocation / FOP Reconciliation</a><br />
<br />
</div>

<h2>AAPPs</h2>
<div>
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=2">Estimated Cost Profile</a><br />
<!--- use this line to disable report
&nbsp;&nbsp;-&nbsp;<a href="javascript:reportUnavailable(3,'Fiscal Plan Report');">Fiscal Plan</a><br />
--->
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=3">Fiscal Plan</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=4">FOP Allocations (by AAPP)</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=5">FOP Listing</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=7">Footprint/Contractor</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=12">CTST Worksheet</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=17">OA/CTS Annualized Workload/Cost Under Current Contracts</a><br />
<!--- hide link to Small Business Report - error to be addressed in future 
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=22">Small Business Funding</a><br /> --->
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=24">Out Year Funding Requirements</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=25">Workload Change List</a><br />
<br />
<!--- disabled trans reports
&nbsp;&nbsp;-&nbsp;<a href="javascript:reportUnavailable(21,'Obligation Transaction Report');">Footprint Transactions: Obligations</a><br />
&nbsp;&nbsp;-&nbsp;<a href="javascript:reportUnavailable(21,'Payment Transaction Report');">Footprint Transactions: Payments</a><br />
&nbsp;&nbsp;-&nbsp;<a href="javascript:reportUnavailable(21,'Cost Transaction Report');">Footprint Transactions: Costs</a><br />
<br>--->
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=21&trans=O">Footprint Transactions: Obligations</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=21&trans=P">Footprint Transactions: Payments</a><br />
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=21&trans=C">Footprint Transactions: Costs</a><br />
<br>
<!--- this link temporarily removed until redone for NCFMS (may be replaced by nightly process)
<br>
&nbsp;&nbsp;-&nbsp;<a href="report_criteria_template.cfm?rpt_id=23">Footprint Transaction Discrepancies</a><br />
--->
<br />
</div>


<h2>CCCs</h2>
<div>
&nbsp;&nbsp;-&nbsp<a href="report_criteria_template.cfm?rpt_id=9">Program Operating Plan Detail</a><br />
&nbsp;&nbsp;-&nbsp<a href="report_criteria_template.cfm?rpt_id=10">FOP CCC Budget</a><br />
&nbsp;&nbsp;-&nbsp<a href="report_criteria_template.cfm?rpt_id=11">Program Year Initial CCC Budget (by Agency)</a><br />
&nbsp;&nbsp;-&nbsp<a href="report_criteria_template.cfm?rpt_id=20">Program Year Initial CCC Budget (by Center)</a><br />
&nbsp;&nbsp;-&nbsp<a href="report_criteria_template.cfm?rpt_id=8">CCC Budget Transfer Requirements</a><br />
<br />
</div>


<h2>Ad Hoc Reports</h2>
<div>
&nbsp;&nbsp;-&nbsp<a href="report_adhoc.cfm">Ad Hoc Report Builder</a><br />
<br />
</div>

<!--- rpt_id = 14 for Contract Close Out --->
<!--- rpt_id = 15 for Fop batch process DOL --->
<!--- rpt_id = 16 for Fop batch process CCC --->
<!--- rpt_id = 18 for Fop batch process CCC --->
<!--- rpt_id = 19 for Fop batch process CCC --->
<!--- rpt_id = 20 for Program Year Initial CCC Budget (by Center) --->
<!--- rpt_id = 21 for Fop Footprint Transaction --->
<!--- rpt_id = 22 for Fop small business report --->

<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">