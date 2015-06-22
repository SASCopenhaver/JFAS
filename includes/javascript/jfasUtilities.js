// jfasUtilities.js
// for JSLint
'use strict';
/*jslint browser: true, devel: true, passfail: false, vars: true, white: true */

// * * * * * * * * * * * * * * * js_formatstring.js

function trim ( strText ) {
	//Trim(string) : Returns a copy of a string without leading or trailing spaces
	// belldr 06/09/2014 removed LTrim(), RTrim(), and using the String prototype .trim()
	var s;

	s = strText.trim();

	return s;

} // trim

function isEmpty(s) {

   return ((s === null) || (s.length === 0));

} // isEmpty

// * * * * * * * * * * * * * * * js_checkdate.js
// this function goes with any object.
function objectchanger (fnc, obj) {
	// I call the function in the object, to modify its value
	return fnc.call(obj);
} // objectchanger



function checkSimpleNumber(object_value) {

	// be sure the incoming object is treated as a string, even if it is a number
	var test_string = object_value.toString();
	// Returns true if value is a number or is NULL
	// otherwise returns false
	if (test_string.length === 0) {
		return true;
	}

	// Returns true if value is a number defined as
	//   having an optional leading + or -.
	//   having at most 1 decimal point.
	//   otherwise containing only the characters 0-9.
	var start_format = "+-";
	// belldr 06/09/2014 - removed leading blank.  A number cannot have an embedded blanke
	var number_format = ".0123456789";
	var check_char;
	var decimal = false;
	var i;
	var ifirst = 0;
	// eliminate leading and trailing blanks
	var trynum = test_string.trim();

	// Check first character for + -
	check_char = start_format.indexOf(trynum.charAt(0));
	// Was it a + or - ??
	if (check_char >= 0) {
		ifirst = 1;
	}

	// Remaining characters can be only . or a digit, but only one decimal point.
	for (i = ifirst; i < trynum.length; i += 1) {

		check_char = number_format.indexOf(trynum.charAt(i));
		if (check_char < 0) {
			// illegal character
			return false;
		}

		if (check_char === 0) {
			if (decimal) {		// Second decimal.
				return false;
			}
			decimal = true;
		}

	} // loop

	// All tests passed, so...
	return true;

} // checkSimpleNumber

function numberRange(object_value, min_value, max_value) {

	var test_integer = parseInt(object_value.toString(), 10);
	// check minimum
	if (min_value !== null) {
		if (test_integer < min_value) {
			return false;
		}
	}
	// check maximum
	if (max_value !== null) {
		if (test_integer > max_value) {
			return false;
		}
	}

	// All tests passed, so...
	return true;

} // numberRange

function checkRange (object_value, min_value, max_value) {
	var test_string = object_value.toString();

	//if value is in range then return true else return false
	if (test_string.length === 0) {
		return true;
	}

	if (!checkSimpleNumber(test_string)) {
		return false;
	}
	return (numberRange(test_string, min_value, max_value));

} // checkRange


function checkInteger(object_value) {

	// Returns true if value is a number or is NULL
	// otherwise returns false

	var test_string = object_value.toString();

	if (test_string.length === 0) {
		return true;
	}

	// Returns true if value is an integer defined as
	//   having an optional leading + or -.
	//   otherwise containing only the characters 0-9.
	var decimal_format = ".";
	var check_char;

	//The first character can be + -  blank or a digit.
	check_char = test_string.indexOf(decimal_format);
	// Was it a decimal?
	if (check_char < 1) {
		return checkSimpleNumber (test_string);
	}
	return false;

} // checkInteger



function checkDay(checkYear, checkMonth, vCheckDay) {

	// requires 4-digit year, and all digits
	var maxDay = 31;

	if (checkMonth === 4 || checkMonth === 6 ||
			checkMonth === 9 || checkMonth === 11) {
		maxDay = 30;
	}
	else {
		if (checkMonth === 2) {
			if (checkYear % 4 > 0) {
				maxDay =28;
			}
			else {
				if (checkYear % 100 === 0 && checkYear % 400 > 0) {
					maxDay = 28;
				}
				else {
					maxDay = 29;
				}
			}
		}
	}

	return checkRange(vCheckDay, 1, maxDay); //check day

} // checkDay

