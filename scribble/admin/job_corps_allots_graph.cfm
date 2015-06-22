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
<form name="frmJCAG" id="frmJCAG"><!--- JCAG: Job Corps Allotments Graph --->

<div id="div_JSON"></div>

DivGraph starts
<div id="divGrapg"></div>
DivGraph ends

<script>
//-----------------------------------------------------------------------------------------------------
var cfcLink = '<cfoutput>'+'#application.urlstart##cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes'+'</cfoutput>';	
var qDatum = {method: "f_getAllotmentGraph"};
	
$(document).ready(function(){
	var jqXHR = $.ajax({
								url:	cfcLink
							   ,type:	"GET"
							   ,data:	qDatum
					}) // end of .ajax
					.success(function(qDatum, statusTxt, xhr){
						//TEST1: alert(JSON.stringify(qDatum)); 
						//TEST2: alert("SASjsdump:\n\n"+jsdump(qDatum))
						//TEST3: $('#div_JSON').html(qDatum);
						
						f_DrawAllotmentGraph( f_makeJsonD3($.parseJSON(qDatum) ) ) ;
						
					})// end of .success
					.error(function(jqXHR, statusTxt, xhr){
						alert("Error: "+statusTxt+": "+errorThrown);
					});
		
}); // end of ready()
//-----------------------------------------------------------------------------------------------------	
function f_makeJsonD3(arg_JSON){

    var s = arg_JSON || {};
    if( !s.COLUMNS && !s.DATA )
    {
        console.error("convertColdFusionJSON() >>  was not passed a coldfusion serialized object");
        return [];
    }
    //Create returned object
    var obj = [];
    //Loops through serialObj and matches the columns
    for(var i=0; i < s.DATA.length; i++)
    {
        var temp = {};
        for(var j=0; j < s.COLUMNS.length; j++)
        {
            temp[s.COLUMNS[j]] = s.DATA[i][j];
		}
        // save the new row with column names
        obj.push(temp);
    }
	// TEST1: alert("f_makeWorkableJSON \n"+jsdump(obj));
	// TEST2: alert("sas  "+JSON.stringify(obj));
	// TEST3: $('#div_JSON').html(JSON.stringify(obj));
	
	// Return the objects
    return obj;
}
//-----------------------------------------------------------------------------------------------------
function f_DrawAllotmentGraph(argData){
	// TEST: $('#div_JSON').html(JSON.stringify(argData));
	
}
	
//-----------------------------------------------------------------------------------------------------
/*
//=================================================================================================================
var cfcLink = '<cfoutput>'+'#application.urlstart##cgi.http_host##application.paths.components#job_corps_allots.cfc?isBackground=yes'+'</cfoutput>';
var arrayData = {method: "f_getAllotmentGraph"};

$(document).ready(function(){
	var jqXHR = $.ajax({
						 url: 	cfcLink
						,type:	"GET"
						//,dataType:"json"
						,data:	arrayData
				 })
				 .success (function(objAllotmentGraph_JSON, statusTxt, xhr){
					 //TEST1: alert(JSON.stringify(objAllotmentGraph_JSON)); 	 
					 //TEST2: 
					 alert("SASjsdump:\n\n"+jsdump(objAllotmentGraph_JSON))
					 //TEST3: works until ',dataType:"json" 'is set: $('#div_JSON').html(objAllotmentGraph_JSON);
					 
					 f_DrawAllotment( f_makeWorkableJSON( $.parseJSON(objAllotmentGraph_JSON) ) );
						
				 })
				 .error (function(jqXHR, statusTxt, errorThrown){
				 		alert("Error: "+statusTxt+": "+errorThrown);
				 });
});	
//---------------------------------------------------------------------------------------------

function f_makeWorkableJSON(arg_JSON){
	
    var s = arg_JSON || {};
    if( !s.COLUMNS && !s.DATA )
    {
        console.error("convertColdFusionJSON() >>  was not passed a coldfusion serialized object");
        return [];
    }
    //Create returned object
    var obj = [];
    //Loops through serialObj and matches the columns
    for(var i=0; i < s.DATA.length; i++)
    {
        var temp = {};
        for(var j=0; j < s.COLUMNS.length; j++)
        {
            temp[s.COLUMNS[j]] = s.DATA[i][j];
		}
        // save the new row with column names
        obj.push(temp);
    }
	// TEST1: alert("f_makeWorkableJSON \n"+jsdump(obj));
	// TEST2: alert("sas  "+JSON.stringify(obj));
	//$('#div_JSON').html(JSON.stringify(obj));
	
	// Return the objects
    return obj;

}
}
//=============================================================================================
function f_Draw(arg_WorkableJSON){
// TEST 1: alert(jsdump(arg_WorkableJSON))
// TEST 2: $('#div_JSON').html(arg_WorkableJSON);
// TEST 3: alert(JSON.stringify(arg_WorkableJSON)); 

	
}
//=============================================================================================

// Test ends.----------------------------------------------------------------------------------
//=============================================================================================

//=============================================================================================
*/
</script>
</form>
</body>
</html>