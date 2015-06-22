<cfsilent>
<!---
page: rpt_footprint_transaction.cfm

description: display summary report for footprint transaction info.
Revisions:
2007-11-08	rroser	add information to header for reports for all AAPPs to show that report is for recent FYs
					alter table display to indicate breaks between AAPPs and Footprints within AAPPs
2007-11-27  abai    Revised for CHG4400 (using numberFormat instead of dollarFormat)
2007-12-10  abai    Made number line up.
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

<cfparam name="form.radReportType" default="AAPP">
<cfparam name="url.aapp" default="">
<cfparam name="form.AAPP" default="#url.aapp#">
<cfif form.radReportType neq "AAPP">
	<cfparam name="lastAAPP" default="">
	<cfparam name="switchAAPP" default="1">
</cfif>


<cfif form.radReportType is "AAPP">
	<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#form.AAPP#" returnvariable="rstGetAAPPGeneral" />
</cfif>



<!-- Begin Content Area -->
<!-- Begin Form Header Info -->
<body class="form">
<table border="0" cellspacing="0" cellpadding="0" align="center" width="762">
<tr>
<td>
<div class="formContent">
<cfoutput>
<h1>Footprint Transaction Discrepancies <cfif form.radReportType is "AAPP">for AAPP #form.AAPP#<cfelse>for all AAPPs</cfif></h1>
		<br>
		<cfif form.radReportType is "AAPP">
		<!--- display sub title data --->
		<table width="742" border="0" align="center" vliagn=top cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr><td width="12%" scope="row" title="AAPP No"><strong>AAPP No.:</strong></td>
				<td width="20%">#rstGetAAPPGeneral.aappNum#</td>
				<td width="25%" valign="top" scope="row" title="Program Activity"><strong>Program Activity:</strong></td>
				<td valign="top">#rstGetAAPPGeneral.programactivity#</td>
			</tr>
			<tr><td valign="top" scope="row" title="Contractor"><strong>Contractor:</strong></td>
				<td valign="top"> #rstGetAAPPGeneral.contractorname#</td>
				<td valign="top" scope="row" title="Performance Venue/Center"><strong>Performance Venue/Center:</strong></td>
				<td valign="top">#rstGetAAPPGeneral.venue# <cfif rstGetAAPPGeneral.venue neq '' and rstGetAAPPGeneral.centername neq "">/</cfif>#rstGetAAPPGeneral.centername#
				</td>
			</tr>
			<tr><td valign="top" scope="row" title="Contract No"><strong>Contract No.:</strong></td>
				<td valign="top">#rstGetAAPPGeneral.contractNum#</td>
				<td valign="top" scope="row" title="Performance Period"><strong>Performance Period:</strong></td>
				<td valign="top"><cfif rstGetAAPPGeneral.datestart neq "">#Dateformat(rstGetAAPPGeneral.datestart, "mm/dd/yyyy")#</cfif> <cfif rstGetAAPPGeneral.dateend neq "">to #dateFormat(rstGetAAPPGeneral.dateend, "mm/dd/yyyy")#</cfif>
				</td>
			</tr>
			<tr><td colspan="4" valign="top" align=right><br />Report run on: #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#</td></tr>
		</table>
		<cfelse><!---	indicate that it's for recent FYs only	--->
					<h2>For Footprints from Fiscal Year #evaluate(request.py - 1)# and later</h2>
		<table width="742" border="0" align="center" vliagn=top cellpadding="0" cellspacing="0" class="formHdrInfo">
			<tr>
				<td valign="top" align=right><br />Report run on: #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#
				</td>
			</tr>
		</table>
		</cfif>

		<!--- display data --->

		<table width="100%" cellpadding="0" cellspacing="0" border="0" class="form2DataTbl">
		<tr align="center" valign="bottom">
			<cfif form.radReportType is not "AAPP">
			<th scope="row" align="center">
			 	AAPP
			</th>
			</cfif>
			<th>
				FY
			</th>
			<th>
				DOLAR$ Doc Type
			</th>
			<th>
				DOLAR$ Doc Number
			</th>
			<th>
				RCC Org
			</th>
			<th>
				RCC Fund
			</th>
			<th>
				Object Class Code
			</th>
			<th>
				OPS vs CRA
			</th>
			<th>
			</th>
			<th>
				Footprint
			</th>
			<th>
				Transaction
			</th>
			<th>
				Difference
			</th>
		</tr>
		<cfif rstFootprintXactn.recordcount gt 0>
	<!--- loop to show records --->
		<cfloop query="rstFootprintXactn">
		<cfif form.radReportType is "AAPP">
			<tr valign="top" <cfif (currentRow mod 2) is 0>class="form2AltRow"</cfif>>
		<cfelse>
			<tr valign="top" <cfif (switchAAPP mod 2) is 0>class="form2AltRow"</cfif>>
		</cfif>
			<cfif form.radReportType is not "AAPP">
			<td>
				<cfif lastAAPP neq AAPPNum>#AAPPNum#<br />#ProgramAct#</cfif>
			</td>
			<cfset lastAAPP = AAPPNum>
			</cfif>
			<td align="center" <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>#FY#</td>
			<td align="center" <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>#DT#</td>
			<td align="center" <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>#docNum#</td>
			<td align="center" <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>#RccOrg#</td>
			<td align="center" <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>#RccFund#</td>
			<td align="center" <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>#ObjClass#</td>
			<td align="center" <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>#OpsCra#</td>
			<td <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>
				Obligation<br />
				Payment<br />
				Cost&nbsp;
			</td>
			<td align="right" <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>
				#numberFormat(Oblig, "$,.99")#<br />
				#numberFormat(Payment, "$,.99")#<br />
				#numberFormat(Cost, "$,.99")#<br>&nbsp;
			</td>
			<td align="right" <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>
				#numberFormat(XACTNAMTO, "$,.99")#<br />
				#numberFormat(XACTNAMTP, "$,.99")#<br />
				#numberFormat(XACTNAMTC, "$,.99")#<br>&nbsp;
			</td>
			<td align="right" <cfif radReportType is not "AAPP"><cfif rstFootprintXactn.AAPPNum[currentRow+1] eq rstFootprintXactn.AAPPNum[currentRow]> style="border-bottom:1px solid ##5e84a6;"</cfif></cfif>>
				<cfif XACTNAMTO neq ''>
					#numberFormat((Oblig - XACTNAMTO), "$,.99")#<br />
				<cfelse>
					#numberFormat(Oblig, "$,.99")#<br />
				</cfif>
				<cfif XACTNAMTP neq ''>
					#numberFormat((Payment - XACTNAMTP), "$,.99")#<br />
				<cfelse>
					#numberFormat(Payment, "$,.99")#<br />
				</cfif>
				<cfif XACTNAMTC neq ''>
					#numberFormat((Cost - XACTNAMTC), "$,.99")#<br>&nbsp;
				<cfelse>
					#numberFormat(Cost, "$,.99")#<br>&nbsp;
				</cfif>
			</td>
		</tr>
			<cfif form.radReportType is not "AAPP"><!--- if it's a report for multiple AAPPs --->
				<cfif rstFootprintXactn.AAPPNum[currentRow+1] neq rstFootprintXactn.AAPPNum[currentRow]><!--- next row is for different aapp --->
					<cfset switchAAPP = switchAAPP + 1><!--- switch colors --->
				</cfif>
			</cfif>
		</cfloop>
	<cfelse>
		<tr>
			<td colspan="11" align="center">
			There are currently no discrepancies
			</td>
		</tr>
	</cfif>

</table>

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
</td>
</tr>
</table>
</body>
</html>
