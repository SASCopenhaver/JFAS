<!--- program_year_budget.cfm --->
<cfsilent>
	<cfset request.pageID = "2495">
	<cfset request.pageTitleDisplay = "JFAS System Administration">
</cfsilent>

<cfinclude template="#application.paths.includes#header.cfm">

<h2>Program Year Budget</h2>

<form name="frmPYB" id="frmPYB"><!--- PYB: Program Year Budget --->

<!---<cfif isDefined("url.saved")>
	<div class="confirmList">
	<cfoutput><li>Information saved successfully.&nbsp;&nbsp;Return to the <a href="#application.paths.admin#">Admin Section</a></li></cfoutput>
	</div><br />
</cfif>--->

<div id="div_SaveMsg">&nbsp;</div>
<div id="div_PYB">
	<div id="div_PYselect">Program year:<select id="sel_PY"></select></div> 
	
    <div id="div_Data">
    
    
    
    </div> <!--- end of div_Data --->

	<div id="div_Buttons" class='buttons'>
    	<button id='cbn_Save'   name='cbn_Save'   type="submit" onClick='f_onClick(this.name);'>Save</button>
		<button id='cbn_Reset'  name='cbn_Reset'  type="reset"  onClick='f_onClick(this.name);'>Reset</button>
		<button id='cbn_Cancel' name='cbn_Cancel' type="button" onClick='location.href=\"admin_main.cfm\"'>Cancel</button>
    </div> <!--- end of div_Buttons --->
</div> <!--- end of div_PYB --->

        

</form>
<cfinclude template="#application.paths.includes#footer.cfm">
<cfinclude template="#application.paths.includes#program_year_budgetJS.cfm">
