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