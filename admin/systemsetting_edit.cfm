<cfsilent>
<!---
page: systemsetting_edit.cfm

description: data entry form to edit system settings

revisions:

2007-07-30	mstein	formatting numbers with commas or decimal places, depending on data type.
--->

<cfset request.pageID = "2480" />
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->

<cfif isDefined("form.hidMode")> <!--- coming from form submittal --->

	<!--- database interaction / server-side validation --->
	<cfinvoke component="#application.paths.components#dataadmin" method="saveSystemSetting" formData="#form#" returnvariable="stcResults">
	<cfif stcResults.success>
		<cflocation url="#cgi.SCRIPT_NAME#?saved=yes">
	<cfelse>
		<cfset variables.lstErrorMessages = stcResults.errorMessages>
	</cfif>

<cfelse> <!--- first time to form --->

	<cfset form.hidMode = "edit">
	<cfinvoke component="#application.paths.components#dataadmin" method="getSystemSettingInfo" returnvariable="rstSystemSettings">
	<cfset form.hidFieldList = valuelist(rstSystemSettings.systemSettingCode,"~~")>

	<!--- loop through system settings, creating form fields for each --->
	<cfloop query="rstSystemSettings">
		<cfset form[systemSettingCode] = systemSetting>
		<cfset form[systemSettingCode & "~~desc"] = systemSettingDesc>
		<cfset form[systemSettingCode & "~~required"] = required>
		<cfset form[systemSettingCode & "~~locked"] = locked>
		<cfset form[systemSettingCode & "~~dataType"] = dataType>
		<cfset form[systemSettingCode & "~~sortOrder"] = sortOrder>
	</cfloop>


</cfif>

</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">


function ValidateForm(form)
{
	// trim text fields
	trimFormTextFields(form);
	strErrors= '';

	<cfoutput>
	<cfloop list="#form.hidFieldList#" index="settingCode" delimiters="~~">
		<cfif not(form[settingCode & "~~locked"])>
			<cfif form[settingCode & "~~required"]>
				// #form[settingCode & "~~desc"]# is required
				if (form.#settingCode#.value == '')
					strErrors = strErrors + '   - #form[settingCode & "~~desc"]# must be entered.\n';
			</cfif>
			<cfif form[settingCode & "~~dataType"] is "date">
				if (form.#settingCode#.value != '')
					{
					if (!Checkdate(form.#settingCode#.value))
						{
						strErrors = strErrors + '   - #form[settingCode & "~~desc"]# must be a valid date in the format mm/dd/yyyy.\n';
						}
					}
			</cfif>
		</cfif>
	</cfloop>
	</cfoutput>

	if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before saving.\n\n' + strErrors + '\n');
		return false
		}
	else
		return true;
}

</script>


<h2>System Settings</h2>

<!--- show error / confirmation messages --->
<cfif listLen(variables.lstErrorMessages) gt 0>
	<div class="errorList">
	<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters="~">
		<cfoutput><li>#listItem#</li></cfoutput>
	</cfloop>
	</div><br />
</cfif>
<cfif isDefined("url.saved")>
	<div class="confirmList">
	<cfoutput><li>Information saved successfully. Return to the <a href="#application.paths.admin#">Admin Section</a></li></cfoutput>
	</div><br />
</cfif>


	<!--- Start Form --->
	<form name="frmSystemSettings"  action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" onSubmit="return ValidateForm(this);">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Small Bus Category Information">
	<cfoutput>
	<cfset tmpSort = 0>
	<cfloop list="#form.hidFieldList#" index="settingCode" delimiters="~~">
		<cfif (form[settingCode & "~~sortOrder"] - tmpSort) gt 1 and (tmpSort neq 0)>
			<tr><td colspan="2">&nbsp;</td></tr>
		</cfif>
		<tr>
			<td width="33%" align="right">
				<label for="id#settingCode#">#form[settingCode & "~~desc"]#</label>
			</td>
			<td width="67%">
				<input type="text" id="id#settingCode#" name="#settingCode#" maxlength="150" size="60"
				<cfif form[settingCode & "~~locked"]>readonly class="inputReadonly"</cfif> tabindex="#request.nextTabIndex#"
				<cfswitch expression="#form[settingCode & "~~dataType"]#">
				<cfcase value="int_pos"> <!--- positive integer --->
					onBlur="formatNum(this,1,0);"
					value="#numberFormat(form[settingCode])#"
				</cfcase>
				<cfcase value="rate">
					onBlur="formatDecimal(this,3);"
					value="#numberFormat(form[settingCode],"0.999")#"
				</cfcase>
				<cfdefaultcase>
					value="#form[settingCode]#"
				</cfdefaultcase>
				</cfswitch>
				/>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				<input type="hidden" name="#settingCode#~~desc" value="#form[settingCode & "~~desc"]#" />
				<input type="hidden" name="#settingCode#~~locked" value="#form[settingCode & "~~locked"]#" />
				<input type="hidden" name="#settingCode#~~required" value="#form[settingCode & "~~required"]#" />
				<input type="hidden" name="#settingCode#~~dataType" value="#form[settingCode & "~~dataType"]#" />
				<input type="hidden" name="#settingCode#~~sortOrder" value="#form[settingCode & "~~sortOrder"]#" />
			</td>
		</tr>
		<cfset tmpSort = form[settingCode & "~~sortOrder"]>
	</cfloop>
	</cfoutput>
	</table>

	<cfoutput>
	<input type="hidden" name="hidMode" value="#form.hidMode#" />
	<input type="hidden" name="hidFieldList" value="#form.hidFieldList#" />
	<div class="buttons">
		<input name="btnSubmit" type="Submit" value="Save" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input name="btnReset" type="button" value="Reset" tabindex="#request.nextTabIndex#" onClick="window.location.href='#cgi.SCRIPT_NAME#';" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='#application.paths.admin#';" tabindex="#request.nextTabIndex#" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</div>
	</form>
	</cfoutput>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />