<cfsilent>
<!---
page: aapp_xactn_details.cfm

description: displays read-only details of transaction

revisions:
2011-07-07	mstein	page created
--->
<cfset request.pageID = "363" />
<cfparam name="url.footprintID" default="0">
<cfparam name="variables.lstErrorMessages" default="">
<cfset transVendor = "CITIBANK">
<cfset arraTAFS = "0182">

<cfif isDefined("form.hidAAPPNum")> <!--- form submitted: add transaction--->


	<!--- save form data --->
	<cfinvoke component="#application.paths.components#footprint" method="saveXactnData" formData="#form#" returnvariable="stcXactnResults" />

	<cfif stcXactnResults.success>
		<!--- if save was successful, then redirect read-only version of this xactn --->
		<cflocation url="aapp_foot_details.cfm?aapp=#url.aapp#&footprintID=#stcXactnResults.footprintID#&newXactnID=#stcXactnResults.xactnID#" />
	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfset variables.lstErrorMessages = stcXactnResults.errorMessages />
	</cfif>

<cfelse> <!--- first time viewing form --->

	<cfset form.txtXactnDate = "">
	<cfset form.txtAmount = "">
	<cfset form.txtModNum = "">
	<cfset form.txtDescription = "">
	<cfset form.txtInvoiceNum = "">

	<cfif url.footprintID neq 0> <!--- user is adding xactn from footprint page, so need to gather information for pre-fill --->
		<!--- retrieve data from database --->
		<cfinvoke component="#application.paths.components#footprint" method="getFootprintDetails" returnvariable="stcFootprintDetails" footprintID = "#url.footprintID#">

		<cfset form.radFundCat = stcFootprintDetails.footInfo.fundCat>
		<cfset form.cboDocType = stcFootprintDetails.footInfo.docType>
		<cfset form.cboDocFY = stcFootprintDetails.footInfo.docFY>
		<cfset form.txtDocNum = stcFootprintDetails.footInfo.docNum>
		<cfset form.txtVendorName = stcFootprintDetails.footInfo.vendorName>
		<cfset form.txtVendorID = stcFootprintDetails.footInfo.vendorID>
		<cfset form.cboFundingOffice = stcFootprintDetails.footInfo.fundingOfficeNum>
		<cfset form.hidAccountID = stcFootprintDetails.footInfo.accountID>
			<cfset form.cboAccountID_agencyID = mid(stcFootprintDetails.footInfo.accountID,1,2)>
			<cfset form.cboAccountID_fundCode = mid(stcFootprintDetails.footInfo.accountID,3,10)>
			<cfset form.cboAccountID_budgetYear = mid(stcFootprintDetails.footInfo.accountID,13,4)>
			<cfset form.cboAccountID_programCode = mid(stcFootprintDetails.footInfo.accountID,17,10)>
			<cfset form.cboAccountID_activity = mid(stcFootprintDetails.footInfo.accountID,27,6)>
			<cfset form.cboAccountID_stratGoal = mid(stcFootprintDetails.footInfo.accountID,33,5)>
			<cfset form.cboAccountID_fundingOrg = mid(stcFootprintDetails.footInfo.accountID,38,6)>
			<cfset form.cboAccountID_activity = mid(stcFootprintDetails.footInfo.accountID,27,6)>
			<cfset form.cboAccountID_mngUnit = mid(stcFootprintDetails.footInfo.accountID,44,6)>
		<cfset form.cboCostCenter = stcFootprintDetails.footInfo.costCenter>
		<cfset form.cboObjectClass = stcFootprintDetails.footInfo.objectClass>

	</cfif>

	<cfif url.footprintID eq 0 or stcFootprintDetails.footInfo.recordCount eq 0>

		<!--- get managing unit, based on AAPP fuding office --->

		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#request.fundingOfficeNum#" returnvariable="rstFundingOffice_mu">

		<cfset form.radFundCat = "OPS">
		<cfset form.cboDocType = "">
		<cfset form.cboDocFY = "">
		<cfset form.txtDocNum = request.contractNum>
		<cfset form.txtVendorName = "">
		<cfset form.txtVendorID = "">
		<cfset form.cboFundingOffice = request.fundingOfficeNum>
		<cfset form.hidAccountID = "">
			<cfset form.cboAccountID_agencyID = 26>
			<cfset form.cboAccountID_fundCode = "">
			<cfset form.cboAccountID_budgetYear = "">
			<cfset form.cboAccountID_programCode = "">
			<cfset form.cboAccountID_activity = "">
			<cfset form.cboAccountID_stratGoal = "">
			<cfset form.cboAccountID_fundingOrg = "">
			<cfset form.cboAccountID_activity = "">
			<cfset form.cboAccountID_mngUnit = rstFundingOffice_mu.managingUnit>
		<cfset form.cboCostCenter = "">
		<cfset form.cboObjectClass = "">

	</cfif>




