<cfsilent>
<!---
page: reports_criteria_template.cfm

description: root page of reports criteria section

revisions:
2006-12-26	yjeng	For the report Fiscal Plan, only apply to agreementTypeCode in ('DC','GR')
2007-01-09	rroser	Allow regional users to only generate reports for their region
2007-02-08	mstein	modified queries for AAPP nums to improve performance (defect 137)
2007-03-30  abai    Revised for defect 139 -- capitalize "Funding Office" On the javascript message.
2007-05-15  abai	Add new case 13, and 17
2007-05-24  abai    Add for case 13 and 17.
2007-05-24  abai    Add for case 20.
2007-08-29  abai    Add for case 21.
2007-09-13  abai	Add for case 22
2007-10-01	rroser	Add case 23
2007-10-23  abai    Make smallbusiness sub category not required.
2007-11-26  abai    Revised for allowing open more report windows.
2014-10-23	mstein	Modified - FOP / Allocation Recon (id 28) to not include CCCs in funding office drop-down)
--->
<cfset request.pageID="0">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "Reports">
<!--- Set session.region to mimic regional user --->

<!---	<cfset session.roleid = 3>
	<cfset session.region = 3>--->

<!--- set funding office filter for regional users --->
<cfif session.roleid neq 3 and session.roleid neq 4>
	<cfset fundingOfficeFilter = 0>
<cfelse>
	<cfset fundingOfficeFilter = session.region>
</cfif>
<cfif not isDefined("url.rpt_id")>
	<cflocation url="reports_main.cfm">
</cfif>


<cfswitch expression="#url.rpt_id#">
	<cfcase value="1">
		<!---Report: Budget Authority Requirements by AAPP--->
		<cfset request.pageID=1010>
	</cfcase>
	<cfcase value="2">
		<!---Report: Estimated Cost Profile--->
		<cfset request.pageID=1020>
		<cfinvoke component="#application.paths.components#lookup" method="getServiceTypes" displayType="ecp" returnvariable="rstCostCat">
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				agreementType="DC,GR"
				returnvariable="rstAAPP">
		<cfelse>  <!--- limit AAPPs from that region for region users --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				agreementType="DC,GR"
				fundingOfficeNum = "#session.region#"
				returnvariable="rstAAPP">
		</cfif>


	</cfcase>
	<cfcase value="3">
		<!---Report: Fiscal Plan--->
		<cfset request.pageID=1030>
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				agreementType="DC,GR"
				returnvariable="rstAAPP">
		<cfelse>  <!--- limit AAPPs from that region for region users --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				agreementType="DC,GR"
				fundingOfficeNum = "#session.region#"
				returnvariable="rstAAPP">
		</cfif>
	</cfcase>
	<cfcase value="4"><!--- get program years for drop down and list of AAPPs to test against --->
		<!---Report: FOP Allocations (by AAPP)--->
		<cfset request.pageID=1040>
		<cfinvoke component="#application.paths.components#lookup" method="getPY" sortDir="desc" returnvariable="rstPY">
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				returnvariable="rstAAPP">
		<cfelse>  <!--- limit AAPPs from that region for region users --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				fundingOfficeNum = "#session.region#"
				returnvariable="rstAAPP">
		</cfif>
	</cfcase>
	<cfcase value="5"><!--- get funding offices and program years for dropdowns --->
		<!---Report: FOP Listing--->
		<cfset request.pageID=1050>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" returnvariable="rstFundingOffices">
		<cfinvoke component="#application.paths.components#lookup" method="getPY" sortDir="desc" returnvariable="rstPY">
	</cfcase>
	<cfcase value="6">
		<!---Report: Budget Authority Requirements by Funding Office--->
		<cfset request.pageID=1060>
	</cfcase>
	<cfcase value="7">
		<!---Report: Footprint Contractor report--->
		<cfset request.pageID=1090>
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				returnvariable="rstAAPP">
		<cfelse>  <!--- limit AAPPs from that region for region users --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				fundingOfficeNum = "#session.region#"
				returnvariable="rstAAPP">
		</cfif>
	</cfcase>
	<cfcase value="8">
		<!---Report: CCC BA Transfer report--->
		<cfset request.pageID=1070>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#fundingOfficeFilter#" fundingOfficeType="FED" returnvariable="rstFundingOffices">
	</cfcase>
	<cfcase value="9">
		<!---Report: Program Operating Plan Detail report--->
		<cfset request.pageID=1100>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices"  fundingOfficeType="FED" returnvariable="rsFundingOffices">
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices"  fundingOfficeType="DOL" returnvariable="rstDOLRegion">
		<cfelse>
			<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices"  fundingOfficeNum="#fundingOfficeFilter#" returnvariable="rstDOLRegion">
		</cfif>
		<cfinvoke component="#application.paths.components#lookup" method="getPY" sortDir="desc" returnvariable="rstPY">
	</cfcase>
	<cfcase value="10">
		<!---Report: FOP CCC Budget report--->
		<cfset request.pageID=1080>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices"  fundingOfficeType="FED" returnvariable="rsFundingOffices">
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices"  fundingOfficeType="DOL" returnvariable="rstDOLRegion">
		<cfelse>
			<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices"  fundingOfficeNum="#fundingOfficeFilter#" returnvariable="rstDOLRegion">
		</cfif>
		<cfinvoke component="#application.paths.components#lookup" method="getPY" sortDir="desc" returnvariable="rstPY">
	</cfcase>
	<cfcase value="11">
		<!---Report: Program Year Initial CCC Budget worksheet (by Agency) report--->
		<cfset request.pageID=1140>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices"  fundingOfficeType="FED" returnvariable="rsFundingOffices">
		<cfinvoke component="#application.paths.components#lookup" method="getPY" sortDir="desc" returnvariable="rstPY">
	</cfcase>
	<cfcase value="12">
		<!--- Report: VST Worksheet --->
		<cfset request.pageID=1110>
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				agreementType="DC,GR"
				returnvariable="rstAAPP">
		<cfelse>  <!--- limit AAPPs from that region for region users --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				agreementType="DC,GR"
				fundingOfficeNum = "#session.region#"
				returnvariable="rstAAPP">
		</cfif>
		<cfinvoke component="#application.paths.components#lookup" method="getPastPY" sortDir="desc" returnvariable="rstPY">
	</cfcase>
	<cfcase value="13">
		<!---Report: Budget Status--->
		<cfset request.pageID=1150>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices"  fundingOfficeType="DOL" returnvariable="rsFundingOffices">

	</cfcase>
	<!---  14 for Contract Close Out --->
	<!---  15 for Fop batch process DOL --->
	<!---  16 for Fop batch process CCC --->

	<cfcase value="17">
		<!---Report: OA/CTS Annualized Workload/Cost Under Current Contracts--->
		<cfset request.pageID=1160>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices"  fundingOfficeTypeNot="FED" returnvariable="rsFundingOffices">
	</cfcase>
	<!---  18 for Fop batch process CCC --->
	<!---  19 for Fop Future NEw--->
	<cfcase value="20">
		<!---Report: Program Year Initial CCC Budget (by Center)--->
		<cfset request.pageID=1145>
		<cfinvoke component="#application.paths.components#lookup" method="getWorksheetPY" returnvariable="rstPY">
	</cfcase>
	<!--- 21 for Footprint Transaction--->
	<cfcase value="21">
		<!---Report: Footprint Transaction--->
		<cfif isDefined("url.trans") and url.trans eq "O">
			<cfset request.pageID=1170>
		<cfelseif isDefined("url.trans") and url.trans eq "P">
			<cfset request.pageID=1180>
		<cfelseif isDefined("url.trans") and url.trans eq "C">
			<cfset request.pageID=1190>
		</cfif>
		<cfset request.trans_type = url.trans>
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				returnvariable="rstAAPP">
		<cfelse>  <!--- limit AAPPs from that region for region users --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				fundingOfficeNum = "#session.region#"
				returnvariable="rstAAPP">
		</cfif>
	</cfcase>

	<!---  22 for Small Business report--->
	<cfcase value="22">
		<!---Report: Small Business report--->
		<cfset request.pageID=1200>
		<cfinvoke component="#application.paths.components#lookup" method="getAgreementTypes" returnvariable="rsAgreementTypes">
		<cfinvoke component="#application.paths.components#lookup" method="getSmallBusTypes" returnvariable="rsSmallBusinessTypes">
		<cfinvoke component="#application.paths.components#lookup" method="getOrganizationTypes" catView="combo" returnvariable="rsOrgTypes">
		<cfinvoke component="#application.paths.components#lookup" method="getFootprintFY" returnvariable="rsFY">
	</cfcase>

	<cfcase value="23">
		<!--- Report: Footprint Transaction Discrepancy --->
		<cfset request.pageID=1210>
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				returnvariable="rstAAPP">
		<cfelse>  <!--- limit AAPPs from that region for region users --->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing"
				fundingOfficeNum = "#session.region#"
				returnvariable="rstAAPP">
		</cfif>
	</cfcase>
	<cfcase value="24"> <!--- outyear --->
		<cfset request.pageID=1220>
		<cfinvoke component="#application.paths.components#lookup" method="getServiceTypes" displayType="ecp" returnvariable="rstCostCat">
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeTypeNot="FED" fundingOfficeNum="#fundingOfficeFilter#" returnvariable="rstFundingOffice">
	</cfcase>

	<cfcase value="25"> <!--- workload change list --->
		<cfset request.pageID=1230>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeType="DOL" returnvariable="rsFundingOffices">
		<cfinvoke component="#application.paths.components#lookup" method="getWorkloadTypes" returnvariable="rsWorkloadTypes">
	</cfcase>

	<cfcase value="27"> <!--- NCFMS / FOP Recon --->
		<cfset request.pageID=1240>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeTypeNOT="FED" returnvariable="rstFundingOffices">
		<cfinvoke component="#application.paths.components#lookup" method="getPY" sortDir="desc" returnvariable="rstPY">
	</cfcase>

	<cfcase value="28"> <!--- FOP / Allocation Recon --->
		<cfset request.pageID=1250>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeTypeNot="FED" returnvariable="rstFundingOffices">
		<cfinvoke component="#application.paths.components#lookup" method="getPY" sortDir="desc" returnvariable="rstPY">
	</cfcase>
	<cfcase value="29"> <!--- Allotment / Obligation / Allocation Recon (National) --->
		<cfset request.pageID=1260>
		<cfinvoke component="#application.paths.components#lookup" method="getPY" sortDir="desc" returnvariable="rstPY">
	</cfcase>
	<cfcase value="30"> <!--- Allotment / Obligation / Allocation Recon (AAPP) --->
		<cfset request.pageID=1265>
		<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" returnvariable="rstFundingOffices">
		<cfinvoke component="#application.paths.components#lookup" method="getPY" sortDir="desc" returnvariable="rstPY">
	</cfcase>



