<!---
page: utility.cfc

description: component that handles system utility functions

revisions:
07-10-2007	rroser	add functions to search for recent updates/release notes
07-26-2007	yjeng	add functions to format string to different type
2014-03-29	mstein	Added getQuarter function
--->
<cfcomponent displayname="Lookup Component" hint="Contains various functions/methods for JFAS System">

	<cffunction name="getCurrentSystemProgramYear" access="public" returntype="numeric" hint="Returns current program year (DOL AAPPS)">

		<cfquery name="qryCurrentPY">
		select utility.fun_getcurrntprogram_year as currentPY
		from dual
		</cfquery>

		<cfreturn qryCurrentPY.currentPY>
	</cffunction>

	<cffunction name="getCurrentSystemProgramYear_CCC" access="public" returntype="numeric" hint="Returns current program year (CCCs)">

		<cfquery name="qryCurrentPY">
		select utility.fun_getcurrntprogram_year_ccc as currentPY
		from dual
		</cfquery>

		<cfreturn qryCurrentPY.currentPY>
	</cffunction>

	<cffunction name="getProgramYearDate" access="public" returntype="date" hint="Returns start or end date of specified PY">
		<cfargument name="py" type="numeric" required="yes">
		<cfargument name="type" type="string" required="no" default="S">

		<cfquery name="qryPYdate">
		select Utility.fun_get_py_date (#arguments.py#, '#ucase(arguments.type)#') as PYdate
		from dual
		</cfquery>

		<cfreturn qryPYdate.PYDate>
	</cffunction>

	<cffunction name="getYear_byDate" access="public" returntype="numeric" hint="Returns current fiscal/program/calendar year based on date">
		<cfargument name="yearType" type="string" required="no" default="C">
		<cfargument name="baseDate" type="date" required="no" default="#now()#">

		<cfquery name="qryYear_byDate">
		select utility.fun_get_year(to_date('#dateformat(arguments.baseDate, "mm/dd/yyyy")#','MM/DD/YYYY'),'#ucase(yearType)#') as getYear
		from dual
		</cfquery>

		<cfreturn qryYear_byDate.getYear>
	</cffunction>

	<cffunction name="insertSystemAudit" access="public" returntype="void" hint="Inserts history record in system auditing table">

		<cfargument name="aapp" type="numeric" required="no" />
		<cfargument name="statusID" type="numeric" required="no" />
		<cfargument name="fopID" type="numeric" required="no" />
		<cfargument name="adjustID" type="numeric" required="no" />
		<cfargument name="sectionID" type="numeric" required="no" />
		<cfargument name="description" type="string" required="yes" />
		<cfargument name="userID" type="string" required="yes" />

		<cfquery name="qryInsertAudit" >
		insert into system_audit (
			audit_id,
			<cfif isDefined("arguments.aapp")>aapp_num,</cfif>
			<cfif isDefined("arguments.statusID")>contract_status_id,</cfif>
			<cfif isDefined("arguments.fopID")>fop_id,</cfif>
			<cfif isDefined("arguments.adjustID")>adjustment_id,</cfif>
			<cfif isDefined("arguments.sectionID")>aapp_section_id,</cfif>
			<cfif isDefined("arguments.description")>description,</cfif>
			user_id)
		values (
			seq_system_audit.nextval,
			<cfif isDefined("arguments.aapp")>#arguments.aapp#,</cfif>
			<cfif isDefined("arguments.statusID")>#arguments.statusID#,</cfif>
			<cfif isDefined("arguments.fopID")>#arguments.fopID#,</cfif>
			<cfif isDefined("arguments.adjustID")>#arguments.adjustID#,</cfif>
			<cfif isDefined("arguments.sectionID")>#arguments.sectionID#,</cfif>
			<cfif isDefined("arguments.description")>'#arguments.description#',</cfif>
			'#arguments.userID#')
		</cfquery>

	</cffunction>

	<cffunction name="getSystemSetting" access="public" returntype="string" hint="Gets value (by code) from System Setting table">
		<cfargument name="systemSettingCode" type="string" required="yes">

		<cfquery name="qrySystemSetting">
		select	value
		from	system_setting
		where	system_setting_code = '#arguments.systemSettingCode#'
		</cfquery>

		<cfreturn qrySystemSetting.value>

	</cffunction>

	<cffunction name="getPOCs" access="public" returntype="query" hint="Gets contact information">
		<cfargument name="contactType" type="string" required="no">

		<cfquery name="qryContactTypes">
		select	system_setting_code,
				value
		from	system_setting
		where	1=1
			<cfif isDefined("arguments.contactType")>
				and system_setting_code like '#arguments.contactType#%'
			</cfif>
		</cfquery>

		<cfset qryContacts = QueryNew("#valuelist(qryContactTypes.system_setting_code)#")>
		<cfset temp = QueryAddRow(qryContacts)>
		<cfloop query="qryContactTypes">
			<cfset temp = QuerySetCell(qryContacts, system_setting_code, value)>
		</cfloop>

	<cfreturn qryContacts>

	</cffunction>

	<cffunction name="GetCurrentQuarterNum" access="public" returntype="numeric" hint="Get Current Quarter Number">
		<cfargument name="quarter_type" type="string" required="true">

		<cfquery name="qryCurrentQuarter">
		select utility.fun_get_quarter(sysdate, '#arguments.quarter_type#') as currentQuarterNum
		from dual
		</cfquery>

		<cfreturn qryCurrentQuarter.currentQuarterNum>
	</cffunction>

	<cffunction name="VerticalList" access="public" returntype="string" hint="Convert the list to order by Vertical">
		<cfargument name="col" type="numeric" required="true">
		<cfargument name="list" type="string" required="true">
		<cfargument name="blank_filler" type="string" required="no" default="NA">
		<cfset newlist="">
		<cfset looper=1>
		<cfset container=arraynew(2)>
		<cfif arguments.col neq 0>
			<cfset row=ceiling(listlen(arguments.list)/arguments.col)>
			<cfloop index="idx" from="1" to="#arguments.col#">
				<cfloop index="idx1" from="1" to="#row#">
					<cfset pos=idx+(idx1-1)*arguments.col>
					<cfif pos gt listlen(arguments.list)>
						<cfset container[idx1][idx]=arguments.blank_filler>
					<cfelse>
						<cfset container[idx1][idx]=listgetat(arguments.list,looper)>
						<cfset looper=looper+1>
					</cfif>
				</cfloop>
			</cfloop>
			<cfloop index="idx" from="1" to="#row#">
				<cfloop index="idx1" from="1" to="#arguments.col#">
					<cfset newlist=listappend(newlist,container[idx][idx1])>
				</cfloop>
			</cfloop>
		<cfelse>
			<cfset newlist=arguments.list>
		</cfif>
		<cfreturn newlist>
	</cffunction>

	<cffunction name="Crosstab" access="public" returntype="array" hint="Provide a crosstab function by return 2 dimension array">
		<!---Query for Crosstab: data source --->
		<cfargument name="qry" type="query" required="true">
		<!---A column in qry. In crosstab presentation will be the columns--->
		<cfargument name="col" type="string" required="true">
		<!---A column in qry. Display order for col, require if order by other column--->
		<cfargument name="col_sort" type="string" required="no" default="#arguments.col#">
		<!---A column in qry. In crosstab presentation will be the rows--->
		<cfargument name="row" type="string" required="true">
		<!---A column in qry. Display order for row usually same as row--->
		<cfargument name="row_sort" type="string" required="no" default="#arguments.row#">
		<!---The value column in qry.--->
		<cfargument name="val" type="string" required="true">
		<!---In crosstab presentation will be the [1][1] usually this is a header--->
		<cfargument name="corner" type="string" required="no">
		<!---In crosstab presentation, will be [1][col] if supply, instead of display col, you can specify the columns namem usually this is header--->
		<cfargument name="col_titles" type="string" required="no">
		<cfset crosstab=arraynew(2)>
		<cfquery name="total_rows" dbtype="query">
			select	distinct #arguments.row# as row_name
			from	arguments.qry
			order by #arguments.row_sort#
		</cfquery>
		<cfset row_list=valuelist(total_rows.row_name)>
		<cfquery name="total_cols" dbtype="query">
			select	distinct #arguments.col# as col_name
			from	arguments.qry
			order by #arguments.col_sort#
		</cfquery>
		<cfset col_list=valuelist(total_cols.col_name)>

		<cfquery name="subqry" dbtype="query">
			select	#arguments.row# as subrow, #arguments.col# as subcol, #arguments.val# as subvalue
			from	arguments.qry
		</cfquery>
		<!---Initial Array--->
		<cfloop index="idx_row" from="1" to="#listlen(row_list)+1#">
			<cfloop index="idx_col" from="1" to="#listlen(col_list)+1#">
				<cfset crosstab[idx_row][idx_col]="">
			</cfloop>
		</cfloop>
		<!---Setup for corner--->
		<cfset crosstab[1][1]=#arguments.corner#>
		<!---Crosstabing -- Setup for first Column--->
		<cfif isDefined("arguments.col_titles") and listlen(arguments.col_titles) and listlen(arguments.col_titles) eq listlen(col_list)>
		<cfloop index="idx" from="1" to="#listlen(arguments.col_titles)#">
			<cfset crosstab[1][#idx#+1]=#listgetat(arguments.col_titles,idx)#>
		</cfloop>
		<cfelse>
		<cfloop query="total_cols">
			<cfset crosstab[1][#currentrow#+1]=#col_name#>
		</cfloop>
		</cfif>

		<!---Crosstabing -- Setup for first Row--->
		<cfloop query="total_rows">
			<cfset crosstab[#currentrow#+1][1]=#row_name#>
		</cfloop>
		<!---Fill in Array from [2][2]--->
		<cfloop query="subqry">
			<cfset col_position=listfind(col_list,subcol)+1>
			<cfset row_position=listfind(row_list,subrow)+1>
			<cfset crosstab[#row_position#][#col_position#]=subvalue>
		</cfloop>
		<cfreturn crosstab>
	</cffunction>



	<cffunction name="formatString" access="public" returntype="string" hint="Returns string on specify type and format">
		<cfargument name="str" type="string" required="yes">
		<cfargument name="type" type="string" required="yes">
		<cfargument name="mask" type="string" required="no">
		<cfargument name="except" type="string" required="no" default="">
		<cfset myStr = "">
		<cftry>
			<cfswitch expression="#type#">
				<cfcase value="dollar">
					<cfif arguments.str lt 0>
						<cfset myStr = "-$"&#numberformat(abs(arguments.str),",")#>
					<cfelse>
						<cfset myStr = "$"&#numberformat(arguments.str,",")#>
					</cfif>
				</cfcase>
				<cfcase value="int">
					<cfset myStr = #int(arguments.str)#>
				</cfcase>
				<cfcase value="date">
					<cfset myStr = #dateformat(arguments.str,arguments.mask)#>
				</cfcase>
				<cfcase value="time">
					<cfset myStr = #timeformat(arguments.str,arguments.mask)#>
				</cfcase>
			</cfswitch>
			<cfcatch type="any">
				<cfset myStr = arguments.except>
			</cfcatch>
		</cftry>
		<cfreturn myStr>
	</cffunction>

	<cffunction name="getFormVersion" access="public" returntype="numeric" hint="Return most recent form version (based on type passed)">
		<cfargument name="formType" type="string" required="yes">

		<cfquery name="qryGetFormVersion">
		select	max(form_version) as maxVersion
		from	lu_form_version
		where	form_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formType)#">
		</cfquery>

		<cfreturn qryGetFormVersion.maxVersion>

	</cffunction>


	<cffunction name="getOMBInflationRate" access="public" returntype="numeric" hint="Takes date, and returns OMB infl rate on that date">
		<cfargument name="effectDate" type="date" required="true">
		<cfargument name="costCat" type="string" required="false" default="A" hint="B3 uses different method of infl rate">

		<cfquery name="qryGetOMBRate">
		select utility.fun_get_omb_inflat_rate('#dateformat(arguments.effectDate,"dd-mmm-yyyy")#','#arguments.costCat#') as ombRate
		from dual
		</cfquery>
		<cfreturn qryGetOMBRate.ombRate>

	</cffunction>


	<cffunction name="getQuarter" access="public" returntype="numeric" hint="Returns quarter of the year, based on date">
		<cfargument name="yearType" type="string" required="yes" default="PROG">
		<cfargument name="myDate" type="date" required="yes" default="#now()#">

		<cfswitch expression="#arguments.yearType#">
			<cfcase value="PROG">
				<cfswitch expression="#month(arguments.myDate)#">
					<cfcase value="7,8,9">		<cfset myQtr = 1></cfcase>
					<cfcase value="10,11,12">	<cfset myQtr = 2></cfcase>
					<cfcase value="1,2,3">		<cfset myQtr = 3></cfcase>
					<cfcase value="4,5,6">		<cfset myQtr = 4></cfcase>
				</cfswitch>
			</cfcase>
			<cfcase value="FISC">
				<cfswitch expression="#month(arguments.myDate)#">
					<cfcase value="7,8,9">		<cfset myQtr = 4></cfcase>
					<cfcase value="10,11,12">	<cfset myQtr = 1></cfcase>
					<cfcase value="1,2,3">		<cfset myQtr = 2></cfcase>
					<cfcase value="4,5,6">		<cfset myQtr = 3></cfcase>
				</cfswitch>
			</cfcase>
			<cfcase value="CAL">
				<cfswitch expression="#month(arguments.myDate)#">
					<cfcase value="7,8,9">		<cfset myQtr = 3></cfcase>
					<cfcase value="10,11,12">	<cfset myQtr = 4></cfcase>
					<cfcase value="1,2,3">		<cfset myQtr = 1></cfcase>
					<cfcase value="4,5,6">		<cfset myQtr = 2></cfcase>
				</cfswitch>
			</cfcase>
		</cfswitch>

		<cfreturn myQtr>

	</cffunction> <!--- getQuarter --->

	<cffunction name="getSessionAnnouncement" access="remote" returntype="any" returnformat="plain" output="no" hint="Function retrieves text of the message.">

		<cfset var q = ''>
		<cfquery maxrows="1" name="q">
			SELECT msg_text
			FROM message
			WHERE status = 1 and msg_type='WELCOME'
			ORDER BY update_time DESC
		</cfquery>


		<cfreturn SerializeJSON(q)>
	</cffunction> <!--- getSessionAnnouncement --->
<cfscript>
/**
* @hint I am a function to convert a comma-delimited list to a list of quote-delimited values
* @inList list of values, to be converted to be OK for an Oracle IN list
* @variableType  "Numeric" if list is of numeric values
*/
string function buildQuotedValueList (
	required string inList
	, required variableType
	)

{

	var ret = '' ;
	var arguments.inList = UCase(arguments.inList) ;

	for (var walker = 1; walker le ListLen(arguments.inList); walker += 1) {
		listItem = ListGetAt( arguments.inList, walker );

		if ( arguments.variableType eq "Numeric" ) {
			ret = ret & LTrim(RTrim(listItem)) & "," ;
		} else {
			ret = ret & "'" & LTrim(RTrim(listItem)) & "'," ;
		}
	}
	if ( ret neq '' ) {
		ret = '(' & mid(ret, 1, len(ret) - 1) & ')' ;
	}
	return ret;

} // buildQuotedValueList

function CFconvertJSONQuery(tJSON){
	// this is CF, NOT JS
	// I return an ARRAY of objects, one item in the array per row in the query
	// this is like f_makeWorkableJSON, except converts column headings to lower case

	// I take an object of two properties:  COLUMNS and DATA
	// COLUMNS is an ARRAY of column headings
	// DATA is an ARRAY of objects
	//		the first object contains the values for row1 in the query
	//		each object in the data array has an array of values.

    // so that we don't change the calling object, create a local copy of the column names, lower case
    var aColumnNames = [];
	for(var cColumn=1; cColumn le ArrayLen(tJSON.COLUMNS); cColumn = cColumn + 1) {
		aColumnNames[ cColumn ] = tJSON.COLUMNS[ cColumn ].toLowerCase();
	}

    // Create return variable, which is an ARRAY
    var aReturn = [];

    for(var rRow=1; rRow LE ArrayLen(tJSON.DATA); rRow = rRow + 1) {
    	// for this row, create a structure
        var oRowData = {};
        for(cColumn=1; cColumn LE ArrayLen(tJSON.COLUMNS);  cColumn = cColumn + 1) {
        	// for this column, create an object, like {b1:123}. This is an ASSOCIAE ARRAY ???
            oRowData[aColumnNames[cColumn]] = Duplicate(tJSON.DATA[rRow][cColumn]);
		}
        // save the new row with column names
        aReturn[rRow] = Duplicate(oRowData);
    }
	// TEST1: alert("f_makeWorkableJSON \n"+jsdump(aReturn));
	// TEST2: alert(JSON.stringify(aReturn));


	// Return the array of objects
    return aReturn;
}

/**
* @hint I am a function to analyze a string, and to be sure it fits in an alert box
* @sString is the string
* @nHeight  is the maximum height in px of the alert box
* @nWidth is the width in px of the alert box
*/
function setAlertLayout (sString, nHeight, nWidth) {
	var tRet = {};
	// This hard coding must be adjusted depending on font.  Since font is variable-width, which will always be just an approximation.  The nCharWidthPx affects the display when there are a lot og long lines with no breaks.
	var nLineHeightPx = 18;
	var nCharWidthPx = 7;

	var nLineMax = Ceiling(nHeight / nLineHeightPx) - 1;
	var nCharPerLine = Ceiling (nWidth / nCharWidthPx ) - 1;
	var vHeight = nHeight;
	var vWidth = nWidth;
	var nSegLen = 0;
	var sCR = '<br>';

	var vString = ReplaceNoCase(jsStringformat(sString), '\r\n', sCR, 'all');
	//vString = ReplaceNoCase(vString, '\r', sCR, 'all');
	vString = ReplaceNoCase(vString, '\\\"', '"', 'all');


	// scan the string, adding a line each time we hit a <br>, for we reach the max width of a line in characters
	var ipSegStart = 1;
	var kpSegEnd = 1;
	var nLen = len (vString);
	var nLines = 0; // number of lines so far
	var nSegLen = 0; // lenght of current segment
	var newLen = 0; // new length for string

	// this is essentially an infinite loop. Test for fitting string to pane is within the loop
	for (nSegs = 1; nSegs LE 1000; nSegs = nSegs + 1){
		if (ipSegStart GT nLen) {
			// we are done
			break;
		}
		kpSegEnd = findNoCase ( sCR, vString, ipSegStart );
		if (kpSegEnd LT 1) {
			// we are looking at the last segment in the line
			nSegLen = nLen - ipSegStart + 1;
			nLinesInSeg = Ceiling( nSegLen / nCharPerLine );
			if ( nLines + nLinesInSeg GT nLineMax ) {
				// chop the message to fit within nLineMax
				newLen = ipSegStart + nCharPerLine * ( nLineMax - nLines ) - 1 ;
				nLines = nLineMax;
				vString = mid (vString, 1, newLen ) ;
			}
			else {
				// last line fits in pane
				nLines += nLinesInSeg;
			}
			break;
		}
		// found sCR
		nSegLen = kpSegEnd - ipSegStart;
		nLinesInSeg = Ceiling( nSegLen / nCharPerLine );

		if ( nLines + nLinesInSeg GT nLineMax ) {
			// chop the message to fit within nLineMax, but don't break a <CR>
			newLen = ipSegStart + nCharPerLine * ( nLineMax - nLines ) - 4 ;
			if (newLen GT kpSegEnd - 1) {
				newLen = kpSegEnd - 1;
			}
			nLines = nLineMax;
			vString = mid (vString, 1, newLen ) ;
			break;
		}
		else {
			// line fits in pane
			nLines += nLinesInSeg;
		}

		// skip the <cr>
		ipSegStart = kpSegEnd + 3;
		if (ipSegStart GT nLen) {
			break;
		}
	}

	// allow for "no sCR" at the end of the last line
	nLines += 1;

	// adjust the height of the pane to fit the message
	vHeight = nLines * nLineHeightPx;

	tRet.sString = vString;
	tRet.nHeight = vHeight;
	tRet.nWidth = vWidth;
	//writedump(var="#tRet#");
	//writedump(var="nlen #nlen# newLen #newLen# kpSegEnd #kpSegEnd# nCharPerLine #nCharPerLine# nLines #nLines# nLineMax #nLineMax# ");
	//abort;
	return tRet;
}


function countStringOccurrences (sString, SSubString) {
	// I return the number of times SSubString appears in sString
	var ip = 1;
	var kp = 1;
	var nLen = len(sString);

	for (nCount = 1; nCount LE 100; nCount = nCount + 1){
		kp = findNoCase ( sSubString, sString, ip );
		if (kp LT 1) {
			break;
		}
		ip = kp + 1;
		if (kp GT nLen) {
			break;
		}
	}
	return nCount;
} // countStringOccurrences

</cfscript>

</cfcomponent>