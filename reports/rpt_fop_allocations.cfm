<cfsilent>
<!---
page: rpt_budget_fop_allocations.cfm

description: display report for FOP listing

revisions:
12/20/2006 - rroser - Defect # 20 -
		removed "click to close window" link
07/18/2007 - abai - change "cat." to "category"	on the report header.
08/07/2007 - abai - change "program activity" by using short name
abai 11/26/2007: 	Revised for CHG4400 (using numberFormat instead of dollarFormat)
2009-03-23	mstein	Added info to subtitle - if display for ARRA is yes or no
2015-03-16	mstein	Bug: removed css path from report title
--->
</cfsilent>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<title>#request.htmlTitleDetail#</title>
<link href="#request.paths.reportcss#" rel="stylesheet" type="text/css" />
</cfoutput>
</head>

<body class="form">
<table border="0" cellspacing="0" cellpadding="0" align="center" width="762">
<tr>
<td>
	<!-- Begin Content Area -->
		<!-- Begin Form Header Info -->
		<div class="formContent">
			<cfoutput>
			<h1>FOP Listing Report</h1>
			<h2>
				#rstFundingOffices.fundingOfficeDesc#<cfif form.cboPY neq "all">, Program Year #form.cboPY#</cfif><cfif form.txtStartDate neq '' and form.txtEndDate neq ''>, From #dateformat(form.txtStartDate, "mm/dd/yyyy")# to #dateformat(form.txtEndDate, "mm/dd/yyyy")#</cfif><cfif form.radARRA neq "all">, <cfif form.radARRA eq 0>non-</cfif>ARRA records only</cfif>
			</h2>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr>
				<td>
					Report run on: #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#
				</td>
				<td align=right>
					For <cfif form.radStatus is "all">All&nbsp;
					<cfelseif form.radStatus eq 1>Active&nbsp;
					<cfelseif form.radStatus eq 0>Inactive&nbsp;
					</cfif>Records
				</td>
			</tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
			<th scope="col" title="PY">PY</th>
			<th scope="col" title="FOP No.">FOP No.</th>
            <th scope="col" title="AAPP No.">AAPP No.</th>
			<th scope="col" title="Program Activity">Program<br />Activity</th>
			<th scope="col" title="Performance Venue/Center">Performance Venue/Center</th>
			<th scope="col" title="Contractor">Contractor</th>
			<th scope="col" title="Contract No.">Contract No.</th>
			<th scope="col" title="Cost Category">Cost Cat.</th>
			<th scope="col" title="ARRA">ARRA</th>
			<th scope="col" title="Date Issued">Date Issued</th>
			<th scope="col" title="Amount" style="text-align:center">Amount</th>
			<th scope="col" title="Purpose">Purpose</th>
			<cfif rstFopList.recordcount is 0><!--- if there were no results, link to close new window --->
			<tr>
				<td colspan="12" style="text-align:center">
				<br />
				<Br />
				<br />
					There are no matching records.
				</td>
			</tr>
			<cfelse><!--- if there are records to show --->
				<cfset amountTotal = 0><!--- initialize variable --->
				<cfloop query="rstFopList"><!--- loop through query --->
				<tr<cfif currentrow mod 2> class="formAltRow"</cfif>><!--- alternate row colors --->
					<td scope="row" valign="top">
						#programyear#
					</td>
					<td valign="top">
						#fopnum#
					</td>
					<td valign="top">
						#aappnum#
					</td>
					<td valign="top">
						#PROGRAM_ACTIVITY_SHORT#
					</td>
					<td valign="top">
						<cfif venue neq ''>#venue#<br /></cfif><!--- only show venue if it exists --->
						#centername#
					</td>
					<td valign="top">
						#contractorname#
					</td>
					<td valign="top">
						#contractnum#
					</td>
					<td valign="top">
						#costcatcode#
					</td>
					<td valign="top" align="center">
						#arra#
					</td>
					<td valign="top">
						#DateFormat(dateexecuted, "mm/dd/yyyy")#
					</td>
					<td style="text-align:right" valign="top">
						#numberFormat(amount, "$,.99")#<cfset amountTotal = amountTotal + amount><!--- add amount to total to display at bottom --->
					</td>
					<td valign="top">
						#fopdescription#
					</td>
				</tr>
				</cfloop>
				<tr>
					<td colspan="7">&nbsp;</td>
					<td colspan="2" style="font-weight:bold">Total Amount</td>
					<td colspan="2" style="text-align:right; font-weight:bold"><cfoutput>#numberformat(amountTotal, "$,.99")#</cfoutput></td><!--- display total amount --->
					<td></td>
				</tr>
			</cfif>
		  	</table>
	 </cfoutput>
		</div>
		<!-- End Content Area -->
			<!-- Begin Form Footer Info -->
  <cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf"><!--- if it's a pdf, show the page and total pages in footer --->
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
			<!-- End Form Footer Info -->

	</td>
</tr>
</table>
</body>
</html>
