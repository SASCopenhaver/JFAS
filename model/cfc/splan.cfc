<!---
page: splan.cfc

description: functions that support spendplans (splan)  non-ajax

revisions:
2014-12-22	dbellenger	Created
--->

<cfcomponent displayname="Spend Plan Component (splan.cfc)" hint="Contains queries and functions for Spend Plans">
<cfinclude template="#application.paths.includes#DataManipulationLib.cfm">
<cfoutput>
<cfset sxPrefix = "">

<cfscript>
/**
* @hint I run the AAPP query, and generate (1) html for the home page data, and (2) html for the Filter Description, and (3) the effective length of the Filter Description, allowing 3 characters for each icon
* @sCFFieldString This string is built by a JS form.serialize()
* @sortBy		a column name from url
* @sortDir		asc/desc from url
* @roleID		from login
* @region		from login
*/

public struct function getBudgetMenus ()
{
	// this returns a structure that is an array of structs
	var tPY = getSplanPY() ;
	var ncurrentPY = tPY.aRet[1].PY ;
	var nfuturePY = ncurrentPY + 1;

	var tRet = { aMenuItems =
	[

		{ aPrimaryMenuItems =
		[
			{itemname = "spendplan"
				,display = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Spend Plan&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
				,target= 'splan_main'
				}

			, {itemname = 'allotment'
				,display = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Budget Appropriation / Allotment&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
				,target= 'approp_allot_controller'
				}
		]
		}
		,{ aSecondaryMenuItems =
		[
			{pagename = 'SplanMain'
				,display = 'Spend Plan'
				,target= 'splan_main'
				,PrimaryMenuItem = 'spendplan'
				}

			, {pagename = 'SplanTransList'
				,display = 'Transactions'
				,target= 'splan_transaction_list'
				,PrimaryMenuItem = 'spendplan'
				}

			, {pagename = 'SplanFuture'
				,display = 'PY#nfuturePY# Spend Plan Worksheet'
				,target= 'splan_future_controller'
				,PrimaryMenuItem = 'spendplan'
				}

			, {pagename = 'SplanAppropAllot'
				,display = ''
				,target= 'approp_allot_controller'
				,PrimaryMenuItem = 'allotment'
				}
		]
		}
		,{ aPageToMenus =
		[
			{pagename = 'SplanEdit'
				,menupagename = 'SplanTransList'
				}
			,{pagename = 'SplanDisplaySettings'
				,menupagename = 'SplanTransList'
				}
		]
		}
	]
	};

	return tRet;

} // getBudgetMenus


/**
* @hint I get a list of PYs that have a (finalized = "not future") spendplan associated with them
*/
public struct function getPysWithSplan (  )
{
	var tRet = {};
	var aRet = [];
	var oQuery = new query();

	var sQueryText = "select distinct (py) as py from splan_trans order by py" ;

	oQuery.setsql ( sQueryText );

	var qRes = oQuery.execute().getresult();

	tRet.aRet = QuerytoArrayofStructures(qRes);
	tRet.status = true;

	return tRet;

} // getPysWithSplan

public struct function getFirstSplanDate ( py )
{
	var tRet = {};
	var aRet = [];
	var oQuery = new query();
	var sQueryText = 'select trans_date as transdate from splan_trans ';
	if ( arguments.py NEQ '') {
		sQueryText &= " where py=" & arguments.py ;
	}
	sQueryText &= ' order by trans_date';

	sQueryText = "select transdate, TO_CHAR( transdate, 'MM/DD/YYYY') as texttransdate from ( " & sQueryText & " ) where ROWNUM <= 1";
	oQuery.setsql ( sQueryText );

	var qRes = oQuery.execute().getresult();

	tRet.aRet = QuerytoArrayofStructures(qRes);
	tRet.status = true;

	return tRet;

} // getFirstSplanDate

public struct function getAppropriationNumber ( py, fundcat )
{

	var tRret = {};
	var aRet = [];
	var oQuery = new query();

	var sQueryText = "select approp_id as appropid, fund_cat as fundcat, py, amount
	FROM appropriation
	WHERE fund_cat = '" & arguments.fundcat & "' AND PY = " & arguments.py ;

	oQuery.setsql ( sQueryText );

	var qRes = oQuery.execute().getresult();

	tRet.aRet = QuerytoArrayofStructures(qRes);
	tRet.status = true;
	return tRet;

} // getAppropriationNumber

/**
* @hint I return two single quotes where there was one.  Helps with Oracle queries
* @field value to convert
*/

function dblquote ( field ) {
	return ReplaceNoCase( field, "'", "''", 'all');
}

/**
* @hint I save a set of spend plans details. There is one splan_trans record, and TWO splan_trans_det records
* @formdata Values to be saved
*/

public struct function saveSplanDetails ( formData )

{
	var tret = {};
	var d = {};
	var aRet = [];
	var sQueryText = '';
	var oQuery = new query();
	var nsplantransid = 0;
	var walker = 0;
	var aAmount = [];
	var aCategory = [];
	var aDetId = [];
	tRet.slErrorMessages = '';
	tRet.slErrorFields = '';
	// this must be 0, not blank, since it is used by splan_edit page as the splantransid after save.  If there are errors on Add, there is no new splantransid, and 0 is the correct return.
	tRet.sMessage = '0';
	tRet.status = true;

	// for ease of coding
	d = duplicate( arguments.formData );

	// adjust data for update
	d.amount = ReplaceNoCase ( d.amount, ',', '', 'all');

	//writedump (var="#d#", label="d in saveSplanDetails");
	//abort;

	// check data for errors
	if ( NOT isNumeric( d.PY ) OR d.PY LT (year(Now()) - 10) OR d.PY GT (year(Now()) + 10) ) {
		tRet.status = false;
		tRet.slErrorMessages = ListAppend( tRet.slErrorMessages, 'ProgramYear (PY) is out of range' ,"~") ;
		tRet.slErrorFields = ListAppend( tRet.slErrorFields, 'PY' ,"~");
	}
	if ( transdesc EQ '' ) {
		tRet.status = false;
		tRet.slErrorMessages = ListAppend( tRet.slErrorMessages, 'Description is required',"~") ;
		tRet.slErrorFields = ListAppend( tRet.slErrorFields, 'TransDesc' ,"~");
	}
	if ( transstatuscode NEQ 'O' AND transstatuscode NEQ 'C' ) {
		tRet.status = false;
		tRet.slErrorMessages = ListAppend( tRet.slErrorMessages, 'Status must be Open or Closed',"~") ;
		tRet.slErrorFields = ListAppend( tRet.slErrorFields, 'transstatuscode' ,"~");
	}
	if ( NOT isNumeric( d.amount ) OR d.amount LT 0 ) {
		tRet.status = false;
		tRet.slErrorMessages = ListAppend( tRet.slErrorMessages, 'Amount must be numeric, and greater than 0',"~") ;
		tRet.slErrorFields = ListAppend( tRet.slErrorFields, 'Amount' ,"~");
	}
	if ( (d.fromcategory EQ '' or d.fromcategory EQ 0) AND d.TransTypeCode NEQ 'INIT') {
		tRet.status = false;
		tRet.slErrorMessages = ListAppend( tRet.slErrorMessages, 'You must pick a FROM category',"~") ;
		tRet.slErrorFields = ListAppend( tRet.slErrorFields, 'fromcategory' ,"~");
	}

	if ( d.tocategory EQ '' or d.tocategory EQ 0 ) {
		tRet.status = false;
		tRet.slErrorMessages = ListAppend( tRet.slErrorMessages, 'You must pick a TO category',"~") ;
		tRet.slErrorFields = ListAppend( tRet.slErrorFields, 'tocategory' ,"~");
	}

