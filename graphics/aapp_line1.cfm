<!--- aapp_line1.cfm   (AAPP Funding Comparison Chart) --->
<!--- based on http://www.janwillemtulp.com/2011/04/01/tutorial-line-chart-in-d3/
	simple date axis at http://bl.ocks.org/phoebebright/3059392
	time scales: https://github.com/mbostock/d3/wiki/Time-Scales
	time chart example: http://bl.ocks.org/mbostock/3883245
	adding tool tips: http://www.d3noob.org/2013/01/adding-tooltips-to-d3js-graph.html

	--->
<cfoutput>
<!--- these are CF functions --->
<cfinclude template="#application.paths.includes#DataManipulationLib.cfm">

<cfscript>

tGrStruct = structNew();
tGrStruct = application.ographicsUtils.graphicSetForAAPPNum( url.aapp, session.userID, "AAPP Funding Comparison by Execution Date", "JFG-FComp" );

</cfscript>

<!--- *********** start of d3 output ********** --->

<!DOCTYPE html>
<meta charset="utf-8">
<head>
<title>#tGrStruct.tRepPar.sWindowName#</title>

<!--- STYLES --->
<link href="#application.paths.reportcss#" rel="stylesheet" type="text/css" />
<!--- jfas_graphics follows jfas_report, to override, in graphics reports --->
<link href="#application.paths.cssdir#jfas_graphics.css" rel="stylesheet" type="text/css" />
<link href="#application.paths.cssdir#jfasgraphicsresponse.css" rel="stylesheet" type="text/css" />
</cfoutput>
<style>

.bodyGraphicsStyle {
	font-family: sans-serif;
}


.legend {
	font: 			sans-serif;
	font-weight: 	bold;
	stroke-width: 	2;
}


.bar {
  fill: black;
}

path {
	stroke: black;
	stroke-width: 2;
	fill: none;
}

/* many colors are in jfas_graphics.less */
path.fopclass {
	stroke-dasharray: 3,1;
	stroke-width: 3;
}

path.ecpclass {
	stroke-width: 2;
}

path.fmsclass {
	stroke-width: 2;
}

/* get this color from jfas_graphics.CSS - path.fopclass, where you can see the translation from jfas_graphics.less */
.fopSymbol {
  fill: #DE0F09;
  stroke: #DE0F09;
}

.ecpSymbol {
  fill: #123652;
  stroke: #123652;
}

.fmsSymbol {
	fill: #6A7B15;
	stroke: #6A7B15;
	stroke-width: 1;
	shape-rendering: crispEdges;

}

.calendarDivider {
	stroke: black;
	stroke-width: 2;
	stroke-dasharray: 1,5;
}

.contractDivider {
	stroke: #7E1518;
	stroke-width: 2;
	stroke-dasharray: 2,4;
}

.pyDivider {
	stroke: #774A8E;
	stroke-width: 2;
	stroke-dasharray: 3,3;
}


/* use slash-star for css comments */
/* separate each selector with a comma, to group selectors */
.xaxis path,
.xaxis line,
.yaxis path,
.yaxis line {
	fill: none;
	stroke: black;
	stroke-width: 1;
  	shape-rendering: crispEdges;
}

ylabel90 {
	fill: none;
	stroke: black;
	stroke-width: 1;
}

text {
	font-family: Arial;
	font-size: 9pt;
}

</style>
</head>

<body class="bodyGraphicsStyle">
<div id="HomeSurround" class="HomeSurround">


<cfoutput>
<!--- this is different from jsPackage.cfm, in that it does not include jsHome.cfm, which is large --->
<cfinclude template= "#application.paths.includes#jsGlobal.cfm">
<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>
<script language="javascript"	src="#application.paths.jsdir#jfas.js"></script>
<script language="javascript"	src="#application.paths.jsdir#d3.min.js"></script>
<script language="javascript"	src="#application.paths.jsdir#bpopup.js"></script>
<cfinclude template="#application.paths.includes#jsGoToGraph.cfm">
<cfinclude template="#application.paths.includes#jsGraphics.cfm">
</cfoutput>

<!--- build the hidden div for the Report Alert Popup --->
<cfset BuildGraphicsAlertDiv()>

<cfscript>
// these control the overall width and height of the TITLE BLOCK.  They vary according the the height and width of the browser window
tLayout=structNew();
//tLayout.titlewidth	= 762;
tLayout.titlewidth	= 986;
tLayout.marginleft	= 50;

// display the title block and checkboxes
application.ographicsUtils.displayTitleForAAPPNum( tLayout, tGrStruct, 'aapp_line1.cfm'  );

</cfscript>

<div id="graphdiv" class="graphdiv">
<script>

// these global JS variables get set with the data
// make a structure for the global variables

var glvars = {};

glvars.catdat = [];
glvars.fopdat = [];
glvars.ecpdat = [];
glvars.fmsdat = [];
glvars.contractdat = [];
glvars.pydat = [];

glvars.sFieldString = '';
glvars.sErrorMessage = '';

<cfoutput>
// more global variables, from the jfas calling environment
glvars.aappNum = #tGrStruct.tRepPar.aapp#;
glvars.nGraphicsTime = '';
glvars.adjustDates = true;
glvars.isGraphDisplayed = false;

</cfoutput>

<!--- js variables specify the -outside- positioning and size of the chart --->

glvars.jftitleheight = 250; // estimate of the height of the title block

glvars.jfmargintop = 50; // leave room below the title block
glvars.jfmarginleft = 50;  // leave room for y-axis labels to left of axis
glvars.jfmarginbottom = 50; // leave room for x-axis labels on bottom
glvars.jfmarginright = 50; // leave room for text panel to right of graph
glvars.jfwidth = 0;
glvars.jfheight = 0;

glvars.isCatCheckboxChanged = false;

glvars.nTimeForGrapherCompletion = 10000;
glvars.nGrapherCompletionTimer = '';
glvars.nTimeForCheckboxes = 1250;
glvars.nLatestCheckboxTimer = '';

// these global variables are not put into the global structure, to maintain consistency with documentation of many d3 graphs

var margin = {}, padding, width, height;


// END of global variables
</script>
<!--- THIS include - jsGraph1.cfm - contains JS functions that must appear after the global or function variables they use
these are functions associated with resizing the window with the graph
--->
<CFINCLUDE TEMPLATE="#application.paths.includes#jsGraph1.cfm">
<script>
// start timer to timeout if graph takes WAY too long to display. Will trigger an IE8 incompatability alert
startGrapherCompletionTimer();

// displays graph after data has been read
// this does not work in IE8, because d3 does not work in IE8

