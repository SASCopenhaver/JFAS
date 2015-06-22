<!--- fop_aapp.cfm --->
<cfoutput>

<!--- these are CF functions --->
<cfinclude template="#application.paths.includes#DataManipulationLib.cfm">


<cfscript>

// filename depends on userID, to keep users separate. Assumes one session per user
fullfile	= "#application.paths.upload##session.userID#fop_aapp.csv";
fullurl		= "#application.urls.upload##session.userID#fop_aapp.csv";

tGrStruct = structNew();
tGrStruct = application.ographicsUtils.graphicSetForAAPPNum(url.aapp, session.userID, "FOP Allocations", "JFG-FOP");
</cfscript>

<!--- start of HTML output --->

<!DOCTYPE html>
<meta charset="utf-8">
<head>
<title>#tGrStruct.tRepPar.sWindowName#</title>
<link href="#application.paths.reportcss#" rel="stylesheet" type="text/css" />

<style>

graphdiv {
  font: 10px sans-serif;
}

.legend {
  font: 10px sans-serif;
}

.axis path,
.axis line {
  fill: none;
  stroke: ##000;
  shape-rendering: crispEdges;
}

.bar {
  fill: steelblue;
}

// what is this?
.x.axis path {
  display: none;
}

</style>
</head>

<body style="font-family: sans-serif;">

<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>
<script language="javascript"	src="#application.paths.jsdir#d3.min.js"></script>
<script language="javascript"	src="#application.paths.jsdir#jfas.js"></script>
<cfinclude template="#application.paths.includes#jsGraphics.cfm">
</cfoutput>

<!--- Begin Content Area --->
<!--- Cold Fusion global variables for this routine --->
<cfscript>
tLayout=structNew();
tLayout.titlewidth	= 986;
tLayout.width 		= tLayout.titlewidth + 180;
tLayout.height		= 400;

// these are margins for the chart
tLayout.margintop		= 50; // just a comfortable distance below the title block
tLayout.marginright		= 120; // reducing this number pushes legend off the right of the page
tLayout.marginbottom	= 20; // leave room for x-axis labels below access
tLayout.marginleft		= 50; // leave room for y-axis labels to left of axis

// display the title block
application.ographicsUtils.displayTitleForAAPPNum( tLayout, tGrStruct, 'fop_aapp.cfm' );

</cfscript>

<div id="graphdiv" class="graphdiv">

<script>

// this is the function to display the graph.  'data' is the name to match the d3 standard

var displayGraph = function ( data ) {
	// alert ("displayGraph jsdump(data):\n\n"+jsdump(data) );

<cfoutput>

<!---
	build JS for the mapping from code to description for the legend
	this is CF in the middle of JS
	this does not depend on the AAPP chosen
	we are building an object.  Each property has a name
	sample output: var nameToDesc = {PY : 'Prog Year' ,A : 'Center Operations' ,B1 : 'Facility Cnst/Rehab' ,B2 : 'Capital Equipment' ,B3 : 'Vehicle Amortization' ,B4 : 'CTST Materials' ,C1 : 'Outreach/Admissions' ,C2 : 'Career Transition' ,D : 'Student Transportation' ,S : 'Support' };
--->
<cfscript>

rstCostCategories	= application.oLookup.getCostCategories(displayFormat='primary');
// need to convert to JS
fixedcolumncodes = "PY," & valuelist(tGrStruct.rstCostCategories.costcatcode);
fixedcolumndesc = "Prog Year," & valuelist(tGrStruct.rstCostCategories.costcatdesc);

cfNameToDesc = "var nameToDesc = {";
for (ii = 1; ii le ListLen(fixedcolumncodes); ii += 1) {
	cfNameToDesc &= " #ListGetAt(fixedcolumncodes, ii)#: '#ListGetAt(fixedcolumndesc, ii)#'" ;
	if (ii lt ListLen(fixedcolumncodes) )  {cfNameToDesc &= ',';}
}
cfNameToDesc &= "};" ;

</cfscript>
<!---  drop the JS line we just built into the JS code --->
#cfNameToDesc#

<!--- js variables specify the -outside- positioning and size of the chart --->
var jfmargintop = #tLayout.margintop#, jfmarginleft = #tLayout.marginleft#, jfwidth = #tLayout.width#, jfheight = #tLayout.height#;

var margin = {top: #tLayout.margintop#, right: #tLayout.marginright#, bottom: #tLayout.marginbottom#, left: #tLayout.marginleft#},
    width = jfwidth - margin.left - margin.right,
    height = jfheight - margin.top - margin.bottom;
</cfoutput>



<!--- construct an ordinal scale (1, 2, 3...) --->
// x is a function that returns a scaled value from the data, so that the bar fits on the graph display
// x is used in var rect, as in x(d.PY), below.  Each PY is its own stacked bar (2009, 2010, 2011, ...).  The .3 is the ratio of the width of the white space between bars, to the width of the bars
var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .3);

// this maps a range of numbers in the domain (the data), to a range of widths in the display (y means vertical pixels). See d3 tutorial Part 3 on why range is [height, 0] for a vertical bar chart (svg origin is at top left of graph, we want bottom left)
var y = d3.scale.linear()
    .rangeRound([height, 0]);

// d3-provided colors
var color = d3.scale.category10();

// define a function to create the horizonal axis
var xAxis = d3.svg.axis()
    .scale(x)  // set the scale to the "x" scale defined above
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y) // set the scale to the "y" scale defined above
    .orient("left")
    .tickFormat(d3.format(".2s"));

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")"); // position the graph in the margins

