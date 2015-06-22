<!--- homeDisplayHomeFilter.cfm

	I am the headerFilter div for the jfas home page.

--->
<cfoutput>
<cffunction name="DisplayHomeFilter">
<cfset var cmd=''>


<!--- FILTER PANEL --->
<div id="homeFilter" class="homeFilter">
<div id="idHomeFilterGuts" class="homeFilterGuts">

	<table width="60%" border="0" cellspacing="0" cellpadding="0" summary="Filtering Controls for AAPP List">

		<!--- on submit, executes js to redisplay jfasDataDiv --->

		<FORM name="frmHomeFilter" id = "frmHomeFilter" action="index.cfm?jfasAction=dumpError"  method="post" >

		<tr>

		<!--- submit with search box --->

		<!--- keyword --->
		<input id="home_filterSearchWord" name="home_filterSearchWord" type="text" class="home_filterSearchWord" placeholder="Enter Keyword" value="#session.userPreferences.tMyFilterNow.home_filterSearchWord#" maxlength="100" title="Enter partial match for document number, contractor, contract number, venue, or center">
		<!--- on submit executes JS to redisplay jfasDataDiv. This action is implemented by
			$("##frmHomeFilter").on( "submit", submitFiltersPanel );
			in views/home.cfm. This executes submitFiltersPanel() to do the ajax call in displayAAPPsAjax()
		--->

		<button class="ImgOnFilterTab usetooltip btn btn-link btn-xs" btn-type="submit"
		data-toggle="tooltip" data-placement="bottom" title="Search for AAPPs using this filter" name="btnFilterContracts" style="margin: 0 2px 4px 2px;"><img src="#application.paths.images#search.png" name="filterSearch" alt="Apply these filters"  /></button>
		<!--- undock. Use link with simple text, since glyph doesn't work on button with ie8. Position this button right over the previous one.  Only one button is visible at a time --->
		<a href="##" id="btnCloseFilter" class="ImgOnFilterTab usetooltip  btn btn-link btn-xs" data-toggle="tooltip" data-placement="bottom" title="Hide this Filter Panel" onclick="closeFilterPanel();" style="margin: 0 2px 4px 2px;"><img src="#application.paths.images#arrow-left.png" name="filterSearch" alt="Hide the Filter Tab" /></a>

		</td>
		</tr>

		<tr>
		<td>

		<cfset DisplayOneFilterAsCheckBoxes(
			"cboAgreementTypeFilter"
			, "AAPP TYPE"
			, "idAgreementTypeFilter"
			, "all"
			, "All Types"
			, "#session.rstAgreementTypes#"
			, "agreementTypeCode"
			, "agreementTypeAbbrDesc"
			, "#session.userPreferences.tMyFilterNow.home_agreementTypeFilter#"
			, "toggleAgreementType();"
		)>


		<!--- fundingOffice --->
		<!--- session.roleID =3 is regional, =4 is regional admin --->
		<cfif not listfind("3,4", session.roleID)>
			<cfset DisplayOneFilterAsCheckBoxes(
				"cboFundingOfficeFilter"
				, "FUNDING OFFICE"
				, "idFundingOfficeFilter"
				, "all"
				, "All Fund Offices"
				, "#session.rstFundingOffices#"
				, "fundingOfficeNum"
				, "fundingOfficeAbbrDesc"
				, "#session.userPreferences.tMyFilterNow.home_fundingOfficeFilter#"
				, "toggleFundingOffice();"

			)>
		<cfelse>
			<cfset DisplayOneFilterAsCheckBoxes(
				"cboFundingOfficeFilter"
				, "FUNDING OFFICE"
				, "idFundingOfficeFilter"
				, "all"
				, "All Fund Offices"
				, "#session.rstDisplayFundingOffices#"
				, "fundingOfficeNum"
				, "fundingOfficeAbbrDesc"
				, "#session.userPreferences.tMyFilterNow.home_fundingOfficeFilter#"
				, "toggleFundingOffice();"

			)>
		</cfif>


		<!--- the whole banner is clickable --->
		<div class="filterRadioSetBanner" onclick="toggleContractStatus();" title="Click to collapse or open STATUS">
			STATUS
		</div>

		<div id="idContractStatusFilter" class="btn-group-vertical btn-group-sm filterSelectorCheckboxes">

			<input type="checkbox" name="cboContractStatusFilter" id="labelactive" value="active" <cfif listFindNoCase(session.userPreferences.tMyFilterNow.home_contractStatusFilter, "active") neq 0>checked</cfif> onclick="pushAAPPsAjax();" title="Click to include/exclude Active AAPPs"/>
			<label for="labelactive" class="filterRadioLabel">ACT - Active AAPPs</label><br />

			<input type="checkbox" name="cboContractStatusFilter" id="labelcurrent" value="current" <cfif listFindNoCase(session.userPreferences.tMyFilterNow.home_contractStatusFilter, "current") neq 0>checked</cfif> onclick="pushAAPPsAjax();" title="Click to include/exclude Current / Awarded"/>
			<label for="labelcurrent" class="filterRadioLabel">CUR - Current / Awarded</label><br />

			<input type="checkbox" name="cboContractStatusFilter" id="labelfuture" value="future" <cfif listFindNoCase(session.userPreferences.tMyFilterNow.home_contractStatusFilter, "future") neq 0>checked</cfif> onclick="pushAAPPsAjax();" title="Click to include/exclude Future"/>
			<label for="labelfuture" class="filterRadioLabel">FUT - Future</label><br />

			<!--- session.roleID =3 is regional, =4 is regional admin --->
			<cfif not listfind("3,4", session.roleID)>
				<input type="checkbox" name="cboContractStatusFilter" id="labelrecon" value="recon" <cfif listFindNoCase(session.userPreferences.tMyFilterNow.home_contractStatusFilter, "recon") neq 0>checked</cfif> onclick="pushAAPPsAjax();" title="Click to include/exclude Due for reconciliation" />
				<label for="labelrecon" class="filterRadioLabel">DUE - Due for reconciliation</label><br />

				<input type="checkbox" name="cboContractStatusFilter" id="labelcloseout" value="closeout" <cfif listFindNoCase(session.userPreferences.tMyFilterNow.home_contractStatusFilter, "closeout") neq 0>checked</cfif> onclick="pushAAPPsAjax();" title="Click to include/exclude Completed, but active"/>
				<label for="labelcloseout" class="filterRadioLabel">COM - Completed, but active</label><br />

			</cfif>

			<input type="checkbox" name="cboContractStatusFilter" id="labelinactive" value="inact" <cfif listFindNoCase(session.userPreferences.tMyFilterNow.home_contractStatusFilter, "inact") neq 0>checked</cfif> onclick="pushAAPPsAjax();" title="Click to include/exclude Inactive"/>
			<label for="labelinactive" class="filterRadioLabel">INA - Inactive</label><br />

			<br />
		</div> <!-- idContractStatusFilter -->

		<!--- "serviceType" and "contractType" names are confused --->
		<cfset DisplayOneFilterAsCheckBoxes(
			"cboServiceTypeFilter"
			, "SERVICE TYPE"
			, "idServiceTypeFilter"
			, "all"
			, "All Service Types"
			, "#session.rstServiceTypes#"
			, "contractTypeCode"
			, "contractTypeAbbrDesc"
			, "#session.userPreferences.tMyFilterNow.home_serviceTypeFilter#"
			, "toggleServiceType();"

		)>

		<cfset DisplayOneFilterAsSelect(
			"cboStateFilter"
			, "STATE"
			, "idStateFilter"
			, "all"
			, "All States"
			, "#application.rstStates#"
			, "state"
			, "stateName"
			, "#session.userPreferences.tMyFilterNow.home_stateFilter#"
			, "toggleState();"
		)>


		<!--- * * * start dates * * * --->
		<cfset DisplayDatePair(
			"CONTRACT START"
			, "idContractStartDate"
			, "home_ContractStartDate1"
			, "mm/dd/yyyy"
			, ""
			, ""
			, "#session.userPreferences.tMyFilterNow.home_ContractStartDate1#"
			, "home_ContractStartDate2"
			, "mm/dd/yyyy"
			, ""
			, ""
			, "#session.userPreferences.tMyFilterNow.home_ContractStartDate2#"
			, "toggleContractStartDate();"
		)>

		<!--- * * * end dates * * * --->
		<cfset DisplayDatePair(
			"CONTRACT END"
			, "idContractEndDate"
			, "home_ContractEndDate1"
			, "mm/dd/yyyy"
			, ""
			, ""
			, "#session.userPreferences.tMyFilterNow.home_ContractEndDate1#"
			, "home_ContractEndDate2"
			, "mm/dd/yyyy"
			, ""
			, ""
			, "#session.userPreferences.tMyFilterNow.home_ContractEndDate2#"
			, "toggleContractEndDate();"
		)>

		</td>
		</tr>
	</form> <!-- frmFilterContracts -->
