<!--- splan_main_include.cfm --->

<cfoutput>
<cffunction name="DisplayPrintColumnHeadings">
	<cfargument name="tHeadings">
	<!--- display Column Headings --->
	<tr>
	<cfscript>
	var sText = "";
	for (walker = 1; walker LE arraylen(arguments.tHeadings.aHeadings); walker +=1 ) {
		sText &= '<th scope="col" width="' & arguments.tHeadings.aHeadings[ walker].width & '%"  class="columnHeading" >' & arguments.tHeadings.aHeadings[ walker].text & '</th>';
	}
	</cfscript>
	#sText#
	</tr>
</cffunction> <!--- DisplayPrintColumnHeadings --->
<cfscript>

array function clearSectionTotals ( aTot ) {
	var icol = 0;

	for ( icol = 1; icol LE ncols; icol += 1) {
		aTot[icol] = 0;
	}

return aTot;

} // clearSectionTotals

function addWithBlanks ( an2, an1 ) {

	var n1 = an1;
	var n2 = an2;

	if ( IsNumeric(n1) ) {
		// there is a number in the incrementing field
		if ( NOT IsNumeric (n2)) {
			// there is NO number in the target
			n2 = n1;
		}
		else {
			// there is a number in both fields
			n2 += n1;
		}
	}

	return n2;

} // addWithBlanks


function subtractWithBlanks ( an2, an1 ) {

	var n1 = an1;
	var n2 = an2;

	if ( IsNumeric(n1) ) {
		// there is a number in the incrementing field
		if ( NOT IsNumeric (n2)) {
			// there is NO number in the target
			n2 = -1 * n1;
		}
		else {
			// there is a number in both fields
			n2 -= n1;
		}
	}

	return n2;

} // subtractWithBlanks


array function incrementTotals ( aM, aTot, irow, ncols ) {
	var icol = 0;

	// skipping the label column
	for ( icol = 2; icol LE ncols; icol += 1) {
		aTot[icol] = addWithBlanks ( aTot[icol], aM[irow][icol] );
	}
	return aTot;

} // incrementTotals

array function insertSectionTotals ( aM, aTot, iSectionHeadingRow, ncols ) {
	var icol = 0;

	// skip the label column
	for ( icol = 2; icol LE ncols; icol += 1) {
		if (aTot[icol] NEQ '&nbsp;' ) {
			aM[iSectionHeadingRow][icol] = aTot[icol] ;
		}
	}
	return aM;

} // insertSectionTotals

</cfscript>

<cffunction name="DoSplan">
<cfargument name="pagetarget">

<!--- GET THE DATA for setting up the display --->

<cfquery name="qgetbareserve">
	select splan_cat_id from splan_cat_master_list where summary_code = 'BARESERVE'
</cfquery>
<cfset splancatidbareserve = qgetbareserve.splan_cat_ID>

<cfquery name="qgetreserve">
	select splan_cat_id from splan_cat_master_list where summary_code = 'RESERVE'
</cfquery>
<cfset splancatidreserve = qgetreserve.splan_cat_ID>


<!--- retrieve current PY from session --->

<cfscript>

//writedump (var = "#session.userpreferences.tmysplannow#", label = "session.userpreferences.tmysplannow in savesettings");
//abort;

if (NOT isDefined ('session.userpreferences.tMySplanNow') ) {
	session.ouser.CreateDefaultSplanDisplaySetting ();
}

nThisPY = session.userpreferences.tMySplanNow.PY;
// retrieve the splancatid of ONE record that has "subheaders" in the report (= 3 = NATIONAL HQ CONTRACTS/ACCOUNTS )
tTemp = application.oSplan.getSplanNationalHQ ( nThisPY )  ;
splancatidforsubheadings = tTemp.aRet[1].splancatid  ;

// get the first date of a Splan in the given PY  ;
tFirstSplan = application.oSplan.getFirstSplanDate( nThisPY )  ;
sFirstSplanDate = tFirstSplan.aRet[1].texttransdate  ;

// queries to retrieve reference data to populate drop-down lists  ;
tPYs = application.oSplan.getPysWithSplan()  ;
aPYs = duplicate(tPYs.aRet)  ;

tTopCodes = application.oSplan.getTopSplanCodes( PY=nThisPY )  ;
aTopCodes = tTopCodes.aRet  ;

// for each row, get the list of child splancatids  ;
tTopChildren = application.oSplan.getTopSplanChildren( aTopCodes )  ;
aTopChildren = tTopChildren.aRet  ;
</cfscript>

<cfif pageTarget EQ 'Screen' >

	<cfset tNotes = application.oSplan.BuildCatNoteStruct ()>

</cfif>
<!---
<cfdump var="#aTopCodes#" LABEL="aTopCodes">
<cfdump var="#aTopChildren#" LABEL="aTopChildren">
<cfabort>
--->

<!--- get lookup data for cost codes --->
<cfquery name="qCostCat">
	select cost_cat_id AS costCatId, cost_cat_code AS costCatCode from lu_cost_cat
</cfquery>
<cfset slcostcatid = valuelist( qCostCat.costCatId )>
<cfset slcostcatcode = valuelist( qCostCat.costCatCode )>

<cfset request.paths.reportcss = application.paths.reportcssPDF>

<cfset na_total = 0>
<cfset cnt= 0>

<!--- get the parameters for the report --->
<cfset throughDate = session.userPreferences.tMySplanNow.todate >
<cfif throughDate EQ ''>
	<cfset throughDate = DateFormat(Now(), 'mm/dd/yyyy')>
	<cfset session.userPreferences.tMySplanNow.todate = throughDate>
</cfif>

<!------------------------   BEGIN HTML --->
<!--- 5/7/2015 padding controls position of the table within the plan black single-line border --->
<div class="ctrSubContent" style="padding: 10px 2px 2px 4px !important;">

<cfif arguments.pagetarget EQ 'Screen' >
	<!--- this appears below the header, and the nagivation submenus --->
	<div id="budgetHeader">
		<div id="budgetSubheaderLeft" style="padding: 2px 0 2px 10px !important;">
			PY #nThisPY# Operations Spend Plan
		</div>
		<!-- /budgetSubheaderLeft-->
		<div id="budgetSubheaderRight">
			#DisplaySpendPlanOptionsButton ( request.pageName )#
		</div>
		<!-- /budgetSubheaderRight-->
	</div>
	<!-- /budgetHeader-->

</cfif> <!--- splanreportformat --->


<div id="BridgeTooltip">

</div> <!--- BridgeTooltip --->


<div style="clear:both;"></div>

<!--- padding lets us position the table precisely withing the one-line border --->
<div class="budgetContent" style="padding: 0 !important;">

<table class="currentSP">

<cfset tSX = duplicate ( session )>
<cfset tHeadings = calculateColumnHeadings ( nThisPY, tSX )>
<cfif arguments.pagetarget EQ 'Screen' >
	<!--- save these for the bridge --->
	<cfset session.tSplanHeadings = duplicate ( tHeadings )>
</cfif>

<cfset ncols = ArrayLen ( tHeadings.aHeadings ) >

<cfset DisplayPrintColumnHeadings( tHeadings ) >

<cfscript>
// set up the initial parameters

aM = ArrayNew (2);
aRowDet = ArrayNew (1);

// this goes PAST the grandtotal row
nrows = arraylen( aTopCodes );
ncols = ArrayLen ( tHeadings.aHeadings );
icolLabel = 1;
icolInit = 2;
icolCurrentSP = ncols - 2;
icolCumulativeFop = ncols - 1;
icolVariance = ncols;
iSection = 0;
iSubSection = 0;
irowGrandTotal = 0;
aSectionTotal = ArrayNew (1);
aSubSectionTotal = ArrayNew (1);
aGrandTotal = ArrayNew (1);

aSectionTotal = ClearSectionTotals ( aSectionTotal );
aSubSectionTotal = ClearSectionTotals ( aSubSectionTotal );
aGrandTotal = ClearSectionTotals ( aGrandTotal );

nappropriation = 0;
nreserve = 0;
nbareserve = 0;


// set up the initial matrix (aM) with row labels and blanks

for (irow = 1; irow LE nrows; irow += 1) {

	sTry = BuildCatOption ( tCat = aTopCodes[ irow ], TriggerFlag = "ReportDisplay", bWithPrefix=true, bBuildDisplayOnly = true, pageTarget = pageTarget );

	aRowDet[iRow] = structNew();
	// we are tracking section AND subsection
	aRowDet[iRow].iSection = iSection;
	aRowDet[iRow].iSubSection = iSubSection;

	aM[irow][icolLabel] = sTry;

	for (icol = 2; icol LE ncols; icol += 1) {
		aM[irow][icol] = '&nbsp;';
	}
} // end of build blank display loop

// calculate values, and insert into matrix

// ---------------------  get all the splan and fop numbers, for use below - (pass 1)

for (irow = 1; irow LE nrows; irow += 1) {

	if ( ListLen (aTopChildren[irow].splanCatIDList ) EQ 1 ) {

		// there is a column-1 label.  This is a lowest level splancat. Get the detail numbers

		aRowDet[irow].type = 'child';
		aRowDet[irow].iSection = iSection;

		// get the splandet records for this splancat, PY, and distribute the numbers across the date columns

		tSplanNumbers = application.oSplan.getSplanDetNumbers ( nThisPY, aTopCodes[irow], aTopChildren[irow], tHeadings );

		//writedump (var="#tSplanNumbers#", label = "tSplanNumbers in splan_main");
		//abort;

		for ( icol = icolInit; icol LE icolCurrentSP; icol += 1 ) {
			aM[irow][icol] = tSplanNumbers.aDateTotal [icol];
		}

		// we get fop records only for splanCats that are at the lowest level in the hierarchy

		tFopNumbers = application.oSplan.getSplanFopNumbers ( PY = nThisPY, tOneTopCode = aTopCodes[irow], tOneTopChildren = aTopChildren[irow], dEndDate = throughDate );

		// writedump (var="#tFopNumbers#", label = "tFopNumbers");

		if ( ArrayLen ( tFopNumbers.Aret ) GE 1) {
			aM[irow][icolCumulativeFop] = tFopNumbers.Aret[1].fopsum;
		}

		// variance
		ncur = 0;
		if ( IsNumeric ( aM[irow][icolCurrentSP] ) ) {
			ncur  = aM[irow][icolCurrentSP] ;
		}
		ncum = 0;
		if ( IsNumeric ( aM[irow][icolCumulativeFop] ) ) {
			ncum  = aM[irow][icolCumulativeFop] ;
		}
		aM[irow][icolVariance] = ncur - ncum;

	} // there is a column-1 label.  This is a lowest level splan-cat

	else {
		// this is not a lowest-level splancat
		iSection += 1;
		aRowDet[irow].type = 'heading';
		aRowDet[irow].iSection = iSection;
	}

	if (aTopCodes[irow].splansectioncode EQ 'SUM' AND irowGrandTotal EQ 0) {
		// set the pointer to the GrandTotal for the first SUM record
		irowGrandTotal = irow;
	}

} // end of calculate values loop - (pass 1)

//writedump (var="#aM#", label="aM after pass 1");
//abort;

// ---------------------  calculate section subtotals, for use below - (pass 2)

sLastsplansectioncode = '';
iSectionHeadingRow = 0;
LastSubSectionSplancatid = 0;
inSubsection = 0;

for (irow = 1; irow LE nrows; irow += 1) {

	// SUBSECTON
	if ( inSubSection EQ 1 AND aTopCodes[irow].SPLAN_CAT_PARENT_ID NEQ LastSubSectionSplancatid ) {
		// we are leaving a subsection
		// insert the old SUBsection totals correctly
		//writedump (var="writing for LastSubSectionSplancatid #LastSubSectionSplancatid# <BR> ");
		aM = insertSectionTotals ( aM, aSubSectionTotal, iSubSectionHeadingRow, ncols );

		// clear the subsection totals for the next section
		aSubSectionTotal = clearSectionTotals ( aSubSectionTotal );

		inSubSection = 0;


	} // we were in a subsection

	if ( aTopCodes[irow].SPLAN_CAT_PARENT_ID EQ splancatidforsubheadings ) {
		// This is a heading for a SUBSection of 3 = NATIONAL HQ CONTRACTS/ACCOUNTS

		inSubSection = 1;

		// remember the splancatid of this subsection, which subsequent aTopCodes[irow].SPLAN_CAT_PARENT_ID in the section will match
		iSubSectionHeadingRow = irow;
		LastSubSectionSplancatid = aTopCodes[irow].splancatid;
	}

	if ( inSubSection EQ 1 ) {
		// since we are in a SUBsection, increment the subsection totals
		aSubSectionTotal = incrementTotals ( aM, aSubSectionTotal, irow, ncols );
		//writedump (var="#aSubSectionTotal#", label="aSubSectionTotal row #irow#");
	}

	// SECTION, which relates to a totally different field: splansectioncode
	if ( aTopCodes[irow].splansectioncode NEQ sLastsplansectioncode OR irow EQ irowGrandTotal) {
		if ( sLastsplansectioncode NEQ '' ) {

			// since we are wrapping up a section, wrap up a SUBsection if there is one
			if ( inSubSection EQ 1 ) {
				//writedump (var="writing for LastSubSectionSplancatid #LastSubSectionSplancatid# <BR> ");
				aM = insertSectionTotals ( aM, aSubSectionTotal, iSubSectionHeadingRow, ncols );

				// clear the subsection totals for the next section
				aSubSectionTotal = clearSectionTotals ( aSubSectionTotal );
				inSubSection = 0;
			}

			// insert the section totals in the section heading row
			//writedump (var="writing for #sLastsplansectioncode#, new code is #aTopCodes[irow].splansectioncode# <BR>");
			aM = insertSectionTotals ( aM, aSectionTotal, iSectionHeadingRow, ncols );
			// clear the section totals for the next section
			aSectionTotal = clearSectionTotals ( aSectionTotal );
		}
		iSectionHeadingRow = irow;
		sLastsplansectioncode = aTopCodes[irow].splansectioncode;
	}

	// SECTION - we are always in one
	aSectionTotal = incrementTotals ( aM, aSectionTotal, irow, ncols );

	if ( irow LT irowGrandTotal ) {
		aGrandTotal = incrementTotals ( aM, aGrandTotal, irow, ncols );
	}

} // end of adjust the splan numbers loop - (pass 2)

// ---------------------  do calculations for the summary section of the report
// THE LAST SUBSECTON
if ( InSubSection EQ 1 ) {
	// we are in a subsection
	// we are starting a new SUBsection, insert the old SUBsection totals correctly
	//writedump (var="writing for LastSubSectionSplancatid #LastSubSectionSplancatid# to row #iSubSectionHeadingRow#<BR> ");
	aM = insertSectionTotals ( aM, aSubSectionTotal, iSubSectionHeadingRow, ncols );
}

// insert the grand totals
aM = insertSectionTotals ( aM, aGrandTotal, irowGrandTotal, ncols );

//writedump (var="#aM#", label="aM after pass 2");
//abort;

// Special plugs in the summary section

// appropriation - goes to 3 locations
xRet	= application.osplan.getSplanAppropriationNumber ( 'OPS', nThisPY );
nappropriation = xRet.aRet[1].amount;

aM [ irowGrandTotal + 1 ][ icolInit ] = nappropriation;
aM [ irowGrandTotal + 1 ][ icolCurrentSP ] = nappropriation;
aM [ irowGrandTotal + 1 ][ icolCumulativeFop ] = nappropriation;

// balance before reserve - straight arithmetic
aM [ irowGrandTotal + 2 ][ icolInit ] = aM [ irowGrandTotal + 1 ][icolInit ] - aM [ irowGrandTotal ][icolInit ] ;
aM [ irowGrandTotal + 2 ][ icolCurrentSP ] = aM [ irowGrandTotal + 1 ][icolCurrentSP ] - aM [ irowGrandTotal ][icolCurrentSP ] ;
aM [ irowGrandTotal + 2 ][ icolCumulativeFop ] = aM [ irowGrandTotal + 1 ][icolCumulativeFop ] - aM [ irowGrandTotal ][icolCumulativeFop ] ;

// reserve - from database call - goes to one cell in the database
xRet	= application.osplan.getSplanReserveNumber ( summarycode = 'RESERVE', PY = nThisPY, dEndDate = throughDate );

