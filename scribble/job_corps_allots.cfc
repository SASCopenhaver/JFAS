
<cfcomponent displayname="comp_JobCorpsAllot">
		<!--- ............................................................................................................................................. --->
    	<cffunction name="f_getCurrentPY" access="remote" returntype="any" returnformat="plain" output="false" hint="Function returns Current Program Year (PY)">
        	<cfstoredproc procedure="JFAS.ALLOTMENT_AMOUNT_PKG.sp_getCurrentPY" returncode="false">
            	<cfprocresult name="spr_getCurrentPY" resultset="1">
            </cfstoredproc>
            <cfreturn SerializeJSON(spr_getCurrentPY)>
        </cffunction>
		<!--- ............................................................................................................................................. --->
        <cffunction name="f_getAllotment" access="remote" returntype="any" returnformat="plain" output="false"
                    hint="Function returns Jonb Corps Allotments amount within period (CurrentPY - 5) years, CurrentPY, and (CurrentPY + 2) years">
                
                <cfstoredproc procedure="JFAS.ALLOTMENT_AMOUNT_PKG.sp_selectAllotment" returncode="false">
				    <cfprocresult name="spr_selectAllotment" resultset="1">
                </cfstoredproc>
                <cfwddx action="cfml2wddx" input="#spr_selectAllotment#" output="client.sprWDDX_selectAllotmentGraph">
				<cfreturn SerializeJSON(spr_selectAllotment)>
        </cffunction>
		<!--- ............................................................................................................................................. --->
        <cffunction name="f_updAllotment" access="remote" returntype="any" returnformat="plain" output="false" hint="Function updates Allotments that were changed on front-end">
            <cfargument type="string" name="argStringForUpdate" hint="">
            <!---<cfargument type="string" name="argUserID" hint="">--->
            <cfstoredproc procedure="JFAS.ALLOTMENT_AMOUNT_PKG.sp_updAllotment" returncode="false">
            	<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" variable="argStringForUpdate" value="#arguments.argStringForUpdate#" >
                <cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" variable="argUserID" 			value="#arguments.argUserID#" >
            </cfstoredproc>

            <!--- log update --->
			<cfset application.outility.insertSystemAudit (
                      sectionID="1000",
                      description="Job Corps Allotment Data Updated",
                      userID="#session.userID#")>
        </cffunction>
        <!--- ............................................................................................................................................. ---> 
        <!---
        <cffunction name="f_getAllotmentAsCSV" access="remote" returntype="any" returnformat="plain" output="no" hint="D3 Graph">
        	<cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_getAllotmentAsCSV" returncode="no">
        		<cfprocresult name="spr_getAllotmentAsCSV" resultset="1">
			</cfstoredproc>	
            <cfreturn spr_getAllotmentAsCSV>
        </cffunction>
        --->
         <!--- ...................................................................................................................................... --->
        <cffunction name="f_getFundOfficeAllotment" access="remote" returntype="any" returnformat="plain" output="no" hint="D3 Graph">
        	<cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_getFundOfficeAllotment" returncode="no">
        		<cfprocresult name="spr_getFundOfficeAllotment" resultset="1">
			</cfstoredproc>	
            <cfreturn SerializeJSON(spr_getFundOfficeAllotment)>
        </cffunction>         
         <!--- ...................................................................................................................................... --->
         <cffunction name="f_getAAPP_Center_Contr" access="remote" returntype="any" returnformat="plain" output="no" hint="AJAX call for JSON">
        
		 <cfargument type="string" name="argVenue" hint="">
                <cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_getAAPP_Center_Contr" returncode="no" >
                    <cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" variable="argVenue" value="#arguments.argVenue#" >
					<cfprocresult name="spr_getAAPP_Center_Contr" resultset="1">
                </cfstoredproc>
                
                <cfreturn SerializeJSON(spr_getAAPP_Center_Contr)>
				
        </cffunction> 
        <!--- ...................................................................................................................................... --->
        <cffunction name="f_testJSON" access="remote" returntype="any" returnformat="plain" output="no" hint="AJAX call for fop_aapp">
            	<cfargument name="argAAPPnum" type="numeric" required="no">
                <!---<cfoutput>sas: #arguments.argAAPPnum#</cfoutput><cfabort>--->
                <cfset var strucTestJSON = StructNew()>
                
                <cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_test_JSON" returncode="no" >
                    <cfprocparam cfsqltype="cf_sql_numeric" value="#arguments.argAAPPnum#">
                    
                    <cfprocresult name="strucTestJSON.spr_GraphFOPallocation" resultset=1>
                    <cfprocresult name="strucTestJSON.spr_CostCategories"     resultset=2>
					
                </cfstoredproc>
                
                <cfreturn strucTestJSON /> 
                <!---<cfreturn SerializeJSON(spr_GraphFOPallocation_JSON)>--->
        </cffunction>
        <!--- ...................................................................................................................................... --->
        <cffunction name="f_getAllotmentGraph" access="remote" returntype="any" returnformat="plain" output="no" hint="AJAX call for JSON">
                
                <cfset var strucGetAllotmentGraph = StructNew()>
                
                <cfstoredproc procedure="JFAS.ALLOTMENT_AMOUNT_PKG.sp_selectAllotment" returncode="no" >
                
                	<cfprocresult name="spr_getAllotmentGraph" resultset="1">
                
                </cfstoredproc>
                
                <cfreturn SerializeJSON(spr_getAllotmentGraph)>
				
        </cffunction> 
        <!--- ...................................................................................................................................... --->
        
        <cffunction name="f_getGraphTest" access="remote" returntype="any" returnformat="plain" output="no" hint="D3 Graph">
        
        	<cfset var strucGraphTest = StructNew()>
        
        	<cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_getGraphTest" returncode="no">
            
        		<cfprocresult name="strucGraphTest.spr_Timeline" resultset="1">
                <cfprocresult name="strucGraphTest.spr_graphOPS" resultset="2">
                <cfprocresult name="strucGraphTest.spr_graphCRA" resultset="3">
                <cfprocresult name="strucGraphTest.spr_graphTotals" resultset="4">
                
			</cfstoredproc>	
            
            <cfreturn SerializeJSON(strucGraphTest) />
        </cffunction>
        <!--- ...................................................................................................................................... --->
        <cffunction name="f_getGroupedBar" access="remote" returntype="any" returnformat="plain" output="no" hint="D3 Graph">
        
        	<cfset var strucGroupedBar = StructNew()>
        
        	<cfstoredproc procedure="JFAS.ALLOTMENT_GRAPH_PKG.sp_getGroupedBar" returncode="no">
            	<cfprocresult name="strucGroupedBar.spr_GroupedBarOPS" resultset="1">
                <cfprocresult name="strucGroupedBar.spr_GroupedBarCRA" resultset="2">
            </cfstoredproc>	
            
            <cfreturn SerializeJSON(strucGroupedBar) />
        </cffunction>
        <!--- ...................................................................................................................................... --->
</cfcomponent>