</cfswitch>
</cfsilent>


<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">
<script language="javascript1.1" type="text/javascript">
	var strErrors = '';
	function ErrorMsg (s) {
		if (s.length==0) {
			strErrors = '';
			//window.open('about:blank','location=no,resizable=yes,scrollbars=yes,status=yes');
			return true;
		}
		else {
			alert('The following problems have occurred. Please fix these errors before continuing.\n\n' + s + '\n');
			strErrors = '';
			return false;
		}
	}
<cfswitch expression="#url.rpt_id#">
	<cfcase value="1">
		function validateForm (s) {
			if (document.frmReportCriteria.cboFundingOffice.selectedIndex == 0)
				{
				strErrors = strErrors + '  - You must choose a Funding Office.\n';
				}
			return ErrorMsg(strErrors);
		}
	</cfcase>
	<cfcase value="2">

		var AAPPS=new Array;
		<cfoutput query="rstAAPP">
		AAPPS[#evaluate(currentrow-1)#]=#aappNum#;
		</cfoutput>

		function validateForm (s) {
			for (i=0; i<AAPPS.length;i++) {
				if (AAPPS[i]==s.AAPP.value) {
					break;
				}
			}
			if (i==AAPPS.length) {
				strErrors = strErrors + '  - A valid AAPP number must be entered.\n';
			}
			for (i=0; i<s.chkCostCat.length;i++) {
				if (s.chkCostCat[i].checked) {
					break;
				}
			}
			if (i==s.chkCostCat.length) {
				strErrors = strErrors + '  - At least one Cost Category must be entered.\n';
			}
			return ErrorMsg(strErrors);
		}
	</cfcase>
	<cfcase value="3,4,12">
		var AAPPS=new Array;
		<cfoutput query="rstAAPP">
		AAPPS[#evaluate(currentrow-1)#]=#aappNum#;
		</cfoutput>

		function validateForm (s) {
			for (i=0; i<AAPPS.length;i++) {
				if (AAPPS[i]==s.AAPP.value) {
					break;
				}
			}
			if (i==AAPPS.length) {
				strErrors = strErrors + '  - A valid AAPP number must be entered.\n';
			}
			return ErrorMsg(strErrors);
		}
	</cfcase>
	<cfcase value="5">
		function validateForm (s)
		{
			if (document.frmReportCriteria.cboFundingOffice.selectedIndex == 0) 	//Make sure they've chosen a funding office
			{
				strErrors = strErrors + '  - You must choose a funding office.\n';
			}
			if(document.frmReportCriteria.txtStartDate.value != '' || document.frmReportCriteria.txtEndDate.value != '')
			//there's something in at least one of the date fields
			{
				if(document.frmReportCriteria.txtStartDate.value != '' && document.frmReportCriteria.txtEndDate.value != '')
				//if there's something in both, test for valid dates, set variables
				{
					if(!Checkdate(document.frmReportCriteria.txtStartDate.value))
					{
						strErrors = strErrors + '  - First date in date range must be a valid date in the format mm/dd/yyyy.\n';
					}
					else
					{
						dateRangeStart = new Date(document.frmReportCriteria.txtStartDate.value);
					}
					if(!Checkdate(document.frmReportCriteria.txtEndDate.value))
					{
						strErrors = strErrors + '  - Second date in date range must be a valid date in the format mm/dd/yyyy.\n';
					}
					else
					{
						dateRangeEnd = new Date(document.frmReportCriteria.txtEndDate.value);
					}
					if(Checkdate(document.frmReportCriteria.txtStartDate.value) && Checkdate(document.frmReportCriteria.txtEndDate.value))
					{
						if(dateRangeStart > dateRangeEnd)
						{
							strErrors = strErrors + '  - Second date in date range must be greater than first date.\n';
						}
					}
				}
				else
				//one of the date fields is blank
				{
					strErrors = strErrors + '  - You must enter dates in both fields to search by date range.\n';
				}
			}

			return ErrorMsg(strErrors);
		}
	</cfcase>
	<cfcase value="7">
		function validateForm(s){
			var AAPPS=new Array;
			<cfoutput query="rstAAPP">
			AAPPS[#evaluate(currentrow-1)#]=#aappNum#;
			</cfoutput>

			// check AAPP
			if (document.frmReportCriteria.AAPP.value != ''){
				for (i=0; i<AAPPS.length;i++) {
					if (AAPPS[i]==s.AAPP.value) {
						break;
					}
				}
				if (i==AAPPS.length) {
					strErrors = strErrors + '  - A valid AAPP number must be entered.\n';
				}
			}

			// check start date
			if(document.frmReportCriteria.txtStartDate.value != '' && !Checkdate(document.frmReportCriteria.txtStartDate.value))
				{
					strErrors = strErrors + '  - First date in Start Date range must be a valid date in the format mm/dd/yyyy.\n';
				}
			else
				{
					dateRangeStart = new Date(document.frmReportCriteria.txtStartDate.value);
				}

			// check start end date
			if(document.frmReportCriteria.txtEndDate.value != '' && !Checkdate(document.frmReportCriteria.txtEndDate.value))
				{
					strErrors = strErrors + '  - Second date in Start Date range must be a valid date in the format mm/dd/yyyy.\n';
				}
			else
				{
					dateRangeEnd = new Date(document.frmReportCriteria.txtEndDate.value);
				}

			//check start date range
			if(document.frmReportCriteria.txtStartDate.value != '' && document.frmReportCriteria.txtEndDate.value != '' && Checkdate(document.frmReportCriteria.txtStartDate.value) && Checkdate(document.frmReportCriteria.txtEndDate.value))
				{
					if(dateRangeStart > dateRangeEnd)
					{
						strErrors = strErrors + '  - Second date in Start Date range must be greater than first date.\n';
					}
				}

			// check End date
			if(document.frmReportCriteria.txtStartDate1.value != '' && !Checkdate(document.frmReportCriteria.txtStartDate1.value))
				{
					strErrors = strErrors + '  - First date in End Date range must be a valid date in the format mm/dd/yyyy.\n';
				}
			else
				{
					dateRangeStart = new Date(document.frmReportCriteria.txtStartDate1.value);
				}

			// check end date
			if(document.frmReportCriteria.txtEndDate1.value != '' && !Checkdate(document.frmReportCriteria.txtEndDate1.value))
				{
					strErrors = strErrors + '  - Second date in End Date range must be a valid date in the format mm/dd/yyyy.\n';
				}
			else
				{
					dateRangeEnd = new Date(document.frmReportCriteria.txtEndDate1.value);
				}

			//check end date range
			if(document.frmReportCriteria.txtStartDate1.value != '' && document.frmReportCriteria.txtEndDate1.value != '' && Checkdate(document.frmReportCriteria.txtStartDate1.value) && Checkdate(document.frmReportCriteria.txtEndDate1.value))
				{
					if(dateRangeStart > dateRangeEnd)
					{
						strErrors = strErrors + '  - Second date in End Date range must be greater than first date.\n';
					}
				}

			return ErrorMsg(strErrors);
		}


		function fprint_aapp_fund(s){
			if (document.frmReportCriteria.AAPP.value != ''){
				document.frmReportCriteria.cboFundingOffice.disabled = 1;
				document.frmReportCriteria.cboFundingOffice.selectedIndex = 0;
				document.frmReportCriteria.cboAgreementType.disabled = 1;
				document.frmReportCriteria.cboAgreementType.selectedIndex = 0;
				document.frmReportCriteria.txtStartDate.disabled = 1;
				document.frmReportCriteria.txtStartDate.value = '';
				document.frmReportCriteria.txtEndDate.disabled = 1;
				document.frmReportCriteria.txtEndDate.value = '';
				document.frmReportCriteria.txtStartDate1.disabled = 1;
				document.frmReportCriteria.txtStartDate1.value = '';
				document.frmReportCriteria.txtEndDate1.disabled = 1;
				document.frmReportCriteria.txtEndDate1.value = '';
				document.frmReportCriteria.radStatus[2].checked = 1;

			}
			else if (document.frmReportCriteria.AAPP.value == '')
			{
				document.frmReportCriteria.cboFundingOffice.disabled = 0;
				document.frmReportCriteria.cboAgreementType.disabled = 0;
				document.frmReportCriteria.txtStartDate.disabled = 0;
				document.frmReportCriteria.txtEndDate.disabled = 0;
				document.frmReportCriteria.txtStartDate1.disabled = 0;
				document.frmReportCriteria.txtEndDate1.disabled = 0;

			}

			if(document.frmReportCriteria.txtStartDate.value != '' || document.frmReportCriteria.txtEndDate.value != '' || document.frmReportCriteria.txtStartDate1.value != '' || document.frmReportCriteria.txtEndDate1.value != '' || document.frmReportCriteria.cboFundingOffice.value != 0 || document.frmReportCriteria.cboAgreementType.value != 0 )
			{
				document.frmReportCriteria.AAPP.value = '';
				document.frmReportCriteria.AAPP.disabled = 1;
			}
			else
			{
				document.frmReportCriteria.AAPP.disabled = 0;
			}
		}
	</cfcase>

	<cfcase value="9,10, 20">
		function validateForm(s){
			<cfif url.rpt_id eq 20>
				if (document.frmReportCriteria.cboAAPP.selectedIndex == 0)
				{
				strErrors = strErrors + '  - You must choose an AAPP.\n';
				}

			</cfif>

			if (document.frmReportCriteria.cboPY.selectedIndex == 0)
				{
				strErrors = strErrors + '  - You must choose a Program Year.\n';
				}

			return ErrorMsg(strErrors);
		}


		//select center and find a matched aapp
		function checkAAPP(field, aapp){
			if (document.frmReportCriteria.cboCenter.value != 0)
			{
				for(i=0; i<=aapp.length-1;i++){
					if (document.frmReportCriteria.cboAAPP.options[i].value == document.frmReportCriteria.cboCenter.value) {
						document.frmReportCriteria.cboAAPP.options[i].selected = true;
						break;
					}
				}
			}
			else
				document.frmReportCriteria.cboAAPP.options[0].selected = true;
		}
		//select aapp and find a matched center
		function checkCenter(field, center){
			if (document.frmReportCriteria.cboAAPP.value != 0)
			{
				for(i=0; i<=center.length-1;i++){
					if (document.frmReportCriteria.cboCenter.options[i].value == document.frmReportCriteria.cboAAPP.value) {
						document.frmReportCriteria.cboCenter.options[i].selected = true;
						break;
					}
					else
						document.frmReportCriteria.cboCenter.options[0].selected = true;
				}
			}
			else
				document.frmReportCriteria.cboCenter.options[0].selected = true;
		}
	</cfcase>

	<cfcase value="11">
		function validateForm(s){
			if (document.frmReportCriteria.cboPY.selectedIndex == 0)
				{
				strErrors = strErrors + '  - You must choose a Program Year.\n';
				}

			if (document.frmReportCriteria.cboFundingOffice.selectedIndex == 0)
				{
				strErrors = strErrors + '  - You must choose a Funding Office.\n';
				}

			return ErrorMsg(strErrors);
		}

	</cfcase>

	<cfcase value="17">
		function validateForm(s){
		//check date
			if(document.frmReportCriteria.txtStartDate.value == '')
				strErrors = strErrors + '  - Date As Of field is required. \n';
			else{
				if (!Checkdate(document.frmReportCriteria.txtStartDate.value))
					strErrors = strErrors + '  - Date As Of is not a valid date. \n';
			}

			return ErrorMsg(strErrors);
		}
	</cfcase>

	<cfcase value="21"><!--- footprint transaction report --->
		var AAPPS=new Array;
		<cfoutput query="rstAAPP">
		AAPPS[#evaluate(currentrow-1)#]=#aappNum#;
		</cfoutput>

		function validateForm (s) {
			for (i=0; i<AAPPS.length;i++) {
				if (AAPPS[i]==s.AAPP.value) {
					break;
				}
			}
			if (i==AAPPS.length) {
				strErrors = strErrors + '  - A valid AAPP number must be entered.\n';
			}

			// check start date
			if(document.frmReportCriteria.txtStartDate.value != '' && !Checkdate(document.frmReportCriteria.txtStartDate.value))
			{
				strErrors = strErrors + '  - First date in Date range must be a valid date in the format mm/dd/yyyy.\n';
			}
			else{
				dateRangeStart = new Date(document.frmReportCriteria.txtStartDate.value);
			}

			// check start end date
			if(document.frmReportCriteria.txtEndDate.value != '' && !Checkdate(document.frmReportCriteria.txtEndDate.value))
			{
				strErrors = strErrors + '  - Second date in Date range must be a valid date in the format mm/dd/yyyy.\n';
			}
			else
			{
				dateRangeEnd = new Date(document.frmReportCriteria.txtEndDate.value);
			}
			if (dateRangeStart > dateRangeEnd)
				strErrors = strErrors + '  - Fisrt date in Date range must be earlier than Second date.\n';

			return ErrorMsg(strErrors);
		}
	</cfcase>

	<cfcase value="22">
		function orgTypeCheck(form)
			{
				// when org type changes,
				// check to see if small bus is selected
				// if so, enable small bus type check boxes
				if (form.cboOrgType.options[form.cboOrgType.selectedIndex].value.toUpperCase() == 'FPSMALL')
					for (i=0;i<form.ckbSmallBusType.length;i++){
						form.ckbSmallBusType[i].checked = 1;
						form.ckbSmallBusType[i].disabled = 0;
					}
				else
					{
					for (i=0;i<form.ckbSmallBusType.length;i++)
						{
						form.ckbSmallBusType[i].checked = 0;
						form.ckbSmallBusType[i].disabled = 1;
						}
					}
			}
		function validateForm(form){
			var agreeTotal = 0;
			var smallBusinessTotal = 0;

			//check agreement type
			for (i=0; i<form.ckbAgreementType.length; i++){
				if (eval("form.ckbAgreementType[" + i + "].checked") == true)
					agreeTotal += 1;
			}
			if (agreeTotal == 0)
				strErrors = strErrors + '  - At least one of Agreement Type must be selected.\n';

			if (form.txtStartDate.value == '')
				strErrors = strErrors + '  - The First Date in Date Range is required.\n';
			else if (form.txtStartDate.value != '' && !Checkdate(form.txtStartDate.value))
				strErrors = strErrors + '  - First date in Date range must be a valid date in the format mm/dd/yyyy.\n';
			else
				var dateRangeStart = new Date(form.txtStartDate.value);

			//check category
			if (form.cboOrgType.value == 'FPSMALL'){
				for (i=0; i<form.ckbSmallBusType.length; i++){
					if (eval("form.ckbSmallBusType[" + i + "].checked") == true)
						smallBusinessTotal += 1;
				}
				if (smallBusinessTotal == 0)
					strErrors = strErrors + '  - At least one Small Business Category must be checked if you select Small Business(for Profit) in Organization Category .\n';
			}

			//check date range
			if (form.txtEndDate.value == '')
				strErrors = strErrors + '  - Second Date in Date Range is required.\n';
			else if (form.txtEndDate.value != '' && !Checkdate(form.txtEndDate.value))
				strErrors = strErrors + '  - Second date in Date range must be a valid date in the format mm/dd/yyyy.\n';
			else
				var dateRangeEnd = new Date(form.txtEndDate.value);

			if (dateRangeStart > dateRangeEnd)
				strErrors = strErrors + '  - Fisrt date in Date range must be earlier than Second date.\n';

			return ErrorMsg(strErrors);
		}

		function changeDateRange(form){
			var startYear = form.cboFY.value-1;
			form.txtStartDate.value='10/01/'+ startYear;
			form.txtEndDate.value='09/30/'+ form.cboFY.value;
		}
		function changeFY(form){
			var startYear = document.frmReportCriteria.cboFY.value-1;
			var startDate = '10/01/'+ startYear;
			var endDate = '09/30/'+ document.frmReportCriteria.cboFY.value;
			//alert(startDate +' == '+ form.txtStartDate.value);

			if (form.txtStartDate.value == '' || form.txtEndDate.value == '' || form.txtStartDate.value != startDate || form.txtEndDate.value != endDate)
				document.frmReportCriteria.cboFY.value = '';
		}

	</cfcase>

	<cfcase value="23">
		var AAPPS=new Array;
		<cfoutput query="rstAAPP">
		AAPPS[#evaluate(currentrow-1)#]=#aappNum#;
		</cfoutput>

		function validateForm (s)
		{
		if (s.radReportType[0].checked)
			{
			if (s.AAPP.value == '')
				{
				strErrors = strErrors + '  - You must enter an AAPP number for an AAPP report.\n';
				}
			else
				{
				for (i=0; i<AAPPS.length;i++)
					{
					if (AAPPS[i]==s.AAPP.value)
						{
						break;
						}
					}
				if (i==AAPPS.length)
					{
					strErrors = strErrors + '  - A valid AAPP number must be entered.\n';
					}
				}
			}
		else if (s.radReportType[0].checked == false && s.radReportType[1].checked == false)
			{
			strErrors = strErrors + '  - Please choose the type of report.\n';
			}
		return ErrorMsg(strErrors);
		}
	</cfcase>

	<cfcase value="24">
		function validateForm(s)
		{
			for (i=0; i<s.chkCostCat.length;i++) {
				if (s.chkCostCat[i].checked) {
					break;
				}
			}
			if (i==s.chkCostCat.length) {
				strErrors = strErrors + '  - At least one Cost Category must be entered.\n';
			}
		return ErrorMsg(strErrors);
		}
	</cfcase>

	<cfcase value="25">
		//workload change list
		function validateForm(s)
		{
			for (i=0; i<s.ckbWorkload.length;i++) {
				if (s.ckbWorkload[i].checked) {
					break;
				}
			}
			if (i==s.ckbWorkload.length) {
				strErrors = strErrors + '  - At least one Workload Type must be entered.\n';
			}
		return ErrorMsg(strErrors);
		}
	</cfcase>

	<cfdefaultcase>
		function validateForm(s){
			return ErrorMsg(strErrors);
		}
	</cfdefaultcase>
</cfswitch>
</script>
<p></p>
<cfoutput>
<form name="frmReportCriteria" action="reports.cfm?rpt_id=#url.rpt_id#" method="post" onSubmit="return validateForm(this);" target="_blank"><!--- target="reports" --->
</cfoutput>

<cfswitch expression="#url.rpt_id#">
	<cfcase value="1">
		<!---Report: Budget Authority Requirements by AAPP--->
		<cfinclude template="crit_budget_authority_requirements.cfm">
	</cfcase>
	<cfcase value="2">
		<!---Report: Estimated Cost Profile--->
		<cfinclude template="crit_estimated_cost_profile.cfm">
	</cfcase>
	<cfcase value="3">
		<!---Report: Fiscal Plan--->
		<cfinclude template="crit_fiscal_plan.cfm">
	</cfcase>
	<cfcase value="4">
		<!---Report: FOP Allocations (by AAPP)--->
		<cfinclude template="crit_fop_aapp.cfm">
	</cfcase>
	<cfcase value="5">
		<!---Report: FOP Listing--->
		<cfinclude template="crit_fop_allocations.cfm">
	</cfcase>
	<cfcase value="6">
		<!---Report: Budget Authority Requirements by funding office--->
		<cfinclude template="crit_budget_authority_fundingoffice.cfm">
	</cfcase>
	<cfcase value="7">
		<!---Report: Footprint/contractor report--->
		<cfinclude template="crit_footprint_contract.cfm">
	</cfcase>
	<cfcase value="8">
		<!---Report: CCC BA Transfer report--->
		<cfinclude template="crit_ccc_ba_transfer.cfm">
	</cfcase>
	<cfcase value="9">
		<!---Report: Operating Plan Detail report--->
		<cfinclude template="crit_progop_detail.cfm">
	</cfcase>
	<cfcase value="10">
		<!---Report: FOP CCC Budget report--->
		<cfinclude template="crit_ccc_py_budget.cfm">
	</cfcase>
	<cfcase value="11">
		<!---Report: Program Year Inital CCC Budget report--->
		<cfinclude template="crit_ccc_py_worksheet.cfm">
	</cfcase>
	<cfcase value="12">
		<!--- Report: VST Worksheet report --->
		<cfinclude template="crit_vst.cfm">
	</cfcase>
	<cfcase value="13">
		<!--- Report: Budget Status --->
		<cfinclude template="crit_budget_status.cfm">
	</cfcase>

	<!---  14 for Contract Close Out --->
	<!---  15 for Fop batch process DOL --->
	<!---  16 for Fop batch process CCC --->

	<cfcase value="17">
		<!--- Report: OA/CTS Annualized Workload/Cost Under Current Contracts --->
		<cfinclude template="crit_oa_cts_annualized.cfm">
	</cfcase>
	<!---  18 for Fop batch process CCC --->
	<!---  19 for Fop future new --->
	<cfcase value="20">
		<!---Report: Program Year Initial CCC Budget (by Center) report--->
		<cfinclude template="crit_ccc_py_aapp_bycenter.cfm">
	</cfcase>
	<!---  21 for Footprint Transaction --->
	<cfcase value="21">
		<!---Report: Footprint Transaction--->
		<cfinclude template="crit_footprint_transaction.cfm">
	</cfcase>
	<!---  22 for Small Business Funding Report --->
	<cfcase value="22">
		<!---Report: Small Business Funding Report--->
		<cfinclude template="crit_smallbusiness.cfm">
	</cfcase>
	<cfcase value="23">
		<!--- Report: Footprint Transaction Discrepancy --->
		<cfinclude template="crit_footprint_xactn_disc.cfm">
	</cfcase>
	<cfcase value="24">
		<!--- Report: Outyear funding report --->
		<cfinclude template="crit_outyear.cfm">
	</cfcase>
	<cfcase value="25">
		<!--- Report: Workload Change List report --->
		<cfinclude template="crit_workload_change.cfm">
	</cfcase>
	<cfcase value="27">
		<!--- Report: Obligation / FOP Recon report --->
		<cfinclude template="crit_ncfms_fop_recon.cfm">
	</cfcase>
	<cfcase value="28">
		<!--- Report: Allocation / FOP Recon report --->
		<cfinclude template="crit_fop_allocat_recon.cfm">
	</cfcase>
	<cfcase value="29">
		<!--- Report: Allotment / Allocation / Oblig Recon report (national) --->
		<cfinclude template="crit_allot_allocat_recon_nat.cfm">
	</cfcase>
	<cfcase value="30">
		<!--- Report: Allotment / Allocation / Oblig Recon report (aapp)  --->
		<cfinclude template="crit_ncfms_allocat_fop_recon_aapp.cfm">
	</cfcase>
</cfswitch>
</form>

<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">

