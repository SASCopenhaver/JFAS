<cfsilent>
<!---
page: data_import.cfm

description: data import template

revisions:
abai 12/18/2006 Change dbusername, dbpassword, dbhostname to request variable.
abai 01/12/2007 Change it for defect #105
abai 08/20/2007 Revised for adding Transaction Import part.
abai 08/27/2007 Revised for tracking import event
rroser	9/7/2007	Added adjustment upload
2007-10-01	mstein	Added cfsettign to override default page timeout (needed for transaction upload)
2010-08-04	mstein	Added redirect to manual transaction upload
2011-05-23	mstein	Extended timeout to 1800 (30 minutes) to deal with FMS/2110 issues
2013-08-04	mstein	Added NCFMS Footprint, Removed Manual Transaction
--->



<cfset request.pageID="2300">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - Data Import">
<cfset request.pageTitleDisplay = "JFAS System Administration">

<cfsetting requestTimeout = "3000">

<cfparam name="form.hidDataType" default="#url.datatype#">
<cfparam name="form.hidMode" default="#url.mode#">
<cfparam name="Attributes.result" default="">
<cfparam name="lstMessage" default="">
<cfparam name="tableName" default=""> 
<cfparam name="status" default="">
<cfparam name="result" default="0">

<cfinvoke component="#application.paths.components#lookup" method="getImportTypes" importType="#form.hidDataType#" returnvariable="rstImportType">

<cfset importDesc = #rstImportType.importTypeDesc# />
<cfswitch expression="#form.hidDataType#">
<cfcase value="NCFMSFOOT">
	<cfset request.pageID="2307">
	<cfset tableName="footprint_ncfms_load">
</cfcase>
<cfcase value="TRANSACT">
	<cfset request.pageID="2304">
	<cfset tableName="FOOTPRINT_XACTN_LOAD">
</cfcase>
<cfcase value="2110">
	<cfset request.pageID="2300">
	<cfset tableName="center_2110_load">
</cfcase>
<cfcase value="EQUIPMENT">
	<cfset request.pageID="2302">
	<cfset tableName="equipment_load">
</cfcase>
<cfcase value="VEHICLE">
	<cfset request.pageID="2303">
	<cfset tableName="vehicle_load">
</cfcase>
<cfcase value="ADJUSTMENT">
	<cfset request.pageID="2305">
	<cfset tableName="adjustment_load">
</cfcase>
<cfdefaultcase>
	<cfset importDesc = "" />
</cfdefaultcase>
</cfswitch>

</cfsilent>

