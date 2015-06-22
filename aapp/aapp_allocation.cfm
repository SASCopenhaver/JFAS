<cfsilent>
<!---
page: aapp_allocation.cfm

description: Form to enter contract PY allocation

revisions:
2013-09-09	mstein	page created
2014-03-29	mstein	Page updated to show quarterly OPS values, as well as FOPs and Obligations
--->

<cfset request.pageID = "150" />
<cfset formEditable = 0>
<cfparam name="variables.lstErrorMessages" default="" />

<!---Post--->
<cfif isDefined("form.btnSave")>

	<cfinvoke component="#application.paths.components#aapp_budget" method="savePYAllocationData" formData="#form#">
	<cflocation url="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&save=1" addtoken="no">

<cfelse>

	<!--- get allocation data from database --->
	<cfinvoke component="#application.paths.components#aapp_budget" method="getPYAllocationData" aapp="#url.aapp#" returnvariable="stcPYAllocationData">
	<cfset tmpListPYs = "">

	<cfloop list="#structKeyList(stcPYAllocationData)#" index="fieldName">
		<cfset form[#fieldName#] = stcPYAllocationData[#fieldName#]>
	</cfloop>


	<!--- admins can edit all PYs, everyone else based on business rules --->
	<cfif listfind("2", session.roleID)>
		<cfset form.lstEditablePY = stcPYAllocationData.lstPYs>
		<cfset formEditable = 1>
	<cfelseif listfind("1", session.roleID)>
		<cfset form.lstEditablePY = stcPYAllocationData.lstEditablePY>
		<cfset formEditable = 1>
	<cfelse>
		<cfset form.lstEditablePY = "">
		<cfset formEditable = 0>
	</cfif>
</cfif>

<!--- get current PY quarter --->
<cfset currentQtr = application.outility.getQuarter(yearType="PROG" )>

</cfsilent>


<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">
<script language="javascript1.1" type="text/javascript">
function groupSum(py) {
	//loops through all allocation fields for the given PY, and populates OPS subtotal and total
	subtotalOps = 0;

	// loop through OPS quarters to get OPS subtotal
	for (var qtr=1; qtr<5; qtr++)
		subtotalOps = subtotalOps + parseInt(stripCharsInBag(frmAllocation['amount_' + py + '_OPS_' + qtr].value,','));

	// set value of OPS subtotal, and format
	frmAllocation['subtotal_' + py + '_OPS'].value = subtotalOps;
	formatNum(frmAllocation['subtotal_' + py + '_OPS'],2,1);

	// set value of total, and format
	frmAllocation['total_' + py].value = subtotalOps + parseInt(stripCharsInBag(frmAllocation['amount_' + py + '_CRA_0'].value,','));
	formatNum(frmAllocation['total_' + py],2,1);

}

function validateForm (s) {
	return true;
}

</script>
<div class="ctrSubContent">
	<cfoutput>
	<h2>Program Year Contract Allocation</h2>

	<cfinclude template="#application.paths.includes#error_list.cfm">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTblCol">
	<form name="frmAllocation" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#" method="post" onSubmit="return validateForm(this);">
	<tr>
		<th colspan="2" width="*"></th>
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<th scope="col" nowrap style="text-align:center">#py#</th>
		</cfloop>
	</tr>

	<!--- OPS --->
	<cfloop from="1" to="4" index="qtr">
		<td style="text-align:left;"><cfif qtr eq 1><b>Operations</b></cfif></td>
		<td>Q#qtr#</td>
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<td>
				<label for="id_amount_#py#_OPS_#qtr#" class="hiddenLabel">OPS Allocation for PY#py#, qtr#qtr#</label>
				<input type="text" name="amount_#py#_OPS_#qtr#" id="id_amount_#py#_OPS_#qtr#" value="#numberFormat(form["amount_" & py & "_OPS_" & qtr])#"
				<cfif listFind(form.lstEditablePY,py)>
					onChange="formatNum(this,2,1);groupSum(#py#);"
				<cfelse>
					readonly class="inputReadonly"
				</cfif>
				<cfif py eq request.py> <!--- color field background --->
					<cfif qtr eq currentQtr>
						style="background-color:yellow;"
					<cfelse>
						style="background-color:##FFFF99;"
					</cfif>
				</cfif>
				tabindex="#request.nextTabIndex#">
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
		</tr>
	</cfloop>
	<tr>
		<td colspan="2" align="right">Subtotal</td> <!--- OPS subtotal row --->
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<td>
				<label for="id_subtotal_#py#_OPS" class="hiddenLabel">OPS Subtotal for PY#py#</label>
				<input type="text" name="subtotal_#py#_OPS" id="id_subtotal_#py#_OPS" value="#numberFormat(form["subtotal_" & py & "_OPS"])#" readonly class="inputReadonly" tabindex="#request.nextTabIndex#">
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
	</tr>
	<!--- OPS FOPs --->
	<tr>
		<td colspan="2" align="right">FOPs</td>
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<td>
				<label for="id_fop_#py#_OPS" class="hiddenLabel">FOP OPS Subtotal for PY#py#</label>
				<input type="text" name="fop_#py#_OPS" id="id_fop_#py#_OPS" value="#numberFormat(form["fop_" & py & "_OPS"])#" readonly
					class="inputReadonly" style="border:0;" tabindex="#request.nextTabIndex#">
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
	</tr>
	<!--- OPS NCFMS Obligations --->
	<tr>
		<td colspan="2" align="right">NCFMS Obligations</td>
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<td>
				<label for="id_oblig_#py#_OPS" class="hiddenLabel">Obligation OPS Subtotal for PY#py#</label>
				<input type="text" name="oblig_#py#_OPS" id="id_oblig_#py#_OPS" value="#numberFormat(form["oblig_" & py & "_OPS"])#" readonly
					class="inputReadonly" style="border:0;" tabindex="#request.nextTabIndex#">
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
	</tr>
	<tr><td colspan="#evaluate((form.endPY-form.startPY) + 1)#">&nbsp;</td></tr>


	<!--- CRA --->
	<tr>
		<td colspan="2" style="text-align:left;"><b>Construction</b></td>
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<td>
				<label for="id_amount_#py#_CRA_0" class="hiddenLabel">CRA Allocation for PY#py#</label>
				<input type="text" name="amount_#py#_CRA_0" id="id_amount_#py#_CRA_0" value="#numberFormat(form["amount_" & py & "_CRA_0"])#"
				<cfif listFind(form.lstEditablePY,py)>
					onChange="formatNum(this,2,1);groupSum(#py#);"
				
					<cfif py eq request.py> <!--- color field background --->
						style="background-color:yellow;"
					</cfif>
					
				<cfelse>
					readonly class="inputReadonly"
				</cfif>
				tabindex="#request.nextTabIndex#">
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
	</tr>
	<!--- CRA FOPs --->
	<tr>
		<td colspan="2" align="right">FOPs</td>
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<td>
				<label for="id_fop_#py#_CRA" class="hiddenLabel">FOP CRA Subtotal for PY#py#</label>
				<input type="text" name="fop_#py#_CRA" id="id_fop_#py#_CRA" value="#numberFormat(form["fop_" & py & "_CRA"])#" readonly
					class="inputReadonly" style="border:0;" tabindex="#request.nextTabIndex#">
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
	</tr>
	<!--- CRA NCFMS Obligations --->
	<tr>
		<td colspan="2" align="right">NCFMS Obligations</td>
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<td>
				<label for="id_oblig_#py#_CRA" class="hiddenLabel">Obligation CRA Subtotal for PY#py#</label>
				<input type="text" name="oblig_#py#_CRA" id="id_oblig_#py#_CRA" value="#numberFormat(form["oblig_" & py & "_CRA"])#" readonly
					class="inputReadonly" style="border:0;" tabindex="#request.nextTabIndex#">
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
	</tr>
	<tr><td colspan="#evaluate((form.endPY-form.startPY) + 1)#">&nbsp;</td></tr>



	<!--- Totals --->
	<tr>
		<td colspan="2" style="text-align:left;"><b>Total</b></td>
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<td>
				<label for="id_amount_#py#_CRA_0" class="hiddenLabel">Total Allocation for PY#py#</label>
				<input type="text" name="total_#py#" id="id_total_#py#" value="#numberFormat(form["total_" & py])#" readonly class="inputReadonly" tabindex="#request.nextTabIndex#">
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
	</tr>
	<!--- FOP Totals --->
	<tr>
		<td colspan="2" align="right">FOPs</td>
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<td>
				<label for="id_fopTotal_#py#" class="hiddenLabel">FOP Total for PY#py#</label>
				<input type="text" name="fopTotal_#py#" id="id_fopTotal_#py#" value="#numberFormat(form["fopTotal_" & py])#" readonly
					class="inputReadonly" style="border:0;" tabindex="#request.nextTabIndex#">
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
	</tr>
	<!--- Obligation Totals --->
	<tr>
		<td colspan="2" align="right">NCFMS Obligations</td>
		<cfloop from="#form.startPY#" to="#form.endPY#" index="py">
			<td>
				<label for="id_obligTotal_#py#" class="hiddenLabel">Obligation Total for PY#py#</label>
				<input type="text" name="obligTotal_#py#" id="id_obligTotal_#py#" value="#numberFormat(form["obligTotal_" & py])#" readonly
					class="inputReadonly" style="border:0;" tabindex="#request.nextTabIndex#">
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</cfloop>
	</tr>

	</table>
	<table width="100%">
	<tr>
		<td>
			<div class="buttons">
			<cfoutput>
			<input type="hidden" name="hidAAPP" value="#url.aapp#">
			<input type="hidden" name="startPY" value="#form.startPY#">
			<input type="hidden" name="endPY" value="#form.endPY#">
			<input type="hidden" name="lstFundCat" value="#form.lstFundCat#">
			<cfif formEditable> <!--- only show form buttons if anything is ediatble --->
				<input name="btnSave" type="submit" value="Save" />
				<input name="btnClear" type="button" value="Reset" onClick="window.location.href='#cgi.SCRIPT_NAME#?aapp=#url.aapp#';" />
			</cfif>
			</cfoutput>
			</div>
		</td>
	</tr>
	</table>
	</cfoutput>
	</form>
</div>



<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

