<!---
page: splan_display_settings.cfm

description: user can customize the appearance of the Spend Plan

--->

<cfoutput>

<cfset request.pageName="SplanDisplaySettings">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "JFAS System Budget">

<cfif NOT isDefined("form.btnSubmit")>
	<!--- first time into the form --->
	<!--- retrieve current PY from database --->
	<cfset tPY = application.oSplan.getSplanPY() />
	<cfset nCurrentPY = tPY.aRet[1].PY />
	<cfset form.PY = nCurrentPY>
<cfelse>
	<!--- coming back with new parameters --->

</cfif>

<!--- define the Display Setting for the Current PY Spend Plan --->
<cfparam name="form.actionMode" default="Edit">
<cfparam name="form.CancelReturn" default="SpendPlan">
<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default="" />
<!--- default to "Initial spend plan date through current date"  --->
<cfparam name="form.radSpendingBreakdown" default = 1>
<!--- default to "do not save" settings --->
<cfparam name="form.radSaveSettings" default = 1>
<cfparam name="form.todate" default = "#DateFormat(Now(), 'mm/dd/yyyy')#">

<cfif isDefined ( "url.actionMode") >
	<cfset form.actionMode = url.actionMode>
</cfif>
<cfif isDefined ( "url.CancelReturn") >
	<cfset form.CancelReturn = url.CancelReturn>
</cfif>

<!--- get the first date of a Splan in the given PY --->
<cfset tFirstSplan = application.oSplan.getFirstSplanDate( form.PY ) />
<cfset sFirstSplanDate = tFirstSplan.aRet[1].texttransdate />
<cfif NOT IsDefined ( 'form.customdate' ) >
	<cfset form.customdate = arrayNew(1)>
	<!--- default to first Splan Date in the current PY --->
	<cfset form.customdate[1] = sFirstSplanDate>
	<cfloop index = "walker" from = "2" to = "14">
		<cfset form.customdate[walker] = ''>
	</cfloop>
</cfif>

<cfif isDefined("form.btnSubmit")>

	<!--- SAVE to the database, and the session scope ---->
	<cfset tRet = {} >

	<!--- SAVE THE DATA from the form into the session scope, and possibly the database --->
	<cfset tRet = application.oSplan.saveSplanDisplaySettings( formData: form )>

	<cfif tRet.status EQ true >
		<!--- save was successful. Display the current splan --->
		<cflocation url= "#application.paths.budgetdir#splan_main.cfm" />

	<cfelse>
		<!--- slErrorMessages failed. Set list of error messages for later display --->
		<cfset variables.lstErrorMessages = tRet.slErrorMessages />
		<cfset variables.lstErrorFields = tRet.slErrorFields />
		<!--- note:  continues on in this instance of the page. Allow edit to fix problems --->
		<cfset form.actionMode = "Edit">
	</cfif>
	<!--- END of isDefined btnSubmit --->
</cfif>

<!--- always use the values from session.userPreferences.tMySplan --->

<cfscript>
form.py = session.userPreferences.tMySplanNow.py;
form.radspendingbreakdown = session.userPreferences.tMySplanNow.radspendingbreakdown;
form.todate = session.userPreferences.tMySplanNow.todate;
form.radSaveSettings = session.userPreferences.tMySplanNow.radSaveSettings;

for ( walker = 1; walker LE 14; walker += 1) {
	temp = session.userPreferences.tMySplanNow.CustomDate[walker];
	target = "CUSTOMDATE_#walker#";
	structinsert(form, target, temp, 1);
}

// data has been sent to the database, and/or retrieved
structDelete (form, "btnSubmit");
tRet = structNew() ;
tFormFromDB = structNew() ;

tPY = structNew() ;
tPYs = structNew() ;

tgetLuCodes = structNew() ;
aStatusCodes = arrayNew(1) ;

tTopCodes = structNew() ;
aTopCodes = arrayNew(1) ;

tRet.status = true ;
form.nextTabIndex = 1 ;

// queries to retrieve reference data to populate drop-down lists
tPYs = application.oSplan.getPysWithSplan();
aPYs = duplicate(tPYs.aRet);
</cfscript>

<!--- ready to view form.  Data for record may or may not pre-exist --->

<!--- begin HTML --->

<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">

<!--- this page uses routines in headerDisplayBudgetFunctions.cfm, which is included in header.cfm, above --->

<!--- this appears below the header, and the navigation submenus --->
<div class="ctrSubContent">

	<div id="budgetHeader">
		<div id="budgetSubheaderLeft">
			Spend Plan Display Settings
		</div>
		<div id="budgetSubheaderRight">
			&nbsp;
		</div>
	</div>
	<!-- budgetHeader -->
	<div style="clear:both;"></div>

	<!--- show error / confirmation messages --->
	<cfif listLen(variables.lstErrorMessages ,"~") gt 0>

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

	<!--- submits to itself. splantransid is in form scope --->

	<FORM name="frmDisplaySettings" action="#cgi.SCRIPT_NAME#?CancelReturn=View" method="post" onSubmit="return ValidateDisplaySettingsForm(this);"  >

	<!--- start the "TABLE" --->
	<div class="jdivtable">

	<!--- program year (PY) --->

	<div class = "leftcell">
	Program Year
	</div> <!--- leftcell --->

	<div class = "rightcell">
		<!--- always editable --->
		<select name="PY" id="idDisplayPY" tabindex="#form.nextTabIndex#">
			<option value="">All PY</option>
			<cfloop from="1" to="#arrayLen( aPYs )#" index="walker">
				<option value="#aPYs[ walker ].py#"
					<cfif aPYs[ walker ].py eq form.py>selected</cfif>>
					#aPYs[ walker ].py#</option>
			</cfloop>
		</select>
		<cfset form.nextTabIndex = form.nextTabIndex + 1>
	</div> <!--- rightcell --->
	<div class="displayspacer">&nbsp;</div>

	<!--- spending breakdown --->
	<div class = "leftcell">
		Spending Breakdown
	</div> <!--- leftcell --->

	<div class = "rightcell">
		<input type="radio" name="radSpendingBreakdown" id="idSpendingBreakdown_1" value="1" tabindex="#form.nextTabIndex#" <cfif form.radSpendingBreakdown EQ 1>checked</cfif> onClick="changeSpending(1);" />
		Default (initial spend plan through current date)
		<cfset form.nextTabIndex = form.nextTabIndex + 1>
		<br />

		<input type="radio" name="radSpendingBreakdown" id="idSpendingBreakdown_2" value="2" tabindex="#form.nextTabIndex#" <cfif form.radSpendingBreakdown EQ 2>checked</cfif> onClick="changeSpending(2);"  />
		By Quarter
		<cfset form.nextTabIndex = form.nextTabIndex + 1>
		<br />

		<input type="radio" name="radSpendingBreakdown" id="idSpendingBreakdown_3" value="3" tabindex="#form.nextTabIndex#" <cfif form.radSpendingBreakdown EQ 3>checked</cfif> onClick="changeSpending(3);"  />
		By Month
		<cfset form.nextTabIndex = form.nextTabIndex + 1>
		<br />

		<input type="radio" name="radSpendingBreakdown" id="idSpendingBreakdown_4" value="4" tabindex="#form.nextTabIndex#" <cfif form.radSpendingBreakdown EQ 4>checked</cfif> onClick="changeSpending(4);"  />
		Custom (specify columns below)
		<cfset form.nextTabIndex = form.nextTabIndex + 1>
		<br />

	</div> <!--- rightcell --->
	<div class="displayspacer">&nbsp;</div>


	<!--- ToDate --->
	<div class = "leftcell">
		Show Transactions Through
	</div> <!--- leftcell --->

	<div class = "rightcell">
		<!--- always editable --->
		<input id="idDisplayToDate" name="ToDate" type="text" class="datepicker NonCustomDateThrough" placeholder="Through" value="#form.todate#" title="Latest Spend Plan Transaction Date to Include"  tabindex="#form.nextTabIndex#">
		<cfset form.nextTabIndex = form.nextTabIndex + 1>
	</div> <!--- rightcell --->
	<div class="displayspacer">&nbsp;</div>


	<!--- Custom Columns (Dates) --->
	<div class = "leftcell">
		Custom Columns
	</div> <!--- leftcell --->

	<div class = "rightcell">
		<!--- never editable --->
		<input id="idCustomDate1" name="CustomDate_1" type="text" class="NonCustomDateStart inputReadonly" value="#form.customdate[1]#" title="Date of Earliest Spend Plan Transaction in the PY"  disabled> (initial spend plan)
	</div> <!--- rightcell --->


	<cfset lastdaterow = 1>
	<!--- calculate index of last non-blank date --->
	<cfloop index = "walker" from = "2" to = "14">
		<cfset target = "form.CustomDate_"&walker>
		<cfset fvalue = Evaluate("#target#")>
		<cfif NOT (fvalue EQ '' AND walker GT 4 )>
			<cfset lastdaterow = walker>
		<cfelse>
			<cfbreak>
		</cfif>
	</cfloop>
	<cfloop index = "walker" from = "2" to = "14">
		<!--- display a non-blank date in ONE div --->
		<cfset sRowText = ''>
		<cfset target = "form.CustomDate_"&walker>
		<cfset fvalue = Evaluate("#target#")>
		<div class = "bigleftcell" id="idCustomDateRow#walker#" <cfif walker GT lastdaterow >  style="display:none;" </cfif> >
			<!--- always put the date field into the cell --->
			<cfset sRowText &= '<input id="idCustomDate#walker#" name="CustomDate_#walker#" type="text" class="datepicker CustomDate" value="#fvalue#" title="Enter a date to create a new column"  tabindex="#form.nextTabIndex#">'>
			<cfset form.nextTabIndex = form.nextTabIndex + 1>
			<cfset sRowText &= '<span onClick="deleteDisplayColumn( #walker# );"><img src="#application.paths.images#close.png" class="filterTextImg CustomDate_delete" border="0" alt="Delete this date" ></span>' >
			<!--- " TextPad --->

			#sRowText#
		</div> <!--- bigleftcell --->

	</cfloop>
	<div class = "bigleftcell">
		<span onClick="addDisplayColumn( #walker# );" id="AddCustomDate">+ Add custom column</span>
	</div> <!--- bigleftcell --->

	<div class="displayspacer">&nbsp;</div>

	<!--- save settings --->
	<div class = "leftcell" >
		Save Settings
	</div> <!--- leftcell --->

	<div class = "rightcell">
		<input type="radio" name="radSaveSettings" id="idSaveSettings_1" value="1" tabindex="#form.nextTabIndex#" <cfif form.radSaveSettings EQ 1>checked</cfif> />
		Only keep these settings for this session
		<cfset form.nextTabIndex = form.nextTabIndex + 1>
		<br />

		<input type="radio" name="radSaveSettings" id="idSaveSettings_2" value="2" tabindex="#form.nextTabIndex#" <cfif form.radSaveSettings EQ 2>checked</cfif> />
		Keep these settings for the next time I log in
		<cfset form.nextTabIndex = form.nextTabIndex + 1>
		<br />

	</div> <!--- rightcell --->

	<div class="displayspacer">&nbsp;</div>

	<div class = "leftcell">
		&nbsp;
	</div> <!--- leftcell --->

	<div class = "rightcell">
		<!--- this is the INCOMING actionMode --->
		<input type="hidden" name="actionMode" value="#form.actionMode#" />
		<input type="hidden" name="userID" value="#session.userID#" />

		<div class="BudgetButtons"  style="text-align: right;" >
			<input name="btnSubmit" type="submit" value="Save" />
			<input name="btnClear" type="reset" value="Reset" />
			<input name="btnCancel" type="button" value="Cancel" onClick="CancelReturn( '#form.CancelReturn#' );" />
		</div>
		<!-- buttons -->
	</div> <!--- rightcell --->
	</div> <!--- jdivtable --->

	</form>
</div>
<!-- ctrSubContent -->

<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">
<script>

	<!--- this JS is AFTER the footer, which also has $("document").ready  functions --->
	<!--- JS, with CFOUTPUT --->
	$("document").ready(function(){
		setLastDateRow ( #lastdaterow# ) ;
		changeSpending ( #form.radSpendingBreakdown# ) ;
	}); // ready

</script>

</cfoutput>