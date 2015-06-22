<!---
page: frmCriteriaTrans.cfm

description: JFAS Footprint Transaction Dataset Criteria Form (for use with adhoc tool)

revisions:
2007-10-16  abai    Revised for displaying form criteria correctly
--->

<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.txtEndDate" default="">
<cfparam name="form.txtStartDate" default="">
<cfparam name="form.cboFY" default="#year(now())#">
<cfparam name="form.ckbTransTypeO" default="">
<cfparam name="form.ckbTransTypeP" default="">
<cfparam name="form.ckbTransTypeC" default="">
<cfparam name="form.ckbFundingTypeOPS" default="">
<cfparam name="form.ckbFundingTypeCRA" default="">
<cfparam name="form.txtVendor" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>
<cfif isDefined("variables.lstErrorMessage") and variables.lstErrorMessage neq "" and find("At least one Transaction Type must be selected.", variables.lstErrorMessage) gt 0>
	<cfif StructKeyExists(form, "CKBTRANSTYPEO")>
		<cfset form = StructUpdate(form, "CKBTRANSTYPEO", "")>
	</cfif>
	<cfif StructKeyExists(form, "CKBTRANSTYPEP")>
		<cfset form = StructUpdate(form, "CKBTRANSTYPEP", "")>
	</cfif>
	<cfif StructKeyExists(form, "CKBTRANSTYPEC")>
		<cfset form = StructUpdate(form, "CKBTRANSTYPEC", "")>
	</cfif>
<cfelse>
	<cfif StructKeyExists(form, "CKBTRANSTYPEO")>
		<cfset form = StructUpdate(form, "CKBTRANSTYPEO", "#form.CKBTRANSTYPEO#")>
	</cfif>
	<cfif StructKeyExists(form, "CKBTRANSTYPEP")>
		<cfset form = StructUpdate(form, "CKBTRANSTYPEP", "#form.CKBTRANSTYPEP#")>
	</cfif>
	<cfif StructKeyExists(form, "CKBTRANSTYPEC")>
		<cfset form = StructUpdate(form, "CKBTRANSTYPEC", "#form.CKBTRANSTYPEC#")>
	</cfif>
</cfif>
<cfif isDefined("variables.lstErrorMessage") and variables.lstErrorMessage neq "" and find("At least one Funding Type must be selected.", variables.lstErrorMessage) gt 0>
	<cfif StructKeyExists(form, "ckbFundingTypeOPS")>
		<cfset form = StructUpdate(form, "ckbFundingTypeOPS", "")>
	</cfif>
	<cfif StructKeyExists(form, "ckbFundingTypeCRA")>
		<cfset form = StructUpdate(form, "ckbFundingTypeCRA", "")>
	</cfif>
<cfelse>
	<cfif StructKeyExists(form, "ckbFundingTypeOPS")>
		<cfset form = StructUpdate(form, "ckbFundingTypeOPS", "#form.ckbFundingTypeOPS#")>
	</cfif>
	<cfif StructKeyExists(form, "ckbFundingTypeCRA")>
		<cfset form = StructUpdate(form, "ckbFundingTypeCRA", "#form.ckbFundingTypeCRA#")>
	</cfif>
</cfif>

<cfif StructFind(form, "FIELDNAMES") eq "CURRENTSTEP,SORTCOLUMN,BTNSAVE">
	<cfset form.ckbTransTypeO = "Obligation">
	<cfset form.ckbTransTypeP = "Payment">
	<cfset form.ckbTransTypeC = "Cost">
	<cfset form.ckbFundingTypeOPS = "OPS">
	<cfset form.ckbFundingTypeCRA = "CRA">
</cfif>

<script>
	function changeDateRange(form){
			var startYear = form.cboFY.value-1;
			form.txtStartDate.value='10/01/'+ startYear;
			form.txtEndDate.value='09/30/'+ form.cboFY.value;
	}
	function changeFY(form){
			var startYear = document.frmSelectCriteria.cboFY.value-1;
			var startDate = '10/01/'+ startYear;
			var endDate = '09/30/'+ document.frmSelectCriteria.cboFY.value;
			//alert(startDate +' == '+ form.txtStartDate.value);

			if (form.txtStartDate.value == '' || form.txtEndDate.value == '' || form.txtStartDate.value != startDate || form.txtEndDate.value != endDate)
				document.frmSelectCriteria.cboFY.value = '';
		}