	if ( tRet.status EQ true) {
		// passed all the edits
		// must be a single quote around a text field

		if (d.actionmode EQ 'edit') {

			sQueryText = "UPDATE splan_trans
			SET
			trans_status_code = '#d.transStatusCode#'
			, trans_desc = '#dblquote(d.transDesc)#'
			, py = '#d.py#'
			, trans_note = '#dblquote(d.transNote)#'
			, trans_type_code = '#d.transTypeCode#'
			, update_user = '#session.userID#'
			, update_date = #now()#
			WHERE splan_trans_id = #d.splanTransId#";

			oQuery.setsql ( sQueryText );
			// there is no return from the query
			oQuery.execute();

			// todo:  need to detect if query fails
			ndetailcount = 1;
			aAmount[1] = d.amount;
			aCategory[1] = d.tocategory;
			aDetId[1] = ListGetAt( d.slsplantransdetid, 1);
			if ( d.TransTypeCode NEQ 'INIT' ) {
				ndetailcount = 2;
				aAmount[2] = -1 * d.amount;
				aCategory[2] = d.fromcategory;
				aDetId[2] = ListGetAt( d.slsplantransdetid, 2);
			}

			// save 1 or 2 detail records

			for (walker = 1; walker <= ndetailcount; walker += 1 ) {
				sQueryText = "UPDATE splan_trans_det
				SET
				splan_cat_id = #aCategory [ walker ]#
				, amount = #aAmount [ walker ]#
				, update_user = '#session.userID#'
				WHERE splan_trans_det_id = #aDetId [ walker ]#";

				oQuery.setsql ( sQueryText );
				// there is no return from the query
				oQuery.execute();


			} // two detail records
			application.outility.insertSystemAudit ( description="Spend Plan Transaction Updated #d.PY#-#d.splanTransId#", userID=session.userID );

			tRet.status = true;

		} // edit

		else if ( d.actionmode EQ 'add') {
			// splan_trans_id is handled by a sequence
			// trans_date is now
			// Create_date, update_date, and trans_date are handled by triggers
			// trans_status_code is alpha
			// trans_type_code is alpha

			sQueryText = "INSERT INTO splan_trans (
			splan_trans_id,
			trans_desc,
			py,
			trans_note,
			trans_status_code,
			trans_type_code,
			create_user,
			update_user

			) VALUES (

			SEQ_SPLAN_TRANS.nextval,
			'#dblquote(d.transdesc)#',
			#d.py#,
			'#dblquote(d.transnote)#',
			'#d.transstatuscode#',
			'#d.transtypecode#',
			'#session.userid#',
			'#session.userid#')";

			oQuery.setsql ( sQueryText );
			// there is no return from the query
			oQuery.execute();
			// get the key value for the record just inserted
			oQuery.setsql ( 'select seq_splan_Trans.currval from dual' );
			var qRes = oQuery.execute().getresult();

			nSplanTransID = qres.currval[1];

			ndetailcount= 1;
			aAmount[1] = d.amount;
			aCategory[1] = d.tocategory;
			if ( d.TransTypeCode NEQ 'INIT' ) {
				ndetailcount = 2;
				aAmount[2] = -1 * d.amount;
				aCategory[2] = d.fromcategory;
			}

			// save 2 detail records
			for (walker = 1; walker <= ndetailcount; walker += 1 ) {

				sQueryText = "INSERT INTO splan_trans_det(
				splan_trans_det_id,
				splan_trans_id,
				splan_cat_id,
				amount,
				create_user,
				update_user

				) VALUES (

				SEQ_SPLAN_TRANS_DET.nextval,
				#nSplanTransID#,
				#aCategory[walker]#,
				#aAmount[walker]#,
				'#session.userid#',
				'#session.userid#')";

				oQuery.setsql ( sQueryText );

				// there is no return from the query
				oQuery.execute();

				// get the key value for the record just inserted
				oQuery.setsql ( 'select seq_splan_trans_det.currval from dual' );

				oQuery.execute();

			} // two detail records
			application.outility.insertSystemAudit ( description="Spend Plan Transaction Created #d.PY#-#nSplanTransID#", userID=session.userID );

			tRet.sMessage = nSplanTransID;
			tRet.status = true;

		} // add

		else {
			tRet.slErrorMessages = "In SplanSaveDetails, actionmode should be add or edit ... is now: #d.actionmode#";
			tRet.status = false;

		} // error

	} // passed all the edits

	return tRet;

} // saveSplanDetails

/**
* @hint I get a list of spend plans details
* @PY Program Year
* @splanTransIdList List of splan_trans_ids to include
* @splanCatIdList List of splan_cat_ids to include
* @startDate minimum trans_date to include
* @endDate maximum trans_date to include
* @transStatusTypeCode	to include
* @transStatusCode	to include
*/

public struct function getSplanDetails (
	numeric PY,
	string splanTransIdList,
	string splanCatIdList,
	date startDate,
	date endDate,
	string transStatusTypeCode,
	string transStatusCode
	)
{

	var tRet = {};
	var aRet = [];
	var oQuery = new query();

	var sQueryText = 'SELECT
	spt.splan_trans_id AS splantransid,
	spt.py ,
	spt.trans_date AS transdate,
	spt.trans_desc AS transdesc,
	spt.trans_note AS transnote,
	spt.trans_status_code AS transstatuscode,
	spt.trans_type_code AS transtypecode,
	sptd.splan_trans_det_id AS splantransdetid,
	sptd.splan_cat_id AS splancatid,
	scml.splan_cat_desc AS splancatdesc,
	sptd.amount,
	spt.create_user AS createuser,
	spt.create_date AS createdate,
	spt.update_user AS updateuser,
	spt.update_date AS updatedate ' ;

	sQueryText &= ' FROM
	splan_trans spt,
	splan_trans_det sptd,
	splan_cat_master_list scml ';

	//  (+) allows there to be no sptd for the spt
	sQueryText &= ' WHERE
	spt.splan_trans_id = sptd.splan_trans_id (+)
	AND sptd.splan_cat_id = scml.splan_cat_id
	AND sptd.splan_cat_id = scml.splan_cat_id
	' ;

	if (structKeyExists ( arguments, "PY" ) and arguments.PY NEQ 0) {
		sQueryText &= ' AND spt.PY = ' & arguments.PY;
	}

	if (structKeyExists ( arguments, "splanCatIdList" )) {
		sQueryText &= " AND  sptd.splan_cat_id IN ( " & arguments.splanTransIdList & " )" ;
	}

	if (structKeyExists ( arguments, "startDate" )) {
		sQueryText &= " AND  spt.trans_date >= TO_DATE('#dateformat(arguments.startDate,'mm/dd/yyyy')#', 'mm/dd/yyyy')";
	}

	if (structKeyExists ( arguments, "endDate" )) {
		sQueryText &= " AND  spt.trans_date <= TO_DATE('#dateformat(arguments.endDate,'mm/dd/yyyy')#', 'mm/dd/yyyy')";
	}

	if (structKeyExists ( arguments, "transTypeCode" )) {
		sQueryText &= " AND  spt.trans_Type_Code = '" & arguments.transTypeCode & "' ";
	}

	if (structKeyExists ( arguments, "transStatusCode" )) {
		sQueryText &= " AND  spt.trans_Status_Code = '" & arguments.transStatusCode & "' ";
	}

	if (structKeyExists ( arguments, "splanTransIdList" )) {
		sQueryText &= " AND  spt.splan_trans_id IN ( " & arguments.splanTransIdList & " )" ;
	}

	//sQueryText &= ' ORDER BY  spt.py,splan_trans_id, sptd.splan_trans_det_id ';
	// put the FROM first
	sQueryText &= ' ORDER BY  spt.py, spt.splan_trans_id, sptd.amount desc ';


//writedump (var="#sQueryText#");
//writedump (var="#arguments#");
//abort;

	oQuery.setsql ( sQueryText );

	var qRes = oQuery.execute().getresult();

	// build the list of splan_trans_det_id for convenience of caller
	tRet.slsplantransdetid = valuelist(qRes.splantransdetid);
	tRet.aRet = QuerytoArrayofStructures(qRes);
	tRet.status = true;
	return tRet;

} // getSplanDetails

