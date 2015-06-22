<!--- message_editorJS.cfm --->

<script language="javascript">
//==========================================================================================================
// VARIABLES declaration starts:
var v_UserID = '<cfoutput>#session.userid#</cfoutput>';
var cfcLink = '<cfoutput>'+'#application.urlstart##cgi.http_host##application.paths.components#message_editor.cfc?isBackground=yes'+'</cfoutput>';

var v_RecordSet = "";
var v_RowCount = 0;
var v_Columns,
	v_ColumnCount;

var v_SelectedMsgID = -1;

var v_ajaxMethod,
	v_MsgStatus,
	v_MsgID,
	v_MsgType,
	v_MsgComment,
	v_MsgText;

var v_NewMsgID;

var v_MaxCharLength = 1000;

var v_Controller = "INIT_GET_MESSAGE_TYPES";
//------------------------------------------------------------------------------
var v_ValidationPassed = "YES";
var v_DefaultError = "The following problem has occurred.  Please fix this error before saving.\n\n";
var v_DefaultValue = "-1";
var objRegExp_onlyCapitalAlphaNumeric =  /^([A-Z0-9_-])$/;
//------------------------------------------------------------------------------
var v_CtrlName  = "";
var v_CtrlID    = "";
var v_CtrlType  = "";
var v_CtrlValue = "";
var v_CtrlText  = "";
var v_CtrlAlt   = "";
var v_CtrlSize  = 0;
var v_Char 		= "";
//------------------------------------------------------------------------------
// VARIABLES declaration ends.
//==========================================================================================================
// GENERIC FUNCTIONS start:
function of_setSingleValue(arg_CtrlName, arg_Value, arg_Text, arg_ZeroLength_YesNo, arg_Pos)
{with(self.document.forms["frmMsgEditor"]){
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
    //
    var v_CtrlType = "";
    //
    for (var e=0; e<elements.length; e++)
    {
        if (elements[e].name == arg_CtrlName)
        {
            v_CtrlType = elements[e].type;
            break;
        }
    }
    //alert(v_CtrlType)

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
            eval(arg_CtrlName+".value = "+arg_Value);
        break;
		//
		case "hidden":
            eval(arg_CtrlName+".value = "+arg_Value);
        break;
		//
		case "textarea":
	    	eval(arg_CtrlName+".value = "+arg_Value);
	  	break;
    }
}}
//------------------------------------------------------------------------------
function of_selectRecord(arg_CtrlName, arg_Value)
{with(self.document.forms["frmMsgEditor"]){
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
}} // end of of_selectRecord
//------------------------------------------------------------------------------
function of_getCtrlProperties(arg_CtrlName)
{with(self.document.forms["frmMsgEditor"]){
      v_CtrlName = arg_CtrlName;
      v_CtrlID   = eval(v_CtrlName+".id");
      v_CtrlType = eval(v_CtrlName+".type");
      v_CtrlAlt  = eval(v_CtrlName+".alt");
      v_CtrlSize = eval(v_CtrlName+".size");

      //
      if (v_CtrlType == "select-one")
      {
         v_CtrlValue = eval(v_CtrlName+".options["+v_CtrlName+".options.selectedIndex].value");
         v_CtrlText  = eval(v_CtrlName+".options["+v_CtrlName+".options.selectedIndex].text");
      }
      else if (v_CtrlType == "text" || v_CtrlType == "hidden" || v_CtrlType == "textarea")
      {
         v_CtrlValue = of_Trim(eval(v_CtrlName+".value"));
      }
	  else
	  {
			for (var e=0; e<elements.length; e++)
	  	  	{
				if (elements[e].name == v_CtrlName )
				{
					v_CtrlType = elements[e].type;
					break;	
				}
			}
			//
			if (v_CtrlType == "radio")
			{
				for(var r=0; r<eval(v_CtrlName+".length"); r++)
				{
					if(eval(v_CtrlName+"["+r+"].checked") == true )	
					{
						v_CtrlValue = eval(v_CtrlName+"["+r+"].value");
					}
				}
			}
	  }

}}	// end of  of_getCtrlProperties
//------------------------------------------------------------------------------
function of_Trim(s) {//***
  s = s.replace(/(^\s*)|(\s*$)/gi,"");
  s = s.replace(/[ ]{2,}/gi," ");
  s = s.replace(/\n /,"\n");
  return s;
}
//------------------------------------------------------------------------------

