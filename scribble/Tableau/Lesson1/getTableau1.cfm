<!---getTableau1.cfm--->

<!DOCTYPE html>

<html>
<head>

	<title>Tableau 8.0 JavaScript API On-Demand Tutorial Example</title>
<cfoutput>
    <script language="javascript" src="#application.paths.jsdir#jquery-1.10.2.js"></script> 
</cfoutput>
    <script src="../../includes/javascript/jfas.js"></script>
	<script src="http://d3js.org/d3.v3.min.js"  charset="utf-8"></script>
    
	<link href='http://fonts.googleapis.com/css?family=Roboto' rel='stylesheet' type='text/css'>
	<link href="../../includes/javascript/bootstrap.js" rel="stylesheet" media="screen">
	<script type="text/javascript" src="http://public.tableausoftware.com/javascripts/api/tableau_v8.debug.js"></script>
    <script type="text/javascript" src="LessonOneEnd.js"></script>
</head>
<body>
	<div class='container'>
		<div class='row'>
			<div class='span3'><!---<img src='logo.png' >---></div>
			<h2 class='span7 pagination-centered'>JavaScript API Tutorial</h2>
		</div>
		<div class='row'><h3 class='offset3 span7 pagination-centered' id='sheetName'></h3></div>
		<div class='row'>
		
			<!-- All of our work will happen here -->
			<!-- Viz located at http://public.tableausoftware.com/views/Presents/TreeMap -->
			<ul id = 'menu' class='nav nav-list offset1 span2'>
				<!-- This is the menu where we will add all of our buttons. -->
				<!-- <li class='nav-header'>Switching Views</li> -->
				<!-- <li><a onClick="switchView('LineChart')">LineChart</a></li> -->
			</ul>
			<div id='viz'></div>
            
			<script>
				
			</script>
			
            
			
			<!-- This is the end of the section where we will do our work. -->
		</div>
	</div>
</body>
</html>