/**
* @hint I am a front end for getSplanFopSum(), to allow selection of fops that match a heading-level category
* I am called from the Transactions page (splan_transaction_list), which passes only one item in splanCatIdList
* If the Category is NOT a heading, we just pass through the call to getSplanFopSum()
* If it IS a heading, we get a list of the categories that are hierarchically within the heading category, and pass that list to getSplanFopSum()

*/
public struct function getSplanListFopSum (
	numeric PY,
	numeric fop_num,
	string splanTransIdList,
	string splanCatIdList,
	string splanSectionCodeList,
	date startDate,
	date endDate,
	string transStatusTypeCode,
	string transStatusCode,
	string transTypeCode,
	// these are default values
	string sortBy = 'transdate',
	string sortDir = 'asc',
	boolean dumpargs = false
	)
{

	// 3/24/2015 used in budget/splan_transaction_list to get TRANSACTION LIST data, with FOP SUMMED
	// 3/26/2015 used in reports/report_budget_splan_list_fop_sum to get TRANSACTION LIST data, with FOP SUMMED


	if (arguments.dumpargs) {
		writedump (var="#arguments#" , label = "arguments in getSplanListFopSum");
		abort;
	}


	var formdata = StructNew();

	formdata = duplicate ( arguments );

	if ( structKeyExists ( formdata, "splanCatIdList" )  ) {
		formdata.splanCatIdList = expandCatIdList ( argumentCollection: "#formdata#" ) ;
	}

	return getSplanFopSum( argumentCollection: "#formdata#" );


} // getSplanListFopSum

public struct function getSplanPY ()
{

	var tRet = {};
	var oQuery = new query();

	var sQueryText = "SELECT MAX(year) PY FROM BATCH_PROCESS_LOG WHERE PROCESS_TYPE = 'SPLAN' AND STATUS = 1";

	oQuery.setsql ( sQueryText );
	var qRes = oQuery.execute().getresult();

	tRet.aRet = QuerytoArrayofStructures(qRes);
	tRet.status = true;
	return tRet;

} // getSplanPY

public struct function getLuCodes ( string codetype )
{

	var tRet = {};
	var aRet = [];
	var oQuery = new query();

	var sQueryText = "SELECT code_id codeId, code_type codetype, code, code_desc codedesc, note FROM lu_code WHERE code_type = '" & arguments.codetype & "' " ;

	oQuery.setsql ( sQueryText );
	var qRes = oQuery.execute().getresult();

	tRet.aRet = QuerytoArrayofStructures(qRes);
	tRet.status = true;
	return tRet;

} // getSplanPY


/**
* @hint I get a list of children for each record in splan_cat_master_list mentioned in aTopSplanCode
* @aTopSplanCode is an array that includes the splan_cat_id for each parent for which we want the children
*/
public struct function getTopSplanChildren ( aTop )
{
	var slChildren = '';
	var slToTest = '';
	var tRec = {};
	var nParentID = 0;
	var aRet = [];
	var aRetIP = 0;
	var tRet = {};
	var nToTestIP = 0;

	for (var walker = 1; walker LE ArrayLen (arguments.aTop); walker += 1) {

		nParentID = arguments.aTop [ walker ] . splancatid;

		slToTest = "#nParentID#";
		nToTestIP = 0;

		// Start a new list of children for nParentID. Include the parent in the list of its children
		slchildren = "#nParentID#";

		// infinite loop over slToTest
		for (wx = 1; wx < 10000; w2 += 1) {

			nToTestIP += 1;
			if ( nToTestIP GT ListLen( slToTest) ) {
				// all done with this parent
				break;
			}

			ntryParentID = ListGetAt ( slToTest, nToTestIP );

			// get the direct children of ntryParentID

			for (var w2 = 1; w2 LE ArrayLen (arguments.aTop); w2 += 1) {

				if ( arguments.aTop [ w2 ].SPLAN_CAT_PARENT_ID EQ ntryParentID ) {
					// found a child
					sTryCatID = "#arguments.aTop [ w2 ].splancatid#";
					slChildren = ListAppendNoDups ( slChildren, sTryCatID );
					slToTest = ListAppendNoDups ( slToTest, sTryCatID );
				}

			} // loop over direct children

		} // infinite loop

		// add record to aRet for this parent
		tRec.splancatid = nParentID;
		tRec.splanCatIdList = ListSort ( slChildren, 'numeric' );
		aRetIP +=1;
		aRet [aRetIP] = duplicate ( tRec );

	} // loop for each aTop

	// don't sort this.  It is in order by the row labels on the report.
	tRet.aRet = duplicate (aRet);
	return tRet;

} // getTopSplanChildren

/**
* @hint I get the splancatid for NATIONAL HQ CONTRACTS. Any heading file under that is a "SubHeading"
*/
public struct function getSplanNationalHQ ( PY ) {
	var tRet = {};
	var aRet = [];
	var oQuery = new query();

	var sQueryText = "select splan_cat_id AS splancatid from splan_cat_master_list where SUBSTR( splan_cat_desc, 1, 21) = 'NATIONAL HQ CONTRACTS' " ;

	oQuery.setsql ( sQueryText );
	var qRes = oQuery.execute().getresult();

	tRet.aRet = QuerytoArrayofStructures(qRes);
	tRet.status = true;
	return tRet;

} //getSplanNationalHQ

/**
* @hint I get the splandet records for this splancat, PY, and distribute the numbers across the date columns
*/
public struct function getSplanDetNumbers ( PY, aTop, aTopChildren, tHeadings ) {
	var tRet = {};
	var aRet = [];
	var oQuery = new query();

	// get all the relevant splandetrecords, for PY, splancatid
	// set up the initial parameters

	var nqrows = 0;
	var ncols = ArrayLen ( tHeadings.aHeadings );
	var icolLabel = 1;
	var icolInit = 2;
	var icolCurrentSP = ncols - 2;
	var icolCumulativeFop = ncols - 1;
	var icolVariance = ncols;
	var aDateBreak = duplicate ( arguments.tHeadings.aDateBreak );
	var throughDate = arguments.tHeadings.endDate;
	var throughDateP1 = DateAdd ( "d", 1, DateFormat(ThroughDate, "mm/dd/yyyy"));
	var nBreaks = arrayLen( aDateBreak );
	var aDateTotal = ArrayNew (1);

	for (var iDateptr = 1; iDatePtr LE ncols; iDatePtr += 1) {
		aDateTotal [ iDatePtr ] = '&nbsp;';
	}


	// get ALL records for this PY and splan_cat_id

	var sQueryText = 'SELECT
	spt.splan_trans_id AS splantransid,
	spt.trans_type_code AS transtypecode,
	spt.trans_date AS transdate,
	spd.splan_trans_det_id AS splantransdetid,
	spd.amount AS spdamount ' ;

	sQueryText &= ' FROM
	splan_trans spt,
	splan_trans_det spd
	 ';

	// AND (spt.trans_type_code = 'INIT' OR spt.trans_date <= TO_DATE('#dateformat(throughDateP1,'mm/dd/yyyy')#',

	sQueryText &= " WHERE
	spt.PY = " & arguments.PY & "
	AND spt.splan_trans_id = spd.splan_trans_id
	AND spd.splan_cat_id = " & arguments.aTop.splancatid & "
	AND spt.trans_date <= TO_DATE('#dateformat(throughDateP1,'mm/dd/yyyy')#', 'mm/dd/yyyy')"
	;

	oQuery.setsql ( sQueryText );
	var qRes = oQuery.execute().getresult();
	var aQ = QuerytoArrayofStructures( qRes );
	nqrows = arrayLen( aQ );

	//writedump(var="#qres#", label='qres');
	//abort;
	// allocate the amounts
	for ( var iqrow = 1; iqrow LE nqrows ; iqrow += 1) {

		// the total will reflect ALL the amounts
		aDateTotal [ icolCurrentSP ] = AddPreserveBlanks ( aDateTotal [ icolCurrentSP ] , aQ [iqrow].spdamount );

		if ( aQ [iqrow].transtypecode EQ 'INIT') {
			aDateTotal [ icolInit ] = AddPreserveBlanks ( aDateTotal [ icolInit ]  , aQ [iqrow].spdamount );
		}
		else {
			// allocate to ONE of the intermediate columns
			for ( var ibreak = 1; ibreak LE nBreaks ; ibreak += 1) {

				// loop over the dates within this column date
				if ( aQ [iqrow].transdate LE aDateBreak [ ibreak ] ) {
					// there IS a record for this column
					// leaving room for the "INIT" total
					aDateTotal [ icolInit + ibreak ] =  AddPreserveBlanks ( aDateTotal [ icolInit + ibreak ], aQ [iqrow].spdamount );
					// "break", so we don't keep allocating
					break;
				}

			} // nBreaks
		}
	}

	tRet.aDateTotal = duplicate ( aDateTotal );

	return tRet;

} // getSplanDetNumbers


/**
* @hint I get the appropriation for the spend plan
* @fundcat is like 'OPS'
* @PY is the program year
*/
public struct function getSplanAppropriationNumber ( required fundcat, required PY ) {
	var tRet = {};
	var aRet = [];
	var oQuery = new query();
	var sQueryText = '';

	sQueryText = "
		SELECT amount
		FROM appropriation
		WHERE FUND_CAT = '#arguments.fundcat#'
		  AND PY = #arguments.PY#
		";

	oQuery.setsql ( sQueryText );
	var qRes = oQuery.execute().getresult();

	tRet.aRet = QuerytoArrayofStructures( qRes );

	return tRet;

} // getSplanAppropriationNumber


/**
* @hint I get the values for the SOP column for the spend plan
* @splanCatID is the one for the row on the report
* @splanCatIdList is the list of the all the child splanCatIDs for this row
* @splanSectionCode is the section code for this row in the report
*/
public struct function getSplanReserveNumber ( summarycode, PY, dStartDate, dEndDate ) {

	var tRet = {};
	var aRet = [];
	var oQuery = new query();
	var sQueryText = '';
	var sPYPhrase = '';
	var sStartDatePhrase = '';
	var sEndDatePhrase = '';
	var dEndDateP1 = '';


	if ( structKeyExists (arguments, 'PY') AND arguments.PY NEQ '' AND arguments.PY NEQ 0 ) {
		nPY = arguments.PY;
	}
	else {
		// caller can pass in PY = 0 to get current PY
		var tPY = getSplanPY();
		nPY = tPY.aRet[1].PY;
	}

	sPYPhrase = " AND fop.py = #nPY#" ;

	if ( structKeyExists (arguments, 'dStartDate') AND arguments.dStartDate NEQ '') {
		sStartDatePhrase = " AND TRUNC(fop.date_executed) >= TO_DATE('#dateformat(arguments.dStartDate,'mm/dd/yyyy')#', 'mm/dd/yyyy')";
	}

	if ( structKeyExists (arguments, 'dEndDate') AND arguments.dEndDate NEQ '') {
		// adjust by one day
		dEndDateP1 =  DateAdd ( "d", 1, DateFormat(arguments.dEndDate, "mm/dd/yyyy"));
		sEndDatePhrase = " AND TRUNC(fop.date_executed) < TO_DATE('#dateformat(dEndDateP1,'mm/dd/yyyy')#', 'mm/dd/yyyy')";
	}

	sQueryText = "
	SELECT  sum(fop.amount) as fopamount
	FROM
		fop,
		aapp,
		splan_cat_master_list,
		LU_COST_CAT lcat

	WHERE   fop.aapp_num = aapp.aapp_num and
	        aapp.splan_cat_id = splan_cat_master_list.splan_cat_id
	        AND UPPER (summary_code)  = '#arguments.summarycode#'
			AND fop.COST_CAT_ID = lcat.COST_CAT_ID
			AND lcat.FUND_CAT = 'OPS'
	        #sPYPhrase#
	        #sStartDatePhrase#
	        #sEndDatePhrase#
			 " ;

//writedump ( var="getSplanReserveNumber sQueryText #sQueryText#", label="sQueryText" );
//abort;

	oQuery.setsql ( sQueryText );
	var qRes = oQuery.execute().getresult();

	tRet.aRet = QuerytoArrayofStructures( qRes );

	return tRet;

} // getSplanReserveNumber

/**
* @hint I get the values for the FOP column for the spend plan
* @PY is the PY for the report
* @tOneTopCode is one item of aTopCodes, for this row
* @tOneTopChildren is one item of aTopChildren, for this row
* @dEndDate is the throughDate for the report
*/
public struct function getSplanFopNumbers ( PY, tOneTopCode, tOneTopChildren, dEndDate ) {

	// Construction (CRA) FOPs (B1) - have a cost category of 2.
	// A fail safe way of determining which FOPs are OPS, and which are CRA is to use FOP.cost_cat_id,
	// join to LU_COST_CAT.cost_cat_id, and use the FUND_CAT field. (FUND_CAT = 'OPS').

	var tRet = {};
	var aRet = [];
	var splancatid = tOneTopCode.splancatid;
	var splanCatIdList = tOneTopChildren.splanCatIdList;
	var splanSectionCode = tOneTopCode.splanSectionCode;
	var costcatid = tOneTopCode.costcatid;
	var oQuery = new query();
	var sQueryText = '';
	// adjust by one day
	var dEndDateP1 =  DateAdd ( "d", 1, DateFormat(arguments.dEndDate, "mm/dd/yyyy"));

	if ( splanSectionCode EQ 'CTR' ) {
		sQueryText = "SELECT SUM(f.AMOUNT) as fopsum
			FROM
			FOP f ,
			LU_FUNDING_OFFICE fo

			WHERE f.PY = #PY#
			AND TRUNC(f.date_executed) < TO_DATE('#dateformat(dEndDateP1,'mm/dd/yyyy')#', 'mm/dd/yyyy')

			AND fo.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
			AND fo.OFFICE_TYPE = 'DOL'
			AND f.COST_CAT_ID = #costcatid#" ;
	}

	else if ( splanSectionCode EQ 'FED' ) {

		sQueryText = "SELECT SUM(f.AMOUNT) as fopsum
			FROM
			FOP f ,
			LU_FUNDING_OFFICE fo,
			LU_COST_CAT lcat

			WHERE f.PY = #PY#
			AND TRUNC(f.date_executed) < TO_DATE('#dateformat(dEndDateP1,'mm/dd/yyyy')#', 'mm/dd/yyyy')

			AND fo.FUNDING_OFFICE_NUM = f.FUNDING_OFFICE_NUM
			AND fo.OFFICE_TYPE = 'FED'

			AND f.COST_CAT_ID = lcat.COST_CAT_ID
			AND lcat.FUND_CAT = 'OPS'";


			;
	}

	else if ( splanSectionCode EQ 'HQC' ) {

		sQueryText = "SELECT SUM(f.AMOUNT) as fopsum
			FROM FOP f,
			LU_COST_CAT lcat

			WHERE f.PY = #PY#
			AND TRUNC(f.date_executed) < TO_DATE('#dateformat(dEndDateP1,'mm/dd/yyyy')#', 'mm/dd/yyyy')

			AND f.COST_CAT_ID = lcat.COST_CAT_ID
			AND lcat.FUND_CAT = 'OPS'

			AND f.AAPP_NUM IN (SELECT aa.AAPP_NUM
				FROM AAPP aa
				WHERE aa.SPLAN_CAT_ID = #splancatid#)" ;

	} // end of cases of splanSectionCode

	if ( sQueryText NEQ '' ) {
		oQuery.setsql ( sQueryText );
		var qRes = oQuery.execute().getresult();

		tRet.aRet = QuerytoArrayofStructures( qRes );
	}
	else {
		tRet.aRet = ArrayNew(1);
	}
	return tRet;

} // getSplanFopNums


/**
* @hint I run a query to get all the splan_cat records hierarchically including and below a particular category
* @PY limits the search to splan_cat's active in the PY
* @splanSectionCode limits the search to splan_cat's in splanSectionCode
*/
public struct function getTopSplanCodes ( PY, splanSectionCodeList, StartParentID )
{

	var tRet = {};
	var tTemp = {};
	var aRet = [];
	var aRetx = [];
	var oQuery = new query();
	var sQueryText = '';
	// these are defaults for -all-
	var sSectionFilterList = 'all';
	var nStartParentId = 0;
	var nPY = 0;

	if ( IsDefined("arguments.splanSectionCodeList") AND arguments.splanSectionCodeList neq "all") {

		// this is just a validation check that the splanSectionCodeList contains only valid codes

		var sQuotedList = application.outility.buildQuotedValueList(arguments.splanSectionCodeList,"Alpha");
		// remove the leading and trailing (), and replace with ""

		sQueryText = "select code, code_desc AS codedesc from lu_code where code IN " & sQuotedList;

		oQuery.setsql ( sQueryText );
		var qRes = oQuery.execute().getresult();
		sSectionFilterList = valuelist (qRes.code);
		if (listlen( sSectionFilterList ) NEQ listlen ( arguments.splanSectionCodeList ) ) {
			throw( message ="Invalid value in getTopSplanCodes: arguments.splanSectionCodeList = #arguments.splanSectionCodeList#");
		}
	}

