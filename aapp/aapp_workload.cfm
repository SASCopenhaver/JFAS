<cfsilent>
<!---
page: aapp_workload.cfm

description: displays aapp workload information

revisions:
2007-03-13	mstein	added VST slots
2007-12-12	mstein	Updated validation to make sure year end dates are not blank
2008-05-19	mstein	Updated validation - do not allow years longer than 365 (366) days
2009-10-13	mstein	Updated validation - user only gets one warning per session when changing workload levels on a Future New
2011-12-29	mstein	Added "Contract Extension" button
2012-10-14	mstein	Changed display of end date field to make it appear non-editable, when it's... not editable
--->

<cfset request.pageID = "120" />
<cfparam name="url.hidMode" default="edit">
<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default="" />


<cfif isDefined("form.btnSubmit")> <!--- form submitted --->

	<!--- save AAPP workload data --->
	<cfinvoke component="#application.paths.components#aapp_workload" method="saveAAPPWorkload" formData="#form#" returnvariable="stcWorkloadSaveResults" />
	<cfdump var="#stcWorkloadSaveResults#">
	<cfif stcWorkloadSaveResults.success>
		<!--- if save was successful, then redirect back to this page in edit mode --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&save=1" />
	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfset variables.lstErrorMessages = stcWorkloadSaveResults.errorMessages />
		<cfset variables.lstErrorFields = stcWorkloadSaveResults.errorFields />
	</cfif>	


<cfelse> <!--- first time viewing form --->
	
	
		<!--- retrieve data from database --->
		<cfinvoke component="#application.paths.components#aapp_workload" method="getWorkloadData" aapp="#url.aapp#" returnvariable="rstAAPPWorkload" />
		<!--- preload into form fields --->
		<cfset tempYear = 0>
		<cfset form["startDate__1"] = request.dateStart />
		<cfloop query="rstAAPPWorkload">
			<cfif contractYear neq tempYear>
				<cfset form["startDate__" & contractYear+1] = dateadd("d",1,yearEndDate) />
				<cfset form["endDate__" & contractYear] = yearEndDate />
				<cfset form["prevDate__" & contractYear] = yearEndDate />
			</cfif>
			<cfset form[workloadTypeCode & "__" & contractTypeCode & "__" & contractYear] = iif(value eq "",0,value) />
			<cfset tempYear = contractYear />
		</cfloop>
		
		<cfset form.txtVSTslots = rstAAPPWorkload.vstSlots>
		
		<cfif request.statusID eq 1>
			<cfset form.hidMode = "edit" />
		<cfelse>
			<cfset form.hidMode = "readonly" />
		</cfif>

</cfif>

<cfinvoke component="#application.paths.components#aapp" method="getAAPPLength" aapp="#url.aapp#" returnvariable="contractlength">
<cfinvoke component="#application.paths.components#aapp" method="getAAPPServiceTypes" aapp="#url.aapp#" returnvariable="lstServiceTypes">
<cfinvoke component="#application.paths.components#lookup" method="getWorkloadTypes" returnvariable="rstWorkloadTypes">
</cfsilent>

<!---
<cfdump var="#rstAAPPWorkload#">
<cfdump var="#form#">
<cfdump var="#lstServiceTypes#">--->



<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">


<script language="javascript">

var displayChangeWarning_slot = 1;
var displayChangeWarning_noslot = 1;

function checkValidDate(txtControl)
{
	form = txtControl.form;
	prevValueFieldName = txtControl.name.replace('end','prev');

	if (!Checkdate(txtControl.value))
		{
		alert('This is not a valid date.');
		txtControl.value = form[prevValueFieldName].value;
		}
		
}

function comparePred(future, pred, name)
{
if(name.match("SL") == "SL")
	{
	if(future != pred && displayChangeWarning_slot)
		{
		alert('Please note that this is a successor contract. Any differences between the Slots amount from the predecessor contract, and any of the Slots values in this contract could affect the New Contract Estimates. ');
		displayChangeWarning_slot = 0;
		}
	}
else
	{
	if((future.value > pred * 1.1 || future.value < pred * .9) && displayChangeWarning_noslot)
		{
		alert('Please note that this is a successor contract. Significant changes to Arrivals, Grads, or Former Enrollees should probably be accompanied by manual changes to the New Contract Estimates. ');
		displayChangeWarning_noslot = 0;
		}
	}
}

function isLeapYear (Year) {
	if (((Year % 4)==0) && ((Year % 100)!=0) || ((Year % 400)==0))
		return true;
	else
		return false;
}

