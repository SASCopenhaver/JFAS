<!---
page: validateInactiveAAPPs.cfm

description:	scheduled event that looks through all inactive AAPPs and determines which ones
				violate the business rules (and should actually be reactivated)

revisions:
2014-10-16	mstein	Modified to fix Request.PY error, and standardize cfmail to other scheduled events
--->

<cfset request.pageID = "0" />
<cfsetting requesttimeout="900">

<!--- get list of inactive AAPPs from the database --->
<cfinvoke component="#application.paths.components#aapp" method="getAAPPNumListing" status="0" returnvariable="rstAAPPs">

<!--- get current PY --->
<cfset request.PY = application.outility.getCurrentSystemProgramYear ()>

<cfset arrAAPP = ArrayNew(1)>

<!--- loop through AAPPs --->
<cfloop query="rstAAPPs">

	<!--- check to see if AAPP can be inactive --->
	<cfinvoke component="#application.paths.components#aapp" method="testForInactive" aapp="#aappNum#" returnvariable="lstErrorMessages">

	<!--- if AAPP cannot be inactive, collect error messages --->
	<cfif lstErrorMessages neq "">
		<cfset lstErrorMessages = replace(lstErrorMessages, "This AAPP can not be made inactive because ","","all")>

		<!--- add to array --->
		<cfset badRecord = StructNew()>
		<cfset badRecord.aappNum = aappNum>
		<cfset badRecord.errorMsgs = lstErrorMessages>
		<cfset temp = ArrayAppend(arrAAPP,badRecord)>

	</cfif>

</cfloop>

<cfif arrayLen(arrAAPP) gt 0>
	<cfsavecontent variable="txtInvalidAAPPOutput">
	<div style="font-family:Arial, Helvetica, sans-serif; font-size:smaller">
	The following AAPPs in JFAS are currently inactive although they violate certain
	conditions based on JFAS business rules. Please look into these issues to either
	reactivate the AAPPs, or modify the data that is violating the business rule.</div>	<br />
	
	<cfoutput>
	<table>
	<tr>
		<td width="75" align="left" style="font-family:Arial, Helvetica, sans-serif; font-size:smaller"><strong>AAPP No.</strong></td>
		<td width="*" style="font-family:Arial, Helvetica, sans-serif; font-size:smaller"><strong>Invalid Conditions</strong></td>
	</tr>
	<cfloop index="i" from="1" to="#ArrayLen(arrAAPP)#">
	<tr valign="top">
		<td align="left" style="font-family:Arial, Helvetica, sans-serif; font-size:smaller">#arrAAPP[i].aappNum#</td>
		<td style="font-family:Arial, Helvetica, sans-serif; font-size:smaller">
			<cfloop list="#arrAAPP[i].errorMsgs#" index="msgItem" delimiters="~">
			<li>#ucase(left(msgItem,1))##right(msgItem, len(msgItem)-1)#</li>
			</cfloop>
			<br />
		</td>
	</tr>
	</cfloop>
	</table>
	</cfoutput>
	</cfsavecontent>

	<br>
	<cfoutput>#txtInvalidAAPPOutput#</cfoutput>
	<br>	

	<cfset jfasSysEmail = application.outility.getSystemSetting(systemSettingCode="jfas_system_email")>
	<cfset reportEmail = application.outility.getSystemSetting(systemSettingCode="report_auto_email")>

	<!--- send email, with list of AAPPs, and messages --->
	<cfmail	to="#reportEmail#"
			from="#jfasSysEmail#"
			cc="#jfasSysEmail#"
			subject="List of Inactive AAPPs Requiring Attention #iif(application.cfEnv neq 'prod',DE(' (' & Evaluate('application.cfEnvDesc') & ')'), DE(''))#"
			type="html">
	#txtInvalidAAPPOutput#
	</cfmail>

</cfif>



