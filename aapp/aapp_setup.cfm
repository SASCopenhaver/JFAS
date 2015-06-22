<cfsilent>
<!---
page: aapp_setup.cfm

description: displays data entry form with information for aapp setup
note: this functionality used to be called AAPP Summary, and was in aapp_summary.cfm

revisions:
2006-12-18	rroser	corrected display of Service Types on saved AAPPs
2006-12-19	mstein	Allowed Service types (and BI Fees) to be editable on successors
2006-12-19	rroser	degree of competition and set aside disabled when viewing non-DoL Contract/Grant AAPPs
2007-01-10	yjeng	Change Title: Contract Summary to AAPP Summary
2007-01-12	rroser	Give alert when choose state not in chosen funding office
2007-01-18	mstein	Make Service Description always editable (when in edit mode)
2007-01-24	mstein	Start Date can not be set to a date in the past
2007-02-02	mstein	508 adjustments made
2007-02-09	mstein	more 508 adjustments made - user of fieldset tags for option groups
2007-02-16	mstein	help ID adjustments
2007-04=19	mstein	fixed defect - national office read-only could see Save button

2007-05-17	mstein	fixed problem with Reset button - did not work correctly on return from server-side validation
2007-06-01	rroser	fixed problem with center - did not select correctly on return from server-side validation
2007-06-01	rroser	fix for future contracts with no base years selected
2007-06-01	mstein	defect - cf error when making misc aapps inactive "form.hidLatFOPID is not defined"
2007-09-10	mstein	inserted code to allow admin user to re-activate AAPP
2007-09-17	mstein	now passing along cgi.query_string when redirecting to ccc page (needed for reactivation)
2008-07-11	mstein	added validation/notifications for current PY FOPs
2008-07-23	mstein	modified business rules for disabling service type checkboxes (removed curYear > 1)
2009-03-18	mstein	disabled constraint that prohibits users from entereing a start date earlier than today's date
2011-12-02	mstein	saved functionality under aapp_setup.cfm (instead of aapp_summary.cfm)
2015-03-09	mstein	Added field and validation for spend plan category
2015-04-23	mstein	Made Base/Option years disabled for non-contracts (JFAS-391)
--->
<cfif url.aapp eq 0>
	<!--- creating new --->
	<cfif isDefined("url.hidMode") and url.hidMode eq "copy"> <!--- creating successor --->
		<cfset request.pageID = "112" />
	<cfelse>
		<cfset request.pageID = "111" /> <!--- creating new aapp --->
	</cfif>
<cfelse>
	<!--- editing exiting aapp --->
	<cfset request.pageID = "110" />
</cfif>


<cfparam name="url.hidMode" default="">

<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default="" />
<!--- define form fields that might be disabled on submission --->
<cfparam name="form.ckbServiceTypes" default="" />
<!---<cfparam name="form.ckbBIFees" default="" />--->
<cfparam name="form.cboCompetition" default="" />
<cfparam name="form.cboSetAside" default="" />
<cfparam name="form.txtOtherTypeDesc" default="" />
<cfparam name="form.radYearsBase" default="" />
<cfparam name="form.radYearsOption" default="" />
<cfparam name="form.hidCostCatCodes" default="" />


<cfif request.agreementTypeCode eq "CC" and not findnocase("aapp_setup_ccc", cgi.SCRIPT_NAME)> <!--- redirect to CCC summary --->
	<cflocation url="aapp_setup_ccc.cfm?#cgi.query_string#" />
</cfif>

<cfif isDefined("url.reactivateAAPP")> <!--- user is re-activating AAPP --->
	<cfinvoke component="#application.paths.components#aapp" method="reactivateAAPP" aapp="#request.aapp#" />
	<cflocation url="#cgi.SCRIPT_NAME#?aapp=#request.aapp#&reactivate=1" />
</cfif>


<cfif isDefined("form.btnSubmit")> <!--- form submitted --->

	<!--- save AAPP Summary data --->
	<cfinvoke component="#application.paths.components#aapp" method="saveAAPPSummary" formData="#form#" returnvariable="stcAAPPSaveResults" />

	<cfif stcAAPPSaveResults.success>
		<!--- if save was successful, then redirect back to this page in edit mode --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#stcAAPPSaveResults.aappNum#&save=1" />
	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfset variables.lstErrorMessages = stcAAPPSaveResults.errorMessages />
		<cfset variables.lstErrorFields = stcAAPPSaveResults.errorFields />
	</cfif>


