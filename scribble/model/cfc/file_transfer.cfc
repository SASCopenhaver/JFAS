<!--- 
Template: file_Transfer.cfc
Description: Functions related to file transfer (NCFMS, FMS, etc)

Revision:
2013-08-02	mstein		File created
--->
<cfcomponent name="file_Transfer" displayname="File Transfer Functions" hint="File Transfer Functions">
	
	<cffunction name="getImportParams" returntype="query" output="false" hint="Get parameters for connecting to NCFMS server">
		<cfargument name="importType" type="string" required="true">
		
		<cfquery name="qryGetNCFMSparams" datasource="#request.dsn#" maxrows="1">
		select	*
		from	import_param
		where	import_type = '#arguments.importType#'
		</cfquery>
		
		<cfreturn qryGetNCFMSparams>
	
	</cffunction>
	
	
	<cffunction name="logFileTransfer" output="false" hint="Write to import log table">
		<cfargument name="importType" type="string" required="true">
		<cfargument name="importFile" type="string" required="true">
		<cfargument name="status" type="numeric" required="true">
		<cfargument name="notes" type="string" required="false" default="">
		
		<cfquery name="qryUpdateImportFileLog" datasource="#request.dsn#">
		insert into import_file_log
			(import_date, import_type, file_name,
			status, note)
		values
			(sysdate, '#arguments.importType#', '#arguments.importFile#',
			#arguments.status#, '#notes#')
		</cfquery>
		
	</cffunction>

	
	
	
	
			
	
	
	
</cfcomponent>