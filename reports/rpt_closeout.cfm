<cfsilent>

<!---
page: rpt_closeout.cfm

description: contract closeout report

revisions:

2011-04-21	mstein	JFAS 2.8: Major Revision of Close-out Report

--->

<!--- get general AAPP data --->
<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#form.hidAAPP#" returnvariable="rstGetAAPPGeneral" />
<cfinvoke component="#application.paths.components#footprint" method="getDocNumbers" aapp="#form.hidAAPP#" returnvariable="rstDocNumbers" />
<cfset lstDocNumbers = valuelist(rstDocNumbers.docNum,", ")>

<cfset reportStruct = structnew()>

<cfif form.closeOutID eq 0>
	<!--- if pending close-out, data will be passed in form struct, need to translate into reportStruct --->
	<cfloop collection="#form#" item="i">
		<!--- remove any commas from numerical values --->
		<cfif not listFindNoCase("hidCostCategories,hidContractTypes,hidCarryoverCats",i)>
			<cfset form[i] = replaceNoCase(form[i],",","","all")>
		</cfif>
	</cfloop>
	<cfset reportStruct = form>


<cfelse>
	<!--- closeoutID neq 0 --->
	<!--- if executed close-out, need to grab data from database, translate into reportStruct --->
	<cfinvoke component="#application.paths.components#aapp_yearend" aapp="#form.hidAAPP#" closeOutId="#form.closeOutId#" method="getCloseOutData" returnvariable="stcCloseOutData">

	<cfquery name="qryContractTypes" dbtype="query">
	select	costCatCode
	from	stcCloseOutData.rstFOPRecords
	where	cumulativeECP <> 0
	order	by costCatCode
	</cfquery>

	<!--- populate variables --->
	<cfset reportStruct.hidCostCategories = valueList(stcCloseOutData.rstFOPRecords.costCatCode) />
	<cfset reportStruct.hidContractTypes = valuelist(qryContractTypes.costCatCode) />
	<cfset reportStruct.hidReportingDate = stcCloseOutData.rstFOPRecords.reportingDate />

	<cfset reportStruct.hidModNum = stcCloseOutData.mod_num>
	<cfset reportStruct.hqTakeBack_ops = stcCloseOutData.hqOPStakeback />
	<cfset reportStruct.hqtakeBack_cra = stcCloseOutData.hqCRAtakeback />
	<cfset reportStruct.txtComments = stcCloseOutData.comments />
	<cfset reportStruct.hidCloseoutDate = stcCloseOutData.closeOutDate />
	<cfset reportStruct.hidFormVersion = stcCloseOutData.formVersion />

	<cfset reportStruct.txtFootFundingOPSTotal = stcCloseOutData.foot_funding_ops_total />
	<cfset reportStruct.txtFootFundingCRATotal = stcCloseOutData.foot_funding_cra_total>
	<cfset reportStruct.txtFootFundingTotal = stcCloseOutData.foot_funding_total>
	<cfset reportStruct.txtFootFundingOPSActive = stcCloseOutData.foot_funding_ops_active>
	<cfset reportStruct.txtFootFundingCRAActive = stcCloseOutData.foot_funding_cra_active>
	<cfset reportStruct.txtFootFundingOPSExpired = stcCloseOutData.foot_funding_ops_expired>
	<cfset reportStruct.txtFootFundingCRAExpired = stcCloseOutData.foot_funding_cra_expired>

	<cfset reportStruct.txtFootFundingChangeOPSTotal = stcCloseOutData.foot_funding_change_ops_total>
	<cfset reportStruct.txtFootFundingChangeCRATotal = stcCloseOutData.foot_funding_change_cra_total>
	<cfset reportStruct.txtFootFundingChangeTotal = stcCloseOutData.foot_funding_change_total>
	<cfset reportStruct.txtFootFundingChangeOPSActive = stcCloseOutData.foot_funding_change_ops_active>
	<cfset reportStruct.txtFootFundingChangeCRAActive = stcCloseOutData.foot_funding_change_cra_active>
	<cfset reportStruct.txtFootFundingChangeOPSExpired = stcCloseOutData.foot_funding_change_ops_expired>
	<cfset reportStruct.txtFootFundingChangeCRAExpired = stcCloseOutData.foot_funding_change_cra_expired>

	<cfloop query="stcCloseOutData.rstFOPRecords">
		<cfset reportStruct[costcatCode & "_costCatDesc"] = costCatDesc />
		<cfset reportStruct[costcatCode & "_contractorFinal"] = contractorFinal />
		<cfset reportStruct[costcatCode & "_budgetAuth"] = budgetAuth />
		<cfset reportStruct[costcatCode & "_FMSFOPvariance"] = FMSFOPvariance />
		<cfset reportStruct[costcatCode & "_fopChangeAmount"] = fopChangeAmount />
		<cfset reportStruct[costcatCode & "_rollover"] = rollover />
		<cfset reportStruct[costcatCode & "_hqAdjustment"] = hqAdjustment />
		<cfset reportStruct[costcatCode & "_cumulativeECP"] = cumulativeECP />
		<cfset reportStruct[costcatCode & "_ECPFOPvariance"] = ECPFOPvariance />
		<cfset reportStruct[costcatCode & "_ECPadjustment"] = ECPadjustment />
		<cfset reportStruct[costcatCode & "_FMSECPvariance"] = FMSECPvariance />
		<cfset reportStruct[costcatCode & "_modFunding"] = modFunding />
		<cfset reportStruct[costcatCode & "_FOPMODvariance"] = FOPMODvariance />
	</cfloop>

