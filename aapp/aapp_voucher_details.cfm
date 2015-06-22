<cfsilent>
<!---
page: aapp_voucher_details.cfm

description: Enter information for Contract or Purchase Order Voucher to create coversheet for Accounting

revisions:
29-03-2007 - Defect 146 - added trim and numberformat functions to value of OPS/CRA total in cases where there are no footprints for that group
10-05-2007 - Show user amounts charged on previous version when creating or editing addenda
24-07-2007 - Add historical information for previously saved voucher footprints - amounts at time of save, who saved and when
2010-10-01	mstein	Disabled Edit and Addendum buttons until voucher module can be updated to work with NCFMS accounting codes
--->
<cfif url.hidMode is "View">
	<cfset request.pageID = "721">
<cfelse>
	<cfset request.pageID = "720" />
</cfif>
<!--- initialize variables that may not be created otherwise --->
<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default="">
<cfparam name="form.hidMaxVoucherNum" default="0">
<cfparam name="form.hidOutOfOrder" default="0">
<cfparam name="form.hidAmtOPSPrev" default="0">
<cfparam name="form.hidAmtCRAPrev" default="0">
<cfparam name="form.hidAmtTotalPrev" default="0">
<cfparam name="form.hidOPSCumWrong" default="0">
<cfparam name="form.hidCRACumWrong" default="0">

<cfif isDefined("form.txtVoucherNum")><!--- if there was an error in submission, and form is being reloaded, set url variables from form --->
	<cfparam name="url.txtVoucherNum" default="#form.txtVoucherNum#">
<cfelse>
	<cfparam name="url.txtVoucherNum" default="">
</cfif>
<cfoutput>
<!--- coming from form submittal --->
<cfif isDefined("form.btnSubmit")>

	<cfif form.btnSubmit eq "Save">
		<!--- Save the Voucher and its Footprints --->
		<cfinvoke component="#application.paths.components#voucher" method="saveVoucher" formData="#form#" aapp="#url.aapp#" voucherID="#url.voucherID#" returnvariable="stcSaved">
		<!--- redirect to saved page afer saving --->
		<cfif stcSaved.success>
			<cflocation url="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&voucherID=#stcSaved.voucherID#&save=1&hidMode=View&hidVoucherType=#form.hidVoucherType#">
		<cfelse>
			<cfset variables.lstErrorMessages = stcSaved.errorMessages />
			<cfset variables.lstErrorFields = stcSaved.errorFields />
		</cfif>
	<cfelseif form.btnSubmit eq "Edit This Voucher">
	<!--- if user is updating a previously existing voucher --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&voucherID=#url.VoucherID#&hidMode=Edit&hidVoucherType=#form.hidVoucherType#&txtVoucherNum=#form.txtVoucherNum#">
	<!--- if user is creating addendum to this voucher --->
	<cfelseif form.btnSubmit eq "Create Addendum to this Voucher">
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&voucherID=0&hidMode=Add&txtVoucherNum=#form.txtVoucherNum#&hidVoucherType=#form.hidVoucherType#&prevVoucherID=#url.VoucherID#">
	</cfif>
<!--- first time viewing form --->
<cfelse>
	<!--- if it's a Contract Voucher - get the last Voucher Num in the database to make sure they're in order, and to compare cumulative totals --->
	<cfif url.hidVoucherType is "C">
		<cfinvoke component="#application.paths.components#voucher" method="getMaxVoucherNum" aapp="#url.aapp#" returnvariable="rstMaxVoucherNum">
		<cfif rstMaxVoucherNum neq 0>
			<cfif url.hidMode is "Add" or url.hidMode is "Edit"><!--- if adding or editing --->
				<cfif rstMaxVoucherNum eq url.txtVoucherNum> <!---the most recent voucher,--->
					<cfset rstMaxVoucherNum = rstMaxVoucherNum - 1><!--- compare cum totals to previous voucher --->
				</cfif>
			</cfif>
			<cfinvoke component="#application.paths.components#voucher" method="getCumAmounts" aapp="#url.aapp#" lastVoucherNum="#rstMaxVoucherNum#" returnvariable="rstCumAmounts">
		</cfif>
	</cfif>
	<!--- Get information for an exiting Voucher --->
	<cfif url.hidMode is "View" or url.hidMode is "Edit">
		<cfinvoke component="#application.paths.components#voucher" method="getVoucher" voucherId="#url.voucherID#" returnvariable="rstVoucher">
	<cfelseif url.hidMode is "Add">
		<cfinvoke component="#application.paths.components#voucher" method="getAddendumInfo" aapp="#url.aapp#" voucherID="#url.prevVoucherID#" returnvariable="rstPrevVoucher">
		<cfinvoke component="#application.paths.components#voucher" method="getVoucher" voucherId="#rstPrevVoucher#" hidMode="Add" returnvariable="rstVoucher">
	</cfif>
	<!--- Get footprints --->
	<cfif url.hidMode neq "View"><!--- get new Footprints --->
		<cfif url.hidVoucherType is "C">
			<cfinvoke component="#application.paths.components#footprint" method="getFootprint" aapp="#url.aapp#" returnvariable="rstFootprint" >
		<cfelse>
			<cfinvoke component="#application.paths.components#footprint" method="getFootprint" aapp="#url.aapp#" docNum="#url.txtVoucherNum#" returnvariable="rstFootprint" >
		</cfif>
	<cfelse><!--- if user is viewing, get existing footprints --->
		<cfinvoke component="#application.paths.components#voucher" method="getVoucherFootprint" voucherID="#url.voucherID#" returnvariable="rstFootprint">
	</cfif>
</cfif>
<!--- get OPS CRA Codes --->
<cfinvoke component="#application.paths.components#footprint" method="getOPSCRA" returnvariable="rstOPSCRA">

<!--- Set up voucher information based on form, or query --->
<cfset form.hidMode = url.hidMode>
<cfif form.hidMode is "New">
	<cfset voucherCode = "Create New">
<cfelseif form.hidMode is "Add">
	<cfset voucherCode = "Create Addendum to">
<cfelse>
	<cfset voucherCode = form.hidMode>
