<cfsilent>
<!---
page: rpt_workload_change.cfm

description: display report for wokload change list

revisions:
2008-05-01	mstein	page created
2008-05-19	mstein	bold workload indicators that are selected on criteria page
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
			<h1>Workload Change List</h1>
			<cfoutput>
			<h2>
				<cfif form.cboFundingOffice neq "all">#rstFundingOffices.fundingOfficeDesc#</cfif>
				<cfif form.cboFundingOffice neq "all" and variables.lstWorkloadTypeDesc neq "">-</cfif>
				<cfif variables.lstWorkloadTypeDesc neq ""> AAPPs with changes in #variables.lstWorkloadTypeDesc#</cfif>
			</h2>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr>
				<td>
					Report run on: #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#
				</td>
				<td align=right>
					For Active AAPPs
				</td>
			</tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
            <th scope="col" title="AAPP No.">AAPP No.</th>
			<th scope="col" title="Program Activity" nowrap="nowrap">Program Activity</th>
			<th scope="col" title="Performance Venue/Center">Performance Venue/Center</th>
			<th scope="col" title="Period of Performance">Start Date</th>
			<th scope="col" title="Period of Performance">End Date</th>
			<th scope="col" title="Slots">Contract Year</th>
			<th scope="col" title="Slots">Slots</th>
			<th scope="col" title="Arrivals">Arrivals</th>
			<th scope="col" title="Grads">Grads</th>
			<th scope="col" title="Former Enrollees">Former Enrollees</th>
			<cfif rstWorkLoadChange.recordcount is 0><!--- if there were no results, link to close new window --->
			<tr>
				<td colspan="11" style="text-align:center">
				<br />
				<Br />
				<br />
					There are no matching records.
				</td>
			</tr>
			<cfelse><!--- if there are records to show --->
				<cfset tempAAPP = "">
				<cfset rowStyle = "">
				<cfloop query="rstWorkLoadChange"><!--- loop through query --->
					<cfif tempAAPP neq aappNum>
						<cfif rowStyle eq "">
							<cfset rowStyle = "formAltRow">
						<cfelse>
							<cfset rowStyle = "">
						</cfif>
					</cfif>
					<tr class="#rowStyle#"><!--- alternate row colors --->
						<cfif tempAAPP neq aappNum>
							<td valign="top">
								#aappNum#
							</td>
							<td valign="top" nowrap>
								#programActivity#
							</td>
							<td valign="top" nowrap>
								#venue#<cfif venue neq "" and centerName neq "">/</cfif>#centerName#
							</td>
							<td valign="top">
								#dateformat(dateStart, "mm/dd/yyyy")#
							</td>
							<td valign="top">
								#dateformat(dateEnd, "mm/dd/yyyy")#
							</td>
						<cfelse>
							<td colspan="5">&nbsp;</td>
						</cfif>
						<td valign="top">
							#contractYear#
						</td>
						<td valign="top" style="text-align:right;<cfif listfindnocase(form.ckbWorkload, "SL")>font-weight:bold;</cfif>">
							#numberFormat(slots)#
						</td>
						<td valign="top" style="text-align:right;<cfif listfindnocase(form.ckbWorkload, "AR")>font-weight:bold;</cfif>">
							#numberFormat(arrivals)#
						</td>
						<td valign="top" style="text-align:right;<cfif listfindnocase(form.ckbWorkload, "GR")>font-weight:bold;</cfif>">
							#numberFormat(grads)#
						</td>
						<td valign="top" style="text-align:right;<cfif listfindnocase(form.ckbWorkload, "FE")>font-weight:bold;</cfif>">
							#numberFormat(enrollees)#
						</td>
					</tr>
					<cfset tempAAPP = aappNum>
				</cfloop>
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
