<cfsilent>
<!---
page: aapp_notes.cfm

description: displays aapp notes

revisions:
2009-10-13	mstein	page created
--->
<cfset request.pageID = "910" />
<cfparam name="variables.lstErrorMessages" default="" />
<cfparam name="variables.lstErrorFields" default="" />

<cfif isDefined("form.hidMode")> <!--- form submitted --->

	<!--- save note --->
	<cfinvoke component="#application.paths.components#aapp_note" method="saveAAPPnote" formData="#form#" returnvariable="stcNoteSaveResults" />

	<cfif stcNoteSaveResults.success>
		<!--- if save was successful, then redirect --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#url.aapp#">
	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfset variables.lstErrorMessages = stcNoteSaveResults.errorMessages />
		<cfset variables.lstErrorFields = stcNoteSaveResults.errorFields />
	</cfif>

</cfif>

<!--- retrieve notes from database --->
<cfinvoke component="#application.paths.components#aapp_note" method="getAAPPNote" aapp="#url.aapp#" returnvariable="rstAAPPNotes" />
</cfsilent>

<!--- begin HTML --->

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<!--- note: div ctrContent is opened in the header.cfm --->
<div class="ctrSubContent">
	<h2>Notes</h2>

	<!--- show error / confirmation messages --->
	<cfif listLen(variables.lstErrorMessages) gt 0>
		<div class="errorList">
		<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters="~">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div>
		<!-- errorList -->
		<br />
	</cfif>
	<cfif isDefined("url.save")>
		<!--- no confirmation message needed - note will display at top of page --->
	</cfif>
	<table border="0" cellpadding="0" cellspacing="0" class="contentTbl" >
	<cfoutput>
	<form name="frmAAPPNote" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#" method="post" onSubmit="return ValidateForm(this);">
	</cfoutput>
	<tr valign="top">
		<td width="75%">
			<cfoutput>
			<label for="txtNote">Note Text:</label><BR>
			<textarea name="txtNote" id="idNote" cols="100" rows="6"
			onKeyDown="textCounter(this, 1000);" onKeyUp="textCounter(this, 1000);" tabindex="#request.nextTabIndex#"
			<cfif listFindNoCase(variables.lstErrorFields,"txtaapp")>class="errorField"</cfif>></textarea>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</cfoutput>
		</td>
		<td width="5%">
			<cfoutput>
			<BR>
			<a href="javascript:resizeTextArea(document.frmAAPPNote.txtNote, 6, 0);">
			<img src="#application.paths.images#sizetext_min.gif" alt="Minimize Text Field" width="13" height="12" vspace="2" border="0"></a><br>
			<a href="javascript:resizeTextArea(document.frmAAPPNote.txtNote, 6, 1);">
			<img src="#application.paths.images#sizetext_max.gif" alt="Maximize Text Field" width="13" height="12" vspace="2" border="0"></a><br>
			<img src="#application.paths.images#clear.gif" alt="" width="13" height="24"><br>
			<!---
			<cf_etaspellcheck action="spellcheckbutton" type="image" imageSrc="#application.paths.images#spellcheck.gif" name="spellcheck"
			formName="frmAAPPNote" fieldName="txtNote" checkTextboxes="No">
			--->
			<!--- belldr 05/01/2014 - moved code here from below --->
			<input type="hidden" name="hidAAPP" value="#url.aapp#">
			<input type="hidden" name="hidMode" value="add">
			<input name="btnSubmit" type="submit" value="Add Note" tabindex="#request.nextTabIndex#">
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</cfoutput>
		</td>
	</tr>
	</form>
	</table>
	<!-- contentTbl -->

	<p></p>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<tr valign="bottom">
		<th scope="col" width="70%" style="text-align:left">Note</th>
		<th scope="col" width="15%">Date</th>
		<th scope="col" width="12%">User</th>
		<th scope="col" width="3%"></th>
	</tr>

	<cfif rstAAPPNotes.recordcount>
		<cfoutput query="rstAAPPNotes">
			<form name="frmAAPPNoteList" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#" method="post">
			<tr valign="top">
				<td>#replace(note, chr(13), "<BR>", "all")#</td>
				<td align="center">#dateformat(update_time,"mm/dd/yyyy")#</td>
				<td>#last_name#, #first_name#</td>
				<td>
					<cfif listfind("2", session.roleID)>
						<input type="image" name="btnSubmit" tabindex="#request.nextTabIndex#" alt="Delete this Note"
							src="#application.paths.images#delete_icon.gif" height="13" width="13" />
							<cfset request.nextTabIndex = request.nextTabIndex + 1>
					</cfif>
					<input type="hidden" name="hidAAPP" value="#url.aapp#">
					<input type="hidden" name="hidAAPPnoteID" value="#aapp_note_id#">
					<input type="hidden" name="hidMode" value="delete">
				</td>
			</tr>
			<tr>
				<td colspan="4" class="hrule"></td>
			</tr>
			</form>
		</cfoutput>
	<cfelse>
		<tr>
			<td colspan="4" align="center">
				<br /><br />
				No notes have been entered for this AAPP.
				<br /><br />
			</td>
		</tr>
	</cfif>
	</table>
	<!-- contentTbl -->

</div>
<!-- ctrSubContent -->

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

<script language="javascript">
document.frmAAPPNote.txtNote.focus();


function ValidateForm(form)
{
	var strErrors = '';
	var strWarnings = '';
	// trim text fields
	trimFormTextFields(form);

	// make sure note has been entered
	if (form.txtNote.value == '') {
		alert('Please enter a note.');
		return false;
		}
	else
		return true;

}

</script>

