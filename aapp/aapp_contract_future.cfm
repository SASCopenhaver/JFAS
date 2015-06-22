<cfsilent>
<!---
page: aapp_contract_future.cfm

description: display / update data for future new contract estimates

revisions:
2008-07-10	mstein	Defect: Save/Cancel buttons were showing to all users, should only be showing to admin & budget unit
2010-10-13	mstein	Adjusted formatting on "Future New Report" button
2011-01-25	mstein	Fixed 508 Issue - label on inputAlertMessage text box
--->
<cfset request.pageID = "230" />
<cfparam name="variables.lstErrorMessages" default="" />
<cfset variables.formEditable = 0>
<cfset variables.slotsChange = 0>

<cfif isDefined("form.btnSave")> <!--- form submitted --->

	<!--- save future estimate Input --->
	<cfinvoke component="#application.paths.components#aapp_budget" method="saveFutureContractInput" formData="#form#" returnvariable="stcContractInputSaveResults" />
	<cfif stcContractInputSaveResults.success>
		<!--- if save was successful, then redirect back to this page in edit mode --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#stcContractInputSaveResults.aappNum#&save=1" addtoken="no" />
	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfabort>
		<cfset variables.lstErrorMessages = stcContractInputSaveResults.errorMessages />
	</cfif>
<cfelse>
		<!--- retrieve data from database --->
		
		<!--- get future contract input/estimate data --->
		<cfinvoke component="#application.paths.components#aapp_budget" method="getFutureNewContractEstimates" aapp="#url.aapp#" returnvariable="rstFutureEstimates" />
		<!--- q of q: get list of service types --->
		<cfquery name="qGetServiceTypes" dbtype="query">
		select	distinct contract_type_code, contract_type_desc_short, input_future_type_code, con_sort_order
		from	rstFutureEstimates
		order	by con_sort_order 
		</cfquery>
		
		<!--- get year start/end and workload levels --->
		<cfinvoke component="#application.paths.components#aapp_workload" method="getWorkloadData" aapp="#url.aapp#" returnvariable="rstAAPPWorkload" />
		<!--- q of q: get year start/end dates --->
		<cfquery name="qGetYears" dbtype="query">
		select	distinct contractYear, yearEndDate, yearStartDate, cyDays
		from	rstAAPPWorkload
		order	by contractYear
		</cfquery>
		
		<!--- get list of future input types --->
		<cfinvoke component="#application.paths.components#lookup" method="getFutureInputTypes" returnvariable="rstFutureInputTypes" />
		
		<!--- if predecessor exists --->		
		<cfif request.predaappnum neq "">
		
			<!--- get list of service types on the predecessor --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPServiceTypes" aapp="#request.predaappnum#" returnvariable="lstPredServiceTypes" />
			
			<cfif listContainsNoCase(lstPredServiceTypes, "A")>
				<!--- check to see if slot levels on this AAPP vary from final year of predecessor --->
				<cfinvoke component="#application.paths.components#aapp_workload" method="slotsChange" aapp="#url.aapp#" returnvariable="slotsChange" />
			</cfif>
			
		<cfelse>
			<cfset lstPredServiceTypes = "">
		</cfif>
		
		<cfquery name="sumID" dbtype="query">
			select	distinct con_sort_order as sum_con_sort_order, contract_budget_item_id as sum_contract_budget_item_id
			from	rstFutureEstimates
			where	sumup=1
		</cfquery>
		
		
		
		<!--- check to see if contract came over in migration --->
		<cfquery name="migrate" datasource="#request.dsn#">
			select	aapp_num
			from	aapp_migration
			where	aapp_num=#request.aapp#
			and		award_package=1
		</cfquery>
</cfif>

<cfif listFindNoCase("1,2", session.roleID) and (not request.budgetInputType neq "F")>
	<cfset variables.formEditable = 1>
</cfif>

</cfsilent>

<cfif isDefined("url.dump")>
	<cfdump var="#rstFutureEstimates#"><br /><br />
	<cfdump var="#rstAAPPWorkload#">
	<cfdump var="#slotsChange#">

	<cfquery name="sd" datasource="#request.dsn#">
	select contract.fun_getconestratio(5371) as foo
	from dual
	</cfquery>
	
	<br />
	<cfdump var="#sd#">

</cfif>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<script language="javascript1.1" type="text/javascript">
<cfoutput>
var rate=#rstFutureEstimates.ratio#;
var formChanged=0;
</cfoutput>
function groupSum(eleName,target_id) {
	var sum=0, j=0;
	for (i=0;i<document.form1.elements.length; i++) {
		if (document.form1.elements[i].name.indexOf(eleName)!=-1) {
			if (document.form1.elements[i].name!=eleName+target_id) {
				document.form1.elements[i].value=trim(document.form1.elements[i].value);
				if (!isInteger(stripCharsInBag(document.form1.elements[i].value,','))) {
					alert("You must enter a non-negative whole number.");
					document.form1.elements[i].value=0;
					document.form1.elements[i].focus();
				}
				sum+=parseInt(stripCharsInBag(document.form1.elements[i].value,','));
				formatNum(document.form1.elements[i]);
			}
			else {
				j=i;
			}
		}
	}
	document.form1.elements[j].value=sum;
	formatNum(document.form1.elements[j]);
}

function formatForm (s) {
	s.value=trim(s.value);
	if (!isInteger(stripCharsInBag(s.value,','))) {
		alert("You must enter a non-negative whole number.");
		s.value=0;
		s.focus();
	}
	formatNum(s);
}

function validateForm (s) {
	for (i=0;i<s.elements.length; i++) {
		if (s.elements[i].name.indexOf('rec_')!=-1) {
			if (!isInteger(stripCharsInBag(s.elements[i].value,','))) {
				//alert("You must enter a positive whole number.");
				s.elements[i].value=0;
				s.elements[i].focus();
				return false;
			}
		}
	}	
	return true;
}



function setFieldsEditable (conSort, newInputType) {
	//function that sets form fields editable or not, based on user slection of "input type"
	
	oldInputType = document.form1.elements['hidInputType_' + conSort].value;
	
	// this is onClick - so only proceed if user changed intput type
	if (oldInputType != newInputType) {
		
		formChange();
		for (i=0;i<document.form1.elements.length; i++) {
			//split form element name into array
			tmpArray = document.form1.elements[i].name.split("_");
			
			if ((tmpArray[0] == 'rec') && (tmpArray[3] == conSort)) {
				
				if (newInputType == 'P') {
					// setting to predecessor... all fields read-only
					document.form1.elements[i].value = '0';
					document.form1.elements[i].readOnly=true;
					document.form1.elements[i].className='inputReadonly_modified';
				
				}
				
				if (newInputType == 'I') {
					// moving to Initial Year entry
					
					//reset all fields to zero if moving from predecessor, otherwise leave year 1 as is
					if (tmpArray[2] > 1)
						document.form1.elements[i].value = '0';
					
					// set style of all "non-editable" fields
					if (document.form1.elements[i].id.indexOf('futureEdit') == -1) {
						document.form1.elements[i].readOnly=true;
						if (tmpArray[2] > 1)
							document.form1.elements[i].className='inputReadonly_modified';
						else
							document.form1.elements[i].className='inputReadonly';
					}
					else {
						if (tmpArray[2] == 1) {
							document.form1.elements[i].readOnly=false;
							document.form1.elements[i].className='inputEditable';
						}
						else
							document.form1.elements[i].className='inputReadonly_modified';
						
					}
				
				}
				
				if (newInputType == 'A') {
					// moving to All Year entry					
					if (document.form1.elements[i].id.indexOf('futureEdit') != -1) {
						document.form1.elements[i].readOnly=false;
						document.form1.elements[i].className='inputEditable';
					}
					else {
						document.form1.elements[i].readOnly=true;
						document.form1.elements[i].className='inputReadonly';
					}
				
				}				
			
			}				
	
		}
		
		document.form1.elements['hidInputType_' + conSort].value = newInputType;
		if ((newInputType == 'P') || (newInputType == 'I'))
			document.form1.elements['inputAlertMessage_' + conSort].value = 'SAVE form to view estimates';
		else
			document.form1.elements['inputAlertMessage_' + conSort].value = '';
		
	}
	
	
}


function proRate (s,CTC) {
	// populates Fee based on percentage of reimbursable
	var target=s.name.substring(0,s.name.lastIndexOf('_'));
	// find the next element in order that shares the same element name, minus the budget item id.
	// this assumes that the Fee line will always follow the reimbursable line.
	for (i=0;i<document.form1.elements.length; i++) {
		if (document.form1.elements[i].name.indexOf(target)!=-1 && (document.form1.elements[i].name != s.name)) {
			document.form1.elements[i].value=Math.round(parseInt(stripCharsInBag(s.value,','))*rate);
			break;
		}
	}
}

function formChange() {

	document.frmReportCriteria.btnFutureNewReport.disabled = 1;

}
</script>


