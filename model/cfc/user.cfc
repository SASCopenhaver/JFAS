<!---
page: user.cfc

description: component that handles jfas user functions

revisions:
2007-09-11	mstein	Added RoleID to GetJfasUserList (to get admin emails for scheduled event)
2013-12-27	mstein	Updated recordUserLogin to capture user_agent (Browser information)
2014-11-16	mstein	Added user alert message functions
--->
<cfcomponent displayname="User Component" hint="Handles User setup">

<cffunction name="loginUser"
access="public"
returntype="boolean"
output="false"
hint="Logs in user based on EBSS session ID.  Set session variables from the Oracle database">
	<!--- this IS a sessionID from the common.sessions.cf Oracle table known by P:\grantee_prod\application.cfm --->
	<cfargument name="EBSSsession_ID" type="string" required="yes">

	<cfscript>

	success = "true";
	session.userID = "";
	//  belldr 01/10/2014
	session.region = "";

	//  determine EBSS user ID based on EBSSsession_ID eg 'jadminuser', 'juser', 'jregionuser', 'mstein'
	EBSSUserID = this.getEBSSUserID(arguments.EBSSsession_ID);

	if ( EBSSUserID neq "" ) {

		//  this is an EBSS user
		session.userID = trim(EBSSUserID);
		//  one cannot SET the CF sessionID in session.  We are storing the relationship to the EBSSsession_ID, only
		session.EBSSsession_ID = arguments.EBSSsession_ID;

		//  get user information from EBSS account
		rstEBSSUserData = this.getEBSSUserData(session.userID);

		if ( rstEBSSUserData.recordCount gt 0 ) { //  user found in EBSS accounts table?
			session.fullName = rstEBSSUserData.fullName;
			session.emailAddress = rstEBSSUserData.emailAddress;
			session.region = rstEBSSUserData.region;
			ClearUserPreferences();

			//  check for user information in JFAS user table
			rstJFASUserData = this.getJFASUserData(session.userID,1);


			if ( rstJFASUserData.recordcount gt 0) { //  user found in JFAS user table?
				//  if user is in JFAS user table, set session vars based on that data
				session.roleID = rstJFASUserData.roleID;
				session.rolecd = ListGetAt( application.slrolecds, session.roleID);
				session.roleDesc = rstJFASUserData.roleDesc;
				// retrieve the entire filter definition for the current filter. This creates a default filter for a new user
				bReturn = ReadMyFilter(session.userID, 'Now');
				// get the current MyAAPPs and MyFilter from the database. This does NOT affect roleID and region
				bReturn = ReadMyAAPPs(session.userID);
				// retrive an array of all the MyFilters
				bReturn = ReadFilterList(session.userID);
				// retrieve the entire SplanDisplaySetting definition for a PERM Splan. This creates a default SplanDisplaySetting for a new user
				bReturn = ReadMySplanDisplaySetting (session.userID, 'PERM');

			} else {
				//  if user does not have account in JFAS user table, give them regional priviledges
				session.roleID = 3;
				session.roleDesc = "Regional Office (read-only)";
			}

		} else { //  user not found in EBSS user table
			success = "false";
		}

	} else {
		success = "false";
	}

	if (success) {
		temp = this.recordUserLogin(session.userID);
	}

	return success;
	</cfscript>
</cffunction>


<cffunction name="getEBSSUserID" returntype="string" access="package" output="false" hint="Get user ID from EBSS session table">
	<cfargument name="EBSSsession_ID" type="numeric" required="yes">

	<!--- get EBSS user ID, based on session ID --->
	<cfquery name="qryGetUserID" datasource="#request.dsn#">
	SELECT NVL(common.sessions.USER_ID, null) as userID
	FROM   common.sessions
	WHERE  SESSION_ID = #arguments.EBSSsession_ID#
	</cfquery>

	<cfreturn qryGetUserID.userID>

</cffunction>

<cffunction name="getEBSSUserData" returntype="query" access="package" output="false" hint="Get user data from EBSS account table">
	<cfargument name="userID" type="string" required="yes">

	<!--- get EBSS account information based on user_id --->
	<cfquery name="qryGetEBSSAccountData" datasource="#request.dsn#">
	SELECT	Substr(first_name, 1,  1) || '. ' || last_name as fullName,
			email_address as emailAddress,
			new_region as region
	FROM   common.accounts
	WHERE  user_id = '#arguments.userID#'
	</cfquery>

	<cfreturn qryGetEBSSAccountData>

</cffunction>

<cffunction name="getSessionAnnouncement">
	<cfargument name="nHeight" type="numeric" required="yes" >
	<cfargument name="nWidth" type="numeric" required="yes" >
	<!--- get the SystemAlertMsg from the Oracle database, where it was set in the Administration section of the software.  If it is not enabled, then set the session variable to an empty string --->
	<cfset var sAnnouncement = ''>
	<cfset var qAnnouncement = ''>
	<cftry>

		<cfset qAnnouncement = getMessageAlert( messageType='WELCOME', status="1")>
		<cfif qAnnouncement.recordcount GE 1>
			<cfset sAnnouncement = qAnnouncement.messageText[1]> <!--- assuming one row for WELCOME message --->
		</cfif>
		<!--- <cfset sAnnouncement = 'Test Hard Coded Message in user.cfc'> --->
		<cfcatch>
			<cfset sAnnouncement = 'Problem reading announcement from database (user.cfc)'>
		</cfcatch>
	</cftry>
	<cfreturn application.oUtility.setAlertLayout(sAnnouncement, nHeight, nWidth) />

