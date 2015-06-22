<!--- jsGraph1.cfm --->
<script>
// this is all JavaScript
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

}; // setGraphDimensions

var StartGraphDisplayerTimer = function () {
	if ( glvars.nGraphicsTime !== '') {
		clearInterval( glvars.nGraphicsTime );
	}
	glvars.nGraphicsTime = setInterval(function () {
		GraphDisplayer();
	},300); // milliseconds

}; // StartGraphDisplayerTimer


var GraphDisplayer = function () {
	if ( glvars.nGraphicsTime !== '') {
		clearInterval( glvars.nGraphicsTime);
	}
	glvars.nGraphicsTime = '';

	reDisplayGraph();

}; // GraphDisplayer


function startGrapherCompletionTimer () {

	// this starts timer to be sure graphics display completes within a few seconds
	if (glvars.nGrapherCompletionTimer != '') {
		clearInterval(glvars.nGrapherCompletionTimer);
	}

	glvars.nGrapherCompletionTimer = setInterval(function () {

		popGrapherCompletionFailed();

	},  glvars.nTimeForGrapherCompletion); // milliseconds

} // startGrapherCompletionTimer

function popGrapherCompletionFailed () {

	if (glvars.nGrapherCompletionTimer == '') {
		// the flag was cleared by DisplayAAPPsAjax upon successful completion of the display of the graph
		return;
	}

	// finished with Completion timer
	clearInterval(glvars.nGrapherCompletionTimer);

	glvars.nGrapherCompletionTimer = '';

	alert('Your current browser version and settings may not support the display of this chart. If you do not see the chart displayed, please contact the JFAS POC (on the Contact page). ');

} // popGrapherCompletionFailed

function startRedisplayGraphTimer () {
	// this is about the delay for clicking multiple checkboxes
	//alert('in startRedisplayGraphTimer');
	if (glvars.nLatestCheckboxTimer != '') {
		clearInterval(glvars.nLatestCheckboxTimer);
	}
	// readyRedisplayGraphTimer() will execute after the checkbox delay, to run submitAnyCheckBoxes()
	glvars.nLatestCheckboxTimer = setInterval(function () {

		readyRedisplayGraphTimer();

	}, glvars.nTimeForCheckboxes);

} // startRedisplayGraphTimer

function readyRedisplayGraphTimer( ) {
	// finished with the checkbox timer
	//alert('in readyRedisplayGraphTimer');
	if ( glvars.nLatestCheckboxTimer != '') {
		clearInterval( glvars.nLatestCheckboxTimer);
	}
	 glvars.nLatestCheckboxTimer = '';

	// start the timer on completion of submitAnyCheckBoxes
	startGrapherCompletionTimer();

	submitAnyCheckBoxes();

} // readyRedisplayGraphTimer

function convertQueryForD3(oJSON) {
	// this is like f_makeWorkableJSON, except converts column headings to lower case
	// this is JAVASCRIPT
	// I take an object of two properties:  COLUMNS and DATA
	// COLUMNS is an ARRAY of column headings
	// DATA is an ARRAY of objects
	//		the first object contains the values for row1 in the query
	//		each object in the data array has an array of values.

    var s = oJSON || {};
    if( !s.COLUMNS && !s.DATA )
    {
        console.error("convertColdFusionJSON() >>  was not passed a coldfusion serialized object");
        return [];
    }
    // so that we don't change the calling object, create a local copy of the column names, lower case
    var aColumnNames = [];
	for(var cColumn=0; cColumn < oJSON.COLUMNS.length; cColumn++) {
		aColumnNames[ cColumn ] = oJSON.COLUMNS[ cColumn ].toLowerCase();
	}

    // Create returned object, which is an ARRAY
    var aReturn = [];

    for(var rRow=0; rRow < oJSON.DATA.length; rRow++) {
    	// for this row
        var oRowData = {};
        for(cColumn=0; cColumn < oJSON.COLUMNS.length; cColumn++) {
        	// for this column, create an object, like {b1:123}
            oRowData[aColumnNames[cColumn]] = oJSON.DATA[rRow][cColumn];
		}
        // save the new row with column names
        aReturn.push(oRowData);
    }
	// TEST1: alert("f_makeWorkableJSON \n"+jsdump(aReturn));
	// TEST2: alert(JSON.stringify(aReturn));

	// Return the array of objects
    return aReturn;
}

</script>
