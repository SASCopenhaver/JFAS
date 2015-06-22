<cfsilent>
<!---
page: fopbatch_other_2.cfm

description: page that previews/executes/finalizes/un-dos fop batch process for DOL contracts other type

revisions:
2007-05-15	yjeng	Change layout, add funding office num, program activity, venue, start date, end date
2007-05-16	yjeng	Add report id 18
2007-06-05	rroser	changed print form button type from button to submit
2011-04-25	mstein	changed VST error message to replace VST with CTST (JFAS 2.8)
					adjusted code so that page is not as funky when no records are returned
2013-05-09	mstein	Added code to handle scenario with no Misc FOPs - presents diff message, and button to exec and finalize
--->

<cfset request.pageID="2531">
<cfparam name="url.sortDir" default="asc">
<cfparam name="url.sortBy" default="aapp_num">
<cfparam name="url.py" default="#evaluate(request.py_other+1)#">
<cfparam name="form.py" default="#url.py#">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - FOP Batch Process (DOL)">
<cfset request.pageTitleDisplay = "FOP Batch Process for Miscellaneous DOL AAPPs: PY #form.py#">
<cfsetting requestTimeout = "900">
<!---Post Section--->
<cfif  isDefined("form.action") and form.action eq "exec">
	<cfinvoke component="#application.paths.components#fop_batch" method="ExeOtherFOPBatch" py="#form.py#" />
<cfelseif  isDefined("form.action") and form.action eq "exec0sumFOP">
	<cfinvoke component="#application.paths.components#fop_batch" method="ExeZeroSum_OtherFOP" py="#form.py#" />
	<cflocation url="admin_main.cfm" addtoken="no">	
<cfelseif isDefined("form.action") and form.action eq "undo">
	<cfinvoke component="#application.paths.components#fop_batch" method="UndoOtherFOPBatch" py="#form.py#" />	
	<cflocation url="admin_main.cfm" addtoken="no">
<cfelseif isDefined("form.action") and form.action eq "fin">
	<cfinvoke component="#application.paths.components#fop_batch" method="FinOtherFOPBatch" py="#form.py#" />		
	<cflocation url="admin_main.cfm" addtoken="no">
</cfif>
<!---Query Section--->
<!--- retrieve data from database --->
<cfif not isDefined("url.cache")>
	<cfinvoke component="#application.paths.components#fop_batch" method="getEstFopSort" py="#form.py#" adj_type="OTHER" sortBy="#url.sortBy#" sortDir="#url.sortDir#" returnvariable="rstEstFopSort0" />
	<cfset session.rstEstFopSort1=rstEstFopSort0>
</cfif>
<cfset vst_msg="Note: There are certain AAPPs on this page for which the latest FMS report date is earlier than 03/31/#form.py#. A current FMS report is required for calculation of the CTST allocation. The FOP Batch Process can not be executed until this problem has been fixed.">
<cfquery name="rstEstFopSort" dbtype="query">
	select	*
	from	session.rstEstFopSort1
<cfif #url.sortby# neq "aapp_num">
	order by #url.sortby# #url.sortDir#, aapp_num asc, cost_cat_code asc
<cfelse>
	order by #url.sortby# #url.sortDir#, center_name asc, cost_cat_code asc
</cfif>
</cfquery>
<cfquery name="rstEstFopTotal" dbtype="query">
	select	cost_cat_code, sum(amount) as amount
	from	rstEstFopSort
	where	cost_cat_code!='B4'
	group by cost_cat_code
	union
	select	cost_cat_code, sum(amount) as amount
	from	rstEstFopSort
	where	cost_cat_code='B4'
	and		amount!=-1
	group by cost_cat_code
	order by cost_cat_code
</cfquery>
<cfquery name="vst_err" dbtype="query">
	select	aapp_num
	from	rstEstFopSort
	where	cost_cat_code='B4'
	and		amount=-1
</cfquery>

<!--- Batch Process for Misc Items frequently results in $0 in FOPs --->
<!--- Need to check for this, to present other options for user (immediate update of system PY value) --->
<cfquery name="qryGetGrandTotal" dbtype="query">
select sum(amount) as fopGrandTotal
from rstEstFopTotal
</cfquery>

</cfsilent>



<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">
<script language="javascript1.1" type="text/javascript">
function pleasewait(s) {
	if (s.name=='action_exec' || s.name=='action_exec1') {
		document.form1.action_exec.value='Please wait..';
		document.form1.action_exec.disabled=true;
		document.form2.action_exec1.value='Please wait..';
		document.form2.action_exec1.disabled=true;
		s.form.action.value='exec';
		s.form.submit();
	}
	else if (s.name=='action_exec_0fop') {
		document.form1.action_exec_0fop.value='Please wait..';
		document.form1.action_exec_0fop.disabled=true;
		s.form.action.value='exec0sumFOP';
		s.form.submit();
	}
	else if (s.name=='action_undo' || s.name=='action_undo1') {
		document.form1.action_undo.value='Please wait..';
		document.form1.action_undo.disabled=true;
		document.form2.action_undo1.value='Please wait..';
		document.form2.action_undo1.disabled=true;
		s.form.action.value='undo';
		document.form1.action_fin.style.visibility = "hidden";
		document.form2.action_fin1.style.visibility = "hidden";
		s.form.submit();
	}	
	else if (s.name=='action_fin' || s.name=='action_fin1') {
		document.form1.action_fin.value='Please wait..';
		document.form1.action_fin.disabled=true;
		document.form2.action_fin1.value='Please wait..';
		document.form2.action_fin1.disabled=true;
		s.form.action.value='fin';
		document.form1.action_undo.style.visibility = "hidden";
		document.form2.action_undo1.style.visibility = "hidden";
		s.form.submit();
	}
}
</script>

<div>
<span style="color:#999999">Step 1: Start</span> &nbsp;&nbsp;|&nbsp;&nbsp;
<cfif rstEstFopSort.history_rec eq -1>
<strong>Step 2: Preview FOP Changes</strong> &nbsp;&nbsp;|&nbsp;&nbsp; 
<span style="color:#999999">Step 3: Execute Batch Process</span>&nbsp;&nbsp;|&nbsp;&nbsp; 
<span style="color:#999999">Step 4: Finalize Batch Process</span>
<cfelseif rstEstFopSort.history_rec eq 0>
<span style="color:#999999">Step 2: Preview FOP Changes</span> &nbsp;&nbsp;|&nbsp;&nbsp; 
<strong>Step 3: Execute Batch Process</strong>&nbsp;&nbsp;|&nbsp;&nbsp; 
<span style="color:#999999">Step 4: Finalize Batch Process</span> 
<cfelseif rstEstFopSort.history_rec eq 1>
<span style="color:#999999">Step 2: Preview FOP Changes</span> &nbsp;&nbsp;|&nbsp;&nbsp; 
<span style="color:#999999">Step 3: Execute Batch Process</span>&nbsp;&nbsp;|&nbsp;&nbsp; 
<strong>Step 4: Finalize Batch Process</strong> 
</cfif>
</div>

<p></p>

<div>
<cfif rstEstFopSort.history_rec eq -1>
	<cfif qryGetGrandTotal.fopGrandTotal neq 0>
	The data below represents the list of FOP records that will be written to the system for Program Year <cfoutput>#form.py#</cfoutput>.
	Click the "Execute FOP Batch Process" button to generate these FOPs in the database.<br /><br />
	Note: Unless you have restricted access to this system, once this process is executed, all of these FOPs will be immediately visible to
	other National and Regional Office users.
	Access to the system can be restricted by using the <a href="user_access.cfm">User Access</a> component of the Admin module.
	<cfelse>
	No FOP amounts have been entered for the coming Program Year on miscellaneous DOL contracts. If you wish to generate FOPs as part
	of the batch process, you will need to navigate to the AAPP by either (1) clicking on the linked AAPP number below, or (2) going to the AAPP,
	and then clicking on the "New PY Budget" tab.<br><br>
	<span style="background-color:#FFFF99">
	If you do not wish generate FOPs as part of the batch process, you can click the "No FOPs to Generate..." button below. This will 
	execute and finalize this process, and update the system PY (for miscellaneous contracts).</span>
	</cfif>
