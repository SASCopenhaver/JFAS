<!---<cfif isdefined("form")><cfdump var="#form#"><br /><br /></cfif><cfabort>--->
<cfsilent>
<!---
page: aapp_adjust.cfm

description: data entry form for adding/editing/viewing adjustments and FOPs

revisions:
2006-12-17	mstein	rewrite of entire form to separate adjusment/fop functions in edit mode
2006-12-26	mstein	revision of CCC FOP mode
2006-12-28	mstein	defect 39... toggle of Ongoing and Base/Incentive radio controls
2006-01-19	mstein	changes to Full / Initial $$, based on Ongoing Status - Defect 80
2006-01-23	mstein	effective date can not be earlier then end of last contract year reconciled
2006-01-30	mstein	fixed defect 124... calculating cost resulted in NaN populated
2007-02-09	mstein	508 issues - use of fieldset tag
2007-03-20	mstein	fixed defect with reversing out a non-ongoing adjustment (blank fullCyamount caused error)
					also changed business rule: for dup/rev... if ongoing, use fullCyAmount. for non-ongoing, use initial CY amount
2007-06-01	mstein	new reqmt... allow CCC FOP to be added for previous PY, up until a certain point
					(and also allow user to edit those in the next PY, but only if there were added in the next PY)
2007-06-06	mstein	defect (209) on inactive AAPPs, user was still able to use drop-down list to "Add Another FOP", or "Duplicate..."
					This drop-down has now been removed if the contract is inactive.
					Also added <label> to that drop-down
2007-07-03	mstein	Fixed issues related to previous PY FOPs for CCCs (see above)... defect 225
2007-07-24	mstein	Default "Ongoing" to "No" at customer's request
2007-09-12	mstein	Added capability to delete FOPs and Adjustments, based on certain business rules
2007-10-10	mstein	Delete FOP - notify user if associated adjustment exists
2007-12-11	mstein	Added in kluge to fix defect in some browsers (blank PY for FOP)
2008-06-09	mstein	Allow for read-only view of adjustments created by JFAS processes (batch process, close-out, etc)
2008-07-03	mstein	Change to make the "Add to Estimated Cost Profile" checkbox always unchecked, disabled for un-awarded AAPPs
2009-03-18	mstein	Added new form field "ARRA" checkbox (for tracking stimulus funds)
2009-06-02	mstein	Modified query so that Cost Cat drop down only includes active cost cats
2009-10-23	mstein	For ongoing adjustments made in final CY - FOP amount can not be larger than current CY amount
2010-10-15	mstein	When duplicating Adjustments, error was occurring when effective date was blank
2011-04-21	mstein	Created new short-cut type: dup_same: duplicate this fop/adj, for THIS aapp (JFAS 2.8)
2011-05-06	mstein	Fixed defect... if $0 was entered for Initial CY Cost on an ongoing adjustment (validation now prevents)
2011-06-30	mstein	Increased length of description field to 200 char (2.9.0)
2011-07-01	mstein	Adjusted defect with IE autofilling of Effective Date did not fire onChange event.
2011-09-13	mstein	Reversed out IE autofill fix (conflicted with calendar pop-up)
2011-01-05	mstein	Re-adjusted Effective Date field - setting both onChange and onBlur events
2015-03-09	mstein	Added Spend Plan Transaction (detail) drop-down, and validation
--->

<cfif request.agreementtypecode neq "CC">
	<cfset request.pageID = "340" />
<cfelse>
	<cfset request.pageID = "341" />
</cfif>

<cfparam name="url.frompage" default="#application.paths.root#aapp/aapp_adjust_fop.cfm">
<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default="" />
<cfparam name="form.radModRequired" default="0" />
<cfparam name="form.radBIFees" default="0" />
<cfparam name="form.radOngoing" default="0" />
<cfparam name="form.cboProgramYearCRA" default="" />

<!--- get current system programYear, and current AAPP contract year --->
<cfif request.agreementTypeCode eq "CC">
	<cfset currentProgramYear = application.outility.getCurrentSystemProgramYear_CCC()>
<cfelse>
	<cfset currentProgramYear = application.outility.getCurrentSystemProgramYear()>
</cfif>
<cfset DatePYStart="07/01/" & evaluate(currentProgramYear)>
<cfset DatePYEnd="06/30/" & evaluate(currentProgramYear+1)>

<cfif isDefined("form.hidMode") and form.hidMode eq "delete">
	<!--- user is deleting fop or adjustment --->

	<cfif form.hidDisplayType eq "adj"> <!--- delete adjustment --->
		<cfinvoke component="#application.paths.components#aapp_adjustment" method="deleteAdjustment" adjustmentID="#form.hidAdjustID#">
		<cfset returnPage = "aapp_adjust_ec.cfm">

	<cfelseif form.hidDisplayType eq "fop"> <!--- delete fop --->
		<cfinvoke component="#application.paths.components#aapp_adjustment" method="deleteFOP" fopID="#form.hidFOPID#">
		<cfset returnPage = "aapp_adjust_fop.cfm">

	</cfif>

	<cflocation url="#returnPage#?aapp=#request.aapp#&action=recordDeleted">

</cfif>

<cfif isDefined("form.btnSubmit")> <!--- form submitted --->

	<!--- slight kluge to handle defect experienced in some users' browsers --->
	<!--- where PY is not populated --->
	<!--- if contract, where FOP will be created, but PY is blank, set to current py --->
	<cfif	(listFindNoCase("DC,GR", request.agreementtypecode)) and
			(form.hidDisplayType eq "adjfop") and
			(form.txtFOPAmount neq "" and form.txtFOPAmount neq 0) and
			(form.txtProgramYear eq "")>
		<cfset form.txtProgramYear = request.py>
	</cfif>

	<!--- save adjustment data --->
	<cfinvoke component="#application.paths.components#aapp_adjustment" method="saveAdjustmentFormData" formData="#form#" returnvariable="stcAdjustmentSaveResults" />

	<cfif stcAdjustmentSaveResults.success>
		<!--- if save was successful, then redirect back to this page in edit mode --->
		<!--- need to determine whether result of previous save was adjustment or FOP --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#request.aapp#&#stcAdjustmentSaveResults.recordType#ID=#stcAdjustmentSaveResults.recordID#&save=1&frompage=#url.fromPage#" /> --->

	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfset variables.lstErrorMessages = stcAdjustmentSaveResults.errorMessages />
		<cfset variables.lstErrorFields = stcAdjustmentSaveResults.errorFields />
	</cfif>