function ValidateForm(form)
{
	var startDate, endDate;
	var strErrors = '';
	var strWarnings = '';
	var datesHaveChanged = 0;
	var datesAreBlank = 0;
	<cfoutput>
	// need to loop through end dates to ensure
	// that all dates are sequential
	// warnings should also be displayed if any contract year exceeds 1 calendar year
	
	startDate = new Date('#dateformat(request.dateStart, "mm/dd/yyyy")#');
	for (i=1;i<=#contractLength#;i++) {
		endDate = new Date(form['endDate__' + i].value);
		prevEndDate = new Date(form['prevDate__' + i].value);
		//alert(i + ' start: ' + startDate);
		//alert(i + ' end: ' + endDate);
		daysDifference = Math.round((endDate-startDate)/864e5)+1;
		//alert(startDate+'-'+endDate+'-'+daysDifference);
		
		if (daysDifference < 2)
			strErrors = strErrors + '   - Year ' + i + ': End Date must be later than Start Date.\n';
		
		// need to validate length of contract year - cannot exceed 365 (orr 366 if leap year)
		if (daysDifference == 366) {
			// in this date range, what year holds February?
			if (startDate.getMonth() > 1) // if contract starts after Feb (months are numbered 0,1,2,3...)
				febYear = endDate.getFullYear();
			else
				febYear = startDate.getFullYear();
			
			if (!isLeapYear(febYear))
				strErrors = strErrors + '   - Year ' + i + ': This contract year exceeds the normal contract year length.\n';
		}
			
		if (daysDifference > 366)
			strErrors = strErrors + '   - Year ' + i + ': This contract year exceeds the normal contract year length.\n';
		
		//if (daysDifference > 367)
			//strWarnings = strWarnings + '   - Year ' + i + ': Note that this contract year exceeds the normal contract year length.\n';
		
		// start date for next time through the loop should be end date + 1 day
		startDate.setTime(endDate.getTime() + 86400000);
		
		//check to see if date is blank
		if (trim(form['endDate__' + i].value) == '')
			datesAreBlank = 1;
		
		// check to see if user has changed dates
		if (form['endDate__' + i].value != form['prevDate__' + i].value)
			datesHaveChanged = 1;
	}
		
		 
	if (datesAreBlank)
		strErrors = strErrors + '   - An End Date must be entered for each contract year.\n';	
	
	// if final end date has changed,
	// it's possible that current PY FOPs might need to be adjusted (or notifications given)
	//  - if contract used to end in current PY but now doesn't
	//  - if successor used to start in current PY but now doesn't
	//  - if successor used to start in future PY, but now starts in current PY 
	// need to perform checks to see if user should be notified

	// has end date changed
	datOldContractEndDate = new Date(form['prevDate__#contractLength#'].value);
	datNewContractEndDate = new Date(form['endDate__#contractLength#'].value);
	if (datOldContractEndDate.getTime() != datNewContractEndDate.getTime()) // end date has been changed
		{
		// get PYs of both dates
		origEndingPY = getProgramYear(datOldContractEndDate);
		newEndingPY = getProgramYear(datNewContractEndDate);
		
		// if orig ending PY or new ending PY = current PY, then give alert
		if ((origEndingPY == #request.PY#) || (newEndingPY == #request.PY#))
			strWarnings = strWarnings + '   - Modifications to current program year FOPs may be necessary due to changes\n' +
									  '     in the end date of this contract.\n';	
		
		
		<cfif request.succAAPPnum neq "">
			// if successor exists
			datOrigSuccStartDate = new Date(datOldContractEndDate.getTime() + 86400000);
			origSuccStartPY = getProgramYear(datOrigSuccStartDate);
			datNewSuccStartDate = new Date(datNewContractEndDate.getTime() + 86400000);
			newSuccStartPY = getProgramYear(datNewSuccStartDate);												
			//alert(datOrigSuccStartDate + '---' + datNewSuccStartDate);
			//alert(origSuccStartPY + '---' + newSuccStartPY);
			
				//successor contract used to start in future PY, now current
				if (origSuccStartPY > #request.py# && newSuccStartPY == #request.py#) 
					strWarnings = strWarnings + '\n   - Since the successor contract now starts in the current program year, current PY FOPs\n' +
											    '     may need to be created for it.\n';
				//contract used to start in current PY, now future
				else if (origSuccStartPY == #request.py# && newSuccStartPY > #request.py#) 
					{
					strWarnings = strWarnings + '\n   - Since the successor contract is no longer scheduled to be active in the current PY,\n' +
											    '     any current PY FOPs for the successor may need to be offset.\n';
					}
					
				//date has changed, but PY didn't (both are in current PY)
				else if (origSuccStartPY == #request.py# && newSuccStartPY == #request.py#)
					strWarnings = strWarnings + '\n   - Modifications to current program year FOPs on the successor contract \n' +
											    '     may be necessary due to changes in the end date of this contract.\n';
				// if start date of the successor changed, but neither the original or new starting PY is the current PY,
				//no alerts/actions required					
				
		</cfif> <!--- successor exists? --->
		
		}
		
	if (strWarnings == '' && datesHaveChanged) // if no other warnings have been generated above, but some end dates have changed...
		strWarnings = strWarnings + '   - Any changes to the contract year end dates may have an impact on estimated costs\n' + 
									'     and FOP amounts. Please go to the Adjustments section to correct these amounts.\n';
		
	if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before saving.\n\n' + strErrors + '\n');
		return false
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
	</cfoutput>
}

function extendContract()
{
	<cfoutput>
	window.location.href='aapp_contract_extension.cfm?aapp=#request.aapp#';
	</cfoutput>

}

</script>
			
			
			
<div class="ctrSubContent">
	<h2>Workload Information</h2>
	
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
	<cfset numCols=3 + rstWorkloadTypes.recordCount>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<cfoutput>
	<form name="frmAAPPWorkload" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&radAgreementType=#request.agreementTypeCode#" method="post" onSubmit="return ValidateForm(this);">
	</cfoutput>
	<tr>
		<th scope="col" width="10%" nowrap>Contract Year</th>
		<th scope="col" width="15%">Start Date</th>
		<th scope="col" width="15%">End Date</th>
		<cfoutput query="rstWorkloadTypes">
			<th scope="col" width="15%">#workloadTypeDesc#</th>
		</cfoutput>
	</tr>
	
	<cfoutput>
	<cfloop index="i" from="1" to="#contractLength#">
		<tr>
			<td align="center">#i#</td>
			<td align="center">
				<cfset fieldName = "startDate__" & i />	
				#dateformat(form[fieldName],"mm/dd/yyyy")#
				<input type="hidden" name="#fieldName#" value="#dateformat(form[fieldName],"mm/dd/yyyy")#">
			</td>
			<td align="center">
				<cfset fieldName = "endDate__" & i />	
				<cfif (request.budgetInputType neq "A")> <!--- if contract is awarded, dates can't be changed --->
					<input type="text" name="#fieldName#" value="#dateformat(form[fieldName],"mm/dd/yyyy")#" size="12" maxlength="10"	
						onChange="checkValidDate(this);" tabindex="#request.nextTabIndex#"
						<cfif listFindNoCase(variables.lstErrorFields, fieldName)>
							class="errorField"
						</cfif>
						>
					<cfset fieldName = "prevDate__" & i />	
					<input type="hidden" name="#fieldName#" value="#dateformat(form[fieldName],"mm/dd/yyyy")#">
				<cfelse>
					#dateformat(form[fieldName],"mm/dd/yyyy")#
				</cfif>
				<cfset request.nextTabIndex = request.nextTabIndex + 1> 
			</td>
			<cfloop query="rstWorkloadTypes">
				<td align="center">
					<cfset fieldName = workLoadTypeCode & "__" & contractTypeCode & "__" & i />
					<label for="id#fieldName#" class="hiddenLabel">Workload Data Input, Year #i#, Type #workLoadTypeCode#</label>
					<input type="text" name="#fieldName#" id="id#fieldName#" size="10" maxlength="6" style="text-align:right"
					<cfif structKeyExists(form,fieldName)>
						value="#numberformat(form[fieldName])#"
					<cfelse>
						value="0"
					</cfif>
					<cfif listContains(lstServiceTypes,contractTypeCode)>
						onBlur="formatNum(this,2,1);"
					<cfelse>
						readonly class="inputReadonly"
					</cfif>
					<cfif form.hidMode eq "readonly">
						readonly class="inputReadonly"
					</cfif>
					<cfif request.predaappnum neq '' and request.budgetInputType is 'F'>
						onChange="comparePred(this, #form[fieldname]#, '#fieldname#');"
					</cfif>
					tabindex="#request.nextTabIndex#">
					<cfset request.nextTabIndex = request.nextTabIndex + 1> 
				</td>
			</cfloop>
		</tr>
	</cfloop>
			
	</table>
	
	<p></p>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<tr>
		<th width="41%"></th>
		<th width="15%" scope="col">CTST Slots</th>
		<th width="44%"></th>
	</tr>
	<tr>
		<td></td>
		<td align="center">
			<input type="text" name="txtVSTslots" id="idVSTslots" size="10" maxlength="6" style="text-align:right"
			value="#numberformat(form.txtVSTslots)#"
			<cfif form.hidMode eq "readonly">
			readonly class="inputReadonly"
			<cfelse>
			onBlur="formatNum(this,2,1);"
			</cfif>
			tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1> 
		</td>
		<td></td>
	</tr>
	</table>
	</cfoutput>
	
	
	
	<cfif form.hidMode neq "readonly">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="red">
		<tr valign="top">
			<td>
				<!--- if awarded (otherwise user can change years/dates through setup and workload pages --->
				<cfif listfind("1,2", session.roleID) and request.budgetinputtype eq "A">
					<div class="buttons" style="text-align:left">
					<input type="button" name="btnContractExtension" value="Contract Extension / Early Termination" onClick="extendContract();" style="text-align:center;width:25em"/>
					</div>
				</cfif>
			</td>
			<td>
				<div class="buttons">
				<cfoutput>
				<input type="hidden" name="hidAAPP" value="#url.aapp#">
				<input type="hidden" name="hidMode" value="#form.hidMode#" />	
				<input name="btnSubmit" type="submit" value="Save" />
				<input name="btnClear" type="button" value="Reset" onClick="window.location.href='#cgi.SCRIPT_NAME#?aapp=#url.aapp#';" />
				</cfoutput>
				</div>
			</td>
		</tr>
		</table>		
	</cfif>
	</form>
</div>



<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

