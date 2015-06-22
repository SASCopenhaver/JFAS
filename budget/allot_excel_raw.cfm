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
            //fileDir=GetDirectoryFromPath(GetCurrentTemplatePath()); 
            fileName = "Allot" & "#session.userid#" & ".xls";
            //fileDirName = fileDir & fileName; 
        </cfscript>
        <cfheader name="content-disposition" value="attachment; filename=#fileName#">
        <cfcontent type="application/msexcel">

<form id="frmAppropExcel" name="frmAppropExcel" method="post">
<table border="0" cellpadding="0" cellspacing="0">
	<tr>
    	<!---<td><strong>ALLOT. ID</strong></td>--->
        <td><strong>FUNDING CATEGORY</strong></td>
        <td><strong>FUNDING OFFICE NUM</strong></td>
        <td><strong>FUNDING OFFICE DESCR.</strong></td>
        <td><strong>PY</strong></td>
        <td><strong>JFAS Q1</strong></td>
        <td><strong>JFAS Q2</strong></td>
        <td><strong>JFAS Q3</strong></td>
        <td><strong>JFAS Q4</strong></td>
        <td><strong>JFAS TOTAL</strong></td>
        <td><strong>NCFMS Q1</strong></td>
        <td><strong>NCFMS Q2</strong></td>
        <td><strong>NCFMS Q3</strong></td>
        <td><strong>NCFMS Q4</strong></td>
        <td><strong>NCFMS TOTAL</strong></td>
    </tr>
<cfloop query="strucAppropAllot.spr_getAllotment" startrow="1" endrow="#strucAppropAllot.spr_getAllotment.RecordCount#">
	<tr>
    	<!---<td>#ALLOT_ID#</td>--->
    	<td>#FUND_CAT#</td>
        <td>#FUNDING_OFFICE_NUM#</td>
    	<td>#FUNDING_OFFICE_DESC#</td>
        <td>#PY#</td>
    	<td>#Q1_AMOUNT#</td>
        <td>#Q2_AMOUNT#</td>
    	<td>#Q3_AMOUNT#</td>
        <td>#Q4_AMOUNT#</td>
    	<td>#QT_AMOUNT#</td>
        <td>#Q1_AMOUNT_NCFMS#</td>
    	<td>#Q2_AMOUNT_NCFMS#</td>
        <td>#Q3_AMOUNT_NCFMS#</td>
    	<td>#Q4_AMOUNT_NCFMS#</td>
        <td>#QT_AMOUNT_NCFMS#</td>
    </tr>
</cfloop> 
</table>
</form>
</cfoutput>
</body>
</html>


