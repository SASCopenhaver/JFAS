<cfcomponent displayname="aapp_home" hint="Component that contains queries for the Home Page.">
<cfoutput>

<!--- belldr 12/30/2013 Took these particular routines from aapp.cfc, in order to cache in the application scope, since used constantly. --->
<!--- based on ideas as http://www.bennadel.com/blog/762-Learning-ColdFusion-8-Javascript-Object-Notation-JSON-Part-II-Remote-Method-Calls.htm --->

<!--- * * * * * * * * * * REMOTE ROUTINES * * * * * * * * * * --->
<cfinclude template="#application.paths.includes#jfascommon.cfm">

<cfscript>
/**
* @hint I run the AAPP query, and generate (1) html for the home page data, and (2) html for the Filter Description, and (3) the effective length of the Filter Description, allowing 3 characters for each icon
* @sCFFieldString This string is built by a JS form.serialize()
* @sortBy		a column name from url
* @sortDir		asc/desc from url
* @roleID		from login
* @region		from login
*/

remote string function CFSessionDisplayDataColumns (
	required string sCFFieldString
	, required sortBy
	, required sortDir
	, required roleID
	, region
	)

	returnFormat	= "plain"
	output			= "true"
	{

	// get a structure that is valid for all the preferences in the filter form
	var tFilterSelections = ConvertFieldStringToPrefs(arguments.sCFFieldString);

	// UPDATE SESSION VARIABLES from arguments, which were calculated from a JS form.serialize()

	// Put the current status of the filter into session.userPreferences.tMyFilterNow

	// Special cases for keyword, remove "%" encoded characters, and replace '+' with blank
	tFilterSelections.HOME_FILTERSEARCHWORD = ConvertToDisplayable(tFilterSelections.HOME_FILTERSEARCHWORD);
	tFilterSelections.HOME_FILTERSEARCHWORD = ReplaceNoCase(tFilterSelections.HOME_FILTERSEARCHWORD, '+', ' ', 'all');

	// for EVERY FILTER preference, update the session variable to the value from the form, or the default value

	// start with a new filter
	// we need this, since checkboxes do not come over from the form, unless checked
	var tFil = Duplicate(application.userPreferencesDefault.tMyFilterNow);
	var thisKey = '';

	for (walker = 1; walker LE Listlen(application.userPreferencesDefault.slRequiredDefinedFilters ); walker = walker + 1) {
		thisKey = ListGetAt(application.userPreferencesDefault.slRequiredDefinedFilters, walker);
		if (StructKeyExists( tFilterSelections, thisKey)) {
			structInsert(tFil, thisKey, StructFind(tFilterSelections, thisKey), true);
		}
	}
	session.userPreferences.tMyFilterNow = structNew();
	session.userPreferences.tMyFilterNow = Duplicate(tFil);

	// write tMyFilterNow to the database
	var nReturn = session.oUser.WriteMyFilter(session.UserID, 'Now', 1);
	if (nReturn EQ 0) {
		// session timeout, or database down
		tReturn.sColumnsOfData="Fatal: Session Time Out";
		tReturn.sFilterHTML = '';
		tReturn.nFilterLength = 0;
		tReturn.recordcount = 0;
		return SerializeJSON ( tReturn );
	}

	// the the HTML for the display of the data
	var tReturn = CFSessionDisplayDataColumnsGuts (
		tFilterSelections
		, 0
		, sortBy
		, sortDir
		, roleID
		, region
	);

	return SerializeJSON ( tReturn );

} // CFSessionDisplayDataColumns


/**
* @hint I run the AAPP query, and generate (1) html for the home page data, and (2) html for the Filter Description, and (3) the effective length of the Filter Description, allowing 3 characters for each icon
* @ClearField Name of field in Filter Form of preference being cleared
* @sortBy a column name from url
* @sortDir asc/desc from url
* @roleID from login
* @region from login
*/
remote string function DisplayDataColumnsClearOne (
	required string ClearField
	, required sortBy
	, required sortDir
	, required roleID
	, region
	)

	returnFormat	= "plain"
	output			= "false"
	{

	var defaultValue= '';

	if ( arguments.ClearField EQ 'cboStateFilter') {
		// special case for state dropdown
		defaultValue= 'all';
	}

	var	listPtr =  listContainsNoCase(application.userPreferencesDefault.slFilterFormNames, arguments.ClearField);
	if (listPtr NEQ 0) {
		structUpdate(session.userPreferences.tMyFilterNow, ListGetAt(application.userPreferencesDefault.slRequiredDefinedFilters, listPtr), defaultValue);
	}

	var tReturn = CFSessionDisplayDataColumnsGuts (
		session.userPreferences.tMyFilterNow
		, 0
		, sortBy
		, sortDir
		, roleID
		, region
	);

	return SerializeJSON ( tReturn );

} // DisplayDataColumnsClearOne




/**
* @hint I return session.UserPreferences.aMyAAPPs as html appropriate for the MyAAPPs tab
* @user_ID like 'mstein'
*/
remote string function ListMyAAPPs (
	required user_ID
	)

	returnFormat	= "plain"
	output			= "false"

	{
	var tReturn = structNew();
	var shtml = '<table class="MyFiltersTable">';
	var listlen = 0;
	var aappNum='';
	var jslink = '';

	try {
		// this line would fail if the session has timed out
		if (NOT IsArray(session.UserPreferences.aMyAAPPs)) {
			session.UserPreferences.aMyAAPPs = [];
			shtml = '';
		} else {
			// build a table, one row per filtername, delete button
			for (var walker = 1; walker LE ArrayLen(session.UserPreferences.aMyAAPPs); walker += 1) {
				aappNum = session.UserPreferences.aMyAAPPs[walker];
				jslink = "GotoAAPP('" & aappNum & "');";
				jsdellink = "DeleteMyAAPP ('" & session.userID & "', '" & aappNum & "' );";
				// click on the AAPP to display details, click on the "X" to delete the MyAAPP
				shtml &= '<tr><td>' &

				'<a href="##" onclick="' & jslink & '">' & aappNum & '</a></td><td>' &

				'<a href="##" class="ImgOnFilterTab usetooltip  btn btn-link btn-xs" data-toggle="tooltip" data-placement="top" title="Delete MyAAPP" onclick="' & jsdellink & '" ><img src="#application.paths.images#close.png" border="0" name="deleteMyAAPP" alt="Delete MyAAPP" width="14" height="14" /></a>'

				& '</td></tr>';
			}
			shtml &= '</table>';

			listlen = ArrayLen(session.UserPreferences.aMyAAPPs);
		}
		tReturn.shtml = shtml;
		tReturn.listlen = listlen;

	} // try
	catch (any e) {
		// possibly a session timeout
		tReturn.shtml = "Fatal:" & e.message;
		tReturn.listlen = 1;
	}
	finally {
		return SerializeJSON ( tReturn );
	}

} // ListMyAAPPs


/**
* @hint I save an aappNum in the user's list of My AAPPs, which is a preference
* @user_ID like 'mstein'
* @aappNum		the aappNum to save
*/
remote string function SaveMyAAPP (
	required user_ID
	, required string aappNum
	)

	returnFormat	= "plain"
	output			= "false"

	{
	var sReturn = '';
	var bTemp = session.ouser.SaveMyAAPP(arguments.user_ID, arguments.aappNum);
	if (bTemp NEQ 1) {
		sReturn = 'Fatal: Session Timeout in SaveMyAAPP';
	}

	return SerializeJSON ( sReturn );

} // SaveMyAAPP


/**
* @hint I delete the user's list of My AAPPs, which is a preference, then return the current list
* @user_ID like 'mstein'
* @aappNum		the aappNum to save
*/
remote string function DeleteMyAAPP (
	required user_ID
	, required string aappNum
	)

	returnFormat	= "plain"
	output			= "false"

	{

	var breturn = session.ouser.DeleteMyAAPP(arguments.user_ID, arguments.aappNum);
	return ListMyAAPPs(user_ID);

} // DeleteMyAAPP

/**
* @hint I return session.UserPreferences.aMyAAPPs as html appropriate for the MyAAPPs tab
* @user_ID like 'mstein'
*/
remote string function ListMyFilters (
	required user_ID
	)

	returnFormat	= "plain"
	output			= "false"

	{
	var tReturn = structNew();
	var shtml = '<table class="MyFiltersTable">';
	var listlen = 0;
	var width = 0;
	var filterName='';
	var jslink = '';

	try {
		// this line would fail if the session has timed out
		if (NOT IsArray(session.UserPreferences.aMyFilters)) {
			session.UserPreferences.aMyFilters = [];
			shtml = '';
		} else {
			// build a table, one row per filtername, delete button
			for (var walker = 1; walker LE ArrayLen(session.UserPreferences.aMyFilters); walker += 1) {
				filterName = session.UserPreferences.aMyFilters[walker];
				width = max(width, len(filterName));
				// handle ' and & in filterName. Note we are converting to pass as an argument to a GoToMyFilter() , which is JS.  This is DIFFERENT from converting for use in an Oracle query.  GoToMyFilter() passsses the escFilterName to aapp_home.ReadMyFilter(), which passes to session.ouser.ReadMyFilter(), which looks in select * from user_preference where user_id = 'mstein' and preference_key = 'myFilterDon''s Favorite'.  NOTE this is EQUALS, not LIKE, and the doubling of the apostrophe. The value in the database is myFilterDon's Favorite

				escFilterName = replaceNoCase(filterName, "'", "\'", "all"); // escape the apostrophe, for JS
				escFilterName = replaceNoCase(escFilterName, "&", "\&", "all");
				escFilterName = replaceNoCase(escFilterName, ">", "\>", "all");
				escFilterName = replaceNoCase(escFilterName, "<", "\<", "all");
				jslink = "GoToMyFilter('" & session.userID & "', '" & escFilterName & "');";
				jsdellink = "DeleteMyFilter ('" & session.userID & "', '" & escFilterName & "' );";
				// click on the FilterName to invoke the filter, click on the "X" to delete the MyFilter
				shtml &= '<tr><td>' &

				'<a href="##" onclick="' & jslink & '">' & filterName & '</a></td><td>' &

				'<a href="##" class="ImgOnFilterTab usetooltip  btn btn-link btn-xs" data-toggle="tooltip" data-placement="top" title="Delete MyFilter" onclick="' & jsdellink & '" ><img src="#application.paths.images#close.png" border="0" name="deleteMyFilter" alt="Delete MyFilter" width="14" height="14" /></a>'

				& '</td></tr>';
			}
			// " TextPad

			shtml &= '</table>';
			listlen = ArrayLen(session.UserPreferences.aMyFilters);
		}
		tReturn.shtml = shtml;
		tReturn.listlen = listlen;
		tReturn.width = width;
	} // try
	catch (any e) {
		// possibly a session timeout
		tReturn.shtml = "Fatal:" & e.message;
		tReturn.listlen = 1;
		tReturn.width = 1;
	}
	finally {
		return SerializeJSON ( tReturn );
	}

} // ListMyFilters

/**
* @hint I read a filter from the database into session.userPreferences.tMyFilterNow
* @user_ID like 'mstein'
* @filterName like 'MyFavoriteFilter'
*/
remote boolean function ReadMyFilter (
	required user_ID
	, required filterName
	)

	returnFormat	= "plain"
	output			= "false"

	{

	var bReturn = session.ouser.ReadMyFilter(arguments.user_ID, arguments.filterName);
	return SerializeJSON (bReturn);

} // ReadMyFilter



/**
* @hint I copy the standard setup from application to session.userPreferences.tMyFilterNow
*/
remote string function ResetMyFilter (
	)

	returnFormat	= "plain"
	output			= "false"

	{
	var tReturn = StructNew();

	// this would fail if the session timed out
	try {
		// tReturn has bReturn, and copy of the default userPreferences structure
		tReturn = session.ouser.ResetMyFilter();
	} // try
	catch (any e) {
		// possibly a session timeout
		// we are going to the home page, unless this is false. Set it to false, to force a logout, interpreted in jsHome
		tReturn.bReturn = 0;
	} // catch
	finally {
		return SerializeJSON ( tReturn );
	} // finally

} // ResetMyFilter



