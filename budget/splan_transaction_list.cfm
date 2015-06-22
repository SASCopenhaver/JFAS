<!---
page: splan_transaction_list.cfm

description: user can select subsets of Spend Plan Transactions to view

--->

<cfoutput>

<cfset request.pageName="SplanTransList">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "JFAS System Budget">

<!--- retrieve current PY from database --->
<cfset tPY = application.oSplan.getSplanPY() />
<cfset nCurrentPY = tPY.aRet[1].PY />

<!--- cannot select on transStatusTypeCode ( Open, Closed ), splanSectionCodeList --->
<cfparam name="form.py" default = "#nCurrentPY#" />
<cfparam name="form.startdate" default = '' />
<cfparam name="form.enddate" default = '' />
<!--- only ONE category can be selected in this report/list --->
<cfparam name="form.splanCatIdList" default = '' />
<cfparam name="form.transstatuscode" default = '' />
<cfparam name="form.transtypecode" default = '' />
<cfparam name="form.sortBy" default = 'TransDate' />
<cfparam name="form.sortDir" default = 'asc' />

<!--- etc --->

<cfset tRet = {}>
<cfset tPys = {}>
<cfset aRec = []>
<cfset form.nextTabIndex = 1>
<cfset variables.lstErrorMessages = "">
<cfset variables.lstErrorFields = "">


<cfif structKeyExists ( url, 'SortBy') >
	<!--- existence of SortBy is like a resubmit, but use most parameters from session.tsplanlistformdata --->
	<!--- retrieve the form parameters from the session.tsplanlistformdata saved before --->
	<cfif StructKeyExists (session, 'tsplanlistformdata' ) AND IsStruct ( session.tsplanlistformdata) >
		<!---
		<cfdump var="#session.tsplanlistformdata#" label="reading session structure">
		--->

		<!--- for some reason we have to do this field by field --->
		<cfset aKeys  = StructKeyArray ( session.tsplanlistformdata )>
		<cfloop index="walker" from = "1" to = "#ArrayLen(aKeys)#" >
			<!--- copy property from session structure, to form, allowing overwrite --->
			<cfset StructInsert ( form, aKeys[walker], StructFind (session.tsplanlistformdata, aKeys[walker]), true) >
		</cfloop>
	</cfif>
	<cfset structDelete( form, "btnSubmit")>
	<cfset form.sortBy = url.sortBy />
	<cfset form.sortDir = url.sortDir />
	<!--- update the session structure with the latest --->
	<cfset session.tsplanlistformdata = Duplicate( form ) >

	<!---
	<cfdump var="#form#" label="form after reading from session">
	<cfabort>
	--->

<cfelse>

	<cfset form.sortBy = "TransDate" />
	<cfset form.sortDir = "asc" />

</cfif>

<!--- for coding convenience --->
<cfset formSortBy = form.sortby>
<cfset formSortDir = form.sortdir>

<cfif isDefined ( "url.actionMode") >
	<cfset form.actionMode = url.actionMode>
</cfif>

<!--- save these form parameters for use if the user comes in with a sort request later --->
<cfif structKeyExists (session, "tsplanlistformdata") >
	<cfset StructClear ( session.tsplanlistformdata ) >
<cfelse>
	<cfset session.tsplanlistformdata = {} >
</cfif>

<cfset session.tsplanlistformdata = Duplicate( form ) >
<!---
<cfdump var="#session.tsplanlistformdata#" label="session.tsplanlistformdata after store to session">
<cfabort>
--->


<!---
<cfif isDefined("form.btnSubmit") OR structKeyExists ( url, 'SortBy' ) >
--->
	<!--- ALWAYS get the correctly-sorted data from the database, and display it --->
	<!--- use "formdata" to get a subset of the "Form" variables that are displayed to the user, and to translate the field names/meanings --->

	<cfset formdata = {} >

	<cfif form.py NEQ 0>
		<cfset formdata.py = form.py>
	</cfif>
	<cfif form.splanCatIdList NEQ ''>
		<cfset formdata.splanCatIdList = form.splanCatIdList>
	</cfif>
	<cfif form.startdate NEQ ''>
		<cfset formdata.startDate = form.startdate>
	</cfif>
	<cfif form.enddate NEQ ''>
		<cfset formdata.endDate = form.enddate>
	</cfif>
	<cfif form.transstatuscode NEQ ''>
		<cfset formdata.transStatusCode = form.transstatuscode>
	</cfif>
	<cfif form.transtypecode NEQ ''>
		<cfset formdata.transtypecode = form.transtypecode>
	</cfif>
	<cfset formdata.sortby = form.SortBy>
	<cfset formdata.sortdir = form.SortDir>


	<!--- GET THE DATA --->


	<!---
		<cfset formdata.dumpargs = true>
	--->

	<cfset tRet = application.osplan.getSplanListFopSum ( argumentCollection: "#formdata#") />

	<cfif (tRet.status EQ false ) >
		<cfdump var="#tRet.sErrorMessage#">
		<cfabort>
	</cfif>

	<cfset aRec = duplicate (Tret.aRet) />
	<!---
<cfdump var="#tRet#">
<cfabort>
--->

<!---
</cfif> <!--- isDefined("form.btnSubmit") OR structKeyExists ( url, 'SortBy') --->
--->

<!--- data has been retrieved for the report --->

<!--- queries to retrieve reference data to populate drop-down lists --->
<cfset tgetLuCodes = application.oSplan.getLuCodes( codetype: 'TRANS_STATUS_CODE') />
<cfset aStatusCodes = tgetLuCodes.aRet />

<cfset tgetLuCodes = application.oSplan.getLuCodes( codetype: 'TRANS_TYPE_CODE') />
<cfset aTypeCodes = tgetLuCodes.aRet />

<cfset tTopCodes = application.oSplan.getTopSplanCodes(  ) />
<cfset aTopCodes = tTopCodes.aRet />

<cfset tPYs = application.oSplan.getPysWithSplan() />
<cfset aPYs = duplicate(tPYs.aRet) />

<!--- ****** begin HTML --->

<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">

<!--- page-specific Javascript --->
<script>
	function resetPars() {
		// reset the selection parameters, but don't submit

		$('##idpy').val(#ncurrentpy#);
		$('##idStartDate').val('');
		$('##idEndDate').val('');
		$('##idsplancatidlist').val('');
		$('##idtransstatuscode').val('');
		$('##idtranstypecode').val('');

	}
	<!--- JS, with CFOUTPUT --->
</script>

<!--- this appears below the header, and the nagivation submenus --->
<div class="ctrSubContent">

	<div id="budgetHeader">
		<div id="budgetSubheaderLeft">
			Spend Plan Transactions
		</div>
		<div id="budgetSubheaderRight">
			#DisplaySpendPlanOptionsButton ( request.pageName )#
		</div>
	</div>
	<!-- budgetHeader -->

	<div style="clear:both;"></div>

	<!--- show error / confirmation messages --->
	<cfif listLen(variables.lstErrorMessages) gt 0>

		<div class="errorList">
		<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters="~">
			<li>#listItem#</li>
		</cfloop>
		</div><br />
	</cfif>

	<cfif isDefined("url.showConfirm")>
		<div class="confirmList">
		<li>Information saved successfully.</li>
		</div><br />
	</cfif>

	<!--- this page submits to itself --->
	<FORM name="frmSplanEdit" action="#cgi.SCRIPT_NAME#" method="post" onSubmit="return ValidateSplanListForm(this);" >

	<!--- *********** show dropdowns, dates, and GO at the top of page --->
	<div id = "splanOptionsRow">

		<div class="splanOptionsRowDropdown">
		<!--- PY --->
		<select name="py" id="idpy" tabindex="#form.nextTabIndex#">
			<option value="0">All PYs</option>
			<cfloop from="1" to="#arrayLen( aPYs )#" index="walker">
				<option value="#aPYs[ walker ].py#"
					<cfif aPYs[ walker ].py eq form.py>selected</cfif>>
					#aPYs[ walker ].py#</option>
			</cfloop>
		</select>
		<cfset form.nextTabIndex = form.nextTabIndex + 1>
		</div>

		<!--- dates --->
		<div  class="splanOptionsRowDropdown">
		<input id="idStartDate" name="StartDate" type="text" class="datepicker" placeholder="From" value="#form.startdate#" title="Earliest Spend Plan Transaction Date to include"  tabindex="#form.nextTabIndex#">
		<cfset form.nextTabIndex = form.nextTabIndex + 1>

		<input id="idEndDate" name="EndDate" type="text" class="datepicker"  placeholder="To" value="#form.enddate#" title="Latest Spend Plan Transaction Date to include" tabindex="#form.nextTabIndex#">
		<cfset form.nextTabIndex = form.nextTabIndex + 1>
		</div>
		<!-- /dates -->

		<!--- category --->
		<div style="float: left; padding: 0; margin: 3px 0 0 0 !important;">
			<!--- Category (splancatidlist) --->
			<select name="splancatidlist" id="idsplancatidlist"  class="splanSelectTrans" tabindex="#form.nextTabIndex#">
				<option value="" >All Categories</option>
				<cfloop from="1" to="#arrayLen( aTopCodes )#" index="walker">
					#BuildCatOption( tCat=aTopCodes[ walker ], selectedValue=form.splanCatIdList, triggerFlag = "TransDisplay", bWithPrefix=true, bBuildDisplayOnly = false)#
				</cfloop>
			</select>
			<cfset form.nextTabIndex = form.nextTabIndex + 1>
		</div>

		<div  class="splanOptionsRowDropdown">
			<!--- Status--->
			<select name="transstatuscode" id="idtransstatuscode"  class="splanSelectTrans" tabindex="#form.nextTabIndex#">
				<option value="">All Status</option>
				<cfloop from="1" to="#arrayLen( aStatusCodes )#" index="walker">
					<option value="#aStatusCodes[ walker ].code#"
						<cfif aStatusCodes[ walker ].code eq form.transstatuscode>selected</cfif>>
						#aStatusCodes[ walker ].codedesc#</option>
				</cfloop>
			</select>
			<cfset form.nextTabIndex = form.nextTabIndex + 1>

			<!--- Type (Init, trns) --->
			<select name="transtypecode" id="idtranstypecode"  class="splanSelectTrans" tabindex="#form.nextTabIndex#">
				<option value="">All Types</option>
				<cfloop from="1" to="#arrayLen( aTypeCodes )#" index="walker">
					<option value="#aTypeCodes[ walker ].code#"
						<cfif aTypeCodes[ walker ].code eq form.transtypecode>selected</cfif>>
						#aTypeCodes[ walker ].codedesc#</option>
				</cfloop>
			</select>
			<cfset form.nextTabIndex = form.nextTabIndex + 1>

		</div>
		<!-- /last selects -->

		<input name="btnSubmit" id = "btnSubmit" type="submit" value="Go" />
		<input name="btnTReset" id = "btnTReset" type="button" value="Reset" onclick="resetPars();"/>

	</div>
	<!-- END OF splanOptionsRow (controls and buttons) -->

	<div style="clear:both;"></div>

	<!---
	<cfif isDefined("form.btnSubmit")  OR structKeyExists ( url, 'SortBy' ) >
	--->
	<!--- breaking code alignment --->
	<!--- *********** THE ACTUAL REPORT --->
	<!--- modelled on aapp/aapp_adjust_fop.cfm --->

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
		<tr>
			#DisplaySortableColumnHeading( CGI.SCRIPT_NAME, 'transdate', formSortBy, formSortDir, 'Date','center')#
			#DisplaySortableColumnHeading( CGI.SCRIPT_NAME, 'splantransid', formSortBy, formSortDir, 'Trans No', 'center')#
			#DisplaySortableColumnHeading( CGI.SCRIPT_NAME, 'transdesc', formSortBy, formSortDir, 'Description','center')#
			#DisplaySortableColumnHeading( CGI.SCRIPT_NAME, 'splancatdesc', formSortBy, formSortDir, 'Category','center')#
			#DisplaySortableColumnHeading( CGI.SCRIPT_NAME, 'amount', formSortBy, formSortDir, 'Amount', 'right')#
			#DisplaySortableColumnHeading( CGI.SCRIPT_NAME, 'fopamount', formSortBy, formSortDir, 'FOP Amount', 'right')#
			#DisplaySortableColumnHeading( CGI.SCRIPT_NAME, 'transstatuscode', formSortBy, formSortDir, 'Status')#
		</tr>
		<cfset tempVal = "" />
		<cfif ArrayLen(aRec) neq 0>
			<cfset splanTotal = 0>
			<cfset fopTotal = 0>
			<cfloop index="currentRow" from = "1" to = "#arrayLen(aRec)#">

				<tr <cfif currentrow mod 2>class="AltRow"</cfif>>

					<td width="8%">#dateFormat(aRec[currentRow].transdate, "mm/dd/yyyy")#</td>
					<td width="8%" class="tdspnum" style="padding: 0 10px 0 10px !important;">SP #NumberFormat(aRec[currentRow].splantransid,'0000')#&nbsp;</td>
					<td width="*" scope="row">
						<a href="javascript:splanView( #aRec[currentRow].splantransid# );" title="#aRec[currentRow].transnote#">#aRec[currentRow].transdesc#</a></td>
					<td width="20%">#aRec[currentRow].splancatdesc#</td>
					<td width="10%"  align="right">#numberformat(aRec[currentRow].amount, "$9,999")#</td>
					<!--- fopamount should be NULL if there are no fop records --->
					<td width="10%"  align="right"><cfif aRec[currentRow].fopamount NEQ ''>#numberformat(aRec[currentRow].fopamount, "$9,999")#<cfelse>#aRec[currentRow].fopamount#</cfif></td>
					<td width="6%">#aRec[currentRow].transstatusdesc#</td>
				</tr>
				<cfset splanTotal += aRec[currentRow].amount>
				<cfif IsNumeric(aRec[currentRow].fopamount)><cfset fopTotal += aRec[currentRow].fopamount></cfif>
			</cfloop>

			<!--- show totals --->
			<tr>
				<td></td><td></td><td></td><td><strong>Totals</strong></td>
				<cfif splanTotal EQ fopTotal>
					<cfset sStyle = "">
				<cfelse>
					<cfset sStyle = 'style="color:red;"'>
				</cfif>
				<td align="right"><strong>#numberformat(splanTotal,"$9,999")#</strong></td>
				<td align="right" #sStyle#><strong>#numberformat(fopTotal,"$9,999")#</strong></td>
			</tr>
		<cfelse>
			<tr>
				<td colspan="7" align="center" style="font-weight: bold;">
					<br><br>No Spend Plan Transactions meet your selections.<br><br><br>
				</td>
			</tr>
		</cfif>
	</table>
	<!---
	</cfif> <!--- isDefined("form.btnSubmit") --->
	--->
	<!--- END of THE ACTUAL REPORT --->
	</FORM>

</div>
<!-- ctrSubContent -->

<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">

</cfoutput>