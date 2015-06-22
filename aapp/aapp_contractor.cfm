<cfsilent>
<!---
page: aapp_summary.cfm

description: displays aapp summary information

revisions:
04-01-2007	rroser	changed Small Business to checkboxes, to allow more than one to be selected
2008-06-09	mstein	changed form so that Contract/Agreement Number, Contractor/Recipient, and Organization Category			
					are not required
2009-12-22	mstein	lable change on Doc Number (also back end changes for NCFMS)
2011-06-20	mstein	Removed Doc Number field (JFAS 2.9)
2013-08-16	mstein	Replaced Doc Number Field (JFAS 2.12)
2014-03-06	mstein	Add capability for user to add contractor on the fly
2014-03-23	mstein	Validation - if org type is small bus, user must check at least one small bus category
--->
<cfset request.pageID = "130" />
<cfparam name="url.hidMode" default="edit">
<cfparam name="form.hidNewContractorName" default="">
<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default="" />
<!--- define form fields that migth be disabled on submission --->

<cfif isDefined("form.btnSubmit")> <!--- form submitted --->

	<!--- save AAPP Summary data --->
	<cfinvoke component="#application.paths.components#aapp" method="saveAAPPContractor" formData="#form#" returnvariable="stcAAPPContractorResults" />
	
	<cfif stcAAPPContractorResults.success>
		<!--- if save was successful, then redirect back to this page in edit mode --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&save=1" />
	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfset variables.lstErrorMessages = stcAAPPContractorResults.errorMessages />
		<cfset variables.lstErrorFields = stcAAPPContractorResults.errorFields />
	</cfif>	

<cfelse> <!--- first time viewing form --->
	
	<!--- retrieve data from database --->
	<cfinvoke component="#application.paths.components#aapp" method="getAAPPContractor" aapp="#url.aapp#" returnvariable="rstAAPPContractor" />
	<!--- preload into form fields --->
	<cfset form.txtContractNum = rstAAPPContractor.contractNum />
	<cfset form.cboContractor = rstAAPPContractor.contractorID />
	<cfset form.cboOrgType = rstAAPPContractor.orgTypeCode &
		iif(rstAAPPContractor.orgSubTypeCode eq "",de(""),de("-" & rstAAPPContractor.orgSubTypeCode))/>
	<cfset form.ckbSmallBusType = ValueList(rstAAPPContractor.smbTypeCode, ",")>
	<cfset form.hidDocNumList = rstAAPPContractor.docNumList>
	<cfif request.statusID eq 1>
		<cfset form.hidMode = "edit" />
	<cfelse>
		<cfset form.hidMode = "readonly" />
	</cfif>

</cfif>


<!--- preform queries to retrieve reference data to populate drop-down lists --->
<cfinvoke component="#application.paths.components#contractor" method="getContractors" returnvariable="rstContractors" />
<cfinvoke component="#application.paths.components#lookup" method="getOrganizationTypes" catView="combo" returnvariable="rstOrgTypes" />
<cfinvoke component="#application.paths.components#lookup" method="getSmallBusTypes" returnvariable="rstSmallBusTypes" />

</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<script language="javascript">


function orgTypeCheck(form)
{
	// when org type changes,
	// check to see if small bus is selected
	// if so, enable small bus type check boxes
	if (form.cboOrgType.options[form.cboOrgType.selectedIndex].value.toUpperCase() == 'FP-FPSMALL')
		for (i=0;i<form.ckbSmallBusType.length;i++)
		form.ckbSmallBusType[i].disabled = 0;
	else
		{
		for (i=0;i<form.ckbSmallBusType.length;i++)
			{
			form.ckbSmallBusType[i].checked = 0;
			form.ckbSmallBusType[i].disabled = 1;
			}
		}
}

function addContractor()
{
	// prompts user to add new contractor to drop-down list
	newContractor = prompt('New Contractor Name:','Enter contractor name here');
	newContractor = trim(newContractor);
	if ((newContractor  != '') && (newContractor  != 'null')) //user clicked OK, name is not blank
		{
		var option = document.createElement("option");
		option.value = '~new'; //set value
		option.text = newContractor; //set dispplayed name
		document.frmAAPPContractor.cboContractor.add(option); //add option to list
		document.frmAAPPContractor.cboContractor.selectedIndex = document.frmAAPPContractor.cboContractor.options.length-1; //select option	
		document.frmAAPPContractor.hidNewContractorName.value = newContractor; //send this with form submission
		}
	
}


