<cfsilent>
<!---
page: rpt_allot_allocat_recon_nat.cfm

description: display report for Allotment / Obligation / Allocation Recon (National)

revisions:
2014-03-10	mstein	page created
2014-04-24	mstein	updates to column headings
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
			<h2>#rstAllotAlloc_ReconNat.fundCatDesc#, National and Regional Levels, PY#rstAllotAlloc_ReconNat.py#</h2>

			<br>

			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr>
				<td>
				Sub-Allotment Data Source: #rstAllotAlloc_ReconNat.allotSource# (as of #dateFormat(rstAllotAlloc_ReconNat.allotDate, "mm/dd/yyyy")#);
				Obligation Data Source: NCFMS (as of #dateFormat(rstAllotAlloc_ReconNat.obligDate, "mm/dd/yyyy")#)<td>
				</td>
				<td align=right>
					Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#
				</td>
				</td>
			</tr>
			</table>

			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
			<tr>
				<th scope="col" title="Funding Office No."></th>
				<th valign=bottom align="center" scope="col" title="Funding Office">Funding Office</th>
				<th valign=bottom align="center" scope="col" title="Centers">Centers</th>
				<th valign=bottom align="center" scope="col" title="O/A,CTS">O/A, CTS</th>
				<th valign=bottom align="center" scope="col" title="Other">Other</th>
                   	<cfif #rstAllotAlloc_ReconNat.allotSource# NEQ "">
                    	<cfset variables.allotSource = "(#rstAllotAlloc_ReconNat.allotSource#)">
                    <cfelse>
                    	<cfset variables.allotSource = "">
                    </cfif>
				<th valign=bottom align="center" scope="col" title="PY Sub-allotment">PY Suballotment #variables.allotSource#</th>
				<th valign=bottom align="center" scope="col" title="PY Qtrly Allocation">PY Cum. <cfif rstAllotAlloc_ReconNat.fundCat eq "OPS">Q#rstAllotAlloc_ReconNat.qrtr#</cfif> Allocation (JFAS)</th>
				<th valign=bottom align="center" scope="col" title="Difference" nowrap>Difference<br>(Suballot -<br>Allocation)</th>
				<th valign=bottom align="center" scope="col" title="Obligation">Obligation (NCFMS)</th>
				<th valign=bottom align="center" scope="col" title="FOP">FOP (JFAS)</th>
				<th valign=bottom align="center" scope="col" title="FOP %">FOP % (vs Obligation)</th>
				<th valign=bottom align="center" scope="col" title="FOP Diff" nowrap>Difference<br>(FOP -<br>Allocation)</th>
			</tr>
			
				<cfset aappCount_ctrops_total = 0>
				<cfset aappCount_oacts_total = 0>
				<cfset aappCount_other_total = 0>
				<cfset subAllotment_total = 0>
				<cfset allocation_total = 0>
				<cfset diffAllotAllocat_total = 0>
				<cfset oblig_total = 0>
				<cfset fopAmount_total = 0>
				<cfset diffFOPAllocat_total = 0>
						
				<cfloop query="rstAllotAlloc_ReconNat">					

					<tr <cfif currentrow mod 2 eq 1>class="form2AltRow"</cfif>>
						<td scope="row" nowrap>#fundingOfficeNum#</td>
						<td nowrap>#fundingOfficeDesc#</td>
						<td align="right" nowrap>#aappCount_ctrops#</td>
						<td align="right" nowrap>#aappCount_oacts#</td>
						<td align="right" nowrap>#aappCount_other#</td>
						<td align="right" nowrap>#numberFormat(subAllotment, "$9,999")#</td>
						<td align="right" nowrap>#numberFormat(allocation, "$9,999")#</td>
						<td align="right" nowrap>#numberFormat(diffAllotAllocat, "$9,999")#</td>
						<td align="right" nowrap>#numberFormat(oblig, "$9,999")#</td>
						<td align="right" nowrap>#numberFormat(fopAmount, "$9,999")#</td>
						<td align="right" nowrap>#numberFormat(fopPercent, "999.9")#%</td>
						<td align="right" nowrap>#numberFormat(diffFOPAllocat, "$9,999")#</td>
						
						<!--- keep running totals --->
						<cfset aappCount_ctrops_total = aappCount_ctrops_total + aappCount_ctrops>
						<cfset aappCount_oacts_total =aappCount_oacts_total + aappCount_oacts>
						<cfset aappCount_other_total = aappCount_other_total + aappCount_other>
						<cfset subAllotment_total = subAllotment_total + subAllotment>
						<cfset allocation_total = allocation_total + allocation>
						<cfset diffAllotAllocat_total = diffAllotAllocat_total + diffAllotAllocat>
						<cfset oblig_total = oblig_total + oblig>
						<cfset fopAmount_total = fopAmount_total + fopAmount>
						<cfset diffFOPAllocat_total = diffFOPAllocat_total + diffFOPAllocat>
				</cfloop>

			<cfif fopAmount_total neq 0>
				<cfset fopPercent_total = (oblig_total/fopAmount_total)*100>
			<cfelse>
				<cfset fopPercent_total = 0>
			</cfif>	
	

			<tr><td colspan=12><HR NOSHADE size=1></td></tr>
			<tr>
				<td></td>
				<td align="right" scope="row" nowrap><strong>Total</strong></td>
				<td align="right" nowrap><strong>#aappCount_ctrops_total#</strong></td>
				<td align="right" nowrap><strong>#aappCount_oacts_total#</strong></td>
				<td align="right" nowrap><strong>#aappCount_other_total#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(subAllotment_total, "$9,999")#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(allocation_total, "$9,999")#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(diffAllotAllocat_total, "$9,999")#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(oblig_total, "$9,999")#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(fopAmount_total, "$9,999")#</strong></td>
				<td align="right" nowrap><strong>#numberFormat(fopPercent_total, "999.9")#%</strong></td>
				<td align="right" nowrap><strong>#numberFormat(diffFOPAllocat_total, "$9,999")#</strong></td>
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