var displayGraph = function () {

	// This displays the whole graph, but the data has already been passed in
	// see if there is any data to be plotted

// BREAKS INDENTATION RULES, since this is the bulk of this program
// displays graph after dimensions have been set

var dispGraph = function() {

	var ecpSymbolSize = '4'; // size of glvars.ecpdat symbol
	var fmsrx = '6'; // length of the x-axis of the ellipse
	var fmsry = '3'; // length of the y axis of the ellipse

	// send a variable to a function in a method
	var parseDate = d3.time.format("%Y-%m-%d").parse;	// match the date format in the data file
	var formatTime = d3.time.format("%m/%d/%y");		// Format the date / time for tooltips
	var formatTime4 = d3.time.format("%m/%d/%Y");		// Format the date / time for url from tooltips
	var comma3 = d3.format(",");						// format for numbers in the tooltips

	// this scaling can only be done after setGraphDimensions()
	var xScale = d3.time.scale()
		.range([padding, width - padding * 2]);   // map the x-data to range: chart width = total width minus padding at both sides

	var yScale = d3.scale.linear()
		.range([height - padding, padding]);   // map these to the chart height, less padding.
			 //REMEMBER: y axis range has the bigger number first because the y value of zero is at the top of chart and increases as you go down.

	var xAxis = d3.svg.axis()
		.scale(xScale)
		.orient("bottom");

	var yAxis = d3.svg.axis()
		.scale(yScale)
		.orient("left")
		.tickFormat(d3.format(".2s"));

	// this is a line generator, that uses our Scale functions. Use column names from glvars.fopdat
	var fopline = d3.svg.line()
		.x(function(d) { return xScale(d.date_exec); })
		.y(function(d) { return yScale(d.amttot); })
		.interpolate("step-after");  // linear is the default

	// this is a line generator. Use column names from glvars.ecpdat
	var ecpline = d3.svg.line()
		.x(function(d) { return xScale(d.date_exec); })
		.y(function(d) { return yScale(d.amt); })
		.interpolate("linear");  // linear is the default

	// this is a line generator. Use column names from glvars.fmsdat
	var fmsline = d3.svg.line()
		.x(function(d) { return xScale(d.date_exec); })
		.y(function(d) { return yScale(d.amt); })
		.interpolate("linear");  // linear is the default

	// here is where we start manipulating the DOM

	// Define 'div' for tooltips
	var tooldiv = d3.select("body").append("tooldiv")	// declare the properties for the div used for the tooltips
		.attr("class", "tooltip")				// apply the 'tooltip' class
		.style("opacity", 0);					// set the opacity to nil, so they are not displaying

	// this is the canvas for drawing. Contains the height, width, positioning, and inversion of y-axis
	var svg = d3.select("body").append("svg")
		.attr("id", "svgid")
		// this width can chop off the right side of the graph
		.attr("width", width + margin.left + margin.right)
		// this height can chop off the bottom of the graph
		.attr("height", height + margin.top + margin.bottom)
		.append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")")
	; // position the graph in the margins

	var getECPToolTipText = function (showtip, vdate_exec, vamt, vcfmprog) {
		var sRet = '';
		var cmd;
		if (showtip == 1) {
			cmd = vcfmprog + '?aapp=' + glvars.aappNum + '&date_executed=' + formatTime4(vdate_exec) + '&CostCatList=' + glvars.sFieldString ;
			sRet = '<a href = "#" onclick="GoToAAPPGraph ( \'' + cmd + '\', \'JFGFCompECP\');">' +
				'E ' + formatTime(vdate_exec) + '</a><br/>'  + comma3(vamt);
		} else {
			// NO tooltip
			sRet = 'E ' + formatTime(vdate_exec) + '<br/>'  + comma3(vamt)
		}

		return sRet;

	}; // getECPToolTipText

	var getFMSToolTipText = function (showtip, vdate_exec, vamt, vcfmprog) {
		var sRet = '';
		var cmd;
		if (showtip == 1) {
			cmd = vcfmprog + '?aapp=' + glvars.aappNum + '&date_executed=' + formatTime4(vdate_exec) + '&CostCatList=' + glvars.sFieldString ;
			sRet = '<a href = "#" onclick="GoToAAPPGraph ( \'' + cmd + '\', \'JFGFCompFMS\');">' +
				'F ' + formatTime(vdate_exec) + '</a><br/>'  + comma3(vamt);
		} else {
			// NO tooltip
			sRet = 'F ' + formatTime(vdate_exec) + '<br/>'  + comma3(vamt)
		}

		return sRet;

	}; // getFMSToolTipText

	// total of all amts spent
	vtot  =0;
	// for building tooltip links to detail window
	var cmd = '';

	if (glvars.adjustDates) {
		// This was READ THE DATA FILES, until replaced by ajax string in the call to getDataAndDisplay
		// this is a URL, not an internal disk location
		// one record per date_exec
		glvars.fopdat.forEach(function(d) {
			d.date_exec = parseDate(d.date_exec); // convert date to an object
			d.amt = +d.amt; // convert to a number, NOT summation
			d.amttot = vtot + d.amt; // amttot is amttot so far, put this amt
			vtot += d.amt;
		});

		// clean up the glvars.ecpdat
		// forEach is a native function of JS arrays
		// one record per ECP
		glvars.ecpdat.forEach(function(d, i) {
			d.date_exec = parseDate(d.date_exec); // convert date to an object
			d.amt = +d.amt; // convert to a number, NOT summation
			d.showtip = +d.showtip; // convert to a number, NOT summation
		});

		// clean up the glvars.fmsdat
		// forEach is a native function of JS arrays
		// one record per ECP
		glvars.fmsdat.forEach(function(d, i) {
			d.date_exec = parseDate(d.date_exec); // convert date to an object
			d.amt = +d.amt; // convert to a number, NOT summation
		});

		// clean up the glvars.contractdat
		// forEach is a native function of JS ARRAYS
		glvars.contractdat.forEach(function(d, i) {
			d.contractanniversary = parseDate(d.contractanniversary); // convert date to an object
		});

		// clean up the glvars.pydat
		// forEach is a native function of JS ARRAYS
		glvars.pydat.forEach(function(d, i) {
			d.pyanniversary = parseDate(d.pyanniversary); // convert date to an object
		});
		glvars.adjustDates = false;
	} // glvars.adjustDates

	// Scale the DOMAIN of the data
	// extent(array, accessor) returns min/max value in the array
	var datemin=Math.min( d3.min(glvars.fopdat, function(d) { return d.date_exec; })
	, d3.min(glvars.ecpdat, function(d) { return d.date_exec; })
	, d3.min(glvars.fmsdat, function(d) { return d.date_exec; })
	, d3.min(glvars.contractdat, function(d) { return d.contractanniversary; })
	, d3.min(glvars.pydat, function(d) { return d.pyanniversary; })
	);
	// last pyanniversary will not extend the range, because it is already truncated in .cfc
	var datemax=Math.max( d3.max(glvars.fopdat, function(d) { return d.date_exec; })
	, d3.max(glvars.ecpdat, function(d) { return d.date_exec; })
	, d3.max(glvars.fmsdat, function(d) { return d.date_exec; })
	, d3.max(glvars.contractdat, function(d) { return d.contractanniversary; })
	);

	xScale.domain([datemin, datemax]);

	var amtmin=Math.min( d3.min(glvars.fopdat, function(d) { return d.amt; })
	, d3.min(glvars.ecpdat, function(d) { return d.amt; })
	, d3.min(glvars.fmsdat, function(d) { return d.amt; })
	);
	var amtmax=Math.max( d3.max(glvars.fopdat, function(d) { return d.amt; })
	, d3.max(glvars.ecpdat, function(d) { return d.amt; })
	, d3.max(glvars.fmsdat, function(d) { return d.amt; })
	);

	yScale.domain([amtmin, amtmax]);

	// calculate range: startEnd like [2009, 2013].  getFullYear() is a JS function
	// calendarYears will be like 2010,2011,2012,2013. Don't draw vertical line at left or right of graph. 2013 is inside end of x-axis
	// .map copies all enumerable properties into the new map: calendarRange. So, the domain has 2 values, and calendarRange had 2 values
	var calendarRange = xScale.domain().map(function(d) { return d.getFullYear(); });
	var	calendarYears = d3.range(calendarRange[0]+1, calendarRange[1]+1);

	// HERE IS WHERE WE START TO DRAY THE GRAPH
	// this defines "g" within "svg"

	// draw y axis with labels and move in from the size by the amount of padding
	svg.append("g")
		.attr("class", "yaxis")
		.attr("transform", "translate("+padding+",0)")
		.call(yAxis)

		.append("text")
		.attr("class", "ylabel90")
		.attr("transform", "rotate(-90)")
		.attr("y", 6) // higher number pushes label to right of the axis
		.attr("dy", ".71em")
		.style("text-anchor", "end")
		.text("Dollars");

	// draw x axis with labels and move to the bottom of the chart area
	svg.append("g")
	  .attr("class", "xaxis") // give it a class so it can be used to select only xaxis labels  below
	  // move the x axis to the bottom of the graph
	  .attr("transform", "translate(0," + (height - padding) + ")")
	  .call(xAxis);

	// rotate text on x axis by 45 degrees
	// solution based on idea here: https://groups.google.com/forum/?fromgroups#!topic/d3-js/heOBPQF3sAY
	// first move the text left so no longer centered on the tick
	// then rotate up to get 45 degrees.
	//getBBox gets the text area of a piece of text
	svg.selectAll(".xaxis text")  // select all the text elements for the xaxis
	  .attr("transform", function(d) {
		  return "translate(" + this.getBBox().height*-1 + "," + this.getBBox().height + ")rotate(-45)";
	});

	// ** LINES **

	// Draw the FOP line. Use .data([glvars.fopdat]) to bind glvars.fopdat to a single svg element
	svg.append("path")
		.data([glvars.fopdat])
		.attr("id", "fopline")
		.attr("class", "fopclass")
		.attr("active", false)
		.attr("d", fopline);

	// draw the FOP SCATTERPLOT (SYMBOLS)
	svg.selectAll(".fopSymbol")
	.data(glvars.fopdat)
	.enter().append("circle")
		.attr("class", "fopSymbol")
		.attr("r", 3)												// Made radius large enough for mouse selection
		.attr("cx", function(d) { return xScale(d.date_exec); })	// same as for fopline
		.attr("cy", function(d) { return yScale(d.amttot); })		// remove semicolon, because tooltip stuff follows
	// tooltip stuff after this
	.on("mouseover", function(d) {
		// when the mouse goes over a circle, do the following

		// eliminate any previous tooltip
		tooldiv.transition()
		.duration(500)
		.style("opacity", 0);

		tooldiv.transition()								// declare the transition properties to bring fade-in div
			.duration(200)									// it shall take 200ms
			.style("opacity", .8);							// and go all the way to an opacity of .9
		// add the text of the tooltip as html. First item is a link. The dollar amt is NOT the cumulative, but the amount executed that day

		cmd = 'aapp_line1_fopdetail.cfm?aapp=' + glvars.aappNum + '&date_executed=' + formatTime4(d.date_exec) + '&CostCatList=' + glvars.sFieldString ;

		// FOP does not have a function for this, unlike ECP and FMS
		tooldiv	.html('<a href = "#" onclick="GoToAAPPGraph ( \'' + cmd + '\', \'JFGFCompFOP\');">' +
		'F ' + formatTime(d.date_exec) + "</a><br/>"  + comma3(d.amt) )
			.style("background","#fee9e8") // foptip.  Get this color from jfas_graphics.CSS, where you can see color generated for foptip from jfas_graphics.less
			.style("left", (d3.event.pageX + 3) + "px")			// move it in the x direction
			.style("top", (d3.event.pageY - 40) + "px");	// move it in the y direction
		}) // end of on function
		; // end of selectAll


	// Draw the ECP LINE. Use .data([glvars.ecpdat]) to bind data to a single svg element
	// Add the ecpline path.
	// this wants x,y pairs.  Can't have a third column, like recordType
	svg.append("path")
		.data ([glvars.ecpdat])
		.attr("id", "ecpline")
		.attr("class", "ecpclass")
		.attr("active", false)
		// ecpline is a line generator function
		.attr("d", ecpline)
	; // end of append

	// draw the ECP SCATTERPLOT (SYMBOLS)
	// d3 supported types: circle, cross, diamond, square, triangle-down, triangle-up
	// svg types are circle, rect, ellipse, polyline, polycon (https://www.dashingd3js.com/svg-basic-shapes-and-d3js)
	svg.selectAll(".ecpSymbol")
	.data(glvars.ecpdat)
	.enter().append("rect")  // rect is a standard svg shape
		.attr("class", "ecpSymbol")
		.attr("width", ecpSymbolSize)
		.attr("height", ecpSymbolSize)
		.attr("x", function(d) { return (xScale(d.date_exec) - ecpSymbolSize / 2); }) // center on the line - y scale is reversed
		.attr("y", function(d) { return (yScale(d.amt) - ecpSymbolSize / 2); })
		// tooltip stuff after this
		.on("mouseover", function(d) {
			// when the mouse goes over a symbol, do the following
			// eliminate any previous tooltip
			tooldiv.transition()
			.duration(500)
			.style("opacity", 0);

			tooldiv.transition()								// declare the transition properties to bring fade-in
				.duration(200)									// it shall take 200ms
				.style("opacity", .8);							// and go all the way to an opacity of .9
				// add the text of the tooltip as html. Date as a link, then amt

			// tooltip
			tooldiv.html( getECPToolTipText( d.showtip, d.date_exec, d.amt, 'aapp_line1_ecpdetail.cfm' ) )
				.style("background","#80b8e3") // ecptip
				.style("left", (d3.event.pageX + 3) + "px")			// move it in the x direction
				.style("top", (d3.event.pageY - 40) + "px");	// move it in the y direction
		}) // end of "on" function
	; // end of selectAll


	// Draw the FMS LINE. Use .data([glvars.fmsdat]) to bind data to a single svg element
	// Add the fmsline path.
	// this wants x,y pairs.  Can't have a third column, like recordType
	svg.append("path")
		.data ([glvars.fmsdat])
		.attr("id", "fmsline")
		.attr("class", "fmsclass")
		.attr("active", false)
		.attr("d", fmsline)
	; // end of append

/* sample: uses ellipses
	// draw the FMS SCATTERPLOT with ellipses
	// d3 supported types: circle, cross, diamond, square, triangle-down, triangle-up
	// svg types are circle, rect, ellipse, polyline, polygon (https://www.dashingd3js.com/svg-basic-shapes-and-d3js)
	// underlying SVG terms are at http://www.w3.org/TR/SVG/coords.html#Introduction
	svg.selectAll(".fmsSymbol")
	.data(glvars.fmsdat)
	.enter().append("ellipse")  // ellipse is a standard svg shape
		.attr("class", "fmsSymbol")
		.attr("rx", fmsrx)
		.attr("ry", fmsry)
		// use cx and cy for ellipse
		.attr("cx", function(d) { return (xScale(d.date_exec) ); }) // center on the line - y scale is reversed
		.attr("cy", function(d) { return (yScale(d.amt) ); })
	; // end of selectAll
end of sample */

	// draw the FMS SCATTERPLOT (SYMBOLS) triangles
	svg.selectAll(".fmsSymbol")
	  .data(glvars.fmsdat)
	.enter().append("path")
	  .attr("class", "fmsSymbol")
	  // d is the detailed mini-language for generating a polygon that is the triangle
	  // the default size is 64, so we are shrinking it
	  .attr("d", d3.svg.symbol().type("triangle-up").size(20))
	  // this moves the triangle to the right place, based on the data
	  .attr("transform", function(d) { return "translate(" + xScale(d.date_exec) + "," + yScale(d.amt) + ")"; })
		// tooltip stuff after this
		.on("mouseover", function(d) {
			// when the mouse goes over a circle, do the following
			// eliminate any previous tooltip
			tooldiv.transition()
			.duration(500)
			.style("opacity", 0);
			tooldiv.transition()			// declare the transition properties to bring fade-in div
				.duration(200)				// it shall take 200ms
				.style("opacity", .8);		// and go all the way to an opacity of .9
			// add the text of the tooltip as html. Date, then dollar amount

			tooldiv.html( getFMSToolTipText( 1, d.date_exec, d.amt, 'aapp_line1_fmsdetail.cfm' ) )
				.style("background","#e2efa0") // fmstip
				.style("left", (d3.event.pageX + 3) + "px")			// move it in the x direction
				.style("top", (d3.event.pageY - 40) + "px");	// move it in the y direction
			}) // end of "on" function

	; // end of selectAll

	// ** CALENDAR VERTICAL DIVIDING LINES

	// draw the dividing lines on Jan. 1 of calendar year
	// calendarYears are like 2010,2011,2012,2013.  Length of calendarYears determines how may lines
	svg.selectAll(".calendarDivider").data(calendarYears)
		.enter().append("line")
		.attr("class", "calendarDivider")
		// y goes from y = minimum to y = maximum
		.attr("y1", yScale.range()[0])
		.attr("y2", yScale.range()[1])
		// 'd' is one of the dividers. Vertical line means x values are same at top and bottom
		.attr("x1", function(d) { return xScale(new Date(d, 0)); })
		.attr("x2", function(d) { return xScale(new Date(d, 0)); })
	; // end of selectAll

	// draw the dividing lines right on the contract anniversary
	// glvars.contractdat are like 2010,2011,2012,2013.  Length of glvars.contractdat determines how may lines
	svg.selectAll(".contractDivider").data(glvars.contractdat)
		.enter().append("line")
		.attr("class", "contractDivider")
		// y goes from y = minimum to y = maximum
		.attr("y1", yScale.range()[0])
		.attr("y2", yScale.range()[1])
		// 'd' is one of the dividers. Vertical line means x values are same at top and bottom
		.attr("x1", function(d) { return xScale(d.contractanniversary); })
		.attr("x2", function(d) { return xScale(d.contractanniversary); })
	; // end of selectAll

	// draw the dividing lines right on the py anniversary
	// glvars.pydat are like 2010,2011,2012,2013.  Length of glvars.pydat determines how many lines
	svg.selectAll(".pyDivider").data(glvars.pydat)
		.enter().append("line")
		.attr("class", "pyDivider")
		// y goes from y = minimum to y = maximum
		.attr("y1", yScale.range()[0])
		.attr("y2", yScale.range()[1] - 1)
		// 'd' is one of the dividers. Vertical line means x values are same at top and bottom
		.attr("x1", function(d) { return xScale(d.pyanniversary); })
		.attr("x2", function(d) { return xScale(d.pyanniversary); })
	; // end of selectAll


	// ** LEGEND

	var OnClickLegendItem = function (xPosition, sColor, sTitle, oLineGenerator, sClass, sSymbolClass) {
		// this routine implements the click of a legend item, and does not have access to the surrounding environment, as does .on("click", function(){ in displayLegendItem
		// eliminate any previous tooltip
		// DO NOT DO THIS ...  LOSES the tooltips altogether $(".tooltip").remove();
		// make any previous tooltip invisible
		tooldiv.transition()
		.duration(500)
		.style("opacity", 0);

		// determine if line is visible
		// local to the function
		var active = oLineGenerator.active ? false : true,
			newOpacity = active ? 0 : 1;
		var classselector = '.' + sClass;
		var symbolclassselector = '.' + sSymbolClass;
		// hide or show the elements, which is line + icons on the line
		d3.select(classselector).style("opacity", newOpacity);
		// use jQuery selector, because d3.select does not work in this case
		$( symbolclassselector ).css("opacity", newOpacity);
		// update whether or not the elements are active
		oLineGenerator.active = active;

	}; // OnClickLegendItem

	var displayLegendItem = function (xPosition, sColor, sTitle, oLineGenerator, sClass, sSymbolClass) {

		if ( sTitle == 'FOP' ) {
			var sLineStyle = 'stroke:' + sColor + ';stroke-width:3;stroke-dasharray: 3,1';
			svg.append("circle")
				.attr("class", "fopSymbol")
				.attr("r", 3)
				.attr("cx", +xPosition + 17)
				.attr("cy", -14)
			; // end of svg.append
		}
		else if ( sTitle == 'ECP' ) {
			var sLineStyle = 'stroke:' + sColor + ';stroke-width:2';
			svg.append("rect")
				.attr("class", "ecpSymbol")
				.attr("width", ecpSymbolSize)
				.attr("height", ecpSymbolSize)
				.attr("x", +xPosition + 17)
				.attr("y", -16)
			; // end of svg.append
		}
		else if ( sTitle == 'FMS' ) {

			var xPos = +xPosition + 17;
			var sLineStyle = 'stroke:' + sColor + ';stroke-width:2';
			svg.append("path")
				.attr("class", "fmsSymbol")
				// d is the detailed mini-language for generating a polygon that is the triangle
				// the default size is 64, so we are shrinking it
				.attr("d", d3.svg.symbol().type("triangle-up").size(20))
				// this moves the triangle to the right place, based on the data
				.attr("transform", function(d) { return "translate(" +xPos + "," + -14 + ")"; })
			; // end of svg.append
		}

		svg.append("line")
			//.attr("class", sClass)
			.attr("style", sLineStyle)
			// y goes from y = minimum to y = maximum
			.attr("y1", -14)
			.attr("y2", -14)
			.attr("x1", +xPosition)
			.attr("x2", +xPosition + 35)
		; // end of svg.append

		svg.append("text")
			.attr("x", +xPosition + 50)
			.attr("y", -10)
			.attr("class", "legend")
			.style("fill", sColor)
			.text(sTitle)
		; // end of svg.append

		// make a clickable area containing both line and text, So that user does not have to hit the line or the symbol exactly to hide/reveal related line
		svg.append("text")
			.attr("x", +xPosition)
			.attr("y", -10)
			.attr("width", "100")
			.style("background","red")
			.html('XXXXXXXXXX')
			.style("opacity","0")
			//.on("mouseover", function(){
			//	$( this ).css("cursor", "pointer");
			//})
			//.on("mouseleave", function(){
			//	$( this ).css("cursor", "default");
			//})
			//.on("click", function(){

				// run the OnClickLegendItem function
				// commment out, since using check boxes
				///OnClickLegendItem (xPosition, sColor, sTitle, oLineGenerator, sClass, sSymbolClass) ;

			//}) // end of "on()" function, and "on"
		; // end of svg.append


	}; // displayLegendItem


	// these colors must match colors above for fopSymbol, ecpSymbol, fmsSymbol

	displayLegendItem(75, '#DE0F09', 'FOP', fopline, 'fopclass', 'fopSymbol' );
	displayLegendItem(200, '#123652', 'ECP', ecpline, 'ecpclass', 'ecpSymbol' );
	displayLegendItem(325, '#6A7B15', 'FMS', fmsline, 'fmsclass', 'fmsSymbol' );

	// these functions cannot be "var", because they are called from outside this function
	clickFOPCheckBox = function () {
		OnClickLegendItem (75, '#DE0F09', 'FOP', fopline, 'fopclass', 'fopSymbol');
	};
	clickECPCheckBox = function () {
		OnClickLegendItem (200, '#123652', 'ECP', ecpline, 'ecpclass', 'ecpSymbol');
	};
	clickFMSCheckBox= function () {
		OnClickLegendItem (325, '#6A7B15', 'FMS', fmsline, 'fmsclass', 'fmsSymbol');
	};

	/* END of LEGEND Functions */

	// finished with Completion timer
	clearInterval(glvars.nGrapherCompletionTimer);
	glvars.nGrapherCompletionTimer = '';

	} // dispGraph ***********   end of broken indentation rule

	// initial set of dimensions

	setGraphDimensions();

	dispGraph();

	// "fundMap1" can be a variable, but not "var", since it is called from outside this function
	// "fundMap1" is inside displayGraph()
	fundMap1 = function ( fund ) {
		//alert('fundMap1 ' + fund);
		if (fund =='FOP') {
			clickFOPCheckBox();
		}
		else if (fund =='ECP') {
			clickECPCheckBox();
		}
		else if (fund =='FMS') {
			clickFMSCheckBox();
		}
	}

} // displayGraph

