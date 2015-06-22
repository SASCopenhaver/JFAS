<cfsilent>
<!---
page: rpt_footprint_disc.cfm

description: printable version of the aapp / footprint discrepancy page (in the admin section)

Revisions:
2008-06-19	mstein	page created
2009-12-23	mstein	updated for NCFMS
2013-08-16	mstein	updated for ncfms
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


<!-- Begin Content Area -->
<!-- Begin Form Header Info -->
<body class="form">
<table border="0" cellspacing="0" cellpadding="0" align="center" width="762">
<tr>
<td>
<div class="formContent">
<cfoutput>
<h1>Unmatched NCFMS Document Numbers</h1>
<br />

	<table width="100%" border="0" align="center" vliagn=top cellpadding="0" cellspacing="0" class="formHdrInfo">
	<tr>
		<td>
		#strAAPPFootDisc.rstFootprintDisc.recordcount# records retrieved
		</td>
		<td valign="top" align=right>
		Report run on: #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#
		</td>
	</tr>
	</table>

	<!--- display data --->

	<table width="100%" cellpadding="0" cellspacing="0" border="0" class="form1DataTbl">
	<tr align="center" valign="bottom">
		<th scope="row">Doc ##</th>
		<th>Funding Office</th>
		<th>Vendor</th>
		<th></th>
	</tr>

	<cfif strAAPPFootDisc.rstFootprintDisc.recordcount gt 0>

		<cfloop query="strAAPPFootDisc.rstFootprintDisc"><!--- loop to show records --->
			<tr <cfif (currentRow mod 2) eq 0>class="form2AltRow"</cfif>>
				<td align="left">#docNum#</td>
				<td align="center">#FundingOfficeNum#</td>
				<td>#vendorName#</td>
				<td nowrap="nowrap">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
			</tr>
		</cfloop>
	<cfelse>
		<tr>
			<td colspan="4" align="center">
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