</cfif>

<!--- retrieve contents of drop-down lists --->
<cfinvoke component="#application.paths.components#lookup" method="getFundCats" returnvariable="rstFundCats">
<cfinvoke component="#application.paths.components#footprint" method="getDocTypes" filter="allowImport" returnvariable="rstDocTypes">
<cfinvoke component="#application.paths.components#lookup" method="getNCFMSTransTypes" usedOnly="1" returnvariable="rstXactnTypes">
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeTypeNot="FED" returnvariable="rstFundingOffices">
<cfinvoke component="#application.paths.components#footprint" method="getAgencyIDs" returnvariable="lstAgencyIDs">
<cfinvoke component="#application.paths.components#footprint" method="getFundCodes" returnvariable="rstFundCodes">
<cfinvoke component="#application.paths.components#footprint" method="getProgramCodes" returnvariable="rstProgramcodes">
<cfinvoke component="#application.paths.components#footprint" method="getActivityCodes" returnvariable="rstActivityCodes">
<cfinvoke component="#application.paths.components#footprint" method="getStrategicGoals" returnvariable="rstStrategicGoals">
<cfinvoke component="#application.paths.components#footprint" method="getFundingOrgs" returnvariable="rstFundingOrgs">
<cfinvoke component="#application.paths.components#footprint" method="getManagingUnits" returnvariable="rstManagingUnits">
<cfinvoke component="#application.paths.components#footprint" method="getCostCenters" returnvariable="rstCostCenters">
<cfinvoke component="#application.paths.components#footprint" method="getObjectClasses" returnvariable="rstObjectClasses">
<cfset currentFY = application.outility.getYear_byDate(yearType="F" )>

<!--- get system settings for migration, transaction upload dates --->
<cfset mnlxactnStartDate = application.outility.getSystemSetting(systemSettingCode="mnlxactn_start")>
<cfset mnlxactnEndDate = application.outility.getSystemSetting(systemSettingCode="mnlxactn_end")>
<!--- get ARRA, and Transportation AAPP nums to use for validation --->
<cfinvoke component="#application.paths.components#lookup" method="getAAPPRef" refType="NOTRANS" returnvariable="docref_noTrans">
<cfinvoke component="#application.paths.components#lookup" method="getAAPPRef" refType="ARRA_NO_CRA" returnvariable="docref_noArraCRA">
<cfinvoke component="#application.paths.components#lookup" method="getAAPPRef" refType="ARRA_NO_SE" returnvariable="docref_noArraSE">

<cfset yearRangeMin = "1991">
<cfset yearRangeMax = currentFY>

</cfsilent>



<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<script>
<cfoutput>
// define dates used in validation
dateContractStart = new Date('#dateformat(request.dateStart,"mm/dd/yyyy")#');
dateXacntUploadStart = new Date('#dateformat(mnlxactnStartDate,"mm/dd/yyyy")#');
dateXacntUploadEnd = new Date('#dateformat(mnlxactnEndDate,"mm/dd/yyyy")#');
</cfoutput>
// build array of fund  and program codes, to use whe updating drop-down lists
arrFundCodes = new Array(<cfoutput query="rstFundCodes">'#fundCat#~#arraInd#~#fundCode#'<cfif currentRow neq rstFundCodes.recordCount>,</cfif></cfoutput>);
arrProgramCodes = new Array(<cfoutput query="rstProgramCodes">'#fundCat#~#arraInd#~#programCode#'<cfif currentRow neq rstProgramCodes.recordCount>,</cfif></cfoutput>);
arrCostCenters = new Array(<cfoutput query="rstCostCenters">'#fundingOfficeNum#~#costCenterCode#~#costCenterDesc#'<cfif currentRow neq rstCostCenters.recordCount>,</cfif></cfoutput>);

