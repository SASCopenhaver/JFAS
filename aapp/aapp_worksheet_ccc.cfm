<cfsilent>
<!---
page: aapp_worksheet_ccc.cfm

description: display CCC worksheet

revisions:

2007-04-02	yjeng	Add length limit for editable field, change go from submit to button
2007-04-09	yjeng	Change wording
2007-04-19	yjeng	Fix bug for inflation rate title
2007-05-14	yjeng	Add B3 inflation rate title
2007-05-16	yjeng	Remove B3 inflation rate title
2007-07-12  abai    Revised print button to generate a PDF worksheet.
2007-08-07  rroser  changed print button to allow new window to be maximized/minimized.
2007-09-25	mstein	added in "PY proration" line at top
2007-12-04	mstein	added link to Batch Process for admin users
2009-06-01	mstein	reformat of worksheet based on Appendix 509 changes (see Rel 2.5 docs)
--->

<cfset request.pageID = "510" /> 
<cfparam name="form.py_ccc" default="#evaluate(request.py_ccc+1)#">
<cfparam name="url.fromPage" default="">
<cfparam name="variables.lstErrorMessages" default="" />

<cfif isDefined("form.btnSave")> <!--- form submitted --->
	<!--- save CCC Worksheet data --->
	<cfinvoke component="#application.paths.components#fop_batch" method="saveCCCNewPYBudget" formData="#form#" returnvariable="stcSaveResults" />
	<cfif stcSaveResults.success>
		<!--- if save was successful, then redirect back to this page in edit mode --->
		<cfif isDefined("form.cboStatus") and form.cboStatus eq 0>
			<cflocation url="#cgi.SCRIPT_NAME#?aapp=#stcSaveResults.aappNum#&save=1&reset=1" addtoken="no" />
		<cfelse>
			<cflocation url="#cgi.SCRIPT_NAME#?aapp=#stcSaveResults.aappNum#&save=1" addtoken="no" />
		</cfif>
	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfset variables.lstErrorMessages = stcSaveResults.errorMessages />
	</cfif>
<cfelse>
	<!--- Query --->
	<cfinvoke component="#application.paths.components#fop_batch" method="getCCCNewPYBudget" aapp="#url.aapp#" py="#form.py_ccc#" returnvariable="rst" />
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
		<cfif form.py_ccc lt evaluate(request.py_ccc+1)>
		select	1 as ro
		from	rst.rs3
		<cfelse>
		select	checked as ro
		from	rst.rs3
		where	worksheet_status_id=4
		</cfif>
	</cfquery>
</cfif>

<!--- check to see if batch process is already in progress for this PY --->
<cfinvoke component="#application.paths.components#fop_batch" method="getBatchProcessStatus" py="#form.py_ccc#" adj_type="CCC" returnvariable="rstStatus"/>

</cfsilent>

