<cfsilent>
<!---
page: adjust_functions.cfm

description: pop-up from adjustment form that allows user to copy/reverse/move this adjustment to other AAPPs

revisions:

--->
<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default="" />
<cfparam name="url.fromAAPP" default="" />

<cfif isDefined("form.txtAAPP")>
	<!--- user has entered an AAPP number, and has submitted the form --->
	<cfinvoke component="#application.paths.components#aapp_adjustment" method="handleAdjustmentFunction" formdata="#form#" returnvariable="stcAdjustResults" />
	
	<cfif not stcAdjustResults.success>
		<!--- set list of error messages --->
		<cfset variables.lstErrorMessages = stcAdjustResults.errorMessages />
		<cfset variables.lstErrorFields = stcAdjustResults.errorFields />
	</cfif>

<cfelse> <!--- first time into form --->
	<cfset form.hidActionType = url.actionType />
	<cfset form.hidItemID = url.itemID />
	<cfset form.hidItemType = url.itemType />
	<cfset form.hidFromAAPP = url.fromAAPP />
</cfif>

<!--- determine page title, instructions, button label --->
<cfswitch expression="#form.hidActionType#">
	<cfcase value="add_diff">
		<cfset displayTitle="Add Adjustment for Another AAPP" />
		<cfset displayHelp="Enter the number of an active AAPP." />
		<cfset displayButton="Add Adjustment" />
	</cfcase>
	<cfcase value="dup_diff">
		<cfset displayTitle="Copy this Adjustment to Another AAPP" />
		<cfset displayHelp="Enter the number of an active AAPP. The current adjustment will be copied to that AAPP." />
		<cfset displayButton="Create Duplicate Adjustment" />
	</cfcase>
	<cfcase value="rev_diff">
		<cfset displayTitle="Reverse this Adjustment for Another AAPP" />
		<cfset displayHelp="Enter the number of an active AAPP. The current adjustment will be reversed out for that AAPP." />
		<cfset displayButton="Create Reverse Adjustment" />
	</cfcase>
	<cfcase value="mov_diff">
		<cfset displayTitle="Move Adjustment to Another AAPP" />
		<cfset displayHelp="Enter the number of an active AAPP. The current adjustment will be moved to that AAPP." />
		<cfset displayButton="Move Adjustment" />
	</cfcase>
</cfswitch>
</cfsilent>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<link href="#application.paths.css#" rel="stylesheet" type="text/css" />
</cfoutput>

<script language="javascript" src="<cfoutput>#application.paths.includes#js_formatstring.js</cfoutput>"></script>
<script language="javascript">
<!--- if form submission was successful, reroute base page --->
<cfif isDefined("form.txtAAPP") and stcAdjustResults.success>
	<cfoutput>
	window.opener.location.href='#application.paths.root#aapp/aapp_adjust.cfm?aapp=#form.txtAAPP#&#stcAdjustResults.itemType#=#stcAdjustResults.itemID##stcAdjustResults.addlURLParams#';
	window.close();
	</cfoutput>
</cfif>

function validateForm(form)
{
	errorMsg = '';
	form.txtAAPP.value = trim(form.txtAAPP.value);

	if (form.txtAAPP.value == '')
		errorMsg = 'Please enter an AAPP number.';
	else
		if (isNaN(form.txtAAPP.value))
			errorMsg = 'AAPP Number must be numeric.';
	
	if (errorMsg == '')
		return true;
	else
		{
		alert(errorMsg);
		return false;
		}	
}

</script>

<title>JFAS : <cfoutput>#displayTitle#</cfoutput></title>
</head>

<body onLoad="window.focus();document.frmAdjustFucntionPop.txtAAPP.focus();" >

<table width="100%" bgcolor="white">
<tr>
	<td>
		<cfoutput>
		<h2>#displayTitle#</h2>
		<!---#displayHelp#<br />--->
		<cfif listLen(variables.lstErrorMessages) gt 0>
			<div class="errorList">
			<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters="~">
				<cfoutput><li>#listItem#</li></cfoutput>
			</cfloop>
			</div><br />
		</cfif>
		
		<table width="100%" border="0" cellspacing="0" class="contentTbl" summary="User Information to be added to JFAS user list">
		<form name="frmAdjustFucntionPop" action="#cgi.SCRIPT_NAME#" method="post" onsubmit="return validateForm(this);">
		<tr>
			<td width="29%" nowrap="nowrap" align="right">
				<label for="idAAPPNum">AAPP No.:&nbsp;&nbsp;</label></td>
			<td width="71%">
				<input type="text" name="txtAAPP" id="idAAPPNum" maxlength="6" size="10"
				tabindex="#request.nextTabIndex#" style="font-size: larger" />
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</tr>
		</table>
		
		<div class="buttons" style="text-align:left">
			<input type="hidden" name="hidActionType" value="#form.hidActionType#" />
			<input type="hidden" name="hidItemID" value="#form.hidItemID#" />
			<input type="hidden" name="hidItemType" value="#form.hidItemType#" />
			<input type="hidden" name="hidFromAAPP" value="#form.hidFromAAPP#" />
			<input type="submit" name="btnSubmit" value="#displayButton#" tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="button" name="Cancel" value="Cancel" onClick="window.close();" tabindex="#request.nextTabIndex#" />
		</div>
		</form>
		</cfoutput>
	</td>
</tr>
</table>

</body>
</html>
