<cfsilent>
<!---
page: aapp_newpy_budget.cfm

description: Screen for Next PY Budget

revisions:
2007-04-02	yjeng	When save budget, add a cffunction saveNewPYBudget
2007-04-06	yjeng	Also display  agreement type code 'LE', 'SP', 'BA', 'IA'
2007-04-10	yjeng	Add B2 for edit
2007-04-12	yjeng	Add B3 for edit in agreement type code 'LE', 'SP', 'BA', 'IA'
2007-05-22	yjeng	Fix bug for null value
2007-06-05	mstein	Added separate handling of Misc ('LE', 'SP', 'BA', 'IA') PY setting in request
2007-06-06	mstein	Fixed defect.. this form was still enabled for expired LE, SP, IA, BA... now it is not.
					Also removed "Batch Process Preview" link if inactive
2007-11-06	rroser	Fix id lables for 508 compliance					
--->
<cfset request.pageID = "140" />
<cfparam name="variables.lstErrorMessages" default="" />

<!--- set PY, based on agreement type --->
<cfif listfindnocase("DC,GR",request.agreementtypecode)>
	<cfset form_py = request.py>
<cfelse>
	<cfset form_py = request.py_other>
</cfif>
		
<!---Post--->
<cfif isDefined("form.action")>
	<cftry>	
		<cfloop collection="#form#" item="key">  
			<cfif findnocase("amount_",key) and listgetat(key,2,"_") eq 1>
				<cfinvoke component="#application.paths.components#fop_batch" method="saveNewPYBudget" aapp="#listgetat(key,3,"_")#" cost_cat_id="#listgetat(key,4,"_")#" amount="#iif(len(form[key]),rereplace(form[key],"[,]","","all"),0)#" />
			</cfif>
		</cfloop>
		<cfcatch type="database">
			<cfset variables.lstErrorMessages="Fail Save to Database.">
		</cfcatch>
	</cftry>
	<cfif len(variables.lstErrorMessages) eq 0>
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&save=1" addtoken="no" />
	</cfif>	
</cfif>
<!---Query--->
<cfinvoke component="#application.paths.components#fop_batch" method="getNewPYBudget" aapp="#url.aapp#" returnvariable="rstNPB" />
<cfquery name="sumNPB" dbtype="query">
	select	sum(amount) as amount, sum(cur_amount) as cur_amount, sum(cur_cum_amount) cur_cum_amount
	from	rstNPB
</cfquery>
<cfquery name="editable" datasource="#request.dsn#">
	select	
			<cfif request.statusid>
				decode(sign(utility.fun_cnt_date(#url.aapp#,0,'E')-utility.fun_get_py_date(#evaluate(form_py+1)#,'S')),-1,0,1)
			<cfelse>
				0
			</cfif> as edit,
			nvl(contract.fun_getcurrntcontract_year(#url.aapp#),0) as current_cy
	from	dual
</cfquery>
<cfset s_editable=1>
<cfif listfindnocase(valuelist(rstNPB.cost_cat_code),"S")>
	<cfinvoke component="#application.paths.components#aapp_costprofile" method="getEstCostProfileTotal" aapp="#url.aapp#" contract_type_code="S" contract_year="#editable.current_cy#" returnvariable="rstEstCostProfileTotal" />
	<cfif len(rstEstCostProfileTotal.funds) and rstEstCostProfileTotal.funds neq 0>
		<cfset s_editable=0>
	</cfif>
</cfif>
<!---Check for batch process status--->
<cfinvoke component="#application.paths.components#fop_batch" method="getBatchProcessStatus" py="#evaluate(form_py+1)#" adj_type="OTHER" returnvariable="rstStatus"/>

</cfsilent>

<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">
<script language="javascript1.1" type="text/javascript">
function groupSum(eleName,tgteleName) {
	
	var sum=0, j=0;
	for (i=0;i<document.form1.elements.length; i++) {
		if (document.form1.elements[i].name.indexOf(eleName)!=-1) {
			checkNum(document.form1.elements[i],4,getBFchange());
			if (getStatus()==1) {
				if (document.form1.elements[i].value.length!=0) {
					sum+=formatNum1(document.form1.elements[i].value,9);
				}
				//parseInt(stripCharsInBag(document.form1.elements[i].value,','));
			}
			else {
				break;
				return;
			}
			formatNum1(document.form1.elements[i]);
		}
		else if (document.form1.elements[i].name==tgteleName) {
			j=i;
		}
	}
	document.form1.elements[j].value=sum;
	formatNum1(document.form1.elements[j]);
}

function validateForm (s) {
	if (getStatus()!=1) 
		return false;
	else	
		return true;
}

</script>
<div class="ctrSubContent">
	<cfoutput>
	<!---
	<h2>New PY Budget: PY #evaluate(request.py+1)#
	<cfif listfindnocase("LE,SP,BA,IA",request.agreementtypecode) and not rstStatus.recordcount>
		<div style="float: right; margin-bottom: 10px; text-align: right;"><a href="#application.paths.admindir#fopbatch_other_2.cfm###url.aapp#">Batch Process Preview</a></div>
	</cfif>
	</h2>
	--->
	<h2>New PY Budget: PY #evaluate(form_py+1)#</h2>
	<cfif listfindnocase("LE,SP,BA,IA",request.agreementtypecode) and not rstStatus.recordcount and editable.edit and request.adminAccess>
		<div class="btnRight"><a href="#application.paths.admindir#fopbatch_other_2.cfm###url.aapp#">Batch Process Preview</a></div>
	</cfif>
	
	<cfinclude template="#application.paths.includes#error_list.cfm">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<form name="form1" action="aapp_newpy_budget.cfm?aapp=#url.aapp#" method="post" onSubmit="return validateForm(this);">
	<tr>
		<th width="5%"></th>
		<th scope="col" width="25%" nowrap>Cost Category</th>
		<th scope="col" width="20%">PY #evaluate(form_py+1)# Amount</th>
		<th scope="col" width="20%">PY #form_py# Amount</th>
		<th scope="col" width="20%">PY #form_py# Cumulative</th>
	</tr>
	</cfoutput>
	<cfoutput query="rstNPB">
	<tr>
		<td></td>
		<td>
			<cfif cost_cat_code eq "B4">
				<a href="#application.paths.reportdir#rpt_vst_worksheet.cfm?aapp=#aapp_num#&type=0&py=#evaluate(form_py+1)#" target="_blank">
					#cost_cat_code# - #cost_cat_desc#
				</a>
			<cfelse>
				#cost_cat_code# - #cost_cat_desc#
			</cfif>
		</td>
		<td align="center">
			<label for="id#aapp_num#_#cost_cat_code#_1" class="hiddenLabel">New Program Year Budget PY:#evaluate(form_py+1)# #cost_cat_desc#</label>
			<cfif cost_cat_code eq "S">
				$<input type="text" name="amount_#s_editable#_#aapp_num#_#cost_cat_id#" value="#numberformat(amount,",")#" size="15" maxlength="11" style="text-align:right" id="id#aapp_num#_#cost_cat_code#_1" tabindex="#request.nextTabIndex#" 
					<cfif not editable.edit or not s_editable>readonly class="inputReadonly"<cfelse> onChange="groupSum('amount_','sumamount');" onfocus="setBFchange(this);"</cfif>
				  />
			<cfelse>
				<!---Non CC, DC and GR--->
				<cfif listfindnocase("LE,SP,BA,IA",request.agreementtypecode)>
				$<input type="text" name="amount_#iif(not listfindnocase("B1,B2,B3,D",cost_cat_code),0,1)#_#aapp_num#_#cost_cat_id#" value="#numberformat(amount,",")#" size="15" maxlength="11" style="text-align:right" id="id#aapp_num#_#cost_cat_code#_1" tabindex="#request.nextTabIndex#" 
					<cfif not editable.edit or not listfindnocase("B1,B2,B3,D",cost_cat_code)>readonly class="inputReadonly"<cfelse> onChange="groupSum('amount_','sumamount');" onfocus="setBFchange(this);"</cfif>
				  />
				<cfelse>
				$<input type="text" name="amount_#iif(not listfindnocase("B1,B2,D",cost_cat_code),0,1)#_#aapp_num#_#cost_cat_id#" value="#numberformat(amount,",")#" size="15" maxlength="11" style="text-align:right" id="id#aapp_num#_#cost_cat_code#_1" tabindex="#request.nextTabIndex#" 
					<cfif not editable.edit or not listfindnocase("B1,B2,D",cost_cat_code)>readonly class="inputReadonly"<cfelse> onChange="groupSum('amount_','sumamount');" onfocus="setBFchange(this);"</cfif>
				  />
				</cfif>
				
			</cfif>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>	
		</td>
		<td align="center">
			$<input type="text" name="txt" value="#numberformat(cur_amount,",")#" size="15" maxlength="11" readonly id="id#aapp_num#_#cost_cat_code#_2" tabindex="#request.nextTabIndex#"
				class="inputReadonly" style="text-align:right" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>	
		</td>
		<td align="center">
			$<input type="text" name="txt" value="#numberformat(cur_cum_amount,",")#" size="15" maxlength="11" readonly id="id#aapp_num#_#cost_cat_code#_3" tabindex="#request.nextTabIndex#"
				class="inputReadonly" style="text-align:right" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>	
		</td>
	</tr>
	</cfoutput>
	<tr>
		<td></td>
		<td class="hrule" colspan="4"></td>
	</tr>
	<cfoutput>
	<tr>
		<td></td>
		<td><strong>Total</strong></td>
		<td align="center">
			$<input type="text" name="sumamount" value="#numberformat(sumNPB.amount,",")#" size="15" maxlength="11" readonly
				class="inputReadonly" style="text-align:right" />
		</td>
		<td align="center">
			$<input type="text" name="txt" value="#numberformat(sumNPB.cur_amount,",")#" size="15" maxlength="11" readonly
				class="inputReadonly" style="text-align:right" />
		</td>
		<td align="center">
			$<input type="text" name="txt" value="#numberformat(sumNPB.cur_cum_amount,",")#" size="15" maxlength="11" readonly
				class="inputReadonly" style="text-align:right" />
		</td>
	</tr>
	</cfoutput>
	</table>
		<cfif editable.edit>
		<div class="buttons">
		<input name="action" type="submit" value="Save" />
		<input name="btnClear" type="button" value="Reset" onClick="window.location.href=window.location.href" >
		</div>
		</cfif>
	</form>
</div>



<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