// "fundMap" CANNOT be a var, since it is called from outside (cfc/graphicsUtils.cfc)
function fundMap ( fund ) {
	//alert('fundMap');
	fundMap1( fund );
}

// this is called when the window is resized
function reDisplayGraph() {
	// eliminate any previous tooltip
	$(".tooltip").remove();
	// clear the graph from the terminal
	$("#svgid").remove();
	displayGraph();

} //reDisplayGraph

function GetDataandRedisplayGraph() {
	// eliminate any previous tooltip
	$(".tooltip").remove();
	// clear the graph from the monitor
	$("#svgid").remove();

	// this says to process the data in d3 as though it just came from the database
	glvars.adjustDates = true;
//alert (' in GetDataandRedisplayGraph calling getDataAndDisplay');

	getDataAndDisplay();

} //GetDataandRedisplayGraph

var markCheckBoxes1 = function () {
	var selector='';
	// mark the CostCat check boxes that correspond to data in the current graph
	for (var walker = 0; walker < glvars.catdat.length; walker += 1) {
		selector = '#CostCat' + glvars.catdat[walker].costcatcode;
		$( selector ).prop("checked", true);
	}
	// set all the fundtype checkboxes to true after a data read

	selector = '[name="FundTypeList"]';
	$( selector ).prop("checked", true);

} // markCheckBoxes1

var toggleAllCheckBoxes1 = function () {
	//alert(jsdump(glvars.catdat));

	var selector = '#CostCatToggle';
	var vchecked = $( selector ).prop('checked');

	// toggle ALL the check boxes that correspond to data in the current graph
	selector = '.costcatcheck';
	$( selector ).prop("checked", vchecked);
	//alert('recording that one of the Cat checkboxes changed');
	glvars.isCatCheckboxChanged = true;
	// redisplay after a delay
	startRedisplayGraphTimer();

} // toggleAllCheckBoxes1

var clearCostCatToggle = function () {
	// clears the All checkbox when a detailed costcat checkbox is checked
	var selector = '#CostCatToggle';
	var vchecked = $( selector ).prop('checked', false);
	// record that one of the Cat checkboxes changed.  This is checked by submitCheckBoxes
	//alert('recording that one of the Cat checkboxes changed');
	glvars.isCatCheckboxChanged = true;
	// redisplay after a delay
	startRedisplayGraphTimer();

} // clearCostCatToggle


function submitAnyCheckBoxes() {

	// save the filter variables from the form into the JS global area, for GetDataandRedisplayGraph
	glvars.sFieldString = $('#displayTitleForAAPPNum').serialize();

	// convert from CostCatList=A&CostCatList=B& ... to A,B ...
	// Do not want to send FundTypeList to back end

	// remove CostCatToggle
	glvars.sFieldString = replaceAll("CostCatToggle=CostCatToggle&", "", glvars.sFieldString);
	glvars.sFieldString = replaceAll("CostCatList=", "", glvars.sFieldString);
	glvars.sFieldString = replaceAll("&", ",", glvars.sFieldString);
	glvars.sFieldString = replaceAll("FundTypeList=FOP,", "", glvars.sFieldString);
	glvars.sFieldString = replaceAll("FundTypeList=ECP,", "", glvars.sFieldString);
	glvars.sFieldString = replaceAll("FundTypeList=FMS,", "", glvars.sFieldString);

	var localisCatCheckboxChanged = glvars.isCatCheckboxChanged;
	glvars.isCatCheckboxChanged = false;

	if ( localisCatCheckboxChanged ) {
		// changed cost category.  Must extract the data from the database again
		GetDataandRedisplayGraph();

	}
	else {

		// changed only the fund source.  Don't use reDisplayGraph - which kills the tooltips
		displayGraph();
	}

	// this prevents the default action of submitCatCheckBoxes
	return false;

}  // submitAnyCheckBoxes


