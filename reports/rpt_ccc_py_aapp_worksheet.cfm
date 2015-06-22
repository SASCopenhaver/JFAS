<!---  
Page: rpt_ccc_py_aapp_worksheet.cfm
Description: This template is used for providing CCC PY worksheet for agency.
Revisions:
abai 04/09/2007 Revised for adding footer notes and making heading consistence with the form.
yjeng 06/28/2007 Revised CHG 3404, Fixed B2, B3, & B4 amounts not in generated XLS, and remove space
2007-10-17	mstein	Added PY length proration footnote
--->

<cfheader name="Content-Disposition" value="inline;filename=ccc_py_aapp_worksheet.xls">
<cfcontent type="application/msexcel">

<cfset request.pageID=1130>

<cfinvoke component="#application.paths.components#fop_batch" method="getCCCNewPYBudget" aapp="#url.aapp#" py="#url.py#" returnvariable="rst" />
	<cfquery datasource="#request.dsn#" name="qryGetCenterAgence">
		select c.CENTER_NAME, ctr.CONTRACTOR_NAME
		from center c, contractor ctr, aapp a
		where a.CENTER_ID = c.CENTER_ID(+) and
			  a.CONTRACTOR_ID = ctr.CONTRACTOR_ID and
			  a.AAPP_NUM = #url.aapp#
	</cfquery>
	<cfquery name="group_a" dbtype="query">
		select	*
		from	rst.rs2
		where	cost_cat_code='A'
	</cfquery>
	<cfquery name="group_b" dbtype="query">
		select	*
		from	rst.rs2
		where	cost_cat_code in ('B2','B3','B4')
	</cfquery>
	<cfquery name="group_c1" dbtype="query">
		select	*
		from	rst.rs2
		where	cost_cat_code='C1'
	</cfquery>
	<cfquery name="group_c2" dbtype="query">
		select	*
		from	rst.rs2
		where	cost_cat_code='C2'
	</cfquery>
	<cfquery name="group_s" dbtype="query">
		select	*
		from	rst.rs2
		where	cost_cat_code='S'
	</cfquery>
	<cfquery name="group_sum" dbtype="query">
		select	cost_cat_id, sum(amount_py_base) as amount
		from	rst.rs2
		where	amount_py_base is not null
		and		cost_cat_id is not null
		group by cost_cat_id
	</cfquery>
	<cfquery name="fstatus" dbtype="query">
		select	checked as ro
		from	rst.rs3
		where	worksheet_status_id=4
	</cfquery>

<cfoutput>
	
<cfset a_sum = 0>
<cfset b_sum = 0>
<cfset c_sum = 0>
<cfset d_sum = 0>
<cfset s_sum = 0>

<table width="740" border="1" cellpadding="0" cellspacing="0">
<tr valign="bottom">
	<td colspan="2">PY  #url.py# CCC Budget Worksheet for:</td>
	<td colspan="2">#qryGetCenterAgence.CENTER_NAME#</td>
	<td>#dateFormat(now(),'mm/dd/yyyy')#</td>
</tr>
<tr>
	<td colspan="2"></td>
	<td colspan="2">#qryGetCenterAgence.CONTRACTOR_NAME#</td>
	<td>&nbsp;</td>
</tr>
<tr><td colspan="5"></td></tr>
</table>


<table width="740" border="1" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="2" width="300" valign=top><strong>Cost Category</strong></td>
	<td align="center" width="130" valign=top><strong>&nbsp;PY #url.py-1# Baseline 1/&nbsp;</strong></td>
	<td align="center" width="130" valign=top><strong>PY #url.py# Target 2/</strong></td>
	<td align="center" width="130" valign=top><strong>PY #url.py# CCC <br>Agency Proposal</strong></td>
</tr>
</cfoutput>
<!---Group A--->
<cfoutput query="group_a">

<tr>
	<td colspan="2">&nbsp;
		<cfif not len(cost_cat_id)>
			<strong>#cost_cat_desc#</strong>
		<cfelse>
			#cost_cat_desc#
		</cfif>
	</td>
	<td align="right">
		<cfif not len(cost_cat_id)><strong>#numberformat(amount_py_base)#</strong><cfelse>#numberformat(amount_py_base,",")#</cfif>
	</td>
	<td align="right">
		<cfif not len(cost_cat_id)><strong>#numberformat(amount_py_inflated)#</strong><cfelse>#numberformat(amount_py_inflated,",")#</cfif>
	</td>
	<td align="right" <cfif not len(cost_cat_id)>formula="=sum(E3:E40)"</cfif>>
		<cfif not len(cost_cat_id)>
			<strong>#numberformat(amount_py_proposed)#</strong>
		<cfelse>
			#numberformat(amount_py_proposed)#
		</cfif>
	</td>
</tr>
</cfoutput>
<tr>
	<td colspan="2">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
</tr>
<cfoutput query="group_b">
<tr class="AltRow">
	<td colspan="2">
		<cfif not len(cost_cat_id)>
			<strong>#cost_cat_desc#</strong>
		<cfelse>
			#cost_cat_desc#
		</cfif>
	</td>
	<td align="right">
		#numberformat(amount_py_base)#
	</td>
	<td align="right">
		#numberformat(amount_py_inflated)#
	</td>
	<td align="right">
		#numberformat(amount_py_proposed)#
	</td>
</tr>
</cfoutput>
<tr>
	<td colspan="2">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
</tr>
<cfoutput query="group_c1">
<tr class="AltRow">
	<td colspan="2">
		<cfif not len(cost_cat_id)>
			<strong>#cost_cat_desc#</strong>
		<cfelse>
			#cost_cat_desc#
		</cfif>
	</td>
	<td align="right">
		<cfif not len(cost_cat_id)>
			<strong>#numberformat(amount_py_base)#</strong>
		<cfelse>
			#numberformat(amount_py_base)#
		</cfif>
	</td>
	<td align="right">
		<cfif not len(cost_cat_id)>
			<strong>#numberformat(amount_py_inflated)#</strong>
		<cfelse>
			#numberformat(amount_py_inflated)#
		</cfif>
	</td>
	<td align="right" <cfif not len(cost_cat_id)>formula="=sum(E47:E48)"</cfif>>
		<cfif not len(cost_cat_id)>
			<strong>#numberformat(amount_py_proposed)#</strong>
		<cfelse>
			#numberformat(amount_py_proposed)#
		</cfif>
	</td>
</tr>
</cfoutput>
<tr>
	<td colspan="2">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
</tr>
<cfoutput query="group_c2">
<tr class="AltRow">
	<td colspan="2">
		<cfif not len(cost_cat_id)>
			<strong>#cost_cat_desc#</strong>
		<cfelse>
			#cost_cat_desc#
		</cfif>
	</td>
	<td align="right">
		<cfif not len(cost_cat_id)>
			<strong>#numberformat(amount_py_base)#</strong>
		<cfelse>
			#numberformat(amount_py_base)#
		</cfif>
	</td>
	<td align="right">
		<cfif not len(cost_cat_id)>
			<strong>#numberformat(amount_py_inflated)#</strong>
		<cfelse>
			#numberformat(amount_py_inflated)#
		</cfif>
	</td>
	<td align="right" <cfif not len(cost_cat_id)>formula="=sum(E51:E52)"</cfif>>
		<cfif not len(cost_cat_id)>
			<strong>#numberformat(amount_py_proposed)#</strong>
		<cfelse>
			#numberformat(amount_py_proposed)#
		</cfif>
	</td>
</tr>
</cfoutput>
<tr>
	<td colspan="2">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
</tr>
<cfoutput query="group_s">
<tr class="AltRow">
	<td colspan="2">
		<cfif not len(cost_cat_id)>
			<strong>#cost_cat_desc#</strong>
		<cfelse>
			#cost_cat_desc#
		</cfif>
	</td>
	<td align="right">
		<cfif not len(cost_cat_id)>
			<strong>#numberformat(amount_py_base)#</strong>
		<cfelse>
			#numberformat(amount_py_base)#
		</cfif>
	</td>
	<td align="right">
		<cfif not len(cost_cat_id)>
			<strong>#numberformat(amount_py_inflated)#</strong>
		<cfelse>
			#numberformat(amount_py_inflated)#
		</cfif>
	</td>
	<td align="right" <cfif not len(cost_cat_id)>formula="=sum(E55:E56)"</cfif>>
		<cfif not len(cost_cat_id)>
			<strong>#numberformat(amount_py_proposed)#</strong>
		<cfelse>
			#numberformat(amount_py_proposed)#
		</cfif>
	</td>
</tr>
</cfoutput>
<cfoutput>
<tr>
	<td colspan="2">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
</tr>
<tr><td colspan="5">
		1/ Equals the PY #url.py-1# budget with adjustments to arrive at annual ongoing expense amounts
	</td>
</tr>
<tr><td colspan="5">
		2/ Equals PY #url.py-1# baseline with inflation allowances: #numberformat(evaluate((rst.rs3.fed_rate-1)*100),".00")#% for federal personnel, #numberformat(evaluate((rst.rs3.omb_rate-1)*100),".00")#% for other expenses
		<cfif rst.rs3.prorate_factor neq 1> <!--- if prev PY, or next PY is leap year, show proration factor --->
			<br />&nbsp;&nbsp; and a proration factor of #rst.rs3.prorate_factor# for differences in Program Year length<br />
		</cfif>
	</td>
</tr>
</cfoutput>
</table>


