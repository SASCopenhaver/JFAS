<cfsilent>
<!---
page:  fopbatch_ccc1.cfm

description:Job Corps Fund Allocation System - FOP Batch Process (CCC)

revisions:

--->

<cfset request.pageID="2520">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - FOP Batch Process (CCC)">
<cfset request.pageTitleDisplay = "FOP Batch Process for CCCs: PY #evaluate(request.py_ccc+1)#">
<cfinvoke component="#application.paths.components#fop_batch" method="CCCFOPBatchPreview" py="#evaluate(request.py_ccc+1)#" returnvariable="qryPreview" />
<cfquery name="done" dbtype="query">
	select	worksheet_status_id
	from	qryPreview
	where	worksheet_status_id=4
</cfquery>
</cfsilent>



<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">

<div>
<strong>Step 1: Start</strong> &nbsp;&nbsp;|&nbsp;&nbsp;
<span style="color:#999999">Step 2: Preview FOP Changes</span> &nbsp;&nbsp;|&nbsp;&nbsp; 
<span style="color:#999999">Step 3: Execute Batch Process</span>&nbsp;&nbsp;|&nbsp;&nbsp; 
<span style="color:#999999">Step 4: Finalize Batch Process</span>
</div>

<p></p>

<div>
The purpose of the FOP batch process is to generate FOP records for funding increments for the coming
Program Year that Job Corps management has approved for CCCs.<br /><br />

It is recommended that, during the execution of the batch process,
all other users with write access to the adjustments and FOP functions log out of the system to reduce the chance of inconsistencies
between the amounts shown on the preview page, and the actual records created during the execution of the batch process.
Access to the system can be restricted by using the <a href="user_access.cfm">User Access</a> component of the Admin module.<br /><br />

The next step in this process is to preview the FOP records that will be created when the process is executed.
Clicking the button below does not create any records in the database.<br /><br />
<form action="fopbatch_ccc_2.cfm" method="post">
<input type="submit" name="action" value="Preview FOP Changes" <cfif done.recordcount neq qryPreview.recordcount>disabled</cfif> />
&nbsp;&nbsp;<cfoutput>(#done.recordcount# of #qryPreview.recordcount# CCC worksheets completed)</cfoutput>
</form>
</div>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
<tr>
	<th style="text-align:left">Center Name</a></th>
	<th style="text-align:center">AAPP</a></th>
	<th style="text-align:center">Agency</th>
	<th style="text-align:center">Region</th>
	<th style="text-align:center">Worksheet Status</th>
</tr>
<cfoutput query="qryPreview">
<tr <cfif currentrow mod 2>class="AltRow"</cfif>>
	<td>#center_name#</td>
	<td align="center">
		<a href="#application.paths.aapp#?aapp=#aapp_num#">#aapp_num#</a>
	</td>
	<td>#funding_office_desc#</td>
	<td>#region_desc#</td>
	<td align="center">
		<a href="#application.paths.aappdir#aapp_worksheet_ccc.cfm?aapp=#aapp_num#">
		<cfif worksheet_status_id eq 4>
			#worksheet_status#
		<cfelse>
			<span style="color:red">#worksheet_status#</span>
		</cfif>
		</a>
	</td>
</tr>
</cfoutput>
</table>

<!--- include main footer file --->  
<cfinclude template="#application.paths.includes#footer.cfm">