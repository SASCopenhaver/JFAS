<cfsilent>
<!---
page: aapp_reports.cfm

description:
	(1) establishes a context for a list of reports available for the current aapp
	(2) displays the list


revisions:

2007-08-13	rroser	added div tag to allow border around page
2007-09-11	rroser	only allow Future new report link to appear for DC, GR
2007-11-21	rroser	pass numeric funding office information to footprint/contractor report
2007-11-28  abai	Revised for allowing open more report windows.
2010-12-21	mstein	Removed link to Footprint / Transaction Discrepancies report
2011-04-25	mstein	Changed name of VST Worksheet to CTST Worksheet
2011-07-01	mstein	Added links to generate reports in PDF, HTML, or XLS formats
2011-11-21	mstein	Disabled Fiscal Plan
2011-12-06	mstein	Reenabled Fiscal Plan
--->
<cfoutput>

<cfset request.pageID = "810" />

<cfset lstContractGrant = "DC,GR">
<cfset lstNotCCC = "DC,GR,BA,IA,LE,SP">

<!--- check to see which PY to use --->
<cfif request.agreementTypeCode is 'CC'>
	<!--- this is establishing a form variable, BEFORE the <FORM> statement ! --->
	<cfset form.cboPY = request.py_ccc>
<cfelseif request.agreementTypeCode is "DC" or request.AgreementTypeCode is "GR">
	<cfset form.cboPY = request.py>
<cfelse>
	<cfset form.cboPY = request.py_other>
</cfif>

<!--- get service types for Est. Cost Profile report --->
<cfinvoke component="#application.paths.components#aapp" method="getAAPPServiceTypes" aapp="#url.aapp#" returnvariable="lstServTypes">

<!--- perform queries to retrieve reference data to populate drop-down lists --->
</cfoutput>

</cfsilent>

<!--- include main header, including contract info block, and secondary navigation bar --->
<cfinclude template="#application.paths.includes#header.cfm" />


