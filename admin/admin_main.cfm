<cfsilent>
<!---
page: reports_main.cfm

description: root page of reports section

revisions:
2007-03-18	mstein	Completed functionality for display of batch process menu items
2007-04-05	mstein	Defect with pyEndDate - need dol and ccc value
2007-04-06	mstein	Defect with "Finalize" on CCC process... using DOL PY instead of CCC PY
2007-05-03  abai    Add data export part.
2007-05-15  yjeng   Add FOP Batch Process for Miscellaneous DOL AAPPs
2007-06-05	mstein	Added special handling of MIsc FOP Batch Process (separate request.py var
2007-08-26	rroser	Added link for footprint/transaction page
2009-12-22	mstein	Changes to Dat Imports section for NCFMS (removed links for some import types)
--->

<cfset request.pageID="2000">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "JFAS System Administration">

<!-- code to force CF error (to test error handling) --->
<cfif isDefined("url.showError")>
	<cfset errVal = 5/0>
</cfif>

<cfinvoke component="#application.paths.components#dataadmin" method="getImportTypeInfo" returnvariable="rstImportTypeInfo" status=1>
<cfset batchWindowDays = application.outility.getSystemSetting(systemSettingCode="batchprocess_window")>


<cfset pyEndDate_dol = application.outility.getProgramYearDate ( py="#request.py#", type="E")>
<cfset pyEndDate_other = application.outility.getProgramYearDate ( py="#request.py_other#", type="E")>
<cfset pyEndDate_ccc = application.outility.getProgramYearDate ( py="#request.py_ccc#", type="E")>
<cfinvoke component="#application.paths.components#fop_batch" method="getBatchProcessList" type="DOLFOP" status="1" returnvariable="rstPrevBatchProcess_dol">
<cfinvoke component="#application.paths.components#fop_batch" method="getBatchProcessList" type="DOLFOP" py="#evaluate(request.py + 1)#" returnvariable="rstNextBatchProcess_dol">
<cfinvoke component="#application.paths.components#fop_batch" method="getBatchProcessList" type="OTHER" status="1" returnvariable="rstPrevBatchProcess_other">
<cfinvoke component="#application.paths.components#fop_batch" method="getBatchProcessList" type="OTHER" py="#evaluate(request.py_other + 1)#" returnvariable="rstNextBatchProcess_other">
<cfinvoke component="#application.paths.components#fop_batch" method="getBatchProcessList" type="CCC" status="1" returnvariable="rstPrevBatchProcess_ccc">
<cfinvoke component="#application.paths.components#fop_batch" method="getBatchProcessList" type="CCC" py="#evaluate(request.py_ccc + 1)#" returnvariable="rstNextBatchProcess_ccc">

<cfinvoke component="#application.paths.components#dataadmin" method="f_getJfasSnapshot" returnvariable="rtn_getJfasSnapshot">
<!---<cfdump var="#rtn_getJfasSnapshot#"><cfabort>--->
</cfsilent>

<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">

<script>
// function f_onClick applies to the section: "JFAS Snapshot Log"
function f_onClick(arg_CtrlID)
{	
	var v_SnapsotObject = arg_CtrlID.substr(3); // Ex: AAPP_CONTRACT_SNAPSHOT
		
	document.getElementById(arg_CtrlID).value = "Rebuilding...";
	document.getElementById(arg_CtrlID).disabled = true;
	window.location.href = "rebuild_snapshots.cfm?argSnapshotName="+v_SnapsotObject;
}
</script>
<p></p>
<h2>User Management</h2>
<div>
&nbsp;&nbsp;-&nbsp;<a href="users.cfm">Users</a><br />
&nbsp;&nbsp;-&nbsp;<a href="user_access.cfm">User Access Controls</a><br />
&nbsp;&nbsp;-&nbsp;<a href="message_edit.cfm">User Alert Messages</a><br />
<br />
</div>

<h2>Data Imports</h2>
<div>

<!--- loop through data imports, displaying last successful import date (and unsuccessful, if most recent --->
<table width="95%" cellpadding="0" cellspacing="0" summary="List of Data Imports">
<cfoutput query="rstImportTypeInfo">
	<tr>
		<td width="1%"></td>
		<td>
			<cfif allow_upload eq 1>
				-&nbsp;<a href="data_import.cfm?datatype=#importTypeCode#&mode=upload">#importTypeDesc#</a>
			<cfelse>
				-&nbsp;#importTypeDesc#
			</cfif>
		</td>
		<td>
			<cfif dateLastSuccess neq "">
				last import: #dateFormat(dateLastSuccess, "mm/dd/yyyy")#, #timeformat(dateLastSuccess)#
				<cfif dateLastFail neq "" and dateCompare(dateLastSuccess, dateLastFail) eq -1>
					--
					<span style="color:red;">failed import on #dateFormat(dateLastFail, "mm/dd/yyyy")#, #timeformat(dateLastFail)#</span>
				</cfif>
			</cfif>
		</td>
		<td align="right">
			<cfif dateLastSuccess neq "">
				<a href="data_import_log.cfm?importType=#importTypeCode#">View Import History</a>
			</cfif>
		</td>
	</tr>
</cfoutput>
<tr><td>&nbsp;</td></tr>
<tr>
	<td></td>
	<td colspan="2">-&nbsp;<a href="data_footprint_match.cfm">Unmatched NCFMS Document Numbers</a></td>
</tr>
<tr>
	<td></td>
	<td colspan="2">-&nbsp;<a href="data_import_params.cfm">NCFMS Data Import Settings (PO Subledger)</a></td>
</tr>
<tr>
	<td></td>
	<td colspan="2">-&nbsp;<a href="data_import_params_ncfmsbudget.cfm">NCFMS Data Import Settings (Budget Execution Balances)</a></td>
</tr>

</table>

<br />
</div>

<h2>Inflation Rate Adjustments</h2>
<div>
&nbsp;&nbsp;-&nbsp;<a href="omb_inflation.cfm">OMB Inflation Rates</a><br />
&nbsp;&nbsp;-&nbsp;<a href="fpw_inflation.cfm">Federal Personnel Inflation Rates</a><br />
<!---&nbsp;&nbsp;-&nbsp;Federal Personnel Wages<br />--->
<br />
</div>

<h2>Reference Data Management</h2>
<div>
<!---&nbsp;&nbsp;-&nbsp;<a href="program_year_budget.cfm">Program Year Budget</a><br />--->
&nbsp;&nbsp;-&nbsp;<a href="center_list.cfm">Centers</a><br />
&nbsp;&nbsp;-&nbsp;<a href="contractor_list.cfm">Contractors</a><br />
&nbsp;&nbsp;-&nbsp;<a href="contractor_perf.cfm">Contractor Performance Ratings and Rollover Rates</a><br />
&nbsp;&nbsp;-&nbsp;<a href="rcccode_list.cfm">RCC Codes</a><br />
&nbsp;&nbsp;-&nbsp;<a href="setaside_list.cfm">Small Business Set Aside Categories</a><br />
&nbsp;&nbsp;-&nbsp;<a href="ba_transfer_edit.cfm">CCC Budget Auth. Transfer Percentages</a><br />
&nbsp;&nbsp;-&nbsp;<a href="aapp_deleteunfunded.cfm">Remove an Unfunded AAPP</a><br />
&nbsp;&nbsp;-&nbsp;<a href="systemsetting_edit.cfm">System Settings</a><br />
&nbsp;&nbsp;-&nbsp;<a href="recentUpdates_list.cfm">Recent Updates</a><br />
<br />
</div>

<form name="frmBatchProcessDOL" action="fopbatch_dol_2.cfm" method="post">
<h2>Batch Processes</h2>
<div>
<cfoutput>
<cfif rstNextBatchProcess_dol.recordcount>
	<!--- batch process for next py has been executed but not finalized --->
	&nbsp;&nbsp;-&nbsp;<a href="fopbatch_dol_2.cfm">Finalize PY #evaluate(request.py+1)# FOP Batch Process (DOL Contracts)</a><br />
<cfelse>
	<!--- batch process for next PY has not been executed --->
	<!--- only show link if current date is within available "window" for running process --->
	&nbsp;&nbsp;-&nbsp;
	<cfif abs(datediff("d",pyEndDate_dol, now())) lte (batchWindowDays)>
		<a href="fopbatch_dol_1.cfm">
	</cfif>
	Initiate PY #evaluate(request.py+1)# FOP Batch Process (DOL Contracts)
	<cfif abs(datediff("d",pyEndDate_dol, now())) lte batchWindowDays>
		</a>
	<cfelse>
		&nbsp;&nbsp;&nbsp;
		<span style="color:gray;"><em>(this process can be run between #dateformat(dateadd("d",0-(batchWindowDays+1),pyEndDate_dol), "mm/dd/yyyy")# and
		#dateformat(dateadd("d",batchWindowDays+1,pyEndDate_dol), "mm/dd/yyyy")#)
		</em></span>
	</cfif><br />
</cfif>
</cfoutput>
<cfif rstPrevBatchProcess_dol.recordcount>
	&nbsp;&nbsp;-&nbsp;&nbsp;View Results from previous FOP Batch Process (DOL Contracts)&nbsp;
	<select name="PY">
	<cfoutput query="rstPrevBatchProcess_dol">
	<option value="#py#">#py#</option>
	</cfoutput>
	</select>
	<input type="submit" name="" value="Go" />
</cfif>
</form>

<form name="frmBatchProcessOTHER" action="fopbatch_other_2.cfm" method="post">
<cfoutput>
<cfif rstNextBatchProcess_other.recordcount>
	<!--- batch process for next py has been executed but not finalized --->
	&nbsp;&nbsp;-&nbsp;<a href="fopbatch_other_2.cfm">Finalize PY #evaluate(request.py_other+1)# FOP Batch Process (Miscellaneous DOL AAPPs)</a><br />
<cfelse>
	<!--- batch process for next PY has not been executed --->
	<!--- only show link if current date is within available "window" for running process --->
	&nbsp;&nbsp;-&nbsp;
	<cfif abs(datediff("d",pyEndDate_other, now())) lte (batchWindowDays)>
		<a href="fopbatch_other_1.cfm">
	</cfif>
	Initiate PY #evaluate(request.py_other+1)# FOP Batch Process (Miscellaneous DOL AAPPs)
	<cfif abs(datediff("d",pyEndDate_other, now())) lte batchWindowDays>
		</a>
	<cfelse>
		&nbsp;&nbsp;&nbsp;
		<span style="color:gray;"><em>(this process can be run between #dateformat(dateadd("d",0-(batchWindowDays+1),pyEndDate_other), "mm/dd/yyyy")# and
		#dateformat(dateadd("d",batchWindowDays+1,pyEndDate_other), "mm/dd/yyyy")#)
		</em></span>
	</cfif><br />
</cfif>
</cfoutput>
<cfif rstPrevBatchProcess_other.recordcount>
	&nbsp;&nbsp;-&nbsp;&nbsp;View Results from previous FOP Batch Process (Miscellaneous DOL AAPPs)&nbsp;
	<select name="PY">
	<cfoutput query="rstPrevBatchProcess_other">
	<option value="#py#">#py#</option>
	</cfoutput>
	</select>
	<input type="submit" name="" value="Go" />
</cfif>
</form>

<form name="frmBatchProcessCCC" action="fopbatch_ccc_2.cfm" method="post">
<cfoutput>
<cfif rstNextBatchProcess_ccc.recordcount>
	<!--- batch process for next py has been executed but not finalized --->
	&nbsp;&nbsp;-&nbsp;<a href="fopbatch_ccc_2.cfm">Finalize PY #evaluate(request.py_ccc+1)# FOP Batch Process (CCCs)</a><br />
<cfelse>
	<!--- batch process for next PY has not been executed --->
	<!--- only show link if current date is within available "window" for running process --->
	&nbsp;&nbsp;-&nbsp;
	<cfif abs(datediff("d",pyEndDate_ccc, now())) lte (batchWindowDays)>
		<a href="fopbatch_ccc_1.cfm">
	</cfif>
	Initiate PY #evaluate(request.py_ccc+1)# FOP Batch Process (CCCs)
	<cfif abs(datediff("d",pyEndDate_ccc, now())) lte batchWindowDays>
		</a>
	<cfelse>
		&nbsp;&nbsp;&nbsp;
		<span style="color:gray;"><em>(this process can be run between #dateformat(dateadd("d",0-(batchWindowDays+1),pyEndDate_ccc), "mm/dd/yyyy")# and
		#dateformat(dateadd("d",batchWindowDays+1,pyEndDate_ccc), "mm/dd/yyyy")#)
		</em></span>
	</cfif><br />
</cfif>
</cfoutput>
<cfif rstPrevBatchProcess_ccc.recordcount>
	&nbsp;&nbsp;-&nbsp;&nbsp;View Results from previous FOP Batch Process (CCCs)&nbsp;
	<select name="PY_CCC">
	<cfoutput query="rstPrevBatchProcess_ccc">
	<option value="#py#">#py#</option>
	</cfoutput>
	</select>
	<input type="submit" name="" value="Go" />
</cfif>
</div>
<p></p>
</form>

<h2>JFAS Snapshot Log</h2>
<div id="div_Snapshot">
        <table width="95%" border="0" cellspacing="1" cellpadding="1">
        <cfoutput query="rtn_getJfasSnapshot">
          <tr>
            <td width="35%">&nbsp;&nbsp;-&nbsp;&nbsp;#SNAPSHOT_OBJECT_DESC#</td>
            <td width="25%">updated #DateFormat(UPDATE_TIME,"mm/dd/yyyy")#, #TimeFormat(UPDATE_TIME,"hh:mm")#</td>
            <td width="29%">#UPDATE_NOTES#</td>
            <td width="*" align="right"><input type="submit" 
                                   id="cb_#SNAPSHOT_OBJECT#" 
                                   name="cb_#SNAPSHOT_OBJECT#" 
                                   onClick="javascript: f_onClick(this.id)" 
                                   value="&nbsp;&nbsp;Rebuild&nbsp;&nbsp;&nbsp;" />
            </td>
          </tr>
        </cfoutput>
        </table>
</div>

<br />
<br />

<!--- no longer displaying link to export FilePro data
<h2>Data Exports</h2>
<div>
&nbsp;&nbsp;-&nbsp;<a href="data_export.cfm">JFAS Export to FilePro</a><br />
<br />
</div>
 --->

<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">