function reloadCodes(form)
{
	/// occurs on page load, and when the user changes Fund Cat (OPS, CRA, S&E)
	// filters list of options in Fund and Program Code lists, based on those that are appropriate for the fund cat
	// will also list all ARRA codes at the bottom (independent of fund cat)

	//determine selected Fund Cat
	for (var i=0; i < form.radFundCat.length; i++)
			if (form.radFundCat[i].checked)
				tmpFundCat = form.radFundCat[i].value;

	// grab currently selected value in drop-down
	tmpFundSelectedItem = form.cboAccountID_fundCode.options[form.cboAccountID_fundCode.selectedIndex].value;
	tmpFundSelectIndex = 0;
	newFundListLength = 0;
	tmpProgramSelectedItem = form.cboAccountID_programCode.options[form.cboAccountID_programCode.selectedIndex].value;
	tmpProgramSelectIndex = 0;
	newProgramListLength = 0;

	// remove all items from current drop-down lists, put in list header
	form.cboAccountID_fundCode.length = 0;
	elOptNew = document.createElement('option');
	elOptNew.text = 'Fund Code';
	form.cboAccountID_fundCode.add(elOptNew);
	newFundListLength = 0;
	form.cboAccountID_programCode.length = 0;
	elOptNew = document.createElement('option');
	elOptNew.text = 'Program Code';
	form.cboAccountID_programCode.add(elOptNew);
	newProgramListLength = 0;

	// loop through fund code array, and rebuild list with all items that match Fund Cat, or ARRA
	for (var i=0; i < arrFundCodes.length; i++)
		{
		tmpCode = arrFundCodes[i].split('~');
		if ((tmpCode[0] == tmpFundCat) || (tmpCode[1] == 1)) // if fund cat is in the desc, or if arra flag is true
			{
			// add new item to the drop-down list
			var elOptNew = document.createElement('option');
  			elOptNew.text = tmpCode[2];
  			elOptNew.value = tmpCode[2];
			form.cboAccountID_fundCode.add(elOptNew);
			newFundListLength++;
			// if this value matches the one that was previously selected by the user, mark this option
			if (tmpCode[2] == tmpFundSelectedItem) tmpFundSelectIndex = newFundListLength;
			}
		}
	form.cboAccountID_fundCode.selectedIndex = tmpFundSelectIndex;

	// loop through program code array, and rebuild list with all items that match Fund Cat, or ARRA
	for (var i=0; i < arrProgramCodes.length; i++)
		{
		tmpCode = arrProgramCodes[i].split('~');
		if ((tmpCode[0] == tmpFundCat) || (tmpCode[1] == 1))
			{
			var elOptNew = document.createElement('option');
  			elOptNew.text = tmpCode[2];
  			elOptNew.value = tmpCode[2];
			form.cboAccountID_programCode.add(elOptNew);
			newProgramListLength++;
			if (tmpCode[2] == tmpProgramSelectedItem) tmpProgramSelectIndex = newProgramListLength;
			}
		}
	form.cboAccountID_programCode.selectedIndex = tmpProgramSelectIndex;
	reloadYears(form);
}


function reloadYears(form)
{
	<cfoutput>
	// occurs on page load, and when user changes anything that impacts Fund Code
	// list of years in Budget Year drop-down list should be range based on char 5-6, and 7-8 of fund code
	// does not apply to ARRA



	// get current selected value of BudgYear drop-down
	// grab currently selected value in drop-down
	tmpSelectedItem = form.cboAccountID_budgetYear.options[form.cboAccountID_budgetYear.selectedIndex].value;
	form.cboAccountID_budgetYear.selectedIndex = 0;
	tmpSelectIndex = 0;
	newListLength = 0;
	tmpFundCode = form.cboAccountID_fundCode.options[form.cboAccountID_fundCode.selectedIndex].value;

	// clear out all options, put in list header
	form.cboAccountID_budgetYear.length = 0;
	elOptNew = document.createElement('option');
	elOptNew.text = 'Budget Year';
	form.cboAccountID_budgetYear.add(elOptNew);

	// if Fund Code is selected, then set year ranges and loop through (if fund code is not selected, no years will show)
	if (tmpFundCode != '')
		{
		if (tmpFundCode.indexOf('#arraTAFS#') == -1)
			{
			tmpYearRangeMin = get4digitYear(1*tmpFundCode.substr(4,2));
			tmpYearRangeMax = get4digitYear(1*tmpFundCode.substr(6,2));
			}
		else
			{
			// set default start/end years. If not filtered below, then these will be used for list
			tmpYearRangeMin = #yearRangeMin#;
			tmpYearRangeMax = #yearRangeMax#;
			}

		// loop through range, add new options to drop-down list
		for (var i=tmpYearRangeMax; i >= tmpYearRangeMin; i--)
			{
			var elOptNew = document.createElement('option');
			elOptNew.text = i;
			elOptNew.value = i;
			form.cboAccountID_budgetYear.add(elOptNew);
			newListLength++;
			if (i == tmpSelectedItem) tmpSelectIndex = newListLength;
			}
		form.cboAccountID_budgetYear.selectedIndex = tmpSelectIndex;
		}
	</cfoutput>
}


