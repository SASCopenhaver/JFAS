<cfsilent>
<!---
page: aapp_contract_award.cfm

description: display / update data for award package entry / contract estimates

revisions:
2014-11-17	mstein	Confirmation messages, and restrictions to edit form (only within CY1)

--->
<cfset request.pageID = "240" />
<cfparam name="variables.lstErrorMessages" default="" />
<cfset variables.formEditable = 0>

<cfif isDefined("form.btnSave")> <!--- form submitted --->

	<!--- save form Input --->
	<cfinvoke component="#application.paths.components#aapp_budget" method="saveContractAwardInput" formData="#form#" returnvariable="stcContractInputSaveResults" />
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
		
        <!--- get contract award input/estimate data --->
		<cfinvoke component="#application.paths.components#aapp_budget" method="getContractAwardInfo" aapp="#url.aapp#" returnvariable="rstContractAwardInfo" />
        
		<!--- q of q: get list of service types --->
		<cfquery name="qGetServiceTypes" dbtype="query">
		select	distinct contract_type_code, contract_type_desc_short, con_sort_order
		from	rstContractAwardInfo
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
		
		<cfquery name="sumID" dbtype="query">
			select	distinct con_sort_order as sum_con_sort_order, contract_budget_item_id as sum_contract_budget_item_id
			from	rstContractAwardInfo
			where	sumup=1
		</cfquery>
		
</cfif>

<!--- check to see if contract came over in migration --->
		<cfquery name="migrate" datasource="#request.dsn#">
			select	aapp_num
			from	aapp_migration
			where	aapp_num=#request.aapp#
			and		award_package=1
		</cfquery>

<cfif listFindNoCase("1,2", session.roleID) and not migrate.recordcount AND #request.curcontractyear# LTE 1>
	<cfset variables.formEditable = 1>
</cfif>
</cfsilent>

<cfif isDefined("url.dump")>
	<cfdump var="#rstContractAwardInfo#"><br /><br />
	<cfdump var="#rstAAPPWorkload#">
