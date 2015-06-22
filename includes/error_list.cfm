<!--- show error / confirmation messages --->
<cfif isDefined("variables.lstErrorMessages") and listLen(variables.lstErrorMessages) gt 0>
	
	<div class="errorList">
	<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters="~">
		<cfoutput><li>#listItem#</li></cfoutput>
	</cfloop>
	</div><br />
</cfif>
<cfif isDefined("url.save")>
	<div class="confirmList">
	<cfoutput><li>Information saved successfully.</li></cfoutput>
	</div><br />
</cfif>