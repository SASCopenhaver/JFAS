<!--- graphics/bullets.cfm ---->

<!DOCTYPE html>

<!--- sample for "slots"
select aapp_num, workload_type_code,contract_year, value
from
aapp_workload
where
value <> 0

order by aapp_num, workload_type_code, contract_year

;

--->

<cfoutput>
<!--- these are CF functions --->
<cfinclude template="#application.paths.includes#DataManipulationLib.cfm">

<cfscript>

tGrStruct = structNew();
tGrStruct = application.ographicsUtils.graphicSetForHome( session.userID, "Bullet Charts for Selected AAPPs", "JFG BL1" );

</cfscript>

<!DOCTYPE html>
<meta charset="utf-8">
<head>

<title>#tGrStruct.tRepPar.sWindowName#</title>

<!--- STYLES --->
<link href="#application.paths.reportcss#" rel="stylesheet" type="text/css" />
<link href="#application.paths.cssdir#jfas_graphics.css" rel="stylesheet" type="text/css" />
<link href="#application.paths.cssdir#jfasgraphicsresponse.css" rel="stylesheet" type="text/css" />
</cfoutput>
<style>

.bodyGraphicsStyle {
	font-family: sans-serif;
}

.graphdiv {
  font: 10px sans-serif;
  /* this width does not affect the display, but is dynamically changed when the window size changes. The width is used to calculate jfwidth in setGraphDimensions() */
  width: 800px;
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

.fopSymbol {
  fill: #774A8E;
  stroke: #774A8E;
}

.ecpSymbol {
  fill: #7E1518;
  stroke: #7E1518;
}

.fmsSymbol {
	fill: black;
	stroke: black;
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

body {
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
  margin: auto;
  padding-top: 40px;
  position: relative;
  width: 960px;
}

button {
  position: absolute;
  right: 10px;
  top: 10px;
}

.bullet { font: 10px sans-serif; }
.bullet .marker { stroke: ##000; stroke-width: 2px; }
.bullet .tick line { stroke: ##666; stroke-width: .5px; }
.bullet .range.s0 { fill: ##eee; }
.bullet .range.s1 { fill: ##ddd; }
.bullet .range.s2 { fill: ##ccc; }
.bullet .measure.s0 { fill: lightsteelblue; }
.bullet .measure.s1 { fill: steelblue; }
.bullet .title { font-size: 14px; font-weight: bold; }
.bullet .subtitle { fill: ##999; }

</style>

</head>

<body class="bodyGraphicsStyle">

<cfoutput>
<cfinclude template= "#application.paths.includes#jsGlobal.cfm">
<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>
<script language="javascript"	src="#application.paths.jsdir#jfas.js"></script>
<script language="javascript"	src="#application.paths.jsdir#d3.min.js"></script>
<cfinclude template="#application.paths.includes#jsGraphics.cfm">
<script language="javascript"	src="#application.paths.jsdir#bullets.js"></script>
</cfoutput>

<!--- get the data that was displayed on the home page --->
<cfset na_total = 0>
<cfset cnt= 0>
<!--- get the current filter information from session scope --->
<cfscript>
// these control the overall width and height of the TITLE BLOCK.  They vary according the the height and width of the browser window
tLayout=structNew();
tLayout.titlewidth	= 986;
tLayout.marginleft	= 50;

// display the title block. Anything dependent on the data cannot be displayed here (e.g. the s
application.ographicsUtils.displayTitleForHome( tLayout, tGrStruct, 'bullets.cfm'  );

</cfscript>
<button>Update</button>

<div id="graphdiv" class="graphdiv">

<!--- JAVASCRIPT --->
<script>

/*** original
var margin = {top: 5, right: 40, bottom: 20, left: 120},
    width = 960 - margin.left - margin.right,
    height = 50 - margin.top - margin.bottom;
***/

// these global JS variables get set with the data
// make a structure for the global variables

var glvars = {};

glvars.sFieldString = '';

<cfoutput>
// more global variables, from the jfas calling environment
glvars.nGraphicsTime = '';
glvars.adjustDates = true;

</cfoutput>

<!--- js variables specify the -outside- positioning and size of the chart --->

glvars.jftitleheight = 250; // estimate of the height of the title block

glvars.jfmargintop = 5; // leave room below the title block
glvars.jfmarginleft = 120;  // leave room for y-axis labels to left of axis
glvars.jfmarginbottom = 20; // leave room for x-axis labels on bottom
glvars.jfmarginright = 40; // leave room for text panel to right of graph
glvars.jfwidth = 0;
glvars.jfheight = 0;

// these global variables are not put into the global structure, to maintain consistency with documentation of many d3 graphs

var margin = {}, padding, width, height;


// END of global variables


var displayGraph = function () {

	// functions must appear after the function variables they use

	<CFINCLUDE TEMPLATE="#application.paths.includes#jsGraph1.cfm">

// This displays the whole graph, but the data has already been passed in
// breaks indentation rules, since this is the bulk of this program
var dispGraph = function() {

	var chart = d3.bullet()
		.width(width)
		.height(height);

	/*** Data for sample of bullet charts
	[
	  {"title":"Revenue","subtitle":"US$, in thousands","ranges":[150,225,300],"measures":[220,270],"markers":[250]},
	  {"title":"Profit","subtitle":"%","ranges":[20,25,30],"measures":[21,23],"markers":[26]},
	  {"title":"Order Size","subtitle":"US$, average","ranges":[350,500,600],"measures":[100,320],"markers":[550]},
	  {"title":"New Customers","subtitle":"count","ranges":[1400,2000,2500],"measures":[1000,1650],"markers":[2100]},
	  {"title":"Satisfaction","subtitle":"out of 5","ranges":[3.5,4.25,5],"measures":[3.2,4.7],"markers":[4.4]}
	]
	***/


	// the file name must end in html, not json
	// eliminate this line once "data" is set by ajax
	d3.json("#application.urls.upload#bullets.html", function(error, data) {
	  var svg = d3.select("body").selectAll("svg")
		  .data(data)
		.enter().append("svg")
		  .attr("class", "bullet")
		  .attr("width", width + margin.left + margin.right)
		  .attr("height", height + margin.top + margin.bottom)
		.append("g")
		  .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
		  .call(chart);
	  var title = svg.append("g")
		  .style("text-anchor", "end")
		  .attr("transform", "translate(-6," + height / 2 + ")");

	  title.append("text")
		  .attr("class", "title")
		  .text(function(d) { return d.title; });

	  title.append("text")
		  .attr("class", "subtitle")
		  .attr("dy", "1em")
		  .text(function(d) { return d.subtitle; });

	  d3.selectAll("button").on("click", function() {
		svg.datum(randomize).call(chart.duration(1000)); // TODO automatic transition
	  });
	// });

	function randomize(d) {
	  if (!d.randomizer) d.randomizer = randomizer(d);
	  d.ranges = d.ranges.map(d.randomizer);
	  d.markers = d.markers.map(d.randomizer);
	  d.measures = d.measures.map(d.randomizer);
	  return d;
	}

	function randomizer(d) {
	  var k = d3.max(d.ranges) * .2;
	  return function(d) {
		return Math.max(0, d + k * (Math.random() - .5));
	  };
	}


	} // dispGraph - end of broken indentation rule

	// initial set of dimensions
	setGraphDimensions();
	dispGraph();

} // displayGraph


function reDisplayGraph() {
	// eliminate any previous tooltip
	$(".tooltip").remove();
	$("#svgid").remove();
	displayGraph();
} //reDisplayGraph

function GetDataandRedisplayGraph() {
	// eliminate any previous tooltip
	$(".tooltip").remove();
	$("#svgid").remove();
	adjustDates = true;
	getDataandDisplay();
} //GetDataandRedisplayGraph




var getDataandDisplay = function () {

alert('in getDataandDisplay');
	<cfoutput>
	// JS variables within ready()
	var cfcLink = '#application.urlstart##cgi.http_host##application.paths.components#graphicsRestful.cfc?isBackground=yes';

	var formdata = {
			method:'f_get_bullets'
			, sortBy:url.SortBy
			, sortDir:url.SortDir
			 } ; //array
	</cfoutput>

	// get SOME OF the data from the database, and pass it in to the program to display the graph
	// some of the data is already available in CF, for display of the title section

	// alert('formdata\n\n ' + jsdump(formdata));

	var jqXHR = $.ajax({
				type:	"POST"
				, url:	cfcLink
				, data: formdata   // note this conversion from formdata to data, for ajax
		})

		.success (function(tReturn, statusTxt, xhr){
			//alert('tReturn\n\n' + jsdump(tReturn));
			tReturn = $.parseJSON(tReturn);
			alert("getDataandDisplay tReturn after Parse:\n"+jsdump(tReturn));
			// this is JS
			// Deep copy

			// setting global variables defined at the top
			glvars.data =  convertQueryForD3( $.extend(true, {}, tReturn.QBULLETSDATA) );
			// put the filter description into the title
			$('##sFilterHTML').html(tReturn.SFILTERHTML);

			displayGraph();

		})

		.error (function(jqXHR, statusTxt, errorThrown){
		alert('in error');
		alert("Error: "+statusTxt+": "+errorThrown);
		});

} // getDataandDisplay

$("document").ready(function() {

	$( window ).resize(function() {
		StartGraphDisplayerTimer();
	});

	getDataandDisplay();

}); // ready
</script>

</div>
<!-- graphdiv -->


</body>
</html>