</table>  <!--- homeFilterTable --->

</div> <!-- filterR -->
</div> <!-- homeFilter -->
</cffunction> <!--- DisplayHomeFilter --->

<!--- * * * * * subsidiary routines * * * * * --->

<cffunction name="DisplayDatePair">
	<cfargument name="divDescription">
	<cfargument name="idDiv">
	<cfargument name="fieldName1">
	<cfargument name="placeHolder1">
	<cfargument name="label1">
	<cfargument name="allValue1">
	<cfargument name="currentValue1">
	<cfargument name="fieldName2">
	<cfargument name="placeHolder2">
	<cfargument name="label2">
	<cfargument name="allValue2">
	<cfargument name="currentValue2">
	<cfargument name="toggleFunction">

	<!--- e.g. 'Contract Start' --->
	<div class="filterRadioSetBanner" onclick="#arguments.toggleFunction#;" title="Click to collapse or open #arguments.divDescription#">
		#arguments.divDescription#
	</div>
	<cfset var sFormField1 = "frmHomeFilter" & "." & arguments.fieldName1>
	<cfset var sAltText1 = "Earliest " & arguments.divDescription & " Date">
	<cfset var sFormField2 = "frmHomeFilter" & "." & arguments.fieldName2>
	<cfset var sAltText2 = "Latest " & arguments.divDescription & " Date">

	<div id="#arguments.idDiv#" class="btn-group-vertical btn-group-sm filterSelectorCheckboxes">
		<div class="filterdate"><label class="filtercheckboxLabel">
		#arguments.label1#
		<input id="#arguments.fieldName1#" name="#arguments.fieldName1#" type="text" class="home_filterDate" placeholder="#arguments.placeHolder1#" value="#arguments.currentValue1#" title="#sAltText1#">

		to
		</label></div>
		<!-- /filterdate -->

		<div class="filterdate"><label class="filtercheckboxLabel">
		#arguments.label2#
		<input id="#arguments.fieldName2#" name="#arguments.fieldName2#" type="text" class="home_filterDate" placeholder="#arguments.placeHolder2#" value="#arguments.currentValue2#" title="#sAltText2#">

		<button class="btn btn-link btn-xs usetooltip" btn-type="submit"
		data-toggle="tooltip" data-placement="top" title="Search for AAPPs using this filter"  name="btnFilterContracts"><img src="#application.paths.images#search.png" border="0" name="filterSearch" alt="Apply these filters"  width="16" height="16" /></button>

		</label></div>
		<!-- /filterdate -->
	</div> <!-- arguments.idDiv -->
</cffunction> <!--- DisplayDatePair --->

<cffunction name="DisplayOneFilterAsSelect">
	<cfargument name="fieldName">
	<cfargument name="divDescription">
	<cfargument name="idDiv">
	<cfargument name="allValue">
	<cfargument name="allDescription">
	<cfargument name="theQuery">
	<cfargument name="valueName">
	<cfargument name="valueDescription">
	<cfargument name="currentValue">
	<cfargument name="toggleFunction">

	<!--- the whole banner is clickable --->
	<div class="filterRadioSetBanner" onclick="#arguments.toggleFunction#;" title="Click to collapse or open #arguments.divDescription#">
		#arguments.divDescription#
	</div>


 	<div  id="#arguments.idDiv#" class="btn-group-vertical btn-group-sm filterSelectorCheckboxes">
 		<!--- want onChange to resubmit the filter panel frmHomeFilter  onChange="('##frmHomeFilter').submit();"--->

		<select name="#arguments.fieldName#" onChange="pushAAPPsAjax();">
			<option value="#arguments.allValue#">#arguments.allDescription#</option>

			<cfloop query=arguments.theQuery>
				<cfset thisValue = evaluate('#arguments.valuename#')>
				<cfset thisDescription = evaluate("#arguments.valueDescription#")>
				<option value="#thisValue#"
					<cfif #thisValue# eq #arguments.currentValue#>selected</cfif>>
					#thisDescription#</option>
			</cfloop>
		</select> <!--- cboAgreementTypeFilter --->
		<br />
		<br />

	</div> <!-- arguments.idDiv -->
</cffunction>

<cffunction name="DisplayOneFilterAsRadioSet">
	<cfargument name="fieldName">
	<cfargument name="divDescription">
	<cfargument name="idDiv">
	<cfargument name="allValue">
	<cfargument name="allDescription">
	<cfargument name="theQuery">
	<cfargument name="valueName">
	<cfargument name="valueDescription">
	<cfargument name="currentValue">
	<cfargument name="toggleFunction">


	<!--- the whole banner is clickable --->
	<div class="filterRadioSetBanner" onclick="#arguments.toggleFunction#;" title="Click to collapse or open this section">
		#arguments.divDescription#
	</div>


	<div id="#arguments.idDiv#" class="btn-group-vertical btn-group-sm filterSelectorCheckboxes">

		<div class="radio"><label class="filterRadioLabel">
			<input type="radio" name="#arguments.fieldName#" id="label#arguments.allValue#" value="#arguments.allValue#" <cfif arguments.allValue eq arguments.currentValue>checked</cfif> />
			#arguments.allDescription#
		 </label>
		 </div>  <!-- radio -->

		<cfloop query=arguments.theQuery>
			<cfset thisValue = evaluate('#arguments.valuename#')>
			<cfset thisDescription = evaluate("#arguments.valueDescription#")>

			<input type="checkbox"  name="#arguments.fieldName#" id="label#thisValue#" value="#thisValue#"  <cfif thisValue eq arguments.currentValue>checked</cfif> onclick="pushAAPPsAjax();" title="Click to include/exclude #thisDescription#" />
			<label for="label#thisValue#" class="filterRadioLabel">#thisDescription#</label><br />

		</cfloop>
		<br />
	</div> <!-- arguments.idDiv -->

</cffunction>

<cffunction name="DisplayOneFilterAsCheckBoxes">
	<cfargument name="fieldName">
	<cfargument name="divDescription">
	<cfargument name="idDiv">
	<cfargument name="allValue">
	<cfargument name="allDescription">
	<cfargument name="theQuery">
	<cfargument name="valueName">
	<cfargument name="valueDescription">
	<cfargument name="currentValue">
	<cfargument name="toggleFunction">

	<!--- the whole banner is clickable --->
	<div class="filterRadioSetBanner" onclick="#arguments.toggleFunction#;" title="Click to collapse or open #arguments.divDescription#">
		#arguments.divDescription#
	</div>


	<div id="#arguments.idDiv#" class="filterSelectorCheckboxes btn-group-vertical btn-group-sm ">

		<cfloop query=arguments.theQuery>
			<cfset thisValue = evaluate('#arguments.valuename#')>
			<cfset thisDescription = evaluate("#arguments.valueDescription#")>

			<input type="checkbox"  name="#arguments.fieldName#" id="label#thisValue#" value="#thisValue#"  <cfif listFindNoCase(arguments.currentValue, thisValue) neq 0>checked</cfif> onclick="pushAAPPsAjax();" title="Click to include/exclude #thisDescription#"/>
			<label for="label#thisValue#" class="filterRadioLabel">#thisDescription#</label><br />

		</cfloop>
		<br />

	</div> <!-- arguments.idDiv -->

</cffunction>


</cfoutput>


