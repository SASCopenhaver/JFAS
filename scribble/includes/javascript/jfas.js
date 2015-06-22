// jfas.js
// for JSLint
'use strict';
/*jslint browser: true, devel: true, passfail: false, vars: true, white: true */
/*global $,Modernizr,DisplayHomeNoFilter,tGlobalJsValues,RH_ShowHelp,HH_DISPLAY_TOC,HH_HELP_CONTEXT */
// GLOBAL variables - default values

//glJFAS is defined in jsGlobal.cfm
// current time in milliseconds allowed for the AAPP list to display

// this CANNOT be set in init(), since that is run by the home page, and we need to preserve a value set by ResetMyFilter().  Set to the time allowed for a ResetMyFilter
glJFAS.nTimeForCompletion = 60000;
glJFAS.nTimeForCheckboxes = 1250;
// time in milliseconds allowed for the AAPP list to display, without throwing an error, UNLESS resetting
// belldr changed from 15 to 30 seconds, to allow for largest query on (slow) production server
glJFAS.nStandardTimeForCompletion = 30000;

glJFAS.sSortBy					= '';
glJFAS.sSortDir					= '';
glJFAS.sFieldString				= '';
glJFAS.sBrowser					= '';

// this is for ie8, which needs it to implement .trim() in JS
if(typeof String.prototype.trim !== 'function') {
	String.prototype.trim = function() {return this.replace(/^\s+|\s+$/g, '') ; } ;
}

function detectBrowser() {
	// based on http://webknight-nz.blogspot.com/2011/03/ie-9-detection-with-jquery.html
	// assume we have modern browser, unless we have IE8 or IE 9
	// IE9 supports opacity, but not htmlSerialize
	// IE8 does not support opacity, and does not support htmlSerialize

	var mq = Modernizr.mq('only all');
	if (mq === true) {
		glJFAS.sBrowser = 'ok';
	}
}

function cssToNumber (selector, property) {
	// I return the number associated with a css propery that has 'px' at the end
	var rn;
	rn = $(selector).css(property);
	rn = rn.substring(0, rn.length - 2);
	return rn;
}

function init()
{
	//alert('in init');
	glJFAS.bEmailIsWorking			= true;
	glJFAS.bShowDalert				= false;
	glJFAS.bFilterIsLocked			= true;
	glJFAS.bFilterIsOpen			= true;
	glJFAS.bFilterAgreementIsOpen	= true;
	glJFAS.bFilterFundingIsOpen		= true;
	glJFAS.bFilterStatusIsOpen		= true;
	glJFAS.bFilterServiceTypeIsOpen	= true;
	glJFAS.bFilterStateIsOpen		= true;

	glJFAS.bContractStartDateIsOpen	= true;
	glJFAS.bContractEndDateIsOpen	= true;

	// these numbers should closely relate to the numbers in jfas.less
	glJFAS.nHomeFilterOutsideWidth	= 195;
	glJFAS.nFCHTop					= 105;
	glJFAS.nScrollingAreaMarginLeft	= 195;

	// leaving room for ie. scrollbar. Cut down from 1024

	glJFAS.nHomeSurroundLeft		= 150;
	glJFAS.nHomeSurroundWidth		= 990;

	glJFAS.nLowerContainerWidth		= glJFAS.nHomeSurroundWidth;

	glJFAS.nHomeFilterHeight		= 500;
	glJFAS.nHomeNoFilterWidth		= 35;
	glJFAS.nFilterStringLength		= 50;
	glJFAS.nHomeNoFilterIconTabWidth = 35;
	glJFAS.nFilterTextLeft			= 195;

	glJFAS.sSortBy					= 'aappNum';
	glJFAS.sSortDir					= 'asc';

	glJFAS.sBrowser					= 'ie7';

	// take a look at initial sizing, to initialize width of FilterText et all
	glJFAS.nHomeSurroundLeft 		= $('#HomeSurround').offset().left;
	glJFAS.nHomeSurroundWidth 		= +1 * cssToNumber ('#HomeSurround', "width");

	glJFAS.nHeaderDivLeft 			= $('#HeaderDiv').offset().left;
	glJFAS.nHeaderDivWidth 			= +1 * cssToNumber ('#HeaderDiv', "width");

	// storage for timers
	glJFAS.nLatestResizingTimer 	= '';
	glJFAS.nLatestCompetionTimer	= '';
	glJFAS.nLatestCheckboxTimer 	= '';

	// this kludge is just to clean up the display before the first data display
	//$("#idFilterText").css("width", 975) ;
	$("#idFilterText").css("width", glJFAS.nHeaderDivWidth - glJFAS.nHomeFilterOutsideWidth) ;

	detectBrowser();

	$( window ).resize(function() {
	// hide the filter text and column headings
	StartResizerTimer();
	});

	$( window ).scroll(function() {
	// this does NOT hide the filter text and column headings
	$(".TopMarker").not("#homeNoFilter").remove();
	});
}

function adjustHomeDivs () {
	// I calculate the positions based on the current window sizes and status of the display of the filter panel, then display the appropriate divs

	// Set height of filter tab. Adjust to be below the title @homeFilterTop shown in jfas.less
	// exact fit is to subtract 112.  Instead, subtract more, so that ie10 works

	var nDataWidth;

	// filter tab height
	glJFAS.nHomeFilterHeight 		= window.innerHeight - 130;

	// Filter Tab Left Side - based on width of window
	glJFAS.nHomeFilterOffset 		= +1 * $('#FilterandColumnHeadings').offset().left;

	glJFAS.nHomeSurroundLeft 		= $('#HomeSurround').offset().left;
	glJFAS.nHomeSurroundWidth		= +1 * cssToNumber('#HomeSurround', 'width');

	glJFAS.nHeaderDivLeft 			= $('#HeaderDiv').offset().left;
	glJFAS.nHeaderDivWidth			= +1 * cssToNumber('#HeaderDiv', 'width');

	glJFAS.nLowerContainerOffset 	= +1 * $('#idLowerContainer').offset().left;

	// Calculate the NEW x-position and width for the scrolling area
	if ( glJFAS.bFilterIsOpen && glJFAS.bFilterIsLocked) {
		// This is the main calculation. Margin for ScrollingArea must leave room for the filter tab.
		// glJFAS.nHomeFilterOutsideWidth is the width of the filter panel
		glJFAS.nScrollingAreaMarginLeft	= glJFAS.nHomeFilterOutsideWidth - ( glJFAS.nLowerContainerOffset - glJFAS.nHomeFilterOffset) ;
		glJFAS.nScrollingAreaWidth		= glJFAS.nHomeSurroundWidth - glJFAS.nHomeFilterOutsideWidth;
	}
	else {
		// Filter Tab is CLOSED. ScrollingArea is pushed to the left
		// 0 is the width of the noFilter panel, since the button has now been moved above the scrolling area
		glJFAS.nScrollingAreaMarginLeft	= +0 - ( glJFAS.nLowerContainerOffset - glJFAS.nHomeFilterOffset) ;
		glJFAS.nScrollingAreaWidth		= glJFAS.nHomeSurroundWidth;

		// display the HomeNoFilter icon, since the filter tab is closed
		// this routine depends on the offset of HeaderDiv
		DisplayHomeNoFilter();
	} // Filter Tab is Closed

	// these have been determined
	// 	 glJFAS.nHomeFilterHeight

	// 	 glJFAS.nHomeFilterOffset
	// 	 glJFAS.nHomeSurroundWidth
	// 	 glJFAS.nHomeSurroundLeft
	// 	 glJFAS.nHeaderDivWidth
	// 	 glJFAS.nHeaderDivLeft
	// 	 glJFAS.nLowerContainerOffset
	// 	 glJFAS.nScrollingAreaMarginLeft
	// 	 glJFAS.nScrollingAreaWidth

	//alert(' glJFAS.nHomeFilterHeight ' + glJFAS.nHomeFilterHeight + ' glJFAS.nHomeFilterOffset ' + glJFAS.nHomeFilterOffset + '\n glJFAS.nHomeSurroundWidth ' + glJFAS.nHomeSurroundWidth + ' glJFAS.nHomeSurroundLeft ' + glJFAS.nHomeSurroundLeft + '\n glJFAS.nHeaderDivWidth ' + glJFAS.nHeaderDivWidth + ' glJFAS.nHeaderDivLeft ' + glJFAS.nHeaderDivLeft + ' glJFAS.nLowerContainerOffset ' + glJFAS.nLowerContainerOffset + '\n glJFAS.nScrollingAreaMarginLeft ' + glJFAS.nScrollingAreaMarginLeft + ' glJFAS.nScrollingAreaWidth ' + glJFAS.nScrollingAreaWidth );

	// SET glJFAS.nHomeFilterHeight, whether or not it is visible
	$("#homeFilter").css("height", glJFAS.nHomeFilterHeight);

	// SET the position, height, and width of FilterTEXT and ColumnHeadings to match the left position and width of idAAPPHomeTbl
	if( glJFAS.nFilterStringLength > 130) {
		// Filter description is too long to fit on one line
		 glJFAS.nFilterTextHeight = 50;
	} else {
		 glJFAS.nFilterTextHeight = 30;
	}

	// glJFAS.nFCHTop is top of FilterText (constant)
	 glJFAS.nColumnHeadingTop = glJFAS.nFCHTop + glJFAS.nFilterTextHeight;

	$( ".homeNoFilter" ).css( "height", glJFAS.nFilterTextHeight );
	$( "#idFilterText" ).css( "height", glJFAS.nFilterTextHeight );

	// adjust to make the scrolling area appear below the filter text and column headers
	// adjust because of height of columnHeadings
	$( ".ScrollingArea" ).css ( "margin-top", glJFAS.nFCHTop + glJFAS.nFilterTextHeight + 20) ;

	// SET the width and margin of the LowerContainer area, as calculated above
	$( ".ScrollingArea" ).css( "margin-left", 	 glJFAS.nScrollingAreaMarginLeft);
	$( ".ScrollingArea" ).css( "width", 		 glJFAS.nScrollingAreaWidth);

	// filter tab does not float.  It is either open or closed
	if (! glJFAS.bFilterIsOpen) {
		// filter tab is CLOSED. Data area is wider
		// display homeNoFilter ABOVE jfasDataDiv
		$( ".homeFilter" ).css( "visibility", "hidden" );
		// generate HomeNoFilterIconTab
		 glJFAS.nFilterTextLeft 		= glJFAS.nScrollingAreaMarginLeft + glJFAS.nHomeFilterOffset + glJFAS.nHomeNoFilterIconTabWidth;
		 glJFAS.nFilterTextWidth 		= glJFAS.nHeaderDivWidth - glJFAS.nHomeNoFilterIconTabWidth;
		 glJFAS.nColumnHeadingsLeft	= glJFAS.nScrollingAreaMarginLeft + glJFAS.nHomeFilterOffset;
		nDataWidth 				= glJFAS.nHeaderDivWidth;
	}
	else {
		// filter tab is OPEN
		// display homeFilter NEXT TO jfasDataDiv
		$( ".homeFilter" ).css( "visibility", "visible" );
		$( ".homeNoFilter" ).css( "visibility", "hidden" );
		 glJFAS.nFilterTextLeft 		= glJFAS.nScrollingAreaMarginLeft + glJFAS.nHomeFilterOffset;
		// this is IGNORING glJFAS.nScrollingAreaWidth calculated above
		 glJFAS.nFilterTextWidth 		= glJFAS.nHeaderDivWidth - glJFAS.nHomeFilterOutsideWidth;
		 glJFAS.nColumnHeadingsLeft	= glJFAS.nFilterTextLeft;
		nDataWidth 				= glJFAS.nFilterTextWidth;
	}

	// idFilterText is at z-index 20, to the right of the NoFilter div, over the ColumnHeadings
	// $( "#idFilterText" ).offset({top: glJFAS.nFCHTop, left: glJFAS.nFilterTextLeft });
	$( "#idFilterText" ).offset({left: glJFAS.nFilterTextLeft });
	$( "#idFilterText" ).css( "top", 	 glJFAS.nFCHTop);
	$( "#idFilterText" ).css( "width", glJFAS.nFilterTextWidth);

	// ColumnHeadings is at z-index 20, directly over the data area
	// $( "#ColumnHeadings" ).offset({top: glJFAS.nColumnHeadingTop, left: glJFAS.nColumnHeadingsLeft });
	$( "#ColumnHeadings" ).offset({left: glJFAS.nColumnHeadingsLeft });
	$( "#ColumnHeadings" ).css( "top", 	 glJFAS.nColumnHeadingTop);
	$( "#ColumnHeadings" ).css( "width", nDataWidth);

	$( "#jfasDataDiv" ).css( "width", nDataWidth);
	$( ".homeFooter" ).css( "margin-left", 0);
	$( ".homeFooter" ).css( "width", nDataWidth - 5);

	$( '#idFilterText' ).css( 'visibility', 'visible' );
	$( '#ColumnHeadings' ).css( 'visibility', 'visible' );
	$( '#idLowerContainer' ).css( 'visibility', 'visible' );


} //adjustHomeDivs

