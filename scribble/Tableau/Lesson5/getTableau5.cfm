<!---getTableau4.cfm--->

<!DOCTYPE html>

<html>
<head>

	<title>Tableau 8.0 JavaScript API On-Demand Tutorial Example</title>
<cfoutput>
    <script language="javascript" src="#application.paths.jsdir#jquery-1.10.2.js"></script> 
</cfoutput>
    <!---<script src="../../includes/javascript/jfas.js"></script>--->
	<!---<script src="http://d3js.org/d3.v3.min.js"  charset="utf-8"></script>--->
    
	<link href='http://fonts.googleapis.com/css?family=Roboto' rel='stylesheet' type='text/css'>
	<link href="bootstrap.css" rel="stylesheet" media="screen">
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
		hideTabs: true,
		onFirstInteractive: function(){
			//alert("Interactive");
			workbook = viz.getWorkbook();
		}
	};
	viz = new tableauSoftware.Viz(vizDiv, vizURL, options);
	//viz.addEventListener("marksselection", function(){ alert("Marks has been selected."); });
};
//-----------------------------------------------------------------------------------------
var switchView = function(sheetName) {
	//workbook = viz.getWorkbook();			// getting viz object
	workbook.activateSheetAsync(sheetName); // 
}
//-----------------------------------------------------------------------------------------
var showOnly = function (filterName, values){
	sheet = viz.getWorkbook().getActiveSheet();
	if (sheet.getSheetType() === "worksheet")
	{
		sheet.applyFilterAsync(filterName, values, "REPLACE");
	}
	else
	{
		worksheetArray = sheet.getWorksheet();
		for (var i=0; i<worksheetArray.length; i++)	
		{
			worksheetArray[i].applyFilterAsync(filterName, values, 'REPLACE');
		}
	}
} // end of showOnly
//-----------------------------------------------------------------------------------------
function alsoShow(filterName, values) 
{
	sheet = viz.getWorkbook().getActiveSheet();
	if(sheet.getSheetType() === 'worksheet') {
		sheet.applyFilterAsync(filterName, values, 'ADD');
	} else {
		worksheetArray = sheet.getWorksheets();
		for(var i = 0; i < worksheetArray.length; i++) {
			worksheetArray[i].applyFilterAsync(filterName, values, 'ADD');
		}
	}
}
//-----------------------------------------------------------------------------------------
function dontShow(filterName, values) {
	sheet = viz.getWorkbook().getActiveSheet();
	if(sheet.getSheetType() === 'worksheet') {
		sheet.applyFilterAsync(filterName, values, 'REMOVE');
	} else {
		worksheetArray = sheet.getWorksheets();
		for(var i = 0; i < worksheetArray.length; i++) {
			worksheetArray[i].applyFilterAsync(filterName, values, 'REMOVE');
		}
	}
}
//-----------------------------------------------------------------------------------------
function clearFilter(filterName) {
	sheet = viz.getWorkbook().getActiveSheet();
	if(sheet.getSheetType() === 'clearFilter') {
		sheet.clearFilterAsync(filterName);
	} else {
		worksheetArray = sheet.getWorksheets();
		for(var i = 0; i < worksheetArray.length; i++) {
			worksheetArray[i].clearFilterAsync(filterName);
		}
	}
}
//-----------------------------------------------------------------------------------------
function selectMarks(filterName, values) {
	sheet = viz.getWorkbook().getActiveSheet();
	if(sheet.getSheetType() === 'worksheet') {
		sheet.selectMarksAsync(filterName, values, 'REPLACE');
	} else {
		worksheetArray = sheet.getWorksheets();
		for(var i = 0; i < worksheetArray.length; i++) {
			worksheetArray[i].selectMarksAsync(filterName, values, 'REPLACE');
		}
	}
}
//-----------------------------------------------------------------------------------------
function problemExample()
{
	// Not Properly Working code:
	workbook = viz.getWorkbook();
	workbook.activateSheetAsync('LineChart');
	sheet = workbook.getActiveSheet();
	sheet.applyFilterAsync("Category", "Stuffed Animal","REPLACE");
}
//-----------------------------------------------------------------------------------------
function solution() {
	//workbook = viz.getWorkbook();
	workbook.activateSheetAsync('LineChart').then(function() {
		sheet = workbook.getActiveSheet();
		//throw new Error('Oooops!');
		sheet.applyFilterAsync('Category','Stuffed Animal','REPLACE');
		return "Hello there";
	//.then(callback).otherwise(errback).always(callAlways)
	}).then(function(parameterString) {
		//alert(parameterString + " it worked!");
		alertFunc(parameterString + " it worked!")
	}, function(err) {
		alertFunc(err + " It Didn't work!");
	});
}
//-----------------------------------------------------------------------------------------
function alertFunc(arg_Msg)
{
	alert(arg_Msg);	
}
//-----------------------------------------------------------------------------------------
var listenerOn = false;
function toggleSelectionAlert()
{
	if (listenerOn)
	{
		listenerOn = false;
		viz.removeEventListener("marksselection", alertFunc(" listenerOn = false "));
	}
	else
	{
		listenerOn = true;
		vis.addEventListener("marksselection", alertFunc(" listenerOn = true "));
	}
}
//-----------------------------------------------------------------------------------------
</script>
    
</head>
<body>
	<div class='container'>
		<div class='row'>
			<div class='span3'><!---<img src='logo.png' >---></div>
			<h2 class='span7 pagination-centered'>Tutorial</h2>
		</div>
		<div class='row'><h3 class='offset3 span7 pagination-centered' id='sheetName'></h3></div>
		<div class='row'>
        
			<!-- All 
            work will happen here -->
			<!-- Viz located at http://public.tableausoftware.com/views/Presents/TreeMap -->
			<!---<ul id = 'menu' class='nav nav-list offset1 span2'>--->
            <ul id = 'menu' class='nav nav-list span2'>
				<!-- This is the menu where we will add all of our buttons. -->
				<li class='nav-header'>Switching Views</li>
					<li><a onClick="switchView('LineChart')">LineChart</a></li>
                	<li><a onClick="switchView('TreeMap')">TreeMap</a></li>
                	<li><a onClick="switchView('MyDashboard')">Dashboard</a></li>
                
                <li class='nav-header'>Filtering & Selecting Marks</li>
                	<li><a onClick="showOnly('Category','Book');">Show Only Books</a></li>
                	<li><a onClick="alsoShow('Category',['Gift Certificates','Doll','Electronics','Blocks']);">Also Show Certificates, Dolls, Electronics, Books</a></li>
                	<li><a onClick="dontShow('Category',['Gift Certificates','Doll']);">Don't Show Gift Certificates and Dolls</a></li>
                    <li><a onClick="clearFilter('Category');">Clear Category Filter</a></li>
                    <li><a onClick="selectMarks('Category',['Electronics', 'Gift Certificates']);">Select Electronics Marks and Gift Certif.</a></li>
                    
                <li class='nav-header'>Asyncronous Programming</li>
                	<li><a onClick="problemExample();">Problem Example</a></li>
                    <li><a onClick="solution();">Solution</a></li>
                    <li><a onClick="toggleSelectionAlert();">Toggle Selection Alert</a></li>
                	
			</ul>
			<div id='viz'></div>
 
            
			
			<!-- This is the end of the section where we will do our work. -->
		</div>
	</div>
</body>
</html>