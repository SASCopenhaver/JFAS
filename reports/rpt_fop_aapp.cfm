<cfsilent>
<!---
page: rpt_fop_aapp.cfm

description: display report for FOP listing

revisions:
12/20/2006 - rroser - Defect # 20 -
		Header now populated by getGeneralAAPP method of AAPP component, so visible when no records returned
		Table header visible when no records returned
		removed "click to close window" link
07/18/2007 - abai - change "cat." to "category"	on the report header.
07/24/2007 - abai - change "performance dates" to "performance period" and add title attribute into header of <td>
07/30/2007 - abai - add total on the report buttom
08/07/2007 - abai - Make header font bold
08/08/2007 - abai - Revised for not displaying period performance date if it is null
--->

</cfsilent>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>

<title>JF FOP #form.aapp#</title>
<link href="#request.paths.reportcss#" rel="stylesheet" type="text/css" />
</cfoutput>
</head>

<body class="form">
<table name="outsideReportTable" border="0" cellspacing="0" cellpadding="0" align="center" width="762">
<tr>
<td>
<!-- Begin Content Area -->
<div class="formContent">
	<!-- Begin Header Info -->
	<cfoutput>
	<h1>FOP Allocations for AAPP #form.AAPP#</h1>
	<h2><Cfif form.cboPY neq "all">Program Year #form.cboPY#<cfelse>All Program Years</Cfif></h2>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="display report header info.">
	<tr>
		<td width="15%" valign="top" title="Funding Office" scope="row"><strong>Funding Office:</strong></td>
		<td width="25%" valign="top">#rstGetAAPPGeneral.fundingofficedesc#</td>
		<td width="20%" valign="top" title="Program Activity" scope="row"><strong>Program Activity:</strong></td>
		<td width="*" valign="top">#rstGetAAPPGeneral.programactivity#</td>
	</tr>
	<tr>
		<td valign="top" title="Contractor" scope="row"><strong>Contractor:</strong></td>
		<td valign="top">#rstGetAAPPGeneral.contractorname#</td>
		<td valign="top" nowrap title="Performance Venue / Center" scope="row"><strong>Performance Venue/Center:</strong></td>
		<td valign="top"><cfif rstfoplist.venue neq ''>#rstfoplist.venue# / </cfif>#rstGetAAPPGeneral.centername#</td><!--- only show venue if it exists --->
	</tr>
	<tr>
		<td valign="top" title="Contract No." scope="row"><strong>Contract No.:</strong></td>
		<td valign="top">#rstGetAAPPGeneral.contractNum#</td>
		<td valign="top" title="Performance Period" scope="row"><strong>Performance Period:</strong></td>
		<td valign="top"><cfif rstGetAAPPGeneral.datestart neq "">#Dateformat(rstGetAAPPGeneral.datestart, "mm/dd/yyyy")#</cfif> <cfif rstGetAAPPGeneral.dateend neq "">to #dateFormat(rstGetAAPPGeneral.dateend, "mm/dd/yyyy")#</cfif></td>
	</tr>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2">Report run on: #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#</td>
		<td colspan="2" align="right"><cfif rstGetAAPPGeneral.contractStatusId is 1>Active<cfelse>Inactive</cfif> Record</td>
	  </tr>
	</table> <!-- End Form Header Info -->

	<!--- start form1DataTbl to contain the data --->
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
	<!--- column headings in one row --->
	<tr>
		<th scope="col" width="10%" style="text-align:center" title="PY">PY</th>
		<th scope="col" width="10%" style="text-align:center" title="FOP No.">FOP No.</th>
		<th scope="col" width="7%" style="text-align:center" title="Cost Category">Cost Category</th>
		<th scope="col" width="10%" style="text-align:center" title="Date Issued">Date Issued</th>
		<th scope="col" width="10%" style="text-align:center" title="Amount">Amount</th>
		<th scope="col" width="*" style="text-align:left" title="Purpose">Purpose</th>
	</tr>
	<cfif rstfoplist.recordcount is 0><!--- recordcount = 0 --->
		<tr>
		<td colspan="6" style="text-align:center">
			<br />
			<br />
			<br />
			There are no matching records.
		</td>
		</tr>
	<cfelse><!--- if there are records to show --->
		<cfset totalAmount = 0><!--- set amount to zero --->
		<cfset alt = 1><!--- and alt to one for first costcatcodegroup --->
		<cfset tempCostCatCode = rstFopList.costcatcodegroup><!--- save current costcat to compare  --->
		<cfset grant_total = 0>

		<cfloop query="rstFopList">
			<cfif tempCostCatCode neq #costcatcodegroup#><!--- if it's a new group --->
				<tr style="font-weight:bold"><!--- show the total --->
					<td colspan="2" style="text-align:right" nowrap="nowrap">Subtotal for Cost Category</td>
					<td style="text-align:center">#tempCostCatCode#</td>
					<td></td>
					<td style="text-align:right">#numberformat(totalAmount, "$,.99")#</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>

				<cfset totalAmount = 0><!--- reset the amount to zero --->
				<cfif currentrow mod 2><!--- for next costcatcodegroup, --->
					<cfset alt = 0>		<!--- if it starts with an even row --->
				<cfelse>				<!--- turn even rows blue --->
					<cfset alt = 1>		<!--- otherwise --->
				</cfif>					<!--- turn odd rows blue --->
			</cfif>
			<tr <cfif alt is 1>
					<cfif not currentrow mod 2>
						class="formAltRow"
					</cfif>
				<cfelse>
					<cfif currentrow mod 2>
						class="formAltRow"
					</cfif>
				</cfif>>
				<td scope="row" style="text-align:center" valign="top">
					#programyear#
				</td>
				<td style="text-align:center" valign="top">
					#fopnum#
				</td>
				<td style="text-align:center" valign="top">
					#costcatcode#
				</td>
				<td style="text-align:center" valign="top">
					#dateformat(dateexecuted, "mm/dd/yyyy")#
				</td>
				<td style="text-align:right" valign="top">
					#numberformat(Amount, "$,.99")# <cfset totalAmount = totalAmount + Amount><!--- add current amount to total for sum --->
				</td>
				<td valign="top" style="text-align:left">
					#fopdescription#
				</td>
			</tr>
			<cfset tempCostCatCode = costcatcodegroup><!--- set the current costcatcodegroup to be compared to next row --->
			<cfset grant_total =  grant_total + Amount >
		</cfloop>
		<tr style="font-weight:bold">
			<td colspan="2" valign="top" style="text-align:right">Subtotal for Cost Category</td>
			<td style="text-align:center" valign="top">#tempCostCatCode#</td>
			<td></td>
			<td style="text-align:right" valign="top">#numberFormat(totalAmount, "$,.99")#</td>
		</tr>
		<!--- display grant total --->
		<tr style="font-weight:bold">
			<td colspan="4" valign="top">&nbsp;Total</td>
			<td style="text-align:right" valign="top" >#numberFormat(grant_total, "$,.99")#</td>
			<td></td>
		</tr>
	</cfif>

	</table> <!--- form1DataTbl --->
</cfoutput>
</div>
<-- /formContent -->
<!-- End Content Area -->


<!-- Begin Form Footer Info -->
<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf"><!--- it's a pdf, show page info --->
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
</cfif> <!-- End Form Footer Info -->

</td>
</tr>
</table> <!--- outsideReportTable --->
</body>
</html>