function ExecuteResizer() {
	if ( glJFAS.nLatestResizingTimer !== '') {
		clearInterval( glJFAS.nLatestResizingTimer);
	}
	 glJFAS.nLatestResizingTimer = '';
	adjustHomeDivs();
}

function StartResizerTimer () {
	if ( glJFAS.nLatestResizingTimer !== '') {
		clearInterval( glJFAS.nLatestResizingTimer);
	}
	 glJFAS.nLatestResizingTimer = setInterval(function () {
		ExecuteResizer();
	},300);
	// hide the fixed divs. adjustHomeDivs will make these visible at the right time
	$( '#homeNoFilter' ).css( 'visibility', 'hidden' );
	$( '#idFilterText' ).css( 'visibility', 'hidden' );
	$( '#ColumnHeadings' ).css( 'visibility', 'hidden' );
	$( '#idLowerContainer' ).css( 'visibility', 'hidden' );
	// remove dropdown menus (e.g. MyAAPPs) that have been appended to the document
	$(".TopMarker").not("#homeNoFilter").remove();

}


function setdalert(b) {
	 glJFAS.bShowDalert = b;
}

function dalert(s) {
	if( glJFAS.bShowDalert){
		alert(s);
	}
}

function openFilterPanel() {

	 glJFAS.bFilterIsOpen	= true;
	 glJFAS.bFilterIsLocked	= true;
	adjustHomeDivs();

}

function closeFilterPanel() {
	/* set these variables before making the Filter invisible, because making it invisible fires the onmouseleave event, which will call this routine if the variables weren't already set */
	 glJFAS.bFilterIsOpen	= false;
	 glJFAS.bFilterIsLocked	= false;
	adjustHomeDivs();

}

function OpenHelpWin(helpID)
{
	// alert("Don't run with scissors.");
	// open RoboHelp window, either in general mode, or context-sensitive mode

	var helpLink = tGlobalJsValues.sPathRoot + 'help/JFAS_Help.htm';

	if (helpID === '' || helpID === 0) {
		RH_ShowHelp(0,helpLink, HH_DISPLAY_TOC, 0);
	}
	else {
		RH_ShowHelp(0,helpLink, HH_HELP_CONTEXT, helpID);
	}
}


function toggleAgreementType () {
	 glJFAS.bFilterAgreementIsOpen = ! glJFAS.bFilterAgreementIsOpen;
	$( '#idAgreementTypeFilter' ).toggle();
}

function toggleFundingOffice () {
	 glJFAS.bFilterFundingIsOpen = ! glJFAS.bFilterFundingIsOpen;
	$( '#idFundingOfficeFilter' ).toggle();
}

function toggleContractStatus () {
	 glJFAS.bFilterStatusIsOpen = ! glJFAS.bFilterStatusIsOpen;
	$( '#idContractStatusFilter' ).toggle();
}

function toggleServiceType () {
	 glJFAS.bFilterServiceTypeIsOpen = ! glJFAS.bFilterServiceTypeIsOpen;
	$( '#idServiceTypeFilter' ).toggle();
}

function toggleState () {
	 glJFAS.bFilterStateIsOpen = ! glJFAS.bFilterStateIsOpen;
	$( '#idStateFilter' ).toggle();
}

function toggleContractStartDate () {
	 glJFAS.bContractStartDateIsOpen = ! glJFAS.bContractStartDateIsOpen;
	$( '#idContractStartDate' ).toggle();
}

function toggleContractEndDate () {
	 glJFAS.bContractEndDateIsOpen = ! glJFAS.bContractEndDateIsOpen;
	$( '#idContractEndDate' ).toggle();
}

$( "#homeFilter" ).mouseleave(function() {
	//hide the Filter panel, unless it is locked
	if ( glJFAS.bFilterIsLocked === false && glJFAS.bFilterIsOpen === true) {
		closeFilterPanel();
	}
});

// add the tooltip() explicitly to anything with the (don-defined) class. This must be done explicitly, according to the bootstrap documentation.  This makes the bootstrap tooltip display when hovering over the object.
//$( ".usetooltip" ).tooltip();

// call this to see if this jfas.js is available
function IsJfasThere() {
	alert('jfas.js IS there');
}
// * * * * * * * * * * * * * * * utilities from jfasdd.js

function jsdhtml(arr,level) {
/**
Use this for diagnosing Javascript on a page.
pass it an array, such as   alert( jsdhtml( aValidation ) );
It produces a text string to be used by alert().

* Function : dump()
* Arguments: The data - array,hash(associative array),object
*    The level - OPTIONAL
* Returns  : The textual representation of the array.
* This function was inspired by the print_r function of PHP.
* This will accept some data as the argument and return a
* text that will be a more readable version of the
* array/hash/object that is given.
	FROM: http://www.openjs.com/scripts/others/dump_function_php_print_r.php
*/

	var dumped_text = "";
	var walker = 0;
	var item,value,level_padding;
	if(!level) {level = 0;}
	//The padding given at the beginning of the line.
	level_padding = "";
	for(walker=0; walker<level+1; walker += 1) {
		level_padding += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
	}

	if( (typeof arr) === 'object') {
		//Array/Hashes/Objects
		for(item in arr) {
			value = arr[item];

			if ( (typeof value)  === 'object') {
				//If it is an array,
				dumped_text += level_padding + '(' + walker + ')' + "'" + item + "' (object) ...<br>";
				// recursive call
				dumped_text += jsdhtml(value, level+1);
				dumped_text += '<br>';
			} else {
				dumped_text += level_padding + '(' + walker + ')' + "'" + item + "' value => \"" + value + "\"<br>";
			}
		}
	} else {
		//Stings/Chars/Numbers etc.
		dumped_text = '===>'+arr+'<===('+ (typeof arr) +')<br>';
	}
	return dumped_text;
} //jsdhtml

function jsdump(arr,level) {
/**
Use this for diagnosing Javascript on a page.
pass it an array, such as

		alert( jsdump( aValidation ) );


It produces a text string to be used by alert().

* Function : dump()
* Arguments: The data - array,hash(associative array),object
*    The level - OPTIONAL
* Returns  : The textual representation of the array.
* This function was inspired by the print_r function of PHP.
* This will accept some data as the argument and return a
* text that will be a more readable version of the
* array/hash/object that is given.
	FROM: http://www.openjs.com/scripts/others/dump_function_php_print_r.php
*/

//alert('in jsdump');
//alert('typeof is ' + (typeof arr));
	var dumped_text = "";
	var item,value,j;
	//The padding given at the beginning of the line.
	var level_padding = "";

	if(!level) {level = 0;}

	for(j=0;j<level+1;j+=1) {
		level_padding += "     ";
	}

	if( (typeof arr) === 'object') {
		//Array/Hashes/Objects
		for(item in arr) {
			value = arr[item];

			if( (typeof value) === 'object') {
				//If it is an array,
				dumped_text += level_padding + '(' + j + ')' + "'" + item + "' (object) ...\n";
				// recursive call
				dumped_text += jsdump(value,level+1);
			} else {
				dumped_text += level_padding + "'" + item + "' value => \"" + value + "\"\n";
			}
		}
	} else {
		//Stings/Chars/Numbers etc.
		dumped_text = "===>"+arr+"<===("+ (typeof arr) +")";
	}
	return dumped_text;
} //jsdump

function privatefnDumpJSON (data, msg, selector)
{
	// I put jsdump output into a selected div - for debugging
	$(selector).html('from privatefnDumpJSON ');
	alert('starting jsdhtml for ' + msg);
	var fred = jsdhtml(data);
	$(selector).html(fred);
	alert(msg);
}  //privatefnDumpJSON


// END of jfas.js