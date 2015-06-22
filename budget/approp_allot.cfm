<!--- approp_allot.cfm --->
<cfset request.pageName="SplanAppropAllot">
<cfset request.htmlTitleDetail = "Job Corps Budget Functions">
<cfset request.pageTitleDisplay = "Budget Appropriation / Allotment">

<cfset variables.nextTabIndex = 1>

<cfoutput>
<cfif actionMode EQ "Init">
	<cfset strucAppropAllot = application.oapprop_allot.f_getAppropAllot( arg_py: "#session.selectedPY#", arg_UserID: "#session.userid#")>
<cfelseif actionMode EQ "anotherPY">
	<cfset strucAppropAllot = application.oapprop_allot.f_getAppropAllot( arg_py: "#session.selectedPY#", arg_UserID: "#session.userid#")>
</cfif>

<!---
TEST (do not delete):
<cfdump var="#strucAppropAllot.spr_getListOfPY#">
<cfdump var="#strucAppropAllot.spr_getAppropriation#">
<cfdump var="#strucAppropAllot.spr_getAllotment#">
<cfdump var="#strucAppropAllot.spr_getDateNCFMSloaded#">
<cfabort>
--->
<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">
<cfinclude template="#application.paths.includes#jsGraphics.cfm">

<script language="javascript">
// GENERIC FUNCTIONS:
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
var v_CtrlName  = "";
var v_CtrlID    = "";
var v_CtrlType  = "";
var v_CtrlValue = "";
var v_CtrlText  = "";
var v_CtrlAlt   = "";
var v_CtrlSize  = 0;

//var objRegExp_onlyNumeric = /^\s*(\+)?\d+\s*$/;// Only positive number
var objRegExp_onlyNumeric = /^(\d+\.?\d{0,9}|\.\d{1,9})$/;
//-----------------------------------------------------------------------------
function of_getCtrlProperties(arg_CtrlName){with(self.document.frmPage)
{
	  v_CtrlName = arg_CtrlName;

      v_CtrlID   = $("##"+v_CtrlName).attr("id");
	  v_CtrlType = $("##"+v_CtrlName).prop("type");
      v_CtrlAlt  = eval(v_CtrlName+".alt");
      v_CtrlSize = eval(v_CtrlName+".size");

      if (v_CtrlType == "select-one")
      {
		 v_CtrlValue = $("##"+v_CtrlName).val();
		 v_CtrlText  = $("##"+v_CtrlName+" option:selected").text();
	  }
      else if (v_CtrlType == "text" || v_CtrlType == "hidden")
      {
		 v_CtrlValue = $("##"+v_CtrlName).val(); //alert(v_CtrlValue)
      }
}}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function of_selectRecord(arg_CtrlName, arg_Value){with(self.document.frmPage)
{
    var v_IsMatched = "NO";
    //
    for (var i=0; i<eval(arg_CtrlName+".options.length"); i++)
    {
        if (eval(arg_CtrlName+".options["+i+"].value") == arg_Value)
        {
            //
            v_IsMatched = "YES";
            //
            eval(arg_CtrlName+".options["+i+"].selected=true");
            //
            break;
        }
    }
    //
    of_getCtrlProperties(arg_CtrlName);
    //
    if (v_IsMatched == "NO")
    {
        alert("Searched value of "+v_CtrlText+" ("+v_CtrlValue+") in "+v_CtrlAlt+" could not be found."+
              "\nPlease record indicated value and report to the help desk\n"+
              "about the problem.");
    }
}}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function of_Submit(argSubmitString){with (self.document.frmPage)
{
	action = argSubmitString;
	submit();
}}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function of_Trim(s) {//***
  s = s.replace(/(^\s*)|(\s*$)/gi,"");
  s = s.replace(/[ ]{2,}/gi," ");
  s = s.replace(/\n /,"\n");
  return s;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function of_setSingleValue(arg_CtrlName, arg_Value, arg_Text, arg_ZeroLength_YesNo, arg_Pos){with(self.document.frmPage)
{
    //TEST:
    //if ( arg_CtrlName==""){alert(arg_CtrlName+"  "+arg_Value+"  "+arg_Text+"  "+arg_ZeroLength_YesNo+"  "+arg_Pos)}
    //
///////////////////////////////////////////////////////////////////////////////
//
//  arg_CtrlName         - Control Name;
//  arg_Value            - Value (for "select-one" and "text")
//  arg_Text             - Text  (for "select-one")
//  arg_ZeroLength_YesNo - To set the length of the <options> to "0" (YES / NO)
//  arg_Pos              - Position in <options> (for "select-one")
//
///////////////////////////////////////////////////////////////////////////////
	var v_CtrlType = $("##"+arg_CtrlName).attr("type");

    switch (v_CtrlType)
    {
        //
        case "select-one":
            //
            if (arg_ZeroLength_YesNo == "YES")
            {
                eval(arg_CtrlName+".options.length = 0");
            }
            //
            optionX = new Option;
            optionX.value = arg_Value;
            //optionX.text  = "("+arg_Value+")  "+arg_Text;
            optionX.text  = arg_Text;
            eval(arg_CtrlName+".options["+arg_Pos+"] = optionX");
            //
        break;
        //

        case "text":
            //eval(arg_CtrlName+".value = "+arg_Value);
			$(function()
			{
				$("##"+arg_CtrlName).val(arg_Value.replace(/^\'|\'$/g, ''));
			});
        break;
		//
		case "hidden":
            //eval(arg_CtrlName+".value = "+arg_Value);
			$(function()
			{
				$("##"+arg_CtrlName).val(arg_Value.replace(/^\'|\'$/g, ''));
			});
        break;
		//
		case "textarea":
	    	//eval(arg_CtrlName+".value = "+arg_Value);
			$(function()
			{
				$("##"+arg_CtrlName).val(arg_Value.replace(/^\'|\'$/g, ''));
			});
	  	break;
    }
}}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function of_outPut(arg_WhereOutput, arg_WhatOutput){with(self.document.frmPage)
{
    //TEST:
	//alert(arg_WhereOutput+"  "+ arg_WhatOutput)
    document.getElementById(arg_WhereOutput).innerHTML = arg_WhatOutput;
}}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function of_LPad(arg_StrToSize, arg_PadLength, arg_PadChar)
{
// Arguments:
// StrToSize - String to be Padded
// PadLength -Length of the string after padding
// PadChar - Character to be Padded if the String is length is lesser then PadLength

     var v_PaddedString=arg_StrToSize.toString();
     for(i=arg_StrToSize.length+1; i<=arg_PadLength; i++)
     {
         v_PaddedString=arg_PadChar+v_PaddedString;
     }
     return v_PaddedString;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function of_RPad(arg_StrToSize, arg_Max_Str_Length, arg_PadChar)
{//alert(arg_StrToSize.length+"  "+arg_Max_Str_Length+"  "+arg_PadChar)
// Arguments:
// StrToSize - String to be Padded
// PadLength -Length of the string after padding
// PadChar - Character to be Padded if the String is length is lesser then PadLength

     var v_StrLength = parseInt(arg_Max_Str_Length);
     var v_PaddedString=arg_StrToSize.toString();

     for(i=0; i< parseInt(v_StrLength) - parseInt(arg_StrToSize.length); i++)
     {
         v_PaddedString=v_PaddedString+arg_PadChar;
     }

     return v_PaddedString;

}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function f_RemoveCommas(arg_CtrlValue)
{
	var v_RtnVal = arg_CtrlValue;
	var v_IsCommaPresent = v_RtnVal.indexOf(",");

	if (v_IsCommaPresent >= 0)
	{
		v_RtnVal = v_RtnVal.replace(/\,/g,'');
	}

	return v_RtnVal;
}
//---------------------------------------------------------------------

function f_AddCommas(arg_CtrlValue)
{//alert(arg_CtrlValue)
	var v_RtnVal = arg_CtrlValue;
	var v_IsCommaPresent = v_RtnVal.indexOf(",");

	if (v_IsCommaPresent < 0)// Adding commas - Ex: 123456789 becomes 123,456,789
	{
		v_RtnVal = v_RtnVal.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
	}

	return v_RtnVal;
}
//---------------------------------------------------------------------

function f_Options(idSubMenu, user_ID) {

///*
	// user_ID allows you to get to the right preferences

	var idArray = [ 'getExcelOutput'];
	// alert (' in openOneSplanmenu with ' + idSubMenu );
	var SHTML = '';
	var sStyle = '';
	var selector, selectorTemp;
	// selects the drop-down menu, not the options button
	var selector = '##' + idSubMenu;
	var nTop, nLeft, nRight, $Source, $Target, nTargetWidth, i;
	// cannot use a global here.  Make sure this is consistent with jfas.less
	var hdrBgHeight = 57;
	// determined empirically
	var nOptionButtonTop = hdrBgHeight + 137;
	var nDetailxAdjustment = -2;
	var nXAdjustment;
	var nYAdjustment;
	var sSubMenuPosition;
	var budgetSubheaderLeftWidth;
	var sBorderString = 'border-top:0;border-right:1px solid white;border-bottom:1px solid white;border-left:1px solid white;';

	//alert('selector is ' + selector);
	//alert('$(selector).length) ' + $(selector).length);
	if ($(selector).length){
		// the submenu is in the document
		if ($(selector).css("visibility") == "visible") {
			// alert('$(selector).css("visibility") ' + $(selector).css("visibility"));
			// remove the open TopMessage (that is, the dropdown, which has class="Topmessage"
			$(selector).remove();
		}
		else {
			$(selector).css("visibility", "visible")
		}

	} else {
		// close any abandoned subMenus
		for (i = 0; i < idArray.length; i += 1) {
			selectorTemp = '##' + idArray[i];
			if(selector != selectorTemp && $(selectorTemp).length) {
				$(selectorTemp).remove();
			}
		}
		nXAdjustment = nDetailxAdjustment;
		nYAdjustment = 2;
		// use absolute, not fixed, to let a submenu scroll off the page
		sSubMenuPosition = 'absolute';

		nTop	= 1 * cssToNumber('.PriNavDiv', 'height') + 1 * nYAdjustment + 1 * nOptionButtonTop;

		// build and append a div

		// BUDGET MAIN SCREEN - Current Spend Plan (splan_main.cfm)
		if (idSubMenu == 'getExcelOutput' ) {

			// this displays a list of links

			nTargetWidth	= 220;
			nHeight = 80;
			// base this on the position of ##btnOptions
			$Source	= $('##btnOptions');
			nSourceWidth =  cssToNumber($Source, 'width')
			// "Right" is horizontal position in from the right side.
			nRight	= ($(window).width() - ($Source.offset().left + $Source.outerWidth()));
			// this the the target left position for the dropdown.
			// small adjustment to make the drop-down under the button, considering the border
			nLeft	= 1 * $(window).width() - 1 * nRight - (1 * nSourceWidth) - 1 ;
			sStyle	= sBorderString+'top:' + nTop + 'px;margin-left:' + nLeft + 'px;height:' + nHeight + 'px;position:' + sSubMenuPosition;
			// this is a div added to the document, not relative to some other div
			
			SHTML = '<div id="'+idSubMenu+'" class="TopMessage BudgetOptions TopMarker" style="' + sStyle + '" >'
				+ '<ul>'
					+ '<li onclick="f_onClick(\'linkFormattedExcelReport\');"><a href="##"  title="Formatted Excel Report">Generate Report</a></li>'
					+ '<li onclick="f_onClick(\'linkRawApprop\');"><a href="##" title="Raw Appropriation Data Output">Appropr. Data</a></li>'
					+ '<li onclick="f_onClick(\'linkRawAllot\');"><a href="##" title="Raw Allotment Data Output">Allotment Data</a></li>'
				+ '<ul>'
			+ '</div>';
			$(document.body).append(SHTML);
		}

	}
	return;
}



//---------------------------------------------------------------------
</script>
<div class="ctrSubContent">
<!---<div id="divPageTitleDisplay">#request.pageTitleDisplay#</div>--->
<form name="frmPage" id="frmPage" method="post" >
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="contentTbl">
	<tr>
    	<td><div id="divPageTitleDisplay">#request.pageTitleDisplay#</div></td>
        <td align="right">
            <cfset btnOptionstyle = "border:normal 0px !important; height:25px; border-top: 0px solid black !important;border-right: 1px solid black !important;">
            <button type="button" id="btnOptions" style="#btnOptionstyle#" title="Links to Reports" onclick="f_Options('getExcelOutput', '#session.userID#');">
                &nbsp;&nbsp;Options <span class="caret"></span>&nbsp;&nbsp;
            </button>
            &nbsp;&nbsp;&nbsp;&nbsp;
        </td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="contentTbl">
	<tr>
        <td >
            <table border="0" width="100%" cellspacing="0" cellpadding="0" >
            	<tr>
                	<td align="left" width="40%"><div id="divSaveMsg"></div></td>

               		<td align="right">
<!---                    	<cfset btnOptionstyle = "border:normal 0px !important; height:25px; border-top: 0px solid black !important;border-right: 1px solid black !important;">
                        <button type="button" id="btnOptions" style="#btnOptionstyle#" title="Links to Reports" onclick="f_Options('getExcelOutput', '#session.userID#');">
                        	&nbsp;&nbsp;Options <span class="caret"></span>&nbsp;&nbsp;
                        </button>
--->
                        &nbsp;&nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <tr>
                	<td>
                        <select name="sel_ListOfPY" id="sel_ListOfPY"
                        		tabindex="#variables.nextTabIndex#"
                                onfocus="f_selOnFocus(this.name);">  
                            <cfloop query="strucAppropAllot.spr_getListOfPY" startrow="1" endrow="#strucAppropAllot.spr_getListOfPY.RecordCount#">
                                <option value="#PY_LIST#">#PY_LIST#</option>
                            </cfloop>
                        </select>
                        <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                        <input type="button" name="btnGo" id="btnGo" value="Go"  tabindex="#variables.nextTabIndex#" />
                        <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                    
                    </td>
                    <td><div id="divLoadMsgNCFMS">#strucAppropAllot.spr_getDateNCFMSloaded.NCFMS_LOAD_MSG#</div></td>
                </tr>
            </table>
        </td>
  </tr>
  <tr>
    <td>
    		<table width="100%" border="0" cellpadding="0" cellspacing="0">
            	<cfloop query="strucAppropAllot.spr_getAppropriation" startrow="1" endrow="#strucAppropAllot.spr_getAppropriation.RecordCount#">
                <cfset variables.Appr_Fund_Cat = #appr_fund_cat#>

<!--- spr_getAppropriation column list: APPROP_ID, appr_fund_cat, appr_fund_cat_desc, appr_py, appr_amount, appr_amount_ncfms --->
<!--- APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION --->
                    <tr>
                        <th scope="col" style="text-align:center; color:##FFF">#appr_fund_cat_desc#</th>
                        <th scope="col" style="text-align:center; color:##FFF">Q1</th>
                        <th scope="col" style="text-align:center; color:##FFF">Q2</th>
                        <th scope="col" style="text-align:center; color:##FFF">Q3</th>
                        <th scope="col" style="text-align:center; color:##FFF">Q4</th>
                        <th scope="col" style="text-align:center; color:##FFF">TOTAL</th>
                    </tr>
                    <tr>
                        <td><div id="divApprTitl_#APPROP_ID#_#appr_fund_cat#_0_#appr_py#_TL" >Appropriation</div></td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td>
                        <!---txtApprAmnt_#APPROP_ID#_#appr_fund_cat#_0_#appr_py#_QA<br />--->
                        	<div id="divApprAmnt_#APPROP_ID#_#appr_fund_cat#_0_#appr_py#_QA">
                        		<!---txtApprAmnt_#APPROP_ID#_#appr_fund_cat#_0_#appr_py#_QA--->
                                <input align="right" type="text" name="txtApprAmnt_#APPROP_ID#_#appr_fund_cat#_0_#appr_py#_QA"
                                                                   id="txtApprAmnt_#APPROP_ID#_#appr_fund_cat#_0_#appr_py#_QA"
                                                             tabindex="#variables.nextTabIndex#"
                                                                value="#appr_AMOUNT#"/>
                                <input type="hidden"
                                	     id="hdnApprAmnt_#APPROP_ID#_#appr_fund_cat#_0_#appr_py#_QA"
                                       name="hdnApprAmnt_#APPROP_ID#_#appr_fund_cat#_0_#appr_py#_QA"
                                      value="#APPROP_ID#" />
                                <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                            </div>
                            <!---divNCFMS_#APPROP_ID#_#appr_fund_cat#_0_#appr_py#_QA<br />--->
                            <div id="divNCFMS_#APPROP_ID#_#appr_fund_cat#_0_#appr_py#_QA">
                            	<cfif #appr_amount_ncfms# EQ "0">&nbsp;<cfelse>#appr_amount_ncfms#</cfif>
                            </div>
                        </td>
                    </tr>
<!--- APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION APPROPRIATION --->
                    <tr><td colspan="6" class="hrule"></td></tr>

<!--- ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT  --->
					<cfloop query="strucAppropAllot.spr_getAllotment" startrow="1" endrow="#strucAppropAllot.spr_getAllotment.RecordCount#">

                    <!--- spr_getAllotment column list: ALLOT_ID, FUND_CAT, FUNDING_OFFICE_NUM, FUNDING_OFFICE_DESC, PY,
														Q1_AMOUNT, 		 Q2_AMOUNT,  	  Q3_AMOUNT,       Q4_AMOUNT,       QT_AMOUNT,
														Q1_AMOUNT_NCFMS, Q2_AMOUNT_NCFMS, Q3_AMOUNT_NCFMS, Q4_AMOUNT_NCFMS, QT_AMOUNT_NCFMS --->

						<cfif variables.Appr_Fund_Cat EQ #FUND_CAT#>
                    	<tr>
                        	<td width="22%">
                           <!--- divAlltTitl_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_TL--->
                                <div id="divAlltTitl_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_TL">
                                	#FUNDING_OFFICE_DESC#
                                </div>
                            </td>

                        	<td width="13%">
                            	<cfif #FUNDING_OFFICE_NUM# NEQ 20>
                                    <div id="divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1">
                                    	<!---divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1<br />--->
                                        <!---txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1<br />--->
                                        <input type="text" size="15" maxlength="15"
                                               id=  "txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1"
                                               name="txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1"
                                               tabindex="#variables.nextTabIndex#"
                                               value="#Q1_AMOUNT#"/>
                                        <input type="hidden"
                                        	   id=  "hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1"
                                               name="hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1"
                                               value="#ALLOT_ID#" />
                                        <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                                    </div>
                                <cfelseif #FUNDING_OFFICE_NUM# EQ 20>
                                	<!---divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1--->
                                    <div id="divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1">#Q1_AMOUNT#</div>
                                    <!---hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1<br />--->
                                    <input type="hidden"
                                      	   id=  "hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1"
                                           name="hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1"
                                           value="#ALLOT_ID#" />

                                </cfif>
                                <div id="divNCFMS_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q1" >
                                	<cfif #Q1_AMOUNT_NCFMS# EQ "0">&nbsp;<cfelse>#Q1_AMOUNT_NCFMS#</cfif>
                                </div>
                            </td>

                            <td width="13%">
                            	<cfif #FUNDING_OFFICE_NUM# NEQ 20>
                                	<!---divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2--->
                                    <div id="divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2">
                                        <!---txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2<br />--->
                                        <input type="text"
                                               id=  "txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2"
                                               name="txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2"
                                               tabindex="#variables.nextTabIndex#"
                                               value="#Q2_AMOUNT#"  />
                                        <input type="hidden"
                                        	   id=  "hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2"
                                               name="hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2"
                                               value="#ALLOT_ID#" />
                                        <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                                    </div>
                                <cfelseif #FUNDING_OFFICE_NUM# EQ 20>
                                	<!---divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2--->
                                	<div id="divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2">#Q2_AMOUNT#</div>
                                    <!---hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2<br />--->
                                    <input type="hidden"
                                      	   id=  "hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2"
                                           name="hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2"
                                           value="#ALLOT_ID#" />
                                </cfif>
                               <!--- divNCFMS_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2--->
                                <div id="divNCFMS_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q2">
                                    <cfif #Q2_AMOUNT_NCFMS# EQ "0">&nbsp;<cfelse>#Q2_AMOUNT_NCFMS#</cfif>
                                </div>
                            </td>

                            <td width="13%">
                            	<cfif #FUNDING_OFFICE_NUM# NEQ 20>
                                    <!---divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3--->
                                    <div id="divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3">
                                        <!---txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3<br />--->
                                        <input type="text"
                                               id=  "txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3"
                                               name="txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3"
                                               tabindex="#variables.nextTabIndex#"
                                               value="#Q3_AMOUNT#"  />
                                        <input type="hidden"
                                        	   id=  "hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3"
                                               name="hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3"
                                               value="#ALLOT_ID#" />
                                        <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                                    </div>
                                <cfelseif #FUNDING_OFFICE_NUM# EQ 20>
                                	<!---divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3--->
                                    <div id="divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3">#Q3_AMOUNT#</div>
                                    <!--- hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3<br />--->
                                    <input type="hidden"
                                      	   id=  "hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3"
                                           name="hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3"
                                           value="#ALLOT_ID#" />
                                </cfif>
                               <!--- divNCFMS_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3--->
                                <div id="divNCFMS_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q3">
                                    <cfif #Q3_AMOUNT_NCFMS# EQ "0">&nbsp;<cfelse>#Q3_AMOUNT_NCFMS#</cfif>
                                </div>
                            </td>

                            <td width="13%">
                            	<cfif #FUNDING_OFFICE_NUM# NEQ 20>
                                	<!---divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4--->
                                    <div id="divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4">
                                        <!---txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4<br />--->
                                        <input type="text"
                                               id=  "txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4"
                                               name="txtAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4"
                                               tabindex="#variables.nextTabIndex#"
                                               value="#Q4_AMOUNT#"  />
                                        <input type="hidden"
                                        	   id=  "hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4"
                                               name="hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4"
                                               value="#ALLOT_ID#" />
                                        <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                                    </div>
                                <cfelseif #FUNDING_OFFICE_NUM# EQ 20>
                                	<!---divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4--->
                                    <div id="divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4">#Q4_AMOUNT#</div>
                                    <!---hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4<br />--->
                                    <input type="hidden"
                                      	   id=  "hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4"
                                           name="hdnAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4"
                                           value="#ALLOT_ID#" />
                                </cfif>
                                <!---divNCFMS_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4--->
                                <div id="divNCFMS_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_Q4">
                                   <cfif #Q4_AMOUNT_NCFMS# EQ "0">&nbsp;<cfelse>#Q4_AMOUNT_NCFMS#</cfif>
                                </div>
                            </td>

                            <td width="13%">
                            	<!---divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_QT--->
                                <div id="divAlltAmnt_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_QT">#QT_AMOUNT#</div>
                                <!---divNCFMS_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_QT--->
                                <div id="divNCFMS_#FUND_CAT#_#FUNDING_OFFICE_NUM#_#PY#_QT">
                                    <cfif #QT_AMOUNT_NCFMS# EQ "0">&nbsp;<cfelse>#QT_AMOUNT_NCFMS#</cfif>
                                </div>
                            </td>
                            <cfif #strucAppropAllot.spr_getAllotment.currentRow# EQ 1
									OR
								  #strucAppropAllot.spr_getAllotment.currentRow# EQ 2
								  	OR
								  #strucAppropAllot.spr_getAllotment.currentRow# EQ 15
									OR
								  #strucAppropAllot.spr_getAllotment.currentRow# EQ 16>
                                  <tr><td colspan="6" class="hrule"></td></tr>
							</cfif>

                        </tr>
                        </cfif> <!--- end of if variables.Fund_Cat EQ #FUND_CAT# --->
                    </cfloop> <!--- end of loop spr_getAllotment --->
<!--- ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT ALLOTMENT  --->

                </cfloop> <!--- end of loop spr_getAppropriation --->
            </table>
    </td>
  </tr>
  <tr>
    <td align="right">
				<!---<div class="buttons">--->
                <!---<input type="button" name="btnExcel" id="btnExcel" value="Create Excel" tabindex="#variables.nextTabIndex#" />
				<cfset variables.nextTabIndex = variables.nextTabIndex + 1>--->
                
				<input type="button" name="btnSave" id="btnSave" value="Save" tabindex="#variables.nextTabIndex#" />
				<cfset variables.nextTabIndex = variables.nextTabIndex + 1>
				<input type="button" name="btnClear" id="btnClear" value="Reset" tabindex="#variables.nextTabIndex#"/>
                <!---</div>--->
    </td>
  </tr>
</table>


</form>
</div> <!--- end of "ctrSubContent" --->
<cfinclude template="#application.paths.includes#footer.cfm">
<script language="javascript">
var v_ValOnFocus = 0, 		// Var captures the value in the txt control when control receives focus
	v_ValOnBlur = 0, 		// Var captures the value in the txt control when control looses focus
	v_delta_FocusBlur = parseInt(v_ValOnFocus) - parseInt(v_ValOnBlur);	// Var registers the difference of the values.

var v_UserID = "#session.userid#";
var v_ApprUpdSQL = "APPR:",
	v_AlltUpdSQL = "ALLT:",
	v_urlPY,
	v_createArgsForSave;

var v_txtSize = 15,
	v_txtMaxLength = 15;

var vFontSize = "12px";
var vFontSizeNCFMS = "11px";

var vFontFamily = "Arial, Helvetica, sans-serif";


//--------------------------------------------------------------------
$("document").ready(function() {

	$("##divPageTitleDisplay").css("font-size","1.1em")
							 .css("font-weight","bold")
							 .css("font-family",vFontFamily)
							 ;

	$("div[id^=divApprTitl]").css("font-family",vFontFamily)
							 .css("font-size",vFontSize)
							 .css("font-weight","bold");

	$("div[id^=divApprAmnt]").attr("align","right");

	$("div[id^=divAlltTitl]").css("font-family",vFontFamily)
							 .css("font-size",vFontSize);

	$("div[id^=divAlltTitl_OPS_71],"+
	  "div[id^=divAlltTitl_CRA_71]").css("font-weight","bold");

	$("div[id^=divAlltAmnt]").css("font-family",vFontFamily)
							 .css("font-size",vFontSize)
							 .attr("align","right");

	$("div[id^=divNCFMS]").css("font-family",vFontFamily)
						  .css("font-size",vFontSizeNCFMS)
						  .css("color","##069")
						  .attr("align","right");

	$("##divLoadMsgNCFMS").css("font-family",vFontFamily)
						.css("font-size",vFontSizeNCFMS)
						.css("color","##069")
						.attr("align","right");

	$("[id$='_QT'],[id$='_QA']").not("div[id^=divNCFMS]")
								.css("font-weight","bold");

	$("input[id^=txtApprAmnt]").css("font-weight","bold");

	$("input[id^=txtApprAmnt],"+
	  "input[id^=txtAlltAmnt]").css("font-family",vFontFamily)
							   .css("font-size",vFontSize)
							   .css("text-align","right")
							   .attr("align","right")
							   .attr("size",v_txtSize)
  			  				   .attr("maxlength",v_txtMaxLength);

	//-------------
	$("input[id^=txtApprAmnt], input[id^=txtAlltAmnt]").change(function(){formatNum(this,2,1);});
	//-------------
	$("input[id^=txtApprAmnt_],input[id^=txtAlltAmnt_]").focus(function(){
		f_onFocus(this.name);
	});
	//-------------
	$("input[id^=txtApprAmnt_],input[id^=txtAlltAmnt_]").blur(function(){
		f_onBlur(this.name);
	});
	//-------------
	$("input[id^=btn]").click(function(){
		f_onClick(this.name);
	});
	//-------------
});
//---------------------------------------------------------------------
//---------------------------------------------------------------------
with(self.document.frmPage){
//=====================================================================
//---------------------------------------------------------------------

function f_onFocus(arg_CtrlName)//{with(self.document.frmPage)
{
	f_msgShowHide("CHANGES_NO");

	v_ValOnFocus = $( "##"+arg_CtrlName ).val();
	v_ValOnFocus = f_RemoveCommas(v_ValOnFocus);
}//} // end of f_onFocus
//---------------------------------------------------------------------

function f_onBlur(arg_CtrlName)
{
	v_ValOnBlur = $( "##"+arg_CtrlName ).val();
	v_ValOnBlur = f_RemoveCommas(v_ValOnBlur);
	if (v_delta_FocusBlur == 0)
	{
		v_delta_FocusBlur = parseInt(v_ValOnFocus) - parseInt(v_ValOnBlur);
	}
	//TEST: alert(v_ValOnFocus+"  || "+v_ValOnBlur+"   "+v_delta_FocusBlur);
	f_reCalculateTotal(arg_CtrlName);
} //end of f_onBlur
//----------------------------------------------------------------------
//----------------------------------------------------------------------
function f_reCalculateTotal(arg_CtrlName)
{
	var v_CtrlName = arg_CtrlName;
	var v_CtrlValue = $( "##"+arg_CtrlName ).val();
		v_CtrlValue = f_RemoveCommas(v_CtrlValue);

	var v_Pos, v_PartCtrlName, v_CtrlPrefix, v_FundCat, v_FundOfficeNum, v_PY, v_Q;

	var v_Val, v_Allot, v_Sum = 0, v_NatOffice;

	//f_extractCtrlNameComponents(arg_CtrlName);

	//txtApprAmnt_"appr_fund_cat"_0_"appr_py"_QA
	//txtAlltAmnt_ FUND_CAT _ FUNDING_OFFICE_NUM _ PY _ Q4"
														// arg_CtrlName = 'txtAlltAmnt_OPS_2_2014_Q3'
	v_PartCtrlName = arg_CtrlName;						// v_PartCtrlName = 'txtAlltAmnt_OPS_2_2014_Q3'
	v_Pos = v_PartCtrlName.indexOf("_");				// v_Pos = 11
	v_CtrlPrefix = v_PartCtrlName.substr(0, v_Pos);		// v_CtrlPrefix = 'txtAlltAmnt'
	v_PartCtrlName = v_PartCtrlName.substr(v_Pos+1);	// v_PartCtrlName = 'OPS_2_2014_Q3'
	v_Pos = v_PartCtrlName.indexOf("_");				// v_Pos = 3
	v_FundCat = v_PartCtrlName.substr(0, v_Pos);		// v_FundCat = 'OPS'
	v_PartCtrlName = v_PartCtrlName.substr(v_Pos+1);	// v_PartCtrlName = '2_2014_Q3'
	v_Pos = v_PartCtrlName.indexOf("_");				// v_Pos = 1
	v_FundOfficeNum = v_PartCtrlName.substr(0, v_Pos);	// v_FundOfficeNum = '2'
	v_PartCtrlName = v_PartCtrlName.substr(v_Pos+1);	// v_PartCtrlName = '2014_Q3'
	v_Pos = v_PartCtrlName.indexOf("_");				// v_Pos = 4
	v_PY = v_PartCtrlName.substr(0, v_Pos);				// v_PY = '2014'
	v_Q = v_PartCtrlName.substr(v_Pos+1);				// v_Q = 'Q3'
	// TEST: alert(arg_CtrlName+"\n"+v_CtrlPrefix+"\n"+v_FundCat+"\n"+v_FundOfficeNum+"\n"+v_PY  +"\n"+v_Q);


// Calculate NATIONAL OFFICE (from top to buttom):
	// The following loop iterates through the list of controls which ids
	// start with [id^="+v_CtrlPrefix+"_"+v_FundCat+"_] and
	// end on [id$="+v_Q+"]
	// The first record is Allotment.
	//Amount for "National Office" =  Allotment - SUM (Centers) of the selected FUND_CAT.
	$( "input[id^="+v_CtrlPrefix+"_"+v_FundCat+"_][id$="+v_Q+"]" ).each(function( index ) {

			v_Val = $( this ).val();
			v_Val = parseInt(f_RemoveCommas(v_Val));

			if (index == 0) {v_Allot = v_Val;}
			else { v_Sum = parseInt(v_Sum) + parseInt(v_Val);	}
			//alert(v_Val)
	});
	v_NatOffice = parseInt(v_Allot) - parseInt(v_Sum);
	v_NatOffice = f_AddCommas(v_NatOffice.toString());
	$("##divAlltAmnt_"+v_FundCat+"_"+"20"+"_"+v_PY+"_"+v_Q).html(v_NatOffice);

// Calculate TOTAL (from left to right):
	v_Sum = 0;
	$("input[id^="+v_CtrlPrefix+"_"+v_FundCat+"_"+v_FundOfficeNum+"_"+v_PY+"_"+ "]").each(function(index){
			v_Val = $( "##"+this.id ).val();
			v_Val = parseInt(f_RemoveCommas(v_Val));
			v_Sum = parseInt(v_Sum) + parseInt(v_Val);
	});
	v_Sum = f_AddCommas(v_Sum.toString());
	$("##divAlltAmnt_"+v_FundCat+"_"+v_FundOfficeNum+"_"+v_PY+"_QT").html(v_Sum);

// Calculate TOTAL for NATIONAL OFFICE (from left to right):
	v_Sum = 0;
	// Search for divs which DO NOT end on "QT":
	//divAlltAmnt_CRA_20_2014_Q1
	$("div[id^=divAlltAmnt_"+v_FundCat+"_"+"20"+"_"+v_PY+"_"+"]"+":not([id$='_QT'])"  ).each(function(index){
		v_Val = $(this).text();
		v_Val = parseInt(f_RemoveCommas(v_Val));
		v_Sum = parseInt(v_Sum) + parseInt(v_Val);
	});
	v_Sum = f_AddCommas(v_Sum.toString());
	$("##divAlltAmnt_"+v_FundCat+"_"+"20"+"_"+v_PY+"_QT").html(v_Sum);
}

//----------------------------------------------------------------------
//----------------------------------------------------------------------
function f_selOnFocus(arg_CtrlName)
{
	f_msgShowHide("CHANGES_NO");
	//of_getCtrlProperties("sel_ListOfPY");
	//v_createArgsForSave = f_createArgsForSave();
	//TEST: alert("f_selOnFocus   "+v_createArgsForSave+"\n\n"+v_delta_FocusBlur+"\n\n"+v_ValOnFocus+"  "+v_ValOnBlur);
}
//---------------------------------------------------------------------
//---------------------------------------------------------------------

function f_onClick(arg_CtrlName)//{with(self.document.frmPage)
{
	if (arg_CtrlName == "btnGo")
	{
		f_msgShowHide("CHANGES_NO");
		of_getCtrlProperties("sel_ListOfPY");
		//
		if (v_delta_FocusBlur != 0)  // This validation indicates that some changes had been made.
		{							 // Warning of loses is needed:
			if ( !confirm("There are changes in the form that have not been saved.\n"+
						 "Click 'OK' to continue and lose your changes.\n"+
						 "Click 'Cancel' to remain on this page.") )
			{
				
				of_selectRecord("sel_ListOfPY", v_CtrlValue)
			}
			else
			{
				//of_getCtrlProperties("sel_ListOfPY");
				//of_selectRecord("sel_ListOfPY", v_CtrlValue)
				of_Submit("approp_allot_controller.cfm?actionMode=anotherPY&selectedPY="+v_CtrlValue);
			}
		}
		else
		{
			//of_getCtrlProperties("sel_ListOfPY");
			//of_selectRecord("sel_ListOfPY", v_CtrlValue)
			of_Submit("approp_allot_controller.cfm?actionMode=anotherPY&selectedPY="+v_CtrlValue);
		}
	}
	else if (arg_CtrlName == "btnSave")
	{
		v_createArgsForSave = f_createArgsForSave();
		// All arguments are passing to the stored procedure:
		of_Submit(v_createArgsForSave);
		//
	}
	else if (arg_CtrlName == "btnClear")
	{
		f_msgShowHide("CHANGES_NO");
		of_getCtrlProperties("sel_ListOfPY");
		// after calling this function v_CtrlValue has a value of the selected year.
		of_Submit("approp_allot_controller.cfm?actionMode=anotherPY&selectedPY="+v_CtrlValue);
		
	}
//	else if (arg_CtrlName == "btnExcel")
//	{
//		f_msgShowHide("CHANGES_NO");
//		of_Submit("approp_allot_controller.cfm?actionMode=getAppropAllotExcel&selectedPY="+$("##sel_ListOfPY").val());
//	}
	else if ( arg_CtrlName == "linkFormattedExcelReport")
	{
		f_msgShowHide("CHANGES_NO");
		of_Submit("approp_allot_controller.cfm?actionMode=getFormattedExcelReport&selectedPY="+$("##sel_ListOfPY").val());
	}
	else if ( arg_CtrlName == "linkRawApprop")
	{
		f_msgShowHide("CHANGES_NO");
		of_Submit("approp_allot_controller.cfm?actionMode=getRawApprop&selectedPY="+$("##sel_ListOfPY").val());
	}
	else if ( arg_CtrlName == "linkRawAllot")
	{
		f_msgShowHide("CHANGES_NO");
		of_Submit("approp_allot_controller.cfm?actionMode=getRawAllot&selectedPY="+$("##sel_ListOfPY").val());
	}
}//} // end of f_onClick()
//---------------------------------------------------------------------

function f_createArgsForSave()
{
		// Setting up initial values:
		var v_ApprUpdSQL = "APPR:",
			v_AlltUpdSQL = "ALLT:",
			//---------------------
			v_txtCtrlName = "",
			v_txtCtrlValue = "",
			v_divCtrlName = "",
			v_divCtrlValue = "",
			v_hdnCtrlName = "",
			v_hdnCtrlValue = "",
			v_Quarter = "",
			//---------------------
			v_ApprUpdSQL = "",
			v_AlltUpdSQL = "",
			//---------------------
			v_RtnVal = "";

// I. APPROPRIATION:	// ALLT:1_1_1000000^1_2_2000000^1_3_2000000^1_4_2000000^
			$( "input[id^=txtApprAmnt_]" ).each(function( index ) {					// Looping through Appropriation text controls

				v_txtCtrlName = this.id;											// Getting text control name/id
				v_txtCtrlValue = f_RemoveCommas($("##"+v_txtCtrlName).val());		// Getting value (Appropriation Amount) of the control and removing commas
				//
				v_hdnCtrlName = "hdn"+v_txtCtrlName.substr(3);						// Getting hidden control name
				v_hdnCtrlValue = $("##"+v_hdnCtrlName).val();						// Getting value (Appropriation ID) of the control
				//
				v_ApprUpdSQL += v_hdnCtrlValue.toString()+'_'+v_txtCtrlValue.toString()+'^'; // Building a string to be passed to the stored procedure for update records
			}); 																	// End of Appropriation loop
			v_ApprUpdSQL = "APPR:"+v_ApprUpdSQL; //Ex: "APPR:1_123^2_987^"			// Attaching prefix to identify an Appropriation update string

// II.a. ALLOTMENT for Centers, National Office is not included:	//   1- ALLOT_ID; 1/2/3/4 - Q1/Q2/Q3/Q4; 100000/2000000/.... - Quarterly amounts

			$("input[id^=txtAlltAmnt_]").each(function(index){
				v_txtCtrlName = this.id;
				v_txtCtrlValue = f_RemoveCommas($("##"+v_txtCtrlName).val());
				//
				v_hdnCtrlName = "hdn"+v_txtCtrlName.substr(3);
				v_hdnCtrlValue = f_RemoveCommas($("##"+v_hdnCtrlName).val());
				//
				v_Quarter = v_hdnCtrlName.substr(v_hdnCtrlName.length-1);
				//
				if (v_hdnCtrlValue != 0)
				{
					v_AlltUpdSQL += v_hdnCtrlValue.toString()+'_'+v_Quarter+'_'+v_txtCtrlValue.toString()+'^';
				}
			});


//II.b. ALLOTMENT just National Office:

			$("div[id^=divAlltAmnt_OPS_20_]:not([id$='_QT']), div[id^=divAlltAmnt_CRA_20_]:not([id$='_QT'])").each(function(index){
				v_divCtrlName = this.id;
				v_divCtrlValue = f_RemoveCommas($(this).text());
				//
				v_hdnCtrlName = "hdn"+v_divCtrlName.substr(3);
				v_hdnCtrlValue = f_RemoveCommas($("##"+v_hdnCtrlName).val());
				//
				v_Quarter = v_hdnCtrlName.substr(v_hdnCtrlName.length-1);
				//
				v_AlltUpdSQL += v_hdnCtrlValue.toString()+'_'+v_Quarter+'_'+v_divCtrlValue.toString()+'^';
			});

			v_AlltUpdSQL = "ALLT:"+v_AlltUpdSQL;
			// Getting the value of selected PY:
			of_getCtrlProperties("sel_ListOfPY");
			v_urlPY = v_CtrlValue;
//
			v_RtnVal = "approp_allot_controller.cfm?actionMode=saveApprAllt&urlPY="+v_urlPY+"&urlUserID="+v_UserID+"&urlApprUpdSQL="+v_ApprUpdSQL+"&urlAlltUpdSQL="+v_AlltUpdSQL;

		return v_RtnVal;
}


//---------------------------------------------------------------------

function f_selectPY(){with(self.document.frmPage)
{
	for (var py=0; py<sel_ListOfPY.length; py++)
	{
		if (sel_ListOfPY.options[py].value == "#session.selectedPY#")
		{
			of_selectRecord("sel_ListOfPY", sel_ListOfPY.options[py].value);
		}
	}
}}
f_selectPY();
//---------------------------------------------------------------------
//---------------------------------------------------------------------

function f_msgShowHide(arg_Action){with(self.document.forms["frmPage"])
{//alert("f_msgShowHide   "+arg_Action)


	var v_Msg = "&nbsp;";
	var v_ClassName = "confirmList";
	var v_TrueFalse = true;

	if (arg_Action == "CHANGES_YES")//
	{
		//<!---v_Msg = "Your changes have been saved. Return to the <a href='<cfoutput>#application.paths.admin#</cfoutput>'>Admin Section</a>."--->
		v_Msg = "Your changes have been saved."
		v_TrueFalse = true;

	}
	else if (arg_Action == "CHANGES_NO")//
	{
		v_Msg = "&nbsp;";
		v_TrueFalse = false;
	}

	$("##divSaveMsg").toggleClass(v_ClassName, v_TrueFalse);
	$("##divSaveMsg").html(v_Msg);

}}
f_msgShowHide("<cfoutput>#session.anyChanges#</cfoutput>");
//---------------------------------------------------------------------
//---------------------------------------------------------------------
}// end of with() declared after <script>
</script>
</cfoutput>

