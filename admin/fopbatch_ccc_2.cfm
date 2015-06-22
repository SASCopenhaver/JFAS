<cfsilent>
<!---
page: fopbatch_ccc_2.cfm

description: page that previews/executes/finalizes/un-dos fop batch process for CCC contracts

revisions:
2007-04-02	yjeng	Fixed Print button.
2007-04-05	yjeng	Add summary for funding office
2007-04-10	yjeng	Add white spance between center name and agency name, add print button target
2007-04-25	yjeng	Add url parameter py to links
2007-06-05	rroser	changed print form button type from button to submit
--->

<cfset request.pageID="2521">
<cfparam name="url.sortDir" default="asc">
<cfparam name="url.sortBy" default="center_name">
<cfparam name="url.py_ccc" default="#evaluate(request.py_ccc+1)#">
<cfparam name="form.py_ccc" default="#url.py_ccc#">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - FOP Batch Process (CCC)">
<cfset request.pageTitleDisplay = "FOP Batch Process for CCCs: PY #form.py_ccc#">
<!---Post Section--->
<cfif  isDefined("form.action_exec")>
	<cfinvoke component="#application.paths.components#fop_batch" method="ExeCCCFOPBatch" py="#form.py_ccc#" />
<cfelseif isDefined("form.action_undo")>
	<cfinvoke component="#application.paths.components#fop_batch" method="UndoCCCFOPBatch" py="#form.py_ccc#" />
	<cflocation url="admin_main.cfm" addtoken="no">
<cfelseif isDefined("form.action_fin")>
	<cfinvoke component="#application.paths.components#fop_batch" method="FinCCCFOPBatch" py="#form.py_ccc#" />
	<cflocation url="admin_main.cfm" addtoken="no">
</cfif>
<!---Query Section--->
<!--- retrieve data from database --->
<cfif not isDefined("url.cache")>
	<cfinvoke component="#application.paths.components#fop_batch" method="getCCCEstFop" py="#form.py_ccc#" returnvariable="rstEstFopSort0" />
	<cfset session.rstEstFopSort1=rstEstFopSort0>
</cfif>
<cfquery name="rstEstFopSort" dbtype="query">
	select	*
	from	session.rstEstFopSort1
	order by #url.sortby# #url.sortDir#
</cfquery>
<cfquery name="rstEstFopTotal" dbtype="query">
	select	funding_office_desc, group_code, sum(amount) as amount
	from	rstEstFopSort
	group by funding_office_desc, group_code
</cfquery>
<cfquery name="rstCenter" dbtype="query">
	select	distinct center_name
	from	session.rstEstFopSort1
	order by center_name
</cfquery>
<cfset col=4>
<cfset blank_filler="NA">
<cfset rstlist = application.outility.VerticalList ( col="#col#", blank_filler="#blank_filler#", list="#valuelist(rstCenter.center_name)#") />
</cfsilent>
<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">

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
The data below represents the list of FOP records that will be written to the system for Program Year <cfoutput>#form.py_ccc#</cfoutput>.
Click the "Execute FOP Batch Process" button to generate these FOPs in the database.<br /><br />

Note: Unless you have restricted access to this system, once this process is executed, all of these FOPs will be immediately visible to
other National and Regional Office users.
Access to the system can be restricted by using the <a href="user_access.cfm">User Access</a> component of the Admin module.
<br /><br />
<cfelseif rstEstFopSort.history_rec eq 0>
Below is the complete list of FOP records that were created as a result of the Program Year <cfoutput>#form.py_ccc#</cfoutput> Batch Process.
All of the FOPs below are visible to any users who currently have access to the system. <br /><br />
This process can be reversed by clicking the "Undo Batch Process" button below. This will remove all of the <cfoutput>#form.py_ccc#</cfoutput> FOPs in the system,
including any that have been created since this process was run.
<br /><br />
To finalize the batch process, click the "Finalize batch Process" button below. Once this is done, the official Program Year in the
system will be set to <cfoutput>#form.py_ccc#</cfoutput>, and the batch process can no longer be undone.<br /><br />
<cfelseif rstEstFopSort.history_rec eq 1>
Below is a list of the FOPs that were created as a result of the PY <cfoutput>#form.py_ccc#</cfoutput> Batch Process.<br /><br />
</cfif>
</div>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<tr>
	<cfoutput>
	<form action="#application.paths.reportdir#reports.cfm?rpt_id=16&cache=true&sortby=#url.sortby#&sortdir=#url.sortdir#" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
	<td width="50%">
		<!---<input type="button" name="" value="Print" onclick="this.form.submit();">--->
		<input type="submit" name="" value="Print" />
		<input type="hidden" name="py_ccc" value="#form.py_ccc#" />
		<input type="hidden" name="radReportFormat" value="application/pdf" />
	</td>
	</form>
	</cfoutput>
	<form action="fopbatch_ccc_2.cfm" method="post">
	<td width="40%" align="right">
		<cfif rstEstFopSort.history_rec eq -1>
			<input type="submit" name="action_exec" value="Execute Batch Process" />
		<cfelseif rstEstFopSort.history_rec eq 0>
			<input type="submit" name="action_undo" value="Undo Batch Process" /><input type="submit" name="action_fin" value="Finalize Batch Process" />
		</cfif>
	</td>
	</form>
</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<tr class="AltRow">
	<td valign="top" colspan="4">Centers</td>
</tr>

<tr valign="top">
<cfoutput>
	<cfloop index="idx" from="1" to="#listlen(rstlist)#">
		<td width="25%">
			<cfif listgetat(rstlist,idx) neq #blank_filler#>
				<a href="###listgetat(rstlist,idx)#">#listgetat(rstlist,idx)#</a>
			</cfif>
		</td>
		<cfif idx MOD col IS 0>
			</tr>
			<tr>
			</tr>
		</cfif>
	</cfloop>
</cfoutput>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
<tr>
	<cfoutput>
	<th style="text-align:left"><a href="fopbatch_ccc_2.cfm?cache=true&py_ccc=#form.py_ccc#&sortby=center_name&sortdir=<cfif url.sortby eq "center_name" and url.sortdir eq "asc">desc<cfelse>asc</cfif>">Center Name</a></th>
	<th style="text-align:center"><a href="fopbatch_ccc_2.cfm?cache=true&py_ccc=#form.py_ccc#&sortby=aapp_num&sortdir=<cfif url.sortby eq "aapp_num" and url.sortdir eq "asc">desc<cfelse>asc</cfif>">AAPP</a></th>
	</cfoutput>
	<th style="text-align:center">Cost Category</th>
	<th style="text-align:center">FOP Number</th>
	<th style="text-align:right">Amount</th>
</tr>
<cfset altrow=1>
<cfset curaapp=0>
<cfoutput query="rstEstFopSort">
	<cfif curaapp neq aapp_num>
	<cfset altrow=altrow+1>
	<tr <cfif altrow mod 2>class="AltRow"</cfif>>
		<td><a name="#center_name#">#center_name#</a></td>
		<td align="center"><a name="#aapp_num#" href="#application.paths.aappdir#aapp_worksheet_ccc.cfm?aapp=#aapp_num#&fromPage=preview">#aapp_num#</a></td>
		<cfset curaapp=aapp_num>
	<cfelse>
	<tr <cfif altrow mod 2>class="AltRow"</cfif>>
		<td></td>
		<td></td>
	</cfif>
	<td align="center">#cost_cat_code#</td>
	<td align="center">#fop_num#</td>
	<td align="right"><cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#</td>
	</tr>
</cfoutput>
</table>
<br />
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
<tr>
	<th style="text-align:left">Agency Name</th>
	<th style="text-align:center"></th>
	<th style="text-align:center">Cost Category</th>
	<th style="text-align:center"></th>
	<th style="text-align:right">Amount</th>
</tr>
<cfset altrow=1>
<cfset curoffice=0>
<cfoutput query="rstEstFopTotal">
	<cfif curoffice neq funding_office_desc>
	<cfset altrow=altrow+1>
	<tr <cfif altrow mod 2>class="AltRow"</cfif>>
		<td>#funding_office_desc#</td>
		<td align="center"></td>
		<cfset curoffice=funding_office_desc>
	<cfelse>
	<tr <cfif altrow mod 2>class="AltRow"</cfif>>
		<td></td>
		<td></td>
	</cfif>
	<td align="center">#group_code#</td>
	<td align="center"></td>
	<td align="right"><cfif amount lt 0>-</cfif>$#numberformat(abs(amount),",")#</td>
	</tr>
</cfoutput>
</table>

<p></p>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<tr>
	<form action="#application.paths.reportdir#reports.cfm?rpt_id=16&cache=true&sortby=#url.sortby#&sortdir=#url.sortdir#" method="post" onSubmit="window.open('about:blank','reports','location=no,resizable=yes,scrollbars=yes,status=yes');" target="reports">
	<td width="50%">
		<input type="button" name="" value="Print" onclick="this.form.submit();">
		<input type="hidden" name="py_ccc" value="#form.py_ccc#" />
		<input type="hidden" name="radReportFormat" value="application/pdf" />
	</td>
	</form>
	<form action="fopbatch_ccc_2.cfm" method="post">
	<td width="40%" align="right">
		<cfif rstEstFopSort.history_rec eq -1>
			<input type="submit" name="action_exec" value="Execute Batch Process" />
		<cfelseif rstEstFopSort.history_rec eq 0>
			<input type="submit" name="action_undo" value="Undo Batch Process" /><input type="submit" name="action_fin" value="Finalize Batch Process" />
		</cfif>
	</td>
	</form>
</tr>
</table>



<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">