<!---<cfdump var="#group_a#"><br />--->

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />
<script language="javascript1.1" type="text/javascript">
var AAPPS=new Array;
<cfoutput query="group_sum">
	AAPPS[#cost_cat_id#]=#amount#;
</cfoutput>
<cfoutput>
var fed_rate=#rst.rs3.fed_rate#;
var omb_rate=#rst.rs3.omb_rate#;
var py_prorate = #rst.rs3.prorate_factor#;
</cfoutput>
function calcol12(s) {
	var myarray=s.name.split("_");
	var non_fed=0,j=0,valS=0;
	<!---
	myarray[0]=header
	myarray[1]=aapp_num
	myarray[2]=program_year
	myarray[3]=ccc_worksheet_id
	myarray[4]=column
	myarray[5]=buffer
	myarray[6]=cost_cat_id
	myarray[7]=default amount
	myarray[8]=cost_cat_code
	--- dev added 5/28/09:
	myarray[9]=pd_expense
	myarray[10]=base_subtotal
	myarray[11]=base_subtotal_nopd
	---
	ex:rec_1604_2007_1_col1_catid_10_1_A_0_0_1
	--->
	
	//Do not allow null
	if (trim(s.value)=='') {
		s.value='.';
	}
	//Check if it is good number
	checkNum(s);
	// Good Number
	if (getStatus()==1) {
		// Stripped comma for s.value and convert to Int
		formatNum1(s,9);
		// Input value is great than maximum
		if (AAPPS[myarray[6]]<=s.value) {
			s.value = AAPPS[myarray[6]];
		}
	
		for (i=0;i<document.form1.elements.length; i++) {
			<!---Pro rate Fed Column 2--->			
			if (document.form1.elements[i].name.indexOf(myarray[0]+'_'+myarray[1]+'_'+myarray[2]+'_'+myarray[3]+'_col2_'+myarray[5]+'_'+myarray[6]+'_'+myarray[7]+'_'+myarray[8])!=-1) {
				document.form1.elements[i].value=Math.round(s.value*py_prorate*fed_rate);
				formatNum1(document.form1.elements[i]);
			}
			<!---Non Fed--->
			if (document.form1.elements[i].name.indexOf(myarray[4]+'_'+myarray[5]+'_'+myarray[6]+'_0')!=-1) {
				non_fed=AAPPS[myarray[6]]-s.value;
				document.form1.elements[i].value=non_fed;
				formatNum1(document.form1.elements[i]);
			}
			<!---Pro rate Non Fed Column 2--->
			if (document.form1.elements[i].name.indexOf('_col2_'+myarray[5]+'_'+myarray[6]+'_0')!=-1) {
				document.form1.elements[i].value=Math.round(non_fed*py_prorate*omb_rate);
				formatNum1(document.form1.elements[i]);
			}
		}
		formatNum1(s);
		<!---Sum for colum2--->
		sumcal('col2',myarray[8]);
		<!---disable generate xls--->
		disable_gen_xls();
	} 
	// End Good Number
}

function sumcal(col,cat) {
	var colTotal=0, colSubTotal=0, totalElmID=0,subtotalElmID=0,inloop=0;
	for (i=0;i<document.form1.elements.length; i++)
		{
			if (
				//same Column and category
				document.form1.elements[i].name.indexOf('_'+col+'_')!=-1 && document.form1.elements[i].name.indexOf('_'+cat)!=-1
				) 
				{
					var myarray=document.form1.elements[i].name.split("_");
					//if this is a total (or subtotal) row, identify ID, and do not add to total
					if ((myarray[10] == 1) || (myarray[11] == 1))
						{
						if (myarray[11] == 1)
							subtotalElmID=i;
						else
							totalElmID=i;
						}
					else
						{
						// not a total row - add amount to appropriate total
						if (isInteger(formatNum1(document.form1.elements[i].value,9)))
							{
							//colsum+=Math.round(parseInt(stripCharsInBag(document.form1.elements[i].value,',')));
							if (myarray[9] == 0)
								colSubTotal+=formatNum1(document.form1.elements[i].value,9);
							colTotal+=formatNum1(document.form1.elements[i].value,9);
							inloop=1;
							}
						}
				}
		}
	<!---End loop--->
	
	<!--- Sum for Sub-Total --->
	if (subtotalElmID > 0)
		{
		if (inloop==1)
			{
			document.form1.elements[subtotalElmID].value=colSubTotal;
			formatNum1(document.form1.elements[subtotalElmID]);
			}
		else
			document.form1.elements[subtotalElmID].value='';
		}
		
	<!--- Sum for Total --->
	if (totalElmID > 0)
		{
		if (inloop==1)
			{
			document.form1.elements[totalElmID].value=colTotal;
			formatNum1(document.form1.elements[totalElmID]);
			}
		else
			document.form1.elements[totalElmID].value='';
		}
}

function calcol345(s) {
	var myarray=s.name.split("_");
	var col3=0,col4=0,col5=0,col3Status=0,col4Status=0,col5val=0,col5Str='';
	<!---
	myarray[0]=header
	myarray[1]=aapp_num
	myarray[2]=program_year
	myarray[3]=ccc_worksheet_id
	myarray[4]=column
	myarray[5]=buffer
	myarray[6]=cost_cat_id
	myarray[7]=default amount
	myarray[8]=cost_cat_code
	ex:rec_1604_2007_1_col1_catid_10_1_A
	--->
	//s.value=trim(s.value);
	//formatNum1(s,2,1,1,val_before);
	for (i=0;i<document.form1.elements.length; i++) {
		if (document.form1.elements[i].name.indexOf(myarray[0]+'_'+myarray[1]+'_'+myarray[2]+'_'+myarray[3]+'_col3_'+myarray[5]+'_'+myarray[6]+'_'+myarray[7]+'_'+myarray[8])!=-1) {
			col3 = i;
		}
		if (document.form1.elements[i].name.indexOf(myarray[0]+'_'+myarray[1]+'_'+myarray[2]+'_'+myarray[3]+'_col4_'+myarray[5]+'_'+myarray[6]+'_'+myarray[7]+'_'+myarray[8])!=-1) {
			col4 = i;
		}
		if (document.form1.elements[i].name.indexOf(myarray[0]+'_'+myarray[1]+'_'+myarray[2]+'_'+myarray[3]+'_col5_'+myarray[5]+'_'+myarray[6]+'_'+myarray[7]+'_'+myarray[8])!=-1) {
			col5 = i;
		}
	}
	checkNum(document.form1.elements[col3],4,getBFchange(),0);
	col3Status=getStatus();
	checkNum(document.form1.elements[col4],4,getBFchange(),0);
	col4Status=getStatus();
	
	if (trim(document.form1.elements[col3].value) != '' && col3Status == 1) {
		col5val+=formatNum1(document.form1.elements[col3].value,9);
		formatNum1(document.form1.elements[col3]);
	}
	if (trim(document.form1.elements[col4].value) != '' && col4Status == 1) {
		col5val+=formatNum1(document.form1.elements[col4].value,9);
		formatNum1(document.form1.elements[col4]);
	}
	if (trim(document.form1.elements[col3].value) == '' && trim(document.form1.elements[col4].value) == '') {
		document.form1.elements[col5].value = '';
	}
	else if (col3Status == 1 && col4Status == 1) {
		document.form1.elements[col5].value = col5val;
		formatNum1(document.form1.elements[col5]);
	}
	<!---Sum for colum3, 4, 5--->
	sumcal('col3',myarray[8]);
	sumcal('col4',myarray[8]);
	sumcal('col5',myarray[8]);
	<!---disable generate xls--->
	disable_gen_xls();
}

function setChecking(s) {
	for (var i=0; i < s.length; i++) {
		if (s[i].selected && s[i].value==-'1')
			s[0].selected = true;
	}
}

function validateForm (s) {
	if (getStatus()!=1) 
		return false;
	else	
		for (i=0;i<s.elements.length; i++) {
			//if (s.elements[i].name.indexOf('_col5_catid_0_1_A')!=-1) {
			if (s.elements[i].name.indexOf('_col5_catid_0_1_A_0_1_0')!=-1) {
				break;
			}
		}
		if (s.cboStatus.value==4 && s.elements[i].value=='') {
			alert('You must enter at least one Approved Budget Amount in the Center Ops section before saving this worksheet as Finalized');
			return false;
		}
		if (s.cboStatus.value==0) {
			return confirm("Resetting this worksheet will remove any data that you have previously saved. Are you sure you want to continue?");
		}
		return true;
}

function disable_gen_xls () {
	<cfif listfind(valuelist(rst.rs3.checked),1)>
	document.form1.dd.disabled=1;
	</cfif>
}

function new_window () {
	<cfoutput>
	window.open("#application.paths.reportdir#rpt_ccc_py_aapp_worksheet.cfm?aapp=#url.aapp#&py=#form.py_ccc#","newwondow","location=no,resizable=yes,scrollbars=yes,status=yes");
	</cfoutput>
}

function new_window_print () {
	<cfoutput>
	window.open("#application.paths.reportdir#rpt_ccc_py_aapp_bycenter.cfm?aapp=#url.aapp#&py=#form.py_ccc#","print","location=no,resizable=yes,scrollbars=yes,status=yes");
	</cfoutput>
}

function checkyear (s) {
	<cfoutput>
	var next_py_ccc=#evaluate(request.py_ccc+1)#;
	</cfoutput>
	if (s.form.btnSave)
		{
		if (s.value==next_py_ccc)
			s.form.btnSave.disabled=false;
		else
			s.form.btnSave.disabled=true;
		}
}
</script>				
<div class="ctrSubContent">
<cfoutput>
<h2>Program Year #form.py_ccc# Budget Worksheet</h2>
<cfif not rstStatus.recordcount and request.adminAccess>
	<div class="btnRight">
	<a href="#application.paths.admindir#fopbatch_ccc_#iif(url.fromPage eq "preview",2,1)#.cfm###url.aapp#">CCC Batch Process <cfif url.fromPage eq "preview">Preview<cfelse>Listing</cfif></a></div>
</cfif>
</cfoutput>
<!---Customize the message display after save--->
<cfif isDefined("variables.lstErrorMessages") and listLen(variables.lstErrorMessages) gt 0>
	<div class="errorList">
	<cfloop index="listItem" list="#variables.lstErrorMessages#" delimiters="~">
		<cfoutput><li>#listItem#</li></cfoutput>
	</cfloop>
	</div><br />
</cfif>
<cfif isDefined("url.save") and isDefined("url.reset")>
	<div class="confirmList">
	<cfoutput><li>Worksheet has been reset.</li></cfoutput>
	</div><br />
<cfelseif isDefined("url.save")>	
	<div class="confirmList">
	<cfoutput><li>Information saved successfully.</li></cfoutput>
	</div><br />
</cfif>

<cfoutput>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<form name="form1" method="post" action="aapp_worksheet_ccc.cfm?aapp=#url.aapp#" onsubmit="return validateForm(this);" >
	<tr>
		<td>
			Inflation allowance for federal personnel: #numberformat(evaluate((rst.rs3.fed_rate-1)*100),".00")#%<br />
			Inflation allowance for other expenses: #numberformat(evaluate((rst.rs3.omb_rate-1)*100),".00")#%<br />
			<cfif rst.rs3.prorate_factor neq 1> <!--- if prev PY, or next PY is leap year, show proration factor --->
				Proration factor for differences in Program Year length: #rst.rs3.prorate_factor#<br />
			</cfif>
			<!---
			Inflation allowance for vehicle expenses: #numberformat(evaluate((rst.rs3.omb_b3_rate-1)*100),".00")#%
			--->
		</td>
		<td align="right" valign="bottom">
			View worksheets in Program Year:
			<select onchange="checkyear(this);" name="py_ccc" tabindex="#request.nextTabindex#" <cfif request.statusid eq 0>disabled="disabled"</cfif>>
			<cfloop query="rst.rs1">
			<option value="#program_year#" <cfif form.py_ccc eq program_year>selected</cfif>>#program_year#</option>
			</cfloop>
			</select>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input type="hidden" name="aapp" value="#url.aapp#" />
			<cfif request.statusid eq 1>
			<input type="button" value="Go" name="action_go" onclick="this.form.submit();" tabindex="#request.nextTabindex#">
			</cfif>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
<tr>
	<th scope="col" width="*" valign="top">Cost Category</th>
	<th scope="col" width="14%" style="text-align:center" valign="top">PY #evaluate(form.py_ccc-1)# Baseline</th>
	<th scope="col" width="14%" style="text-align:center" valign="top">PY #form.py_ccc#<br />Target</th>
	<th scope="col" width="14%" style="text-align:center" valign="top">PY #form.py_ccc#<br />CCC Agency Proposal</th>
	<th scope="col" width="14%" style="text-align:center" valign="top">DOL<br />Adjustment</th>
	<th scope="col" width="14%" style="text-align:center" valign="top">PY #form.py_ccc#<br />Final Approved<br />Budget Amount</th>
</tr>
</cfoutput>	


<!---Group A--->
<cfoutput query="group_a">
<cfif not len(cost_cat_id)>
<tr>
	<td colspan="6" class="hrule"></td>
</tr>
</cfif>

<tr <cfif group_a.currentrow mod 2 and len(cost_cat_id)>class="AltRow"</cfif>>
	<td>
		<cfif not len(cost_cat_id)>
			<strong>#cost_cat_desc#</strong>
		<cfelse>
			#cost_cat_desc#
		</cfif>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col1_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif not base_edit or not listfind(valuelist(group_sum.cost_cat_id),cost_cat_id) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol12(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_py_base)>
			value="#numberformat(amount_py_base,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col2_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_py_inflated)>
			value="#numberformat(amount_py_inflated,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>	
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col3_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif not len(cost_cat_id) or (not next_py_edit) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol345(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_py_proposed)>
			value="#numberformat(amount_py_proposed,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col4_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif not len(cost_cat_id) or (not next_py_edit) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol345(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_dol_adjusted)>
			value="#numberformat(amount_dol_adjusted,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col5_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_final)>
			value="#numberformat(amount_final,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
</cfoutput>
<tr>
	<td>&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
</tr>
<cfoutput query="group_b">
<tr class="AltRow">
	<td>
		#cost_cat_desc#
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col1_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_py_base)>
			value="#numberformat(amount_py_base,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col2_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_py_inflated)>
			value="#numberformat(amount_py_inflated,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>	
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col3_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol345(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_py_proposed)>
			value="#numberformat(amount_py_proposed,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col4_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol345(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_dol_adjusted)>
			value="#numberformat(amount_dol_adjusted,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col5_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_final)>
			value="#numberformat(amount_final,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
