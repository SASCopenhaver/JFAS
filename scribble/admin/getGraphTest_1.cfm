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
var arrayData = {method: "f_getGraphTest"};

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
					//
					$("#div_Data").html(jsdump(objAllotmentGraph_JSON) );
					
					var parsedJSON = $.parseJSON(objAllotmentGraph_JSON);
					
					f_Draw( parsedJSON );
					
					
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
function f_Draw(arg_parsedJSON){
	
	//	"spr_Timeline"
	//	"spr_graphTotals"
	//	"spr_graphCRA"
	//	"spr_graphOPS"
	var objDatum  = arg_parsedJSON || {};
	var v_ResultSetName = "";
	
	var v_CanvasWidth  = 800; // Default value
	var v_CanvasHeight = 600; // Default value
	var v_BarHeight = 40;
	var v_SpaceBetwBars = 5;
	
	var v_ScaleFactor = 100000;
	
	var v_Value  = 0;
	var v_MaxVal = 0;
	var v_MinVal = 0;	

	// Loop through the result sets in "objDatum".
	$.each(objDatum, function(key){
            // TEST: alert(i); //spr_Timeline | spr_graphTotals | spr_graphCRA | spr_graphOPS
			v_ResultSetName = key;
			//alert(v_ResultSetName+"   "+ jsdump(objDatum[key]) )
			if (v_ResultSetName === "spr_graphTotals")
			{
				
				//alert(v_ResultSetName+"   "+ jsdump(objDatum[key]) )
				
				//oDatumTotals = f_makeWorkableJSON( objDatum.spr_graphTotals);
				oDatumTotals = f_makeWorkableJSON( eval("objDatum."+v_ResultSetName) );
				
				alert(" sas \n"+jsdump(oDatumTotals))
	
				
				for ( var t in oDatumTotals )
				{
					oDatumTotalOPS    = oDatumTotals[0];
					oDatumTotalCRA    = oDatumTotals[1];
					oDatumTotalOPSCRA = oDatumTotals[2];
				}
				// TEST: 
				//alert("OPS:\n"+JSON.stringify(oDatumTotalOPS)+"\nCRA:"+JSON.stringify(oDatumTotalCRA)+"\nOPS CRA:"+JSON.stringify(oDatumTotalOPSCRA) );
				// TEST: $('#div_Data').html(JSON.stringify( datumTotalOPSCRA));
				//
				
			
			
//				// ** LINES ** from aapp_line1.cfm
//
//	// Draw the FOP line. Use .data([fopdat]) to bind fopdat to a single svg element
//	svg.append("path")
//		.data([fopdat])
//		.attr("id", "fopline")
//		.attr("class", "fopclass")
//		.attr("active", false)
//		.attr("d", fopline);

				
				
				
				
				
//				(function()
//				{
//					var oDataOPSCRA = oDatumTotalOPSCRA.slice();
//					
//					
//				})();	// end of namless function 
			}
			
			
	});	// end of $.each

}  // end of f_Draw()
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
// f_SortJsonArray works, but not used in this csript.
function f_SortJsonArray(arg_Array, arg_Property){
	var v_arrayToBeSorted = arg_Array;
	
	return v_arrayToBeSorted.sort(function(a,b) 
	{ 
    	return a[arg_Property] < b[arg_Property];
    });	
}
//=============================================================================================
function f_getMaxMinJsonValue(arg_Array, arg_Property, arg_MaxOrMin) {
	// TEST: alert(JSON.stringify(arg_Array))
	
	var v_RtnVal  = 0
	var v_TempVal = 0;
	//
	var v_MinVal = 0;
	var v_MaxVal = 0;

//	for (var v=0; v<arg_Array.length; v++)
//	{
//		v_TempVal = JSON.stringify(arg_Array)+"["+v+"]."+arg_Property;
//		//alert( eval(arg_Array[v].arg_Property) )
//		
//		if (arg_MaxOrMin == "MAX"){if (v_TempVal >= v_RtnVal){v_RtnVal = v_TempVal}}
//		else if (arg_MaxOrMin == "MIN"){ if (v_TempVal <= v_RtnVal){v_RtnVal = v_TempVal}}
//	}
	


}
//=============================================================================================
function f_Draw(arg_WorkableJSON){
// TEST 1: alert(jsdump(arg_WorkableJSON))
// TEST 2: $('#div_JSON').html(arg_WorkableJSON);
// TEST 3: alert(JSON.stringify(arg_WorkableJSON)); 

	
}
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
/*//Working code starts:
function f_Draw(arg_WorkableJSON){
	// TEST: alert(jsdump(arg_WorkableJSON))
	//var arraySort = arg_WorkableJSON;
	
	var v_Data  = arg_WorkableJSON;
	var v_CanvasWidth  = 800; // Default value
	var v_CanvasHeight = 600; // Default value
	var v_BarHeight = 40;
	var v_SpaceBetwBars = 5;
	
	var v_ScaleFactor = 200000;
	
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
	v_CanvasHeight = Math.round((v_Data.length*v_BarHeight)+(2*v_SpaceBetwBars));
	//TEST:	alert(v_MaxVal+"   "+v_MinVal+"   "+v_Data.length+"   "+v_CanvasWidth+"   "+v_CanvasHeight);
	//-----------------------------------------------------------------------------------
	var v_WidthScale = d3.scale.linear()
							.domain([0, Math.round(v_MaxVal/v_ScaleFactor)])
							.range( [0, v_CanvasWidth]);
							
	var v_Color = d3.scale.linear()
							.domain([0, Math.round(v_MaxVal/v_ScaleFactor)])
							.range(["red", "blue"]);
							
	var v_Canvas = d3.select("#div_Graph")
						.append("svg")
						.attr("width", v_CanvasWidth)
						.attr("height", v_CanvasHeight);
	
	var v_Bars = v_Canvas.selectAll("rect")
							.data(v_Data)
							.enter()
								.append("rect")
								.attr("width", function(d){return v_WidthScale(d.ALLOTMENT_AMOUNT/200000);})
								.attr("height", v_BarHeight - v_SpaceBetwBars )
								.attr("fill", function(d){ return v_Color(d.ALLOTMENT_AMOUNT/200000);})
								.attr("y", function(d,i){ return i*v_BarHeight;});//

	var v_Text = v_Canvas.selectAll("text")
							.data(v_Data)
							.enter()
								.append("text")
								.attr("fill", "green")
								.attr("y", function (d, i) { return i*v_BarHeight + (v_BarHeight/2); })
								.text(function(d) {return d.FUND_CAT+"-"+d.FUNDING_OFFICE_DESC+"  "+d.ALLOTMENT_AMOUNT});


}

*/
//=============================================================================================
</script>
</form>
</body>
</html>
<!---
//---------------------------------------------------------------------------------------------
//CODE SAMPLE:
					//oDatumTotals = parsedJSON.spr_graphTotals.DATA;	//TEST:	alert(oDatumTotals)
					//datumOPS 	  = parsedJSON.spr_graphOPS.DATA;		//TEST: alert(datumOPS)
					//datumCRA 	  = parsedJSON.spr_graphCRA.DATA;		//TEST: alert(datumCRA)
					//
					
					
					//f_TestDraw(datumTimeline);
					
					////jsonTest = JSON.parse(objAllotmentGraph_JSON);
					////alert(JSON.stringify(jsonTest.spr_graphTotals));
					////alert( JSON.stringify( f_makeWorkableJSON( jsonTest.spr_graphTotals)))
					////$('#div_JSON').html(JSON.stringify( f_makeWorkableJSON( jsonTest.spr_graphTotals)));


//--------------------------------------------------------------------------------------------->