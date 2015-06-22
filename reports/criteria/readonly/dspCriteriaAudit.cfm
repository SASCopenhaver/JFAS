
<cfparam name="form.txtAAPPNum" default="">
<cfparam name="form.cboUserName" default="">
<cfparam name="form.txtDateStart" default="">
<cfparam name="form.txtDateEnd" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>

<!--- get a user --->
<cfif form.cboUserName neq "all">
<cfinvoke component="#application.paths.components#user" method="GetJfasUserList" userId="#form.cboUserName#" returnvariable="rsUser">
</cfif>

<cfoutput>
<table width="100%" border="0" align="center" class="criteriaCellDisplay" cellpadding="0" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
		<td width="25%">
			AAPP No.:
		</td>
		<td width="75%">#form.txtAAPPNum#</td>
	</tr>
	<tr>
		<td>User Name:</td>
		<td>
			<cfif #form.cboUserName# neq "all">
				#rsUser.firstName# #rsUser.lastName#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	<tr>
		<td nowrap>Modification Date:&nbsp;</td>
		<td>
			<cfif form.txtDateStart neq "" or form.txtDateEnd neq "">
				<cfif form.txtDateStart neq "">
					#form.txtDateStart#
				</cfif>
				<cfif form.txtDateEnd neq "">
					<cfif form.txtDateStart neq "">
						to 
					<cfelse>
						No later than
					</cfif>
					#form.txtDateEnd#
				<cfelse>
					to present
				</cfif>
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	
</table>
</cfoutput>