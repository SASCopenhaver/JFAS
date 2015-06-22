<cfstoredproc procedure="JFAS.ALLOTMENT_AMOUNT_PKG.sp_selectAllotmentGraph" returncode="no">
        <cfprocresult name="spr_getFundCat" resultset="1">
</cfstoredproc>
<cfdump var="#spr_getFundCat#"><cfabort>







<!--- job_corps_allots_graph.cfm --->
<!---<cfdump var="#client.sprWDDX_selectAllotmentGraph#" /><cfabort>--->
<cfwddx action="wddx2cfml" input="#client.sprWDDX_selectAllotmentGraph#" output="q_selectAllotmentGraph">

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Job Corps Allotments</title>
</head>

<body>
<form name="frmJCA" id="frmJCA">
<!---<cfset request.pageID = "2490">--->
<h1>JFAS Systems Administration</h1>
<h2>Job Corps Allotments ($) Graph</h2>

<div id="div_AllotmentGraph" class="">

<!---<cfset v_ColumnList = #q_selectAllotmentGraph.columnList#>
<cfoutput>#v_ColumnList#</cfoutput><cfabort>--->

<cfoutput>#application.paths.components#</cfoutput>


	<cfloop query="q_selectAllotmentGraph">
    	<cfif fund_cat EQ fund_office_num>
        	<cfset variables.v_Fund_Cat = fund_cat>
            <cfbreak>
        </cfif>
    </cfloop>
	
    
    <cfloop query="q_selectAllotmentGraph">
		<cfif (fund_cat NEQ 'TBL_HEADER') AND (fund_cat NEQ 'ATOTAL') >
			  	  
				<cfset variables.v_Fund_Cat_Iteration = #q_selectAllotmentGraph.fund_cat#>
				
				<cfif #variables.v_Fund_Cat_Iteration# EQ #variables.v_Fund_Cat#>
					<!---<cfoutput>#variables.v_Fund_Cat#</cfoutput><br />	--->
				<cfelse>
					<cfbreak>
				</cfif>
		</cfif>
		
	</cfloop><!--- end of q_selectAllotmentGraph --->
<br />

<cfchart>
	<!---Boston--->
    <cfchartseries type="bar" valuecolumn="Boston" >
    	<cfchartdata item="2010" value="10">
        <cfchartdata item="2011" value="13333">
        <cfchartdata item="2012" value="10000">
        <cfchartdata item="2013" value="10000">
        <cfchartdata item="2014" value="0">
        <cfchartdata item="2015" value="0">
	</cfchartseries>

	<!---Phila--->
    <cfchartseries type="bar" >
    	<cfchartdata item="2010" value="500">
        <cfchartdata item="2011" value="1300">
        <cfchartdata item="2012" value="0">
        <cfchartdata item="2013" value="20000">
        <cfchartdata item="2014" value="0">
        <cfchartdata item="2015" value="0">
	</cfchartseries>
    
	<!---Atlanta--->
    <cfchartseries type="bar" >
    	<cfchartdata item="2010" value="100">
        <cfchartdata item="2011" value="99000">
        <cfchartdata item="2012" value="0">
        <cfchartdata item="2013" value="30000">
        <cfchartdata item="2014" value="0">
        <cfchartdata item="2015" value="0">
	</cfchartseries>
	
	<!---Dallas--->
    <cfchartseries type="bar" >
    	<cfchartdata item="2010" value="0">
        <cfchartdata item="2011" value="0">
        <cfchartdata item="2012" value="0">
        <cfchartdata item="2013" value="40000">
        <cfchartdata item="2014" value="0">
        <cfchartdata item="2015" value="0">
	</cfchartseries>
    
	<!---Chicago--->
    <cfchartseries type="bar" >
    	<cfchartdata item="2010" value="0">
        <cfchartdata item="2011" value="0">
        <cfchartdata item="2012" value="0">
        <cfchartdata item="2013" value="50000">
        <cfchartdata item="2014" value="0">
        <cfchartdata item="2015" value="0">
	</cfchartseries>

	<!---San Francisco--->
    <cfchartseries type="bar" >
    	<cfchartdata item="2010" value="0">
        <cfchartdata item="2011" value="0">
        <cfchartdata item="2012" value="0">
        <cfchartdata item="2013" value="60000">
        <cfchartdata item="2014" value="456666">
        <cfchartdata item="2015" value="0">
	</cfchartseries>
    
	<!---National--->
    <cfchartseries type="bar" >
    	<cfchartdata item="2010" value="0">
        <cfchartdata item="2011" value="0">
        <cfchartdata item="2012" value="0">
        <cfchartdata item="2013" value="70000">
        <cfchartdata item="2014" value="0">
        <cfchartdata item="2015" value="0">
	</cfchartseries>
    
	<!---Subtotal--->
    <cfchartseries type="line" >
    	<cfchartdata item="2010" value="610">
        <cfchartdata item="2011" value="113633">
        <cfchartdata item="2012" value="10000">
        <cfchartdata item="2013" value="280000">
        <cfchartdata item="2014" value="456666">
        <cfchartdata item="2015" value="0">
	</cfchartseries>
</cfchart>




</div> <!--- end of div_AllotmentGraph --->

</form>
<cfinclude template="#application.paths.includes#footer.cfm">
</body>
</html>