<!--- Rapid response Dataset Criteria Form (for use with adhoc tool) --->

<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.txtDateStart" default="">
<cfparam name="form.txtDateEnd" default="">
<cfparam name="form.cboUserName" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>

<!--- get reference data for drop-down lists --->
<cfinvoke component="#application.paths.components#user" method="GetJfasUserList" returnvariable="rsUserList">

<cfoutput>

<table width="100%" border="0" align="center" cellpadding="3" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
	<td width="18" valign="top" class="StepNumber">5.</td>
	<td colspan="2">Choose Criteria (filter)</td>
	</tr>
	<tr>
		<td></td>
		<td align="right" width=35%><label for="idtxtAAPPNum">AAPP No.:</label></td>
		<td>
			<input type="text" name="txtAAPPNum" id="idtxtAAPPNum" value="#form.txtAAPPNum#" size="12" maxlength="12"  accesskey="l" tabindex="#request.NextTabIndex#"><cfset request.NextTabIndex=request.NextTabIndex+1>
		</td>
	</tr>
	<tr>
		<td></td>
		<td align="right"><label for="idUser">User Name</label></td>
		<td>
			<select name="cboUserName" id="idUser" tabindex="#request.nextTabIndex#" accesskey="p">
				<option value="all">All</option>
				<cfloop query="rsUserList">
					<option value="#userId#"
						<cfif userId eq form.cboUserName>SELECTED</cfif>>#firstName# #lastName#</option>
				</cfloop>
			</select>
			<cfset request.nextTabIndex=request.nextTabIndex+1>
		</td>
	</tr>

	<tr>
		<td></td>
		<td align="right" valign="top"><label for="idDateStart">Date Issued:</label></td>
		<td>

			<input type="text" size="12" name="txtDateStart" id="idDateStart" value="#form.txtDateStart#"
					accesskey="s" tabindex="#request.nextTabIndex#" maxlength="10" class="datepicker" title="Select to specify start issue date"><cfset request.nextTabIndex=#request.nextTabIndex#+1>
			&nbsp;&nbsp;<label for="idDateEnd">to</label>
			<input type="text" size="12" name="txtDateEnd" id="idDateEnd" value="#form.txtDateEnd#"
					accesskey="e" tabindex="#request.nextTabIndex#" maxlength="10" class="datepicker" title="Select to specify end issue date"><cfset request.nextTabIndex=#request.nextTabIndex#+1>
					&nbsp;&nbsp;(mm/dd/yyyy - leave blank to return all)

		</td>
	</tr>

</table>
</cfoutput>