<!--- job_corps_allots.cfm --->
<!---<cfinvoke component="#application.paths.root#/model/cfc/job_corps_allots" method="f_GetAllotment" returnvariable="spr_getCurrentPY">
	<cfinvokeargument name=argDataOrTotal value="DATA">
	<cfinvokeargument name=argFirstYearInPeriod value="2010">
	<cfinvokeargument name=argLastYearInPeriod value="2013">
</cfinvoke>
<cfdump var="#spr_getCurrentPY#"><cfabort>--->
<!---
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Job Corps Allotments</title>
   <cfoutput> 
   <link href="#application.paths.css#" rel="stylesheet" type="text/css" />
   </cfoutput>
   
<!--- Blocked on 03/13/2014 removing Bootstrap
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" type="text/css">
    <script type="text/javascript" src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
--->    
</head>

<body>--->
<cfset request.pageID = "2490">
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfinclude template="#application.paths.includes#header.cfm">
<h2>Job Corps Allotments ($)</h2>

<!---<cfoutput>
<link href="#application.paths.reportcss#" rel="stylesheet" type="text/css" />
</cfoutput>--->


<form name="frmJCA" id="frmJCA"><!--- JCA: Job Corps Allotments --->


<div id="div_SaveMsg">&nbsp;</div>

<div id="div_contentAllotData"></div>


<script type="text/javascript" src="http://code.jquery.com/jquery-1.10.2.min.js"></script>

<!--- Blocked on 03/13/2014 removing Bootstrap
<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
--->

<!---<script type="text/javascript" src="../includes/javascript/jfasUtilities.js"></script>--->
<script type="text/javascript" src="../includes/javascript/jfas.js"></script>

<cfinclude template="#application.paths.includes#job_corps_allotJS.cfm">

</form>
<cfinclude template="#application.paths.includes#footer.cfm">
<!---
</body>
</html>
--->