	if ( IsDefined("arguments.PY") AND isNumeric(arguments.PY)) {
		nPY = arguments.PY;
	}

	if ( IsDefined("arguments.StartParentID") AND isNumeric(arguments.StartParentID)) {

		nStartParentID = arguments.StartParentID;
	}
	if ( ListLen( sSectionFilterList ) EQ 1 ) {
		// make simple call to sp
		spService = new storedproc();
		if ( FindNoCase ( 'jfas_don', application.paths.root ) NEQ 0 ) {
			//for disconnect in development
			spService.setProcedure ( "SPLAN_PKG_DON.sp_getTopSplanCodes" );
		}
		else {
			spService.setProcedure ( "SPLAN_PKG.sp_getTopSplanCodes" );
		}


			spService.setProcedure ( "SPLAN_PKG.sp_getTopSplanCodes" );

		spService.addParam ( dbvarname = "argsplanSectionCodeList", cfsqltype="cf_sql_varchar", type = "in", value = sSectionFilterList );
		spService.addParam ( dbvarname = "argPY", cfsqltype="cf_sql_numeric", type = "in", value = nPY );
		spService.addParam ( dbvarname = "argStartParentId", cfsqltype="cf_sql_numeric", type = "in", value = nStartParentID );

		spService.addProcResult( name="qRes", resultset = 1);
		qTemp = spService.execute();
		aRetx = QuerytoArrayofStructures(qTemp.getProcResultSets().qRes);

	}
	else {
		// get all the codes, then eliminate the ones that are not on the list
		spService = new storedproc();
		spService.setProcedure ( "SPLAN_PKG.sp_getTopSplanCodes" );
		spService.addParam ( dbvarname = "argsplanSectionCodeList", cfsqltype="cf_sql_varchar", type = "in", value = 'all' );
		spService.addParam ( dbvarname = "argPY", cfsqltype="cf_sql_numeric", type = "in", value = nPY );
		spService.addParam ( dbvarname = "argStartParentId", cfsqltype="cf_sql_numeric", type = "in", value = nStartParentID );

		spService.addProcResult( name="qRes", resultset = 1);
		qTemp = spService.execute();
		aRetx = QuerytoArrayofStructures(qTemp.getProcResultSets().qRes);
	}

	// make adjustments for subcategory and for sSectionFilterList GT 1 element
	// writedump (var="#aRetx#" label="aRetx");

	IP = 0;
	for (var walker = 1; walker LE ArrayLen( aRetx ); walker += 1) {
		if ( ListLen (sSectionFilterList ) GT 1 AND ListFindNoCase ( sSectionFilterList, aRetx [ walker] .splansectioncode ) EQ 0) {
			continue;

		}
		aRetx [ walker] .splancatdesc = TRIM (aRetx [ walker] .splancatdesc) ;
		if ( ListFindNoCase ( 'CENTERS,USDA,CATEGORY USDA', aRetx [ walker ] .splancatdesc) NEQ 0) {
			// skip this record, because splansectioncode is not on the list of desired codes, or it is a higher "category" record
			//writedump (var="skipping " & aRetx [ walker ] .splancatdesc);
			continue;
		}

		if ( FindNoCase ( 'SUBCATEGORY', aRetx [ walker ] .splancatdesc ) NEQ 0 ) {
			// adjust - we want what is after SUBCATEGORY
			//writedump (var="adjusting " & aRetx [ walker ] .splancatdesc & ' ' & len(aRetx [ walker ] .splancatdesc));
			kp = FindNoCase ( 'SUBCATEGORY', aRetx [ walker ] .splancatdesc );
			aRetx [ walker ] . level = 1;
			aRetx [ walker ] . hierarchylevel = 1;
			aRetx [ walker ] . splan_cat_parent_ID = 0;
			aRetx [ walker ] . splancatdesc = mid ( aRetx [ walker ] . splancatdesc, kp + 12, Len(aRetx [ walker ] . splancatdesc) - kp - 11) ;
			// no prefix
			aRetx [ walker ] . splancatdescwithprefix = aRetx [ walker ] . splancatdesc;
		}
		else if ( FindNoCase ( 'CATEGORY', aRetx [ walker ] .splancatdesc ) NEQ 0 ) {
			// adjust - we want what is after CATEGORY
			kp = FindNoCase ( 'CATEGORY', aRetx [ walker ] .splancatdesc );
			//writedump (var="adjusting " & aRetx [ walker ] .splancatdesc & ' ' & len(aRetx [ walker ] .splancatdesc));
			aRetx [ walker ] . level = 1;
			aRetx [ walker ] . hierarchylevel = 1;
			aRetx [ walker ] . splan_cat_parent_ID = 0;
			aRetx [ walker ] . splancatdesc = mid ( aRetx [ walker ] . splancatdesc, kp + 9, Len(aRetx [ walker ] . splancatdesc) - kp - 8) ;
			// no prefix
			aRetx [ walker ] . splancatdescwithprefix = aRetx [ walker ] . splancatdesc;
		}

		// copy the adjusted record
		IP += 1;
		aRet [ IP ] = duplicate ( aRetx [ walker ] );
	}

	tRet.aRet = duplicate ( aRet );
	tRet.status = true;

	return tRet;

} //getTopSplanCodes

public struct function BuildCatNoteStruct () {
	// build a structure reflecting the category notes

	var tRet = {};
	var aRet = [];
	var oQuery = new query();

	var sQueryText = 'select splan_cat_ID AS splancatid, splan_Cat_Note as splancatnote
	FROM splan_cat_master_list
	ORDER BY splan_cat_ID';

	oQuery.setsql ( sQueryText );

	var qRes = oQuery.execute().getresult();

	// make each splancatid point directly to the note
	aRet = QuerytoArrayofStructures(qRes);

	for ( var walker = 1; walker LE arrayLen ( aRet ); walker += 1) {
		structInsert ( tRet, aRet[walker].splancatid, aRet[walker].splancatnote, 1);
	}

	return tRet;

} // BuildCatNoteStruct

public struct function saveSplanDisplaySettings ( formData ) {
	var tret = {};
	var d = {};
	var aRet = [];
	var sQueryText = '';
	var oQuery = new query();
	var nsplantransid = 0;
	var walker = 0;
	var outwalker = 1;
	var aDates = [];
	var previousDate = '';
	tRet.slErrorMessages = '';
	tRet.slErrorFields = '';
	tRet.sMessage = '';
	tRet.status = true;

//writedump (var="#formdata#", label="formdata");

	d.py = arguments.formData.py;
	d.radspendingbreakdown = arguments.formData.radspendingbreakdown;
	d.todate = arguments.formData.todate;
	d.radSaveSettings = arguments.formData.radSaveSettings;
	d.customdate = arrayNew(1);
	for ( walker = 1; walker LE 14; walker += 1) {
		d.customdate[walker] = '';
	}
	// date 1 is different, for historical reasons
	d.customdate[1] = formData.customdate[1];

	// remove any blank spaces in the dates
	for ( walker = 1; walker LE 14; walker += 1) {
		if (IsDefined ("formData.customdate_#walker#") ) {
			tmp = Evaluate("formData.customdate_#walker#");
			if (tmp NEQ '' ) {
				outwalker += 1;

				//writedump(var='writing #dateformat(tmp, "mm/dd/yyyy")# to #outwalker# --- ');
				d.customdate[outwalker] = dateformat(tmp, "mm/dd/yyyy");
			}
		}
	}

	// ensure the dates are in order
	previousDate = d.customdate[1];

	for ( walker = 2; walker LE 14; walker += 1) {
		if (d.customdate[walker] eq '') {
			break;
		}
		if ( DateCompare ("#previousDate#", "#d.customdate[walker]#" , "d" ) GE 0 ) {
			tRet.slErrorMessages = "Custom dates must be in order, and not duplicated";
			tRet.status = false;
			// don't save, tell the user
			break;
		}
		// move the pointer to the next "previous date"
		previousDate = d.customdate[walker];
	}
	if ( tRet.status ) {
		// passed all the edits
		// update session.userPreferences.tMySplanNow
		session.userpreferences.tmysplannow = '';
		session.userpreferences.tmysplannow = duplicate ( d );
//writedump (var = "#session.userpreferences.tmysplannow#", label = "session.userpreferences.tmysplannow in savesettings");
//abort;
		if ( arguments.formData.radSaveSettings EQ 2 ) {
			session.ouser.WriteMySplanDisplaySetting( session.userid, "PERM" );
		}
		else {
			// user doesn't want to save setting for login. Delete any left over PERM setting
			session.ouser.DeleteMySplanDisplaySetting( session.userid, "PERM" );
		}
	}
	return tRet;

} // saveSplanDisplaySettings

/**
* @hint I get a list of spend plans details WITHOUT SUM of FOP.amount
* @PY = Program Year
* @fop_num = Fop number to include
* @splanTransIdList = List of splan_trans_ids to include
* @splanTransDetIdList = List of splan_trans_det_ids to include
* @splanCatIdList = List of splan_cat_ids to include
* @splanSectionCodeList = List of splan_section_codes to include
* @startDate = minimum trans_date to include
* @endDate = maximum trans_date to include
* @transStatusTypeCode	= to include
* @transStatusCode	= to include
* @sortBy = column for sorting
* @sortDir = direction for sorting
*/
public struct function getSplanListFopDetails (
	numeric PY,
	numeric fop_num,
	string splanTransIdList,
	string splanCatIdList,
	string splanSectionCodeList,
	date startDate,
	date endDate,
	string transStatusTypeCode,
	string transStatusCode,
	string sortBy = 'fopnum',
	string sortDir = 'asc'
	)
{

	// 02/11/2015 used in splan_edit.cfm to display a few splan_dets
	// 04/02/2015 used in reports\report_budget_splan_list_fop_detail.cfm

	var tRet = {};
	var aRet = [];
	var oQuery = new query();
	var banymatch = false;
	var sFopField = '';

	var aSortMap =
	[
		{sortkey = 'transdate',
			firstField = 'spt.trans_date',
			otherFields = ' spt.splan_trans_id, spt.trans_desc, scml.splan_cat_desc ' }
		,{sortkey = 'splantransid',
			firstField = 'spt.splan_trans_id',
			otherFields = ' spt.py, sptd.splan_trans_det_id, fop.fop_num'}
		,{sortkey = 'transdesc',
			firstField = 'spt.trans_desc',
			otherFields = ' spt.py, spt.splan_trans_id, sptd.splan_trans_det_id, fop.fop_num'}
		,{sortkey = 'splancatdesc',
			firstField = 'scml.splan_cat_desc',
			otherFields = ' spt.py, spt.splan_trans_id, sptd.splan_trans_det_id, fop.fop_num'}
		,{sortkey = 'amount',
			firstField = 'sptd.amount',
			otherFields = 'spt.py, spt.splan_trans_id, sptd.splan_trans_det_id, fop.fop_num'}
		,{sortkey = 'fopamount',
			firstField = 'fop.amount',
			otherFields = ' spt.py, spt.splan_trans_id, sptd.splan_trans_det_id, fop.fop_num'}
		,{sortkey = 'transstatuscode',
			firstField = 'spt.trans_status_code ',
			otherFields = ' spt.py, spt.splan_trans_id, sptd.splan_trans_det_id, fop.fop_num'}
		,{sortkey = 'fopnum',
			firstField = 'spt.py ',
			otherFields = ' fop.fop_num, fop.aapp_num'}

	] ;
	var sTrySortKey = Trim(LCase(arguments.SortBy));
	for ( var sortWalker = 1; sortWalker LE arrayLen ( aSortMap); sortWalker += 1 ) {

		if ( aSortMap[sortWalker].sortkey EQ sTrySortKey ) {
			bAnyMatch = true;
			break;
		}
	}

	if ( NOT bAnyMatch ) {
			tRet.status = false;
			tRet.sErrorMessage = "Undefined sort field " & arguments.SortBy;
			return tRet;

	}

	//  (+) allows there to be no fop for the splan_trans_det
	// do not know what to do with this  aapp_program_activity (a.aapp_num, 'S') AS program_activity_short,

	var sQueryText = "
	SELECT
	spt.py,
	spt.splan_trans_id AS splantransid,
	spt.trans_date AS transdate,
	spt.trans_desc AS transdesc,
	spt.trans_status_code AS transstatuscode,
	luc.code_desc AS transstatusdesc,
	spt.trans_type_code AS transtypecode,
	sptd.splan_trans_det_id AS splantransdetid,
	sptd.splan_cat_id AS splancatid,
	scml.splan_cat_desc AS splancatdesc,
	scml.splan_section_code AS splansectioncode,
	sptd.amount AS amount,
	fop.cost_cat_id AS costcatid,
	fop.fop_num AS fopnum,
	fop.fop_description AS fopdescription,
	fop.amount AS fopamount,
	fop.date_executed AS fopdateexecuted,
	fop.aapp_num AS fopaapp,

	c.center_name AS centername,
	a.venue AS venue,
	lo.funding_office_desc AS fundingofficedesc,
	ct.contractor_name AS contractorname,
	a.contract_num AS contractnum,
	CASE WHEN fop.arra_ind = 1 THEN 'Y' ELSE '' END AS arra,
	aapp_program_activity (a.aapp_num, 'S') AS program_activity_short


	FROM
	splan_trans spt,
	splan_trans_det sptd,
	splan_cat_master_list scml,
	fop,
	lu_code luc,

	aapp a,
	center c,
	contractor ct,
	lu_funding_office lo


	WHERE
	spt.splan_trans_id = sptd.splan_trans_id
	AND sptd.splan_cat_id = scml.splan_cat_id
	AND sptd.splan_trans_det_id = fop.splan_trans_det_id (+)
	AND spt.trans_status_code = luc.code
	AND luc.code_type = 'TRANS_STATUS_CODE'

	AND fop.aapp_num = a.aapp_num
	AND a.center_id = c.center_id(+)
	AND a.contractor_id = ct.contractor_id(+)
	AND fop.funding_office_num = lo.funding_office_num
	" ;

	if (structKeyExists ( arguments, "PY" ) AND arguments.PY NEQ '') {
		sQueryText &= ' AND spt.PY = ' & arguments.PY;
	}
	if (structKeyExists ( arguments, "splanCatIdList" )  AND arguments.splanCatIdList NEQ '' ) {
		sQueryText &= " AND  sptd.splan_cat_id  IN  " & application.outility.buildQuotedValueList(arguments.splanCatIdList,"Numeric") & " " ;
	}

	if (structKeyExists ( arguments, "startDate" ) AND arguments.startDate NEQ '' ) {
		sQueryText &= " AND  spt.trans_date >= TO_DATE('#dateformat(arguments.startDate,'mm/dd/yyyy')#', 'mm/dd/yyyy')";
	}

	if (structKeyExists ( arguments, "endDate" ) AND arguments.endDate NEQ '' ) {
		sQueryText &= " AND  spt.trans_date <= TO_DATE('#dateformat(arguments.endDate,'mm/dd/yyyy')#', 'mm/dd/yyyy')";
	}

	if (structKeyExists ( arguments, "transTypeCode" )  AND arguments.transTypeCode NEQ '' ) {
		sQueryText &= " AND  spt.trans_Type_Code = '" & arguments.transTypeCode & "' ";
	}

	if (structKeyExists ( arguments, "transStatusCode" )  AND arguments.transStatusCode NEQ '' ) {
		sQueryText &= " AND  spt.trans_Status_Code = '" & arguments.transStatusCode & "' ";
	}

	if (structKeyExists ( arguments, "splanTransDetIdList" )  AND arguments.splanTransDetIdList NEQ '' ) {
		sQueryText &= " AND  sptd.splan_trans_det_id IN  " & application.outility.buildQuotedValueList(arguments.splanTransDetIdList,"Numeric") & " " ;
	}

	if (structKeyExists ( arguments, "splanTransIdList" )  AND arguments.splanTransIdList NEQ '' ) {
		sQueryText &= " AND  spt.splan_trans_id IN  " & application.outility.buildQuotedValueList(arguments.splanTransIdList,"Numeric") & " " ;
	}

	if (structKeyExists ( arguments, "splanSectionCodeList" )  AND arguments.splanSectionCodeList NEQ '' ) {
		sQueryText &= " AND  scml.splan_section_code IN  " &  application.outility.buildQuotedValueList(arguments.splansectionCodeList,"Alpha") ;
	}

	sQueryText &= ' ORDER BY ' & aSortMap[sortWalker].firstField & ' ' & arguments.sortdir & ',' & aSortMap[sortWalker].otherfields ;

	//IF ( splanCatIdList eq '5') {
	//	writedump(var="#sQueryText#");
	//	abort;
	//}

	oQuery.setsql ( sQueryText );

	var qRes = oQuery.execute().getresult();

	tRet.aRet = QuerytoArrayofStructures(qRes);
	tRet.status = true;
	return tRet;

} // getSplanListFopDetails



/*********  PRIVATE ROUTINES *******/

private function AddPreserveBlanks ( a, b ) {

	if ( a EQ '&nbsp;' ) {
		if ( b EQ '&nbsp;' ) {
			return '&nbsp;' ;
		}
		else {
			return b;
		}
	}
	else {
		if ( b EQ '&nbsp;' ) {
			return a;
		}
		else {
			return a + b;
		}
	}
} // AddPreserveBlanks

private function ListAppendNoDups ( slList, sTry ) {

	var slRet = slList;
	if (ListContainsNoCase ( slList, sTry ) EQ 0 ) {

		slRet = ListAppend ( slList, sTry );

	}
	return slRet;
} // ListAppendNoDups


private function expandCatIdList (
	numeric PY=0,
	numeric fop_num,
	string splanTransIdList,
	string splanCatIdList,
	string splanSectionCodeList,
	date startDate,
	date endDate,
	string transStatusTypeCode,
	string transStatusCode,
	string sortBy = 'transdate',
	string sortDir = 'asc'
 	)
 {

	var oQuery = new query();
	var qRes = '';
	var sRet = '';
	var sQueryText = '';
	var tTopCodes = {};
	var aTopCodes = [];
	var walker = 0;
	var walkerparent = 0;
	var bIsParent = false;

	sRet = arguments.splanCatIdList;

	// get ALL the code for this year, or any year
	tTopCodes = getTopSplanCodes( PY=arguments.PY );
	aTopCodes = tTopCodes.aRet;
//writedump (var="#aTopCodes#", label = "ALL aTopCodes in Expand");
//abort;
	// see if the code is NOT the lowest in the path

	for (walker = 1; walker LE arrayLen ( aTopCodes ); walker += 1 ) {
		// the incoming list is either '', or a single splanCatID
		if ( aTopCodes[walker].splancatid EQ arguments.splanCatIdList ) {
		//writedump("found match");
			// see if this splancatid is a parent
			for (walkerparent = 1; walkerparent LE arrayLen ( aTopCodes ); walkerparent += 1 ) {
				if ( aTopCodes[walkerparent].SPLAN_CAT_PARENT_ID EQ aTopCodes[walker].splancatid ) {
					bIsParent = true;
					break;
				}
			}
			if ( bIsParent ) {
				// this has splancats below it
				// get the list of cats under this
				//writedump (var="PY #arguments.PY# StartParentID #aTopCodes[walker].splancatid# #aTopCodes[walker].path#  ");
				tTopCodes = getTopSplanCodes( PY=arguments.PY, StartParentID = aTopCodes[walker].splancatid );
				aTopCodes = tTopCodes.aRet;
				//writedump(var="#aTopCodes#", label="found match, aTopCodes");
				//abort;
				// build a list of all of these that are transassoc = 1
				sRet = '';
				for ( walker = 1; walker LE arrayLen ( aTopCodes ); walker += 1 ) {
					if (aTopCodes[walker].transassoc EQ 1 ) {
						sRet = ListAppend( sRet, aTopCodes[walker].splancatid );
					}
				}
			} // found a header
			break;
		}

	} // loop



	return sRet;

} // expandCatIdList

/**
* @hint I get a list of spend plans details  WITH SUM of FOP.amount
* @PY = Program Year
* @fop_num = Fop number to include
* @splanTransIdList = List of splan_trans_ids to include
* @splanCatIdList = List of splan_cat_ids to include
* @splanSectionCodeList = List of splan_section_codes to include
* @startDate = minimum trans_date to include
* @endDate = maximum trans_date to include
* @transStatusTypeCode	= to include
* @transStatusCode	= to include
* @sortBy = column for sorting
* @sortDir = direction for sorting
*/
private struct function getSplanFopSum (
	numeric PY,
	numeric fop_num,
	string splanTransIdList,
	string splanCatIdList,
	string splanSectionCodeList,
	date startDate,
	date endDate,
	string transStatusTypeCode,
	string transStatusCode,
	string transTypeCode,
	string sortBy = 'transdate',

	string sortDir = 'asc'
	)
{
	// this is a LOWER LEVEL routine called only from getSplanListFopSum

	var tRet = {};
	var aRet = [];
	var aMain = [];

	var oFopQuery = new query();
	var oQuery = new query();
	var banymatch = false;
	var qResFop = '';

	// get all the requested splan_trans_det records, correctly sorted and aliased ...

	var aSortMap =
	[
		{sortkey = 'transdate',
			firstField = 'spt.trans_date',
			otherFields = ' spt.splan_trans_id, spt.trans_desc, scml.splan_cat_desc ' }
		,{sortkey = 'splantransid',
			firstField = 'spt.splan_trans_id',
			otherFields = ' spt.py, sptd.splan_trans_det_id'}
		,{sortkey = 'transdesc',
			firstField = 'spt.trans_desc',
			otherFields = ' spt.py, spt.splan_trans_id, sptd.splan_trans_det_id'}
		,{sortkey = 'splancatdesc',
			firstField = 'scml.splan_cat_desc',
			otherFields = ' spt.py, spt.splan_trans_id, sptd.splan_trans_det_id'}
		,{sortkey = 'amount',
			firstField = 'sptd.amount',
			otherFields = 'spt.py, spt.splan_trans_id, sptd.splan_trans_det_id'}
		,{sortkey = 'fopamount',
			firstField = 'fopamount',
			otherFields = ' spt.py, spt.splan_trans_id, sptd.splan_trans_det_id'}
		,{sortkey = 'transstatuscode',
			firstField = 'spt.trans_status_code ',
			otherFields = ' spt.py, spt.splan_trans_id, sptd.splan_trans_det_id'}

	] ;

	var sTrySortKey = Trim(LCase(arguments.SortBy));
	for ( var sortWalker = 1; sortWalker LE arrayLen ( aSortMap); sortWalker += 1 ) {

		if ( aSortMap[sortWalker].sortkey EQ sTrySortKey ) {
			bAnyMatch = true;
			break;
		}
	}

	if ( NOT bAnyMatch ) {
			tRet.status = false;
			tRet.sErrorMessage = "Undefined sort field " & arguments.SortBy;
			return tRet;

	}

	// sDetailFieldList is list of all the fields except SUM(fop.amount)
	var sDetailFieldList = 'spt.py,
	spt.splan_trans_id AS splantransid,
	spt.trans_date AS transdate,
	spt.trans_desc AS transdesc,
	spt.trans_status_code AS transstatuscode,
	spt.trans_note AS transnote,
	luc.code_desc AS transstatusdesc,
	spt.trans_type_code AS transtypecode,
	sptd.splan_trans_det_id AS splantransdetid,
	sptd.splan_cat_id AS splancatid,
	scml.cost_cat_id AS costcatid,
	scml.splan_cat_desc AS splancatdesc,
	scml.splan_section_code AS splansectioncode,
	sptd.amount AS amount
	 ' ;

	// sGroupByList is sDetailFieldList, with no aliasing
	var sGroupByList = 'spt.py,
	spt.splan_trans_id,
	spt.trans_date,
	spt.trans_desc,
	spt.trans_status_code,
	spt.trans_note,
	luc.code_desc,
	spt.trans_type_code,
	sptd.splan_trans_det_id,
	sptd.splan_cat_id,
	scml.cost_cat_id,
	scml.splan_cat_desc,
	scml.splan_section_code,
	sptd.amount
	 ' ;

	var sQueryText = 'SELECT ' & sDetailFieldList &
	', SUM(fop.amount) AS fopamount';

	sQueryText &= ' FROM
	splan_trans spt,
	splan_trans_det sptd,
	splan_cat_master_list scml,
	lu_code luc,
	fop';

	//  (+) allows there to be no fop for the splan_trans_det
	sQueryText &= " WHERE
	spt.splan_trans_id = sptd.splan_trans_id
	AND sptd.splan_cat_id = scml.splan_cat_id
	AND spt.trans_status_code = luc.code
	AND luc.code_type = 'TRANS_STATUS_CODE'
	AND sptd.splan_trans_det_id = fop.splan_trans_det_id (+)
	" ;

	// add the conditions
	if (structKeyExists ( arguments, "PY" ) AND arguments.PY NEQ 0) {
		sQueryText &= ' AND spt.PY = ' & arguments.PY;
	}
	if (structKeyExists ( arguments, "splanCatIdList" )  AND arguments.splanCatIdList NEQ '' ) {
		sQueryText &= " AND  sptd.splan_cat_id  IN  " & application.outility.buildQuotedValueList(arguments.splanCatIdList,"Numeric") & " " ;
	}

	if (structKeyExists ( arguments, "startDate" ) AND arguments.startDate NEQ '' ) {
		sQueryText &= " AND  spt.trans_date >= TO_DATE('#dateformat(arguments.startDate,'mm/dd/yyyy')#', 'mm/dd/yyyy')";
	}

	if (structKeyExists ( arguments, "endDate" ) AND arguments.endDate NEQ '' ) {
		// because of hours/minutes, trans_date must be LT EndDate + 1
		dTarget = DateAdd("d", 1, arguments.endDate );
		sQueryText &= " AND  spt.trans_date < TO_DATE('#dateformat( dTarget, 'mm/dd/yyyy')#', 'mm/dd/yyyy')";
	}

	if (structKeyExists ( arguments, "transTypeCode" )  AND arguments.transTypeCode NEQ '' ) {
		sQueryText &= " AND  spt.trans_Type_Code = '" & arguments.transTypeCode & "' ";
	}

	if (structKeyExists ( arguments, "transStatusCode" )  AND arguments.transStatusCode NEQ '' ) {
		sQueryText &= " AND  spt.trans_Status_Code = '" & arguments.transStatusCode & "' ";
	}

	if (structKeyExists ( arguments, "splanTransIdList" )  AND arguments.splanTransIdList NEQ '' ) {
		sQueryText &= " AND  spt.splan_trans_id IN  " & application.outility.buildQuotedValueList(arguments.splanTransIdList,"Numeric") & " " ;
	}

	if (structKeyExists ( arguments, "splanSectionCodeList" )  AND arguments.splanSectionCodeList NEQ '' ) {
		sQueryText &= " AND  scml.splan_section_code IN  " &  application.outility.buildQuotedValueList(arguments.splansectionCodeList,"Alpha") ;
	}

	sQueryText &= ' GROUP BY ' & sGroupByList;

	sQueryText &= ' ORDER BY ' & aSortMap[sortWalker].firstField & ' ' & arguments.sortdir & ',' & aSortMap[sortWalker].otherfields ;

	//writedump(var="sQueryText in getSplanListFopSum: #sQueryText#");
	//abort;

	oQuery.setsql ( sQueryText );

	var qRes = oQuery.execute().getresult();

	tRet.status = true;
	tRet.aRet = QuerytoArrayofStructures(qRes);
	for (var walker = 1; walker LE ArrayLen( tRet.aRet ); walker += 1) {
		if ( tRet.aRet[walker].splancatdesc EQ 'SUBCATEGORY USDA') {
			tRet.aRet[walker].splancatdesc = 'USDA';
		}
	}
	return tRet;

} // getSplanFopSum

public struct function getSplanCatSum ( numeric PY )
{

	var tRet = {};

	var oQuery = new query();
	var qRes = '';
	var sCmd = '';

	sCmd = "SELECT
	spdt.splan_cat_id AS splancatid,
	SUM(spdt.amount) as amount

	FROM
	splan_trans spt,
	splan_trans_det spdt

	WHERE spt.py = #arguments.PY#
	AND spdt.splan_trans_id = spt.SPLAN_TRANS_ID

	group by spdt.splan_cat_id
	ORDER BY splan_cat_id ";

	oQuery.setsql ( sCmd ) ;
	qRes = oQuery.execute().getresult();

	tRet.status = true;
	tRet.aRet = QuerytoArrayofStructures(qRes);

	return tRet;

} // getSplanCatSum


remote string function GetSplanCatAmountArray ( PY )
	returnFormat	= "plain"
	output			= "false"

{

	var sRet = 'this is sRet in GetSplanCatAmountArray';

	var oQuery = new query();
	var qRes = '';
	var aRet = [];
	var sCmd = '';

	sCmd = "SELECT
	spdt.splan_cat_id,
	SUM(spdt.amount) as amount

	FROM
	splan_trans spt,
	splan_trans_det spdt

	WHERE spt.py = #arguments.PY#
	AND spdt.splan_trans_id = spt.SPLAN_TRANS_ID

	group by spdt.splan_cat_id
	ORDER BY splan_cat_id ";

	oQuery.setsql ( sCmd ) ;
	qRes = oQuery.execute().getresult();

	aRet = QuerytoArrayofStructures(qRes);

	if (arrayLen ( aRet ) GE 1) {

		sRet = ARet[1].amount;
	}
	return SerializeJSON ( sRet );

} // GetSplanCatAmountArray


</cfscript>
</cfoutput>


