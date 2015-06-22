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
            fileName = "Approp" & "#session.userid#" & ".xls";
            fileDirName = fileDir & fileName; 
        </cfscript>
        
        
        <cfheader name="content-disposition" value="attachment; filename=#fileName#">
        <cfcontent type="application/msexcel" variable="#spreadsheetReadBinary(sObjApprop)#" reset="true"> 
        
		<cfset sObjApprop=SpreadsheetNew()>
        
        <cfset SpreadsheetAddRow(sObjApprop, "APPROPRIATION ID,FUNDING CATEGORY ID,FUNDING CATEGORIES,PY,JFAS APPROPR. AMOUNT, NCFMS APPROPR. AMOUNT")>
        <cfset SpreadsheetFormatRow(sObjApprop, {bold="TRUE"}, 1)>
        <cfset SpreadsheetAddRows(sObjApprop, "#strucAppropAllot.spr_getAppropriation#")>
        
        <cfspreadsheet action="write" filename="#fileDirName#" name="sObjApprop" sheetname="Appropriation" overwrite="true">

		<cfheader name="content-disposition" value="attachment; filename=#fileName#">
        <cfcontent type="application/msexcel" variable="#spreadsheetReadBinary(sObjApprop)#" reset="true">

        
<!---        <cfcontent type="application/msexcel">
        <cfheader name="content-disposition" value="attachment; filename=#fileName#">
        <cfcontent type="application/msexcel" variable="#spreadsheetReadBinary(sObjApprop)#" reset="true">--->
</cfoutput>

</body>
</html>


