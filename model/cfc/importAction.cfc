<!---
page name: import_action.cfc
Deacription: This component is used for upload file and import data into temp database.
Revision:

2013-08-04	mstein	File revised to clean up sql loader (prep for ncfms foot)
2013-12-27	mstein	Get SQLLoaderPath from system settings table (instead of request scope)
--->

<cfcomponent name="import data" hint="Import JFAS data">
	<cffunction name="importAction" returntype="string" output="false" hint="Upload Data into a temp table">

	<cfargument name="tableName" type="string" required="true">
	<cfargument name="fileName" required="false" hint="If loading from an uploaded file.">
	<cfargument name="fileExtension" required="false" default="dat">
	<cfargument name="dataLoadPath" required="false" hint="If loading from an uploaded file.">
	<cfargument name="formName" required="false" hint="If loading from an uploaded file.">
	<cfargument name="fullFilePath" required="false" hint="If loading from an existing file (no upload)">
	<cfset errormsg = "">
	<cfset this.result = "">


	<!--- get sql loader parameters from system settings table  --->
	<cfset dbUserName = application.outility.getSystemSetting(systemSettingCode="sqlload_schema")>
	<cfset dbPassword = application.outility.getSystemSetting(systemSettingCode="sqlload_auth")>
	<cfset sqlLoaderPath = application.outility.getSystemSetting(systemSettingCode="sqlload_path")>
	<cfset dbHost = application.outility.getSystemSetting(systemSettingCode="sqlload_host")>


	<!--- check sql loader path required attributes --->
	<cfif fileExists("#sqlLoaderPath#") eq "no">
		<cfset errormsg = errormsg & "The SQL Loader can not be found in the system.">
	</cfif>

	<cfif fileExists("#sqlLoaderPath#") eq "no">
		<cfset errormsg = errormsg & "The control file can not be found.">
	</cfif>

	<!--- check table name --->
	<cfif  arguments.tableName eq "">
		<cfset errormsg = errormsg & "Argument tableName is required.">
	</cfif>





	<cfif errormsg eq "">

		<cfif isDefined("arguments.formName")>
			<!--- upload file --->
			<cffile action="Upload"
					filefield = "#arguments.formName#"
					destination = "#arguments.dataLoadPath##arguments.fileName#.#arguments.fileExtension#"
					nameconflict = "overwrite"
					accept="application/octet-stream, text/plain, application/vnd.ms-excel, application/pdf" >
		<cfelse>
			<!--- copy file from existing location --->
			<cffile action="copy"
					source="#arguments.fullFilePath#"
					destination="#arguments.dataLoadPath##arguments.fileName#.#arguments.fileExtension#">

		</cfif>

		<cfscript>
			pos_bt=0;
			pos_at=0;
			total=0;
			pos_brej=0;
			pos_erej=0;
			total_rej=0;
			error_start = 0;
			error_end = 0;
		</cfscript>


		<!--- give sql loader path --->
		<cfset sql_name="#sqlLoaderPath#">
		<!--- give slq loader arguments --->
		<cfset sql_arguments="userid=#dbUserName#/#dbPassword#@#dbHost# control=#application.paths.config##arguments.fileName#.ctl  data=#arguments.dataLoadPath##arguments.fileName#.dat log=#arguments.dataLoadPath##arguments.fileName#.log  bad=#arguments.dataLoadPath##arguments.fileName#.bad errors=20000 rows=2000 bindsize=262144">

		<!--- invoke SQL loader and insert data --->
		<cfexecute name="#sql_name#"
				arguments="#sql_arguments#"
				variable="uploadLogfile"
				timeout="100">
		</CFEXECUTE>

		<!--- check if import successful --->
		<cfif fileExists("#arguments.dataLoadPath##arguments.fileName#.log") eq "no">
			<cfset errormsg = errormsg & "Your Log file can not be found.">
		<cfelse>
			<CFFILE ACTION="Read"
				FILE="#arguments.dataLoadPath##arguments.fileName#.log"
				VARIABLE="myFile">

			<cfif findNoCase("SQL*Loader-128:", myFile) gt 0>
				<cfset errormsg =  "Invalid db credentials.">
			<cfelseif findNoCase("SQL*Loader-941:", myFile) gt 0>
				<cfset errormsg =  "Uploaded table does not exist. Please check your control file.">
			<cfelseif findNoCase("SQL*Loader-466:", myFile) gt 0>
				<cfset errormsg = "one of the column does not exist. Please check your control file.">
			<cfelse>
				<cfset pos_bt = findnocase("Total logical records read:", myfile,1)>
				<cfset pos_at = pos_bt +15>
				<cfset total = left(trim(mid(myfile, pos_bt+27,pos_at)), 9)>
				<cfset total = RereplaceNoCase(total, "[A-Za-z]", "", "ALL")>

				<cfset pos_brej = findnocase("Total logical records rejected:", myfile,1)>
				<cfset pos_erej = pos_bt +15>
				<cfset total_rej = left(trim(mid(myfile, pos_brej+31,pos_erej)), 9)>
				<cfset total_rej = RereplaceNoCase(total_rej, "[A-Za-z]", "", "ALL")>

				<cfif total_rej gt 0>
					<cfset error_start=ReFindNoCase("Rejected \-", myFile)>
					<cfset error_end = FindNoCase("Rows successfully loaded.", myFile, error_start+1)>
					<cfif evaluate("#error_start#-14") gt 0 and evaluate("#error_end#-#error_start#-#len(arguments.tableName)#-8") gt 0>
						<cfset errorMsg=mid("#myFile#", error_start-14, error_end-error_start-#len(arguments.tableName)#-8)>
					</cfif>
					<cfset errormsg =  ReReplaceNoCase(errormsg, 'Rejected - Error on table #dbUserName#.#arguments.tableName#,', '', 'ALL')>
					<cfset errormsg =  ReReplaceNoCase(errormsg, '#chr(13)##chr(10)#Field in', ' Field in', 'ALL')>
					<cfset errormsg =  ReReplaceNoCase(errormsg, '#chr(13)##chr(10)#ORA-01722', ' ', 'ALL')><!--- invlid number --->
					<cfset errormsg =  ReReplaceNoCase(errormsg, '#chr(13)##chr(10)#ORA-01400', ' ', 'ALL')><!--- cannot insert NULL  --->
					<cfset errormsg =  ReReplaceNoCase(errormsg, '#chr(13)##chr(10)#ORA-00001', ' ', 'ALL')><!--- unique constraint   --->
					<cfset errormsg =  ReReplaceNoCase(errormsg, '#chr(13)##chr(10)#Record', 'Record', 'ONE')>
					<cfset errormsg =  ReReplaceNoCase(errormsg, '#chr(13)##chr(10)#Record', 'Record', 'ONE')>
				</cfif>
				<cfset errormsg = "#ltrim(ReREplacenocase(errormsg, '#chr(13)##chr(10)#', '<br>','ALL'))#">
			</cfif>

		</cfif>
	</cfif>

	<cfset this.result = errormsg>

	<cfreturn this.result>

	</cffunction>
</cfcomponent>

<!--- end of choose upload method --->