/**
* @hint I create an array of MyFilters in session.userPreferences
* @user_ID like 'mstein'
*/
remote boolean function ReadFilterList (
	required user_ID
	)

	returnFormat	= "plain"
	output			= "false"

	{

	return session.ouser.ReadFilterList(arguments.user_ID);

} // ReadFilterList


/**
* @hint I delete the user-s list of My AAPPs, which is a preference, then return the current list
* @user_ID like 'mstein'
* @aappNum		the aappNum to save
*/
remote string function DeleteMyFilter (
	required user_ID
	, required string filterName
	)

	returnFormat	= "plain"
	output			= "false"

	{

	// this updates the database synchronously, and updates session.userPreferences.aMyFilters
	// returns the updated list of the filters

	// this would fail if session was timed out
	try {
		var bReturn = session.ouser.DeleteMyFilter(arguments.user_ID, arguments.filterName);
		// this tReturn is already serialized
		tReturn	= ListMyFilters(user_ID);
	} // try

	catch (any e) {
		// possibly a session timeout
		// this mimics the return of ListMyFilters
		tReturn.SHTML = "Fatal:Session Timeout in DeleteMyFilter";
		tReturn.LISTLEN = 1;
		tReturn.WIDTH = 1;
		tReturn = SerializeJSON(tReturn);
	} // catch

	finally {
		return tReturn;
	} // finally

} // DeleteMyAAPP


/**
* @hint I write a new filter to the session and database
* @user_ID like 'mstein'
* @filterName		the filterName to save
* @confirmOverwrite		1 if overwrite is OK, else 0
*/
remote string function WriteMyFilter (
	required user_ID
	, required string filterName
	, required string bConfirmOverwrite
	)

	returnFormat	= "plain"
	output			= "false"

	{

	// this updates the database synchronously, and updates the names in session.userPreferences.aMyFilters
	// this would fail if the session timed out
	try {

		var nReturn = session.ouser.WriteMyFilter(arguments.user_ID, arguments.filterName, arguments.bConfirmOverwrite);
	} // try

	catch (any e) {
		// possibly a session timeout
		nReturn = 0;
	}

	finally {
		return SerializeJSON (nReturn);
	}

} // WriteMyFilter

/**
* @hint I send an email to the Technical POCS, containing a dump of the scopes
* @subject is the subject of the email
*/
remote string function EmailScopesAjax (
	required string subject
	)

	returnFormat	= "plain"
	output			= "false"

{
	var sReturn = '';
	// calling a non-remote routine in jfasCommon.cfm
	// may return a Fatal: error, which is trapped in jsHome
	sReturn = EmailScopes(arguments.subject);

	// serializing the output, because THIS is a remote routine
	var sJSON = SerializeJSON ( sReturn );

	return sJSON;

} // EmailScopesAjax

remote string function clearSessionAnnouncement (
	)

	returnFormat	= "plain"
	output			= "false"

{
	var sReturn = '';

	session.Announcement = '';

	// serializing the output, because THIS is a remote routine
	var sJSON = SerializeJSON ( sReturn );

	return sJSON;

} // clearSessionAnnouncement

</cfscript>

<cffunction name="validateQuickSearch" access="remote" returntype="string" hint="This is called only when processing the quickSearch form.  I look for a match on AAPP. If match, go to the AAPP Summary page. If none, then change FilterNow session and database entry, and go to home page" returnFormat = "plain" output="false" >
	<cfargument name="aappNum" type="string" required="yes">

	<!--- sMethod is an indicator whether to bother looking as an aappNum --->
	<cfargument name="sMethod" type="string" required="yes">

	<cfset var qValidate = ''>
	<cfset sReturn = 'Home'>

	<cfif arguments.sMethod EQ 'tryAAPP'>

		<cfquery name="qValidate">
			select count(*) cnt from AAPP_CONTRACT_SNAPSHOT where aappNum = #arguments.aappNum#
		</cfquery>
		<cfif qValidate.cnt EQ 1>
			<!--- found the AAPP, just go to it --->
			<cfset sReturn = 'AAPP'>
			<cfreturn SerializeJSON ( sReturn ) />
		</cfif>
	</cfif>
	<!--- falls through, if not a match for aappNum --->
	<!--- use the aappNum as a keyword --->
	<cfscript>
		var tReturn = StructNew();

		// this would fail if the session timed out
		try {
			tReturn = session.ouser.SetFilterToKeyword( arguments.aappNum );
		} // try
		catch (any e) {
			// possibly a session timeout
			sReturn = 'Timeout';
		}
		finally {
			return SerializeJSON ( sReturn );
		}
	</cfscript>

</cffunction> <!--- validateQuickSearch --->

<!---  * * * * * * * * non-remote routines * * * * * * * --->