</cfif>



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

<style>
.form1DataTbl {
	font-family: Arial, Helvetica, sans-serif;
	font-size: .72em;
	width: 800px;
}

</style>

</head>
<body class="form">

<table border="0" cellspacing="0" cellpadding="0" align="center" width="800">
<tr>
	<td>
		<!-- Begin Content Area -->
		<!-- Begin Form Header Info -->
		<div class="formContent">
		<h1>Expired Contract / Budget Item Close out Report</h1>
		<cfoutput>
		<h2>
		<cfif form.closeOutId eq 0>Current Date:<cfelse>Close-out Executed:</cfif>
		#dateformat(reportStruct.hidCloseoutDate, "mm/dd/yyyy")#
		<cfif form.closeOutId eq 0>(this close-out has not been executed)</cfif></h2>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
		<tr valign="top">
			<td width="10%">AAPP No.:</td>
			<td width="20%">#rstGetAAPPGeneral.aappNum#</td>
			<td width="20%">Performance Period:</td>
			<td width="25%">#dateformat(rstGetAAPPGeneral.dateStart, "mm/dd/yyyy")# to #dateformat(rstGetAAPPGeneral.dateEnd, "mm/dd/yyyy")#</td>
			<td width="15%">Cost. Report Date:</td>
			<td width="10%">#dateformat(reportStruct.hidReportingDate, "mm/dd/yyyy")#</td>
		</tr>
		<tr valign="top">
			<td>Region:</td>
			<td>#rstGetAAPPGeneral.fundingOfficeDesc#</td>
			<td>Doc Number:</td>
			<td><cfif listLen(lstDocNumbers) gt 1>Multiple<cfelse>#lstDocNumbers#</cfif></td>
			<td>Contract Number:</td>
			<td>#rstGetAAPPGeneral.contractNum#</td>
		</tr>
		<tr valign="top">
			<td>Center:</td>
			<td>#rstGetAAPPGeneral.centerName#</td>
			<td>Contractor:</td>
			<td colspan="3">#rstGetAAPPGeneral.contractorName#</td>
		</tr>
		</table>
		</cfoutput>
		<!-- End Form Header Info -->

		<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">

		<cfset rowcounter = 1>
		<cfset colCount_sect1 = iif(reportStruct.hidFormVersion gte 3,de("7"),de("6"))>
		<cfset contractorFinalTotal = 0>
		<cfset contractorFinalTotal_ops = 0>
		<cfset budgetAuthTotal = 0>
		<cfset budgetAuthTotal_ops = 0>
		<cfset FMSFOPvarianceTotal = 0>
		<cfset FMSFOPvarianceTotal_ops = 0>
		<cfset fopChangeAmountTotal = 0>
		<cfset fopChangeAmountTotal_ops = 0>
		<cfset rolloverTotal = 0>
		<cfset rolloverTotal_ops = 0>
		<cfset hqAdjustmentTotal = 0>
		<cfset hqAdjustmentTotal_ops = 0>

		<cfoutput>
		<tr>
			<td colspan="#colCount_sect1#">AAPP/FOP RECONCILED TO FINAL CONTRACTOR COSTS</td>
		</tr>
		<tr valign="bottom">
			<th nowrap scope="col">Cost Category</th>
			<th scope="col" style="text-align:center">Final Contractor<br />Obligations</th>
			<th scope="col" style="text-align:center">Cumulative<br />FOP Total</th>
			<cfif reportStruct.hidFormVersion gte 3><th scope="col" style="text-align:center">Variance</th></cfif>
			<th scope="col" style="text-align:center">FOP Change<br>(AAPP #form.hidAAPP#)</th>
			<th scope="col" style="text-align:center">FOPportunity<br>(AAPP #form.hidSuccAAPP#)</th>
			<th scope="col" style="text-align:center">National Office<br>Adjustment</th>
		</tr>
		</cfoutput>

		<cfloop list="#reportStruct.hidCostCategories#" index="costCat">
			<cfoutput>

			<tr <cfif rowcounter MOD 2> class="formAltRow"</cfif>>
				<td scope="row">#costCat#&nbsp; #reportStruct[costCat & '_costCatDesc']#</td>
				<!--- FMS: Contractor Obligations --->
				<td align="right" nowrap>#numberformat(reportStruct[costCat & '_contractorFinal'],"$9,999")#</td>
				<cfif reportStruct[costCat & '_contractorFinal'] neq ''>
					<cfset contractorFinalTotal = contractorFinalTotal + reportStruct[costCat & '_contractorFinal']>
					<cfif costCat neq 'B1'>
						<cfset contractorFinalTotal_ops = contractorFinalTotal_ops + reportStruct[costCat & '_contractorFinal']>
					</cfif>
				</cfif>

				<!--- Cumulative FOP Total --->
				<td align="right" nowrap>#numberformat(reportStruct[costCat & '_budgetAuth'],"$9,999")#</td>
				<cfif reportStruct[costCat & '_budgetAuth'] neq ''>
					<cfset budgetAuthTotal = budgetAuthTotal + reportStruct[costCat & '_budgetAuth']>
					<cfif costCat neq 'B1'>
						<cfset budgetAuthTotal_ops = budgetAuthTotal_ops + reportStruct[costCat & '_budgetAuth']>
					</cfif>
				</cfif>

				<!--- FMS / FOP Variance (form version 3 and later) --->
				<cfif reportStruct.hidFormVersion gte 3>
					<td align="right" nowrap>#numberformat(reportStruct[costCat & '_FMSFOPvariance'],"$9,999")#</td>
					<cfif reportStruct[costCat & '_FMSFOPvariance'] neq ''>
						<cfset FMSFOPvarianceTotal = FMSFOPvarianceTotal + reportStruct[costCat & '_FMSFOPvariance']>
						<cfif costCat neq 'B1'>
							<cfset FMSFOPvarianceTotal_ops = FMSFOPvarianceTotal_ops + reportStruct[costCat & '_FMSFOPvariance']>
						</cfif>
					</cfif>

				</cfif>
				<!--- FOP Change Amount --->
				<td align="right" nowrap>#numberformat(reportStruct[costCat & '_fopChangeAmount'],"$9,999")#</td>
				<cfif reportStruct[costCat & '_fopChangeAmount'] neq ''>
					<cfset fopChangeAmountTotal = fopChangeAmountTotal + reportStruct[costCat & '_fopChangeAmount']>
					<cfif costCat neq 'B1'>
						<cfset fopChangeAmountTotal_ops = fopChangeAmountTotal_ops + reportStruct[costCat & '_fopChangeAmount']>
					</cfif>
				</cfif>

				<!--- FOPportunity / Rollover --->
				<td align="right" nowrap>#numberformat(reportStruct[costCat & '_rollover'],"$9,999")#</td>
				<cfif reportStruct[costCat & '_rollover'] neq ''>
					<cfset rolloverTotal = rolloverTotal + reportStruct[costCat & '_rollover']>
					<cfif costCat neq 'B1'>
						<cfset rolloverTotal_ops = rolloverTotal_ops + reportStruct[costCat & '_rollover']>
					</cfif>
				</cfif>

				<!--- National Office Adjustment --->
				<td align="right" nowrap>#numberformat(reportStruct[costCat & '_hqAdjustment'],"$9,999")#</td>
				<cfif reportStruct[costCat & '_hqAdjustment'] neq ''>
					<cfset hqAdjustmentTotal = hqAdjustmentTotal + reportStruct[costCat & '_hqAdjustment']>
					<cfif costCat neq 'B1'>
						<cfset hqAdjustmentTotal_ops = hqAdjustmentTotal_ops + reportStruct[costCat & '_hqAdjustment']>
					</cfif>
				</cfif>

			</tr>
			</cfoutput>
			<cfset rowcounter = rowcounter + 1>
		</cfloop>

		<!--- SECTION 1: TOTALS --->
		<cfoutput>
		<tr><td colspan="#colCount_sect1#" class="hrule"></td></tr>
		<tr <cfif rowcounter MOD 2> class="formAltRow"</cfif>>
			<td scope="row" align="right">Operations</td>
			<td align="right">#numberformat(contractorFinalTotal_ops,"$9,999")#</td>
			<td align="right">#numberformat(budgetAuthTotal_ops,"$9,999")#</td>
			<cfif reportStruct.hidFormVersion gte 3>
				<td align="right">#numberformat(FMSFOPvarianceTotal_ops,"$9,999")#</td>
			</cfif>
			<td align="right">#numberformat(fopChangeAmountTotal_ops,"$9,999")#</td>
			<td align="right">#numberformat(rolloverTotal_ops,"$9,999")#</td>
			<td align="right">#numberformat(hqAdjustmentTotal_ops,"$9,999")#</td>
		</tr>
		<tr <cfif rowcounter MOD 2> class="formAltRow"</cfif>>
			<td scope="row" align="right" style="font-weight:bold">Total</td>
			<td align="right">#numberformat(contractorFinalTotal,"$9,999")#</td>
			<td align="right">#numberformat(budgetAuthTotal,"$9,999")#</td>
			<cfif reportStruct.hidFormVersion gte 3>
				<td align="right">#numberformat(FMSFOPvarianceTotal,"$9,999")#</td>
			</cfif>
			<td align="right">#numberformat(fopChangeAmountTotal,"$9,999")#</td>
			<td align="right">#numberformat(rolloverTotal,"$9,999")#</td>
			<td align="right">#numberformat(hqAdjustmentTotal,"$9,999")#</td>
		</tr>
		<tr>
			<td colspan="#colCount_sect1#"><img src="#application.paths.images#clear.gif" height="2" width="1" alt="" /></td>
		</tr>
		</cfoutput>
		</table>

		<!--- SECTION 2: ESTIMATED COST PROFILE CHANGES --->
		<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl">
		<tr>
			<td colspan="4">CONTRACT VALUE CHANGES</td>
		</tr>
		<tr valign="bottom">
			<cfoutput>
			<th nowrap scope="col" style="text-align:center">Cost Category</th>
			<th scope="col" style="text-align:center">Final Contractor<br />Obligations</th>
			<th scope="col" style="text-align:center">Cumulative<br>Estimated Cost</th>
			<cfif reportStruct.hidFormVersion gte 3><th scope="col" style="text-align:center">Variance</th></cfif>
			<th scope="col" style="text-align:center">Estimated Cost<br>Adjustment</th>
			</cfoutput>
		</tr>

		<cfset rowCounter = 0>
		<cfset showECPFOPkey = false> <!--- show legend for alert icon? --->
		<cfloop list="#reportStruct.hidContractTypes#" index="costCat">
			<tr <cfif rowcounter MOD 2> class="formAltRow"</cfif>>
				<cfoutput>
				<td width="*">#costCat# &nbsp; #reportStruct[costCat & '_costCatDesc']#</td>
				<td width="15%" align="right">#numberformat(reportStruct[costCat & '_contractorFinal'],"$9,999")#</td>
				<td width="15%" align="right">#numberformat(reportStruct[costCat & '_cumulativeECP'],"$9,999")#</td>
				<cfif reportStruct.hidFormVersion gte 3>
					<td width="15%" align="right">#numberformat(reportStruct[costCat & '_FMSECPvariance'],"$9,999")#</td>
				</cfif>
				<td width="15%" align="right">#numberformat(reportStruct[costCat & '_ECPadjustment'],"$9,999")#</td>
				</cfoutput>
			</tr>
			<cfset rowCounter = rowCounter + 1>
		</cfloop>
		<tr>
			<cfoutput>
			<td colspan="4"><img src="#application.paths.images#clear.gif" height="2" width="1" alt="" /></td>
			</cfoutput>
		</tr>
		</table>


		<table width="100%">
		<tr valign="top">

			<td align="left">
				<!--- SECTION 3: ontract Funding Totals (from Mods) - new section with form version 3 --->
				<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl" style="width:365px">
				<tr>
					<td colspan="4">CONTRACT FUNDING TOTALS (from Mods)</td>
				</tr>
				<tr valign="bottom">
					<cfoutput>
					<th nowrap scope="col">Cost Category</th>
					<th scope="col" style="text-align:center">Cumulative<br />FOP Total</th>
					<th scope="col" style="text-align:center">Cumulative Funding<br>Through Mod <cfif reportStruct.hidModNum neq "">#reportStruct.hidModNum#<cfelse>(N/A)</cfif></th>
					<th scope="col" style="text-align:center">Variance</th>
					</cfoutput>
				</tr>
				<cfif reportStruct.hidModNum neq "">
					<cfset rowCounter = 0>
					<cfset ModFundingTotal = 0>
					<cfset ModFundingTotal_ops = 0>
					<cfset FOPModVarianceTotal = 0>
					<cfset FOPModVarianceTotal_ops = 0>

					<cfloop list="#reportStruct.hidCostCategories#" index="costCat">
						<tr <cfif rowcounter MOD 2> class="formAltRow"</cfif>>
							<cfoutput>
							<td>#costCat#</td>
							<td align="right">#numberformat(reportStruct[costCat & '_budgetAuth'],"$9,999")#</td>
							<td align="right">#numberformat(reportStruct[costCat & '_modFunding'],"$9,999")#</td>
							<td align="right">#numberformat(reportStruct[costCat & '_FOPMODvariance'],"$9,999")#</td>
							</cfoutput>
							<cfset ModFundingTotal = ModFundingTotal + reportStruct[costCat & '_modFunding']>
							<cfif costCat neq 'B1'>
								<cfset ModFundingTotal_ops = ModFundingTotal_ops + reportStruct[costCat & '_modFunding']>
							</cfif>
							<cfset FOPModVarianceTotal = FOPModVarianceTotal + reportStruct[costCat & '_FOPMODvariance']>
							<cfif costCat neq 'B1'>
								<cfset FOPModVarianceTotal_ops = FOPModVarianceTotal_ops + reportStruct[costCat & '_FOPMODvariance']>
							</cfif>
						</tr>
						<cfset rowCounter = rowCounter + 1>
					</cfloop>

					<!--- SECTION 3: TOTALS --->
					<cfoutput>
					<tr><td colspan="#colCount_sect1#" class="hrule"></td></tr>
					<tr>
						<td scope="row" align="right">Operations</td>
						<td align="right">#numberformat(budgetAuthTotal_ops,"$9,999")#</td>
						<td align="right">#numberformat(ModFundingTotal_ops,"$9,999")#</td>
						<td align="right">#numberformat(FOPModVarianceTotal_ops,"$9,999")#</td>
					</tr>
					<tr>
						<td scope="row" align="right" style="font-weight:bold">Total</td>
						<td align="right">#numberformat(budgetAuthTotal,"$9,999")#</td>
						<td align="right">#numberformat(ModFundingTotal,"$9,999")#</td>
						<td align="right">#numberformat(FOPModVarianceTotal,"$9,999")#</td>
					</tr>
					</cfoutput>
				<cfelse>
					<tr>
						<td colspan="4" align="center"><br><br><br>No contract mod funding information available for this close-out.<br><br><br></td>
					</tr>
				</cfif>
				</table>

			</td>

			<td align="right">

				<!--- SECTION 4: FUNDING (DOLAR$/NCFMS) CHANGES NEEDED --->
				<table border="0" cellpadding="0" cellspacing="0" class="form1DataTbl" style="width:385px">
				<tr>
					<td colspan="5">CONTRACT FUNDING RECONCILED TO FINAL CONTRACTOR COSTS</td>
				</tr>
				<cfoutput>
				<tr valign="bottom">
					<th colspan="2"></th>
					<th scope="col" style="text-align:center">OPS Account</th>
					<th scope="col" style="text-align:center">CRA Account</th>
					<th scope="col" style="text-align:center">Total</th>
				</tr>
				<tr valign="top" class="formAltRow">
					<td>a.</td>
					<td>Cumulative Contractor Obligations</td>
					<td align="right">#numberformat(contractorFinalTotal_ops,"$9,999")#</td>
					<td align="right">#numberformat(evaluate(contractorFinalTotal-contractorFinalTotal_ops),"$9,999")#</td>
					<td align="right">#numberformat(contractorFinalTotal,"$9,999")#</td>
				</tr>
				<tr valign="top">
					<td>b.</td>
					<td>Current Contract Funding</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingOPSTotal,"$9,999")#</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingCRATotal,"$9,999")#</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingTotal,"$9,999")#</td>
				</tr>
				<tr valign="top">
					<td></td>
					<td>(1) Active Funds</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingOPSActive,"$9,999")#</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingCRAActive,"$9,999")#</td>
					<td></td>
				</tr>
				<tr valign="top">
					<td></td>
					<td>(2) Expired Funds</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingOPSExpired,"$9,999")#</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingCRAExpired,"$9,999")#</td>
					<td></td>
				</tr>
				<tr valign="top" class="formAltRow">
					<td>c.</td>
					<td>Indicated Funding Changes (a-b)</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingChangeOPSTotal,"$9,999")#</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingChangeCRATotal,"$9,999")#</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingChangeTotal,"$9,999")#</td>
				</tr>
				<tr valign="top" class="formAltRow">
					<td></td>
					<td>(1) Active Funds</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingChangeOPSActive,"$9,999")#</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingChangeCRAActive,"$9,999")#</td>
					<td></td>
				</tr>
				<tr valign="top" class="formAltRow">
					<td></td>
					<td>(2) Expired Funds (Lapses)</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingChangeOPSExpired,"$9,999")#</td>
					<td align="right">#numberformat(reportStruct.txtFootFundingChangeCRAExpired,"$9,999")#</td>
					<td></td>
				</tr>
				</cfoutput>
				</table>

			</td>
		</tr>
		<tr>
			<cfoutput>
			<td><img src="#application.paths.images#clear.gif" height="2" width="1" alt="" vspace="2"/></td>
			</cfoutput>
		</tr>
		</table>

		<cfif len(reportStruct.txtComments)>
			<table class="form1DataTbl" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td>COMMENTS</td>
			</tr>
			<tr>
				<td><cfoutput>#replace(reportStruct.txtComments, chr(13), "<BR>", "all")#</cfoutput></td>
			</tr>
			</table>
		</cfif>

	</div>
		<!-- End Content Area -->
	</td>
</tr>
</table>
</body>
</html>