<cfelse> <!--- first time viewing form --->

	<cfif request.aapp neq 0> <!--- not new contract --->

		<!--- retrieve data from database --->
		<cfinvoke component="#application.paths.components#aapp" method="getAAPPSummary" aapp="#url.aapp#" returnvariable="rstAAPPSummary" />

		<!--- preload into form fields --->
		<cfset form.cboFundingOffice = rstAAPPSummary.fundingOfficeNum />
		<cfset form.radStatus = rstAAPPSummary.statusID />
		<cfset form.hidStatus = rstAAPPSummary.statusID />
		<cfset form.cboAgreement = rstAAPPSummary.agreementTypeCode />
		<cfset form.ckbServiceTypes = rstAAPPSummary.serviceTypes />
		<cfset form.hidServiceTypes = rstAAPPSummary.serviceTypes />
		<cfset form.txtOtherTypeDesc = rstAAPPSummary.otherTypeDesc />
		<cfset form.cboCenter = rstAAPPSummary.centerID & "__" & rstAAPPSummary.state />
		<cfset form.cboState = rstAAPPSummary.state />
		<cfset form.txtVenue = rstAAPPSummary.venue />
		<cfset form.cboCompetition = rstAAPPSummary.competitionCode />
		<cfset form.cboSetAside = rstAAPPSummary.setAsideID />
		<!---<cfset form.ckbBIFees = rstAAPPSummary.BIFees />--->
		<!---<cfset form.hidBIFees = rstAAPPSummary.BIFees />--->
		<cfset form.txtDateStart = dateformat(rstAAPPSummary.dateStart, "mm/dd/yyyy") />
		<cfset form.hidDateStart = dateformat(rstAAPPSummary.dateStart, "mm/dd/yyyy") />
		<cfset form.radYearsBase = rstAAPPSummary.yearsBase />
		<cfset form.hidYearsBase = rstAAPPSummary.yearsBase />
		<cfset form.radYearsOption = rstAAPPSummary.yearsOption />
		<cfset form.hidYearsOption = rstAAPPSummary.yearsOption />
		<cfif form.cboAgreement eq "DC" or form.cboAgreement eq "GR">
			<cfset form.hidContractLength = rstAAPPSummary.yearsBase + rstAAPPSummary.yearsOption />
		<cfelse>
			<cfset form.hidContractLength = 0>
		</cfif>
		<cfset form.txtCOTR = rstAAPPSummary.COTR />
        <cfset form.cboSplanCatID = rstAAPPSummary.splanCatID />
		<cfset form.txtComments = rstAAPPSummary.comments />
		<cfset form.hidPredAAPP = rstAAPPSummary.predAAPPNum />
		<cfset form.hidLatestFOPID = rstAAPPSummary.latestFOPID />
		<cfif request.statusID eq 1>
			<cfset form.hidMode = "edit" />
		<cfelse>
			<cfset form.hidMode = "readonly" />
		</cfif>

	<cfelse> <!--- new/successor contract --->

		<cfif url.hidMode eq "copy"> <!--- successor --->

			<!--- retrieve predecessor data from database --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPSummary" aapp="#url.predaapp#" returnvariable="rstAAPPSummary" />

			<!--- preload into form fields --->
			<cfset form.txtAAPP = url.predaapp + 1000 />
			<cfset form.cboFundingOffice = rstAAPPSummary.fundingOfficeNum />
			<cfset form.radStatus = 1 />
			<cfset form.hidStatus = 1 />
			<cfset form.cboAgreement = rstAAPPSummary.agreementTypeCode />
			<cfset form.ckbServiceTypes = rstAAPPSummary.serviceTypes />
			<cfset form.hidServiceTypes = rstAAPPSummary.serviceTypes />
			<cfset form.txtOtherTypeDesc = rstAAPPSummary.otherTypeDesc />
			<cfset form.cboCenter = rstAAPPSummary.centerID & "__" & rstAAPPSummary.state />
			<cfset form.cboState = rstAAPPSummary.state />
			<cfset form.txtVenue = rstAAPPSummary.venue />
			<cfset form.cboCompetition = rstAAPPSummary.competitionCode />
			<cfset form.cboSetAside = rstAAPPSummary.setAsideID />
			<!---<cfset form.ckbBIFees = rstAAPPSummary.BIFees />--->
			<!---<cfset form.hidBIFees = rstAAPPSummary.BIFees />--->
			<cfset form.txtDateStart = dateAdd("d",1, rstAAPPSummary.dateEnd) />
			<cfset form.hidDateStart = dateformat(rstAAPPSummary.dateStart, "mm/dd/yyyy") />
			<cfset form.radYearsBase = rstAAPPSummary.yearsBase />
			<cfset form.hidYearsBase = rstAAPPSummary.yearsBase />
			<cfset form.radYearsOption = rstAAPPSummary.yearsOption />
			<cfset form.hidYearsOption = rstAAPPSummary.yearsOption />
			<cfif form.cboAgreement eq "DC" or form.cboAgreement eq "GR">
				<cfset form.hidContractLength = rstAAPPSummary.yearsBase + rstAAPPSummary.yearsOption />
			<cfelse>
				<cfset form.hidContractLength = 0>
			</cfif>
			<cfset form.txtCOTR = rstAAPPSummary.COTR />
            <cfset form.cboSplanCatID = rstAAPPSummary.splanCatID />
			<cfset form.txtComments = rstAAPPSummary.comments />
			<cfset form.hidPredAAPP = url.predaapp />
			<cfset form.hidLatestFOPID = "" />
			<cfset form.hidMode = "copy">

		<cfelse> <!--- brand new aapp --->

			<cfset form.txtAAPP = "" />
			<cfset form.cboFundingOffice = "" />
			<cfset form.radStatus = 1 />
			<cfset form.hidStatus = 1 />
			<cfset form.cboAgreement = "" />
			<cfset form.ckbServiceTypes = "" />
			<cfset form.hidServiceTypes = "" />
			<cfset form.txtOtherTypeDesc = "" />
			<cfset form.cboCenter = "" />
			<cfset form.cboState = "" />
			<cfset form.txtVenue = "" />
			<cfset form.cboCompetition = "" />
			<cfset form.cboSetAside = "" />
			<!---<cfset form.ckbBIFees = "" />--->
			<!---<cfset form.hidBIFees = "" />--->
			<cfset form.txtDateStart = "" />
			<cfset form.hidDateStart = "" />
			<cfset form.radYearsBase = "" />
			<cfset form.hidYearsBase = "" />
			<cfset form.radYearsOption = "" />
			<cfset form.hidYearsOption = "" />
			<cfset form.hidContractLength = "" />
			<cfset form.txtCOTR = "" />
            <cfset form.cboSplanCatID = "" />
			<cfset form.txtComments = "" />
			<cfset form.hidPredAAPP = "" />
			<cfset form.hidLatestFOPID = "" />
			<cfset form.hidMode = "new">

		</cfif>
	</cfif>

	<!--- regional users can only see this form readonly --->
	<cfif not listfind("1,2", session.roleID)>
		<cfset form.hidMode = "readonly">
	</cfif>

</cfif>

<!--- these calls to lookup are duplicated in applicationVariablesSetup.cfm, to set up variables like application.rstFundingOffices.  These calls are left here for backwards compatability, while rstFundingOffices is converted to application.rstFundingOffices throughout the application, etc. --->
<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeTypeNot="FED" returnvariable="rstFundingOffices" />
<cfinvoke component="#application.paths.components#lookup" method="getStates" returnvariable="rstStates" />
<cfinvoke component="#application.paths.components#lookup" method="getServiceTypes" displayType="summary" returnvariable="rstServiceTypes" />
<cfinvoke component="#application.paths.components#lookup" method="getAgreementTypes" returnvariable="rstAgreementTypes" />
<cfinvoke component="#application.paths.components#lookup" method="getServiceTypes" returnvariable="rstServiceTypes" />
<!--- END of duplicated calls to lookup --->

<!--- perform queries to retrieve reference data to populate drop-down lists --->
<cfinvoke component="#application.paths.components#center" method="getCenters" returnvariable="rstCenters" />
<cfinvoke component="#application.paths.components#lookup" method="getCompetitionTypes" returnvariable="rstCompetitionTypes" />
<cfinvoke component="#application.paths.components#lookup" method="getSetAsideTypes" returnvariable="rstSetAsideTypes" />
<cfinvoke component="#application.paths.components#splan" method="getTopSplanCodes" splanSectionCodeList="HQC,SUM" returnvariable="tSplanCats" />




<cfif form.hidMode eq "edit" and listFindNoCase("DC,GR",request.agreementTypeCode)>
	<!--- in edit mode, for grants and contracts, need to check for the existence of adjustments and FOPs --->
	<!--- this determines the editability of soem of the fields on the form --->

	<!--- get list of ECP cost cats, and cum values --->
	<cfinvoke component="#application.paths.components#aapp_adjustment" method="getECPVals" aapp="#url.aapp#" returnvariable="rstECPVals" />
	<cfquery name="qryGetECPCatswithVal" dbtype="query">
	select	costCatCode
	from	rstECPVals
	where	cumECPTotal <> 0
	</cfquery>
	<cfset hidECPCatList = valuelist(qryGetECPCatswithVal.costCatCode)>

	<!--- get list of FOP cost cats and cum values --->
	<cfinvoke component="#application.paths.components#aapp_adjustment" method="getCumulativeFOPAmounts" aapp="#url.aapp#" returnvariable="rstFOPVals" />
	<cfquery name="qryGetFOPCatswithVal" dbtype="query">
	select	costCatCode
	from	rstFOPVals
	where	totalFOPAmount <> 0
	</cfquery>
	<cfset hidFOPCatList = valuelist(qryGetFOPCatswithVal.costCatCode)>

	<!--- join both sets together (for service type checks) --->
	<cfset hidTotalCatList = hidECPCatList & "," & hidFOPCatList>

	<cfif listLen(hidECPCatList) gt 0>
		<cfquery name="rstAgreementTypes" dbtype="query">
		select	*
		from	rstAgreementTypes
		where	agreementTypeCode in ('DC','GR')
		</cfquery>
	</cfif>

	<!--- get earliest adjustment effective date (used to validate start date) --->
	<cfinvoke component="#application.paths.components#aapp_adjustment" method="getMinMaxAdjustmentDate" aapp="#url.aapp#" minMax="min" returnvariable="earlyAdjustmentDate" />

	<!--- get minimum number of option years allowed (has to do with mods and effective dates) --->
	<cfinvoke component="#application.paths.components#aapp_adjustment" method="getMinOptionYear" aapp="#url.aapp#" returnvariable="minOptionYears_valid" />

	<!--- get contract year end dates (used in validation) --->
	<cfinvoke component="#application.paths.components#aapp" method="getAAPPContractYears" aapp="#url.aapp#" returnvariable="rstContractYears" />

</cfif>




<cfset minBaseYears = 1>
<cfset maxBaseYears = 3>
<cfset minOptionYears = 0>
<cfif form.hidYearsBase neq ""><!--- fix in case there are no base years for non DC,GR contract --->
	<cfif request.curcontractyear neq '' and (request.curcontractyear - form.hidYearsBase) GTE 4>
		<cfset maxOptionYears = 5>
	<cfelse>
		<cfset maxOptionYears = 4>
	</cfif>
<cfelse>
	<cfset maxOptionYears = 4>
</cfif>
<cfset minContractLength = minBaseYears + minOptionYears>
<cfset maxContractLength = maxBaseYears + maxOptionYears>

</cfsilent>



<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<script language="javascript">

<!--- for contracts/grants, build array of contract year end dates (used in validation) --->
<cfif form.hidMode eq "edit" and listFindNoCase("DC,GR",request.agreementTypeCode)>
	//create array of contract end dates
	arrEndDates = new Array();
	<cfoutput query="rstContractYears">
		arrEndDates[#contractYear#] = "#dateformat(dateEnd, "mm/dd/yyyy")#";
	</cfoutput>
</cfif>


function radioReadOnly(formCntrl)
{
	form = formCntrl.form;
	if (formCntrl.name == 'radYearsBase')
		{
		if (form.hidYearsBase.value != '')
			form.radYearsBase[form.hidYearsBase.value-1].checked = 1;
		else
			for (var i=0; i < form.radYearsBase.length; i++)
				form.radYearsBase[i].checked = 0;
		}

	if (formCntrl.name == 'radYearsOption')
		{
		if (form.hidYearsOption.value != '')
			form.radYearsOption[form.hidYearsOption.value].checked = 1;
		else
			for (var i=0; i < form.radYearsOption.length; i++)
				form.radYearsOption[i].checked = 0;
		}

	if (formCntrl.name == 'radStatus')
		form.radStatus[<cfif form.radStatus eq 1>0<cfelse>1</cfif>].checked = 1;
}

function agreementTypeCheck(form)
{
	// when agreement type changes,
	// if dol contract:
	// enable service types
	// enable bi fees
	// set aside
	// degree of competition
	if ((form.cboAgreement.options[form.cboAgreement.selectedIndex].value.toUpperCase() == 'DC') ||
			(form.cboAgreement.options[form.cboAgreement.selectedIndex].value.toUpperCase() == 'GR'))
		{
		for (i=0;i<form.ckbServiceTypes.length;i++)
			form.ckbServiceTypes[i].disabled = 0;
		//for (i=0;i<form.ckbBIFees.length;i++)
			//don't set - form.ckbBIFees[i].disabled = 0;
		form.cboSetAside.disabled = 0;
		form.cboCompetition.disabled = 0;
		}
	else
		{
		for (i=0;i<form.ckbServiceTypes.length;i++)
			{
			form.ckbServiceTypes[i].checked = 0;
			form.ckbServiceTypes[i].disabled = 1;
			}
		//for (i=0;i<form.ckbBIFees.length;i++)
			//{
			//form.ckbBIFees[i].checked = 0;
			//form.ckbBIFees[i].disabled = 1;
			//}
		form.cboSetAside.disabled = 1;
		form.cboSetAside.selectedIndex = 0;
		form.cboCompetition.disabled = 1;
		form.cboCompetition.selectedIndex = 0;
		}

}



function checkCenter(form)
{
	//	when center is changed, if not blank,
	//	auto pop state and venue

	centerVal = form.cboCenter.options[form.cboCenter.selectedIndex].value;
	if (centerVal != '')
		{
		if(form.cboFundingOffice.options[form.cboFundingOffice.selectedIndex].value >0 && form.cboFundingOffice.options[form.cboFundingOffice.selectedIndex].value < 7)
			{
			var state = centerVal.split("__")[1];
			for (i=0;i<form.cboState.options.length;i++)
				{
				if(form.cboState.options[i].value.split("__")[0] == state)
					{
					form.cboState.selectedIndex = i;
					form.txtVenue.value = form.cboState.options[form.cboState.selectedIndex].text;
					{break}
					}
				}
			form.txtVenue.value = form.cboState.options[form.cboState.selectedIndex].text;
			var fundOffVal = form.cboFundingOffice.options[form.cboFundingOffice.selectedIndex].value
			var centerFundOffVal = centerVal.split("__")[2];
			if(fundOffVal != centerFundOffVal)
				{
				alert('The center you have chosen is not located in the selected funding office.')
				}
			}
		else
			{
			var state = centerVal.split("__")[1];
			for (i=0;i<form.cboState.options.length;i++)
				{
				if(form.cboState.options[i].value.split("__")[0] == state)
					{
					form.cboState.selectedIndex = i;
					form.txtVenue.value = form.cboState.options[form.cboState.selectedIndex].text;
					{break}
					}
				}
			}
		}
	else
		{
		form.cboState.selectedIndex = 0;
		form.txtVenue.value = '';
		}
}

function checkState(form)
{
	//	when state is changed, if not blank,
	//	auto pop venue
	//	set center to "none"

	form.cboCenter.selectedIndex = 0;
	stateVal = form.cboState.options[form.cboState.selectedIndex].value;
	if (stateVal != '')
	{
		form.txtVenue.value = form.cboState.options[form.cboState.selectedIndex].text;
		if(form.cboFundingOffice.options[form.cboFundingOffice.selectedIndex].value >0 && form.cboFundingOffice.options[form.cboFundingOffice.selectedIndex].value < 7)
		{
		var fundOffVal = form.cboFundingOffice.options[form.cboFundingOffice.selectedIndex].value
		var stateFundOffVal = stateVal.substr(stateVal.indexOf('__')+2,1);
			if(fundOffVal != stateFundOffVal)
				{
				alert('The state you have chosen is not located in the selected funding office.')
				}
		}
	}
}

function checkFundingOffice(form)
// function runs when user changes value in funding office drop-down:
//  - validates value in State drop-down
//  - determines if spend plan category field should be enabled or not (only applicable for National Office)
{
var fundOffVal = form.cboFundingOffice.options[form.cboFundingOffice.selectedIndex].value;
if(fundOffVal >0 && fundOffVal < 7)
	{
	if(form.cboState.selectedIndex !=0)
		{
		var stateVal = form.cboState.options[form.cboState.selectedIndex].value;
		var stateFundOffVal = stateVal.substr(stateVal.indexOf('__')+2,1);
		if(fundOffVal != stateFundOffVal)
			{
			if(form.cboCenter.selectedIndex != 0)
			{
			var msg = 'The state and center you have chosen are not located in the selected funding office';
			}
			else
			{
			var msg = 'The state you have chosen is not located in the selected funding office';
			}
			alert(msg);
			}
		}
	}
if (fundOffVal == 20) // is funding office National Office?
	form.cboSplanCatID.disabled = 0;
else
	{
	form.cboSplanCatID.value = '';
	form.cboSplanCatID.disabled = 1;
	}	
}

function enableFields(form)
{
	// for successor contracts, on creation,
	// need to enable all disabled fields before submitting
	form.cboFundingOffice.disabled = 0;
	form.cboAgreement.disabled = 0;
	form.txtOtherTypeDesc.disabled = 0;
	form.cboCenter.disabled = 0;
	form.cboState.disabled = 0;
	form.txtVenue.disabled = 0;
	form.cboSplanCatID.disabled = 0;
	form.txtDateStart.disabled = 0;
	for (i=0;i<form.ckbServiceTypes.length;i++)
		form.ckbServiceTypes[i].disabled = 0;
	//for (i=0;i<form.ckbBIFees.length;i++)
		//form.ckbBIFees[i].disabled = 0;

}

function ValidateForm(form)
{

	// trim text fields
	trimFormTextFields(form);
	strErrors= '';
	strWarnings = '';

	<cfif form.hidMode eq "new" or form.hidMode eq "copy">
		// for new/successor contracts, AAPP number must be specified
		if (form.txtAAPP.value == '')
			strErrors = strErrors + '   - AAPP Number must be entered.\n';
		else
			{
			if (isNaN(form.txtAAPP.value))
				strErrors = strErrors + '   - AAPP Number must be numeric.\n';
			else if (!isInteger(form.txtAAPP.value) || form.txtAAPP.value <= 0)//AAPP must be positive whole number
				strErrors = strErrors + '   - AAPP Number must be a postive integer.\n';
			else if (form.txtAAPP.value > 50000)
				strErrors = strErrors + '   - AAPP Number is invalid.\n';
			}
	</cfif>

	// funding office is required
	if (form.cboFundingOffice.selectedIndex == 0)
			strErrors = strErrors + '   - Funding Office must be specified.\n';

	// agreement type is required
	if (form.cboAgreement.selectedIndex == 0)
			strErrors = strErrors + '   - Agreement Type must be specified.\n';

	// for national office AAPPs, spend plan category must be populated
	if ((form.cboFundingOffice.value == '20') && (form.cboSplanCatID.value == ''))
		strErrors = strErrors + '   - Spend Plan Category must be specified for National Office AAPPs.\n';
	
	//for contract or grant, at least one service type must be checked
	// center is required when "Ctr ops" check box is checked
	if ((form.cboAgreement.options[form.cboAgreement.selectedIndex].value.toUpperCase() == 'DC') ||
			(form.cboAgreement.options[form.cboAgreement.selectedIndex].value.toUpperCase() == 'GR'))
		{
		serviceTypeChecked = 0;
		centerOpsChecked = 0;
		supptOtherChecked = 0;
		for (i=0;i<form.ckbServiceTypes.length;i++)
			if (form.ckbServiceTypes[i].checked)
				{
				serviceTypeChecked = 1;
				if (trim(form.ckbServiceTypes[i].value) == 'A')
					centerOpsChecked = 1;
				if ((trim(form.ckbServiceTypes[i].value) == 'S') || (trim(form.ckbServiceTypes[i].value) == 'OT'))
					supptOtherChecked = 1;
				}
		if (!serviceTypeChecked)
			strErrors = strErrors + '   - At least one Type of Service must be specified.\n';

		if (centerOpsChecked && form.cboCenter.selectedIndex == 0)
			strErrors = strErrors + '   - A Center must be specified.\n';

		<cfif form.hidMode eq "new" or form.hidMode eq "copy">
			// if support or other are checked, then description must be specified
			if (supptOtherChecked && form.txtOtherTypeDesc.value == '')
				strErrors = strErrors + '   - Service Description must be entered when either "Support" or "Other" are selected.\n';
		</cfif>

		//start date must be entered and formatted properly for contracts and grants
		dateStart = new Date(form.txtDateStart.value);

		if (form.txtDateStart.value == '')
			strErrors = strErrors + '   - Start Date must be entered.\n';
		else
			{
			//if user changed start date, make sure it is not earlier than today
			// or later than the earliest adjustment effective date
			var now = new Date();
			dateDiff = Math.abs((dateStart - now)/864e5);
			if (form.txtDateStart.value != form.hidDateStart.value)
				{
				 //if ((dateStart < now) && (dateDiff > 1))
					//strErrors = strErrors + '   - Start Date can not be in the past.\n';

				<cfif (form.hidMode eq "edit") and listFindNoCase("DC,GR",request.agreementTypeCode) and earlyAdjustmentDate neq "">
					<cfoutput>
					var earlyAdjustDate = new Date('#dateformat(earlyAdjustmentDate, "mm/dd/yyyy")#');
					if (dateStart > earlyAdjustDate)
						strErrors = strErrors + '   - Start Date can not be later than the effective date of any adjustment.\n';
					</cfoutput>
				</cfif>

				}
			}

		// base and option years required for contracts and grants
		baseYearsChecked = -1;
		for (var i=0; i < form.radYearsBase.length; i++)
			if (form.radYearsBase[i].checked)
				baseYearsChecked = i+1;

		if (baseYearsChecked == -1)
			strErrors = strErrors + '   - Number of Base Years must be specified.\n';

		optionYearsChecked = -1;
		for (var i=0; i < form.radYearsOption.length; i++)
			if (form.radYearsOption[i].checked)
				optionYearsChecked = i;

		if (optionYearsChecked == -1)
			strErrors = strErrors + '   - Number of Option Years must be specified.\n';

		<cfif form.hidMode eq "edit" and listFindNoCase("DC,GR",request.agreementTypeCode) and (minOptionYears_valid gt 0)>
			<cfoutput>
			if (baseYearsChecked + optionYearsChecked < #minOptionYears_valid#)
				strErrors = strErrors + '   - Number of total contract years can not be set to less than #minOptionYears_valid#.\n';
			</cfoutput>
		</cfif>


		<cfif form.hidMode eq "edit">
			// if length of contract has changed, or start date has changed,
			// it's possible that current PY FOPs might need to be adjusted (or notifications given)
			//  - if contract used to start in current PY but now doesn't
			//  - if successor used to start in current PY but now doesn't
			//  - if successor used to start in future PY, but now starts in current PY
			// need to perform checks to see if user should be notified

			<cfoutput>
			// area 1 - changes to start date
			datOrigStartDate = new Date('#dateFormat(request.dateStart, "mm/dd/yyyy")#');
			datNewStartDate = new Date(form.txtDateStart.value);
			if (datOrigStartDate.getTime() != datNewStartDate.getTime()) // start date has been changed
				{
				// get PYs of both dates
				origStartPY = getProgramYear(datOrigStartDate);
				newStartPY = getProgramYear(datNewStartDate);

				//contract used to start in future PY, now current
				if (origStartPY > #request.py# && newStartPY == #request.py#)
					strWarnings = strWarnings + '   - Since this contract now starts in the current program year, current PY FOPs\n' +
											    '     may need to be created.\n';
				//contract used to start in current PY, now future
				else if (origStartPY == #request.py# && newStartPY > #request.py#)
					{
					strWarnings = strWarnings + '   - Since this contract is no longer scheduled to be active in the current PY,\n' +
										   	    '     any current PY FOPs may need to be offset.\n';
					}

				//date has changed, but PY didn't (both are in current PY)
				else if (origStartPY == #request.py# && newStartPY == #request.py#)
					strWarnings = strWarnings + '   - Modifications to current program year FOPs may be necessary due to changes\n' +
											    '     in the start date of this contract.\n';
				// if start date changed, but neither the original or new starting PY is the current PY, no alerts/actions required
				}

			//area 2 - changes to length of contract
			if (form.hidContractLength.value != (baseYearsChecked + optionYearsChecked)) // contract length has changed
				{
				// set program year that contract was originally ending
				datOldContractEndDate = new Date('#dateFormat(request.dateEnd, "mm/dd/yyyy")#');
				origEndingPY = getProgramYear(datOldContractEndDate);
				if (form.hidContractLength.value > (baseYearsChecked + optionYearsChecked))
					{
					// contract has been shortened - dtermine new end date by using array of year end dates
					datNewContractEndDate = new Date(arrEndDates[baseYearsChecked + optionYearsChecked]);
					}
				else // contract lengthened
					{
					addYears = baseYearsChecked + optionYearsChecked - form.hidContractLength.value;
					datNewContractEndDate = new Date(datOldContractEndDate.getFullYear() + addYears, datOldContractEndDate.getMonth(),datOldContractEndDate.getDate());
					}
				newEndingPY = getProgramYear(datNewContractEndDate);

				// if orig ending PY or new ending PY = current PY, then give alert
				if ((origEndingPY == #request.PY#) || (newEndingPY == #request.PY#))
					strWarnings = strWarnings + '   - Modifications to current program year FOPs may be necessary due to changes\n' +
										   	    '     in the end date of this contract.\n';

				}

			<cfif request.succAAPPnum neq "">
				// area 3 - if either the start date or length was changed, and a successor exists
				if ((datOrigStartDate.getTime() != datNewStartDate.getTime()) ||
						(form.hidContractLength.value != (baseYearsChecked + optionYearsChecked)))
					{
					datOrigSuccStartDate = new Date(datOldContractEndDate.getTime() + 86400000);
					origSuccStartPY = getProgramYear(datOrigSuccStartDate);
					datNewSuccStartDate = new Date(datNewContractEndDate.getTime() + 86400000);
					newSuccStartPY = getProgramYear(datNewSuccStartDate);

					//alert(datOrigSuccStartDate + '---' + datNewSuccStartDate);
					//alert(origSuccStartPY + '---' + newSuccStartPY);

					//contract used to start in future PY, now current
					if (origSuccStartPY > #request.py# && newSuccStartPY == #request.py#)
						strWarnings = strWarnings + '\n   - Since the successor contract now starts in the current program year, current PY FOPs\n' +
												    '     may need to be created for that contract.\n';
					//contract used to start in current PY, now future
					else if (origSuccStartPY == #request.py# && newSuccStartPY > #request.py#)
						{
						strWarnings = strWarnings + '\n   - Since the successor contract is no longer scheduled to be active in the current PY,\n' +
												    '     any current PY FOPs for the successor may need to be offset.\n';
						}

					//date has changed, but PY didn't (both are in current PY)
					else if (origSuccStartPY == #request.py# && newSuccStartPY == #request.py#)
						strWarnings = strWarnings + '\n   - Modifications to current program year FOPs on the successor contract \n' +
											   	    '     may be necessary due to changes in the start date of this contract.\n';
					// if start date of the successor changed, but neither the original or new starting PY is the current PY,
					//no alerts/actions required

					}
			</cfif>
			</cfoutput>
		</cfif> <!--- edit mode? (checks for changes in dates/length - program year FOP alerts) --->


		}	// end of checks for contracts, grants


	// if start date is entered, make sure it is valid
	if (form.txtDateStart.value != '')
		if (!Checkdate(form.txtDateStart.value))
			strErrors = strErrors + '   - Start Date must be valid, and in the format "mm/dd/yyyy".\n';

	//comments max len is 200
	if (form.txtComments.value.length > 200)
		strErrors = strErrors + '   - Comments can not be longer than 200 characters.\n';


	if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before saving.\n\n' + strErrors + '\n');
		return false
		}
	else
		// if main validation passed, but there are FOP notifications...
		{
		if (strWarnings != '')
			if (confirm('The following warnings should be noted. Click "OK" to continue saving, or "Cancel"\nto return to the data entry form:\n\n' + strWarnings + '\n'))
				saveForm = 1;
			else
				saveForm = 0;
		else
			saveForm = 1;

		if (saveForm) {
			enableFields(form);
			return true;
			}
		else
			return false;
		}

}

function checkDateChange(form)
//make sure they really want to change the start date
{
	if (form.hidDateStart.value != '')
		{
		if (!confirm("Are you sure you want to change the start date?\nClick 'Cancel' to undo your changes."))
			form.txtDateStart.value = form.hidDateStart.value;
		}

}
</script>



<div class="ctrSubContent">
	<h2>AAPP Setup</h2>
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
	<cfif isDefined("url.reactivate")>
		<div class="confirmList">
		<cfoutput><li>AAPP has been reactivated successfully.</li></cfoutput>
		</div><br />
	</cfif>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<cfoutput>
	<form name="frmAAPPSummary" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&radAgreementType=#request.agreementTypeCode#" method="post" onSubmit="return ValidateForm(this);">
	</cfoutput>
	<cfif form.hidMode eq "new" or form.hidMode eq "copy"> <!--- for new or copy, show AAPP number --->
		<tr>
			<td scope="row" align="right">
				<label for="idAAPP">*AAPP Number</label>
			</td>
			<cfoutput>
			<td>
				<input type="text" name="txtAAPP" id="idAAPP" value="#form.txtAAPP#" size="6" maxlength="5"
				tabindex="#request.nextTabIndex#" <cfif listFindNoCase(variables.lstErrorFields,"txtaapp")>class="errorField"</cfif>/>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
			<td align="right">
				<label for="idPredAAPP">Predecessor</label>
			</td>
			<td>
				<cfif form.hidPredAAPP neq "">#form.hidPredAAPP#<cfelse>&nbsp;(none)</cfif>
			</td>
			</cfoutput>
		</tr>
	</cfif>
	<tr>
		<td scope="row" width="17%" align="right">
			<label for="idFundingOffice">*Funding Office</label>
		</td>
		<cfoutput>
		<td width="30%" style="text-align:left;">
			<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#" onChange="checkFundingOffice(this.form);"
				<cfif (form.hidMode eq "readonly")>	disabled </cfif>>

				<option value="">Select Funding Office...</option>
				<cfloop query="rstFundingOffices">
					<option value="#fundingOfficeNum#"
						<cfif fundingOfficeNum eq form.cboFundingOffice>selected</cfif>>
						#fundingOfficeNum# - #fundingOfficeDesc#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
		<td width="20%" align="right">
			<label for="idCompetition">Degree of Competition</label>
		</td>
		<cfoutput>
		<td width="33%" style="text-align:left;">
			<select name="cboCompetition" id="idCompetition" tabindex="20#request.nextTabIndex#"
				<cfif form.hidMode eq "readonly">disabled class="input_readonly"</cfif>
				<cfif form.cboAgreement neq "DC" and form.cboAgreement neq "GR">disabled class="input_readonly"</cfif> />
				<cfloop query="rstCompetitionTypes">
					<option value="#competitionCode#"
						<cfif competitionCode eq form.cboCompetition>selected</cfif>>
						#competitionDesc#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>
	<tr valign="top">
		<td scope="row" align="right">
			<fieldset><legend align="right">Status</legend>
		</td>
		<cfoutput>
		<td>
			<input type="radio" name="radStatus" value="1" id="radStatus_active" <cfif form.radStatus eq 1>checked</cfif> tabindex="#request.nextTabIndex#"
			<!--- status is only editable in edit mode, when the end date has passed --->
			<cfif (form.hidMode eq "new") or (form.hidMode eq "copy") or
				((form.hidMode eq "edit") and (request.dateEnd neq "") and (datecompare(request.dateEnd, now()) eq 1)) or
				(form.hidMode eq "readonly")>
				onClick="radioReadOnly(this);"
			</cfif> />
			<label for="radStatus_active">Active</label>&nbsp;
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="radio" name="radStatus" value="0" id="radStatus_inactive" <cfif form.radStatus eq 0>checked</cfif> tabindex="#request.nextTabIndex#"
			<cfif (form.hidMode eq "new") or (form.hidMode eq "copy") or
				((form.hidMode eq "edit") and (request.dateEnd neq "") and (datecompare(request.dateEnd, now()) eq 1)) or
				(form.hidMode eq "readonly")>
				onClick="radioReadOnly(this);"
			<cfelse>
				<cfif session.roleID neq 2>
					onClick="alert('Are you sure you want to make this AAPP inactive? This action can not be undone.');"
				</cfif>
			</cfif> />
			<label for="radStatus_inactive">Inactive</label>
			</fieldset>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
		<td align="right">
			<label for="idSetAside">Set Aside</label>
		</td>
		<cfoutput>
		<td>
			<select name="cboSetAside" id="idSetAside" tabindex="20#request.nextTabIndex#"
				<cfif form.hidMode eq "readonly">disabled class="inputReadonly"</cfif>
				<cfif form.cboAgreement neq "DC" and form.cboAgreement neq "GR">disabled class="input_readonly"</cfif> />
				<option value="">None</option>
				<cfloop query="rstSetAsideTypes">
					<option value="#setasideID#"
						<cfif setasideID eq form.cboSetAside>selected</cfif>>
						#setasideDesc#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>
	<tr>
		<td scope="row" align="right">
			<label for="idAgreement">*Type of Agreement</label>
		</td>
		<cfoutput>
		<td style="text-align:left;">
			<select name="cboAgreement" id="idAgreement" tabindex="#request.nextTabIndex#"
				<cfif	(form.hidMode eq "readonly") or
						(request.predAAPPNum neq "") or
						(form.hidMode eq "edit" and
						 listFindNoCase("DC,GR",request.agreementTypeCode) and
							(datediff("M", request.datestart, now()) gt 3 or listlen(hidECPCatList) gt 0))>
					disabled</cfif>
				onChange="agreementTypeCheck(this.form);">
				<option value="">Select Agreement Type...</option>
				<cfloop query="rstAgreementTypes">
					<cfif agreementTypeCode neq "CC">
						<option value="#agreementTypeCode#"
							<cfif agreementTypeCode eq form.cboAgreement>selected</cfif>>
							#agreementTypeDesc#</option>
					</cfif>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
		<td align="right">
			<label for="idCOTR">COTR</label>
		</td>
		<cfoutput>
		<td style="text-align:left;">
			<input type="text" name="txtCOTR" id="idCOTR" value="#form.txtCOTR#" size="30" maxlength="50" tabindex="20#request.nextTabIndex#"
				<cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>/>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>
	<tr valign="top">
		<td scope="row" align="right">
			<fieldset>
			<legend align="right">Type of Service</legend>
		</td>
		<cfoutput>
		<td style="text-align:left;">
			<cfloop query="rstServiceTypes">
				<input type="checkbox" name="ckbServiceTypes" value="#contractTypeCode#" id="idServiceTypes_#contractTypeCode#" tabindex="#request.nextTabIndex#"
				<cfif listContains(form.ckbServiceTypes, contractTypeCode)>checked</cfif>
				<cfif form.hidMode eq "edit">
					<cfif (not (form.cboAgreement eq "DC" or form.cboAgreement eq "GR")) or
							<!---(request.curContractYear gt 1) or--->
							(listContains(hidTotalCatList, contractTypeCode) and listContains(form.ckbServiceTypes, contractTypeCode))>
						disabled
					</cfif>
				<cfelseif form.hidMode eq "readonly">
					disabled
				</cfif>
				<!---onClick="serviceTypeCheck(this.form,#evaluate(currentRow-1)#);"--->
				>
				<label for="idServiceTypes_#contractTypeCode#">#contractTypeLongDesc#</label><br />
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</cfloop>
			</fieldset>
		</td>
		</cfoutput>
        <!--- spend plan category - currently only applies to national office AAPPs --->
		<td scope="row" align="right">
			<label for="isSplanCat">Spend Plan Category</label>
		</td>
        <cfoutput>
		<td style="text-align:left;">
			<select name="cboSplanCatID" id="idSplanCatID" tabindex="#request.nextTabIndex#"
				<!--- this field should be disabled if
					(1) form is NOT editable or
					(2) form is in Add (new) mode or
					(3) form is in Edit mode, and fund ofice is NOT national --->
				<cfif (form.hidMode eq "readonly") or (form.hidMode eq "new") or (form.hidMode eq "edit" and form.cboFundingOffice neq "20")>
                	disabled
                </cfif>
                >
				<option value="">None</option>
				<cfloop from="1" to="#arrayLen(tSplanCats.aRet)#" index="i">
					<option value="#tSplanCats.aRet[i].splanCatID#"
						<cfif tSplanCats.aRet[i].splanCatID eq form.cboSplanCatID>selected</cfif>
                        <cfif not tSplanCats.aRet[i].transassoc>disabled</cfif>
                        >
                        #repeatString("&nbsp;&nbsp;",(tSplanCats.aRet[i].hierarchyLevel-1))##tSplanCats.aRet[i].splanCatDescWithPrefix#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>

	</tr>
	<tr valign="top">
		<td scope="row" align="right" valign="top">
			<label for="idOtherTypeDesc">Service Description</label>
		</td>
		<cfoutput>
		<td style="text-align:left;">
			<input type="text" name="txtOtherTypeDesc" size="30" maxlength="50" id="idOtherTypeDesc" tabindex="#request.nextTabIndex#"
			value="#form.txtOtherTypeDesc#"
			<cfif form.hidMode eq "readonly">
				readonly class="inputReadonly"
			</cfif>
			/>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
		<td scope="row" align="right">
			<label for="idDateStart">Start Date</label>
		</td>
		<cfoutput>
		<td style="text-align:left;">
			<cfif (request.predAAPPNum neq "") or (request.curContractYear gt 1) or (request.budgetInputType eq "A") or (form.hidMode eq "readonly")>
				<cfset startDateLocked = 1>
			<cfelse>
				<cfset startDateLocked = 0>
			</cfif>
			<input type="text" name="txtDateStart" id="idDateStart" value="#dateformat(form.txtDateStart, "mm/dd/yyyy")#"
				tabindex="20#request.nextTabIndex#" size="12" maxlength="10"  <cfif form.hidMode eq "edit">onChange="checkDateChange(this.form);" title="Select to specify start date" </cfif> <cfif startDateLocked>readonly class="inputReadonly"<cfelse> class="datepicker"  </cfif> />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>

	<tr valign="top">
		<td scope="row" align="right">
			<label for="idCenter">Center</label>
		</td>
		<cfoutput>
		<td style="text-align:left;">
			<select name="cboCenter" id="idCenter" tabindex="#request.nextTabIndex#"
				<cfif form.hidMode eq "readonly">disabled</cfif> onChange="checkCenter(this.form);">
				<option value="">None</option>
				<cfloop query="rstCenters">
					<cfset optionVal = "#centerID#__#state#">
					<option value="#optionVal#__#fundingOfficeNum#"
						<cfif find(optionVal,form.cboCenter) gt 0>selected</cfif>>
						#centerName#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
		<td align="right">
			<fieldset><legend align="right">Base Years</legend>
		</td>
		<cfoutput>
		<td style="text-align:left;">
			<!--- loop through possible number of contract base years --->
			<cfloop index="i" from="#minBaseYears#" to="#maxBaseYears#">
				<input type="radio" name="radYearsBase" value="#i#"
					id="idBaseYears_#i#" tabindex="20#request.nextTabIndex#"
					<cfif i eq form.radYearsBase>checked</cfif> <!--- select year based on form value --->
					<cfif (request.curContractYear gt 1) or (form.hidMode eq "readonly") or
						  (request.budgetInputType eq "A") or (request.agreementTypeCode neq "DC")>
						  <!--- can't change after awarded, or first year, or for non-contract --->
						onClick="radioReadOnly(this);"
					</cfif>
				>
				<label for="idBaseYears_#i#">#i#</label>
				<cfif i neq maxBaseYears>&nbsp;</cfif>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</cfloop>
			</fieldset>
		</td>
		</cfoutput>
	</tr>
	<tr valign="top">
		<td scope="row" align="right">
			<label for="idState">State</label>
		</td>
		<cfoutput>
		<td style="text-align:left;">
			<!--- drop-down list of states --->
			<select name="cboState" id="idState" tabindex="#request.nextTabIndex#"
				<cfif form.hidMode eq "readonly">disabled</cfif>
				onChange="checkState(this.form);"> <!--- onChange - blank center drop-down list --->
				<option value="">None</option>
				<cfloop query="rstStates">
					<option value="#state#__#regionNum#"<cfif state eq Left(form.cboState,2)>selected</cfif>>
						#stateName#
					</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
		<td align="right">
			<fieldset><legend align="right">Option Years</legend>
		</td>
		<cfoutput>
		<td style="text-align:left;" nowrap>
			<cfloop index="i" from="#minOptionYears#" to="#maxOptionYears#">
				<input type="radio" name="radYearsOption" value="#i#" id="idYearsOption_#i#" tabindex="20#request.nextTabIndex#"
					<cfif i eq form.radYearsOption>checked</cfif>
					<cfif (form.hidMode eq "readonly") or (request.budgetInputType eq "A")or
						  (request.agreementTypeCode neq "DC")>
						  <!--- can't change after awarded, or for non-contract --->
						onClick="radioReadOnly(this);"
					</cfif>
					>
					<label for="idYearsOption_#i#">#i#</label> <cfif i neq maxOptionYears>&nbsp;</cfif>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</cfloop>
			</fieldset>
		</td>
		</cfoutput>
	</tr>
	<tr valign="top">
		<td scope="row" align="right">
			<label for="idVenue">Venue</label>
		</td>
		<cfoutput>
		<td style="text-align:left;">
			<input type="text" name="txtVenue" id="idVenue" value="#form.txtVenue#" size="22" maxlength="50"
			tabindex="#request.nextTabIndex#"
			<cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>/>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
		<td align="right">
			<label for="idComments">Comments</label>
		</td>
		<cfoutput>
		<td style="text-align:left;">
			<textarea name="txtComments" rows="3" cols="30" id="idComments" tabindex="20#request.nextTabIndex#"
			onKeyDown="textCounter(this, 200);" onKeyUp="textCounter(this, 200);"
			<cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>>#form.txtComments#</textarea>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>



	</table>
	<cfoutput>
	<cfif form.hidMode neq "readonly">
		<div class="buttons">
			<input type="hidden" name="hidAAPP" value="#url.aapp#">
			<input type="hidden" name="hidPredAAPP" value="#form.hidPredAAPP#" id="idPredAAPP" />
			<input type="hidden" name="hidStatus" value="#form.hidStatus#">
			<input type="hidden" name="hidServiceTypes" value="#form.hidServiceTypes#">
			<!---<input type="hidden" name="hidBIFees" value="#form.hidBIFees#">--->
			<input type="hidden" name="hidDateStart" value="#form.hidDateStart#">
			<cfif form.hidMode eq "edit">
				<input type="hidden" name="hidContractLength" value="#form.hidContractLength#">
			</cfif>

			<input type="hidden" name="hidLatestFOPID" value="#form.hidLatestFOPID#">
			<input type="hidden" name="hidMode" value="#form.hidMode#" />
			<input type="hidden" name="hidCostCatCodes" value="#form.hidCostCatCodes#" />
			<!--- form buttons --->
			<input name="btnSubmit" type="submit" value="Save" />
			<input name="btnClear" type="button" value="Reset" onClick="window.location.href=window.location.href"  />
			<cfif listfindnocase("new,copy",form.hidMode)>
				<input name="btnCancel" type="button" value="Cancel" onClick="window.location.href='#application.paths.root#';" />
			</cfif>
		</div>
	</cfif>
		<input type="hidden" name="hidYearsBase" value="#form.hidYearsBase#">
		<input type="hidden" name="hidYearsOption" value="#form.hidYearsOption#">
		</cfoutput>
	</form>
</div>

<!--- debug only
<cfinvoke component="#application.paths.components#aapp_budget" method="getContractInput" aapp="#request.aapp#" returnvariable="rstNewContractInput" />
<cfdump var="#rstNewContractInput#" label="Contract Budget"><br><br>


<cfinvoke component="#application.paths.components#aapp" method="getWorkloadData" aapp="#request.aapp#" returnvariable="rstWorkloadData" />
<cfdump var="#rstWorkloadData#" label="Workload"><br><br>--->


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">


