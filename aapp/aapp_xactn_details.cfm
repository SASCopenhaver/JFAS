<cfsilent>
<!---
page: aapp_xactn_details.cfm

description: displays read-only details of transaction

revisions:
2011-07-07	mstein	page created
--->
<cfset request.pageID = "362" />

<cfparam name="url.xactnStatus" default="1">


<cfif isdefined("form.hidDeleteXactnID")>
	<!--- delete transaction --->
	<cfinvoke component="#application.paths.components#footprint" method="deleteXactn"
		xactnID="#form.hidDeleteXactnID#"
		footprintID="#form.hidFootprintID#"
		comments="#form.hidComments#">
	<cflocation url="aapp_foot_details.cfm?aapp=#url.aapp#&footprintID=#url.footprintID#">
</cfif>

<!--- get transaction details --->
<cfinvoke component="#application.paths.components#footprint" method="getXactnDetails" returnvariable="rstXactnDetails"
	xactnID="#url.xactnID#"
	xactnStatus="#url.xactnStatus#">

<!--- get system settings for migration, transaction upload dates --->
<cfset mnlxactnStartDate = application.outility.getSystemSetting(systemSettingCode="mnlxactn_start")>
<cfset mnlxactnEndDate = application.outility.getSystemSetting(systemSettingCode="mnlxactn_end")>

</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<script>

function deleteXactn(form)
{
	<cfif dateCompare(rstXactnDetails.xactnDate,mnlxactnEndDate) lte 0>
		confirmMessage = 'The date of this transaction is within the range covered by the XLS upload. This means that your action\n' +
						 'could be reversed upon the next upload. Are you sure you want to delete this transaction?\n';

	<cfelse>
		confirmMessage = 'Are you sure you would like to delete this transaction? This action can not be undone.';
	</cfif>

	if (confirm(confirmMessage))
		{
		<cfoutput>
		urlString = '?aapp=' + #request.aapp#;
		newWin = window.open("aapp_xactn_comment.cfm"+urlString, "xactnComment",'status=no,toolbar=no,menubar=no,location=no,scrollbars=no,resizable=no,width=425,height=190');
		</cfoutput>
		}
}

</script>

<div class="ctrSubContent">
	<h2>Transaction Details</h2>

	<!---
	<cfif request.statusID eq 1 and listFind("1,2",session.roleID) and (request.budgetInputType eq "A" or request.agreementTypeCode neq "DC") and rstXactnDetails.xactnStatus>
		<!--- allow to add transaction if aapp is active, if contract is awarded (applies to contracts only), and if this transaction is not deleted --->
		<div class="btnRight" style="margin-bottom:0;margin-right:20px;">
		<cfoutput>
		<form name="frmAddXactn" action="aapp_xactn_add.cfm" method="get">
		<input name="btnAddXactn" type="submit" value="Enter Transaction" />
		<input type="hidden" name="aapp" value="#url.aapp#" />
		<input type="hidden" name="footprintID" value="#url.footprintID#" />
		<input type="hidden" name="frompage" value="#cgi.SCRIPT_NAME#" />
		</form>
		</cfoutput>
		</div>
	</cfif>
	--->

	<table width="97%" border="0" cellpadding="0" cellspacing="0" class="readOnlyDataTbl">
	<cfoutput query="rstXactnDetails">
		<tr><td colspan="2" height="5"></td></tr>
		<tr>
			<td>Transaction Type:</td>
			<td>#xactnTypeDesc#</td>
		</tr>
		<tr>
			<td>Transaction Date:</td>
			<td>#dateformat(xactnDate, "mm/dd/yyyy")#</td>
		</tr>
		<tr>
			<td>Amount:</td>
			<td>#numberformat(amount,"$9,999")#</td>
		</tr>
		<tr>
			<td>Mod No.:</td>
			<td>#modNum#</td>
		</tr>
		<tr valign="top">
			<td>Description:</td>
			<td>#xactnDesc#</td>
		</tr>
		<tr>
			<td>Invoice No.:</td>
			<td>#invoiceNum#</td>
		</tr>
		<tr><td colspan="2" height="5"></td></tr>
		<tr><td colspan="2" class="hrule"></td></tr>
		<tr><td colspan="2" height="5"></td></tr>
		<tr>
			<td width="20%">Fund Category:</td>
			<td width="*">#fundCat#</td>
		</tr>
		<tr>
			<td>Document ID:</td>
			<td>#docID#</td>
		</tr>
		<tr>
			<td>Vendor:</td>
			<td>#vendorName# (#vendorID#)</td>
		</tr>
		<tr>
			<td>Funding Office:</td>
			<td>#fundingOfficeNum# - #fundingOfficeDesc#</td>
		</tr>
		<tr>
			<td>Account ID:</td>
			<td>
				#mid(accountID,1,2)# #mid(accountID,3,10)# #mid(accountID,13,4)# #mid(accountID,17,10)#
				#mid(accountID,27,6)# #mid(accountID,33,5)# #mid(accountID,38,6)# #mid(accountID,44,6)#
			</td>
		</tr>
		<tr>
			<td>Cost Center:</td>
			<td>#costCenter#</td>
		</tr>
		<tr>
			<td>Object Class:</td>
			<td>#objectClass#</td>
		</tr>
		<tr><td colspan="2" height="5"></td></tr>
		<tr><td colspan="2" class="hrule"></td></tr>
		<tr><td colspan="2" height="5"></td></tr>
		<tr>
			<td>Date Entered in JFAS:</td>
			<td>#dateformat(dateCreate, "mm/dd/yyyy")#</td>
		</tr>
		<tr>
			<td>Data Source:</td>
			<td>#dataSource#</td>
		</tr>
		<tr>
			<td>Last Update:</td>
			<td <cfif xactnStatus eq 0>style="color:red;"</cfif>>#updateFunction# &nbsp;&nbsp;(#dateformat(updateTime, "mm/dd/yyyy")#, #updateUser#)</td>
		</tr>
		<cfif len(xactnComments)>
			<tr valign="top">
				<td>Comments:</td>
				<td <cfif xactnStatus eq 0>style="color:red;"</cfif>>#replace(xactnComments, chr(13), "<BR>", "all")#</td>
			</tr>
		</cfif>
	</cfoutput>
	<tr>
		<cfoutput>
		<td colspan="2" valign="bottom" height="40">
			<a href="aapp_foot_details.cfm?aapp=#url.aapp#&footprintID=#url.footprintID#"><< Return to Footprint Details</a>
		</td>
		</cfoutput>
	</tr>
	</table>

	<!---
	<table width="97%" border="0" cellpadding="0" cellspacing="0" height="60" class="readOnlyDataTbl">
	<tr>
		<cfoutput>
		<form name="frmDeleteXactn" action="#cgi.script_name#?aapp=#url.aapp#&footprintID=#url.footprintID#" method="post" onSubmit="return SubmitForm(this);">
		<td>
			<a href="aapp_foot_details.cfm?aapp=#url.aapp#&footprintID=#url.footprintID#"><< Return to Footprint Details</a>
		</td>
		<td align="right">
			<!--- if active transaction, admin user, and transaction is post migration, display delete button --->
			<cfif rstXactnDetails.xactnStatus and listFind(2,session.roleID) and (datecompare(rstXactnDetails.xactnDate,mnlxactnStartDate) gte 0)>
				<input type="button" name="btnSubmit" tabindex="#request.nextTabIndex#" value="Delete Transaction" onClick="deleteXactn(this.form);">
				<input type="hidden" name="hidDeleteXactnID" value="#url.xactnID#">
				<input type="hidden" name="hidFootprintID" value="#url.footprintID#">
				<input type="hidden" name="hidComments" value="">
			</cfif>
		</td>
		</form>
		</cfoutput>
	</tr>
	</table>
	--->
</div>


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

