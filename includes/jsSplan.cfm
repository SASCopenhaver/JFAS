<!--- jsSplan.cfm --->
<!--- this is JS specific to the Budget/Splan "module", but which uses some .cfm capability --->
<cfoutput>
<cfif application.cfEnv neq "dev">
	<!--- this immediately disables the "BACK" button --->
	<script language="javascript" src="#application.paths.jsdir#disableBackButton.js"></script>
</cfif>

<script language="javascript">
// jsSplan.cfm

// global JS variables for these routines, which depends on CF, so they not in jfas.js

glJFAS.sAAPPHomeLink = '#application.urlstart##cgi.http_host##application.paths.components#aapp_home.cfc?isBackground=yes';

glJFAS.sSplanLink = '#application.urlstart##cgi.http_host##application.paths.components#splan_ajax.cfc?isBackground=yes';

glJFAS.sGotoProblem = '#application.urls.root#problem.htm';
glJFAS.sGotoTimeout = '#application.urls.root#timeout.htm';
glJFAS.sGotoLogout = '#application.urls.root#logout.htm';
glJFAS.sHomeLoc = '#application.urls.root#';

// this is JAVASCRIPT!!!

function gotoSplanTransBridge ( that, splancatid, icol ) {

	//alert('in gotoSplanTransBridge splancatid ' + splancatid + ' icol ' + icol);
	var sourcex = $(that).offset().left;
	var sourcey = $(that).offset().top;
	var aPosition = new Object;
	//aPosition = [ 'auto', 25 ];
	aPosition[0] = sourcex;
	aPosition[1] = sourcey + 15; // move it just below the number
	//alert(JSON.stringify( aPosition, null, 4));
	//alert ('$(that).attr(\'id\') ' + $(that).attr('id') );

	// close (not hide) any existing popup, by clicking its close button
	// close any popup already open
	$('.b-close').each(function(index) {
		$(this).click();
	});
	that.style.cursor = 'wait';
	var formData = {
		method:'MakeBridgePopupHTML'
		 , splancatid:splancatid     			// this is providing value from arguments.splancatid
		 , icol:icol     						// this is providing value from arguments.splancatid
		 } ; //array

	$.ajax(
		{
		type:	"POST"
		, url:	 glJFAS.sSplanLink
		, data: formData
		, success: function(responseTxt,statusTxt,xhr){
			// alert("External content loaded successfully...!");

			tResponse = $.parseJSON( responseTxt );

			//alert('in success');
			//alert(jsdump( tResponse ));

			// set the contents of the popup.  "b-close" is an important class, which is the default class the bPopup recognizes as a "close" button
			var sButton = '<div style="width:100%;text-align:right;" title="Close" class="b-close"><img src="#application.paths.images#close.gif" class="filterTextImg" alt="Close" /></div>';
			$( '##BridgeTooltip' ).html( sButton + tResponse.SRET );

			$( "##BridgeTooltip" ).css("height", tResponse.HEIGHT );
			$( "##BridgeTooltip" ).css("width", tResponse.WIDTH );
			$( "##BridgeTooltip" ).css('opacity','1');
			that.style.cursor = 'default';

			// calculate position for popup, based on the item that was clicked, and the dimensions of the popup

			// prevent the whole spend plan report from scrolling to the top of the report, when a popup is requested
			//savedtop = sourcey - 20;
			//$('html, body').animate({
			//	scrollTop: savedtop
			//});


			// display the popup
			$('##BridgeTooltip').bPopup({
				//autoClose: 5000,
				positionStyle: 'absolute', //'fixed' or 'absolute'
				//fadeSpeed: 'fast', //can be a string ('slow'/'fast') or int
				followSpeed: 'fast', //can be a string ('slow'/'fast') or int
				//speed: 450,
				//transition: 'slideIn',
				//transitionClose: 'slideBack'

				position : aPosition,
				follow: [false, false],

				//position: [xsource, ysource], //x, y
				opacity: 0.5,
				modal: false,
				// scrollBar: true,
				modalColor: '##073053' // color of background behind the modal "window" with the announcement

			});


		} // success
		, error: function(responseTxt,statusTxt,xhr){
			alert('in error in gotoSplanTransBridge');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			}
		}
	);

} // gotosplan_transaction_list

function openOneSplanmenu ( idSubMenu, user_ID ) {

	// user_ID allows you to get to the right preferences

	var idArray = [ 'idSplanOptsSplanMain', 'idSplanOptsSplanTransList' ];
	// alert (' in openOneSplanmenu with ' + idSubMenu );
	var SHTML = '';
	var sStyle = '';
	var selector, selectorTemp;
	// selects the drop-down menu, not the options button
	var selector = '##' + idSubMenu;
	var nTop, nLeft, nRight, $Source, $Target, nTargetWidth, walker;
	// cannot use a global here.  Make sure this is consistent with jfas.less
	var hdrBgHeight = 57;
	// determined empirically
	var nOptionButtonTop = hdrBgHeight + 140;
	var nDetailxAdjustment = -2;
	var nXAdjustment;
	var nYAdjustment;
	var sSubMenuPosition;
	var budgetSubheaderLeftWidth;
	var sBorderString = 'border-top:0;border-right:1px solid white;border-bottom:1px solid white;border-left:1px solid white;';

	//alert('selector is ' + selector);
	//alert('$(selector).length) ' + $(selector).length);
	if ($(selector).length){
		// the submenu is in the document
		if ($(selector).css("visibility") == "visible") {
			// alert('$(selector).css("visibility") ' + $(selector).css("visibility"));
			// remove the open TopMessage (that is, the dropdown, which has class="Topmessage"
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
		nXAdjustment = nDetailxAdjustment;
		nYAdjustment = 2;
		// use absolute, not fixed, to let a submenu scroll off the page
		sSubMenuPosition = 'absolute';

		nTop	= 1 * cssToNumber('.PriNavDiv', 'height') + 1 * nYAdjustment + 1 * nOptionButtonTop;

		// build and append a div

		// BUDGET MAIN SCREEN - Current Spend Plan (splan_main.cfm)
		if (idSubMenu == 'idSplanOptsSplanMain' ) {

			// this displays a list of links

			nTargetWidth	= 200;
			nHeight = 80;
			// base this on the position of ##btnOptions
			$Source	= $('##btnOptions');
			nSourceWidth =  cssToNumber($Source, 'width')
			// "Right" is horizontal position in from the right side.
			nRight	= ($(window).width() - ($Source.offset().left + $Source.outerWidth()));
			// this the the target left position for the dropdown.
			// small adjustment to make the drop-down under the button, considering the border
			nLeft	= 1 * $(window).width() - 1 * nRight - (1 * nSourceWidth) - 1 ;
			sStyle	= sBorderString+'top:' + nTop + 'px;margin-left:' + nLeft + 'px;height:' + nHeight + 'px;position:' + sSubMenuPosition;
			// this is a div added to the document, not relative to some other div

			SHTML = '<div id="'+idSubMenu+'" class="TopMessage BudgetOptions TopMarker" style="' + sStyle + '" >'
			+ '<ul>'
			+ '<li><a href="#application.paths.budgetdir#splan_display_settings.cfm" title="Customize the Display of the Spend Plan">Display Settings</a></li>'
			+ '<li><a href="#application.paths.budgetdir#splan_edit.cfm?actionMode=Add&CancelReturn=SpendPlan" title="Create a new Spend Plan Transaction">Add Transaction</a></li>'
			+ '<li><a href="#application.paths.budgetdir#splan_main_report.cfm" title="Generate an Excel Spreadsheet of this Spend Plan">Generate Report</a></li>'
			+ '<ul>'
			+ '</div>';

			$(document.body).append(SHTML);
		}

		// TRANSACTION LISTING WINDOW (splan_transaction_list.cfm)
		else if (idSubMenu == 'idSplanOptsSplanTransList') {

			// this displays a list of links

			// align the RIGHT of the dropdown with the RIGHT of the button
			// width of the dropdown
			nTargetWidth = 120;
			nHeight = 60;
			// base this on the position of ##btnOptions
			$Source	= $('##btnOptions');
			nSourceWidth =  cssToNumber($Source, 'width')
			// "Right" is horizontal position in from the right side.
			nRight	= ($(window).width() - ($Source.offset().left + $Source.outerWidth()));
			// this the the target left position for the dropdown.
			// small adjustment to make the drop-down under the button, considering the border
			nLeft	= 1 * $(window).width() - 1 * nRight - (1 * nSourceWidth) - 1 ;
			// this padding is around the padding of the ul/li
			sStyle	= sBorderString+'top:' + nTop + 'px;margin-left:' + nLeft + 'px;height:' + nHeight + 'px;position:' + sSubMenuPosition;
			// this is a div added to the document, not relative to some other div
			SHTML = '<div id="'+idSubMenu+'" class="TopMessage BudgetOptions TopMarker" style="' + sStyle + '" >'
			+ '<ul>'
			+ '<li><a href="#application.paths.budgetdir#splan_edit.cfm?actionMode=Add&CancelReturn=TransList" title="Create a new Spend Plan Transaction">Add Transaction</a></li>'
			+ '<li><a href="#application.paths.reportdir#report_budget_splan_list_fop_sum.cfm" title="Generate an Excel Spreadsheet of this Transaction Listing">Generate Report</a></li>'
			+ '<ul>'
			+ '</div>';

			$(document.body).append(SHTML);
		}
	}
	//alert('returning');
	return;
}

function CancelReturn ( target, splanTransID ) {
	var cmd = '';
	if ( target == 'SpendPlan' ) {
		cmd = glJFAS.sHomeLoc+'/budget/splan_main.cfm';
		document.location = cmd ;
	}
	else if ( target == 'TransList' ) {
		cmd = glJFAS.sHomeLoc+'/budget/splan_transaction_list.cfm';
		document.location = cmd ;
	}
	else if ( target == 'View' ) {
		splanView( splanTransID );
	}
	else {
		alert ('Unrecognized target for Cancel=' & arguments.target);
	}

} // CancelReturn

function GoToBudgetReport ( cfmfile, PY, splanTransIdList, splanTransDetIdList, splanCatIdList, SplanCatDesc) {
	// prints PDF of fops related to a TOCategory or a FROMCategory
	// opens a separate window for the report
	//window.open('#application.paths.reportdir#report_aapp_list.cfm?SortBy='+ glJFAS.sSortBy+'&SortDir='+ glJFAS.sSortDir);
	// this is JS
	var cmd = '#application.paths.reportdir#'+cfmfile+'?PY='+PY+'&splanTransIdList=' + splanTransIdList +'&splanTransDetIdList=' + splanTransDetIdList + '&splanCatIdList=' + splanCatIdList + '&SplanCatDesc=' + SplanCatDesc ;
	//alert(cmd);
	window.open( cmd );

} // GoToBudgetReport

function GetSplanCatAmountJS ( PY, splanCatId ) {
	// this makes one ajax call, gets the total amount of the spend plan for the PY
	<!--- this link calls a cfc directly.  If there is an application.cfc in the path of the cfc, it is executed. We control which parts execute with isBackground=yes  --->

	var sRet = '' ; // this must be OUTSIDE the success struct

	// clear a field, and display based on filters
	var formData = {
		method:'GetSplanCatAmount'
		 , PY:PY     			// this is providing value from arguments.aappNum
		 , splanCatId:splanCatId     			// this is providing value from arguments.aappNum
		 } ; //array
	$.ajax(
		{
		type:	"POST"
		, url:	 glJFAS.sSplanLink
		, data: formData

		, async: false  // THIS IS A SYNCHRONOUS CALL.  THIS IS VERY UNUSUAL IN MY CALL

		, success: function (responseTxt,statusTxt,xhr) {
			sRet = $.parseJSON( responseTxt );

		} // success

		, error: function(responseTxt,statusTxt,xhr){
			alert('in error in SaveMyAAPP');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			} // error
		}
	); // ajax

	return sRet;

} // GetSplanCatAmount

function closeOneSplanmenu (idSubMenu) {
	// the TopMessage is always in a div: id="idTopMessage".  Only one submenu is open at a time
	var selector = '##' + idSubMenu;
	$(selector).remove();
}

function splanView ( splanTransID ) {
	var cmd = '';
	cmd = glJFAS.sHomeLoc+'/budget/splan_edit.cfm?actionmode=View&splanTransID='+splanTransID;
	//alert('goto ' + cmd);
	document.location = cmd ;
}

function splanEdit ( splantransid ) {
	var cmd = '';
	cmd = glJFAS.sHomeLoc+'/budget/splan_edit.cfm?actionmode=Edit&splantransid='+splantransid;
	//alert('goto ' + cmd);
	document.location = cmd ;
}

function Check2Datesval ( $Date1, description1, $Date2, description2 ) {

	if ( $Date1 == '' ||  $Date2 == '' ) {
		return true;
	}
	if (Date.parse( $Date2 ) < Date.parse( $Date1 ) ) {
		alert(description2 + ' must be equal to or greater than ' + description1);
		return false;
	}
	return true;

} // Check2Datesval

function ValidateSplanListForm (form) {

	var bRet = true;
	// alert('in ValidateSplanListForm');
	bRet = Check2Datesval ( form.FromDate.value, '"From" Date', form.ToDate.value, '"To" Date');
	if (bRet) {
		return true;
	}
	else {
		return false;
	}
	return true;
}

function setLastDateRow ( lastdaterow ) {
	if (lastdaterow <= 14 ) {
		// make the NEXT row visible
		glJFAS.lastdaterow  = lastdaterow;
	}
}

function addDisplayColumn () {
	//alert('into addDisplayColumn with ' + daterow);
	if (glJFAS.lastdaterow < 13 ) {
		// make the NEXT row visible
		var nextrowid = '##idCustomDateRow'+(glJFAS.lastdaterow +1).toString();
		var nextdateid = '##idCustomDate'+(glJFAS.lastdaterow +1).toString();
		$(nextrowid).css( "display", "block");
		$(nextdateid).focus();
		// scroll it into view
		// see http://stackoverflow.com/questions/4884839/how-do-i-get-a-element-to-scroll-into-view-using-jquery
		// this gets the position of the "Add Custom Date" link
		//var offset = $('##AddCustomDate').offset();
		//offset.top -= 20;
		//$('html, body').animate({
		//	// scrolls to 20 above the link
		//	scrollTop: offset.top
		//});
		glJFAS.lastdaterow  = glJFAS.lastdaterow + 1;

	}
	else {
		alert('You already have the maximum number of custom dates');
	}
}

function changeSpending ( value ) {
	var selector = '.CustomDate';
	var deleteselector = '.CustomDate_delete';
	var imgselector = '.ui-datepicker-trigger';
	var throughselector = '##idDisplayToDate';
	if ( value == 4 ) {
		// Custom dates are active
		$(selector).prop('disabled', false);
		$(deleteselector).css("visibility", "visible");
		$( ".bigleftcell" ).children( imgselector ).removeClass("inputReadonly");
		$( ".bigleftcell" ).children( imgselector ).css("visibility", "visible");
		$( "##AddCustomDate" ).css("visibility", "visible");
		$( throughselector ).prop('disabled', false);
		$( throughselector ).removeClass("inputReadonly");
		$( ".rightcell" ).children( imgselector ).removeClass("inputReadonly");
		$( ".rightcell" ).children( imgselector ).css("visibility", "visible");
	}
	else {
		// Custom dates are inactive, and through date is today, and disabled, AND cleared
		$(selector).val('');
		$(selector).prop('disabled', true);
		$(deleteselector).css("visibility", "hidden");
		$( ".bigleftcell" ).children( imgselector ).css("visibility", "hidden");
		$( "##AddCustomDate" ).css("visibility", "hidden");
		$( throughselector ).val( '#dateformat(Now(), "mm/dd/yyyy")#');
		$( throughselector ).prop('disabled', true);
		$( throughselector ).addClass("inputReadonly");
		$( ".rightcell" ).children( imgselector ).addClass("inputReadonly");
		$( ".rightcell" ).children( imgselector ).css("visibility", "hidden");

	}
}

function deleteDisplayColumn ( daterow ) {
	//alert('into deleteDisplayColumn with ' + daterow);
	if (daterow > 1 ) {
		// make THIS row invisible, and clear the contents
		var dateid = '##idCustomDate'+(daterow).toString();
		var rowid = '##idCustomDateRow'+(daterow).toString();

		$(dateid).val( "");
		$(rowid).css( "display", "none");
		if ( daterow == glJFAS.lastdaterow) {
			glJFAS.lastdaterow  = glJFAS.lastdaterow - 1;
		}
		// scroll it into view
		// see http://stackoverflow.com/questions/4884839/how-do-i-get-a-element-to-scroll-into-view-using-jquery
		//var offset = $('##AddCustomDate').offset();
		//offset.top -= 20;
		//$('html, body').animate({
		//	scrollTop: offset.top
		//});

	}
}

// from http://www.howtocreate.co.uk/tutorials/javascript/browserwindow
function getScrollXY() {
  var scrOfX = 0, scrOfY = 0;
  if( typeof( window.pageYOffset ) == 'number' ) {
    //Netscape compliant
    scrOfY = window.pageYOffset;
    scrOfX = window.pageXOffset;
  } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
    //DOM compliant
    scrOfY = document.body.scrollTop;
    scrOfX = document.body.scrollLeft;
  } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
    //IE6 standards compliant mode
    scrOfY = document.documentElement.scrollTop;
    scrOfX = document.documentElement.scrollLeft;
  }
  return [ scrOfX, scrOfY ];
}

function ValidateDisplaySettingsForm (form) {
	var bRet = true;
	var walker = 0;
	var walkerM1 = 0;

	//alert('in ValidateDisplaySettingsForm');
	//alert('PY ' + form.PY.value);
	if (form.PY.value == '') {
		alert ('You must select a PY');
		return false;
	}

	for (walker = 2; walker <= glJFAS.lastdaterow; walker += 1) {
		walkerM1 = walker - 1;
		date1sel = "##idCustomDate" + walkerM1;
		date2sel = "##idCustomDate" + walker;
		bRet = Check2Datesval ( $( date1sel ).val(), 'Custom Date ' + walkerM1, $( date2sel ).val(), 'Custom Date ' + walker);

		if ( !bRet ) {
			return false;
		}
	}
}

</script>
</cfoutput>