function ValidateForm(form)
{
	strErrors= '';
	trimFormTextFields(form);	// trim text fields
	
	// if organization category is small business, one small business type must be checked
	if (form.cboOrgType.options[form.cboOrgType.selectedIndex].value.toUpperCase() == 'FP-FPSMALL') 
	{
		// loop through small bus type checkboxes to make sure one is checked
		smallBusCatChecked = 0;
		for (i=0;i<form.ckbSmallBusType.length;i++)
			if (form.ckbSmallBusType[i].checked)
				smallBusCatChecked = 1;
		if (!smallBusCatChecked)
			strErrors = strErrors + '   - At least one Small Business Category must be specified.\n';
	}	
	
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
	<h2>Contractor Info</h2>
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
		<cfoutput><li>Information saved successfully.</li></cfoutput>
		</div><br />
	</cfif>
		
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<cfoutput>
	<form name="frmAAPPContractor" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#" method="post" onSubmit="return ValidateForm(this);">
	</cfoutput>
	<tr>
		<td scope="row" width="30%" align="right">
			<label for="idContractNum">Contract/Agreement Number</label>
		</td>
		<cfoutput>
		<td width="70%">
			<input type="text" name="txtContractNum" id="idContractNum" tabindex="#request.nextTabIndex#" size="30" maxlength="18"
				value="#form.txtContractNum#" <cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>		
	</tr>
	<tr>
		<td scope="row" align="right">
			<label for="idContractor">Contractor/Recipient</label>
		</td>
		<cfoutput>
		<td>
			<select name="cboContractor" id="idContractor" tabindex="#request.nextTabIndex#"
				<cfif form.hidMode eq "readonly">disabled</cfif>>
				<option value="">Select a contractor...</option>
				<cfloop query="rstContractors">
					<option value="#contractorID#"
						<cfif contractorID eq form.cboContractor>selected</cfif>>
						#contractorName#</option>
				</cfloop>
			</select>
			<cfif listfind("2", session.roleID)>
				<a href="javascript:addContractor();" tabindex="#request.nextTabIndex#">
				<img src="#application.paths.images#add_icon.gif" border="0" hspace="4" alt="Add a new contractor" width="11" height="11" align="absmiddle" /></a>
			</cfif>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>
	<tr>
		<td scope="row" align="right">
			<label for="idOrgType">Organization Category</label>
		</td>
		<cfoutput>
		<td>
			<select name="cboOrgType" id="idOrgType" tabindex="#request.nextTabIndex#" onChange="orgTypeCheck(this.form);"
				<cfif form.hidMode eq "readonly">disabled</cfif>>
				<option value="">Select a category...</option>
				<cfset tmpCat = "">
				<cfloop query="rstOrgTypes">
					<cfif tmpCat neq orgTypeCode>
						<option value="#orgTypeCode#"
							<cfif orgTypeCode eq form.cboOrgType>selected</cfif>>
							#orgTypeDesc#</option>
					</cfif>
					<option value="#orgTypeCode#-#orgSubTypeCode#"
						<cfif (orgTypeCode & "-" & orgSubTypeCode) eq form.cboOrgType>selected</cfif>>
						&nbsp;&nbsp;-&nbsp;#orgSubTypeDesc#</option>
					<cfset tmpCat = orgTypeCode />
				</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		</cfoutput>
	</tr>
	
	<tr>
		<td scope="row" align="right" valign="top">
			<fieldset><legend align="right">Small Business Subcategories</legend>
		</td>
		<cfoutput>
		<td>
			<cfloop query="rstSmallBusTypes">
				<input type="checkbox" name="ckbSmallBusType" value="#smbTypeCode#" id="id_#smbTypeCode#" tabindex="#request.nextTabIndex#"
				 <cfif (form.ckbSmallBusType CONTAINS smbTypeCode) and (form.cboOrgType eq "FP-FPSMALL")>checked</cfif>
				 <cfif form.cboOrgType neq "FP-FPSMALL">disabled</cfif> />&nbsp;
				 <label for="id_#smbTypeCode#">#smbTypeDesc#</label><br />
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</cfloop>
			</fieldset>
		</td>
		</cfoutput>
	</tr>
	
	<tr valign="top">
		<td scope="row" align="right">
			<fieldset><legend align="right">Document Number<cfif listLen(form.hidDocNumList) gt 1>s</cfif></legend>
		</td>
		<cfoutput>
		<td>
			<cfif listLen(form.hidDocNumList) eq 0>
				(none)
			<cfelse>
				<cfloop list="#form.hidDocNumList#" index="ListItem">
					&nbsp;#ListItem# &nbsp;&nbsp;&nbsp;
					<input type="checkbox" name="ckbDelDocNum" value="#ListItem#" id="#ListItem#" tabindex="#request.nextTabIndex#" />
					<label for="#ListItem#">Remove</label><br />
					<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</cfloop>
				</fieldset>
			</cfif>
		</td>
		</cfoutput>
	</tr>
	
	
	
			
	</table>
	<cfif form.hidMode neq "readonly">
		<div class="buttons">
			<cfoutput>
			<input type="hidden" name="hidAAPP" value="#url.aapp#">
			<input type="hidden" name="hidMode" value="#form.hidMode#" />
			<input type="hidden" name="hidDocNumList" value="#form.hidDocNumList#" />
			<input type="hidden" name="hidNewContractorName" value="#form.hidNewContractorName#" />
			</cfoutput>
			<input name="btnSubmit" type="submit" value="Save" />
			<input name="btnClear" type="reset" value="Reset" />
		</div>
	</cfif>
	</form>
</div>


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

