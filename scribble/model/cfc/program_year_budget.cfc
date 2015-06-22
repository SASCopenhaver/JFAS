<!--- program_year_budget.cfc --->
<cfcomponent displayname="comp_ProgramYearBudget">
		<!--- ............................................................................................................................................. --->
    	<cffunction name="f_getCurrentPY" access="remote" returntype="any" returnformat="plain" output="false" hint="Function returns Current Program Year (PY)">
        	<cfstoredproc procedure="JFAS.PROGRAM_YEAR_BUDGET_PKG.sp_getCurrentPY" returncode="false">
            	<cfprocresult name="spr_getCurrentPY" resultset="1">
            </cfstoredproc>
            
            <cfreturn SerializeJSON(spr_getCurrentPY)>
           
        </cffunction>
		<!--- ............................................................................................................................................. --->
        <cffunction name="f_getProgramYears" access="remote" returntype="any" returnformat="plain" output="false" hint="Function returns Program Years">
        	<cfstoredproc procedure="JFAS.PROGRAM_YEAR_BUDGET_PKG.sp_getProgramYears" returncode="false">
            	<cfprocresult name="spr_getProgramYears" resultset="1">
            </cfstoredproc>
            <cfreturn SerializeJSON(spr_getProgramYears)>
        </cffunction>
        
		<!--- ............................................................................................................................................. --->
        <cffunction name="f_getProgramYearBudget" access="remote" returntype="any" returnformat="plain" output="false" hint="Function returns Program Year Budget">
        	<cfargument name="arg_selectedPY" type="numeric" required="yes">
            <cfset var str_ProgramYearBudget = StructNew()>
            
            <cfstoredproc procedure="JFAS.PROGRAM_YEAR_BUDGET_PKG.sp_getProgramYearBudget" returncode="false">
				<cfprocparam type="in" cfsqltype="cf_sql_numeric" variable="arg_selectedPY" value="#arguments.arg_selectedPY#" >
            		
                <cfprocresult name="str_ProgramYearBudget.spr_PY_Budget_Appropriation" resultset="1">
                <cfprocresult name="str_ProgramYearBudget.spr_PY_Budget_Allotment" resultset="2">
                <cfprocresult name="str_ProgramYearBudget.spr_PY_Budget" resultset="3">
                
            </cfstoredproc>

            <cfreturn SerializeJSON(str_ProgramYearBudget)>
        </cffunction>
        
        
        <!--- ............................................................................................................................................. --->
</cfcomponent>

       <!--- ...................................................................................................................................... 
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
        ...................................................................................................................................... --->
