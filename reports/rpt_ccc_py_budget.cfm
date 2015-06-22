<cfsilent>
<!---
page: rpt_ccc_py_budget.cfm

description: This template is used for displaying FOP CCC Budget report Result.

revisions:
abai 03/29/2007  Revised for defect 141 -- B1 data alignment.
abai 04/02/2007  Revised for defect 152 -- item B1 program year display wrong info.
abai 07/24/2007  Revised for adding title attribute in the <TD> tag
abai 08/07/2007  Making header bold
abai 10/26/2007  Add table header if there is no record returned.
20090613	mstein	Removed trailing comma from all cost categories (qc 353)
--->
</cfsilent>


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
<cfset old_aapp = "">
<cfset new_aapp = "">
<cfset cnt=1>
<cfset A_total = 0>
<cfset B1_total = 0>
<cfset grant_total = 0>
<cfset display_grantTotal = "false">
<cfset display_A_total = "false">
<cfset display_B1_Total = "false">
<cfset new_subCat = "">
<cfset old_subCat = "">
<cfset new_center = "">
<cfset old_center = "">

<div class="formContent">
<cfoutput>

<h1>FOP CCC Budget - Program Year #form.cboPY#</h1>
<h2>Report Printed #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#</h2>
<cfif rsFOP_CCC_Budget.recordcount gt 0>
	<cfloop query="rsFOP_CCC_Budget">
	<cfset new_aapp = aapp_num>
	<cfset new_subCat = cost_cat_code>
	<cfset new_center = center_name>

	 <cfif new_aapp neq old_aapp>
		<cfset cnt = 1>
		<cfif currentRow gt 1 and new_aapp neq old_aapp>
			<cfset display_grantTotal = "true">
		</cfif>
	</cfif>
	<cfif find("B1",new_subCat) gt 0 and find("A", old_subCat)>
		<cfset display_A_total = "true">
	</cfif>
	<cfif find("B2",new_subCat) gt 0 and find("B1", old_subCat)>
		<cfset display_B1_total = "true">
	</cfif>

	<cfif cnt eq 1>
		 <!--- display grant total if there are one more AAPP --->
		 <cfif display_grantTotal>
				<tr><td colspan="5" class="hrule"></td></tr>

				<tr>
					<td align="center"></td>
					<td><strong>Grand Total for #old_center#</strong></td>
					<td></td>
					<td align="right"><strong>$#numberFormat(grant_total)#</strong></td>
					<td></td>
				</tr>
				<cfset display_grantTotal = "false">
				<cfset display_A_total = "false">
				<cfset display_B1_total = "false">
				<cfset A_total = 0>
				<cfset B1_total = 0>
				<cfset grant_total = 0>
			</table>

			<!--- break page --->
			<cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
				<cfdocumentitem type="pagebreak" />
			<cfelse>
				<br><br>
			</cfif>
		</cfif>

		<!--- display header info --->
		<table width="760" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="show report header info.">
		<tr valign="top">
			<td width="20%" title="Center" scope="row"><strong>Center:</strong></td>
			<td width="*">#center_name#</td>
		</tr>
		<tr valign="top">
			<td title="AAPP No. " scope="row"><strong>AAPP No.:</strong></td>
			<td>#aapp_num#</td>
		</tr>
		<tr valign="top">
			<td title="Funding Office" scope="row"><strong>Funding Office:</strong></td>
			<td>#fundingOfficeDesc#</td>
		</tr>
		</table>
		<!-- End Form Header Info -->


		<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
		<tr>
			<th></th>
			<th scope="col" style="text-align:center" title="Cost Category">Cost Category </th>
			<th scope="col" colspan="2" style="text-align:center" title="Amount"><strong>Amount</strong>&nbsp;&nbsp;&nbsp;</th>
			<th></th>
		</tr>
  </cfif>

	<!--- display A sub total --->
	<cfif display_A_total eq "true">
		<tr><td colspan="5" class="hrule"></td></tr>

		<tr>
			<td align="center"></td>
			<td><strong>Center Operations Total</strong></td>
			<td></td>
			<td align="right"><strong>$#numberFormat(A_total)#</strong></td>
			<td></td>
		</tr>
		<tr><td colspan="5">&nbsp;</td></tr>
		<cfset display_A_total = "false">
	</cfif>

	<!--- display B1 sub total --->
	<cfif display_B1_total eq "true">
		<tr><td colspan="5" class="hrule"></td></tr>

		<tr>
			<td align="center"></td>
			<td><strong>Facility Cnst/Rehab Total</strong></td>
			<td></td>
			<td align="right"><strong>$#numberFormat(B1_total)#</strong></td>
			<td></td>
		</tr>
		<tr><td colspan="5">&nbsp;</td></tr>
		<cfset display_B1_total = "false">
	</cfif>

	<!--- begin to display data --->
	<cfset grant_total = grant_total + amount>
	<cfif find("A",new_subCat) gt 0>
		<cfset A_total = A_total + amount>
	</cfif>
	<cfif find("B1",new_subCat) gt 0>
		<cfset B1_total = B1_total + amount >
	</cfif>
	<tr <cfif currentRow mod 2>
			class="form2AltRow"
		</cfif>>
		<td width="10%" >#cost_cat_code#</td>
		<td width="*">#cost_cat_desc#
				<cfif new_subCat eq "B1">
					,&nbsp;&nbsp;#PY#&nbsp;&nbsp;CRA
				</cfif>
		</td>
		<cfif find("A",cost_cat_code) gt 0 or find("B1",cost_cat_code) gt 0>
			<td width="15%" align="right">$#numberFormat(amount)#</td>
			<td width="15%"></td>
		<cfelse>
			<td width="15%"></td>
			<td width="15%" align="right">$#numberFormat(amount)#</td>
		</cfif>
		<td width="10%"></td>
	</tr>



	<cfif currentRow eq rsFOP_CCC_Budget.recordcount>
	<tr><td colspan="5" class="hrule"></td></tr>

	<tr>
		<td align="center"></td>
		<td><strong> Grand Total for #new_center#</strong></td>
		<td></td>
		<td align="right"><strong>$#numberFormat(grant_total)#</strong></td>
		<td></td>
	</tr>
	<cfset display_grantTotal = "false">
	</table>
	</cfif>

	 	<cfset cnt=cnt+1>
	 	<cfset old_subCat = new_subCat>
		<cfset old_aapp = new_aapp>
		<cfset old_center = new_center>
	</cfloop>
<cfelse>
	<br>
		<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
		<tr>
			<th></th>
			<th scope="col" style="text-align:center" title="Cost Category">Cost Category </th>
			<th scope="col" colspan="2" style="text-align:center" title="Amount"><strong>Amount</strong>&nbsp;&nbsp;&nbsp;</th>
			<th></th>
		</tr>
		<tr><td colspan=3 align=center><br><br>There are no matching records</td></tr>
		</table>

</cfif>
</cfoutput>
</div>
<!-- End Content Area -->


</body>
</html>