</cffunction>


<cffunction name="getJFASUserData" returntype="query" access="package" output="false" hint="Get user data from JFAS user table">
	<cfargument name="userID" type="string" required="no" default="">
	<cfargument name="statusID" type="numeric" required="no" default="">

	<!--- get JFAS account information based on user_id --->
	<cfquery name="qryGetJFASAccountData" datasource="#request.dsn#">
	SELECT	first_name as firstName,
			last_name as lastName,
			email as emailAddress,
			user_jfas.user_role_id as roleID,
			user_role_desc as roleDesc,
			user_role_cd as roleCd
	FROM	user_jfas inner join lu_user_role on
				(user_jfas.user_role_id = lu_user_role.user_role_id)
	WHERE	1 = 1
	<cfif arguments.userID neq "">
		and	upper(user_id) = upper('#arguments.userID#')
	</cfif>
	<cfif arguments.statusID neq "" AND arguments.statusID NEQ 0>
		and user_status_id = #arguments.statusID#
	</cfif>
	</cfquery>

	<cfreturn qryGetJFASAccountData>

</cffunction>

<cffunction name="getUserData" returntype="query" access="public" output="false" hint="Get user data for one user">
	<!--- for security, don't expose whole table --->
	<cfargument name="userID" type="string" required="yes" default="">
	<cfset var qryGetJFASAccountData = getJfasUserData ( arguments.userID, 0) />
	<cfreturn qryGetJFASAccountData />

</cffunction>

<cffunction name="recordUserLogin" output="false" hint="Record User Login">
	<cfargument name="userID" type="string" required="yes">

	<cfquery name="qryInsertUserLogin" datasource="#request.dsn#">
	INSERT INTO user_login (user_id, date_login, browser)
	VALUES ('#arguments.userID#', sysdate, '#left(cgi.http_user_agent,300)#')
	</cfquery>

	<cfquery name="qryUpdateUserLoginDate" datasource="#request.dsn#">
	update	user_jfas
	set		date_last_login = sysdate
	where	user_id = '#arguments.userID#'
	</cfquery>

</cffunction>


<!--- get the jfas users, or get information on one user if you have the user id --->
<cffunction name="GetJfasUserList" returntype="query" access="public">
	<cfargument name="userId" required="no" type="string">
	<cfargument name="roleID" required="no" type="numeric">

	<cfquery name="qryGetJfasUsers" datasource="#request.dsn#">
	select	jfas.user_jfas.user_id as userId,
			jfas.user_jfas.user_status_id as status,
			jfas.user_jfas.user_role_id as roleId,
			common.accounts.first_name	as firstName,
			common.accounts.last_name	as lastName,
			common.accounts.email_address as email,
			jfas.lu_user_role.user_role_desc as userRole
	from	jfas.user_jfas inner join common.accounts
			on (jfas.user_jfas.user_id = common.accounts.user_id)
				inner join jfas.lu_user_role
				on (jfas.user_jfas.user_role_id = jfas.lu_user_role.user_role_id)
	where	1 = 1
	<cfif isDefined("arguments.userId")> <!--- if you have the user id --->
		and jfas.user_jfas.user_id = '#arguments.userId#'
	</cfif>
	<cfif isDefined("arguments.roleID")> <!--- if you have the role --->
		and jfas.user_jfas.user_role_id = #arguments.roleID#
	</cfif>
	order by jfas.user_jfas.user_status_id DESC,
		common.accounts.last_name, common.accounts.first_name
	</cfquery>

<cfreturn qryGetJfasUsers>

</cffunction>

<!--- update the users info in the jfas database --->
<cffunction name="UpdateUser" access="public">
	<cfargument name="userId" type="string" required="yes">
	<cfargument name="status" type="numeric" required="no">
	<cfargument name="roleId" type="numeric" required="no">

		<cfquery name="qryUpdateUserInfo" datasource="#request.dsn#">
		update user_jfas
		set
			<cfif isDefined("arguments.roleId")>
			user_role_id = #arguments.roleId#,
			</cfif>
			<cfif isDefined("arguments.status")>
			user_status_id = #arguments.status#,
			</cfif>
			UPDATE_USER_ID = '#session.userID#',
			UPDATE_FUNCTION = '#request.auditVarUpdate#',
			UPDATE_TIME = sysdate
		where user_id = '#arguments.userId#'
		</cfquery>

</cffunction>

<!--- Before adding a new user, make sure that they're in EBSS, but not in JFAS --->
<cffunction name="VerifyNewUser" access="public" returntype="struct">
	<cfargument name="userId" type="string" required="yes">
	<cfset success = true>
	<cfset lstErrorMsg = ''>
	<!--- make sure they're in EBSS --->
		<cfquery name="qryVerifyUser" datasource="#request.dsn#">
		select common.accounts.first_name as firstName,
			common.accounts.last_name as lastName,
			common.accounts.email_address as email,
			common.accounts.user_id as userId
		from common.accounts
		where common.accounts.user_id = '#arguments.userId#'
		</cfquery>

		<cfif qryVerifyUser.recordcount neq 1> <!--- if not in EBSS --->
			<cfset lstErrorMsg = listAppend(lstErrorMsg, "#userId# is not a user in the EBSS system", "~")>
			<cfset success = false>
		<cfelse> <!--- check to see if they're in JFAS --->
			<cfinvoke component="#application.paths.components#user" method="GetJfasUserList" userId="#qryVerifyUser.userId#"
			returnvariable="rstUserData">
			<cfif rstUserData.recordcount GT 0><!--- if they are --->
				<cfset success = false>
				<cfset lstErrorMsg = listAppend(lstErrorMsg,"#userId# is already a JFAS user.", "~")>
			</cfif>
		</cfif>

	<!--- return struct --->
	<cfset stcVerifyResults = StructNew()>
		<cfset stcVerifyResults.success = success>
		<cfset stcVerifyResults.errorMsg = lstErrorMsg>
		<cfif stcVerifyResults.success><!--- only return user's information if successful --->
			<cfset stcVerifyResults.firstName = qryVerifyUser.firstName>
			<cfset stcVerifyResults.lastName = qryVerifyUser.lastName>
			<cfset stcVerifyResults.email = qryVerifyUser.email>
		</cfif>

	<cfreturn stcVerifyResults>

</cffunction>

<!--- add a user to jfas --->
<cffunction name="AddNewJfasUser" access="public">
	<cfargument name="userId" type="string" required="yes">
	<cfargument name="firstName" type="string" required="no">
	<cfargument name="lastName" type="string" required="no">
	<cfargument name="email" type="string" required="no">
	<cfargument name="roleId" type="numeric" required="no">
	<cfargument name="status" type="numeric" required="no">

	<cfquery name="qryAddUser" datasource="#request.dsn#">
	insert into user_jfas
	fields(user_id, first_name, last_name, email, user_role_id, user_status_id, UPDATE_USER_ID, UPDATE_FUNCTION, UPDATE_TIME)
	values('#userId#', '#firstName#', '#lastName#', '#email#', #roleId#, #status#, '#session.userID#', '#request.auditVarInsert#', sysdate)
	</cfquery>

</cffunction>

<!--- Update or Insert user data into JFAS_user table --->
<cffunction name="saveJFASUserData" access="public" returntype="void">
<cfargument name="formData" type="struct" required="yes">
	<cfif arguments.formData.hidMode is "edit">
		<cfinvoke component="#application.paths.components#user" method="UpdateUser"
		userId = "#arguments.formData.txtUserId#"
		roleId = "#arguments.formData.radRole#"
		status = "#arguments.formData.radStatus#">

	<cfelseif arguments.formData.hidMode is "add">
		<cfinvoke component="#application.paths.components#user" method="AddNewJfasUser"
		userId = "#arguments.formData.txtUserId#"
		firstName = "#arguments.formData.txtFirstName#"
		lastName = "#arguments.formData.txtLastName#"
		email = "#arguments.formData.txtEmail#"
		roleId = "#arguments.formData.radRole#"
		status = "#arguments.formData.radStatus#">
	</cfif>

</cffunction>

<cffunction name="getUserAccessSettings" access="public" returntype="query" hint="returns query with list of users and access to sections">
	<cfargument name="roleID" type="numeric" required="no">

	<cfquery name="qryUserAccessSettings" datasource="#request.dsn#">
	select	user_role_access.user_role_id as	userRoleID,
			user_role_desc as 					userRoleDesc,
			user_role_cd as 					userRoleCd,
			aapp_access as						aappAccess,
			reports_access as 					reportsAccess,
			budget_access as 					budgetAccess,
			admin_access as 					adminAccess
	from	user_role_access, lu_user_role
	where	user_role_access.user_role_id = lu_user_role.user_role_id
		<cfif isDefined("arguments.roleID")>
			and user_role_access.user_role_id = #arguments.roleID#
		</cfif>
	order	by lu_user_role.sort_number
	</cfquery>

	<cfreturn qryUserAccessSettings>

</cffunction>

<cffunction name="updateUserRoleAccess" access="public" returntype="void" hint="updates user access settings">
	<cfargument name="roleID" type="numeric" required="yes">
	<cfargument name="aappAccess" type="numeric" required="yes">
	<cfargument name="reportsAccess" type="numeric" required="yes">
	<cfargument name="adminAccess" type="numeric" required="yes">
    <cfargument name="budgetAccess" type="numeric" required="yes">

	<cfquery name="qryUpdateAccessSetting" datasource="#request.dsn#">
	update	user_role_access set
			aapp_access = #arguments.aappAccess#,
			reports_access = #arguments.reportsAccess#,
			admin_access = #arguments.adminAccess#,
            budget_access = #arguments.budgetAccess#,
			update_user_id = '#session.userID#',
			update_function = '#request.auditVarUpdate#',
			update_time = sysdate
	where	user_role_id = #arguments.roleID#
	</cfquery>

</cffunction>

<cffunction name="saveUserAccessSettings" access="public" returntype="struct" hint="handles form save for user access settings">
	<cfargument name="formData" type="struct" required="yes">

	<cfset success = "true">
	<cfset errorMessages = "">
	<cfset errorFields = "">

	<!--- remove data admin role from list of roles (can not be edited) --->
	<cfset arguments.formData.UserRoleList = replace(arguments.formData.UserRoleList,'2','','all')>

	<!--- loop through list of user roles, and update access based on form data --->
	<cfloop list="#arguments.formData.UserRoleList#" index="roleID">
		<cfinvoke method="updateUserRoleAccess"
					roleID="#roleID#"
					aappAccess="#iif(structKeyExists(arguments.formData, "r" & roleID & "_aappAccess"),1,0)#"
					reportsAccess="#iif(structKeyExists(arguments.formData, "r" & roleID & "_reportsAccess"),1,0)#"
					adminAccess="#iif(structKeyExists(arguments.formData, "r" & roleID & "_adminAccess"),1,0)#"
                    budgetAccess="#iif(structKeyExists(arguments.formData, "r" & roleID & "_budgetAccess"),1,0)#">
	</cfloop>

	<!--- set up structure to return --->
	<cfset stcResults = StructNew()>
	<cfset stcResults.success = success>
	<cfset stcResults.errorMessages = errorMessages>
	<cfset stcResults.errorFields = errorFields>

	<cfreturn stcResults>

</cffunction>


<!--- USER ALERT MESSAGE FUNCTIONS --->
<cffunction name="getMessageAlert" access="public" returntype="query" hint="Returns Alert Messages">
	<cfargument name="messageType" type="string" required="false">
	<cfargument name="messageID" type="numeric" required="false">
	<cfargument name="status" type="string" required="false" default="all">

	<cfquery name="qryMessageAlert" >
	select	message_id messageID,
			message_text messageText,
			message_type messageType,
			status
	from	message_alert
	where	1=1
		<cfif isDefined("arguments.messageType")>
			and upper(message_type) = '#ucase(arguments.messageType)#'
		</cfif>
		<cfif isDefined("arguments.messageID")>
			and message_id = '#arguments.messageID#'
		</cfif>
		<cfif arguments.status neq "all">
			and status = '#arguments.status#'
		</cfif>
	</cfquery>

	<cfreturn qryMessageAlert>
</cffunction>

<cffunction name="saveMessageAlert" access="public" hint="Returns Alert Messages">
	<cfargument name="formData" type="struct" required="yes">

	<cfinvoke component="#application.paths.components#user" method="insertUpdateMessage"
		messageText="#arguments.formData.txtMessageText#"
		messageType="#arguments.formData.hidMessageType#"
		status="#arguments.formData.radStatus#"
		userID="#session.userID#">

</cffunction>


<cffunction name="insertUpdateMessage" access="public">
	<cfargument name="messageText" type="string" required="false" default="">
	<cfargument name="messageType" type="string" required="true">
	<cfargument name="status" type="string" required="false" default="">
	<cfargument name="userID" type="string" required="false" default="">

	<!--- check to see if this message type exists already --->
	<cfquery name="qryCheckforMessage" datasource="#request.dsn#">
	select	message_id
	from	message_alert
	where	upper(message_type) = '#ucase(arguments.messageType)#'
	</cfquery>

	<cfif qryCheckforMessage.recordcount> <!--- message exists, so update --->
		<cfquery name="qryUpdateMessage" datasource="#request.dsn#">
		update	message_alert set
				message_text = '#arguments.messageText#',
				status = '#arguments.status#',
				update_user_id = '#arguments.userID#',
				update_time = sysdate
		where	message_type = '#ucase(arguments.messageType)#'
		</cfquery>

	<cfelse> <!--- message doesn't exist, so insert --->

		<!--- get next val from sequence --->
		<cfquery name="qryGetSeq" datasource="#request.dsn#">
		select	seq_message_alert.nextval as newID
		from	dual
		</cfquery>

		<cfquery name="qryInsertMessage" datasource="#request.dsn#">
		insert into message_alert (
				message_id, message_text,
				status, message_type,
				update_user_id, update_time)
		values	(#qryGetSeq.newID#, '#arguments.messageText#',
				#arguments.status#, '#ucase(arguments.messageType)#',
				'#arguments.userID#', sysdate)
		</cfquery>
	</cfif>

</cffunction>


<!--- NEW PREFERENCES ROUTINES --->
<cfoutput>
<cffunction name="ReadUserPreference" access="package">
	<cfargument name="user_ID"   type="string" required="yes">
	<cfargument name="preferenceKey"   type="string" required="yes">
	<cfargument name="DBpreferenceKey"   type="string" required="yes">

	<!--- 1 = true = OK, 0 = NOT OK --->
	<cfset var bReturn = 1>
	<cfset var tDeserialized = structNew()>
	<cfset var selectOne = ''>

	<cfquery name="selectOne" datasource="jfas">
		select serialized_value from user_preference
		where user_ID = '#arguments.user_ID#'
		and preference_key = '#arguments.DBpreferenceKey#'
	</cfquery>

	<cfif selectOne.recordCount EQ 1>
		<!--- create a structure from the JSON --->
		<cfset tDeserialized = DeserializeJSON(selectOne.serialized_value)>
		<!--- allow overwrite of the existing preference key in session.userpreferences --->
		<cfset structInsert(session.UserPreferences, arguments.preferenceKey, tDeserialized, 1)>
	<cfelse>
		<cfset var bReturn = 0>
	</cfif>
	<cfreturn bReturn />

</cffunction><!--- ReadUserPreference --->

<cffunction name="WriteUserPreference" access="package">
	<cfargument name="user_ID"   type="string" required="yes">
	<cfargument name="preferenceKey"   type="string" required="yes">
	<cfargument name="serializedValue"   type="string" required="yes">
	<cfargument name="bConfirmOverwrite"   type="string" required="no" default="1">

	<cfset var checkDups = ''>
	<cfset var deleteDups = ''>
	<cfset var insertOne = ''>
	<cfset var updateOne = ''>
	<!--- 1 = true = OK, 0 = NOT OK --->
	<cfset var bReturn = 1>

	<!--- protect against database down --->
	<cftry>
		<cfquery name="checkDups" datasource="jfas">
			select count(*) cnt from user_preference
			where user_ID = '#arguments.user_ID#'
			and preference_key = '#arguments.preferenceKey#'
		</cfquery>
		<cfset var nCount = checkDups.cnt>
		<cfif nCount GT 1>
			<!--- this is an error condition.  Clear out the garbage --->
			<cfquery name="deleteDups" datasource="jfas">
			delete from user_preference
			where user_ID = '#arguments.user_ID#'
			and preference_key = '#arguments.preferenceKey#'
			</cfquery>
			<cfset nCount = 0>
		</cfif>
		<cfif nCount EQ 0>
			<cfquery name="insertOne" datasource="jfas">
				insert into user_preference (user_ID, preference_key, serialized_value)
				values
				('#arguments.user_id#', '#arguments.preferenceKey#', '#arguments.serializedValue#' )
			</cfquery>
		<cfelse>
			<!--- nCount EQ 1 --->
			<cfif arguments.bConfirmOverwrite EQ '0'>
				<!--- not allowing clobbering a pre-existing preference --->
				<cfset bReturn = 0>
			<cfelse>
				<cfquery name="updateOne" datasource="jfas">
					update user_preference
					set serialized_value = '#arguments.serializedValue#'
					where user_ID = '#arguments.user_ID#'
					and preference_key = '#arguments.preferenceKey#'
				</cfquery>
			</cfif>
		</cfif>
		<cfcatch type="any">
			<cfset bReturn = 0>
		</cfcatch>
		<cffinally>
			<cfreturn bReturn />
		</cffinally>
	</cftry>

</cffunction> <!--- WriteUserPreference --->

<cffunction name="WriteMyFilter" access="public" output="false" returntype="numeric">
	<cfargument name="user_ID"   type="string" required="yes">
	<cfargument name="filterName"   type="string" required="yes">
	<cfargument name="bConfirmOverwrite"   type="string" required="no" default="1">

	<!---
	I write session.userPreferences.tMyFilterNow to the database for user_ID, MyFilter<filterName>
	user_ID 		like 'mstein'
	filterName		'Now' is the current state of the UI, otherwise a named "My Filter"
	bConfirmOverwrite is 1 if an overwrite is allowed

	I return
		1 = success
		2 = fail because it is a duplicate, and overwrite was not allowed
		0 = other failure
	--->

	<cfset 	var filterKey = 'myFilter' & arguments.filterName>

	<cfset var checkDups = ''>
	<cfset var deleteDups = ''>
	<cfset var insertOne = ''>
	<cfset var updateOne = ''>

	<cfset var nReturn = 1>
	<cfset var sSerialValue = '#SerializeJSON(session.UserPreferences.tMyFilterNow)#'>

	<!--- protect against database down --->
	<cftry>
		<cfquery name="checkDups" >
			select count(*) cnt from user_preference
			where user_ID = '#arguments.user_ID#'
			and preference_key = '#filterkey#'
		</cfquery>
		<cfset var nCount = checkDups.cnt>
		<cfif nCount GT 1>
			<!--- There is more than one dup. This is an error condition.  Clear out the garbage --->
			<cfquery name="deleteDups">
			delete from user_preference
			where user_ID = '#arguments.user_ID#'
			and preference_key = '#filterkey#'
			</cfquery>
			<cfset nCount = 0>
		</cfif>
		<cfif nCount EQ 1>
			<cfif arguments.bConfirmOverwrite EQ '0'>
				<!--- not allowing clobbering a pre-existing preference --->
				<cfset nReturn = 2>
			<cfelse>
				<cfquery name="updateOne">
					update user_preference
					set serialized_value = '#sSerialValue#'
					where user_ID = '#arguments.user_ID#'
					and preference_key = '#filterkey#'
				</cfquery>
			</cfif>
		<cfelse>
			<!--- nCount EQ 0 --->
			<cfquery name="insertOne">
				insert into user_preference (user_ID, preference_key, serialized_value)
				values
				('#arguments.user_id#', '#filterkey#', '#sSerialValue#' )
			</cfquery>
		</cfif>
		<!--- get the list of filters into the session scope --->
		<cfset ReadFilterList(arguments.user_id)>

		<cfcatch type="any">
			<cfset nReturn = 0>
		</cfcatch>
		<cffinally>
			<cfreturn nReturn />
		</cffinally>
	</cftry>

</cffunction> <!--- WriteMyFilter --->

<cffunction name="WriteMySplanDisplaySetting" access="public" output="false" returntype="numeric">
	<cfargument name="user_ID"   type="string" required="yes">
	<cfargument name="SplanName"   type="string" required="yes">

	<!---
	I write session.userPreferences.tMySplanNow to the database for user_ID, MySplan<splanName>
	user_ID 		like 'mstein'
	splanName		'Now' is the current state of the UI, otherwise a named "My Splan", where name = "Saved"

	I return
		1 = success
		0 = other failure
	--->

	<cfset 	var filterKey = 'mySplan' & arguments.SplanName>

	<cfset var checkDups = ''>
	<cfset var insertOne = ''>
	<cfset var updateOne = ''>

	<cfset var nReturn = 1>

	<cfset var d = duplicate (session.UserPreferences.tMySplanNow) >

	<!--- don't save todate, unless we are doing custom --->
	<cfif d.radspendingbreakdown NEQ 4>
		<cfset d.todate = ''>
	</cfif>

	<cfset var sSerialValue = '#SerializeJSON( d )#'>

	<!--- protect against database down --->
	<cftry>
		<cfquery name="checkDups" >
			select count(*) cnt from user_preference
			where user_ID = '#arguments.user_ID#'
			and preference_key = '#filterkey#'
		</cfquery>
		<cfset var nCount = checkDups.cnt>
		<cfif nCount EQ 1>
			<cfquery name="updateOne">
				update user_preference
				set serialized_value = '#sSerialValue#'
				where user_ID = '#arguments.user_ID#'
				and preference_key = '#filterkey#'
			</cfquery>
		<cfelse>
			<!--- nCount EQ 0 --->
			<cfquery name="insertOne">
				insert into user_preference (user_ID, preference_key, serialized_value)
				values
				('#arguments.user_id#', '#filterkey#', '#sSerialValue#' )
			</cfquery>
		</cfif>
		<cfcatch type="any">
			<cfset nReturn = 0>
		</cfcatch>
		<cffinally>
			<cfreturn nReturn />
		</cffinally>
	</cftry>
	<cfreturn nReturn />

</cffunction> <!--- WriteMySplanDisplaySetting --->

<cffunction name="ReadFilterList" access="package" output="true">
	<cfargument name="user_ID"   type="string" required="yes">

	<cfset var qMyFilters = ''>
	<cfset var aMyFilters = ''>

	<cfquery name="qMyFilters">
		select substr(preference_key, 9) as filterName from user_preference
		where user_ID='#arguments.user_ID#'
		and substr(preference_key, 1, 8) = 'myFilter'
		and substr(preference_key, 9) != 'Now'
	</cfquery>

	<cfset session.userPreferences.aMyFilters = ListToArray( Valuelist (qMyFilters.filtername) )>
	<!---
	<cfdump var="#session#" label="session in ReadFilterList">
	<cfabort>
	--->
	<cfreturn 1 />

</cffunction> <!--- ReadFilterList --->

<cffunction name="DeleteMyFilter" access="package" output="false">
	<cfargument name="user_ID"   type="string" required="yes">
	<cfargument name="filterName"   type="string" required="yes">

	<!---
/**
* @hint I delete a filterName from session.UserPreferences.aMyFilters, and write the result to the database
* @user_ID like 'mstein'
* @filterName		the filterName to delete
*/
	--->

	<cfset var qDeleteMyFilter = ''>
	<cfset var bReturn = 1>
	<cftry>

		<!--- case counts! --->
		<cfset var vpreference_key = 'myFilter' & arguments.filterName>

		<cfset bReturn = ArrayDelete(session.UserPreferences.aMyFilters, filterName)>
		<cfquery name="qDeleteMyFilter">
			delete user_preference
			where user_ID='#arguments.user_ID#'
			and preference_key = '#vpreference_key#'
		</cfquery>

		<cfcatch type="any">
			<cfset bReturn = 0>
		</cfcatch>
		<cffinally>
			<cfreturn bReturn />
		</cffinally>
	</cftry>

</cffunction> <!--- DeleteMyFilter --->

<cffunction name="DeleteMySplanDisplaySetting" access="public" output="false">
	<cfargument name="user_ID"   type="string" required="yes">
	<cfargument name="splanName"   type="string" required="yes">

	<!---
/**
* @hint I delete a splanName from session.UserPreferences, and write the result to the database
* @user_ID like 'mstein'
* @filterName		the filterName to delete (must be PERM)
*/
	--->

	<cfset var qDeleteMyFilter = ''>
	<cfset var bReturn = 1>
	<cftry>

		<!--- case counts! --->
		<cfset var vpreference_key = 'mySplan' & arguments.splanName>

		<cfquery name="qDeleteMySplan">
			delete user_preference
			where user_ID='#arguments.user_ID#'
			and preference_key = '#vpreference_key#'
		</cfquery>

		<cfcatch type="any">
			<cfset bReturn = 0>
		</cfcatch>
		<cffinally>
			<cfreturn bReturn />
		</cffinally>
	</cftry>

</cffunction> <!--- DeleteMySplanDisplaySetting --->

<cfscript>

/**
* @hint I write session.userPreferences.aMyAAPPs into the database
* @user_ID like 'mstein'
*/
public boolean function writeMyAAPPs (
	required user_ID
	)

	output			= "false"
	{

	var filterKey = 'myAAPPs';

	var bReturn = 1;
	try {
		bReturn = WriteUserPreference(arguments.user_id, filterKey, '#SerializeJSON(session.UserPreferences.aMyAAPPs)#' );
	} // try
	catch (any e) {
		// session timeout
		bReturn = 0;
	} // catch
	finally {
		return bReturn;
	} // finally

} // writeMyAAPPs


/**
* @hint I read the myAAPPs array from the database into session.userPreferences.aMyAAPPs
* @user_ID like 'mstein'
*/
public boolean function ReadMyAAPPs (
	required user_ID
	)

	output			= "false"
	{

	return ReadUserPreference(arguments.user_ID, 'aMyAAPPs', 'myAAPPs');

} // ReadMyAAPPs


/**
* @hint I replace session.userPreferences.tMyFilterNow with deserialized values from user_preference for user_ID, MyFilter<filterName>
* @user_ID like 'mstein'
* @filterName		'Now' is the current state of the UI, otherwise a named "My Filter"
*/
public boolean function ReadMyFilter (
	required user_ID
	, required filterName
	)

	output			= "false"
	{

	try {
		var DBpreferenceKey = 'myFilter' & arguments.filterName;

		// always read into the session.userpreferences.tMyFilterNow
		var bReturn = ReadUserPreference(arguments.user_ID, 'tMyFilterNow', DBpreferenceKey);
		if (bReturn NEQ 1) {
			if (filterName NEQ 'Now') {
				// it is an error to try to read a real named MyFilter
				return bReturn;
			}
			else {
				// this is a new user.  Create a default filter in the session scope
				CreateDefaultFilter();
				bReturn = 1;
			}
		}

		var tTemp = StructNew();
		tTemp = Duplicate(session.UserPreferences.tMyFilterNow);

		var slKeyList = structKeyList(application.userPreferencesDefault.tMyFilterNow);
		var slDBKeyList = structKeyList(tTemp);

		var bAnyChange = 0;

		// delete any value from the database that is not in the defined list of required Filter Components
		for (var walker = 1; walker LE ListLen(slDBKeyList); walker += 1) {
			if ( NOT ListContains(slKeyList, ListGetAt(slDBKeyList, walker))) {
				// delete the value
				StructDelete(tTemp, ListGetAt(slDBKeyList, walker));
				bAnyChange = 1;
			}
		}

		// now ensure that all the required preferences are in the structure
		for (walker = 1; walker LE ListLen(slKeyList); walker += 1) {
			if ( NOT StructKeyExists(tTemp, ListGetAt(slKeyList, walker))) {
				// insert the missing required filter component, with a default value
				StructInsert(tTemp, ListGetAt(slKeyList, walker), '' );
				bAnyChange = 1;
			}
		}
		if (bAnyChange) {
			session.UserPreferences.tMyFilterNow = structNew();
			session.UserPreferences.tMyFilterNow = Duplicate(tTemp);
		}

	} // try
	catch (any e) {
		bReturn = 0;
	} // catch
	finally {
		return bReturn;
	}

} // ReadMyFilter

/**
* @hint I replace session.userPreferences.tMySplanNow with deserialized values from user_preference for user_ID, MySplan<splanName>
* @user_ID like 'mstein'
* @splanName		'Now' is the current state of the UI, but not saved, otherwise "MyPerm", which is saved for the next login
*/
public boolean function ReadMySplanDisplaySetting (
	required user_ID
	, required splanName
	)

	output			= "true"
	{

	try {
		var DBpreferenceKey = 'mySplan' & arguments.splanName;

		// always read into the session.userpreferences.tMySplanNow
		var bReturn = ReadUserPreference(arguments.user_ID, 'tMySplanNow', DBpreferenceKey);

		if (bReturn NEQ 1) {
			if (splanName NEQ 'PERM') {
				// it is an error to try to read anything but PERM
				return bReturn;
			}
			else {
				// this is a new user.  Create a default filter in the session scope
				CreateDefaultSplanDisplaySetting();
				bReturn = 1;
			}
		}

		var tTemp = StructNew();
		tTemp = Duplicate(session.UserPreferences.tMySplanNow);

		var slKeyList = structKeyList(application.userPreferencesDefault.tMySplanNow);
		var slDBKeyList = structKeyList(tTemp);

		var bAnyChange = 0;

		// delete any value from the database that is not in the defined list of required Filter Components
		for (var walker = 1; walker LE ListLen(slDBKeyList); walker += 1) {
			if ( NOT ListContains(slKeyList, ListGetAt(slDBKeyList, walker))) {
				// delete the value
				StructDelete(tTemp, ListGetAt(slDBKeyList, walker));
				bAnyChange = 1;
			}
		}

		// now ensure that all the required preferences are in the structure
		for (walker = 1; walker LE ListLen(slKeyList); walker += 1) {
			if ( NOT StructKeyExists(tTemp, ListGetAt(slKeyList, walker))) {
				// insert the missing required filter component, with a default value
				StructInsert(tTemp, ListGetAt(slKeyList, walker), '' );
				bAnyChange = 1;
			}
		}
		if (bAnyChange) {
			session.UserPreferences.tMySplanNow = structNew();
			session.UserPreferences.tMySplanNow = Duplicate(tTemp);
		}

	} // try
	catch (any e) {
		bReturn = 0;
	} // catch
	finally {
		return bReturn;
	}
	return bReturn;

} // ReadMySplanDisplaySetting

/**
* @hint I set session.userPreferences.tMyFilterNow to the default structure
*/
public struct function ResetMyFilter (
	)

	output			= "false"
	{

	var tReturn = StructNew();
	var bReturn = 1;

	try {
		ClearUserPreferences();
		CreateDefaultFilter();

		var nReturn =  WriteMyFilter(session.userID, 'Now', 1);
		// this is just reporting on what has already been done in the session scope
		// tReturn has bReturn, and copy of the default userPreferences structure
		if (nReturn NEQ 1) {
			bReturn = 0;
		}
		tReturn.bReturn = bReturn;
		// returns a copy of the default filter
		tReturn.tMyFilterNow = Duplicate(session.userPreferences.tMyFilterNow);
	} // try
	catch (any e) {
		tReturn.bReturn = 0;
		tReturn.tMyFilterNow = 'Error caught in ouser.ResetMyFilter '  ;
	} // catch
	finally {
		return tReturn;
	}

} // ResetMyFilter

/**
* @hint I set session.userPreferences.tMyFilterNow to the default structure, with a keyword
*/
public struct function SetFilterToKeyword (
	sKey
	)

	output			= "false"
	{

	var tTemp = StructNew();
	var tReturn = StructNew();
	var bReturn = 1;

	// write out a filter that is just the keyword passed in
	tTemp = Duplicate(application.userPreferencesDefault.tMyFilterNow);
	tTemp.HOME_FILTERSEARCHWORD = sKey;
	session.userPreferences.tMyFilterNow = Duplicate(tTemp);
	var nReturn =  WriteMyFilter(session.userID, 'Now', 1);

	// this is just reporting on what has already been done in the session scope
	if (nReturn NEQ 1) {
		bReturn = 0;
	}
	tReturn.bReturn = bReturn;
	tReturn.tMyFilterNow = Duplicate(session.userPreferences.tMyFilterNow);
	return tReturn;

} // SetFilterToKeyword

public function CreateDefaultFilter() {

	var bReturn = 1;
	try {
		// session.roleID: 3=regional, 4=regional admin
		if (not listfind("3,4", session.roleID)) {
			session.userPreferences.tMyFilterNow.HOME_FUNDINGOFFICEFILTER = "20";
		}
		else {
			session.userPreferences.tMyFilterNow.HOME_FUNDINGOFFICEFILTER = "#session.region#";
		}

		session.userPreferences.tMyFilterNow.HOME_CONTRACTSTATUSFILTER = "Active";
		session.userPreferences.tMyFilterNow.HOME_AGREEMENTTYPEFILTER = "DC";
	} // try
	catch (any e) {
		// session timeout
		bReturn = 0;
	} // catch
	finally {
		return bReturn;
	} // finally

} // CreateDefaultFilter

public function CreateDefaultSplanDisplaySetting() {

	var bReturn = 1;

	// retrieve current PY from database
	tPY = application.oSplan.getSplanPY();
	nCurrentPY = tPY.aRet[1].PY;

	// get the first date of a Splan in the given PY
	tFirstSplan = application.oSplan.getFirstSplanDate( nCurrentPY );
	sFirstSplanDate = tFirstSplan.aRet[1].texttransdate;

	try {
		session.userPreferences.tMySplanNow = structNew();
		session.userPreferences.tMySplanNow.PY = nCurrentPY;
		session.userPreferences.tMySplanNow.RADSPENDINGBREAKDOWN = 1;
		session.userPreferences.tMySplanNow.RADSAVESETTINGS = 1;
		session.userPreferences.tMySplanNow.TODATE = dateFormat(Now(), 'mm/dd/yyyy');
		var CUSTOMDATE = ArrayNew(1);
		for (var walker = 1; walker le 14; walker += 1) {
			CUSTOMDATE[walker] = '';
		}
		CUSTOMDATE[1] = sFirstSplanDate ;
		session.userPreferences.tMySplanNow.CUSTOMDATE = duplicate(CUSTOMDATE);
	} // try
	catch (any e) {
		// session timeout
		bReturn = 0;
	} // catch
	finally {
		return bReturn;
	} // finally

} // CreateDefaultSplanDisplaySetting


/**
* @hint I set session.userPreferences.tMyFilterNow to the default structure
*/
public void function ClearUserPreferences (
	)

	output			= "false"
	{
	session.userPreferences.aMyAAPPs = [];
	session.userPreferences.aMyFilters = [];
	session.userPreferences.tMyFilterNow = structNew();
	// this is the application scope
	session.userPreferences.tMyFilterNow = Duplicate(application.userPreferencesDefault.tMyFilterNow);
	return;

} // ClearUserPreferences

/**
* @hint I save an aappNum in the user's list of My AAPPs, which is a preference
* @user_ID like 'mstein'
* @aappNum		the aappNum to save
*/
remote boolean function SaveMyAAPP (
	required user_ID
	, required string aappNum
	)

	returnFormat	= "plain"
	output			= "false"

	{

	var bReturn = 1;

	try {
		var slMyAAPPs = ArrayToList(session.UserPreferences.aMyAAPPs);

		if ( NOT ListContains(slMyAAPPs, arguments.aappNum)) {
			slMyAAPPs 							= ListSort(ListAppend(slMyAAPPs, arguments.aappNum), 'numeric');
			session.UserPreferences.aMyAAPPS 	= Duplicate(ListToArray(slMyAAPPs));
			bReturn 							= writeMyAAPPs(arguments.user_ID);
		}

	} // try

	catch (any e) {
		// session timeout
		bReturn = 0;
	} // catch
	finally {
		return bReturn;
	} // finally

} // SaveMyAAPP

/**
* @hint I delete an aappNum from session.UserPreferences.aMyAAPPs, and write the result to the database
* @user_ID like 'mstein'
* @aappNum		the aappNum to delete
*/
remote boolean function DeleteMyAAPP (
	required user_ID
	, required string aappNum
	)

	returnFormat	= "plain"
	output			= "false"

	{
	var bReturn = 1;
	try {

		var bReturn = ArrayDelete(session.UserPreferences.aMyAAPPs, aappNum);
		bReturn = writeMyAAPPs(arguments.user_ID);
	} // try
	catch (any e) {
		// session timeout
		bReturn = 0;
	} // catch
	finally {
		return bReturn;
	} // finally

} // DeleteMyAAPP


</cfscript>
<!--- END OF NEW PREFERENCES ROUTINES --->
</cfoutput>

</cfcomponent>