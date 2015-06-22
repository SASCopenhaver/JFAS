<cfsilent>
<!---
page: showAdjustmentButton.cfm

description: contains logic and display for "Add FOP/Adjustment" button for AAPPs

revisions:

--->


<cfif request.statusID eq 1> <!--- is this aapp active? --->

	
	<cfif listFindNoCase("DC,GR", request.agreementTypeCode)> <!--- is this a contract or grant? --->
		
		<cfinvoke component="#application.paths.components#aapp" method="getAAPPServiceTypes" aapp="#url.aapp#" returnvariable="lstServiceTypes" />
		
		<cfif listLen(replace(lstServiceTypes, "OT",""))> <!--- does the AAPP have Est Cost Profile (A,C1,C2,S)? --->
			<cfset adjustType="adjust"/>
			
			<cfif 1 eq 1> <!--- has award package been entered? --->
				<cfset allowNewAdjustment=1/>
			<cfelse>
				<cfset allowNewAdjustment=0/>
			</cfif>	
				
		<cfelse> <!--- no Est Cost Profile --->
			<cfset adjustType="fop"/>
			<cfset allowNewAdjustment=1/>
		</cfif>
	
	<cfelse> <!--- not a contract or grant --->
		<cfset adjustType="fop"/>
		<cfset allowNewAdjustment=1/>	
		
	</cfif>
	
<cfelse> <!--- inactive, can't add adjustments --->
	<cfset allowNewAdjustment=0/>
</cfif>

</cfsilent>

<cfif allowNewAdjustment>
	<div class="btnRight">
	<cfoutput>
	<form name="frmAddAdjustment" action="aapp_adjust.cfm" method="get">
	<input name="btnAddAdjustment" type="submit" value="Add FOP<cfif adjustType eq "adjust">/Estimated Cost</cfif>" />
	<input type="hidden" name="aapp" value="#url.aapp#" />
	<input type="hidden" name="#adjustType#ID" value="0" />
	<input type="hidden" name="frompage" value="#cgi.SCRIPT_NAME#" />
	</form>
	</cfoutput>
	</div>
</cfif>