<cfif isDefined("form.btnSubmit")>
	<cfif form.btnSubmit neq "Create Adjustments and FOPs">			  
	<!--- call component to upload file and import data--->
	<cfinvoke component="#application.paths.components#importAction" method="importAction" 
			  tableName='#tableName#' 
			  dsn='#request.dsn#' 
			  dataLoadPath='#application.paths.upload#' 
			  formName="filDataImport" 
			  fileName='jfas_#hidDataType#'
			  returnvariable="lstMessage">
	</cfif>
	<!--- get upload result --->
	<cfswitch expression="#form.hidDataType#">
		<!--- NCFMS FOOTPRINT --->
		<cfcase value="NCFMSFOOT">
			<cfif lstMessage eq "">
				<cfinvoke component="#application.paths.components#import_data_ncfms" method="validateNCFMSFootLoad" returnvariable="strValidateNCFMSFootLoad">
				<cfif strValidateNCFMSFootLoad.success>
					<cfinvoke component="#application.paths.components#import_data_ncfms" method="NCFMSFootImport" userID="#session.userID#" returnvariable="strInsertNCFMSFoot">
					<cfif strInsertNCFMSFoot.success eq 1>
						<cfset form.hidMode = "success">
					</cfif>
				<cfelse>
					<cfset form.hidMode = "error_level_2"> <!--- validation error --->
					<cfset lstMessage = strValidateNCFMSFootLoad.lstErrorMessages>
				</cfif>
			<cfelse>
				<cfset form.hidMode = "error_level_1"> <!--- sql loader error --->
			</cfif>
		</cfcase>
		
		<!--- fms --->
		<cfcase value="2110">
			 <cfif lstMessage eq ""> 
			    <cfinvoke component="#application.paths.components#import_data" method="validate2110" returnvariable="validate2110">
			    
				<cfif validate2110.recordcount eq 0>
					<cfinvoke component="#application.paths.components#import_data" method="insert2110" returnvariable="result">
					<cfif result.status eq 1>
						<cfset form.hidMode = "success">
					</cfif>
				<cfelse>
					<cfset form.hidMode = "error_level_2"> <!--- validation error --->
				</cfif>
			<cfelse>
				<cfset form.hidMode = "error_level_1"> <!--- sql loader error --->
			</cfif> 
			<cfif form.hidMode eq "success">
				<cfinvoke component="#application.paths.components#import_data" method="import_tracking" import_type="2110" success="1"
						  note="#result.recordsRaw# records loaded, #result.records# records inserted/updated.">				
			</cfif>
		</cfcase>
		
		<!--- equipment --->
		<cfcase value="EQUIPMENT">
			 <cfif lstMessage eq ""> 
			    <cfinvoke component="#application.paths.components#import_data" method="validateEquipment" returnvariable="validateEquipment">
			    
			    <cfif validateEquipment.recordcount eq 0>
					<cfinvoke component="#application.paths.components#import_data" method="insertEquipment" returnvariable="result">
					
					<cfif result.status eq 1>
						<cfset form.hidMode = "success">
					</cfif>
				<cfelse>
					<cfset form.hidMode = "error_level_2">
				</cfif>
			<cfelse>
				<cfset form.hidMode = "error_level_1">
			</cfif> 
			<cfif form.hidMode eq "success">
				<cfinvoke component="#application.paths.components#import_data" method="import_tracking" import_type="EQUIPMENT" success="1">
			</cfif>
		</cfcase>
		
		<!--- vehicle --->
		<cfcase value="VEHICLE">
			 <cfif lstMessage eq ""> 
				<cfinvoke component="#application.paths.components#import_data" method="validateVehicle" returnvariable="validateVehicle">
			    
				<cfif validateVehicle.recordcount eq 0>
					<cfinvoke component="#application.paths.components#import_data" method="insertVehicle" returnvariable="result">
					<cfif result.status eq 1>
						<cfset form.hidMode = "success">
					</cfif>
				<cfelse>
					<cfset form.hidMode = "error_level_2">
				</cfif> 
			<cfelse>
				<cfset form.hidMode = "error_level_1">
			</cfif>
			<cfif form.hidMode eq "success">
				<cfinvoke component="#application.paths.components#import_data" method="import_tracking" import_type="VEHICLE" success="1">
			</cfif>
		</cfcase>
		
		<!--- Transaction--->
		<cfcase value="TRANSACT">
			 <cfif lstMessage eq ""> 
			    <cfinvoke component="#application.paths.components#import_data" method="validateTransact" returnvariable="validateTransact">
			   
				<cfif validateTransact.recordcount eq 0>
					<cfinvoke component="#application.paths.components#import_data" method="insertTransact" returnvariable="result">
					
					<cfif result.status eq 1>
						<cfset form.hidMode = "success">
					</cfif>
				<cfelse>
					<cfset form.hidMode = "error_level_2">
				</cfif>
			<cfelse>
				<cfset form.hidMode = "error_level_1">
			</cfif> 
			<cfif form.hidMode eq "success">
				<cfinvoke component="#application.paths.components#import_data" method="import_tracking" import_type="TRANSACT" success="1">
			</cfif>
		</cfcase>
		
		<!--- Adjustment --->
		<cfcase value="ADJUSTMENT">
			<cfif url.Mode is "upload">
				<cfif lstMessage eq ""> 
					<cfinvoke component="#application.paths.components#import_data" method="validateAdjustment" returnvariable="validateAdjustment">
					<cfif validateAdjustment.recordcount eq 0>
						<!--- preview data --->
						<cfset form.hidMode = "preview">
						<cfinvoke component="#application.paths.components#import_data" method="previewAdjustment" returnvariable="rstPreviewAdjustment">
					<cfelse>
						<cfset form.hidMode = "error_level_2">
					</cfif>
				<cfelse>
					<cfset form.hidMode = "error_level_1">
				</cfif> 
			<cfelseif url.Mode is "preview">
				<!--- insert data --->
				<cfinvoke component="#application.paths.components#import_data" method="insertAdjustment" returnvariable="result">
				<cfif result.status eq 1>
					<cfset form.hidMode = "success">
				</cfif>
			</cfif>
			<cfif form.hidMode eq "success">
				<cfinvoke component="#application.paths.components#import_data" method="import_tracking" import_type="ADJUSTMENT" success="1">
			</cfif>
		</cfcase>
	</cfswitch>
</cfif>

<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">

<cfoutput>
<script language="javascript">
function ValidateForm(form){
  strErrors= '';
  
  if (form.filDataImport.value == '')
  		strErrors = strErrors + '   - The upload file must be provided.\n';
  else{
  	EXPextension = form.filDataImport.value.substring(form.filDataImport.value.length-4, form.filDataImport.value.length);
  	EXPextension = EXPextension.toUpperCase();
  	//alert(EXPextension);
  	if (EXPextension != '' && EXPextension != '.TXT' && EXPextension != '.CSV'  && EXPextension != '.DAT')
		strErrors = strErrors + '   - The upload file must be text format (.txt or .csv, or .dat).\n';
  }
  	
  if (strErrors != '')
		{
		alert('The following problems have occurred. Please fix these errors before uploading.\n\n' + strErrors + '\n');
		return false
		}
  else {
  	form.btnSubmit.value = 'Please wait - Uploading File.';
  	form.btnClear.disabled = true;
  	form.btnCancel.disabled = true;
  	return true
  }
		
}
</script>

<p></p>

<h2>Data Import: #importDesc#</h2>
</cfoutput>


<cfswitch expression="#form.hidMode#">
<cfcase value="upload">	
	
	<cfoutput>
	<form name="frmDataImport" action="#cgi.SCRIPT_NAME#?datatype=#url.datatype#&mode=#url.mode#&requesttimeout=5000" method="post" enctype="multipart/form-data" onSubmit="return ValidateForm(this);">
		
	<div>
	<cfif url.datatype is "ADJUSTMENT">
		<a href="#application.paths.root#admin/AdjustmentBatch.xlt">Download the Adjustment Batch upload template excel file</a><br />
	</cfif>
	Locate the appropriate #importDesc# data file by clicking "Browse..." and then click the "Import File" button.<br />
	NOTE: This process may take a few minutes.<br /><br />
	<label for="idDataImport" class="hiddenLabel">File to Import</label>
	<input type="file" name="filDataImport" id="idDataImport" />
	</div>
	</cfoutput>
	
	<div class="buttons">
	<cfoutput>
	<input type="hidden" name="hidDataType" value="#form.hidDataType#">
	<input type="hidden" name="hidMode" value="#form.hidMode#">
	</cfoutput>
	<input name="btnSubmit" type="submit" value="Import File" /><!--- onClick="this.value='Please wait - uploading file'" --->
	<input name="btnClear" type="reset" value="Reset" />
	<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='admin_main.cfm'" />
	</div>
	</form>

</cfcase>

<cfcase value="error_level_1">
	<div>
	<cfoutput>
	The following errors occured when trying to import the #importDesc# data file:
	</div>
	
	<p></p>
	<div class="errorList">
	<table>
		<tr>
			<td>
			#lstMessage#
			</td>
		</tr>
	</table>
	
	</div>
	
	<p></p>
	<div>
	Return to <a href="#application.paths.admin#">Admin</a>.
	</cfoutput>
	</div>
</cfcase>


<cfcase value="error_level_2">
	<cfoutput>
	<div>
	The following errors occured when trying to import the #importDesc# data file:
	</div>
	
	<p></p>
	<div class="errorList">
	<cfif form.hidDataType eq "NCFMSFOOT">
		<cfloop list="#lstMessage#" index="msg" delimiters="~">
			<li>#msg#</li>
		</cfloop><br>
	<cfelseif form.hidDataType eq "EQUIPMENT">
		<cfloop query="validateEquipment">
				#AAPP_NUM#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				#ErrorMsg#<br>
		</cfloop>
	<cfelseif form.hidDataType eq "VEHICLE">
		<cfloop query="validateVehicle">
			#CENTER_NAME#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			#ErrorMsg#<br>
		</cfloop>
	<cfelseif form.hidDataType eq "2110">
	   <cfloop query="validate2110">
			#AAPP_NUMBER#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			#ErrorMsg#<br>
		</cfloop>
	<cfelseif form.hidDataType eq "TRANSACT">
	   <cfloop query="validateTransact">
			#AAPP_NUMBER#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			#ErrorMsg#<br>
		</cfloop>
	<cfelseif form.hidDataType eq "ADJUSTMENT">
		<cfset RowNum = 0>
		<table>
		<tr>
			<td>AAPP</td>
			<td>Description</td>
			<td>Cost Category</td>
			<td></td>
		</tr>
		<cfloop query="validateAdjustment">
			<cfif Row_Num neq RowNum>
			<cfif RowNum neq 0>
				<tr>
					<td colspan="4"><hr /></td>
				</tr>
			</cfif>
			<tr>
				<td>#AAPP_NUM#</td>
				<td>#Description#</td>
				<td align="center">#Cost_cat_Code#</td>
				<td><li>#errorMsg#</li></td>
			</tr>
			<cfelse>
			<tr>
				<td colspan="3">&nbsp;</td>
				<td><li>#errorMsg#</li></td>
			</tr>
			</cfif>
			<cfset rowNum = validateAdjustment.Row_Num[currentrow]>
		</cfloop>
		</table>
	</cfif>
	</div>
	<p></p>
	
	<div>
	Return to <a href="#application.paths.admin#">Admin</a>.
	</div>
	</cfoutput>
</cfcase>

<cfcase value="preview"><!--- Preview uploaded data before making changes --->
	<cfoutput>
	<cfif rstPreviewAdjustment.recordcount gt 0>
		<br />
		<h2>Please preview and accept the #importDesc# data.</h2>
		<br />
		<cfset currType = "">
		<cfloop query="rstPreviewAdjustment">
		<cfif rstPreviewAdjustment.adjType[currentRow] is "ADJ">
			<cfset adjTypeName = "Adjustments">
		<cfelse>
			<cfset adjTypeName = "FOPs">
		</cfif>
		<cfif adjType neq currType>
			<div>The following #adjTypeName# will be created</div>
			<table class="contentTbl" width="100%" cellspacing="0" cellpadding="0">
				<tr>
					<th align="left">AAPP</th>
					<th>Description</th>
					<th>Cost Category</th>
					<th>Effective Date</th>
					<cfif adjType is "ADJ"><th>Ongoing</th></cfif>
					<th>Amount</th>
				</tr>
		</cfif>
				<tr>
					<td align="center">
						#AAPPNum#
					</td>
					<td>
						#description#
					</td>
					<td align="center">
						#costCatCode#
					</td>
					<td align="center" <cfif warndate is 1> style="color:##FF0000"</cfif>>
						#dateFormat(effectiveDate, "mm/dd/yyyy")#
					</td>
					<cfif adjType is "ADJ">
						<td align="center">
						#ongoing#
						</td>
					</cfif>
					<td align="right">
						#dollarFormat(Amount)#
					</td>
				</tr>
			<cfset currType = adjType>
		<cfif (currType neq rstPreviewAdjustment.adjType[currentRow + 1]) or (rstPreviewAdjustment.recordCount eq rstPreviewAdjustment.currentRow)>
			</table>
			<br />
			<br />
		</cfif>
		</cfloop>
		<form name="frmDataImport" action="#cgi.SCRIPT_NAME#?datatype=#url.datatype#&mode=preview&requesttimeout=2000" method="post">
		<input type="hidden" name="hidDataType" value="#form.hidDataType#">
		<input type="hidden" name="hidMode" value="preview">
		<div class="buttons">
		<input name="btnSubmit" type="submit" value="Create Adjustments and FOPs" />
		<input name="btnClear" type="reset" value="Return to File Upload" onclick="javascript:window.location='#cgi.SCRIPT_NAME#?datatype=#url.datatype#&mode=upload&requesttimeout=2000'" />
		<input name="btnCancel" type="button" value="Cancel" onClick="javascript:window.location='admin_main.cfm'" />
		</div>
		</form>
	<cfelse>
		<br />
		<h2>No Adjusments or FOPs will be created from this data.</h2>
		<br />
	</cfif>
	</cfoutput>
</cfcase>


<cfcase value="success">
	<div>
	<cfoutput>
	The #importDesc# data import process was successful.<br><br>
	
	<cfif form.hidDataType eq "NCFMSFOOT">
		<cfloop list="#strInsertNCFMSFoot.lstImportMessage#" index="msg" delimiters="~~">
			<li>#msg#</li>
		</cfloop>
		<br><br>View and Edit the <a href="data_footprint_match.cfm">AAPP Matching Discrepancies</a>
	<cfelseif form.hidDataType eq "adjustment">
		</div>
		<!---<cfdump var="#result.query#">--->	
		<cfset currType = "">
		<cfloop query="result.query">
		<cfif result.query.adjType[currentRow] is "ADJ">
			<cfset adjTypeName = "Adjustment">
		<cfelse>
			<cfset adjTypeName = "FOP">
		</cfif>
		<cfif adjType neq currType>
			<div>The following #adjTypeName#s were created</div>
			<table class="contentTbl" width="100%" cellspacing="0" cellpadding="0">
				<tr>
					<cfif adjType is "FOP"><th>FOP Number</th></cfif>
					<th>AAPP</th>
					<th>Description</th>
					<th>Cost Category</th>
					<th>Effective Date</th>
					<cfif adjType is "ADJ"><th>Ongoing</th></cfif>
					<th>Amount</th>
				</tr>
		</cfif>
				<tr>
					<cfif adjType is "FOP">
						<td align="center">
						#FOPNum#
						</td>
					</cfif>
					<td align="center">
						#AAPPNum#
					</td>
					<td>
						#description#
					</td>
					<td align="center">
						#costCatCode#
					</td>
					<td align="center">
						#dateFormat(effectiveDate, "mm/dd/yyyy")#
					</td>
					<cfif adjType is "ADJ">
						<td align="center">
						<cfif Ongoing is 1>Y<cfelse>N</cfif>
						</td>
					</cfif>
					<td align="right">
						#dollarFormat(Amount)#
					</td>
				</tr>
			<cfset currType = adjType>
		<cfif (currType neq result.query.adjType[currentRow + 1]) or (result.query.recordCount eq result.query.currentRow)>
			</table>
			<br />
			<br />
		</cfif>
	</cfloop>
	<div>	
	</cfif>
	
	Return to <a href="#application.paths.admin#">Admin</a>.
	
	</cfoutput>
	</div>
</cfcase>

</cfswitch>

<!--- include main footer file --->  
<cfinclude template="#application.paths.includes#footer.cfm">