<!--- this function is NOT CFSCRIPT, because it contains a query --->
<cffunction name="getContractListingHomeforCheckboxes" access="public" returntype="any" output="true" hint="Get listing of contracts for home page, USING CHECKBOXES">
	<cfargument name="status" type="string" required="no" default="">
	<cfargument name="agreementType" type="string" required="no" default="">
	<cfargument name="fundingOffice" type="string" required="no" default="">
	<cfargument name="serviceType" type="string" required="no" default="">
	<cfargument name="searchWord" type="string" required="no" default="">
	<cfargument name="contractStartDate1" type="string" required="no" default="">
	<cfargument name="contractStartDate2" type="string" required="no" default="">
	<cfargument name="contractEndDate1" type="string" required="no" default="">
	<cfargument name="contractEndDate2" type="string" required="no" default="">
	<cfargument name="sortby" type="string" required="no" default="aappNum">
	<cfargument name="sortDir" type="string" required="no" default="asc">
	<cfargument name="region" type="string" required="no" default="">
	<cfargument name="State" type="string" required="no" default="">

	<!---
	<cfdump var="#arguments#">
	<cfabort>
	--->

	<cfset var qryAAPPfromFootprint = ''>
	<cfset var sAAPPfromFootprint = ''>
	<cfset var qcheckifaapp = ''>

	<!--- ensure that the arguments are upper case --->
	<cfif arguments.State EQ "all">
		<cfset arguments.State = ''>
	</cfif>
	<cfset arguments.status 		= application.outility.buildQuotedValueList(arguments.status,"Alpha")>
	<cfset arguments.agreementType 	= application.outility.buildQuotedValueList(arguments.agreementType,"Alpha")>
	<cfset arguments.fundingOffice	= application.outility.buildQuotedValueList(arguments.fundingOffice,"Numeric")>
	<cfset arguments.serviceType	= application.outility.buildQuotedValueList(arguments.serviceType,"Alpha")>
	<cfset arguments.searchWord		= trim(UCase(ReplaceNoCase(arguments.searchWord, '+', '_','all')))>
	<cfset arguments.State			= application.outility.buildQuotedValueList(arguments.State,"Alpha")>
	<cfset arguments.contractStartDate1		= ValidateDate(arguments.contractStartDate1)>
	<cfset arguments.contractStartDate2		= ValidateDate(arguments.contractStartDate2)>
	<cfset arguments.contractEndDate1		= ValidateDate(arguments.contractEndDate1)>
	<cfset arguments.contractEndDate2		= ValidateDate(arguments.contractEndDate2)>

	<!--- interpret a number as an aappNum IF there is a match.  BUT, also allow number to be partial match within contract number, etc. --->
	<cfset local.aappNum = 0>
	<cfif arguments.searchWord neq ''> {
		<cfif IsNumeric(arguments.searchWord)>
			<!--- this is the exact match to an aappNum --->
			<cfset local.aappNum = Val(arguments.searchWord)>
			<cfif local.aappNum LT 100 OR local.aappNum GT 99999>
				<cfset local.aappNum = 0>
			<cfelse>
				<!--- this is a possible aappNum --->
				<cfquery name="qcheckifaapp">
					select count(*) cnt from aapp_contract_snapshot
					where aappnum = #local.aappNum#
				</cfquery>
				<cfif qcheckifaapp.cnt NEQ 1>
					<cfset local.aappNum = 0>
				</cfif>
			</cfif>
		</cfif>
		<!--- build a list of AAPPs where the document number matches the searchWord --->
		<cfquery name="qryAAPPfromFootprint" >
			select distinct(aapp_num)
			FROM footprint_ncfms
			WHERE UPPER(doc_num) LIKE '%#arguments.searchWord#%'
			AND aapp_NUM IS NOT NULL
		</cfquery>
		<cfset sAAPPfromFootprint = Valuelist(qryAAPPfromFootprint.aapp_Num)>
	</cfif>

	<cfscript>
	var statuslist = '';
	var datecriteria  = '';
	var cmd1 = '';
	var cmd2 = '';
	var cmd = "SELECT aappNum, predAAPPNum, succAAPPNum, agreementTypeCode, agreementTypeDesc, programActivity, venue, dateStart, dateEnd, curContractYear, lastReconYear, lastCYearEndDate, contractStatusID, contractStatusDesc, centerID, centerName, fundingOfficeNum, fundingOfficeDesc, fundingOfficeAbbr, contractNum, contractorName, budgetInputType, stateAbbr FROM AAPP_CONTRACT_SNAPSHOT WHERE 1=1 ";

	if (arguments.agreementType neq "") {
		cmd &= " AND UPPER(agreementTypeCode) IN #arguments.agreementType#";
	}

	if (arguments.serviceType neq "") {
		cmd &= " AND (aappNum in (select distinct (aapp_num) FROM aapp_contract_type WHERE UPPER( TRIM( contract_type_code ) ) IN #arguments.serviceType# AND aapp_num IS NOT NULL    ) )";
	}

	if (arguments.state neq "") {
		cmd &= " AND UPPER(stateAbbr) IN #arguments.state#";
	}


	if (arguments.searchWord neq "") {

		if (local.aappNum NEQ 0) {
			// we already know there is a match on the aappNum
			cmd1 = " ( aappnum = #local.aappNum# ) " ;
		}
		else {
			// use function that handles ' and &, and adds the "% and %"
			escSearchWord = "'%" & convertSearchKeyforSQL( arguments.searchWord ) & "%'";

			// search many fields in the query for the appearance of the search term
			cmd1 = " ( UPPER(centername) LIKE " & escSearchWord & " OR UPPER(venue) LIKE " & escSearchWord & " OR UPPER(contractnum) LIKE " & escSearchWord & " OR UPPER(contractorname) LIKE " & escSearchWord & " OR UPPER(programActivity) LIKE " & escSearchWord & " )";
		}

		if ( sAAPPfromFootprint EQ '' ) {
			// there is NO list of aapps of aapps that match on document number, etc
			cmd &= " AND " & cmd1 & " ";
		}
		else {
			// there IS A list of aapps of aapps that match on document number, etc
			// use the results from the search in the document number, using cmd2
			cmd2 = " ( aappNum IN ( #sAAPPfromFootprint# ) ) " ;

			cmd &= " AND ( " & cmd1 & " OR " & cmd2 & " ) ";
		}
	} //arguments.searchWord neq ""

	if (arguments.fundingOffice neq "") {
		cmd &= " AND (fundingOfficeNum in #arguments.fundingOffice# )";
	}
	else {
		if (arguments.region neq "") {
			cmd &= " AND (fundingOfficeNum = #arguments.region# or agreementTypeCode = 'CC')";
		}
	}

	if (arguments.status neq "") {
		// determine whether in or out of the results, based on status, and TODAY'S DATE !
		// these date-based statuses are ORed, eg: status is current OR status is future OR status is closeout or status is recon. Format is " AND ( (datecriteria1) OR (datecriteria2) .... )

		if (findNoCase("active", arguments.status) neq 0) {
			statuslist = ListAppend(statuslist, "'Active'");
		} // active

		if (findNoCase("inact", arguments.status) neq 0) {
			statuslist = ListAppend(statuslist, "'Inactive'");
		} // inact

		if (statuslist neq '') {
			datecriteria &= " (contractstatusdesc IN ( " & statuslist & " ) ) ";
		}

		if (findNoCase("current", arguments.status) neq 0) {
			if ( datecriteria neq '' ) { datecriteria &= " OR " ; }
			// within their period of performance
			datecriteria &= " (budgetInputType = 'A' AND (dateStart IS NULL OR ( ( dateStart IS NOT NULL ) AND ( dateStart <= TO_DATE('#dateformat(Now(),'mm/dd/yyyy')#', 'mm/dd/yyyy') ) AND ( dateEnd IS NULL OR dateEnd >= TO_DATE('#dateformat(Now(),'mm/dd/yyyy')#', 'mm/dd/yyyy') ) ) ) )";
		} // current


		if (findNoCase("future", arguments.status) neq 0) {
			if ( datecriteria neq '' ) { datecriteria &= " OR " ; }
			// future only applies to DOL
			datecriteria &= " (budgetInputType = 'F' AND agreementTypeCode = 'DC' ) ";
		} // future

		if (findNoCase("closeout", arguments.status) neq 0) {
			if ( datecriteria neq '' ) { datecriteria &= " OR " ; }
			datecriteria &= " ( agreementTypeCode in ('DC','GR') AND dateEnd < TO_DATE('#dateformat(Now(),'mm/dd/yyyy')#', 'mm/dd/yyyy') AND contractStatusID = 1 ) ";
		} // closeout

		if (findNoCase("recon", arguments.status) neq 0) {
			// ignore contracts that were reconciled in FilePro before go-live
			if ( datecriteria neq '' ) { datecriteria &= " OR " ; }
			datecriteria &= " ( agreementTypeCode in ('DC','GR') AND lastReconYear + 1 < curContractYear AND dateEnd > TO_DATE('#dateformat(Now(),'mm/dd/yyyy')#', 'mm/dd/yyyy') AND lastCYearEndDate > TO_DATE('03/31/2007', 'mm/dd/yyyy') ) ";
		} // recon

		if ( datecriteria neq '') {
			cmd &= " AND ( " & datecriteria & " ) ";
		}

	} //arguments.status neq ""

	// determine whether IN or OUT of results, based on user's entry of EARLIEST/LATEST StartDate, and EARLIEST/LATEST EndDate

	// use '-' instead of '/' because it works with .serialize()
	if (arguments.contractStartDate1 neq '') {
		if (arguments.contractStartDate2 neq '') {
			cmd &= " AND datestart >= TO_DATE('#arguments.contractStartDate1#','mm-dd-yyyy') AND datestart <= TO_DATE('#arguments.contractStartDate2#','mm-dd-yyyy') ";
		} else {
			cmd &= " AND datestart >= TO_DATE('#arguments.contractStartDate1#','mm-dd-yyyy') " ;
		}
	} // arguments.contractStartDate1 neq ''
	else {
		if (arguments.contractStartDate2 neq '') {
			cmd &= " AND datestart <= TO_DATE('#arguments.contractStartDate2#','mm-dd-yyyy') " ;
		}
	}

	// Should an end test be different from a start???
	if (arguments.contractEndDate1 neq '') {
		if (arguments.contractEndDate2 neq '') {
			cmd &= " AND dateEnd >= TO_DATE('#arguments.contractEndDate1#','mm-dd-yyyy') AND dateEnd <= TO_DATE('#arguments.contractEndDate2#','mm-dd-yyyy') ";
		} else {
			cmd &= " AND dateEnd >= TO_DATE('#arguments.contractEndDate1#','mm-dd-yyyy') " ;
		}
	} // arguments.contractEndDate1 neq ''
	else {
		if (arguments.contractEndDate2 neq '') {
			cmd &= " AND dateEnd <= TO_DATE('#arguments.contractEndDate2#','mm-dd-yyyy') " ;
		}
	}

	cmd &= " ORDER BY #arguments.sortby# #arguments.sortDir#";

	</cfscript>

	<!--- here is where we break the home page --->
<!---
<cfdump var="#cmd#">
<cfabort>
--->
	<cfif session.debugemails>
		<cfsavecontent variable="dump1">
			<cfdump var="#cmd#"><br>
		</cfsavecontent>
		<cfset EmailScopes('Before executing cmd in getContractListingHomeforCheckboxes', dump1)>
	</cfif>
	<!--- convert comma-delimited lists to list of quoted items --->
	<cfquery name="qryContractListingHomeInList" >
		#PreserveSingleQuotes(cmd)#
	</cfquery>

	<cfreturn qryContractListingHomeInList>
</cffunction> <!--- getContractListingHomeforCheckboxes --->

<cfscript>
/**
* @hint I return a string with the % codes for special characters converted to the special characters
* @sKey is the string containing the % codes
*/
public string function convertToDisplayable ( sKey ) {

	// comma is special, because ReplaceList uses a comma-delimited list
	var sRet = Replace(arguments.sKey, "%2C", ",");
	sRet = ReplaceList(sRet,"%24,%3E,%3C,%3A,%26", "$,>,<,:,&");

	return sRet;

} // convertToDisplayable

/**
* @hint I return a filterSearchWord ready for a "LIKE" search in Oracle
* @sKey is the filterSearchWord entered by the user, and passed via ajax to a service that calls this routine
*/

public string function convertSearchKeyforSQL ( sKey ) {

	// here are special characters in the database 	- .,$><:()'&
	// here is what JS sends via ajax 				- .%2C%24%3E%3C%3A()'%26
	// here are mappings: , = %2C, $ = %24, > = %3E, < = %3C, : = %3A, & = %26

	var sNewKey = "";

	if ( FindOneOf ("'%&", arguments.sKey) EQ 0) {
		// nothing special
		sNewKey = arguments.sKey;
	} else {
		// convert the mapped characters to displayable, if any.  Comma is special, because ReplaceList uses a comma-delimited list
		sNewKey = convertToDisplayable ( arguments.sKey );

		// for SQL, double the apostrophe
		sNewKey = Replace( sNewKey, "'", "''", "all" );
		// break the string at the &
		sNewKey = Replace( sNewKey, "&", "&'||'", "all" );
	}

	return sNewKey;

} // convertSearchKeyforSQL


/**
* @hint I run the AAPP query, and generate (1) html for the home page data, and (2) html for the Filter Description, and (3) the effective length of the Filter Description, allowing 3 characters for each icon
* @formDataIn Structure containing arguments built either from JS form.serialize(), or from session.userPreferences.tMyFilterNow and URL variables
* @textOnly		should this be text only (no links?) 	1 = yes, 0 = no
* @sortBy		a column name from url
* @sortDir		asc/desc from url
* @roleID		from login
* @region		from login
*/
public struct function CFSessionDisplayDataColumnsGuts (
	required struct formDataIn
	, required textOnly
	, required sortBy
	, required sortDir
	, required roleID
	, region
	)

	output			= "false"
	{

	var tReturn = structNew();
	var tTemp = structNew();
	var qrow = 0;
	var nFilterLength = 0;

	if ( not listfind("3,4", arguments.roleID) ) {
		// run the query
		qAAPPListing = getContractListingHomeforCheckboxes(
			status					=formDataIn.home_contractStatusFilter
			, agreementType			=formDataIn.home_agreementTypeFilter
			, fundingOffice			=formDataIn.home_fundingOfficeFilter
			, state					=formDataIn.home_stateFilter
			, contractStartDate1	=formDataIn.home_contractStartDate1
			, contractStartDate2	=formDataIn.home_contractStartDate2
			, contractEndDate1		=formDataIn.home_contractEndDate1
			, contractEndDate2		=formDataIn.home_contractEndDate2
			, serviceType			=formDataIn.home_serviceTypeFilter
			, searchWord			=formDataIn.home_filterSearchWord
			, sortby				=arguments.sortBy
			, sortDir				=arguments.sortDir
		);

	} else {
		// add region to the filter
		// run the query
		qAAPPListing = getContractListingHomeforCheckboxes(
			status					=formDataIn.home_contractStatusFilter
			, agreementType			=formDataIn.home_agreementTypeFilter
			, fundingOffice			=formDataIn.home_fundingOfficeFilter
			, state					=formDataIn.home_stateFilter
			, contractStartDate1	=formDataIn.home_contractStartDate1
			, contractStartDate2	=formDataIn.home_contractStartDate2
			, contractEndDate1		=formDataIn.home_contractEndDate1
			, contractEndDate2		=formDataIn.home_contractEndDate2
			, serviceType			=formDataIn.home_serviceTypeFilter
			, searchWord			=formDataIn.home_filterSearchWord
			, sortby				=arguments.sortBy
			, sortDir				=arguments.sortDir
			, region				=arguments.region
		);
	}


	// loop over the query to produce the HTML for the table, and build the sAAPPNumList
	var sClass='';
	var sTRClass = '';
	// Don't use Valuelist. We want this list of AAPPNums to be in the sort order of the query
	var sAAPPNumList = '';
	if (textOnly) {
		sClass='form3DataTbl';
		sTRClass = 'form3AltRow';
	}
	else {
		sClass='AAPPHomeTbl';
		sTRClass = 'AltRow';
	}
	var sColumnsOfData = '<table id="idAAPPHomeTbl" width="100%" border="0" cellspacing="0" cellpadding="0" class="#sClass#" >';
	for (qrow = 1; qrow LE qAAPPListing.recordCount; qrow += 1) {
		sAAPPNumList &= (',' & qAAPPListing.aappNum[qrow]);
		sColumnsOfData &= '<tr valign="top" ';

		if ( not (qrow mod 2) ) {sColumnsOfData &= 'class="#sTRClass#"';}

		sColumnsOfData &= '><td style="width:6%;">';

		// Textpad "
		if( !arguments.textOnly) {
			sColumnsOfData &= '<a href="#application.paths.aapp#?aapp=' & qAAPPListing.aappNum[qrow] & '" title="Go to AAPP ' & qAAPPListing.aappNum[qrow] & '" >' & qAAPPListing.aappNum[qrow] & '</a>';
		}
		else {
			sColumnsOfData &= qAAPPListing.aappNum[qrow];
		}

		sColumnsOfData &= '</td><td style="width:6%;">' & qAAPPListing.fundingOfficeAbbr[qrow] & '</td><td style="width:22%;">' & qAAPPListing.centerName[qrow];

		// Textpad "
		if (qAAPPListing.centerName[qrow] neq ""){sColumnsOfData &= '<br>';}

		if (qAAPPListing.venue[qrow] neq ""){sColumnsOfData &= 'Venue:&nbsp;' & qAAPPListing.venue[qrow];}
		// Textpad '

		sColumnsOfData &= '</td><td style="width:22%;">' & qAAPPListing.programActivity[qrow] & '</td><td style="width:16%;">' & qAAPPListing.contractorName[qrow] & '</td><td style="width:12%;">' & qAAPPListing.contractNum[qrow] & '</td><td style="width:8%;">' & dateformat(qAAPPListing.dateStart[qrow], "mm/dd/yy") & '</td><td style="width:8%;">' & dateformat(qAAPPListing.dateEnd[qrow], "mm/dd/yy") & '</td></tr>';
		// Textpad "

	} // loop over qAAPPListing
	sColumnsOfData &= '</table>';

	tReturn.sColumnsOfData = sColumnsOfData;

	tTemp = BuildFilterDescription(qAAPPListing.recordCount, formDataIn, textOnly);

	tReturn.sFilterHTML = tTemp.sFilterHTML;
	tReturn.nFilterLength = tTemp.nFilterLength;
	if (Len(sAAPPNumList) GT 0) {
		tReturn.sAAPPNumList = Mid(sAAPPNumList, 2, Len(sAAPPNumList) - 1);
	} else {
		tReturn.sAAPPNumList = '';
	}
	tReturn.recordcount = qAAPPListing.recordcount;

	// NOT serializeJSON, because internal routine
	return tReturn;

} // CFSessionDisplayDataColumnsGuts

/**
* @hint I validate if a string is a date, and convert it to a consistent format to use when building an Oracle query string
* @tryDate A string that might be a date
*/
string function ValidateDate (
	string tryDate=''
	)

{
	if ( IsDate(arguments.tryDate) ) {
		return DateFormat(arguments.tryDate,'mm-dd-yyyy') ;
	} else {
		return '' ;
	}

} // ValidateDate

/**
* @hint I am a function to convert a list of filter codes to a list of short descriptions, e.g.: Funding Office = 1 becomes BOS.
* @sFilterType a filter type defined in application.userPreferencesDefault.slRequiredDefinedFilters , e.g. home_fundingOfficeFilter
* @slCodeList  list of valid codes for the filter
*/
string function ConvertFilterToText (
	required string sFilterType
	, required slCodeList
	)

{

	var ret = '';

	// code for the first case
	if (arguments.sFilterType EQ 'home_filterSearchWord') {
		// replace '+' with blank on search word.
		ret = slCodeList;
	}
	else {

		// convert each code to its text, and return the list.  The mapping from code to text is built in applicationVariablesSetup.cfm.
		if (ListLen(arguments.slCodeList) LE 4) {
			for (var walker = 1; walker le ListLen(arguments.slCodeList) ; walker +=1 ) {
				ret = ret & structFind(application.tCodeAbbreviations, arguments.sFilterType & ListGetAt(arguments.slCodeList, walker)) & ',';
			}
			// eliminate trailing comma
			ret = mid(ret, 1, len(ret) - 1);
		}
		else {
			ret = "Mult.";
		}
	}

	return ret;

} // ConvertFilterToText

/**
* @hint I am a function to build a descriptive string, showing filters in effect, and providing links to clear each particular filter.
* @recordCount Count of records that have been found
* @tPreferences  Structure containing Filters and Filter Values that have be selected by the user
*/
struct function BuildFilterDescription (
	required string recordCount
	, required struct tPreferences
	, required string textOnly
	)

{

	var tRet = StructNew();
	var sFilterHTML = '';
	var filterSegment = '';
	var nFilterLength = 0;

	var pnglink = '<img src="#application.paths.images#close.png" class="filterTextImg" name="filterSearch" alt="Delete this filter" /> ';

	// arguments are names of fields in $("##frmHomeFilter")
	if (arguments.textOnly) {
		// NOT using links
		if ( arguments.tPreferences.home_filterSearchWord NEQ '' ) {
			// convert the mapped characters to displayable, if any.  Comma is special, because ReplaceList uses a comma-delimited list
			filterSegment = convertToDisplayable(arguments.tPreferences.home_filterSearchWord);

			filterSegment = ' Keyword (' & ReplaceNoCase(filterSegment, "+", " ", "all") ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & '),' ;
		}
		if ( arguments.tPreferences.home_agreementTypeFilter NEQ '' ) {
			filterSegment = ' Agreement (' & ConvertFilterToText('home_agreementTypeFilter', arguments.tPreferences.home_agreementTypeFilter) ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & '),' ;
		}
		if ( arguments.tPreferences.home_fundingOfficeFilter NEQ '' ) {
			filterSegment = ' Fund Ofc (' & ConvertFilterToText('home_fundingOfficeFilter', arguments.tPreferences.home_fundingOfficeFilter) ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & '),' ;
		}
		if ( arguments.tPreferences.home_ContractStatusFilter NEQ '' ) {
			filterSegment = ' Status (' & ConvertFilterToText('home_ContractStatusFilter', arguments.tPreferences.home_contractStatusFilter) ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & '),' ;
		}
		if ( arguments.tPreferences.home_stateFilter NEQ 'all' ) {
			filterSegment = ' State (' & ConvertFilterToText('home_stateFilter', arguments.tPreferences.home_stateFilter) ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & '),' ;
		}
		if ( arguments.tPreferences.home_serviceTypeFilter NEQ '' ) {
			filterSegment = ' Svc Type (' & ConvertFilterToText('home_serviceTypeFilter', arguments.tPreferences.home_serviceTypeFilter) ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & '),' ;
		}
		if ( arguments.tPreferences.home_ContractStartDate1 NEQ '' ) {
			filterSegment = ' Start (' & arguments.tPreferences.home_ContractStartDate1 ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & '),' ;
		}
		if ( arguments.tPreferences.home_ContractStartDate2 NEQ '' ) {
			filterSegment = ' Start To (' & arguments.tPreferences.home_ContractStartDate2 ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & '),' ;
		}
		if ( arguments.tPreferences.home_ContractEndDate1 NEQ '' ) {
			filterSegment = ' End (' & arguments.tPreferences.home_ContractEndDate1  ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & '),' ;
		}
		if ( arguments.tPreferences.home_ContractEndDate2 NEQ '' ) {
			filterSegment = ' End To (' & arguments.tPreferences.home_ContractEndDate2 ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & '),' ;
		}
	}
	else {
		//using links
		// search word needs no conversion
		if ( arguments.tPreferences.home_filterSearchWord NEQ '' ) {
			filterSegment = ' Keyword (' & ReplaceNoCase(arguments.tPreferences.home_filterSearchWord, '+', ' ', 'all') ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & ')<a href="##" onclick="ClearFilterField(''home_filterSearchWord'')">' & pnglink & '</a>,' ;
		}
		if ( arguments.tPreferences.home_agreementTypeFilter NEQ '' ) {
			filterSegment = ' Agreement (' & ConvertFilterToText('home_agreementTypeFilter', arguments.tPreferences.home_agreementTypeFilter) ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & ')<a href="##" onclick="ClearFilterField(''cboAgreementTypeFilter'')">' & pnglink & '</a>,' ;
		}
		if ( arguments.tPreferences.home_fundingOfficeFilter NEQ '' ) {
			filterSegment = ' Fund Ofc (' & ConvertFilterToText('home_fundingOfficeFilter', arguments.tPreferences.home_fundingOfficeFilter) ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & ')<a href="##" onclick="ClearFilterField(''cboFundingOfficeFilter'')">' & pnglink & '</a>,' ;
		}
		if ( arguments.tPreferences.home_ContractStatusFilter NEQ '' ) {
			filterSegment = ' Status (' & ConvertFilterToText('home_ContractStatusFilter', arguments.tPreferences.home_contractStatusFilter) ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & ')<a href="##" onclick="ClearFilterField(''cboContractStatusFilter'')">' & pnglink & '</a>,' ;
		}
		if ( arguments.tPreferences.home_stateFilter NEQ 'all' ) {
			filterSegment = ' State (' & ConvertFilterToText('home_stateFilter', arguments.tPreferences.home_stateFilter) ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & ')<a href="##" onclick="ClearFilterField(''cboStateFilter'')">' & pnglink & '</a>,' ;
		}
		if ( arguments.tPreferences.home_serviceTypeFilter NEQ '' ) {
			filterSegment = ' Svc Type (' & ConvertFilterToText('home_serviceTypeFilter', arguments.tPreferences.home_serviceTypeFilter) ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & ')<a href="##" onclick="ClearFilterField(''cboServiceTypeFilter'')">' & pnglink & '</a>,' ;
		}
		if ( arguments.tPreferences.home_ContractStartDate1 NEQ '' ) {
			filterSegment = ' Start (' & arguments.tPreferences.home_ContractStartDate1 ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & ')<a href="##" onclick="ClearFilterField(''home_ContractStartDate1'')">' & pnglink & '</a>,' ;
		}
		if ( arguments.tPreferences.home_ContractStartDate2 NEQ '' ) {
			filterSegment = ' Start To (' & arguments.tPreferences.home_ContractStartDate2 ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & ')<a href="##" onclick="ClearFilterField(''home_ContractStartDate2'')">' & pnglink & '</a>,' ;
		}
		if ( arguments.tPreferences.home_ContractEndDate1 NEQ '' ) {
			filterSegment = ' End (' & arguments.tPreferences.home_ContractEndDate1  ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & ')<a href="##" onclick="ClearFilterField(''home_ContractEndDate1'')">' & pnglink & '</a>,' ;
		}
		if ( arguments.tPreferences.home_ContractEndDate2 NEQ '' ) {
			filterSegment = ' End To (' & arguments.tPreferences.home_ContractEndDate2 ;
			nFilterLength += len(filterSegment) + 4;
			sFilterHTML &= filterSegment & ')<a href="##" onclick="ClearFilterField(''home_ContractEndDate2'')">' & pnglink & '</a>,' ;
		}
	} // using links

	if ( sFilterHTML NEQ '' ) {
		sFilterHTML = "#arguments.recordCount# AAPPs found filtered by " & mid(sFilterHTML, 1, len(sFilterHTML) - 1) ;
		nFilterLength += 28;
	}
	else {
		sFilterHTML = "#arguments.recordCount# AAPPs found (No Filter)";
		nFilterLength += 28;
	}
	tRet.sFilterHTML = ltrim(rtrim(sFilterHTML)) ;
	tRet.nFilterLength = nFilterLength;

	return tRet;

} // BuildFilterDescription

/**
* @hint I build a CF structure from an argument created by JS form.serialize(). This does NOT write to the session scope
* @sCFFieldString Structure built by JS form.serialize() on the Filter Tab
*/
struct function ConvertFieldStringToPrefs (
	required string sCFFieldString
	)

{
	// split the Field string into separate field name/value pairs.  The javascript .serialize() has separated them by &amp;
	var walker = 0;
	var fieldvalue = '';
	var fieldname = '';
	var vamp = "&" ;
	var tPairs = structNew();
	var tPreferences = StructNew();

	// for each field from the form
	for (walker = 1; walker LE Listlen(arguments.sCFFieldString, vamp); walker = walker + 1) {
		thisPair = ListGetAt(arguments.sCFFieldString, walker, vamp);
		//writeOutput('thispair ' & thisPair & '<br>');

		fieldname = listGetAt(thisPair, 1, '=');
		fieldValue = '';
		// an '=' in the search term  will break this code
		if (findnocase('=', thisPair) NEQ len(thisPair)) {
			fieldvalue = listGetAt(thisPair, 2, '=');
		}
		//writeOutput(fieldname & ' ' & fieldvalue & '<br>');

		if (structKeyExists(tPairs, fieldname )) {
			// update the field that is already in the tPairs structure, by appending the value to the list of values for the field
			// a field can have multiple values, say for a set of checkboxes
			oldFieldValue = structFind(tPairs, fieldname);
			fieldValue = ListAppend(oldFieldValue, fieldValue);
			structUpdate(tPairs, fieldname, fieldValue);
		}
		else {
			structInsert(tPairs, fieldname, fieldValue);
		}
	}
	// writedump(tPairs);

	// set up a preferences structure with each key defined, WHETHER OR NOT IT IS IN THE FILTER TABLE.  A specific example of an exception is the list of MyAAPPs
	for (walker = 1; walker LE Listlen(application.userPreferencesDefault.slRequiredDefinedFilters ); walker = walker + 1) {
		if (ListGetAt(application.userPreferencesDefault.slFilterFormNames, walker) NEQ 'NotAFilter') {
			structInsert(tPreferences, ListGetAt(application.userPreferencesDefault.slRequiredDefinedFilters , walker), '', true);
		}
	}

	// this is a separate loop from above, since arguments may have had multiple values
	sKeyArray = structKeyArray(tPairs);
	// for each field that came in from the form
	for (walker = 1; walker LE arrayLen(sKeyArray); walker = walker + 1) {
		// get the matching required preference name
		listPtr =  listContainsNoCase(application.userPreferencesDefault.slFilterFormNames, sKeyArray[walker]);

		if(listPtr NEQ 0) {
			sesPrefName = ListGetAt(application.userPreferencesDefault.slRequiredDefinedFilters , listPtr);
			structInsert(tPreferences, sesPrefName, structFind(tPairs, sKeyArray[walker]), true);
		}
	}
	return tPreferences ;

} // ConvertFieldStringToPrefs

</cfscript>

</cfoutput>
</cfcomponent>