</cfif>
<cfif isDefined("rstVoucher")><!--- viewing, editing, or creating addendum to existing voucher --->
	<cfset form.txtVoucherNum = rstVoucher.voucherNum>
	<cfset form.txtDateVendorSigned = rstVoucher.dateVendorSigned>
	<cfset form.txtDateRecvRO = rstVoucher.dateRecvRO>
	<cfset form.txtDateRecvNO = rstVoucher.dateRecvNO>
	<cfset form.txtDateToAcct = rstVoucher.DateToAcct>
	<cfset form.txtDatePaymentDue = rstVoucher.datePaymentDue>
	<cfset form.hidVoucherType = rstVoucher.voucherTypeCode>
	<cfset form.txtComments = rstVoucher.comments>
	<cfset form.txtOPS = rstVoucher.amountOPS>
	<cfset form.txtCRA = rstVoucher.amountCRA>
	<cfset form.txtTotal = rstVoucher.amountTotal>
	<cfset form.OPS_Prev_txtAmountCharged = rstVoucher.OPS_Prev_txtAmountCharged>
	<cfset form.CRA_Prev_txtAmountCharged = rstVoucher.CRA_Prev_txtAmountCharged>
	<cfset form.EnterDate = DateFormat(rstVoucher.EnterDate, "mm/dd/yyyy")>
	<cfif form.hidMode neq "Add">
		<cfset form.hidVersion = rstVoucher.version>
	<cfelse>
		<cfset form.hidVersion = ''>
		<cfif rstVoucher.voucherTypeCode is not "C"><!--- If it's a purchase order --->
			<cfif rstFootprint.OPSCRA is "OPS">
				<cfset form.txtOPS = rstFootprint.AmountAvail + rstVoucher.OPS_Prev_txtAmountCharged>
				<cfset form.txtTotal = rstFootprint.AmountAvail>
				<cfset form.txtCRA = 0>
			<cfelse>
				<cfset form.txtCRA = rstFootprint.AmountAvail + rstVoucher.CRA_Prev_txtAmountCharged>
				<cfset form.txtTotal = rstFootprint.AmountAvail>
				<cfset form.txtOPS = 0>
			</cfif>
		</cfif>
	</cfif>
	<cfif rstVoucher.voucherTypeCode is "C">
		<cfparam name="form.txtCRACum" default="#rstVoucher.amountCumCRA#">
		<cfparam name="form.txtOPSCum" default="#rstVoucher.amountCumOPS#">
		<cfparam name="form.txtTotalCum" default="#rstVoucher.amountCumTotal#">
		<cfif isDefined("rstMaxVoucherNum")>
			<cfset form.hidMaxVoucherNum = rstMaxVoucherNum>
		</cfif>
		<cfif isDefined("rstCumAmounts")>
			<cfset form.hidAmtOPSPrev = rstCumAmounts.amtCumOPS>
			<cfset form.hidAmtCRAPrev = rstCumAmounts.amtCumCRA>
			<cfset form.hidAmtTotalPrev = rstCumAmounts.amtCumTotal>
		</cfif>
	</cfif>
<cfelse><!--- new voucher --->
	<cfparam name="form.hidVersion" default="">
	<cfparam name="form.txtDateVendorSigned" default="">
	<cfparam name="form.txtDateRecvRO" default="">
	<cfparam name="form.txtDateRecvNO" default="">
	<cfparam name="form.txtDateToAcct" default="">
	<cfparam name="form.txtDatePaymentDue" default="">
	<cfparam name="form.txtComments" default="">
	<cfset form.CRA_Total_Allocated = 0>
	<cfset form.OPS_Total_Allocated = 0>
	<cfparam name="form.hidVoucherType" default="#url.hidVoucherType#">
	<cfparam name="form.txtVoucherNum" default="">
	<cfparam name="form.txtCRACum" default=0>
	<cfparam name="form.txtOPSCum" default=0>
	<cfparam name="form.txtTotalCum" default=0>
	<cfparam name="form.CRA_TotalCharged" default="0">
	<cfparam name="form.OPS_TotalCharged" default="0">
	<cfparam name="form.OPS_Prev_txtAmountCharged" default="0">
	<cfparam name="form.CRA_Prev_txtAmountCharged" default="0">
	<cfset form.EnterDate = DateFormat(Now(), "mm/dd/yyyy")>
	<cfif form.hidVoucherType is "C">
		<cfparam name="form.txtOPS" default=0>
		<cfparam name="form.txtCRA" default=0>
		<cfparam name="form.txtTotal" default=0>
		<cfif isDefined("rstMaxVoucherNum")>
			<cfset form.hidMaxVoucherNum = rstMaxVoucherNum>
		</cfif>
		<cfif isDefined("rstCumAmounts")>
			<cfset form.hidAmtOPSPrev = rstCumAmounts.amtCumOPS>
			<cfset form.hidAmtCRAPrev = rstCumAmounts.amtCumCRA>
			<cfset form.hidAmtTotalPrev = rstCumAmounts.amtCumTotal>
		</cfif>
	<cfelse>
		<cfif isDefined("rstFootprint.OPSCRA")>
			<cfif rstFootprint.OPSCRA is "OPS">
				<cfparam name="form.txtOPS" default="#rstFootprint.AmountAvail#">
				<cfparam name="form.txtCRA" default="0">
				<cfparam name="form.txtTotal" default="#rstFootprint.AmountAvail#">
			<cfelse>
				<cfparam name="form.txtCRA" default="#rstFootprint.AmountAvail#">
				<cfparam name="form.txtOPS" default="0">
				<cfparam name="form.txtTotal" default="#rstFootprint.AmountAvail#">
			</cfif>
		</cfif>
	</cfif>
</cfif>

<!--- set up footprint information based on query --->
<cfif isDefined("rstFootprint")>
	<!--- Initialize Variables --->
	<cfset form.CRA_recordcount = 0>
	<cfset form.OPS_recordcount = 0>
	<cfset form.CRA_totalCharged = form.CRA_Prev_txtAmountCharged>
	<cfset form.OPS_totalCharged = form.OPS_Prev_txtAmountCharged>
	<cfset Variables.OPS_Remainder = (form.txtOPS - form.OPS_Prev_txtAmountCharged)>
	<cfset Variables.CRA_Remainder = (form.txtCRA - form.CRA_Prev_txtAmountCharged)>
	<cfset form.CRA_totalAvail = 0>
	<cfset form.OPS_totalAvail = 0>
	<cfif rstFootprint.recordcount gt 0>
		<cfset Variables.OPSCRA = rstFootprint.OPSCRA>
		<cfset form[rstFootprint.OPSCRA & '_recordcount'] = 0>
		<cfset form[rstFootprint.OPSCRA & '_totalAvail'] = 0>
		<cfset form[rstFootprint.OPSCRA & '_totalCharged'] = form[rstOPSCRA.OPSCRA & '_Prev_txtAmountCharged']>
		<cfset Variables[rstFootprint.OPSCRA & '_Remainder'] = form['txt' & rstFootprint.OPSCRA] - form[rstOPSCRA.OPSCRA & '_Prev_txtAmountCharged'] >
			<cfloop query="rstFootprint">
				<cfif rstFootprint.OPSCRA neq Variables.OPSCRA>
					<cfset form[rstFootprint.OPSCRA & '_recordcount'] = 0>
					<cfset form[rstFootprint.OPSCRA & '_totalAvail'] = 0>
					<cfset form[rstFootprint.OPSCRA & '_totalCharged'] = form[rstFootprint.OPSCRA & '_Prev_txtAmountCharged']>
					<cfset Variables[rstFootprint.OPSCRA & '_Remainder'] = form['txt' & rstFootprint.OPSCRA] - form[rstFootprint.OPSCRA & '_Prev_txtAmountCharged']>
				</cfif>
				<cfset form[rstFootprint.OPSCRA & '_recordcount'] = form[rstFootprint.OPSCRA & '_recordcount'] + 1>
				<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidFootprintID'] = rstFootprint.FootprintID>
				<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidDocType'] = rstFootprint.DocType>
				<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidDocNum'] = rstFootprint.DocNum>
				<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidFY'] = rstFootprint.FY>
				<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidRCCFund'] = rstFootprint.RccFund>
				<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidRCCOrg'] = rstFootprint.RccOrg>
				<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidObcl'] = rstFootprint.obcl>
				<cfif rstFootprint.oblig eq ''><!--- set to 0 if voucher doesn't have historical information --->
					<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidOblig'] = 0>
				<cfelse>
					<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidOblig'] = rstFootprint.Oblig>
				</cfif>
				<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidEin'] = rstFootprint.Ein>
				<cfif rstFootprint.Cost neq ''><!--- set to 0 if voucher doesn't have historical information --->
					<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidCost'] = rstFootprint.Cost>
				<cfelse>
					<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidCost'] = 0>
				</cfif>
				<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_hidAmountAvail'] = rstFootprint.AmountAvail>
				<cfif form.hidMode is "View">
					<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_txtAmountCharged'] = rstFootprint.AmountCharged>
				<cfelseif form.hidMode is "Edit" or form.hidMode is "Add">
					<cfif  Variables[rstFootprint.OPSCRA & '_Remainder'] gt 0>
						<cfif  Variables[rstFootprint.OPSCRA & '_Remainder'] gt rstFootprint.AmountAvail>
							<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_txtAmountCharged'] = rstFootprint.AmountAvail>
							<cfset Variables[rstFootprint.OPSCRA & '_Remainder'] = Variables[rstFootprint.OPSCRA & '_Remainder'] - rstFootprint.AmountAvail>
						<cfelse>
							<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_txtAmountCharged'] = Variables[rstFootprint.OPSCRA & '_Remainder']>
							<cfset Variables[rstFootprint.OPSCRA & '_Remainder'] = 0>
						</cfif>
					<cfelse>
						<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_txtAmountCharged'] = 0>
					</cfif>
				<cfelseif form.hidMode is "New">
					<cfif form.hidVoucherType is "P">
						<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_txtAmountCharged'] = rstFootprint.AmountAvail>
					<cfelse>
						<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_txtAmountCharged'] = 0>
					</cfif>
				<cfelse>
					<cfset form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_txtAmountCharged'] = 0>
				</cfif>
				<cfif rstFootprint.AmountAvail neq ''><!--- set to 0 if voucher doesn't have historical information --->
					<cfset form[rstFootprint.OPSCRA & '_totalAvail'] = form[rstFootprint.OPSCRA & '_totalAvail'] + rstFootprint.AmountAvail>
				<cfelse>
					<cfset form[rstFootprint.OPSCRA & '_totalAvail'] = form[rstFootprint.OPSCRA & '_totalAvail']>
				</cfif>
				<cfset form[rstFootprint.OPSCRA & '_totalCharged'] = form[rstFootprint.OPSCRA & '_totalCharged'] + form[rstFootprint.OPSCRA & '_' & form[rstFootprint.OPSCRA & '_recordcount'] & '_txtAmountCharged']>
				<cfset Variables.OPSCRA = rstFootprint.OPSCRA>
			</cfloop>
	</cfif>
