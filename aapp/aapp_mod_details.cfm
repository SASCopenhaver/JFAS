<cfsilent>
<!---
page: aapp_mod_edit.cfm

description: allows user to enter/edit information about a contract mod

revisions:
2011-03-18	mstein	page created
2014-12-15	mstein	Update to allow negative dollar amounts
--->
<cfset request.pageID = "351" />
<cfparam name="variables.lstErrorMessages" default="" />


<!--- get list of top level cost categories --->
<cfinvoke component="#application.paths.components#lookup" method="getCostCategories" returnvariable="rstCostCats" />

<cfif isDefined("form.hidMode")> <!--- form submitted --->

	<cfif form.hidMode eq "delete">

		<cfinvoke component="#application.paths.components#aapp_mod" method="deleteMod" modID="#form.hidModID#"/>
		<cflocation url="#form.hidFromPage#?aapp=#url.aapp#">
	</cfif>

	<!--- save AAPP Summary data --->
	<cfinvoke component="#application.paths.components#aapp_mod" method="saveModData" formData="#form#" returnvariable="stcModResults" />

	<cfif stcModResults.success>
		<!--- if save was successful, then redirect back to this page in edit mode --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&modid=#stcModResults.modID#&fromPage=#form.hidFromPage#&save=1" />
	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfset variables.lstErrorMessages = stcModResults.errorMessages />
	</cfif>

<cfelse> <!--- first time viewing form --->

	<cfif url.modID neq 0> <!--- existing mod --->
		<!--- retrieve data from database --->
		<cfinvoke component="#application.paths.components#aapp_mod" method="getModData" modID="#url.modID#" returnvariable="stcModData" />

		<!--- load data into form fields --->
		<cfset form.txtModNum = stcModData.modData.modNum>
		<cfset form.txtDateIssued = stcModData.modData.dateIssued>
		<cfloop query="stcModData.modFundingData">
			<cfset form["txtFunding_" & costCatID] = fundingTotal>
		</cfloop>

	<cfelse> <!--- new mod --->

		<!--- initialize form fields --->
		<cfset form.txtModNum = "">
		<cfset form.txtDateIssued = "">

	</cfif>

	<cfif request.statusID eq 1 and listFind("1,2",session.roleID)>
		<cfset form.hidMode = "edit" />
	<cfelse>
		<cfset form.hidMode = "readonly" />
	</cfif>

	<cfset form.hidFromPage = url.fromPage>

</cfif>

<cfset form.txtFundingTotal = 0>


</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<script language="javascript">

function fundingSum(form) {
	var sum=0, j=0;
	formFieldIdent = 'txtFunding_';
	sumtargetField = form.txtFundingTotal;

	for (i=0;i<form.elements.length; i++)
		{
		if (form.elements[i].name.indexOf(formFieldIdent)!=-1)
			{
			form.elements[i].value=trim(form.elements[i].value);
				if (!isInteger(stripCharsInBag(form.elements[i].value,'-,')))
					{
					alert("All funding fields must contain a positive numeric value.");
					form.elements[i].value=0;
					}
			sum+=parseInt(stripCharsInBag(form.elements[i].value,','));
			formatNum(form.elements[i],4,1);
			}
		}
	sumtargetField.value=sum;
	formatNum(sumtargetField,4,1);
}

<cfif form.hidMode eq "edit">
	function deleteRecord(form)
	{
		// user is trying to delete FOP or adjustment
		msg = 'Are you sure you want to delete this record? This action can not be undone.\n';
		if (confirm(msg))
			{
			form.hidMode.value = 'delete';
			form.submit();
			}

	}
</cfif>


function ValidateForm(form)
{
	strErrors= '';
	trimFormTextFields(form);	// trim text fields

	// mod number must be entered, and first digit must be numeric
	if (form.txtModNum.value == '')
		strErrors = strErrors + '   - Mod Number must be entered.\n';
	else
		if (!isInteger(form.txtModNum.value.substring(0,1)))
			strErrors = strErrors + '   - Mod Number must start with a numeric value.\n';

	// date issued must be valid date
	if (!Checkdate(form.txtDateIssued.value))
		strErrors = strErrors + '   - Date Issued must be a valid date.\n';

	if(strErrors != '')
	{
		alert('The following problems have occurred. Please fix these errors before continuing.\n\n' + strErrors + '\n');
		return false;
	}
	else
	{
		return true;
	}
}

</script>



<div class="ctrSubContent">
	<h2>Contract Mod Details</h2>
	<!--- show error / confirmation messages --->
	<cfif listLen(variables.lstErrorMessages) gt 0>

		<div class="errorList">
		<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters="~">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div><br />
	</cfif>
	<cfif isDefined("url.save")>
		<div class="confirmList">
		<cfoutput><li>Information saved successfully. Return to <a href="#url.fromPage#?aapp=#url.aapp#&modID=#url.modID#">previous page</a>.</li></cfoutput>
		</div><br />
	</cfif>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<cfoutput>
	<form name="frmModDetails" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&modID=#url.modID#" method="post" onSubmit="return ValidateForm(this);">
	</cfoutput>
	<tr>
		<td scope="row" width="30%" align="right">
			<label for="idModNum">Mod Number</label>
		</td>
		<cfoutput>
		<td colspan="3">
			<input type="text" name="txtModNum" id="idModNum" tabindex="#request.nextTabIndex#" size="10" maxlength="6"
				value="#form.txtModNum#" <cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>
	<tr>
		<td scope="row" align="right">
			<label for="idDateIssued">Date Issued</label>
		</td>
		<cfoutput>
		<td colspan="3">
			<input type="text" name="txtDateIssued" id="idDateIssued" tabindex="#request.nextTabIndex#" size="12" maxlength="10"
				value="#dateFormat(form.txtDateIssued, "mm/dd/yyyy")#" <cfif form.hidMode eq "readonly"> readonly class="inputReadonly" title="Select to specify issue date" <cfelse> class="datepicker" </cfif> >
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>
	<tr><td colspan="4"></td></tr>
	<cfoutput query="rstCostCats">
		<tr>
			<td scope="row" align="right" width="25%"><cfif currentRow eq 1>Funding</cfif></td>

			<td width="2%" align="right"><b>#CostCatCode#</b></td>
			<td width="20%"><label for="idFunding_#costCatID#">&nbsp; #CostCatDesc#</label></td>
			<td width="*">
				<!--- need to handle case where cost cats have been added since data was entered --->
				<cfset fieldName = "txtFunding_" & costCatID>
				<cfif isDefined("form.#fieldName#")>
					<cfset fieldValue = replace(form[fieldName],",","","all")>
				<cfelse>
					<cfset fieldValue = 0>
				</cfif>
				<input type="text" name="txtFunding_#costCatID#" id="idFunding_#costCatID#" tabindex="#request.nextTabIndex#" size="18" maxlength="12"
					value="#numberFormat(fieldValue)#" <cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>
					onChange="fundingSum(this.form);"
					style="text-align: right;">
				<cfset form.txtFundingTotal = form.txtFundingTotal + fieldValue>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</tr>
	</cfoutput>

	<tr>
		<td scope="row"></td>
		<td></td>
		<td><label for="idFundingTotal">Total</label></td>
		<cfoutput>
		<td>
			<input type="text" name="txtFundingTotal" id="idFundingTotal" tabindex="#request.nextTabIndex#" size="18" maxlength="12"
				value="#numberFormat(form.txtFundingTotal)#" readonly class="inputReadonly"	style="text-align: right;">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="red">
	<cfif form.hidMode neq "readonly">
		<tr>
			<td width="20%">
				<div class="buttons">
				<input type="button" name="btnDelete" value="Delete Mod"
					 onClick="deleteRecord(this.form);" tabindex="#request.nextTabIndex#" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
				</div>
			</td>
			<td width="*">
				<div class="buttons">
					<cfoutput>
					<input type="hidden" name="hidModID" value="#url.modID#">
					<input type="hidden" name="hidAAPPnum" value="#url.aapp#">
					<input type="hidden" name="hidMode" value="#form.hidMode#" />
					<input type="hidden" name="hidFromPage" value="#form.hidFromPage#">
					</cfoutput>
					<input name="btnSubmit" type="submit" value="Save" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
					<input name="btnClear" type="reset" value="Reset" /><cfset request.nextTabIndex = request.nextTabIndex + 1>
				</div>
			</td>
		</tr>
	</cfif>

	</table>
	</form>
</div>


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

