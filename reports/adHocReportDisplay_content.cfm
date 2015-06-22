
<html>
<head>
<cfoutput>
<title> JFAS Ad Hoc Report Builder</title>
<link href="#request.paths.reportcss#" rel="stylesheet" type="text/css">
</cfoutput>

</head>
<body bgcolor="ffffff">

<style type="text/css">
body {
	background-color: #ffffff;
	margin-left: 0px;
	margin-top: 15px;
	margin-right: 0px;
	margin-bottom: 15px;
}

</style>
<cfoutput>

<h1>JFAS Ad Hoc Report Builder (#session.adHocReport.getDataset().getDisplayName()# Dataset)</h1>

</cfoutput>
<cfinclude template="adHocDisplayCriterion.cfm">
<table cellpadding="3" cellspacing="0" border="0" width="100%" <cfif isDefined("url.format") and url.format eq "application/pdf">class="form2DataTbl"</cfif> summary="Display management report information">
	<tr valign="top"><cfoutput>
		<cfloop list="#variables.lstColumnIndexDisplayed#" index="idx">
			<!--- <cfif variables.lstColumnsGrouping eq "" or variables.lstColumnsGrouping neq variables.arColumns[idx].getId()> --->
			<cfif variables.lstColumnsGrouping eq "" or not listfindnocase(variables.lstColumnsGrouping,variables.arColumns[idx].getId())>
			<th scope="col" valign="top" title="#variables.arColumns[idx].getDisplayName()#" class="report_hdr">
				#variables.arColumns[idx].getDisplayName()#
			</th></cfif>
		</cfloop></cfoutput>
	</tr>
	<tr>
		<td></td>
	</tr>
	<!--- display when no grouping is selected --->
	<cfset count = 1><cfset nullFlg = "Y">
	<cfloop index="idx" list="#variables.lstColumnsGrouping#">
		<cfif idx neq "0">
			<cfset nullFlg = "N">
		</cfif>
	</cfloop>
	<cfif nullFlg eq "Y"><cfoutput>
	<cfloop query="qryGetAdHocResults">

		<tr valign="top" <cfif count mod 2 eq 0>class="form2AltRow"</cfif>>
			<cfloop list="#variables.lstColumnIndexDisplayed#" index="idx">
				<cfif currentRow eq 1>
					<cfset "total_#idx#" = 0>
				</cfif>
				<cfset columnVal = evaluate(variables.arColumns[idx].getName())>

					<cfswitch expression="#variables.arColumns[idx].getTypeID()#">
						<cfcase value="3">
							<cfset display = "#numberformat(columnVal)#">
							<cfset cellClass = "report_datarow_right">
						</cfcase>
						<cfcase value="4">
							<cfset display = "#numberformat(columnVal,"$9,999")#">
							<cfset cellClass = "report_datarow_right">
						</cfcase>
						<cfcase value="5">
							<cfset display = "#numberformat(columnVal,"$9,999.00")#">
							<cfset cellClass = "report_datarow_right">
						</cfcase>
						<cfcase value="6">
							<cfset display = "#dateformat(columnVal,"mm/dd/yyyy")#">
							<cfset cellClass = "report_datarow">
						</cfcase>
						<cfcase value="7">
							<cfset display = "#dateformat(columnVal,"mm/dd/yyyy")# #timeformat(columnVal,"hh:mm")#">
							<cfset cellClass = "report_datarow">
						</cfcase>
						<cfcase value="8">
							<cfset display = "#numberformat(columnVal)#%">
							<cfset cellClass = "report_datarow_right">
						</cfcase>
						<cfcase value="9">
							<cfset display = "#numberformat(columnVal,"9,999.00")#%">
							<cfset cellClass = "report_datarow_right">
						</cfcase>
						<cfdefaultcase>
							<cfset display = "#columnVal#">
							<cfset cellClass = "report_datarow">
						</cfdefaultcase>
					</cfswitch>

					<cfif (variables.arColumns[idx].showTotal() or variables.arColumns[idx].showAverage()) and columnVal neq "">
						<cfset "total_#idx#" = evaluate("total_#idx#") + columnVal>
					</cfif>
				<td class="#cellClass#">
					#display#
				</td>
			</cfloop>
		</tr>
		<cfset count = count + 1>
	</cfloop></cfoutput>
	<cfelse>
		<!--- display when grouping is selected --->
		<cfoutput query="qryGetAdHocResults" group="#variables.arColumns[listgetat(variables.lstColumnsSortOrder,1)].getName()#" >
		<cfset rowLen = listlen(variables.lstColumnsSortOrder) - 1>
		<tr><td class="group_label" colspan="#rowLen#">
				<cfset grpcolval = Evaluate("#variables.arColumns[listgetat(variables.lstColumnsSortOrder,1)].getName()#")>

				<cfswitch expression="#variables.arColumns[listgetat(variables.lstColumnsSortOrder,1)].getTypeID()#">
					<cfcase value="3">
						<cfset display = "#numberformat(grpcolval)#">
					</cfcase>
					<cfcase value="4">
						<cfset display = "#numberformat(grpcolval,"$9,999")#">
					</cfcase>
					<cfcase value="5">
						<cfset display = "#numberformat(grpcolval,"$9,999.00")#">
					</cfcase>
					<cfcase value="6">
						<cfset display = "#dateformat(grpcolval,"mm/dd/yyyy")#">
					</cfcase>
					<cfcase value="7">
						<cfset display = "#dateformat(grpcolval,"mm/dd/yyyy")# #timeformat(grpcolval,"hh:mm")#">
					</cfcase>
					<cfcase value="8">
						<cfset display = "#numberformat(grpcolval)#%">
					</cfcase>
					<cfcase value="9">
						<cfset display = "#numberformat(grpcolval,"9,999.00")#%">
					</cfcase>
					<cfdefaultcase>
						<cfset display = "#grpcolval#">
					</cfdefaultcase>
				</cfswitch>
				#display#
			</td>
		</tr><cfset grpcnt = 1><cfset count = 1>
			<cfoutput>
			<tr valign="top" <cfif count mod 2 eq 0>class="form2AltRow"</cfif>>
				<cfloop list="#variables.lstColumnIndexDisplayed#" index="idx">
					<cfif grpcnt eq 1>
						<cfset "grpTotal_#idx#" = 0>
					</cfif>
					<cfif currentRow eq 1>
						<cfset "total_#idx#" = 0>
					</cfif>
					<cfset columnVal = evaluate(variables.arColumns[idx].getName())>
						<cfif grpcolval neq columnVal>
						<cfswitch expression="#variables.arColumns[idx].getTypeID()#">
							<cfcase value="3">
								<cfset display = "#numberformat(columnVal)#">
								<cfset cellClass = "report_datarow_right">
							</cfcase>
							<cfcase value="4">
								<cfset display = "#numberformat(columnVal,"$9,999")#">
								<cfset cellClass = "report_datarow_right">
							</cfcase>
							<cfcase value="5">
								<cfset display = "#numberformat(columnVal,"$9,999.00")#">
								<cfset cellClass = "report_datarow_right">
							</cfcase>
							<cfcase value="6">
								<cfset display = "#dateformat(columnVal,"mm/dd/yyyy")#">
								<cfset cellClass = "report_datarow">
							</cfcase>
							<cfcase value="7">
								<cfset display = "#dateformat(columnVal,"mm/dd/yyyy")# #timeformat(columnVal,"hh:mm")#">
								<cfset cellClass = "report_datarow">
							</cfcase>
							<cfcase value="8">
								<cfset display = "#numberformat(columnVal)#%">
								<cfset cellClass = "report_datarow_right">
							</cfcase>
							<cfcase value="9">
								<cfset display = "#numberformat(columnVal,"9,999.00")#%">
								<cfset cellClass = "report_datarow_right">
							</cfcase>
							<cfdefaultcase>
								<cfset display = "#columnVal#">
								<cfset cellClass = "report_datarow">
							</cfdefaultcase>
						</cfswitch>

						<cfif (variables.arColumns[idx].showTotal() or variables.arColumns[idx].showAverage()) and columnVal neq "">
							<cfif grpcolval neq display>
								<cfset "grpTotal_#idx#" = evaluate("grpTotal_#idx#") + columnVal>
							</cfif>
							<cfif grpcolval neq display>
								<cfset "total_#idx#" = evaluate("total_#idx#") + columnVal>
							</cfif>
						</cfif>

						<td class="#cellClass#">#display#</td>
					</cfif>
				</cfloop>
					<cfset count = count + 1>
				</tr>
				<cfset grpcnt = grpcnt+ 1>
				</cfoutput>
				<!--- row for sub totals --->
			<tr valign="top">
				<cfset lpTotCnt = 1>
				<cfloop list="#variables.lstColumnIndexDisplayed#" index="idx">
					<cfif variables.lstColumnsGrouping neq variables.arColumns[idx].getId()>
					<td class="report_totalrow">
						<cfif variables.arColumns[idx].showTotal()>
							<cfset columnVal = #evaluate("grpTotal_" & idx)#>
							<cfif columnVal neq 0><strong>Group Total:</strong>
								<cfswitch expression="#variables.arColumns[idx].getTypeID()#">
									<cfcase value="3">
										#numberformat(columnVal)#
									</cfcase>
									<cfcase value="4">
										$#numberformat(columnVal)#
									</cfcase>
									<cfcase value="5">
										$#numberformat(columnVal,"9.00")#
									</cfcase>
									<cfcase value="6">
										#dateformat(columnVal,"mm/dd/yyyy")#
									</cfcase>
									<cfcase value="7">
										#dateformat(columnVal,"mm/dd/yyyy")# #timeformat(columVal,"hh:mm")#
									</cfcase>
									<cfdefaultcase>
										#columnVal#
									</cfdefaultcase>
								</cfswitch>
							</cfif>
						</cfif>
					</td></cfif>
					<cfset lpTotCnt = lpTotCnt + 1>
				</cfloop>
			</tr>
			<!--- row for group averages --->
			<tr valign="top">
				<cfset lpTotCnt = 1>
				<cfloop list="#variables.lstColumnIndexDisplayed#" index="idx">
					<cfif variables.lstColumnsGrouping neq variables.arColumns[idx].getId()>
					<td class="report_totalrow">
						<cfif variables.arColumns[idx].showAverage()>
							<cfset columnVal = evaluate("grpTotal_" & idx)/(grpcnt-1)>
							<cfif columnVal neq 0><strong>Group Average:</strong>
								<cfswitch expression="#variables.arColumns[idx].getTypeID()#">
									<cfcase value="3">
										#numberformat(columnVal)#
									</cfcase>
									<cfcase value="4">
										$#numberformat(columnVal)#
									</cfcase>
									<cfcase value="5">
										$#numberformat(columnVal,"9.00")#
									</cfcase>
									<cfcase value="6">
										#dateformat(columnVal,"mm/dd/yyyy")#
									</cfcase>
									<cfcase value="7">
										#dateformat(columnVal,"mm/dd/yyyy")# #timeformat(columVal,"hh:mm")#
									</cfcase>
									<cfdefaultcase>
										#columnVal#
									</cfdefaultcase>
								</cfswitch>
							</cfif>
						</cfif>
					</td>
					</cfif><cfset lpTotCnt = lpTotCnt + 1>
				</cfloop>
			</tr>


		</cfoutput>
	</cfif>
	<cfoutput>
	<!--- row for totals --->
	<tr valign="top">
		<cfset lpTotCnt = 1>
		<cfloop list="#variables.lstColumnIndexDisplayed#" index="idx">
			<cfif variables.lstColumnsGrouping neq variables.arColumns[idx].getId()>
			<td class="report_totalrow">
				<cfif variables.arColumns[idx].showTotal()>
					<cfset columnVal = #evaluate("total_" & idx)#>
					<cfif columnVal neq 0><strong>Total:</strong>
						<cfswitch expression="#variables.arColumns[idx].getTypeID()#">
							<cfcase value="3">
								#numberformat(columnVal)#
							</cfcase>
							<cfcase value="4">
								$#numberformat(columnVal)#
							</cfcase>
							<cfcase value="5">
								$#numberformat(columnVal,"9,999.00")#
							</cfcase>
							<cfcase value="6">
								#dateformat(columnVal,"mm/dd/yyyy")#
							</cfcase>
							<cfcase value="7">
								#dateformat(columnVal,"mm/dd/yyyy")# #timeformat(columVal,"hh:mm")#
							</cfcase>
							<cfdefaultcase>
								#columnVal#
							</cfdefaultcase>
						</cfswitch>
					</cfif>
				</cfif>
			</td></cfif>
			<cfset lpTotCnt = lpTotCnt + 1>
		</cfloop>
	</tr>
	<!--- row for averages --->
	<tr valign="top" >
		<cfset lpTotCnt = 1>
		<cfloop list="#variables.lstColumnIndexDisplayed#" index="idx">
			<cfif variables.lstColumnsGrouping neq variables.arColumns[idx].getId()>
			<td class="report_totalrow">
				<cfif variables.arColumns[idx].showAverage()>
					<cfset columnVal = #evaluate("total_" & idx)#>
					<cfif columnVal neq 0 ><strong>Average:</strong>
						<cfswitch expression="#variables.arColumns[idx].getTypeID()#">
							<cfcase value="3">
								#numberformat(columnVal/qryGetAdHocResults.recordcount)#
							</cfcase>
							<cfcase value="4">
								$#numberformat(columnVal/qryGetAdHocResults.recordcount)#
							</cfcase>
							<cfcase value="5">
								$#numberformat(columnVal/qryGetAdHocResults.recordcount,"9.00")#
							</cfcase>
							<cfcase value="6">
								#dateformat(columnVal,"mm/dd/yyyy")#
							</cfcase>
							<cfcase value="7">
								#dateformat(columnVal,"mm/dd/yyyy")# #timeformat(columVal,"hh:mm")#
							</cfcase>
							<cfdefaultcase>
								#columnVal/qryGetAdHocResults.recordcount#
							</cfdefaultcase>
						</cfswitch>
					</cfif>
				</cfif>
			</td></cfif>
			<cfset lpTotCnt = lpTotCnt + 1>
		</cfloop>
	</tr>
</table>
</cfoutput>