<!--- jsGraph1.cfm --->
var setGraphDimensions = function() {
	// function in a function.
	// I adjust the height and width of a jfas graph, based on the width of the browser window
	// Most variables are defined in the surrounding routne

	// js variables specify the -outside- positioning and size of the chart


	// setting width to match the width of graphdiv (almost). That width is set by responsive style sheet
	glvars.jfwidth = +1 * cssToNumber('#graphdiv', 'width') - 50;
	glvars.jfheight = window.innerHeight - glvars.jftitleheight; // leave room for the title block

	margin =
			{top: glvars.jfmargintop,
			right: glvars.jfmarginright,
			bottom: glvars.jfmarginbottom,
			left: glvars.jfmarginleft};

	padding = 30;
	width = glvars.jfwidth - margin.left - margin.right;
	height = glvars.jfheight - margin.top - margin.bottom;

} // setGraphDimensions

var StartGraphResizerTimer = function () {
	if ( glvars.nGraphicsTime !== '') {
		clearInterval( glvars.nGraphicsTime);
	}
	glvars.nGraphicsTime = setInterval(function () {
		graphResizer();
	},300); // milliseconds

} // StartGraphResizerTimer


var graphResizer = function () {
	if ( glvars.nGraphicsTime !== '') {
		clearInterval( glvars.nGraphicsTime);
	}
	glvars.nGraphicsTime = '';

	reDisplayGraph();

} // graphResizer

