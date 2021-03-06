<!---
page: footer.cfm

description: contains all necessary items for footer

revisions:
belldr 12/12/2013  - converted to use be compatible with new header.cfm

These were left open
	<div class="ctrContent">
	<td>
	<tr>
	<table class="table100">
	<div class="row"  >
	<div class="container">

--->

</div>
<!-- /ctrContent -->

<cfif not isDefined("footerpage")>
	<script language="javascript">
		function openWindow(url)
		{
			newWin = window.open(url, "Info", 'status=no,toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=yes, width=790, height=350');
		}
	</script>
</cfif>

<!--- Begin Footer Area --->
<cfoutput>
<div class="FtrBtmL"><img src="#application.paths.images#clear.gif" alt="" width="1" height="1" /></div>
<div class="FtrBtmR"><img src="#application.paths.images#clear.gif" alt="" width="1" height="1" /></div>
<cfif not isDefined("footerpage")>
	<div id="idFooter" class="ctrFooter">
		<div class="FooterL"><a href="javascript:openWindow('#application.urls.root#views/accessibility.cfm');" >Accessibility</a> | <a href="javascript:openWindow('#application.urls.root#views/DisplayPrivacyAct.cfm');">Privacy</a> | <a href="javascript:openWindow('#application.urls.root#views/DisplayContactInfo.cfm');">Contact</a></div>
		<div class="FooterR"><a href="#application.paths.dolhome#">Department of Labor</a> <a href="#application.paths.dolhome#"><img src="#application.paths.images#logo_dol.gif" alt="Department of Labor logo" width="33" height="32" border="0" align="middle" /></a></div>
	</div>
	<!-- /ctrFooter -->
</cfif>
</cfoutput>
<!--- End Footer Area --->

</td>
</tr>
</table>
<!-- /table100 -->

<!--- remove container and row
</div>
<!-- /row -->
</div>
<!-- /container -->
end of remove container and row --->

</div>
<!-- /detailSurround -->


<!--- javascript is at the end of the page, to make it load quicker --->
<cfinclude template="#application.paths.includes#jsPackage.cfm">

<script>
$("document").ready(function(){
	// remove dropdowns from pri_nav when scrolling or resizing
	$( window ).scroll(function() {
		$(".TopMarker").remove();
	});
	$( window ).resize(function() {
		$(".TopMarker").remove();
	});
	// change background on PriNav buttons on detail pages, when hovering (no bootstrap)
	$( '.btn_pri_nav' ).hover(
		function() {$( this ).addClass('PriNavBackgroundColor');
		}, function() {	$( this ).removeClass('PriNavBackgroundColor');
		}
	);
	$("document").ready(function(){
		$( "input:disabled" ).addClass( "btnDisabled" );
	}); // ready

});
</script>

</body>
</html>
<!--- footer.cfm --->