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






<!--- ============================================================================================ --->
<cfscript> 
    //Use an absolute path for the files. ---> 
    excelDir=GetDirectoryFromPath(GetCurrentTemplatePath()); 
    excelFile = excelDir & "Budget_Appropriation_Allotment.xls"; 
    //Create two empty ColdFusion spreadsheet objects. ---> 
    sheetApprop = SpreadsheetNew("AppropData"); 
    sheetAllot  = SpreadsheetNew("AllotData"); 
    //Populate each object with a query. ---> 
    SpreadsheetAddRows(sheetApprop,"#strucAppropAllot.spr_getAppropriation#"); 
    SpreadsheetAddRows(sheetAllot,"#strucAppropAllot.spr_getAllotment#"); 
</cfscript> 

<!--- Write the two sheets to a single file ---> 
<cfspreadsheet action="write" filename="#excelFile#" name="sheetApprop" sheetname="Appropriation" overwrite=true> 
<cfspreadsheet action="update" filename="#excelFile#" name="sheetAllot" sheetname="Allotment"> 

<!---<cfspreadsheet action="read" src="#excelFile#" sheetname="courses" name="spreadsheetData"> 
<cfspreadsheet action="read" src="#excelFile#" sheet=1 rows="3,4" format="csv" name="csvData"> 
<cfspreadsheet action="read" src="#excelFile#" format="html" rows="5-10" name="htmlData"> 
<cfspreadsheet action="read" src="#excelFile#" sheetname="centers" query="queryData"> --->

<cfspreadsheet action="read" src="#excelFile#" sheetname="Appropriation" query="qAppropData">
<cfspreadsheet action="read" src="#excelFile#" sheetname="Allotment" query="qAllotData">

<!---<cfdump var="#qAppropData#"><cfdump var="#qAllotData#"><cfabort>--->


<cfscript> 
    //SpreadsheetAddRow(qAppropData,"APPROP_ID,appr_fund_cat,appr_fund_cat_desc,appr_py,appr_amount,appr_amount_ncfms",8,1); 
 //   SpreadsheetAddColumn(qAllotData, "ALLOT_ID, FUND_CAT, FUNDING_OFFICE_NUM, FUNDING_OFFICE_DESC, PY,
//														Q1_AMOUNT, 		 Q2_AMOUNT,  	  Q3_AMOUNT,       Q4_AMOUNT,       QT_AMOUNT,
//														Q1_AMOUNT_NCFMS, Q2_AMOUNT_NCFMS, Q3_AMOUNT_NCFMS, Q4_AMOUNT_NCFMS, QT_AMOUNT_NCFMS", 1, 1); 
</cfscript> 

<cfspreadsheet action="write" filename="#excelDir#updatedFile.xls" name="Appropriation" sheetname="sheetApprop" overwrite=true> 

<!---<cfspreadsheet action="write" filename="#excelDir#updatedFile.xls" name="qAllotData" sheetname="All" overwrite=true>---> 

<!--- =========================================================================================== --->












<!--- /////////////////////////////////////////////////////  --->

<cfif not structKeyExists(form, "doit")>

<form action="test.cfm" method="post">
<table>
<tr>
<th>Name</th>
<th>Beers</th>
<th>Vegetables</th>
<th>Fruits</th>
<th>Meats</th>
</tr>
<cfloop index="x" from="1" to="10">
<cfoutput>
<tr>
<td><input type="text" name="name_#x#"></td>
<td><input type="text" name="beers_#x#"></td>
<td><input type="text" name="veggies_#x#"></td>
<td><input type="text" name="fruits_#x#"></td>
<td><input type="text" name="meats_#x#"></td>
</tr>
</cfoutput>
</cfloop>
</table>
<input type="submit" name="doit" value="Create Excel File">
</form>

<cfelse>

<cfset q = queryNew("Name,Beers,Vegetables,Fruits,Meats", "cf_sql_varchar,cf_sql_integer,cf_sql_integer,cf_sql_integer,cf_sql_integer")>
<cfloop index="x" from="1" to="10">
	<cfset queryAddRow(q)>
    <cfset querySetCell(q, "Name", form["name_#x#"])>
    <cfset querySetCell(q, "Beers", form["beers_#x#"])>
    <cfset querySetCell(q, "Vegetables", form["veggies_#x#"])>
    <cfset querySetCell(q, "Fruits", form["fruits_#x#"])>
    <cfset querySetCell(q, "Meats", form["meats_#x#"])>
</cfloop>

<cfset filename = expandPath("./myexcel.xls")>
<!---
<cfspreadsheet action="write" query="q" filename="#filename#" overwrite="true">
--->
<!--- Make a spreadsheet object --->
<cfset s = spreadsheetNew()>
<!--- Add header row --->
<cfset spreadsheetAddRow(s, "Name,Beers,Vegetables,Fruits,Meats")>
<!--- format header --->
<cfset spreadsheetFormatRow(s,
{
bold=true,
fgcolor="lemon_chiffon",
fontsize=14
},
1)>

<!--- Add query --->
<cfset spreadsheetAddRows(s, q)>
<!---
<cfset spreadsheetWrite(s, filename, true)>

Your spreadsheet is ready. You may download it <a href="myexcel.xls">here</a>.
--->

<cfheader name="content-disposition" value="attachment; filename=myexcel.xls">
<cfcontent type="application/msexcel" variable="#spreadsheetReadBinary(s)#" reset="true">
</cfif>
<!--- /////////////////////////////////////////////////////// --->
















<!---
<cfheader name="Content-Disposition" value="inline;filename=Budget_Appropriation_Allotment.xls">
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
--->

</cfoutput>

</body>
</html>