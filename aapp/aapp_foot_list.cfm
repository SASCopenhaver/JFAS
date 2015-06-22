<cfsilent>
<!---
page: aapp_foot_listing.cfm

description: listing of AAPP funding mods

revisions:
2011-03-18	mstein	page created
2013-08-16	mstein	Updates for NCFMS Integration
--->

<cfset request.pageID = "360" />
<cfset maxRecordCount = 50>


<!--- filtering criteria for this page is saved in session, but only as long as the user stays on same aapp --->
<cfif isDefined("session.footFilter.aapp") and (session.footFilter.aapp neq url.aapp)>
	<cfset temp=structClear(session.footFilter)>
</cfif>

<!--- set up session vars for filtering this page (if they don't exist already) --->
<cfparam name="session.footFilter.aapp" default="#url.aapp#">
<cfparam name="session.footFilter.FundCat" default="">
<cfparam name="session.footFilter.DocNum" default="">
<cfparam name="session.footFilter.DocNum_SearchType" default="">
<cfparam name="session.footFilter.FundCode" default="">
<cfparam name="session.footFilter.ProgramCode_short" default="">
<cfparam name="session.footFilter.VendorName" default="">
<cfparam name="session.footFilter.VendorName_SearchType" default="">
<cfparam name="session.footFilter.sortBy" default="fundCat">
<cfparam name="session.footFilter.sortDir" default="asc">

<cfif isdefined("form.cboFundCat")> 
	<!--- user is filtering results --->
	<!--- set session values based on selections user made on form --->
	<cfset session.footFilter.FundCat = form.cboFundCat>
	<cfset session.footFilter.DocNum = form.txtDocNum>
	<cfset session.footFilter.DocNum_SearchType = form.hidDocNum_SearchType>
	<cfset session.footFilter.FundCode = form.cboFundCode>
	<cfset session.footFilter.ProgramCode_short = form.cboProgramCode>
	<cfset session.footFilter.VendorName = form.txtVendorName>
	<cfset session.footFilter.VendorName_SearchType = form.hidVendorName_SearchType>
	<cfset session.footFilter.sortBy = form.hidSortBy>
	<cfset session.footFilter.sortDir = form.hidSortDir>
</cfif>


<!--- get total footprint count for this AAPP --->
<cfinvoke component="#application.paths.components#footprint" method="getFootprintCount" returnvariable="footprintCount" aapp="#session.footFilter.aapp#">

<!--- get list of footprint records, based on search criteria (from session) --->
<cfinvoke component="#application.paths.components#footprint" method="getFootprintList" returnvariable="rstFootprintList"
	aapp="#session.footFilter.aapp#"
	fundCat = "#session.footFilter.FundCat#"
	docNum = "#session.footFilter.DocNum#"
	docNum_searchType = "#session.footFilter.DocNum_SearchType#"
	fundCode = "#session.footFilter.FundCode#"
	ProgramCode_short = "#session.footFilter.ProgramCode_short#"
	vendorName = "#session.footFilter.VendorName#"
	vendorName_searchType = "#session.footFilter.VendorName_SearchType#"
	sortBy = "#session.footFilter.sortBy#"
	sortDir="#session.footFilter.sortDir#">

<cfinvoke component="#application.paths.components#lookup" method="getFundCats" returnvariable="rstFundCats">	
<cfinvoke component="#application.paths.components#footprint" method="getDocNumbers" aapp="#session.footFilter.aapp#" returnvariable="rstDocNums">
</cfinvoke><cfinvoke component="#application.paths.components#footprint" method="getFundCodes" aapp="#session.footFilter.aapp#" returnvariable="rstFundCodes">
<cfinvoke component="#application.paths.components#footprint" method="getProgramCodes" aapp="#session.footFilter.aapp#" displayType="short" returnvariable="rstProgramCodes">
<cfinvoke component="#application.paths.components#footprint" method="getVendorNames" aapp="#session.footFilter.aapp#" returnvariable="rstVendorNames">

</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<script language="javascript">

docNumText = 'Enter Doc Number';
vendorNameText = 'Enter Vendor Name';

// if doc number or vendor are text boxes (instead of drop-downs
function enterField(myField, defaultText)
{
	// user enters text box, clear out default text (if it exists), and set text color to black
	if (myField.value == defaultText)
		{
		myField.value = '';
		myField.style.color = '000000';
		}
}

function leaveField(myField, defaultText)
{
	// user leaves text box. If blank, then insert default text, set text color to gray
	myField.value = trim(myField.value);
	if (trim(myField.value) == '')
		{
		myField.value = defaultText;
		myField.style.color = '999999';
		}
}

function submitForm(form)
{
	trimFormTextFields(form);
	if (form.txtDocNum.value == docNumText)
		form.txtDocNum.value = '';
	
	if (form.txtVendorName.value == vendorNameText)
		form.txtVendorName.value = '';
		
	form.submit();
}

function sortPage(sortColumn)
{
	if (document.frmFootFilter.hidSortBy.value != sortColumn)
		// if user is selecting new column to sort by, set direction to asc
		{
		document.frmFootFilter.hidSortBy.value = sortColumn;
		document.frmFootFilter.hidSortDir.value = 'asc';
		}
	else
		// if user is selecting same sort column, then flip sort direction
		{
		if (document.frmFootFilter.hidSortDir.value == 'asc')
			document.frmFootFilter.hidSortDir.value = 'desc';
		else document.frmFootFilter.hidSortDir.value = 'asc';
		}
	// submit form
	submitForm(document.frmFootFilter);
}

<cfif rstFootprintList.recordcount lte maxRecordCount>
	<cfoutput query="rstFootprintList">
		footDetails#footprintID# = '<font face="verdana" size="1">Fund Cat: #repeatString("&nbsp;",5)##fundCat#<br>Doc ID: #repeatString("&nbsp;",9)##docID#<br>Vendor: #repeatString("&nbsp;",8)##vendorName#<br>Fund Office: &nbsp;&nbsp;#fundingOfficeNum#-#fundingOfficeDesc#';
		footDetails#footprintID# = footDetails#footprintID# + '<br>Cost Center: &nbsp;#costCenter#<br>Object Class: #objectClass#';
		footDetails#footprintID# = footDetails#footprintID# + '<br>Obligation: #repeatString("&nbsp;",3)##numberformat(oblig,"$9,999.99")#<br>Payment: #repeatString("&nbsp;",5)##numberformat(payment,"$9,999.99")#<br>Cost: #repeatString("&nbsp;",11)##numberformat(cost,"$9,999.99")#</font>';
	</cfoutput>
</cfif>

</script>


<div class="ctrSubContent">
	<cfoutput>
	<h2>Footprint Listing
	<span style="font-size:x-small;font-weight:normal;">
	(displaying #iif(rstFootprintList.recordCount gt maxRecordCount,0,rstFootprintList.recordCount)# of #numberformat(footprintCount)# footprints for this AAPP)
	</span></h2>
	</cfoutput>
		
		<!---
		<cfif request.statusID eq 1 and listFind("1,2",session.roleID) and (request.budgetInputType eq "A" or request.agreementTypeCode neq "DC")>
			<!--- button to create new transaction (if aapp is active, and contract has been awarded) --->
			<div class="btnRight" style="margin-bottom:0;margin-right:10px;">
			<cfoutput>
			<form name="frmAddXactn" action="aapp_xactn_add.cfm" method="get">
			<input name="btnAddXactn" type="submit" value="Enter Transaction" />
			<input type="hidden" name="aapp" value="#url.aapp#" />
			<input type="hidden" name="footprintID" value="0" />
			<input type="hidden" name="frompage" value="#cgi.SCRIPT_NAME#" />
			</form>
			</cfoutput>
			</div>
		</cfif>
		<br><br>
		--->
		<div class="btnright">
		<cfoutput>
			<form name="frmFootFilter" action="#CGI.SCRIPT_NAME#?aapp=#url.aapp#" method="post">
				<label for="idFundCat" class="hiddenLabel">Fund Category</label>
				<select name="cboFundCat" id="idFundCat" tabindex="#request.nextTabIndex#" <cfif len(session.FootFilter.fundCat)>style="background-color:##FFFFCC;"</cfif>>
					<option value="">All Fund Cats</option>
					<cfloop query="rstFundCats">
						<option value="#fundCat#" <cfif fundCat eq session.FootFilter.fundCat>selected</cfif>>#fundCat#</option>
					</cfloop>			
				</select>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				
				<label for="idDocNum" class="hiddenLabel">Document Number</label>
				<!--- if more than 30 doc nums for this AAPP, display text box instead of drop-down list --->
				<cfif rstDocNums.recordCount lte 30>
					<select name="txtDocNum" id="idDocNum" tabindex="#request.nextTabIndex#" <cfif len(session.FootFilter.docNum)>style="background-color:##FFFFCC;"</cfif>>
						<option value="">All Doc Numbers</option>
						<cfloop query="rstDocNums">
							<option value="#docNum#" <cfif docNum eq session.FootFilter.docNum>selected</cfif>>#docNum#</option>
						</cfloop>			
					</select>
					<input name="hidDocNum_SearchType" type="hidden" value="exact">
				<cfelse>
					<input name="txtDocNum" id="idDocNum" type="text" size="17" maxlength="13"
							tabindex="#request.nextTabIndex#"
							<cfif len(session.FootFilter.docNum)>
								style="background-color:##FFFFCC;"
								value="#session.FootFilter.docNum#"
							<cfelse>
								style="color:##999999;"
								value="Enter Doc Number"
							</cfif>
							onFocus="enterField(this, docNumText);"
							onBlur="leaveField(this, docNumText);"
							>
					<input name="hidDocNum_SearchType" type="hidden" value="part">
				</cfif>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				
				<label for="idFundCode" class="hiddenLabel">Fund Code</label>
				<select name="cboFundCode" id="idFundCode" tabindex="#request.nextTabIndex#" <cfif len(session.FootFilter.fundCode)>style="background-color:##FFFFCC;"</cfif>>
					<option value="">All Fund Codes</option>
					<cfloop query="rstFundCodes">
						<option value="#fundCode#" <cfif fundCode eq session.FootFilter.fundCode>selected</cfif>>#fundCode#</option>
					</cfloop>			
				</select>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				
				<label for="idProgramCode" class="hiddenLabel">Program Code</label>
				<select name="cboProgramCode" id="idProgramCode" tabindex="#request.nextTabIndex#" <cfif len(session.FootFilter.programCode_short)>style="background-color:##FFFFCC;"</cfif>>
					<option value="">All Program Codes</option>
					<cfloop query="rstProgramCodes">
						<option value="#programCode#" <cfif programCode eq session.FootFilter.programCode_short>selected</cfif>>#programCode#</option>
					</cfloop>			
				</select>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>			
				
				<label for="idVendorName" class="hiddenLabel">Vendor Name</label>
				<!--- if more than 30 doc nums for this AAPP, display text box instead of drop-down list --->
				<cfif rstVendorNames.recordCount lte 30>
					<select name="txtVendorName" id="idVendorName" tabindex="#request.nextTabIndex#" style="width:22em;<cfif len(session.FootFilter.vendorName)>background-color:##FFFFCC;</cfif>">
						<option value="">All Vendors</option>
						<cfloop query="rstVendorNames">
							<option value="#vendorName#" <cfif vendorName eq session.FootFilter.vendorName>selected</cfif>>#vendorName#</option>
						</cfloop>			
					</select>
					<input name="hidVendorName_SearchType" type="hidden" value="exact">
				<cfelse>
					<input name="txtVendorName" id="idVendorName" type="text" size="33" maxlength="80"
							tabindex="#request.nextTabIndex#"
							<cfif len(session.FootFilter.vendorName)>
								style="background-color:##FFFFCC;"
								value="#session.FootFilter.vendorName#"
							<cfelse>
								style="color:##999999;"
								value="Enter Vendor Name"
							</cfif>
							onFocus="enterField(this, vendorNameText);"
							onBlur="leaveField(this, vendorNameText);"
							>
					<input name="hidVendorName_SearchType" type="hidden" value="part">
				</cfif>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				
				<input type="button" name="btnFilter" value="Go" onClick="submitForm(this.form);" />
				<input type="hidden" name="hidSortBy" value="#session.FootFilter.sortBy#">
				<input type="hidden" name="hidSortDir" value="#session.FootFilter.sortDir#">				
			</form>
		</cfoutput>
		</div>
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
		<tr>
			<cfoutput>
			<th scope="col"><a href="javascript:sortPage('fundCat');">Cat</a></th>
			<th scope="col"><a href="javascript:sortPage('docID');">Doc ID</a></th>
			<th scope="col"><a href="javascript:sortPage('fundCode');">Fund</a></th>
			<th scope="col"><a href="javascript:sortPage('programCode_short');">Program</a></th>
			<th scope="col"><a href="javascript:sortPage('vendorName');">Vendor</a></th>
			<th scope="col"><a href="javascript:sortPage('oblig');">Obligation</a></th>
			<th></th>
			</cfoutput>
		</tr>
		<cfif rstFootprintList.recordCount eq 0>
			<tr>
				<td colspan="6" align="center" valign="middle" height="150">
					<cfoutput>
					<cfif footprintCount eq 0>
						No footprint records exist for this AAPP.
						<!--- not able to add records at this time
						<cfif request.statusID eq 1 and listFind("1,2",session.roleID) and (request.budgetInputType eq "A" or request.agreementTypeCode neq "DC")>
							Click <a href="javascript:document.frmAddXactn.submit();" title="Add a Transaction">here</a> to add a new footprint / transaction.</td>
						</cfif>
						--->
					<cfelse>
						No footprints match the search criteria entered above.
					</cfif>
					</cfoutput>
			</tr>
			
		<cfelseif rstFootprintList.recordcount gt maxRecordCount>
			<tr>
				<td colspan="6" align="center" valign="middle" height="150">
					This AAPP has more footprint records than can be displayed at one time.<br><br>
					Please specify search criteria in the fields above to filter those records.
			</tr>
		
		<cfelse>
			<cfset obligTotal = 0>		
			<cfoutput query="rstFootprintList">
				<tr <cfif currentrow mod 2>class="AltRow"</cfif> valign="top">
					<td width="5%">#fundCat#</td>
					<td width="22%" nowrap>#docID#</td>
					<td width="15%">#fundCode#</td>
					<td width="10%">#programCode_short#</td>
					<td width="33%" nowrap>#left(vendorName,28)#<cfif len(vendorName) gt 28>...</cfif></td>
					<td width="10%" align="right">#numberformat(oblig,"$9,999.99")#</td>
					<td width="5%">
						<a href="aapp_foot_details.cfm?aapp=#url.aapp#&footprintID=#footprintID#" onmouseover="tooltip.show(footDetails#footprintID#,460);" onmouseout="tooltip.hide();"><img src="#application.paths.images#moreinfo_icon.gif" alt="" border="0"></a></td>
				</tr>
				<cfset obligTotal = obligTotal + oblig>
			</cfoutput>
			<tr>
				<cfoutput>
				<td colspan="4"></td>
				<td><b>Total</b></td>
				<td align="right"><b>#numberformat(obligTotal,"$9,999.99")#</b></td>
				<td></td>
				</cfoutput>
			</tr>
		</cfif>
			  
		</table>
	</div>

</div>


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

