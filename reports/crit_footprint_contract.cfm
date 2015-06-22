<cfsilent>
<!---
page: crit_footprint_contract.cfm

description: This template displays form criteria fields.

revisions:
2007-04-11	abai	Revised for defect 172 -- make title consistent with menu page
2007-07-12	mstein	temporarily removed javascript calls that keep user from entering AAPP number AND other criteria
					(was causing issues on some computers)
2007-07-16  abai	Delete "s" from Agreement Type(s)
2010-01-06	mstein	Added criteria for data source (DOLAR$ or NCFMS)
--->
</cfsilent>

<h2>Footprint/Contractor</h2>

<cfparam name="form.cboFundingOffice" default="0">
<cfparam name="form.cboAgreementType" default="0">
<cfparam name="form.AAPP" default="">
<cfparam name="form.txtStartDate" default="">
<cfparam name="form.txtEndDate" default="">
<cfparam name="form.txtStartDate1" default="">
<cfparam name="form.txtEndDate1" default="">

<cfif session.roleid neq 3 and session.roleid neq 4>
	<cfset fundingOfficeFilter = 0>
<cfelse>
	<cfset fundingOfficeFilter = session.region>
</cfif>

<cfinvoke component="#application.paths.components#lookup" method="getFundingOffices" fundingOfficeNum="#fundingOfficeFilter#" returnvariable="rsFundingOffices">
<cfinvoke component="#application.paths.components#lookup" method="getAgreementTypes"  returnvariable="rsAgreementTypes">

<table width="90%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Search for DOL Contract Information">

<tr>
	<td align="right"><label for="idAAPP">AAPP No.</label></td>
	<td>
		<input type="text" name="AAPP" id="idAAPP" size="6" maxlength="6" value="" tabindex="#request.nextTabIndex#" <!---onChange="fprint_aapp_fund(this.form);"--->/>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>

	</td>
</tr>
<tr>
	<td></td>
	<td><br />OR<br /><br /></td>
</tr>
<tr>
	<td align="right"><label for="idFundingOffice">Funding Office</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>
		<select name="cboFundingOffice" id="idFundingOffice" tabindex="#request.nextTabIndex#" <!---onChange="fprint_aapp_fund(this.form);"--->>
		<cfif session.roleid neq 3 and session.roleid neq 4>
			<option value="0">All Funding Offices</option>
		</cfif>
				<cfloop query="rsFundingOffices">
					<option value="#fundingOfficeNum#"
					<cfif session.roleid is 3 or session.roleid is 4>
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
	<td align="right"><label for="idAgreementType">Agreement Type</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>
		<select name="cboAgreementType" id="idAgreementType"  tabindex="#request.nextTabIndex#"  <!---onChange="fprint_aapp_fund(this.form);"--->>
			<option value="0">All Agreement Types</option>
				<cfloop query="rsAgreementTypes">
					<option value="#agreementTypeCode#"
					 />#agreementTypeDesc#
					</option>
				</cfloop>
		</select>
		</cfoutput>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr valign="top">
	<td align="right"><fieldset><legend align="right">Status</legend>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>
		<input type="radio" name="radStatus" id="idStatus" value="1" tabindex="#request.nextTabIndex#" checked/>
		<label for="idStatus">Active</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		&nbsp;
		<input type="radio" name="radStatus" value="0" id="idStatusInactive" tabindex="#request.nextTabIndex#"/>
		<label for="idStatusInactive">Inactive</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		&nbsp;
		<input type="radio" name="radStatus" value="all" id="idStatusAll"  tabindex="#request.nextTabIndex#" />
		<label for="idStatusAll">All</label>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfoutput>
		</fieldset>
	</td>
</tr>
<tr>
	<td align="right"><label for="idDate">Start Date Range</label></td>
	<td nowrap="nowrap">
	<cfoutput>
		<input type="text" name="txtStartDate" size="15" id="idDate"
		tabindex="#request.nextTabIndex#" class="datepicker" title="Select to specify first date in date range"/>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>

		<label for="idDateEnd">to</label>
		<input type="text" name="txtEndDate" size="15" id="idDateEnd" tabindex="#request.nextTabIndex#"
		class="datepicker" title="Select to specify second date in Start Between range"/>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>

	</cfoutput>
	</td>

</tr>
<tr>
	<td align="right"><label for="idDate1">End Date Range</label></td>
	<td nowrap="nowrap">
	<cfoutput>
		<input type="text" name="txtStartDate1" size="15" id="idDate1"
		tabindex="#request.nextTabIndex#" class="datepicker" title="Select to specify first date in date range" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>

		<label for="idDateEnd1">to</label>
		<input type="text" name="txtEndDate1" size="15" id="idDateEnd1"
		tabindex="#request.nextTabIndex#" class="datepicker" title="Select to specify second date in Start Between range" />
		<cfset request.nextTabIndex = request.nextTabIndex + 1>

	</cfoutput>
	</td>

</tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr>
	<td align="right"><label for="idDataSource_NCFMS">Data source</label>&nbsp;&nbsp;&nbsp;</td>
	<td>
		<cfoutput>
		<label for="idDataSource_NCFMS"><input type="radio" name="radDataSource" id="idDataSource_NCFMS" value="NCFMS" tabindex="#request.nextTabIndex#" checked>&nbsp;NCFMS</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<label for="idDataSource_DOLAR$"><input type="radio" name="radDataSource" id="idDataSource_DOLAR$" value="DOLAR$" tabindex="#request.nextTabIndex#">&nbsp;DOLAR$</label> &nbsp;&nbsp;
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfoutput>
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
	<input type="submit" name="btnGenerateReport" value="Generate Report" tabindex="#request.nextTabIndex#"/>
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="reset" name="btnReset" value="Reset" tabindex="#request.nextTabIndex#" onClick="javascript:window.location='report_criteria_template.cfm?rpt_id=7'" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	<input type="button" name="btnCancel" value="Cancel" tabindex="#request.nextTabIndex#" onClick="javascript:window.location='reports_main.cfm'" />
	<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</cfoutput>
</div>

