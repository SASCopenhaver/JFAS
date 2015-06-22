<!--- reports/adHocReportDisplay.cfm --->

<cfparam name="url.format" default="">
<cfscript>
	if (#url.format# eq "application/pdf"){
		session.adHocReport.setOrientation("#url.o#");
		session.adHocReport.setPaperSize("#url.p#");
	}
</cfscript>

<cfinclude template="#application.paths.reportdir#reportFunctions.cfm">

<!--- set request level path to css - could vary by output format --->
<!--- obs <cfset request.paths.reportcss = application.paths.reportcss> --->
<cfset request.paths.reportcss = application.urls.cssdir & 'jfas_report.css'>

<cfsetting requestTimeout = "900">

<cfset maxResults = 4000>
<cfset variables.arColumns = session.adHocReport.getDataset().getColumns()>
<cfset variables.lstColumnIndexDisplayed = session.adHocReport.getDataset().getColumnDisplayOrder()>
<cfset variables.lstColumnsSortOrder = session.adHocReport.getDataset().getColumnSortOrder()>
<cfset variables.lstColumnsSorting = session.adHocReport.getDataset().getColumnSorting()>
<cfset variables.lstColumnsGrouping = session.adHocReport.getDataset().getColumnGrouping()>
<Cfset variables.whereClause = session.adHocReport.getDataset().getCriteria().getWhereClause()>
<cfset lpcnt = 1>
<cfset orderbyClause = "">
<cfloop list="#variables.lstColumnsSortOrder#" index="idx">
	<cfif variables.arColumns[idx].getTypeID() eq 6>
		<cfset orderbyClause = orderbyClause & "to_date(#variables.arColumns[idx].getName()#,'dd-mon-yy') #listgetat(variables.lstColumnsSorting,lpcnt)#">
	<cfelse>
		<cfset orderbyClause = orderbyClause & "#variables.arColumns[idx].getName()# #listgetat(variables.lstColumnsSorting,lpcnt)#">
	</cfif>
	<cfif idx neq listgetat(variables.lstColumnsSortOrder,listlen(variables.lstColumnsSortOrder))>
		<cfset orderbyClause = orderbyClause & ",">
	</cfif>
	<cfset lpcnt = lpcnt + 1>
</cfloop>
<cfset listSelect ="">
<cfloop list="#variables.lstColumnIndexDisplayed#" index="idx">
	<cfset listSelect =listSelect & "#variables.arColumns[idx].getName()#">
	<cfif idx neq listgetat(variables.lstColumnIndexDisplayed,listlen(variables.lstColumnIndexDisplayed))>
		<cfset listSelect =listSelect & ",">
	</cfif>
</cfloop>


<cfquery name="qryGetAdHocResults" datasource="#session.reportBuilder.getDatasourceName()#">
	select #listSelect#
	from	#session.adHocReport.getDataset().getViewName()#
	<cfif variables.whereClause neq "">
		where	#preserveSingleQuotes(variables.whereClause)#
	</cfif>
	order by #preserveSingleQuotes(orderbyClause)#
</cfquery>

<cfif qryGetAdHocResults.recordcount eq 0>
	<script>
	alert('Your query returned no results.');
	window.close();
	</script>
<cfelseif qryGetAdHocResults.recordcount gt maxResults>
	<script>
	<cfoutput>
	alert('Your query returned more than #numberformat(maxResults)# records. Please modify the filter to return less data.');
	window.close();
	</cfoutput>
	</script>
<cfelse>
	<cfswitch expression="#url.format#">
		<cfcase value="application/pdf"><cfoutput>
			<cfif session.adHocReport.getPaperSize() eq "">
			<cfset paperSz = "letter">
		<cfelse><cfset paperSz = session.adHocReport.getPaperSize()>
		</cfif>
		<cfif session.adHocReport.getOrientation() eq "">
			<cfset paperOri = "landscape">
		<cfelse><cfset paperOri = session.adHocReport.getOrientation()>
		</cfif>
			<cfdocument format="PDF" pagetype="#paperSz#" margintop=".6" marginbottom=".6" marginright=".6" marginleft=".6" orientation="#paperOri#">

				<!--- Use a footer with current page of totalpages format--->
				<cfdocumentitem type="footer">

					<table width="100%">
					<tr>
						<td><span style="font-family:arial;font-size:x-small;">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</span></td>
						<td align="right"><span style="font-family:arial;font-size:x-small;">#dateformat(Now(), "mm/dd/yyyy")#</span></td>
					</tr>
					</table>

				</cfdocumentitem>

				<cfinclude template="adHocReportDisplay_content.cfm">
				</cfdocument>
			</cfoutput>
		</cfcase>
		<cfcase value="application/vnd.ms-excel">
			<cfheader name="Content-Disposition" value="inline;filename=adHocReportDisplay.xls">
			<cfcontent type="application/msexcel">
			<cfinclude template="adHocReportDisplay_content.cfm">
		</cfcase>
		<cfdefaultcase>
			<html>
			<body>
			<cfinclude template="adHocReportDisplay_content.cfm">
			</body>
			</html>
		</cfdefaultcase>
	</cfswitch>

</cfif>