</cfoutput>
<tr>
	<td>&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
</tr>
<cfoutput query="group_c1">
<tr class="AltRow">
	<td>
		#cost_cat_desc#
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col1_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" 
			<cfif not base_edit or not listfind(valuelist(group_sum.cost_cat_id),cost_cat_id) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol12(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_py_base)>
			value="#numberformat(amount_py_base,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col2_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_py_inflated)>
			value="#numberformat(amount_py_inflated,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>	
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col3_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif not len(cost_cat_id) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol345(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_py_proposed)>
			value="#numberformat(amount_py_proposed,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col4_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif not len(cost_cat_id) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol345(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_dol_adjusted)>
			value="#numberformat(amount_dol_adjusted,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col5_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_final)>
			value="#numberformat(amount_final,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
</cfoutput>
<tr>
	<td>&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
</tr>
<cfoutput query="group_c2">
<tr class="AltRow">
	<td>
		#cost_cat_desc#
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col1_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" 
			<cfif not base_edit or not listfind(valuelist(group_sum.cost_cat_id),cost_cat_id) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol12(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_py_base)>
			value="#numberformat(amount_py_base,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col2_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_py_inflated)>
			value="#numberformat(amount_py_inflated,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>	
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col3_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif not len(cost_cat_id) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol345(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_py_proposed)>
			value="#numberformat(amount_py_proposed,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col4_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif not len(cost_cat_id) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol345(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_dol_adjusted)>
			value="#numberformat(amount_dol_adjusted,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col5_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_final)>
			value="#numberformat(amount_final,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
</cfoutput>
<tr>
	<td>&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="right">&nbsp;</td>
</tr>
<cfoutput query="group_s">
<tr class="AltRow">
	<td>
		#cost_cat_desc#
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col1_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" 
			<cfif not base_edit or not listfind(valuelist(group_sum.cost_cat_id),cost_cat_id) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol12(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_py_base)>
			value="#numberformat(amount_py_base,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col2_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_py_inflated)>
			value="#numberformat(amount_py_inflated,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>	
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col3_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif not len(cost_cat_id) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol345(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_py_proposed)>
			value="#numberformat(amount_py_proposed,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col4_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12"
			<cfif not len(cost_cat_id) or request.statusid eq 0 or fstatus.ro>
			class="inputReadonly" readonly
			<cfelse>
			onchange="calcol345(this);" onfocus="setBFchange(this);"
			maxlength="10"
			</cfif>
			<cfif len(amount_dol_adjusted)>
			value="#numberformat(amount_dol_adjusted,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
	<td align="right">$
		<input name="rec_#aapp_num#_#program_year#_#ccc_wscc_id#_col5_catid_#iif(not len(cost_cat_id),0,cost_cat_id)#_#default_amount#_#cost_cat_code#_#pd_expense#_#base_subtotal#_#base_subtotal_nopd#" type="text" STYLE="text-align: right;" size="12" class="inputReadonly" readonly
			<cfif len(amount_final)>
			value="#numberformat(amount_final,",")#"
			</cfif>
			tabindex="#request.nextTabindex#"
		>  
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
</cfoutput>
<cfoutput>
<tr valign="top">
	<td>Comments</td>
	<td colspan="5">
		<textarea id="idComments" name="txtComments" tabindex="#request.nextTabIndex#" cols="85" rows="4" 
		onKeyDown="textCounter(this, 4000);" onKeyUp="textCounter(this, 4000);"
		<cfif request.statusid eq 0 or fstatus.ro>readonly</cfif>>#rst.rs3.ccc_comment#</textarea>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
	</td>
</tr>
<tr>
	<td colspan="6" class="hrule"></td>
	</tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="tblContent">
<cfif form.py_ccc lt evaluate(request.py_ccc+1)>
	<tr>
		<td align="center">
			<div class="buttons" style="text-align:center">
			<input type="button" value="Print" tabindex="#request.nextTabindex#" onclick="new_window_print(); "/>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</div>
		</td>	
	</tr>
<cfelse>
<tr>
	<td width="33%">
		<div class="buttons" style="text-align:left">
		Status:
		<select name="cboStatus" onchange="setChecking(this);" tabindex="#request.nextTabindex#" <cfif request.statusid eq 0>disabled="disabled"</cfif>>
			<cfloop query="rst.rs3">
			<option value="#worksheet_status_id#" <cfif checked> selected="selected"</cfif>>#worksheet_status_desc#</option>
			</cfloop>
			<option value="-1">===================</option>
			<option value="0">Reset (delete existing data)</option>
		</select>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</div>
	</td>
	<td width="*">
		<div class="buttons">
		<input type="button" value="Print" tabindex="#request.nextTabindex#" onclick="new_window_print(); "/>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<cfif listfind(valuelist(rst.rs3.checked),1)>
			<input name="dd" type="button" value="Generate XLS" tabindex="#request.nextTabindex#" onclick="new_window();"/>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfif>
		</div>
	</td>
	<td width="33%">
		<div class="buttons">
		<cfif request.statusid eq 1>
			<input name="btnSave" type="submit" value="Save" tabindex="#request.nextTabindex#"/>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input name="btnClear" type="button" value="Reset" tabindex="#request.nextTabindex#" onClick="window.location.href=window.location.href" >
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</cfif>
		</div>
	</td>
</tr>
</cfif>
</cfoutput>
</table>
</form>
</div>


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />