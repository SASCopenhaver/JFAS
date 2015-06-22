<!---
page: splan_future.cfm

description: user can select subsets of Spend Plan Transactions to view

--->

<cfset request.pageName="SplanFuture">
<cfset request.htmlTitleDetail = "Job Corps Fund Allocation System">

<cfset variables.nextTabIndex = 1>
<cfoutput>


<cfset spr_getCurrentPY = application.ospend_plan.f_getCurrentPY()>


<!--- TEST:
<cfdump var="#spr_getCurrentPY#"><cfabort>--->
<cfset variables.v_Current_PY = #spr_getCurrentPY.CURRENT_PY#>
<cfset variables.v_Next_Year_PY = #spr_getCurrentPY.NEXT_YEAR_PY#>

<cfset request.pageTitleDisplay = "PY #variables.v_Next_Year_PY# Operations Spend Plan Worksheet">

<cfset strucSplanFutureAmnt = application.ospend_plan.f_getAmountsFutureSPlan(argUserID: "#session.userid#")>

<!--- TEST:
<cfdump var="#spr_getCurrentPY#">
<cfdump var="#strucSplanFutureAmnt.spr_getAmount_CTR_FED_HQC#">
<cfdump var="#strucSplanFutureAmnt.spr_getAmount_GT#">
<cfdump var="#strucSplanFutureAmnt.spr_getAmount_APPRP#">
<cfdump var="#strucSplanFutureAmnt.spr_getAmount_BBR#">
<cfdump var="#strucSplanFutureAmnt.spr_getAmount_RES#">
<cfdump var="#strucSplanFutureAmnt.spr_getAmount_BAR#">
<cfdump var="#strucSplanFutureAmnt.spr_getTransClosed#">
<cfabort>--->

<!--- include main header file --->
<cfinclude template="#application.paths.includes#header.cfm">
<cfinclude template="#application.paths.includes#jsGraphics.cfm">

<script language="javascript">
// GENERIC FUNCTIONS:
var v_UserID = "#session.userid#";
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
/*
function f_onKeyUp(arg_CtrlName){with(self.document.forms["frmPage"]) 
{ 
	var v_Char = "";

	of_getCtrlProperties(arg_CtrlName);
	//alert("KeyUp  "+v_CtrlValue)
	for (var i=0; i<v_CtrlValue.length; i++)
	{
		v_Char = v_CtrlValue.substr(i,1);
		
		if ( 
				(objRegExp_onlyNumeric.test(v_Char) == false)
				||
		   		(objRegExp_onlyNumeric.test(v_Char) == true && v_Char == 0 && i == 0)
		   )
		{
			v_CtrlValue = v_CtrlValue.substr(0,i)+v_CtrlValue.substr(i+1, v_CtrlValue.length);
			eval(v_CtrlName+".value=\""+v_CtrlValue+"\"");
			eval(v_CtrlName+".focus();");
			alert("You must enter a valid, non-negative number that does not have leading \"0\".");
			break;
		}
	}
}}
*/
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function of_Submit(argSubmitString){with (self.document.frmPage)
{
	//alert("X    "+argSubmitString)
	action = argSubmitString;
	submit();
}}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
</script>

<div class="ctrSubContent">    
<cfset variables.v_TodayDate = #DateFormat(Now(),"mm/dd/yyyy")# >
<form name="frmPage" id="frmPage" method="post" >	
<!---<table border="0" cellspacing="0" cellpadding="0" class="contentTbl"><tr><td><div id="divPageTitleDisplay">#request.pageTitleDisplay#</div></td></tr></table>--->
<div id="divPageTitleDisplay">#request.pageTitleDisplay#</div>
   	<table width="100%" border="0" cellpadding="0" cellspacing="0"  class="contentTbl"  summary="Setting-up Next Year pend Plan">
    		<tr><td align="left" colspan="1" ><div id="divSaveMsg"></div></td><td colspan="5">&nbsp;</td></div></tr>
            <tr>
                <th scope="col" style="text-align:center; color:##FFF" width="30%">&nbsp;</th>
                <th scope="col" style="text-align:center; color:##FFF" width="20%">PY#variables.v_Current_PY# Spend Plan<br />(as of #variables.v_TodayDate#)</th>
                <th scope="col" style="text-align:center; color:##FFF" width="12%">PY#variables.v_Next_Year_PY# FOPs</th>
                <th scope="col" style="text-align:center; color:##FFF" width="12%">PY#variables.v_Next_Year_PY# Spend Plan</th>
                <th scope="col" style="text-align:center; color:##FFF" colspan="2" >Notes</th>
			</tr>
<!--- ......................... Beginning of strucSplanFutureAmnt.spr_getAmount_CTR_FED_HQC ................................. ---> 
<!---
            PATH , H_LEVEL,  SPLAN_CAT_ID, SPLAN_CAT_ID_ORG,  SPLAN_CAT_PARENT_ID, SPLAN_CAT_DESC, 
			NOTE_CURRENT_PY, NOTE_NEXT_YEAR_PY, SORT_ORDER, COST_CAT_ID, SPLAN_SECTION_CODE,
            CURRENT_PY, NEXT_YEAR_PY, AMOUNT_AS_OF_TODAY, AMOUNT_NEXT_YEAR_FOP, AMOUNT_NEXT_YEAR_PY
--->

            <cfloop query="strucSplanFutureAmnt.spr_getAmount_CTR_FED_HQC" startrow="1" endrow="#strucSplanFutureAmnt.spr_getAmount_CTR_FED_HQC.RecordCount#">

            <cfif #H_LEVEL# EQ 1>
            	<cfset variables.v_BgColor = "##CCCCCC">
                <tr><td colspan="6" class="hrule"></td></tr>
            <cfelseif #H_LEVEL# EQ 2>
                <cfset variables.v_BgColor = "##E6E6E6">
            <cfelse><!--- #H_LEVEL# EQ 3 --->
            	<cfset variables.v_BgColor = "">
            </cfif>

            <tr bgcolor="#variables.v_BgColor#">
            	<td valign="top">
                	<div id="divCatDescr_#H_LEVEL#_#SPLAN_CAT_ID#">
                		<cfif #H_LEVEL# EQ 1>
                        	#SPLAN_CAT_DESC#
                        <cfelseif #H_LEVEL# EQ 2>
                        	<cfloop index="loopIndex" from="1" to="5">&nbsp;</cfloop>
                            #SPLAN_CAT_DESC#
                        <cfelseif #H_LEVEL# EQ 3>
                        	<cfloop index="loopIndex" from="1" to="10">&nbsp;</cfloop>
                        	#SPLAN_CAT_DESC#
                        </cfif>
                    </div>
                </td>
            	<td valign="top">
                	<cfif #H_LEVEL# EQ "1" && #SPLAN_CAT_ID# EQ "3">
                    	<!--- Applies ONLY to NATIONAL HQ CONTRACTS --->
						<cfset variables.Display = 'style="display:none;"'>
                    <cfelse>
                    	<cfset variables.Display = ''>
                    </cfif>
                    <div id="divAmntTody_#H_LEVEL#_#SPLAN_CAT_ID#" #variables.Display# >#AMOUNT_AS_OF_TODAY#</div>
                </td>
                <td valign="top">
                	<div id="divAmntFOPPY_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_NEXT_YEAR_FOP#</div>
                </td>
                <td valign="top" >
					<cfif (#H_LEVEL# EQ 1 AND #SPLAN_CAT_ID# EQ #SPLAN_CAT_ID_ORG#)
							OR
						  (#H_LEVEL# EQ 2)>
                    	<div id="divSPNextPY_#H_LEVEL#_#PATH#">#AMOUNT_NEXT_YEAR_PY#</div>
                    <cfelse>
                    	<div id="divSPNextPY_#H_LEVEL#_#PATH#">
                                <!---txtSPNextPY_#H_LEVEL#_#PATH#--->
                                <input	type="text"
                                        name="txtSPNextPY_#H_LEVEL#_#PATH#" 
                                        id="txtSPNextPY_#H_LEVEL#_#PATH#" 
                                        alt="#SPLAN_CAT_ID#"
                                        tabindex="#variables.nextTabIndex#"
                                        value="#AMOUNT_NEXT_YEAR_PY#" />
                                <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                        </div>               
                    </cfif>
                </td>

		<cfif #NOTE_NEXT_YEAR_PY# EQ "">
            <cfset variables.StyleDisplayYES = "style='display:none;'">
            <cfset variables.StyleDisplayNOT = "">
            <cfset variables.StyleDisplayCLS = "style='display:none;'">
            <cfset variables.StyleDisplayTXA = "style='display:none;'">
        <cfelse>
            <cfset variables.StyleDisplayYES = "">
            <cfset variables.StyleDisplayNOT = "style='display:none;'">
            <cfset variables.StyleDisplayCLS = "style='display:none;'">
            <cfset variables.StyleDisplayTXA = "style='display:none;'">
        </cfif>                    

				<cfif (#H_LEVEL# EQ 1 AND #SPLAN_CAT_ID# NEQ #SPLAN_CAT_ID_ORG#) OR (#H_LEVEL# EQ 3)>
                <td width="5%" valign="top">
                        <!---<div id="divNoteImg_#H_LEVEL#_#PATH#">--->
                               	<img src="#application.paths.images#notesYES.png" 
                                	 name="btnNotesYES_#H_LEVEL#_#PATH#" 
                                     id="btnNotesYES_#H_LEVEL#_#PATH#" 
                                     width="23" height="23" border="0" 
                                     title="Notes exist" 
                                     alt="Click to edit notes"
                                     onclick="f_editNotes(this.name)"
                                     #variables.StyleDisplayYES#/>
                                <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                                
                       		    <img src="#application.paths.images#notesNOT.png" 
                                	 name="btnNotesNOT_#H_LEVEL#_#PATH#" 
                                     id="btnNotesNOT_#H_LEVEL#_#PATH#" 
                                     width="23" height="23" border="0" 
                                     title="Notes do not exist" 
                                     alt="Click to edit notes"
                                     onclick="f_editNotes(this.name)" 
                                     #variables.StyleDisplayNOT#/>
                                 <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                                 
                                 <img src="#application.paths.images#notesCLS.png" 
                                	 name="btnNotesCLS_#H_LEVEL#_#PATH#" 
                                     id="btnNotesCLS_#H_LEVEL#_#PATH#" 
                                     width="23" height="23" border="0" 
                                     title="Close notes" 
                                     alt="Click to close notes"
                                     onclick="f_editNotes(this.name)"
                                     #variables.StyleDisplayCLS#/>
                                 <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                         <!---</div>--->
                </td>
                <td valign="top" colspan="2">
                                <textarea name="txaNote_#H_LEVEL#_#PATH#" id="txaNote_#H_LEVEL#_#PATH#" 
                                          rows="3"
                                          cols="25" 
                                          maxlength="500"
                                          tabindex="#variables.nextTabIndex#"
                                          #variables.StyleDisplayTXA#>#NOTE_NEXT_YEAR_PY#</textarea>
                            	<cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                        <!---</div>--->
                    
                </td>
                <cfelse>
                <td colspan="2">&nbsp;</td>
                </cfif>
            </tr>
            </cfloop>
            
<!--- ......................... End of strucSplanFutureAmnt.spr_getAmount_CTR_FED_HQC .......................................... --->            

<!--- ......................... Beginning of GRAND TOTAL strucSplanFutureAmnt.spr_getAmount_GT     ............................. ---> 
<!--- PATH, H_LEVEL, SPLAN_CAT_ID,  SPLAN_CAT_ID_ORG, SPLAN_CAT_PARENT_ID, SPLAN_CAT_DESC, 
       NOTE_NEXT_YEAR_PY, SPLAN_SECTION_CODE, AMOUNT_NEXT_YEAR_FOP, AMOUNT_NEXT_YEAR_PY --->
             <cfloop query="strucSplanFutureAmnt.spr_getAmount_GT" startrow="1" endrow="#strucSplanFutureAmnt.spr_getAmount_GT.RecordCount#">
             <tr id="idTr_GT">
             	<td><div id="divCatDescr_#H_LEVEL#_#SPLAN_CAT_ID#">#SPLAN_CAT_DESC#</div></td>
                <td><div id="divAmntTody_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_AS_OF_TODAY#</div></td>
                <td><div id="divAmntFOPPY_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_NEXT_YEAR_FOP#</div></td>
                <td><div id="divSPNextPY_GT">#AMOUNT_NEXT_YEAR_PY#</div></td>
                <td colspan="2"><div id="">&nbsp;</div></td>
             </tr>
             </cfloop>
<!--- ......................... End of GRAND TOTAL strucSplanFutureAmnt.spr_getAmount_GT .......................................... --->

<!--- ......................... Beginning of APPROPRIATION strucSplanFutureAmnt.spr_getAmount_APPRP  .............................. --->
             <cfloop query="strucSplanFutureAmnt.spr_getAmount_APPRP" startrow="1" endrow="#strucSplanFutureAmnt.spr_getAmount_APPRP.RecordCount#">
             <tr id="idTr_APPRP">
             	<td><div id="divCatDescr_#H_LEVEL#_#SPLAN_CAT_ID#">#SPLAN_CAT_DESC#</div></td>
                <td><div id="divAmntTody_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_AS_OF_TODAY#</div></td>
                <td><div id="divAmntFOPPY_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_NEXT_YEAR_FOP#</div></td>
                <td><div id="divSPNextPY_APPRP">#AMOUNT_NEXT_YEAR_PY#</div></td>
                <td colspan="2"><div id="">&nbsp;</div></td>
             </tr>
             </cfloop>             
<!--- ......................... End of APPROPRIATION strucSplanFutureAmnt.spr_getAmount_APPRP .................................... --->
 
<!--- ......................... Beginning of BALANCE BEFORE RESERVE strucSplanFutureAmnt.spr_getAmount_BBR  ...................... --->
			 <cfloop query="strucSplanFutureAmnt.spr_getAmount_BBR" startrow="1" endrow="#strucSplanFutureAmnt.spr_getAmount_BBR.RecordCount#">
             <tr id="idTr_BBR">
             	<td><div id="divCatDescr_#H_LEVEL#_#SPLAN_CAT_ID#">#SPLAN_CAT_DESC#</div></td>
                <td><div id="divAmntTody_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_AS_OF_TODAY#</div></td>
                <td><div id="divAmntFOPPY_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_NEXT_YEAR_FOP#</div></td>
                <td><div id="divSPNextPY_BBR">#AMOUNT_NEXT_YEAR_PY#</div></td>
                <td colspan="2"><div id="">&nbsp;</div></td>
             </tr>
             </cfloop>             
<!--- ......................... End of BALANCE BEFORE RESERVE strucSplanFutureAmnt.spr_getAmount_BBR ............................ --->

<!--- ......................... Beginning of RESERVE strucSplanFutureAmnt.spr_getAmount_RES  .................................... --->             
             <cfloop query="strucSplanFutureAmnt.spr_getAmount_RES" startrow="1" endrow="#strucSplanFutureAmnt.spr_getAmount_RES.RecordCount#">
             <tr id="idTr_RES">
             	<td><div id="divCatDescr_#H_LEVEL#_#SPLAN_CAT_ID#">#SPLAN_CAT_DESC#</div></td>
                <td><div id="divAmntTody_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_AS_OF_TODAY#</div></td>
                <td><div id="divAmntFOPPY_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_NEXT_YEAR_FOP#</div></td>
                <td><div id="divSPNextPY_RES">#AMOUNT_NEXT_YEAR_PY#</div></td>
                <td colspan="2"><div id="">&nbsp;</div></td>
             </tr>
             </cfloop>  
<!--- ......................... End of RESERVE strucSplanFutureAmnt.spr_getAmount_RES ......................................... --->

<!--- ......................... Beginning of BALANCE BEFORE RESERVE strucSplanFutureAmnt.spr_getAmount_BAR  ................... --->              
             <cfloop query="strucSplanFutureAmnt.spr_getAmount_BAR" startrow="1" endrow="#strucSplanFutureAmnt.spr_getAmount_BAR.RecordCount#">
             <tr id="idTr_BAR">
             	<td><div id="divCatDescr_#H_LEVEL#_#SPLAN_CAT_ID#">#SPLAN_CAT_DESC#</div></td>
                <td><div id="divAmntTody_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_AS_OF_TODAY#</div></td>
                <td><div id="divAmntFOPPY_#H_LEVEL#_#SPLAN_CAT_ID#">#AMOUNT_NEXT_YEAR_FOP#</div></td>
                <td><div id="divSPNextPY_BAR">#AMOUNT_NEXT_YEAR_PY#</div></td>
                <td colspan="2"><div id="">&nbsp;</div></td>
             </tr>
             </cfloop>      
<!--- ......................... End of BALANCE BEFORE RESERVE strucSplanFutureAmnt.spr_getAmount_BAR ......................... --->
                    
             <tr>
                    <td colspan="3" align="left">
                    	<cfloop query="strucSplanFutureAmnt.spr_getTransClosed" startrow="1" endrow="#strucSplanFutureAmnt.spr_getTransClosed.RecordCount#">
                        	<cfif #TRANS_CLOSED# EQ "YES">
                            	<cfset variables.btnDisabled = "">
                            <cfelse>
                            	<cfset variables.btnDisabled = "disabled='disabled'">
                                <!---<cfset variables.btnDisabled = "">--->
                            </cfif>
						</cfloop><!------>
                        <input type="button" name="btnCreateSplan" id="btnCreateSplan"  #variables.btnDisabled#
                        	   value="Create PY #spr_getCurrentPY.NEXT_YEAR_PY# Spend Plan" tabindex="#variables.nextTabIndex#"/>
                        <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                    </td>
                    <td align="right" colspan="3" >
                        <!---<div class="buttons">--->
                        <input type="button" name="btnSave" id="btnSave"  value="Save&nbsp;"  tabindex="#variables.nextTabIndex#"/>
                        <cfset variables.nextTabIndex = variables.nextTabIndex + 1>
                        <input type="button" name="btnClear" id="btnClear" value="Reset" tabindex="#variables.nextTabIndex#"/>
                        <!---</div>--->
            		</td>
          	</tr>
    </table>
<!---<cfinclude template="#application.paths.includes#footer.cfm">--->
</form>
</div><!-- ctrSubContent -->

<cfinclude template="#application.paths.includes#footer.cfm">

<script language="javascript">
var v_ValOnFocus = 0, 		// Var captures the value in the txt control when control receives focus
	v_ValOnBlur = 0, 		// Var captures the value in the txt control when control looses focus
	v_delta_FocusBlur = parseInt(v_ValOnFocus) - parseInt(v_ValOnBlur);	// Var registers the difference of the values.  

var v_txtSize = 15,
	v_txtMaxLength = 15;
	
var v_createArgsForSave;

var vFontSize = ".9em";
var vFontFamily = "Arial, Helvetica, sans-serif";
//------------------------------------------------------------------------------------
$("document").ready(function() {

	$("##divPageTitleDisplay").css("font-family",vFontFamily)
							  .css("font-size",".9em")
							  .css("font-weight","bold");

	
	$("div[id^=divCatDescr]").css("font-weight","bold")
							 .css("font-size", vFontSize)
							 .css("font-family",vFontFamily);
							  
	$("div[id^=divAmntTody],"+
	  "div[id^=divAmntFOPPY],"+
	  "div[id^=divSPNextPY]").css("font-size", vFontSize)
							 .css("font-family",vFontFamily)
							 .attr("align","right");
	
							  
	$("div[id^=divAmntTody_1],"+
	  "div[id^=divAmntTody_2],"+
	  //------------------------
	  "div[id^=divAmntFOPPY_1],"+
	  "div[id^=divAmntFOPPY_2],"+
	  //------------------------
	  "div[id^=divSPNextPY_1],"+
	  "div[id^=divSPNextPY_2],"+
	  //------------------------
	  "div[id=divSPNextPY_GT],"+ 
	  "div[id=divSPNextPY_APPRP],"+  
	  "div[id=divSPNextPY_BBR],"+ 
	  "div[id=divSPNextPY_RES],"+ 
	  "div[id=divSPNextPY_BAR]").css("font-weight","bold");
	
  	 $("input[id^=txtSPNextPY]").css("text-align","right")
				    			.css("font-size", vFontSize)
				    			.css("font-family",vFontFamily);

	 
	 $("textarea[id^=txaNote_]").css("font-size", vFontSize)
								.css("font-family",vFontFamily)
								.css("resize", "none");
	//-------------
	$("tr[id^=idTr_]").css("background-color","##CCCCCC");
	//-------------
	$("input[id^=txtSPNextPY]").change(function(){
		formatNum(this,2,1);
	});
	//$(document).on('change', 'input', function() {
  	//	formatNum(this,2,1);
	//});	
	//-------------
	$("input[id^=btn]").click(function(){
		f_onClick(this.name);
	});
	//-------------
	$("input[id^=txtSPNextPY]").focus(function(){
		f_onFocus(this.name);	
	});
	//-------------
	$("input[id^=txtSPNextPY]").blur(function(){
		f_onBlur(this.name);	
	});
	$("textarea[id^=txaNote]").focus(function(){
		f_msgShowHide("CHANGES_NO");
	});
});
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function f_editNotes(arg_CtrlName)
{//btnNotesYES_##H_LEVEL##_##PATH##"
 //txaNote_##H_LEVEL##_##PATH##
	//alert(arg_CtrlName)
	var v_Pos = arg_CtrlName.indexOf("_");
	var v_CtrlPrefix = arg_CtrlName.substr(0, v_Pos);           //Ex: btnNotesYES
	var v_LevelPath = arg_CtrlName.substr(v_CtrlPrefix.length); //Ex: _3_4_16_25 (3-Level, 4_6_25 - Path)
	var v_YNC =  v_CtrlPrefix.substr(v_Pos-3); // YNC - stands for YesNotClose
	var //v_CurrentNote = $("textarea##txaNote"+v_LevelPath).val(),
		v_UpdatedNote = "";
//$("textarea##txaNote"+v_LevelPath).val(),
//alert("txaNote"+v_LevelPath+" - "+arg_CtrlName)


	
	f_msgShowHide("CHANGES_NO");
	
	if (v_YNC == "YES" || v_YNC == "NOT")
	{//"style='display:none;'"
		$("##"+arg_CtrlName).css("display","none");
		$("##btnNotesCLS"+v_LevelPath).css("display","");
		$("##txaNote"+v_LevelPath).css("display","");
	}
	else if (v_YNC == "CLS")
	{
		v_UpdatedNote = $("textarea##txaNote"+v_LevelPath).val();
		v_UpdatedNote = of_Trim(v_UpdatedNote);
		if (v_UpdatedNote.length == 0 )
		{
			$("##btnNotesCLS"+v_LevelPath).css("display","none");	
			$("##btnNotesYES"+v_LevelPath).css("display","none");	
			$("##btnNotesNOT"+v_LevelPath).css("display","");
			$("##txaNote"+v_LevelPath).css("display","none");	
		}
		else if (v_UpdatedNote.length != 0)
		{
			$("##btnNotesCLS"+v_LevelPath).css("display","none");	
			$("##btnNotesYES"+v_LevelPath).css("display","");	
			$("##btnNotesNOT"+v_LevelPath).css("display","none");					
			$("##txaNote"+v_LevelPath).css("display","none");
		}
	}
	
	//alert("|"+v_CurrentNote+"|     |"+v_UpdatedNote+"|")
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function f_onClick(arg_CtrlName)
{
	var argSPNextPYRES, argSPNextPYBAR;
	
	switch (arg_CtrlName)
	{
		case "btnSave":
					v_createArgsForSave = f_createArgsForSave();
					of_Submit("splan_future_controller.cfm?actionMode=saveFutureSplan&urlUserID="+v_UserID+"&urlSplan="+v_createArgsForSave);
		break;
		//
		case "btnClear":
			f_msgShowHide("CHANGES_NO");
			//of_Submit("splan_future_controller.cfm?actionMode=INIT");
			of_Submit("splan_future_controller.cfm?actionMode=INIT");
		break;
		//
		case "btnCreateSplan":
			if (v_delta_FocusBlur != 0)
			{
					if (confirm("Changes have been made.\n\n"+
								"If you would like to save changes, click 'OK' to save changes, then proceed with Spend Plan creation.\n\n"+
								"If changes have to be ignored, click 'Cancel', to reset page, then proceed with Spend Plan creation."))
					{
						//v_createArgsForSave = f_createArgsForSave();
						//of_Submit("splan_approp_allot_controller.cfm?actionMode=saveFutureSplan&urlUserID="+v_UserID+"&urlSplan="+v_createArgsForSave);
						f_onClick("btnSave");
					}
					else
					{
						//f_msgShowHide("CHANGES_NO");
						//of_Submit("splan_future_controller.cfm?actionMode=INIT");
						f_onClick("btnClear");
					}
				
			}
			else
			{
					f_msgShowHide("CHANGES_NO");
					if ( confirm("Are you sure you want to generate the PY#spr_getCurrentPY.NEXT_YEAR_PY# Spend Plan?\n"+
								"This action cannot be undone.\n"+
								"Click 'OK' to continue.\n"+
								"Click 'Cancel' to remain on this page.") )
				  {
					  argSPNextPYRES = parseInt(f_RemoveCommas($("##divSPNextPY_RES").html()));
					  argSPNextPYBAR = parseInt(f_RemoveCommas($("##divSPNextPY_BAR").html()));
					  
					  /*TEST:
					  alert("splan_future_controller.cfm?actionMode=setNextYearSplan"+
					  						  			    "&urlUserID="+v_UserID+
					  										"&argPY=#variables.v_Next_Year_PY#"+
					  										"&argSPNextPYRES="+argSPNextPYRES+
					  										"&argSPNextPYBAR="+argSPNextPYBAR);
					  */
					  of_Submit("splan_future_controller.cfm?actionMode=setNextYearSplan"+
					  						  			    "&urlUserID="+v_UserID+
					  										"&argPY=#variables.v_Next_Year_PY#"+
					  										"&argSPNextPYRES="+argSPNextPYRES+
					  										"&argSPNextPYBAR="+argSPNextPYBAR);
					 
				  }
			}
		break;
	}
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function f_createArgsForSave(){with(self.document.frmPage)
{
	var v_SplanCatID="", v_Amnt="", v_Pos=0, v_Note="";
	var v_CtrlNoteName="", v_Splan="";
	//
	$("input[id^=txtSPNextPY]").each(function()
	{
		v_Amnt = this.value;	//123,456
		v_Amnt = f_RemoveCommas(v_Amnt); //123456
		v_Amnt = v_Amnt.toString();	//123456
		v_SplanCatID = $(this).attr("alt"); //45 // Record ID is stored in property "alt".
		//
		v_Pos = this.id.indexOf("_");
		//
		// Obtain Note:
		v_CtrlNoteName = "txaNote"+this.id.substr(v_Pos);	//txa_Note_3_3_20_45  txa_Note_##H_LEVEL##_##PATH##
		v_Note = $("textarea##"+v_CtrlNoteName).val();	//'Msg is here', or ''

		if (v_Amnt != 0 || v_Note !='' )
		{
			v_Splan = v_Splan+v_SplanCatID+"_"+v_Amnt+"_"+v_Note+"^"; 
		}

	});	//
	
	return v_Splan;
}}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function f_onFocus(arg_CtrlName)
{
	f_msgShowHide("CHANGES_NO");
	
	v_ValOnFocus = $( "##"+arg_CtrlName ).val(); 
	v_ValOnFocus = f_RemoveCommas(v_ValOnFocus);
}
//---------------------------------------------------------------------
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
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function f_reCalculateTotal(arg_CtrlName)
{
//Control Name structure: txtSPNextPY_LEVEL_PATH
//
//	LEVEL=1: txtSPNextPY_1_4	  1-Level; 4-SPLAN_CAT_ID
//
//	LEVEL=2: txtSPNextPY_2_5_7	  2-Level; 5-SPLAN_CAT_ID is the ID of the LEVEL 1 record ID, 
//										   7-SPLAN_CAT_ID is the ID of the LEVEL 2 record ID.
//
//	LEVEL=3: txtSPNextPY_3_6_8_9  3-Level; 6-SPLAN_CAT_ID is the ID of the LEVEL 1 record ID, 
//										   8-SPLAN_CAT_ID is the ID of the LEVEL 2 record ID,
//										   9-SPLAN_CAT_ID is the ID of the LEVEL 3 record ID.
//

var v_CtlrPrefix="",
	v_Level=0, v_L=0, 
	v_idL1=0, v_idL2=0, v_idL3=0, // Record IDs for the LEVELS 1,2 and 3
	v_Pos=0, v_IntermStr=arg_CtrlName,
	// Sums:
	v_SumL1=0, v_SumL2=0, 
	v_SumGT=0, v_SumAPRRP=0, v_SumBBR=0, v_SumRES=0, v_SumBAR=0,
	v_RES_Percent="#strucSplanFutureAmnt.spr_getResPercent.RES_PERCENT#";	
	
	
	v_Pos = v_IntermStr.indexOf("_");
	v_CtlrPrefix = v_IntermStr.substr(0, v_Pos).substr(3);
	v_IntermStr = v_IntermStr.substr(v_Pos+1);
	//
	v_Pos = v_IntermStr.indexOf("_");
	v_Level = v_IntermStr.substr(0, v_Pos);
	//
	v_IntermStr = v_IntermStr.substr(v_Pos+1);
	//
	if (v_Level == 1)
	{
			v_idL1 = v_IntermStr;
	}
	else if (v_Level == 2) {/* No functionality assumed for the Level=2*/}
	else if (v_Level == 3)
	{
			v_Pos = v_IntermStr.indexOf("_");
			v_idL1 = v_IntermStr.substr(0, v_Pos);
			
			v_IntermStr = v_IntermStr.substr(v_Pos+1);
			v_Pos = v_IntermStr.indexOf("_");
			v_idL2 = v_IntermStr.substr(0, v_Pos);
			
			v_IntermStr = v_IntermStr.substr(v_Pos+1);
			v_idL3 = v_IntermStr;
			//
			// Recalculate "subtotal" for the Level=2:
			$("input[id^="+"txt"+v_CtlrPrefix+"_"+v_Level+"_"+v_idL1+"_"+v_idL2+"]").each(function(index){
					v_SumL2 = parseInt(v_SumL2)+parseInt(f_RemoveCommas(this.value));
			});
			v_SumL2 = v_SumL2.toString();
			v_SumL2 = f_AddCommas(v_SumL2);
			v_L = parseInt(v_Level)-1;
			
			//$("##div"+v_CtlrPrefix.substr(3)+"_"+v_L+"_"+v_idL1+"_"+v_idL2).html(v_SumL2);
	
			// The following "if" validates if control exists, and if yes, it sets the value into that control.... see "A"
			if ( $("##div"+v_CtlrPrefix+"_"+v_L+"_"+v_idL1+"_"+v_idL2).length  ) 
			{
				$("##div"+v_CtlrPrefix+"_"+v_L+"_"+v_idL1+"_"+v_idL2).html(v_SumL2);
				
				// Recalculate "subtotal" for Level=1	  divSPNextPY_2_5_7
				$("div[id^=div"+v_CtlrPrefix+"_"+v_L+"_"+v_idL1+"]").each(function(){
					v_SumL1 = parseInt(v_SumL1)+parseInt(f_RemoveCommas( $("##"+this.id).html() ) );
				});
				v_SumL1 = v_SumL1.toString();
				v_SumL1 = f_AddCommas(v_SumL1);
				v_L = parseInt(v_Level)-2;
				
				$("##div"+v_CtlrPrefix+"_"+v_L+"_"+v_idL1).html(v_SumL1);
			}
			else //... "A": if it doesn't, sets the value in the control LEVEL=1.
			{
				v_L = parseInt(v_Level)-2;
				if (  $("##div"+v_CtlrPrefix+"_"+v_L+"_"+v_idL1).length  ) 
				{
					$("##div"+v_CtlrPrefix+"_"+v_L+"_"+v_idL1).html(v_SumL2);
				}
			}
	}
	//
	//GRAND TOTAL:
	$("input[id^=txt"+v_CtlrPrefix+"_]").each(function()
	{
		v_SumGT += parseInt(  f_RemoveCommas($("##"+this.id).val())  );
	});
	v_SumGT = v_SumGT.toString();
	v_SumGT = f_AddCommas(v_SumGT);
	$("##divSPNextPY_GT").html(v_SumGT);
	//
	//APPROPRIATION: remains unchanged:
	v_SumAPRRP = $("##divSPNextPY_APPRP").html();
	//v_SumAPRRP =  f_RemoveCommas(v_SumAPRRP);
	//
	//BALANCE BEFORE RESERVE:
	v_SumBBR = parseInt(f_RemoveCommas(v_SumAPRRP)) - parseInt(f_RemoveCommas(v_SumGT));
	v_SumBBR = v_SumBBR.toString();
	v_SumBBR = f_AddCommas(v_SumBBR);
	$("##divSPNextPY_BBR").html(v_SumBBR);
	//
	// RESERVE: remains unchanged:
	v_SumRES = parseInt(f_RemoveCommas(v_SumAPRRP))*v_RES_Percent/100;
	v_SumRES = Math.round(v_SumRES);
	//
	// BALANCE AFTER RESERVE
	v_SumBAR = parseInt(f_RemoveCommas(v_SumAPRRP))- parseInt(f_RemoveCommas(v_SumGT)) -v_SumRES;
	v_SumBAR = v_SumBAR.toString();
	v_SumBAR = f_AddCommas(v_SumBAR); 
	$("##divSPNextPY_BAR").html(v_SumBAR);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function f_msgShowHide(arg_Action){with(self.document.forms["frmPage"])
{//alert("f_msgShowHide   "+arg_Action)


	var v_Msg = "&nbsp;";
	var v_ClassName = "confirmList";
	var v_TrueFalse = true;

	if (arg_Action == "CHANGES_YES")//
	{
		v_Msg = "Your changes have been saved. Return to the <a href='<cfoutput>#application.paths.admin#</cfoutput>'>Admin Section</a>."
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

</script>
</cfoutput>