</script>

<!--- get reference data for drop-down lists --->
<cfinvoke component="#application.paths.components#lookup" method="getFootprintFY" returnvariable="rsFY">

<cfoutput>
<table width="100%" border="0" align="center" cellpadding="3" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
	<td width="18" valign="top" class="StepNumber">5.</td>
	<td colspan="2">Choose Criteria (filter)</td>
</tr>
<tr><!--- AAPP No. --->
	<td></td>
	<td align="right"><label for="idtxtAAPPNum">AAPP No.:</label></td>
	<td>
		<input type="text" name="txtAAPPNum" id="idtxtAAPPNum" value="#form.txtAAPPNum#" size="20" maxlength="12">
	</td>
</tr>
<tr><!--- FY --->
	<td></td>
	<td align="right"><label for="idFY">Footprint Fiscal Year</label></td>
	<td>
		<select name="cboFY" id="idFY"><!---  onChange="changeDateRange(this.form);" --->
			<option value="">All
			<cfloop query="rsFY">
				<option value="#fy#" <cfif form.cboFY eq fy>selected</cfif>>#fy#
			</cfloop>
		</select>
	</td>
</tr>
<tr><!---Transaction Date --->
	<td width="18"></td>
	<td width="230" align="right" valign="top"><label for="idDate">Transaction Date Range:</label></td>
	<td>
		<input type="text" name="txtStartDate" size="15" id="idDate" value="#form.txtStartDate#" class="datepicker" title="Select to specify start  date" />

		<label for="idDateEnd">&nbsp;to&nbsp;</label>
		<input type="text" name="txtEndDate" size="15" id="idDateEnd" value="#form.txtEndDate#" class="datepicker" title="Select to specify end date" />

	</td>
</tr>
<tr><!---Transaction type: OPS/CRA --->
	<td width="18"></td>
	<td width="230" align="right" valign="top"><label for="idTransType">Transaction Type:</label></td>
	<td>
		<input type="checkbox" name="ckbTransTypeO" id="idO" value="Obligation" <cfif StructKeyExists(form, "ckbTransTypeO") and form.ckbTransTypeO eq "Obligation">checked</cfif> /><label for="idO">Obligations</label>&nbsp;&nbsp;
		<input type="checkbox" name="ckbTransTypeP" id="idP" value="Payment" <cfif StructKeyExists(form, "ckbTransTypeP") and form.ckbTransTypeP eq "Payment">checked</cfif> /><label for="idP">Payments</label>&nbsp;&nbsp;
		<input type="checkbox" name="ckbTransTypeC" id="idC" value="Cost" <cfif StructKeyExists(form, "ckbTransTypeC") and form.ckbTransTypeC eq "Cost">checked</cfif> /><label for="idC">Costs</label>&nbsp;&nbsp;
	</td>
</tr>
<tr><!---Funding type: OPS/CRA --->
	<td width="18"></td>
	<td width="230" align="right" valign="top"><label for="idFundingType">Funding Type:</label></td>
	<td>
		<input type="checkbox" name="ckbFundingTypeOPS" id="idOPS" value="OPS" <cfif  StructKeyExists(form, "ckbFundingTypeOPS") and form.ckbFundingTypeOPS eq "OPS">checked</cfif>/><label for="idOPS">OPS</label>&nbsp;&nbsp;
		<input type="checkbox" name="ckbFundingTypeCRA" id="idCRA" value="CRA" <cfif  StructKeyExists(form, "ckbFundingTypeCRA") and form.ckbFundingTypeCRA eq "CRA">checked</cfif> /><label for="idCRA">CRA</label>&nbsp;&nbsp;
	</td>
</tr>

<tr><!--- Vendor--->
	<td width="18"></td>
	<td width="230" align="right" valign="top"><label for="idtxtVendor">Vendor:</label></td>
	<td>
		<input type="text" name="txtVendor" id="idtxtVendor" value="#form.txtVendor#" size="20" maxlength="55">
	</td>
</tr>

</table>
</cfoutput>