<br /><br />
<cfif vst_err.recordcount>
<cfoutput>
<span style="color:##FF0000; font-weight:bold">#vst_msg#</span>
<br /><br />
</cfoutput>
</cfif>
<cfelseif rstEstFopSort.history_rec eq 0>
Below is the complete list of FOP records that were created as a result of the Program Year <cfoutput>#form.py#</cfoutput> Batch Process.
All of the FOPs below are visible to any users who currently have access to the system. <br /><br />
This process can be reversed by clicking the "Undo Batch Process" button below. This will remove all of the <cfoutput>#form.py#</cfoutput> FOPs in the system,
including any that have been created since this process was run.
<br /><br />
To finalize the batch process, click the "Finalize batch Process" button below. Once this is done, the official Program Year in the
system will be set to <cfoutput>#form.py#</cfoutput>, and the batch process can no longer be undone.<br /><br />
<cfelseif rstEstFopSort.history_rec eq 1>
Below is a list of the FOPs that were created as a result of the PY <cfoutput>#form.py#</cfoutput> Batch Process.<br /><br />
</cfif>
</div>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">

<tr>
	<cfoutput>
		<form action="#application.paths.reportdir#reports.cfm?rpt_id=18&cache=true&sortby=#url.sortby#&sortdir=#url.sortdir#" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
	<td width="50%">
		<!---<input type="button" name="" value="Print" onclick="this.form.submit();">--->
		<input type="submit" name="" value="Print" />
		<input type="hidden" name="py" value="#form.py#" />
		<input type="hidden" name="radReportFormat" value="application/pdf" />
	</td>
		</form>
	</cfoutput>	
	<form name="form1" action="fopbatch_other_2.cfm" method="post">
	<td width="40%" align="right">
		<cfif not vst_err.recordcount>
			<cfif rstEstFopSort.history_rec eq -1>
				<cfif qryGetGrandTotal.fopGrandTotal neq 0>
					<input type="submit" name="action_exec" value="Execute Batch Process" onclick="pleasewait(this);" />
				<cfelse>
					<input type="submit" name="action_exec_0fop" value="No FOPs to Generate - Update to Next PY" onclick="pleasewait(this);" />
				</cfif>
			<cfelseif rstEstFopSort.history_rec eq 0>
				<input type="submit" name="action_undo" value="Undo Batch Process" onclick="pleasewait(this);" /><input type="submit" name="action_fin" value="Finalize Batch Process" onclick="pleasewait(this);" />
			</cfif>	
		</cfif>
	</td>
	<input type="hidden" name="action" value="" />
	</form>
</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
<tr>
	<cfoutput>
	<th style="text-align:center; vertical-align:text-top"><a href="fopbatch_dol_2.cfm?cache=true&py=#form.py#&sortby=aapp_num&sortdir=<cfif url.sortby eq "aapp_num" and url.sortdir eq "asc">desc<cfelse>asc</cfif>">AAPP</a></th>
	<th style="text-align:left; vertical-align:text-top"><a href="fopbatch_dol_2.cfm?cache=true&py=#form.py#&sortby=funding_office_num&sortdir=<cfif url.sortby eq "funding_office_num" and url.sortdir eq "asc">desc<cfelse>asc</cfif>">Funding Office</a></th>
	<th style="text-align:left; vertical-align:text-top"><a href="fopbatch_dol_2.cfm?cache=true&py=#form.py#&sortby=center_name&sortdir=<cfif url.sortby eq "center_name" and url.sortdir eq "asc">desc<cfelse>asc</cfif>">Center</a></th>
	<th style="text-align:left; vertical-align:text-top">Program Activity</th>
	<th style="text-align:left; vertical-align:text-top"><a href="fopbatch_dol_2.cfm?cache=true&py=#form.py#&sortby=venue&sortdir=<cfif url.sortby eq "venue" and url.sortdir eq "asc">desc<cfelse>asc</cfif>">Venue</a></th>
	<th style="text-align:left; vertical-align:text-top">Start/End Date</th>
	<th></th>
	</cfoutput>
</tr>
<cfset same_aapp=0>
<cfset altrow=-1>
<cfoutput query="rstEstFopSort">
	<cfif same_aapp neq aapp_num>
		<cfset altrow=altrow+1>
	</cfif>
	<cfif same_aapp neq aapp_num>
		<cfif same_aapp neq 0>
			</table>
		</td>	
	</tr>	
		</cfif>
		<cfset same_aapp=aapp_num>
	<tr <cfif altrow mod 2>class="AltRow"</cfif>>
		<td style="text-align:center; vertical-align:text-top">
			<a name="#aapp_num#" href="#application.paths.aappdir#aapp_newpy_budget.cfm?aapp=#aapp_num#">#aapp_num#</a>
		</td>
		<td style="text-align:left; vertical-align:text-top">#funding_office_num#</td>
		<td style="text-align:left; vertical-align:text-top">#center_name#</td>
		<td style="text-align:left; vertical-align:text-top">#prog_services#</td>
		<td style="text-align:left; vertical-align:text-top">#venue#</td>
		<td style="text-align:left; vertical-align:text-top">#start_date#<br />#end_date#</td>
		<td>
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
	</cfif>
		<tr>	
			<td align="center">
				<cfif cost_cat_code eq "B4" and listfind(valuelist(vst_err.aapp_num),aapp_num)>
					<a href="#application.paths.reportdir#rpt_vst_worksheet.cfm?aapp=#aapp_num#&py=#form.py#" target="_blank" style="color:##FF0000">#cost_cat_code#</a>
				<cfelseif cost_cat_code eq "B4" and not listfind(valuelist(vst_err.aapp_num),aapp_num)>
					<a href="#application.paths.reportdir#rpt_vst_worksheet.cfm?aapp=#aapp_num#&py=#form.py#" target="_blank">#cost_cat_code#</a>
				<cfelse>
					#cost_cat_code#
				</cfif>
			</td>
			<td align="center" nowrap>#fop_num#</td>
			<td align="right" nowrap>
				<cfif cost_cat_code eq "B4" and listfind(valuelist(vst_err.aapp_num),aapp_num)>
					<a href="#application.paths.reportdir#rpt_vst_worksheet.cfm?aapp=#aapp_num#&py=#form.py#" target="_blank" style="color:##FF0000">NA</a>
				<cfelseif cost_cat_code eq "B4" and not listfind(valuelist(vst_err.aapp_num),aapp_num)>
					<a href="#application.paths.reportdir#rpt_vst_worksheet.cfm?aapp=#aapp_num#&py=#form.py#" target="_blank"><cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#</a></td>
				<cfelse>
					<!--- mstein 2007-03-30 --->
					<cfif amount eq "">
						0
					<cfelse>
						<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#
					</cfif>
				</cfif>
			</td>
		</tr>
</cfoutput>
<cfif rstEstFopSort.recordcount>
			</table>
		</td>
	</tr>
</cfif>	
<tr>
	<td colspan="7">&nbsp;</td>
</tr>
<tr>
	<td colspan="7" class="hrule"></td>
</tr>
<cfoutput query="rstEstFopTotal">
	<tr>
		<td colspan="5">
		<cfif currentrow eq 1>
			<strong>Totals by Cost Category</strong>
		<cfelse>
			&nbsp;
		</cfif>	
		</td>
		<td align="center"><strong>#cost_cat_code#</strong></td>
		<td align="right">
			<strong>
			<!--- mstein 2007-03-30 --->
			<cfif amount eq "">
				0
			<cfelse>
				<cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#
			</cfif>
			</strong></td>
	</tr>
</cfoutput>
</table>

<p></p>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<tr>
	<cfoutput>
		<form action="#application.paths.reportdir#reports.cfm?rpt_id=18&cache=true&sortby=#url.sortby#&sortdir=#url.sortdir#" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
	<td width="50%">
		<input type="button" name="" value="Print" onclick="this.form.submit();">
		<input type="hidden" name="py" value="#form.py#" />
		<input type="hidden" name="radReportFormat" value="application/pdf" />
	</td>
		</form>
	</cfoutput>	
	<form name="form2" action="fopbatch_other_2.cfm" method="post">
	<td width="40%" align="right">
		<cfif not vst_err.recordcount>
			<cfif rstEstFopSort.history_rec eq -1>
				<cfif qryGetGrandTotal.fopGrandTotal neq 0>
					<input type="submit" name="action_exec1" value="Execute Batch Process" onclick="pleasewait(this);" />
				</cfif>
			<cfelseif rstEstFopSort.history_rec eq 0>
				<input type="submit" name="action_undo1" value="Undo Batch Process" onclick="pleasewait(this);" /><input type="submit" name="action_fin1" value="Finalize Batch Process" onclick="pleasewait(this);" />
			</cfif>	
		</cfif>
	</td>
	<input type="hidden" name="action" value="" />
	</form>
</tr>
</table>


</div>

	

<!--- include main footer file --->  
<cfinclude template="#application.paths.includes#footer.cfm">