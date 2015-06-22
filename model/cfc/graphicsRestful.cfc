<!--- graphicsRestful.cfc --->
<cfcomponent displayname="graphicsRestful" hint="Component that contains components of our restul backend for graphics">
<cfinclude template="#application.paths.includes#DataManipulationLib.cfm">

<cfoutput>

<cffunction name="GetDataAappLine1" access="remote" returntype="any" returnformat="plain" output="true" hint="AJAX call for aapp_line1">
	<cfargument name="aappNum" required="yes">
	<cfargument name="costCatList" required="no" default="">

	<cfscript>
	var qFop = '';
	var qExec1 = '';
	var qExec = '';
	var qAAPP = '';
	var qFop = '';
	var qECP = QueryNew('date_exec');
	var tReturn = structNew();
	var costCatIDList = '';
	var walker = '';
	var pointer = '';
	var gCatList = '';
	var gIdList = '';
	var qCostCatBuild = queryNew('COSTCATID');
	var qCostCatId = '';
	var nbAnyData = 0;
	var sErrorMessage = '';
	var cmd = '';
	var cmd1 = '';
	var cmd2 = '';
	var cmdFopCats = '';
	var startdate = '';
	var lastdate = '';
	var maxyears = 0;
	</cfscript>

	<!--- all cost categories (independent of contract) --->
	<cfquery name="qCostCat">
		select cost_cat_code, cost_cat_id from
		LU_COST_CAT
		where	cost_cat_p_id is null
		order by COST_CAT_CODE
	</cfquery>
	<!---
