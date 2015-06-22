<cfsilent>
<!---
page: crit_ccc_py_budget.cfm

description: This template displays form criteria fields.

revisions:
abai: 04/11/2007  Revised for defect 172 -- make title consistent with menu page
abai: 07/24/2007  Change AAPP to AAPP No.
2011-05-23	mstein	fixed 508 finding (release 2.8)
--->
</cfsilent>

<h2>FOP CCC Budget</h2>

<cfparam name="form.cboAAPP" default="0">
<cfparam name="form.cboCenter" default="0">
<cfparam name="form.cboFundingOffice" default="0">
<cfparam name="form.cboPY" default="0">
<cfparam name="form.cboDolRegion" default="0">

<cfif session.roleid neq 3>
	<cfset fundingOfficeFilter = 0>
<cfelse>
	<cfset fundingOfficeFilter = session.region>
</cfif>

<!--- <cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeType="FED" returnvariable="rsFundingOffices"> --->
<cfinvoke component="#application.paths.components#reports" method="getFED_AAPPS_centers" returnvariable="rsAAPPsCenters">

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">
<tr>
	<td align="right"><label for="idAAPP">AAPP No.</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>	
		<select name="cboAAPP" id="idAAPP" tabindex="#request.nextTabIndex#" onChange="checkCenter(this.form.cboAAPP, this.form.cboCenter);">
			<option value="0">All AAPPs</option>
				<cfloop query="rsAAPPsCenters.rsprogop_detail_aapps">
					<option value="#aapp_num#-#CENTER_ID#">#aapp_num#</option>
				</cfloop>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td align="right"><label for="idCenter">Center</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>	
		<select name="cboCenter" id="idCenter" tabindex="#request.nextTabIndex#"  onChange="checkAAPP(this.form.cboAAPP, this.form.cboCenter);">
			<option value="0">All Centers</option>
				<cfloop query="rsAAPPsCenters.rsprogop_detail_centers">
					<option value="#aapp_num#-#center_id#">#CENTER_NAME#</option>
				</cfloop>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td align="right"><label for="idPY">Program Year&nbsp;&nbsp;&nbsp;</label></td>
	<td>
		<cfoutput>	<!--- loop through all PYs in system --->
		<select name="cboPY" id="idPY" tabindex="#request.nextTabIndex#">
			<option value="0">Select Program Year</option>
			<cfloop query="rstPY">
			<option value="#PY#">#PY#
			</option>
			</cfloop>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td align="right"><label for="idFundingOffice">Funding Office</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>	
		<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#">
			<option value="0">All Funding Offices</option>
				<cfloop query="rsFundingOffices">
					<option value="#fundingOfficeNum#"
					<cfif session.roleid is 3>
						<cfif fundingOfficeNum eq session.region>
						selected
						</cfif>
					</cfif>
					 />#fundingOfficeDesc#
					</option>
				</cfloop>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td align="right"><label for="idDolRegion">DOL Region</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>	
		<select name="cboDolRegion" id="idDolRegion" tabindex="#request.nextTabIndex#">
			<option value="0">All DOL Regions</option>
				<cfloop query="rstDOLRegion">
					<option value="#fundingOfficeNum#"
					<cfif session.roleid is 3>
						<cfif fundingOfficeNum eq session.region>
						selected
						</cfif>
					</cfif>
					 />#fundingOfficeDesc#
					</option>
				</cfloop>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td align="right"><label for="format_html">Report Format</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>
		<label for="format_pdf"><input type="radio" name="radReportFormat" id="format_pdf" value="application/pdf" tabindex="#request.nextTabIndex#" checked>&nbsp;PDF</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<label for="format_html"><input type="radio" name="radReportFormat" id="format_html" value="html" tabindex="#request.nextTabIndex#">&nbsp;HTML</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<label for="format_excel"><input type="radio" name="radReportFormat" id="format_excel" value="application/vnd.ms-excel" tabindex="#request.nextTabIndex#">&nbsp;MS Excel</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfoutput>
	</td>
</tr>
</table>
<div class="buttons">
	<cfoutput>
	<input type="submit" name="btnGenerateReport" value="Generate Report" tabindex="#request.nextTabIndex#" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#" onClick="javascript:window.location='reports_main.cfm'" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</cfoutput>
</div>
<!--- <script>
	checkAAPPCenter(0);
</script> --->
