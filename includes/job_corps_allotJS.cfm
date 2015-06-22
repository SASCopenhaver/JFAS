<!--- job_corps_allotJS.cfm --->

<script language="javascript">
//<!---alert('<cfoutput>#session.userid#</cfoutput>')--->

// VARIABLES: ----------------------------------------------------------------------------------------------

var v_UserID = '<cfoutput>#session.userid#</cfoutput>';
var cfcLink = '<cfoutput>'+'#application.urlstart##cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes'+'</cfoutput>';

var v_OutputTblHeader = "<table width='100%' border='0' class='dataTblCol' cellpadding='0' cellspacing='0' >"; //  contentTbl	class='dataTblCol'
var v_OutputTbl = "";
var v_OutputCbn = "";
var v_ColSpan = 0;

var v_CurrentPY;
//---
var v_AllotRecordSet = "";
var v_RowCount = 0;
var v_Columns = 0;
var v_NumOfColumns = 0;
//---
var v_txtCtrlNm = "";
var v_hdnCtrlNm = "";
var v_FundCat = "";
var v_FundOffcNum = "";
var v_Year = "";
//
var v_OutputChart = "";
var v_Type = "bar";
var v_SeriesLable = "";
var v_SeriesColor = "##ffcc00";
var v_Item = "";
var v_Value = "";

var v_FormatedNum = "";

var v_CtrlName  = "";
var v_CtrlID    = "";
var v_CtrlType  = "";
var v_CtrlValue = "";
var v_CtrlText  = "";
var v_CtrlAlt   = "";
var v_CtrlSize  = 0;

var v_Disabled = "";

var v_14_Bold = "style='font-size: 14px; font-weight: bold;'";
var v_12_Bold = "style='font-size: 12px; font-weight: bold;'";
var v_11_Normal = "style='text-align:right; font-size:11px; font-weight: normal;' ";
var v_12_Normal = "style='text-align:right; font-size:12px; font-weight: normal;' ";

var vBtn = "style='font-family: Arial, Helvetica, sans-serif; font-size:11px; padding: none; margin-top: 10px; margin-bottom: 0px;' ";

var objRegExp_Date = /^(?=\d)(?:(?:(?:(?:(?:0?[13578]|1[02])(\/|-|\.)31)\1|(?:(?:0?[1,3-9]|1[0-2])(\/|-|\.)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})|(?:0?2(\/|-|\.)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))|(?:(?:0?[1-9])|(?:1[0-2]))(\/|-|\.)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{2}))($|\ (?=\d)))?(((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))|([01]\d|2[0-3])(:[0-5]\d){1,2})?$/;
//
var objRegExp_onlyNumeric = /^\s*(\+)?\d+\s*$/;// Only positive number

var objRegExp_onlyAlpha = /^([a-zA-Z_-]+)$/;