nreserve = xRet.aRet[1].fopamount;
aM [ irowGrandTotal + 3 ][ icolCumulativeFop ] = nreserve;

// balance after reserve - preliminary calculation straight arithmetic
aM [ irowGrandTotal + 4 ][ icolInit ] = subtractWithBlanks  (aM [ irowGrandTotal + 2 ][icolInit ],aM [ irowGrandTotal + 3 ][icolInit ]) ;
aM [ irowGrandTotal + 4 ][ icolCurrentSP ] = subtractWithBlanks  (aM [ irowGrandTotal + 2 ][icolCurrentSP ], aM [ irowGrandTotal + 3 ][icolCurrentSP ]) ;
aM [ irowGrandTotal + 4 ][ icolCumulativeFop ] = subtractWithBlanks  (aM  [ irowGrandTotal + 2 ][icolCumulativeFop ], aM [ irowGrandTotal + 3 ][icolCumulativeFop ] );

// variance column for last 3 rows
for ( walker = irowGrandTotal + 2; walker LE irowGrandTotal + 4; walker += 1) {
	aM [ walker][ icolVariance ] = subtractWithBlanks ( aM [ walker][ icolCurrentSP ], aM [ walker ][ icolCumulativeFop ] ) ;
}

// ---------------------  display the calculated values in a table - (pass 3)

