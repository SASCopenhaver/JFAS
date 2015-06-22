<cfsilent>
<!---
page: footprint_xactn.cfm

description: administrative page to view discrepancies between footprint and transaction information

revisions:

--->

<cfset request.pageID = "2320" /> 
<cfset request.pageTitleDisplay = "JFAS System Administration">

<cfparam name="url.aapp" default="0">

<cfinvoke component="#application.paths.components#import_data" method="FootprintXactnDisc" returnvariable="rstFootprintXactn" aapp="#url.aapp#">

</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">

</script>		
<cfoutput>
	<h2>Footprint / Transaction Discrepancies</h2>
	
	
	<!--- Start Display Table --->
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	
	<tr align="center" valign="bottom">
		<th scope="row">
			DOLAR$ Doc Type
		</th>
		<th>
		DOLAR$ Doc Number
		</th>
		<th>
		FY
		</th>
		<th>
		RCC Org
		</th>
		<th>
		RCC Fund
		</th>
		<th>
		Object Class Code
		</th>
		<th>
		OPS vs CRA
		</th>
		<th>
		</th>
		<th>
		Footprint
		</th>
		<th>
		Transaction
		</th>
		<th>
		Difference
		</th>
	</tr>
		
<cfif rstFootprintXactn.recordcount gt 0>
<!--- loop to show records --->
	<cfloop query="rstFootprintXactn">
	<tr valign="top" <cfif (currentRow mod 2) is 0>class="AltRow"</cfif>>
		<td align="center">#DT#</td>
		<td align="center">#docNum#</td>
		<td align="center">#FY#</td>
		<td align="center">#RccOrg#</td>
		<td align="center">#RccFund#</td>
		<td align="center">#ObjClass#</td>
		<td align="center">#OpsCra#</td>
		<td>
			Obligation<br />
			Payment<br />
			Cost
		</td>
		<td align="right">
			#dollarFormat(Oblig)#<br />
			#dollarFormat(Payment)#<br />
			#dollarFormat(Cost)#
		</td>
		<td style="text-align:right">
			#dollarFormat(XACTNAMTO)#<br />
			#dollarFormat(XACTNAMTP)#<br />
			#dollarFormat(XACTNAMTC)#
		</td>
		<td style="text-align:right">
			<cfif XACTNAMTO neq ''>
				#dollarFormat((Oblig - XACTNAMTO))#<br />
			<cfelse>
				#dollarFormat(Oblig)#<br />
			</cfif>
			<cfif XACTNAMTP neq ''>
				#dollarFormat((Payment - XACTNAMTP))#<br />
			<cfelse>
				#dollarFormat(Payment)#<br />
			</cfif>
			<cfif XACTNAMTC neq ''>
				#dollarFormat((Cost - XACTNAMTC))#
			<cfelse>
				#dollarFormat(Cost)#
			</cfif>
		</td>
	</tr>
	</cfloop>
<cfelse>
	<tr>
		<td colspan="11" align="center">
		There are currently no discrepancies
		</td>
	</tr>
</cfif>

</table>
</cfoutput>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />