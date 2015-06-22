<cfsilent>
<!--- sessionVariableSetup.cfm

I build the variables that are in request and session

--->

<cfoutput>
<cfset request.pageID="10">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "AAPPs">
<cfparam name="url.sortBy" default="aappNum">
<cfparam name="url.sortDir" default="asc">
<cfparam name="session.ncfmsAlertDisplay" default="1">

<!--- checkboxes are not defined, unless something is checked --->
<cfparam name="form.cboAgreementTypeFilter" default="">
<cfparam name="form.cboFundingOfficeFilter" default="">
<cfparam name="form.cboContractStatusFilter" default="">
<cfparam name="form.cboserviceTypeFilter" default="">
<cfparam name="form.cboStateFilter" default="">
<cfparam name="form.home_filterSearchWord" default="">

</cfoutput>

<cfif listFind("1,2", session.roleID)>
	<!--- button to directly add FOPs, will display in header --->
	<!--- only shows for admins and budget unit staff --->
	<cfsavecontent variable="variables.headerButton">
	<div> <!-- btnRight -->
		<form>
			<input name="btnAddFOP" type="submit" value="Add FOP/Estimated Cost" onclick="selectAdjustmentAAPP();" />
		</form>
	</div> <!-- btnRight -->
	</cfsavecontent> <!--- variables.headerButton --->
</cfif>


<!--- get list of agreement types, funding offices, states for drop-down lists --->
<!--- session.roleID =3 is regional, =4 is regional admin --->
<cfif not listfind("3,4", session.roleID)>
	<cfset session.rstFundingOffices = application.olookup.getFundingOffices()>
<cfelse>
	<!--- build HOME funding office --->
	<cfset session.rstHomeFundingOffice = application.olookup.getFundingOffices(
		fundingOfficeNum="#session.region#"
	)>
	<!--- build list for FED --->
	<cfset session.rstFundingOffices = application.olookup.getFundingOffices(
		fundingOfficeType="FED"
	)>
	<!--- build list for region and FED --->
	<cfset session.rstDisplayFundingOffices = application.olookup.getFundingOffices(
		fundingOfficeNum="#session.region#", includeFED='yes'
	)>
</cfif>

<cfset session.rstAgreementTypes	= application.olookup.getAgreementTypes()>
<cfset session.rstServiceTypes		= application.olookup.getServiceTypes()>

<!--- get page properties --->
<cfinvoke component="#application.paths.components#page" method="getPageProperties" pageID="#request.pageID#" returnvariable="rstPageProperties">
<cfset request.pageSectionID			= rstPageProperties.sectionID />
<cfset request.parentSectionID			= rstPageProperties.parentID />
<cfset request.pageHelpID				= rstPageProperties.helpID />

</cfsilent>
