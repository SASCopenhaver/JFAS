<cfsilent>
<!---
page: rpt_vst_worksheet.cfm

description: display report for Fop Worksheet by AAPP

revisions:
2007-08-07  abai    Make header font bold
2007-08-08  abai    Revised for not displaying period performance date if it is null
2007-11-26  abai    Revised for CHG4400 (using numberformat instead of dollarFOrmat)
--->
<cfset request.pageID = "1110" />
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - FOP CTST Worksheet">
<cfparam name="url.py" default="#evaluate(request.py+1)#">
<cfparam name="form.py" default="#url.py#">
<cfparam name="request.paths.reportcss" default="#application.paths.reportcss#"> <!--- this report could be run in html format without report_display.cfm --->
<cfinvoke component="#application.paths.components#reports" method="getVstRpt" aapp="#url.aapp#" py="#form.py#" returnvariable="rstVstRpt" />
</cfsilent>

<!---<cfdump var="#rstVstRpt#">--->

<!---Display Section--->
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
<cfoutput>
<table border="0" cellspacing="0" cellpadding="0" align="center" width="762">
	<tr>
		<td>
			<!--- Begin Content Area --->
			<!--- Begin Form Header Info --->
			<div class="formContent">
			<h1>PY #form.py# Job Corps CTST Funding</h1>

			<!--- if showing executed VST record, then show date it was executed --->
			<cfif rstVstRpt.history_rec neq 0>
				<h2>Executed on #dateformat(rstVstRpt.calculated_date,"mm/dd/yyyy")#</h2>
			<cfelse>
				<!--- otherwise, show today's date, the FMS Reporting Date, and whether this is acceptable to run the batch process --->
				<div style="text-align:center;margin-top:5px;margin-bottom:10px;">
				Calculated as of #dateformat(now(),"mm/dd/yyyy")#<br>
				<cfif rstVstRpt.vst_rpt_date neq request.voiddate>
					FMS Reporting Data as of  #dateformat(rstVstRpt.vst_rpt_date,"mm/dd/yyyy")#<br>
				<cfelse>
					No FMS Reporting Data found for this AAPP<br>
				</cfif>
				<cfif not rstVstRpt.status>
					<span style="color:red;">
					This AAPP requires FMS Reporting Data from #dateformat(rstVstRpt.good_report_Date,"mm/dd/yyyy")# or later
					in order to execute the PY #form.py# batch process</span>
				</cfif>
				</div>
			</cfif>

			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="CTST Worksheet Header Information">
				<tr valign="top">
					<td width="10%"><strong>Region:</strong></td>
					<td width="30%">#rstVstRpt.region_desc#</td>
					<td width="20%"><strong>Contractor:</strong></td>
					<td width="40%">#rstVstRpt.contractor_name#</td>
				</tr>
				<tr>
					<td><strong>AAPP No.:</strong></td>
					<td>#rstVstRpt.aapp_num#</td>
					<td><strong>Contract No.:</strong></td>
					<td>#rstVstRpt.contract_num#</td>
				</tr>
				<tr>
					<td w><strong>Center:</strong></td>
					<td>#rstVstRpt.center_name#</td>
					<td><strong>Performance Period:</strong></td>
					<td><cfif rstVstRpt.cnt_date_start neq "">#dateformat(rstVstRpt.cnt_date_start,"mm/dd/yyyy")#</cfif> <cfif rstVstRpt.cnt_date_end neq "">to #dateformat(rstVstRpt.cnt_date_end,"mm/dd/yyyy")#</cfif></td>
				</tr>

			</table>
			<!--- End Form Header Info --->

			<p></p>

			<cfif rstVstRpt.rpt_Type eq 0> <!--- this AAPP is not eligible for CTST this PY --->

				<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl" summary="CTST Worksheet not applicable">
					<tr>
						<td class="hrule"></td>
					</tr>
					<tr valign="middle">
						<td align="center">
							<br><br><br><br><br>
							AAPP #rstVstRpt.aapp_num# is not eligible for CTST funding in PY #form.py#.
							<br><br><br><br><br><br><br>
						</td>
					</tr>
					<tr>
						<td class="hrule"></td>
					</tr>
				</table>


			<cfelse>

				<cfif rstVstRpt.form_version gte 2>

					<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl" summary="CTST Worksheet details">
						<tr>
							<td colspan="3" class="hrule"></td>
						</tr>
						<tr class="formAltRow">
							<td width="85%" colspan="2">a. CTST Slots for AAPP #rstVstRpt.aapp_num#</td>
							<td align="right" width="15%"><strong>#rstVstRpt.vst_slots#</strong></td>
						</tr>
						<tr>
							<td colspan="2">b. Cumulative CTST Funding for AAPP #rstVstRpt.aapp_num# through PY #rstVstRpt.pre_py#</td>
							<td align="right">#numberformat(rstVstRpt.fopamount,"$,")#</td>
						</tr>
						<tr class="formAltRow">
							<td colspan="2">c. Contractor Obligations of CTST Funds for AAPP #rstVstRpt.aapp_num# through PY #rstVstRpt.pre_py#</td>
							<td align="right"><cfif rstVstRpt.rpt_type eq "13">#numberformat(rstVstRpt.fms_amount,"$,")#</cfif></td>
						</tr>

						<cfif rstVstRpt.rpt_type neq "13">
							<tr>
								<td></td>
								<td>(1) Cumulative Contractor Obligations Reported
									<cfif rstVstRpt.vst_rpt_date neq request.voiddate>
										#dateformat(rstVstRpt.vst_rpt_date,"mm/dd/yyyy")#:
									</cfif>
								</td>
								<td align="right">
									<cfif rstVstRpt.vst_rpt_date eq request.voiddate>
									n/a
									<cfelse>
										<cfif len(rstVstRpt.fms_amount)>
											#numberformat(rstVstRpt.fms_amount,"$,")#
										</cfif>
									</cfif>
								</td>
							</tr>
							<tr>
								<td></td>
								<td>(2) Estimated Additional Obligations for Remainder of PY #rstVstRpt.pre_py#:</td>
								<td align="right">
									<cfif rstVstRpt.rpt_type eq 3 and rstVstRpt.cnt_date_start eq rstVstRpt.next_prg_date_start>
										n/a
									<cfelse>
										<cfif len(rstVstRpt.credit)>
											#numberformat(rstVstRpt.credit,"$,")#
										</cfif>
									</cfif>
								</td>
							</tr>
							<tr>
								<td></td>
								<td>(3) Estimated Cumulative Obligations Through PY End (c1 + c2):</td>
								<td align="right"><strong>
									<cfif len(rstVstRpt.est_cum_obligation)>
										<cfif rstVstRpt.est_cum_obligation lt 0>-</cfif>#numberformat(abs(rstVstRpt.est_cum_obligation),"$,")#
									</cfif>
								</strong></td>
							</tr>
						</cfif>
						<tr class="formAltRow">
							<td colspan="2">d. Estimated Unused CTST Funds at PY End (b-c):</td>
							<td align="right">
								<cfif len(rstVstRpt.total_uncommit_vst)>
									#numberformat(rstVstRpt.uncommit_vst,"$,")#
								</cfif>
							</td>
						</tr>
						<tr>
							<td colspan="2">e. Allowance for Retaining Unspent Funds ($#rstVstRpt.vst_minium# x CTST Slots):</td>
							<td align="right">
								<cfif len(rstVstRpt.allowance)>
									#numberformat(rstVstRpt.allowance,"$,")#
								</cfif>
							</td>
						</tr>
						<tr class="formAltRow">
							<td colspan="2">f. Takeback of Excess Unspent CTST Funds (d-e):</td>
							<td align="right">
								<cfif len(rstVstRpt.excess_vst)>
									#numberformat(rstVstRpt.excess_vst,"$,")#
								</cfif>
							</td>
						</tr>
						<tr>
							<td colspan="2">g. Base PY #rstVstRpt.py# CTST Allocation ($#rstVstRpt.vst_supple# x CTST Slots):</td>
							<td align="right">
								<cfif len(rstVstRpt.base_allowance)>
									#numberformat(rstVstRpt.base_allowance,"$,")#
								</cfif>
							</td>
						</tr>
						<tr class="formAltRow">
							<td colspan="2">h. Prorated PY #rstVstRpt.py# CTST Allocation amount, based on number of days contract is active in PY:</td>
							<td align="right">
								<cfif len(rstVstRpt.vst_amount)>
									#numberformat(rstVstRpt.vst_prorated,"$,")#
								</cfif>
							</td>
						</tr>
						<tr>
							<td colspan="2"><strong>i. Net CTST Allocation for PY #rstVstRpt.py# (h-f):</strong></td>
							<td align="right"><strong>
								<cfif len(rstVstRpt.vst_amount)>
									#numberformat(rstVstRpt.vst_amount,"$,")#
								</cfif>
							</strong></td>
						</tr>

						<tr>
							<td colspan="3" class="hrule"></td>
						</tr>
					</table>

				<cfelseif rstVstRpt.form_version eq 1>


					<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl" summary="CTST Worksheet details">
						<tr>
							<td colspan="3" class="hrule"></td>
						</tr>
						<tr class="formAltRow">
							<td width="85%" colspan="2">a. CTST Slots for AAPP #rstVstRpt.aapp_num#</td>
							<td align="right" width="15%"><strong>#rstVstRpt.vst_slots#</strong></td>
						</tr>
						<tr>
							<cfif listfind("1,4,5",rstVstRpt.rpt_type)>
							<td colspan="2">b. Pending CTST Rollover from Predecessor Contract</td>
							<td align="right">n/a</td>
							<cfelse>
							<td colspan="2">b. Pending CTST Rollover from Predecessor Contract, AAPP #rstVstRpt.pre_aapp_num#, Ending #dateformat(rstVstRpt.pre_cnt_date_end,"mm/dd/yyyy")#</td>
							<td></td>
							</cfif>
						</tr>
						<cfif not listfind("1,4,5",rstVstRpt.rpt_type)>
						<tr>
							<td></td>
							<td>(1) CTST Slots for AAPP #rstVstRpt.pre_aapp_num#</td>
							<td align="right">#rstVstRpt.pre_vst_slots#</td>
						</tr>
						<tr>
							<td></td>
							<td>(2) Cumulative CTST Funding for AAPP #rstVstRpt.pre_aapp_num# Approved in AAPP/FOP:</td>
							<td align="right">
								<cfif len(rstVstRpt.pre_fopamount)>
									#numberformat(rstVstRpt.pre_fopamount,"$,")#
								</cfif>
							</td>
						</tr>
						<tr>
							<td></td>
							<td>(3) Cumulative Contractor Obligations Reported
								<cfif rstVstRpt.pre_vst_rpt_date eq request.voiddate>
									<font color="##FF0000">n/a</font>
								<cfelse>
									#dateformat(rstVstRpt.pre_vst_rpt_date,"mm/dd/yyyy")#:
								</cfif>
							</td>
							<td align="right">
								<cfif rstVstRpt.pre_vst_rpt_date neq request.voiddate>
									<cfif len(rstVstRpt.pre_fms_amount)>
										#numberformat(rstVstRpt.pre_fms_amount,"$,")#
									</cfif>
								</cfif>
							</td>
						</tr>
						<tr>
							<td></td>
							<td>(4) Estimated Additional Obligations for Remainder of Contract:</td>
							<td align="right">
								<cfif len(rstVstRpt.pre_credit)>
									#numberformat(rstVstRpt.pre_credit,"$,")#
								</cfif>
							</td>
						</tr>
						<tr>
							<td></td>
							<td>(5) Estimated Final Contractor Obligations (b3 + b4):</td>
							<td align="right">
								<cfif len(rstVstRpt.pre_final_obligation)>
									#numberformat(rstVstRpt.pre_final_obligation,"$,")#
								</cfif>
							</td>
						</tr>
						<tr>
							<td></td>
							<td>(6) Pending CTST Rollover from AAPP #rstVstRpt.pre_aapp_num# (b2-b5):</td>
							<td align="right"><strong>
								<cfif len(rstVstRpt.pre_uncommit_vst)>
									#numberformat(rstVstRpt.pre_uncommit_vst,"$,")#
								</cfif>
							</strong></td>
						</tr>
						</cfif>
						<tr class="formAltRow">
							<td colspan="2">c. Cumulative CTST Funding for AAPP #rstVstRpt.aapp_num#</td>
							<td></td>
						</tr>
						<tr class="formAltRow">
							<td></td>
							<td>(1) Cumulative CTST Funds Approved for AAPP #rstVstRpt.aapp_num# in AAPP/FOP:</td>
							<td align="right">
								<cfif len(rstVstRpt.fopamount)>
									#numberformat(rstVstRpt.fopamount,"$,")#
								</cfif>
							</td>
						</tr>
						<tr class="formAltRow">
							<td></td>
							<td>(2) Pending CTST Rollover from Predecessor Contract:</td>
							<td align="right">
								<cfif listfind("1,4,5",rstVstRpt.rpt_type)>
								n/a
								<cfelse>
									<cfif len(rstVstRpt.pre_uncommit_vst)>
										#numberformat(rstVstRpt.pre_uncommit_vst,"$,")#
									</cfif>
								</cfif>
							</td>
						</tr>
						<tr class="formAltRow">
							<td></td>
							<td>(3) Estimated Total CTST Funding (c1 + c2):</td>
							<td align="right"><strong>
								<cfif len(rstVstRpt.est_total_vst_find)>
									#numberformat(rstVstRpt.est_total_vst_find,"$,")#
								</cfif>
							</strong></td>
						</tr>
						<tr>
							<td colspan="2">d. Contractor Obligations of CTST Funds for AAPP #rstVstRpt.aapp_num# through PY #rstVstRpt.pre_py#</td>
							<td></td>
						</tr>
						<tr>
							<td></td>
							<td>(1) Cumulative Contractor Obligations Reported
								<cfif rstVstRpt.vst_rpt_date neq request.voiddate>
									#dateformat(rstVstRpt.vst_rpt_date,"mm/dd/yyyy")#:
								</cfif>
							</td>
							<td align="right">
								<cfif rstVstRpt.vst_rpt_date eq request.voiddate>
								n/a
								<cfelse>
									<cfif len(rstVstRpt.fms_amount)>
										#numberformat(rstVstRpt.fms_amount,"$,")#
									</cfif>
								</cfif>
							</td>
						</tr>
						<tr>
							<td></td>
							<td>(2) Estimated Additional Obligations for Remainder of PY #rstVstRpt.pre_py#:</td>
							<td align="right">
								<cfif rstVstRpt.rpt_type eq 3 and rstVstRpt.cnt_date_start eq rstVstRpt.next_prg_date_start>
									n/a
								<cfelse>
									<cfif len(rstVstRpt.credit)>
										#numberformat(rstVstRpt.credit,"$,")#
									</cfif>
								</cfif>
							</td>
						</tr>
						<tr>
							<td></td>
							<td>(3) Estimated Cumulative Obligations Through PY End (d1 + d2):</td>
							<td align="right"><strong>
								<cfif len(rstVstRpt.est_cum_obligation)>
									<cfif rstVstRpt.est_cum_obligation lt 0>-</cfif>#numberformat(abs(rstVstRpt.est_cum_obligation),"$,")#
								</cfif>
							</strong></td>
						</tr>
						<tr class="formAltRow">
							<td colspan="2">e. Estimated Unused CTST Funds at PY End (c3-d3):</td>
							<td align="right">
								<cfif len(rstVstRpt.total_uncommit_vst)>
									#numberformat(rstVstRpt.total_uncommit_vst,"$,")#
								</cfif>
							</td>
						</tr>
						<tr>
							<td colspan="2">f. Allowance for Retaining Unspent Funds ($#rstVstRpt.vst_minium# x CTST Slots):</td>
							<td align="right">
								<cfif len(rstVstRpt.allowance)>
									#numberformat(rstVstRpt.allowance,"$,")#
								</cfif>
							</td>
						</tr>
						<tr class="formAltRow">
							<td colspan="2">g. Takeback of Excess Unspent CTST Funds (e-f):</td>
							<td align="right">
								<cfif len(rstVstRpt.excess_vst)>
									#numberformat(rstVstRpt.excess_vst,"$,")#
								</cfif>
							</td>
						</tr>
						<tr>
							<td colspan="2">h. Base PY #rstVstRpt.py# CTST Allocation ($#rstVstRpt.vst_supple# x CTST Slots):</td>
							<td align="right">
								<cfif len(rstVstRpt.base_allowance)>
									#numberformat(rstVstRpt.base_allowance,"$,")#
								</cfif>
							</td>
						</tr>
						<tr class="formAltRow">
							<td colspan="2"><strong>i. Net CTST Allocation for PY #rstVstRpt.py# (h-g):</strong></td>
							<td align="right"><strong>
								<cfif len(rstVstRpt.vst_amount)>
									#numberformat(rstVstRpt.vst_amount,"$,")#
								</cfif>
							</strong></td>
						</tr>

						<tr>
							<td colspan="3" class="hrule"></td>
						</tr>
					</table>
				</cfif>  <!--- what form version? --->

			</cfif> <!--- reprt type = 0? (is AAPP eligible for CTST this PY) --->

			<!--- End Form Data --->

			</div>
			<!--- End Content Area --->
		</td>
	</tr>
</table>
</cfoutput>
</body>
</html>

