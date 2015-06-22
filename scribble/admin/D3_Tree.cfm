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

<div id="div_Tree"></div>

<script>
<cfoutput>
var v_Datum	= "#application.urls.upload#treeData.csv";
</cfoutput>
// TEST: alert(v_Datum)
//=================================================================================================================
//( function(){
	//-------------------------------------	
	var canvas = d3.select("#div_Tree")
						.append("svg")
							.attr("width", 500)
							.attr("height", 500)
							.append("g")
								.attr("transform", "translate(50,50)");
	//-------------------------------------		
	var tree = d3.layout.tree()
							.size([400,400]);
	//-------------------------------------

	//d3.json("http://devetareports.doleta.gov/cfdocs/grantee_prod/jfas_sergey/jfas/admin/tempupload/treeData.json", function(data){
		d3.json(v_Datum, function(data){
		var nodes = tree.nodes(data);
		var links = tree.links(nodes);
		//console.log(nodes);
		var node = canvas.selectAll(".node")
							.data(nodes)
							.enter()
							.append("g")
								.attr("class", "node")
								.attr("transform", function(d){return "translate ("+d.y+","+d.x+")";});
		node.append("circle")					
				.attr("r", 5)
				.attr("fill", "red");
		
		//circle.on("click", function(){
		//			d3.select(this).attr("r",20);
		//});		
				
		
		node.append("text")
				.text(function(d){return d.name;});
		
		var diagonal = d3.svg.diagonal()
								.projection(function(d){return [d.y, d.x]});
		
		canvas.selectAll(".link")
					.data(links)
					.enter()
					.append("path")
					.attr("fill", "none")
					.attr("stroke", "gray")
					.attr("d", diagonal);
		
	});
// Path. builds line: ---------------------------------------------------------------------------------------------
/*
	var canvas = d3.select("#id_Parph2")
						.append("svg")
							.attr("width", 200)
							.attr("height", 200);
	var data = [
					{x:10, y:20},
					{x:30, y:60},
					{x:50, y:70},
					{x:100, y:50}
				];
	var group = canvas.append("g")
						.attr("transform", "translate(100,100)");
						
	var line = d3.svg.line()
						.x(function(d){return d.x;})
						.y(function(d){return d.y;});
						
		group.selectAll("path")
				.data([data])
				.enter()
				.append("path")
				.attr("d", line)
				.attr("fill", "none")
				.attr("stroke", "green")
				.attr("stroke-width", 10);

//})();
*/
</script>
</form>
</body>
</html>