
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Job Corps Allotments</title>
<cfoutput>
	<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>    
</cfoutput>
<script src="../includes/javascript/jfas.js"></script>
<script src="http://d3js.org/d3.v3.min.js"  charset="utf-8"></script>

</head>
<body class="form">
<form name="frmJCA" id="frmJCAG"><!--- JCAG: Job Corps Allotments Graph --->
<br />div_JSON starts<br />
	<div id="div_JSON"></div>
<br /><br />div_JSON ends<br />

<script>
//var v_AllotRecordSet = "";
var cfcLink = '<cfoutput>'+'#application.urlstart##cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes'+'</cfoutput>';
var arrayData = {method: "f_getAllotmentGraph"};
/*
$(document).ready(function(){
	var jqXHR = $.ajax({
						 url: 	cfcLink
						,type:	"GET"
						,dataType:"json"
						,data:	arrayData
				 })
				 .success (function(objResponseCFC_JSON, statusTxt, xhr){
					 //TEST: alert(JSON.stringify(oResponseCFC_JSON)); 	 
					 //TEST: 
					 alert("1\n"+jsdump(objResponseCFC_JSON))
					 //TEST: works until ',dataType:"json" 'is set: $('#div_JSON').html(oResponseCFC_JSON);
					 
					 f_Draw( f_makeWorkableJSON(objResponseCFC_JSON) );
						
				 })
				 .error (function(jqXHR, statusTxt, errorThrown){
				 		alert("Error: "+statusTxt+": "+errorThrown);
				 });
});	
*/
// TEST starts:--------------------------------------------------------------------------
var jsonCircles = [ { "x_axis": 30, "y_axis": 30, "radius": 20, "color" : "green" },
  					{ "x_axis": 70, "y_axis": 70, "radius": 20, "color" : "purple"},
              		{ "x_axis": 110, "y_axis": 100, "radius": 20, "color" : "red"}
				  ];
var svgContainer = d3.select("body").append("svg")
                                    .attr("width", 200)
                                    .attr("height", 200);
var circles = svgContainer.selectAll("circle")
                          .data(jsonCircles)
                          .enter()
                          .append("circle");
// Test ends.------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
function f_makeWorkableJSON(arg_JSON)
{
    var s = arg_JSON || {};
    if( !s.COLUMNS && !s.DATA )
    {
        console.error("convertColdFusionJSON() >>  was not passed a coldfusion serialized object");
        return [];
    }
    //Create returned object
    var obj = [];
    //Loops through serialObj and matches the columns
    for(var i=0; i < s.DATA.length; i++)
    {
        var temp = {};
        for(var j=0; j < s.COLUMNS.length; j++)
        {
            temp[s.COLUMNS[j]] = s.DATA[i][j];
		}
        // save the new row with column names
        obj.push(temp);
    }
	// TEST: 
	alert(jsdump(obj));
	// Return the objects
    return obj;

}
//----------------------------------------------------------------------------------------------
function f_Draw(arg_WorkableJSON)
{// TEST: alert(JSON.stringify(arg_WorkableJSON)); 
 // TEST: d3.select("#div_JSON").append("p").text(v_Data);

	//var v_Data = JSON.stringify(arg_WorkableJSON);
//var objData2 = jQuery.extend(true, {}, arg_WorkableJSON);	
alert(jsdump(arg_WorkableJSON))



var objData1 = [{"FUNDING_OFFICE_NUM":1,"ALLOTMENT_AMOUNT":1234567},
				{"FUNDING_OFFICE_NUM":2,"ALLOTMENT_AMOUNT":1234567},
				{"FUNDING_OFFICE_NUM":3,"ALLOTMENT_AMOUNT":456465},
				{"FUNDING_OFFICE_NUM":4,"ALLOTMENT_AMOUNT":84925234},
				{"FUNDING_OFFICE_NUM":5,"ALLOTMENT_AMOUNT":97214306},
				{"FUNDING_OFFICE_NUM":6,"ALLOTMENT_AMOUNT":96911607},
				{"FUNDING_OFFICE_NUM":20,"ALLOTMENT_AMOUNT":92048970}];

var circleAttributes = circles
                       .attr("cx", function (d) { return d.x_axis; })
                       .attr("cy", function (d) { return d.y_axis; })
                       .attr("r", function (d) { return d.radius; })
                       .style("fill", function(d) { return d.color; });

	var v_Canvas = d3.select("body")
						.append("svg")
							.attr("width", 1000)
							.attr("height", 1000);
	var c_Circle = v_Canvas.selectAll("circle")
							.data(objData1)
							.enter()
							.append("circle");
	var circleAttributes = c_Circle
							.attr("cx", function(d){return d.FUNDING_OFFICE_NUM*30;})
							.attr("cy", function(d){return d.ALLOTMENT_AMOUNT/1000000;})
							.attr("r",function(d){return d.FUNDING_OFFICE_NUM;})
							.attr("fill", function(d){return "green";});
}
//----------------------------------------------------------------------------------------------
// DOM elements < Data elements --> (enter)
// DOM elements > Data elements --> (exit)
// DOM elements = Data elements --> (update)

			


</script>
</form>
</body>
</html>