    <cffunction name="f_getCurrentPY" access="remote" returntype="any" returnformat="plain" output="false" hint="Function returns Current Program Year (PY)">
        	<cfstoredproc procedure="SPLAN_PKG.sp_getCurrentPY" returncode="false">

            	<cfprocresult name="spr_getCurrentPY" resultset="1">
            </cfstoredproc>

            <cfreturn spr_getCurrentPY>
    </cffunction>
    <!--- ------ --->

    <cffunction name="f_getAmountsFutureSPlan" access="remote" returntype="any" returnformat="plain" output="false" hint="Function returns calculation to create future PY.">
    	<cfargument name="argUserID" type="string"  required="no">

        <cfstoredproc procedure="SPLAN_PKG.sp_getAmountsFutureSPlan" returncode="no">
        	<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argUserID#">
            <cfset var strucSplanFutureAmnt = structNew()>
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_CTR_FED_HQC" resultset="1"> <!--- CENTERS, USDA, NATIONAL HQ CONTRACTS  --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_GT"          resultset="2"> <!--- GRAND TOTAL --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_APPRP"   	resultset="3"> <!--- APPROPRIATION --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_BBR" 	   	resultset="4"> <!--- BALANCE BEFORE RESERVE --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_RES" 	   	resultset="5"> <!--- RESERVE --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getAmount_BAR" 	   	resultset="6"> <!--- BALANCE AFTER RESERVE --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getResPercent" 	   	resultset="7"> <!--- Reserve percentage --->
            <cfprocresult name="strucSplanFutureAmnt.spr_getTransClosed"		resultset="8"> <!--- Are all transaction closed? --->
        </cfstoredproc>

         <cfreturn strucSplanFutureAmnt />
    </cffunction>
    <!--- ------ --->
	<cffunction name="f_saveFutureSplan" access="remote" returntype="any" returnformat="plain" output="false"
    			hint="Function saves Allocated amounts and Notes for Future PY.">
          <cfargument name="argUserID" type="string"  required="no">
          <cfargument name="argSplan"  type="string"  required="no">

          <cfstoredproc procedure="SPLAN_PKG.sp_saveFutureSplan" returncode="no">
				<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argUserID#" >
                <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argSplan#" >
          </cfstoredproc>
	</cffunction>
    <!--- ------ --->
    <cffunction name="f_setNextYearSplan" access="remote" returntype="any" returnformat="plain" output="false" hint="Function sets initial transactions for the Next Year.">

          <cfargument name="argUserID" type="string"  required="yes">
          <cfargument name="argPY"     type="numeric" required="yes">
          <cfargument name="argSPNextPYRES" type="numeric" required="yes">
          <cfargument name="argSPNextPYBAR" type="numeric" required="yes">

          <cfstoredproc procedure="SPLAN_PKG.sp_setNextYrSplan" returncode="no">
          		<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.argUserID#" >
                <cfprocparam cfsqltype="cf_sql_integer" value="#arguments.argPY#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#arguments.argSPNextPYRES#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#arguments.argSPNextPYBAR#">

                <cfprocresult name="spr_NextYrSplan" resultset="1">
          </cfstoredproc>

    	  <cfreturn spr_NextYrSplan />

    </cffunction>
    <!--- ------ --->



</cfcomponent> <!--- Spend Plan Component --->
