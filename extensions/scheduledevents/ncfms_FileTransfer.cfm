<!---
page: ncfms_FileTransfer.cfm

description:	scheduled task to transfer files from NCFMS FTP site to JFAS shared document folder

revisions:

2015-02-23	mstein	Page created

--->
<cfset request.pageID = "0" />
<cfsetting requesttimeout="900">

<cfif NOT isDefined("url.importType")>
	Import Type not defined. Execution aborted.<br>
	<cfabort>
</cfif>

<!--- get transfer parameters from db --->
<cfinvoke component="#application.paths.components#file_transfer" method="getImportParams" importType="#url.importType#" returnvariable="rstNCFMSParams">

<cfset ncfmsKey = application.outility.getSystemSetting(systemSettingCode="ncfms_key")>
<cfset jfasSysEmail = application.outility.getSystemSetting(systemSettingCode="jfas_system_email")>
<cfset emailSuccess = application.outility.getSystemSetting(systemSettingCode="dataImport_success_email")>
<cfset emailFail = application.outility.getSystemSetting(systemSettingCode="dataImport_fail_email")>
<cfset jfasTechPOC = application.outility.getSystemSetting(systemSettingCode="technical_poc_email")>

<cfset paths.jfasShare = rstNCFMSParams.jfas_share_dir>
<cfset paths.remoteFTP = rstNCFMSParams.ftp_remote_dir>


<cfset success="1">
<cfset lstStatusMessage = "">

<cftry>
	<!--- verify connection to FTP server --->
	<cfset job=createObject("Java","JFASFTPS").init("#rstNCFMSParams.ftp_site#","#rstNCFMSParams.ftp_port#",
							   "#rstNCFMSParams.ftp_uid#","#decrypt(rstNCFMSParams.ftp_pwd,ncfmsKey)#","#rstNCFMSParams.ftps_type#")>
	<cfcatch type="any">
		<cfset lstStatusMessage = listAppend(lstStatusMessage,"Error initiating Java class","~~")>
		<cfset success = 0>
	</cfcatch>
</cftry>


<!--- attempt to connect to FTP site --->
<cfif success>
	<cfset conn=job.connect()>
	<cfif conn NEQ 0>
		<!--- if error --->
		<cfset lstStatusMessage = listAppend(lstStatusMessage,"FTP Connection Failure","~~")>
		<cfset success = 0>
	<cfelse>
		<br />
		<cfset lstStatusMessage = listAppend(lstStatusMessage,"FTP Connection Successful: #rstNCFMSParams.ftp_site#","~~")>
	</cfif>
</cfif>

<!--- change directory - on FTP site --->
<cfif success>
	<cfset dir=job.changeDirectory("#rstNCFMSParams.ftp_remote_dir#")>
	<cfif dir NEQ 0>
		<!--- if error --->
		<cfset lstStatusMessage = listAppend(lstStatusMessage,"Failure when changing FTP site directory: #rstNCFMSParams.ftp_remote_dir#.","~~")>
		<cfset success = 0>
	<cfelse>
		<cfset lstStatusMessage = listAppend(lstStatusMessage,"Folder change successful: #rstNCFMSParams.ftp_remote_dir#","~~")>
	</cfif>
</cfif>

<!--- transfer files to local folder --->
<cfif success>
	<cfset tempFileLocation = application.paths.upload & rstNCFMSParams.ftp_remote_file>
	<cfset dwnload = job.getFile(rstNCFMSParams.ftp_remote_file,tempFileLocation)>
	<cfif dwnload NEQ 0>
		<!--- if error --->
		<cfset lstStatusMessage = listAppend(lstStatusMessage,"Failure when transferring file to JFAS server.","~~")>
		<cfset success = 0>
	<cfelse>
		<!--- transfer was successful --->
		<cfoutput>
		<!--- get file date (force current year - bug in java getModDate function when file mod date is same as current date) --->
		<cfset lastFileNameRemote = job.getFileName()>
		<cfset lastFileDateRemote = createDate(year(now()), month(job.getModDate()), day(job.getModDate()))>
		<cfset lstStatusMessage = listAppend(lstStatusMessage,"Transfer of file #rstNCFMSParams.ftp_remote_file# (mod date: #dateformat(lastFileDateRemote)#) successful at #now()#.","~~")>
		
		<!--- if file date is earlier than current date - put warning in message --->
		<cfset currentDate = createDate(year(now()), month(now()), day(now()))>
		<cfset fileAge = dateDiff("d", lastFileDateRemote, currentDate)>
		
		<cfset lstStatusMessage = listAppend(lstStatusMessage,"NOTE: this file was created on #dateformat(lastFileDateRemote)#.","~~")>
		<br>NOTE: this file was created on #dateformat(lastFileDateRemote)#<br />
		</cfoutput>
	</cfif>
</cfif>

<!--- copy file to jfas netshare folder(s) : may be multiple destinations --->
<cfif success>
	<cfloop list="#rstNCFMSParams.jfas_share_dir#" delimiters="~" index="sharedDir">
		
		<cfif not DirectoryExists(sharedDir)>
			<cfoutput>#sharedDir# doesn't exist.</cfoutput><br>
			<cfset DirectoryCreate(sharedDir)>
			Created Directory.<br>
		</cfif>
		
		<cffile action="copy" source="#tempFileLocation#" destination="#sharedDir#">
        <cfset lstStatusMessage = listAppend(lstStatusMessage,"File transferred to #sharedDir#.","~~")>		
	</cfloop>
</cfif>

<!--- log results --->
<cfinvoke component="#application.paths.components#file_transfer" method="logFileTransfer"
	importType="#url.importType#"
	importFile = "#rstNCFMSParams.ftp_remote_file#"
	status = "#success#"
	notes = "#lstStatusMessage#">
</cfinvoke>


<cfsavecontent variable="txtFileTransferResults">
	<cfoutput>
	Details:<br>
	<cfloop list="#lstStatusMessage#" index="statusItem" delimiters="~~">
		- #statusItem#<br>
	</cfloop>
	</cfoutput>
</cfsavecontent>


<br>
<cfoutput>#txtFileTransferResults#</cfoutput>
<br>

<!--- send email --->
<cfif success>
	<cfmail from="#jfasSysEmail#"
		to="#emailSuccess#"
		cc="#jfasSysEmail#"
		subject="#rstNCFMSParams.import_type_desc# Transfer :: SUCCESS :: #dateformat(now(), "yyyy-mm-dd")# #iif(application.cfEnv neq 'prod',DE(' (' & Evaluate('application.cfEnvDesc') & ')'), DE(''))#" type="html">
	#txtFileTransferResults#
	</cfmail>

<cfelse>
	<cfmail from="#jfasSysEmail#"
		to="#emailFail#"
		cc="#jfasSysEmail#;#jfasTechPOC#"
		subject="#rstNCFMSParams.import_type_desc# File Transfer :: FAILURE :: #dateformat(now(), "yyyy-mm-dd")# #iif(application.cfEnv neq 'prod',DE(' (' & Evaluate('application.cfEnvDesc') & ')'), DE(''))#" type="html">
	#txtFileTransferResults#
	</cfmail>

</cfif>



<br><br>

Current contents of JFAS Storage Folders:<br>
<cfloop list="#paths.jfasShare#" delimiters="~" index="sharedDir">
	<!--- loop through all jfas storage folders, and list contents --->
	<cfdirectory directory="#sharedDir#" name="rstShareDocFileList">
	<cfoutput>
	#sharedDir#:<br>
	<cfdump var="#rstShareDocFileList#">
	</cfoutput>
</cfloop>

<br><br>
Import Parameters:
<cfdump var="#rstNCFMSParams#"><br>

