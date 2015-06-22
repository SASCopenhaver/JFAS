<!---
page: compareFOP_PYallocation.cfm

description:	compares FOPs and allocations for all active AAPPs (for the given program year)
				sends list of contracts where FOPs exceed allocation

revisions:
2013-09-17	mstein	page created
2014-03-31	mstein	Added call to get current PY (instead of getting from request scope)
--->

<cfset request.pageID = "0" />
<cfsetting requesttimeout="900">

<!--- get current PY --->
<cfset currentPY = application.outility.getCurrentSystemProgramYear ()>

<!--- get full list of active aapps, where FOPs exceed allocation (for current PY)  --->
<cfinvoke component="#application.paths.components#reports" method="getFOPAllocation_Reconciliation"
			py = "#currentPY#"
			condition="fop_gt_allocation"
			returnvariable="rstFOPAllocation_Exceed">
<cfset jfasSysEmail = application.outility.getSystemSetting(systemSettingCode="jfas_system_email")>
<cfset reportEmail = application.outility.getSystemSetting(systemSettingCode="report_auto_email")>

<!---
<cfdump var="#rstFOPAllocation_Exceed#">
<cfabort>
--->



<cfif rstFOPAllocation_Exceed.recordcount gt 0>

	<cfsavecontent variable="txtAllocationOutput">
	<cfoutput>
	<div style="font-family:Arial, Helvetica, sans-serif; font-size:smaller">
	The following #rstFOPAllocation_Exceed.recordcount# AAPPs have PY#currentPY# FOP totals that exceed their specified PY contract allocation.</div>	<br />

	<table border="1" cellspacing="0" cellpadding="2" style="font-family:Arial, Helvetica, sans-serif; font-size:x-small">
	<tr>
		<td><strong>AAPP No.</strong></td>
		<td><strong>Program Activity</strong></td>
		<td><strong>Contract No.</strong></td>
		<td><strong>Fund Cat.</strong></td>
		<td><strong>Allocation</strong></td>
		<td><strong>FOP Total</strong></td>
	</tr>
	<cfloop query="rstFOPAllocation_Exceed">
		<tr>
			<td>#aappNum#</td>
			<td>#programActivity#</td>
			<td>#contractNum#</td>
			<td align="center">#fund_cat#</td>
			<td align="right">#numberFormat(PYallocation, "$9,999")#</td>
			<td align="right">#numberFormat(fopTotal, "$9,999")#</td>
		</tr>
	</cfloop>
	</table>
	</cfoutput>
	</cfsavecontent>

<br>
<cfoutput>#txtAllocationOutput#</cfoutput>
<br>

<!--- send email, with list of AAPPs --->
<cfmail	to="#reportEmail#"
		from="#jfasSysEmail#"
		cc="#jfasSysEmail#"
		subject="JFAS AAPPs with FOPs exceeding Allocations #iif(application.cfEnv neq 'prod',DE(' (' & Evaluate('application.cfEnvDesc') & ')'), DE(''))#"
		type="html">
#txtAllocationOutput#
</cfmail>

</cfif>



