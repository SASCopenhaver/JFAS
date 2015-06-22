<!--- jsGraphics.cfm --->
<!--- this is JS specific to graphics pages, but which uses some .cfm capability --->
<cfoutput>

<cffunction name="BuildGraphicsAlertDiv">
	<div id="ReportAlert" >
		<div class="titlebar"> <!--- titlebar --->
			<div class="title">Alert
			</div>
			<!-- end of title -->
			<div class="btnTitleBar">
			<button class="usetooltip btn btn-link btnTitleBar" btn-type="link"
			data-toggle="tooltip" data-placement="bottom" title="Close this alert" name="btnAlert"
			onClick = "glJFAS.oReportPopup.close();"
			>
			<img src="#application.paths.images#close.gif" alt="Close"  />
			</button>
			</div>
			<!-- button -->
		</div> <!--- titlebar --->
		<br style="clear: left;" />
		<!--- message text gets set by JS --->
		<div id="ReportAlertText"></div>
	</div>
	<!-- ReportAlert -->
</cffunction> <!--- BuildGraphicsAlertDiv --->


</cfoutput>
