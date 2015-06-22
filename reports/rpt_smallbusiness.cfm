<cfsilent>
<!---
page: rpt_smallbusiness.cfm

description: display summary report for Small Business Report info.
Revisions:

abai 10/17/2007  Revised for displaying FY on the title of "Obligation FY" only if the fiscal year is defined.
2007-11-26  abai    Revised for CHG4400 (using numberformat instead of dollarFOrmat)
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

<cfif session.roleid neq 3 and session.roleid neq 4>
	<cfset region="no">
<cfelse>
	<cfset region="yes">
</cfif>

<cfscript>
 argreementType="";
 smallBusinessType="";
 OrganizationTypes="";
 old_org = "";
 new_org = "";
 obli_total = 0;
 total = 0;
 cnt=0;
</cfscript>

<cfinvoke component="#application.paths.components#reports" method="getRptSmallbusiness" formdata="#form#" region="#region#" returnvariable="rsSmallBusiness" />
<cfinvoke component="#application.paths.components#lookup" method="getAgreementTypes"  returnvariable="rsAgreementTypes" />
<cfif isDefined("form.ckbAgreementType")>
	<cfloop query="rsAgreementTypes">
		<cfloop list="#form.ckbAgreementType#" delimiters="," index="i">
			<cfif rereplace(i, "'", "", "ALL") eq agreementTypeCode>
				<cfset argreementType = argreementType & ", " & agreementTypeDesc>
			</cfif>
		</cfloop>
	</cfloop>
</cfif>
<cfif isDefined("form.cboOrgType") neq "">
	<cfinvoke component="#application.paths.components#lookup" method="getOrganizationTypes" catView="combo" returnvariable="rsOrganizationTypes" />
	<cfloop query="rsOrganizationTypes">
		<cfloop list="#form.cboOrgType#" delimiters="," index="i">
			<cfif len(rereplace(i, "'", "", "ALL")) lte 3 and rereplace(i, "'", "", "ALL") eq orgTypeCode>
				<cfset OrganizationTypes = orgTypeDesc>
			<cfelseif rereplace(i, "'", "", "ALL") eq orgSubTypeCode>
				<cfset OrganizationTypes = orgSubTypeDesc>
			</cfif>
		</cfloop>
	</cfloop>
</cfif>
<cfif isDefined("form.ckbSmallBusType")>
	<cfinvoke component="#application.paths.components#lookup" method="getSmallBusTypes"  returnvariable="rsSmallBusTypes" />
	<cfloop query="rsSmallBusTypes">
		<cfloop list="#form.ckbSmallBusType#" delimiters="," index="i">
			<cfif rereplace(i, "'", "", "ALL") eq smbTypeCode>
				<cfset smallBusinessType = smallBusinessType & ", " & smbTypeDesc>
			</cfif>
		</cfloop>
	</cfloop>
</cfif>

<!-- Begin Content Area -->
<!-- Begin Form Header Info -->

	<body class="form">
	<div class="formContent">
	<cfoutput>

	  <!--- display title --->
		<h1>Small Business Funding Report</h1>  <br>

		<!--- display sub title data --->
		<table width="742" border="0" align="center" vliagn=top cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr>
				<td width="30%" align="right"><strong>Agreement Types:</strong></td>
				<td width="*">#REReplace(argreementType, ",", "", "ONE")#<!--- #rereplace(rereplace(form.ckbAgreementType, "'", "", "ALL"), ",", ", ", "ALL")# ---></td>
			</tr>
			<tr>
				<td align="right"><strong>Date Range:</strong></td>
				<td>#form.txtStartDate# through #form.txtEndDate#</td>
			</tr>
			<tr>
				<td align="right"><strong>Organization Category:</strong></td>
				<td>#OrganizationTypes#</td>
			</tr>
			<cfif isDefined("form.ckbSmallBusType")>
			<tr>
				<td align="right"><strong>Small Business Category:</strong></td>
				<td>#REReplace(smallBusinessType, ",", "", "ONE")#</td>
			</tr>
			</cfif>
			<tr><td colspan="2" valign="top" align="right"><br />Report run on: 08/27/2007 09:53:24AM</td></tr>
		</table>

		<!--- display data --->
		<cfif rsSmallBusiness.recordcount gt 0>
		  <table valig=top width="100%" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
			<tr>
				<th valign=bottom scope="col" style="text-align:left" title="Contractor / Contract No.">Contractor /<br> Contract No.</th>
				<th valign=bottom scope="col" style="text-align:center" title="AAPP">AAPP</th>
				<th valign=bottom scope="col" style="text-align:center" title="Program Activity">Program<br />Activity</th>
				<th valign=bottom scope="col" style="text-align:center" title="Center/Performance Venue" nowrap>Center/<br />Performance Venue</th>
				<th valign=bottom scope="col" style="text-align:center" title="Funding Office">Funding<br />Office</th>
				<th valign=bottom scope="col" style="text-align:center" title="Organization Category">Organization Category</th>
				<th valign=bottom scope="col" style="text-align:center" title="Small Bus. Sub Cats" nowrap>Small Bus.<br />Sub Cats</th>
				<th valign=bottom scope="col" style="text-align:center" title="Period of Performance">Period of<br />Performance</th>
				<th valign=bottom scope="col" style="text-align:center" title="Obligations,FY 2007" nowrap>Obligations <cfif isDefined("form.cbofy") and form.cbofy neq "">,<br />FY <cfoutput>#form.cbofy#</cfoutput></cfif></th>
			</tr>

			 <cfloop query="rsSmallBusiness">
				<cfset new_org = ORG_TYPE_DESC>

				<cfif new_org neq old_org or rsSmallBusiness.recordcount eq 1>
					<cfset cnt = 1 >
				<cfelse>
					<cfset cnt = cnt + 1>
				</cfif>

				<cfif rsSmallBusiness.recordcount gt 1 and (old_org neq "" and new_org neq old_org)>
					<tr>
							<td colspan=8 align="right" style="border-right:1px solid ##5e84a6;"><strong>Subtotal, #old_org#</strong></td>
							<td align=right><strong>#numberFormat(obli_total, "$,")#</strong></td>
					</tr>
					<cfset obli_total = 0>
				</cfif>

				<cfif amount neq "">
				<cfset obli_total = obli_total + amount>
				<cfset total = total + amount>
				</cfif>
				<tr <cfif currentRow mod 2>
							class="form2AltRow"
					</cfif> >
					<td valign=top>#CONTRACTOR_NAME#<br>#CONTRACT_NUM#</td>
					<td valign=top >#aapp_num#</td>
					<td valign=top>#programActivity#</td>
					<td valign=top>#CENTER_NAME#<cfif CENTER_NAME neq ""><br></cfif>#VENUE#</td>
					<td valign=top>#FUNDING_OFFICE_NUM#</td>
					<td valign=top>#ORG_TYPE_DESC#</td>
					<td valign=top>#SMB_TYPE_Code#</td>
					<td valign=top  style="border-right:1px solid ##5e84a6;">#DateFormat(DATE_START, 'mm/dd/yyyy')#<br>#DateFormat(date_end, 'mm/dd/yyyy')#</td>
					<td align="right" valign=top>#numberFormat(amount, "$,")#</td>
				</tr>

				<cfif currentRow eq rsSmallBusiness.recordcount or rsSmallBusiness.recordcount eq 1>
					<tr>
						<td colspan=8 align=right style="border-right:1px solid ##5e84a6;"><strong>Subtotal, <cfif rsSmallBusiness.recordcount eq 1>#new_org#<cfelse>#old_org#</cfif></strong></td>
						<td align=right><strong>#numberFormat(obli_total, "$,")#</strong></td>
					</tr>
					<tr>
						<td colspan=8 align=right style="border-right:1px solid ##5e84a6;"><strong>Total</strong></td>
						<td align=right><strong>#numberFormat(total, "$,")#</strong></td>
					</tr>
				</cfif>

				<cfset old_org = new_org>
		    </cfloop>
		  </table>
		<cfelse>
			<table valig=top width="100%" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
				<tr>
					<th valign=bottom scope="col" style="text-align:left" title="Contractor / Contract No.">Contractor /<br />Contract No.</th>
					<th valign=bottom scope="col" style="text-align:center" title="AAPP">AAPP</th>
					<th valign=bottom scope="col" style="text-align:center" title="Program Activity">Program<br />Activity</th>
					<th valign=bottom scope="col" style="text-align:center" title="Center/Performance Venue" nowrap>Center/<br />Performance Venue</th>
					<th valign=bottom scope="col" style="text-align:center" title="Funding Office">Funding<br />Office</th>
					<th valign=bottom scope="col" style="text-align:center" title="Organization Category">Organization<br /> Category</th>
					<th valign=bottom scope="col" style="text-align:center" title="Small Bus. Sub Cats" nowrap>Small Bus.<br />Sub Cats</th>
					<th valign=bottom scope="col" style="text-align:center" title="Period of Performance">Period of<br />Performance</th>
					<th valign=bottom scope="col" style="text-align:center" title="Obligations,FY 2007" nowrap>Obligations <cfif isDefined("form.cbofy") and form.cbofy neq "">,<br />FY <cfoutput>#form.cbofy#</cfoutput></cfif></th>
				</tr>
				<tr><td align=center colspan="9">
					<br><br>There are no matching records
					</td>
				</tr>
			</table>
		</cfif><!--- end loop of title --->

		<!-- Begin Form Footer Info  --->
		<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
			<cfdocumentitem type="footer">
			<table align=top width=100% cellspacing="0" border=0 cellpadding="0">
				<tr>
					<td align=right valign=top>
						<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
							page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
						</font>
					</td>
				</tr>
			</table>
			</cfdocumentitem>
		</cfif>
		<!-- End Content Area -->
	  </cfoutput>
	</div>

	</body>
	</html>

