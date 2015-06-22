<cfsilent>
<!---
page: rpt_progop_detail.cfm

description: This template is used for displaying Program Operating Plan Detail report

revisions:
abai: 03/29/2007	Revised for defect 140 -- subTotal name.
abai: 07/24/2007    Revised for adding title attribute in the <td> tag. format header info.
abai: 08/07/2007    Making header bold
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
<!-- Begin Content Area -->
<!-- Begin Form Header Info -->
<div class="formContent">
<cfset old_aapp = "">
<cfset new_aapp = "">
<cfset cnt=1>
<cfset subTotal = 0>
<cfset display_subtotal = "false">
<cfset old_centerName = "">
<cfset new_centerName = "">

<cfif rsProgop_detail.recordcount gt 0>
	<cfoutput query="rsProgop_detail">
	<cfset new_aapp = aapp_num>
	<cfset new_centerName = center_name>

	 <cfif new_aapp neq old_aapp>
		<cfset cnt = 1>
		<cfif currentRow gt 1 and new_aapp neq old_aapp>
			<cfset display_subtotal = "true">
		</cfif>
	</cfif>

	<cfif cnt eq 1>

		<!--- display table end tag, subtotal and page break if there are more records--->
		<cfif display_subtotal>
				<tr>
					<td colspan="9" class="hrule"></td>
				</tr>
				<tr valign="top">
					<td></td>
					<td colspan="3"><strong>Subtotal for #old_centerName#</strong></td>
					<td align="right" colspan="2"><strong>#numberFormat(subTotal)#</strong></td>
					<td colspan="3"></td>
				</tr>
					<cfset display_subtotal = "false">
					<cfset subTotal = 0>
			</table>

			<!--- break page --->
			<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
				<cfdocumentitem type="pagebreak" />
			<cfelse>
				<br><br>
			</cfif>
	 	</cfif>

		<!--- display header info only once for each AAPP --->
		<h1>Program Operating Plan Detail</h1>
		<h2>Program Year #form.cboPY#</h2>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="display report header info.">

			<tr>
				<td width="20%" valign="top" scope="row" title="center"><strong>Center:</strong></td>
				<td width="65%" valign="top">#center_name#</td>
				<td></td>
			</tr>
			<tr>
			  	<td  valign="top" scope="row" title="AAPP No."><strong>AAPP No.:</strong></td>
				<td  valign="top">#aapp_num#</td>
				<td ></td></td>
			</tr>
			<tr>
			  	<td valign="top" scope="row" title="Funding Office"><strong>Funding Office:</strong></td>
				<td valign="top">#FUNDING_OFFICE_DESC#</td>
				<td></td>
			</tr>
			<tr><td colspan="3"><br>Report run on: #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#</td></tr>
        </table>
    <!-- End Form Header Info -->

	<table style="width: 100%;" border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
		<tr valign="bottom">
			<th scope="col" colspan="2" title="Cost Category">Cost Category</th>
			<th scope="col" style="text-align:center" title="CRA PY">CRA PY</th>
			<th scope="col" style="text-align:center" colspan="2" title="Center Ops Subcategory">Center Ops Subcategory</th>
			<th scope="col" style="text-align:center" title="Amount">Amount</th>
			<th scope="col" style="text-align:center" title="PY and FOP No.">PY and FOP No.</th>
			<th scope="col" style="text-align:center" title="Date Issued">Date Issued</th>
			<th scope="col">Purpose</th>
		</tr>
	</cfif>

		<tr valign="top" <cfif cnt mod 2>class="form2AltRow"</cfif>>
			<td width="2%">#cost_category_code#</td>
			<td width="10%" nowrap>#cost_cat_desc#</td>
			<td width="6%">#py_cra_budget#&nbsp;</td>
			<td width="2%" align=right>&nbsp;<cfif cost_subcategory_ID neq "" and left(trim(cost_subcategory_ID), 1) eq "0">#right(cost_subcategory_ID,1)#<cfelse>#trim(cost_subcategory_ID)#</cfif></td>
			<td width="10%" nowrap>&nbsp;#cost_subcategory#</td>
			<td width="12%" align="right">#numberFormat(amount)#</td>
			<td width="12%">#py#&nbsp;&nbsp;#fundingOffNum#&nbsp;&nbsp;#fop_num#</td>
			<!---<td width="12%">#form.cboPY#&nbsp;&nbsp;#fundingOffNum#&nbsp;&nbsp;#fop_num#</td>--->
			<td width="10%">#dateFormat(date_executed, 'mm/dd/yyyy')#</td>
			<td width="*" nowrap>#fop_description#</td>
		</tr>

		 <cfif amount neq "">
		 	<cfset subTotal = subTotal + amount>
	 	 </cfif>

		<!--- display subtotal if there is only one aapp or last one aapp --->
		<cfif currentRow eq rsProgop_detail.recordcount>
				<tr>
					<td colspan="9" class="hrule"></td>
				</tr>
				<tr valign="top">
					<td></td>
					<td colspan="3"><strong>Subtotal for #center_name#</strong></td>
					<td align="right" colspan="2"><strong>#numberFormat(subTotal)#</strong></td>
					<td colspan="3"></td>
				</tr>
					<cfset display_subtotal = "false">
					<cfset subTotal = 0>
			</table>

		</cfif>

		 <cfset cnt=cnt+1>
		 <cfset old_aapp = new_aapp>
	 	 <cfset old_centerName = new_centerName>
	</cfoutput>
<cfelse>
	<cfoutput>
	<h1>Program Operating Plan Detail</h1>
			<h2>PY #form.cboPY#</h2><br>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="display report header info.">
		<tr><td colspan="3"><br>Report run on: #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#</td></tr>
	</table>
	<table style="width: 100%;" border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
		<tr valign="bottom">
			<th scope="col" colspan="2" title="Cost Category">Cost Category</th>
			<th scope="col" style="text-align:center" title="CRA PY">CRA PY</th>
			<th scope="col" style="text-align:center" colspan="2" title="Center Ops Subcategory">Center Ops Subcategory</th>
			<th scope="col" style="text-align:center" title="Amount">Amount</th>
			<th scope="col" style="text-align:center" title="PY and FOP No.">PY and FOP No.</th>
			<th scope="col" style="text-align:center" title="Date Issued">Date Issued</th>
			<th scope="col">Purpose</th>
		</tr>
		<tr><td colspan=9 align=center><br><br>There are no matching records </td></tr>
	</table>
	</cfoutput>
</cfif>

<cfoutput>
 <!-- Begin Form Footer Info  --->
<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
	<cfdocumentitem type="footer">
		<table valign=top width=100% cellspacing="0" border=0 cellpadding="0">
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
</cfoutput>
</div>

</body>
</html>