<style type="text/css">
input.inputReadonly {
	border: 1px solid #999999;
	background-color: transparent;
	color: #000000;
}
input.inputReadonly_modified {
	border: 1px solid #999999;
	background-color: transparent;
	color: #FF0000;
	}


</style>

<div class="ctrSubContent">
<cfoutput>


<h2>Future New Contract Estimates</h2>

<form name="frmReportCriteria" action="#application.paths.reportdir#reports.cfm?rpt_id=19&aapp=#request.aapp#" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
	<input name="radReportFormat" type="hidden" value="application/pdf" />
	<input name="aapp" type="hidden" value="#request.aapp#" />
	<div class="btnRight"><input name="btnFutureNewReport" type="submit" value="Future New Report"></div>
</form>

<cfinclude template="#application.paths.includes#error_list.cfm">
</cfoutput>
<form name="form1" action="#cgi.SCRIPT_NAME#?aapp=#request.aapp#" method="post" onsubmit="return validateForm(this);">
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTblCol">
	<tr>
		<th scope="col" style="font-weight:normal;text-align:left;">
			Contract Year<br />
			Start Date<br />
			End Date<br />
			No. of days
		</th>
		<!--- loop through contract years, display start/end dates --->
		<cfoutput query="qGetYears">
		<th scope="col">
			Year #contractYear#<br/>
			#dateformat(yearStartDate, "mm/dd/yyyy")#
			#dateformat(yearEndDate, "mm/dd/yyyy")#<br/>
			<span style="font-weight: normal">#cyDays#</span>
		</th>
		</cfoutput>
	</tr>

	<!--- loop through contract type list --->
	<cfloop query="qGetServiceTypes">
		
		<!--- display contract type desc, and method of future input (predecessor, initial year, all year) --->
		<tr>
			<cfoutput>
			<cfset contractCode = contract_type_code>
			<cfset contractCodeDesc = contract_type_desc_short>
			<cfset conSortOrder = con_sort_order>
			<cfset inputType = input_future_type_code>
			
			<td scope="row"><strong>#contractCodeDesc#</strong></td>
			<td colspan="#evaluate(rstFutureEstimates.years_base + rstFutureEstimates.years_option)#" >
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				
				<cfloop query="rstFutureInputTypes">
					
					<input type="radio" name="input_type_#conSortOrder#" id="id_#contractCode#_#inputFutureTypeCode#_input_type" value="#inputFutureTypeCode#"
						onClick="setFieldsEditable('#conSortOrder#','#inputFutureTypeCode#');" style="width:auto;" tabindex="#request.nextTabIndex#" 
						<cfif inputFutureTypeCode eq inputType>checked</cfif>
						<cfif (
								(inputFutureTypeCode eq "P") and
								 ((not listFindNoCase(lstPredServiceTypes,contractCode) or (contractCode eq "A" and slotsChange))))

								or (not variables.formEditable)>
						
							disabled 						
						
						</cfif>/>
					<label for="id_#contractCode#_#inputFutureTypeCode#_input_type" style="font-weight:normal">#inputFutureTypeDesc#</label>
					&nbsp;&nbsp;
					<cfset request.nextTabIndex = request.nextTabIndex + 1>	
			  
				</cfloop>
				
				<input type="hidden" name="hidInputType_#conSortOrder#" value="#inputType#" />
				<!---<span id="inputAlertMessage_#conSortOrder#" style="position:absolute;color:##FF0000;">123</span>--->
				<input name="inputAlertMessage_#conSortOrder#" id="id_inputAlertMessage_#conSortOrder#" type="text"
					style="text-align:right;
						   color:##FF0000;
						   border: 0px;
						   background-color: transparent;
						   width:215px" />
				<label for="id_inputAlertMessage_#conSortOrder#" class="hiddenLabel">
						Alert Message for #contractCodeDesc#. Ignore if blank.</label>
			</td>
			</cfoutput>
		</tr>
		
		<!--- workload levels for this service type --->
		<!--- q of q: select workload numbers by service type --->
		<cfquery name="qGetWorkLoadByType" dbtype="query">
		select	*
		from	rstAAPPWorkload
		where	contractTypeCode = '#contractCode#'
		order	by workloadTypeCode, contractYear
		</cfquery>
		
		<!--- output workload level data --->
		<tr>
			<cfset tempWorkType = "">
			<cfoutput query="qGetWorkLoadByType">
				<cfif tempWorkType neq workloadTypeCode>
					<cfif currentRow neq 1>
						</tr><tr>
					</cfif>
					<td>
						#WorkloadTypeDesc#<cfif contractCode eq "A" and slotsChange>*</cfif>
					</td>
				</cfif>
				<td <cfif contractYear lte rstFutureEstimates.years_base>class="AltCol"</cfif>>#value#</td>
				<cfset tempWorkType = workloadTypeCode>
			</cfoutput>		
		</tr>
		
		
		<!--- future estimate data --->
		<!--- q of q: select contract estimate figures by service type --->
		<cfquery name="qGetFutureEstimates" dbtype="query">
		select	*
		from	rstFutureEstimates
		where	contract_type_code = '#contractCode#'
		order	by bud_sort_order, contract_year
		</cfquery>
		
		<!--- output contract estimates level data --->
		<tr>
			<cfset tempBudgetID = "">
			<cfset sum_target_id=0>
			<cfset the_con_sort_order=con_sort_order>
			<cfloop query="sumID">
				<cfif the_con_sort_order eq sum_con_sort_order>
					<cfset sum_target_id=sum_contract_budget_item_id>
					<cfbreak>
				</cfif>
			</cfloop>
			
			<cfoutput query="qGetFutureEstimates">
			
				<cfif tempBudgetID neq contract_budget_item_id>
					<cfif currentRow neq 1>
						</tr><tr>
					</cfif>
					<td>
						#budget_item_desc#
						<cfif listFindNoCase("7,16,23",contract_budget_item_id)>
						&nbsp;(#evaluate(ratio*100)#%)
						</cfif>
					</td>
				</cfif>
				<td <cfif contract_year lte rstFutureEstimates.years_base>class="AltCol"</cfif>>
					
					<label for="id#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#_#contractCode#" class="hiddenLabel">
						New Contract Input, Year #contract_year#, Contract Type #contract_type_desc_short#, Item #budget_item_desc#</label>
					$<input name="rec_#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#"
							id="id#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#_#iif(future_edit eq 1,de("futureEdit"),de(""))#"
							type="text" value="#numberformat(amount,",")#" tabindex="#request.nextTabIndex#" maxlength="15"
						
						<cfif inputType eq "P" or (not variables.formEditable)>
							<!--- predecessor, or if contract has been awarded, no entry allowed --->
							readonly="Yes" class="inputReadonly"
						</cfif>				
					
						<!---<cfif future_edit and (inputType eq "A" or ((inputType eq "I") and (contract_year eq 1)))>--->
						<cfif future_edit>
							<!---onClick="this.select();"---> onChange="formChange();proRate(this,'#contract_type_code#');
							<cfif sum_target_id>
								groupSum('rec_#aapp_num#_#contract_year#_#con_sort_order#_','#sum_target_id#');
							<cfelse>
								formatForm(this);
							</cfif>"	
						</cfif>					
						<cfif (not future_edit) or ((inputType eq "I") and (contract_year neq 1))>
							<!--- read-only, no entry allowed --->
							readonly="Yes" class="inputReadonly"							
						</cfif>
						/>
						
						<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</td>
		
				<cfset tempBudgetID = contract_budget_item_id>
			</cfoutput>		
		</tr>
		
		
		
		<cfoutput>
		<tr>
			<td colspan="#evaluate(rstFutureEstimates.years_base + rstFutureEstimates.years_option)#" align="left">
				<cfif contractCode eq "A" and slotsChange>
					<div style="font-size:smaller; color:##FF6666; text-align:left;">
					&nbsp;&nbsp;&nbsp;* slot levels in this AAPP vary from final year of predecessor -
					estimation based on predecessor costs is not allowed
					</div>	
				<cfelseif contractCode eq "C1" and inputType eq "P">
					<div style="font-size:smaller; color:##FF6666; text-align:left;">
					&nbsp;&nbsp;&nbsp;Note: Please confirm the fee calculation
					</div>	
				<cfelse>
					&nbsp;
				</cfif>
			</td>
		</tr>
		<tr><td colspan="8" class="hrule"></td></tr>
		</cfoutput>
	</cfloop> <!--- loop through service types --->
	
</table>
	
	
<cfif variables.formEditable> <!--- show Save/Cancel buttons? --->
	<div class="buttons">
		<cfoutput>
		<input name="btnSave" type="submit" value="Save" />
		<input name="btnClear" type="button" value="Reset" onClick="window.location.href=window.location.href" >
		<input type="hidden" name="hidConSortList" value="#valuelist(qGetServiceTypes.con_sort_order)#" />
		</cfoutput>
	</div>
</cfif>
</form>
</div>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">