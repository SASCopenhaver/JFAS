<!---
page: lookup.cfc

description: JFAS Equipment Dataset Criteria Form (for use with adhoc tool) 

revisions:
--->


<cfparam name="form.txtAAPPNum" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>

<!--- get reference data for drop-down lists --->

<cfoutput>

<table width="100%" border="0" align="center" cellpadding="3" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
	<td width="18" valign="top" class="StepNumber">5.</td>
	<td colspan="2">Choose Criteria (filter)</td>
</tr>
<tr>
	<td></td>
	<td align="right"><label for="idtxtAAPPNum">AAPP No.:</label></td>
	<td>
		<input type="text" name="txtAAPPNum" id="idtxtAAPPNum" value="#form.txtAAPPNum#" size="12" maxlength="12"  accesskey="l" tabindex="#request.NextTabIndex#"><cfset request.NextTabIndex=request.NextTabIndex+1>
	</td>
</tr>





</table>
</cfoutput>