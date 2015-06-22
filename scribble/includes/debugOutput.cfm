<!---
page: debugOutput.cfm

description: This page displays at the end of a request if debug mode is on

revisions:

--->

<cfdump var="#request#" label="Request Scope" />

<br><br>

<cfdump var="#session#" label="Session Scope" />

<br><br>

<cfdump var="#application#" label="Application Struct" />

<br><br>

<cfparam name="form">
<cfdump var="#form#" label="Form Struct" />

<br><br>

<cfdump var="#cgi#" label="CGI Struct" />