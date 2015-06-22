<!---
page: createScheduledEvents.cfm

description: creates scheduled events for JFAS application

revisions:

--->

<cfschedule 
    action="UPDATE"
	task="aapp_inactive_check"
	operation="HTTPRequest"
	url="http://#cgi.http_host##application.paths.events#validateInactiveAAPPs.cfm"
	startdate="01/03/2011"
	starttime="5:00 am"
	interval="monthly">

<cfoutput>

aapp_inactive_check updated<br /><br />
	
Events updated on: #now()#

</cfoutput>
