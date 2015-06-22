<cfsilent>
<!---
page: aapp_closeout.cfm

description: Year End Closeout Informatoin

revisions:
18-01-2007	rroser	add total line to listing
19-01-2007	rroser	add comments field
2007-02-08	mstein	fix spelling errors
2007-03-27	mstein	formatting changes for Release 1.1
					added report button
2010-12-14	mstein	Release 2.7 - added pop-up message about deactivation of some automatic features
2011-03-31	mstein	Major updates for Release 2.8 - see specs for details
--->

<cfset request.pageID = "430" />
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->
<cfparam name="form.hidAction" default="">


<cfif form.hidAction is "save"> <!--- Finalizing Close Out --->
	<!--- Save the data and send to yearend summary page --->
	<cfinvoke component="#application.paths.components#aapp_yearend" method="saveCloseoutData" formData="#form#" returnvariable="stcResults">
		<cfif stcResults.success>
			<cflocation url="aapp_yearend_summary.cfm?aapp=#url.aapp#&closeOutId=#stcResults.closeOutId#&save=1" />
		</cfif>

<cfelseif form.hidAction is "calc">
	<!--- recalculate the fields, and show page again --->
		<cfinvoke component="#application.paths.components#aapp_yearend" method="calculateCloseOutAmounts" closeOutStruct="#form#" returnvariable="form">

<cfelseif form.hidAction is "">
	<!--- first time viewing form (could be existing closeout, or pending) - read data from database, set up form fields --->

	<!--- get close out data --->
	<cfinvoke component="#application.paths.components#aapp_yearend" aapp="#url.aapp#" closeOutId="#url.closeOutId#" method="getCloseOutData" returnvariable="stcCloseOutData">

	<cfquery name="qryContractTypes" dbtype="query">
	select	costCatCode
	from	stcCloseOutData.rstFOPRecords
	where	cumulativeECP <> 0
	order	by costCatCode
	</cfquery>

	<!--- populate form fields --->
	<cfset form.hidCostCategories = valueList(stcCloseOutData.rstFOPRecords.costCatCode) />
	<cfset form.hidContractTypes = valuelist(qryContractTypes.costCatCode) />
	<cfset form.hidReportingDate = stcCloseOutData.rstFOPRecords.reportingDate />

	<cfset form.hidModNum = stcCloseOutData.mod_num>
	<cfset form.hqTakeBack_ops = stcCloseOutData.hqOPStakeback />
	<cfset form.hqtakeBack_cra = stcCloseOutData.hqCRAtakeback />
	<cfset form.txtComments = stcCloseOutData.comments />
	<cfset form.hidCloseoutDate = stcCloseOutData.closeOutDate />
	<cfset form.hidFormVersion = stcCloseOutData.formVersion />

	<cfset form.txtFootFundingOPSTotal = stcCloseOutData.foot_funding_ops_total />
	<cfset form.txtFootFundingCRATotal = stcCloseOutData.foot_funding_cra_total>
	<cfset form.txtFootFundingTotal = stcCloseOutData.foot_funding_total>
	<cfset form.txtFootFundingOPSActive = stcCloseOutData.foot_funding_ops_active>
	<cfset form.txtFootFundingCRAActive = stcCloseOutData.foot_funding_cra_active>
	<cfset form.txtFootFundingOPSExpired = stcCloseOutData.foot_funding_ops_expired>
	<cfset form.txtFootFundingCRAExpired = stcCloseOutData.foot_funding_cra_expired>

	<cfset form.txtFootFundingChangeOPSTotal = stcCloseOutData.foot_funding_change_ops_total>
	<cfset form.txtFootFundingChangeCRATotal = stcCloseOutData.foot_funding_change_cra_total>
	<cfset form.txtFootFundingChangeTotal = stcCloseOutData.foot_funding_change_total>
	<cfset form.txtFootFundingChangeOPSActive = stcCloseOutData.foot_funding_change_ops_active>
	<cfset form.txtFootFundingChangeCRAActive = stcCloseOutData.foot_funding_change_cra_active>
	<cfset form.txtFootFundingChangeOPSExpired = stcCloseOutData.foot_funding_change_ops_expired>
	<cfset form.txtFootFundingChangeCRAExpired = stcCloseOutData.foot_funding_change_cra_expired>

	<cfloop query="stcCloseOutData.rstFOPRecords">
		<cfset form[costcatCode & "_costCatDesc"] = costCatDesc />
		<cfset form[costcatCode & "_contractorFinal"] = contractorFinal />
		<cfset form["hid_" & costcatCode & "_contractorFinal"] = contractorFinal />
		<cfset form[costcatCode & "_budgetAuth"] = budgetAuth />
		<cfset form[costcatCode & "_FMSFOPvariance"] = FMSFOPvariance />
		<cfset form[costcatCode & "_fopChangeAmount"] = fopChangeAmount />
		<cfset form[costcatCode & "_rollover"] = rollover />
		<cfset form[costcatCode & "_hqAdjustment"] = hqAdjustment />
		<cfset form[costcatCode & "_cumulativeECP"] = cumulativeECP />
		<cfset form[costcatCode & "_ECPFOPvariance"] = ECPFOPvariance />
		<cfset form[costcatCode & "_ECPadjustment"] = ECPadjustment />
		<cfset form[costcatCode & "_FMSECPvariance"] = FMSECPvariance />
		<cfset form[costcatCode & "_modFunding"] = modFunding />
		<cfset form[costcatCode & "_FOPMODvariance"] = FOPMODvariance />
	</cfloop>

		<cfif url.closeOutId eq 0> <!--- if closeout is pending --->
			<cfset hidMode = 'edit'>
			<!--- send form struct to component to calculate... form gets returned with calculated fields populated --->
				<cfinvoke component="#application.paths.components#aapp_yearend" method="calculateCloseOutAmounts" closeOutStruct="#form#" returnvariable="form">
		<cfelse>
			<cfset hidMode = 'readonly'>
			<cfset request.pageID = "431" />
		</cfif>
</cfif>

</cfsilent>

<!---
<cfdump var="#stcCloseOutData#">
<cfdump var="#form#">
<cfabort>
--->



<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">
<cfoutput>

