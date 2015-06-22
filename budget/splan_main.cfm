<!---
page: splan_main.cfm

description: root page of budget section

--->
<cfoutput>

<cfset request.pageName="SplanMain">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">
<cfset request.pageTitleDisplay = "JFAS System Budget">

<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">
<cfinclude template="#application.paths.includes#jsGraphics.cfm">

<cfinclude template = "splan_main_include.cfm">
<cfset DoSplan ( 'Screen' )>

<!--- include main footer file --->
<cfinclude template="#application.paths.includes#footer.cfm">
<!---
<script>
$("document").ready(function(){
	<!--- JS, with CFOUTPUT --->
	//alert('document ready');
	$('.splandesclink').css('style',''); {
		a {
			text-decoration: none;
		}
		a:hover {
			color: red;
			cursor: help;
		}
	}

}); // ready
--->

</script>
</cfoutput>
