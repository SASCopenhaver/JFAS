<!---
page: headerDisplayBudgetFunctions.cfm

01/14/2015 - model headerDisplayBudgetFunctions on headerDisplayInfo

--->

<!--- session.roleIDs are  (not sure)
	1 admin
	2 budget
	3 regional
	4 is regional admin
--->
<cfoutput>
<cffunction name="headerDisplayBudgetInfo">
	<cfargument name="PageName">
	<cfif listFindNoCase("ADMIN,BUDOVER", session.rolecd) EQ 0>
		<h1>You do not have Access to the Budget Section</h1>
		<cfreturn>
	</cfif>
	<h1>Job Corps Budget Functions</h1>

</cffunction> <!--- headerDisplayBudgetInfo --->

<cffunction Name="headerDisplayBudgetSecondaryNav">
	<cfargument name="PageName">
	<cfargument name="PY">

	<cfset var tMenu = application.oSplan.getBudgetMenus()>
	<cfset var sPage = ''>
	<cfset var nPage = 0>
	<cfset var sPrimaryMenuStrip = ''>
	<cfset var sMenuStrip = ''>
	<cfscript>
	sPageName = arguments.PageName;
	// check aliasing for menus
	for (var walker = 1; walker LE arraylen( tMenu.aMenuItems[3].aPageToMenus); walker += 1) {
		if ( tMenu.aMenuItems[3].aPageToMenus[walker].pagename EQ sPageName ) {
			sPageName = tMenu.aMenuItems[3].aPageToMenus[walker].menupagename;
			break;
		}
	} // loop

	for (var walker = 1; walker LE arraylen( tMenu.aMenuItems[2].aSecondaryMenuItems); walker += 1) {
		if ( tMenu.aMenuItems[2].aSecondaryMenuItems[walker].pagename EQ sPageName ) {
			nPage = walker;
			break;
		}
	} // loop

	if ( nPage EQ 0 ) {
		writedump (var="No match for pagename #arguments.pagename#");
		abort;
	}

	sPrimaryMenuItem = tMenu.aMenuItems[2].aSecondaryMenuItems[ nPage ].PrimaryMenuItem;

	for (var walker = 1; walker LE arraylen( tMenu.aMenuItems[1].aPrimaryMenuItems); walker += 1) {

		if ( sPrimaryMenuItem EQ tMenu.aMenuItems[1].aPrimaryMenuItems[ walker ].ItemName ) {
			sPrimaryMenuStrip &= '<li id="current2" > ' ;
		}
		else {
			sPrimaryMenuStrip &= '<li> ';
		}

		sPrimaryMenuStrip &= '<a href="' & application.paths.root & 'budget/'
					& tMenu.aMenuItems[1].aPrimaryMenuItems[ walker ].target & '.cfm " >';
					// TextPad '

		sPrimaryMenuStrip &=  tMenu.aMenuItems[1].aPrimaryMenuItems[ walker ].display & '</a></li>' ;
	}
	</cfscript>


	<!--- this is higher-level of Budget Submenu --->
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<!--- determine which top-level item to highlight, based on the particular PageName --->
	<tr class="ctrSubNav">
		<td>
			<ul id="SubNav">
			#sPrimaryMenuStrip#
			</ul>
		</td>
	</tr>
	</table>

	<!--- this is lower level of Budget Submenu --->
	<!--- class = "current" to highlight a particular selection, based on request.pagename EQ arguments.pagename = tMenu.secondaryMenus[walker].pagename --->
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr class="ctrTerNav">
			<td>
			<cfscript>
			for (var walker = 1; walker LE arraylen( tMenu.amenuitems[2].aSecondaryMenuItems); walker += 1) {
				if ( tMenu.amenuitems[2].aSecondaryMenuItems[ walker ].PrimaryMenuItem EQ sPrimaryMenuItem ) {
					if ( tMenu.amenuitems[2].aSecondaryMenuItems[ walker ].display EQ '' ) {
						sMenuStrip &= '&nbsp';

					}
					else {
						if ( TRIM(sMenuStrip) NEQ '' ) {
							sMenuStrip &= ' | ';
						}
						sMenuStrip &= '<a href="' & application.paths.root & 'budget/'
									& tMenu.amenuitems[2].aSecondaryMenuItems[walker].target & '.cfm " ';
									// TextPad '
						if ( arguments.PageName EQ tMenu.amenuitems[2].aSecondaryMenuItems[walker].pagename ) {
							sMenuStrip &= ' class="current" >';
						}
						else {
							sMenuStrip &= ' >';
						}
						sMenuStrip &=  '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' & tMenu.amenuitems[2].aSecondaryMenuItems[walker].display & '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' & '</a>' ;

					} // something to display

				} // matches sPrimaryMenuItem
			}

			</cfscript>
			#sMenuStrip#
			</td>
		</tr>
	</table>

