<cfsilent>
<!---
page: aapp_contract_extension.cfm

description: allows user to extend/shorten contract - handles all ECP and FOP adjustments

revisions:
2011-12-29	mstein	page created
2014-12-15	mstein	Don't allow user to delete final CY of one year contract. Default check to "shorten" in this case.
--->

<cfset request.pageID = "122" />
<cfparam name="url.hidMode" default="edit">
<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default="" />
<cfset returnPage = "aapp_workload.cfm">


<cfif isDefined("form.extMode")> <!--- form submitted --->
	<!--- <cfdump var="#form#"><cfabort> --->
	<!--- submit form data --->
	<cfinvoke component="#application.paths.components#aapp_extension" method="contractExtensionHandler" aapp="#url.aapp#" formData="#form#" returnvariable="stcContractExt" />
	<!--- <cfdump var="#stcContractExt#"> --->
	<cfif stcContractExt.success>
		<!--- if save was successful, then redirect back to this page in edit mode --->
		<cflocation url="aapp_workload.cfm?aapp=#url.aapp#&save=1&action=#stcContractExt.extSubMode#" />
	</cfif>


<cfelse> <!--- first time viewing form --->

		<!--- retrieve first step data --->
		<cfinvoke component="#application.paths.components#aapp_extension" method="contractExtensionHandler" aapp="#url.aapp#" returnvariable="stcContractExt" />


</cfif>
</cfsilent>




<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">


<script language="javascript">

function backStep (gotoStep)
{
	<cfoutput>
	document.frmContractExtension.formStep.value = gotoStep;
	document.frmContractExtension.formStepPrev.value = #stcContractExt.formStep#;
	document.frmContractExtension.submit();
	</cfoutput>

}

<cfif stcContractExt.formStep eq 2>
	function isLeapYear (Year) {
		if (((Year % 4)==0) && ((Year % 100)!=0) || ((Year % 400)==0))
			return true;
		else
			return false;
	}

	function checkMonthEnd(dateControl)
	{
		// checks to see if date entered is last day of that month
		enteredDate = new Date(dateControl.value);
		myYear = enteredDate.getFullYear();
		myMonth = enteredDate.getMonth();
		var monthEndDate = new Date(myYear, myMonth + 1, 0);
		if (monthEndDate.getTime() != enteredDate.getTime())
			alert('Please note: the date you have entered is not the last day of the month.');
	}

	function calculateDays(formField)
	{
		form = formField.form;
		endDate = trim(formField.value);

		switch(formField.name)
			{
				case 'newFinalEndDate_EXT':
					startDate = new Date(form.finalYearStartDate_EXT.value);
					targetField = form.numDaysYear_EXT;
					showDiff = 1;
					difField = form.numDaysYearDif_EXT;
					break;

				case 'newFinalEndDate_ADD':
					startDate = new Date(form.finalYearStartDate_ADD.value);
					targetField = form.numDaysYear_ADD;
					showDiff = 0;
					break;

				case 'newFinalEndDate_SHR':
					startDate = new Date(form.finalYearStartDate_SHR.value);
					targetField = form.numDaysYear_SHR;
					showDiff = 1;
					difField = form.numDaysYearDif_SHR;
					break;
			}

		if (endDate != '')
			{
			if (Checkdate(endDate))
				{
				newEndDate = new Date(endDate);
				CYlength = Math.round((newEndDate-startDate)/864e5)+1;
				currentEndDate = new Date(form.currentFinalEndDate.value);
				oldCYlength = Math.round((currentEndDate-startDate)/864e5)+1;

				<cfif stcContractExt.extMode eq "INC"> <!--- extending contract --->
					// leap year?
					if (startDate.getMonth() > 1) // if contract starts after Feb (months are numbered 0,1,2,3...)
						febYear = newEndDate.getFullYear();
					else
						febYear = startDate.getFullYear();

					if ((CYlength < 1) || ((CYlength > 365) && !isLeapYear(febYear)) || ((CYlength > 366) && isLeapYear(febYear)))
						{
						alert('Please enter a date that is one year or less from the contract year start date.')
						formField.value = '';
						targetField.value = '';
						if (showDiff) difField.value = '';
						}

				<cfelse>
					if ((newEndDate < startDate) || (newEndDate > currentEndDate))
						{
						alert('Please enter a date that is between the final contract year start date and end date.')
						formField.value = '';
						targetField.value = '';
						if (showDiff) difField.value = '';
						}
				</cfif>

				else //pass validation
					{
					targetField.value = CYlength + ' days';
					checkMonthEnd(formField); //alert user if date entered is not last day of the month
					// calculate change in year length
					if (showDiff)
						{
						changeDays = CYlength - oldCYlength;
						difField.value = '(' + changeDays + ' day change in CY)';
						}
					}
				}
			else
				{
				alert('Please enter a valid date.');
				formField.value = '';
				targetField.value = '';
				if (showDiff) difField.value = '';
				}
			}
		else
			{
			targetField.value = '';
			if (showDiff) difField.value = '';
			}




	}

	<!--- increasing length of contract --->

	function checkExtend(form)
	{
	if (form.extSubMode[0].checked) // add year
		{
		<cfif stcContractExt.extMode eq "INC">
			form.newFinalEndDate_EXT.value = '';
			form.newFinalEndDate_EXT.disabled = 1;
			form.numDaysYear_EXT.value = '';
			form.newFinalEndDate_EXT.className = 'inputReadonly';
			form.newFinalEndDate_ADD.disabled = 0;
			form.newFinalEndDate_ADD.className = 'inputEditable';
		<cfelse>
			form.newFinalEndDate_SHR.value = '';
			form.newFinalEndDate_SHR.disabled = 1;
			form.numDaysYear_SHR.value = '';
			form.newFinalEndDate_SHR.className = 'inputReadonly';
		</cfif>
		}
	else
		{
		<cfif stcContractExt.extMode eq "INC">
			form.newFinalEndDate_ADD.value = '';
			form.newFinalEndDate_ADD.disabled = 1;
			form.numDaysYear_ADD.value = '';
			form.newFinalEndDate_ADD.className = 'inputReadonly';
			form.newFinalEndDate_EXT.disabled = 0;
			form.newFinalEndDate_EXT.className = 'inputEditable';
		<cfelse>
			form.newFinalEndDate_SHR.disabled = 0;
			form.newFinalEndDate_SHR.className = 'inputEditable';
		</cfif>
		}

	}
</cfif>

<cfif stcContractExt.formStep eq 3>
	function reCalcOAFOP(form)
	{
	// function calculates OA Sucessor FOP. O/A is the only cost cat where the Fee field could be editable
	// need to compare the proposed FOPs for current AAPP (reimburs+fee), with the current amount on the successor
	// the FOP change to the successor can not bring the new successor cum below $0
	tmpCurrentFOPTotal = parseInt(stripCharsInBag(form.C1_R_newFOP.value,",")) + parseInt(stripCharsInBag(form.C1_F_newFOP.value,","));
	tmpSuccFOPTotal = parseInt(stripCharsInBag(form.C1_succFOPCum.value,","));
	if (tmpCurrentFOPTotal > tmpSuccFOPTotal)
		{
		// if total would go below $0, show alert, and set value at max (inverse of current successor cum)
		form.C1_newSuccFOP.value = commaFormat(-1*tmpSuccFOPTotal);
		alert('In order to prevent a negative balance, the FOP amount for the successor can not be less than ' + form.C1_newSuccFOP.value + '.');
		document.getElementById('C1_succAlert').style.visibility = 'visible';
		}
	else
		{
		//otherwise, just update value (and hide alert icon, if necessary
		form.C1_newSuccFOP.value = commaFormat(-1*tmpCurrentFOPTotal);
		document.getElementById('C1_succAlert').style.visibility = 'hidden';
		}
	}

	function validateB3(form)
	{
	// function makes sure that user-entered amount for B3 successor FOP will not bring levels below $0
	tmpProposedSuccFOP = parseInt(stripCharsInBag(form.VEH_newSuccFOP.value,","));
	tmpCurrentSuccFOP = parseInt(stripCharsInBag(form.VEH_succFOPCum.value,","));
	if ((tmpProposedSuccFOP + tmpCurrentSuccFOP) < 0)
		{
		// if total would go below $0, show alert, and set value at max (inverse of current successor cum)
		alert('A FOP in this amount would bring the cumulative B3 level below $0. The current B3 funding on the successor is $' + form.VEH_succFOPCum.value + '.');
		form.VEH_newSuccFOP.value = 0;
		}
	}


	function alertNoCreate(form)
	{
	if (form.ckbNoCreate.checked == 1)
		{
		tmpMsg = 'Notice: if you do not allow JFAS to create the necessary adjustments and FOPs,\n' +
				 'there is a very good chance that the budget will be out of synch. Certain ECP \n' +
				 'adjustments will automatically be created regardless of your selection here.\n\n';
		alert(tmpMsg);
		}
	}

	function recalcWorkload(formField)
	{
		// if workload level change section is displayed, this function will recalc
		// the 'change' column, based on the user's change to the 'Total' column
		wlType = formField.name.split("_")[0]; //get workload type
		totalAmount = stripCharsInBag(formField.value,',');
		currentAmount = stripCharsInBag(formField.form[wlType + '_WL_currentAmount'].value,',');
		formField.form[wlType + '_WL_change'].value = commaFormat(totalAmount - currentAmount);
	}

</cfif>


</script>