</cfif>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<script language="javascript1.1" type="text/javascript">
<cfoutput>

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
//
</script>
<div class="ctrSubContent">
<h2>Actual New Contract Award</h2>
<form name="form1" action="<cfoutput>#cgi.SCRIPT_NAME#?aapp=#request.aapp#</cfoutput>" method="post" onsubmit="return validateForm(this);">


	<cfif isDefined("url.save")>
		<div class="confirmList">
			<li>Information saved successfully.</li>
		</div><br />
    <cfelse>
    	<cfif #variables.formEditable# EQ 1 and (request.budgetInputType eq "A")>
            <!--- if contract is awarded, and form is editable - warn about impact to ECP --->
            <div class="errorList">
                <li>Note: Modifying the data on this form could result in changes to the Estimated Cost Profile.</li>
            </div><br />
		</cfif>
	</cfif>

    
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
		
		<!--- display contract type desc --->
		<tr>
			<cfoutput>
			<cfset contractCode = contract_type_code>
			<cfset contractCodeDesc = contract_type_desc_short>
			<cfset conSortOrder = con_sort_order>
			<cfset yearsBase = rstContractAwardInfo.years_base>
			<cfset yearsOption = rstContractAwardInfo.years_option>
			
			<td scope="row"><strong>#contractCodeDesc#</strong></td>
			<td colspan="#evaluate(rstContractAwardInfo.years_base + rstContractAwardInfo.years_option)#" ></td>
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
					<td>#WorkloadTypeDesc#</td>
				</cfif>
				<td <cfif contractYear lte yearsBase> class="AltCol"</cfif>>#value#</td>
				<cfset tempWorkType = workloadTypeCode>
			</cfoutput>		
		</tr>
		
		
		<!--- award package / estimate data --->
		<!--- q of q: select contract figures by service type --->
		<cfquery name="qGetContractAwardInfo" dbtype="query">
            select	*
            from	rstContractAwardInfo
            where	contract_type_code = '#contractCode#'
            order	by bud_sort_order, contract_year
		</cfquery>
		
		<!--- output contract estimates level data --->
		<tr>
			<cfset tempBudgetID = "">
			<cfset tempConSortOrder = "">
			<cfset sum_target_id=0>
			<cfset the_con_sort_order=con_sort_order>
			<cfloop query="sumID">
				<cfif the_con_sort_order eq sum_con_sort_order>
					<cfset sum_target_id=sum_contract_budget_item_id>
					<cfbreak>
				</cfif>
			</cfloop>
			
			<cfoutput query="qGetContractAwardInfo">
			
				<cfif tempBudgetID neq contract_budget_item_id>
					<cfif currentRow neq 1>
						</tr>
						<tr>
					</cfif>
					<td>#budget_item_desc#</td>
				</cfif>
				<td <cfif contract_Year lte rstContractAwardInfo.years_base>class="AltCol"</cfif>>
					
					<!--- don't show inflated amounts in base years --->
					<cfif (contract_Year gt yearsBase) or
						  ((contract_Year lte yearsBase) and (base_year_display eq 1))>
						
						<cfif inflated> <!--- in;fated values, display, but without form field --->
						
							
							<strong>$#numberformat(amount,",")#</strong>
							<input name="rec_#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#" type="hidden" value="0" />
						
						
						<cfelse>
							<label for="id#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#_#contractCode#" class="hiddenLabel">
								Contract Award Input, Year #contract_year#, Contract Type #contract_type_desc_short#, Item #budget_item_desc#</label>
								$<input name="rec_#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#"
							    		id="id#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#_#iif(award_edit eq 1,de("awardEdit"),de(""))#"
										type="text" 
                                        value="#numberformat(amount,",")#" 
                                        tabindex="#request.nextTabIndex#" 
                                        maxlength="15" 
								<cfif award_edit and variables.formEditable>
									onClick="this.select();"
									<cfif sum_target_id>
										onChange="groupSum('rec_#aapp_num#_#contract_year#_#con_sort_order#_','#sum_target_id#');"
									<cfelse>
										onChange="formatForm(this);"
									</cfif>	
								<cfelse>
									<!--- read-only, no entry allowed --->
									readonly="Yes" class="inputReadonly"
								</cfif>					
								/>
						</cfif>
							
					<cfelse> <!--- hidden form field - valus that shouldn't show in base years --->
					
						<input name="rec_#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#" type="hidden" value="0" />
						
					</cfif>
					
					<cfset request.nextTabIndex = request.nextTabIndex + 1>
						
				</td>
		
				<cfset tempBudgetID = contract_budget_item_id>
			</cfoutput>		
		</tr>
		
		<cfoutput>
		<!--- list "Diff from Award" row, which is diff between Total, and Total Inflated --->
		<tr>
			<td>Difference from Award</td>
			<!--- blank cell for base years --->
			<td class="AltCol" colspan="#yearsBase#">&nbsp;</td>
			<!--- loop through option years --->
			<cfloop index="i" from="1" to="#yearsOption#">
				<cfquery name="qGetDiff" dbtype="query">
				select	amount
				from	qGetContractAwardInfo
				where	contract_year = #evaluate(yearsBase + i)# and
						contract_budget_item_id in
						<cfswitch expression="#contractCode#">
						<cfcase value="A">
							(5,8)
						</cfcase>
						<cfcase value="C1">
							(9,10)
						</cfcase>
						<cfcase value="C2">
							(17,18)
						</cfcase>
						<cfcase value="S">
							(19,20)
						</cfcase>						
						</cfswitch>
						
				order	by contract_budget_item_id 
				</cfquery>
				<td>
					<cfset diffAmount = qGetDiff.amount[2] - qGetDiff.amount[1]>
					<cfif diffAmount lt 0>-</cfif>
					$#numberformat(abs(diffAmount),",")#</td>
			</cfloop>
		</tr>
		<tr><td colspan="#evaluate(rstContractAwardInfo.years_base + rstContractAwardInfo.years_option)#">&nbsp;</td></tr>
		<tr><td colspan="8" class="hrule"></td></tr>
		</cfoutput>
	</cfloop> <!--- loop through service types --->
</table>
<cfif variables.formEditable> <!--- award package hasn't been entered yet --->
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