<cfelse> <!--- first time viewing form (no form submittal) --->


	<cfif isDefined("url.adjustID")>

		<cfset form.hidAdjustID = url.adjustID/>

		<cfif url.adjustID eq 0> <!--- user is creating a new adjustment record --->

			<cfset form.hidMode = "add" />
			<cfset form.hidDisplayType = "adjfop" />

			<cfif not isDefined("url.fromadjust")>
				<!--- brand new adjustment, show both adjustment and FOP fields --->
				<!--- (user is not duplicating adjustment from another AAPP) --->
				<cfset form.txtDescription = "" />
				<cfset form.cboCostCat = "" />
				<cfset form.txtDateEffective = "" />
				<cfset form.hidDateEffective = "" />
				<cfset form.radModRequired = "0" />
				<cfset form.radBIFees = "0" />
				<cfset form.radOngoing = "0" />
				<cfset form.txtCostInitialCY = "" />
				<cfset form.txtCostFullCY = "" />
				<cfset form.cboCostCat = "" />
				<cfset form.txtProgramYear = "" />
				<cfset form.txtFOPNum = "" />
				<cfset form.txtFOPAmount = "" />
				<cfset form.txtBackupLoc = "" />
				<cfset form.hidAdjustType = "ADJ">

			<cfelse> <!--- user is duplicating an adjustment record from another AAPP --->
				<cfinvoke component="#application.paths.components#aapp_adjustment" method="getAdjustmentFormData"
					adjustID="#url.fromadjust#" returnvariable="rstAdjustmentFormData_FromAdjustment">

				<cfset form.txtDescription = rstAdjustmentFormData_FromAdjustment.description  />
				<cfset form.cboCostCat = rstAdjustmentFormData_FromAdjustment.costCatID  />
				<cfif rstAdjustmentFormData_FromAdjustment.arra_ind>
					<cfset form.ckbARRA = 1 />
				</cfif>
				<cfif rstAdjustmentFormData_FromAdjustment.includeECP>
					<cfset form.ckbIncludeECP = 1 />
				</cfif>
				<cfset form.txtDateEffective = rstAdjustmentFormData_FromAdjustment.dateEffective  />
				<cfset form.hidDateEffective = rstAdjustmentFormData_FromAdjustment.dateEffective  />
				<cfset form.radModRequired = rstAdjustmentFormData_FromAdjustment.modRequired />
				<cfset form.radBIFees = rstAdjustmentFormData_FromAdjustment.biFees />
				<cfset form.radOngoing = rstAdjustmentFormData_FromAdjustment.ongoing />
				<cfset form.hidAdjustType = "ADJ">

				<cfif url.actionType neq "rev_diff">
					<!--- duplicate: if ongoing, copy full year cost. if not ongoing, copy initial year cost --->
					<cfif form.radOngoing>
						<cfset form.txtCostFullCY = rstAdjustmentFormData_FromAdjustment.costFullCY />
						<cfset form.txtCostInitialCY = "" /> <!--- diff AAPP, diff CY end date, so don't pre-populate --->
					<cfelse>
						<cfset form.txtCostInitialCY = rstAdjustmentFormData_FromAdjustment.costCurrentCY />
						<cfset form.txtCostFullCY = "" /> <!--- not ongoing, no full CY cost --->
					</cfif>
				<cfelse>
					<!--- reverse: if ongoing, copy full year cost. if not ongoing, copy initial year cost --->
					<cfif form.radOngoing and (rstAdjustmentFormData_FromAdjustment.costFullCY neq "")>
						<cfset form.txtCostFullCY = 0-rstAdjustmentFormData_FromAdjustment.costFullCY />
						<cfset form.txtCostInitialCY = "" /> <!--- diff AAPP, diff CY end date, so don't pre-populate --->
					<cfelseif rstAdjustmentFormData_FromAdjustment.costCurrentCY neq "">
						<cfset form.txtCostInitialCY = 0-rstAdjustmentFormData_FromAdjustment.costCurrentCY />
						<cfset form.txtCostFullCY = "" /> <!--- not ongoing, no full CY cost --->
					</cfif>
				</cfif>

				<cfset form.txtFOPNum = "" />
				<!--- if effective date of original adjustment is in current PY, then set that value --->
				<cfif (form.txtDateEffective neq "") and listFindNoCase("0,1",datecompare(form.txtDateEffective,datePYStart)) and
					listFindNoCase("0,-1",datecompare(form.txtDateEffective,datePYEnd))>
					<cfset form.txtProgramYear = currentProgramYear />
				<cfelse>
					<cfset form.txtProgramYear = "" />
				</cfif>

				<cfif rstAdjustmentFormData_FromAdjustment.fopAmount neq "" and url.actionType eq "rev_diff">
					<cfset form.txtFOPAmount = 0 - rstAdjustmentFormData_FromAdjustment.fopAmount  />
				<cfelse>
					<cfset form.txtFOPAmount = rstAdjustmentFormData_FromAdjustment.fopAmount  />
				</cfif>
				<cfset form.txtBackupLoc = rstAdjustmentFormData_FromAdjustment.backupLoc  />
			</cfif>

		<cfelse> <!--- adjustID is not 0, must be existing adjustment --->

			<cfset form.hidDisplayType = "adj" />

			<cfinvoke component="#application.paths.components#aapp_adjustment" method="getAdjustmentFormData"
				adjustID="#url.adjustID#" returnvariable="rstAdjustmentFormData">

			<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileSort"
				aapp="#url.aapp#" adjustment_id="#url.adjustID#" returnvariable="stcAdjustmentCosts">

			<cfset form.hidDisplayType = "adj" />
			<cfset form.hidAdjustID = url.adjustID />
			<cfset form.hidFOPID = rstAdjustmentFormData.fopID />
			<cfset form.hidAdjustType = rstAdjustmentFormData.adjustmentTypeCode>

			<!--- determine if form is editable or not (and which sections) --->
			<!--- if this adjustment has any mod # associated, can't change --->
			<cfif rstAdjustmentFormData.latestMod neq "">
				<cfset form.hidMode = "readonly" />
			<cfelse>
				<cfset form.hidMode = "edit" />
			</cfif>

			<cfset form.txtDescription = rstAdjustmentFormData.description  />
			<cfset form.cboCostCat = rstAdjustmentFormData.costCatID  />
			<cfif rstAdjustmentFormData.arra_ind>
				<cfset form.ckbARRA = 1 />
			</cfif>
			<cfif rstAdjustmentFormData.includeECP>
				<cfset form.ckbIncludeECP = 1 />
			</cfif>
			<cfset form.txtDateEffective = rstAdjustmentFormData.dateEffective  />
			<cfset form.hidDateEffective = rstAdjustmentFormData.dateEffective  />
			<cfset form.radModRequired = rstAdjustmentFormData.modRequired />
			<cfset form.radBIFees = rstAdjustmentFormData.biFees />
			<cfset form.radOngoing = rstAdjustmentFormData.ongoing />
			<cfset form.txtCostInitialCY = rstAdjustmentFormData.costCurrentCY />
			<cfset form.txtCostFullCY = rstAdjustmentFormData.costFullCY />
			<!--- if original adjustment was entered without FOP, but now user is adding one, --->
			<!--- need to display PY based on effective date --->
			<cfif form.hidFOPID neq "">
				<cfset form.hidProgramYear = rstAdjustmentFormData.programYear  />
				<cfset form.hidFOPNum = rstAdjustmentFormData.fopNum  />
			</cfif>

		</cfif> <!--- new adjustment, or existing? --->

	<cfelse> <!--- adjustID not in URL, must be FOP --->

		<cfset form.hidDisplayType = "fop" />
		<cfparam name="url.fopID" default="0">
		<cfset form.hidFOPID = url.fopID />

		<cfif url.fopID eq 0> <!--- new FOP --->

			<cfset form.hidMode = "add" />
			<cfset form.hidAssocAdjustID = "">

			<cfif request.agreementTypeCode eq "CC">
				<!--- for CCCs, allow user to enter FOPs from previous PY until a certain point in the next PY --->
				<!--- this code just determines the max date up until prev PY FOPs are not allowed --->
				<cfset thisPYStart = application.outility.getProgramYearDate(py="#evaluate(currentProgramYear)#", type="S")>
				<cfset prevPYdays = application.outility.getSystemSetting(systemSettingCode="prevPYfop_window")>
				<cfset prevPYFOPallowedUntil = dateadd("d",prevPYdays,thisPYStart)>
			</cfif>

			<cfif not isDefined("url.fromfop")> <!--- blank FOP, user is NOT duplicating an FOP record from another AAPP --->

				<cfset form.hidMode = "add" />
				<cfset form.txtDescription = "" />
				<cfset form.cboCostCat = "" />
				<cfset form.txtDateEffective = "" />
				<cfset form.hidDateEffective = "" />
				<cfset form.radModRequired = "0" />
				<cfset form.radBIFees = "0" />
				<cfset form.radOngoing = "0" />
				<cfset form.txtCostInitialCY = "" />
				<cfset form.txtCostFullCY = "" />
				<cfset form.cboCostCat = "" />
				<cfset form.txtProgramYear = currentProgramYear />
				<cfset form.txtFOPNum = "" />
				<cfset form.txtFOPAmount = "" />
				<cfset form.txtBackupLoc = "" />
				<cfset form.txtSplanDetail = "" />
				<cfif request.agreementTypeCode eq "CC"> <!--- for CCCs only --->
					<cfset form.txtDateEffectiveFOP = "">
					<cfset form.radOngoingFOP = 0>
					<cfset form.cboProgramYearCRA = "">
					<cfset form.txtFOPAmountNextPY = "">
				</cfif>
				<cfset form.hidAdjustType = "ADJ">

			<cfelse> <!--- user is duplicating an FOP record from another AAPP --->
				<cfinvoke component="#application.paths.components#aapp_adjustment" method="getAdjustmentFormData"
					fopID="#url.fromfop#" returnvariable="rstAdjustmentFormData_FromFOP">

				<cfset form.txtDescription = rstAdjustmentFormData_FromFOP.description  />
				<cfset form.cboCostCat = rstAdjustmentFormData_FromFOP.costCatID  />
				<cfif rstAdjustmentFormData_FromFOP.arra_ind>
					<cfset form.ckbARRA = 1>
				</cfif>
				<cfset form.txtFOPNum = "n/a" />
				<cfset form.txtProgramYear = currentProgramYear />
				<cfif rstAdjustmentFormData_FromFOP.fopAmount neq "" and url.actionType eq "rev_diff">
					<cfset form.txtFOPAmount = 0 - rstAdjustmentFormData_FromFOP.fopAmount  />
				<cfelse>
					<cfset form.txtFOPAmount = rstAdjustmentFormData_FromFOP.fopAmount  />
				</cfif>
				<cfset form.txtBackupLoc = rstAdjustmentFormData_FromFOP.backupLoc  />
				<cfset form.txtSplanDetail = "" />
				<cfif request.agreementTypeCode eq "CC"> <!--- for CCCs only --->
					<cfset form.txtDateEffectiveFOP = "">
					<cfset form.cboProgramYearCRA = "">
					<cfset form.txtFOPAmountNextPY =  rstAdjustmentFormData_FromFOP.fopAmountNextPY />
					<cfif form.txtFOPAmountNextPY neq "" and form.txtFOPAmountNextPY gt 0>
						<cfset form.radOngoingFOP = 1>
					<cfelse>
						<cfset form.radOngoingFOP = 0>
					</cfif>
				</cfif>
				<cfset form.hidAdjustType = "ADJ">
			</cfif>


		<cfelse> <!--- url.fopID not 0, must be existing FOP --->

			<!--- get data from database--->
			<cfinvoke component="#application.paths.components#aapp_adjustment" method="getAdjustmentFormData"
				fopID="#url.fopID#" returnvariable="rstAdjustmentFormData">

			<!--- retrieve greatest FOP number for this FOP's region and program year (determines if it can be deleted) --->
			<cfinvoke component="#application.paths.components#aapp_adjustment" method="getNewFOPNum"
				regionNum="#request.fundingOfficeNum#" programYear="#rstAdjustmentFormData.programYear#" returnvariable="nextFOPNum">

			<cfif request.agreementTypeCode eq "CC">
				<!--- for CCCs, allow user to enter FOPs from previous PY until a certain point in the next PY --->
				<cfset nextPYStart = application.outility.getProgramYearDate(py="#evaluate(rstAdjustmentFormData.programYear + 1)#", type="S")>
				<cfset prevPYdays = application.outility.getSystemSetting(systemSettingCode="prevPYfop_window" )>
				<cfset prevPYFOPallowedUntil = dateadd("d",prevPYdays,nextPYStart)>
			</cfif>

			<cfif rstAdjustmentFormData.programYear lt currentProgramYear>
				<!--- if FOP is from previous PY, it is read-only, unless... --->
				<!---  this is a CCC, --->
				<!--- still within the window for editing previous PY FOPs --->
				<!--- the FOP was executed in the current PY (user can only edit a previous PY if it was created after the batch process) --->

				<!--- get PY based on FOP executed date --->
				<cfset executedPY = application.outility.getYear_byDate(yearType="P", baseDate="#rstAdjustmentFormData.dateExectued#" )>
				<cfif (request.agreementTypeCode eq "CC") and
					  (datecompare(now(),prevPYFOPallowedUntil) neq 1) and
					  (executedPY eq currentProgramYear)>
					<cfset form.hidMode = "edit" />
				<cfelse>
					<cfset form.hidMode = "readonly" />
				</cfif>
			<cfelse>
				<cfset form.hidMode = "edit" />
			</cfif>

			<cfset form.txtDescription = rstAdjustmentFormData.description />
			<cfset form.cboCostCat = rstAdjustmentFormData.costCatID />
			<cfif rstAdjustmentFormData.arra_ind>
				<cfset form.ckbARRA = 1>
			</cfif>
			<cfset form.txtProgramYear = rstAdjustmentFormData.programYear />
			<cfset form.txtFOPNum = rstAdjustmentFormData.fopNum />
			<cfset form.hidMaxRegionFOPNum = nextFOPNum - 1 />
			<cfset form.txtFOPAmount = rstAdjustmentFormData.fopAmount />
			<cfset form.txtBackupLoc = rstAdjustmentFormData.backupLoc />
			<cfset form.txtSplanDetail = rstAdjustmentFormData.splanDetail />
			<cfset form.hidAssocAdjustID = rstAdjustmentFormData.adjustmentID>
			<cfif request.agreementTypeCode eq "CC"> <!--- for CCCs only --->
				<cfset form.txtDateEffectiveFOP = rstAdjustmentFormData.dateEffectiveFOP>
				<cfset form.cboProgramYearCRA = rstAdjustmentFormData.programYearCRA />
				<cfset form.txtFOPAmountNextPY = rstAdjustmentFormData.fopAmountNextPY />
				<cfif form.txtFOPAmountNextPY neq "" and form.txtFOPAmountNextPY gt 0>
					<cfset form.radOngoingFOP = 1>
				<cfelse>
					<cfset form.radOngoingFOP = 0>
				</cfif>
			</cfif>
			<cfset form.hidAdjustType = rstAdjustmentFormData.adjustmentTypeCode>


		</cfif> <!--- new FOP, or existing? --->

	</cfif> <!--- adjustment, or FOP? --->

	<!--- if AAPP is inactive, or if this is a system-generated adjustment/FOP - readonly --->
	<cfif request.statusID eq 0 or form.hidAdjustType neq "ADJ">
		<cfset form.hidMode = "readonly" />
	</cfif>
	<cfset form.hidFromPage = url.frompage />

