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
            fileName = "Allot" & "#session.userid#" & ".xls";
            fileDirName = fileDir & fileName; 
        </cfscript>
        
        <cfset sObjAllot=SpreadsheetNew()>
        <cfset SpreadsheetAddRow(sObjAllot, "ALLOT. ID, FUNDING CATEGORY,FUNDING OFFICE NUM,FUNDING OFFICE DESCR.,PY,JFAS Q1,JFAS Q2,JFAS Q3,JFAS Q4,JFAS TOTAL,NCFMS Q1,NCFMS Q2,NCFMS Q3,NCFMS Q4,NCFMS TOTAL")>
        <cfset SpreadsheetFormatRow(sObjAllot, {bold="TRUE"}, 1)>
        <cfset SpreadsheetAddRows(sObjAllot, "#strucAppropAllot.spr_getAllotment#")>
        
        <cfspreadsheet action="write" filename="#fileDirName#" name="sObjAllot" sheetname="Allotment" overwrite="true">
        
        <cfcontent type="application/msexcel">
        <cfheader name="content-disposition" value="attachment; filename=#fileName#">
        <cfcontent type="application/msexcel" variable="#spreadsheetReadBinary(sObjAllot)#" reset="true">
</cfoutput>

</body>
</html>


