<div id="chartContainer">
<cfoutput>
<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>
<script language="javascript"	src="#application.paths.jsdir#jfas.js"></script>
<script language="javascript"	src="#application.paths.jsdir#d3.min.js"></script>
<script language="javascript"	src="#application.paths.jsdir#dimple.js"></script>
</cfoutput>
  <script type="text/javascript">
  	<!--- refers to div above --->
    var svg = dimple.newSvg("#chartContainer", 590, 400);
    var parseDate = d3.time.format("%Y-%m-%d").parse;	// match the date format in the data file

    <cfoutput>
    d3.csv("#application.urls.upload#dimplesimple.csv", function (data) {
    </cfoutput>
		data.forEach(function(d) {
			// convert to a date object in each record from the data file
			d.date = parseDate(d.date);
		});

		//data = dimple.filterData(data, "Owner", ["Aperture", "Black Mesa"])
		var myChart = new dimple.chart(svg, data);
		// parameters are x, y, width, height within the svg. Moving y-axis left chops the display on the right
		myChart.setBounds(60, 30, 505, 305);

		// last argument is a field in the data
		var xAxis = myChart.addAxis("x", null, null, "date");

		// picks up all the date values in ascending order. "date" is field name
		xAxis.addOrderRule("date");

		xAxis.title = 'Simple Date';
		xAxis.tickFormat = "%m/%Y";
		var yAxis = myChart.addMeasureAxis("y", "Millions");

		// here is the magic!
		Constructor: dimple.series(chart, categoryFields, xAxis, yAxis, zAxis, colorAxis, plotFunction, aggregateMethod, stacked)
		arguments: (categoryFields, plotFunction, axes (optional))
		// add a time series.  fundtype is categoryFields, and is field name in data, dimple.plot.line is plotFunction
		myChart.addSeries("fundtype", dimple.plot.line);

		// x, y, width, height, horizontal align, series. Note y is measured down from the top
		myChart.addLegend(60, 10, 500, 20, "right");
		myChart.draw();
    });
  </script>
</div>