// this function is called directly from many places in the jfas code
function Checkdate(object_value) {

	//Returns true if value is a date format or is NULL
	//otherwise returns false

	var isplit, sMonth, sDay, sYear;

	if (object_value.length === 0) {
		return true;
	}

	//Returns true if value is a date in the mm/dd/yyyy format
	isplit = object_value.indexOf('/');

	if (isplit === -1 || isplit === object_value.length) {
		return false;
	}

	sMonth = object_value.substring(0, isplit);
	isplit = object_value.indexOf('/', isplit + 1);
	if (isplit === -1 || (isplit + 1 ) === object_value.length) {
		return false;
	}
	sDay = object_value.substring((sMonth.length + 1), isplit);
	sYear = object_value.substring(isplit + 1);
	if (!checkInteger(sMonth)) { //check month
		return false;
	}
	if (!checkRange(sMonth, 1, 12)) {//check month
			return false;
	}
	if (sYear.length < 4) {
		//line added by mstein - make sure year is 4 char
		return false;
	}
	if (!checkInteger(sYear)) { //check year
		return false;
	}
	if (!checkRange(sYear, 0, 9999)) { //check year
		return false;
	}
	if (!checkInteger(sDay)) { //check day
		return false;
	}
	var fourDigitYear = sYear;

	if (1 * fourDigitYear < 100) {
		fourDigitYear = (2000 + 1 * fourDigitYear).toString();
	}
	if (!checkRange(fourDigitYear, 1950, 2050)) {
		return false;
	}

	if (!checkDay(1 * sYear, 1 * sMonth, 1 * sDay)) {// check day
		return false;
	}
	return true;

} // Checkdate

function timeDifference ( earlierdate, laterdate ) {

    var difference = laterdate.getTime() - earlierdate.getTime();

    var daysDifference = Math.floor(difference/1000/60/60/24);
    difference -= daysDifference*1000*60*60*24;

    var hoursDifference = Math.floor(difference/1000/60/60);
    difference -= hoursDifference*1000*60*60;

    var minutesDifference = Math.floor(difference/1000/60);
    difference -= minutesDifference*1000*60;

    // not used      var secondsDifference = Math.floor(difference/1000);

	return daysDifference;

} // timeDifference

function getProgramYear(tempDate) {

    var myDate = tempDate;
	if (myDate.getMonth() >= 6) {
		return myDate.getFullYear();
	}
	return myDate.getFullYear() - 1;

} // getProgramYear


function get4digitYear(yearNum) {

	if (yearNum > 50) {
		return 1900 + yearNum;
	}
	return 2000 + yearNum;

} // get4digitYear


// * * * * * * * * * * * * * * * js_form_util.js

function trimFormTextFields(form) {
	// loop through all form fields
	var counter = 0;
	for (counter = 0; counter < form.length; counter += 1) {
		// if it is a text box, or textarea, trim leading and trailing spaces
		if ((form[counter].type === "text") || (form[counter].type === "textarea")) {
			form[counter].value = trim(form[counter].value);
		}
	}
} // trimFormTextFields

function textCounter(field, maxlimit) {
	if (field.value.length > maxlimit) {
		alert('The maximum size of this field is ' + maxlimit + ' characters.');
		field.value = field.value.substring(0, maxlimit);
	}
} // textCounter

function resizeTextArea(field, minRows, action) {
	var x, CharCount, LineCount, LastSpace, WrapCount, MaxChars, maxRows;

	if (action === 0) {
		// minimize
		field.rows = minRows;
	}
	else if (action === 1) {
		// maximize
		if (field.value.length === 0) {
			field.rows = minRows;
		}
		else {
			CharCount = 0;
			LineCount = 0;
			LastSpace = 0;
			WrapCount = 0;
			MaxChars = field.cols;
			maxRows = 400; //keeps the text area from getting HUGE

			for (x=0; x <= field.value.length; x += 1)	{
				CharCount += 1;
				if (field.value.charCodeAt(x) === 32) {
					//If this character is a space, mark it...
					//When the string is broken into two parts, this mark
					//will be used, so that the string doesn't get split
					//in the middle of a word
					LastSpace = x;
				}
				if (field.value.charCodeAt(x) === 10) {
					//If this character is a soft return(appears in IE and Netscape recognizes only
					// chr(10) not chr(13) hard return... that is why charCodeAt (13) is no longer used
					LineCount += 1;  //increment the line count
					CharCount = 0;  //reset the char count
					LastSpace = x;  //mark this as a possible separation point
				}
				else if (CharCount === MaxChars) {
					//If we have reached the maximum chars per line...
					LineCount += 1;  //increment the line count
					CharCount = 0;  //reset the char count
					WrapCount += 1;

					if (field.value.charCodeAt(x) !== 32) {
						//If it's not a space, move the counter back to
						//the previous space. This will account for word wrapping
						//within the text box.
						x = LastSpace;
					}
				}
				if (LineCount > maxRows) {
					break;
				}
			} // for loop


			if (LineCount+1 > minRows) {
				// if line count is not less than the minimum height
				field.rows = LineCount + 1 + parseInt( 0.3 * WrapCount, 10 );
			}
			else {
				// otherwise, just set to minimum
				field.rows = minRows;
			}

		} // if field is not blank

	} // if action is "maximize'

} //resizeTextArea

// * * * * * * * * * * * * * * * js_formatnum.js


// js_formatnum.js
// file that handles number formatting functions

// revisions
// 2006-12-16	mds		modified formatNum() to automatically round decimals

