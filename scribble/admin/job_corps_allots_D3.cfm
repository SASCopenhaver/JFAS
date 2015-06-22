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

<div id="div_Circle"></div>


    div_JSON starts
    <div id="div_JSON">div_JSON inside</div>
    div_JSON ends
<div id="div_Data"></div>
    <div id="div_Graph"></div>
    
    <div id="div_Graph2">div_Graph2</div>
<script>
//=================================================================================================================
var cfcLink = '<cfoutput>'+'#application.urlstart##cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes'+'</cfoutput>';
var arrayData = {method: "f_getFundOfficeAllotment"};

$(document).ready(function(){
	var jqXHR = $.ajax({
						 url: 	cfcLink
						,type:	"GET"
						//,dataType:"json"
						,data:	arrayData
				 })
				 .success (function(objAllotmentGraph_JSON, statusTxt, xhr){
					 //TEST1: alert(JSON.stringify(objAllotmentGraph_JSON)); 	 
					 //TEST2: alert("SASjsdump:\n\n"+jsdump(objAllotmentGraph_JSON))
					 //TEST3: works until ',dataType:"json" 'is set: $("#div_Dump").html( f_makeWorkableJSON( $.parseJSON(objAllotmentGraph_JSON) )) ;
					 
					 //$("#div_Data").html(jsdump(objAllotmentGraph_JSON)) ;
					 $("#div_Data").html(JSON.stringify(objAllotmentGraph_JSON) );
					 
					 f_DrawAllotment( f_makeWorkableJSON( $.parseJSON(objAllotmentGraph_JSON) ) );
					 //f_DrawFundOfficeAllotment( $.parseJSON(objAllotmentGraph_JSON) ) ;
						
				 })
				 .error (function(jqXHR, statusTxt, errorThrown){
				 		alert("Error: "+statusTxt+": "+errorThrown);
				 });
});

//=============================================================================================
function f_DrawAllotment(arg_WorkableJSON){
	// TEST: 
	alert("SAS:\n"+jsdump(arg_WorkableJSON))
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
	

/*	
// Same as above, but using Array Sorting:
    var v_SortedArray = f_SortJsonArray(arg_Array, arg_Property);
	var v_MinVal = parseInt(v_SortedArray[v_SortedArray.length-1][arg_Property]);
	var v_MaxVal = parseInt(v_SortedArray[0][arg_Property]);
	
	 TEST: alert(v_MaxVal+"   "+v_MinVal)
	
	if (arg_MaxOrMin == "MAX")
	{
		return v_MaxVal;
	}
	else //(arg_MaxOrMin == "MIN")
	{
		return v_MinVal;
	}
//*/

}
//=============================================================================================	
//---------------------------------------------------------------------------------------------
/*<!---
(function(){ // Anonymous function. For details, see Jerome Cukier: Communication with data. Getting beyond hello world with d3. 
		function f_getAAPP_Center_Contractor(argVenue){
		//
			var v_Url    = '<cfoutput>'+'#application.urlstart##cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes&argVenue=CALIFORNIA'+'</cfoutput>';
			var v_Method = {method: "f_getAAPP_Center_Contr"};
			$(document).ready( function(){
					var jsonData = $.ajax({
												url:	v_Url
											   ,type:	"GET"
											   ,data:	v_Method
											 })
									   .success (function(objAllotmentGraph_JSON, statusTxt, xhr){
												//TEST1: alert(JSON.stringify(objAllotmentGraph_JSON)); 	 
												//TEST2: alert("1\n"+jsdump(objAllotmentGraph_JSON))
												//TEST3: works until ',dataType:"json" 'is set: $('#div_JSON').html(objAllotmentGraph_JSON);
								 
												f_Draw( f_makeWorkableJSON( $.parseJSON(objAllotmentGraph_JSON) ) );
												
								
											})
									   .error (function(jqXHR, statusTxt, errorThrown){
												alert("Error: "+statusTxt+": "+errorThrown);
						 });
									  
				}//end of unnamed function
			);
		}// end of f_getAAPP_Center_Contr
		f_getAAPP_Center_Contractor('CALIFORNIA');
})();
---> */
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
	// TEST2: alert("sas  "+JSON.stringify(obj));
	// TEST3: $('#div_Dump').html(JSON.stringify(obj));
	
	// Return the objects
    return obj;

}

function f_Draw(arg_WorkableJSON){
// TEST 1: alert(jsdump(arg_WorkableJSON))
// TEST 2: $('#div_JSON').html(arg_WorkableJSON);
// TEST 3: alert(JSON.stringify(arg_WorkableJSON)); 

	
}

// TEST starts:--------------------------------------------------------------------------------
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

var canvas = d3.select("#div_Graph2")
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
//=============================================================================================					
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
// Test ends.----------------------------------------------------------------------------------
//=============================================================================================
///*//Working code starts:
function f_DrawFundOfficeAllotment(arg_WorkableJSON){
	// TEST: 
	alert(111)
	//var arraySort = arg_WorkableJSON;
/*
	
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

*/
}

//*/
//=============================================================================================
</script>
</form>
</body>
</html>