// GENERIC FUNCTION end.
//===========================================================================================================
//
// PAGE FUNCTIONS start:
//
function f_callAJAX(arg_ajaxMethod){
	//var aryMethod = {method: "f_cfcFunctionName"
	//				  ,arg_One: v_ValueForArg_1
	//				  ,...
	//				  ,arg_N:   v_ValueForArg_N}
	
	var jqXHR = $.ajax
	({
		type:	"POST"
	   ,url:	cfcLink
	   ,data:	arg_ajaxMethod
	   ,success: function(serializedJSON, statusTxt, xhr)
	   {
		  v_RecordSet    = $.parseJSON(serializedJSON); // TEST: alert(v_Controller+"  "+jsdump(v_RecordSet));
		  v_RowCount     = v_RecordSet.DATA.length; 	// TEST: alert(v_RowCount);
		  v_Columns      = v_RecordSet.COLUMNS; 		// TEST: alert(v_Columns);
		  v_ColumnCount  = v_RecordSet.COLUMNS.length;  // TEST: alert(v_ColumnCount);
			
		  switch(v_Controller)
		  {
				case "INIT_GET_MESSAGE_TYPES":
					f_setMessageTypes(v_RecordSet, v_RowCount, v_Columns, v_ColumnCount);
				break;
				//
				case "GET_SELECTED_MESSAGE":
					f_setSelectedMessage(v_RecordSet, v_RowCount, v_Columns, v_ColumnCount);
				break;
				//
				case "DELETE_SELECTED_MESSAGE":
					f_setMessageTypes(v_RecordSet, v_RowCount, v_Columns, v_ColumnCount);
					of_selectRecord("sel_MsgType", -1);
					f_onChange("sel_MsgType");
					alert("Selected message has been deleted.")
				break; 
				//
				case "UPDATE_MESSAGE":
					f_getMessageTypes();
					alert("Message has been updated.");
					//of_selectRecord("sel_MsgType", v_MsgID);
					//f_onChange("sel_MsgType");
				break;
				//
				case "GET_NEW_MESSAGE_ID":
					v_NewMsgID = v_RecordSet.DATA[0][0];
					f_createNewMessage(v_NewMsgID);
				break;
				//
				case "NEW_MESSAGE_CREATED":
					f_getMessageTypes();
					alert("New message has been created.");
				break;
		  }
		  //
	   }// end of setting ".success: function... "
	   ,error: function(jqXHR, statusTxt, xhr)
	   {
			alert("Error: "+xhr.status+": "+xhr.statusText);
 	   }// end of setting ".error"	
	});// end of jqXHR
}// end of f_callAJAX
//
//==========================================================================================================
//
//
//==========================================================================================================
//
function f_getMessageTypes()
{//alert("257  "+v_Controller)
	v_Controller = "INIT_GET_MESSAGE_TYPES";
//alert("259  "+v_Controller)
	v_ajaxMethod = {method: "f_getMessageTypes"};
	f_callAJAX(v_ajaxMethod);
}
f_getMessageTypes();
//
//==========================================================================================================
//
function f_setMessageTypes(arg_RecordSet, arg_RowCount, arg_Columns, arg_ColumnCount)
{with(self.document.forms["frmMsgEditor"]){
	
	of_setSingleValue("sel_MsgType", v_DefaultValue, "Select / Create Message", "YES", 0);
	//TEST: alert(v_Controller+"   "+v_RowCount+"   "+v_MsgID)
	for (var row=0; row<v_RowCount; row++)
	{//v_Columns = STATUS,MSG_ID,MSG_TYPE
					
		of_setSingleValue("sel_MsgType", arg_RecordSet.DATA[row][1], arg_RecordSet.DATA[row][2], "NO", row+1);
	}
	//
	//if (v_Controller == "INIT_GET_MESSAGE_TYPES" )
	if (v_Controller == "INIT_GET_MESSAGE_TYPES" && isNaN(v_MsgID)==true)
	{
		of_selectRecord("sel_MsgType", -1);
		txt_MsgType.value = "";
		txt_MsgComments.value = "";
		txa_MsgText.value = "";	
		rbn_Status[0].checked = true;
		//
		txt_NumOfChar.value = v_MaxCharLength - txa_MsgText.value.length;
		//
		f_onClick("rbn_Status");
		txt_MsgType.focus();
	}
	else if (v_Controller == "INIT_GET_MESSAGE_TYPES" && isNaN(v_MsgID)==false)
	{
		of_selectRecord("sel_MsgType", v_MsgID);
		f_onChange("sel_MsgType");
	}
}} // end of f_setMessageTypes
//
//==========================================================================================================
//
function f_onChange(arg_CtrlName)
{with(self.document.forms["frmMsgEditor"]){
	switch (arg_CtrlName)
	{
		case "sel_MsgType":	
			of_getCtrlProperties("sel_MsgType");
			if (v_CtrlValue == -1)
			{
				txt_MsgType.value = "";
				txt_MsgComments.value = "";
				txa_MsgText.value = "";	
				rbn_Status[0].checked = true;
				//
				txt_NumOfChar.value = v_MaxCharLength;
				//
				f_onClick("rbn_Status");
				txt_MsgType.focus();					
			}
			else
			{
				v_Controller = "GET_SELECTED_MESSAGE";
				v_ajaxMethod = { method: "f_getSelectedMessage"
					 			,arg_MsgID:   v_CtrlValue}
				f_callAJAX(v_ajaxMethod);
			}
		break;
	}
}} // end of f_onChange
//
//==========================================================================================================
//
function f_onClick(arg_CtrlName)
{with(self.document.forms["frmMsgEditor"]){
	switch(arg_CtrlName)
	{
		case "cbn_Save":
			v_ValidationPassed = "YES";
			v_ValidationPassed = f_Validate();
			if (v_ValidationPassed == "YES")
			{
				of_getCtrlProperties("sel_MsgType");
				v_MsgID = v_CtrlValue;
				//
				of_getCtrlProperties("txt_MsgType");
				v_MsgType = v_CtrlValue;
				//
				for (var r=0; r<rbn_Status.length; r++)
				{
					if (rbn_Status[r].checked == true)	
					{
						v_MsgStatus = rbn_Status[r].value;
						break;
					}
				}
				//
				of_getCtrlProperties("txt_MsgComments");
				v_MsgComment = v_CtrlValue;
				//
				of_getCtrlProperties("txa_MsgText");
				v_MsgText = v_CtrlValue;
				if (v_MsgText.length == 0){v_MsgText = "NULL"; }
				//	
				if (v_MsgID == -1)//Newe record has to be created
				{
					v_Controller = "GET_NEW_MESSAGE_ID";
					v_ajaxMethod = { method: "f_getNewMessageID"} // TEST: alert(jsdump(v_ajaxMethod));
					f_callAJAX(v_ajaxMethod);
				}
				else
				{
					v_Controller = "UPDATE_MESSAGE";
					v_ajaxMethod = { method: "f_InsertUpdateMessage"
									,arg_MsgStatus:  v_MsgStatus
									,arg_MsgID:		 v_MsgID
									,arg_MsgType:	 v_MsgType
									,arg_MsgComment: v_MsgComment
									,arg_MsgText:	 v_MsgText
									,arg_UserID:	 v_UserID
								   } // TEST: alert(jsdump(v_ajaxMethod));
					f_callAJAX(v_ajaxMethod);						
				}
			}
		break;
		//-------------------------------------------------------------------------------------------------
		case "rbn_Status":
		if (document.getElementById("rbn_Status").checked) // returns "true" or "false"
		{
			txt_MsgType.disabled     = false;
			txt_MsgComments.disabled = false;
			txa_MsgText.disabled     = false;
		}
		else
		{
			txt_MsgType.disabled     = true;
			txt_MsgComments.disabled = true;
			txa_MsgText.disabled     = true;			
		}
		break;
		//--------------------------------------------------------------------------------------------------
		case "cbn_Delete":
			
			of_getCtrlProperties("sel_MsgType");
			if (v_CtrlValue == -1)
			{
				alert("This record could be deleted.\nPlease select another one.");
			}
			else
			{
				v_Controller = "DELETE_SELECTED_MESSAGE";
				
				v_ajaxMethod = {method: "f_deleteSelectedMessage"
							   ,arg_MsgID: v_CtrlValue}
				f_callAJAX(v_ajaxMethod);
			}
		break;
		//--------------------------------------------------------------------------------------------------
	}
}} // end of f_onClick
//
//==========================================================================================================
//
function f_createNewMessage(arg_NewMsgID)
{with(self.document.forms["frmMsgEditor"]){
	
		v_MsgID = arg_NewMsgID;
		//
		of_getCtrlProperties("txt_MsgType");
		v_MsgType = v_CtrlValue;
		//
		for (var r=0; r<rbn_Status.length; r++)
		{
			if (rbn_Status[r].checked == true)	
			{
				v_MsgStatus = rbn_Status[r].value;
				break;
			}
		}
		//
		of_getCtrlProperties("txt_MsgComments");
		v_MsgComment = v_CtrlValue;
		//
		of_getCtrlProperties("txa_MsgText");
		v_MsgText = v_CtrlValue;

		v_Controller = "NEW_MESSAGE_CREATED";
		
		v_ajaxMethod = { method: "f_InsertUpdateMessage"
						,arg_MsgStatus:  v_MsgStatus
						,arg_MsgID:		 v_NewMsgID
						,arg_MsgType:	 v_MsgType
						,arg_MsgComment: v_MsgComment
						,arg_MsgText:	 v_MsgText
						,arg_UserID:	 v_UserID
					   } // TEST: alert(v_Controller+"   "+jsdump(v_ajaxMethod));
		f_callAJAX(v_ajaxMethod);
		//
}}
//
//==========================================================================================================
//
function f_setSelectedMessage(arg_RecordSet, arg_RowCount, arg_Columns, arg_ColumnCount)
{with(self.document.forms["frmMsgEditor"]){// Columns:STATUS, MSG_ID, MSG_TYPE, COMMENTS, MSG_TEXT 
//	alert(  "STATUS = "+arg_RecordSet.DATA[0][0]+"\n"+
//			"MSG_ID = "+arg_RecordSet.DATA[0][1]+"\n"+
//			"MSG_TYPE = "+arg_RecordSet.DATA[0][2]+"\n"+
//			"COMMENTS = "+arg_RecordSet.DATA[0][3]+"\n"+
//			"MSG_TEXT = "+arg_RecordSet.DATA[0][4]);
			
	txt_MsgType.value = arg_RecordSet.DATA[0][2];
	for (var rbn=0; rbn<rbn_Status.length; rbn++)
	{
		if (rbn_Status[rbn].value == arg_RecordSet.DATA[0][0])	
		{
			rbn_Status[rbn].checked = true;
			break;
		}
	} 
	txt_MsgComments.value = arg_RecordSet.DATA[0][3];
	txa_MsgText.value = arg_RecordSet.DATA[0][4];
	txt_NumOfChar.value = v_MaxCharLength - txa_MsgText.value.length;
	f_onClick("rbn_Status");
}}
//
//==========================================================================================================
//
function f_Validate()
{with(self.document.forms["frmMsgEditor"]){
	
	// 1. Message Type:
	of_getCtrlProperties("txt_MsgType");
	if (v_CtrlValue == "")
	{
		v_ValidationPassed = "NO";
		alert(v_DefaultError+"\t- Message type must be entered.");
		txt_MsgType.focus();
	}
	// 2. Comments:
	of_getCtrlProperties("txt_MsgComments");
	if (v_ValidationPassed == "YES" && v_CtrlValue == "")
	{
		v_ValidationPassed = "NO";
		alert(v_DefaultError+"\t- Comments must be entered.");
		txt_MsgComments.focus();
	}
	// 3. Message:
	of_getCtrlProperties("txa_MsgText");
	for (var rbn=0; rbn<rbn_Status.length; rbn++)
	{
		if (rbn_Status[rbn].checked == true)	
		{
			v_MsgStatus = rbn_Status[rbn].value;
			break;
		}
	}
	//
	if (v_MsgStatus == 1)
	{
		if (v_ValidationPassed == "YES" && v_CtrlValue == "")
		{
			v_ValidationPassed = "NO";
			alert(v_DefaultError+"\t- Message must be entered.");
			txa_MsgText.focus();
		}
	}
	
	return v_ValidationPassed;
}} // end of f_Validate()
//
//==================================================================================================
//
//
//==================================================================================================
function f_onKeyUp(arg_CtrlName){with(self.document.forms["frmMsgEditor"]){
	
	switch (arg_CtrlName)
	{
		//------------------------------------------------------------------------------------------
		case "txa_MsgText":
			f_LimitText();
		break;
		//--------------------------------------------------------------------------------------------------
		case "txt_MsgType":
		
			of_getCtrlProperties(arg_CtrlName);
			// Loop through the the value in the control, evaluating each character:
					for (var i=0; i<v_CtrlValue.length; i++)
					{//
						v_Char = v_CtrlValue.substr(i,1);
						//alert("|"+v_Char+"|")
						//alert(objRegExp_onlyCapitalAlpha.test(v_Char))
						//v_Char = parseInt(v_Char);
						//
						if (objRegExp_onlyCapitalAlphaNumeric.test(v_Char) == false)
						{
							alert("Special charecters, white spaces, and numeric values are not allowed in this field."+
								 "\nTo populate this field, please use only capital letters and/or numerics.");
							//Removing "unauthorised" charecter, set value without it:
							eval(v_CtrlName+".value=\""+v_CtrlValue.substr(0,i)+v_CtrlValue.substr(i+1, v_CtrlValue.length)+"\"");
							eval(v_CtrlName+".focus();");
							break;
						}
					}// end of for (var i=0; i<v_CtrlValue.length; i++)
		break;
		//--------------------------------------------------------------------------------------------------	
	}
}}
//
//===================================================================================================
//
function f_onKeyDown(arg_CtrlName){with(self.document.forms["frmMsgEditor"]){
	
	switch (arg_CtrlName)
	{
		case "txa_MsgText":
			f_LimitText();
		break;	
	}
}}
//
//===================================================================================================
//
function f_LimitText(){with(self.document.forms["frmMsgEditor"]){
	
	var v_TxtLength = txa_MsgText.value.length;
	
	if (v_TxtLength > v_MaxCharLength)
	{
		txa_MsgText.value = txa_MsgText.value.substring(0, v_MaxCharLength);
		alert("The maximum size of this field is "+v_MaxCharLength+" characters.")
	}
	else
	{
		txt_NumOfChar.value = v_MaxCharLength - v_TxtLength;
	}
}}
//
//===================================================================================================
//
//==========================================================================================================
//
</script>