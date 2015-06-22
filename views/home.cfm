<!--- home.cfm --->

<!--- functions for displaying data in various divs --->
<cfinclude template="#application.paths.includes#headerDisplayFunctions.cfm">
<cfinclude template="#application.paths.includes#homeDisplayHomeFilter.cfm">
<cfscript>
// this is CF, NOT JS
public boolean function BooleanFormat (sTry) {
	var bRet=false;

	if (YesNoFormat(arguments.sTry) EQ 'Yes') {
		bRet=true;
	}

	return bRet;

} // BooleanFormat
</cfscript>

<!--- links to something with id="pagebody" --->

<cfif structKeyExists(url, 'dumpscopes')>
	<cfset DumpScopes('in Home Page')>
	<cfabort>
</cfif>


<!--- begin HTML --->
<!--- set up header for home page. Set up doctype, load css libraries --->
<!--- styled in jfas.less to be below the navbar --->

<cfset DisplayHTMLSetup('yes')>

<div id="HomeSurround" class="HomeSurround">

	<!--- div around the whole heading - there is no table here --->
	<div id = "HeaderDiv" class="HeaderDiv">
		<cfset DisplayTopUI('yes')>
	</div>
	<!-- /HeaderDiv -->

	<!--- column headings are with the banner, below the title (home-specific) --->

	<!--- to keep the Filter Tab, Filter Text, and column headings together --->
	<!--- these ARE ALL z-indexed over the scrolling area--->

	<div id="FilterandColumnHeadings">
		<cfset DisplayHomeFilter()>
		<cfset DisplayFilterText()>
		<cfset DisplayColumnHeadings()>
		<div class="clear"></div>
	</div>
	<!-- /FilterandColumnHeadings -->

	<!--- removed container and row from the lower area of the home page --->
	<div id="idLowerContainer" class="lowerContainer">

		<div  class="ScrollingArea">

			<div id="jfasDataDiv">
			</div>
			<!-- /jfasDataDiv -->

			<!--- the footer is in the scrolling area, but NOT in the jfasDataDiv --->
			<div class="clear"></div>
			<!--- this routine is only for the Home page --->
			<cfset DisplayHomeFooter()>

		</div>
		<!-- /ScrollingArea -->

	</div>
	<!-- /lowerContainer -->


</div>
<!-- /HomeSurround -->

<cfinclude template="#application.paths.includes#jsPackage.cfm">

<!--- HERE IS WHERE WE LOAD THE DIVS --->
<!--- javascript at the end, for fast loading --->
<cfoutput>
<script>
  $(function() {
    $( ".home_filterDate" ).datepicker({
      showOn: "button",
      buttonImage: "#application.urls.cssdir#images/calendar_icon.gif",
      buttonImageOnly: true,
      buttonText: "Select date",
      changeMonth: true,
      changeYear: true,
      dateFormat: "mm-dd-yy"
    });
  });

$("document").ready(function(){

	<!--- JS, with CFOUTPUT --->
	//alert('home ready');

	// initialize global variables
	// note: this approach implies a one-page JS application...

	init();
	//alert('after init');

	<!--- this is set if structKeyExists (url, 'debugemails') --->
	if (#BooleanFormat(session.debugemails)#) {
		setdalert(true);
	}
	dalert('session.debugemails is set');

	// these functions must be within .ready() !!! because of  glJFAS.sFieldString =  $( "##frmHomeFilter" ).serialize();

	var MasterFilterDate = function ( aselector, adescription ) {
		// I check one date on the Filter Tab, and alert if there is a problem
		// see Functional method for calling JS functions in Javascript: The Good Parts, p.52

		// this has properties:
		//	selector
		//	description
		//	value

		// this has methods
		//	CheckFilterDate (internal)
		//	cleanFilterDate

		var that = {};

		var selector = aselector;
		var description = adescription;

		// setting a value in the function, based on the selector.  "value" is used by the caller.
		// This is addressed from outside this object by MasterFilterDate.value

		var value = ( replaceAll('-', '/', $( selector ).val()) );

		// method
		var CheckFilterDate = function () {

			// Returns true if value is a date format or is NULL
			// otherwise returns false
			if (value.length === 0) {
				return true;
			}

			// Returns true if value is a date in the mm/dd/yyyy format
			var isplit = value.indexOf('/');
			if (isplit === -1 || isplit === value.length) {
				return false;
			}

			var sMonth = value.substring(0, isplit);
			isplit = value.indexOf('/', isplit + 1);

			if (isplit === -1 || (isplit + 1 ) === value.length) {
				return false;
			}

			var sDay = value.substring((sMonth.length + 1), isplit);
			var sYear = value.substring(isplit + 1);
			if (!checkInteger(sMonth) || sMonth.length > 2) { //check month
				return false;
			}

			if (!checkRange(sMonth, 1, 12)) { //check month
				return false;
			}

			// 5/8/2014 bellenger allow a 2-year date
			if (sYear.length !== 4 && sYear.length !== 2) {
				return false;
			}

			if (!checkInteger(sYear)) { //check year
				return false;
			}

			var fourDigitYear = sYear;

			if (1 * fourDigitYear < 100) {
				fourDigitYear = (2000 + 1 * fourDigitYear).toString();
			}
			if (!checkRange(fourDigitYear, 1950, 2050)) {
				return false;
			}
			if (!checkInteger(sDay) || sDay.length > 2) { //check day
				return false;
			}

			if (!checkDay(fourDigitYear, 1 * sMonth, 1 * sDay)) { // check day
				return false;
			}

			// modify the value in this object
			value = sMonth + '/' + sDay + '/' + fourDigitYear;
			return true;

		} ;  // CheckFilterDate


		var CleanFilterDate = function () {

			if ( CheckFilterDate() ) {
				// change / to - in the calling date, since / does not serialize, and use the clean date from the object.
				$( selector ).val( replaceAll('/', '-', value) );

				return true;
			}
			else {
				alert('Problem with ' + description + '. ' + $( selector ).val() + ' is invalid' );
				$( selector ).val('');
				return false;
			}
		} // CleanFilterDate

		// expose these to the creator of this object
		that.value = value;
		that.CleanFilterDate = CleanFilterDate;

		return that;

	} // MasterFilterDate


	function Check2Dates ( selector1, description1, selector2, description2 ) {

		// get date values from the form, based on the jQuery selector
		var $Date1 = $( selector1 ).val();
		var $Date2 = $( selector2 ).val();

		if ( $Date1 == '' ||  $Date2 == '' ) {
			return true;
		}
		if (Date.parse( $Date2 ) < Date.parse( $Date1 ) ) {
			alert(description2 + ' must be equal to or greater than ' + description1);
			return false;
		}
		return true;

	} // Check2Dates

	function CheckFilterSearchWord(sSearchWord) {

		if ( sSearchWord.length > 0 && ( sSearchWord.length < 3 || sSearchWord.length > 50) ) {
			alert('SearchKey must be between 3 and 50 characters');
			return false;
		}
	if (sSearchWord.indexOf('\*') >= 0 || sSearchWord.indexOf('\%') >= 0 || sSearchWord.indexOf('\"') >= 0 || sSearchWord.indexOf('\+') >= 0 ) {
		alert('Special characters are not allowed in the SearchKey');
		return false;
	}

		return true;

	} // CheckFilterSearchWord


	function Check4Dates () {

		// I check that all 4 dates in the filter tab pass validity tests

		// Make a JS object for each of the 4 dates.  The object contains the value of the date, and supporting method
		var oContractStartDate1	= MasterFilterDate( '##home_ContractStartDate1', 'Earliest Contract Start Date');
		var oContractStartDate2	= MasterFilterDate( '##home_ContractStartDate2', 'Latest Contract Start Date');
		var oContractEndDate1	= MasterFilterDate( '##home_ContractEndDate1', 'Earliest Contract End Date');
		var oContractEndDate2	= MasterFilterDate( '##home_ContractEndDate2', 'Latest Contract End Date');

		if ( ! oContractStartDate1.CleanFilterDate ()
					|| ! oContractStartDate2.CleanFilterDate ()
					|| ! oContractEndDate1.CleanFilterDate ()
					|| ! oContractEndDate2.CleanFilterDate () ) {
			// one of the 4 dates is invalid per se
			return false;
		}

		// verify that the first date is LE the second date
		if ( ! Check2Dates( '##home_ContractStartDate1', 'Earliest Contract Start Date', '##home_ContractStartDate2', 'Latest Contract Start Date' )) {
			return false;
		}

		if ( ! Check2Dates( '##home_ContractEndDate1', 'Earliest Contract End Date', '##home_ContractEndDate2', 'Latest Contract End Date' )) {
			return false;
		}

		if ( ! Check2Dates( '##home_ContractStartDate1', 'Earliest Contract Start Date', '##home_ContractEndDate2', 'Latest Contract End Date' )) {
			return false;
		}

		if ( ! Check2Dates( '##home_ContractStartDate2', 'Latest Contract Start Date', '##home_ContractEndDate2', 'Latest Contract End Date' )) {
			return false;
		}

		return true;

	} // Check4Dates

	function submitFiltersPanel() {
		// this is a validation routine for the Home Page )i.e. the Go on the Filtertab)
		var $home_filterSearchWord = $( '##home_filterSearchWord' ).val();
		if (! Check4Dates()) {
			return false;
		}

		if (! CheckFilterSearchWord($home_filterSearchWord)) {
			return false;
		}

		else {
			// dates passed the initial edits - check that latest date is >= earliest

			popAAPPsAjax();
			// this prevents the default action of submitFiltersPanel
			return false;
		}

	}  // submitFiltersPanel

	// This is for the initial view of the home page.
	// Turn on listening for the submit button in the homeFilter form to be clicked. When clicked, executes submitFiltersPanel(), above

	$("##frmHomeFilter").on( "submit", submitFiltersPanel );

	// test a plugin
	// $(".bannerLogoutNav").greenify({'color':'blue', backgroundColor: "red"});
	// This is the initial display using the session filter values from the database, when the person logs on

	// this displays the AAPP records on the Home Page, based on the current MyFilter
	popAAPPsAjax('');
	displaySessionAnnouncement();

}); // ready

</script>
</cfoutput>

</body>
</html>

<!--- END of home.cfm --->