function reloadCostCenters(form)
{
	<cfoutput>
	// occurs on page load, and when user changes the Funding Office dropd-won (this filters the Cost Center list)

	// get current selected value of CostCenter drop-down
	tmpSelectedItem = form.cboCostCenter.options[form.cboCostCenter.selectedIndex].value;
	form.cboCostCenter.selectedIndex = 0;
	tmpSelectIndex = 0;
	newListLength = 0;
	tmpFundingOffice = form.cboFundingOffice.options[form.cboFundingOffice.selectedIndex].value;

	// clear out all options, put in list header
	form.cboCostCenter.length = 0;
	elOptNew = document.createElement('option');
	elOptNew.text = 'Select Cost Center...';
	form.cboCostCenter.add(elOptNew);

	// if Fudning Office is selected, then loop through array of cost centers(if fund code is not selected, no years will show)
	if (tmpFundingOffice != '')
		{
		// loop through range, add new options to drop-down list
		for (var i=0; i < arrCostCenters.length; i++)
		{
		tmpCode = arrCostCenters[i].split('~');
		if (tmpCode[0] == tmpFundingOffice)
			{
			var elOptNew = document.createElement('option');
  			elOptNew.text = tmpCode[1] + ' - ' + tmpCode[2];
  			elOptNew.value = tmpCode[1];
			form.cboCostCenter.add(elOptNew);
			newListLength++;
			if (tmpCode[1] == tmpSelectedItem) tmpSelectIndex = newListLength;
			}
		}
		form.cboCostCenter.selectedIndex = tmpSelectIndex;
		}
	</cfoutput>
}



function testForEnter()
{
	if (event.keyCode == 13)
	{
		event.cancelBubble = true;
		event.returnValue = false;
         }
}

function vendorSearch(form)
{
	<cfoutput>
	urlString = '?vendornameSearch=' + form.txtVendorName.value + '&vendorIDSearch=' + form.txtVendorID.value;
	newWin = window.open("#application.urls.root#views/vendor_search.cfm"+urlString, "vendorSearch",'status=no,toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=no,width=425,height=400');
	</cfoutput>
}

