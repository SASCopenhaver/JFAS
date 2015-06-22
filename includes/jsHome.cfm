<!--- jsHome.cfm --->
<!--- this is JS specific to home.cfm, but which uses some .cfm capability --->
<cfoutput>
<cfif application.cfEnv neq "dev">
	<!--- this immediately disables the "BACK" button --->
	<script language="javascript" src="#application.paths.jsdir#disableBackButton.js"></script>
</cfif>

<script language="javascript">
// jsHome.cfm

// global JS variables for these routines, which depends on CF, so they not in jfas.js

glJFAS.sAAPPHomeLink = '#application.urlstart##cgi.http_host##application.paths.components#aapp_home.cfc?isBackground=yes';
glJFAS.sGotoProblem = '#application.urls.root#problem.htm';
glJFAS.sGotoTimeout = '#application.urls.root#timeout.htm';
glJFAS.sGotoLogout = '#application.urls.root#logout.htm';
glJFAS.sHomeLoc = '#application.urls.root#';

// Validate the search form
function validateQuickSearch(form) {

	// belldr 05/27/2014 allow a number, or a keyword
	var sMethod = 'keyword';
	trimFormTextFields(form);

	if (form.quickaapp.value !== '' && form.quickaapp.value.length > 2 ) {
		if (!isNaN(form.quickaapp.value) && form.quickaapp.value.length < 6) {
			// keyword is possibly an AAPP. Tell the back end to try it
			sMethod = 'tryAAPP';
		}
		var formData = {
				method:'validateQuickSearch'
				 , aappNum:form.quickaapp.value
				 , sMethod:sMethod
				 } ; //array

		$.ajax(
			{
			type:	"POST"
			, url:	glJFAS.sAAPPHomeLink
			, data: formData
			, success: function(responseTxt,statusTxt,xhr){

				responseTxt	= $.parseJSON( responseTxt );
				// error message if appropriate
				if (responseTxt.substr(0, 4) === 'AAPP') {

					// this goes to AAPP Summary page, if there is a match
					GotoAAPP(form.quickaapp.value);

					// must return false, since this routine is the validation of a form
					return false;
				}

				else if (responseTxt.substr(0, 6) === 'Timeout') {
					document.location = glJFAS.sGotoTimeout;
					return false;
				}

				else if (responseTxt.substr(0, 4) === 'Home') {
					// the session variables were set by aapp_home(validateQuickSearch)
					// go home, using the new filter
					document.location = glJFAS.sHomeLoc;

					return false;
				}
				else {
					// show error, go home, using the new filter
					alert('validateQuickSearch unexpected return ' + responseTxt);
					document.location = glJFAS.sHomeLoc;
					return false;
				}
				return false;
				} // success

			, error: function(responseTxt,statusTxt,xhr){
				// getting spurious errors, here. ???  So, do alert them
				alert("Error in validateQuickSearch: "+responseTxt + ' ' + xhr.status+": "+xhr.statusText);
				return false;
				} // error
			} // ajax function
		); // ajax

		// This is the return that prevents the form from submitting

		return false;
	} // 3 or more characters

	else {
		alert('Search text must be between 3 and 50 characters');
		// must return false, since this routine is the validation of a form
		return false;
}
} // validateQuickSearch

function popAAPPsAjax(ClearField) {
	// finished with the checkbox timer
	//alert('in popAAPPsAjaxx');
	if ( glJFAS.nLatestCheckboxTimer != '') {
		clearInterval( glJFAS.nLatestCheckboxTimer);
	}
	 glJFAS.nLatestCheckboxTimer = '';

	// start the timer on completion of DisplayAAPPsAjax
	pushAAPPsCompletion();

	// save the filter variables from the form into the JS global area, for displayAAPPsAjax
	 glJFAS.sFieldString = $('##frmHomeFilter').serialize();

	// start the display - displayAAPPsAjax
	//alert('calling displayAAPPsAjax');
	displayAAPPsAjax(ClearField);
}

function pushAAPPsAjax (ClearField) {
	// this is about the delay for clicking multiple checkboxes
	if (glJFAS.nLatestCheckboxTimer != '') {
		clearInterval(glJFAS.nLatestCheckboxTimer);
	}
	// popAAPPsAjax will execute after the checkbox delay, to run DisplayAAPPsAjax
	glJFAS.nLatestCheckboxTimer = setInterval(function () {

		popAAPPsAjax(ClearField);

	}, glJFAS.nTimeForCheckboxes);
}


function pushAAPPsCompletion () {

	// this starts timer to be sure DisplayAAPPsAjax completes within a few seconds
	if (glJFAS.nLatestCompletionTimer != '') {
		clearInterval(glJFAS.nLatestCompletionTimer);
	}

	if ( glJFAS.nTimeForCompletion <=  glJFAS.nStandardTimeForCompletion ) {
		// NOT resetting filter. Use the standard time for executing AAPPs List
		 glJFAS.nTimeForCompletion =  glJFAS.nStandardTimeForCompletion;
	}
	glJFAS.nLatestCompletionTimer = setInterval(function () {

		popAAPPsCompletionFailed();

	},  glJFAS.nTimeForCompletion);

}

function popAAPPsCompletionFailed () {
	var sReturn = '';
	if (glJFAS.nLatestCompletionTimer == '') {
		// the flag was cleared by DisplayAAPPsAjax upon successful completion of the display
		return;
	}

	// finished with Completion timer
	clearInterval(glJFAS.nLatestCompletionTimer);
	glJFAS.nLatestCompletionTimer = '';

	// send message to developers

	sReturn = EmailScopesAjax('User had error or timeout on the home page list of AAPPs');

	// go to the problem page
	alert('The query is taking too long to process.');
	document.location = glJFAS.sGotoTimeout ;
	return false;

}

function displayAAPPsAjax (ClearField) {
	// this makes one ajax call, which updates session variables, and provides various returns in a structure:
	//	The HTML for the display of the data.
	//	The HTML for the string describing the filters in effect, which includes JS to call routines to clear filters.
	//  The length of the filter string
	//  etc.

	//alert('in displayAAPPsAjax');
	// 8/26/2014 belldr defense:  ensure there is a valid value for glJFAS.sSortBy and glJFAS.sSortDir

	var sValidSortByList = 'aappNum,fundingOfficeDesc,centerName,programActivity,contractorName,contractNum,dateStart,dateEnd';


	if (glJFAS.sSortBy === undefined || glJFAS.sSortBy.length === 0 || sValidSortByList.search(glJFAS.sSortBy) < 0) {
		glJFAS.sSortBy	= 'aappNum';
	}
	if (glJFAS.sSortDir === undefined || glJFAS.sSortDir.length === 0 ) {
		glJFAS.sSortDir	= 'asc';
	}
<!--- this link calls a cfc directly.  If there is an application.cfc in the path of the cfc, it is executed. We control which parts execute with isBackground=yes  --->
	var sStyle, nGap;
	// The CFSessionDisplayDataColumns UPDATES session variables
	if (typeof ClearField != 'undefined'  && ClearField != '') {
		// clear a field, and display based on filters
		var formData = {
			method:'DisplayDataColumnsClearOne'
			 , ClearField:ClearField     	// this is providing value from arguments.ClearField
			 , roleID:#session.roleID#		// integer
			 , region:#session.region#	// integer
			 , sortBy: glJFAS.sSortBy 			// from Javascript Global
			 , sortDir: glJFAS.sSortDir 			// from Javascript Global
			 } ; // object.  Each data value has a name

	} else {
		// just display, based on filters
		var formData = {
			method:'CFSessionDisplayDataColumns'
			 , sCFFieldString: glJFAS.sFieldString     // this is providing value JS global glJFAS.sFieldString as a value
			 , roleID:#session.roleID#			// integer
			 , region:#session.region#		// integer
			 , sortBy: glJFAS.sSortBy // from Javascript Global
			 , sortDir: glJFAS.sSortDir // from Javascript Global
			 } ; //array
	}

	$(".TopMarker").remove();

	$("##homeFooter,##ColumnHeadings").css("visibility", "hidden");
	$("##idFilterText").html('Processing...');
	$("##jfasDataDiv").html('');
	// disable all the input elements in the Filter Tab
	$("##idHomeFilterGuts :input").attr('disabled', true);

	$.ajax(
		{
		type:	"POST"
		, url:	 glJFAS.sAAPPHomeLink
		, data: formData
		, success: function(responseStructJSON,statusTxt,xhr){
			//alert("External content loaded successfully...!");
			//alert(responseStructJSON);

			// don't worry about calling ChekErrors, because error is caught by timeout routines.
			responseStruct	= $.parseJSON( responseStructJSON );
			sColumnsOfData	= responseStruct.SCOLUMNSOFDATA;
			// alert(jsdump(sColumnsOfData));
			sFilterHTML		= responseStruct.SFILTERHTML;

			// set global variable to be used by adjustHomeDivs()
			glJFAS.nFilterStringLength = 1 * responseStruct.NFILTERLENGTH;
			CheckForError(sColumnsOfData);
			// display the filter string
			$("##idFilterText").html(sFilterHTML);

			// display the data in columns, plus spacer

			sSpacer = '';
			if (responseStruct.RECORDCOUNT == 0) {
				sSpacer='<div class="AAPPSpacer">'
				+ 'No AAPPs meet the search criteria';
				+ '</div>';
			}
			else if (responseStruct.RECORDCOUNT < 5) {
				nGap = 14 * (6 - responseStruct.RECORDCOUNT);
				sStyle = 'padding: ' + nGap + 'px 0 ' + nGap + 'px 0;';
				sSpacer='<div class="AAPPSpacer" Style="' + sStyle + '">'
				+ ' ';
				+ '</div>';
			}

			$("##jfasDataDiv").html(sColumnsOfData + sSpacer);
			// enable the Filter Tab
			$("##idHomeFilterGuts :input").attr("disabled", false);
			// highlight the search word if it was used in the filter
			if (sFilterHTML.indexOf('home_filterSearchWord') >= 0 ) {
				$("##home_filterSearchWord").addClass("home_filterSearchWordActive");
			} else {
				$("##home_filterSearchWord").removeClass("home_filterSearchWordActive");
			}

			adjustHomeDivs();

			// homeFooter and ColumnHeadings have fixed content
			$("##homeFooter,##ColumnHeadings").css("visibility", "visible");

			// finished with Completion timer
			clearInterval(glJFAS.nLatestCompletionTimer);
			glJFAS.nLatestCompletionTimer = '';

			// clear possible "resetMyFilter" mode
			 glJFAS.nTimeForCompletion =  glJFAS.nStandardTimeForCompletion;

			} // success

		, error: function(responseStruct,statusTxt,xhr){
			//alert('in error in displayAAPPsAjax');
			//alert("Error: xhr.status: xhr.statusText "+xhr.status+": "+xhr.statusText);
			$("##homeFooter,##ColumnHeadings").css("visibility", "visible");
			// enable the Filter Tab
			$("##idHomeFilterGuts :input").attr("disabled", false);

			}
		}
	);

} // displayAAPPsAjax

function SaveMyAAPP (user_ID, aappNum) {
	// this makes one ajax call, which updates session variables, and provides two returns:
	//	The HTML for the display of the data.
	//	The HTML for the string describing the filters in effect, which includes JS to call routines to clear filters.

	<!--- this link calls a cfc directly.  If there is an application.cfc in the path of the cfc, it is executed. We control which parts execute with isBackground=yes  --->

	// clear a field, and display based on filters
	var formData = {
		method:'SaveMyAAPP'
		 , user_ID:user_ID     			// this is providing value from arguments.aappNum
		 , aappNum:aappNum     			// this is providing value from arguments.aappNum
		 } ; //array

	$.ajax(
		{
		type:	"POST"
		, url:	 glJFAS.sAAPPHomeLink
		, data: formData
		, success: function(responseTxt,statusTxt,xhr){
			responseTxt = $.parseJSON( responseTxt );
			// this is going to be a generic error handling plugin
			CheckForError(responseTxt);
			// clear the submitting tab
			$("##idAAPPPageOptions").css("visibility", "hidden");

			} // success

		, error: function(responseTxt,statusTxt,xhr){
			alert('in error in SaveMyAAPP');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			} // error
		}
	);

} // SaveMyAAPP

function GotoAAPP(aappNum) {

	document.location ="#application.paths.root#aapp/aapp_summary.cfm?aapp=" + aappNum;

} //GotoAAPP

function DisplayHomeNoFilter() {

	var SHTML, $Source, nLeft, sStyle;
	$(".TopMarker").remove();

	$Source	= $('##HeaderDiv');
	nLeft	= 1 * $Source.offset().left;
	sStyle	='margin-left:' + nLeft + 'px;';

	SHTML = '<div id="homeNoFilter" class="homeNoFilter TopMarker" style="'+ sStyle + '" >'
	+ '<a href="##" id="btnOpenFilter"  onclick="openFilterPanel();"><img src="#application.paths.images#arrow-right.png" class="ImgOnFilterTab" name="filterSearch" alt="View the filter panel" /></a>'
	+ '</div>';
	$(document.body).append(SHTML);
	$(".homeNoFilter").css("visibility", "visible");

} // DisplayHomeNoFilter

function openOneSubmenu(idSubMenu, user_ID, IsHomePage) {
	var idArray = ['idMyAAPPs','idMyFilters','idNewAAPP','idHomePageOptions','idAAPPPageOptions','idNameOneFilter','idAAPPChartOptions'];

	var SHTML = '';
	var sStyle = '';
	var selector, selectorTemp;
	var selector = '##' + idSubMenu;
	var nTop, nLeft, nRight, $Source, $Target, nTargetWidth, walker;
	// cannot use a global here.  Make sure this is consistent with jfas.less
	var hdrBgHeight = 57;
	var nDetailxAdjustment = -2;
	var nXAdjustment;
	var nYAdjustment;
	var sSubMenuPosition;

	// alert('$(selector).length) ' + $(selector).length);
	if ($(selector).length){
		// the submenu is in the document
		if ($(selector).css("visibility") == "visible") {
			// alert('$(selector).css("visibility") ' + $(selector).css("visibility"));
			// remove the open TopMessage
			$(selector).remove();
		}
		else {
			$(selector).css("visibility", "visible")
		}

	} else {
		// close any abandoned subMenus
		for (walker = 0; walker < idArray.length; walker += 1) {
			selectorTemp = '##' + idArray[walker];
			if(selector != selectorTemp && $(selectorTemp).length) {
				$(selectorTemp).remove();
			}
		}
		if (IsHomePage) {
			nXAdjustment = 0;
			nYAdjustment = 0;
			sSubMenuPosition = 'fixed';
		} else {
			nXAdjustment = nDetailxAdjustment;
			nYAdjustment = 2;
			// use absolute, not fixed, to let a submenu scroll off the page
			sSubMenuPosition = 'absolute';
		}
		<cfif session.RoleID neq 2>
			// adjust because there is no Admin Button when role is not 12 (admin)
			// belldr 1/8/2015 changed from 100 to 200, because BOTH Admin and Budget buttons are displayed for roleID = 2
			nXAdjustment = nXAdjustment - 200;
		</cfif>

		nTop	= 1 * cssToNumber('.PriNavDiv', 'height') + 1 * nYAdjustment + 1 * hdrBgHeight;
		// alert('idSubMenu ' + idSubMenu);
		// build and append a div

		if (idSubMenu == 'idHomePageOptions') {
			// height is set in jfas.less for .HomePageOptions

			nTargetWidth	= 200;
			//nPriNavHeight	= cssToNumber('.PriNavDiv', 'height');

			$Source	= $('##PriNavDivRight');
			// "Right" is horizontal position in from the right side
			nRight	= ($(window).width() - ($Source.offset().left + $Source.outerWidth()));

			// leave a few px to see if clears up issue that scrolling makes dropdown NOT appear on the next click
			nLeft	= 1 * $(window).width() - 1 * nRight - (1 * nTargetWidth) - 5;
			sStyle	= 'top:' + nTop + 'px;margin-left:' + nLeft + 'px;visibility:visible;';

			SHTML = '<div id="idHomePageOptions" class="TopMessage HomePageOptions TopMarker" style="' + sStyle + '" >'
			+ '<ul>'
			+ '<li><a href="##"  onclick="PrintAAPP();" title="Show PDF format of the AAPP list in another tab">Print AAPP Listing (PDF)</a></li>'
			+ '<li><a href="##"  onclick="SaveMyFilter(\'#session.userID#\');"  title="Save the checkboxes in the Filter Tab as a named My Filter">Save Current Filter</a></li>'
			+ '<li><a href="##"  onclick="ResetMyFilter();"  title="Set the checkboxes in the Filter Tab to the default">Reset Filter</a></li>'
			// comment out until implemented + '<li><a href="##"  onclick="javascript:GoToAAPPGraph (\'bullets.cfm?SortBy=\'+ glJFAS.sSortBy+\'&SortDir=\'+ glJFAS.sSortDir, \'JFG B1\');"  title="Display Bullet Chart for Selected AAPPs">Bullet Chart</a></li>'
			+ '<ul>'
			+ '</div>';

			$(document.body).append(SHTML);
		}

		else if (idSubMenu == 'idAAPPPageOptions') {

			// on DETAIL page, top left of idAAPPPageOptions so that top right of idAAPPPageOptions = bottom right of PriNavDivRight
			// DETAIL page cannot use global variable here
			nTargetWidth	= 155;

			$Source	= $('##PriNavDivRight');
			// "Right" is horizontal position in from the right side
			nRight	= ($(window).width() - ($Source.offset().left + $Source.outerWidth()));
			nLeft	= 1 * $(window).width() - 1 * nRight - (1 * nTargetWidth);
			// this padding is around the padding of the ul/li for "Save AAPP to My AAPPS"
			sdivStyle	= 'top:' + nTop + 'px;margin-left:' + nLeft + 'px;padding: 15px 10px 5px 10px;';

			// url.aapp is an integer
			SHTML = '<div id="idAAPPPageOptions" class="TopMessage AAPPPageOptions TopMarker" style="' + sdivStyle + '" >'
			+ '</div>';

			$(document.body).append(SHTML);

			// put the list into the div just written
			// this has additional styling!
			SHTML =  '<ul style="padding:0;margin:0;>'
			+ '<li style="padding: 0px;margin:0;"><a href="##"  onclick="SaveMyAAPP(\'#session.userID#\', #url.aapp#);">Save AAPP to My AAPPs</a></li>'
			+ '<ul>';
			$("##idAAPPPageOptions").html(SHTML);

		}
		// TextPad "

		else if (idSubMenu == 'idAAPPChartOptions') {

			// on DETAIL page, top left of idAAPPChartOptions so that top right of idAAPPChartOptions = bottom right of PriNavDivRight
			// DETAIL page cannot use global variable here
			nTargetWidth	= 155;

			$Source	= $('##PriNavDivRight');
			// "Right" is horizontal position in from the right side.  Leave room for PageOptions button
			nRight	= ($(window).width() - ($Source.offset().left + $Source.outerWidth()) + 40);
			nLeft	= 1 * $(window).width() - 1 * nRight - (1 * nTargetWidth);
			// this padding is around the padding of the ul/li for "Save AAPP to My AAPPS"
			sdivStyle	= 'top:' + nTop + 'px;margin-left:' + nLeft + 'px;padding: 15px 10px 5px 10px;';

			// url.aapp is an integer
			SHTML = '<div id="idAAPPChartOptions" class="TopMessage AAPPChartOptions TopMarker" style="' + sdivStyle + '" >'
			+ '</div>';

			$(document.body).append(SHTML);

			// put the list into the div just written
			// this has additional styling!
			SHTML =  '<ul style="padding:0;margin:0;>'
			+ '<li style="padding: 0px;margin:0;"><a href="##"  onclick="javascript:GoToAAPPGraph (\'aapp_line1.cfm?aapp=#url.aapp#\', \'JFGFComp#url.aapp#\');">AAPP Funding Comparison</a></li>'
			+ '<ul>';
			$("##idAAPPChartOptions").html(SHTML);

		}

		// TextPad "

		else if (idSubMenu == 'idMyAAPPs') {

			$Source	= $('.banner');
			// hard-coded value overrides jfas.less
			nLeft	= 1 * $Source.offset().left + 400 + nXAdjustment;
			sStyle	= 'top:' + nTop + 'px;margin-left:' + nLeft + 'px;position:' + sSubMenuPosition;
			SHTML = '<div id="idMyAAPPs" class="TopMessage MyAAPPs TopMarker" style="' + sStyle + '" >'
			+ '<form role="form" name="frmMyAAPPs" action="##" method="get"><div id="MyAAPPsList"></div></form></div>';
			$(document.body).append(SHTML);

			// put the list into the div just written
			ListMyAAPPs(user_ID);
		}

		else if (idSubMenu == 'idNewAAPP') {

			$Source	= $('##HeaderDiv');
			// hard-coded value overrides jfas.less
			nLeft	= 1 * $Source.offset().left + 600 + nXAdjustment;
			sStyle	='margin-left:' + nLeft + 'px;';

			SHTML = '<div id="idNewAAPP" class="TopMessage NewAAPP TopMarker" style="' + sStyle + '">'
			+ '<form role="form" id="frmNewContract" name="frmNewContract" action="##" method="post" >'
			+ '<input type="hidden" name="aapp" value="0" />'
			+ '<input type="hidden" name="hidmode" value="new" />'
			+ '<ul>'
			+ '<li><a href="#application.paths.root#aapp/aapp_setup.cfm?radAgreementType=DC&aapp=0">DOL</a></li>'
			+ '<li><a href="#application.paths.root#aapp/aapp_setup_ccc.cfm?radAgreementType=CC&aapp=0&hidmode=new">CCC</a></li>'
			+ '</ul>'
			+ '</form>'
			+ '</div>';

			$(document.body).append(SHTML);
		}

		else if (idSubMenu == 'idMyFilters') {
			$Source	= $('.banner');
			// hard-coded value overrides jfas.less
			nLeft	= 1 * $Source.offset().left + 500 + nXAdjustment;
			sStyle	= 'top:' + nTop + 'px;margin-left:' + nLeft  + 'px;position:' + sSubMenuPosition;
			SHTML = '<div id="idMyFilters" class="TopMessage MyFilters TopMarker" style="' + sStyle + '">'
			+ '<form role="form" name="frmMyFilters" action="##" method="post"  onsubmit="frmMyFiltersSubmit(this);">'
			+ '<div id="MyFiltersList">'
			+ '</div>'
			+ '</form>'
			+ '</div>';

			$(document.body).append(SHTML);
			// put the list into the div just written
			ListMyFilters(user_ID);

		}

		else if (idSubMenu == 'idNameOneFilter') {

			$Source	= $('##HeaderDiv');
			// make sure hard-coded value agrees with jfas.less
			nLeft	= 1 * $Source.offset().left + 400 + nXAdjustment;
			sStyle	= 'top:' + nTop + 'px;margin-left:' + nLeft + 'px;';

			SHTML =
			'<div id="idNameOneFilter" class="TopMessage NameOneFilter TopMarker" style="' + sStyle + '">'
			+ '<form role="form" name="frmNameOneFilter" id="frmNameOneFilter" action="index.cfm?jfasAction=dumpError"  method="post" method="post"  onsubmit="return frmNameOneFilterSubmit(this);">'
			+ '<a href="##" onclick="closeOneSubmenu(\'idNameOneFilter\');"> <b>Enter My Filter Name</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span class="caret"></span></a>'
			+ '<div id="NameOneFilterDetail">'
				+ '<br><input type="hidden" name="user_ID" value="#session.userID#">'
				+ '<label for="NameForOneFilter" class="filterRadioLabel">New Name:&nbsp;&nbsp;</label>'
				+ '<input type="text" maxlength="40" size="40" name="filterName" id="NameForOneFilter" value="" placeholder="Enter Name for Filter" />&nbsp;&nbsp;'
				+ '<input type="submit" name="btnFilter" value="Go" />'
				+ '<div id="idNameOneFilterDuplicate" style="margin-left:55px;">'
					+ '<BR>This is an existing My Filter.<br> Check to confirm overwrite&nbsp;&nbsp;'
					+ '<input type="checkbox" name="confirmOverwrite" id="confirmOverwrite" value="1" onclick="frmNameOneFilterSubmit(getElementById(\'frmNameOneFilter\'));"/>'
				+ '</div>'
			+ '</div>'
			+ '</form>'
			+ '</div>';

			$(document.body).append(SHTML);
		}
	}
	// alert('returning');
	return;
}

function closeOneSubmenu (idSubMenu) {
	// the TopMessage is always in a div: id="idTopMessage".  Only one submenu is open at a time
	var selector = '##' + idSubMenu;
	$(selector).remove();
}

function ListMyAAPPs (user_ID) {

	var formData = {
		method:'ListMyAAPPs'
		 , user_ID:user_ID     			// this is providing value from arguments.aappNum
		 } ; //array

	$.ajax(
		{
		type:	"POST"
		, url:	 glJFAS.sAAPPHomeLink
		, data: formData
		, success: function(responseTxt,statusTxt,xhr){
			// alert("External content loaded successfully...!");
			tResponse = $.parseJSON( responseTxt );
			// this is going to be a generic error handling plugin
			CheckForError(tResponse.SHTML);
			// adjust the height of the panel, depending on how may AAPPs are there
			ListMyAAPPsClean (tResponse);

			} // success
		, error: function(responseTxt,statusTxt,xhr){
			alert('in error in ListMyAAPPs');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			}
		}
	);

} //ListMyAAPPs

function ListMyFilters (user_ID) {

	var formData = {
		method:'ListMyFilters'
		 , user_ID:user_ID     			// this is providing value from arguments.aappNum
		 } ; //array

	$.ajax(
		{
		type:	"POST"
		, url:	glJFAS.sAAPPHomeLink
		, data: formData
		, success: function(responseTxt,statusTxt,xhr){
			// alert("External content loaded successfully...!");
			// alert(responseTxt);

			tResponse = $.parseJSON( responseTxt );
			// alert(jsdump(tResponse));
			// this is going to be a generic error handling plugin
			CheckForError(tResponse.SHTML);

			// adjust the height of the panel, depending on how may AAPPs are there
			// belldr removed "25 +" when removed header on form

			listMyFiltersClean(tResponse);

			} // success
		, error: function(responseTxt,statusTxt,xhr){
			alert('in error in ListMyFilters');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			}
		}
	);

} //ListMyFilters