sLastsplansectioncode = '';
sExcelEmphasis = '';
if ( pageTarget NEQ 'Screen' ) {
	sExcelEmphasis = ' style="font-weight:bold !important;" ';
}
for (irow = 1; irow LE nrows; irow += 1) {

	// set the shading (and font weight for Excel)
	sclass = '';
	if (aTopCodes[irow].splansectioncode NEQ sLastsplansectioncode OR aTopCodes[irow].splansectioncode EQ 'SUM') {
		sClass = 'class="splanHeaderRow" ' & sExcelEmphasis ;
	}
	else if ( aTopCodes[irow].SPLAN_CAT_PARENT_ID EQ splancatidforsubheadings ) {
		sClass = 'class="splanSubHeaderRow" '  & sExcelEmphasis ;
	}

	sLastsplansectioncode = aTopCodes[irow].splansectioncode;

	sDisplayDesc = aM[irow][icolLabel];
	if ( pagetarget EQ 'Screen' ) {

		// add the note as a title
		sDisplayDesc = '<span title=''#Structfind ( tNotes, aTopCodes[irow].splancatid)#'' >' & sDisplayDesc & '</span>';
	}
	srow = '<tr><td #sclass# >' & sDisplayDesc & '</td>';

	// numerical columns

	for (icol = 2; icol LE ncols; icol += 1) {

		// always display the amount calculated in the spreadsheet
		if (aM[irow][icol] NEQ '&nbsp;' ) {
			sDisplayDesc = NumberFormat ( aM[irow][icol], "9,999");
		}
		else {
			sDisplayDesc = aM[irow][icol];
		}

		if ( pagetarget EQ 'Screen') {
			if (icol GE 2 AND icol LE ncols - 2 ) {

				if ( irow LT nrows - 4 OR irow EQ nrows - 1 ) {
					// row that needs a link to details
					sDisplayDesc = '<span class="splandesclink" title=''Click for details'' id="x#irow##icol#" onClick="gotoSplanTransBridge (this, #aTopCodes[irow].splancatid#, #icol#);">' & sDisplayDesc & '</span>';
				} // row that needs a link to details

			} //column that needs links to details

			if ( irow EQ nrows) {

				// doing the last row

				// we are doing BALANCE AFTER RESERVE

				if ( icol EQ icolInit ) {
					xRet 	= application.osplan.getSplanListFopSum ( splancatidlist = '#splancatidbareserve#', splantranstypecode='INIT',  PY = nThisPY);
					nbareserve = 0;
					// THIS IS AMOUNT, not FOPAMOUNT
					if ( ArrayLen( xRet.aRet ) GT 0 AND xRet.aRet[1].amount NEQ ''){
						nbareserve = xRet.aRet[1].amount;
					}
					// compare the number already in the cell to the calculated difference of the previous rows

					nDiff = subtractWithBlanks( aM [ irow - 2 ][ icol ], aM [ irow - 1 ][ icol ] );

					if ( subtractWithBlanks ( nbareserve, aM [ irow ][ icol ] ) NEQ 0 ) {

						sMsg = 'The sum of the Balance After Reserve Transactions ($#numberformat ( nbareserve, "9,")#) is not equal to this calculated amount ';

						// always display the amount calculated in the spreadsheet
						aM[irow][icol] = ndiff;
						sDisplayDesc = NumberFormat ( ndiff, "9,999");
						sDisplayDesc = '<span class="splandesclink" title=''Click for details'' onClick="gotoSplanTransBridge (this, #aTopCodes[irow].splancatid#, #icol#);">' & sDisplayDesc & '</span>';
						// add the alert
						sDisplayDesc = '<img src="#application.paths.images#alert_icon.gif" width="12" height="11" title="#sMsg#">&nbsp;' & sDisplayDesc ;

					}
				}

				else if ( icol EQ icolCurrentSP ) {

					// get the BARESERVE number from the database
					xRet 	= application.osplan.getSplanListFopSum ( splancatidlist = '#splancatidbareserve#',  PY = nThisPY, dEndDate = throughDate );

					nbareserve = 0;
					// add up the amounts for all the details
					// THIS IS AMOUNT, not FOPAMOUNT
					for (walker = 1; walker LE ArrayLen( xRet.aRet ); walker += 1) {
						nbareserve += xRet.aRet[walker].amount;
					}

					// compare the number already in the cell to the calculated difference of the previous rows
					nDiff = subtractWithBlanks( aM [ irow - 2 ][ icol ] , aM [ irow - 1 ][ icol ] );

					if (  subtractWithBlanks( nbareserve, aM [ irow ][ icol ] ) NEQ 0 ) {

						sMsg = 'The sum of the Balance After Reserve Transactions ($#numberformat ( nbareserve, "9,")#) is not equal to this calculated amount ';

						// always display the amount calculated in the spreadsheet
						aM[irow][icol] = ndiff;
						sDisplayDesc = NumberFormat ( ndiff, "9,999");
						sDisplayDesc = '<span class="splandesclink" title=''Click for details'' onClick="gotoSplanTransBridge (this, #aTopCodes[irow].splancatid#, #icol#);">' & sDisplayDesc & '</span>';
						// add the alert
						sDisplayDesc = '<img src="#application.paths.images#alert_icon.gif" width="12" height="11" title="#sMsg#">&nbsp;' & sDisplayDesc ;

					}
				}

				else if ( icol EQ icolCumulativeFop ) {

					// get the BARESERVE FOP number from the database.  This does NOT consider whether the fop is related to a splantrans
					xRet	= application.osplan.getSplanReserveNumber ( summarycode = 'BARESERVE', PY = nThisPY, dEndDate = throughDate );

					nbreserve = 0;
					// THIS IS FOPAMOUNT, not AMOUNT

					if ( ArrayLen( xRet.aRet ) GT 0 AND xRet.aRet[1].fopamount NEQ ''){
						nbareserve = xRet.aRet[1].fopamount;
					}

					if ( subtractWithBlanks( nbareserve, aM [ irow ][ icol ] ) NEQ 0 ) {

						sMsg = 'The sum of the Balance After Reserve FOPs ($#numberformat ( nbareserve, "9,")#)  is not equal to the this calculated amount';

						// always display the amount calculated in the spreadsheet, which is already correctly placed
						sDisplayDesc = NumberFormat ( aM [ irow ] [ iCol ], "9,999");
						// There is NO "Click for details" on a FOP column
						// add the alert
						sDisplayDesc = '<img src="#application.paths.images#alert_icon.gif" width="12" height="11" title="#sMsg#">&nbsp;' & sDisplayDesc ;

					}
				}
			} // last row

		} // modifications for pagetarget EQ 'Screen'


		srow &= '<td align="right" #sclass# >#sDisplayDesc#</td>';
	} // of numerical column

	srow &= '</tr>';

	// put out the row that has been built
	writeoutput ( srow );

} // irow

</cfscript>


</table>

</div> <!--- budgetContent --->
</div> <!--- ctrSubContent --->
</cffunction> <!--- doPlan --->
</cfoutput>

