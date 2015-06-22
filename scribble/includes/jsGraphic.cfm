<!--- jsGraphic.cfm --->
<!--- this is JS specific to graphics pages, but which uses some .cfm capability --->
<cfoutput>
<script>
// this is JS
function GoToAAPPGraph (file, aapp) {
	var MyWindow = window.open('#application.urls.root#/reports/'+file+'?aapp='+aapp,'JFG FOP ' + aapp );
	MyWindow.focus();
}

</script>
</cfoutput>
