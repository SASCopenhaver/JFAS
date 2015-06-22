<!---
function within component job_corps_allots.cfc
         <cffunction name="f_getAllotmentGraph" access="remote" returntype="any" returnformat="plain" output="no" hint="AJAX call for JSON">
                <cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_getAllotmentGraph" returncode="no" >
                    <cfprocresult name="spr_getAllotmentGraph" resultset="1">
                </cfstoredproc>
                
                <cfreturn SerializeJSON(spr_getAllotmentGraph)>
				
        </cffunction> 
--->
<!--- job_corps_allots_graph.cfm --->
<!---<cfinvoke component="#application.paths.root#/model/cfc/job_corps_allots" method="f_getAllotmentAsCSV" returnvariable="rtn_getAllotmentAsCSV"></cfinvoke>
<cfdump var="#spr_getAllotmentGraph#"><cfabort>--->
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Job Corps Allotments</title>
<cfoutput>
	<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>    
</cfoutput>
<!---<script src="../includes/javascript/jfas.js"></script>--->
<script src="http://d3js.org/d3.v3.min.js"  charset="utf-8"></script>

</head>
<body class="form">
<form name="frmJCA" id="frmJCAG"><!--- JCAG: Job Corps Allotments Graph --->

    div_JSON starts
    <div id="div_JSON">div_JSON inside</div>
    div_JSON ends

    <div id="div_Graph">div_Graph</div>

P starts
<p></p>
P ends
<script>
var cfcLink = '<cfoutput>'+'#application.urlstart##cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes'+'</cfoutput>';
var arrayData = {method: "f_getAllotmentGraph"};


$(document).ready(function(){
	var jqXHR = $.ajax({
						 url: 	cfcLink
						,type:	"GET"
						//,dataType:"json"
						,data:	arrayData
				 })
				 .success (function(objResponseCFC_JSON, statusTxt, xhr){
					 //TEST1: alert(JSON.stringify(objResponseCFC_JSON)); 	 
					 //TEST2: alert("1\n"+jsdump(objResponseCFC_JSON))
					 //TEST3: works until ',dataType:"json" 'is set: $('#div_JSON').html(objResponseCFC_JSON);
					 
					 f_Draw( f_makeWorkableJSON( $.parseJSON(objResponseCFC_JSON) ) );
						
				 })
				 .error (function(jqXHR, statusTxt, errorThrown){
				 		alert("Error: "+statusTxt+": "+errorThrown);
				 });
});	
//---------------------------------------------------------------------------------------------

function f_makeWorkableJSON(arg_JSON){
	
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
	// TEST1: alert("f_makeWorkableJSON \n"+jsdump(obj));
	// TEST2: alert(JSON.stringify(obj));
	//$('#div_JSON').html(JSON.stringify(obj));
	
	// Return the objects
    return obj;

}
//=============================================================================================
var dataArray




//=============================================================================================
// TEST starts:--------------------------------------------------------------------------------
//Test is based on youtube video #10 D3.js Tutorial:
function f_jsonCircles(){
	
		var jsonCircles = [ { "x_axis": 30, "y_axis": 30, "radius": 20, "color" : "green" },
							{ "x_axis": 70, "y_axis": 70, "radius": 20, "color" : "purple"},
							{ "x_axis": 110, "y_axis": 100, "radius": 20, "color" : "red"}
						  ];
		var svgContainer = d3.select("body").selectAll("p").append("svg")
											.attr("width", 200)
											.attr("height", 200);
		var circles = svgContainer.selectAll("circle")
								  .data(jsonCircles)
								  .enter()
								  .append("circle");
		var circleAttributes = circles
                       .attr("cx", function (d) { return d.x_axis; })
                       .attr("cy", function (d) { return d.y_axis; })
                       .attr("r", function (d) { return d.radius; })
                       .style("fill", function(d) { return d.color; });
}
f_jsonCircles();
// Test ends.-----------------------------------------------------------------------------------
//=============================================================================================
//=============================================================================================
</script>
</form>
</body>
</html>