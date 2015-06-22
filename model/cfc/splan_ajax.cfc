<!---
page: splan_ajax.cfc

description: functions that respond to ajax functions for spend plans (splan)

splan_ajax.cfc is analogous to aapp_home.cfc

revisions:
2014-12-22	dbellenger	Created
--->
<cfcomponent displayname="Spend Plan Component" hint="Contains queries and functions for Spend Plans">
<cfoutput>
<cfinclude template="#application.paths.includes#DataManipulationLib.cfm">

<!--- THIS IS COLD FUSION --->

<cfscript>
remote string function MakeBridgePopupHTML ( splancatid, icol )

	returnFormat	= "plain"
	output			= "false"

{
	var tRet = {};
	var tTemp = {};
	var aTemp = [];
	var sRet = "";
	var cmd = '';
	var sWindow	= '';
	var nlines = 0;
	var nwidth = 0;
	var nheight = 0;
	var ncharacterMultiplier = 7;
	var nheightMultiplier = 17;
	// this should be 10
	var nmaxDetailCount = 10;

	var sDetailLink = '';
	var sNum1 = '';
	var sNum2 = '';
	var tFirstSplanDate = {};

	var oQuery = new query();

	oQuery.setsql( 'select splan_cat_desc as splancatdesc from splan_cat_master_list where splan_cat_id = #arguments.splancatid#' );

	var qRes = oQuery.execute().getresult();

	var form = {};

	var aHeadings = duplicate ( session.tSplanHeadings.aHeadings ) ;

	form.splanCatdesc = qRes.splancatdesc ;
	form.splanCatIdList = arguments.splancatid;

	tPY = application.oSplan.getSplanPY() ;
	form.PY = tPY.aRet[1].PY ;

	// start and end dates depend on the column

	var ncols = arraylen ( aHeadings ) ;

	if ( arguments.icol EQ 2 ) {
		// initial
		var tFirstSplanDate = application.oSplan.getFirstSplanDate( form.PY );
		var sFirstSplanDate = tFirstSplanDate.aRet[1].texttransdate;
		form.startDate = sFirstSplanDate;

		form.transTypeCode = 'INIT';

	}
	else if ( arguments.icol EQ 3 ) {
		// first increment after initial
		tFirstSplanDate = application.oSplan.getFirstSplanDate( form.PY );
		sFirstSplanDate = tFirstSplanDate.aRet[1].texttransdate;
		form.startDate = sFirstSplanDate;

		// this is SUBTRACTING from dLastDayP1, to emulate submission from the form (?)
		var dTempDate = DateAdd ( "d", -1, aHeadings [ arguments.icol ].dLastDayP1 );
		form.endDate = DateFormat (dTempDate, "mm/dd/yyyy") ;

		form.transTypeCode = 'TRNS';
	}

	else if  ( arguments.icol EQ ncols - 2 ) {
		// total spend plan through the throughDate
		tFirstSplanDate = application.oSplan.getFirstSplanDate( form.PY );
		sFirstSplanDate = tFirstSplanDate.aRet[1].texttransdate;
		form.startDate = sFirstSplanDate;

		form.endDate = session.tSplanHeadings.enddate;
		// includes both INIT and TRNS

	}

	else {
		// all the other incremental columns - there is no call for the fop or variance column

		dTempDate =  aHeadings [ arguments.icol - 1 ].dLastDayP1;
		form.startDate = DateFormat (dTempDate, "mm/dd/yyyy") ;

		dTempDate = DateAdd ( "d", -1, aHeadings [ arguments.icol ].dLastDayP1 );
		form.endDate = DateFormat (dTempDate, "mm/dd/yyyy") ;

		form.transTypeCode = 'TRNS';

	}

	if (structKeyExists (session, "tsplanlistformdata") ) {
		StructClear ( session.tsplanlistformdata ) ;
	}
	else {
		session.tsplanlistformdata = {} ;
	}


//writedump(var="#form#", label="form in splan_ajax");
//abort;
	session.tsplanlistformdata = Duplicate( form ) ;


	// ---------  build detail menu before "Full Details"

	tTemp = application.osplan.getSplanListFopSum ( argumentCollection: "#form#") ;
//writedump(var="#tTemp#", label="tTemp in splan_ajax");
//abort;

	aTemp = duplicate ( tTemp.aRet ) ;
	sRet &= '<table>';
	sDetailLink = '';
	sDisplayRecordCount = '';

	if ( arrayLen ( aTemp ) LE nmaxDetailCount ) {
		// comment out this useful addition...  sDisplayRecordCount = ' (' & arrayLen ( aTemp ) & ' records)';
		// show details
		for ( var walker = 1; walker LE arrayLen ( aTemp ) ; walker += 1 ) {

			nlines += 1;

			sDetailLink = aTEMP[walker].transdesc ;

			cmd = '#application.urls.root#budget/splan_edit.cfm?actionMode=View&CancelReturn=SpendPlan&splanTransID=#aTEMP[walker].splantransid#';

			// this opens a window right now
			// sWindow = window.open( cmd, 'Detail', '' );

			//cmd = 'window.open( ''' & cmd & ''', ''Detail'', '''' );' ;
			cmd = 'location.assign(''' & cmd & ''');';

			sDetailLink = "<a href='##' onClick=" & cmd & ">#sDetailLink#</a> " ;

			sNum1 = numberformat(aTEMP[walker].splantransid, "0000");
			sNum2 = NumberFormat(aTEMP[walker].amount,"9,999");
			nwidth = max (nwidth, (len(sNum1) + len(sNum2) + len(aTEMP[walker].transdesc)) + 4 );

			sRet &= '<tr><td>SP #sNum1#</td><td>#sDetailLink#</td><td style="text-align: right;">&nbsp;&nbsp;&nbsp;&nbsp;#sNum2#</td></tr>';

		}
	} // show details
	else {
		// comment out this useful addition...  sDisplayRecordCount = ' (' & arrayLen ( aTemp ) & ' records)';
	}

	nlines += 1;
	nheight = 40 + nlines * nheightMultiplier;

	// here is "Full Details" link

	cmd = '#application.urls.root#budget/splan_transaction_list.cfm?SortBy=splancatdesc&SortDir=asc' ;
	cmd = 'location.assign(''' & cmd & ''');';
	sRet &= "<tr><td colspan=3 style='text-align:left;'><a href='##' onClick=" & cmd & "  >Full Details#sDisplayRecordCount#</a></td></tr> " ;
	sRet &= '<table><BR>';

	nwidth = max (nwidth, len('Full Details#sDisplayRecordCount#'));
	nwidth = 15 + nwidth * ncharacterMultiplier;

	tRet.HEIGHT = numberformat(nheight,"9")&'px';
	tRet.WIDTH = numberformat(nwidth,"9")&'px';


	tRet.sRet = sRet;
	return SerializeJSON ( tRet );

} // MakeBridgePopupHTML

</cfscript>
</cfoutput>
</cfcomponent> <!--- Spend Plan Component --->
