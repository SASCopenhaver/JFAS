<!--- 
<cfinvoke component="#application.paths.root#/model/cfc/job_corps_allots" 
		  method="f_testJSON"
          returnvariable="spr">
          <!---returnvariable="spr_GraphFOPallocation">--->
    <cfinvokeargument name="argAAPPnum" value="5457">
</cfinvoke>
spr:<br/>
<cfdump var="#spr#">
<cfabort> --->


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
	div_Circle Starts:
    <div id="div_Circle"></div>
    div_Circle ends.
    <div id="div_Dump"></div>
<script>
//=============================================================================================					
//Test is based on youtube video #10 D3.js Tutorial:
function f_jsonCircles(){

	
		var jsonCircles = [ { "x_axis": 30, "y_axis": 30, "radius": 20, "color" : "green" },
							{ "x_axis": 70, "y_axis": 70, "radius": 20, "color" : "purple"},
							{ "x_axis": 110, "y_axis": 100, "radius": 20, "color" : "red"}
						  ];
		
		var svgContainer = d3.select("body").selectAll("#div_Circle").append("svg")
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
//=================================================================================================================
</script>
</form>
</body>
</html>