// start looking at the data

  color.domain(d3.keys(data[0]).filter(function(key) { return key !== "PY"; }));

  // for each record ... NOT, for each column in the record
  data.forEach(function(d) {
    var y0 = 0;
    // d.amts is a new data field, which is an array of objects, not in the data file. The anonymous function function(name) is returning an object literal for every value in the array returned by color.domain().  map is a javascript Array builtin.
    d.amts = color.domain().map(function(name) { return {name: name, y0: y0, y1: y0 += +d[name]}; });
    // new data field, not in the data file
    d.total = d.amts[d.amts.length - 1].y1;
  });

  // this would put the highest bar first (ok for the demo app, but not here)
  // data.sort(function(a, b) { return b.total - a.total; });

  // get a list of the PY values
  x.domain(data.map(function(d) { return d.PY; }));
  // get the highest total for any column. 'Total' is a property name, defined above
  y.domain([0, d3.max(data, function(d) { return d.total; })]);

  // append a "g" element to the SVG. NOT d3 specific. g is used to group SVG shapes together. This is the x-axis group
  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

  // This is the y-axis group, including an extra label
  svg.append("g")
      .attr("class", "y axis")
      .attr("font-family", "sans-serif")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Dollars");

  // traverse the PY data, appending a "g" group for the stacked bar (?)
  var PY = svg.selectAll(".PY")
      .data(data)
    .enter().append("g")
      .attr("class", "g")
      .attr("transform", function(d) { return "translate(" + x(d.PY) + ",0)"; });

  // for each of the BARS created above, create a number of rects, one for each d.amts, calculating the top and bottom of the bar segment
  PY.selectAll("rect")
      .data(function(d) { return d.amts; })
    .enter().append("rect")
      .attr("width", x.rangeBand())
      .attr("y", function(d) { return y(d.y1); })
      .attr("height", function(d) { return y(d.y0) - y(d.y1); })
      .style("fill", function(d) { return color(d.name); });

  // create the legend. For each color, create a "g" group of objects, with the CSS class and positioned
  var legend = svg.selectAll(".legend")
  		//  slice() method returns a shallow copy of a portion of an array into a new array object.
      .data(color.domain().slice().reverse())
    .enter().append("g")
      .attr("class", "legend")
      // following line controls the vertical spacing between legend items
      .attr("transform", function(d, i) { return "translate(0," + i * 25 + ")"; });

  // define the square of color
  legend.append("rect")
  		// x controls horizontal position.  The legend is in the right margin.
  		// this controls distance from text to legend color block
      .attr("x", width + 78)
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", color);

  legend.append("text")
  		// x controls horizontal position or text.  The legend is in the right margin.
      .attr("x", width + 67)
      .attr("y", 9)
      .attr("dy", ".35em")
      .style("text-anchor", "end")
      // using var nameToDesc created in CF, and dumped into JS
      .text(function(d) { return nameToDesc[d]; });

} // displayGraph

$("document").ready(function() {

	<cfoutput>
	// JS variables within ready()
	var cfcLink = '#application.urlstart##cgi.http_host##application.paths.components#graphicsRestful.cfc?isBackground=yes';
	var aappNum = #url.aapp#;
	// alert('aappNum ' + aappNum);
	</cfoutput>

	// get SOME OF the data from the database, and pass it in to the program to display the graph
	// some of the data is already available in CF, for display of the title section

	var formdata = {
		method:"f_getrst_fop_aapp"
		, aappNum: aappNum
		 } ; //array

	var jqXHR = $.ajax({
				 url: 	cfcLink
				,type:	"GET"
				,data:	formdata
		})
		.success (function(tReturn, statusTxt, xhr){

			//alert("tReturn:\n"+jsdump(tReturn))
			tReturn = $.parseJSON(tReturn);

			// alert("tReturn after Parse:\n"+jsdump(tReturn));
			// this is JS
			// Deep copy
			// USE ALL CAPS FOR THIS QUERY NAME, because of CF return from Ajax
			var qFOP = $.extend(true, {}, tReturn.QFOP);

			//alert("qFOP alone:\n"+jsdump(qFOP))
			displayGraph ( f_makeWorkableJSON( qFOP ) );

		})

		.error (function(jqXHR, statusTxt, errorThrown){
		alert("Error: "+statusTxt+": "+errorThrown);
		});


}); // ready
</script>
<!-- /graphdiv -->
</div>

</html>
</body>


