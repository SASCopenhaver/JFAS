
<cfparam name="form.txtAAPPNum" default="">

<cfset form = StructAppend(form,session.adHocReport.getDataset().getCriteria().getFormData(),true)>
<!--- get display version of form criteria --->


<cfoutput>
<table width="100%" border="0" align="center" class="criteriaCellDisplay" cellpadding="0" cellspacing="0" class="FormTable_line" summary="Layout Table for Data entry form">
	<tr>
		<td width="15%" nowrap>
			AAPP No.:&nbsp;
		</td>
		<td width="85%">
			<cfif form.txtAAPPNum neq "">
				#form.txtAAPPNum#
			<cfelse>
				All
			</cfif>
		</td>
	</tr>
	
</table>
</cfoutput>