<!--- reports/report_adhoc.cfm --->
<cfset request.pageID = "1900" />
<!--- <cfset breadCrumb = breadCrumb & " > Ad Hoc Report Builder"> --->
<cfinclude template="#application.paths.includes#header.cfm">


<table width="95%" border="0" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td>

		<cfmodule template="/cfdocs/adhoc/code/core/web/reportBuilder.cfm"
				      userId="#session.userID#"
					  role="#session.roleID#"
				      datasource="#request.dsn#"
				      criteriaFormPath="#application.paths.root#reports/criteria/form/"
				      criteriaFormActionPath="#application.paths.root#reports/criteria/action/"
				      criteriaReadOnlyPath="#application.paths.root#reports/criteria/readonly/"
				      cancelButtonUrl="#application.paths.root#reports/reports_main.cfm">
		 </td>
	</tr>
</table>

<cfinclude template="#application.paths.includes#footer.cfm">
<script language="javascript">
		//scroll to bottom of form each time
		if (document.getElementById("errorFlg") && document.getElementById("errorFlg").value == "N" && document.getElementById("btnSave"))
			{
			document.getElementById("btnSave").focus();
			}
</script>
<!--- END of reports/report_adhoc.cfm --->