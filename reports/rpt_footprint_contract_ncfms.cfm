<cfsilent>
<!---
page: rpt_footprint_contract_ncfms.cfm

description: JFAS Footprint Contractor Report, updated for NCFMS

Revisions:
2010-01-06	mstein	File created
--->
</cfsilent>


<cfset total_ops_obligation = 0>
<cfset total_ops_cost = 0>
<cfset total_ops_unspend_bal = 0>
<cfset total_ops_payment = 0>
<cfset total_ops_unpaid_bal = 0>
<cfset total_cra_obligation = 0>
<cfset total_cra_cost = 0>
<cfset total_cra_unspend_bal = 0>
<cfset total_cra_payment = 0>
<cfset total_cra_unpaid_bal = 0>
<cfset total_aapp_obligation = 0>
<cfset total_aapp_cost = 0>
<cfset total_aapp_unspend_bal = 0>
<cfset total_aapp_payment = 0>
<cfset total_aapp_unpaid_bal = 0>


<cfif isDefined("form.cboFundingOffice") and form.cboFundingOffice neq 0>
	<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#form.cboFundingOffice#" returnvariable="rsFundingOffice">
</cfif>
<cfif isDefined("form.cboAgreementType") and form.cboAgreementType neq 0>
	<cfinvoke component="#application.paths.components#lookup" method="getAgreementTypes" agreementTypeCode="#form.cboAgreementType#" returnvariable="rsAgreementType">
</cfif>


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

<cfset old_aapp = "">
<cfset new_aapp = "">
<cfset cnt=1>
<cfset subTotal = 0>
<cfset display_aappTotal = "false">
<cfset cra_ops_group = "">
<cfset cra_ops_group_old = "">
<cfset cnt_cra = 0>
<CFSET ops_total = "false">
<cfset new_doc_num = "">
<cfset new_dt = "">
<cfset old_doc_num = "">
<cfset old_dt = "">

<!-- Begin Content Area -->
<!-- Begin Form Header Info -->
<div class="formContent">
  <cfoutput>
  <cfif rsFootprintContractor_ncfms.recordcount gt 0>

	<cfloop query="rsFootprintContractor_ncfms">
		<cfset new_aapp = aapp_num>
		<cfset not_display_data = "true">
		<cfset new_doc_num = doc_num>
		<cfset new_dt = doc_type>

		<cfif new_aapp neq old_aapp>
			<cfset cnt = 1>
			<cfif currentRow gt 1 and new_aapp neq old_aapp>
				<cfset display_aappTotal = "true">
			</cfif>
			<cfif currentRow gt 1 AND old_doc_num eq "" and old_DT eq "">
				<cfset not_display_data = "false">
			</cfif>
		</cfif>

		<cfif cnt eq 1>

			<!--- display table end tag, subtotal and page break if there are more than one AAPP records--->
			<cfif display_aappTotal>
					<cfif new_aapp neq old_aapp and cra_ops_group_OLD eq "OPS" and not_display_data eq "true">
						<!--- display OPS total there are only OPS or CRA--->
						<tr>
							<td colspan="5">&nbsp;</td>
							<td><strong>OPS</strong></td>
							<td colspan=2><strong>SUBTOTALS</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_obligation)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_cost)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_unspend_bal)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_payment)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_unpaid_bal)#</strong></td>
						</tr>
							<cfset ops_total = "false">
					</cfif>

					<!--- display CRA total --->
					<cfif not_display_data eq "true">
						<cfif  new_aapp neq old_aapp and cra_ops_group_OLD EQ "CRA">
						<tr valign=top>
							<td colspan="5">&nbsp;</td>
							<td><strong>CRA</strong></td>
							<td colspan=2><strong>SUBTOTALS</strong></td>
							<td align=right nowrap="nowrap"><strong>#numberformat(total_cra_obligation)#</strong></td>
							<td align=right nowrap="nowrap"><strong>#numberFormat(total_cra_cost)#</strong></td>
							<td align=right nowrap="nowrap"><strong>#numberFormat(total_cra_unspend_bal)#</strong></td>
							<td align=right nowrap="nowrap"><strong>#numberFormat(total_cra_payment)#</strong></td>
							<td align=right nowrap="nowrap"><strong>#numberFormat(total_cra_unpaid_bal)#</strong></td>
						</tr>
						</cfif>
						<!--- display AAPP total --->
						<tr valign=top>
						<td colspan="8" align=center><strong>Totals for AAPP No. #old_aapp#</strong></td>
						<td align=right nowrap="nowrap"><strong>#numberFormat(total_aapp_obligation)#</strong></td>
						<td align=right nowrap="nowrap"><strong>#numberFormat(total_aapp_cost)#</strong></td>
						<td align=right nowrap="nowrap"><strong>#numberFormat(total_aapp_unspend_bal)#</strong></td>
						<td align=right nowrap="nowrap"><strong>#numberFormat(total_aapp_payment)#</strong></td>
						<td align=right nowrap="nowrap"><strong>#numberFormat(total_aapp_unpaid_bal)#</strong></td>
						</tr>
					</cfif>

					<cfset display_aappTotal = "false">
					<cfset subTotal = 0>
					<!--- re-initial total --->
					<cfset total_ops_obligation = 0>
					<cfset total_ops_cost = 0>
					<cfset total_ops_unspend_bal = 0>
					<cfset total_ops_payment = 0>
					<cfset total_ops_unpaid_bal = 0>
					<cfset total_cra_obligation = 0>
					<cfset total_cra_cost = 0>
					<cfset total_cra_unspend_bal = 0>
					<cfset total_cra_payment = 0>
					<cfset total_cra_unpaid_bal = 0>
					<cfset total_aapp_obligation = 0>
					<cfset total_aapp_cost = 0>
					<cfset total_aapp_unspend_bal = 0>
					<cfset total_aapp_payment = 0>
					<cfset total_aapp_unpaid_bal = 0>
					<cfset cra_ops_group = "">
					<cfset cra_ops_group_old = "">
					<CFSET ops_total = "false">
					<cfset cnt_cra = 0>
				</table>

				<!--- break page --->
				<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
					<cfdocumentitem type="pagebreak" />
				<cfelse>
					<br><br>
				</cfif>
		 	</cfif>


			<!--- display title --->
			<h1>Footprint / Contractor Report
			&nbsp;&nbsp;<span style="font-weight:normal;">(source: NCFMS)</span>
			</h1>
			<h2>
				<cfif (not isDefined("form.AAPP")) or form.AAPP eq "">
					<cfif isDefined("form.cboFundingOffice") and  form.cboFundingOffice neq 0>Funding Office: #rsFundingOffice.fundingOfficeDesc#<br></cfif>
					<cfif isDefined("form.cboAgreementType") and form.cboAgreementType neq 0>Agreement Type: #rsAgreementType.agreementTypeDesc#<br></cfif>
				</cfif>
			</h2>

			<table width="742" border="0" vliagn=top cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr><td width="12%"><strong>AAPP No.:</strong></td>
				<td width="20%">#aapp_num#</td>
				<td width="30%" valign="top"><strong>Program Activity:</strong></td>
				<td valign="top">#prog_services#</td>
			</tr>
			<tr><td valign="top"><strong>Contractor:</strong></td>
				<td valign="top"> #CONTRACTOR_NAME#</td>
				<td valign="top"><strong>Performance Venue / Center:</strong></td>
				<td valign="top">
					#venue#<cfif venue neq "" and center_name neq ""> / </cfif>#center_name#
				</td>
			</tr>
			<tr><td valign="top"><strong>Contract No.:</strong></td>
				<td valign="top">#CONTRACT_NUM#</td>
				<td valign="top"><strong>Performance Period:</strong></td>
				<td valign="top">
					<cfif datestart neq "">from #DateFormat(datestart, 'mm/dd/yyyy')#</cfif>
					<cfif dateend neq "">to #DateFormat(dateend, 'mm/dd/yyyy')#</cfif>
				</td>
			</tr>
			</table>


			<table width="95%" border="0" valign=top cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr><td align=right nowrap="nowrap">Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#</td></tr>
			</table>

		    <table valign=top width="95%" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
				<tr valign=top>
					<th valign=top scope="col" style="text-align:center" title="Doc Type">Doc Type</th>
					<th valign=top scope="col" style="text-align:center" title="Doc FY" width=250>Doc FY</th>
					<th valign=top scope="col" style="text-align:center" title="Doc No." width=250>Doc No.</th>

					<th valign=top scope="col" style="text-align:center" title="Fund Code">Fund</th>
					<th valign=top scope="col" style="text-align:center" title="Program">Program</th>
					<th valign=top scope="col" style="text-align:center" title="Funding Office">Fund<br />Office</th>


					<th valign=top scope="col" style="text-align:center" title="PY">PY</th>
					<th valign=top scope="col" style="text-align:center" title="Last PY">Last<br>PY</th>

					<th valign=top scope="col" style="text-align:center" title="Obligation">Obligation</th>
					<th valign=top scope="col" style="text-align:center" title="Costs">Costs</th>
					<th valign=top scope="col" style="text-align:center" title="Unspent Balance">Unspent<br>Balance</th>
					<th valign=top scope="col" style="text-align:center" title="Payments">Payments</th>
					<th valign=top scope="col" style="text-align:center" title="Unpaid Balance">Unpaid<br>Balance</th>
				</tr>
		</cfif>

			<cfset cra_ops_group = fund_cat>
			<cfif cra_ops_group eq "CRA" and cra_ops_group_old eq "OPS">
				<cfset ops_total = "true">
				<cfset cnt_cra = 1>
			</cfif>
			<cfif rsFootprintContractor_ncfms.currentRow gt 1 and  ops_total eq "true" and not_display_data eq "true" and cnt_cra eq 1 >
				<!--- display OPS total there are both OPS and CRA--->
				<tr>
					<td colspan="5">&nbsp;</td>
					<td><strong>OPS</strong></td>
					<td colspan=2><strong>SUBTOTALS</strong></td>
					<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_obligation)#</strong></td>
					<td valign=top align=right nowrap="nowrap"><strong>#numberFormat(total_ops_cost)#</strong></td>
					<td valign=top align=right nowrap="nowrap"><strong>#numberFormat(total_ops_unspend_bal)#</strong></td>
					<td valign=top align=right nowrap="nowrap"><strong>#numberFormat(total_ops_payment)#</strong></td>
					<td valign=top align=right nowrap="nowrap"><strong>#numberFormat(total_ops_unpaid_bal)#</strong></td>
				</tr>
				<tr><td colspan=15>&nbsp;</td></tr>
				<cfset ops_total = "false">
			</cfif>

				<tr valign="top"
					<cfif cnt_cra eq 1>
						class="form2AltRow"
					<cfelseif cnt_cra gt 1>
						<cfif cnt_cra mod 2>
							class="form2AltRow"
						</cfif>
					<cfelseif currentRow mod 2>
						class="form2AltRow"
					</cfif> >
					<td scope="row">#doc_type#</td>
					<td>#right(doc_fy,2)#</td>
					<td>#doc_num#</td>
					<td>#fund_code#</td>
					<td>#right(program_code,6)#</td>
					<td align="center">#funding_office_num#</td>
					<td>#approp_py#</td>
					<td>#approp_exp_py#</td>
					<td align=right nowrap="nowrap"><cfif OBLIG neq "">#numberformat(OBLIG)#</cfif></td>
					<td align=right nowrap="nowrap"><cfif cost neq "">#numberformat(cost)#</cfif></td>
					<td align=right nowrap="nowrap"><cfif unspent_balance neq "">#numberformat(unspent_balance)#</cfif></td>
					<td align=right nowrap="nowrap"><cfif PAYMENT neq "">#numberformat(PAYMENT)#</cfif></td>
					<td align=right nowrap="nowrap"><cfif unpaid_balance neq "">#numberformat(unpaid_balance)#</cfif></td>
				</tr>

				<!--- get OPS total --->
				<cfif ucase(fund_cat) eq "OPS">
					<cfif OBLIG neq "">
						<cfset total_ops_obligation = total_ops_obligation + OBLIG>
					</cfif>
					<cfif cost neq "">
						<cfset total_ops_cost = total_ops_cost + cost>
					</cfif>
					<cfif unspent_balance neq "">
						<cfset total_ops_unspend_bal = total_ops_unspend_bal + unspent_balance>
					</cfif>
					<cfif PAYMENT neq "">
						<cfset total_ops_payment = total_ops_payment + PAYMENT>
					</cfif>
					<cfif unpaid_balance neq "">
						<cfset total_ops_unpaid_bal = total_ops_unpaid_bal + unpaid_balance>
					</cfif>
			   </cfif>

			<!--- get CRA total --->
			<cfif ucase(fund_cat) eq "CRA">
				<cfif OBLIG neq "">
					<cfset total_cra_obligation = total_cra_obligation + OBLIG>
				</cfif>
				<cfif cost neq "">
					<cfset total_cra_cost = total_cra_cost + cost>
				</cfif>
				<cfif unspent_balance neq "">
					<cfset total_cra_unspend_bal = total_cra_unspend_bal + unspent_balance>
				</cfif>
				<cfif PAYMENT neq "">
					<cfset total_cra_payment = total_cra_payment + PAYMENT>
				</cfif>
				<cfif unpaid_balance neq "">
					<cfset total_cra_unpaid_bal = total_cra_unpaid_bal + unpaid_balance>
				</cfif>
			</cfif>

			<!--- get AAPP total --->
			<cfif OBLIG neq "">
				<cfset total_aapp_obligation = total_aapp_obligation + OBLIG>
			</cfif>
			<cfif cost neq "">
				<cfset total_aapp_cost = total_aapp_cost + cost>
			</cfif>
			<cfif unspent_balance neq "">
				<cfset total_aapp_unspend_bal = total_aapp_unspend_bal + unspent_balance>
			</cfif>
			<cfif PAYMENT neq "">
				<cfset total_aapp_payment = total_aapp_payment + PAYMENT>
			</cfif>
			<cfif unpaid_balance neq "">
				<cfset total_aapp_unpaid_bal = total_aapp_unpaid_bal + unpaid_balance>
			</cfif>

			<cfif cnt_cra gt 0>
				<cfset cnt_cra = cnt_cra +1>
			</cfif>

			<cfset cnt=cnt+1>
		 	<cfset old_aapp = new_aapp>
		 	<cfset old_doc_num  = new_doc_num>
		 	<cfset old_dt = new_dt>

			<CFSET cra_ops_group_OLD = cra_ops_group>

			<!--- display subtotal if there is only one aapp or last one aapp --->
			<cfif currentRow eq rsFootprintContractor_ncfms.recordcount and not_display_data eq "true">
					<cfif cra_ops_group eq "OPS">
						<!--- display OPS total there are only OPS or CRA--->
						<tr>
							<td colspan="5">&nbsp;</td>
							<td><strong>OPS</strong></td>
							<td colspan=2><strong>SUBTOTALS</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_obligation)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_cost)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_unspend_bal)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_payment)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_ops_unpaid_bal)#</strong></td>
						</tr>
							<cfset ops_total = "false">
					</cfif>

					<!--- display CRA total --->
					<cfif  cra_ops_group eq "CRA">
						<tr>
							<td colspan="5">&nbsp;</td>
							<td><strong>CRA</strong></td>
							<td colspan=2><strong>SUBTOTALS</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_cra_obligation)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_cra_cost)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_cra_unspend_bal)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberFormat(total_cra_payment)#</strong></td>
							<td valign=top align=right nowrap="nowrap"><strong>#numberFormat(total_cra_unpaid_bal)#</strong></td>
						</tr>
						<cfset cra_total = "false">
					</cfif>
					<tr>
						<td colspan="8" align=center><strong>Totals for AAPP No. #aapp_num#</strong></td>
						<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_aapp_obligation)#</strong></td>
						<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_aapp_cost)#</strong></td>
						<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_aapp_unspend_bal)#</strong></td>
						<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_aapp_payment)#</strong></td>
						<td valign=top align=right nowrap="nowrap"><strong>#numberformat(total_aapp_unpaid_bal)#</strong></td>
					</tr>
					<cfset display_aappTotal = "false">
					<cfset subTotal = 0>
				</table>

			</cfif>
	  </cfloop>

	<cfelse>
		<table valign=top>
		<tr><td align=center>
			<h1>Footprint File Contractor Report </h1>
			<br><br>There are no matching records
			</td>
		</tr>
		</table>
	</cfif><!--- end loop of title --->

		 <!-- Begin Form Footer Info  --->
		 <cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
			<cfdocumentitem type="footer">
				<table align=top width=95% cellspacing="0" border=0 cellpadding="0">
					<tr>
						<td align=right valign=top>
							<font size="-1" face="Arial Narrow, Arial, Times New Roman, Times, serif">
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