</cfif> <!--- form display, or form submission? --->


<!--- perform queries to retrieve reference data to populate drop-down lists --->

<!--- determine what the Cost Cat drop-down list should look like --->
<cfif listFindNoCase("adjfop,fop",form.hidDisplayType)>
	<cfif request.agreementTypeCode eq "CC">
		<cfset costCatListType = "cccFOP" />
	<cfelse>
		<cfset costCatListType = "primary" />
	</cfif>
<cfelse>
	<cfset costCatListType = "ecpOnly" />
</cfif>
<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" displayFormat="#costCatListType#" returnvariable="rstCostCategories" status="active" />
<cfif listFindNoCase("DC,GR", request.agreementtypecode)> <!--- contract or grant --->
	<cfinvoke component="#application.paths.components#aapp" method="getAAPPServiceTypes" aapp="#url.aapp#" returnvariable="lstServiceTypes" />
	<cfinvoke component="#application.paths.components#aapp" method="getAAPPContractYears" aapp="#url.aapp#" returnvariable="rstContractYears" />
	<cfinvoke component="#application.paths.components#aapp_yearend" method="getYearEndListing" aapp="#url.aapp#" returnvariable="rstYearEndRecons" />
	<cfquery name="qryGetMaxRecon" dbtype="query">
	select	max(contractYear) as maxReconYear
	from	rstYearEndRecons
	</cfquery>
	<cfif not qryGetMaxRecon.recordcount>
		<cfset firstAllowedCY = 1>
	<cfelse>
		<cfset firstAllowedCY = qryGetMaxRecon.maxReconYear + 1>
	</cfif>
</cfif>


<!--- in FOP mode, pull list of spend plan transactions --->
<cfif form.hidDisplayType eq "fop">
	<!--- determine what sub-list of transactions to display --->
	<cfif request.fundingOfficeNum lte 6> <!--- regional contract --->
		<cfset sectionCode = "CTR">
	<cfelseif request.agreementTypeCode eq "CC"> <!--- CCC (fed AAPPs) --->
		<cfset sectionCode = "FED">
	<cfelse> <!--- National Office --->
		<cfset sectionCode = "HQC,SUM">
	</cfif>
	<cfset tempspPY = iif(form.txtProgramYear neq "",val(form.txtProgramYear),request.py)>
	<cfinvoke component="#application.paths.components#aapp_adjustment"
    	method="getFOPSpendPlanDetails"
        py="#tempspPY#"
        splanSectionCodeList="#sectionCode#"
        FOPid = "#form.hidFOPid#"
        returnvariable="rstSpendPlanDetails">
	<!--- get spend plan category for this AAPP (currently only applies to National Office AAPPs) --->
	<cfinvoke component="#application.paths.components#aapp_adjustment" method="getAAPPSplanCat" aappNum="#request.aapp#" returnvariable="aappSplanCatID">
	<cfset form.txtAAPPSplanCatID = aappSplanCatID>
	
</cfif> <!--- get spend plan transaction list --->

</cfsilent>



<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<script language="javascript">

<cfif listFindNoCase("DC,GR", request.agreementtypecode)> <!--- contract or grant --->
	//create array of contract end dates
	arrEndDates = new Array();
	<cfoutput query="rstContractYears">
		<cfif contractYear gte (firstAllowedCY-1)>
			arrEndDates[#contractYear#] = "#dateformat(dateEnd, "mm/dd/yyyy")#";
			<cfif contractYear eq firstAllowedCY>
				dateStart = new Date('#dateformat(dateStart,"mm/dd/yyyy")#');
			</cfif>
		</cfif>
	</cfoutput>
	<cfoutput>
	dateEnd = new Date('#dateformat(request.dateEnd,"mm/dd/yyyy")#');
	</cfoutput>
</cfif>
<cfoutput>
datePYStart = new Date('#dateformat(datePYStart,"mm/dd/yyyy")#');
datePYEnd = new Date('#dateformat(datePYEnd,"mm/dd/yyyy")#');
</cfoutput>

<cfif listFindNoCase("DC,GR", request.agreementtypecode)> <!--- contract or grant --->
	function setECPFields(form,status)
	{
		if (status == 1)
			{
			// we are in the est. cost profile
			// this is editable
			form.txtDateEffective.readOnly = 0;
			form.txtDateEffective.className = 'inputEditable';
			//document.imgDateEffective.src = "<cfoutput>#application.paths.images#calendar_icon.gif</cfoutput>";
			//document.imgDateEffective.width = "16";
			//document.imgDateEffective.height = "13";
			// add the calendar
			$('#idDateEffective').addClass('datepicker');
			$('#idDateEffective' ).datepicker({
			  showOn: "button",
			  buttonImage: <cfoutput>"#application.urls.cssdir#images/calendar_icon.gif"</cfoutput>,
			  buttonImageOnly: true,
			  buttonText: "Select date",
			  changeMonth: true,
			  changeYear: true,
			  dateFormat: "mm/dd/yy"   // this format is different from the home page
			});

			$('#idDateEffective').addClass('inputEditable');
			$('#idDateEffective').removeClass('inputReadonly');
			form.radModRequired[0].disabled = 0;
			form.radModRequired[1].disabled = 0;
			form.radModRequired[0].checked = 1;
			form.radBIFees[0].disabled = 0;
			form.radBIFees[1].disabled = 0;
			form.radBIFees[1].checked = 1;
			form.radOngoing[0].disabled = 0;
			form.radOngoing[1].disabled = 0;
			form.radOngoing[1].checked = 1;
			form.txtCostFullCY.readOnly = 1;
			form.txtCostFullCY.className = 'inputReadonly';
			form.txtCostInitialCY.readOnly = 0;
			form.txtCostInitialCY.className = 'inputEditable';
			}
		else
			{
			form.txtDateEffective.readOnly = 1;
			//form.txtDateEffective.className = 'inputReadonly';
			form.txtDateEffective.value = '';
			//document.imgDateEffective.src = "<cfoutput>#application.paths.images#clear.gif</cfoutput>";
			//document.imgDateEffective.width = "1";
			//document.imgDateEffective.height = "1";
			$('#idDateEffective').removeClass('datepicker');
			$('#idDateEffective').removeClass('inputEditable');
			$('#idDateEffective').addClass('inputReadonly');
			$( '#idDateEffective' ).removeClass('hasDatepicker');
			// remove the calendar
			$('.ui-datepicker-trigger').css("display","none");
			form.radModRequired[0].disabled = 1;
			form.radModRequired[1].disabled = 1;
			form.radModRequired[1].checked = 1;
			form.radBIFees[0].disabled = 1;
			form.radBIFees[1].disabled = 1;
			form.radBIFees[1].checked = 1;
			form.radOngoing[0].disabled = 1;
			form.radOngoing[1].disabled = 1;
			form.radOngoing[1].checked = 1;
			form.txtCostFullCY.readOnly = 1;
			form.txtCostFullCY.className = 'inputReadonly';
			form.txtCostFullCY.value = '';
			form.txtCostInitialCY.readOnly = 1;
			form.txtCostInitialCY.className = 'inputReadonly';
			form.txtCostInitialCY.value = '';
			if (form.txtProgramYear.value == '')
				form.txtProgramYear.value = <cfoutput>#currentProgramYear#</cfoutput>;
			}

		setFOPFields(form);

	}

	function checkIncludeECP(form)
	{
		if (form.ckbIncludeECP.checked)
			setFields = 1;
		else
			setFields = 0;

		setECPFields(form,setFields);

	}


	function checkBIOngoing(formControl)
	{
		// if Base and Incentive is "yes", then Ongoing must be "no"
		// and vice versa
		form = formControl.form;
		if (formControl.name == 'radBIFees')
			{
			if (form.radBIFees[0].checked)
				form.radOngoing[1].checked = 1;
			}
		else
			{
			if (form.radOngoing[0].checked)
				form.radBIFees[1].checked = 1;
			}

		if (form.radOngoing[1].checked == 1)
			{
			form.txtCostFullCY.readOnly = 1;
			form.txtCostFullCY.className = 'inputReadonly';
			form.txtCostFullCY.value = '';
			}
		else
			{
			form.txtCostFullCY.readOnly = 0;
			form.txtCostFullCY.className = 'inputEditable';
			}
	}

</cfif>


function setFOPFields(form)
{
	form.txtProgramYear.value = trim(form.txtProgramYear.value);

	if (form.txtProgramYear.value != '')
		{
		form.txtFOPAmount.readOnly = 0;
		form.txtFOPAmount.className = 'inputEditable';
		form.txtBackupLoc.readOnly = 0;
		form.txtBackupLoc.className = 'inputEditable';
		}
	else
		{
		form.txtFOPAmount.readOnly = 1;
		form.txtFOPAmount.className = 'inputReadonly';
		form.txtFOPAmount.value = '';
		form.txtBackupLoc.readOnly = 1;
		form.txtBackupLoc.className = 'inputReadonly';
		form.txtBackupLoc.value = '';
		}

}


<cfif request.agreementTypeCode eq "CC">
	function checkOngoingCCC(form)
	{

		if (form.radOngoingFOP[1].checked == 1)
			{
			form.txtFOPAmountNextPY.value = '';
			form.txtFOPAmountNextPY.readOnly = 1;
			form.txtFOPAmountNextPY.className = 'inputReadonly';
			form.txtDateEffectiveFOP.value = '';
			form.txtDateEffectiveFOP.readOnly = 1;
			form.txtDateEffectiveFOP.className = 'inputReadonly';
			document.imgDateEffectiveFOP.src = "<cfoutput>#application.paths.images#clear.gif</cfoutput>";
			document.imgDateEffectiveFOP.width = "1";
			document.imgDateEffectiveFOP.height = "1";
			}
		else
			{
			form.txtFOPAmountNextPY.readOnly = 0;
			form.txtFOPAmountNextPY.className = 'inputEditable';
			form.txtDateEffectiveFOP.readOnly = 0;
			form.txtDateEffectiveFOP.className = 'inputEditable';
			document.imgDateEffectiveFOP.src = "<cfoutput>#application.paths.images#calendar_icon.gif</cfoutput>";
			document.imgDateEffectiveFOP.width = "16";
			document.imgDateEffectiveFOP.height = "13";
			}
	}
</cfif>


function checkCostCat(form)
{
	// checks to see if "Add to ECP" checkbox should be checked or not

	// make sure they don't select a contract type that is not allowed on this contract
	if (form.cboCostCat.options[form.cboCostCat.selectedIndex].value == '~~')
		{
		alert('This is not a valid cost category for this AAPP.');
		<cfif form.hidDisplayType eq "adjfop"> <!--- in adjustment/fop mode only --->
			form.cboCostCat.selectedIndex = 0;
			form.ckbIncludeECP.checked = 0;
			form.ckbIncludeECP.disabled = 1;
		</cfif>
		}

	<cfif form.hidDisplayType eq "adjfop">  <!--- in adjustment/fop mode only --->
		<cfif request.budgetInputType eq "A">
			<!--- awarded contract: --->
			<!--- A, C1, C2 - "Add to Estimated Cost Profile" checkbox always checked, disabled --->
			<!--- S - checkbox is enabled - user specifies --->
			else
				{
				firstChar = form.cboCostCat.options[form.cboCostCat.selectedIndex].text.substring(0,1);
				//alert(firstChar);
				if (firstChar == 'A' || firstChar == 'C')
					{
					form.ckbIncludeECP.checked = true;
					form.ckbIncludeECP.disabled = 1;
					}
				else
					if (firstChar == 'S')
						{
						form.ckbIncludeECP.disabled = 0;
						}
					else
						{
						form.ckbIncludeECP.checked = 0;
						form.ckbIncludeECP.disabled = 1;
						}
				}

		<cfelse>
			<!--- future contract: "Add to Estimated Cost Profile" checkbox can never be checked --->
			form.ckbIncludeECP.checked = 0;
			form.ckbIncludeECP.disabled = 1;
		</cfif>

		checkIncludeECP(form);
	</cfif>

	<cfif request.agreementTypeCode eq "CC"> <!--- CCCs only --->
		costCatCode = form.cboCostCat.options[form.cboCostCat.selectedIndex].text.substring(0,2).toUpperCase();
		if (costCatCode == 'B1')
			form.cboProgramYearCRA.disabled = 0;
		else
			{
			form.cboProgramYearCRA.selectedIndex = 0;
			form.cboProgramYearCRA.disabled = 1;
			}
	</cfif>

}


<cfif listFindNoCase("DC,GR", request.agreementtypecode)> <!--- contract or grant --->

	function calculateCost(form)
	{
		form.txtDateEffective.value = trim(form.txtDateEffective.value);
		if (!form.ckbIncludeECP.checked)
			form.txtDateEffective.value = '';
		else
			{
			if (form.txtDateEffective.value != '') dateEffective = new Date(form.txtDateEffective.value);
			// only run this if date and full CY cost are populated, and ECP is checked, and date is within PoP
			if ((form.txtDateEffective.value != '' && (form.txtCostFullCY.value != '' || form.txtCostInitialCY.value != '') && form.ckbIncludeECP.checked) &&
				(dateEffective >= dateStart) && (dateEffective <= dateEnd))
				{
				if (form.radOngoing[0].checked == 1) // ongoing cost - pro-rate values based on date
					{
					//determine the end date of the contract year that this adjustment will impact
					for (i=<cfoutput>#firstAllowedCY#</cfoutput>;i<arrEndDates.length;i++)
						{
						dateYearEnd = new Date(arrEndDates[i]);
						if (dateYearEnd >= dateEffective)
							{
							// need to calculate length of impacted CY
							if (i==1)
								{
								// if first year, use contract start date as CY start
								dateYearStart = dateStart;
								CYlength = Math.round((dateYearEnd-dateYearStart)/864e5)+1;
								}
							else
								{
								// if not first year, use previous end date as start date
								dateYearStart = new Date(arrEndDates[i-1]);
								CYlength = Math.round((dateYearEnd-dateYearStart)/864e5);
								}
							dailyCost = stripCharsInBag(form.txtCostFullCY.value,',')/CYlength;

							break;
							}
						}

					//calculate the number of days from the effective date to the end of the impacted contract year
					daysInInitialCY = Math.round((dateYearEnd-dateEffective)/864e5)+1;
					//if (daysInInitialCY == 366) daysInInitialCY == 1;

					// calculate (and set) the initial contract year cost (only if that field is currently blank)
					if (form.txtCostInitialCY.value == '')
						form.txtCostInitialCY.value = commaFormat(Math.round(dailyCost*daysInInitialCY));
					}
				else // not-ongoing
					//form.txtCostInitialCY.value = form.txtCostFullCY.value;
					form.txtCostFullCY.value = '';

				<cfif form.hidDisplayType eq "adjfop">
					// if effective date is within the current program year, calculate FOP Amount
					if ((dateEffective >= datePYStart) && (dateEffective <= datePYEnd))
						if (form.radOngoing[0].checked == 1) // ongoing cost, pro-rate based on date
							{
							daysInProgramYear = Math.round((datePYEnd-dateEffective)/864e5)+1;
							//if (daysInProgramYear == 366) daysInProgramYear == 1;
							// calculate (and set) the FOP Amount (only if that field is currently blank)
							if (form.txtFOPAmount.value == '')
								if (dateEnd <= datePYEnd)
									// if contract ends before PY end, FOP amount is equal to this CY amount
									form.txtFOPAmount.value = form.txtCostInitialCY.value;
								else
									form.txtFOPAmount.value = commaFormat(Math.round(dailyCost*daysInProgramYear));

							}
						else // not-ongoing... FOP amount is same as full CY cost
							{
							if (form.txtFOPAmount.value == '')
								form.txtFOPAmount.value = form.txtCostInitialCY.value;
							}
				</cfif>

				}
			}
	}
</cfif>

<cfif request.agreementTypeCode eq "CC">
	function calculateCostCCC(form)
	{
		form.txtProgramYear.value = trim(form.txtProgramYear.value);
		form.txtDateEffectiveFOP.value = trim(form.txtDateEffectiveFOP.value);
		form.txtFOPAmountNextPY.value = trim(form.txtFOPAmountNextPY.value);

		// only run this if program year, date and full PY cost are populated
		if (form.txtProgramYear.value != '' && form.txtDateEffectiveFOP.value != '' && form.txtFOPAmountNextPY.value != '')
			{
			dateEffectiveFOP = new Date(form.txtDateEffectiveFOP.value);
			dailyCost = stripCharsInBag(form.txtFOPAmountNextPY.value,',')/365;
			// code change... use end date of the PY in the program year field, not request.py_ccc (could be previous PY)
			tmpDatePYEnd = new Date('06/30/' + (form.txtProgramYear.value*1 + 1));

			//calculate the number of days from the effective date to the end of the program year
			daysInPY = Math.round((tmpDatePYEnd-dateEffectiveFOP)/864e5)+1;

			// calculate (and set) the initial contract year cost (only if that field is currently blank)
			if (form.txtFOPAmount.value == '')
				{
				fopCost = Math.round(dailyCost*daysInPY);
				if (fopCost >= 0)
					form.txtFOPAmount.value = commaFormat(fopCost);
				}
			}

	}
</cfif>

<cfif listFindNoCase("DC,GR", request.agreementtypecode)> <!--- contract or grant --->

	function checkEffectiveDate(form)
	{
		<cfoutput>
		if (!form.ckbIncludeECP.checked)
			{
			form.txtDateEffective.value = '';
			<cfif form.hidDisplayType eq "adjfop">
				form.txtProgramYear.value = #currentProgramYear#;
			</cfif>
			}
		else
			{
			form.txtDateEffective.value = trim(form.txtDateEffective.value);
			newPY = '';
			if (Checkdate(form.txtDateEffective.value) && (form.txtDateEffective.value !=''))
					{

					dateEffective = new Date(form.txtDateEffective.value);

					if ((dateEffective >= dateStart) && (dateEffective <= dateEnd))
						{
						// set program year, if not later than current program year end date
						//if ((dateEffective >= datePYStart) && (dateEffective <= datePYEnd))
						if (dateEffective <= datePYEnd)
							//newPY = getProgramYear(form.txtDateEffective.value);
							newPY = #currentProgramYear#;
						else
							newPY = '';
						}
					else
						{
						alert('Effective Date must be within the valid range.');
						form.txtDateEffective.value = '';
						}
					}

				else
					{
					if (form.txtDateEffective.value !='')
						alert('Effective Date must be valid, and in the format "mm/dd/yyyy"');
					form.txtDateEffective.value = '';
					}
			<cfif form.hidDisplayType eq "adjfop">
				form.txtProgramYear.value = newPY;
				setFOPFields(form);
			</cfif>
			}
		</cfoutput>
	}
</cfif>

<cfif request.agreementTypeCode eq "CC">
	function checkEffectiveDateFOP(form)
	{
		form.txtDateEffectiveFOP.value = trim(form.txtDateEffectiveFOP.value);
		form.txtProgramYear.value = trim(form.txtProgramYear.value);
		//only check if Program Year is populated
		if (form.txtProgramYear.value != '' && form.txtDateEffectiveFOP.value != '')
		{
			if (Checkdate(form.txtDateEffectiveFOP.value))
				{
				dateEffectiveFOP = new Date(form.txtDateEffectiveFOP.value);
				if (getProgramYear(dateEffectiveFOP) !=  form.txtProgramYear.value)
					{
					alert('Effective Date must be within the specified Program Year.');
					form.txtDateEffectiveFOP.value = '';
					}

				}
			else
				{
				alert('Effective Date must be valid, and in the format "mm/dd/yyyy"');
				form.txtDateEffectiveFOP.value = '';
				}
		}

	}

</cfif> <!--- CCC only --->

<cfif form.hidMode neq "add">
	function selectAdjustmentAAPP(form)
	// handles "short-cut" actions in drop-down list, duping for another AAPP, Adding for this AAPP, etc...
	{
		<cfoutput>
		if (form.cboAdjustmentFunction.value == 'add_same')
			window.location.href='#cgi.SCRIPT_NAME#?aapp=#url.aapp#&<cfif form.hidDisplayType eq "adj">adjust<cfelse>fop</cfif>ID=0';
		else
			{
			if (form.cboAdjustmentFunction.value == 'dup_same')
				{
				urlString = '#cgi.SCRIPT_NAME#?aapp=#url.aapp#&<cfif form.hidDisplayType eq "adj">adjust<cfelse>fop</cfif>ID=0';
				urlString = urlString + '&actionType=' + form.cboAdjustmentFunction.value;
				<cfif form.hidDisplayType eq "adj">
					urlString = urlString + '&fromadjust=#url.adjustID#';
				<cfelse>
					urlString = urlString + '&fromfop=#url.fopID#';
				</cfif>
				window.location.href = urlString;
				}
			else
				{
				urlString = '?itemType=<cfif form.hidDisplayType eq "adj">adjust<cfelse>fop</cfif>&itemID=<cfif form.hidDisplayType eq "adj">#url.adjustID#<cfelse>#url.fopID#</cfif>';
				urlString = urlString + '&actionType=' + form.cboAdjustmentFunction.value + '&fromAAPP=#url.aapp#';
				newWin = window.open("#application.urls.root#views/adjust_functions.cfm"+urlString, "adjustFunctions",'status=no,toolbar=no,menubar=no,location=no,scrollbars=no,resizable=no,width=325,height=190');
				}
			}
		</cfoutput>
	}
</cfif>


function ValidateForm(form)
{
	// trim text fields
	trimFormTextFields(form);
	strErrors= '';

	//description is required, max len is 200
	if (form.txtDescription.value == '')
		strErrors = strErrors + '   - Description must be entered.\n';
	else
		if (form.txtDescription.value.length > 200)
			strErrors = strErrors + '   - Description can not be longer than 200 characters.\n';

	// cost category is required
	if (form.cboCostCat.options[form.cboCostCat.selectedIndex].value == '' || form.cboCostCat.options[form.cboCostCat.selectedIndex].value == '~~')
			strErrors = strErrors + '   - A valid Cost Category must be entered.\n';

	<cfif listFindNoCase("adj,adjfop", form.hidDisplayType)>
		// for adjustments that impact the ECP, valid effective date, full and initial costs are required
		if (form.ckbIncludeECP.checked)
			{
			if (form.txtDateEffective.value == '')
				strErrors = strErrors + '   - Effective Date must be entered.\n';
			else
				if (!Checkdate(form.txtDateEffective.value))
					strErrors = strErrors + '   - Effective Date must be valid, and in the format "mm/dd/yyyy"\n';
				else
					{
					dateEffective = new Date(form.txtDateEffective.value);
					if ((form.txtDateEffective.value != form.hidDateEffective.value) && !(dateEffective >= dateStart) && (dateEffective <= dateEnd))
						strErrors = strErrors + '   - Effective Date must be within the valid range\n';
					}
			if (form.radModRequired[1].checked && form.radOngoing[0].checked)
				strErrors = strErrors + '   - All ongoing cost adjustments require mods.\n';
			if (form.txtCostFullCY.value == '' && form.radOngoing[0].checked)
				strErrors = strErrors + '   - For Ongoing adjustments, the Full Contract Year Cost must be entered.\n';
			else
				if (isNaN(stripCharsInBag(form.txtCostFullCY.value, ",")))
					strErrors = strErrors + '   - Full Contract Year Cost must be a valid number.\n';
			if (form.txtCostInitialCY.value == '')
				strErrors = strErrors + '   - Initial Contract Year Cost must be entered.\n';
			else
				if (isNaN(stripCharsInBag(form.txtCostInitialCY.value, ",")))
					strErrors = strErrors + '   - Initial Contract Year Cost must be a valid number.\n';
			if ((form.radOngoing[0].checked) && (form.txtCostInitialCY.value == 0))
				strErrors = strErrors + '   - For ongoing adjustments, Initial Contract Year Cost can not be $0.\n';
			}
	</cfif>

	<cfif listFindNoCase("fop", form.hidDisplayType)>

		if (form.txtFOPAmount.value == '')
			strErrors = strErrors + '   - FOP Amount must be entered.\n';
		else
			if (isNaN(stripCharsInBag(form.txtFOPAmount.value, ",")))
				strErrors = strErrors + '   - FOP Amount must be a valid number.\n';

		<cfif ((request.agreementTypeCode eq "CC") and
			((form.hidMode eq "add") or (form.hidMode eq "edit"))  and
			(datecompare(now(),prevPYFOPallowedUntil) neq 1))>

			<cfoutput>
			if ((form.txtProgramYear.value != '#currentProgramYear#') && (form.txtProgramYear.value != '#evaluate(currentProgramYear-1)#'))
				strErrors = strErrors + '   - Program Year must be the current or previous Program Year.\n';
			</cfoutput>
		</cfif>
		
		//validate spend plan category:
		// function to make sure that the spend plan transaction that the user has selected is valid for the current AAPP
		// for Center Contracts (regions 1-6), transaction must be "open", and transaction cost cat must match the FOP cost cat
		// for CCCs (USDA), transaction must be open
		// for all others (National Office), transaction must be open, and must match the spend plan category of the AAPP
		// in all cases, form should allow the user to leave the existing transaction in place (if it was populated on load)
		// first step: break option value into 4 pieces: (0) dtrans detail ID, (1) Status, (2) Spend Plan Cat, (3) Cost Cat
		aComboVal = form.cboSplanDetail.value.split("~"); 
		if ((form.cboSplanDetail.value != '') && (aComboVal[0] != form.txtSplanDetail.value))
			// user has changed the value of the spend plan trans value (when loaded), and has selected something other than 'none'
			{
			if (aComboVal[1] != 'O') // transaction is not open (applies to all AAPP types)
				{
				strErrors = strErrors + '   - Status of spend plan transaction must be Open.\n';
				}
			<cfif request.fundingOfficeNum lte 6> <!--- regional contract --->
				if (aComboVal[3] != form.cboCostCat.value) // transaction has different cost cat from FOP
					{
					strErrors = strErrors + '   - Spend plan transaction must have same cost catgory as FOP.\n';
					}
			<cfelseif request.agreementTypeCode eq "CC">
				<!--- CCC (fed AAPPs) - currently no specific business rules--->
			<cfelse> <!--- National Office --->
				if (aComboVal[2] != form.txtAAPPSplanCatID.value) // transaction has different spend plan cat from AAPP
					{
					strErrors = strErrors + '   - Spend plan transaction must have same spend plan catgory as AAPP.\n';
					}
					
			</cfif>
			} // end spend plan transaction validation		
		

	<cfelseif listFindNoCase("adjfop", form.hidDisplayType)>
		// if an FOP amount is applicable, make sure it has been specified
		if (form.txtFOPAmount.value == '')
			{
			if (form.txtProgramYear.value != '')
				strErrors = strErrors + '   - FOP Amount must be entered.\n';
			}
		else
			if (isNaN(stripCharsInBag(form.txtFOPAmount.value, ",")))
				strErrors = strErrors + '   - FOP Amount must be a valid number.\n';
	</cfif>

	<cfif listFindNoCase("adjfop", form.hidDisplayType)>
		// need to make sure that non-zero dollar amount is entered in at least one of the fields
		if ((form.txtCostFullCY.value == 0) && (form.txtCostInitialCY.value == 0) && ((form.txtFOPAmount.value == 0) || (form.txtFOPAmount.value == '')))
			strErrors = strErrors + '   - At least one non-zero dollar amount must be entered for this record to be saved.\n';
	</cfif>

	<cfif request.agreementTypeCode eq "CC"> <!--- CCC only --->
		// validate effective date against program year
		if (form.txtProgramYear.value != '' && form.txtDateEffectiveFOP.value != '')
		{
			if (Checkdate(form.txtDateEffectiveFOP.value))
				{
				dateEffectiveFOP = new Date(form.txtDateEffectiveFOP.value);
				if (getProgramYear(dateEffectiveFOP) !=  form.txtProgramYear.value)
					strErrors = strErrors + '   - Effective Date must be within the specified Program Year.\n';

				}
			else
				strErrors = strErrors + '   - Effective Date must be valid, and in the format "mm/dd/yyyy"\n';

		}


		if (form.radOngoingFOP[0].checked && form.txtFOPAmountNextPY.value == '')
			strErrors = strErrors + '   - For Ongoing FOPs, the Full Program Year Amount must be entered.\n';
		if (form.txtFOPAmountNextPY.value != '')
			if (isNaN(stripCharsInBag(form.txtFOPAmountNextPY.value, ",")))
				strErrors = strErrors + '   - The Full Program Year Amount must be a valid number.\n';
		if ((form.cboCostCat.options[form.cboCostCat.selectedIndex].text.substring(0,2) == 'B1') &&
				(form.cboProgramYearCRA.selectedIndex == 0))
			strErrors = strErrors + '   - CRA Program Year is required for all B1 FOPs.\n';
	</cfif>


	if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before saving.\n\n' + strErrors + '\n');
		return false
		}
	else
		{
		<cfif form.hidDisplayType eq "adjfop">form.ckbIncludeECP.disabled = 0;</cfif> //enable field before submission
		<cfif listFindNoCase("fop", form.hidDisplayType)>form.txtSplanDetail.value = aComboVal[0];</cfif> // put splan trans ID into hidden field
		form.btnSubmit.value = 'Please wait - record being saved';
		return true;
		}

}


function resetForm()
{
	window.location.reload(false);

}

function testForEnter()
{
	if (event.keyCode == 13)
	{
		event.cancelBubble = true;
		event.returnValue = false;
         }
}

<cfif form.hidMode eq "edit">
	function deleteRecord(form)
	{
		// user is trying to delete FOP or adjustment
		msg = 'Are you sure you want to delete this record? This action can not be undone.\n';
		<cfif form.hidDisplayType eq "adj" and stcAdjustmentCosts.contract_year lt request.curContractYear>
			msg += 'NOTE: This adjustment started prior to the current contract year.\n';
		<cfelseif form.hidDisplayType eq "fop" and form.hidAssocAdjustID neq "">
			msg += 'NOTE: This FOP is associated with an existing ECP adjustment.\n';
		</cfif>
		if (confirm(msg))
			{
			form.hidMode.value = 'delete';
			form.submit();
			}

	}
</cfif>



</script>



<div class="ctrSubContent">
	<h2>
	<cfif form.hidMode eq "add">
		Add
	<cfelseif form.hidMode eq "edit">
		Edit
	</cfif>
	<cfif form.hidDisplayType eq "adjfop">
		FOP / Estimated Cost Adjustment
	<cfelseif form.hidDisplayType eq "fop">
		FOP
	<cfelse>
		Estimated Cost Adjustment
	</cfif>
	</h2>

	<!--- show error / confirmation messages --->
	<cfif listLen(variables.lstErrorMessages) gt 0>

		<div class="errorList">
		<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters="~">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div><br />
	</cfif>
	<cfif isDefined("url.save")>
		<div class="confirmList">
		<cfoutput><li>Information saved successfully.</li></cfoutput>
		</div><br />
	</cfif>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" bordercolor="red">
	<cfoutput>
	<form name="frmAAPPAdjustment" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&frompage=#url.frompage#" method="post"
	onkeydown="testForEnter();" onSubmit="return ValidateForm(this);">
	</cfoutput>
	<tr valign="top">
		<td width="50%">
			<table border="0" cellpadding="0" cellspacing="0" width="95%"> <!--- BEGIN: table that holds left side form fields --->
			<tr valign="top">
				<td width="40%" scope="row" align="right">
					<label for="idDescription">*Description</label>
				</td>
				<td width="60%">
					<cfoutput>
					<textarea name="txtDescription" rows="5" cols="35" id="idDescription" tabindex="#request.nextTabIndex#"
						onKeyDown="textCounter(this, 200);" onKeyUp="textCounter(this, 200);"
						<cfif form.hidMode eq "readonly">readOnly class="inputReadonly"</cfif>
						>#form.txtDescription#</textarea>
					<cfset request.nextTabIndex = request.nextTabIndex + 1>
					</cfoutput>
				</td>
			</tr>
			<tr valign="top">
				<td align="right">
					<label for="idCostCat">*Cost Category</label>
				</td>
				<td>
					<cfoutput>


					<cfset thisCostCat = "">
					<select name="cboCostCat" id="idCostCat"
						<cfif form.hidMode eq "readonly"> <!--- cost cat affects other form fields --->
							disabled
						<cfelse>
							onChange="checkCostCat(this.form);"
						</cfif>
						tabindex="#request.nextTabIndex#"
						>
						<cfif form.hidMode eq "add">
							<option value="">Select Cost Category...</option>
						</cfif>
						<cfloop query="rstCostCategories">
							<cfset optionVal = costCatID />
							<cfset optionStyle = "" />
							<!--- determine if this cost category is available for this aapp --->
							<cfif listFindNoCase("DC,GR",request.agreementTypeCode)>
								<cfif contractTypeCode neq "" and not listFindNoCase(lstServiceTypes,contractTypeCode)>
									<cfset optionVal = "~~" />
									<cfset optionStyle = "style='color:red;'" />
								</cfif>
							</cfif>
							<option value="#optionVal#"
								<cfif costCatID eq form.cboCostCat>
									<cfset thisCostCat = costCatCode />
									selected
								</cfif> #optionStyle#>
								#costCatCode# - #costCatDesc#</option>
						</cfloop>
					</select>
					<cfset request.nextTabIndex = request.nextTabIndex + 1>
					</cfoutput>
				</td>

			</tr>
			<cfif listFindNoCase("adj,adjfop", form.hidDisplayType)>
				<tr valign="top">
					<td></td>
					<td>
						<cfoutput>
						<input type="checkbox" name="ckbIncludeECP" value="1" id="idIncludeECP" tabindex="#request.nextTabIndex#"
						onClick="checkIncludeECP(this.form);" <cfif isDefined("form.ckbIncludeECP")>checked<cfelseif form.cboCostCat neq "S">disabled</cfif>
						<cfif (form.hidMode eq "readonly") or (form.hidDisplayType eq "adj") or (listFindNocase("A,C",left(thisCostCat,1)))>
							disabled <!--- can't change this if A,C1,C2, or in adjustment edit mode --->
						</cfif>>
						<label for="idIncludeECP">Add to Estimated Cost Profile</label>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						</cfoutput>
					</td>
				</tr>
			</cfif>
			<tr valign="top">
				<td></td>
				<td>
					<input type="checkbox" name="ckbARRA" value="1" id="idARRA" tabindex="#request.nextTabIndex#"
						<cfif isDefined("form.ckbARRA")>checked</cfif>
						disabled><label for="idARRA">ARRA</label>
					<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</td>
			</tr>

			</table> <!--- END: table that holds left side form fields --->
		</td>
		<td width="50%">
			<table border="0" cellpadding="0" cellspacing="0" width="100%"> <!--- BEGIN: table that holds right side form fields --->

			<cfif listFindNoCase("adj,adjfop", form.hidDisplayType)>
				<!--- BEGIN: adjustment attributes --->
				<tr>
					<td scope="row" align="right">
						<label for="idDateEffective">Effective Date</label>
					</td>
					<td>
						<cfoutput>
						<input type="text" name="txtDateEffective" id="idDateEffective" value="#dateformat(form.txtDateEffective, "mm/dd/yyyy")#"
							size="12" maxlength="10" tabindex="#request.nextTabIndex#"
							<!--- need both the onChange and the onBlur --->
							<!--- onChange doesn't fire if data is entered from AutoComplete (IE) --->
							<!---  onBlur doesn't occur if data is populated from calendar pop-up --->
							onChange="checkEffectiveDate(this.form);calculateCost(this.form);"
							<cfif form.hidMode neq "readonly">
								onBlur="checkEffectiveDate(this.form);calculateCost(this.form);"
							</cfif>
							<cfif not isDefined("form.ckbIncludeECP") or form.hidMode eq "readonly"> readonly class="inputReadonly"    <cfelse> class="datepicker"
							</cfif> />
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						<input type="hidden" name="hidDateEffective" value="#dateformat(form.hidDateEffective, "mm/dd/yyyy")#" />
						</cfoutput>
					</td>
				</tr>
				<tr valign="top">
					<td scope="row" align="right">
						<fieldset><legend align="right">Mod Required</legend>
					</td>
					<td>
						<cfoutput>
						<input type="radio" name="radModRequired" id="idModRequired_1" value="1" tabindex="#request.nextTabIndex#"
							<cfif form.radModRequired>checked</cfif>
							<cfif not isDefined("form.ckbIncludeECP") or form.hidMode eq "readonly">disabled</cfif>>
						<label for="idModRequired_1">Yes</label>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						<input type="radio" name="radModRequired" id="idModRequired_2" value="0" tabindex="#request.nextTabIndex#"
							<cfif not form.radModRequired>checked</cfif>
							<cfif not isDefined("form.ckbIncludeECP") or form.hidMode eq "readonly">disabled</cfif>>
						<label for="idModRequired_2">No</label>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						</cfoutput>
						</fieldset>
					</td>
				</tr>
				<tr valign="top">
					<td scope="row" align="right">
						<fieldset><legend align="right">Base and Incentive Fees</legend>
					</td>
					<td>
						<cfoutput>
						<input type="radio" name="radBIFees" id="idBIFees_1" value="1" tabindex="#request.nextTabIndex#"
							<cfif form.radBIFees>checked</cfif>
							<cfif not isDefined("form.ckbIncludeECP") or form.hidMode eq "readonly">disabled</cfif>
							onClick="checkBIOngoing(this);">
						<label for="idBIFees_1">Yes</label>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						<input type="radio" name="radBIFees" id="idBIFees_2" value="0" tabindex="#request.nextTabIndex#"
							<cfif not form.radBIFees>checked</cfif>
							<cfif not isDefined("form.ckbIncludeECP") or form.hidMode eq "readonly">disabled</cfif>
							onClick="checkBIOngoing(this);">
						<label for="idBIFees_2">No</label>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						</cfoutput>
						</fieldset>
					</td>
				</tr>
				<tr valign="top">
					<td scope="row" align="right">
						<fieldset><legend align="right">Ongoing</legend>
					</td>
					<td>
						<cfoutput>
						<input type="radio" name="radOngoing" id="idOngoing_1" value="1" tabindex="#request.nextTabIndex#"
							<cfif form.radOngoing>checked</cfif>
							<cfif not isDefined("form.ckbIncludeECP") or form.hidMode eq "readonly">disabled</cfif>
							onClick="checkBIOngoing(this);">
						<label for="idOngoing_1">Yes</label>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						<input type="radio" name="radOngoing" id="idOngoing_2" value="0" tabindex="#request.nextTabIndex#"
							<cfif not form.radOngoing>checked</cfif>
							<cfif not isDefined("form.ckbIncludeECP") or form.hidMode eq "readonly">disabled</cfif>
							onClick="checkBIOngoing(this);">
						<label for="idOngoing_2">No</label>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						</cfoutput>
						</fieldset>
					</td>
				</tr>
				<tr>
					<td scope="row" align="right">
						<label for="idCostFullCY">Full Contract Year Cost</label>
					</td>

					<td>
						<cfoutput>
						$<input type="text" name="txtCostFullCY" id="idCostFullCY"
							value="<cfif form.txtCostFullCY neq "">#numberformat(form.txtCostFullCY)#</cfif>"
							size="12" maxlength="12" tabindex="#request.nextTabIndex#" onChange="formatNum(this,4,0);calculateCost(this.form);"
							<cfif (not isDefined("form.ckbIncludeECP")) or (form.hidMode eq "readonly") or (not form.radOngoing)>readonly class="inputReadonly"</cfif>>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						</cfoutput>
					</td>
				</tr>
				<tr>
					<td scope="row" align="right">
						<label for="idCostInitialCY">Initial Contract Year Cost</label>
					</td>
					<td>
						<cfoutput>
						$<input type="text" name="txtCostInitialCY" id="idCostInitialCY"
							value="<cfif form.txtCostInitialCY neq "">#numberformat(form.txtCostInitialCY)#</cfif>"
							size="12" maxlength="12" tabindex="#request.nextTabIndex#"
							onChange="formatNum(this,4,0);if (form.radOngoing[1].checked == 1) calculateCost(this.form);"
							<cfif not isDefined("form.ckbIncludeECP") or form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						</cfoutput>
					</td>
				</tr>
				<cfif form.hidDisplayType eq "adj" and form.hidFOPID neq ""> <!--- show FOP number, link --->
					<tr>
						<td scope="row" align="right">FOP Number</td>
						<td>
							<cfoutput>
							<a href="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&fopID=#form.hidFOPID#">#form.hidProgramYear#-#form.hidFOPNum#</a>
							</cfoutput>
						</td>
					</tr>
				</cfif>

				<!--- END: adjustment attributes --->
				<cfif form.hidDisplayType eq "adjfop"> <!--- grey separating line --->
					<cfoutput>
					<tr><td colspan="2"><img src="#application.paths.images#clear.gif" width="1" height="1" alt=""></td></tr>
					<tr><td colspan="2" class="hrule"></td></tr>
					<tr><td colspan="2"><img src="#application.paths.images#clear.gif" width="1" height="1" alt=""></td></tr>
					</cfoutput>
				</cfif>
			</cfif> <!--- adjustment mode? --->

			<!--- BEGIN: FOP attributes --->

			<cfif listFindNoCase("fop,adjfop", form.hidDisplayType)>
				<cfif form.hidMode neq "add">
					<tr>
						<td align="right">
							<label for="idFOPNum">FOP Number</label>
						</td>
						<td>
							<cfoutput>
							&nbsp;&nbsp;
							<input type="text" name="txtFOPNum" id="idFOPNum" value="#form.txtFOPNum#" tabindex="#evaluate(100+request.nextTabIndex)#"
								size="12" maxlength="4" readonly class="inputReadonly">
							<cfset request.nextTabIndex = request.nextTabIndex + 1>
							</cfoutput>
						</td>
					</tr>
				</cfif>
				<tr>
					<td align="right">
						<label for="idProgramYear"><cfif form.hidDisplayType eq "fop">*</cfif>Program Year</label>
					</td>
					<td>
						<cfoutput>
						&nbsp;&nbsp;
						<input type="text" name="txtProgramYear" id="idProgramYear" value="#form.txtProgramYear#" tabindex="#request.nextTabIndex#"
							size="12" maxlength="4"
							<!--- for CCCs, user can enter FOP from previous PY until a certain point --->
							<cfif not (
										(request.agreementTypeCode eq "CC") and
										(form.hidMode eq "add") and
										(datecompare(now(),prevPYFOPallowedUntil) neq 1)
										)>
								readonly class="inputReadonly">
							</cfif>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						</cfoutput>
					</td>
				</tr>

				<cfif request.agreementTypeCode eq "CC"> <!--- CCCs only --->
					<tr>
						<td align="right">
							<label for="idProgramYearCRA">CRA Program Year</label>
						</td>
						<td>
							<cfoutput>
							&nbsp;&nbsp;
							<select name="cboProgramYearCRA" id="idProgramYearCRA" tabindex="#request.nextTabIndex#"
								<cfif (form.hidMode eq "readonly") or (thisCostCat neq "B1")>disabled</cfif>>
								<cfif form.hidMode neq "readonly">
									<option value=""></option>
									<cfloop index="i" from="#evaluate(currentProgramYear)#" to="#evaluate(currentProgramYear-4)#" step="-1">
										<option value="#i#"	<cfif form.cboProgramYearCRA eq i>selected</cfif>>#i#</option>
									</cfloop>
								<cfelse>
									<option value="#form.cboProgramYearCRA#">#form.cboProgramYearCRA#</option>
								</cfif>
							</select>
							<cfset request.nextTabIndex = request.nextTabIndex + 1>
							</cfoutput>
						</td>
					</tr>
					<tr>
						<td scope="row" align="right">
							<label for="idOngoing_FOP_1">Ongoing</label>
						</td>
						<td>
							<cfoutput>
							<input type="radio" name="radOngoingFOP" id="idOngoing_FOP_1" value="1" tabindex="#request.nextTabIndex#"
								<cfif form.radOngoingFOP>checked</cfif>
								<cfif form.hidMode eq "readonly">disabled</cfif>
								onClick="checkOngoingCCC(this.form);">
							<label for="idOngoing_FOP_1">Yes</label>
							<cfset request.nextTabIndex = request.nextTabIndex + 1>
							<input type="radio" name="radOngoingFOP" id="idOngoing_FOP_2" value="0" tabindex="#request.nextTabIndex#"
								<cfif not form.radOngoingFOP>checked</cfif>
								<cfif form.hidMode eq "readonly">disabled</cfif>
								onClick="checkOngoingCCC(this.form);">
							<label for="idOngoing_FOP_2">No</label>
							<cfset request.nextTabIndex = request.nextTabIndex + 1>
							</cfoutput>
						</td>
					</tr>
					<tr>
						<td scope="row" align="right">
							<label for="idDateEffectiveFOP">Effective Date</label>
						</td>
						<td>
							<cfoutput>
							<input type="text" name="txtDateEffectiveFOP" id="idDateEffectiveFOP" value="#dateformat(form.txtDateEffectiveFOP, "mm/dd/yyyy")#"
								size="12" maxlength="10" tabindex="#request.nextTabIndex#" onChange="checkEffectiveDateFOP(this.form);calculateCostCCC(this.form);"
								<cfif form.hidMode eq "readonly" or (not form.radOngoingFOP)> readonly class="inputReadonly" <cfelse> class="datepicker" title="Select to specify effective date"  </cfif> />
							<cfset request.nextTabIndex = request.nextTabIndex + 1>
							</cfoutput>
						</td>
					</tr>

					<tr>
						<td align="right">
							<label for="idFOPAmountNextPY">Full Program Year Amount</label>
						</td>
						<td>
							<cfoutput>
							$<input type="text" name="txtFOPAmountNextPY" id="idFOPAmountNextPY"
								value="<cfif form.txtFOPAmountNextPY neq "">#numberformat(form.txtFOPAmountNextPY)#</cfif>"
								size="12" maxlength="12" onChange="formatNum(this,4,0);calculateCostCCC(this.form);" tabindex="#request.nextTabIndex#"
								<cfif form.hidMode eq "readonly" or (not form.radOngoingFOP)>readOnly class="inputReadonly"</cfif>>
							<cfset request.nextTabIndex = request.nextTabIndex + 1>
							</cfoutput>
						</td>
					</tr>

				</cfif> <!--- CCC specific fields --->



				<tr>
					<td align="right">
						<label for="idFOPAmount"><cfif form.hidDisplayType eq "fop">*</cfif>FOP Amount</label>
					</td>
					<td>
						<cfoutput>
						$<input type="text" name="txtFOPAmount" id="idFOPAmount"
							value="<cfif form.txtFOPAmount neq "">#numberformat(form.txtFOPAmount)#</cfif>"
							size="12" maxlength="12" onChange="formatNum(this,4,0);"
							tabindex="#request.nextTabIndex#"
							<cfif form.hidMode eq "readonly">readOnly class="inputReadonly"</cfif>>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						</cfoutput>
					</td>
				</tr>



				<tr>
					<td align="right">
						<label for="idBackupLoc">Backup File Locator</label>
					</td>
					<td>
						<cfoutput>
						&nbsp;&nbsp;<input type="text" name="txtBackupLoc" id="idBackupLoc" value="#form.txtBackupLoc#"
							tabindex="#request.nextTabIndex#" size="25" maxlength="20"
							<cfif form.hidMode eq "readonly">readOnly class="inputReadonly"</cfif>>
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
						</cfoutput>
					</td>
				</tr>
				<!--- END: FOP attributes --->
			</cfif>
			</table> <!--- END: table that holds right side form fields --->

		</td>
	</tr>
	
	<cfif form.hidDisplayType eq "fop"> <!--- in FOP mode, show list of spend plan transactions --->
		<tr>
			<td colspan="2" align="right">
				<table>
				<cfoutput>
				<tr>
					<td align="right">
						<label for="idSplanDetail">Spend Plan Transaction</label>
					</td>
					<td>
						<select name="cboSplanDetail" id="idSplanDetail" <!--- onChange="validateSplanDetail(this.form);" --->
						<cfif form.hidMode eq "readonly">disabled</cfif>
						tabindex="#request.nextTabIndex#"
						>
						<option value="">None</option>
						<cfloop query="rstSpendPlanDetails">
							<cfset optionVal = "">
							<cfset optionVal = listAppend(optionVal,splantransdetid,"~")>
							<cfset optionVal = listAppend(optionVal,transStatusCode,"~")>
							<cfset optionVal = listAppend(optionVal,splanCatID,"~")>
							<cfset optionVal = listAppend(optionVal,costcatID,"~")>
							<cfif transStatusCode neq "O">
								<cfset optionStyle = "style='color:grey;'" >
							<cfelse>
								<cfset optionStyle = "" >
							</cfif>
							<option value="#optionVal#"
								<cfif splantransdetid eq form.txtSplanDetail>
									selected #optionStyle#
								</cfif>
								>
								SP #numberformat(splantransid,"0000")# <cfif costCatCode neq ""> (#costCatCode#) </cfif> #left(transdesc,35)#: #numberformat(amount,"$9,999")#</option>
						</cfloop>
					</select>
					<input type="hidden" name="txtSplanDetail" value="#form.txtSplanDetail#">
					<input type="hidden" name="txtAAPPSplanCatID" value="#form.txtAAPPSplanCatID#">
					</td>
				</tr>
				</cfoutput>
				</table>
				
			</td>		
		</tr>
	</cfif> <!--- in FOP mode, show list of spend plan transactions --->
	
	</table>
	<br />
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="red">
	<tr valign="top">
		<td>
			<!--- only show this "quick add" drop-down in edit mode, on active AAPPs --->
			<cfif form.hidMode neq "add" and request.statusID neq 0>
				<cfif form.hidDisplayType eq "adj">
					<cfset itemType = "adjustment">
				<cfelse>
					<cfset itemType = "FOP">
				</cfif>
				<cfoutput>
				<label for="idAdjustmentFunction" class="hiddenLabel">Perform operation on this adjustment</label>
				<div class="buttons" style="text-align:left">
				<select name="cboAdjustmentFunction" id="idAdjustmentFunction" tabindex="#request.nextTabIndex#">
					<option value="add_same">Add another #itemType# for this AAPP</option>
					<option value="add_diff">Add another #itemType# for a different AAPP</option>
					<option value="dup_same">Duplicate this #itemType# for this AAPP</option>
					<option value="dup_diff">Duplicate this #itemType# for a different AAPP</option>
					<option value="rev_diff">Reverse this #itemType# for a different AAPP</option>
					<cfif form.hidDisplayType eq "fop" and form.hidMode neq "readonly">
						<option value="mov_diff">Move this #itemType# to a different AAPP</option>
					</cfif>
				</select>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				<input name="btnAdjustFunction" type="button" tabindex="#request.nextTabIndex#" value="Go" onclick="selectAdjustmentAAPP(this.form);" />
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</div>
				</cfoutput>
			</cfif>
		</td>
		<cfif form.hidMode neq "readonly"> <!--- if edit mode, show buttons at bottom --->

			<!--- show delete button if: --->
			<!--- 1. This is an adjustment (if it's editable, it can be deleted) --->
			<!--- 2. This is an FOP, and it's from the current PY, and is the most recently created FOP in this region --->
			<!--- 3. This is edit mode --->
			<cfif form.hidMode eq "edit">
				<td>
				<div class="buttons"><cfoutput>
				<input type="button" name="btnDelete" value="Delete <cfif form.hidDisplayType eq "fop">FOP<cfelse>Adjustment</cfif>"
					 onClick="deleteRecord(this.form);" tabindex="#request.nextTabIndex#"
					 <cfif form.hidDisplayType eq "fop" and form.txtFOPNum lt form.hidMaxRegionFOPNum>
						DISABLED
					 </cfif>
					/>
					</cfoutput></div>
				</td>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</cfif>

			<td>
				<div class="buttons">
					<cfoutput>
					<input type="hidden" name="hidAAPP" value="#url.aapp#">
					<cfif listFindNoCase("adj,adjfop", form.hidDisplayType)> <!--- adjustment mode --->
						<input type="hidden" name="hidAdjustID" value="#form.hidAdjustID#" />
					<cfelse>
						<input type="hidden" name="hidFOPID" value="#form.hidFOPID#" />
						<input type="hidden" name="hidAssocAdjustID" value="#form.hidAssocAdjustID#" />
						<cfif form.hidMode eq "edit">
							<input type="hidden" name="hidMaxRegionFOPNum" value="#form.hidMaxRegionFOPNum#" />
						</cfif>
					</cfif>
					<input type="hidden" name="hidMode" value="#form.hidMode#" />
					<input type="hidden" name="hidDisplayType" value="#form.hidDisplayType#" />
					<input type="hidden" name="hidAdjustType" value="#form.hidAdjustType#" />
					<!---<input type="hidden" name="hidFromPage" value="#url.fromPage#" />--->
					<!--- form buttons --->
					<input name="btnSubmit" type="submit" value="Save" tabindex="#request.nextTabIndex#" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
					<input name="btnClear" type="button" value="Reset" onclick="resetForm();" tabindex="#request.nextTabIndex#" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
					<input name="btnCancel" type="button" value="Cancel" onClick="window.location.href='#url.fromPage#?aapp=#url.aapp#';" tabindex="#request.nextTabIndex#" />
					</cfoutput>
				</div>
			</td>
		</cfif>

	</tr>
	</table>
	</form>

	<!--- if editing an adjustment, show the ECP information below --->
	<cfif form.hidDisplayType eq "adj">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
		<tr>
			<th scope="col" width="10%" nowrap>Contract Year</th>
			<th scope="col" width="15%">Start Date</th>
			<th scope="col" width="15%">End Date</th>
			<th scope="col" width="15%">Mod #</th>
			<th scope="col" width="15%">Amount</th>
		</tr>
		<cfoutput query="stcAdjustmentCosts">
			<tr <cfif currentrow mod 2>class="AltRow"</cfif>>
				<td scope="row" align="center">#contract_year#</td>
				<td align="center">#dateformat(date_start, "mm/dd/yyyy")#</td>
				<td align="center">#dateformat(date_end, "mm/dd/yyyy")#</td>
				<td align="center">#mod_num#</td>
				<td align="right">$#numberformat(amount)#</td>
			</tr>
		</cfoutput>
		</table>
	</cfif>
</div>


<cfif form.hidMode neq "readonly">
	<script language="javascript">
	document.frmAAPPAdjustment.txtDescription.focus();
	</script>
</cfif>


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

