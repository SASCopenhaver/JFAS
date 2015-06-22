<!--- spend_plan_future_test.cfm --->

<cfset request.pageID="69">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "JFAS Spend Plan">

<!--- get Future Spend Plan Data 
<cfinvoke component="#application.paths.components#spend_plan_test" 
		  method="f_getFutureSpendPlan" 
          argUserID = "#session.userid#"
          returnvariable="spr_getFutureSpendPlan">
</cfinvoke>--->

<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">
<cfinclude template="#application.paths.includes#jsGraphics.cfm">


<!--- this appears below the header, and the nagivaton submenus --->
<cfloop query="spr_getFutureSpendPlan" startrow="1" endrow="1">
	<cfoutput>
		<cfset local.FuturePY = #FUTURE_PY#>
        <cfset local.CurrentPY = #CURRENT_PY#>
    </cfoutput>
</cfloop>
<cfset local.TodayDate = #DateFormat(Now())#>
<div class="ctrSubContent">
	<cfoutput>
	<h2>PY#local.FuturePY# Spend Plan</h2>
    </cfoutput>
    XYZ
</div>
<!---TEST:<cfdump var="#spr_getFutureSpendPlan#">--->
<!--- HIERARCHY_LEVEL, SPLAN_CAT_PARENT_ID, SPLAN_CAT_ID, SPLAN_CAT_DESC, SORT_ORDER, SUM_INIT_TRNS, FOP_AMOUNT, CURRENT_PY, FUTURE_PY --->
<cfoutput>
<table width="98%" border="1" cellspacing="2" cellpadding="2">
  <tr>
    <th scope="col">&nbsp;</th>
    <th scope="col">PY#local.CurrentPY# Spend Plan (as of #local.TodayDate#)</th>
    <th scope="col">PY#local.FuturePY# FOPs</th>
    <th scope="col">PY#local.FuturePY# Spend Plan</th>
    <th scope="col">Notes</th>
  </tr>
<cfloop query="spr_getFutureSpendPlan" startrow="1" endrow="#spr_getFutureSpendPlan.recordcount#">  
  <tr>
    <td>#SPLAN_CAT_DESC#</td>
    <td>#SUM_INIT_TRNS#</td>
    <td>#FOP_AMOUNT#</td>
    <td>1111</td>
    <td>Future Notes</td>
  </tr>
</cfloop>
</table>
</cfoutput>

<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">