var digits = "0123456789";
// whitespace characters
var whitespace = " \t\n\r";

// value before onchange function use by checkNum, setBFchange, getBFchange
var valBFchange = "";
// value before onchange function use by checkNum, setBFchange and reference by html which call checkNum
// must use together with setBFchange (reset to 1, before onchange)
var valStatus = 1;

// Removes all characters which appear in string bag from string s.
function stripCharsInBag (s, bag) {
	var i;
    var returnString = "";

    // Search through string's characters one by one.
    // If character is not in bag, append to returnString.

    for (i = 0; i < s.length; i++)
    {
        // Check that current character isn't whitespace.
        var c = s.charAt(i);
        if (bag.indexOf(c) === -1) returnString += c;
    }
    return returnString;
} //stripCharsInBag


// Removes all characters which do NOT appear in string bag from string s.
function stripCharsNotInBag (s, bag) {
	var i;
    var returnString = "";

    // Search through string's characters one by one.
    // If character is in bag, append to returnString.

    for (i = 0; i < s.length; i++)
    {
        // Check that current character isn't whitespace.
        var c = s.charAt(i);
        if (bag.indexOf(c) !== -1) returnString += c;
    }
    return returnString;
} stripCharsNotInBag


function commaFormat(number) {
	//remove leading zeros, if any
	while(number.length > 1 && number.substring(0,1) === '0'){
		number = number.substring(1,number.length);
	}
	number += '';
	var dpos = number.indexOf('.');
	var nStrEnd = '';
	if (dpos !== -1) {
		nStrEnd = '.' + number.substring(dpos + 1, number.length);
		number = number.substring(0, dpos);
	}
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(number)) {
		number = number.replace(rgx, '$1' + ',' + '$2');
	}
	return number + nStrEnd;
} //commaFormat


<!-- The JavaScript Source!! http://javascript.internet.com -->
function d_places(n,p) {
	var factor = 1;
	var ans  = 0;
	var j = 0;
	for (j = 1; j <= p; j++)
	factor =  factor * 10.0;
	ans = (Math.round((n + 0.05 / (factor) ) * factor)) / factor;
	return ans;
} // d_places


function isInteger(s) {
	if (s.length===0) {
		return false;
	}
	for (var i = 0; i < s.length; i += 1) {
		var c = s.charAt(i);
		if (!((c >= "0") && (c <= "9"))) {
			return false;
		}
	}
	return true;
} // isInteger


function formatNum(textfield,numberRestrict,forceZero) {
//checks to make sure number follows restrictions,
//then formats with commas
// 1 - Positive only
// 2 - Positive and zero, no negative (default)
// 3 - Positive and negative, no zero
// 4 - Positive, Negative, and zero

	if (!numberRestrict) var numberRestrict = 2;
	if (!forceZero) var forceZero = 0;
	var strError = '';

	textfield.value = trim(textfield.value);
	if (textfield.value == '' && forceZero == 1)
		textfield.value = 0;
	else
		{
		textfield.value = stripCharsInBag(textfield.value, ",");
	 	if (isNaN(textfield.value))
			strError = 'You must enter a valid whole number.';
		if ((textfield.value == 0) && (numberRestrict == 1 || numberRestrict == 3))
			strError = 'Zero is not allowed in this field.';
		if ((textfield.value < 0) && (numberRestrict == 1 || numberRestrict == 2))
			strError = 'Negative numbers are not allowed in this field.';
		if (strError != '')
			{
	   		alert(strError);
	   		if (forceZero)
				textfield.value = 0;
			else
				textfield.value = '';
			}
	 	else
			if (textfield.value != '')
	  			textfield.value = commaFormat(Math.round(textfield.value));
		}

} //formatNum


function formatCurrency(num) {
	//formats to currency format

	num = num.toString().replace(/\$|\,/g,'');
	if(isNaN(num))
		num = "0";
	sign = (num === (num = Math.abs(num)));
	num = Math.floor(num*100+0.50000000001);
	cents = num%100;
	num = Math.floor(num/100).toString();

	if(cents<10)
		cents = "0" + cents;

	for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++)
		num = num.substring(0,num.length-(4*i+3))+','+

	num.substring(num.length-(4*i+3));
	return (((sign)?'':'-') + '$' + num + '.' + cents);
} //formatCurrency


function checkNum( textfield, numberRestrict, reverseVal, alertMsg) {
//checks to make sure number follows restrictions,
//then formats with commas
// 1 - Positive only
// 2 - Positive and zero, no negative (default)
// 3 - Positive and negative, no zero
// 4 - Positive, Negative, and zero
//
// reverseVal
// value before onchange function need to call onfocuse in the html page (default)
// if value supplies, then set to the value
//
// alertMsg
// 0 - no alert message
// 1 - alert message (default)

	if (!numberRestrict) var numberRestrict = 2;
	if (!formatType) var formatType = 1;
	if (!reverseVal) var reverseVal = valBFchange;
	if (!alertMsg) var alertMsg = 1;
	var strError = '';
	textfield.value = trim(textfield.value);
	textfield.value = stripCharsInBag(textfield.value, ",");
	if (isNaN(textfield.value))
		strError = 'You must enter a valid whole number.';
	if ((textfield.value === 0) && (numberRestrict === 1 || numberRestrict === 3))
		strError = 'Zero is not allowed in this field.';
	if ((textfield.value < 0) && (numberRestrict === 1 || numberRestrict === 2))
		strError = 'Negative numbers are not allowed in this field.';
	if (strError !== '')	{
		if (alertMsg===1) {
			setStatus(0);
			alert(strError);
		}
		textfield.value = reverseVal;
	}
} // checkNum

function formatNum1(textfield,formatType) {
//format textfield to different format
//formatType
// 1 - Commaformat (default)
// 2 - Decimalformat
// 9 - Remove comma, just number Math.round(parseInt())

	if (!formatType) var formatType = 1;
	if (!textfield.value) {
		textfield = trim(textfield);
		if (textfield !== '') {
			if (formatType===1)
				textfield = commaFormat(Math.round(textfield));
			else if (formatType===2)
				textfield = d_places(parseFloat(textfield), 2);
			else
				textfield = Math.round(stripCharsInBag(textfield, ","));
		}
		return textfield;
	}
	else {
		textfield.value = trim(textfield.value);
		if (textfield.value !== '') {
			if (formatType===1)
				textfield.value = commaFormat(Math.round(textfield.value));
			else if (formatType===2)
				textfield.value = d_places(parseFloat(textfield.value), 2);
			else
				textfield.value = Math.round(stripCharsInBag(textfield.value, ","));
		}
	}

} // formatNum1

function setBFchange(textfield) {
	valBFchange = textfield.value;
	setStatus(1);
} // setBFchange

function getBFchange() {
	return valBFchange;
} // getBFchange

function setStatus (s) {
	valStatus = s;
} // setStatus

function getStatus() {
	return valStatus;
} // getStatus


function formatDecimal(textfield,numPlaces) {
//checks to make sure number is positive integer,
//then formats with commas
	// default to 2 decimal places, if not specified
	if (!numPlaces) var numPlaces = 2;
	trim(textfield.value);

	if (textfield.value === "")
		textfield.value = 0;
	else
		{
		textfield.value = stripCharsInBag(textfield.value, ",");
	 	if (isNaN(textfield.value) || (textfield.value < 0))
			{
	   		alert("You must enter a valid, non-negative number.");
	   		textfield.value = 0;
			}
	 	else
			{
			//textfield.value = parseFloat(textfield.value);
	  		textfield.value = d_places(parseFloat(textfield.value), numPlaces);
			//textfield.value = commaFormat(textfield.value);
			}
		}

} // formatDecimal


function currencyFormat(num) {

	num = num.toString().replace(/\$|\,/g,'');
	if(isNaN(num))
	num = "0";
	sign = (num === (num = Math.abs(num)));
	num = Math.floor(num*100+0.50000000001);
	cents = num%100;
	num = Math.floor(num/100).toString();
	if(cents<10)
	cents = "0" + cents;
	for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++)
	num = num.substring(0,num.length-(4*i+3))+','+
	num.substring(num.length-(4*i+3));
	return (((sign)?'':'-') + num + '.' + cents);
} // currencyFormat





// * * * * * * * * * * * * * * * js_popcalendar.js

// MS_PopCalendar.js , Created by MS@Keymind, Inc. on 7/17/2001, Revised 7/19/2001, 7/20/2001
// v 1.01
// global variables for calendar
var g_fieldObj;
var g_formname, g_fieldname;
var g_curr_month = 1;
var g_curr_year = 2014;
// just a test
var g_curr_day = 1;
var g_dateformat = "M/D/Y";
var g_screenLeft=100,g_screenTop=100 ;
var newWin;
var g_cmd;
var g_month_name = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
var g_weekday_name = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

function MS_DrawCalendar() {
	//	newWin.moveTo(g_screenLeft, g_screenTop);
	// alert('MS_DrawCalendar g_curr_year ' + g_curr_year);
	// alert('g_curr_month ' + g_curr_month);
	// alert('g_curr_day ' + g_curr_day);

	newWin.document.open(); newWin.document.write(MS_GenerateCalendar());
	newWin.document.close();
} // MS_DrawCalendar


