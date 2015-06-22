<!--- job_corps_allots_graph.cfm --->
<cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_getFundCat" returncode="no">
        <cfprocresult name="spr_getFundCat" resultset="1">
</cfstoredproc>		<!---<cfdump var="#spr_getFundCat#"><br />--->
<cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_getFundingOffice" returncode="no">
        <cfprocresult name="spr_getFundingOffice" resultset="1">
</cfstoredproc>		<!---<cfdump var="#spr_getFundingOffice#"><br />--->
<cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_getAllotmentAmount" returncode="no">
        <cfprocresult name="spr_getAllotmentAmount" resultset="1">
</cfstoredproc>		<!---<cfdump var="#spr_getAllotmentAmount#"><br />---><!---<cfabort>--->
<!DOCTYPE html>

<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Job Corps Allotments</title>
</head>
<!---<cfpod height=800 width=1000>--->
<body class="form">
<form name="frmJCA" id="frmJCAG"><!--- JCAG: Job Corps Allotments Graph --->
<!---<cfset request.pageID = "2490">--->
<table width="100%" border="0" align="center">
  <tr>
    <td><strong><font size="+1" face="Arial, Helvetica, sans-serif">JFAS Systems Administration</font></strong></td>
  </tr>
  <tr>
    <td><strong><font size="-1" face="Arial, Helvetica, sans-serif">Job Corps Allotments</font></strong></td>
  </tr>
</table>
<div id="div_AllotmentGraph" class="">
<table width="100%" border="0">
<cfloop query="spr_getFundCat" startrow="1" endrow="#spr_getFundCat.recordCount#">
		<cfset v_Fund_Cat_FC      = #fund_cat#> 
		<cfset v_Fund_Cat_Desc_FC = #fund_cat_desc#>