var getDataAndDisplay = function () {

	<cfoutput>
	// JS variables within ready()
	//alert('in getDataAndDisplay');
	var cfcLink = '#application.urlstart##cgi.http_host##application.paths.components#graphicsRestful.cfc?isBackground=yes';
	var formdata = {
			method:'GetDataAappLine1'
			 , aappNum:glvars.aappNum  // global variable
			 , costCatList:glvars.sFieldString  // global variable
			 } ; //array
	</cfoutput>

	// get SOME OF the data from the database, and pass it in to the program to display the graph
	// some of the data is already available in CF, for display of the title section

	//alert('formdata\n\n ' + jsdump(formdata));

	var jqXHR = $.ajax({
				type:	"POST"
				, url:	cfcLink
				, data: formdata   // note this conversion from formdata to data, for ajax
		})

		.success (function(tReturn, statusTxt, xhr){

			//alert('tReturn\n\n' + jsdump(tReturn));
			tReturn = $.parseJSON(tReturn);
//alert('back from call to service the JSON data');
			//alert("getDataAndDisplay tReturn after Parse:\n"+jsdump(tReturn));
			// this is JS
			// Deep copy

			glvars.sErrorMessage = tReturn.SERRORMESSAGE;
			if (glvars.sErrorMessage != '') {
				// finished with Completion timer
				clearInterval(glvars.nGrapherCompletionTimer);
				glvars.nGrapherCompletionTimer = '';

				// set the error message text into the div
				$( '#ReportAlertText' ).html(glvars.sErrorMessage);
				glJFAS.oReportPopup = $('#ReportAlert').bPopup({
					follow: [false, false], //x, y
					//autoClose: 4000,
					//transition: 'fadeIn',
					//speed: 650,
					position: ['auto', 100], //x, y
					opacity: 0.5,
					modalColor: '#073053' // color of background behind the modal "window" with the announcement
				});
			}
			else {

				// setting global variables defined at the top
				// FOP data
				glvars.fopdat =  convertQueryForD3( $.extend(true, {}, tReturn.QFOP) );
				// ECP data
				glvars.ecpdat = convertQueryForD3( $.extend(true, {}, tReturn.QECP));
				// FMS data
				glvars.fmsdat = convertQueryForD3( $.extend(true, {}, tReturn.QFMS) );


				// for checking the checkboxes for cost categories
				glvars.catdat =  convertQueryForD3( $.extend(true, {}, tReturn.QCATID) );
				// for vertical lines for contract years
				glvars.contractdat = convertQueryForD3( $.extend(true, {}, tReturn.QCONTRACT) );
				// for vertical lines for PYs
				glvars.pydat = convertQueryForD3( $.extend(true, {}, tReturn.QPY) );

				//alert("getDataAndDisplay glvars after Parse:\n"+jsdump(glvars));

				markCheckBoxes1();

				// This call will fail in IE8, because d3 is not supported in ie8
				//alert('getDataAndDisplay calling displayGraph');
				displayGraph();
			}

		})

		.error (function(jqXHR, statusTxt, errorThrown){
		alert('in error');
		alert("Error: "+statusTxt+": "+errorThrown);
		});


} // getDataAndDisplay


$("document").ready(function() {

	//alert('document ready');

	// We use a Timer to support resizing of the window and subsequently the graph, on the fly
	// the .resize function does NOT fire upon initial load. But this is here to make it fire when the window is subsequently resized
	$( window ).resize(function() {
		StartGraphDisplayerTimer();
	});

	getDataAndDisplay();

}); // ready
</script>

</div>
<!-- graphdiv -->
</div>
<!-- HomeSurround -->

</html>
</body>

