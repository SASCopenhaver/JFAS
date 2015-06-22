<cfsilent>
<!---
page: rpt_ncfms_allocat_fop_recon_aapp.cfm.cfm

description: display report for FOP / Obligation / Allocation Recon (AAPP View)

revisions:
2014-03-23	mstein	page created
--->
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
<!--- <table border="0" cellspacing="0" cellpadding="0" align="center" width="768">
<tr>
<td> --->
	<!-- Begin Content Area -->
		<!-- Begin Form Header Info -->
		<div class="formContent">
			<cfoutput>
			<h1>JFAS Obligation / Allocation / FOP Reconciliation Report</h1>
			<h2>#rstNCFMSAllocation_Recon_AAPP.fundCatDesc#, #rstNCFMSAllocation_Recon_AAPP.fundingOfficeDesc#, PY#rstNCFMSAllocation_Recon_AAPP.py#</h2>

			<br>

			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr>
				<td>
				Obligation Data Source: NCFMS (as of #dateFormat(rstNCFMSAllocation_Recon_AAPP.obligDate, "mm/dd/yyyy")#)<td>
				</td>
				<td align=right>
					Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
				</td>
				</td>
			</tr>
			</table>

			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
			<tr>
				<cfif form.radReportFormat eq "application/vnd.ms-excel">
					<th valign=bottom align="center" scope="col" title="Venue">Venue</th>
					<th valign=bottom align="center" scope="col" title="Center">Center</th>
				<cfelse>	
					<th valign=bottom align="center" scope="col" title="Center/Venue">Performance Venue/Center</th>
				</cfif>
				<th valign=bottom align="center" scope="col" title="Activity">Activity</th>
				<th valign=bottom align="center" scope="col" title="AAPP">AAPP</th>
				<cfif form.radReportFormat eq "application/vnd.ms-excel">
					<th valign=bottom align="center" scope="col" title="Start Date">Start Date</th>
					<th valign=bottom align="center" scope="col" title="End Date">End Date</th>
				<cfelse>
					<th valign=bottom align="center" scope="col" title="Performance Period">Performance Period</th>
				</cfif>
				<th valign=bottom align="center" scope="col" title="PY Qtrly Allocation">PY Cum. <cfif rstNCFMSAllocation_Recon_AAPP.fundCat eq "OPS">Q#rstNCFMSAllocation_Recon_AAPP.qrtr#</cfif> Allocation (JFAS)</th>
				<th valign=bottom align="center" scope="col" title="FOP">FOP (JFAS)</th>
				<th valign=bottom align="center" scope="col" title="Diff FOP/Allocation">Difference (FOP - Allocation)</th>
				<th valign=bottom align="center" scope="col" title="Obligation">Obligation (NCFMS)</th>
				<th valign=bottom align="center" scope="col" title="FOP %">FOP % (vs Oblig)</th>
				<th valign=bottom align="center" scope="col" title="Diff FOP/Oblig">Difference (FOP - Obligation)</th>
			</tr>
			
				<cfset allocation_total = 0>
				<cfset fopAmount_total = 0>
				<cfset diffFOPAllocat_total = 0>
				<cfset oblig_total = 0>				
				<cfset diffFOPOblig_total = 0>
						
				<cfloop query="rstNCFMSAllocation_Recon_AAPP">					

					<tr <cfif currentrow mod 2 eq 1>class="form2AltRow"</cfif>>
						<cfif form.radReportFormat eq "application/vnd.ms-excel">
							<td nowrap>#venue#</td>
							<td nowrap>#centerName#</td>
						<cfelse>
							<td scope="row" nowrap>#venue#<cfif (trim(venue) neq "") AND (trim(centerName) neq "")>/</cfif>#centerName#</td>
						</cfif>
						<td nowrap>#programActivity#</td>
						<td nowrap>#aappNum#</td>
						<cfif form.radReportFormat eq "application/vnd.ms-excel">
							<td valign=top nowrap>#DateFormat(dateStart, 'mm/dd/yyyy')#</td>
							<td valign=top nowrap>#DateFormat(dateEnd, 'mm/dd/yyyy')#</td>
						<cfelse>
							<td valign=top nowrap>#DateFormat(dateStart, 'mm/dd/yyyy')#<cfif dateEnd neq "">-<br></cfif>#DateFormat(dateEnd, 'mm/dd/yyyy')#</td>
						</cfif>
						
						<td align="right" nowrap>#numberFormat(allocation, "$9,999")#</td>
						<td align="right" nowrap>#numberFormat(fopAmount, "$9,999")#</td>
						<td align="right" nowrap>#numberFormat(diffFOPAllocat, "$9,999")#</td>
						<td align="right" nowrap>#numberFormat(oblig, "$9,999")#</td>
						<td align="right" nowrap>#numberFormat(fopPercent, "999.9")#%</td>
						<td align="right" nowrap>#numberFormat(diffFOPOblig, "$9,999")#</td>
						
						<!--- keep running totals --->
						<cfset allocation_total = allocation_total + allocation>
						<cfset fopAmount_total = fopAmount_total + fopAmount>						
						<cfset diffFOPAllocat_total = diffFOPAllocat_total + diffFOPAllocat>
						<cfset oblig_total = oblig_total + oblig>						
						<cfset diffFOPOblig_total = diffFOPOblig_total + diffFOPOblig>
				</cfloop>

			<cfif fopAmount_total neq 0>
				<cfset fopPercent_total = (oblig_total/fopAmount_total)*100>
			<cfelse>
				<cfset fopPercent_total = 0>
			</cfif>	
	

			<tr><td <cfif form.radReportFormat eq "application/vnd.ms-excel">colspan=12<cfelse>colspan=10</cfif>><HR NOSHADE size=1></td></tr>
			<tr>
				<td align="left" scope="row" <cfif form.radReportFormat eq "application/vnd.ms-excel">colspan=6<cfelse>colspan=4</cfif>>
					<strong>Total, #rstNCFMSAllocation_Recon_AAPP.fundingOfficeDesc#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(allocation_total, "$9,999")#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(fopAmount_total, "$9,999")#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(diffFOPAllocat_total, "$9,999")#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(oblig_total, "$9,999")#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(fopPercent_total, "999.9")#%</strong></td>
				<td align="right" nowrap><strong>#numberFormat(diffFOPOblig_total, "$9,999")#</strong></td>
			</tr>			
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

</body>
</html>
