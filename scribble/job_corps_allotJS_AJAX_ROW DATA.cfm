<cfoutput>

<script language="javascript">
//alert('http://#cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes')
var cfcLink = 'http://#cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes';
//orgBfrColumnNames = new Array(); // Original Buffer of Column Names
//updBfrColumnNames = new Array(); // Updated Buffer of Column Names
v_TblAllot = "<table class='table table-striped table-bordered'>";
function f_getAllotData(argFirstYearInPeriod, argLastYearInPeriod)
{
	var arrayData = { method:				'fGetJobCorpsAllot'
				     ,argFirstYearInPeriod:	argFirstYearInPeriod
				     ,argLastYearInPeriod:	argLastYearInPeriod
					};	

	$.ajax({
			type:	'GET'
		   ,url:	cfcLink
		   ,data:	arrayData
		   ,success: function(serializedAllotmentJSON,statusTxt,xhr){
				//alert(serializedAllotmentJSON)
				
				var v_AllotRecordSet = $.parseJSON( serializedAllotmentJSON ); //alert(jsdump(v_AllotRecordSet));
				//var v_RowCount = v_AllotRecordSet.ROWCOUNT;alert(v_RowCount) 
				var v_RowCount = v_AllotRecordSet.DATA.length; //17: from 0 to 16
				
				var v_Columns = v_AllotRecordSet.COLUMNS;
				var v_NumOfColumns = v_AllotRecordSet.COLUMNS.length; // alert(isNaN(v_NumOfColumns)) //16: from 0 to 15
				
				//for (var c=0; c<v_NumOfColumns; c++){alert(c+"   "+v_Columns[c]);}
					
				for (var r=0; r<v_RowCount; r++)
				{
					v_TblAllot = v_TblAllot+"<tr>";
					for (var c=0; c<v_NumOfColumns; c++)
					{//alert(r+"   "+c+"   "+v_AllotRecordSet.DATA[r][c]);
						v_TblAllot = v_TblAllot+"<td>"+v_AllotRecordSet.DATA[r][c]+"</td>";
					}
					v_TblAllot = v_TblAllot+"</tr>";
				}
				v_TblAllot = v_TblAllot+'</table>';
				
				$("##contentAllot").html(v_TblAllot);
				
			} //end of setting ".success: function... "
			, error: function(serializedAllotmentJSON,statusTxt,xhr){
				alert('in error in displayAAPPsAjax');
				alert("Error: "+xhr.status+": "+xhr.statusText);
			}//end of setting ".error"
	}); // end of $.ajax
}

</script>

</cfoutput>

																	