<cfsilent>
<!---
page: rpt_budget_authority_requirements.cfm

description: display report for Budget Authority Requirements

revisions:
abai: 12/20/2006 revised for defects 20.
abai 11/26/2007: 	Revised for CHG4400 (using numberFormat instead of dollarFormat)
--->
</cfsilent>

<cfset OPS_cumu_Total = 0>
<cfset CRA_cumu_Total = 0>
<cfset cumu_Total = 0>
<cfset OPS_expired_Total = 0>
<cfset CRA_expired_Total = 0>
<cfset expired_Total = 0>
<cfset OPS_active_Total = 0>
<cfset CRA_active_Total = 0>
<cfset active_Total = 0>

<cfset rsFundingOffice = application.olookup.getFundingOffices ( fundingOfficeNum="#form.cboFundingOffice#" 	)>
<cfset rsCurrentPY = application.outility.getCurrentSystemProgramYear (	)>

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
			<h1>Budget Authority Requirements for #rsFundingOffice.fundingOfficeDesc#</h1>
			<h2>Program Year #rsCurrentPY# </h2>

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
					<th valign=top scope="col" title="Performance Venue/Center">Performance<br>Venue/Center</th>
					<th valign=top scope="col" title="Contractor and Contract No.">Contractor/ Contract No.</th>
					<th valign=top scope="col" title="Performance Period">Performance Period</th>
					<th valign=top scope="col" title=""></th>
					<th valign=top scope="col" title="Cumulative Funding Per AAPP/FOP">Cumulative Funding Per AAPP/FOP</th>
					<th valign=top scope="col" title="Funding from Expired Account">Funding from<br> Expired<br> Account</th>
					<th valign=top scope="col" title="Approved from Active Account">$ Approved from Active Account</th>
					<th valign=top scope="col" title="Note">Note</th>
				</tr>
				<cfif rsBudgetAuth.recordcount gt 0>
				<cfloop query="rsBudgetAuth">
				<tr <cfif currentrow mod 2>class="form2AltRow"</cfif>>
					<td rowspan=3 valign=top scope="row">#AAPPNum#</td>
					<td rowspan=3 valign=top>#PROGRAMACTIVITY#</td>
					<td rowspan=3 valign=top>#trim(VENUE)#<cfif venue neq ""><br></cfif>#trim(center_name)#</td>
					<td rowspan=3 valign=top>#CONTRACTORNAME#<br>#CONTRACTNUMBER#</td>
					<td rowspan=3 valign=top>#DateFOrmat(DATESTART, 'mm/dd/yyyy')#<br>
						#DateFOrmat(DATEEND, 'mm/dd/yyyy')#
					</td>
					<td valign=top>Operations</td>
					<td align=right valign=top>#numberFormat(FUNDINGCUMMOPS, "$,.99")#</td>
					<td align=right valign=top>#numberFormat(FUNDINGExpiredOPS, "$,.99")#</td>
					<Td align=right valign=top>#numberFormat(FUNDINGACTIVEOPS, "$,.99")#</Td>
					<td valign=top>#NOTEOPS#</td>
				</tr>
				<tr <cfif currentrow mod 2>class="form2AltRow"</cfif>>
					<td valign=top>Cnst/Rehab</td>
					<td align=right valign=top>#numberFormat(FUNDINGCUMMCRA, "$,.99")#</td>
					<td align=right valign=top>#numberFormat(FUNDINGExpiredCRA, "$,.99")#</td>
					<td align=right valign=top>#numberFormat(FUNDINGACTIVECRA, "$,.99")#</td>
					<td valign=top>#NOTECRA#</td>
				</tr>
				<tr <cfif currentrow mod 2>class="form2AltRow"</cfif>>
					<td valign=top>Totals</td>
					<td align=right valign=top>#numberFormat(FUNDINGCUMMTotal, "$,.99")#</td>
					<td align=right valign=top>#numberFormat(FUNDINGExpiredTotal, "$,.99")#</td>
					<td align=right valign=top>#numberformat(FUNDINGACTIVETotal, "$,.99")#</td>
					<td>&nbsp;</td>
				</tr>
				<cfset OPS_cumu_Total = OPS_cumu_Total + FUNDINGCUMMOPS>
				<cfset CRA_cumu_Total = CRA_cumu_Total + FUNDINGCUMMCRA>
				<cfset cumu_Total = cumu_Total + FUNDINGCUMMTOTAL>
				<cfset OPS_expired_Total = OPS_expired_Total + FUNDINGExpiredOPS>
				<cfset CRA_expired_Total = CRA_expired_Total + FUNDINGExpiredCRA>
				<cfset expired_Total = expired_Total + FUNDINGExpiredTOTAL>
				<cfset OPS_active_Total = OPS_active_Total + FUNDINGACTIVEOPS>
				<cfset CRA_active_Total = CRA_active_Total + FUNDINGACTIVECRA>
				<cfset active_Total = active_Total + FUNDINGACTIVETOTAL>
				</cfloop>
				<!--- <tr><td colspan=10><HR NOSHADE size=1></td></tr> --->
				<tr>
					<td colspan=5 align=center rowspan="3" valign=top></td>
					<td valign=top><strong>Operations</strong></td>
					<td align=right valign=top><strong>#numberFormat(OPS_cumu_Total, "$,.99")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(OPS_expired_Total, "$,.99")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(OPS_active_Total, "$,.99")#</strong></td>

					<td rowspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td valign=top><strong>Cnst/Rehab</strong></td>
					<td align=right valign=top><strong>#numberFormat(CRA_cumu_Total, "$,.99")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(CRA_expired_Total, "$,.99")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(CRA_active_Total, "$,.99")#</strong></td>
				</tr>
				<tr>
					<td valign=top><strong>Totals</strong></td>
					<td align=right valign=top><strong>#numberFormat(cumu_Total, "$,.99")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(expired_Total, "$,.99")#</strong></td>
					<td align=right valign=top><strong>#numberFormat(active_Total, "$,.99")#</strong></td>
				</tr>
			<cfelse>
				<tr><td colspan=10 align=center><br><br>There are no matching records</td></tr>
			</cfif>
			</table>


			</cfoutput>
		</div>
	    <!-- Begin Form Footer Info -->

	    <cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
			<cfdocumentitem type="footer">
				<cfoutput>
				<table width=100% cellspacing="0" border=0 cellpadding="0">
				<tr><td>
						<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
						  1/ Where noted, OPS overfunded from expired accounts.<br />
						  2/ Where noted, CRA overfunded from expired accounts .<br />
						</font>
					</td>
					<td align=right>
						<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
							page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
						</font>
					</td>
				</tr>
				</table>
				</cfoutput>
			</cfdocumentitem>
		<cfelse>
			<div class="footnotes">
			  <font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
			  1/ Where noted, OPS overfunded from expired accounts.<br />
			  2/ Where noted, CRA overfunded from expired accounts .<br />
			  </font>
	        </div>
		</cfif>


		<!-- End Content Area -->
<!--- </td>
</tr>
</table> --->
</body>
</html>