</cffunction> <!--- headerDisplayBudgetSecondayNav --->

<cffunction name="DisplayFOPList">
	<cfargument name="ToFrom">
	<!--- display list of FOP's, with FOPs NOT SUMMED --->
	<!--- NOT using a formvariable, but a value returned when getting data for this form --->

	<cfset var nOutstanding = 0>
	<cfset var sRet = ''>
	<cfset var tFop = application.oSplan.getSplanListFopDetails (
		splanTransDetIdList = tFormFromDB.Aret[arguments.tofrom].splantransdetid,
		splanCatIdList = tFormFromDB.Aret[arguments.tofrom].splancatid  ) />
		<!---
	<cfdump var="#tFop#" label="tFop in headerdisplaybudgetfunctions">
	<cfabort>
	--->
	<cfset var nfopCount = arrayLen(tFop.Aret)>
	<cfset var nSplanTotal = tFormFromDB.Aret[arguments.tofrom].amount>
	<cfif nFopCount GT nFopCountBeforeReport>
		<!--- build a link to a report --->
		<cfset nFopTotal = 0>
		<cfloop from="1" to="#arrayLen( tFop.aRet )#" index="walker">
			<cfset nFopTotal += tFop.aRet [ walker ] . fopamount />
		</cfloop>
		<cfset nOutstanding = nSplanTotal - nFopTotal >

		<tr valign="top">
			<!--- style this row with lines top and bottom --->
			<td scope="row" class="LeftLabel" >
				FOPs
			</td>
			<!--- style this TD with lines top and bottom --->
			<td class="RightPad" >
				<cfset saFopLink = '<a href="##" onClick="GoToBudgetReport( ''report_budget_splan_list_fop_detail.cfm'', ' & form.PY & ', ''' & tFormFromDB.Aret[arguments.tofrom].splantransid & ''', ''' & tFormFromDB.Aret[arguments.tofrom].splantransdetid & ''', ''' & tFormFromDB.Aret[arguments.tofrom].splancatid & ''', ''' & tFormFromDB.Aret[arguments.tofrom].splancatdesc & ''' );">Multiple FOPs</a>' >

				<!--- " TextPad --->
				<cfset sfoptotalstyle = "">

				<cfif nFopTotal LE 0>
					<cfset sfoptotalstyle = 'style="color: red;"'>
				</cfif>

				<cfscript>
				sRet = '<tr><td>#saFopLink#</td><td colspan="2">&nbsp;</td><td align="right">#numberFormat(nFopTotal,"$-,")#</td></tr>';
				sRet = '<table class="foplist" width="100%">'  & sRet &
				'<tr><td colspan="1">&nbsp;</td><td colspan="2" align="right">Outstanding</td><td align="right"><span #sfoptotalstyle# >' & numberFormat(nOutstanding,"$-,") & '</span></td></tr></table>';
				</cfscript>

				#sRet#

			</td>
		</tr>

	<cfelse>
		<!--- display the list of FOPs here --->
		<tr valign="top">
			<td scope="row" class="LeftLabel" >
				FOPs
			</td>
			<td class="RightPad" >
				#BuildFopList( tFop.aRet, nSplanTotal )#
			</td>
		</tr>
	</cfif>
</cffunction>


<cffunction name="DisplaySpendPlanOptionsButton">
	<cfargument name="PageName">

	<cfset var btnOptionstyle = "border:normal 0px !important; height:25px; border-top: 0px solid black !important;border-right: 1px solid black !important;">

	<button type="button" id="btnOptions" style="#btnOptionstyle#" title="Links to Other Pages" onclick="openOneSplanmenu('idSplanOpts#arguments.PageName#', '#session.userID#');">&nbsp;&nbsp;Options <span class="caret"></span>&nbsp;&nbsp;</button>

	<!--- class="btn_pri_nav btn btn-default btn-xs "  ---->

</cffunction>

<cffunction name="BuildCatOption" >

	<cfargument name="tCat" >
	<cfargument name="selectedValue" >
	<cfargument name="triggerFlag" default="TransAssoc" >
	<cfargument name="bWithPrefix" default=false >
	<cfargument name="bBuildDisplayOnly" default=false >
	<cfargument name="pagetarget" default='Screen' >

	<!--- builds an option LINE for selecting a category, given an array element from getTopSplanCodes --->
	<cfset var sRet = "">
	<cfset var isMatched = true>
	<cfset var sDescField = "">
	<cfset var sFill = '&nbsp;'>
	<cfif pagetarget NEQ 'Screen'>
		<cfset sFill = '&nbsp;&nbsp;'>
	</cfif>
	<!---
	<cfdump var="#arguments#" label="arguments">
	--->
	<cfif arguments.TriggerFlag eq "TransAssoc" and arguments.tCat.transAssoc EQ 0>
		<cfset isMatched = false>
	<cfelseif arguments.TriggerFlag eq "TransDisplay" and arguments.tCat.transDisplay EQ 0>
		<cfset isMatched = false>
	<cfelseif arguments.TriggerFlag eq "ReportDisplay" and arguments.tCat.ReportDisplay EQ 0>
		<cfset isMatched = false>
	</cfif>
	<cfif structKeyExists(arguments, "bWithPrefix") AND BooleanFormat ( arguments.bWithPrefix ) >
		<cfset sDescField = tCat.SplanCatDescWithPrefix>
	<cfelse>
		<!--- default is "No Prefix" --->
		<cfset sDescField = tCat.SplanCatDesc>
	</cfif>

	<cfif arguments.TriggerFlag EQ "TransAssoc" >
		<!--- put out items for a select box --->
		<cfif isMatched >
			<!--- can associate a transaction --->
			<cfif ListFindNoCase ( 'RESERVE,USDA', sDescField) NEQ 0 >
				<!--- USDA and RESERVE are special cases, since we want to show them as sections --->
				<option value=0 disabled>----------</option>
			</cfif>
			<cfset sRet = "<option value=" & tCat.SplanCatId>
			<cfif tCat.SplanCatId eq arguments.selectedValue><cfset sRet &= " selected "></cfif>
			<cfset sRet &= ">" & RepeatString(sFill, tCat.hierarchylevel) & sDescField & "</option>">
			<!--- TextPad ' --->
		<cfelse>
			<!--- put out something only if the splancat should display --->
			<cfif arguments.tCat.transDisplay EQ 1>
				<!--- cannot associate a transaction (i.e. header, or reporting category --->
				<!--- note: puts out a "------" above a non-associative line --->
				<cfset sRet = "<option value=0 disabled>----------</option><option value=" & tCat.SplanCatId & " disabled>" & RepeatString(sFill, tCat.hierarchylevel) & sDescField & "</option>">
				<!--- TextPad ' --->
			</cfif>
		</cfif>
	<cfelseif arguments.TriggerFlag EQ "TransDisplay">
		<!--- put out items for a select box --->
		<cfif isMatched >
			<!--- can associate a transaction --->
			<cfset sRet = "<option value=" & tCat.SplanCatId>
			<cfif tCat.SplanCatId eq arguments.selectedValue><cfset sRet &= " selected "></cfif>
			<cfset sRet &= ">" & RepeatString(sFill, tCat.hierarchylevel) & sDescField & "</option>">
			<!--- TextPad ' --->
		</cfif>
	<cfelseif arguments.TriggerFlag EQ "ReportDisplay" >
		<!--- put out items for a display --->
		<cfif isMatched >
			<cfset sRet = RepeatString(sFill, tCat.hierarchylevel) & sDescField >
			<!--- TextPad ' --->
		</cfif>
	</cfif>

	<cfreturn sRet />
</cffunction>

<cfscript>
function DisplaySortableColumnHeading ( required SCRIPT_NAME, required fieldName,  required sortBy,  required sortDir,  required ColumnHeading, alignment ) {
	var sRet = '';

	sRet = '<th scope="col" ';
	if (structKeyExists (arguments, 'alignment') and arguments.alignment NEQ '') {
		sRet &= ' style="text-align:' & alignment & ';" ';
	}

	sRet &= '><a href="' & SCRIPT_NAME & '?sortBy=' & fieldName & '&sortDir=';
	// Textpad "

	// if we are sorting on the field noted by this column
	if ( sortBy eq fieldName and sortDir eq 'asc' ) {
		// converts sort order for the next click
		sRet &= 'desc';
	}
	else {
		sRet &= 'asc';
	}
	sRet &= '" > ' & ColumnHeading & '</a></th>';

	return sRet;
} // DisplaySortableColumnHeading
// Textpad '

function BuildInputClass ( fieldname, errorFieldsList, IsReadonly, sFieldType ) {
	// returns a readonly class, a readonly plus error class, an editable class, or an editable class plus error
	// details are different if sFieldType = 'select'

	var sInputClass = '' ;

	if ( structkeyexists (arguments, "sFieldType") and arguments.sFieldType EQ 'select' ) {
		// this is a select
		if ( arguments.IsReadonly EQ true) {
			// readonly
			if ( listFindNoCase ( arguments.errorFieldsList, arguments.fieldname, "~") ) {
				// add the error class for highlighting fields with errors, and a style to erase the borders
				sInputClass = ' readonly class="inputReadonly errorField" style="border: 5px;"' ;
			}
			else {
				// simple readonly
				sInputClass = ' readonly class="inputReadonly" style="border: 5px;" ' ;
			}
		}
		else {
			// editable
			if ( listFindNoCase ( arguments.errorFieldsList, arguments.fieldname, "~") ) {
				// add the error class for highlighting fields with errors
				sInputClass = ' class="inputEditable errorField" ';
			}
			else {
				// simple editable select
				sInputClass = ' class="splanSelect" ' ;
			}
		}
	} // this is a select

	else {
		// not a select

		if ( arguments.IsReadonly EQ true) {
			// readonly
			if ( listFindNoCase ( arguments.errorFieldsList, arguments.fieldname, "~") ) {
				// add the error class for highlighting fields with errors, and a style to erase the borders
				sInputClass = ' readonly class="inputReadonly errorField" style="border: 5px;"' ;
			}
			else {
				// simple readonly
				sInputClass = ' readonly class="inputReadonly" style="border: 5px;" ' ;
			}
		}
		else {
			// editable
			if ( listFindNoCase ( arguments.errorFieldsList, arguments.fieldname, "~") ) {
				// add the error class for highlighting fields with errors
				sInputClass = ' class="inputEditable errorField" ';
			}
			else {
				// simple editable
				sInputClass = ' class="inputEditable" ' ;
			}
		}
	} // not a select
	return sInputClass;

} // BuildInputClass

function BuildDateTime ( datefield ) {
	var sRet = '';
	sRet &= DateFormat(arguments.datefield, 'mm/dd/yyyy') & ' ' & timeformat(arguments.datefield, 'HH:mm');
	return sRet;
} //

function BuildTimeandUser ( datefield, userid ) {
	var sRet = '';
	var qUser = session.ouser.getUserData( arguments.userid );
	sRet &= BuildDateTime ( arguments.datefield) & ' (' & qUser.lastname & ', ' & qUser.firstname & ')';
	return sRet;
} //

function BuildFopList ( aRet, nSplanTotal ) {
	var nFopTotal = 0;
	var sRet = '';
	var walker = 0;
	var nFopCount = 0;
	var nOutstanding = 0;

	for (walker = 1; walker LE arrayLen( aRet ); walker += 1) {
		if ( IsNumeric(aRet [ walker ] . fopamount) ) {
			nFopTotal += aRet [ walker ] . fopamount;
		}
		if ( aRet [walker].fopdateexecuted EQ '' AND aRet [walker].fopdescription EQ '' AND aRet [walker].fopaapp EQ '' AND aRet [walker].fopamount EQ '') {
			continue;
		}
		sRet &= '<tr>'
		& '<td width="30%"> ' & DateFormat(aRet [walker].fopdateexecuted, "mm/dd/yyyy") & ' ' & TimeFormat(aRet [walker].fopdateexecuted, "hh:mm:ss")& '</td>'
		& '<td > ' & aRet [walker].fopdescription & '</td>'
		& '<td > AAPP ' & aRet [walker].fopaapp & '</td>'
		& '<td align="right"> ' & numberFormat(aRet [walker].fopamount, "$-,") & '</td>'
		& '</tr>';
		nFopCount += 1;

	} // loop

	var sfoptotalstyle = "";
	nOutstanding = nSplanTotal - nFopTotal;

	// these are tests on different variables....
	if (nOutStanding LT 0) {
		sfoptotalstyle = 'style="color: red;"' ;
	}

	// there are 4 columns
	if ( nFopCount LE 0 ) {
		sRet = '<tr><td width="30%">None</td><td colspan="3">&nbsp;</td></tr>';
	}


	sRet = '<table class="foplist" width="100%">'  & sRet &
	'<tr><td colspan="1">&nbsp;</td><td colspan="2">Outstanding</td><td align="right"><span #sfoptotalstyle# >' & numberFormat(nOutstanding,"$-,") & '</span></td></tr></table>';

	return sRet;

} // BuildFopList

// this is CF, NOT JS
public boolean function BooleanFormat (sTry) {
	var bRet=false;

	if (YesNoFormat(arguments.sTry) EQ 'Yes') {
		bRet=true;
	}

	return bRet;

} // BooleanFormat


function getDateP1( date ) {
	// calculate a date plus 1 day
	return DateAdd ( "d", 1, DateFormat( date, "mm/dd/yyyy"));
}

array function adjustRevText ( acolHead ) {

	var sRevisionText = "Revs thru ";
	var sRevDateFormat = "mm/dd";
	var dTry = '';
	var sText = '';
	var aRet = duplicate( acolHead );

	// arbitray setting, empirically determined
	if (arrayLen(aRet) GT 7) {

		 for (var walker = 1; walker LE ArrayLen(aRet); walker += 1) {
		 	if ( StructKeyExists (aRet[walker], 'dLastDayP1')) {
				dTry = DateAdd ( "d", -1, aRet[walker].dLastDayP1);
				sText = '#sRevisionText#' & DateFormat( dTry, "#sRevDateFormat#");
				aRet[walker].text = sText;
			}
		 }
	}

	return aRet;

} // adjustRevText


function calculateColumnHeadings ( nCurrentPY, tSes ) {
	// calculate column headings for current year spend plan, using the values from session.userPreferences.tMySplan
	var aRet = [];
	var aDateBreak = [];
	var iDateBreak = 0;
	var nRet = 0;
	var tLoc = {};
	var aLoc = [];
	var nLoc = 0;
	var tCol = {};
	var sText = '';
	var tRet = {};
	var nCustom = 0;

	tRet.py = tSes.userPreferences.tMySplanNow.py;

	// beginning of the PY
	// the initial date for a PY is nominally 7/1/xx.

	var dStartDate = CreateDate ( tRet.py, 7, 1 );
	var dThroughDate = tSes.userPreferences.tMySplanNow.todate;
	if ( dThroughDate EQ '' ) {
		dThroughDate = DateFormat(Now(),'mm/dd/yyyy');
		tSes.userPreferences.tMySplanNow.todate = dThroughDate;
	}
	var dThroughDateP1 = getDateP1 ( dThroughDate );

	var dTempDateP1 = '';
	var sRevisionText = "Revisions Through ";
	var sRevDateFormat = "mm/dd/yyyy";

	tRet.radspendingbreakdown = tSes.userPreferences.tMySplanNow.radspendingbreakdown;
	tRet.startDate = dStartDate;
	tRet.endDate = dThroughDate;
	tRet.radSaveSettings = tSes.userPreferences.tMySplanNow.radSaveSettings;

	for ( walker = 1; walker LE 14; walker += 1) {
		if (tSes.userPreferences.tMySplanNow.CustomDate[walker] NEQ '') {
			aLoc [ walker ] = tSes.userPreferences.tMySplanNow.CustomDate[walker];
			nCustom = walker;
		}
		else {
			break;
		}
	}

	tRet.aCustomDates = duplicate ( aLoc );

	// first column heading is blank (for Centers, splan items)
	// allow overwrite
	structInsert( tCol, 'text', ' ', 1);
	structInsert( tCol, 'width', 15, 1);
	nRet += 1;
	aRet [ nRet ] = duplicate ( tCol );

	// initial value - NOT date related - all INIT records for this PY
	sText = 'PY ' & arguments.nCurrentPY & ' Spend Plan (initial)';
	structInsert( tCol, 'text', sText, 1);
	structInsert( tCol, 'width', 10, 1);
	nRet += 1;
	aRet [ nRet ] = duplicate ( tCol );

	// intermediate columns - must have a related "Last Day in the column, plus 1"
	if ( tRet.radspendingbreakdown EQ 1 ) {
		// DEFAULT.  Show revisions through throughDate
		sText = 'Revisions<br>through ' & DateFormat(dThroughDate, "mm/dd/yyyy");
		structInsert( tCol, 'text', sText, 1);
		structInsert( tCol, 'width', 10, 1);
		dTempDateP1 = DateAdd ( "d", 1, DateFormat(dThroughDate, "mm/dd/yyyy"));
		structInsert( tCol, 'dLastDayP1', dTempDateP1, 1);
		iDateBreak += 1;
		aDateBreak [ iDateBreak ] = dTempDateP1;
		nRet += 1;
		aRet [ nRet ] = duplicate ( tCol );
	}

	else if ( tRet.radspendingbreakdown EQ 2 ) {
		// QUARTERLY
		// there are 3 possible quarterly columns. The first possible quarterly is 9/30/yyyy
		for (walker = 1; walker LE 3; walker += 1) {
			dTempDateP1 = DateAdd ( "m", 3 * walker, dStartDate );
			dTry = DateAdd ( "d", -1, dTempDateP1);
			if ( DateCompare ( dTry, dThroughDate) GE 0 ) {
				// quarterly column equals or exceeds the last day of the PY
				break;
			}

			sText = '#sRevisionText#' & DateFormat( dTry, "mm/dd/yyyy");
			structInsert( tCol, 'text', sText, 1);
			structInsert( tCol, 'width', 10, 1);
			structInsert( tCol, 'dLastDayP1', dTempDateP1, 1);
			iDateBreak += 1;
			aDateBreak [ iDateBreak ] = dTempDateP1;

			nRet += 1;
			aRet [ nRet ] = duplicate ( tCol );
		} // walker
	}

	else if ( tRet.radspendingbreakdown EQ 3 ) {
		// MONTHLY
		// there are 12 possible month columns. The first possible monthly is 7/30/yyyy
		for (walker = 1; walker LE 12; walker += 1) {
			dTempDateP1 = DateAdd ( "m", walker, dStartDate );
			dTry = DateAdd ( "d", -1, dTempDateP1);
			if ( DateCompare ( dTry, dThroughDate) GE 0 ) {
				// month column equals or exceeds the last day of the PY
				break;
			}

			sText = '#sRevisionText#' & DateFormat( dTry, "#sRevDateFormat#");
			structInsert( tCol, 'text', sText, 1);
			structInsert( tCol, 'width', 10, 1);
			structInsert( tCol, 'dLastDayP1', dTempDateP1, 1);
			iDateBreak += 1;
			aDateBreak [ iDateBreak ] = dTempDateP1;

			nRet += 1;
			aRet [ nRet ] = duplicate ( tCol );
		} // walker
	}

	else if ( tRet.radspendingbreakdown EQ 4 ) {

		// CUSTOM DATES
		// there are 12 possible custom date columns. The first possible custom date is 7/2/yyyy
		for ( walker = 2; walker LE nCustom; walker += 1 ) {
			dTempDateP1 = getDateP1 ( aLoc [ walker ] );
			dTry = DateAdd ( "d", -1, dTempDateP1);
			if ( DateCompare ( dTry, dThroughDate) GT 0 ) {
				// custom column exceeds the last day of the PY
				break;
			}

			sText = '#sRevisionText#' & DateFormat( dTry, "#sRevDateFormat#");
			structInsert( tCol, 'text', sText, 1);
			structInsert( tCol, 'width', 10, 1);
			structInsert( tCol, 'dLastDayP1', dTempDateP1, 1);
			iDateBreak += 1;
			aDateBreak [ iDateBreak ] = dTempDateP1;

			nRet += 1;
			aRet [ nRet ] = duplicate ( tCol );
		} // walker
	}

	// see if we need a last "increment" column

	if ( arrayLen ( aDateBreak ) EQ 0  OR DateCompare ( aDateBreak [ iDateBreak ], dThroughDateP1 ) LT 0) {
		// add a last "increment" column

		dTempDateP1 = getDateP1 ( dThroughDate );
		dTry = DateAdd ( "d", -1, dTempDateP1);

		sText = '#sRevisionText#' & DateFormat( dTry, "#sRevDateFormat#");
		structInsert( tCol, 'text', sText, 1);
		structInsert( tCol, 'width', 10, 1);
		structInsert( tCol, 'dLastDayP1', dTempDateP1, 1);
		iDateBreak += 1;
		aDateBreak [ iDateBreak ] = dTempDateP1;

		nRet += 1;
		aRet [ nRet ] = duplicate ( tCol );
	} // add a last "increment" column

	// shorten column heading text for revisions, if there are "too many" revision columns
	aRet = adjustRevText ( aRet );

	structDelete( tCol, 'dLastDayP1');

	// total splan for the PY - date related.  The date shown here is the through date
	sText = 'PY ' & arguments.nCurrentPY & ' Spend Plan<BR>(as of ' & DateFormat(dThroughDate, "mm/dd/yyyy") & ')';
	structInsert( tCol, 'text', sText, 1);
	structInsert( tCol, 'width', 10, 1);
	nRet += 1;
	aRet [ nRet ] = duplicate ( tCol );

	// cumulative FOPs - NOT date related
	sText = 'PY ' & arguments.nCurrentPY & '<br>Cumulative FOPs';
	structInsert( tCol, 'text', sText, 1);
	structInsert( tCol, 'width', 10, 1);
	nRet += 1;
	aRet [ nRet ] = duplicate ( tCol );

	// Spend Plan/FOP Variance - NOT date related
	sText = 'Spend Plan/FOP Variance';
	structInsert( tCol, 'text', sText, 1);
	structInsert( tCol, 'width', 10, 1);
	nRet += 1;
	aRet [ nRet ] = duplicate ( tCol );

	// adjust the column widths based on number of columns
	if (nRet LT 100) {
		aRet[1].width = 25;
		nNewWidth = (100 - 25) / ( nRet - 1);
		for ( walker = 2; walker LE nRet; walker += 1) {
			structUpdate( aRet [ walker ], 'width', nNewWidth );
		}
	}

	tRet.aDateBreak = duplicate ( aDateBreak );
	tRet.aHeadings = duplicate (aRet) ;
	return tRet;

} // calculateColumnHeadings

private function Make0 ( f ) {

	if ( f EQ '&nbsp;') {
		return 0;
	}
	else {
		return f;
	}

} // Make0



</cfscript>


</cfoutput>