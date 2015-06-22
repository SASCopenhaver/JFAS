<!--- graphicsUtils.cfc --->
<cfcomponent displayname="graphicsUtils" hint="Component that contains utilities for supporting graphics.">

<cfoutput>
<cfscript>
function graphicSetForAAPPNum (aapp, userID, sFormTitle, sTabPrefix) {
	// get service types for Est. Cost Profile report --->
	var lstServTypes		= application.oaapp.getAAPPServiceTypes(aapp);

	var tRepPar 			= structNew();
	var tGrStruct 			= structNew();
	var qFuture				= '';
	tRepPar.aapp 			= aapp;
	tRepPar.userID 			= userID;
	tRepPar.cboPY 			= 'all';
	tRepPar.formTitle 		= sFormTitle;
	tRepPar.tabPrefix 		= sTabPrefix;
	tRepPar.sWindowName 	= sTabPrefix & '-' & aapp;
	tRepPar.cboaapp 		= aapp;
	tRepPar.cboCenter 		= 0;
	tRepPar.cboFundingOffice = '';
	tRepPar.cboDolRegion 	= '';
	tRepPar.radReportFormat = 'application/pdf';
	tRepPar.chkCostCat		= lstServTypes;
	tRepPar.radReportType	= aapp;
	tRepPar.hidReportType	= '';

	tGrStruct.tRepPar		= duplicate(tRepPar);
	tGrStruct.rstFopList 		= application.oReports.getFopList(tRepPar);
	tGrStruct.rstGetAAPPGeneral	= application.oaapp.getAAPPGeneral(aapp);
	tGrStruct.rstCostCategories	= application.oLookup.getCostCategories(displayFormat='primary');

	// fixed list of output columns for this report
	tGrStruct.fixedcolumncodes = "PY," & valuelist(tGrStruct.rstCostCategories.costcatcode);
	tGrStruct.fixedcolumndesc = "Prog Year," & valuelist(tGrStruct.rstCostCategories.costcatdesc);
	return tGrStruct;
}

function graphicSetForHome(userID, sFormTitle, sTabPrefix) {
	// get service types for Est. Cost Profile report --->
	//var lstServTypes		= application.oaapp.getAAPPServiceTypes(aapp);

	var tRepPar 			= structNew();
	var tGrStruct 			= structNew();
	tRepPar.userID 			= userID;
	tRepPar.cboPY 			= 'all';
	tRepPar.formTitle 		= sFormTitle;
	tRepPar.tabPrefix 		= sTabPrefix;
	tRepPar.sWindowName 	= sTabPrefix;
	tRepPar.cboaapp 		= aapp;
	tRepPar.cboCenter 		= 0;
	tRepPar.cboFundingOffice = '';
	tRepPar.cboDolRegion 	= '';
	tRepPar.radReportFormat = 'application/pdf';
	//tRepPar.chkCostCat		= lstServTypes;
	tRepPar.radReportType	= aapp;
	tRepPar.hidReportType	= '';

	tGrStruct.tRepPar		= duplicate(tRepPar);
	//tGrStruct.rstFopList 		= application.oReports.getFopList(tRepPar);
	//tGrStruct.rstGetAAPPGeneral	= application.oaapp.getAAPPGeneral(aapp);
	tGrStruct.rstCostCategories	= application.oLookup.getCostCategories(displayFormat='primary');

	// fixed list of output columns for this report
	tGrStruct.fixedcolumncodes = "PY," & valuelist(tGrStruct.rstCostCategories.costcatcode);
	tGrStruct.fixedcolumndesc = "Prog Year," & valuelist(tGrStruct.rstCostCategories.costcatdesc);
	return tGrStruct;
}

</cfscript>

<cffunction name="displayTitleForAAPPNum" output="true">
	<cfargument name="tLayout">
	<cfargument name="tGrStruct">
	<cfargument name="graphicJSCfm">

	<cfset var sWindowName = ''>

	<!--- display a header form for a graphic based on an aapp --->
	<div class="HeaderDiv"> <!--- linked to mobile style sheet --->
	<div class="form" style="margin-left:#tLayout.marginleft#px;">
		<form name="displayTitleForAAPPNum" id="displayTitleForAAPPNum" method="post">
		<div id="formContent" class="formContent" style="width=#tLayout.titlewidth#px;">
			<h1 style="text-align:left">#tGrStruct.tRepPar.formTitle# #tGrStruct.tRepPar.aapp#</h1>
			<h2 style="text-align:left"><Cfif tGrStruct.tRepPar.cboPY neq "all">Program Year #tGrStruct.tRepPar.cboPY#<cfelse>All Program Years</Cfif></h2>
			<table width="#tLayout.titlewidth#px" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="display report header info.">
			<tr>
				<td width="15%" valign="top" title="Funding Office" scope="row"><strong>Funding Office:</strong></td>
				<td width="25%" valign="top">#tGrStruct.rstGetAAPPGeneral.fundingofficedesc#</td>
				<td width="20%" valign="top" title="Program Activity" scope="row"><strong>Program Activity:</strong></td>
				<td width="*" valign="top">#tGrStruct.rstGetAAPPGeneral.programactivity#</td>
			</tr>
			<tr>
				<td valign="top" title="Contractor" scope="row"><strong>Contractor:</strong></td>
				<td valign="top">#tGrStruct.rstGetAAPPGeneral.contractorname#</td>
				<td valign="top" nowrap title="Performance Venue / Center" scope="row"><strong>Performance Venue/Center:</strong></td>
				<td valign="top"><cfif tGrStruct.rstfoplist.venue neq ''>#tGrStruct.rstfoplist.venue# / </cfif>#tGrStruct.rstGetAAPPGeneral.centername#</td><!--- only show venue if it exists --->
			</tr>
			<tr>
				<td valign="top" title="Contract No." scope="row"><strong>Contract No.:</strong></td>
				<td valign="top">#tGrStruct.rstGetAAPPGeneral.contractNum#</td>
				<td valign="top" title="Performance Period" scope="row"><strong>Performance Period:</strong></td>
				<td valign="top"><cfif tGrStruct.rstGetAAPPGeneral.datestart neq "">#Dateformat(tGrStruct.rstGetAAPPGeneral.datestart, "mm/dd/yyyy")#</cfif> <cfif tGrStruct.rstGetAAPPGeneral.dateend neq "">to #dateFormat(tGrStruct.rstGetAAPPGeneral.dateend, "mm/dd/yyyy")#</cfif></td>
			</tr>
			<cfif tGrStruct.rstGetAAPPGeneral.predAAPPNum neq "" OR tGrStruct.rstGetAAPPGeneral.succAAPPNum neq "">
				<tr>
					<!--- window name is same as tab name, to prevent duplicate windows for the same graph --->
					<cfif tGrStruct.rstGetAAPPGeneral.predAAPPNum neq "">
						<cfset sWindowName = '#tGrStruct.tRepPar.tabPrefix# #tGrStruct.rstGetAAPPGeneral.predAAPPNum#'>
						<td valign="top"><strong>Predecessor:</strong></td><td><a href=
						"javascript:GoToAAPPGraph ('#graphicJSCfm#?aapp=#tGrStruct.rstGetAAPPGeneral.predAAPPNum#', '#sWindowName#');">#tGrStruct.rstGetAAPPGeneral.predAAPPNum#</a>
						</td>
					<cfelse>
						<td colspan="2">&nbsp;</td>
					</cfif>
					<cfif tGrStruct.rstGetAAPPGeneral.succAAPPNum neq "">
						<cfquery name = "qFuture">
							select count(*) cnt from AAPP where aapp_num =#tGrStruct.rstGetAAPPGeneral.succAAPPNum# AND AAPP.budget_input_type = 'F'
						</cfquery>
						<cfif qFuture.cnt eq 0>
							<cfset sWindowName = '#tGrStruct.tRepPar.tabPrefix# #tGrStruct.rstGetAAPPGeneral.succAAPPNum#'>
							<td valign="top"><strong>Successor:</strong></td><td><a href="javascript:GoToAAPPGraph ('#graphicJSCfm#?aapp=#tGrStruct.rstGetAAPPGeneral.succAAPPNum#', '#sWindowName#');">#tGrStruct.rstGetAAPPGeneral.succAAPPNum#</a></td>
						<cfelse>
							<td valign="top"><strong>Successor:</strong></td><td>#tGrStruct.rstGetAAPPGeneral.succAAPPNum#</td>
						</cfif>
					<cfelse>
						<td colspan="2">&nbsp;</td>
					</cfif>
				</tr>
			</cfif>
			<tr>
				<td >Report Run on: </td><td>#dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "HH:MM:SS")#</td>
				<td colspan="2" align="left"><cfif tGrStruct.rstGetAAPPGeneral.contractStatusId is 1>Active<cfelse>Inactive</cfif> Record</td>
			</tr>
			<tr>
				<td colspan="4" class="formcheckboxrow">#displayCheckBoxes1()#</td>
			</tr>

			</table>
		</div>
		<!-- /formcontent -->
		</form>
		<!-- displayTitleForAAPPNum -->
	</div>
	<!-- /form -->
	</div>
	<!-- /HeaderDiv -->
</cffunction> <!--- displayTitleForAAPPNum --->

<cffunction name="displayTitleForHome" output="true">
	<cfargument name="tLayout">
	<cfargument name="tGrStruct">
	<cfargument name="graphicJSCfm">

	<cfset var sWindowName = ''>

	<!--- display a header form for a graphic based on an aapp --->

	<div class="form" style="margin-left:#tLayout.marginleft#px;">
		<form name="displayTitleForHome" id="displayTitleForHome" method="post">

			<div id="formContent" class="formContent" style="width=#tLayout.titlewidth#px;">
				<h1 style="text-align:left">#tGrStruct.tRepPar.formTitle# </h1>
				<table width="#tLayout.titlewidth#px" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo" summary="display report header info.">

				<tr><td ><div id="sFilterHTML"> &nbsp;</div></td></tr>
				<tr>
					<td >Report Run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:sstt')#</td>

				</tr>
				</table>
			</div>
			<!-- /formcontent -->
		</form>
		<!-- displayTitleForHome -->
	</div>
	<!-- /form -->
</cffunction> <!--- displayTitleForHome --->


<cffunction name="displayCheckBoxes1">
	<!--- this does the initial display of the checkboxes. Fund checkboxes are checked, CostCat are not --->
	<cfset var sRet = ''>
	<cfset var qAllCatCodes = application.olookup.getCostCategories(displayFormat:"primary", status:"active")>

	<cfsavecontent variable="sRet">
	<!--- this font-size determined empirically, to make it "match" the Funding Office text --->
	<div class="CheckBoxesDiv1" >
		<span class="chklabellabel">FundType:</span>
		<cfloop list="FOP,ECP,FMS" INDEX="thisFundType">
			<span class="chklabel#thisFundType#"><input type="checkbox" ID="FundType#thisFundType#" NAME="FundTypeList" VALUE="#thisFundType#"  onclick="fundMap('#thisFundType#');"  <!---  onclick="hello();"   --->   title="Click to toggle inclusion of #thisFundType# data in the graph"  checked /> #thisFundType# &nbsp;</span>
		</cfloop>
		<BR>&nbsp;&nbsp;&nbsp;<span class="chklabellabel">CostCat:</span>&nbsp;
		<!--- starts as NOT checked --->
		<input type="checkbox" ID="CostCatToggle" CLASS="chklabel" NAME="CostCatToggle" VALUE="CostCatToggle"  onclick="toggleAllCheckBoxes1();" title = "Click to toggle all the cost category checkboxes" > <span class="chklabel">All</span> &nbsp;&nbsp;&nbsp;

		<cfloop list="#valuelist(qAllCatCodes.costCatCode)#" INDEX="thisCostCat">
			<input type="checkbox" ID="CostCat#thisCostCat#" CLASS="chklabel costcatcheck" NAME="CostCatList" VALUE="#thisCostCat#" onclick="clearCostCatToggle();" title="Click to toggle inclusion of cost category #thisCostCat# data in the graph"> <span class="chklabel">#thisCostCat#</span> &nbsp;
		</cfloop>
	</div>

	<!--- this should become automatic submission afer 1.5 seconds --->
	<!--- comment out button until confident in timer
	<div style="float:left;">
		<input type="button" class="chklabel" value="Redisplay" onClick="submitAnyCheckBoxes();">
	</div>
	END of comment out --->
	<!--- / displayCheckBoxes1 --->
	</cfsavecontent>

	<cfreturn sRet>
</cffunction>


<cffunction
	name="QueryToCSV"
	access="public"
	returntype="string"
	output="false"
	hint="I take a query and convert it to a comma separated value string.">

	<!--- Define arguments. --->
	<cfargument
		name="Query"
		type="query"
		required="true"
		hint="I am the query being converted to CSV."
		/>

	<cfargument
		name="Fields"
		type="string"
		required="true"
		hint="I am the list of query fields to be used when creating the CSV value."
		/>

	<cfargument
		name="CreateHeaderRow"
		type="boolean"
		required="false"
		default="true"
		hint="I flag whether or not to create a row of header values."
		/>

	<cfargument
		name="Delimiter"
		type="string"
		required="false"
		default=","
		hint="I am the field delimiter in the CSV value."
		/>

	<!--- Define the local scope. --->
	<cfset var LOCAL = {} />

	<!---
		First, we want to set up a column index so that we can
		iterate over the column names faster than if we used a
		standard list loop on the passed-in list.
	--->
	<cfset LOCAL.ColumnNames = [] />

	<!---
		Loop over column names and index them numerically. We
		are working with an array since I believe its loop times
		are faster than that of a list.
	--->
	<cfloop
		index="LOCAL.ColumnName"
		list="#ARGUMENTS.Fields#"
		delimiters=",">

		<!--- Store the current column name. --->
		<cfset ArrayAppend(
			LOCAL.ColumnNames,
			Trim( LOCAL.ColumnName )
			) />

	</cfloop>

	<!--- Store the column count. --->
	<cfset LOCAL.ColumnCount = ArrayLen( LOCAL.ColumnNames ) />


	<!---
		Now that we have our index in place, let's create
		a string buffer to help us build the CSV value more
		effiently.
	--->
	<cfset LOCAL.Buffer = CreateObject( "java", "java.lang.StringBuffer" ).Init() />

	<!--- Create a short hand for the new line characters. --->
	<cfset LOCAL.NewLine = (Chr( 13 ) & Chr( 10 )) />


	<!--- Check to see if we need to add a header row. --->
	<cfif ARGUMENTS.CreateHeaderRow>

		<!--- Create array to hold row data. --->
		<cfset LOCAL.RowData = [] />

		<!--- Loop over the column names. --->
		<cfloop
			index="LOCAL.ColumnIndex"
			from="1"
			to="#LOCAL.ColumnCount#"
			step="1">

			<!--- Add the field name to the row data. --->
			<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#LOCAL.ColumnNames[ LOCAL.ColumnIndex ]#""" />

		</cfloop>

		<!--- Append the row data to the string buffer. --->
		<cfset LOCAL.Buffer.Append(
			JavaCast(
				"string",
				(
					ArrayToList(
						LOCAL.RowData,
						ARGUMENTS.Delimiter
						) &
					LOCAL.NewLine
				))
			) />

	</cfif>


	<!---
		Now that we have dealt with any header value, let's
		convert the query body to CSV. When doing this, we are
		going to qualify each field value. This is done be
		default since it will be much faster than actually
		checking to see if a field needs to be qualified.
	--->

	<!--- Loop over the query. --->
	<cfloop query="ARGUMENTS.Query">

		<!--- Create array to hold row data. --->
		<cfset LOCAL.RowData = [] />

		<!--- Loop over the columns. --->
		<cfloop
			index="LOCAL.ColumnIndex"
			from="1"
			to="#LOCAL.ColumnCount#"
			step="1">

			<!--- Add the field to the row data. --->
			<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#Replace( ARGUMENTS.Query[ LOCAL.ColumnNames[ LOCAL.ColumnIndex ] ][ ARGUMENTS.Query.CurrentRow ], """", """""", "all" )#""" />

		</cfloop>


		<!--- Append the row data to the string buffer. --->
		<cfset LOCAL.Buffer.Append(
			JavaCast(
				"string",
				(
					ArrayToList(
						LOCAL.RowData,
						ARGUMENTS.Delimiter
						) &
					LOCAL.NewLine
				))
			) />

	</cfloop>


	<!--- Return the CSV value. --->
	<cfreturn LOCAL.Buffer.ToString() />
</cffunction> <!--- QueryToCSV --->


</cfoutput>
</cfcomponent>
