<cfsilent>
<!---
page: aapp_summary.cfm

description: read only AAPP overview page - main hub for all entry points into AAPP

note: functionality on AAPP Setup form (aapp_setup.cfm) used to exist on this page

revisions:
2011-12-02	mstein	AAPP Setup form functionality saved as aapp_setup.cfm
--->
<!---
<cfdump var="#session#" label="session in aapp_summary">
<cfdump var="#form#" label="form in aapp_summary">
<cfdump var="#request#" label="request in aapp_summary">
<cfabort>
--->

<cfset request.pageID = "105">
<cfif isDefined("form.aapp") >
	<cfset request.aapp = form.aapp>
</cfif>
<cfif isDefined("url.aapp") >
	<cfset request.aapp = url.aapp>
</cfif>

<!--- get summary data struct --->

<cfinvoke component="#application.paths.components#aapp_summary" method="getAAPPOverview" aapp="#request.aapp#" returnvariable="stcAAPPSummary">
<!--- belldr 10/26/2014 - put Program Activity into request scope, for header.cfm --->
</cfsilent>


<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">
<cfinclude template="#application.paths.includes#jsGraphics.cfm">

<div class="ctrSubContent">
	<h2>AAPP Summary</h2>

	<!--- top level summary data --->
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="readOnlyDataTbl" title="Table for layout purposes">
	<cfoutput>
	<tr>
		<td width="18%">Type of Agreement:</td>
		<td>#stcAAPPSummary.AgreementTypeDesc#</td>
	</tr>
	<tr>
		<td>Status:</td>
		<td>#stcAAPPSummary.StatusDesc#</td>
	</tr>

	<tr>
		<td>Program Activity:</td>
		<td>#stcAAPPSummary.ProgramActivity#</td>
	</tr>
	<!--- <cfif ListFindNoCase(stcAAPPSummary.ColumnList, "Latest2110ReportDate" )> --->
	<cfif StructKeyExists(stcAAPPSummary, "Latest2110ReportDate")>
		<tr>
			<td>Latest 2110 Report:</td>
			<td>
				<cfif isDate(stcAAPPSummary.Latest2110ReportDate)>
					#dateformat(stcAAPPSummary.Latest2110ReportDate, "mm/dd/yyyy")#
				<cfelse>
					#stcAAPPSummary.Latest2110ReportDate#
				</cfif>
			</td>
		</tr>
	</cfif>
	</cfoutput>
	</table>
	<br>

	<cfif StructKeyExists(stcAAPPSummary, "rstScheduleWorkload")>
		<!--- contract year / workload data, for contracts, grants, and CCCs --->
		<table width="97%" border="0" cellpadding="0" cellspacing="0" class="readOnlyDataTbl" title="Display of Workload Information">
		<tr>
			<th scope="col" style="text-align:center;">
			<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "contractYear")>Year</cfif>&nbsp;</th>
			<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "CYdateStart")><th scope="col" style="text-align:left;">Start</th></cfif>
			<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "CYdateEnd")><th scope="col" style="text-align:left;">End</th></cfif>
			<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "CYnumDays")><th scope="col">Days</th></cfif>
			<th scope="col">Slots</th>
			<th scope="col">Arrivals</th>
			<th scope="col">Grads</th>
			<th scope="col">Frmr Enrollees</th>
			<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "CYtype")><th>&nbsp;</th></cfif>
		</tr>
		<cfoutput query="stcAAPPSummary.rstScheduleWorkload">
			<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "contractYear") and (contractYear eq request.curContractYear)>
				<cfset styleText = 'style="color:##3366FF;font-weight:bold;"'>
			<cfelse>
				<cfset styleText="">
			</cfif>
			<tr>
				<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "contractYear")>
					<td width="50" align="center" #styleText#>#contractYear#</td>
				<cfelse>
					<td width="150" #styleText#>Workload</td>
				</cfif>
				<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "CYdateStart")>
					<td #styleText#>#dateformat(CYdateStart, "mm/dd/yyyy")#</td></cfif>
				<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "CYdateEnd")>
					<td #styleText#>#dateformat(CYdateEnd, "mm/dd/yyyy")#</td></cfif>
				<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "CYnumDays")>
					<td align="center" #styleText#>#CYnumDays#</td></cfif>
				<td align="center" #styleText#>#CYslots#</td>
				<td align="center" #styleText#>#CYArrivals#</td>
				<td align="center" #styleText#>#CYgrads#</td>
				<td align="center" #styleText#>#CYenrollees#</td>
				<cfif ListFindNoCase(stcAAPPSummary.rstScheduleWorkload.ColumnList, "CYtype")><td align="center" #styleText#>#CYtype#</td></cfif>
			</tr>
		</cfoutput>
		</table>
		<br>
	</cfif>

	<cfif StructKeyExists(stcAAPPSummary, "rstContractFunding")>
		<!--- contract estimates, funding, mods --->
		<table width="97%" border="0" cellpadding="0" cellspacing="0" class="readOnlyDataTbl" title="Display of Funding Information">
		<tr>
			<cfoutput>
			<th width="5%" scope="col">&nbsp;</th>
			<th width="22%" scope="col" style="text-align:left;">Cost Category</th>
			<th width="*" scope="col">&nbsp;</th>
			<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "ECPamount")>
				<th width="20%" scope="col" style="text-align:right;">Estimated Cost
					<cfif request.curContractYear lt 999><br>(through CY#request.curContractYear#)</th></cfif>
				<cfset ECPTotal = 0>
				<cfset ECPOpsTotal = 0>
			</cfif>
			<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "TotalFOPamount")>
				<th width="20%" scope="col" style="text-align:right;">Cumulative FOPs
					<cfif request.curContractYear lt 999><br>(through PY#right(request.py,2)#)</th></cfif>
				<cfset FOPTotal = 0>
				<cfset FOPOpsTotal = 0>
			</cfif>
			<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "ModFundingAmount")>
				<th width="20%" scope="col" style="text-align:right;">Mod Funding Total
					<cfif request.curContractYear lt 999><br>(through Mod #stcAAPPSummary.rstContractFunding.ModNumber#)</th></cfif>
				<cfset ModTotal = 0>
				<cfset ModOpsTotal = 0>
			</cfif>
			</cfoutput>
		</tr>
		<cfoutput query="stcAAPPSummary.rstContractFunding">
			<!--- if ECP and FOP both exist, but are different, show both in RED --->
			<cfif (ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "ECPamount") and ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "TotalFOPamount"))
					and (ECPAmount neq "") and (ECPAmount neq totalFOPamount)>
				<cfset ecpFOPvariance = 1>
			<cfelse>
				<cfset ecpFOPvariance = 0>
			</cfif>
			<tr>
				<td> &nbsp;&nbsp;#costCatCode#</td>
				<td>#costCatDesc#</td>
				<td></td>
				<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "ECPamount")>
					<td style="text-align:right;<cfif ecpFOPvariance>color:RED;</cfif>">
						<cfif ECPAmount neq "">
							#numberformat(ECPAmount,"$9,999")#</td>
							<cfset ECPTotal = ECPTotal + ECPAmount>
							<cfif costCatCode neq "B1"><cfset ECPOpsTotal = ECPOpsTotal + ECPAmount></cfif>
						</cfif>
				</cfif>
				<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "TotalFOPamount")>
					<td style="text-align:right;<cfif ecpFOPvariance>color:RED;</cfif>">
						<cfif totalFOPamount neq "">
							#numberformat(totalFOPamount,"$9,999")#</td>
							<cfset FOPTotal = FOPTotal + totalFOPamount>
							<cfif costCatCode neq "B1"><cfset FOPOpsTotal = FOPOpsTotal + totalFOPamount></cfif>
						</cfif>
				</cfif>
				<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "ModFundingAmount")>
					<td style="text-align:right;">
						<cfif modFundingAmount neq "">
							#numberformat(modFundingAmount,"$9,999")#</td>
							<cfset ModTotal = ModTotal + modFundingAmount>
							<cfif costCatCode neq "B1"><cfset ModOpsTotal = ModOpsTotal + modFundingAmount></cfif>
						</cfif>
				</cfif>
			</tr>
		</cfoutput>
		<tr>
			<cfoutput>
			<td style="border-top:solid 1px ##999999;">&nbsp;</td>
			<td style="border-top:solid 1px ##999999;">Total Operations</td>
			<td style="border-top:solid 1px ##999999;">&nbsp;</td>
			<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "ECPamount")>
				<td style="text-align:right;border-top:solid 1px ##999999;">#numberformat(ECPOpsTotal,"$9,999")#</td>
			</cfif>
			<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "TotalFOPamount")>
				<td style="text-align:right;border-top:solid 1px ##999999;">#numberformat(FOPOpsTotal,"$9,999")#</td>
			</cfif>
			<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "ModFundingAmount")>
				<td style="text-align:right;border-top:solid 1px ##999999;">#numberformat(ModOpsTotal,"$9,999")#</td>
			</cfif>
			</cfoutput>
		</tr>
		<tr style="font-weight:bold;">
			<cfoutput>
			<td></td>
			<td>Total</td>
			<td></td>
			<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "ECPamount")>
				<td style="text-align:right;">#numberformat(ECPTotal,"$9,999")#</td>
			</cfif>
			<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "TotalFOPamount")>
				<td style="text-align:right;">#numberformat(FOPTotal,"$9,999")#</td>
			</cfif>
			<cfif ListFindNoCase(stcAAPPSummary.rstContractFunding.ColumnList, "ModFundingAmount")>
				<td style="text-align:right;">#numberformat(ModTotal,"$9,999")#</td>
			</cfif>
			</cfoutput>
		</tr>
		</table>
		<br>
	</cfif>

	<cfif StructKeyExists(stcAAPPSummary, "rstReconciliation")>
		<!--- comparison between obligations, FOPs, and allocation --->
		<table width="97%" border="0" cellpadding="0" cellspacing="0" class="readOnlyDataTbl" title="Display of Reconciliation Information">
		<tr>
			<cfoutput>
			<th width="*" scope="col" style="text-align:left;">Funding Category</th>
			<th width="15%" scope="col" style="text-align:right;">PY#right(request.py,2)# Obligations</th>
			<th width="15%" scope="col" style="text-align:right;">PY#right(request.py,2)# FOPs</th>
			<th width="15%" scope="col" style="text-align:right;">Difference</th>
			<th width="15%" scope="col" style="text-align:right;">Percentage</th>
			<th width="15%" scope="col" style="text-align:right;">PY#right(request.py,2)# Allocation</th>
			</cfoutput>
		</tr>
		<cfoutput query="stcAAPPSummary.rstReconciliation">
			<tr>
				<td>Operations</td>
				<td style="text-align:right;">#numberformat(ops_oblig,"$9,999")#</td>
				<td style="text-align:right;">#numberformat(ops_fop,"$9,999")#</td>
				<td style="text-align:right;">#numberformat(ops_oblig_fop_diff,"$9,999")#</td>
				<td style="text-align:right;">#numberformat(ops_oblig_fop_percent,"999.9")#%</td>
				<td style="text-align:right;">#numberformat(ops_allocat,"$9,999")#</td>
			</tr>
			<tr>
				<td>Construction</td>
				<td style="text-align:right;">#numberformat(cra_oblig,"$9,999")#</td>
				<td style="text-align:right;">#numberformat(cra_fop,"$9,999")#</td>
				<td style="text-align:right;">#numberformat(cra_oblig_fop_diff,"$9,999")#</td>
				<td style="text-align:right;">#numberformat(cra_oblig_fop_percent,"999.9")#%</td>
				<td style="text-align:right;">#numberformat(cra_allocat,"$9,999")#</td>
			</tr>
		</cfoutput>
		</table>

	</cfif>
</div>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">


