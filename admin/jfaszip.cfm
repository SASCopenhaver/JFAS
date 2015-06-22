<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">


 <cfquery name="zip" datasource="#request.dsn#">
    select jfas_export.get_zip_data content from dual
</cfquery>   

<cfset tmp_file_name="#GetDirectoryFromPath(GetCurrentTemplatePath())#jfasdata.zip"> 

<cffile action = "write" 
     file = #tmp_file_name# 
     output = #zip.content#>
	 

  
<CFHEADER NAME="CONTENT-DISPOSITION" VALUE="ATTACHMENT; FILENAME=jfasdata.zip"> 
<cfcontent type="application/zip" file="#tmp_file_name#" deletefile="Yes" >     
<html>
<head>
	<title>Untitled</title>
</head>

<body>

<cfoutput>file:  #tmp_file_name#</cfoutput>

</body>
</html>
