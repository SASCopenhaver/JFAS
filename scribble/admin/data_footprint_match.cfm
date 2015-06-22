<cfsilent>
<!---
page: data_footprint_match.cfm

description: Displays footprint records that are not associated with any AAPPs.
Allows user to manually associate.

revisions:
2009-12-23	mstein	Updated format for NCFMS integration
2013-08-10	mstein	Updated format for NCFMS Integration
--->

<cfset request.pageID = "2310" /> 
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfparam name="lstErrorMessages" default="" />
<cfparam name="lstErrorFields" default="">
<cfparam name="success" default="">
<cfparam name="url.maxRecords" default="80">
 <!--- required for data entry forms --->

<cfif isDefined("form.btnSubmit")> <!--- coming from form submittal --->

	<!--- database interaction / server-side validation --->
	<!--- will update if no errors --->
	<cfinvoke component="#application.paths.components#footprint"  method="updateAAPPFootDisc" formData="#form#" returnvariable="strUpdateResults">
	<!--- if there are no errors, after updating redirect to same page, with those records gone --->
	<!---
		<cfdump var="#strUpdateResults#">
		<cfdump var="#form#">
		<cfabort>
	--->
	<cfif strUpdateResults.success>
		
		<cflocation url="#cgi.SCRIPT_NAME#?updated=1">
	<cfelse> <!--- show error messages, and highlight error fields --->
		<cfset lstErrorMessages = strUpdateResults.lstErrorMessages>
		<cfset lstErrorFields = strUpdateResults.lstErrorFields>
		<cfset success = strUpdateResults.success>
	</cfif>
</cfif>


<!--- read data from database, set up form fields --->
<cfinvoke component="#application.paths.components#footprint" method="getAAPPFootDisc" maxRecords="#url.maxRecords#" returnvariable="strFootprintDisc">
<cfset rstFootprintDisc = strFootprintDisc.rstFootprintDisc>
<cfloop query="rstFootprintDisc"> 
	<cfparam name="form.aappNum__#docNum#" default="">
</cfloop>

</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<!--- validate aappNum for numeric --->
<script language="javascript">
function validNum(frmField)
{
if (isNaN(frmField.value))
	{
	alert('AAPP # must be a number');
	frmField.value = '';
	}
}
</script>				
	

<!--- Start Output --->	
	<table width="100%">
	<cfoutput>
	<tr>
		<td><h2>Unmatched NFCMS Document Numbers</h2></td>
		<cfif rstFootprintDisc.recordcount neq 0>
		<td class="dataTblCol">
			Showing #min(url.maxRecords,strFootprintDisc.totalRecords)# of #strFootprintDisc.totalRecords# records &nbsp;|&nbsp;
		 	<a href="#cgi.SCRIPT_NAME#?maxRecords=#strFootprintDisc.totalRecords#">Show All</a>
		</td>
		<td>
			<div class="buttons">
			<form name="frmReportCriteria" action="#application.paths.reportdir#reports.cfm?rpt_id=26" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
			<input name="radReportFormat" type="hidden" value="application/pdf" />
			<input name="btnAAPPDiscReport" type="submit" value="Print"/>
			</form>
			</div>
		</td>
		</cfif>
	</tr>
	</cfoutput>
	</table>
	
	<cfif isDefined("url.updated")> <!--- if they just updated, let them know it was a success --->
		<div class="confirmList">
			<li>Your changes have been saved.&nbsp;&nbsp;Return to the <a href="<cfoutput>#application.paths.admin#</cfoutput>">Admin Section</a>.</li>
		</div><br />
	</cfif>
	
	<!--- if validation errors exist, display them --->
	<cfif success eq 0> 
		<div class="errorList">
		<cfloop list="#lstErrorMessages#" index="listItem" delimiters="~">
			<cfoutput><li>#listItem#</li></cfoutput>
		</cfloop>
		</div><br />
	</cfif>
	
	<!--- start form ---> 
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<tr valign="bottom">
		<th scope="row">
			Doc Number
		</th>
		<th>
			Funding Office
		</th>
		<th>
			Vendor
		</th>
		<th>
			AAPP #
		</th>
	</tr>		
	<cfif rstFootprintDisc.recordcount is 0><!--- if there aren't any missing aapp numbers --->
	<tr>
		<td colspan="10" align="center">
		<br />
		<br />
			There are currently no discrepencies. Return to the <a href="<cfoutput>#application.paths.admin#</cfoutput>">Admin Section</a>.
		<br />
		<br />
		<br />


		</td>
	</tr>
	</table>
	<cfelse><!--- output records --->
	<form name="frmFootprintDiscList" action="<cfoutput>#cgi.SCRIPT_NAME#</cfoutput>" method="post">
	<cfoutput query="rstFootprintDisc">
	<tr valign="top" <cfif (currentRow mod 2) is 0>class="AltRow"</cfif>>
		<td align="center"><!--- hidden input of document number --->
			#docNum#
		</td>
		<td align="center">
			#fundingOfficeNum#
		</td>
		<td>
			#VendorName#
		</td>
		<td align="center">
			<label for="id_#docNum#" class="hiddenLabel">AAPP Number for this footrpint</label>
			<!--- create field for aappNum --->
			<input type="text" name="aappNum__#docNum#" id="id_#docNum#" size="7" maxlength="6"
				value="#form["aappNum__" & docNum]#" 
				<!--- check to make sure it's a valid number --->
				onChange="javascript:validNum(this);"
				tabindex="#request.nextTabIndex#"
				<cfif listFindNoCase(lstErrorFields, "aappNum__#docNum#", "~")><!--- if this field has an error, highlight it in red --->
					class="errorField"
				</cfif>
			>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
		
	</tr>
	</cfoutput>
	
	
	</table>
	<div class="buttons">
		<input name="btnSubmit" type="submit" value="Save" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<cfif success eq 0><!--- if they had errors, and want to reset, reload the page --->
		<input name="btnClear" type="button" value="Reset" onclick="javascript:window.location='<cfoutput>#cgi.SCRIPT_NAME#</cfoutput>'" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<cfelse><!--- otherwise, reset just resets the form --->
		<input name="btnClear" type="reset" value="Reset" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfif><!--- cancel redirects to main admin page --->
		<input name="btnCancel" type="button" value="Cancel" onclick="javascript:window.location='<cfoutput>#application.paths.admin#</cfoutput>'"  tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</div>
</form>
	</cfif>
<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />