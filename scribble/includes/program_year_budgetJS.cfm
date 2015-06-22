<!---program_year_budgetJS.cfm--->
<script>
var cfcLink = "<cfoutput>"+"#application.urlstart##cgi.http_host##application.paths.components#program_year_budget.cfc?isBackground=yes"+"</cfoutput>";
var v_CurrentPY;

var v_CtrlName  = "";
var v_CtrlID    = "";
var v_CtrlType  = "";
var v_CtrlValue = "";
var v_CtrlText  = "";
var v_CtrlAlt   = "";
var v_CtrlSize  = 0;

// GENERIC FUNCTIONS ---------------------------------------------------------------------------------------
function of_setSingleValue(arg_CtrlName, arg_Value, arg_Text, arg_ZeroLength_YesNo, arg_Pos){with(self.document.forms[0])
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
    //
    v_CtrlType = "";
    //
	for (var e=0; e<elements.length; e++)
    {
        if (elements[e].name == arg_CtrlName)
        {
            v_CtrlType = elements[e].type;
            break;
        }
    }
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



//----------------------------------------------------------------------------------------------------------
// page FUNCTIONS: -----------------------------------------------------------------------------------------
$(document).ready(function(){
	f_getCurrentPY();
});
//
//
//----------------------------------------------------------------------------------------------------------
//
function f_getCurrentPY()
{
	var method = { method: 'f_getCurrentPY'}
	$.ajax({
			 type:		'POST'
			,url:		cfcLink
			,data:		method
			,success:	function(serializedData,statusTxt,xhr){//alert(serializedCurrentPY);
				var v_CurrentPY_JSON = $.parseJSON(serializedData); //	alert(v_CurrentPY_JSON.DATA[0]);
				for (var y=0; y<v_CurrentPY_JSON.DATA.length; y++)
				{
					v_CurrentPY = v_CurrentPY_JSON.DATA[y];
				}
				//------------------------------------------------------------------------------------------
				f_getProgramYears();
				//------------------------------------------------------------------------------------------
			} //end of setting ".success: function... "
			,error: function(serializedData,statusTxt,xhr){
				alert("Error: "+xhr.status+": "+xhr.statusText);
			}//end of setting ".error"
		
	});//end of $.ajax	
} // end of f_getCurrentPY()
//
//----------------------------------------------------------------------------------------------------------
//
function f_getProgramYears()
{
	var method = { method: 'f_getProgramYears'}
	$.ajax({
			 type:		'POST'
			,url:		cfcLink
			,data:		method
			,success:	function(serializedData,statusTxt,xhr){//alert(serializedData);
				var v_ProgramYears_JSON = $.parseJSON(serializedData);
				for (var y=0; y<v_ProgramYears_JSON.DATA.length; y++)
				{
					v_PY = v_ProgramYears_JSON.DATA[y];
					alert(v_PY+" "+v_CurrentPY)
					
					optionX = new Option;
            		optionX.value = v_PY;
            		optionX.text  = v_PY;
            		eval("sel_PY.options["+y+"] = optionX");
					//
					if (eval("sel_PY.options["+y+"].value") == v_CurrentPY)
					{
						eval("sel_PY.options["+y+"].selected=true");
					}
				}
				//
				f_getProgramYearBudget();
				//
				//------------------------------------------------------------------------------------------
			} //end of setting ".success: function... "
			,error: function(serializedData,statusTxt,xhr){
				alert("Error: "+xhr.status+": "+xhr.statusText);
			}//end of setting ".error"
		
	});//end of $.ajax	
}
//
//----------------------------------------------------------------------------------------------------------
//

function f_getProgramYearBudget()
{
	var v_selectedPY = document.getElementById("sel_PY").value;
	
	var method = { //CFC function:
					method: 'f_getProgramYearBudget'
				   //arguments:
				  ,arg_selectedPY: v_selectedPY
				 }
	$.ajax({
			 type:		'POST'
			,url:		cfcLink
			,data:		method
			,success:	function(serializedData,statusTxt,xhr){
			//TEST1: alert("sas\n:"+JSON.stringify(serializedData)); 	 
			//TEST2: alert("SASjsdump:\n\n"+jsdump(serializedData))

			var v_parsedDatum = $.parseJSON(serializedData); //TEST: alert(JSON.stringify(v_parsedDatum));
			//------------------------------------------------------------------------------------------
			f_processParsedDatum(v_parsedDatum);
			//------------------------------------------------------------------------------------------
			} //end of setting ".success: function... "
			,error: function(serializedData,statusTxt,xhr){
				alert("Error: "+xhr.status+": "+xhr.statusText);
			}//end of setting ".error"
		
	});//end of $.ajax			

}// end of f_getProgramYearBudget
//
//----------------------------------------------------------------------------------------------------------
//
function f_processParsedDatum(arg_parsedDatum)
{
	var objDatum  = arg_parsedDatum || {};
	var v_RowCount = 0;
	var v_ColumnCount = 0;
	
	$.each(objDatum, function(key){
			
			v_RowCount = objDatum[key].DATA.length;
			v_ColumnCount = objDatum[key].COLUMNS.length;
			
			if (key === "spr_PY_Budget_Appropriation")
			{//TEST: alert(key+"\n"+v_RowCount+"\n"+ v_ColumnCount+"\n"+jsdump(objDatum[key]) );
				for (var r=0; r<v_RowCount; r++)
				{
					for (var c=0; c<v_ColumnCount; c++)
					{
						alert("r="+r+" c="+c+"  "+objDatum[key].DATA[r][c]);	
					}
				}
			}
			else if (key === "spr_PY_Budget_Allotment")
			{//TEST: alert(key+"\n"+v_RowCount+"\n"+ v_ColumnCount+"\n"+jsdump(objDatum[key]) );
				
				for (var r=0; r<v_RowCount; r++)
				{
					for (var c=0; c<v_ColumnCount; c++)
					{
						//alert(objDatum[key].DATA[r][c]);	
					}
				}
				
			}
			else if (key === "spr_PY_Budget")
			{//TEST: alert(key+"\n"+v_RowCount+"\n"+ v_ColumnCount+"\n"+jsdump(objDatum[key]) );
				
				for (var r=0; r<v_RowCount; r++)
				{
					for (var c=0; c<v_ColumnCount; c++)
					{
						//alert(objDatum[key].DATA[r][c]);	
					}
				}
				//alert(key+"\n"+v_RowCount+"\n"+ v_ColumnCount+"\n"+jsdump(objDatum[key]) );
			}
		} // end of function(key)
	); // end of $.each
}
//
//----------------------------------------------------------------------------------------------------------
//
</script>