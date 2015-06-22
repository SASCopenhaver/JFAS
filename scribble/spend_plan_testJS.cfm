<!--- job_corps_allotJS.cfm --->

<script language="javascript">
//<!---alert('<cfoutput>#session.userid#</cfoutput>')--->

// VARIABLES: ----------------------------------------------------------------------------------------------
var v_UserID = '<cfoutput>#session.userid#</cfoutput>';
var cfcLink = '<cfoutput>'+'#application.urlstart##cgi.http_host##application.paths.components#spend_plan_test.cfc?isBackground=yes'+'</cfoutput>';

function f_getSpendPlanOperations()
{
	var v_PY = 2014;
	
	var aryMethod = {method: "f_getSpendPlanOperations"
					,arg_PY: v_PY}
	var jqXHR = $.ajax
	({
		type:	"POST"
	   ,url:	cfcLink
	   ,data:	aryMethod
	   ,success: function(serializedJSON, statusTxt, xhr)
	   {
		  v_RecordSet    = $.parseJSON(serializedJSON); // TEST: alert(jsdump(v_RecordSet));
		  v_RowCount     = v_RecordSet.DATA.length; 	// TEST: alert(v_RowCount);
		  v_Columns      = v_RecordSet.COLUMNS; 		// TEST: alert(v_Columns);
		  v_ColumnCount  = v_RecordSet.COLUMNS.length;  // TEST: alert(v_ColumnCount);		   
	   }// end of setting ".success: function... "
	   ,error: function(jqXHR, statusTxt, xhr)
	   {
			alert("Error: "+xhr.status+": "+xhr.statusText);
 	   }// end of setting ".error"	
	}); // end of jqXHR
		
}// end of f_getSpendPlanOperations()
//
f_getSpendPlanOperations();
/*
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
*/


</script>