<div class="ctrSubContent">
	<h2>Contract Extension / Early Termination</h2>

	<!--- show error / confirmation messages --->
	<cfif listLen(stcContractExt.lstErrorMessages) gt 0>
		<div class="errorList">
		<cfloop index="listItem" list="#stcContractExt.lstErrorMessages#" delimiters="~">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div><br />
	</cfif>


	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">

	<!--- Step 1: Selecting extenstion/termination --->
	<!--- --->
	<tr>
		<td colspan="3"><b>Type of Contract Schedule Change</b></td>
	</tr>
	<cfif stcContractExt.formStep eq 1>
		<!--- this is current step, display form --->
		<cfoutput>
		<form name="frmContractExtension" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#" method="post" onSubmit="return false;">
		</cfoutput>
		<tr>
			<td></td>
			<td>
				<input type="radio" name="extMode" id="idExtMode_INC" value="INC"
					<cfif NOT stcContractExt.incEnabled>
						disabled
					<cfelse>
						<cfif stcContractExt.extMode eq "INC">checked</cfif>
					</cfif>
					><label for="idExtMode_INC">Extend Contract</label><br>
				<input type="radio" name="extMode" id="idExtMode_DEC" value="DEC"
					<cfif NOT stcContractExt.decEnabled>
						disabled
					<cfelse>
						<cfif stcContractExt.extMode eq "DEC">checked</cfif>
					</cfif>
					><label for="idExtMode_DEC">Terminate Contract Early (shorten)</label>
			</td>
			<td></td>
		</tr>
		<tr>
			<td colspan="2"></td>
			<td align="right">
				<cfoutput>
				<input type="hidden" name="formStep" value="2">
				<input type="hidden" name="formStepPrev" value="1">
				<input name="btnSubmit" type="button" value="Next" onclick="this.form.submit();"
					<cfif (not stcContractExt.incEnabled) and (not stcContractExt.decEnabled)>disabled</cfif>
					/>
				<input name="btnCancel" type="button" value="Cancel" onClick="window.location.href='#returnPage#?aapp=#url.aapp#';" />
				</cfoutput>
			</td>
		</tr>
		</form>

	<cfelse>
		<!--- already passed step 1, display data as read-only --->
		<tr>
			<td></td>
			<td>
				<cfif stcContractExt.extMode eq "INC">
					Extend Contract
				<cfelseif stcContractExt.extMode eq "DEC">
					Terminate Contract Early (shorten)
				</cfif>
			</td>
			<td align="right">
				<a href="javascript:backStep(1);">Change...</a>
			</td>
		</tr>
	</cfif>

	<tr><td colspan="3"><cfoutput><img src="#application.paths.images#clear.gif" alt="" width="1" height="1" /></cfoutput></td></tr>

	<!--- Step 2: Selecting method of extenstion/termination --->
	<!--- --->
	<cfif stcContractExt.formStep gte 2>
		<tr>
			<td colspan="3">
				<cfoutput><b>Method of Contract #iif(stcContractExt.extMode eq "INC",de("Extension"),de("Termination"))#</b></cfoutput>
			</td>
		</tr>
		<cfif stcContractExt.formStep eq 2>
		<!--- this is current step, display form --->
			<cfoutput>
			<form name="frmContractExtension" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#" method="post" onSubmit="return false;">

			<cfif stcContractExt.extMode eq "INC">
				<tr>
					<td></td>
					<td>
						<input type="radio" name="extSubMode" id="idExtSubMode_INC-ADD" value="INC-ADD"
						<cfif NOT stcContractExt.addYearEnabled>
							disabled
						<cfelse>
							<cfif stcContractExt.extSubMode eq "INC-ADD">checked</cfif>
							onclick="checkExtend(this.form);"
						</cfif>
						><label for="idExtSubMode_INC-ADD">Add additional contract year (CY#evaluate(stcContractExt.currentContractLength+1)#)</label>
					</td>
					<td></td>
				</tr>
				<tr>
					<td></td>
					<td colspan="2">
						<table width="60%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="10%"></td>
							<td width="40%">CY#evaluate(stcContractExt.currentContractLength+1)# start date:</td>
							<td width="25%">
								#dateformat(dateadd("d",1,stcContractExt.currentFinalEndDate), "mm/dd/yyyy")#
								<input type="hidden" name="finalYearStartDate_ADD" value="#dateformat(dateadd("d",1,stcContractExt.currentFinalEndDate), "mm/dd/yyyy")#">
							</td>
							<td width="25%"></td>
						</tr>
						<tr>
							<td></td>
							<td>CY#evaluate(stcContractExt.currentContractLength+1)# end date:</td>
							<td>
								<input type="text" name="newFinalEndDate_ADD" id="idNewFinalEndDate" maxlength="10" size="12"
									<cfif stcContractExt.extSubMode eq "INC-ADD">
										value="#dateformat(dateadd("yyyy",1,stcContractExt.currentFinalEndDate), "mm/dd/yyyy")#"
									<cfelse>
										disabled class="inputReadonly"
									</cfif>
									onBlur="calculateDays(this);"
									>
							</td>
							<td>
								<input type="text" name="numDaysYear_ADD" size="12" readonly="true"
									<cfif stcContractExt.extSubMode eq "INC-ADD">
										value="#evaluate(1+dateDiff("d",dateadd("d",1,stcContractExt.currentFinalEndDate),dateadd("yyyy",1,stcContractExt.currentFinalEndDate)))# days"
									</cfif>
									style="border:0;">
							</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td></td>
					<td>
						<input type="radio" name="extSubMode" id="idExtSubMode_INC-EXT" value="INC-EXT"
						<cfif NOT stcContractExt.extendYearEnabled>
							disabled
						<cfelse>
							<cfif stcContractExt.extSubMode eq "INC-EXT">checked</cfif>
							onclick="checkExtend(this.form);"
						</cfif>
						><label for="idExtSubMode_INC-EXT">Increase length of final contract year</label><br>
					</td>
					<td></td>
				</tr>
				<tr>
					<td></td>
					<td colspan="2">
						<table width="60%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="10%"></td>
							<td width="40%">Current CY#stcContractExt.currentContractLength# start date:</td>
							<td width="25%">
								#dateformat(stcContractExt.currentFinalYearStartDate, "mm/dd/yyyy")#
								<input type="hidden" name="finalYearStartDate_EXT" value="#dateformat(stcContractExt.currentFinalYearStartDate, "mm/dd/yyyy")#">
							</td>
							<td width="25%"></td>
						</tr>
						<tr>
							<td></td>
							<td>Current CY#stcContractExt.currentContractLength# end date:</td>
							<td>
								#dateformat(stcContractExt.currentFinalEndDate, "mm/dd/yyyy")#
								<input type="hidden" size="12" name="currentFinalEndDate" value="#dateformat(stcContractExt.currentFinalEndDate, "mm/dd/yyyy")#">
							</td>
							<td>
								<input type="text" size="12" name="numDaysFinalYear" readonly="true" value="#evaluate(1+dateDiff("d",stcContractExt.currentFinalYearStartDate,stcContractExt.currentFinalEndDate))# days" style="border:0;">
							</td>
						</tr>
						<tr>
							<td></td>
							<td>New CY#stcContractExt.currentContractLength# end date:</td>
							<td>
								<input type="text" name="newFinalEndDate_EXT" id="idNewFinalEndDate" maxlength="10" size="12"
									<cfif stcContractExt.extSubMode eq "INC-EXT">
										value="#dateformat(stcContractExt.currentFinalEndDate, "mm/dd/yyyy")#"
									<cfelse>
										disabled  class="inputReadonly"
									</cfif>
									onBlur="calculateDays(this);"
									>
							</td>
							<td valign="top">
								<input type="text" name="numDaysYear_EXT" size="12" readonly="true"
									<cfif stcContractExt.extSubMode eq "INC-EXT">
										value="#evaluate(1+dateDiff("d",stcContractExt.currentFinalYearStartDate,stcContractExt.currentFinalEndDate))# days"
									</cfif>
									style="border:0;">

								<input type="text" name="numDaysYearDif_EXT" size="24" readonly="true" style="border:0; position:absolute;">
							</td>
						</tr>
						</table>
					</td>
				</tr>
			<cfelse> <!--- shortening --->
				<tr>
					<td></td>
					<td>
						<input type="radio" name="extSubMode" id="idExtSubMode_DEC-DEL" value="DEC-DEL"
						<cfif NOT stcContractExt.removeYearEnabled>
							disabled
						<cfelse>
							<cfif stcContractExt.extSubMode eq "DEC-DEL">checked</cfif>
							onclick="checkExtend(this.form);"
						</cfif>
						><label for="idExtSubMode_DEC-DEL">Delete final contract year (CY#stcContractExt.currentContractLength#)</label>
					</td>
					<td></td>
				</tr>
				<tr>
					<td></td>
					<td>
						<input type="radio" name="extSubMode" id="idExtSubMode_DEC-SHR" value="DEC-SHR"
						<cfif NOT stcContractExt.shortenYearEnabled>
							disabled
						<cfelse>
							<!--- if form is in "shorten" mode, or if the user is not allowed to delete the final year - check this option --->
							<cfif (stcContractExt.extSubMode eq "DEC-SHR")>checked</cfif>
							onclick="checkExtend(this.form);"
						</cfif>
						><label for="idExtSubMode_DEC-SHR">Decrease length of final contract year</label><br>
					</td>
					<td></td>
				</tr>
				<tr>
					<td></td>
					<td colspan="2">
						<table width="60%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="10%"></td>
							<td width="40%">Current CY#stcContractExt.currentContractLength# start date:</td>
							<td width="25%">
								#dateformat(stcContractExt.currentFinalYearStartDate, "mm/dd/yyyy")#
								<input type="hidden" name="finalYearStartDate_SHR" value="#dateformat(stcContractExt.currentFinalYearStartDate, "mm/dd/yyyy")#">
								<input type="hidden" name="finalYearStartDate_DEL" value="#dateformat(stcContractExt.currentFinalYearStartDate, "mm/dd/yyyy")#">
							</td>
							<td width="25%"></td>
						</tr>
						<tr>
							<td></td>
							<td>Current CY#stcContractExt.currentContractLength# end date:</td>
							<td>
								#dateformat(stcContractExt.currentFinalEndDate, "mm/dd/yyyy")#
								<input type="hidden" size="12" name="currentFinalEndDate" value="#dateformat(stcContractExt.currentFinalEndDate, "mm/dd/yyyy")#">
							</td>
							<td>
								<input type="text" size="12" name="numDaysFinalYear" readonly="true" value="#evaluate(1+dateDiff("d",stcContractExt.currentFinalYearStartDate,stcContractExt.currentFinalEndDate))# days" style="border:0;">
							</td>
						</tr>
						<tr>
							<td></td>
							<td>New CY#evaluate(stcContractExt.currentContractLength)# end date:</td>
							<td>
								<input type="text" name="newFinalEndDate_SHR" id="idNewFinalEndDate" maxlength="10" size="12"
									<cfif stcContractExt.extSubMode eq "DEC-SHR">
										value="#dateformat(stcContractExt.currentFinalEndDate, "mm/dd/yyyy")#"
									<cfelse>
										disabled class="inputReadonly"
									</cfif>
									onBlur="calculateDays(this);"
									>
							</td>
							<td>
								<input type="text" name="numDaysYear_SHR" size="12" readonly="true"
									<cfif stcContractExt.extSubMode eq "DEC-SHR">
										value="#evaluate(1+dateDiff("d",stcContractExt.currentFinalYearStartDate,stcContractExt.currentFinalEndDate))# days"
									</cfif>
									style="border:0;">

								<input type="text" name="numDaysYearDif_SHR" size="24" readonly="true" style="border:0; position:absolute;">
							</td>
						</tr>
						</table>
					</td>
				</tr>

			</cfif>

			<tr>
				<td colspan="2"></td>
				<td align="right">
					<input type="hidden" name="formStep" value="3">
					<input type="hidden" name="formStepPrev" value="2">
					<input type="hidden" name="extMode" value="#stcContractExt.extMode#">
					<cfif stcContractExt.extMode eq "INC">
						<input type="hidden" name="addYearEnabled" value="#stcContractExt.addYearEnabled#">
						<input type="hidden" name="extendYearEnabled" value="#stcContractExt.addYearEnabled#">
					<cfelse>
						<input type="hidden" name="removeYearEnabled" value="#stcContractExt.removeYearEnabled#">
						<input type="hidden" name="shortenYearEnabled" value="#stcContractExt.shortenYearEnabled#">
					</cfif>
					<input name="btnSubmit" type="button" value="Next" onClick="this.form.submit();" />
					<input name="btnCancel" type="button" value="Cancel" onClick="window.location.href='#returnPage#?aapp=#url.aapp#';" />

				</td>
			</tr>
			</cfoutput>
			</form>
		<cfelse>
			<!--- already passed step 2, display data as read-only --->
			<cfoutput>
			<tr>
				<td></td>
				<td>
					<cfswitch expression="#form.extsubmode#">
					<cfcase value="INC-ADD">Add additional contract year (CY#evaluate(stcContractExt.currentContractLength+1)#)</cfcase>
					<cfcase value="INC-EXT">Increase length of final contract year</cfcase>
					<cfcase value="DEC-DEL">Delete final contract year (CY#stcContractExt.currentContractLength#)</cfcase>
					<cfcase value="DEC-SHR">Decrease length of final contract year</cfcase>
					</cfswitch>
				</td>
				<td align="right">
					<a href="javascript:backStep(2);">Change...</a>
				</td>
			</tr>
				<cfswitch expression="#form.extsubmode#">
					<cfcase value="INC-ADD">
						<tr>
							<td></td>
							<td colspan="2">
								<table width="60%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td width="10%"></td>
									<td width="40%">CY#evaluate(stcContractExt.currentContractLength+1)# start date:</td>
									<td width="25%">#dateformat(stcContractExt.finalYearStartDate_ADD, "mm/dd/yyyy")#</td>
									<td width="25%"></td>
								</tr>
								<tr>
									<td></td>
									<td>CY#evaluate(stcContractExt.currentContractLength+1)# end date:</td>
									<td>#dateformat(stcContractExt.newFinalEndDate_ADD, "mm/dd/yyyy")#</td>
									<td>#stcContractExt.numDaysYear_ADD#</td>
								</tr>
								</table>
							</td>
						</tr>
					</cfcase>
					<cfcase value="INC-EXT">
						<tr>
							<td></td>
							<td colspan="2">
								<table width="60%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td width="10%"></td>
									<td width="40%">Current CY#stcContractExt.currentContractLength# start date:</td>
									<td width="25%">#dateformat(stcContractExt.finalYearStartDate_EXT, "mm/dd/yyyy")#</td>
									<td width="25%"></td>
								</tr>
								<tr>
									<td></td>
									<td>Current CY#stcContractExt.currentContractLength# end date:</td>
									<td>#dateformat(stcContractExt.currentFinalEndDate, "mm/dd/yyyy")#</td>
									<td>#stcContractExt.numDaysFinalYear#</td>
								</tr>
								<tr>
									<cfset changeDays = evaluate(replace(stcContractExt.numDaysYear_EXT," days","") - replace(stcContractExt.numDaysFinalYear," days",""))>
									<td></td>
									<td>New CY#stcContractExt.currentContractLength# end date:</td>
									<td>#dateformat(stcContractExt.newFinalEndDate_EXT, "mm/dd/yyyy")#</td>
									<td nowrap>#stcContractExt.numDaysYear_EXT# &nbsp;(#changeDays# day change in CY)</td>
								</tr>
								</table>
							</td>
						</tr>
					</cfcase>
					<cfcase value="DEC-SHR">
						<tr>
							<td></td>
							<td colspan="2">
								<table width="60%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td width="10%"></td>
									<td width="40%">Current CY#stcContractExt.currentContractLength# start date:</td>
									<td width="25%">#dateformat(stcContractExt.finalYearStartDate_SHR, "mm/dd/yyyy")#</td>
									<td width="25%"></td>
								</tr>
								<tr>
									<td></td>
									<td>Current CY#stcContractExt.currentContractLength# end date:</td>
									<td>#dateformat(stcContractExt.currentFinalEndDate, "mm/dd/yyyy")#</td>
									<td>#stcContractExt.numDaysFinalYear#</td>
								</tr>
								<tr>
									<cfset changeDays = evaluate(replace(stcContractExt.numDaysYear_SHR," days","") - replace(stcContractExt.numDaysFinalYear," days",""))>
									<td></td>
									<td>New CY#evaluate(stcContractExt.currentContractLength)# end date:</td>
									<td>#dateformat(stcContractExt.newFinalEndDate_shr, "mm/dd/yyyy")#</td>
									<td nowrap>#stcContractExt.numDaysYear_SHR# &nbsp;(#changeDays# day change in CY)</td>
								</tr>
								</table>
							</td>
						</tr>
					</cfcase>
				</cfswitch>
			</cfoutput>

		</cfif>
	</cfif>

	<tr><td colspan="3"><cfoutput><img src="#application.paths.images#clear.gif" alt="" width="1" height="1" /></cfoutput></td></tr>

	<!--- Step 3: List of cost/funding adjustments --->
	<!--- --->
	<cfif stcContractExt.formStep eq 3>

		<cfoutput>
		<form name="frmContractExtension" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#" method="post" onSubmit="return false;">
		</cfoutput>
		<tr>
			<td colspan="3"><b>Contract Value/Funding Adjustments</b></td>
		</tr>
		<tr>
			<td></td>
			<td colspan="2">

				<table width="95%" border="0" cellpadding="0" cellspacing="0" align="left">
				<cfoutput>
				<tr>
					<th width="16%" colspan="2" nowrap>Cost Category</th>
					<th width="19%"></th>
					<th width="14%">Current ECP<br>(CY#stcContractExt.currentContractLength#)</th>
					<th width="17%">
						<cfif listFindNoCase("add,add_py",stcContractExt.scenCode)>
							New CY#evaluate(stcContractExt.currentContractLength+1)#<br>ECP Amount
						<cfelse>
							Change in ECP<br>(CY#stcContractExt.currentContractLength#)
						</cfif>
					</th>
					<th width="17%">PY#right(request.py,2)# FOP Change<br>(AAPP #request.aapp#)</th>
					<th width="17%">
						PY#right(request.py,2)# FOP Change<br>
						<cfif stcContractExt.succAAPPnum neq "">
							(AAPP #stcContractExt.succAAPPnum#)
						<cfelse>
							(no successor)
						</cfif>
					</th>
					<th></th>
				</tr>

				<!--- loop through contract types --->
				<cfset rowcounter = 0>
				<cfset successorAlert = 0>
				<cfloop list="#stcContractExt.lstServiceTypes#" index="costCat">
					<tr valign="top" <cfif rowcounter MOD 2> class="AltRow"</cfif>>
						<td nowrap rowspan="2">#stcContractExt[costCat & "_costCat"]#</td>
						<td nowrap rowspan="2">#stcContractExt[costCat & "_costCatDesc"]#</td>
						<td>Reimbursable</td>
						<td align="right">#numberformat(stcContractExt[costCat & "_R_currentECP"])#</td>
						<td align="center">
							<input type="text" name="#costCat#_R_newECP" value="#numberFormat(stcContractExt[costCat & "_R_newECP"])#"
								size="12" style="text-align:right;" readonly="true" class="inputReadonly">
						</td>
						<td align="center">
							<input type="text" name="#costCat#_R_newFOP" value="#numberFormat(stcContractExt[costCat & "_R_newFOP"])#" size="12"
							 style="text-align:right;" readonly="true" class="inputReadonly">
						</td>
						<td align="center">
							<input type="text" name="#costCat#_newSuccFOP"
								<cfif stcContractExt[costCat & "_newSuccFOP"] + stcContractExt[costCat & "_succFOPCum"] gte 0>
									value="#numberFormat(stcContractExt[costCat & "_newSuccFOP"])#"
								<cfelse>
									value="#numberFormat(evaluate(-1*stcContractExt[costCat & "_succFOPCum"]))#"
									<cfset successorAlert = 1>
								</cfif>
								size="12" style="text-align:right;" readonly="true" class="inputReadonly">
						</td>
						<td>
							<input type="hidden" name="#costCat#_succFOPCum" value="#stcContractExt[costCat & "_succFOPCum"]#">
							<!--- if successor exists, and is impacted, need to show alert if resulting FOP change will bring total below $0 --->
							<img src="#application.paths.images#alert_icon.gif" width="12" height="11" id="#costCat#_succAlert"
								alt="FOP amount was adjusted to ensure that there is no negative balance on the successor."
								<cfif successorAlert>style="visibility:visible;"<cfelse>style="visibility:hidden;"</cfif>
								>
						</td>
					</tr>

					<!--- Fee --->
					<cfif costCat neq "S">
						<tr <cfif rowcounter MOD 2> class="AltRow"</cfif>>
							<td>
								Fee
								<cfif stcContractExt.extSubMode neq "INC-EXT" and stcContractExt.extSubMode neq "DEC-SHR"> (#stcContractExt.feePercent#%)</cfif>
							</td>
							<td></td>
							<td align="center">
								<input type="text" name="#costCat#_F_newECP" value="#numberFormat(stcContractExt[costCat & "_F_newECP"])#" size="12"
									 style="text-align:right;" maxlength="13"
									 <!--- if this contract had previously not broken out O/A Fee, need to allow edits to this field --->
									 <cfif costCat eq "C1" and (not stcContractExt.OAFeeExists)>
										 onChange="formatNum(this,4,1);" maxlength="11"
									 <cfelse>
										readonly="true" class="inputReadonly"
									 </cfif>
									 >
							</td>
							<td align="center">
								<input type="text" name="#costCat#_F_newFOP" value="#numberFormat(stcContractExt[costCat & "_F_newFOP"])#" size="12"
									 style="text-align:right;"
									 <!--- if this contract adjustment affects this PY, and --->
									 <!--- had previously not broken out O/A Fee, need to allow edits to this field --->
									 <!--- if successor exists, also need to recalculate the amount of that FOP --->
									 <cfif costCat eq "C1" and (not stcContractExt.OAFeeExists) and stcContractExt.impactsPY>
										 onChange="formatNum(this,4,1);<cfif stcContractExt.succAAPPnum neq "">reCalcOAFOP(this.form);</cfif>" maxlength="11"
									 <cfelse>
										readonly="true" class="inputReadonly"
									</cfif>
									>
							</td>
							<td></td>
							<td></td>
						</tr>
					<cfelse>
						<tr>
							<input type="hidden" name="#costCat#_F_newECP" value="#stcContractExt[costCat & "_F_newECP"]#">
							<input type="hidden" name="#costCat#_F_newFOP" value="#stcContractExt[costCat & "_F_newFOP"]#">
						</tr>
					</cfif>
					<cfset rowcounter = rowcounter + 1>

				</cfloop>

				<!--- B3: vehicle --->
				<tr valign="top" <cfif rowcounter MOD 2> class="AltRow"</cfif>>
					<td nowrap>#stcContractExt.VEH_costCat#</td>
					<td nowrap>#stcContractExt.VEH_costCatDesc#</td>
					<td></td>
					<td></td>
					<td></td>
					<td align="center">
						<input type="text" name="VEH_newFOP" value="#numberFormat(stcContractExt.VEH_newFOP)#" size="12" maxlength="11"
						 style="text-align:right;"
						 <cfif stcContractExt.impactsPY>
						 	onChange="formatNum(this,4,1);"
						 <cfelse>
						 	readonly="true" class="inputReadonly"
						 </cfif>
						 >
					</td>
					<td align="center">
						<input type="text" name="VEH_newSuccFOP" value="#numberFormat(stcContractExt.VEH_newSuccFOP)#" size="12" maxlength="11"
						 style="text-align:right;"
						 <cfif (stcContractExt.impactsPY) and (succAAPPnum neq "")>
						 	onChange="formatNum(this,4,1);validateB3(this.form);"
						 <cfelse>
						 	readonly="true" class="inputReadonly"
						 </cfif>
						 >
					</td>
					<td><input type="hidden" name="VEH_succFOPCum" value="#stcContractExt.VEH_succFOPCum#"></td>
				</tr>
				<cfset rowcounter = rowcounter + 1>


				<!--- B4: CTST: show alert message if contract adjustment has AAPP ending in different PY than original --->
				<cfset originalPY = application.outility.getYear_byDate(yearType="P", baseDate="#stcContractExt.currentFinalEndDate#")>

				<cfset newPY = application.outility.getYear_byDate(yearType="P", baseDate="#stcContractExt.newFinalEndDate#")>

				<cfif originalPY neq newPY>
					<tr valign="top" <cfif rowcounter MOD 2> class="AltRow"</cfif>>
						<td nowrap>B4</td>
						<td nowrap>CTST</td>
						<td></td>
						<td colspan="5">Note: Contract will now end in PY#newPY#. Adjustments to CTST may be necessary.</td>
					</tr>
				</cfif>

				</cfoutput>

				<!--- display alerts --->
				<tr>
					<td colspan="8">
						<div style="font-size:smaller; color:red; text-align:left;">
						<cfif successorAlert>
							The amount of at least one of the successor FOPs has been adjusted so that it will not create a negative balance in the successor contract.<br>
						</cfif>
						<cfif listFindNoCase("INC-EXT,DEC-SHR",stcContractExt.extSubMode)>
							<cfif stcContractExt.modsExist>
								Mods exist for the year being extended/shortened. Additional ECP adjustments (for reimbursable amounts) will be created.<br>
							<cfelse>
								No mods exist for the year being extended/shortened. The ECP adjustments (for reimbursable amounts) will automatically take effect as a result of date changes.<br>
							</cfif>
						</cfif>
						</div>
					</td>
				</tr>
				</table>

			</td>
		</tr>



		<!---  if extending/shortening final year, and there are ongoing adj that start in that year --->
		<!--- need to display to user, and allow them to change "Full CY Amount" --->
		<cfif (stcContractExt.extSubMode eq "INC-EXT" or stcContractExt.extSubMode eq "DEC-SHR") and stcContractExt.lstOngoingFinal neq "">
			<tr>
				<td colspan="3"><b>Ongoing Adjustments Starting in the Final Contract Year</b></td>
			</tr>
			<tr>
				<td></td>
				<td colspan="2">

					<table width="95%" border="0" cellpadding="0" cellspacing="0" align="left">
					<cfoutput>
					<tr>
						<th colspan="2" nowrap>Adjustment</th>
						<th>Current "Full CY" Amount</th>
						<th>Updated "Full CY" Amount</th>
						<th></th>
					</tr>

					<!--- loop through contract types --->
					<cfset rowcounter = 0>
					<cfset successorAlert = 0>
					<cfloop list="#stcContractExt.lstOngoingFinal#" index="ai">
						<tr valign="top" <cfif rowcounter MOD 2> class="AltRow"</cfif>>
							<td>#stcContractExt[ai & "_costCat"]#</td>
							<td>#stcContractExt[ai & "_Desc"]#</td>
							<td align="center">
								<input type="text" name="#ai#__CurrentFullCYAmount" value="#numberFormat(stcContractExt[ai & "_CurrentFullCYAmount"])#"
									size="12" style="text-align:right;" readonly="true" class="inputReadonly">
							</td>
							<td align="center">
								<input type="text" name="#ai#_NewFullCYAmount" value="#numberFormat(stcContractExt[ai & "_NewFullCYAmount"])#" size="12" maxlength="11"
								 style="text-align:right;" onChange="formatNum(this,4,1);">
							</td>
							<td></td>
						</tr>

						<cfset rowcounter = rowcounter + 1>
					</cfloop>
					</cfoutput>

					<!--- display alerts --->
					<tr>
						<td colspan="8">
							<div style="font-size:smaller; color:red; text-align:left;">
							The Full Contract Year amount for these adjustments must be updated to match the new length of the final contract year. The updated values have
							been calculated, but you may change these values in the fields above.
							</div>
						</td>
					</tr>
					</table>

				</td>
			</tr>
		</cfif> <!--- extending/shortening, and there are finaly year ongoing adjustments --->


		<!--- if O/A, CTS - workload levels will need to be changed (does not apply if final year is being deleted) --->
		<cfif isDefined("stcContractExt.lstWorkloadFinal")>
			<tr>
				<td colspan="3"><b>Adjustments to Workload Levels</b></td>
			</tr>
			<tr>
				<td></td>
				<td colspan="2">

					<table width="95%" border="0" cellpadding="0" cellspacing="0" align="left">
					<cfoutput>
					<tr>
						<th></th>
						<th>Current Level(CY#stcContractExt.currentContractLength#)</th>
						<th>Change</th>
						<th>
							New Level
							(CY#iif(form.extSubMode eq "INC-ADD",evaluate(stcContractExt.currentContractLength+1),evaluate(stcContractExt.currentContractLength))#)
						</th>
					</tr>

					<!--- loop through workload types --->
					<cfset rowcounter = 0>
					<cfset successorAlert = 0>
					<cfloop list="#stcContractExt.lstWorkloadFinal#" index="wl">
						<tr valign="top" <cfif rowcounter MOD 2> class="AltRow"</cfif>>
							<td>#stcContractExt[wl & "_wl_label"]#</td>
							<td align="center">
								<input type="text" name="#wl#_WL_currentAmount" value="#numberFormat(stcContractExt[wl & "_WL_currentAmount"])#"
									size="12" style="text-align:right;" readonly="true" class="inputReadonly">
							</td>
							<td align="center">
								<input type="text" name="#wl#_WL_change" value="#numberFormat(stcContractExt[wl & "_WL_change"])#"
									size="12" style="text-align:right;" readonly="true" class="inputReadonly">
							</td>
							<td align="center">
								<input type="text" name="#wl#_WL_newAmount" value="#numberFormat(stcContractExt[wl & "_WL_newAmount"])#" size="12" maxlength="11"
								 style="text-align:right;" onChange="formatNum(this,4,1);recalcWorkload(this);">
							</td>
						</tr>
						<cfset rowcounter = rowcounter + 1>
					</cfloop>
					</cfoutput>
					</table>

				</td>
			</tr>
		</cfif> <!--- changing workload levels for O/A, CTS --->




		<tr>
			<td colspan="2" nowrap>
				<input type="checkbox" name="ckbNoCreate" id="idNoCreate" onClick="alertNoCreate(this.form);">
				<label for="idNoCreate">Do NOT create any new cost adjustments or FOPs</label>
			</td>
			<td align="right">
				<cfoutput>
				<input name="btnSubmit" type="button" value="Finalize Contract Adjustment" onclick="this.form.submit();"/>
				<input name="btnCancel" type="button" value="Cancel" onClick="window.location.href='#returnPage#?aapp=#url.aapp#';" />
				</cfoutput>
			</td>
		</tr>
		<cfoutput>
		<input type="hidden" name="formStep" value="4">
		<input type="hidden" name="formStepPrev" value="3">
		<input type="hidden" name="extMode" value="#stcContractExt.extMode#">
		<input type="hidden" name="extSubMode" value="#stcContractExt.extSubMode#">
		<input type="hidden" name="currentContractLength" value="#stcContractExt.currentContractLength#">
		<input type="hidden" name="newContractLength" value="#stcContractExt.newContractLength#">
		<input type="hidden" name="newFinalEndDate" value="#stcContractExt.newFinalEndDate#">
		<input type="hidden" name="lstServiceTypes" value="#stcContractExt.lstServiceTypes#">
		<input type="hidden" name="veh_CostCat" value="#stcContractExt.veh_CostCat#">
		<cfif stcContractExt.extSubMode eq "DEC-SHR" or stcContractExt.extSubMode eq "INC-EXT">
			<input type="hidden" name="modsExist" value="#stcContractExt.modsExist#">
			<input type="hidden" name="lstOngoingFinal" value="#stcContractExt.lstOngoingFinal#">
		</cfif>
		<cfif isDefined("stcContractExt.lstWorkloadFinal")>
			<input type="hidden" name="lstWorkloadFinal" value="#stcContractExt.lstWorkloadFinal#">
		</cfif>
		</cfoutput>
		</form>
	</cfif>


	</table>



</div>



<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

<cfif session.showDebug><cfdump var="#stcContractExt#"></cfif>