<script language="javascript">
function sbmtReport(rpt_id, rptFormat, trans)
{
	<cfoutput>
	if(rpt_id == 4) {
		document.frmReportCriteria.cboPY.value = 'all';
		}
	else {
		document.frmReportCriteria.cboPY.value = #form.cboPY#;
	}

	if(rpt_id == 10){
		//Only pass the funding office number for the CCC Fop report
		document.frmReportCriteria.cboFundingOffice.value = #request.fundingofficenum#;
	}
	else if(rpt_id == 9 || rpt_id == 7) {
		document.frmReportCriteria.cboFundingOffice.value = 0;
	}
	else {
		document.frmReportCriteria.cboFundingOffice.value = '';
	}

	if(rpt_id == 21) {
		document.frmReportCriteria.hidReportType.value = trans;
	}

	// set form action
	document.frmReportCriteria.action = ['#application.paths.root#reports/reports.cfm?rpt_id=' + rpt_id + '&aapp=' + #request.aapp#];
	// set format of report
	if (rptFormat == 'pdf') {
		document.frmReportCriteria.radReportFormat.value = 'application/pdf';
	}
	else if (rptFormat == 'xls') {
		document.frmReportCriteria.radReportFormat.value = 'application/vnd.ms-excel';
	}
	else {
		document.frmReportCriteria.radReportFormat.value = 'html';
	}
	</cfoutput>
	// submit report/graphics
	document.frmReportCriteria.submit();

}

function reportUnavailable(reportType,reportDesc)
{
	alertMessage = 'The ' + reportDesc + ' is temporarily unavailable.';
	alert(alertMessage);
}

</script>


<!--- start of HTML --->
<style>
.hlt td {
	background-color: yellow;
	color: black;
}
</style>

<div class="ctrSubContent">
<cfoutput>
<h2>Reports for AAPP #url.aapp#</h2>


<!--- this is the form submitted to generate a report. It contains the aapp and userID.  It posts to a new tab --->
<form name="frmReportCriteria" action="" method="post" target="_blank">

<input type="hidden" name="cboPY" value="#form.cboPY#"/>
<input type="hidden" name="aapp" value="#request.aapp#"/>
<input type="hidden" name="cboaapp" value="#request.aapp#-"/>
<input type="hidden" name="cboCenter" value="0"/>
<input type="hidden" name="cboFundingOffice" value=""/>
<input type="hidden" name="cboDolRegion" value="0"/>
<input type="hidden" name="radReportFormat" value="application/pdf" />
<!---<input type="hidden" name="radReportFormat" value="html" />--->
<input type="hidden" name="chkCostCat" value="#lstServTypes#" />
<input type="hidden" name="radReportType" value="AAPP" />
<input type="hidden" name="hidReportType" value="" />
<input type="hidden" name="userID" value="#session.userID#" />
<input type="hidden" name="sWindowName" value="#request.htmlTitleDetail#" />
</form>

<cfset rowCount = 1>
<table border="0" cellpadding="0" cellspacing="0" class="contentTbl" width="95%">
<tr>
	<!---<td width="12%"></td> --->
	<td width="15%"></td>
	<td scope="column" width="50%">Report Name</td>
	<td scope="column" width="45%" align="left">Report Format</td>
</tr>
<cfif (request.agreementtypecode is 'DC' or request.agreementtypecode is 'GR') and (request.budgetInputType is 'F')>
	<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
		<td></td>
		<td>Profile of Future New Contract</td>
		<td align="left">
			<a href="javascript:sbmtReport(19,'pdf');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(19,'htm');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(19,'xls');">MS Excel</a>
		</td>
	</tr>
	<cfset rowCount = rowcount + 1>
</cfif>
<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
	<td></td>
	<td>FOP Allocations</td>
	<td align="left">
		<a href="javascript:sbmtReport(4,'pdf');">PDF</a> &nbsp;|&nbsp;
		<a href="javascript:sbmtReport(4,'htm');">HTML</a> &nbsp;|&nbsp;
		<a href="javascript:sbmtReport(4,'xls');">MS Excel</a>
	</td>
</tr>
<cfset rowCount = rowcount + 1>
<cfif listContainsNoCase(lstContractGrant, request.agreementTypeCode)>
	<cfif request.budgetInputType neq 'F'>
		<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
			<td></td>
			<td>Estimated Cost Profile</td>
			<td align="left">
				<a href="javascript:sbmtReport(2,'pdf');">PDF</a> &nbsp;|&nbsp;
				<a href="javascript:sbmtReport(2,'htm');">HTML</a> &nbsp;|&nbsp;
				<a href="javascript:sbmtReport(2,'xls');">MS Excel</a>
			</td>
		</tr>
		<cfset rowCount = rowcount + 1>
	</cfif>
	<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
		<td></td>
		<td>Fiscal Plan</td>
		<td align="left">
			<a href="javascript:sbmtReport(3,'pdf');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(3,'htm');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(3,'xls');">MS Excel</a>
		</td>
	</tr>
	<cfset rowCount = rowcount + 1>
</cfif>
<cfif listContainsNoCase(lstNotCCC, request.agreementTypeCode) neq 0>
	<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
		<td></td>
		<td>Footprint/Contractor</td>
		<td align="left">
			<a href="javascript:sbmtReport(7,'pdf');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(7,'htm');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(7,'xls');">MS Excel</a>
		</td>
	</tr>
	<cfset rowCount = rowcount + 1>
</cfif>
<cfif request.agreementTypeCode eq 'CC'>
	<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
		<td></td>
		<td>Program Operating Plan Detail for PY #form.cboPY#</td>
		<td align="left">
			<a href="javascript:sbmtReport(9,'pdf');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(9,'htm');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(9,'xls');">MS Excel</a>
		</td>
	</tr>
	<cfset rowCount = rowcount + 1>
	<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
		<td></td>
		<td>FOP CCC Budget for PY #form.cboPY#</td>
		<td align="left">
			<a href="javascript:sbmtReport(10,'pdf');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(10,'htm');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(10,'xls');">MS Excel</a>
		</td>
	</tr>
	<cfset rowCount = rowcount + 1>
</cfif>
<cfif listContainsNoCase(lstContractGrant, request.agreementTypeCode)>
	<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
		<td></td>
		<td>CTST Worksheet for PY #form.cboPY#</td>
		<td align="left">
			<a href="javascript:sbmtReport(12,'pdf');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(12,'htm');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(12,'xls');">MS Excel</a>
		</td>
	</tr>
	<cfset rowCount = rowcount + 1>
</cfif>
<cfif request.agreementTypeCode neq 'CC'>
	<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
		<td></td>
		<td>Footprint Transaction: Obligations</td>
		<td align="left">
			<a href="javascript:reportUnavailable(21,'Obligation Transaction Report');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:reportUnavailable(21,'Obligation Transaction Report');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:reportUnavailable(21,'Obligation Transaction Report');">MS Excel</a>
			<!---
			<a href="javascript:sbmtReport(21,'pdf','O');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(21,'htm','O');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(21,'xls','O');">MS Excel</a>
			--->
		</td>
	</tr>
	<cfset rowCount = rowcount + 1>
	<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
		<td></td>
		<td>Footprint Transaction: Payments</td>
		<td align="left">
			<a href="javascript:reportUnavailable(21,'Payment Transaction Report');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:reportUnavailable(21,'Payment Transaction Report');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:reportUnavailable(21,'Payment Transaction Report');">MS Excel</a>
			<!---
			<a href="javascript:sbmtReport(21,'pdf','P');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(21,'htm','P');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(21,'xls','P');">MS Excel</a>
			--->
		</td>
	</tr>
	<cfset rowCount = rowcount + 1>
	<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
		<td></td>
		<td>Footprint Transaction: Costs</td>
		<td align="left">
			<a href="javascript:reportUnavailable(21,'Cost Transaction Report');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:reportUnavailable(21,'Cost Transaction Report');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:reportUnavailable(21,'Cost Transaction Report');">MS Excel</a>
			<!---
			<a href="javascript:sbmtReport(21,'pdf','C');">PDF</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(21,'htm','C');">HTML</a> &nbsp;|&nbsp;
			<a href="javascript:sbmtReport(21,'xls','C');">MS Excel</a>--->
		</td>
	</tr>
	<cfset rowCount = rowcount + 1>
	<cfif structkeyexists (request, 'agreementtypecode') and request.agreementtypecode EQ 'DC' AND request.budgetInputType neq "F">
		<tr <cfif rowCount mod 2>class="AltRow"</cfif>>
			<td></td>
			<td>AAPP Funding Comparison Chart</td>
			<td align="left">
				<a href="javascript:GoToAAPPGraph ('aapp_line1.cfm?aapp=#url.aapp#', 'JFGFComp#url.aapp#');">HTML</a>
			</td>
		</tr>
		<cfset rowCount = rowcount + 1>
	</cfif>
</cfif>
</table>


</cfoutput>
</div>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />