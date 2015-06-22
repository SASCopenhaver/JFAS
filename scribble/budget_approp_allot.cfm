<!--- budget_approp_allot.cfm --->
<cfset request.pageID="96">
<cfset request.htmlTitleDetail = "Job Corps Budget Functions">
<cfset request.pageTitleDisplay = "Budget Appropriation / Allocation">

<!--- get Data: --->
<cfinvoke component="#application.paths.components#spend_plan_test"  
		  method="f_getAppropAllot"
          arg_PY = "2014"
          arg_UserID = "#session.userid#" 
          returnvariable="strucAppropAllot">

<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">
<cfinclude template="#application.paths.includes#jsGraphics.cfm">


<form name="frmAllot" id="frmAllot">

<table width="100%" border="1" cellspacing="2" cellpadding="2">
  
  <tr align="right">
    <td>

    	<cfoutput>
        
        
        
    	<select name="sel_ListOfPY" id="sel_ListOfPY" >
        	<cfloop query="strucAppropAllot.spr_getListOfPY" startrow="1" endrow="10">
            	<option value="#PY_LIST#">#PY_LIST#</option>
        	</cfloop>
        </select>
        </cfoutput>

    </th>
  </tr>
  
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>

<br />
<cfdump var="#strucAppropAllot.spr_getListOfPY#">
<br />
<cfdump var="#strucAppropAllot.spr_getAppropOperations#">
<br />
<cfdump var="#strucAppropAllot.spr_getOperations#">
<br />
<cfdump var="#strucAppropAllot.spr_getAppropConstruction#">
<br />
<cfdump var="#strucAppropAllot.spr_getConstruction#">

</form>
<!---TEST:<cfdump var="#spr_getFutureSpendPlan#">--->
<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">



