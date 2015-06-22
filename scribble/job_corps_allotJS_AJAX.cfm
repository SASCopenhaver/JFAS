<cfoutput>

<script language="javascript">
//alert('http://#cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes')
var cfcLink = 'http://#cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes';

var arrayData = {
					method:					'fGetJobCorpsAllot'
				   ,argFirstYearInPeriod:	'2012'
				   ,argLastYearInPeriod:	'2014'
				};
				
//alert(arrayData.argFirstYearInPeriod);
//alert(cfcLink)

orgBfrColumnNames = new Array(); // Original Buffer of Column Names
updBfrColumnNames = new Array(); // Updated Buffer of Column Names


	$.ajax({
			type:	'GET'
		   ,url:	cfcLink
		   ,data:	arrayData
		   ,success: function(serializedAllotmentJSON,statusTxt,xhr){
				//alert(serializedAllotmentJSON)
				var v_AllotRecordSet = $.parseJSON( serializedAllotmentJSON );
				var v_RowCount = v_AllotRecordSet.ROWCOUNT;
				var v_Columns = v_AllotRecordSet.COLUMNS;
				var v_NumOfColumns = v_AllotRecordSet.COLUMNS.length; //alert(v_NumOfColumns);
				var v_Data = v_AllotRecordSet.DATA;
				
				for (var c=0; c<v_NumOfColumns; c++)
				{
					alert(v_Columns[c]);
				}		
				
				//alert(jsdump(v_AllotRecordSet));
				/*
				for(var i in v_AllotRecordSet){
				  for(var j in v_AllotRecordSet[i]){
					alert(v_AllotRecordSet[i][j]);
				  }
				}
				*/
				$("##contentAllot").html(v_Data);
				
				
				
			} //end of setting ".success: function... "
			, error: function(serializedAllotmentJSON,statusTxt,xhr){
				alert('in error in displayAAPPsAjax');
				alert("Error: "+xhr.status+": "+xhr.statusText);
			}//end of setting ".error"
	}); // end of $.ajax


</script>

</cfoutput>

																	