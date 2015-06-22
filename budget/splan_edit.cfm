<!---
page: splan_edit.cfm

description: user can select subsets of Spend Plan Transactions to view

This can operate in Add, Edit, or View (Read Only) Mode

--->
<!--- modelled on aapp\aapp_contractor.cfm --->

<cfoutput>

<cfset request.pageName="SplanEdit">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "JFAS System Budget">

<!--- get current Spend Plan Data --->

<cfparam name="form.actionMode" default="Add">
<cfparam name="form.CancelReturn" default="View">
<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default="" />
<cfparam name="form.splanTransID" default = 0>
<cfparam name="form.PY" default = 0>
<cfparam name="form.transDesc" default = ''>
<cfparam name="form.transNote" default = ''>
<cfparam name="form.transstatuscode" default = 'O'>
<cfparam name="form.amount" default = ''>
<cfparam name="form.tocategory" default = '0'>
<cfparam name="form.fromcategory" default = '0'>
<cfparam name="form.slSplanTransDetid" default = ''>
<cfparam name="form.TransTypeCode" default = ''>
<cfparam name="form.sBudgetHeaderLeft" default = 'Edit Spend Plan Transaction'>
<cfparam name="form.createdate" default = ''>
<cfparam name="form.createuser" default = ''>
<cfparam name="form.updatedate" default = ''>
<cfparam name="form.updateuser" default = ''>

<!--- nFopCountBeforeReport is number of fops associated with a _det record, before you see a link to multiple fops report --->
<!--- this should be 30 --->
<cfset nFopCountBeforeReport = 30 >
<cfset tRet = structNew()>
<cfset tFormFromDB = structNew()>
<cfset tFop = structNew()>

<cfset tPY = structNew()>

<cfset tgetLuCodes = structNew()>
<cfset aStatusCodes = arrayNew(1)>

<cfset tTopCodes = structNew()>
<cfset aTopCodes = arrayNew(1)>

<cfset tRet.status = true>
<cfset form.nextTabIndex = 1>

<cfif isDefined ( "url.actionMode") >
	<cfset form.actionMode = url.actionMode>
</cfif>
<cfif isDefined ( "url.CancelReturn") >
	<cfset form.CancelReturn = url.CancelReturn>
</cfif>

<!--- be SURE Edit always cancels to VIEW --->
<CFIF form.actionmode EQ "Edit">
	<CFSET form.CancelReturn = "View">
</cfif>

<cfif isDefined ( "url.splanTransID") and isNumeric ( url.splanTransID )>
	<cfset form.splanTransID = url.splanTransID>
</cfif>

<!--- retrieve current PY from database --->
<cfset tPY = application.oSplan.getSplanPY() />
<cfset nCurrentPY = tPY.aRet[1].PY />

<!--- queries to retrieve reference data to populate drop-down lists --->
<cfset tgetLuCodes = application.oSplan.getLuCodes( codetype: 'TRANS_STATUS_CODE') />
<cfset aStatusCodes = tgetLuCodes.aRet />

<cfif isDefined("form.btnSubmit")>
	<CFIF form.actionMode NEQ "View">

		<!--- Coming from Add or Edit.  SAVE to the database ---->
		<cfset structClear( tRet ) >

		<!--- SAVE THE DATA. Looks at form.actionMode = Add or Edit --->
		<cfset tRet = application.oSplan.saveSplanDetails( formData: form )>

		<cfif form.ActionMode EQ "Add">
			<!--- get the ID of the newly-inserted record from saveSplanDetails --->
			<!--- note that sMessage is NOT an errormessage --->
			<!--- IF there was an error, then form.splanTransID will become 0, and there is no corresponding record in the database --->
			<cfset form.splanTransID = tRet.sMessage>
		</CFIF> <!--- form.ActionMode EQ "Add" --->
		<!---
		<CFDUMP VAR="#tRet#" label="return from saveSplanDetails">
		<CFDUMP VAR="#form#" label="form after saveSplanDetails">
		<cfabort>
		--->
		<cfif tRet.status EQ true >
			<!--- save was successful. Redirect back to this page in VIEW mode.  The redirect will get data from the database, which is a good verification that things worked --->
			<cfset structDelete( form, "btnSubmit" )>
			<cfset cmd = "#cgi.SCRIPT_NAME#?actionmode=view&splanTransID=#form.splanTransID#&showConfirm=true" />
			<!---
			<cfdump var="cmd #cmd#">
			<cfabort>
			--->
			<cflocation url= "#cmd#" />

		<cfelse>
			<!--- save failed. Set list of error messages for later display --->
			<cfset variables.lstErrorMessages = tRet.slErrorMessages />
			<cfset variables.lstErrorFields = tRet.slErrorFields />
			<!--- note:  continues on in this instance of the page. Allow edit to fix problems --->
			<cfif form.splanTransID EQ 0 >
				<cfset form.actionMode = "Add">
			<cfelse>
				<cfset form.actionMode = "Edit">
			</cfif>
		</cfif>
		<!--- END coming from add or edit --->
	<cfelse>
		<!--- coming from View to Edit --->
		<cfset form.ActionMode = 'Edit'>
	</cfif>
</cfif> <!--- isDefined btnSubmit --->

<!--- ready to view form.  Data for record may or may not pre-exist --->

<cfif tRet.status EQ true>
	<!--- we did NOT have a problem with saving the previous version of this form --->
	<cfif listFindNoCase ( "View,Edit", actionMode) NEQ 0 >

		<!--- see if there is data in the database.  There will be none, if there were errors on an add --->
		<cfif form.splanTransID NEQ 0>
			<!--- GET THE DATA (NOT FOP) --->
			<cfset tFormFromDB = application.oSplan.getSplanDetails( PY: form.PY, splanTransIdList: '#form.splanTransID#')>

			<cfif isDefined ( 'tFormFromDB.aRet' ) AND ArrayLen(tFormFromDB.aRet) NEQ 0>
				<!--- preload into form fields --->
				<!--- [1] is FROM, [2] is TO --->
				<cfset form.PY = tFormFromDB.Aret[1].PY/>
				<cfset form.splanTransID = tFormFromDB.Aret[1].splanTransID />
				<cfset form.transdesc = tFormFromDB.Aret[1].transdesc />
				<cfset form.transnote = tFormFromDB.Aret[1].transnote />
				<cfset form.transstatuscode = tFormFromDB.Aret[1].transstatuscode />
				<cfset form.amount = tFormFromDB.Aret[1].amount />
				<cfset form.tocategory = tFormFromDB.Aret[1].splancatid  />

				<!--- for INIT splans, there is NO FROM --->
				<cfif arrayLen(tFormFromDB.Aret) GT 1>
					<cfset form.fromcategory = tFormFromDB.Aret[2].splancatid />
				<cfelse>
					<cfset form.fromcategory = 0>
					<cfset form.FROMsplantransdetid = 0  />
				</cfif>
				<cfset form.slSplanTransDetid = tFormFromDB.slSplanTransDetid />
				<cfset form.TransTypeCode = tFormFromDB.Aret[1].TransTypeCode />
				<cfset form.createuser = tFormFromDB.Aret[1].createuser />
				<cfset form.createdate = tFormFromDB.Aret[1].createdate />
				<cfset form.updateuser = tFormFromDB.Aret[1].updateuser />
				<cfset form.updatedate = tFormFromDB.Aret[1].updatedate />
			<cfelse>
				<cfdump var="THERE IS NO RECORD AND YOU THOUGHT THERE WOULD BE ONE">
				<CFABORT>
			</cfif>
		<cfelse>
			<!--- Add --->
			<cfset form.py = nCurrentPY />
			<cfset form.TransTypeCode = "TRNS" />
			<cfset form.actionMode EQ 'Add'>

		</cfif>
	<cfelse>
		<!--- getting ready to display, after there was an error saving an Add transaction --->
		<cfset form.py = nCurrentPY>
		<cfset form.actionMode EQ 'Add'>
		<cfset form.TransTypeCode = "TRNS" />

	</cfif> <!--- there was data in the database --->
</cfif> <!--- we did NOT have a problem with the previous submission of this form --->

<!--- data has been sent to the database, and/or retrieved --->
<cfset structDelete (form, "btnSubmit")>

<cfif  form.actionMode EQ 'view'>
	<cfset form.sBudgetHeaderLeft = 'Spend Plan Transaction' >
<cfelseif  form.actionMode EQ 'Add'>
	<cfset form.sBudgetHeaderLeft = 'Add Spend Plan Transaction' >
<cfelse>
	<!--- this is Edit --->
	<cfset form.sBudgetHeaderLeft = 'Edit Spend Plan Transaction' >
</cfif>

<!--- list of splan codes depends on the (single) PY in this form.  We also need the available balance for each spend plan category. --->
<cfset tTopCodes = application.oSplan.getTopSplanCodes( PY=form.PY ) />
<cfset aTopCodes = tTopCodes.aRet />

<cfset tCatSum = application.oSplan.getSplanCatSum( PY=form.PY ) />
<cfset aCatSum = tCatSum.aRet />

<cfscript>

	// build array with splancatid, and a parallel one with the category amount, and a third with the description
acatbuiltcode = "var acatid = [];
	var acatamt = [];
	var acatdesc = [];";


	for (walker = 1; walker LE ArrayLen ( aTopCodes ) ; walker += 1)  {
		cattot = 0;

		for ( walker2 = 1; walker2 LE ArrayLen ( aCatSum ) ; walker2 += 1) {
			if ( aCatSum[walker2].splancatid EQ aTopCodes[walker].splancatid ) {
				cattot = aCatSum[walker2].amount;
				break;
			}
		} // inner loop

		walkerm1 = walker - 1;
		aTopCodes[walker].cattot = cattot;
		acatbuiltcode &= "acatid[#walkerm1#]=#aTopCodes[walker].splancatid#; acatamt[#walkerm1#]=#cattot#; acatdesc[#walkerm1#]='#aTopCodes[walker].splancatdesc#'; ";

	}
</cfscript>

<!---
<cfdump var="#tgetLuCodes#" label="tgetLuCodes at BEGIN HTM">
<cfdump var="#tTopCodes#" label="tTopCodes at BEGIN HTM">
<cfdump var="#tFormFromDB#" label="tFormFromDB at BEGIN HTML">
<cfdump var="#form#" label="form at BEGIN HTM">
<cfabort>
--->


<!--- begin HTML --->
<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">
<!--- this page uses routines in headerDisplayBudgetFunctions.cfm, which is included in header.cfm, above --->
<!--- this appears below the header, and the navigation submenus --->
<div class="ctrSubContent">

	<div id="budgetHeader">
		<div id="budgetSubheaderLeft" class="budgetSubheaderLeft">
			#form.sBudgetHeaderLeft#
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
	<!--- this says "if user cancels, return to this page in #form.CancelReturn# mode" --->

	<FORM name="frmSplanEdit" action="#cgi.SCRIPT_NAME#?CancelReturn=#form.CancelReturn#" method="post"
	onSubmit="return validateSplanEditForm(this);"     >

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">

	<!--- program year (PY) --->

	<tr valign="top">
		<td scope="row" class="LeftLabelSmallSpace">
			Program Year
		</td>
		<td class="RightPad" >
			<!--- not editable, simple text --->
			#form.PY#
			<input type="hidden" name = "PY" id="idPY" value="#form.py#" />
		</td>
	</tr>
	<!--- transaction number --->

	<cfif form.ActionMode NEQ 'Add' >
		<!--- system generated, not editable --->
		<tr valign="top">
			<td scope="row" class="LeftLabelSmallSpace" >
				Transaction No.
			</td>
			<!--- splantransID is always read-only, and never has an error --->
			<td  class="RightPad" >
				<!--- not editable, simple text --->
				SP #NumberFormat(form.splanTransID, '0000')#
				<input type="hidden" name = "splanTransID" id="idsplanTransID" value="#form.splanTransID#" />
			</td>
		</tr>
	<cfelse>
		<input type="hidden" name="splanTransID" value=#form.splanTransID# />
	</cfif>

	<!--- description --->
	<tr valign="top">
		<td scope="row" class="LeftLabelSmallSpace" >
			Description
		</td>
		<td class="RightPad" >
			<!--- not editable for INIT --->
			<cfif form.TransTypeCode EQ "INIT" AND form.actionMode NEQ 'Add'>
				<cfset isReadOnly = true>
			<cfelse>
				<cfif form.actionMode NEQ 'View'><cfset isReadOnly = false><cfelse><cfset isReadOnly = true></cfif>
			</cfif>
			<cfif NOT isReadOnly>
				<!--- editable --->
				<input type="text" name="transdesc" id="idtransdesc" size="50" maxlength="50"  value="#form.transdesc#"
				tabindex="#form.nextTabIndex#" #BuildInputClass ( 'TransDesc', variables.lstErrorFields, isReadOnly )#  />
				<cfset form.nextTabIndex = form.nextTabIndex + 1>
			<cfelse>
				<!--- not editable, simple text --->
				#form.transdesc#
				<input type="hidden" name = "transdesc" id="idtransdesc" value="#form.transdesc#" />
			</cfif>
		</td>
	</tr>

	<!--- notes --->
	<tr valign="top">
		<td scope="row" class="LeftLabelSmallSpace" >
			Notes
		</td>
		<td class="RightPad" >
			<!--- editable --->
			<cfif form.actionMode NEQ 'View'>
				<cfset isReadOnly = false>
				<textarea name="transNote" rows="5" cols="35" id="idtransnote"
				tabindex="#form.nextTabIndex#" #BuildInputClass ( 'transNote', variables.lstErrorFields, IsReadOnly )#
				onKeyDown="textCounter(this, 200);" onKeyUp="textCounter(this, 200);" >#form.transNote#</textarea>
				<cfset form.nextTabIndex = form.nextTabIndex + 1>
			<cfelse>
				<cfset isReadOnly = true>
				<div class="wordwrapcontent">#form.transNote#</div>
				<input type="hidden" name = "transnote" id="idtransnote" value="#form.transnote#" />
			</cfif>
		</td>
	</tr>

	<cfif  form.actionMode EQ 'view'>
		<!--- CreateDateUser --->
		<tr valign="top">
			<td scope="row" class="LeftLabelSmallSpace" >
				Created
			</td>
			<td class="RightPad" >
				<!--- not editable, simple text --->
				#BuildTimeandUser ( form.createdate, form.createuser )#
			</td>
		</tr>

		<!--- UpdateDate --->
		<tr valign="top">
			<td scope="row" class="LeftLabel" >
				Last Updated
			</td>
			<td class="RightPad" >
				<!--- not editable, simple text --->
				#BuildTimeandUser ( form.updatedate, form.updateuser )#
			</td>
		</tr>
	</cfif>

	<!--- status (OPEN/CLOSED) --->
	<tr valign="top">
		<td scope="row" class="LeftLabel" >
			Status
		</td>
		<td class="RightPad" >
			<cfif form.actionMode NEQ 'View'>
				<!--- editable --->
				<cfset isReadOnly = false>
				<select name="transstatuscode" id="idtransstatuscode"
				tabindex="#form.nextTabIndex#" #BuildInputClass ( 'transstatuscode', variables.lstErrorFields, IsReadOnly, 'select' )#
					<cfif form.actionMode eq "View">disabled</cfif>>
					<cfloop from="1" to="#arrayLen( aStatusCodes )#" index="walker">
						<option value="#aStatusCodes[ walker ].code#"
							<cfif aStatusCodes[ walker ].code eq form.transstatuscode>selected</cfif>>
							#aStatusCodes[ walker ].codedesc#</option>
					</cfloop>
				</select>
				<cfset form.nextTabIndex = form.nextTabIndex + 1>
			<cfelse>
				<!--- view only --->
				<cfset isReadOnly = true>
				<cfset tempdisplay = ''>
				<!--- display an input field instead of a select --->
				<cfloop from="1" to="#arrayLen( aStatusCodes )#" index="walker">
						<cfif aStatusCodes[ walker ].code eq form.transstatuscode>
							<cfset tempdisplay = aStatusCodes[ walker ].codedesc>
							<cfbreak>
						</cfif>
				</cfloop>
				<!--- not editable, simple text --->
				#tempdisplay#
				<input type="hidden" name="transstatuscode" value="#form.transstatuscode#">
			</cfif>
		</td>
	</tr>

	<!--- amount --->
	<tr valign="top">
		<td scope="row" class="LeftLabelSpace" >
			Amount
		</td>
		<td class="RightPad" >
			<!--- not editable for INIT --->
			<cfif form.TransTypeCode EQ "INIT" AND form.actionMode NEQ 'Add'>
				<cfset isReadOnly = true>
			<cfelse>
				<cfif form.actionMode NEQ 'View'><cfset isReadOnly = false><cfelse><cfset isReadOnly = true></cfif>
			</cfif>
			<cfif NOT IsReadOnly>
				<!--- formatNum is in includes/javascript/jsUtilities.js. Positive and 0 allowed --->
				<input type="text" name="amount" id="idamount" size="16" maxlength="15" style="text-align:right"  onchange="formatNum(this,1,0);copyAmount();"  <!--- onFocus="ZeroToBlank()";  ---> value="#form.amount#"
				tabindex="#form.nextTabIndex#" #BuildInputClass ( 'amount', variables.lstErrorFields, IsReadOnly )# />
				<cfset form.nextTabIndex = form.nextTabIndex + 1>
			<cfelse>
				<!--- not editable, simple text --->
				#NumberFormat(form.amount,"9,999")#
				<input type="hidden" name="amount" value="#form.amount#">
			</cfif>
		</td>
	</tr>

	<cfif form.actionMode EQ 'View'>
		<tr valign="top">
			<td  class="LeftLabelLeft">
				Transaction Details
			</td>
			<td class="RightPad" >
				&nbsp;
			</td>
		</tr>
	</cfif>

	<!--- TO Category --->
	<tr valign="top">
		<td scope="row" class="LeftLabelSmallSpace" >
			TO Category
		</td>
		<td class="RightPad" >
			<!--- not editable for init --->
			<cfif form.TransTypeCode EQ "INIT" AND form.actionMode NEQ 'Add'>
				<cfset isReadOnly = true>
			<cfelse>
				<cfif form.actionMode NEQ 'View'><cfset isReadOnly = false><cfelse><cfset isReadOnly = true></cfif>
			</cfif>
			<cfif NOT IsReadOnly>
				<div id="idtocategorydiv">
				<select name="tocategory" id="idtocategory"
					tabindex="#form.nextTabIndex#" #BuildInputClass ( 'tocategory', variables.lstErrorFields, IsReadOnly, 'select'  )# />
					<option value="0" >Select TO Category ...</option>
					<cfloop from="1" to="#arrayLen( aTopCodes )#" index="walker">
						#BuildCatOption( tCat=aTopCodes[ walker ], selectedValue=form.tocategory, triggerFlag = "TransAssoc", bWithPrefix=true, bBuildDisplayOnly = false)#
					</cfloop>
				</select>
				<cfset form.nextTabIndex = form.nextTabIndex + 1>
				</div> <!--- idtocategorydiv --->
				<div id="idtoamount" size="18" maxlength="18" style="text-align:right">
				<!--- <input type="text" name="toamount" id="idtoamount" size="10" maxlength="18" style="text-align:right" readonly /> --->
			<cfelse>
				<!--- read-only --->
				<cfset isReadOnly = true>
				<cfset tempdisplay = ''>
				<!--- display text instead of a select --->
				<cfloop from="1" to="#arrayLen( aTopCodes )#" index="walker">
					<cfif aTopCodes[ walker ].SplanCatId eq form.tocategory>
						<cfset tempdisplay = aTopCodes[ walker ].SplanCatDesc>
						<cfbreak>
					</cfif>
				</cfloop>
				<!--- not editable, simple text --->
				#tempdisplay#
				<input type="hidden" name="tocategory" value="#form.tocategory#">
			</cfif>
		</td>
	</tr>

	<cfif form.actionMode EQ "View">

		#DisplayFopList(1)#

	</cfif> <!--- view --->

	<!--- FROM Category --->
	<!--- this is invisible on INIT Splans --->
	<cfif form.TransTypeCode NEQ "INIT" >
		<tr valign="top">
			<td scope="row" class="LeftLabelSmallSpace" >
				FROM Category
			</td>
			<td class="RightPad" >

			<cfif form.actionMode NEQ 'View'><cfset isReadOnly = false><cfelse><cfset isReadOnly = true></cfif>
			<cfif NOT IsReadOnly>
				<!--- NOT ReadOnly --->
				<div id="idfromcategorydiv">

				<select name="fromcategory" id="idfromcategory"
					tabindex="#form.nextTabIndex#" #BuildInputClass ( 'tocategory', variables.lstErrorFields, isReadOnly, 'select'  )#
					<cfif IsReadOnly>disabled</cfif>
					>
					<option value="0" >Select FROM Category ...</option>
					<cfloop from="1" to="#arrayLen( aTopCodes )#" index="walker">
						#BuildCatOption( tCat=aTopCodes[ walker ], selectedValue=form.fromcategory, triggerFlag = "TransAssoc", bWithPrefix=true, bBuildDisplayOnly = false )#
					</cfloop>
				</select>
				</div> <!--- idfromcategorydiv --->
				<cfset form.nextTabIndex = form.nextTabIndex + 1>
				<cfif form.actionMode NEQ 'View'>
					<div id="idfromamount" size="18" maxlength="18" style="text-align:right">
					<!---<input type="text" name="fromamount" id="idfromamount" size="10" maxlength="18" style="text-align:right" readonly /> --->
				</cfif>
			<cfelse>
				<!--- ReadOnly --->
				<cfset tempdisplay = ''>
				<!--- display an input field instead of a select --->
				<cfloop from="1" to="#arrayLen( aTopCodes )#" index="walker">
					<cfif aTopCodes[ walker ].SplanCatId eq form.fromcategory>
						<cfset tempdisplay = aTopCodes[ walker ].SplanCatDesc>
						<cfbreak>
					</cfif>
				</cfloop>
				<!--- not editable, simple text --->
				#tempdisplay#
				<input type="hidden" name="fromcategory" value="#form.fromcategory#">
			</cfif>
			</td>
		</tr>

		<cfif form.actionMode EQ "View"
				AND IsDefined ( 'tFormFromDB.Aret' ) AND Arraylen( tFormFromDB.Aret ) GT 1>

			#DisplayFopList(2)#

		</cfif> <!--- view --->

	</cfif> <!--- this is invisible on INIT Splans --->

	<tr valign="top">
		<td >
		&nbsp;
		</td>
		<td >
		<div class="BudgetButtons buttons">
			<input type="hidden" name="slSplanTransDetid" value="#form.slSplanTransDetid#" />
			<input type="hidden" name="transtypecode" value="#form.TransTypeCode#" />
			<input type="hidden" name="sBudgetHeaderLeft" value="#form.sBudgetHeaderLeft#" />
			<!--- this is the INCOMING actionMode --->
			<input type="hidden" name="actionMode" value="#form.actionMode#" />

			<cfif actionMode eq "view">
				<input name="btnSubmit" type="submit" value="Edit" />
			<cfelse>
				<!--- edit or add --->
				<input name="btnSubmit" type="submit" value="Save" />
				<input name="btnClear" type="reset" value="Reset" />
				<cfif form.splanTransID NEQ 0>
					<!--- editing.  Must go to VIEW mode --->
					<input name="btnCancel" type="button" value="Cancel" onClick="CancelReturn( 'View', #form.splanTransID# );" />
				<cfelse>
					<!--- adding --->
					<input name="btnCancel" type="button" value="Cancel" onClick="CancelReturn( '#form.CancelReturn#', #form.splanTransID# );" />
				</cfif>
			</cfif>
		</div>
		<!-- buttons -->
		</td>
	</tr>

	</table>

	</form>

</div>
<!-- ctrSubContent -->

<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">

<script>

// here is code build in CF, above
#acatbuiltcode#

function validateSplanEditForm ( form ) {

	// alert('in validate');
	if (form.actionMode.value == 'View') {
		return true;
	}

	var strErrors = '';
	var dNow = new Date();
	var dYear = dNow.getFullYear();
	var nCatAmount = 0;
	var nFormAmount = 0;
	var sFromCategoryDescription = $('##idfromcategory option:selected').text();

	// alert('in validateSplanEditForm');

	if (form.transdesc.value == '') {
		strErrors = strErrors + ' - Description is required.\n';
	}
	if (form.transstatuscode.value != 'O' && form.transstatuscode.value  != 'C' ) {
		strErrors = strErrors + ' - Status must be Open or Closed.\n';
	}

	if (!$.isNumeric ( form.PY.value ) || 1 * form.PY.value < ( 1 * dYear - 10) || 1 * form.PY.value > (1 * dYear + 10) ) {
		strErrors = strErrors + ' - ProgramYear (PY) is out of range.\n';
	}

	if ( (!$.isNumeric ( replaceAll(',', '', form.amount.value) )) || 1 * replaceAll(',', '', form.amount.value) < 0 ) {
		strErrors = strErrors + ' - Amount must be numeric, and greater than 0.\n';
	}

	if ( (form.fromcategory.value == '' || form.fromcategory.value  == 0) && form.transtypecode.value !== 'INIT') {
		strErrors = strErrors + ' - You must pick a FROM category.\n';
	}

	if ( form.tocategory.value == '' || form.tocategory.value  == 0) {
		strErrors = strErrors + ' - You must pick a TO category.\n';
	}

	// do not test amounts unless good so far
	if ( strErrors == '' ) {
		var nPY = 1 * form.PY.value;
		var nfromcategory = 1 * form.fromcategory.value;

		var arrind = $.inArray( nfromcategory, acatid );
		var sAmount = acatamt [ arrind ];
		var sFromCategoryDescription = acatdesc [ arrind ];

		nCatAmount = 1 * ( sAmount );
		// remove commas from the amount on the form
		nFormAmount = 1 * ( replaceAll(',', '', form.amount.value) ) ;

		if ( nFormAmount > nCatAmount ) {
			strErrors = strErrors + ' - The current spend plan balance for ' + sFromCategoryDescription + ' is $' + commaFormat(nCatAmount) + '. Transaction cannot be created.';
		}
	}

	if ( strErrors == '' ) {
		return true;
	}
	else
	{
		alert('The following problems have occurred. Please fix these errors to continue.\n\n' + strErrors + '\n');
		return false;
	}

} // validateSplanEditForm

function copyAmount () {

	var $Source	= $('##idamount');

	var namount = stripCharsInBag($Source.val(), ",") ;
	if ( namount == '') {
		$Source.val( namount);
		$('##idtoamount').html( namount);
		$('##idfromamount').html( namount);
	}
	else {

		var samount = commaFormat(Math.round(1 * namount));
		var namount2 = namount*-1;
		var samount2 = commaFormat(Math.round(1 * namount2));

		// put the comma format into the original source field
		$Source.val( samount);
		// put the same comma format into idtoamount
		$('##idtoamount').html( samount );
		// put the negative comma format into idfromamount
		$('##idfromamount').html( samount2 );
	}

} // copyAmount

function ZeroToBlank () {
	var $Source	= $('##idamount');
	var namount = stripCharsInBag($Source.val(), ",") ;

	if (namount == 0 ) {
		namount = '';
		$Source.val ( namount) ;
	}
}

$("document").ready(function(){
	<!--- JS, with CFOUTPUT --->
	// alert('ready');

	copyAmount();

}); // ready

</script>

</cfoutput>