function MS_ShowFieldPopCalendar(fieldObj, format, screenLeft, screenTop) {

	if(window.event){
		g_screenLeft = window.event.screenX;
		g_screenTop = window.event.screenY;
	}
	if (screenLeft) {
		g_screenLeft = screenLeft;
	}
	if (screenTop) {
		g_screenTop = screenTop;
	}
	g_fieldObj = fieldObj;
	g_cmd = "status=no,toolbar=no,menubar=no,location=no,scrollbars=no,resizable=no,width=250,height=200,left="+g_screenLeft+",top="+g_screenTop;
	//alert(g_cmd);

	if (format) g_dateformat = format;
	newWin = window.open("", "_blank",g_cmd);

	// put the date from the field into the global values
	if(fieldObj.value !== '') {
		if (fieldObj.value.indexOf("/") >= 0) {
			var from = fieldObj.value.split("/");
		} else {
			var from = fieldObj.value.split("-");
		}
		g_curr_year = from[2];
		g_curr_month = from[0];
		g_curr_day = from[1];
	} else {
		var today = new Date();
		g_curr_year = today.getFullYear();
		g_curr_month = today.getMonth() + 1;
		g_curr_day = today.getDate();
	}

	MS_DrawCalendar();
} // MS_ShowFieldPopCalendar

function MS_ShowPopCalendar(formname, fieldname, format) {
	g_fieldObj = document.forms[formname].elements[ fieldname];
	if (format) g_dateformat = format;
	MS_OpenCalendarWindow();
} // MS_ShowPopCalendar

function MS_OpenCalendarWindow() {
	newWin = window.open("", "_blank",'status=no,toolbar=no,menubar=no,location=no,scrollbars=no,resizable=no,width=200,height=200');
	MS_DrawCalendar();
} // MS_OpenCalendarWindow

function MS_MoveMonth(dM, dY) {
	if (!dY) dY = 0;
	newDate = new Date(g_curr_year + dY,  g_curr_month -1 + dM , 1 );
	g_curr_month = newDate.getMonth() + 1;
	g_curr_year = newDate.getFullYear();
	MS_DrawCalendar();
} // MS_MoveMonth

function MS_goToday() {

	today = new Date(); g_curr_month = today.getMonth()+1; g_curr_year = today.getFullYear(); MS_pick(today.getDate());
} // MS_goToday

function MS_pick(day) {

	g_curr_day = day;
	// insert the date into the field
	g_fieldObj.value = MS_formatConvert(g_curr_year,g_curr_month,g_curr_day, g_dateformat);
	g_fieldObj.fireEvent("onChange");
	newWin.close();
} // MS_pick

function MS_formatConvert(y, m, d, p_format) {

	var result = ""; 	fl = p_format.length;
	for(var i=0; i<fl; i++){
		switch(p_format.charAt(i)){
			case "m" : result += m.toString(); break;
			case "M" : result += (m<=9)? "0"+m.toString(): m.toString(); break;
			case "d" : result += d.toString(); break;
			case "D" : result += (d<=9)? "0"+d.toString(): d.toString(); break;
			case "y" : result += y.toString().substring(2,4); break;
			case "Y" : result += y.toString() ; break;
			case "n" : result += g_month_name[m-1].substring(0,3); break;
			case "N" : result += g_month_name[m-1];break;
			case "W" : result += g_weekday_name[new Date(y, m-1, d).getDay()]; break;
			case "w" : result += g_weekday_name[new Date(y, m-1, d).getDay()].substring(0,3); break;

			default : result += p_format.charAt(i);
		}
	}
	return result;
} // MS_formatConvert

function MS_GenerateCalendar() {

	var today = new Date();
	// pick up global values to start.  Month 0 is January, but we store g_curr_month = 1 for January
	if(isNaN(g_curr_day)) {g_curr_day = 1;}
	// alert ('calling g_curr_year ' + g_curr_year);
	// alert ('calling g_curr_month ' + g_curr_month);
	// alert ('calling g_curr_day ' + g_curr_day);
	var curr_date = new Date (g_curr_year, g_curr_month-1,g_curr_day,0,0,0,0);
	// alert('MS_GenerateCalendar curr_date ' + curr_date);
	// curr_date is a string containing all the Time Zone Information, etc.
	if(isNaN(curr_date)) curr_date = today;

	var curr_month = curr_date.getMonth() + 1; g_curr_month = curr_month;
	var curr_year = curr_date.getFullYear(); g_curr_year = curr_year;
	var first_date = new Date(curr_year, curr_month-1, 1);
	var last_date = new Date( new Date( curr_year, curr_month,1).getTime() - 86400000);
	var wd_first = first_date.getDay();
	var satday = 7 - wd_first;
	var last_day = last_date.getDate();
	var str="";

	var dayofToday = ((today.getMonth()+1 === g_curr_month) && (today.getFullYear() === g_curr_year))? today.getDate(): 0;
	var dayofCurrDay = g_curr_day;
	var prev_month = new Date(curr_year, curr_month-2, 1);
	var next_month = new Date(curr_year, curr_month, 1);
	var TR_attr = "align=right";
	str += "<head><title>Calendar</title>"
	str += "<style>A{TEXT-DECORATION: none};"
	str += "TH{font-family:verdana;font-size:.8em;}TD{font-family:verdana;font-size:.8em;}</style>"
	str += "</head><body vlink=0 text=0 link=0 onload='focus();'>"
	str += "<center><table cellpadding=2 cellspacing=0><tr align=center valign=top><th><a href=javascript:window.opener.MS_MoveMonth(-1)>&lt;</a></th>";
	str += "<th colspan=7>"+g_month_name[curr_month-1] ;
	str += " <nobr><a href=javascript:window.opener.MS_MoveMonth(0,-1)>&laquo;</a>" + curr_year ;
	str += "<a href=javascript:window.opener.MS_MoveMonth(0,1)>&raquo;</a></nobr>";
	str += "<br><br></th><th><a href=javascript:window.opener.MS_MoveMonth(1)>&gt;</a></th></tr>";
	str += "<tr " + TR_attr + "><td></td>";
	for(i=0;i<wd_first;i++) str += "<td></td>";
	for(i=1;i<=last_day;i++){
		 str +=  "<td><a href=javascript:window.opener.MS_pick("+i+")>";
		 str += (i === dayofCurrDay )? "<b>" + i + "</b>" : i ;
		 str += "</a></td>";
		if ((i % 7) === (satday%7))  str += "<td></td></tr><tr " + TR_attr + "><td></td>";
	}
	str +=  "</tr>"; if (wd_first + last_day < 36) str += "<tr><td>&nbsp;</td></tr>";
	str += "</table><table><tr><td align='center'><a href=javascript:window.opener.MS_goToday()>(Today)</a>&nbsp; &nbsp; <a href=javascript:window.close()>(Close)</a></td></tr></table>";
	str += "</center></body>";
	return str;
} // MS_GenerateCalendar

function addDays(myDate,days) {

	thisDate = new Date(myDate);
    futureDate = new Date(thisDate.getTime() + days*24*60*60*1000);
	return futureDate;
} // addDays





// * * * * * * * * * * * * * * * js_tooltip.js

// javascript function for pop-up tool tips
// http://sixrevisions.com/tutorials/javascript_tutorial/create_lightweight_javascript_tooltip/
// Jun 4 2008 by Michael Leigeber

var tooltip=function(){
	var id = 'tt';
	var top = 10;
	var left = -460;
	var maxw = 460;
	var speed = 80;
	var timer = 20;
	var endalpha = 95;
	var alpha = 0;
	var tt,t,c,b,h;
	var ie = document.all ? true : false;
	return{
		show:function(v,w){
			if(tt === null){
				tt = document.createElement('div');
				tt.setAttribute('id',id);
				//t = document.createElement('div');
				//t.setAttribute('id',id + 'top');
				c = document.createElement('div');
				c.setAttribute('id',id + 'cont');
				//b = document.createElement('div');
				//b.setAttribute('id',id + 'bot');
				//tt.appendChild(t);
				tt.appendChild(c);
				//tt.appendChild(b);
				document.body.appendChild(tt);
				tt.style.opacity = 0;
				tt.style.filter = 'alpha(opacity=0)';
				document.onmousemove = this.pos;
			}
			tt.style.display = 'block';
			c.innerHTML = v;
			tt.style.width = w ? w + 'px' : 'auto';
			if(!w && ie){
				//t.style.display = 'none';
				//b.style.display = 'none';
				tt.style.width = tt.offsetWidth;
				t.style.display = 'block';
				//b.style.display = 'block';
			}
			if(tt.offsetWidth > maxw){tt.style.width = maxw + 'px'}
			h = parseInt(tt.offsetHeight) + top;
			clearInterval(tt.timer);
			tt.timer = setInterval(function(){tooltip.fade(1)},timer);
		},
		pos:function(e){
			var u = ie ? event.clientY + document.documentElement.scrollTop : e.pageY;
			var l = ie ? event.clientX + document.documentElement.scrollLeft : e.pageX;
			tt.style.top = (u - h) + 'px';
			tt.style.left = (l + left) + 'px';
		},
		fade:function(d){
			var a = alpha;
			if((a !== endalpha && d === 1) || (a !== 0 && d === -1)){
				var i = speed;
				if(endalpha - a < speed && d === 1){
					i = endalpha - a;
				}else if(alpha < speed && d === -1){
					i = a;
				}
				alpha = a + (i * d);
				tt.style.opacity = alpha * .01;
				tt.style.filter = 'alpha(opacity=' + alpha + ')';
			}else{
				clearInterval(tt.timer);
				if(d === -1){tt.style.display = 'none'}
			}
		},
		hide:function(){
			clearInterval(tt.timer);
			tt.timer = setInterval(function(){tooltip.fade(-1)},timer);
		}
	};
}(); tooltip


// * * * * * * * * * * * * * * * robohelp.csh.js
// eHelp® Corporation
// Copyright© 1998-2002 eHelp® Corporation.All rights reserved.
// RoboHelp_CSH.js
// The Helper function for WebHelp Context Sensitive Help

