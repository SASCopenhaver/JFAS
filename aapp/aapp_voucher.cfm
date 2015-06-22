<cfsilent>
<!---
page: voucher_aapp.cfm

description: a list of vouchers for the current AAPP

revisions:
2010-10-01	mstein	Disabled Create and Pay PO buttons until voucher module can be updated to work with NCFMS accounting codes
--->
<cfoutput>

<cfset request.pageID = "710" />

<cfparam name="url.sortby" default="Desc">
<cfparam name="url.orderby" default="dateRecv">
<cfparam name="form.filterRange" default="25">
<cfparam name="session.voucherAlertDisplay" default="1">

<cfinvoke component="#application.paths.components#footprint" method="getValidDocNum" 
aapp="#url.aapp#"
returnvariable="rstValidDocNum">


<cfinvoke component="#application.paths.components#voucher" method="getVoucherListDates"
aapp="#url.aapp#"
range="#form.filterRange#"
returnvariable="rstVoucherListDates">

<cfinvoke component="#application.paths.components#footprint" method="getOPSCRA"
returnvariable="rstOPSCRA">


<cfparam name="form.cboCostCatFilter" default="both">
<cfparam name="form.cboDateRangeFilter" default="1">

<cfif rstVoucherListDates.recordcount gt 0>
	<cfloop query="rstVoucherListDates">
		<cfset form['startDate_' & currentrow] = start>
		<cfset form['endDate_' & currentrow] = end>	
	</cfloop>
</cfif>

<cfinvoke component="#application.paths.components#voucher" method="getVoucherList" 
aapp="#url.aapp#" 
returnvariable="rstVoucherList">
<cfif rstVoucherList.recordcount lte form.filterRange>
	<cfset nofilter = true>
<cfelse>
	<cfset nofilter = false>
</cfif>

<cfif rstVoucherListDates.recordcount gt 0>	
	<cfquery name="rstVoucherList" dbtype="query">
		Select  *
		From	rstVoucherList
		Where	1=1
		<cfif form.cboCostCatFilter eq "OPS">
			And 	amountOPS > 0
		</cfif>
		<cfif form.cboCostCatFilter eq "CRA">
			And		amountCRA > 0
		</cfif>
		<cfif form.cboDateRangeFilter neq 0>
			And		dateRecv >= '#dateFormat(form['endDate_' & form.cboDateRangeFilter], "MM/DD/YYYY")#'
			And		dateRecv <= '#dateFormat(form['startDate_' & form.cboDateRangeFilter], "MM/DD/YYYY")#'
		</cfif>
	</cfquery>
</cfif>
</cfoutput>

<!--- preform queries to retrieve reference data to populate drop-down lists --->
</cfsilent>



<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">

var DocNums=new Array;
		<cfoutput query="rstValidDocNum">
		DocNums[#evaluate(currentrow-1)#]='#DocNum#';
		</cfoutput>
		
function clearPO()
{
if (trim(document.frmNewPO.txtVoucherNum.value) == 'Enter Document No')
	{
	document.frmNewPO.txtVoucherNum.value = '';
	}
}
		
function checkDocNum()
{
if(trim(document.frmNewPO.txtVoucherNum.value) == '' || trim(document.frmNewPO.txtVoucherNum.value) == 'Enter Document No')
	{
	alert('Please enter a valid document number.');
	document.frmNewPO.txtVoucherNum.value = '';
	return false;
	}
else
	{
	document.frmNewPO.txtVoucherNum.value = trim(document.frmNewPO.txtVoucherNum.value);
	document.frmNewPO.txtVoucherNum.value = document.frmNewPO.txtVoucherNum.value.toUpperCase();
	for (var i=0; i<DocNums.length;i++) 
		{
		if (DocNums[i]==document.frmNewPO.txtVoucherNum.value) 
			{
			return true;
			break;
			}
 		}
	}
if (i==DocNums.length)
	{
	alert(document.frmNewPO.txtVoucherNum.value + ' is not a valid Document Number or has no available funds.');
	return false;
	}
}


<cfif session.voucherAlertDisplay>
	voucherAlert = 'NOTICE: the voucher module will be temporarily disabled while it is being updated to function\n' +
			 'with the new NCFMS accounting codes. We apologize for the inconvenience.';
	alert(voucherAlert);
	<cfset session.voucherAlertDisplay = 0>
</cfif>--->
</script>
				
<div class="ctrSubContent"><h2>Vouchers</h2>
<cfoutput>	
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Table used for layout">
<tr>	
	<form name="frmFilterVoucher" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#" method="post">	<!--- 20070312 - mstein - moved form tags outside <td> for spacing --->
	<td style="text-align:left;vertical-align:bottom" nowrap="nowrap">
		<cfif not nofilter>	
			
			<label for="idFilter">Filter Voucher List by:</label>
			<select name="cboDateRangeFilter" id="idFilter">
				<cfloop query="rstVoucherListDates">
					<option value="#currentrow#" <cfif form.cboDateRangeFilter eq currentrow> selected</cfif>>
						#dateFormat(rstVoucherListDates.end[currentrow], "mm/dd/yyyy")# - #dateFormat(rstVoucherListDates.start[currentrow], "mm/dd/yyyy")#
					</option>
				</cfloop>
				<option value="0" <cfif form.cboDateRangeFilter eq 0> selected</cfif>>
				All Dates
				</option>
			</select>
			&nbsp;&nbsp;
			<select name="cboCostCatFilter">
				<cfloop query="rstOPSCRA">
					<option value="#rstOPSCRA.OPSCRA#" <cfif form.cboCostCatFilter eq rstOPSCRA.OPSCRA>selected</cfif>>
						#rstOPSCRA.OPSCRA#
					</option>
				</cfloop>
				<option value="both" <cfif form.cboCostCatFilter eq "both">selected</cfif>>
				Both
				</option>
			</select>
					<input type="submit" name="btnSubmit" value="Go" />
			
		</cfif>
	</td>
	</form> <!--- 20070312 - mstein - moved form tags outside <td> for spacing --->	
	<cfif (request.statusID is 1) and (session.roleid neq 3 and session.roleid neq 5) and (rstValidDocNum.recordcount gt 0)>
		<form name="frmNewPO" action="aapp_voucher_details.cfm?aapp=#url.aapp#&voucherID=0&hidMode=new&hidVoucherType=P" method="post" onSubmit="return checkDocNum(this);"> <!--- 20070312 - mstein - moved form tags outside <td> for spacing --->
		<td style="text-align:right">
			<!--- button disabled until voucher module can be updated for NCFMS footprints --->
			<input type="button" name="btnNewVoucher" value="&nbsp;&nbsp;Create New Voucher&nbsp;&nbsp;" onclick="location.href='aapp_voucher_details.cfm?aapp=#url.aapp#&voucherID=0&hidMode=new&hidVoucherType=C';" DISABLED />
			<br /><img src="#application.paths.images#clear.gif" alt="" height="1" width="1" vspace="2"><br /> 
			<label for="docNum" class="hiddenLabel">Document Number</label>&nbsp;
			<input type="text" name="txtVoucherNum" id="docNum" value="Enter Document No" size="21" onfocus="clearPO();" /> <!--- 20070312 - mstein - set text box size --->
			<input type="hidden" name="hidMode" value="new" />
			<!--- button disabled until voucher module can be updated for NCFMS footprints --->
			<input type="submit" name="btnNewPo" value="Pay PO" DISABLED />
			
		</td>
		</form> <!--- 20070312 - mstein - moved form tags outside <td> for spacing --->
	</cfif>
</tr>
</table>
</cfoutput>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
	<cfoutput>
	<tr>
		<th>
			Invoice Number
		</th>
		<th>
			Date Received
		</th>
		<th>
			Obligation Type
		</th>
		<th>
			Cost Category
		</th>
		<th style="text-align:right">
			Amount&nbsp;&nbsp;&nbsp;&nbsp;
		</th>
	</tr>	
	</cfoutput>
	<cfif rstVoucherList.recordcount gt 0>
		<cfoutput query="rstVoucherList">
		<tr <cfif not (currentRow mod 2)>class="AltRow"</cfif>>
			<td>
				<a href="aapp_voucher_details.cfm?voucherid=#voucherid#&aapp=#url.aapp#&hidMode=View&hidVoucherType=#VoucherTypeCode#"><cfif request.contractnum neq '' and VoucherTypeCode is "C">#request.contractnum#-</cfif>#voucherNum#<cfif version neq "">#version#</cfif></a>
			</td>
			<td>
				#DateFormat(dateRecv, "mm/dd/yyyy")#
			</td>
			<td>
				#voucherType#
			</td>
			<td>
				#OPSCRA#
			</td>
			<td align="right">
				#dollarFormat(amountTotal)#
			</td>
		</tr>
		</cfoutput>
	<cfelse>
		<tr>
			<td colspan="5" align="center">
				There are currently no vouchers to display.
			</td>
		</tr>
	</cfif>
	</table>
</div>
</div>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />