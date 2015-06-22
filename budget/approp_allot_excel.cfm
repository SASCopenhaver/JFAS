<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<cfset strucAppropAllot = application.oapprop_allot.f_getAppropAllot( arg_py: "#session.selectedPY#", arg_UserID: "#session.userid#")>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Appropriation / Allotment Excel</title>
</head>
<body>
<!---TEST (do not delete):
<cfdump var="#strucAppropAllot.spr_getListOfPY#">
<cfdump var="#strucAppropAllot.spr_getAppropriation#">
<cfdump var="#strucAppropAllot.spr_getAllotment#">
<cfdump var="#strucAppropAllot.spr_getDateNCFMSloaded#">
<cfabort>--->
<cfoutput>
<cfscript>
	fileDir=GetDirectoryFromPath(GetCurrentTemplatePath()); 
	fileName = "AppropAllot" & "#session.userid#" & ".xls";
	fileDirName = fileDir & fileName; 
</cfscript>
<cfheader name="Content-Disposition" value="attachment; filename=#fileName#">
<cfcontent type="application/msexcel">

<form id="frmAppropAllotExcel" name="frmAppropAllotExcel" method="post">

<cfset variables.fontFamily     = 'style="font-family:Arial, Helvetica, sans-serif;"'>
<cfset variables.fontTitle      = 'style="font-family:Arial, Helvetica, sans-serif; font-size:16px;"'>
<cfset variables.headerColors   = 'style="background-color:##5e84a6; color:##FFF; "'>
<cfset variables.fontSize       = 'style="font-size:13px; "'>
<cfset variables.colorsizeNCFMS = 'style="color:##069; font-size:11px; "'>

<table width="80%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
			
            <tr #variables.fontTitle#><td colspan="6" align="left"><strong>Budget Appropriation / Allotment</strong></td></tr>
            <tr #variables.fontFamily#><td colspan="6" align="left" #variables.colorsizeNCFMS#>#strucAppropAllot.spr_getDateNCFMSloaded.NCFMS_LOAD_MSG#</td></tr>
            
<cfloop query="strucAppropAllot.spr_getAppropriation" startrow="1" endrow="#strucAppropAllot.spr_getAppropriation.RecordCount#">
			<cfset variables.Appr_Fund_Cat = #appr_fund_cat#>
            <tr #variables.fontFamily#>
                <th #variables.headerColors#>#appr_fund_cat_desc#</th>
                <th #variables.headerColors#>Q1</th>
                <th #variables.headerColors#>Q2</th>
                <th #variables.headerColors#>Q3</th>
                <th #variables.headerColors#>Q4</th>
                <th #variables.headerColors#>TOTAL</th>
            </tr>            		
            <!---<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>--->
            <tr #variables.fontFamily#>  
                <td #variables.fontSize#><strong>Appropriation</strong></td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td #variables.fontSize#><strong>#appr_AMOUNT#</strong></td>
            </tr>
            <tr #variables.fontFamily#>  
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td #variables.colorsizeNCFMS# >#appr_AMOUNT_NCFMS#</td>
            </tr>
            <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>

<cfloop query="strucAppropAllot.spr_getAllotment" startrow="1" endrow="#strucAppropAllot.spr_getAllotment.RecordCount#">
	<cfif variables.Appr_Fund_Cat EQ #FUND_CAT#>
         <cfset Q1N = #Q1_AMOUNT_NCFMS#> <cfif #Q1N# EQ 0> <cfset Q1N = ""> </cfif>
		 <cfset Q2N = #Q2_AMOUNT_NCFMS#> <cfif #Q2N# EQ 0> <cfset Q2N = ""> </cfif>
		 <cfset Q3N = #Q3_AMOUNT_NCFMS#> <cfif #Q3N# EQ 0> <cfset Q3N = ""> </cfif>
         <cfset Q4N = #Q4_AMOUNT_NCFMS#> <cfif #Q4N# EQ 0> <cfset Q4N = ""> </cfif>
         <cfset QTN = #QT_AMOUNT_NCFMS#> <cfif #QTN# EQ 0> <cfset QTN = ""> </cfif>
         
         <cfset FOD = #FUNDING_OFFICE_DESC#> <cfif FOD EQ "Allotment"> <cfset FOD = "<strong>#FUNDING_OFFICE_DESC#</strong>"> </cfif>
            <tr #variables.fontFamily#>  
                <td #variables.fontSize#>#FOD#</td>
                <td #variables.fontSize#>#Q1_AMOUNT#</td>  
                <td #variables.fontSize#>#Q2_AMOUNT#</td>
                <td #variables.fontSize#>#Q3_AMOUNT#</td>
                <td #variables.fontSize#>#Q4_AMOUNT#</td>
                <td #variables.fontSize#><strong>#QT_AMOUNT#</strong></td>	
            </tr>
            <tr #variables.fontFamily#>    
                <td #variables.colorsizeNCFMS#><!---NCFMS #FUNDING_OFFICE_DESC#---></td>
                <td #variables.colorsizeNCFMS#>#Q1N#</td>
                <td #variables.colorsizeNCFMS#>#Q2N#</td>
                <td #variables.colorsizeNCFMS#>#Q3N#</td>
                <td #variables.colorsizeNCFMS#>#Q4N#</td>
                <td #variables.colorsizeNCFMS#>#QTN#</td>
            </tr>		
         <cfif #FUNDING_OFFICE_DESC# EQ "Allotment"> 
            <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
         </cfif>
    </cfif>
</cfloop><!--- end of ALLOTMENT (spr_getAllotment) --->
</cfloop><!--- end of APPROPRIATION (spr_getAppropriation) --->
</table>
<!---<br /><br />
<cfdump var="#strucAppropAllot.spr_getAppropriation#">
<cfdump var="#strucAppropAllot.spr_getAllotment#">
<cfdump var="#strucAppropAllot.spr_getDateNCFMSloaded#">--->
</form>


</cfoutput>

</body>
</html>