<cfif form.hidAction is ""><!--- first time viewing form --->

	<cfif hidMode eq "readonly" and hidFormVersion eq 2> <!--- already executed close-out from version 2 --->
		// close-out was executed under JFAS 2.7, where FOP and adjustment amounts in the close-out record
		// were not necessarily created in the database.
		var msgTempAlert = 'Amounts displayed in this close-out record do not necessarily reflect actual adjustments.\n' +
						   'Please refer to the FOP report, and Estimated Cost Profile for an accurate record of close-out activities.';
		alert(msgTempAlert);
	</cfif>
</cfif>

<cfif hidMode neq "readonly"> <!--- none of these functions are necessary in read-only mode --->

	// array of cost category prefixes, and column types (for text fields) - helps with dynamic looping below
	var arrCostCats = new Array(#listQualify(form.hidCostCategories,"'")#);
	var arrContractTypes = new Array(#listQualify(form.hidContractTypes,"'")#);
	var arrColumnTypes_forTotal = new Array('contractorFinal','fopChangeAmount','rollover','hqAdjustment');
	var arrColumnTypes_forChangeCheck = new Array('contractorFinal','fopChangeAmount','rollover','hqAdjustment');
	var arrColumnTypes_forDisable = new Array('FMSFOPvariance','fopChangeAmount','rollover','hqAdjustment','FMSECPvariance','ECPadjustment');
	var bolShowFMSChangePrompt = 0;

	function FMSDataChange(form)
	{
		//if user changes values in contractor ob fields,

		//  give them warning message (only once per page load)
		if (!bolShowFMSChangePrompt)
			{
			var msgAlert = 'Changing the Contractor Obligation amounts (FMS 2110), requires that you recalculate the entire form before finalizing.\n' +
						   'All changes that you have made to FOP, Rollover, or Estimated Cost Profile adjustments will be lost.';
			alert(msgAlert);
			bolShowFMSChangePrompt = 1;
			}

		// loop through column types, and cost cat prefixes, to disable and zero out boxes
		for (var i = 0; i < arrColumnTypes_forDisable.length; i++)
			for (var j = 0; j < arrCostCats.length; j++)
				{
				tmpFieldName = arrCostCats[j] + '_' + arrColumnTypes_forDisable[i];
				if (form[tmpFieldName]) // field with this name exists
					{
					form[tmpFieldName].value=0;
					form[tmpFieldName].className = "inputReadonly";
					}
				}

		// disable Finalize button,
		form.hidAction.value = 'calc';
		form.btnSubmit.disabled = 1;
		form.btnSubmit.className = 'btnDisabled';
		// disable report button
		document.frmReportCriteria.btnGenerateReport.disabled = 1;
		document.frmReportCriteria.btnGenerateReport.className = 'btnDisabled';
		// enable Recalc Button
		form.btnRecalc.disabled = 0;
	}



	function recalcForm(form)
	{
		recalcThis = 1;
		tmpMessage = 'If you recalculate the form, all changes that you have made to FOP, Rollover, or Estimated Cost Profile adjustments will be lost.\n'+
					 'Are you sure you want to continue?';

		if(!bolShowFMSChangePrompt) // don't show this message, if they've already seen the one from FMSDataChange()
			if (!confirm(tmpMessage))
				recalcThis = 0;

		if (recalcThis)
			{
			form.hidAction.value = 'calc';
			form.submit();
			}
	}


	function calcFormHQAdjustment(form)
	{
		// calculates values in HQ (National Office) Adjustment Column
		// will always be equal to  0 - (FOP change + rollover)
		for (var counter = 0; counter < arrCostCats.length; counter++)
			{
			tempTotal = parseInt(stripCharsInBag(form[arrCostCats[counter]+'_fopChangeAmount'].value,',')) + parseInt(stripCharsInBag(form[arrCostCats[counter]+'_rollover'].value,','));
			form[arrCostCats[counter]+'_hqAdjustment'].value = commaFormat(Math.round(0 - tempTotal));
			}
	}


	function calcFormTotals(form)
	{
		// loop through column types, and cost cat prefixes, to calculate and set totals for each column
		for (var i = 0; i < arrColumnTypes_forTotal.length; i++)
			{
			tmpTotal = 0;
			tmpTotal_ops = 0;
			for (var j = 0; j < arrCostCats.length; j++)
				{
				tmpFieldName = arrCostCats[j] + '_' + arrColumnTypes_forTotal[i];
				tmpFieldValue = parseInt(stripCharsInBag(form[tmpFieldName].value,','));
				tmpTotal += tmpFieldValue; // accumulate total
				if (tmpFieldName.indexOf('B1')==-1) // ignore B1 for OPS total
					tmpTotal_ops += tmpFieldValue;
				}
			//assign total to appropriate total fields
			form[arrColumnTypes_forTotal[i] + 'Total'].value = commaFormat(Math.round(tmpTotal));
			form[arrColumnTypes_forTotal[i] + 'Total_ops'].value = commaFormat(Math.round(tmpTotal_ops));
			}

		// hardcoded - may remove in future release
		form.hqTakeBack_ops.value = form.hqAdjustmentTotal_ops.value;
		form.hqTakeBack_cra.value = form.B1_hqAdjustment.value;
	}


	function fieldCheckandFormat(formField)
	{
		//function to validate number entry, based on column, and format with commas

		// strip out commas
		fieldValue = stripCharsInBag(formField.value,',');

		//get cost category
		fieldCostCat = formField.name.split("_")[0];

		if (isNaN(fieldValue))
			formField.value = 0; //if not a vliad number, then zero it out.
		else
			{
			// reformat field with commas, so user can see it formatted correctly when validation messages show
			formField.value = commaFormat(Math.round(fieldValue));

			// if contractor obligation, must be positive integer
			if (formField.name.indexOf('_contractorFinal')!=-1)
				if (fieldValue < 0)
					{
					alert('Final Contractor Obligations amount can not be negative.');
					formField.value = 0;
					}
			// if FOP change amount, must be between zero and FMS/FOP variance
			if (formField.name.indexOf('_fopChangeAmount')!=-1)
				if ((fieldValue > 0) || (fieldValue < parseInt(stripCharsInBag(formField.form[fieldCostCat + "_FMSFOPvariance"].value,','))))
					{
					alert('FOP Amount must be between 0 and the amount in the Variance Column.');
					formField.value = 0;
					}
			// if rollover amount, must be between zero and (zero - FOP change amount)
			if (formField.name.indexOf('_rollover')!=-1)
				if ((fieldValue < 0) || (fieldValue > (0 - parseInt(stripCharsInBag(formField.form[fieldCostCat + "_fopChangeAmount"].value,',')))))
					{
					alert('FOPportunity rollover amount must be positive, and can not be greater in magnitude than the FOP Change amount.');
					formField.value = 0;
					}
			// if ECP Adjustment amount, must be between zero and FMS/ECP variance
			if (formField.name.indexOf('_ECPadjustment')!=-1)
				if ((fieldValue > 0) || (fieldValue < parseInt(stripCharsInBag(formField.form[fieldCostCat + "_FMSECPvariance"].value,','))))
					{
					alert('Estaimted Cost Adjustment Amount must be between 0 and the amount in the Variance Column.');
					formField.value = 0;
					}
			}

	}


	function formValid(form)
	{
		// form validation: runs this function before submittal
		trimFormTextFields(form);
		strErrors = '';
		FMSchanged = 0; //user has modified FMS amounts
		FOPchanged = 0; //user has changed FOP amounts
		ECPchanged = 0; // user has changed ECP amounts
		FOPMODvariances = 0; // differences between FOP and MOD totals
		FOPnonzero = 0; // will an FOP result from this close-out?

		// if form being submitted for recalculation, no validation required (based on current reqmts)
		if (form.hidAction.value == 'save')
			{

			/* introduced in JFAS 2.8, but not enforced yet
			<cfif form.hidModNum neq ""> <!--- only do this check if mod funding data was available --->
				// check for any variances between FOP and Mod Funding, in any cost cat
				for (var counter = 0; counter < arrCostCats.length; counter++)
						if(stripCharsInBag(form[arrCostCats[counter]+'_FOPMODvariance'].value, ",") != 0)
							FOPMODvariances++;
			</cfif>
			*/

			if (FOPMODvariances) // any variances between MODs and FOPs? If so, form can not be submitted (don't continue with other validation)
				strErrors = strErrors + '   - There are variances between the Cumulative FOP Amounts, and the Funding shown on the latest Mod.\n' +
										'      This issue must be corrected (outside of this form) before close-out can be executed.';

			else // if there are no FOP/MOD variances, then continue with other validation
				{
				// comments are required if user changed any values. if comments exist, no need to run these validations
				if (form.txtComments.value == '') //are comments entered?
					{
					// if not, then need to check if anything changed
					// loop through FMS Obligations
					for (var counter = 0; counter < arrCostCats.length; counter++)
						if(stripCharsInBag(form[arrCostCats[counter]+'_contractorFinal'].value, ",") != form['hid_'+arrCostCats[counter]+'_contractorFinal'].value)
							FMSchanged++;

					//loop through FOP column - check for negative amount (must be from user action)
					for (var counter = 0; counter < arrCostCats.length; counter++)
						if(stripCharsInBag(form[arrCostCats[counter]+'_fopChangeAmount'].value, ",") < 0)
							FOPchanged++;

					// loop through ECP column - check for negative amount (must be from user action)
					for (var counter = 0; counter < arrContractTypes.length; counter++)
						if(stripCharsInBag(form[arrContractTypes[counter]+'_ECPadjustment'].value, ",") < 0)
							ECPchanged++;

					// check for issues, build validation message
					if (FMSchanged)
						strErrors = strErrors + '   - Contractor Obligation Amounts (FMS) have been modified - comments required.\n';
					if (FOPchanged)
						strErrors = strErrors + '   - FOP Amounts have been modified - comments required.\n';
					if (ECPchanged)
						strErrors = strErrors + '   - Estimated Cost Adjustment Amounts have been modified - comments required.\n';
					}
				}

			// loop through FOP column - check for any non-zero amounts (FOP will be created)
			for (var counter = 0; counter < arrCostCats.length; counter++)
				if(stripCharsInBag(form[arrCostCats[counter]+'_fopChangeAmount'].value, ",") != 0)
					FOPnonzero++;

			if (strErrors != '') // there are validation messages
				{
				alert('The following issues exist. Please correct these before finalizing the close-out.\n\n' + strErrors + '\n');
				return false;
				}
			else // no issues, allow submission (prompt about no FOP creation, if applicable)
				{
				if (!FOPnonzero)
					if (confirm('No FOPs will be created as a result of this close-out, are you sure you would like to continue?'))
						return true;
				else
					return false;
				}
			}
		else // user is doing recalculation - always allow submission
			return true;

	}
</cfif> <!--- read-only mode? --->

function genCloseoutReport()
	{
		tmpAction = document.frmCloseOut.action;
		tmpOnSubmit = document.frmCloseOut.onSubmit;
		tmpTarget = document.frmCloseOut.target;

		<cfoutput>
		document.frmCloseOut.action="#application.paths.reportdir#reports.cfm?rpt_id=14";
		document.frmCloseOut.onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');";
		document.frmCloseOut.target="reports";
		document.frmCloseOut.submit();
		</cfoutput>

		document.frmCloseOut.action = tmpAction;
		document.frmCloseOut.onSubmit = tmpOnSubmit;
		document.frmCloseOut.target = tmpTarget;

	}
</cfoutput>
</script>

<!--- <cf_etaspellcheck action="javascript"> --->

<div class="ctrSubContent">
<h2>Expired Contract Close-out</h2>
<cfoutput>
<form name="frmReportCriteria">
<div class="btnRight">
<input name="btnGenerateReport" type="button" value="Print Close-out Report" onClick="genCloseoutReport();" />
</div>
</form>
<table width="100%">
<tr valign="bottom">
	<td>
		<h3>
		Contract Year End Date: #dateformat(request.dateend, "mm/dd/yyyy")#<br />
		FMS Reporting Date: #dateformat(form.hidReportingDate, "mm/dd/yyyy")#
		</h3>
	</td>
	<td align="right">
		<h3>
		<cfif url.closeOutId eq 0>
			Current Date:
		<cfelse>
			Close-out Executed:
		</cfif>
		#dateformat(form.hidCloseoutDate, "mm/dd/yyyy")#
		</h3>
	</td>
</tr>
</table>
</cfoutput>



	<h3>AAPP/FOP RECONCILED TO FINAL CONTRACTOR COSTS</h3>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<form name="frmCloseOut" action="<cfoutput>#cgi.SCRIPT_NAME#?aapp=#url.aapp#&closeOutId=#url.closeOutId#</cfoutput>" method="post" onSubmit="return formValid(this);" />
	<tr>
		<cfoutput>
		<th scope="col" style="text-align:center">Cost<br>Category</th>
		<th scope="col" style="text-align:center">Final Contractor<br>Obligations</th>
		<th scope="col" style="text-align:center">Cumulative<br>FOP Total</th>
		<cfif form.hidFormVersion gte 3><th scope="col" style="text-align:center">Variance</th></cfif>
		<th scope="col" style="text-align:center">FOP Change<br>(AAPP #request.aapp#)</th>
		<th scope="col" style="text-align:center">FOPportunity<br>(AAPP #request.succaappnum#)</th>
		<th scope="col" style="text-align:center">National Office<br>Adjustment</th>
		</cfoutput>
	</tr>
	<cfoutput>
		<cfset rowcounter = 1>
		<cfset colCount_sect1 = iif(form.hidFormVersion gte 3,de("7"),de("6"))>
		<cfset totalSpacer = iif(form.hidFormVersion gte 3,de("&nbsp;"),de("&nbsp;&nbsp;&nbsp;&nbsp;"))>
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

		<cfloop list="#form.hidCostCategories#" index="costCat">
			<tr <cfif rowcounter MOD 2> class="AltRow"</cfif>>
				<td scope="row" align="center">
					<label for="#costCat#">#costCat#</label>
					<input type="hidden" name="#costCat#_costCatDesc" value="#form[costCat & '_costCatDesc']#" />
				</td>

				<!--- Contractor OB (FMS) --->
				<td align="center" nowrap>
					<input type="text" style="text-align:right" id="#costCat#" name="#costCat#_contractorFinal"
					<cfif form[costCat & '_contractorFinal'] neq ''>
						value="#numberformat(form[costCat & '_contractorFinal'])#"
					<cfelse>
						value="0"
					</cfif>
					size="12"
					onchange="FMSDataChange(this.form);fieldCheckandFormat(this);calcFormTotals(this.form);"
					tabindex="#request.nextTabIndex#"
					<cfif url.closeOutId neq 0> readonly class="inputReadonly"</cfif> />
					<input type="hidden" name="hid_#costCat#_contractorFinal"
					<cfif form['hid_' & costCat & '_contractorFinal'] neq ''>
						value="#form['hid_' & costCat & '_contractorFinal']#"
					<cfelse>
						value="0"
					</cfif>
					/>
					<cfif form[costCat & '_contractorFinal'] neq ''>
						<cfset contractorFinalTotal = contractorFinalTotal + form[costCat & '_contractorFinal']>
						<cfif costCat neq 'B1'>
							<cfset contractorFinalTotal_ops = contractorFinalTotal_ops + form[costCat & '_contractorFinal']>
						</cfif>
					</cfif>
					<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</td>

				<!--- Cumulative FOP Total --->
				<td align="center" nowrap>
					<input type="text" style="text-align:right" name="#costCat#_budgetAuth"
					value="#numberformat(form[costCat & '_budgetAuth'])#" size="12" readonly class="inputReadonly" />
					<cfif form[costCat & '_budgetAuth'] neq ''>
						<cfset budgetAuthTotal = budgetAuthTotal + form[costCat & '_budgetAuth']>
						<cfif costCat neq 'B1'>
							<cfset budgetAuthTotal_ops = budgetAuthTotal_ops + form[costCat & '_budgetAuth']>
						</cfif>
					</cfif>
				</td>

				<!--- FMS / FOP Variance (form version 3 and later) --->
				<cfif form.hidFormVersion gte 3>
					<td align="center" nowrap>
						<input type="text" style="text-align:right" name="#costCat#_FMSFOPvariance"
						value="#numberformat(form[costCat & '_FMSFOPvariance'])#" size="12" readonly class="inputReadonly" />
						<cfif form[costCat & '_FMSFOPvariance'] neq ''>
							<cfset FMSFOPvarianceTotal = FMSFOPvarianceTotal + form[costCat & '_FMSFOPvariance']>
							<cfif costCat neq 'B1'>
								<cfset FMSFOPvarianceTotal_ops = FMSFOPvarianceTotal_ops + form[costCat & '_FMSFOPvariance']>
							</cfif>
						</cfif>
					</td>
				</cfif>

				<!--- FOP Change Amount --->
				<!--- even in edit mode, if value is 0 or greater, field is not editable --->
				<td align="center" nowrap>
					<input type="text" style="text-align:right" name="#costCat#_fopChangeAmount"
					value="#numberformat(form[costCat & '_fopChangeAmount'])#" size="12"
					onChange="fieldCheckandFormat(this);calcFormHQAdjustment(this.form);calcFormTotals(this.form);"
					<cfif hidMode eq "readonly" or (form[costCat & '_FMSFOPvariance'] gte 0) or costCat eq "B1">
						readonly class="inputReadonly"
					</cfif> />
					<cfif form[costCat & '_fopChangeAmount'] neq ''>
						<cfset fopChangeAmountTotal = fopChangeAmountTotal + form[costCat & '_fopChangeAmount']>
						<cfif costCat neq 'B1'>
							<cfset fopChangeAmountTotal_ops = fopChangeAmountTotal_ops + form[costCat & '_fopChangeAmount']>
						</cfif>
					</cfif>
				</td>

				<!--- FOPportunity / Rollover --->
				<!--- will only display for B2 --->
				<!--- will only be editable if under-run in those categories --->
				<td align="center" nowrap>
				<cfif (listFind('B2', costCat)) or (listFind('B1',costCat) and form.hidFormVersion lt 3)>
					<input type="text" style="text-align:right" name="#costCat#_rollover"
					value="#numberformat(form[costCat & '_rollover'])#" size="12"
					onChange="fieldCheckandFormat(this);calcFormHQAdjustment(this.form);calcFormTotals(this.form);"
					<cfif hidMode eq "readonly" or form[costCat & '_FMSFOPvariance'] GTE 0>
						readonly class="inputReadonly"
					</cfif>
					/>
					<cfif form[costCat & '_rollover'] neq ''>
						<cfset rolloverTotal = rolloverTotal + form[costCat & '_rollover']>
						<cfif costCat neq 'B1'>
							<cfset rolloverTotal_ops = rolloverTotal_ops + form[costCat & '_rollover']>
						</cfif>
					</cfif>
				<cfelse>
					<input type="hidden" name="#costCat#_rollover" value="#numberformat(form[costCat & '_rollover'])#" />
				</cfif>
				</td>

				<!--- National Office Adjustment --->
				<td align="center" nowrap>
					<input type="text" style="text-align:right" name="#costCat#_hqAdjustment"
					value="#numberformat(form[costCat & '_hqAdjustment'])#" size="12" readonly class="inputReadonly" />
					<cfif form[costCat & '_hqAdjustment'] neq ''>
						<cfset hqAdjustmentTotal = hqAdjustmentTotal + form[costCat & '_hqAdjustment']>
						<cfif costCat neq 'B1'>
							<cfset hqAdjustmentTotal_ops = hqAdjustmentTotal_ops + form[costCat & '_hqAdjustment']>
						</cfif>
					</cfif>
				</td>
			</tr>
		<cfset rowcounter = rowcounter + 1>
		</cfloop>
			<tr <cfif rowcounter MOD 2> class="AltRow"</cfif>>
				<td scope="row" align="center">
					Operations
				</td>
				<td align="center">
					<input type="text" style="text-align:right;border:0;" name="contractorFinalTotal_ops"
					value="#numberformat(contractorFinalTotal_ops)#" size="12" readonly class="inputReadonly" />
				</td>
				<td align="center">
					<input type="text" style="text-align:right;border:0;" name="budgetAuthTotal_ops"
					value="#numberformat(budgetAuthTotal_ops)#" size="12" readonly class="inputReadonly" />
				</td>
				<cfif form.hidFormVersion gte 3>
					<td align="center">
						<input type="text" style="text-align:right;border:0;" name="FMSFOPvarianceTotal_ops"
						value="#numberformat(FMSFOPvarianceTotal_ops)#" size="12" readonly class="inputReadonly" />
					</td>
				</cfif>
				<td align="center">
					<input type="text" style="text-align:right;border:0;" name="fopChangeAmountTotal_ops"
					value="#numberformat(fopChangeAmountTotal_ops)#" size="12" readonly class="inputReadonly" />
				</td>
				<td align="center">
					<input type="text" style="text-align:right;border:0;" name="rolloverTotal_ops"
					value="#numberformat(rolloverTotal_ops)#" size="12" readonly class="inputReadonly" />
				</td>
				<td align="center">
					<input type="text" style="text-align:right;border:0;" name="hqAdjustmentTotal_ops"
					value="#numberformat(hqAdjustmentTotal_ops)#" size="12" readonly class="inputReadonly" />
				</td>
			</tr>
			<tr <cfif rowcounter MOD 2> class="AltRow"</cfif>>
				<td scope="row" align="center" style="font-weight:bold">
					Total
				</td>
				<td align="center">
					<input type="text" style="text-align:right;border:0;" name="contractorFinalTotal"
					value="#numberformat(contractorFinalTotal)#" size="12" readonly class="inputReadonly" />
				</td>
				<td align="center">
					<input type="text" style="text-align:right;border:0;" name="budgetAuthTotal"
					value="#numberformat(budgetAuthTotal)#" size="12" readonly class="inputReadonly" />
				</td>
				<cfif form.hidFormVersion gte 3>
					<td align="center">
						<input type="text" style="text-align:right;border:0;" name="FMSFOPvarianceTotal"
						value="#numberformat(FMSFOPvarianceTotal)#" size="12" readonly class="inputReadonly" />
					</td>
				</cfif>
				<td align="center">
					<input type="text" style="text-align:right;border:0;" name="fopChangeAmountTotal"
					value="#numberformat(fopChangeAmountTotal)#" size="12" readonly class="inputReadonly" />
				</td>
				<td align="center">
					<input type="text" style="text-align:right;border:0;" name="rolloverTotal"
					value="#numberformat(rolloverTotal)#" size="12" readonly class="inputReadonly" />
				</td>
				<td align="center">
					<input type="text" style="text-align:right;border:0;" name="hqAdjustmentTotal"
					value="#numberformat(hqAdjustmentTotal)#" size="12" readonly class="inputReadonly" />
				</td>
			</tr>
			<tr>
				<td colspan="#colCount_sect1#"><img src="#application.paths.images#clear.gif" height="2" width="1" alt="" /></td>
			</tr>
			<tr>
				<td colspan="#evaluate(colCount_sect1-1)#" align="right">
					National HQ Contingency Adjustment: &nbsp;Operations&nbsp;
				</td>
				<td align="center">
					<input type="text" name="hqTakeBack_ops" style="text-align:right" size="14"
					readonly class="inputReadonly" value="#numberformat(form.hqTakeBack_ops)#" />
				</td>
			</tr>
			<tr>
				<td colspan="#evaluate(colCount_sect1-1)#" align="right">
					Construction/Rehabilitation&nbsp;
				</td>
				<td align="center">
					<input type="text" name="hqTakeBack_cra" size="14" style="text-align:right"
					readonly class="inputReadonly" value="#numberformat(form.hqTakeBack_cra)#"  />
				</td>
			</tr>
	</cfoutput>
	</table>




	<p></p>
	<h3>CONTRACT VALUE CHANGES</h3>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<tr>
		<th width="*" scope="col" style="text-align:center">Cost Category</th>
		<th width="17%" scope="col" style="text-align:center">Final Contractor<br />Obligations</th>
		<th width="17%" scope="col" style="text-align:center">Cumulative<br />Estimated Cost</th>
		<cfif form.hidFormVersion gte 3><th width="17%" scope="col" style="text-align:center">Variance</th></cfif>
		<th width="17%" scope="col" style="text-align:center">Estimated Cost Adjustment</th>
	</tr>
	<cfset rowCounter = 0>
	<cfset showECPFOPkey = false> <!--- show legend for alert icon? --->
	<cfloop list="#form.hidContractTypes#" index="costCat">
		<tr <cfif rowcounter MOD 2> class="AltRow"</cfif>>
			<cfoutput>
			<td>#costCat# &nbsp; #form[costCat & '_costCatDesc']#</td>
			<td align="right">
				<input type="text" style="text-align:right" id="#costCat#_contractorFinal_a" name="#costCat#_contractorDUPFinal"
					<cfif form[costCat & '_contractorFinal'] neq ''>
						value="#numberformat(form[costCat & '_contractorFinal'])#"
					<cfelse>
						value="0"
					</cfif>
					size="12"  readonly class="inputReadonly"/>
					<label for="#costCat#_contractorFinal_a" class="hiddenLabel">Cost Cat #costCat# Contractor Obs</label>
			</td>
			<td align="right">
				<cfif hidMode neq 'readonly' and form[costCat & '_ECPFOPvariance'] neq 0>
					<img src="#application.paths.images#alert_icon.gif" width="12" height="11"
					alt="Cumulative FOP amount differs from ECP by $#(numberformat(abs(form[costCat & '_ECPFOPvariance'])))#">
					<cfset showECPFOPkey = true>
				</cfif>
				<input type="text" style="text-align:right" id="#costCat#_cumulativeECP" name="#costCat#_cumulativeECP"
					<cfif form[costCat & '_cumulativeECP'] neq ''>
						value="#numberformat(form[costCat & '_cumulativeECP'])#"
					<cfelse>
						value="0"
					</cfif>
					size="12"  readonly class="inputReadonly"/>
					<label for="#costCat#_cumulativeECP" class="hiddenLabel">Cost Cat #costCat# Cum ECP</label>
					<input type="hidden" name="#costCat#_ECPFOPvariance" value="#form[costCat & '_ECPFOPvariance']#">
			</td>
			<cfif form.hidFormVersion gte 3>
				<td align="right">
					<input type="text" style="text-align:right" id="#costCat#_FMSECPvariance" name="#costCat#_FMSECPvariance"
						<cfif form[costCat & '_FMSECPvariance'] neq ''>
							value="#numberformat(form[costCat & '_FMSECPvariance'])#"
						<cfelse>
							value="0"
						</cfif>
						size="12"  readonly class="inputReadonly" />
						<label for="#costCat#_FMSECPvariance" class="hiddenLabel">Cost Cat #costCat# FMS/ECP Variance</label>
				</td>
			</cfif>
			<td align="right">
				<input type="text" style="text-align:right" id="#costCat#_ECPadjustment" name="#costCat#_ECPadjustment"
					<cfif form[costCat & '_ECPadjustment'] neq ''>
						value="#numberformat(form[costCat & '_ECPadjustment'])#"
					<cfelse>
						value="0"
					</cfif>
					size="12"
					onChange="fieldCheckandFormat(this);"
					<cfif hidMode eq "readonly" or form[costCat & '_FMSECPvariance'] GTE 0>
						readonly class="inputReadonly"
					</cfif>
					/>
					<label for="#costCat#_ECPadjustment" class="hiddenLabel">Cost Cat #costCat# ECP Adjustment</label>
			</td>
			</cfoutput>
		</tr>
		<cfset rowCounter = rowCounter + 1>
	</cfloop>
	<cfif showECPFOPkey> <!--- if there was a variance between FOP and ECP, show legend --->
		<tr>
			<cfoutput>
			<td colspan="5">
			<img src="#application.paths.images#alert_icon.gif" width="12" height="11" alt="Does not match with FOP amount: $34,206,630">
			<span style="font-size:x-small;">&nbsp;indicates variance between cumulative FOP, and Estimated Cost Profile. Roll over icon for more details.</span>
			</td>
			</cfoutput>
		</tr>
	</cfif>
	</table>



	<!--- Contract Funding Totals (from Mods) - new section with form version 3 --->
	<cfif form.hidFormVersion gte 3>
		<p></p>
		<h3>CONTRACT FUNDING TOTALS (from Mods)</h3>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
		<tr>
			<cfoutput>
			<th width="*" scope="col" style="text-align:center">Cost Category</th>
			<th width="17%" scope="col" style="text-align:center">Cumulative<br>FOP Total</th>
			<th width="17%" scope="col" style="text-align:center">Cumulative Funding<br>Through Mod <cfif form.hidModNum neq "">#form.hidModNum#<cfelse>(N/A)</cfif></th>
			<th width="17%" scope="col" style="text-align:center">Variance</th>
			</cfoutput>
		</tr>
		<cfset rowCounter = 0>
		<cfset ModFundingTotal = 0>
		<cfset ModFundingTotal_ops = 0>
		<cfset FOPModVarianceTotal = 0>
		<cfset FOPModVarianceTotal_ops = 0>
		<cfloop list="#form.hidCostCategories#" index="costCat">
			<tr <cfif rowcounter MOD 2> class="AltRow"</cfif>>
				<cfoutput>
				<td>#costCat# &nbsp; #form[costCat & '_costCatDesc']#</td>
				<td align="right">
					<input type="text" style="text-align:right" id="#costCat#__budgetDUPAuth" name="#costCat#__budgetDUPAuth"
						<cfif form[costCat & '_budgetAuth'] neq ''>
							value="#numberformat(form[costCat & '_budgetAuth'])#"
						<cfelse>
							value="0"
						</cfif>
						size="12"  readonly class="inputReadonly"/>
						<label for="#costCat#_budgetAuth_a" class="hiddenLabel">Cost Cat #costCat# Cumulative FOP</label>
				</td>
				<td align="right">
					<input type="text" style="text-align:right" id="#costCat#_modFunding" name="#costCat#_modFunding"
						<cfif form[costCat & '_modFunding'] neq ''>
							value="#numberformat(form[costCat & '_modFunding'])#"
						<cfelse>
							value=""
						</cfif>
						size="12"  readonly class="inputReadonly"/>
						<label for="#costCat#_modFunding" class="hiddenLabel">Cost Cat #costCat# Mod Funding</label>
						<cfif form.hidModNum neq "">
							<cfset ModFundingTotal = ModFundingTotal + form[costCat & '_modFunding']>
							<cfif costCat neq 'B1'>
								<cfset ModFundingTotal_ops = ModFundingTotal_ops + form[costCat & '_modFunding']>
							</cfif>
						</cfif>
				</td>
				<td align="right">
					<input type="text" style="text-align:right" id="#costCat#_FOPMODvariance" name="#costCat#_FOPMODvariance"
						<cfif form[costCat & '_FOPMODvariance'] neq ''>
							value="#numberformat(form[costCat & '_FOPMODvariance'])#"
						<cfelse>
							value=""
						</cfif>
						size="12"  readonly class="inputReadonly"
						<cfif form[costCat & '_FOPMODvariance'] neq 0 and form[costCat & '_FOPMODvariance'] neq "">style="background-color:##FFB6C1;"</cfif>/>
						<label for="#costCat#_FOPMODvariance" class="hiddenLabel">Cost Cat #costCat# FOP/MOD Variance</label>
						<cfif form.hidModNum neq "">
							<cfset FOPModVarianceTotal = FOPModVarianceTotal + form[costCat & '_FOPMODvariance']>
							<cfif costCat neq 'B1'>
								<cfset FOPModVarianceTotal_ops = FOPModVarianceTotal_ops + form[costCat & '_FOPMODvariance']>
							</cfif>
						</cfif>
				</td>
				</cfoutput>
			</tr>
			<cfset rowCounter = rowCounter + 1>
		</cfloop>

		<cfoutput>
		<tr>
			<td scope="row">
				Operations
			</td>
			<td align="right">
				<input type="text" style="text-align:right;border:0;" name="budgetAuthTotal_ops_a"
				value="#numberformat(budgetAuthTotal_ops)#" size="12" readonly class="inputReadonly" />
			</td>
			<td align="right">
				<input type="text" style="text-align:right;border:0;" name="ModFundingTotal_ops"
				value="#numberformat(ModFundingTotal_ops)#" size="12" readonly class="inputReadonly" />
			</td>
			<td align="right">
				<input type="text" style="text-align:right;border:0;" name="FOPModVarianceTotal_ops"
				value="#numberformat(FOPModVarianceTotal_ops)#" size="12" readonly class="inputReadonly" />
			</td>
		</tr>
		<tr>
			<td scope="row" style="font-weight:bold">
				Total
			</td>
			<td align="right">
				<input type="text" style="text-align:right;border:0;" name="budgetAuthTotal_a"
				value="#numberformat(budgetAuthTotal)#" size="12" readonly class="inputReadonly" />
			</td>
			<td align="right">
				<input type="text" style="text-align:right;border:0;" name="ModFundingTotal"
				value="#numberformat(ModFundingTotal)#" size="12" readonly class="inputReadonly" />
			</td>
			<td align="right">
				<input type="text" style="text-align:right;border:0;" name="FOPModVarianceTotal"
				value="#numberformat(FOPModVarianceTotal)#" size="12" readonly class="inputReadonly" />
			</td>
		</tr>
		</cfoutput>

		</table>
	</cfif>




	<p></p>
	<h3>CONTRACT FUNDING RECONCILED TO FINAL CONTRACTOR COSTS</h3>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<tr>
		<th width="5%" scope="col"></th>
		<th width="*" scope="col"></th>
		<th width="17%" scope="col" style="text-align:center">OPS Account</th>
		<th width="17%" scope="col" style="text-align:center">CRA Account</th>
		<th width="17%" scope="col" style="text-align:center">Total</th>
	</tr>
	<cfoutput>
	<tr class="AltRow">
		<td>a.</td>
		<td>Cumulative Contractor Obligations</td>
		<td align="right">
			<input type="text" style="text-align:right" id="contractorFinalTotal_ops_a" name="contractorFinalTotal_ops_a"
			value="#numberformat(contractorFinalTotal_ops)#" size="14"  readonly class="inputReadonly"/>
			<label for="contractorFinalTotal_ops_a" class="hiddenLabel">Current OPS Costs</label>
		</td>
		<td align="right">
			<input type="text" style="text-align:right" id="contractorFinalTotal_cra_a" name="contractorFinalTotal_cra_a"
			value="#numberformat(evaluate(contractorFinalTotal-contractorFinalTotal_ops))#" size="14"  readonly class="inputReadonly"/>
			<label for="contractorFinalTotal_cra_a" class="hiddenLabel">Current CRA Obligations</label>
		</td>
		<td align="right">
			<input type="text" style="text-align:right" id="contractorFinalTotal_a" name="contractorFinalTotal_a"
			value="#numberformat(contractorFinalTotal)#" size="14"  readonly class="inputReadonly"/>
			<label for="contractorFinalTotal_a" class="hiddenLabel">Current Total Costs</label>
		</td>
	</tr>
	<tr>
		<td>b.</td>
		<td>Current Contract Funding</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingOPSTotal" name="txtFootFundingOPSTotal"
			value="#numberformat(form.txtFootFundingOPSTotal)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingOPSTotal" class="hiddenLabel">Current OPS Obligations</label>
		</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingCRATotal" name="txtFootFundingCRATotal"
			value="#numberformat(form.txtFootFundingCRATotal)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingCRATotal" class="hiddenLabel">Current CRA Obligations</label>
		</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingTotal" name="txtFootFundingTotal"
			value="#numberformat(form.txtFootFundingTotal)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingTotal" class="hiddenLabel">Current Obligations</label>
		</td>
	</tr>
	<tr>
		<td></td>
		<td>(1) Active Funds</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingOPSActive" name="txtFootFundingOPSActive"
			value="#numberformat(form.txtFootFundingOPSActive)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingOPSActive" class="hiddenLabel">Current Active OPS Obligations</label>
		</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingCRAActive" name="txtFootFundingCRAActive"
			value="#numberformat(form.txtFootFundingCRAActive)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingCRAActive" class="hiddenLabel">Current Active CRA Obligations</label>
		</td>
		<td></td>
	</tr>
	<tr>
		<td></td>
		<td>(2) Expired Funds</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingOPSExpired" name="txtFootFundingOPSExpired"
			value="#numberformat(form.txtFootFundingOPSExpired)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingOPSExpired" class="hiddenLabel">Current Expired OPS Obligations</label>
		</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingCRAExpired" name="txtFootFundingCRAExpired"
			value="#numberformat(form.txtFootFundingCRAExpired)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingCRAExpired" class="hiddenLabel">Current Expired CRA Obligations</label>
		</td>
		<td></td>
	</tr>

	<tr class="AltRow">
		<td>c.</td>
		<td>Indicated Funding Changes (a-b)</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingChangeOPSTotal" name="txtFootFundingChangeOPSTotal"
			value="#numberformat(form.txtFootFundingChangeOPSTotal)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingChangeOPSTotal" class="hiddenLabel">Current Change OPS Obligations</label>
		</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingChangeCRATotal" name="txtFootFundingChangeCRATotal"
			value="#numberformat(form.txtFootFundingChangeCRATotal)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingChangeCRATotal" class="hiddenLabel">Current Change CRA Obligations</label>
		</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingChangeTotal" name="txtFootFundingChangeTotal"
			value="#numberformat(form.txtFootFundingChangeTotal)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingChangeTotal" class="hiddenLabel">Current Change Obligations</label>
		</td>
	</tr>
	<tr class="AltRow">
		<td></td>
		<td>(1) Active Funds</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingChangeOPSActive" name="txtFootFundingChangeOPSActive"
			value="#numberformat(form.txtFootFundingChangeOPSActive)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingChangeOPSActive" class="hiddenLabel">Current Change Active OPS Obligations</label>
		</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingChangeCRAActive" name="txtFootFundingChangeCRAActive"
			value="#numberformat(form.txtFootFundingChangeCRAActive)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingChangeCRAActive" class="hiddenLabel">Current Change Active CRA Obligations</label>
		</td>
		<td></td>
	</tr>
	<tr class="AltRow">
		<td></td>
		<td>(2) Expired Funds</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingChangeOPSExpired" name="txtFootFundingChangeOPSExpired"
			value="#numberformat(form.txtFootFundingChangeOPSExpired)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingChangeOPSExpired" class="hiddenLabel">Current Change Expired OPS Obligations</label>
		</td>
		<td align="right">
			<input type="text" style="text-align:right" id="idFootFundingChangeCRAExpired" name="txtFootFundingChangeCRAExpired"
			value="#numberformat(form.txtFootFundingChangeCRAExpired)#" size="14"  readonly class="inputReadonly"/>
			<label for="idFootFundingChangeCRAExpired" class="hiddenLabel">Current Expired CRA Obligations</label>
		</td>
		<td></td>
	</tr>
	</cfoutput>
	<tr><td colspan="5" class="hrule"></td></tr>
	</table>

	<p></p>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<cfoutput>
	<tr valign="top">
		<td width="35%" align="right"><label for="idComments">Comments</label>&nbsp;</td>
		<td width="*">
			<textarea name="txtComments" rows="7" cols="80" id="idComments" wrap="soft" tabindex="#request.nextTabIndex#"
			<cfif hidMode eq 'readonly'>readonly class="inputReadonly"</cfif>
			onKeyDown="textCounter(this, 4000);" onKeyUp="textCounter(this, 4000);">#form.txtComments#</textarea>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		<td width="5%">
			<cfoutput>
			<a href="javascript:resizeTextArea(document.frmCloseOut.txtComments, 7, 0);">
			<img src="#application.paths.images#sizetext_min.gif" alt="Minimize Text Field" width="13" height="12" vspace="2" border="0"></a><br>
			<a href="javascript:resizeTextArea(document.frmCloseOut.txtComments, 7, 1);">
			<img src="#application.paths.images#sizetext_max.gif" alt="Maximize Text Field" width="13" height="12" vspace="2" border="0"></a><br>
			<img src="#application.paths.images#clear.gif" alt="" width="13" height="24"><br>
			<!--- temporarily hiding - tag missing from server
			<cfif hidMode neq "readonly">
				<cf_etaspellcheck action="spellcheckbutton" type="image" imageSrc="#application.paths.images#spellcheck.gif" name="spellcheck"
				formName="frmCloseOut" fieldName="txtComments" checkTextboxes="No">
			</cfif>
			--->
			</cfoutput>
		</td>
	</tr>
	</cfoutput>
	</table>

	<cfif hidMode neq "readonly"><!--- don't show buttons if it's already closed out --->
		<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<cfoutput>
		<tr>
			<td>
				<div class="buttons" style="text-align:left">
				<input type="hidden" name="hidAction" value="save" />
				<input type="button" name="btnRecalc" value="Recalculate Form Data" onClick="recalcForm(this.form);" tabindex="#request.nextTabindex#"/>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</div>
			</td>
			<td>
				<div class="buttons">
				<input name="btnSubmit" type="submit" value="Execute Close Out" tabindex="#request.nextTabindex#"/>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				<input name="btnClear" type="button" value="Reset" onclick="javascript:window.location='#cgi.SCRIPT_NAME#?aapp=#url.aapp#&closeoutId=#url.closeoutID#'"  tabindex="#request.nextTabindex#"/>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='aapp_yearend_summary.cfm?aapp=#url.aapp#'"  tabindex="#request.nextTabindex#"/>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</div>
			</td>
		</tr>
		</cfoutput>
		</table>
	</cfif>
	<cfoutput>
	<input type="hidden" name="hidAAPP" value="#url.AAPP#" />
	<input type="hidden" name="hidSuccAAPP" value="#request.succaappnum#" />
	<input type="hidden" name="closeoutId" value="#url.closeoutid#" />
	<input type="hidden" name="radReportFormat" value="application/pdf" />
	<input type="hidden" name="hidFormVersion" value="#form.hidFormVersion#" />
	<input type="hidden" name="hidCostCategories" value="#form.hidCostCategories#" />
	<input type="hidden" name="hidContractTypes" value="#form.hidContractTypes#" />
	<input type="hidden" name="hidReportingDate" value="#form.hidReportingDate#" />
	<input type="hidden" name="hidCloseoutDate" value="#form.hidCloseoutDate#" />
	<input type="hidden" name="hidModNum" value="#form.hidModNum#" />
	</cfoutput>
</form>
</div>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />