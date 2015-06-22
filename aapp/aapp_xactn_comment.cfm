<cfsilent>
<!---
page: aapp_xactn_comment.cfm

description: pop-up form that captures comment for xactn functions

revisions:
2011-07-20	mstein	page created

--->

</cfsilent>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfoutput>
<link href="#application.paths.css#" rel="stylesheet" type="text/css" />
</cfoutput>

<script language="javascript" src="<cfoutput>#application.paths.includes#js_formatstring.js</cfoutput>"></script>
<script language="javascript" src="<cfoutput>#application.paths.includes#js_form_util.js</cfoutput>"></script>
<script language="javascript">

function saveComment(form)
{
	trimFormTextFields(form);
	if (form.txtComment.value == '')
		alert('Please enter comments.');
	else
		{
		window.opener.document.frmDeleteXactn.hidComments.value = form.txtComment.value;
		window.opener.document.frmDeleteXactn.submit();
		window.close();
		}
}

</script>

<title>JFAS : Transaction Update Comment</title>
</head>

<body onLoad="window.focus();document.frmComment.txtComment.focus();" >

<table width="100%" bgcolor="white">
<tr>
	<td>
		<cfoutput>
		<h2>Enter Explanation</h2>
		
		<table width="100%" border="0" cellspacing="0" class="contentTbl" summary="Capture user comments">
		<form name="frmComment" action="#cgi.SCRIPT_NAME#" method="get">
		<tr valign="top">
			<td>
				<label for="idComment">Comment:</label>
			</td>
			<td>
				<textarea name="txtComment" tabindex="#request.nextTabIndex#" cols="55" rows="5"
				onKeyDown="textCounter(this, 500);" onKeyUp="textCounter(this, 500);" style="font-family:arial;font-size:1.0em;"></textarea>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</td>
		</tr>
		<tr>
			<td></td>
			<td>
				<input type="button" name="btnSubmit" value="Save" onClick="saveComment(this.form);" tabindex="#request.nextTabIndex#" style="font-size:x-small;"/><cfset request.nextTabIndex = request.nextTabIndex + 1>
				<input type="button" name="btnCancel" value="Cancel" onClick="window.close();" tabindex="#request.nextTabIndex#" style="font-size:x-small;"/>
			</td>
		</tr>
		</form>
		</table>		
		</cfoutput>
	</td>
</tr>
</table>

</body>
</html>
