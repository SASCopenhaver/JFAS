<cfsilent>
<!---
page: vendor_search.cfm

description: pop-up form that allows searching for Vendors in Footprint Table

revisions:
2011-07-20	mstein	page created

--->

<cfparam name="url.vendorNameSearch" default="">
<cfparam name="url.vendorIDSearch" default="">

<cfif url.vendorIDSearch eq ".."><cfset url.vendorIDSearch = ""></cfif>

<cfif len(url.vendorNameSearch) or len(url.vendorIDSearch)>
	<!--- search for vendors --->
	<cfinvoke component="#application.paths.components#contractor" method="vendorSearch"
		searchContents="footprint"
		searchName="#url.vendorNameSearch#"
		searchID="#url.vendorIDSearch#"
		returnvariable="rstVendorSearchResults" />
</cfif>
</cfsilent>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<link href="#application.paths.css#" rel="stylesheet" type="text/css" />
</cfoutput>

<script language="javascript" src="<cfoutput>#application.paths.includes#js_formatstring.js</cfoutput>"></script>
<script language="javascript">

function selectVendor(vendorName,vendorID)
{
	window.opener.document.frmEnterXactn.txtVendorName.value = vendorName;
	if (vendorID != '' &&  vendorID != '..')
		window.opener.document.frmEnterXactn.txtVendorID.value = vendorID;
	else
			window.opener.document.frmEnterXactn.txtVendorID.value = '';
	window.close();
}

</script>

<title>JFAS : Vendor/Contractor Search</title>
</head>

<body onLoad="window.focus();document.frmVendorSearch.vendorNameSearch.focus();" >

<table width="100%" bgcolor="white">
<tr>
	<td>
		<cfoutput>
		<h2>Vendor Search</h2>
		<div class="btnRight" style="font-size:x-small;font-family:Arial;margin-right:10px;"><a href="javascript:window.close();">Close Window</a></div>
		
		<table width="100%" border="0" cellspacing="0" class="dataTbl" summary="User Information to be added to JFAS user list">
		<form name="frmVendorSearch" action="#cgi.SCRIPT_NAME#" method="get">
		<tr>
			<td>
				<label for="idVendorNameSearch">Name:</label>
			</td>
			<td colspan="2">
				<input type="text" name="vendorNameSearch" id="idVendorNameSearch" maxlength="80" size="70"
				value="#url.vendorNameSearch#" onChange="this.value = trim(this.value);" tabindex="#request.nextTabIndex#"
				 style="font-size:smaller;"/>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</tr>
		<tr valign="top">
			<td>
				<label for="idVendorIDSearch">DUNS:</label>
			</td>
			<td>
				<input type="text" name="vendorIDSearch" id="idVendorIDSearch" maxlength="25" size="18"
				value="#url.vendorIDSearch#" onChange="this.value = trim(this.value);" tabindex="#request.nextTabIndex#"
				 style="font-size:smaller;"/>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
			<td align="right">
				<input type="submit" name="btnSubmit" value="Search" tabindex="#request.nextTabIndex#"  style="font-size:x-small;"/>
			</td>
		</tr>
		</form>
		</table>		
		</cfoutput>
		
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTbl">
		<tr><td colspan="2" height="8"></td></tr>
		<tr><td colspan="2" class="hrule"></td></tr>
		<tr><td colspan="2" height="8"></td></tr>
		<cfif isDefined("rstVendorSearchResults")>
			<cfoutput query="rstVendorSearchResults">
				<tr>
					<td><a href='javascript:selectVendor("#vendorName#","#vendorID#");'>#vendorName#</a></td>
					<td>#vendorID#</td>
				</tr>
			</cfoutput>
			<cfif not rstVendorSearchResults.recordCount>
				<tr>
					<td align="center" colspan="2" height="200">Your search criteria returned no results.</td>
				</tr>
			</cfif>			
		<cfelse>
			<tr>
				<td align="center" colspan="2" height="200">Enter search criteria above to search for a vendor/contractor.</td>
			</tr>
		</cfif>
		</table>
	</td>
</tr>
</table>
</body>
</html>
