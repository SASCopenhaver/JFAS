<cfsilent>
<!---
page: fopbatch_dol_2.cfm

description: page that previews/executes/finalizes/un-dos fop batch process for DOL contracts

revisions:
2007-03-30	mstein	extended timeoust setting to 15 minutes (900 sec) so that it will not timeout in test
					added <cfif> to display 0 if amount is blank (~lines 207,235)
2007-04-11	yjeng	Add parameter py to B4 link
2007-04-25	yjeng	Add url parameter py to links
2007-05-15	yjeng	Change layout, add funding office num, program activity, venue, start date, end date
2007-06-05	rroser	changed print form button type from button to submit
2011-04-25	mstein	changed VST error message to replace VST with CTST (JFAS 2.8)
--->

<cfset request.pageID="2511">
<cfparam name="url.sortDir" default="asc">
<cfparam name="url.sortBy" default="aapp_num">
<cfparam name="url.py" default="#evaluate(request.py+1)#">
<cfparam name="form.py" default="#url.py#">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - FOP Batch Process (DOL)">
<cfset request.pageTitleDisplay = "FOP Batch Process for DOL Contracts: PY #form.py#">
<cfsetting requestTimeout = "900">

<!---Post Section--->
<cfif  isDefined("form.action") and form.action eq "exec">
	<cfinvoke component="#application.paths.components#fop_batch" method="ExeDOLFOPBatch" py="#form.py#" />	
<cfelseif isDefined("form.action") and form.action eq "undo">
	<cfinvoke component="#application.paths.components#fop_batch" method="UndoDOLFOPBatch" py="#form.py#" />	
	<cflocation url="admin_main.cfm" addtoken="no">
<cfelseif isDefined("form.action") and form.action eq "fin">
	<cfinvoke component="#application.paths.components#fop_batch" method="FinDOLFOPBatch" py="#form.py#" />		
	<cflocation url="admin_main.cfm" addtoken="no">
</cfif>

<!---Query Section--->
<!--- retrieve data from database --->
<!--- get list of AAPPs with FMS reports that are not current enough --->
<cfinvoke component="#application.paths.components#fop_batch" method="checkFMSReport" py="#form.py#" returnvariable="rstFMSNotRecent" />

<!--- get FOP estimates --->
<cfif not isDefined("url.cache")>
	<cfinvoke component="#application.paths.components#fop_batch" method="getEstFopSort" py="#form.py#" sortBy="#url.sortBy#" sortDir="#url.sortDir#" returnvariable="rstEstFopSort0" />
	<cfset session.rstEstFopSort1=rstEstFopSort0>
</cfif>
	

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

<!---
<cfquery name="vst_err" dbtype="query">
	select	aapp_num
	from	rstEstFopSort
	where	cost_cat_code='B4'
	and		amount=-1
</cfquery>
--->

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
The data below represents the list of FOP records that will be written to the system for Program Year <cfoutput>#form.py#</cfoutput>.
Click the "Execute FOP Batch Process" button to generate these FOPs in the database.<br /><br />

Note: Unless you have restricted access to this system, once this process is executed, all of these FOPs will be immediately visible to
other National and Regional Office users.
Access to the system can be restricted by using the <a href="user_access.cfm">User Access</a> component of the Admin module.
<br /><br />
<cfif rstFMSNotRecent.recordcount>
<cfoutput>
<span style="color:##FF0000; font-weight:bold">
Note: The following AAPPs started on or before #dateFormat(rstFMSNotRecent.good_report_date, "mm/dd/yyyy")#,
but do not have FMS reports in JFAS from that date (or later):
<cfloop query="rstFMSNotRecent">
<li style="margin-left:20px;">
	#aapp_num#&nbsp;&nbsp;
	(start date: #dateFormat(date_start, "mm/dd/yyyy")#;&nbsp;
	<cfif fms_report_date neq "">
		last FMS report: #dateFormat(fms_report_date, "mm/dd/yyyy")#)
	<cfelse>
		no FMS report found)
	</cfif>
</li>
</cfloop>
</span>
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
		<form action="#application.paths.reportdir#reports.cfm?rpt_id=15&cache=true&sortby=#url.sortby#&sortdir=#url.sortdir#" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
	<td width="50%">
		<!---<input type="button" name="" value="Print" onclick="this.form.submit();">--->
		<input type="submit" name="" value="Print" />
		<input type="hidden" name="py" value="#form.py#" />
		<input type="hidden" name="radReportFormat" value="application/pdf" />
	</td>
		</form>
	</cfoutput>	
	<form name="form1" action="fopbatch_dol_2.cfm" method="post">
	<td width="40%" align="right">
		<cfif rstEstFopSort.history_rec eq -1>
			<input type="submit" name="action_exec" value="Execute Batch Process" onclick="pleasewait(this);" />
		<cfelseif rstEstFopSort.history_rec eq 0>
			<input type="submit" name="action_undo" value="Undo Batch Process" onclick="pleasewait(this);" /><input type="submit" name="action_fin" value="Finalize Batch Process" onclick="pleasewait(this);" />
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
		<td style="text-align:center; vertical-align:text-top">#aapp_num#</td>
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
				<cfif cost_cat_code eq "B4"> <!--- link to open CTST worksheet --->
					<a href="#application.paths.reportdir#rpt_vst_worksheet.cfm?aapp=#aapp_num#&py=#form.py#" target="_blank">#cost_cat_code#</a>
				<cfelse>
					#cost_cat_code#
				</cfif>
			</td>
			<td align="center" nowrap>#fop_num#</td>
			<td align="right" nowrap>
				<cfif cost_cat_code eq "B4">
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
		</table>
	</td>
</tr>	
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
		<form action="#application.paths.reportdir#reports.cfm?rpt_id=15&cache=true&sortby=#url.sortby#&sortdir=#url.sortdir#" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
	<td width="50%">
		<input type="button" name="" value="Print" onclick="this.form.submit();">
		<input type="hidden" name="py" value="#form.py#" />
		<input type="hidden" name="radReportFormat" value="application/pdf" />
	</td>
		</form>
	</cfoutput>	
	<form name="form2" action="fopbatch_dol_2.cfm" method="post">
	<td width="40%" align="right">
		<cfif rstEstFopSort.history_rec eq -1>
			<input type="submit" name="action_exec1" value="Execute Batch Process" onclick="pleasewait(this);" />
		<cfelseif rstEstFopSort.history_rec eq 0>
			<input type="submit" name="action_undo1" value="Undo Batch Process" onclick="pleasewait(this);" /><input type="submit" name="action_fin1" value="Finalize Batch Process" onclick="pleasewait(this);" />
		</cfif>
	</td>
	<input type="hidden" name="action" value="" />
	</form>
</tr>
</table>


</div>

	

<!--- include main footer file --->  
<cfinclude template="#application.paths.includes#footer.cfm">