var objRegExp_onlyAlphaNumeric = /^([a-zA-Z0-9_-]+)$/;
//
//----------------------------------------------------------------------------------------------------------
//
function of_getCtrlProperties(arg_CtrlName){with(self.document.forms["frmJCA"])
{
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
	  else if (v_CtrlType == "text" || v_CtrlType == "textarea")
	  {
		 v_CtrlValue = eval(v_CtrlName+".value");
	  }
	  else
	  {
		  v_CtrlValue = "";
	  }
}}
//
//----------------------------------------------------------------------------------------------------------
//
function f_AddCommas(arg_Value)
{
	var v_RtnVal = arg_Value;
	var v_IsCommaPresent = v_RtnVal.indexOf(",");
	
	if (v_IsCommaPresent < 0)// Adding commas - Ex: 123456789 becomes 123,456,789
	{
		v_RtnVal = v_RtnVal.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");	
	}
	//else {alert("Error in processing data.  Ask developers to look into the JavaScript Error Code 110.")}
	return v_RtnVal;
}
//
//----------------------------------------------------------------------------------------------------------
//
function f_RemoveCommas(arg_Value)
{
	var v_RtnVal = arg_Value;
	var v_IsCommaPresent = v_RtnVal.indexOf(",");
	
	if (v_IsCommaPresent >= 0)
	{
		v_RtnVal = v_RtnVal.replace(/\,/g,'');
	}
	//else {alert("Error in processing data.  Ask developers to look into the JavaScript Error Code 125.")	}
	return v_RtnVal;
}



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
	var arrayMethod = { method: 'f_getCurrentPY'}
	$.ajax({
			 type:		'POST'
			,url:		cfcLink
			,data:		arrayMethod
			,success:	function(serializedCurrentPY,statusTxt,xhr){
				
				var v_CurrentPY_JSON = $.parseJSON(serializedCurrentPY); //	alert(jsdump(v_CurrentPY));//alert(v_CurrentPY.DATA[0]);
				for (var y=0; y<v_CurrentPY_JSON.DATA.length; y++)
				{
					v_CurrentPY = v_CurrentPY_JSON.DATA[y];
				}
				//================================================================================================================		
				f_getAllotData();
				//================================================================================================================
			} //end of setting ".success: function... "
			,error: function(serializedCurrentPY,statusTxt,xhr){
				alert("Errorx sas: "+xhr.status+": "+xhr.statusText);
			}//end of setting ".error"
		
	});//end of $.ajax	
} // end of f_getCurrentPY()
//
//----------------------------------------------------------------------------------------------------------
//
function f_getAllotData()
{ //TEST:alert("sas" +v_UserID);
	var arrayMethod = { method: 'f_getAllotment' }
	$.ajax({
			type:	'POST'
		   ,url:	cfcLink
		   ,data:	arrayMethod
		   ,success: function(serializedAllotmentJSON,statusTxt,xhr){
		   	
				v_AllotRecordSet = $.parseJSON( serializedAllotmentJSON ); // TEST: alert(jsdump(v_AllotRecordSet));
				v_RowCount = v_AllotRecordSet.DATA.length; //17: from 0 to 16
				
				v_Columns = v_AllotRecordSet.COLUMNS;
				v_NumOfColumns = v_AllotRecordSet.COLUMNS.length; // alert(isNaN(v_NumOfColumns)) //16: from 0 to 15


// Creating OUTPUT starts: =======================================================================================================
// r - stands for "row".
// c - stansd for "column".
//---
				//
				for (var r=0; r<v_RowCount; r++)
				{
					v_OutputTbl = v_OutputTbl+"<tr>";
					for (var c=0; c<v_NumOfColumns; c++)
					{//alert(r+"   "+c+"   "+v_AllotRecordSet.DATA[r][c]);
						

									// Creating control names starts:----------------------
									if(c==0){v_FundCat = v_AllotRecordSet.DATA[r][c];}
									//---
									if(c==1){v_FundOffcNum = v_AllotRecordSet.DATA[r][c];}
									//---
									if(c>2 && c%2==1)
									{ 
										v_Year 			 = v_AllotRecordSet.DATA[0][c]; 
										v_txtCtrlNm      = "txt_"+v_FundCat+"_"+v_FundOffcNum+"_"+v_Year;
										v_hdnCtrlNm      = "hdn_"+v_FundCat+"_"+v_FundOffcNum+"_"+v_Year;
										v_divSubTotalNm  = "sub_"+v_FundCat+"_"+v_FundOffcNum+"_"+v_Year;
										v_divTotalNm     = "tot_"+v_FundCat+"_"+v_FundOffcNum+"_"+v_Year;
									}
									// Creating control names ends. --------------------
									//
									//
									//Table HEADER starts:------------------------------
									if ( (r==0 && c==2) || (r==0 && c>2 && c%2==1) )  // c>1 excludes the first two columns from the record set.
									{
											if (v_AllotRecordSet.DATA[r][c] == "FULL_NAME")
											{
												v_OutputTbl = v_OutputTbl+"<th "+v_14_Bold+">Program Years:</th>";	
											}
											else
											{
												if (v_AllotRecordSet.DATA[r][c] == v_CurrentPY) // v_CurrentPY is determined in f_getCurrentPY()
												{
													v_OutputTbl = v_OutputTbl+"<th "+v_14_Bold+"><center><font color='Red'>"+v_AllotRecordSet.DATA[r][c]+"</font>"+"</center></th>";
												}
												else
												{
													v_OutputTbl = v_OutputTbl+"<th "+v_14_Bold+"><center>"+v_AllotRecordSet.DATA[r][c]+"</center></th>";
												}
											}
									}
									//Table HEADER ends.--------------------------------
									//
									//Table CELLS starts:-------------------------------
									// c>1 excludes the first two columns to be shown from the record set.
									else if ( (r>0 && c==2) || (r>0 && c>2 && c%2==1) )
									{
										
										v_FormatedNum = "'"+v_AllotRecordSet.DATA[r][c]+"'";
										v_FormatedNum = f_AddCommas(v_FormatedNum);
										
										if ((r==1 || r==10) && c>2)
										{
											v_OutputTbl = v_OutputTbl+"<td>&nbsp;</td>"; //
											
										}
							// Subtotal:
										else if ((r==9 || r==18) ) 
										{
											v_FormatedNum = v_FormatedNum.substr(1);
											v_FormatedNum = v_FormatedNum.substr(0, v_FormatedNum.length-1);
											
											v_OutputTbl = v_OutputTbl+"<td "+v_12_Bold+">"+"<strong><span id='"+v_divSubTotalNm+"'>"+v_FormatedNum+"</span></strong>"+"</td>";
											// Ex: v_txtCtrlNm="txt_OPS_OPS_2011" or  v_txtCtrlNm="txt_CRA_CRA_2011"
										}
							//Total:
										else if (r==19)
										{
											v_FormatedNum = v_FormatedNum.substr(1);
											v_FormatedNum = v_FormatedNum.substr(0, v_FormatedNum.length-1);
											v_OutputTbl = v_OutputTbl+"<td "+v_12_Bold+"><br />"+"<span id='"+v_divTotalNm+"'>"+v_FormatedNum+"</span>"+"</td>";
											// Ex: v_txtCtrlNm="txt_ATOTAL_TOTAL_2011"
										}
							// "Operation" or "Construction"
										else if((r==1 || r==10) && c==2)
										{
											//v_OutputTbl = v_OutputTbl+"<td>"+r+" | "+c+" | "+v_FormatedNum+"</td>";
											if (r==1)
											{
												v_OutputTbl = v_OutputTbl+"<td "+v_12_Bold+">"+v_AllotRecordSet.DATA[r][c].toUpperCase()+"</td>";	
											}
											else if (r== 10)
											{
												v_OutputTbl = v_OutputTbl+"<td "+v_12_Bold+"><br /><br />"+v_AllotRecordSet.DATA[r][c].toUpperCase()+"</td>";
											}
											
										}
										else 
										{
											if (c<=2) // Shows a list of Funding Categories and Funding Offices.  No <inputs> are needed.
											{
												//v_OutputTbl = v_OutputTbl+"<td>"+r+" | "+c+" | "+v_AllotRecordSet.DATA[r][c]+"</td>";
												v_FormatedNum = v_FormatedNum.substr(1);
												v_FormatedNum = v_FormatedNum.substr(0, v_FormatedNum.length-1);
												v_OutputTbl = v_OutputTbl+"<td "+v_12_Normal+">"+v_FormatedNum+"</td>";
											}
											/*
											else if (c>2 && (r==1 || r==10)) 
											{
												v_OutputTbl = v_OutputTbl+"<td>"+r+" | "+c+" | "+v_AllotRecordSet.DATA[r][c]+"</td>";
											}
											*/
											else if (c>2 && c%2==1)//Applies to the columns with data where text and hidden controls are needed.
											{
												
													if (v_AllotRecordSet.DATA[r][c+1] == "N")
													{
														v_Disabled = "";
													}
													else if (v_AllotRecordSet.DATA[r][c+1] == "Y")
													{
														v_Disabled = "disabled='disabled' ";
													}
													
													v_OutputTbl = v_OutputTbl+"<td>"+"<input type='text' "+
																							"name='"+v_txtCtrlNm+"' "+
																					  		"id='"+v_txtCtrlNm+"' "+
																					  		"class='' "+
																							v_Disabled +
																							"value="+v_FormatedNum+" "+
																							"maxlength='12' "+
																							"size='13' "+
																							"onkeyup='f_onKeyUp(this.name);' "+
																							"onfocus='f_onFocus(this.name);' "+
																							"onBlur='f_onBlur(this.id);' "+ 
																							v_11_Normal+" "+
																						">"+
																						
																						"<input type='hidden' "+
																							   "name='"+v_hdnCtrlNm+"' "+
																							   "id='"+v_hdnCtrlNm+"' "+
																							   "value='"+v_AllotRecordSet.DATA[r][c]+"' "+
																						">"+
																		      "</td>";
											}
										}
									}
									//Table CELLS ends. -------------------------------
					}// End of loop with v_NumOfColumns
					v_OutputTbl = v_OutputTbl+"</tr>";
					//
				}// End of loop with v_RowCount
				
					
					// Page Header:
					v_ColSpan = parseInt(v_NumOfColumns)-3; 
					v_ColSpan = v_ColSpan/2;
					v_ColSpan = v_ColSpan + 1;
					var v_ColSpan2 = parseInt(v_ColSpan) - 3;
/*					
					// Add buttons:
					//v_ColSpan = parseInt(v_NumOfColumns)-3;
					v_OutputCbn = "<tr>"+
									  "<td colspan='"+v_ColSpan2+"'>&nbsp;</td>"+
									  "<td align='center'>"+
									  	  "<div class='buttons'>"+
										  "<button type='button' class='' id='cbn_Save' name='cbn_Save' onClick='f_onClick(this.name);'>Save</button>"+ //btn btn-primary btn-sm
										  "</div>"+
									  "</td>"+
									  "<td align='center'>"+
									  	  "<div class='buttons'>"+
										  "<button type='button' class='' id='cbn_Reset' name='cbn_Reset' onClick='f_onClick(this.name);'>Reset</button>"+ //btn btn-success btn-sm
										  "</div>"+
									  "</td>"+
									  "<td align='center'>"+
									  	  "<div class='buttons'>"+
										  "<button type='button' class='' id='cbn_Cancel' name='cbn_Cancel' onClick='f_onClick(this.name);'>Cancel</button>"+ //btn btn-warning btn-sm
										  "</div>"+
									  "</td>"+
								  "</tr>";
					//	
*/
				//v_OutputTbl = v_OutputTblHeader+v_OutputTbl+v_OutputCbn+'</table></center>';
				v_OutputTbl = v_OutputTblHeader+v_OutputTbl+'</table>';
				// Add buttons:
				v_OutputCbn = "<table width='100%' border='0' cellpadding='0' cellspacing='0' >"+
							  	  "<tr>"+
							  		  "<td align='center'>"+
										  "<div class='buttons'>"+
										  "<button type='button' "+vBtn+" id='cbn_Save' name='cbn_Save' onClick='f_onClick(this.name);'>Save</button>"+
										  "&nbsp;&nbsp;"+
										  "<button type='button' "+vBtn+" id='cbn_Reset' name='cbn_Reset' onClick='f_onClick(this.name);'>Reset</button>"+
										  "&nbsp;&nbsp;"+
										  "<button type='button' "+vBtn+" id='cbn_Cancel' name='cbn_Cancel' onClick='location.href=\"admin_main.cfm\"'>Cancel</button>"+							  										  "&nbsp;&nbsp;"+
										  "<button type='button' "+vBtn+" id='cbn_Graph' name='cbn_Graph' onClick='f_onClick(this.name);'>Graph</button>"+
										  "</div>"+
							  		  "</td>"+
							  	  "</tr>"
							  "</table>";
				
				v_OutputTbl = v_OutputTbl + v_OutputCbn;	 
				//	
// Creating OUTPUT ends: =======================================================================================================
// Setting Data on the screen starts: ==========================================================================================
				//$("##contentAllotData").html(v_OutputTbl);
				$("#div_contentAllotData").html(v_OutputTbl);
// Setting Data on the screen ends: ============================================================================================
				 
				 //f_buildChart();

			} //end of setting ".success: function... "
			,error: function(serializedAllotmentJSON,statusTxt,xhr){
				alert("Error: "+xhr.status+": "+xhr.statusText);
			}//end of setting ".error"
	}); // end of $.ajax
}// end of f_getAllotData
//
//----------------------------------------------------------------------------------------------------------
//
function f_onKeyUp(arg_CtrlName){with(self.document.forms["frmJCA"]) 
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
			//alert("You must enter a valid, non-negative number.");
			
			v_CtrlValue = v_CtrlValue.substr(0,i)+v_CtrlValue.substr(i+1, v_CtrlValue.length);
			eval(v_CtrlName+".value=\""+v_CtrlValue+"\"");
			eval(v_CtrlName+".focus();");
			alert("You must enter a valid, non-negative number that does not have leading \"0\".");
			break;
		}
	}
}}
//
//----------------------------------------------------------------------------------------------------------
//
function f_onFocus(arg_CtrlName){with(self.document.forms["frmJCA"])
{
	
	of_getCtrlProperties(arg_CtrlName);
	
	f_msgShowHide("HIDE");
	
	//var v_txtCtrlNm    = arg_CtrlName; //Ex: txt_OPS_2_2011
	if (v_CtrlValue == "0")
	{
		document.getElementById(v_CtrlName).value = "";
	}
	else
	{
		document.getElementById(v_CtrlName).value = f_RemoveCommas(v_CtrlValue); // Remove commas
	}

}}
//
//----------------------------------------------------------------------------------------------------------
//
function f_onBlur(arg_CtrlName){with(self.document.forms["frmJCA"])
{
//........................................................
// COMMENTS: 
// Control Name: txt_OPS_2_2011 or hdn_OPS_2_2011
//               txt: <input type='text'>
//				 hdn: <input type='hidden'>
//				 OPS or CRA: Funding Categories
//				 2: Funding Office Number
//				 2011: Year
//........................................................
	of_getCtrlProperties(arg_CtrlName);
	
	var v_txtCtrlNm    = v_CtrlName; 									//Ex: txt_OPS_2_2011
	var v_txtCtrlValue = v_CtrlValue;
	
	var v_hdnCtrlNm    = "hdn"+v_CtrlName.substring(3); 				//Ex: hdn_OPS_2_2011
	var v_hdnCtrlValue = document.getElementById(v_hdnCtrlNm).value;
	
	// No changes were made.  Cursor was in one of the "txt_" controls where value is not "0" and after that removed:
	if ( v_txtCtrlValue == v_hdnCtrlValue  && v_txtCtrlValue != "")
	{
		document.getElementById(v_txtCtrlNm).value = f_AddCommas(v_txtCtrlValue);
	}
	// No changes were made.  Cursor was in one of the "txt_" controls where value is "0" and after that removed:
	else if (v_txtCtrlValue == "" && v_hdnCtrlValue == "0" )
	{
		document.getElementById(v_txtCtrlNm).value = "0";
	}
	else if (v_txtCtrlValue == "" && v_hdnCtrlValue != "0" )
	{
		document.getElementById(v_txtCtrlNm).value = "0";
	}
	//
	f_calcSubtotalAndTotal(v_txtCtrlNm);
}}
//
//----------------------------------------------------------------------------------------------------------
//
function f_calcSubtotalAndTotal(arg_CtrlName){with(self.document.forms["frmJCA"])
{
	of_getCtrlProperties(arg_CtrlName);
	//alert("SubTot   "+v_CtrlValue+"   "+isNaN(v_CtrlValue) );
	if ( !isNaN(v_CtrlValue) )
	{	
			var v_FundCat = v_CtrlName.substr(v_CtrlName.indexOf("_")+1, // =4 is the first position where Funding Category("OPS" or "CRA") starts after "txt_".
											  v_CtrlName.substring( v_CtrlName.indexOf("_")+1 ).indexOf("_") // =3 is lenght of the string of Funding Category.
											  );//Result Ex: OPS or CRA
			
			var v_FundOfficeNum;
			var v_Year = v_CtrlName.substring(v_CtrlName.length-4); // Ex: 2010
			
			var v_SubtotalNew = 0;
			var v_SubtotalOld = document.getElementById("sub_"+v_FundCat+"_"+v_FundCat+"_"+v_Year).innerHTML;
				v_SubtotalOld = f_RemoveCommas(v_SubtotalOld);
			
			var v_TotalNew = 0;
			var v_TotalOld = document.getElementById("tot_ATOTAL_TOTAL_"+v_Year).innerHTML;
				v_TotalOld = f_RemoveCommas(v_TotalOld);
		
				for (var e=0; e<elements.length; e++)
				{
					if (elements[e].type == "text" && 
						elements[e].name.substr(0,4) == "txt_" &&
						v_FundCat == elements[e].name.substr(elements[e].name.indexOf("_")+1, elements[e].name.substring( elements[e].name.indexOf("_")+1 ).indexOf("_") ) &&
						v_Year == elements[e].name.substring(elements[e].name.length-4) )	
					{
						v_FundOfficeNum = elements[e].name.substring( ("txt_"+v_FundCat+"_").length,   ((elements[e].name.length)-(v_Year.length+1)) ); //Ex: 1, or 2..,or 20
						
						of_getCtrlProperties( "txt_"+v_FundCat+"_"+v_FundOfficeNum+"_"+v_Year );
						v_CtrlValue = f_RemoveCommas(v_CtrlValue.toString());
						v_SubtotalNew = parseInt(v_SubtotalNew) + parseInt(v_CtrlValue);
					}
				}
				
				//alert(parseInt(v_SubtotalNew) +"  "+ parseInt(v_CtrlValue))
				
				v_TotalNew = parseInt(v_TotalOld) - parseInt(v_SubtotalOld) + parseInt(v_SubtotalNew);
				
				of_getCtrlProperties(arg_CtrlName);
				document.getElementById(arg_CtrlName).value = f_AddCommas(v_CtrlValue);
				
				document.getElementById("sub_"+v_FundCat+"_"+v_FundCat+"_"+v_Year).innerHTML = f_AddCommas(v_SubtotalNew.toString());
				
				document.getElementById("tot_ATOTAL_TOTAL_"+v_Year).innerHTML = f_AddCommas(v_TotalNew.toString());
		
	}
	
}}
//
//----------------------------------------------------------------------------------------------------------
//
function f_onClick(arg_CtrlName){with(self.document.forms["frmJCA"])
{
	var v_CtrlPartialName = "";
	var v_CtrlValue_txt = ""; 
	var v_CtrlValue_hdn = "";
	
	var v_FundCat = "";
	var v_FundOffice = "";
	var v_Year = "";
	var v_ArgString = "";
	var v_Divider = "|";
	
	var v_Subtotal = "";
	var v_Total = "";
	//
	//
	switch(arg_CtrlName)
	{
		//------------------------------------------------------------------------------------
		case "cbn_Save":
		
			for (var e=0; e<elements.length; e++)
			{
				if (elements[e].name.substr(0,4) == "txt_")	
				{
					// Find controls where changes were applied:
					v_CtrlPartialName = elements[e].name.substr(4);
					v_CtrlValue_txt = document.getElementById("txt_"+v_CtrlPartialName).value;
					v_CtrlValue_txt = f_RemoveCommas(v_CtrlValue_txt);
					v_CtrlValue_hdn = document.getElementById("hdn_"+v_CtrlPartialName).value;
					
					// Collect information what was changed:
					if (v_CtrlValue_txt != v_CtrlValue_hdn)
					{
						v_ArgString = v_ArgString+v_Divider+v_CtrlPartialName+"_"+v_CtrlValue_txt;
					}
				}					
			}// End of loop through elements.
			//
			if (v_ArgString == "")
			{
				//alert("no changes.....");
				f_msgShowHide("NO_CHANGES");
			}
			else
			{
				f_updAllotment(v_ArgString);	
			}
			
		break;
		//------------------------------------------------------------------------------------
		case "cbn_Reset":

			for (var e=0; e<elements.length; e++)
			{
				if (elements[e].type == "text" && 
					elements[e].name.substr(0,4) == "txt_" )
				{
					v_CtrlPartialName = elements[e].name.substr(4); 						   // Ex: OPS_1_2009 or CRA_1_2009
					v_CtrlValue_txt = document.getElementById("txt_"+v_CtrlPartialName).value; // Changed value - Ex: 123,456
					v_CtrlValue_txt = f_RemoveCommas(v_CtrlValue_txt.toString());        	   // Changed value - Ex: 123456
					v_CtrlValue_hdn = document.getElementById("hdn_"+v_CtrlPartialName).value; // Originaly retrieved value.
					if (v_CtrlValue_txt != v_CtrlValue_hdn)
					{
						document.getElementById("txt_"+v_CtrlPartialName).value = f_AddCommas(v_CtrlValue_hdn);
						
						f_calcSubtotalAndTotal(elements[e].name);
					}
				}
			}
			f_msgShowHide("HIDE");
		break;
		//------------------------------------------------------------------------------------
		case "cbn_Cancel":
		   //window.history.go(-1);
		break;
		//------------------------------------------------------------------------------------
		case "cbn_Graph":
			f_getGraph();
		break;
		//------------------------------------------------------------------------------------
	}
}}// end of f_onClick
//
//----------------------------------------------------------------------------------------------------------
//
function f_updAllotment(arg_ArgString){with(self.document.forms["frmJCA"])
{//TEST: alert(arg_ArgString)
	 var arrayMethod = { method: 'f_updAllotment'
	 					,argStringForUpdate: arg_ArgString
						,argUserID: v_UserID
					   }
	 
	 var jqXHR = $.ajax(
	 			  {
       				  url:  cfcLink
      				 ,type: "POST"
      				 ,data: arrayMethod
     			  })
     			  .success (function(response)
				  {
					    for (var e=0; e<elements.length; e++)
						{
							if (elements[e].name.substr(0,4) == "txt_")	
							{
								// Find controls where changes were applied:
								v_CtrlPartialName = elements[e].name.substr(4);
								v_CtrlValue_txt = document.getElementById("txt_"+v_CtrlPartialName).value;
								v_CtrlValue_hdn = document.getElementById("hdn_"+v_CtrlPartialName).value;
								// Collect information what was changed:
								if (v_CtrlValue_txt != v_CtrlValue_hdn)
								{
									document.getElementById("hdn_"+v_CtrlPartialName).value = f_RemoveCommas(v_CtrlValue_txt.toString());
								}
							}					
						}// End of loop through elements.
			  			//
					  	f_msgShowHide("SHOW");
				  })
				  .error (function(jqXHR, textStatus, errorThrown)
				  {
       				  alert("Error: "+textStatus+": "+errorThrown);
     			  });
	
}}
//
//----------------------------------------------------------------------------------------------------------
//
function f_msgShowHide(arg_Action){with(self.document.forms["frmJCA"])
{
	var v_Msg = "&nbsp;";
	var v_ClassName = "confirmList";
	var v_TrueFalse = true;

	if (arg_Action == "SHOW")//
	{
		v_Msg = "Your changes have been saved. Return to the <a href='<cfoutput>#application.paths.admin#</cfoutput>'>Admin Section</a>."
		v_TrueFalse = true;
		
	}
	else if (arg_Action == "HIDE")//
	{
		v_Msg = "&nbsp;";	
		v_TrueFalse = false;
	}
	else if (arg_Action == "NO_CHANGES")
	{
		v_Msg = "No changes have been made.";
		v_TrueFalse = true;
	}
			
	$("#div_SaveMsg").toggleClass(v_ClassName, v_TrueFalse);
	$("#div_SaveMsg").html(v_Msg);

}}
//
//----------------------------------------------------------------------------------------------------------
//
function f_getGraph(){with(self.document.forms["frmJCA"])
{
	//window.open("job_corps_allots_graph_Examples.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("job_corps_allots_graph.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("job_corps_allots_D3.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("D3_Tree.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("D3_Circle.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("job_corps_allots_D3_scale.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("getGraphTest.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	window.open("job_corps_allots_graph_CFCHART_ORG.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	
	//window.open("getGroupedBar.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("../Tableau/Lesson1/getTableau1.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("../Tableau/Lesson2/getTableau2.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("../Tableau/Lesson3_Filtering/getTableau3.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("../Tableau/Tableau.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
	//window.open("job_corps_allots_D3.cfm",null,"height=800,width=1000,status=yes,toolbar=no,menubar=yes,location=no, scrollbars=yes, resizable=yes");
}}

</script>


	