<cfoutput>
function ValidateForm(form)
{
	strErrors= '';
	strWarnings = '';
	trimFormTextFields(form);	// trim text fields
	dateXactn = new Date(form.txtXactnDate.value);
	tmpVendorName = form.txtVendorName.value.toUpperCase();

	//grab fund cat value
	for (var i=0; i < form.radFundCat.length; i++)
			if (form.radFundCat[i].checked)
				myFundCat = form.radFundCat[i].value;

	// build account ID
	form.hidAccountID.value = form.cboAccountID_agencyID.value + form.cboAccountID_fundCode.value + form.cboAccountID_budgetYear.value +
			form.cboAccountID_programCode.value + form.cboAccountID_activity.value + form.cboAccountID_stratGoal.value +
			form.cboAccountID_fundingOrg.value + form.cboAccountID_mngUnit.value;

	// date must be entered, must be valid date later than contract start, and migration
	if (form.txtXactnDate.value == '')
		strErrors = strErrors + '   - Transaction Date must be entered.\n';
	else
		if (!Checkdate(form.txtXactnDate.value))
			strErrors = strErrors + '   - Transaction Date must be valid, and in the format "mm/dd/yyyy".\n';
		else
			if (dateXactn < dateContractStart)
				strErrors = strErrors + '   - Transaction Date can not be earlier than the contract start date.\n';
			else
				if (dateXactn < dateXacntUploadStart)
					strErrors = strErrors + '   - Transaction Date can not be earlier than the footprint migration date (#dateformat(mnlxactnStartDate,"mm/dd/yyyy")#).\n';
				else
					if (dateXactn <= dateXacntUploadEnd) // warning if date is within range of manual XLS upload
						strWarnings = strWarnings + '   - The Transaction Date you entered is within the range covered by the XLS upload. This transaction\n' +
													'     could be overwritten upon next upload.\n';

	// amount must be entered
	if (form.txtAmount.value == '')
		strErrors = strErrors + '   - Transaction Amount must be entered.\n';

	// mod number must be entered, and first digit must be numeric
	if (form.txtModNum.value != '')
		if (!isInteger(form.txtModNum.value.substring(0,1)))
			strErrors = strErrors + '   - Mod Number must start with a numeric value.\n';

	// All segments of Document ID must be entered
	if ((form.cboDocType.options[form.cboDocType.selectedIndex].value == '') ||
		(form.cboDocFY.options[form.cboDocFY.selectedIndex].value == '') ||
		(form.txtDocNum.value == ''))
		strErrors = strErrors + '   - All segments of the Document ID must be entered.\n';

	<cfif request.contractNum neq "">
		if (form.txtDocNum.value.toUpperCase() != '#request.contractNum#')
			strWarnings = strWarnings + '   - The Document Number entered does not match the contract number of this AAPP.\n';
	</cfif>

	// vendor name must be entered
	if (form.txtVendorName.value == '')
		strErrors = strErrors + '   - Vendor Name must be entered.\n';

	// vendor DUNS must be entered
	if (form.txtVendorID.value == '')
		strErrors = strErrors + '   - Vendor DUNS must be entered.\n';

	// Funding Office must be selected
	if (form.cboFundingOffice.options[form.cboFundingOffice.selectedIndex].value == '')
		strErrors = strErrors + '   - Funding Office must be selected.\n';

	// All segments of Account ID must be selected
	if ((form.cboAccountID_fundCode.options[form.cboAccountID_fundCode.selectedIndex].value == '') ||
		(form.cboAccountID_budgetYear.options[form.cboAccountID_budgetYear.selectedIndex].value == '') ||
		(form.cboAccountID_programCode.options[form.cboAccountID_programCode.selectedIndex].value == '') ||
		(form.cboAccountID_activity.options[form.cboAccountID_activity.selectedIndex].value == '') ||
		(form.cboAccountID_stratGoal.options[form.cboAccountID_stratGoal.selectedIndex].value == '') ||
		(form.cboAccountID_fundingOrg.options[form.cboAccountID_fundingOrg.selectedIndex].value == '') ||
		(form.cboAccountID_activity.options[form.cboAccountID_activity.selectedIndex].value == '') ||
		(form.cboAccountID_mngUnit.options[form.cboAccountID_mngUnit.selectedIndex].value == ''))

		strErrors = strErrors + '   - All segements of the Account ID must be selected.\n';
	else
		if (form.cboAccountID_fundCode.options[form.cboAccountID_fundCode.selectedIndex].value.substr(0,4) != form.cboAccountID_programCode.options[form.cboAccountID_programCode.selectedIndex].value.substr(0,4))
			strErrors = strErrors + '   - The Fund Code and the Program Code must have the same TAFS.\n';

	// Cost Center must be selected
	if (form.cboCostCenter.options[form.cboCostCenter.selectedIndex].value == '')
		strErrors = strErrors + '   - Cost Center must be selected.\n';

	// Object Class must be selected
	if (form.cboObjectClass.options[form.cboObjectClass.selectedIndex].value == '')
		strErrors = strErrors + '   - Object Class must be selected.\n';


	<cfif request.aapp neq docref_noArraSE>
		// give warning if S&E, ARRA, and this is NOT the Natl Office ARRA S&E AAPP
		if ((myFundCat == 'S/E') && (form.cboAccountID_fundCode.options[form.cboAccountID_fundCode.selectedIndex].value.substr(0,4) == '#arraTAFS#'))
			strWarnings = strWarnings + '   - Transactions of this type would normally be associated with the National Office ARRA S&E AAPP (#docref_noArraSE#).\n';
	</cfif>
	<cfif request.aapp neq docref_noArraCRA>
		// give warning if CRA, ARRA, and this is NOT the Natl Office ARRA CRA AAPP
		if ((myFundCat == 'CRA') && (form.cboAccountID_fundCode.options[form.cboAccountID_fundCode.selectedIndex].value.substr(0,4) == '#arraTAFS#'))
			strWarnings = strWarnings + '   - Transactions of this type would normally be associated with the National Office ARRA CRA AAPP (#docref_noArraCRA#).\n';
	</cfif>
	<cfif request.aapp neq docref_noTrans>
		// give warning if OPS, National Office, vendor = CITIBANK, and this is NOT the transportation AAPP
		if ((myFundCat == 'OPS') && (form.cboFundingOffice.options[form.cboFundingOffice.selectedIndex].value == '20') && (tmpVendorName.indexOf("#transVendor#") != -1))
			strWarnings = strWarnings + '   - Transactions of this type would normally be associated with the National Office Transportation AAPP (#docref_noTrans#).\n';
	</cfif>
	//docref_noTrans
	//docref_noArraCRA
	//docref_noArraSE

	if(strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before continuing.\n\n' + strErrors + '\n');
		return false;
		}
	else
		if (strWarnings != '')
			{
			if (confirm('The following warnings should be noted. Click "OK" to continue saving, or "Cancel"\nto return to the data entry form:\n\n' + strWarnings + '\n'))
				return true;
			else
				return false;
			}
		else
			return true;
}

</cfoutput>
</script>

<div class="ctrSubContent">
	<h2>Enter Transaction</h2>

	<!--- show error / confirmation messages --->
	<cfif listLen(variables.lstErrorMessages) gt 0>
		<div class="errorList">
		<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters="~">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div><br />
	</cfif>

	<table width="98%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<cfoutput>
	<form name="frmEnterXactn" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&footprintID=#url.footprintID#" method="post"
		onkeydown="testForEnter();" onSubmit="return ValidateForm(this);">
	<tr valign="top">
		<td width="14%">*Type:</td>
		<td width="*">
			<!--- currently, only obligation is allowed for entry, so options are hard-coded --->
			<input type="radio" name="radXactnType" value="OBL" id="idXactnType_OBL" checked tabindex="#request.nextTabIndex#">
			<label for="idXactnType_OBL">Obligation</label>&nbsp;&nbsp;&nbsp;

			<input type="radio" name="radXactnType" value="PAY" id="idXactnType_PAY" disabled tabindex="#request.nextTabIndex#">
			<label for="idXactnType_PAY">Payment</label>&nbsp;&nbsp;&nbsp;
			<input type="radio" name="radXactnType" value="CST" id="idXactnType_CST" disabled tabindex="#request.nextTabIndex#">
			<label for="idXactnType_CST">Cost</label>&nbsp;&nbsp;&nbsp;
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td><label for="idXactnDate">*Date:</label></td>
		<td>
			<input type="text" name="txtXactnDate" id="idXactnDate" tabindex="#request.nextTabIndex#" size="12" maxlength="10"
				value="#form.txtXactnDate#" class="datepicker" title="Select to specify transaction date" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td><label for="idAmount">*Amount:</label></td>
		<td>
			<input type="text" name="txtAmount" id="idAmount" tabindex="#request.nextTabIndex#" size="18" maxlength="14"
				value="#form.txtAmount#" onChange="this.value = currencyFormat(this.value);" style="text-align: right;">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td><label for="idModNum">Mod No.:</label></td>
		<td>
			<input type="text" name="txtModNum" id="idModNum" tabindex="#request.nextTabIndex#" size="10" maxlength="6"
				value="#form.txtModNum#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr valign="top">
		<td><label for="idDescription">Description:</label></td>
		<td>
			<textarea name="txtDescription" id="idDescription" cols="100" rows="2"
			onKeyDown="textCounter(this, 200);" onKeyUp="textCounter(this, 200);" tabindex="#request.nextTabIndex#">#form.txtDescription#</textarea>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td><label for="idInvoiceNum">Invoice No.:</label></td>
		<td>
			<!--- disabled for initial release --->
			<input type="text" name="txtInvoiceNum" id="idInvoiceNum" tabindex="#request.nextTabIndex#" size="18" maxlength="30" disabled class="inputReadonly">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr><td colspan="2" height="5"></td></tr>
	<tr><td colspan="2" class="hrule"></td></tr>
	<tr><td colspan="2" height="5"></td></tr>
	<tr valign="top">
		<td>*Fund Category:</td>
		<td>
			<cfloop query="rstFundCats">
			<input type="radio" name="radFundCat" value="#fundCat#" id="idFundCat_#fundCat#"
				<cfif fundCat eq form.radFundCat>checked</cfif> tabindex="#request.nextTabIndex#"
				onClick="reloadCodes(this.form);">
			<label for="idFundCat_#fundCat#">#fundCat#</label>&nbsp;&nbsp;&nbsp;
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</cfloop>
		</td>
	</tr>
	<tr>
		<td>*Document ID:</td>
		<td>
			<label for="idDocType" class="hiddenLabel">Doc Type</label>
			<select name="cboDocType" id="idDocType" tabindex="#request.nextTabIndex#">
				<option value="">Select Doc Type...</option>
				<cfloop query="rstDocTypes">
					<cfif sortOrder neq rstDocTypes.sortOrder[currentRow-1]>
						<option value="">------------------------</option>
					</cfif>
					<option value="#docType#" <cfif docType eq form.cboDocType>selected</cfif>>#docType# - #docTypeDesc#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>

			<!--- drop-down list of doc FY --->
			<!--- some older records will fall outside the normal range --->
			<!--- in which case this year is forced at the end of the list --->
			<label for="idDocFY" class="hiddenLabel">Doc Year</label>
			<select name="cboDocFY" id="idDocFY" tabindex="#request.nextTabIndex#">
				<option value="">Select FY...</option>
				<cfset yearFound = 0>
				<cfloop index="i" from="#yearRangeMax#" to="#yearRangeMin#" step="-1">
					<option value="#i#" <cfif i eq form.cboDocFY>selected<cfset yearFound = 1></cfif>>#right(i,2)#</option>
				</cfloop>
				<cfif not yearFound and form.cboDocFY neq ""> <!--- year of the footprint is not in list, add it, and select it --->
					<option value="#form.cboDocFY#" selected>#right(form.cboDocFY,2)#</option>
				</cfif>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>

			<label for="idDocNum" class="hiddenLabel">Doc Number</label>
			<input type="text" name="txtDocNum" id="idDocNum" value="#form.txtDocNum#" tabindex="#request.nextTabIndex#" size="18" maxlength="13"
				onChange="this.value = this.value.toUpperCase();">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td><label for="idVendorName">*Vendor Name:</label></td>
		<td>
			<input type="text" name="txtVendorName" id="idVendorName" value="#form.txtVendorName#" tabindex="#request.nextTabIndex#" size="60" maxlength="80">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

			<label for="idVendorID">*DUNS:</label>&nbsp;
			<input type="text" name="txtVendorID" id="idVendorID" value="#form.txtVendorID#" tabindex="#request.nextTabIndex#" size="15" maxlength="25"
				onChange="this.value = this.value.toUpperCase();">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>

			<a href="javascript:vendorSearch(document.frmEnterXactn);" tabindex="#request.nextTabIndex#"><img src="#application.paths.images#binoculars_icon.gif" border="0" alt="Vendor Search" width="19" height="16" align="absmiddle" hspace="10" /></a>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td><label for="idFundingOffice">*Funding Office:</td>
		<td>
			<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#" onChange="reloadCostCenters(this.form);">
				<option value="">Select Funding Office...</option>
				<cfloop query="rstFundingOffices">
					<option value="#fundingOfficeNum#" <cfif fundingOfficeNum eq form.cboFundingOffice>selected</cfif>>#fundingOfficeNum# - #fundingOfficeDesc#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td>*Account ID:</td>
		<td>
			<label for="idAccountID_agencyID" class="hiddenLabel">Agency ID</label>
			<select name="cboAccountID_agencyID" id="idAccountID_agencyID" tabindex="#request.nextTabIndex#" style="width:5em;" title="Agency ID">
				<option value="">Agency...</option>
				<cfloop list="#lstAgencyIDs#" index="i">
					<option value="#i#" <cfif i eq form.cboAccountID_agencyID>selected</cfif>>#i#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>

			<label for="idAccountID_fundCode" class="hiddenLabel">Fund Code</label>
			<select name="cboAccountID_fundCode" id="idAccountID_fundCode" tabindex="#request.nextTabIndex#" title="Fund Code" onChange="reloadYears(this.form);">
				<option value="">Fund Code...</option>
				<cfloop query="rstFundCodes">
					<option value="#fundCode#" <cfif fundCode eq form.cboAccountID_fundCode>selected</cfif>>#fundCode#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>

			<label for="idAccountID_budgetYear" class="hiddenLabel">Budget Year</label>
			<select name="cboAccountID_budgetYear" id="idAccountID_budgetYear" tabindex="#request.nextTabIndex#" style="width:6em;" title="Budget Year">
				<option value="">Year...</option>
				<cfset yearFound = 0>
				<cfloop index="i" from="#yearRangeMax#" to="#yearRangeMin#" step="-1">
					<option value="#i#" <cfif i eq form.cboAccountID_budgetYear>selected<cfset yearFound = 1></cfif>>#i#</option>
				</cfloop>
				<cfif not yearFound and form.cboAccountID_budgetYear neq ""> <!--- year of the footprint is not in list, add it, and select it --->
					<option value="#form.cboAccountID_budgetYear#" selected>#form.cboAccountID_budgetYear#</option>
				</cfif>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>

			<label for="idAccountID_programCode" class="hiddenLabel">Program Code</label>
			<select name="cboAccountID_programCode" id="idAccountID_programCode" tabindex="#request.nextTabIndex#" style="width:10em;" title="Program Code">
				<option value="">Program Code...</option>
				<cfloop query="rstProgramCodes">
					<option value="#programCode#" <cfif programCode eq form.cboAccountID_programCode>selected</cfif>>#programCode#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>

			<label for="idAccountID_activity" class="hiddenLabel">Activity</label>
			<select name="cboAccountID_activity" id="idAccountID_activity" tabindex="#request.nextTabIndex#" style="width:7em;" title="Activity">
				<option value="">Activity...</option>
				<cfloop query="rstActivityCodes">
					<option value="#activityCode#" <cfif activityCode eq form.cboAccountID_activity>selected</cfif>>#activityCode#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>

			<label for="idAccountID_stratGoal" class="hiddenLabel">Strategic Goal</label>
			<select name="cboAccountID_stratGoal" id="idAccountID_stratGoal" tabindex="#request.nextTabIndex#" style="width:7em;" title="Strategic Goal">
				<option value="">Strategic Goal...</option>
				<cfloop query="rstStrategicGoals">
					<option value="#strategicGoal#" <cfif strategicGoal eq form.cboAccountID_stratGoal>selected</cfif>>#strategicGoal#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>

			<label for="idAccountID_fundingOrg" class="hiddenLabel">Funding Org</label>
			<select name="cboAccountID_fundingOrg" id="idAccountID_fundingOrg" tabindex="#request.nextTabIndex#" style="width:7em;" title="Funding Org">
				<option value="">Funding Org...</option>
				<cfloop query="rstFundingOrgs">
					<option value="#fundingOrg#" <cfif fundingOrg eq form.cboAccountID_fundingOrg>selected</cfif>>#fundingOrg#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>

			<label for="idAccountID_mngUnit" class="hiddenLabel">Managing Unit</label>
			<select name="cboAccountID_mngUnit" id="idAccountID_mngUnit" tabindex="#request.nextTabIndex#" style="width:8em;" title="Managing Unit">
				<option value="">Managing Unit...</option>
				<cfset unitFound = 0>
				<cfloop query="rstManagingUnits">
					<option value="#mngUnitCode#" <cfif mngUnitCode eq form.cboAccountID_mngUnit>selected<cfset unitFound = 1></cfif>>#mngUnitCode#</option>
				</cfloop>
				<cfif not unitFound and form.cboAccountID_mngUnit neq ""> <!--- managing unit of the footprint is not in list, add it, and select it --->
					<option value="#form.cboAccountID_mngUnit#" selected>#form.cboAccountID_mngUnit#</option>
				</cfif>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td><label for="idCostCenter">*Cost Center:</label></td>
		<td>
			<select name="cboCostCenter" id="idCostCenter" tabindex="#request.nextTabIndex#" style="width:35em;">
				<option value="">Select Cost Center...</option>
				<cfloop query="rstCostCenters">
					<option value="#costCenterCode#" <cfif costCenterCode eq form.cboCostCenter>selected</cfif>>#costCenterCode# - #costCenterDesc#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr>
		<td><label for="idObjectClass">*Object Class:</label></td>
		<td>
			<select name="cboObjectClass" id="idObjectClass" tabindex="#request.nextTabIndex#">
				<option value="">Select Object Class...</option>
				<cfloop query="rstObjectClasses">
					<cfif sortOrder neq rstObjectClasses.sortOrder[currentRow-1]>
						<option value="">------------------------</option>
					</cfif>
					<option value="#objClassCode#" <cfif objClassCode eq form.cboObjectClass>selected</cfif>>#objClassCode#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr><td colspan="2" height="5"></td></tr>
	<tr><td colspan="2" class="hrule"></td></tr>
	<tr><td colspan="2" height="5"></td></tr>

	<tr>
		<td colspan="2" align="right">
			<input type="hidden" name="hidAAPPnum" value="#url.aapp#">
			<input type="hidden" name="hidFootprintID" value="#url.footprintID#">
			<input type="hidden" name="hidAccountID" value="#form.hidAccountID#">

			<input type="submit" name="btnSubmit" value="Save" tabindex="#request.nextTabIndex#"><cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input name="btnClear" type="button" value="Reset" tabindex="#request.nextTabIndex#" onClick="window.location.href='#cgi.SCRIPT_NAME#?aapp=#url.aapp#&footprintID=#url.footprintID#';">
			<input name="btnCancel" type="button" value="Cancel" onClick="window.location.href='aapp_foot_details.cfm?aapp=#url.aapp#&footprintID=#url.footprintID#';" tabindex="#request.nextTabIndex#" />

		</td>
	</tr>

	</form>
	</cfoutput>
	</table>
</div>

<script language="javascript">
document.frmEnterXactn.txtXactnDate.focus();
reloadCodes(document.frmEnterXactn);
reloadCostCenters(document.frmEnterXactn);
</script>


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