<cfdump var="#qCostCat#">
<cfabort>
--->

	<cfscript>
	gCatList = valuelist(qCostCat.cost_cat_code);
	gIdList = valuelist(qCostCat.cost_cat_id);
	//arguments.costCatList = ''  means give me all CostCats
	if (arguments.costCatList NEQ '') {
		for (walker = 1; walker LE ListLen(arguments.costCatList); walker += 1) {
			pointer = ListFindNoCase(gCatList, ListGetAt (arguments.costCatList, walker));
			costCatIDList &= ',' & ListGetAt(gIdList, pointer);
		}
		// eliminate leading comma
		costCatIDList = mid(costCatIDList, 2, len(costCatIDList) - 1);
	}
	// *** FOP data
	// this could have 4000 records!  (e.g. for AAPP=1500)

	cmd1 = "SELECT
			FOP_ID,
			FOP_NUM,
			PY,
			FOP_DESCRIPTION,
			AMOUNT,
			BACK_LOC,
			COST_CAT_ID,
			AAPP_NUM,
			ADJUSTMENT_TYPE_CODE,
			DATE_EXECUTED,
			TO_CHAR(DATE_EXECUTED, 'YYYY-MM-DD') AS DATE_EXEC,
			AMOUNT_NEXT_PY,
			PY_CRA_BUDGET,
			UPDATE_USER_ID,
			UPDATE_FUNCTION,
			UPDATE_TIME,
			DATE_EFFECTIVE_FOP,
			FUNDING_OFFICE_NUM,
			ARRA_IND,
			UNIT_25_FOP_NUM
		FROM FOP
		WHERE AAPP_NUM = #aappNum#";
		if (costCatIDList NEQ '') {
			cmd1 &= ' and cost_cat_id in ( '& costCatIDList & ')';
		}

	cmd2 = "select DATE_EXEC as date_exec, sum(amount) as amt from (" & cmd1 & ") GROUP BY date_exec ORDER BY date_exec";
	cmdFopCats = "select distinct cost_cat_id from (" & cmd1 & ") ORDER BY cost_cat_id";

	</cfscript>

	<!--- this gets plotted --->
	<cfquery name="qFop">
		#PreserveSingleQuotes( cmd2 )#
	</cfquery>

	<cfif qFop.recordcount GT 0>
		<cfset nbAnyData = 1>
	</cfif>
	<cfif qFop.recordcount GT 200>
			<cfset tReturn.sErrorMessage = "FOP data exceeds limit of 200 data points">
			<cfreturn SerializeJSON(tReturn)>
	</cfif>

	<cfquery name="qFopCats">
		#PreserveSingleQuotes( cmdFopCats )#
	</cfquery>

	<cfset qCostCatBuild = InsertListToQuery(qCostCatBuild, valuelist(qFopCats.cost_cat_id))>
	<!---
	<cfdump var="#qFop#" LABEL="qFop">
	<cfdump var="#qFopCats#" LABEL="qFopCats">
	<cfdump var="#qCostCatBuild#" LABEL="qCostCatBuild">
	<cfabort>
	--->

	<!--- *** ECP data --->
	<!--- aapp_num is unique --->
	<cfquery name="qECP1">
		select
		date_start, years_option, years_base
		from aapp p
		where
		p.aapp_num = #aappNum#
	</cfquery>

	<cfset var walker = 0>
	<cfset var walker2 = 0>
	<cfset var aOneYear = []>
	<cfset var aECP = []>

	<cfif qECP1.recordcount EQ 0 OR qECP1.years_base EQ '' OR qECP1.years_option EQ ''>
		<!--- determine start and end dates from the FOPs --->
		<cfif nbAnyData EQ 1>
			<!--- convert to PY boundaries --->
			<cfset startdate = StartofPY(qFop.date_exec[1])>
			<cfset enddate = EndofPY(qFop.date_exec[qFop.recordCount])>
			<cfset maxyears = year( enddate ) - year( startdate)>
		<cfelse>
			<cfset tReturn.sErrorMessage = "No data to display">
			<cfreturn SerializeJSON(tReturn)>
		</cfif>
	<cfelse>
		<!--- there is valid ECP data --->
		<cfset maxyears = qECP1.years_option + qECP1.years_base>
		<cfset startdate = qECP1.date_start>
		<cfset var startmonth = month(startdate)>
		<cfset var startday = day(startdate)>
		<cfset var startyear = year(startdate)>

		<!--- lastdate is the last date within the contract --->
		<cfset lastdate = DateAdd("d", -1, DateAdd('yyyy', qECP1.years_option + qECP1.years_base, CreateDate( startyear, startmonth, startday )))>


		<!--- set up initial "0" point at the beginning of the year --->
		<cfset aECP[1] 				= structNew()>
		<cfset aECP[1].date_exec 	= DateFormat(CreateDate( startyear, startmonth, startday ), "yyyy-mm-dd")  >
		<cfset aECP[1].amt 			= 0  >
		<cfset aECP[1].showtip 		= 0  >

		<cfset var qOneYear = ''>
		<cfset var vGrandTotal = 0>
		<cfloop INDEX="walker" FROM = "1" TO="#maxyears#">

			<!--- gets cumulative costs by costcatcode up to #walker# years --->

			<cfquery name="qOneYear">
				select	act.contract_type_code costCatCode, lu_cost_cat.cost_cat_id costCatID,
						contract.fun_getestcostprototalamount(p.aapp_num, lu_cost_cat.cost_cat_id, #walker#) as oneyearECPTotal
				from	aapp_contract_type act, aapp p, lu_cost_cat
				where	act.aapp_num = p.aapp_num and
						act.contract_type_code = lu_cost_cat.cost_cat_code and
						p.aapp_num = #aappNum#
						<cfif costCatIDList NEQ ''>
						  and lu_cost_cat.cost_cat_id in ( #costCatIDList# )
						</cfif>
			</cfquery>

			<cfquery dbType=query name="qECPCats">
				select
				distinct costCatID as cost_cat_id
				from qOneYear
				ORDER BY cost_cat_id
			</cfquery>

			<cfset qCostCatBuild = InsertListToQuery(qCostCatBuild, valuelist(qECPCats.cost_cat_id))>

			<cfset aOneYear = QuerytoArrayofStructures(qOneYear)>

			<cfset aECP[walker + 1] = structNew()>

			<cfif walker NEQ maxyears>
				<cfset aECP[walker + 1].date_exec = DateFormat(CreateDate( startyear + 1 + ( walker - 1), startmonth, startday ), "yyyy-mm-dd")  >
			<cfelse>
				<cfset aECP[walker + 1].date_exec = DateFormat(lastdate, "yyyy-mm-dd")>
			</cfif>

			<!--- this is the total for this year --->
			<cfset recordTotal = 0>

			<!--- build a single record for the year, from multiple records (one per cat code) for one year --->
			<cfloop INDEX="walker2" FROM="1" TO ="#arrayLen(aOneYear)#" >
				<CFSET recordTotal += aOneYear[walker2].oneyearECPTotal>
			</cfloop> <!--- each cat code --->

			<cfset vGrandTotal += recordTotal>

			<!--- insert the total for all the catcodes --->
			<CFSET StructInsert(aECP[walker + 1], 'AMT', vGrandTotal ,1) >
			<!--- insert an indication on whether to show a tooltip --->
			<CFSET StructInsert(aECP[walker + 1], 'SHOWTIP', 1 ,1) >
			<cfif recordTotal GT 0>
				<cfset nbAnyData = 1>
			</cfif>
		</cfloop> <!--- each year --->

		<!--- this gets graphed --->
		<cfset QECP = arrayOfStructuresToQuery(aECP)>
	</cfif> <!--- there is valid ECP data --->

	<!--- *** FMS data --->

	<cfquery name="qFMS1">
		select
			max(rep_date),
			max(TO_CHAR(rep_date, 'YYYY-MM-DD')) AS date_exec,
			sum(amount) as amt
		from
			center_2110_data c2d,
			center_2110_amount c2a
		where
			c2d.center_2110_id = c2a.center_2110_id
			<cfif costCatIDList NEQ ''>
			  and c2a.cost_cat_id in ( #costCatIDList# )
			</cfif>
			and c2a.type_id = 1	-- pulls cumulative cost
			and c2d.aapp_num = #aappNum#
		group by rep_date
		order by rep_date
	</cfquery>

	<cfquery name="qFMSCats">
		select
			distinct c2a.cost_cat_id
		from
			center_2110_data c2d,
			center_2110_amount c2a
		where
			c2d.center_2110_id = c2a.center_2110_id
			<cfif costCatIDList NEQ ''>
			  and c2a.cost_cat_id in ( #costCatIDList# )
			</cfif>
			and c2a.type_id = 1	-- pulls cumulative cost
			and c2d.aapp_num = #aappNum#
	</cfquery>

	<cfset qCostCatBuild = InsertListToQuery(qCostCatBuild, valuelist(qFMSCats.cost_cat_id))>
	<cfif qCostCatBuild.recordcount GT 0>
		<cfset nbAnyData = 1>
	</cfif>
	<!---
<cfdump var="#qCostCatBuild#">
<cfabort>
--->

	<!--- year indicators --->
	<cfquery dbType=query name="qFMS">
		select date_exec,
		amt
		from qFMS1
	</cfquery>

	<!--- Contract years --->
	<cfset yeartot = maxyears>
	<cfset qContract = QueryNew('ContractAnniversary')>

	<!--- make a query with a set of contract start dates that fall in the range of the graph --->
	<cfloop index = "walker" from = "1" to="#yeartot#">
		<cfset newRow = QueryAddRow(qContract, 1)>
		<cfset temp = QuerySetCell(qContract, "ContractAnniversary", DateFormat(DateAdd("yyyy", walker - 1, startdate),"yyyy-mm-dd"), newRow)>
	</cfloop>

	<!--- Program years. There may be fewer PYs than Contract Years --->
	<cfset qPY = QueryNew('PYAnniversary')>

	<!--- calculate the first PY date in the contract range --->
	<!--- program year always starts in July --->
	<cfif Month(startdate) GT 7>
		<!--- first PY is the July after the contract start --->
		<cfset py_date_start = CreateDate(Year(startdate) + 1, 7, 1)>
		<cfset yeartot = yeartot - 1>
	<cfelse>
		<cfset py_date_start = CreateDate(Year(startdate), 7, 1)>
	</cfif>

	<!--- make a set of PY dates that falls in the range of the graph --->
	<cfloop index = "walker" from = "1" to="#yeartot#">
		<cfset newRow = QueryAddRow(qPY, 1)>
		<cfset temp = QuerySetCell(qPY, "PYAnniversary", DateFormat(DateAdd("yyyy", walker - 1, py_date_start),"yyyy-mm-dd"), newRow)>
	</cfloop>

	<!--- consolidate the costCatId query --->
	<cfquery dbType=query name="qCostCatIDx">
		select distinct costcatid, '' as costcatcode
		from qCostCatBuild
		order by costcatid
	</cfquery>
	<!---
<cfdump var="#qCostCatIDx#">
<cfabort>
--->
	<cfscript>
	try {
		aCostCatIdx = QueryToArrayOfStructures(qCostCatIDx);

		for (walker = 1; walker LE ArrayLen(aCostCatIdx); walker += 1) {
			pointer = ListFindNoCase(gIdList, aCostCatIdx[walker].costcatid);
			aCostCatIdx[walker].costcatcode = ListGetAt(gCatList, pointer);
		}

		qCostCatId = ArrayofStructurestoQuery(aCostCatIdx);
	}
	catch (any e) {
		tReturn.sErrorMessage = 'Data has non-standard cost codes';
		return SerializeJSON(tReturn);
	} // catch

	if ( NOT nbAnyData ) {
		sErrorMessage = 'No data available for this AAPP';
	}

	tReturn.sErrorMessage = sErrorMessage;

	// TESTING hard-code an error message
	// tReturn.sErrorMessage = "Test message from Restful.cfc";

	if (tReturn.sErrorMessage EQ '' ) {
		tReturn.QCATID 		= Duplicate(qCostCatId);
		tReturn.QFOP 		= Duplicate(qFOP);
		tReturn.QECP 		= Duplicate(QECP);
		tReturn.QFMS 		= Duplicate(qFMS);
		tReturn.QCONTRACT 	= Duplicate(qCONTRACT);
		tReturn.QPY 		= Duplicate(qPY);
	}

	// writedump(var="#tReturn#", label="tReturn in graphicsRestful.GetDataAappLine1()");

	return SerializeJSON(tReturn);

	</cfscript>

</cffunction> <!--- GetDataAappLine1 --->

<cffunction name="f_getrst_fop_aapp" access="remote" returntype="any" returnformat="plain" output="no" hint="AJAX call for fop_aapp">
<cfargument name="aappNum">

	<cfset var tReturn=structNew()>

	<!--- Sergey's routine, for fop_aapp.cfm --->
	<cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_test_JSON" returncode="no" >
		<cfprocparam cfsqltype=" cf_sql_integer"  value=#arguments.aappNum#>
		<cfprocresult name="qFOP" resultset=1>
		<cfprocresult name="qLegend" resultset=2>
	</cfstoredproc>

	<!--- putting the query in a structure, so that other things could be returned, in general --->
	<cfset tReturn.qFOP 			= duplicate(qFOP)>
	<cfset tReturn.qLegend 			= duplicate(qLegend)>

	<cfreturn SerializeJSON(tReturn) />

</cffunction>

<cffunction name="f_get_bullets" access="remote" returntype="any" returnformat="plain" output="no" hint="AJAX call for bullets">
	<cfargument name="SortBy">
	<cfargument name="SortDir">

	<!--- get data based on session variables --->
	<cfscript>

	var tReturn = StructNew();
	var responseStruct = StructNew();
	var qbullet = '';

	responseStruct = application.oaapp_home.CFSessionDisplayDataColumnsGuts(
		formDataIn:session.userpreferences.tmyfilternow
		, textOnly:1						// integer (1 = true, 0 = false).  This sets class to form3DataTbl, sTRClass = form3AltRow
		, roleID:#session.roleID#			// integer
		, region:#session.region#			// integer
		, sortBy:arguments.SortBy
		, sortDir:arguments.SortDir
		) ;

	tReturn.sFilterHTML		= responseStruct.sFilterHTML;
	// list of aappNums in the Home Page Query, in sort order
	tReturn.sAAPPNumList	= responseStruct.sAAPPNumList;
	tReturn.qBulletsData	= duplicate( getBulletsData( tReturn.sAAPPNumList ) );

	return SerializeJSON(tReturn);

	</cfscript>

</cffunction> <!--- f_get_bullets --->

<cffunction name="getBulletsData">
	<cfargument name="sAAPPNumList">

	<cfset var cmd =
		"select aappNum
		FROM AAPP_CONTRACT_SNAPSHOT WHERE 1=1
		AND aappNum in ( #arguments.sAAPPNumList# )">

	<cfquery name = "qBulletsData">
		#PreserveSingleQuotes(cmd)#
	</cfquery>

	<cfreturn qBulletsData />

</cffunction> <!--- getBulletsData --->

<cfscript>
function InsertListToQuery (qQuery, VList) {
	var aTemp = ListToArray(arguments.VList);
	var qRet = duplicate(qQuery);
	var nrecords = qret.recordCount;
	for (var walker = 1; walker LE arrayLen(aTemp); walker += 1) {
		// aRet is an array of objects like [{'codeid':'a1'},{'codeid':'a2'}]
		QueryAddRow(qRet,1);
		nrecords += 1;
		QuerySetCell(qRet,'COSTCATID',aTemp[walker], nrecords);
	}
	return qRet;
} // InsertListToQuery

function StartofPY (dt) {

	var m = month( dt);
	var y = year( dt);

	if (m LT 7) {
		y = y - 1;
	}
	return CreateDate (y, 7, 1);
}

function EndofPY (dt) {

	var m = month( dt);
	var y = year( dt);

	if (m GT 6) {
		y = y + 1;
	}
	return CreateDate (y, 6, 30);
}



</cfscript>

</cfoutput>
</cfcomponent>
