<cfsilent>
<!---
page: aapp_contractinput.cfm

description: display / update data for new contract input

revisions:
2006-12-19	yjeng	Appy Future New and Award Package for input page
2006-12-22	yjeng	If setup page did not check bi fees, then successor will not pro rate for bi fees
2006-12-26	yjeng	Change the style for radio button
2006-12-27	yjeng	Remove cancel button
2007-01-10	yjeng	Change Reset button to reload page
2007-01-17	yjeng	If AAPP is from migration, can not save
2007-01-18	yjeng	table aapp_migration add column award_pacakge if 1, received award package
2007-07-10	yjeng	Fixed Defect ID 219. Remove "," before calculation
--->
<cfset request.pageID = "210" />
<cfparam name="variables.lstErrorMessages" default="" />

<cfif isDefined("form.btnSave")> <!--- form submitted --->

	<!--- save AAPP Contract Input --->
	<cfinvoke component="#application.paths.components#aapp_budget" method="saveContractInput" formData="#form#" returnvariable="stcContractInputSaveResults" />
	<cfif stcContractInputSaveResults.success>
		<!--- if save was successful, then redirect back to this page in edit mode --->
		<cflocation url="#cgi.SCRIPT_NAME#?aapp=#stcContractInputSaveResults.aappNum#&save=1" addtoken="no" />
	<cfelse>
		<!--- otherwise set list of error messages --->
		<cfabort>
		<cfset variables.lstErrorMessages = stcContractInputSaveResults.errorMessages />
	</cfif>
<cfelse>
		<!--- retrieve data from database --->
		<cfinvoke component="#application.paths.components#aapp_budget" method="getContractInput" aapp="#request.aapp#" returnvariable="rstNewContractInput" />
		<cfquery name="dates" dbtype="query">
			select	distinct contract_year, date_start, date_end
			from	rstNewContractInput
		</cfquery>
		<cfquery name="sumID" dbtype="query">
			select	distinct con_sort_order as sum_con_sort_order, contract_budget_item_id as sum_contract_budget_item_id
			from	rstNewContractInput
			where	sumup=1
		</cfquery>
		<cfquery name="FNreadOnly" dbtype="query">
			select	aapp_num, contract_year, con_sort_order, contract_budget_item_id
			from	rstNewContractInput
			where	editable=1
			and		future_new_edit=0
		</cfquery>
		<cfquery name="bi_fees" datasource="#request.dsn#">
			select	contract_type_code
			from	aapp_bi_fees
			where	aapp_num=#request.aapp#
		</cfquery>
		<cfquery name="migrate" datasource="#request.dsn#">
			select	aapp_num
			from	aapp_migration
			where	aapp_num=#request.aapp#
			and		award_package=1
		</cfquery>
</cfif>
</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<script language="javascript1.1" type="text/javascript">
<cfoutput>
var rate=#rstNewContractInput.ratio#;
var chk_rdo_budget_input_type='#rstNewContractInput.budget_input_type#';
var bi_fees='#valuelist(bi_fees.contract_type_code)#';
</cfoutput>
function groupSum(eleName,target_id) {
	var sum=0, j=0;
	for (i=0;i<document.form1.elements.length; i++) {
		if (document.form1.elements[i].name.indexOf(eleName)!=-1) {
			if (document.form1.elements[i].name!=eleName+target_id) {
				document.form1.elements[i].value=trim(document.form1.elements[i].value);
				if (!isInteger(stripCharsInBag(document.form1.elements[i].value,','))) {
					alert("You must enter a positive whole number.");
					document.form1.elements[i].value=0;
					document.form1.elements[i].focus();
				}
				sum+=parseInt(stripCharsInBag(document.form1.elements[i].value,','));
				formatNum(document.form1.elements[i]);
			}
			else {
				j=i;
			}
		}
	}
	document.form1.elements[j].value=sum;
	formatNum(document.form1.elements[j]);
}

function formatForm (s) {
	s.value=trim(s.value);
	if (!isInteger(stripCharsInBag(s.value,','))) {
		alert("You must enter a positive whole number.");
		s.value=0;
		s.focus();
	}
	formatNum(s);
}

function validateForm (s) {
	for (i=0;i<s.elements.length; i++) {
		if (s.elements[i].name.indexOf('rec_')!=-1) {
			if (!isInteger(stripCharsInBag(s.elements[i].value,','))) {
				//alert("You must enter a positive whole number.");
				s.elements[i].value=0;
				s.elements[i].focus();
				return false;
			}
		}
	}	
	return true;
}
function clearForm () {
	var target='rec_';
	for (i=0;i<document.form1.elements.length; i++) {
		if (document.form1.elements[i].name.indexOf(target)!=-1) {
			document.form1.elements[i].value=0;
		}
	}
}

function readonlyField(s) {
	clearForm();
	for (i=0;i<s.rdo_budget_input_type.length; i++) {
		if (s.rdo_budget_input_type[i].checked) {
			chk_rdo_budget_input_type=s.rdo_budget_input_type[i].value;
		}
	}
	for (i=0;i<s.elements.length; i++) {
		if (s.elements[i].id.indexOf("_FN")!=-1) {
			if (chk_rdo_budget_input_type=='F') {
				s.elements[i].readOnly=true;
				s.elements[i].className='inputReadonly';
			}
			else {
				s.elements[i].readOnly=false;
				s.elements[i].className='inputEditable';
			}
		}
	}
}

function proRate (s,CTC) {
	var target=s.name.substring(0,s.name.lastIndexOf('_'))+'_'+String(parseInt(s.name.substring(s.name.lastIndexOf('_')+1,s.name.length))+1);
	for (i=0;i<document.form1.elements.length; i++) {
		if (document.form1.elements[i].name.indexOf(target)!=-1 && chk_rdo_budget_input_type=='F' && bi_fees.indexOf(CTC)!=-1) {
			document.form1.elements[i].value=Math.round(parseInt(stripCharsInBag(s.value,','))*rate);
			break;
		}
	}
}
</script>

<div class="ctrSubContent">
<cfoutput>
<form name="form1" action="#cgi.SCRIPT_NAME#?aapp=#request.aapp#" method="post" onsubmit="return validateForm(this);">
<cfif rstNewContractInput.current_contract_year le 1>
<h2>New Contract Input</h2>
<cfinclude template="#application.paths.includes#error_list.cfm">
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	<tr>
		<td width="200">&nbsp;
			
		</td>
		<td>
			<input name="rdo_budget_input_type" id="budget_input_type_f" type="radio" value="F" tabindex="#request.nextTabIndex#" onclick="readonlyField(this.form);" <cfif rstNewContractInput.budget_input_type eq "F">checked</cfif> />
			<label for="budget_input_type_f" >Special Contract Pricing</label>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input name="rdo_budget_input_type" id="budget_input_type_a" type="radio" value="A" tabindex="#request.nextTabIndex#" onclick="readonlyField(this.form);" <cfif rstNewContractInput.budget_input_type eq "A">checked</cfif> />
			<label for="budget_input_type_a" >Award Package</label>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
		</td>
	</tr>	
</table>
<cfelse>
<h2>New Contract Input</h2>
<input name="rdo_budget_input_type" type="hidden" value="#rstNewContractInput.budget_input_type#" />
</cfif>
</cfoutput>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataTblCol">
	<tr>
		<th scope="col">&nbsp;</th>
		<cfoutput query="dates">
		<th scope="col"><strong>Year #contract_year#</strong><br/>#date_start#-<br/>#date_end#</th>
		</cfoutput>
	</tr>
	<cfoutput query="rstNewContractInput" group="con_sort_order">
	<tr>
		<cfset sum_target_id=0>
		<cfset the_con_sort_order=con_sort_order>
		<cfloop query="sumID">
			<cfif the_con_sort_order eq sum_con_sort_order>
				<cfset sum_target_id=sum_contract_budget_item_id>
				<cfbreak>
			</cfif>
		</cfloop>
		<td scope="row"><strong>#contract_type_desc_short#</strong></td>
		<cfloop query="dates">
		<td <cfif contract_year mod 2 eq 0> class="AltCol"</cfif>></td>
		</cfloop>
	</tr>
	<cfoutput group="bud_sort_order">
	<tr>
		<td scope="row">#budget_item_desc#</td>
		<cfoutput group="contract_year">
		<td <cfif contract_year mod 2 eq 0> class="AltCol"</cfif>>
		<label for="id#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#_#iif(future_new_edit eq 0,de("FN"),de("NOCHG"))#" class="hiddenLabel">New Contract Input, Year #contract_year#, Contract Type #contract_type_desc_short#, Item #budget_item_desc#</label>
		$<input name="rec_#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#" id="id#aapp_num#_#contract_year#_#con_sort_order#_#contract_budget_item_id#_#iif(future_new_edit eq 0,de("FN"),de("NOCHG"))#" type="text" value="#numberformat(amount,",")#" tabindex="#request.nextTabIndex#" <cfif not editable or (future_new_edit eq 0 and budget_input_type eq "F")> readonly="Yes" class="inputReadonly"</cfif> onClick="this.select();" onChange="proRate(this,'#contract_type_code#'); <cfif sum_target_id>groupSum('rec_#aapp_num#_#contract_year#_#con_sort_order#_','#sum_target_id#');<cfelse>formatForm(this);</cfif>"/></td>
		<cfset request.nextTabIndex = request.nextTabIndex + 1>
		<cfset lastrow=currentrow>
		</cfoutput>
	</tr>
	</cfoutput>
	<cfif lastrow neq rstNewContractInput.recordcount>
	<tr>
		<td colspan="8" class="hrule"></td>
	</tr>
	</cfif>
	</cfoutput>
</table>
<cfif rstNewContractInput.current_contract_year le 1>
<div class="buttons">
	<input name="btnSave" type="submit" value="Save" <cfif migrate.recordcount>disabled</cfif> />
	<input name="btnClear" type="button" value="Reset" onClick="window.location.href=window.location.href" >
</div>
</cfif>
</div>
</form>
<!--- if validation errors exist, display them --->

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">