function ClearJfasTimers () {
	// clear timers, to get things clear after an error

	clearInterval(glJFAS.nLatestCompletionTimer);
	glJFAS.nLatestCompletionTimer = '';

	clearInterval(glJFAS.nLatestResizingTimer);
	glJFAS.nLatestResizingTimer = '';

	clearInterval(glJFAS.nLatestCheckboxTimer);
	glJFAS.nLatestCheckboxTimer = '';

	return;
}

function CheckForError (eMessage, displayPassedMessage) {
//alert('in CheckForError');
//alert('typeof eMessage.length is ' + typeof eMessage.length);

	var sReturn = '';
	if (typeof eMessage.length === 'undefined' || eMessage.length < 6){
		return;
	}

	if(eMessage.substr( 0, 6 ) === "Error:") {
		ClearJfasTimers();
		// send an email with the message.
		sReturn = EmailScopesAjax(eMessage);

		if (typeof displayPassedMessage != 'undefined'  && displayPassedMessage === true) {
			alert(eMessage.substring(6));

		}
		else {
			alert('The action you are trying to perform has encountered an error. Returning to the Home Page.');
		}
		document.location = glJFAS.sHomeLoc;
	}
	else if(eMessage.substr( 0, 6 ) === "Fatal:") {
		ClearJfasTimers();
		// send an email with the message.
		sReturn = EmailScopesAjax(eMessage);

		if (typeof displayPassedMessage != 'undefined'  && displayPassedMessage === true) {
			alert(eMessage.substring(6));
		}
		else {
			alert('Your session timed out, or there has been an error from which we cannot recover. Please log in again ...');
		}
		document.location = glJFAS.sGotoLogout;
	}
	// no error, just return
	return;
}

function ListMyAAPPsClean (tResponse) {
	var newlen;
	if (tResponse.LISTLEN < 1) {
		newlen = '28px';
		$("##idMyAAPPs").css("height", newlen);
		$("##idMyAAPPs").css("width", '60px');
		$("##MyAAPPsList").html('None');
	}
	else {


		newlen = Math.round(parseFloat(22 * tResponse.LISTLEN)) + 'px';
		$("##idMyAAPPs").css("height", newlen);
		$("##idMyAAPPs").css("width", '115px');
		// display the current list
		$("##MyAAPPsList").html(tResponse.SHTML);
	}

} //ListMyAAPPsClean


function DeleteMyAAPP (user_ID, aappNum ) {
	var newlen;

	// delete an aappNum from this list, redisplay the list
	var formData = {
		method:'DeleteMyAAPP'
		 , user_ID:user_ID     			// this is providing value from arguments.aappNum
		 , aappNum:aappNum     			// this is providing value from arguments.aappNum
		 } ; //array

	$.ajax(
		{
		type:	"POST"
		, url:	 glJFAS.sAAPPHomeLink
		, data: formData
		, success: function(responseTxt,statusTxt,xhr){
			// alert("External content loaded successfully...!");
			tResponse = $.parseJSON( responseTxt );
			// this is going to be a generic error handling plugin
			CheckForError(tResponse.SHTML);
			// adjust the height of the panel, depending on how may AAPPs are there

			ListMyAAPPsClean (tResponse);
			} // success

		, error: function(responseTxt,statusTxt,xhr){
			alert('in error in DeleteMyAAPP');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			}
		} // success
	);

} //DeleteMyAAPP

function ResetMyFilter() {
	// set the filter to the default, and GO TO the Home page
	// allow ample time for display of AAPPs for the default filter
	// this should be 60000
	glJFAS.nTimeForCompletion = 60000;

	var formData = {
		method:'ResetMyFilter'
		 } ; //array

	$.ajax(
		{
		type:	"POST"
		, url:	glJFAS.sAAPPHomeLink
		, data: formData
		, success: function(responseTxt,statusTxt,xhr){
			var tReturn	= $.parseJSON( responseTxt );

			// CAPITALIZATION IS VITAL WHEN LOOKING AT JSON IN JS
			var bReturn = tReturn.BRETURN;
			// repaint the entire home page
			if (bReturn != 1) {
				// this will force a logout. Second argument says: Display THIS message
				CheckForError('Fatal:Problem resetting filter to default. Please log in again', true);
			}
			// go to home page
			document.location = glJFAS.sHomeLoc;

			}
		, error: function(responseTxt,statusTxt,xhr){
			alert('in error in ResetMyFilter');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			}
		}
	);
} //ResetMyFilter

function GoToMyFilter(user_ID, filterName) {
	var formData = {
		method:'ReadMyFilter'
		 , user_ID:user_ID     			// this is providing value from arguments.user_ID
		 , filterName:filterName     	// this is providing value from arguments.filterName
		 } ; //array

	$.ajax(
		{
		type:	"POST"
		, url:	 glJFAS.sAAPPHomeLink
		, data: formData
		, success: function(responseTxt,statusTxt,xhr){

			var bReturn	= $.parseJSON( responseTxt );
			if (!bReturn) {
				CheckForError('Fatal:Problem getting Filter: ' + filterName + '. Please log in again', true);
			}

			// repaint the entire home page
			document.location = glJFAS.sHomeLoc;
			} // success

		, error: function(responseTxt,statusTxt,xhr){
			alert('in error in GoToMyFilter');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			}
		}
	);

} //GoToMyFilter

function listMyFiltersClean (tResponse) {
	var newlen, width;
	if (tResponse.LISTLEN < 1) {
		newlen = '28px';
		$("##idMyFilters").css("height", newlen);
		$("##idMyFilters").css("width", '60px');
		$("##MyFiltersList").html('None');
	}
	else {
		newlen = Math.round(parseFloat(22  * tResponse.LISTLEN)) + 'px';
		$("##idMyFilters").css("height", newlen);
		var width = (Math.floor(10 + 10.5 * tResponse.WIDTH)) + 'px';
		$("##idMyFilters").css("width", width);
		// display the current list
		$("##MyFiltersList").html(tResponse.SHTML);
	}
}

function SaveMyFilter (user_ID) {
	// Gets name from the user, checks for duplicates, confirms overwrite if necessary, calls WriteMyFilter in jsHome
	openOneSubmenu('idNameOneFilter', user_ID, true);
	$("##NameForOneFilter").focus();

} // SaveMyFilter

function PrintAAPP () {
	// prints PDF of jfasDataDiv, sorted correctly
	// opens a separate window for the report
	window.open('#application.paths.reportdir#report_aapp_list.cfm?SortBy='+ glJFAS.sSortBy+'&SortDir='+ glJFAS.sSortDir);

} // PrintAAPP

function frmNameOneFilterSubmit(form) {
	// Check that name is duplicate, and get confirmation of overwrite
	var bConfirmOverwrite = 0;


	if (form.confirmOverwrite.checked) {
		bConfirmOverwrite = 1;
	}
	if (form.filterName.value == 'Now' || form.filterName.value == 'now') {
		alert('You cannot use the name: Now');
		return false;
	}
	if (form.filterName.value.indexOf('\'\'') >= 0 ) {
		alert('Illegal filter name Filter Name');
		return false;
	}

	var nReturn = WriteMyFilter (form.user_ID.value, form.filterName.value.trim(), bConfirmOverwrite);

	// be sure the normal submit of frmNameOneFilter does not go forward
	return false;

} // frmNameOneFilterSubmit

function WriteMyFilter (user_ID, filterName, bConfirmOverwrite) {
	// this makes one ajax call, which updates session variables, and provides two returns:
	//	The HTML for the display of the data.
	//	The HTML for the string describing the filters in effect, which includes JS to call routines to clear filters.

	<!--- this link calls a cfc directly.  If there is an application.cfc in the path of the cfc, it is executed. We control which parts execute with isBackground=yes  --->

	var formData = {
		method:'WriteMyFilter'
		 , user_ID:user_ID     			// this is providing value from arguments.user_ID
		 , filterName:filterName     	// this is providing value from arguments.filterName
		 , bConfirmOverwrite:bConfirmOverwrite     	// 1 if overwrite is allowed, otherwise 0
		 } ; //array


	$.ajax(
		{
		type:	"POST"
		, url:	 glJFAS.sAAPPHomeLink
		, data: formData
		, success: function(responseTxt,statusTxt,xhr){
				responseTxt	= 1 * $.parseJSON( responseTxt );
				if (responseTxt === 0) {
					// session timeout
					CheckForError('Fatal:Your session timed out, or there has been an error from which we cannot recover. Please log in again ...', true);
				}
				else if (responseTxt === 1) {
					// There was no Duplicate MyFilter. Clear the submitting tabs
					$(".HomePageOptions").css("visibility", "hidden");
					$(".NameOneFilter").css("visibility", "hidden");
					$("##idNameOneFilterDuplicate").css("visibility", "hidden");
				}
				else {
					// responseTxt = 2
					// show the confirmation checkbox, and wait for the user
					$("##idNameOneFilterDuplicate").css("visibility", "visible");
				}

			}
		, error: function(responseTxt,statusTxt,xhr){
			alert('in error in WriteMyFilter');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			}
		}
	);


} // WriteMyFilter

function DeleteMyFilter (user_ID, filterName ) {

	var vfilterName = filterName.trim();
	var formData = {
		method:'DeleteMyFilter'
		 , user_ID:user_ID     			// this is providing value from arguments.user_ID
		 , filterName:vfilterName     	// this is providing value from arguments.filterName
		 } ; //array

	$.ajax(
		{
		type:	"POST"
		, url:	 glJFAS.sAAPPHomeLink
		, data: formData
		, success: function(responseTxt,statusTxt,xhr){

			// alert("External content loaded successfully...!");
			tResponse = $.parseJSON( responseTxt );

			CheckForError(tResponse.SHTML);

			listMyFiltersClean(tResponse);

			} // success

		, error: function(responseTxt,statusTxt,xhr){
			alert('in error in DeleteMyFilter');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			} // error
		} // ajax function
	); // ajax

} //DeleteMyFilter

// this routine from http://stackoverflow.com/questions/1248849/converting-sanitised-html-back-to-displayable-html
function htmlDecode(input){
  var e = document.createElement('div');
  e.innerHTML = input;
  return e.childNodes[0].nodeValue;
}

function adjustSortBy (columnName) {
	// adjust the global JS variables to reflect the click of a column heading. Then display the AAPPs
	if(columnName == glJFAS.sSortBy) {
		if( glJFAS.sSortDir == 'asc') {
			 glJFAS.sSortDir = 'desc';
		}
		else {
			 glJFAS.sSortDir = 'asc';
		}
	}
	else {
		 glJFAS.sSortDir = 'asc';
	}
	 glJFAS.sSortBy = columnName;

	popAAPPsAjax ('');
}

function adjustFilterTab (ClearField) {
	//Adjust the filter tab to reflect the clearing of a field
	var selector='';
	var plainFields = ['home_filterSearchWord','home_ContractStartDate1','home_ContractStartDate2','home_ContractEndDate1','home_ContractEndDate2'];
	if (plainFields.indexOf(ClearField) >= 0) {
		// clear text field
		selector = '##' + ClearField;
		$(selector).val('');
	}
	else if (ClearField == 'cboStateFilter') {
		// set a select to a default value
		selector = '[name=' + ClearField+ ']';
		$(selector).val('all');
	}

	else  {
		// uncheck a set of check boxes.  The checkboxes in a set all have the same name.
		selector = '[name=' + ClearField+ ']';
		$(selector).prop("checked", false);
	}

}

function ClearFilterField (ClearField) {

	// set the selected filter to default in frmHomeFilter, and redisplay the data columns by submitting frmHomeFilter
	// field name is one of home_filterSearchWord, cboAgreementTypeFilter, cboFundingOfficeFilter, cboContractStatusFilter, cboStateFilter,  cboServiceTypeFilter

	adjustFilterTab (ClearField);

	popAAPPsAjax (ClearField);

}

function EmailScopesAjax (subject) {

	var formData = {
		method:'EmailScopesAjax'
		 , subject:subject     			// this is providing value from arguments.subject
				 } ; //array

	// prevent an endless loop sending emails about email failures
 	if (glJFAS.bEmailIsWorking) {
			$.ajax(
				{
				type:	"POST"
				, url:	 glJFAS.sAAPPHomeLink
				, data: formData
				, success: function(responseTxt,statusTxt,xhr){
				responseTxt	= $.parseJSON( responseTxt );

				if (responseTxt.substr( 0, 6 ) === 'Fatal:') {
					// We have an error from sending the email, itself. Just shut off sending emails, and ignore the fact this email did not go.
					glJFAS.bEmailIsWorking = false;
					}

				} // success

		, error: function(responseTxt,statusTxt,xhr){
				//alert('in error in EmailScopesAjax');
				//alert("Error- "+xhr.status+": "+xhr.statusText);
					glJFAS.bEmailIsWorking = false;
				} // error
			} // ajax function
		); // ajax
	} // glJFAS.bEmailIsWorking

} // EmailScopesAjax

function displaySessionAnnouncement() {

	if ('#session.Announcement#' !== '') {
		//alert('#JSStringFormat(session.Announcement)#');
		// adjust the height of the alert box to accomodate the text
		var nHeight = #session.nAnnouncementHeight#;
		var nWidth = #session.nAnnouncementWidth#;
		$('##SessionAnnouncement').css('height', nHeight);
		$('##SessionAnnouncement').css('width', nWidth);
		glJFAS.oAnnouncementPopup = $('##SessionAnnouncement').bPopup({
            follow: [false, false], //x, y
			//autoClose: 4000,
			//transition: 'fadeIn',
			//speed: 650,
            position: ['auto', 100], //x, y
			opacity: 0.5,
			modalColor: '##073053' // color of background behind the modal "window" with the announcement
		});

		clearSessionAnnouncement();

	} // there is a non-blank announcement

} // displaySessionAnnouncement

function clearSessionAnnouncement () {

	var formData = {
		method:'clearSessionAnnouncement'
				 } ; //array

	$.ajax(
		{
		type:	"POST"
		, url:	 glJFAS.sAAPPHomeLink
		, data: formData
		, success: function(responseTxt,statusTxt,xhr){
		responseTxt	= $.parseJSON( responseTxt );

		} // success

		, error: function(responseTxt,statusTxt,xhr){
		} // error
	} // ajax function
); // ajax

} // clearSessionAnnouncement

</script>
</cfoutput>