<!---<tr><td><cfoutput><font size="+1" face="Arial, Helvetica, sans-serif">#v_Fund_Cat_FC# - #v_Fund_Cat_Desc_FC#  ($ Millions)</font></cfoutput></td></tr>--->
    <tr>
        <td>
			<cfchart chartwidth="880" 
            		 font="arial" 
                     format="jpg"
            		 labelformat="number"  
                     showlegend="yes"  
                     xAxisTitle="Program Year"
                     showXGridlines="yes" 
                     title="#v_Fund_Cat_FC# - #v_Fund_Cat_Desc_FC#  ($ Millions)"
                     yAxisTitle="$ Millions">
			<cfloop query="spr_getFundingOffice" startrow="1" endrow="#spr_getFundingOffice.recordCount#">
                    <cfset v_Fund_Cat_FO            = #fund_cat#>
                    <cfset v_Funding_Office_Num_FO  = #funding_office_num#>
                    <cfset v_Funding_Office_Desc_FO = #funding_office_desc#>
                    <!---<cfoutput>#v_Funding_Office_Num_FO#</cfoutput>--->
            		<cfif #v_Fund_Cat_FC# EQ #v_Fund_Cat_FO#>
                          <cfchartseries type="cylinder" itemcolumn="#v_Funding_Office_Desc_FO#" paintstyle="light" seriesLabel="#v_Funding_Office_Desc_FO#">
                          <cfloop query="spr_getAllotmentAmount" startrow="1" endrow="#spr_getAllotmentAmount.recordCount#">
                              	  <cfset v_Fund_Cat_AA 			 = #fund_cat#>
                              	  <cfset v_Funding_Office_Num_AA = #funding_office_num#>
                              	  <cfset v_Program_Year_AA 		 = #program_year#>
                              	  <cfset v_Allotment_Amount_AA 	 = #allotment_amount#> 
                                  <cfset v_Grouping_ID_AA		 = #grouping_id#>
                                  <cfif (#v_Fund_Cat_FO# EQ #v_Fund_Cat_AA#) 
								  		AND 
										(#v_Funding_Office_Num_FO# EQ #v_Funding_Office_Num_AA#)
										AND 
										(#v_Grouping_ID_AA# EQ 0)>
								  <!---<cfoutput>#v_Fund_Cat_AA# #v_Funding_Office_Num_AA# #v_Program_Year_AA# #v_Allotment_Amount_AA# #v_Grouping_ID_AA#<br/></cfoutput>--->
                                  		<cfset v_Allotment_Amount_AA = #v_Allotment_Amount_AA#/1000000>
                                        <cfchartdata item="#v_Program_Year_AA#" value="#v_Allotment_Amount_AA#">
                                  </cfif>
                       	  </cfloop><!--- end of "spr_getAllotmentAmount" --->
                          </cfchartseries>
                    </cfif><!--- end of #v_Fund_Cat_FC# EQ #v_Fund_Cat_FO# --->
            </cfloop><!--- end of "spr_getFundingOffice" --->
            </cfchart>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
</cfloop><!--- end of "spr_getFundCat" --->
	<!---<tr><td><font size="+1" face="Arial, Helvetica, sans-serif">Subtotal and Total for Operations and Construction  ($ Millions)</font></td></tr>--->
	<tr>
    	<td>
        		<cfchart chartwidth="880"  
                		 format="jpg" 
                		 labelformat="number" 
                         showlegend="yes" 
                         xAxisTitle="Program Year"
                         title="Subtotal and Total for Operations and Construction  ($ Millions)" 
                         yAxisTitle="$ Millions">
                        <cfloop query="spr_getFundCat" startrow="1" endrow="#spr_getFundCat.recordCount#">
                                <cfset v_Fund_Cat_FC      = #fund_cat#> 
                                <cfset v_Fund_Cat_Desc_FC = #fund_cat_desc#>
                                
                                <cfchartseries type="cylinder" itemcolumn="Subtotal #v_Fund_Cat_FC#" >
                                        <cfloop query="spr_getAllotmentAmount" startrow="1" endrow="#spr_getAllotmentAmount.recordCount#">
                                                <cfset v_Fund_Cat_AA 		   = #fund_cat#>
                                                <cfset v_Funding_Office_Num_AA = #funding_office_num#>
                                                <cfset v_Program_Year_AA 	   = #program_year#>
                                                <cfset v_Allotment_Amount_AA   = #allotment_amount#> 
                                                <cfset v_Grouping_ID_AA		   = #grouping_id#>
                                                <cfif (#v_Fund_Cat_FC# EQ #v_Fund_Cat_AA#) AND (#v_Grouping_ID_AA# EQ 1)>
                                                      <!---<cfoutput>#v_Grouping_ID_AA# #v_Allotment_Amount_AA# #v_Program_Year_AA#</cfoutput><br />--->		
                                                      <cfset v_Allotment_Amount_AA = #v_Allotment_Amount_AA#/1000000>
                                                      <cfchartdata item="#v_Program_Year_AA#" value="#v_Allotment_Amount_AA#">
                                                </cfif>
                                       </cfloop>
                               </cfchartseries>
                        </cfloop>
                        <cfchartseries type="scatter" itemcolumn="Total" >
                                <cfloop query="spr_getAllotmentAmount" startrow="1" endrow="#spr_getAllotmentAmount.recordCount#">
                                        <cfset v_Fund_Cat_AA 		   = #fund_cat#>
                                        <cfset v_Funding_Office_Num_AA = #funding_office_num#>
                                        <cfset v_Program_Year_AA 	   = #program_year#>
                                        <cfset v_Allotment_Amount_AA   = #allotment_amount#> 
                                        <cfset v_Grouping_ID_AA		   = #grouping_id#>
                                        <cfif (#v_Grouping_ID_AA# EQ 3)>
                                            <cfset v_Allotment_Amount_AA = #v_Allotment_Amount_AA#/1000000>
                                            <cfchartdata item="#v_Program_Year_AA#" value="#v_Allotment_Amount_AA#">
                                        </cfif>
                                </cfloop>
                        </cfchartseries>
        		</cfchart>
        </td>
    </tr>
    <!---<tr><td><a href="javascript:sbmtReport(19,'pdf');">PDF</a></td></tr>--->
    
</table>
</div> <!--- end of div_AllotmentGraph --->
</form>
<!---<cfinclude template="#application.paths.includes#footer.cfm">--->
</body>
<!---</cfpod>--->
</html>