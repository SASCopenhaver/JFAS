<cfoutput>

<script language="javascript">

var cfcLink = 'http://#cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes';

var arrayData = {
					method:					'fGetJobCorpsAllot'
				   ,argFirstYearInPeriod:	'2009'
				   ,argLastYearInPeriod:	'2016'
				};
				
//alert(arrayData.argFirstYearInPeriod);
//alert(cfcLink)


$.ajax({
		type:	'POST'
	   ,url:	cfcLink
	   ,data:	arrayData
	   ,success: function(responseStructJSON,statusTxt,xhr){
			//alert("External content loaded successfully...!");
			
			//alert(responseStructJSON);
			sSelectAllotment = $.parseJSON( responseStructJSON );
			//responseStruct	= $.parseJSON( responseStructJSON );
			//sSelectAllotment	= responseStruct.SPR_SELECTALLOTMENT;
			
			alert(jsdump(sSelectAllotment));
			alert(sSelectAllotment.DATA[1][4]);
			//sFilterHTML		= responseStruct.SFILTERHTML;
			//alert(sFilterHTML);

			// display the filter string
			//$("##jfasHeaderStatus").html(sFilterHTML);

			// display the data in columns
			//$("##jfasDataDiv").html(sColumnsOfData);

			//adjustHomeDivs();

			}
		, error: function(responseStruct,statusTxt,xhr){
			alert('in error in displayAAPPsAjax');
			alert("Error: "+xhr.status+": "+xhr.statusText);
			}
		}
);

alert(url)

</script>

</cfoutput>

																	