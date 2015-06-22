<cfsilent>
<!---
page: rpt_ncfms_fop_recon.cfm

description: display report for NCFMS / FOP Reconciliation Report

revisions:
2013-09-02	mstein	page created
--->
</cfsilent>

<cfset OPS_obligTotal = 0>
<cfset CRA_obligTotal = 0>
<cfset OPS_FOPTotal = 0>
<cfset CRA_FOPTotal = 0>

<!---<cfdump var="#rstNCFMSFOP_Reconciliation#">--->

<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#form.cboFundingOffice#" returnvariable="rsFundingOffice">

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
<!--- <table border="0" cellspacing="0" cellpadding="0" align="center" width="768">
<tr>
<td> --->
	<!-- Begin Content Area -->
		<!-- Begin Form Header Info -->
		<div class="formContent">
			<cfoutput>
			<h1>NCFMS Obligation / FOP Reconciliation Report </h1>
			<h2>#rsFundingOffice.fundingOfficeDesc#, PY#form.cboPY# </h2>

			<br>

			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr><td>
				Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
				</td>
				<td align=right>
					For <cfif form.radStatus eq "0">
							Inactive
						<cfelseif form.radStatus eq "1">
							Active
						<cfelse>
							All
						</cfif> Records
				</td>
			</tr>
			</table>

			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
				<tr>
					<th valign=top scope="col" title="AAPP No.">AAPP No.</th>
					<th valign=top scope="col" title="Program Activity">Program Activity</th>
					<cfif form.radReportFormat eq "application/vnd.ms-excel">
						<th valign=top scope="col" title="Performance Venue">Performance Venue</th>
						<th valign=top scope="col" title="Center">Center</th>
						<th valign=top scope="col" title="Contractor">Contractor</th>
						<th valign=top scope="col" title="Contract No.">Contract No.</th>
						<th valign=top scope="col" title="Start Date">Start Date</th>
						<th valign=top scope="col" title="End Date">End Date</th>
					<cfelse>
						<th valign=top scope="col" title="Performance Venue/Center">Performance Venue/<br>Center</th>
						<th valign=top scope="col" title="Contractor and Contract No.">Contractor/<br>Contract No.</th>
						<th valign=top scope="col" title="Performance Period">Performance Period</th>
					</cfif>
					<th valign=top scope="col" title=""></th>
					<th valign=top scope="col" title="PY obligations">PY#form.cboPY# NCFMS<br>Obligations</th>
					<th valign=top scope="col" title="FOP Total">#form.cboPY# FOP Total</th>
					<th valign=top scope="col" title="Difference">Difference</th>
					<th valign=top scope="col" title="Percentage">%</th>
				</tr>
				<cfif rstNCFMSFOP_Reconciliation.recordcount gt 0>

					<cfloop query="rstNCFMSFOP_Reconciliation">
						<cfset difference = fopTotal-obligTotal>
						<cfif fopTotal neq 0>
							<cfset percent = (obligTotal/fopTotal) * 100>
						<cfelse>
							<cfset percent = 0>
						</cfif>

						<tr <cfif currentrow mod 4 eq 1 or currentrow mod 4 eq 2>class="form2AltRow"</cfif>>
							<cfif fundSort eq 1>
								<td valign=top scope="row" rowspan="2" align="left">#aappNum#</td>
								<td valign=top rowspan="2">#programActivity#</td>
								<cfif form.radReportFormat eq "application/vnd.ms-excel">
									<td valign=top rowspan="2" nowrap>#venue#</td>
									<td valign=top rowspan="2" nowrap>#centerName#</td>
									<td valign=top rowspan="2" nowrap>#contractorName#</td>
									<td valign=top rowspan="2" nowrap>#contractNum#</td>
									<td valign=top rowspan="2" nowrap>#DateFormat(dateStart, 'mm/dd/yyyy')#</td>
									<td valign=top rowspan="2" nowrap>#DateFormat(dateEnd, 'mm/dd/yyyy')#</td>
								<cfelse>
									<td valign=top rowspan="2" nowrap>#venue#<cfif venue neq ""><br></cfif>#centerName#</td>
									<td valign=top rowspan="2" nowrap>#contractorName#<br>#contractNum#</td>
									<td valign=top rowspan="2" nowrap>#DateFormat(dateStart, 'mm/dd/yyyy')#<br>#DateFormat(dateEnd, 'mm/dd/yyyy')#</td>
								</cfif>
							</cfif>
							<td valign=top nowrap>#fund_cat#</td>
							<td align=right valign=top nowrap>#numberFormat(obligTotal, "$9,999")#</td>
							<td align=right valign=top nowrap>#numberFormat(fopTotal, "$9,999")#</td>
							<td align=right valign=top nowrap>#numberFormat(difference, "$9,999")#</td>
							<td align=right valign=top nowrap>#numberFormat(percent, "999.9")#%</td>
						</tr>
						<cfif fund_cat eq "OPS">
							<cfset OPS_obligTotal = OPS_obligTotal + obligTotal>
							<cfset OPS_FOPTotal = OPS_FOPTotal + fopTotal>
						<cfelseif fund_cat eq "CRA">
							<cfset CRA_obligTotal = CRA_obligTotal + obligTotal>
							<cfset CRA_FOPTotal = CRA_FOPTotal + fopTotal>
						</cfif>
					</cfloop>

				<cfset OPS_difference = OPS_FOPTotal - OPS_obligTotal>
				<cfif OPS_FOPTotal neq 0>
					<cfset OPS_percentage = (OPS_obligTotal/OPS_FOPTotal)*100>
				<cfelse>
					<cfset OPS_percentage = 0>
				</cfif>
				<cfset CRA_difference = CRA_FOPTotal - CRA_obligTotal>
				<cfif CRA_FOPTotal neq 0>
					<cfset CRA_percentage = (CRA_obligTotal/CRA_FOPTotal)*100>
				<cfelse>
					<cfset CRA_percentage = 0>
				</cfif>

				<tr><td <cfif form.radReportFormat eq "application/vnd.ms-excel">colspan=13<cfelse>colspan=10</cfif>><HR NOSHADE size=1></td></tr>
				<tr>
					<td <cfif form.radReportFormat eq "application/vnd.ms-excel">colspan=8<cfelse>colspan=5</cfif> align=center rowspan="2" valign=top>
						<b>Total, #rsFundingOffice.fundingOfficeDesc#, PY#form.cboPY#</b>
					</td>
					<td valign=top><b>OPS</b></td>
					<td align=right valign=top><strong>#numberFormat(OPS_obligTotal, "$9,999")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(OPS_FOPTotal, "$9,999")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(OPS_difference, "$9,999")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(OPS_percentage, "999.9")#</strong></td>
				</tr>
				<tr>
					<td valign=top><b>CRA</b></td>
					<td align=right valign=top><strong>#numberFormat(CRA_obligTotal, "$9,999")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(CRA_FOPTotal, "$9,999")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(CRA_difference, "$9,999")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(CRA_percentage, "999.9")#</strong></td>
				</tr>

			<cfelse>
				<tr><td <cfif form.radReportFormat eq "application/vnd.ms-excel">colspan=13<cfelse>colspan=10</cfif> align=center><br><br>There are no matching records</td></tr>
			</cfif>
			</table>


			</cfoutput>
		</div>
	    <!-- Begin Form Footer Info -->

	    <cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
			<cfdocumentitem type="footer">
				<cfoutput>
				<table width=100% cellspacing="0" border=0 cellpadding="0">
				<tr>
					<td align=right>
						<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
							page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
						</font>
					</td>
				</tr>
				</table>
				</cfoutput>
			</cfdocumentitem>
		</cfif>


		<!-- End Content Area -->
<!--- </td>
</tr>
</table> --->
</body>
</html>
