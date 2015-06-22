<cfsilent>
<!---
page: users.cfm

description: list of users to edit, or button to add a user

revisions:

--->

<cfset request.pageID = "2600" /> 
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System - User Admin">
<cfset request.pageTitleDisplay = "JFAS System Administration">

<cfinvoke component="#application.paths.components#user" method="GetJfasUserList" returnvariable="qryUserList">

<!--- preform queries to retrieve reference data to populate drop-down lists --->
</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />
				

	<h2>Users</h2>
	
	<!--- if validation errors exist, display them --->
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="List of JFAS users">
	<tr>
		<td>
			<cfoutput>Displaying 1-#qryUserList.recordcount# of #qryUserList.recordcount# users</cfoutput>
		</td>
		<td align="right"><!--- submit info to edituser page for adding new user --->
			<form name="frmAddUser" action="edituser.cfm" method="post">
			<input type="hidden" name="hidMode" value="add" />
			<input type="hidden" name="hidStatus" value="1" />
			<input type="hidden" name="hidRoleId" value="1" />
			<input type="hidden" name="txtUserId" value="" />
			<input type="hidden" name="txtLastName" value="" />
			<input type="hidden" name="txtFirstName" value="" />
			<input type="hidden" name="txtEmail" value="" />
			<input type="hidden" name="hidIdStyle" value="" />
			<input type="submit" name="btnSubmit" value="Add New User" tabindex="#request.nextTabIndex#" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</form>
		</td>
	</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl" summary="Display list of users">
	<tr>
	<th style="text-align:left">
		Name
	</th>
	<th style="text-align:left">
		Role
	</th>
	<th style="text-align:left">
		Status
	</th>
	</tr>		
	<cfoutput query="qryUserList">
	<tr valign="top" <cfif not (currentRow mod 2)>class="AltRow"</cfif>>
		<td align="left">
			<a href="edituser.cfm?id=#userId#">#lastName#, #firstName#</a>
		</td>
		<td align="left">
			#userRole#
		</td>
		<td align="left">
			<cfif status is 1>Active<cfelse>Inactive</cfif>
		</td>
	</tr>
	</cfoutput>
	</table>
	


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />