<!--- jsPackage.cfm

I am the set of JS at the end of the home page, and applyFilter

--->

<!-- Javascript is placed at the end of the document so the pages load faster -->
<cfoutput>
<!--- use this to get the web root location into js --->
<script type="text/javascript"	src="/CFIDE/scripts/wddx.js"></script>
<cfinclude template="#application.paths.includes#jsGlobal.cfm" >
<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>
<!--- <script language="javascript"	src="#application.paths.jsdir#bootstrap.min.js"></script> --->
<!--- this also does not have jQueryUI --->

<!--- jfas-specific --->
<!--- these files could be combined, and minimized, for higher speed --->
<script language="javascript"	src="#application.paths.jsdir#bpopup.js"></script>
<!--- this is jquery UI, NOT jQuery --->
<script language="javascript"	src="#application.paths.jsdir#jquery-ui.js"></script>
<script language="javascript"	src="#application.paths.jsdir#jfas.js"></script>
<script language="javascript"	src="#application.paths.jsdir#jfasjQPlugins.js"></script>
<script language="javascript"	src="#application.paths.jsdir#jfasUtilities.js"></script>

<!--- this are JS functions that use CF --->
<cfinclude template="#application.paths.includes#jsHome.cfm">
<cfif findNocase("\budget\", CGI.PATH_TRANSLATED)>
	<cfinclude template="#application.paths.includes#jsSplan.cfm">
</cfif>
<cfinclude template="#application.paths.includes#jsGoToGraph.cfm">

</cfoutput>

<!--- END of jsPackage.cfm --->