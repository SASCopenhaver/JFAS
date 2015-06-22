<!--- jsGlobal.cfm
	I make some global js values for use in the js environment
--->
<cfoutput>
<!--- set any relevant CF variables here, if they aren't already set, as in the request scope --->

<cfset localPathRoot = "#application.paths.root#">

<script>
// this is Javascript
// glJFAS is a global object
glJFAS = {};

// convert CF variable: sApplicationPath
//	to JS variable: jsApplicationPath

<cfwddx action="cfml2js" input="#localPathRoot#" topLevelVariable="jsPathRoot">

glJFAS.sPathRoot = jsPathRoot;
// alert('in jsGlobal.cfm, glJFAS.sPathRoot=' + glJFAS.sPathRoot);

</script>

</cfoutput>