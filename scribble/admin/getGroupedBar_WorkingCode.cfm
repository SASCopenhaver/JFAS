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
<style>

body {
  font: 12px sans-serif;
}

.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.bar {
  fill: steelblue;
}

.x.axis path {
  display: none;
}

</style>
<body class="form">
<form name="frmGraph" id="frmGraph">

    <div id="div_Data">div_Data TEST area</div>
    <div id="div_Graph"></div>
    
    <div id="div_OPS"></div>
    <div id="div_CRA"></div>
    <div id="div_TOTAL"></div>
    
<script>
//=================================================================================================================
// Variable Declaration starts:------------------------------------------------------------------------------------
var cfcLink = '<cfoutput>'+
			  '#application.urlstart##cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes'+
			  '</cfoutput>';
var arrayData = {method: "f_getGroupedBar"};

var jsonTest = {};

var datumTimeline = [],
	//
	oDatumTotals = {},
		oDatumTotalOPS    = {},	// "subset" of oDatumTotals
		oDatumTotalCRA 	  = {},	// "subset" of oDatumTotals
		oDatumTotalOPSCRA = {},	// "subset" of oDatumTotals
	//
	datumOPS = {},
	datumCRA = {};
// Variable declaration ends. -------------------------------------------------------------------------------------	
$(document).ready(function(){

	var jqXHR = $.ajax({
						 url: 	cfcLink
						,type:	"GET"
						,data:	arrayData
				 })
				 .success (function(objAllotmentGraph_JSON, statusTxt, xhr){
					 //TEST1: alert(JSON.stringify(objAllotmentGraph_JSON)); 	 
					 //TEST2: alert("SASjsdump:\n\n"+jsdump(objAllotmentGraph_JSON))
					 //TEST3: $('#div_Data').html(objAllotmentGraph_JSON);
					//$("#div_Data").html("Retrieved Data:\n"+jsdump(objAllotmentGraph_JSON) );
					
					var parsedJSON = $.parseJSON(objAllotmentGraph_JSON);
					
					//$("#div_Data").html("Parsed Data:\n"+JSON.stringify(parsedJSON.spr_GroupedBarOPS) );
					
					
					f_prepareData( parsedJSON );
					
					
//					var parsedJSON = JSON.parse(objAllotmentGraph_JSON);
//					//
//					datumTimeline = parsedJSON.spr_Timeline.DATA;		
//					datumTimeline = "["+datumTimeline+"]";	//TEST: alert(datumTimeline)
//					//
//					datumOPS = f_makeWorkableJSON(parsedJSON.spr_graphOPS);	//TEST: $('#div_Data').html(JSON.stringify( datumOPS));
//					datumCRA = f_makeWorkableJSON(parsedJSON.spr_graphCRA);	//TEST: $('#div_JSON').html(JSON.stringify( datumCRA));
					//
					
									
//					oDatumTotals = parsedJSON.spr_graphTotals;	//TEST: 
//					///*
//					oDatumTotals = f_makeWorkableJSON(parsedJSON.spr_graphTotals);	//TEST: alert(JSON.stringify( oDatumTotals))
//					for ( var t in oDatumTotals ){
//						datumTotalOPS    = oDatumTotals[0];
//						datumTotalCRA    = oDatumTotals[1];
//						datumTotalOPSCRA = oDatumTotals[2];
//					}// TEST:
//					 alert("OPS:\n"+JSON.stringify(datumTotalOPS)+
//								"\nCRA:"+JSON.stringify(datumTotalCRA)+
//								"\nOPS CRA:"+JSON.stringify(datumTotalOPSCRA) );
//								$('#div_Data').html(JSON.stringify( datumTotalOPSCRA));
					//datumTotalOPS    = datumTotalOPS;
					//datumTotalCRA    = datumTotalCRA;
					//datumTotalOPSCRA = datumTotalOPSCRA;
					//$('#div_Data').html(JSON.stringify( datumTotalOPS))
					//
					////f_DrawTotals( datumTotalOPS, datumTotalCRA, datumTotalOPSCRA );
					
					
					//
					//*/
				 })
				 .error (function(jqXHR, statusTxt, errorThrown){
				 		alert("Error: "+statusTxt+": "+errorThrown);
				 });
});
//---------------------------------------------------------------------------------------------
function f_prepareData(arg_parsedJSON){
	var objDatum  = arg_parsedJSON || {};
	var objDatumOPS = arg_parsedJSON.spr_GroupedBarOPS
	//$("#div_Data").html("Parsed Data:\n"+JSON.stringify(objDatumOPS) );
	
	f_drawDatumOPSinD3(f_makeWorkableJSON(objDatumOPS));
	
}	// end of f_prepareData(arg_parsedJSON)
//--------------------------------------------------------------------------------------------
function f_drawDatumOPSinD3(arg_objDatumOPS){
//$('#div_Data').html("arg_objDatumOPS <br>"+JSON.stringify( arg_objDatumOPS));

data = arg_objDatumOPS;

var margin = {top: 20, right: 20, bottom: 30, left: 40},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var x0 = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

var x1 = d3.scale.ordinal();

var y = d3.scale.linear()
    .range([height, 0]);

//var color = d3.scale.ordinal().range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);
var color = d3.scale.category20c()

var xAxis = d3.svg.axis()
    .scale(x0)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")
    .tickFormat(d3.format(".2s"));

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

///// Replacement code:
//d3.csv("data.csv", function(error, data) {var seriesNames = d3.keys(data[0]).filter(function(key) { return key !== "State"; });
var seriesNames = d3.keys(data[0]).filter(function (key) 
{
	 return (key !== "YEARS"); 
});	//alert(seriesNames);

  data.forEach(function(d) {
    d.allots = seriesNames.map(function(name) { return {name: name, value: +d[name]}; });
	//alert(JSON.stringify(d.allots));
  });

  x0.domain(data.map(function(d) { return d.YEARS; }));
  x1.domain(seriesNames).rangeRoundBands([0, x0.rangeBand()]);
  y.domain([0, d3.max(data, function(d) { return d3.max(d.allots, function(d) { return d.value; }); })]);

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("$ Allotments");

  var years = svg.selectAll(".years")
      .data(data)
    .enter().append("g")
      .attr("class", "g")
      .attr("transform", function(d) { return "translate(" + x0(d.YEARS) + ",0)"; });

  years.selectAll("rect")
      .data(function(d) { return d.allots; })
	.enter().append("rect")
      .attr("width", x1.rangeBand())
      .attr("x", function(d) { return x1(d.name); })
      .attr("y", function(d) { return y(d.value); })
      .attr("height", function(d) { return height - y(d.value); })
      .style("fill", function(d) { return color(d.name); });

  var legend = svg.selectAll(".legend")
      .data(seriesNames.slice().reverse())
    .enter().append("g")
      .attr("class", "legend")
      .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

  legend.append("rect")
      .attr("x", width - 18)
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", color);

  legend.append("text")
      .attr("x", width - 24)
      .attr("y", 9)
      .attr("dy", ".35em")
      .style("text-anchor", "end")
      .text(function(d) { return d; });

//});
	
//*/	
}	//end of f_drawDatumOPSinD3
//---------------------------------------------------------------------------------------------
/*
function f_prepareData(arg_parsedJSON){

	var objDatum  = arg_parsedJSON || {};
	var v_ResultSetName = "";

	datumTimeline = objDatum.spr_Timeline.DATA;		
	datumTimeline = "["+datumTimeline+"]";	//TEST: alert(datumTimeline)


	// Loop through the result sets in "objDatum".
	$.each(objDatum, function(key){
            // TEST: alert(i); //spr_Timeline | spr_graphTotals | spr_graphCRA | spr_graphOPS
			v_ResultSetName = key;
			//alert(v_ResultSetName+"   "+ jsdump(objDatum[key]) )
			if (v_ResultSetName === "spr_graphTotals")
			{//alert(v_ResultSetName+"   "+ jsdump(objDatum[key]) )
				oDatumTotals = f_makeWorkableJSON( eval("objDatum."+v_ResultSetName) );	//alert(" sas \n"+jsdump(oDatumTotals))
				//
				for ( var t in oDatumTotals )
				{
					oDatumTotalOPS    = oDatumTotals[0];
					oDatumTotalCRA    = oDatumTotals[1];
					oDatumTotalOPSCRA = oDatumTotals[2];
				}
			}
				// TEST: 
				//alert("OPS:\n"+JSON.stringify(oDatumTotalOPS)+"\nCRA:"+JSON.stringify(oDatumTotalCRA)+"\nOPS CRA:"+JSON.stringify(oDatumTotalOPSCRA) );
				// TEST:$('#div_Data').html(JSON.stringify( oDatumTotals));
				//
// ** LINES ** from aapp_line1.cfm
//	// Draw the FOP line. Use .data([fopdat]) to bind fopdat to a single svg element
//	svg.append("path")
//		.data([fopdat])
//		.attr("id", "fopline")
//		.attr("class", "fopclass")
//		.attr("active", false)
//		.attr("d", fopline);
	});	// end of $.each
	f_drawTotalsInD3(oDatumTotals);
}  // end of f_prepareData()
*/
//---------------------------------------------------------------------------------------------
function f_drawTotalsInD3(arg_oDatumTotals){
$('#div_Data').html("sas <br>"+JSON.stringify( oDatumTotals));

data = arg_oDatumTotals;

// 1. Define margins:
	var v_Margin = {top: 20, right: 10, bottom: 20, left: 10};

//	2. Define width and height as the inner dimensions of the chart area.
	var v_Width  = 960 - v_Margin.left - v_Margin.right,
    	v_Height = 500 - v_Margin.top  - v_Margin.bottom;

// 3. Define "svg" as "g" element that translates the origin to the top-left corner of the chart area.
	var v_Svg = d3.select("body")
					.selectAll("#div_TOTAL")
					  	.append("svg")
						.attr("width",  v_Width + v_Margin.left + v_Margin.right)
						.attr("height", v_Height + v_Margin.top + v_Margin.bottom)
					.append("g")
						.attr("transform", "translate(" + v_Margin.left + "," + v_Margin.top + ")");

// 4. Create "x" and "y" scales:
	//var x = d3.scale.linear().range([0, v_Width]);
	var x0 = d3.scale.ordinal()
    					.rangeRoundBands([0, v_Width], .1);
	var x1 = d3.scale.ordinal();
	
	var y = d3.scale.linear()
				.range([v_Height, 0]);
				
// 5. Create color range:
	var color = d3.scale.category20b();

// 6. Set up the xAxis to use our x0 scale and be oriented on the bottom.
var xAxis = d3.svg.axis()
					.scale(x0)
					.orient("bottom");	

// 7. Set up the yAxis to use "y" scale and be oriented on the left.
//      Additionally, set the tick format to display appropriate labels on the axis (taking out for now).
var yAxis = d3.svg.axis()
					.scale(y)
					.orient("left");
//    .tickFormat(d3.format(".2s"));

//  8. seriesNames = "YEAR_MINUS_3", "YEAR_MINUS_2", "YEAR_MINUS_1", "YEAR_MINUS_0", "YEAR_PLUS_1", and "YEAR_PLUS_2"            
var seriesNames = d3.keys(data[0]).filter(function (key) 
{
	 return (key !== "FUND_CAT") && (key !== "FULL_NAME"); 
});
//TEST: alert(JSON.stringify(seriesNames));
//TEST: alert(seriesNames);

// 9. 
data.forEach(function (d) {
    d.Allots = seriesNames.map(function (name) { return { name: name, value: +d[name] }; });
    //alert("d.Allots: " + JSON.stringify(d.Allots));
});
//alert(JSON.stringify(data));

//10. 
x0.domain(data.map(function (d) { return d.FUND_CAT; } ));

x1.domain(seriesNames).rangeRoundBands([0, x0.rangeBand()]);

y.domain([0, (10 + d3.max(data, function (d) { return d3.max(d.Allots, function (d) { return d.value; }); }))]);

//...
// The axis business
v_Svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + v_Height + ")")
    .call(xAxis);

v_Svg.append("g")
    .attr("class", "y axis")
    .call(yAxis)
.append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 6)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text("# Allotss");


// From this point to...

//var state = svg.selectAll(".state")
//    .data(data)
//.enter().append("g")
//    .attr("class", "g")
//    .attr("transform", function (d) { return "translate(" + x0(d.State) + ",0)"; });

var state = svg.selectAll(".state")
    .data(data)
.enter().append("g")
    .attr("class", "g")
    .attr("transform", function (d) { return "translate(" + x0(d.FUND_CAT) + ",0)"; });

//alert(JSON.stringify(d.Allots[0]));
state.selectAll("rect")
    .data(function (d) { return d.Allots; })
.enter().append("rect")
    .attr("width", x1.rangeBand())
    .attr("x", function (d) { return x1(d.name); })
    .attr("y", function (d) { return y(d.value); })
    .attr("height", function (d) { return vHeight - y(d.value); })
    .style("fill", function (d) { return color(d.name); });


var legend = svg.selectAll(".legend")
    .data(seriesNames.slice().reverse())
.enter().append("g")
    .attr("class", "legend")
    .attr("transform", function (d, i) { return "translate(0," + i * 20 + ")"; });

legend.append("rect")
    .attr("x", width - 18)
    .attr("width", 18)
    .attr("height", 18)
    .style("fill", color);

legend.append("text")
    .attr("x", width - 24)
    .attr("y", 9)
    .attr("dy", ".35em")
    .style("text-anchor", "end")
    .text(function (d) { return d; })
    .on("click", function (d) {
        alert(d);
        //state.selectAll("rect")
        //.update()

        //                        .exit().transition()
        //                            .attr("height", 0)
        //                            .remove();

        //state.selectAll("rect")
        //.update()


        //state.selectAll("rect").exit().transition().attr("height", 0).remove();
    });
	
}	//end of f_drawTotalsInD3()
//---------------------------------------------------------------------------------------------
//function f_DrawTotals(arg_datumTotalOPSCRA){
//	
//	$('#div_Data').html(JSON.stringify( arg_datumTotalOPSCRA));
//	
//	alert()
//	for (var i=0; i<arg_datumTotalOPSCRA.length; i++)
//	{
//		alert(arg_datumTotalOPSCRA[0].FUND_CAT)	
//	}
//	
//	
//	var canvasTotalsWidth  = 800,
//		canvasTotalsHeight = 500;
//	
//	
//	
//	/*	
//	var canvasTotals = d3.select("#div_TOTAL")
//							.append("svg")
//							.attr("width", canvasTotalsWidth)
//							.attr("height",canvasTotalsHeight);
//	
//	//$('#div_JSON').html(JSON.stringify( arg_parsedJSON));
//						
//	var barsTotals = canvasTotals.selectAll("rect")
//									.data(arg_datumTotalOPSCRA)
//									.enter()
//										.append("rect")
//										.attr("width", function(d){return d;})
//										.attr("height", 50)
//										.attr("x", function(d, i){return i*50});
//							
//		
//	//*/
//
//
//
//} // end of f_DrawGraph()

/*
function f_TestDraw(arg_datumTimeline)
{
	var datum = "["+arg_datumTimeline+"]";
	
	var canvasWidth	 = 800,
		canvasHeight = 500;
		
	var v_Canvas = d3.select("#div_Graph")
						.append("svg")
						.attr("width", canvasWidth)
						.attr("height", canvasHeight);
						
	var v_Bars = v_Canvas.selectAll("rect")
							.data(datum)
							.enter()
								.append("rect")
								.attr("width", function(d){return d;})
								.attr("height", function(d){return d;})
								.attr("x", function(d, i){return i});
							
*/						
	
/*	
//+++++++++++++++++++++++++++++++++++++++++	
function f_Scales(){
var dataArray = [10,30,50,60];

var width = 500;
var height = 500;

var widthScale = d3.scale.linear()
					.domain([0, 60])
					.range([0, width]);
					
var color = d3.scale.linear()
				.domain([0,60])
				.range(["yellow", "red"]);

var canvas = d3.select("#div_Graph")
					.append("svg")
					.attr("width", width)
					.attr("height", height);

var bars = canvas.selectAll("rect")
					.data(dataArray)
					.enter()
						.append("rect")
						.attr("width", function(d){return widthScale(d);})
						.attr("height", 50)
						.attr("fill", function(d){return color(d)})
						.attr("y", function(d, i){return i*100;});
}
 f_Scales();
//+++++++++++++++++++++++++++++++++++++++++	

}
*/
//---------------------------------------------------------------------------------------------

function f_makeWorkableJSON(arg_JSON){
	
	//alert("f_makeWorkableJSON  "+arg_JSON)
	
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
	// TEST2: alert("sas  "+JSON.stringify(obj));
	//$('#div_JSON').html(JSON.stringify(obj));
	
	// Return the objects
    return obj;

}
/*
//=============================================================================================
function f_DrawAllotment(arg_WorkableJSON){
	// TEST: alert("SAS:\n"+jsdump(arg_WorkableJSON))
	//var arraySort = arg_WorkableJSON;
	
	var v_Data  = arg_WorkableJSON;
	var v_CanvasWidth  = 800; // Default value
	var v_CanvasHeight = 600; // Default value
	var v_BarHeight = 40;
	var v_SpaceBetwBars = 5;
	
	var v_ScaleFactor = 100000;
	
	var v_Value  = 0;
	var v_MaxVal = 0;
	var v_MinVal = 0;
	//-----------------------------------------------------------------------------------
	for (var p=0; p<v_Data.length; p++){
		
		v_MinVal = v_Data[0].ALLOTMENT_AMOUNT; 
		v_Value  = v_Data[p].ALLOTMENT_AMOUNT;
		
		if (v_Value >= v_MaxVal){v_MaxVal = v_Value}
		if (v_Value <= v_MinVal){v_MinVal = v_Value}
	}
	// TEST: alert(v_MaxVal+"   "+v_MinVal);
	//-----------------------------------------------------------------------------------
	v_CanvasWidth  = Math.round(v_MaxVal/v_ScaleFactor);
	v_CanvasHeight = Math.round((v_Data.length*v_BarHeight)+(2*v_SpaceBetwBars))+50;
	//TEST:	alert(v_MaxVal+"   "+v_MinVal+"   "+v_Data.length+"   "+v_CanvasWidth+"   "+v_CanvasHeight);
	//-----------------------------------------------------------------------------------
	var v_WidthScale = d3.scale.linear()
							.domain([0, Math.round(v_MaxVal/v_ScaleFactor)])
							.range( [0, v_CanvasWidth]);
							
	var v_Color = d3.scale.linear()
							.domain([0, Math.round(v_MaxVal/v_ScaleFactor)])
							.range(["yellow", "red"]);
							
	var v_Axis = d3.svg.axis()
						.scale(v_WidthScale);
	
							
	var v_Canvas = d3.select("#div_Graph")
						.append("svg")
							.attr("width", v_CanvasWidth)
							.attr("height", v_CanvasHeight)
						.append("g")
							.attr("transform", "translate(10, 0)")
								//.call(v_Axis) - "calling here makes graph looks wrong.
								;
	
	var v_Bars = v_Canvas.selectAll("rect")
							.data(v_Data)
							.enter()
								.append("rect")
								.attr("width", function(d){return v_WidthScale(d.ALLOTMENT_AMOUNT/v_ScaleFactor);})
								.attr("height", v_BarHeight - v_SpaceBetwBars )
								.attr("fill", function(d){ return v_Color(d.ALLOTMENT_AMOUNT/v_ScaleFactor);})
								.attr("y", function(d,i){ return i*v_BarHeight;});
	
	var v_Text = v_Canvas.selectAll("text")
						.data(v_Data)
						.enter()
							.append("text")
							.attr("fill", "blue")
							.attr("y", function (d, i) { return i*v_BarHeight + (v_BarHeight/2); })
							.text(function(d) {return d.FUND_CAT+"-"+d.FUNDING_OFFICE_DESC+"  "+d.ALLOTMENT_AMOUNT});
	
	v_Canvas.append("g")
				.attr("transform", "translate(0,290)")
				.call(v_Axis);


	var v_Text = v_Canvas.selectAll("text")
						.data(v_Data)
						.enter()
							.append("text")
							.attr("fill", "magenta")
							.attr("y", function (d, i) { return i*v_BarHeight + (v_BarHeight/2); })
							.text(function(d) {return d.FUND_CAT+"-"+d.FUNDING_OFFICE_DESC+"  "+d.ALLOTMENT_AMOUNT});


}
//=============================================================================================

//Test is based on youtube video #10 D3.js Tutorial:
function f_jsonCircles(){
	
		var jsonCircles = [ { "x_axis": 30, "y_axis": 30, "radius": 20, "color" : "green" },
							{ "x_axis": 70, "y_axis": 70, "radius": 20, "color" : "purple"},
							{ "x_axis": 110, "y_axis": 100, "radius": 20, "color" : "red"}
						  ];
		var svgContainer = d3.select("#div_JSON").selectAll("p").append("svg")
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
*/

// Test ends.----------------------------------------------------------------------------------
//=============================================================================================

</script>
</form>
</body>
</html>
