<!--- message_editor.cfc --->

<cfcomponent displayname="comp_MessageEditor">
<!------------------------------------------------------------------------------------------------------------------------------------>
	<cffunction name="f_getMessageTypes" access="remote" returntype="any" returnformat="plain" output="no" hint="Returns a list of the messages.">
		<cfstoredproc procedure="JFAS.MESSAGE_PKG.sp_getMessageTypes" returncode="no">
        	<cfprocresult name="spr_getMessageTypes" resultset="1">
        </cfstoredproc>
        <cfreturn SerializeJSON(spr_getMessageTypes)>
	</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------>
	<cffunction name="f_getNewMessageID" access="remote" returntype="any" returnformat="plain" output="no" hint="Function returns a new message ID.">
       <cfstoredproc procedure="JFAS.MESSAGE_PKG.sp_getNewMessageID" returncode="no">
            <cfprocresult name="spr_getNewMessageID" resultset="1">
        </cfstoredproc>
        <cfreturn SerializeJSON(spr_getNewMessageID)>
    </cffunction>
<!----------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="f_getSelectedMessage" access="remote" returntype="any" returnformat="plain" output="no" hint="Function retrieves text of the message.">
		<cfargument name="arg_MsgID"   type="numeric" required="yes">
        <cfstoredproc procedure="JFAS.MESSAGE_PKG.sp_getSelectedMessage" returncode="no">
			<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_MsgID"   value="#arguments.arg_MsgID#">
            
            <cfprocresult name="spr_getSelectedMessage" resultset="1">
        </cfstoredproc>
        
        <cfreturn SerializeJSON(spr_getSelectedMessage)>
    </cffunction>
<!----------------------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="f_InsertUpdateMessage" access="remote" returntype="any" returnformat="plain" output="no" hint="Function updates customizable message.">
		<cfargument name="arg_MsgStatus"  type="numeric" required="yes">
        <cfargument name="arg_MsgID"      type="numeric" required="yes">
        <cfargument name="arg_MsgType"    type="string"  required="yes">
        <cfargument name="arg_MsgComment" type="string"  required="yes">
        <cfargument name="arg_MsgText"    type="string"  required="yes">
        <cfargument name="arg_UserID"     type="string"  required="yes">
		 
        <cfstoredproc procedure="JFAS.MESSAGE_PKG.sp_InsertUpdateMessage" returncode="no">
        	<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_MsgStatus"  value="#arguments.arg_MsgStatus#">
			<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_MsgID"      value="#arguments.arg_MsgID#">		
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_MsgType"    value="#arguments.arg_MsgType#">	
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_MsgComment" value="#arguments.arg_MsgComment#">
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_MsgText"    value="#arguments.arg_MsgText#">	
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_UserID"     value="#arguments.arg_UserID#">
        	
            <cfprocresult name="spr_InsertUpdateMessage" resultset="1">
        </cfstoredproc>
        
        <cfreturn SerializeJSON(spr_InsertUpdateMessage)>
        
	</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------>
	<cffunction name="f_deleteSelectedMessage" access="remote" returntype="any" returnformat="plain" output="no" hint="Function deletes message.">
        <cfargument name="arg_MsgID"      type="numeric" required="yes">
        
        <cfstoredproc procedure="JFAS.MESSAGE_PKG.sp_deleteSelectedMessage" returncode="no">
			<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_MsgID" value="#arguments.arg_MsgID#">
            
            <cfprocresult name="spr_getRemainingRecords" resultset="1">
        </cfstoredproc>
        
        <cfreturn SerializeJSON(spr_getRemainingRecords)>
        
	</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------>



 
    
    
    
    
    
<!------------------------------------------------------------------------------------------------------------------------------------>
	<cffunction name="f_getMessage" access="remote" returntype="any" returnformat="plain" output="no" hint="Function retrieves text of the message.">
		<cfargument name="arg_MsgID"   type="numeric" required="yes">
        <cfargument name="arg_MsgType" type="string"  required="yes">
        <cfargument name="arg_UserID"  type="string"  required="yes">
        
        <cfstoredproc procedure="JFAS.MESSAGE_PKG.sp_getMessage" returncode="no">
			<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_MsgID"   value="#arguments.arg_MsgID#">
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_MsgType" value="#arguments.arg_MsgType#">
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_UserID"  value="#arguments.arg_UserID#">
            
            <cfprocresult name="spr_getMessage" resultset="1">
        </cfstoredproc>
        
        <cfreturn SerializeJSON(spr_getMessage)>
    </cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------>
	<cffunction name="f_SaveUpdateMessage" access="remote" returntype="any" returnformat="plain" output="no" hint="Function updates customizable message.">
		<cfargument name="arg_MsgID"   type="numeric" required="yes">
        <cfargument name="arg_MsgType" type="string"  required="yes">
        <cfargument name="arg_MsgText" type="string"  required="yes">
        <cfargument name="arg_Status"  type="numeric" required="yes">
        <cfargument name="arg_UserID"  type="string"  required="yes">
		 
        <cfstoredproc procedure="JFAS.MESSAGE_PKG.sp_SaveUpdateMessage" returncode="no">
			<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_MsgID"   value="#arguments.arg_MsgID#">		<!---Ex: 1--->
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_MsgType" value="#arguments.arg_MsgType#">	<!---Ex: WELCOME--->
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_MsgText" value="#arguments.arg_MsgText#">	<!---Ex: Xxxx xxxx xxxxx.--->
            <cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_Status"  value="#arguments.arg_Status#">	<!---Ex: 1--->
            <cfprocparam type="in" cfsqltype="cf_sql_varchar" variable="arg_UserID"  value="#arguments.arg_UserID#">	<!---Ex: mstain--->
        	
            <!---<cfprocresult name="spr_getMessage" resultset="1">--->
        </cfstoredproc>
        
        <!---<cfreturn SerializeJSON(spr_getMessage)>--->
        
	</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------>
</cfcomponent>