<!---<cfelse><!--- load the footprint fields from previous form --->
	<cfloop query="rstOPSCRA">
		<cfif form[rstOPSCRA.OPSCRA & '_recordcount'] gt 0>
			<cfloop from="1" to="#form[rstOPSCRA.OPSCRA & '_recordcount']#" index="i">
				<cfset form[rstOPSCRA.OPSCRA & '_' & i & '_hidFootprintID'] = 	form[rstOPSCRA.OPSCRA & '_' & i & '_hidFootprintID']>
				<cfset form[rstOPSCRA.OPSCRA & '_' & i & '_hidDocType'] =  		form[rstOPSCRA.OPSCRA & '_' & i & '_hidDocType']>
				<cfset form[rstOPSCRA.OPSCRA & '_' & i & '_hidDocNum'] = 		form[rstOPSCRA.OPSCRA & '_' & i & '_hidDocNum']>
				<cfset form[rstOPSCRA.OPSCRA & '_' & i & '_hidFY'] = 			form[rstOPSCRA.OPSCRA & '_' & i & '_hidFY']>
				<cfset form[rstOPSCRA.OPSCRA & '_' & i & '_hidRCCFund'] = 		form[rstOPSCRA.OPSCRA & '_' & i & '_hidRCCFund']>
				<cfset form[rstOPSCRA.OPSCRA & '_' & i & '_hidRCCOrg'] = 		form[rstOPSCRA.OPSCRA & '_' & i & '_hidRCCOrg']>
				<cfset form[rstOPSCRA.OPSCRA & '_' & i & '_hidOblig'] = 		form[rstOPSCRA.OPSCRA & '_' & i & '_hidOblig']>
				<cfset form[rstOPSCRA.OPSCRA & '_' & i & '_hidCost'] = 			form[rstOPSCRA.OPSCRA & '_' & i & '_hidCost']>
				<cfset form[rstOPSCRA.OPSCRA & '_' & i & '_hidAmountAvail'] = 	form[rstOPSCRA.OPSCRA & '_' & i & '_hidAmountAvail']>
				<cfset form[rstOPSCRA.OPSCRA & '_' & i & '_hidAmountCharged'] = form[rstOPSCRA.OPSCRA & '_' & i & '_txtAmountCharged']>
			</cfloop>
		</cfif>
	</cfloop>--->
</cfif>


</cfoutput>
</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />


<script language="javascript">

function checkVoucherNum(MaxVoucherNum)
{
if(document.frmVoucher.hidMaxVoucherNum.value != '')
	{
	if(document.frmVoucher.txtVoucherNum.value != (MaxVoucherNum + 1))
		{
		document.frmVoucher.hidOutOfOrder.value = 1;
		alert('The next voucher number for this AAPP should be ' + (MaxVoucherNum + 1) + '.\nPlease include comments explaining the order.');
		}
	else
		{
		document.frmVoucher.hidOutOfOrder.value = 0;
		}
	}
}

function calculateOPSCum()
{
document.frmVoucher.txtOPSCum.value = currencyFormat(stripCharsInBag(document.frmVoucher.txtTotalCum.value, ",") - stripCharsInBag(document.frmVoucher.txtCRACum.value, ","));
document.frmVoucher.txtTotalCum.value = currencyFormat(stripCharsInBag(document.frmVoucher.txtTotalCum.value, ","));
document.frmVoucher.txtCRACum.value = currencyFormat(stripCharsInBag(document.frmVoucher.txtCRACum.value, ","));
}

function calcTotal()
{
//document.frmVoucher.txtCRA.value = currencyFormat(stripCharsInBag(document.frmVoucher.txtCRA.value, ",") * 1);
//document.frmVoucher.txtOPS.value = currencyFormat(stripCharsInBag(document.frmVoucher.txtOPS.value, ",") * 1);
document.frmVoucher.txtTotal.value = currencyFormat((stripCharsInBag(document.frmVoucher.txtCRA.value, ",") * 1) + (stripCharsInBag(document.frmVoucher.txtOPS.value, ",") * 1));
}

function calcAcctDate(field, otherField)
{
if(document.frmVoucher.txtDatePaymentDue.value == '')
	{
	if(field.value != '' && Checkdate(field.value))
		{
		thisDate = new Date(field.value);
		if(document.frmVoucher['txtDateRecv' + otherField].value != '' && Checkdate(document.frmVoucher['txtDateRecv' + otherField].value))
			{
			otherDate = new Date(document.frmVoucher['txtDateRecv' + otherField].value);
			if(thisDate < otherDate)
				{
				var myDate = thisDate;
				}
			else
				{
				var myDate = otherDate;
				}
			}
		else
			{
			var myDate = thisDate;
			}
		var AcctDate = new Date(addDays(myDate,30));
		if(AcctDate.getDay() == 0)
			{
			AcctDate = addDays(myDate,31);
			}
		else if (AcctDate.getDay() == 6)
			{
			AcctDate = addDays(myDate, 32);
			}
		var month=AcctDate.getMonth() + 1;
		if (month < 10)
			{
			month = '0'+month;
			}
		var day = AcctDate.getDate();
		if (day < 10)
			{
			day = '0'+day;
			}
		var year = AcctDate.getFullYear();
		document.frmVoucher.txtDatePaymentDue.value = month + "/" + day + "/" + year;
		}
	}
}

function checkCumTotals(code)
{
if(document.frmVoucher.hidVoucherType.value == 'C' && document.frmVoucher.hidMaxVoucherNum.value != 0 && document.frmVoucher.hidMaxVoucherNum.value != '')
	{
	var nextVoucher = ((document.frmVoucher.hidMaxVoucherNum.value  * 1) + 1);
	if(document.frmVoucher.txtVoucherNum.value == document.frmVoucher.hidMaxVoucherNum.value || document.frmVoucher.txtVoucherNum.value == nextVoucher)
		{
		var cumTarget = currencyFormat((document.frmVoucher['txt' + code].value * 1) + (document.frmVoucher['hidAmt' + code + 'Prev'].value * 1));
		if(cumTarget != document.frmVoucher['txt' + code + 'Cum'].value)
			{
			var goAhead = confirm('The cumulative ' + code + ' amount does not match with the previous voucher amount.\nIf this is correct, click OK, and indicate the reason in the comments.\nIf this is not correct, please click Cancel and make changes to the form.')
			if (goAhead == true)
				{
				document.frmVoucher['hid' + code + 'CumWrong'].value = 1;
				calcFootprint(code);
				}
			}
		else
			{
			document.frmVoucher['hid' + code + 'CumWrong'].value = 0;
			calcFootprint(code);
			}
		}
	else
		{
		calcFootprint(code);
		}
	}
else
	{
	calcFootprint(code);
	}
}

function calcFootprint(code)
{
var Total = (stripCharsInBag(document.frmVoucher['txt' + code].value, ",") * 1);
var FootprintCount = document.frmVoucher[code + '_recordcount'].value;
var totalAllocated = (stripCharsInBag(document.frmVoucher[code + '_Prev_txtAmountCharged'].value, ",") * 1);
var Remainder = Total - (stripCharsInBag(document.frmVoucher[code + '_Prev_txtAmountCharged'].value, ",") * 1);
if(document.frmVoucher[code + '_totalAvail'].value < Total)
	{
	if(document.frmVoucher[code + '_totalAvail'].value == 0)
		{
		alert('There are currently no ' + code + ' funds available for this AAPP.');
		Total = 0;
		}
	else
		{
		alert('There are currently not enough funds to pay this voucher.');
		Total = 0;
		}
	}
for (var i = 1; i <= document.frmVoucher[code + '_recordcount'].value; i++)
	{
	if(Remainder > 0)
		{
		if(Remainder > document.frmVoucher[code + '_' + i + '_hidAmountAvail'].value * 1)
			{
			document.frmVoucher[code + '_' + i + '_txtAmountCharged'].value = currencyFormat(document.frmVoucher[code + '_' + i + '_hidAmountAvail'].value * 1);
			Remainder = Remainder - document.frmVoucher[code + '_' + i + '_hidAmountAvail'].value * 1;
			}
		else
			{
			document.frmVoucher[code + '_' + i + '_txtAmountCharged'].value = currencyFormat(Remainder);
			Remainder = 0;
			}
		}
	else
		{
		document.frmVoucher[code + '_' + i + '_txtAmountCharged'].value = '0.00';
		}
	totalAllocated = totalAllocated + (stripCharsInBag(document.frmVoucher[code + '_' + i + '_txtAmountCharged'].value, ",") * 1);
	}
document.frmVoucher[code + '_totalCharged'].value = currencyFormat(totalAllocated);
document.frmVoucher['txt' + code].value = currencyFormat(Total);
document.frmVoucher.txtTotal.value = currencyFormat((stripCharsInBag(document.frmVoucher.txtCRA.value, ",") * 1) + (stripCharsInBag(document.frmVoucher.txtOPS.value, ",") * 1));
}

function printCoverSheet()
{
	<cfoutput>
	window.open('aapp_voucher_coversheet.cfm?aapp=#url.aapp#&voucherID=#url.voucherID#','coverSheet','location=no,resizable=yes,scrollbars=yes,status=yes');
	</cfoutput>
}


function validateForm()
{
if(document.frmVoucher.btnSubmit.value == 'Save')
	{
	trimFormTextFields(document.frmVoucher); //trim spaces from the text fields
	var strErrors= '';
	if(document.frmVoucher.txtVoucherNum.value == '')//make sure there's a voucher number
		{
		strErrors = strErrors + ' - Voucher number must be entered.\n';
		}
	else if (document.frmVoucher.txtVoucherNum.value != '')
		{
		if(document.frmVoucher.hidVoucherType.value == 'C')
			{
			if(isNaN(document.frmVoucher.txtVoucherNum.value) || document.frmVoucher.txtVoucherNum.value <= 0)
				{
				strErrors = strErrors + ' - Invoice number must be a positive integer.\n';
				}
			}
		document.frmVoucher.txtVoucherNum.value = document.frmVoucher.txtVoucherNum.value.toUpperCase();
		}
	if(document.frmVoucher.txtDateVendorSigned.value == '')//Date Vendor signed
		{
		strErrors = strErrors + ' - Date Vendor Signed must be entered.\n';
		}
	else
		{
		if(!Checkdate(document.frmVoucher.txtDateVendorSigned.value))
			{
			strErrors = strErrors + ' - Date Vendor Signed must be valid and in the format mm/dd/yyyy.\n';
			}
		else
			{
			DateVendorSigned = new Date(document.frmVoucher.txtDateVendorSigned.value);
			}
		}
	if(document.frmVoucher.txtDateRecvRO.value == '' && document.frmVoucher.txtDateRecvNO.value == '')//check the dates received
		{
		strErrors = strErrors + ' - Date Received in RO or Date Received in NO must be entered.\n';
		}
	else
		{
		if(document.frmVoucher.txtDateRecvRO.value != '')
			{
			if(!Checkdate(document.frmVoucher.txtDateRecvRO.value))
				{
				strErrors = strErrors + ' - Date Received in Regional Office must be valid and in the format mm/dd/yyyy.\n';
				}
			else
				{
				DateRecvRO = new Date(document.frmVoucher.txtDateRecvRO.value);
				if(document.frmVoucher.txtDateVendorSigned.value != '')
					{
					if(DateVendorSigned > DateRecvRO)
						{
						strErrors = strErrors + ' - Date Received in Regional Office cannot be earlier than Date Vendor Signed.\n';
						}
					}
				}
			}
		if(document.frmVoucher.txtDateRecvNO.value != '')
			{
			if(!Checkdate(document.frmVoucher.txtDateRecvNO.value))
				{
				strErrors = strErrors + ' - Date Received in National Office must be valid and in the format mm/dd/yyyy.\n';
				}
			else
				{
				DateRecvNO = new Date(document.frmVoucher.txtDateRecvNO.value);
				if(document.frmVoucher.txtDateVendorSigned.value !='')
					{
					if(DateVendorSigned > DateRecvNO)
						{
						strErrors = strErrors + ' - Date Received in National Office cannot be earlier than Date Vendor Signed.\n';
						}
					}
				}
			}
		}
	if(document.frmVoucher.txtDateToAcct.value == '')
		{
		strErrors = strErrors + ' - Date Scheduled to Acctg must be entered.\n';
		}
	else if (!Checkdate(document.frmVoucher.txtDateToAcct.value))
		{
		strErrors = strErrors + ' - Date Scheduled to Acctg must be valid and in the format mm/dd/yyyy.\n';
		}
	else
		{
		DateToAcct = new Date(document.frmVoucher.txtDateToAcct.value);
		if(document.frmVoucher.txtDateVendorSigned.value != '')
			{
			if (DateToAcct < DateVendorSigned)
				{
				strErrors = strErrors + ' - Date Scheduled to Acctg cannot be earlier than Date Vendor Signed.\n';
				}
			}
		if(document.frmVoucher.txtDateRecvRO.value != '' && Checkdate(document.frmVoucher.txtDateRecvRO.value))
			{
			if(document.frmVoucher.txtDateToAcct.value != '')
				{
				if(DateToAcct < DateRecvRO)
					{
					strErrors = strErrors + ' - Date Scheduled to Acctg cannot be earlier than Date Received in Regional Office.\n';
					}
				}
			}
		if(document.frmVoucher.txtDateRecvNO.value != '' && Checkdate(document.frmVoucher.txtDateRecvNO.value))
			{
			if(document.frmVoucher.txtDateToAcct.value != '')
				{
				if(DateRecvNO > DateToAcct)
					{
					strErrors = strErrors + ' - Date Scheduled to Acctg cannot be earlier than Date Received in National Office.\n';
					}
				}
			}
		}
	if(document.frmVoucher.txtDatePaymentDue.value == '')
		{
		strErrors = strErrors + ' - Date Payment Due must be entered.\n';
		}
	else if (!Checkdate(document.frmVoucher.txtDatePaymentDue.value))
		{
		strErrors = strErrors + ' - Date Payment Due must be valid and in the format mm/dd/yyyy.\n';
		}
	else
		{
		DatePaymentDue = new Date(document.frmVoucher.txtDatePaymentDue.value);
		if(document.frmVoucher.txtDateVendorSigned.value != '')
			{
			if(DatePaymentDue < DateVendorSigned)
				{
				strErrors = strErrors + ' - Date Payment Due cannot be earlier than Date Vendor Signed.\n';
				}
			}
		if(document.frmVoucher.txtDateRecvRO.value != '' && Checkdate(document.frmVoucher.txtDateRecvRO.value))
			{
			if(DatePaymentDue < DateRecvRO)
				{
				strErrors = strErrors + ' - Date Payment Due cannot be earlier than Date Received in Regional Office.\n';
				}
			}
		if(document.frmVoucher.txtDateRecvNO.value != '' && Checkdate(document.frmVoucher.txtDateRecvNO.value))
			{
			if(DatePaymentDue < DateRecvNO)
				{
				strErrors = strErrors + ' - Date Payment Due cannot be earlier than Date Received in National Office.\n';
				}
			}
		}
	if(document.frmVoucher.hidVoucherType.value == 'C')
		{
		if(document.frmVoucher.txtTotalCum.value == '')
			{
			strErrors = strErrors + ' - Cumulative Total Amount must be entered.\n';
			}
		if(document.frmVoucher.txtCRACum.value == '')
			{
			strErrors = strErrors + ' - Cumulative CRA Amount must be entered.\n';
			}
		if (stripCharsInBag(document.frmVoucher.txtOPSCum.value, ",") < 0)
			{
			strErrors = strErrors + ' - Cumulative OPS Amount must be a positve amount.\n';
			}
		if(document.frmVoucher.txtCRA.value == '')
			{
			strErrors = strErrors + ' - CRA Amount for this voucher must be entered.\n';
			}
		else
			{
			if(stripCharsInBag(document.frmVoucher.txtCRA.value, ",") != stripCharsInBag(document.frmVoucher.CRA_totalCharged.value, ","))
				{
				strErrors = strErrors + ' - The total amount charged to CRA footprints must equal the voucher CRA amount.\n';
				}
			}
		if(document.frmVoucher.txtOPS.value == '')
			{
			strErrors = strErrors + ' - OPS Amount for this voucher must be entered.\n';
			}
		else
			{
			if(stripCharsInBag(document.frmVoucher.txtOPS.value, ",") != stripCharsInBag(document.frmVoucher.OPS_totalCharged.value, ","))
				{
				strErrors = strErrors + ' - The total amount charged to OPS footprints must equal the voucher OPS amount.\n';
				}
			}
		}
	if (document.frmVoucher.hidMode.value == "Edit" || document.frmVoucher.hidMode.value =="Add")
		{
		if(document.frmVoucher.txtComments.value == '')
			{
			strErrors = strErrors + ' - Comments must be entered when editing or creating an addendum to a voucher.\n';
			}
		}
	if (document.frmVoucher.hidOutOfOrder.value == 1)
		{
		if(document.frmVoucher.txtComments.value == '')
			{
			strErrors = strErrors + ' - Comments must be entered when entering vouchers out of order.\n';
			}
		}
	if (document.frmVoucher.hidOPSCumWrong.value == 1 && document.frmVoucher.txtComments.value == '')
		{
		strErrors = strErrors + ' - Comments must be entered when the OPS amount for this voucher does not agree with cumulative amounts.\n';
		}
	if (document.frmVoucher.hidCRACumWrong.value == 1 && document.frmVoucher.txtComments.value == '')
		{
		strErrors = strErrors + ' - Comments must be entered when the CRA amount for this voucher does not agree with cumulative amounts.\n';
		}
	if (stripCharsInBag(document.frmVoucher.CRA_totalCharged.value, ",")  <= 0 && stripCharsInBag(document.frmVoucher.OPS_totalCharged.value, ",") <= 0)
		{
		strErrors = strErrors + ' - Form cannot be saved without allocation of funds to a footprint.\n';
		}
	if (document.frmVoucher.hidMode.value == 'Add' && document.frmVoucher.hidVersion.value == '')
		{
		strErrors = strErrors + ' - Version must be entered for an addendum.\n';
		}
	else if (document.frmVoucher.hidVersion.value != '')
		{
		document.frmVoucher.hidVersion.value = document.frmVoucher.hidVersion.value.toUpperCase();
		}
	if (strErrors == '')
		{
		if (document.frmVoucher.hidOutOfOrder.value == 1)
			{
			var answer = confirm('This voucher has been entered out of order.\nIf this is correct, and the comments explain, click OK.\nOtherwise, please click Cancel and return to the form.');
			if(answer == true)
				{
				return true;
				}
			else
				{
				return false;
				}
			}
		if (document.frmVoucher.hidOPSCumWrong.value == 1)
			{
			var answer = confirm('The cumulative OPS amount does not match with previous vouchers.\nIf this is correct, and the comments explain, click OK.\nOtherwise, please click Cancel and return to the form.');
			if(answer == true)
				{
				return true;
				}
			else
				{
				return false;
				}
			}
		if (document.frmVoucher.hidCRACumWrong.value == 1)
			{
			var answer = confirm('The cumulative CRA amount does not match with previous vouchers.\nIf this is correct, and the comments explain, click OK.\nOtherwise, please click Cancel and return to the form.');
			if(answer == true)
				{
				return true;
				}
			else
				{
				return false;
				}
			}
		else
			{
			return true;
			}
		}
	else
		{
		alert('The following problems have occurred. Please fix these errors to continue.\n\n' + strErrors + '\n');
		return false;
		}
	}
}

function reCalcAmountCharged(code)
{
var totalAllocated = stripCharsInBag(document.frmVoucher[code + '_Prev_txtAmountCharged'].value, ",");
for (var i = 1; i <= document.frmVoucher[code + '_recordcount'].value; i++)
	{
	totalAllocated = (totalAllocated * 1) + (stripCharsInBag(document.frmVoucher[code + '_' + i + '_txtAmountCharged'].value, ",") * 1);
	document.frmVoucher[code + '_' + i + '_txtAmountCharged'].value = currencyFormat(stripCharsInBag(document.frmVoucher[code + '_' + i + '_txtAmountCharged'].value, ","));
	}
document.frmVoucher[code + '_totalCharged'].value = currencyFormat(totalAllocated);
if(document.frmVoucher.hidVoucherType.value == 'P')
	{
	document.frmVoucher['txt' + code].value = currencyFormat(totalAllocated);
	calcTotal();
	}
}

function validDate(field, name)
{
if(field.value != '')
	{
	if(!Checkdate(field.value))
		{
		alert(name + ' must be a valid date in the format mm/dd/yyyy.');
		}
	}
}


</script>


<cfoutput>
<div class="ctrSubContent">
	<h2>#voucherCode# Voucher</h2>

	<!--- If user has just saved, show confirmation --->
	<cfif isDefined("url.save")>
		<div class="confirmList">
		<cfoutput><li>Information saved successfully.</li></cfoutput>
		</div><br />
	</cfif>
	<cfif variables.lstErrorMessages neq ''>
		<div class="errorList">
		<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters=",">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div><br />
	</cfif>
<cfset request.nextTabIndex = request.nextTabIndex + 1>
<form name="frmVoucher" action="#cgi.script_name#?aapp=#url.aapp#&voucherID=#url.voucherID#&hidMode=#form.hidMode#&hidVoucherType=#form.hidVoucherType#&txtVoucherNum=#form.txtVoucherNum#" method="post" onSubmit="return validateForm(this.form)">
	<input type="hidden" name="hidVoucherType" value="#form.hidVoucherType#" />
	<input type="hidden" name="hidMode" value="#form.hidMode#" />
	<input type="hidden" name="hidMaxVoucherNum" value="#form.hidMaxVoucherNum#" />
	<input type="hidden" name="hidOPSCumWrong" value="#form.hidOPSCumWrong#" />
	<input type="hidden" name="hidCRACumWrong" value="#form.hidCRACumWrong#" />
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<tr nowrap="nowrap">
		<td nowrap="nowrap">
			<label for="voucherNum"><cfif form.hidVoucherType is "C">Invoice<cfelse>Purchase Order</cfif> Number</label>
		</td>
		<td align="left" nowrap="nowrap">
		<input type="text" name="txtVoucherNum" id="voucherNum" value="#form.txtVoucherNum#" tabindex="#request.nextTabIndex#" maxlength="20" size=20
		<cfif form.hidMode neq "new" or form.hidVoucherType eq "P">
			readonly class="inputReadonly"
		<cfelseif listFindNoCase(variables.lstErrorFields,"txtVoucherNum", ",")>
			class="errorField"
		</cfif>
		<cfif form.hidMaxVoucherNum neq 0>
			onBlur="checkVoucherNum(#form.hidMaxVoucherNum#);"
		</cfif>
		 />
		 <input type="hidden" name="hidOutOfOrder" value="#form.hidOutOfOrder#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 2>
		</td>
		<td nowrap="nowrap">
			<label for="dateSigned">Date Vendor Signed</label>
		</td>
		<td align="left" nowrap="nowrap">
			<input type="text" name="txtDateVendorSigned" size="15" maxlength="15" id="dateSigned" value="#dateFormat(form.txtDateVendorSigned, "mm/dd/yyyy")#" onBlur="validDate(this, 'Date Vendor Signed');" tabindex="#request.nextTabIndex#" <cfif form.hidMode is "View">readonly class="inputReadonly" <cfelse> class="datepicker" title="Select to specify Date Vendor Signed Invoice" </cfif> />
			<cfset request.nextTabIndex = request.nextTabIndex - 1>
		</td>
	</tr>
	<tr nowrap="nowrap">
		<td nowrap="nowrap">
			<cfif form.hidVersion neq "" or form.hidMode is "Add">
				Version
			</cfif>
		</td>
		<td nowrap="nowrap" align="left">
			<cfif form.hidVersion neq "" or form.hidMode is "Add">
				<input type="text" name="hidVersion" maxlength="5" size="5" value="#form.hidVersion#" tabindex="#request.nextTabIndex#"
				<cfif form.hidMode is "View" or form.hidMode is "Edit">
					readonly class="inputReadonly"
				<cfelseif listFindNoCase(variables.lstErrorFields,"hidVersion", ",")>
					class="errorField"
				</cfif>
				/>
			<cfelse>
				<input type="hidden" name="hidVersion" value="#form.hidVersion#" />
			</cfif>
			<cfset request.nextTabIndex = request.nextTabIndex + 2>
		</td>
		<td>
			<label for="ROdate">Date Received in RO</label>
		</td>
		<td align="left" nowrap="nowrap">
			<input type="text" name="txtDateRecvRO" id="ROdate" maxlength="15" value="#dateFormat(form.txtDateRecvRO, "mm/dd/yyyy")#" onBlur="validDate(this, 'Date Received in RO');" tabindex="#request.nextTabIndex#" size="15" onChange="calcAcctDate(this, 'NO');" <cfif form.hidMode is "View">readonly class="inputReadonly" <cfelse> class="datepicker" title="Select to specify date invoice arrived in regional office" </cfif> />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr nowrap="nowrap">
		<td colspan="2" nowrap="nowrap">
			<cfif form.hidVoucherType is "C"><strong>New Cumulative Amounts</strong></cfif>
		</td>
		<td nowrap="nowrap">
			<label for="NOdate">Date Received in NO</label>
		</td>
		<td align="left" nowrap="nowrap">
			<input type="text" name="txtDateRecvNO" id="NOdate" maxlength="15"  value="#dateFormat(form.txtDateRecvNO, "mm/dd/yyyy")#" onBlur="validDate(this, 'Date Received in NO');" tabindex="#request.nextTabIndex#" onChange="calcAcctDate(this, 'RO');"  size="15" <cfif form.hidMode is "View">readonly class="inputReadonly" <cfelse> class="datepicker" title="Select to specify date invoice received in national office" </cfif> />
			<cfset request.nextTabIndex = request.nextTabIndex + 3>
		</td>
	</tr>
	<tr nowrap="nowrap">
		<td nowrap="nowrap">
			<cfif form.hidVoucherType is "C"><label for="totalCum">Total</label></cfif>
		</td>
		<td align="left" nowrap="nowrap">
			<cfif form.hidVoucherType is "C">
				$&nbsp;<input type="text" id="totalCum" maxlength="15" value="#trim(numberFormat(replace(form.txtTotalCum, ',', '', 'all'), '999,999,999.99'))#" style="text-align:right" tabindex="#request.nextTabIndex#" name="txtTotalCum" <cfif form.hidMode is "View">readonly class="inputReadonly"<cfelse> onBlur="checkNum(this);calculateOPSCum(this.form);"</cfif> />
			<cfelse>
				<input type="hidden" name="txtTotalCum" value="0" />
			</cfif>
			<input type="hidden" name="hidAmtTotalPrev" value="#form.hidAmtTotalPrev#">
			<cfset request.nextTabIndex = request.nextTabIndex - 2>
		</td>
		<td nowrap="nowrap">
			<label for="Acctdate">Date Scheduled to Acctg</label>
		</td>
		<td align="left" nowrap="nowrap">
			<input type="text" name="txtDateToAcct" id="Acctdate" maxlength="15" onBlur="validDate(this, 'Date Scheduled to Acctg');" tabindex="#request.nextTabIndex#" value="#dateFormat(form.txtDateToAcct, "mm/dd/yyyy")#" size="15" <cfif form.hidMode is "View"> readonly class="inputReadonly" <cfelse> class="datepicker" title="Select to specify date invoice will go to accounting" </cfif> />
			<cfset request.nextTabIndex = request.nextTabIndex + 3>
		</td>
	</tr>
	<tr nowrap="nowrap">
		<td nowrap="nowrap">
			<cfif form.hidVoucherType is "C"><label for="CRACum">CRA</label></cfif>
		</td>
		<td align="left" nowrap="nowrap">
			<cfif form.hidVoucherType is "C">
				$&nbsp;<input type="text" id="CRACum" maxlength="15" tabindex="#request.nextTabIndex#" value="#trim(numberFormat(replace(form.txtCRACum, ',', '', 'all'), '999,999,999.99'))#" style="text-align:right" name="txtCRACum" <cfif form.hidMode is "View">readonly class="inputReadonly"<cfelse>onBlur="checkNum(this);calculateOPSCum(this.form);" </cfif> />
			<cfelse>
				<input type="hidden" name="txtCRACum" value="0" />
			</cfif>
			<input type="hidden" name="hidAmtCRAPrev" value="#form.hidAmtCRAPrev#" />
			<cfset request.nextTabIndex = request.nextTabIndex - 2>
		</td>
		<td nowrap="nowrap">
			<label for="datePaymentDue">Date Payment Due</label>
		</td>
		<td align="left" nowrap="nowrap">
			<input type="text" name="txtDatePaymentDue" maxlength="15" id="datePayementDue" onBlur="validDate(this, 'Date Payment Due');" tabindex="#request.nextTabIndex#" value="#dateFormat(form.txtDatePaymentDue, "mm/dd/yyyy")#" size="15" <cfif form.hidMode is "View"> readonly  class="inputReadonly" <cfelse> class="datepicker" title="Select to specify date payment on this invoice is due to vendor" </cfif> />
			<cfset request.nextTabIndex = request.nextTabIndex + 5>
		</td>
	</tr>
	<tr nowrap="nowrap">
		<td nowrap="nowrap">
			<cfif form.hidVoucherType is "C"><label for="OPSCum">OPS</label></cfif>
		</td>
		<td align="left" nowrap="nowrap">
			<cfif form.hidVoucherType is "C">
				$&nbsp;<input type="text" name="txtOPSCum" value="#trim(numberFormat(replace(form.txtOPSCum, ',', '', 'all'), '999,999,999.99'))#" maxlength="15" style="text-align:right" id="OPSCum" readonly class="inputReadonly" />
			<cfelse>
				<input type="hidden" name="txtOPSCum" value="0" />
			</cfif>
			<input type="hidden" name="hidAmtOPSPrev" value="#form.hidAmtOPSPrev#" />
		</td>
		<td nowrap="nowrap">
		</td>
	</tr>
	<tr nowrap="nowrap">
		<td colspan="2" nowrap="nowrap">
			<cfif form.hidVoucherType is "C"><strong>This Invoice Amounts</strong></cfif>
		</td>
		<td valign="top" rowspan="4">
			<label for="comments">Comments</label>
		</td>
		<td rowspan="4" align="left" valign="top">
			<textarea name="txtComments" id="comments" tabindex="#request.nextTabIndex#" cols="35" rows="4" wrap="soft" onKeyDown="textCounter(this, 200);" onKeyUp="textCounter(this, 200);" <cfif form.hidMode is "View">readonly class="inputReadonly"</cfif>>#form.txtComments#</textarea>
			<cfset request.nextTabIndex = request.nextTabIndex - 2>
		</td>
	</tr>
	<tr nowrap="nowrap">
		<td nowrap="nowrap">
			<cfif form.hidVoucherType is "C"><label for="CRA">CRA</label></cfif>
		</td>
		<td align="left" nowrap="nowrap">
			<cfif form.hidVoucherType is "C">
				$ <input type="text" id="CRA" name="txtCRA" tabindex="#request.nextTabIndex#" value="#trim(numberFormat(replace(form.txtCRA, ',', '', 'all'), '999,999,999.99'))#" maxlength="15" style="text-align:right" <cfif form.hidMode is "View" or form.CRA_totalAvail eq 0>readonly class="inputReadonly"<cfelse>onBlur="checkNum(this);checkCumTotals('CRA');" </cfif> />
			<cfelse>
				<input type="hidden" name="txtCRA" value="#form.CRA_totalCharged#" />
			</cfif>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
	<tr nowrap="nowrap">
		<td nowrap="nowrap">
			<cfif form.hidVoucherType is "C"><label for="OPS">OPS</label></cfif>
		</td>
		<td align="left" nowrap="nowrap">
			<cfif form.hidVoucherType is "C">
				$ <input type="text" id="OPS" tabindex="#request.nextTabIndex#" value="#trim(numberFormat(replace(form.txtOPS, ',', '', 'all'), '999,999,999.99'))#" maxlength="15" style="text-align:right" name="txtOPS" <cfif form.hidMode is "View" or form.OPS_totalAvail eq 0>readonly class="inputReadonly"<cfelse>onBlur="checkNum(this);calcTotal(this.form);checkCumTotals('OPS');"</cfif> />
			<cfelse>
				<input type="hidden" name="txtOPS" value="#form.OPS_totalCharged#" />
			</cfif>
			<cfset request.nextTabIndex = request.nextTabIndex + 2>
		</td>
	</tr>
	<tr nowrap="nowrap">
		<td nowrap="nowrap">
			<cfif form.hidVoucherType is "C"><label for="Total">Total</label></cfif>
		</td>
		<td align="left" nowrap="nowrap">
			<cfif form.hidVoucherType is "C">
				$ <input type="text" id="total" value="#trim(numberFormat(replace(form.txtTotal, ',', '', 'all'), '999,999,999.99'))#" maxlength="15" style="text-align:right" name="txtTotal" readonly class="inputReadonly" />
			<cfelse>
				<input type="hidden" name="txtTotal" value="#trim(numberFormat(replace(form.txtTotal, ',', '', 'all'), '999,999,999.99'))#" /><!---#trim(numberFormat(Evaluate(replace(form.CRA_totalCharged, ',', '', 'all') + replace(form.OPS_totalCharged, ',', '', 'all')), '999,999,999.99'))#--->
			</cfif>
		</td>
	</tr>
	</table>
	<hr />
<cfloop query="rstOPSCRA">
	<input type="hidden" name="#rstOPSCRA.OPSCRA#_recordcount" value="#form[rstOPSCRA.OPSCRA & '_recordcount']#" />
	<cfif (form[rstOPSCRA.OPSCRA & '_recordcount'] gt 0) or (form[rstOPSCRA.OPSCRA & '_totalCharged'] gt 0)>
		<h2>#rstOPSCRA.OPSCRA# Footprints</h2>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="dataTbl" summary="List of Available #rstOPSCRA.OPSCRA# Footprints">
		<tr>
			<th>
				DOLAR$ Doc Type
			</th>
			<th>
				DOLAR$ Doc Number
			</th>
			<th>
				FY
			</th>
			<th>
				RCC Code
			</th>
			<th>
				Obligation
			</th>
			<th>
				Cost
			</th>
			<th>
				Assumed Balance
			</th>
			<th>
				Amount Charged
			</th>
		<cfif form[rstOPSCRA.OPSCRA & '_Prev_txtAmountCharged'] gt 0>
		<tr class="HighlightRow">
			<td colspan="7">
				#rstOPSCRA.OPSCRA# amount previously charged
			</td>
			<td>
				$&nbsp;<input type="text" name="#rstOPSCRA.OPSCRA#_Prev_txtAmountCharged" style="text-align:right" size="15" maxlength="15"
					value="#trim(numberFormat(replace(form[rstOPSCRA.OPSCRA & '_Prev_txtAmountCharged'], ',', '', 'all'), '999,999,999.99'))#" readonly class="inputReadonly"
					/>
			</td>
		</tr>
		<cfelse>
			<input type="hidden" name="#rstOPSCRA.OPSCRA#_Prev_txtAmountCharged" value="0.00" />
		</cfif>
		</tr>
		<cfloop from="1" to="#form[rstOPSCRA.OPSCRA & '_recordcount']#" index="i">
			<tr valign="top" <cfif not (i mod 2)>class="AltRow"</cfif>>
				<input type="hidden" name="#rstOPSCRA.OPSCRA#_#i#_hidFootprintID" value="#form[rstOPSCRA.OPSCRA & '_' & i & '_hidFootprintID']#" />
					<td>
					#form[rstOPSCRA.OPSCRA & '_' & i & '_hidDocType']#
					<input type="hidden" name="#rstOPSCRA.OPSCRA#_#i#_hidDocType" value="#form[rstOPSCRA.OPSCRA & '_' & i & '_hidDocType']#" />
				</td>
				<td>
					#form[rstOPSCRA.OPSCRA & '_' & i & '_hidDocNum']#
					<input type="hidden" name="#rstOPSCRA.OPSCRA#_#i#_hidDocNum" value="#form[rstOPSCRA.OPSCRA & '_' & i & '_hidDocNum']#" />
					<cfif form.hidVoucherType is "P">
						<input type="hidden" name="txtDocNum" value="#form[rstOPSCRA.OPSCRA & '_' & i & '_hidDocNum']#" />
					</cfif>
				</td>
				<td>
					#form[rstOPSCRA.OPSCRA & '_' & i & '_hidFY']#
					<input type="hidden" name="#rstOPSCRA.OPSCRA#_#i#_hidFY" value="#form[rstOPSCRA.OPSCRA & '_' & i & '_hidFY']#" />
				</td>
				<td>
					#form[rstOPSCRA.OPSCRA & '_' & i & '_hidRccOrg']##form[rstOPSCRA.OPSCRA & '_' & i & '_hidRccFund']#
					<input type="hidden" name="#rstOPSCRA.OPSCRA#_#i#_hidRccOrg" value="#form[rstOPSCRA.OPSCRA & '_' & i & '_hidRccOrg']#" />
					<input type="hidden" name="#rstOPSCRA.OPSCRA#_#i#_hidRccFund" value="#form[rstOPSCRA.OPSCRA & '_' & i & '_hidRccFund']#" />
				</td>
				<td nowrap="nowrap" align="right">
					#DollarFormat(form[rstOPSCRA.OPSCRA & '_' & i & '_hidOblig'])#
					<input type="hidden" name="#rstOPSCRA.OPSCRA#_#i#_hidOblig" value="#form[rstOPSCRA.OPSCRA & '_' & i & '_hidOblig']#" />
				</td>
				<td nowrap="nowrap" align="right">
					#DollarFormat(form[rstOPSCRA.OPSCRA & '_' & i & '_hidCost'])#
					<input type="hidden" name="#rstOPSCRA.OPSCRA#_#i#_hidCost" value="#form[rstOPSCRA.OPSCRA & '_' & i & '_hidCost']#" />
				</td>
				<td nowrap="nowrap" align="right">
					#DollarFormat(form[rstOPSCRA.OPSCRA & '_' & i & '_hidAmountAvail'])#
					<input type="hidden" name="#rstOPSCRA.OPSCRA#_#i#_hidAmountAvail" value="#form[rstOPSCRA.OPSCRA & '_' & i & '_hidAmountAvail']#" />
				</td>
				<td nowrap="nowrap">
				$&nbsp;<input type="text" name="#rstOPSCRA.OPSCRA#_#i#_txtAmountCharged" style="text-align:right" size="15" maxlength="15"
					value="#trim(numberFormat(replace(form[rstOPSCRA.OPSCRA & '_' & i & '_txtAmountCharged'], ',', '', 'all'), '999,999,999.99'))#"
					tabindex="#request.nextTabIndex#" onBlur="checkNum(this);reCalcAmountCharged('#rstOPSCRA.OPSCRA#');"
					<cfif form.hidMode is "View">
						readonly class="inputReadonly"
					</cfif>
					/>
					<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</td>
			</tr>
		</cfloop>
		<tr>

		<td align="right" colspan="6">Total Available</td>
		<td align="right">#dollarFormat(form[rstOPSCRA.OPSCRA & '_totalAvail'])#</td>
			<input type="hidden" name="#rstOPSCRA.OPSCRA#_totalAvail" value="#form[rstOPSCRA.OPSCRA & '_totalAvail']#" />
		<td align="right">
			$&nbsp;<input type="text" name="#rstOPSCRA.OPSCRA#_totalCharged" style="text-align:right;" size="15" readonly class="inputReadonly"
				value="#trim(numberFormat(replace(form[rstOPSCRA.OPSCRA & '_totalCharged'], ',', '', 'all'), '999,999,999.99'))#"/>
		</td>
	</tr>
	</table>
	<cfelse>
		<input type="hidden" name="#rstOPSCRA.OPSCRA#_totalCharged" value="#trim(numberformat(form[rstOPSCRA.OPSCRA & '_totalCharged'], '999,999,999.99'))#" />
		<input type="hidden" name="#rstOPSCRA.OPSCRA#_totalAvail" value="#form[rstOPSCRA.OPSCRA & '_totalAvail']#" />
	</cfif>
</cfloop>
	<cfif url.hidMode is "View">
		<div class="contentTbl">
			&nbsp;&nbsp;&nbsp;Saved by #rstFootprint.FirstName#&nbsp;#rstFootprint.LastName# on #DateFormat(rstFootprint.UpdateTime, 'mm/dd/yyyy')# #timeFormat(rstFootprint.UpdateTime, 'long')#
		</div>
	</cfif>
	<div class="buttons">
		<cfif form.hidMode is "View" and session.roleid neq 3 and session.roleid neq 5><input name="btnPrint" type="button" value="Print Coversheet" onClick="printCoverSheet()"/></cfif>
		<cfif form.hidMode neq "View" and request.statusid is 1><input name="btnSubmit" type="Submit" value="Save" /></cfif>
		<cfif form.hidMode is "View" and session.roleid neq 3 and session.roleid neq 5 and request.statusid is 1>
			<cfif Now() lt dateAdd("d", 30, form.EnterDate)>
				<!--- button disabled until voucher module can be updated for NCFMS footprints --->
				<input name="btnSubmit" type="Submit" value="Edit This Voucher" DISABLED />
			</cfif>
			<!--- button disabled until voucher module can be updated for NCFMS footprints --->
			<input name="btnSubmit" type="Submit" value="Create Addendum to this Voucher" DISABLED />
		</cfif>
		<input name="btnCancel" type="button" value="Cancel" onclick="location.href='aapp_voucher.cfm?aapp=#url.aapp#'" />
	</div>
	</form>
</div>
</cfoutput>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />


