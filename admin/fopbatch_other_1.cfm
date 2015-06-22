<cfsilent>
<!---
page: 

description:

revisions:
2007-05-16	yjeng	Change header title
--->
<cfset request.pageID="2530">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - FOP Batch Process (DOL)">
<cfset request.pageTitleDisplay = "FOP Batch Process for Miscellaneous DOL AAPPs: PY #evaluate(request.py_other+1)#">
</cfsilent>



<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">

<cfoutput>
<p></p>
<!---<h2>FOP Batch Process for DOL Contracts</h2>--->
</cfoutput>



<div>
<strong>Step 1: Start</strong> &nbsp;&nbsp;|&nbsp;&nbsp;
<span style="color:#999999">Step 2: Preview FOP Changes</span> &nbsp;&nbsp;|&nbsp;&nbsp; 
<span style="color:#999999">Step 3: Execute Batch Process</span>&nbsp;&nbsp;|&nbsp;&nbsp; 
<span style="color:#999999">Step 4: Finalize Batch Process</span>
</div>

<p></p>

<div>
The purpose of the FOP batch process is to generate FOP records for funding increments for the coming
Program Year that Job Corps management has approved for DOL administered contracts and accounts.<br /><br />

It is recommended that, during the execution of the batch process,
all other users with write access to the adjustments and FOP functions log out of the system to reduce the chance of inconsistencies
between the amounts shown on the preview page, and the actual records created during the execution of the batch process.
Access to the system can be restricted by using the <a href="user_access.cfm">User Access</a> component of the Admin module.<br /><br />

The next step in this process is to preview the FOP records that will be created when the process is executed.
Clicking the button below does not create any records in the database.<br /><br />
<form action="fopbatch_other_2.cfm" method="post">
<input type="submit" name="" value="Preview FOP Changes" onclick="this.form.submit(); this.value='Please wait..'; this.disabled=true;" />
</form>
</div>

	

<!--- include main footer file --->  
<cfinclude template="#application.paths.includes#footer.cfm">