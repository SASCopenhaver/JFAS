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
    
	
	<!---<script type="text/javascript" src="LessonTwoEnd.js"></script>--->
<script language="javascript">
//To prevent a bug in IE where the global use of the 'viz' variable
//  interferes with the div id 'viz' (in the html), the following line is needed:
//  Note: this line does not appear in the tutorial videos but should still be used
//    and is in all of the included js files. 
var viz, workbook;

window.onload= function() {
	var vizDiv = document.getElementById('viz');
	var vizURL = "http://public.tableausoftware.com/views/Presents/TreeMap";
	var options = {
		width: '600px',
		height: '540px',
		hideToolbar: true,
		hideTabs: true
	};
	viz = new tableauSoftware.Viz(vizDiv, vizURL, options);
};

var switchView = function(sheetName) {
	workbook = viz.getWorkbook();			// getting viz object
	workbook.activateSheetAsync(sheetName); // 
}
</script>
    
</head>
<body>
	<div class='container'>
		<div class='row'>
			<div class='span3'><!---<img src='logo.png' >---></div>
			<h2 class='span7 pagination-centered'>JavaScript API Tutorial</h2>
		</div>
		<div class='row'><h3 class='offset3 span7 pagination-centered' id='sheetName'></h3></div>
		<!---<div class='row'>--->
		<div >
			<!-- All 
            work will happen here -->
			<!-- Viz located at http://public.tableausoftware.com/views/Presents/TreeMap -->
			<!---<ul id = 'menu' class='nav nav-list offset1 span2'>--->
            <ul id = 'menu' >
				<!-- This is the menu where we will add all of our buttons. -->
				<!---<li class='nav-header'>Switching Views</li>--->
                <li >Switching Views</li>
				<li><a onClick="switchView('LineChart')">LineChart</a></li>
                <li><a onClick="switchView('TreeMap')">TreeMap</a></li>
                <li><a onClick="switchView('MyDashboard')">Dashboard</a></li>
			</ul>
			<div id='viz'></div>
            
			<script>
				
			</script>
			
            
			
			<!-- This is the end of the section where we will do our work. -->
		</div>
	</div>
</body>
</html>