//     Syntax:
//     function RH_ShowHelp(hParent, a_pszHelpFile, uCommand, dwData)
//
//     hParent
//          Reserved - Use 0
//
//     pszHelpFile
//          WebHelp:
//               Path to help system start page ("http://www.myurl.com/help/help.htm" or "/help/help.htm")
//               For custom windows (defined in Help project), add ">" followed by the window name ("/help/help.htm>mywin")
//
//          WebHelp Enterprise:
//               Path to RoboEngine server ("http://RoboEngine/roboapi.asp")
//               If automatic merging is turned off in RoboEngine Configuration Manager, specify the project name in the URL ("http://RoboEngine/roboapi.asp?project=myproject")
//               For custom windows (defined in Help project), add ">" followed by the window name ("http://RoboEngine/roboapi.asp>mywindow")
//
//     uCommand
//          Command to display help. One of the following:
//                    HH_HELP_CONTEXT     // Displays the topic associated with the Map ID sent in dwData
//											if 0, then default topic is displayed.
//               The following display the default topic and the Search, Index, or TOC pane.
//               Note: The pane displayed in WebHelp Enterprise will always be the window's default pane.
//                    HH_DISPLAY_SEARCH
//                    HH_DISPLAY_INDEX
//                    HH_DISPLAY_TOC
//
//     dwData
//          Map ID associated with the topic to open (if using HH_HELP_CONTEXT), otherwise 0
//
//     Examples:
//     <p>Click for <A HREF='javascript:RH_ShowHelp(0, "help/help.htm", 0, 10)'>Help</A> (map number 10)</p>
//     <p>Click for <A HREF='javascript:RH_ShowHelp(0, "help/help.htm>mywindow", 0, 100)'>Help in custom window (map number 100)</A></p>


var gbNav6=false;
var gbNav61=false;
var gbNav4=false;
var gbIE4=false;
var gbIE=false;
var gbIE5=false;
var gbIE55=false;

var gAgent=navigator.userAgent.toLowerCase();
var gbMac=(gAgent.indexOf("mac")!==-1);
var gbSunOS=(gAgent.indexOf("sunos")!==-1);
var gbOpera=(gAgent.indexOf("opera")!==-1);

var HH_DISPLAY_TOPIC = 0;
var HH_DISPLAY_TOC = 1;
var HH_DISPLAY_INDEX = 2;
var HH_DISPLAY_SEARCH = 3;
var HH_HELP_CONTEXT = 15;

var gVersion=navigator.appVersion.toLowerCase();

var gnVerMajor=parseInt(gVersion);
var gnVerMinor=parseFloat(gVersion);

gbIE=(navigator.appName.indexOf("Microsoft")!==-1);
if(gnVerMajor>=4)
{
	if(navigator.appName==="Netscape")
	{
		gbNav4=true;
		if(gnVerMajor>=5)
			gbNav6=true;
	}
	gbIE4=(navigator.appName.indexOf("Microsoft")!==-1);
}
if(gbNav6)
{
	document.gnPageWidth=innerWidth;
	document.gnPageHeight=innerHeight;
	var nPos=gAgent.indexOf("netscape");
	if(nPos!==-1)
	{
		var nVersion=parseFloat(gAgent.substring(nPos+10));
		if(nVersion>=6.1)
			gbNav61=true;
	}
}else if(gbIE4)
{
	var nPos=gAgent.indexOf("msie");
	if(nPos!==-1)
	{
		var nVersion=parseFloat(gAgent.substring(nPos+5));
		if(nVersion>=5)
			gbIE5=true;
		if(nVersion>=5.5)
			gbIE55=true;
	}
}

function RH_ShowHelp(hParent, a_pszHelpFile, uCommand, dwData)
{
	// this function only support WebHelp
	var strHelpPath = a_pszHelpFile;
	var strWnd = "";
	var nPos = a_pszHelpFile.indexOf(">");
	if (nPos !== -1)
	{
		strHelpPath = a_pszHelpFile.substring(0, nPos);
		strWnd = a_pszHelpFile.substring(nPos+1);
	}
	if (isServerBased(strHelpPath))
		RH_ShowWebHelp_Server(hParent, strHelpPath, strWnd, uCommand, dwData);
	else
		RH_ShowWebHelp(hParent, strHelpPath, strWnd, uCommand, dwData);
} // RH_ShowHelp

function RH_ShowWebHelp_Server(hParent, strHelpPath, strWnd, uCommand, dwData)
{
	// hParent never used.
	ShowWebHelp_Server(strHelpPath, strWnd, uCommand, dwData);
} // RH_ShowWebHelp_Server

function RH_ShowWebHelp(hParent, strHelpPath, strWnd, uCommand, dwData)
{
	// hParent never used.
	ShowWebHelp(strHelpPath, strWnd, uCommand, dwData);
} // RH_ShowWebHelp


function ShowWebHelp_Server(strHelpPath, strWnd, uCommand, nMapId)
{
	var a_pszHelpFile = "";
	if (uCommand === HH_HELP_CONTEXT)
	{
		if (strHelpPath.indexOf("?") === -1)
			a_pszHelpFile = strHelpPath + "?ctxid=" + nMapId;
		else
			a_pszHelpFile = strHelpPath + "&ctxid=" + nMapId;
	}
	else
	{
		if (strHelpPath.indexOf("?") === -1)
			a_pszHelpFile = strHelpPath + "?ctxid=0";
		else
			a_pszHelpFile = strHelpPath + "&ctxid=0";
	}

	if (strWnd)
		a_pszHelpFile += ">" + strWnd;

	if (gbIE4)
	{
		a_pszHelpFile += "&cmd=newwnd&rtype=iefrm";
		loadData(a_pszHelpFile);
	}
	else if (gbNav4)
	{
		a_pszHelpFile += "&cmd=newwnd&rtype=nswnd";
		var sParam = "left="+screen.width+",top="+screen.height+",width=100,height=100";
		window.open(a_pszHelpFile, "__webCshStub", sParam);
	}
	else
	{
		var sParam = "left="+screen.width+",top="+screen.height+",width=100,height=100";
		if (gbIE5)
			window.open("about:blank", "__webCshStub", sParam);
		window.open(a_pszHelpFile, "__webCshStub");
	}
} // ShowWebHelp_Server


function ShowWebHelp(strHelpPath, strWnd, uCommand, nMapId)
{
	var a_pszHelpFile = "";
	if (uCommand === HH_DISPLAY_TOPIC)
	{
		a_pszHelpFile = strHelpPath + "#<id=0";
	}
	if (uCommand === HH_HELP_CONTEXT)
	{
		a_pszHelpFile = strHelpPath + "#<id=" + nMapId;
	}
	else if (uCommand === HH_DISPLAY_INDEX)
	{
		a_pszHelpFile = strHelpPath + "#<cmd=idx";
	}
	else if (uCommand === HH_DISPLAY_SEARCH)
	{
		a_pszHelpFile = strHelpPath + "#<cmd=fts";
	}
	else if (uCommand === HH_DISPLAY_TOC)
	{
		a_pszHelpFile = strHelpPath + "#<cmd=toc";
	}
	if (strWnd)
		a_pszHelpFile += ">>wnd=" + strWnd;

	if (a_pszHelpFile)
        {
			if (gbIE4)
					loadData(a_pszHelpFile);
			else if (gbNav4)
			{
					var sParam = "left="+screen.width+",top="+screen.height+",width=100,height=100";
					window.open(a_pszHelpFile, "__webCshStub", sParam);
			}
			else
			{
					var sParam = "left="+screen.width+",top="+screen.height+",width=100,height=100";
					if (gbIE5)
							window.open("about:blank", "__webCshStub", sParam);
					window.open(a_pszHelpFile, "__webCshStub");
			}
        }

} // ShowWebHelp

function isServerBased(a_pszHelpFile)
{
	if (a_pszHelpFile.length > 0)
	{
		var nPos = a_pszHelpFile.lastIndexOf('.');
		if (nPos !== -1 && a_pszHelpFile.length >= nPos + 4)
		{
			var sExt = a_pszHelpFile.substring(nPos, nPos + 4);
			if (sExt.toLowerCase() === ".htm")
			{
				return false;
			}
		}
	}
	return true;
} // isServerBased

function getElement(sID)
{
	if(document.getElementById)
		return document.getElementById(sID);
	else if(document.all)
		return document.all(sID);
	return null;
} // getElement

function loadData(sFileName)
{
	if(!getElement("dataDiv"))
	{
		if(!insertDataDiv())
		{
			gsFileName=sFileName;
			return;
		}
	}
	var sHTML="";
	if(gbMac)
		sHTML+="<iframe name=\"__WebHelpCshStub\" src=\""+sFileName+"\"></iframe>";
	else
		sHTML+="<iframe name=\"__WebHelpCshStub\" style=\"visibility:hidden;width:0;height:0\" src=\""+sFileName+"\"></iframe>";

	var oDivCon=getElement("dataDiv");
	if(oDivCon)
	{
		if(gbNav6)
		{
			if(oDivCon.getElementsByTagName&&oDivCon.getElementsByTagName("iFrame").length>0)
			{
				oDivCon.getElementsByTagName("iFrame")[0].src=sFileName;
			}
			else
				oDivCon.innerHTML=sHTML;
		}
		else
			oDivCon.innerHTML=sHTML;
	}
} // loadData

function insertDataDiv()
{
	var sHTML="";
	if(gbMac)
		sHTML+="<div id=dataDiv style=\"display:none;\"></div>";
	else
		sHTML+="<div id=dataDiv style=\"visibility:hidden\"></div>";

	document.body.insertAdjacentHTML("beforeEnd",sHTML);
	return true;
} // insertDataDiv
