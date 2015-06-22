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
            fileName = "Approp" & "#session.userid#" & ".xls";
            //fileDirName = fileDir & fileName; 
        </cfscript>
        <cfheader name="content-disposition" value="attachment; filename=#fileName#">
        <cfcontent type="application/msexcel">
<form id="frmAppropExcel" name="frmAppropExcel" method="post">
<table border="0" cellpadding="0" cellspacing="0">
	<tr>
    	<!---<td><strong>APPROPRIATION ID</strong></td>--->
        <td><strong>FUNDING CATEGORY</strong></td>
        <!---<td><strong>FUNDING CATEGORIES</strong></td>--->
        <td><strong>PY</strong></td>
        <td><strong>JFAS APPROPR. AMOUNT</strong></td>
        <td><strong>NCFMS APPROPR. AMOUNT</strong></td>
    </tr>
<cfloop query="strucAppropAllot.spr_getAppropriation" startrow="1" endrow="#strucAppropAllot.spr_getAppropriation.RecordCount#">
	<tr>
    	<!---<td>#approp_id#</td>--->
    	<td>#appr_fund_cat#</td>
        <!---<td>#appr_fund_cat_desc#</td>--->
        <td>#appr_py#</td>
        <td>#appr_amount#</td>
        <td>#appr_amount_ncfms#</td>
    </tr>
</cfloop> 
</table>
</form>
</cfoutput>

</body>
</html>


