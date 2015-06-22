

<cfcomponent displayname="Inflation" hint="Component that contains inflation functions">

	<cffunction name="getOMBInflation" hint="Get OMB inflation rates" returntype="query" access="public">

		<cfquery name="qryGetOMBInflationResults" datasource="#request.dsn#" maxrows="13">
			select YEAR,
				INFLATION_RATE,
				STATUS
			from OMB_INFLATION
			where
				YEAR >= to_date('#Dateformat(DateAdd("yyyy", -4, Now()), "mm/dd/yyyy")#', 'MM/DD/YYYY')
			order by year

		</cfquery>

		<cfreturn qryGetOMBInflationResults>

	</cffunction>


	<cffunction name="saveOMBInflation" hint="Save Changes to OMB inflation rates" returntype="struct" access="public">
		<cfargument name="FormData" type="struct" required="yes">

		<!--- set the number of years that should be shown in the form - this should match the same variable in omb_inflation.cfm --->
		<cfset display_years = 13>

		<!--- set variables to be returned to determine location --->
		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cftransaction>
			<!--- Query for the latest date, to decide if rows will be updated or inserted --->
			<cfquery name="qryGetMaxOMBInflation" datasource="#request.dsn#">
			select Max(YEAR) as LastYear
			from OMB_INFLATION
			</cfquery>


			<!--- loop through the form data, either updating or inserting --->
			<cfloop index="i" from="0" to="#evaluate(display_years - 1)#">
				<cfset strDate = Dateformat(Dateadd("yyyy", i, arguments.FormData.FirstDate), "mm/dd/yyyy")>
			<!--- if the year being submitted is already in the database --->
				<cfif arguments.FormData["year_" & replace(strDate, "/", "_", "all")] LTE qryGetMaxOMBInflation.LastYear>
			<!--- update the record in the database --->
					<cfquery name="qryUpdateOMBInflationResults" datasource="#request.dsn#">
						update OMB_INFLATION
						set INFLATION_RATE = '#replace(arguments.FormData["rate_" & replace(strDate, "/", "_", "all")], ",", "", "all")#',
						<cfif arguments.FormData["status_" & replace(strDate, "/", "_", "all")] is 'ON'>
							STATUS = 1,
						<cfelse>
							STATUS = 0,
						</cfif>
							UPDATE_USER_ID = '#session.userID#',
							UPDATE_FUNCTION = '#request.auditVarUpdate#',
							UPDATE_TIME = sysdate
						Where YEAR = to_date('#arguments.FormData["year_" & replace(strDate, "/", "_", "all")]#', 'MM/DD/YYYY')
					</cfquery>

				<cfelse><!--- if the year being submitted isn't in the database, insert new records --->

					<cfquery name="qryInsertOMBInflationResults" datasource="#request.dsn#">
					insert into OMB_INFLATION
					(YEAR, STATUS, INFLATION_RATE, UPDATE_USER_ID, UPDATE_FUNCTION, UPDATE_TIME)
					values
					(to_date('#arguments.FormData["year_" & replace(strDate, "/", "_", "all")]#', 'MM/DD/YYYY'),
						<cfif #arguments.FormData["status_" & replace(strDate, "/", "_", "all")]# is "ON">
							1,
						<cfelse>
							0,
						</cfif>
					#arguments.FormData["rate_" & replace(strDate, "/", "_", "all")]#, '#session.userID#', '#request.auditVarInsert#', sysdate)
					</cfquery>

				</cfif>
			</cfloop>
		</cftransaction>

	<!--- Set variables to be returned --->
	<cfset stcResults = StructNew()>
	<cfset stcResults.success = success>

	<cfreturn stcResults>

	</cffunction>

	<cffunction name="getFpwInflation" access="public" returntype="query" hint="Get Inflation Rates for Federal Personnel Wages" >
		<cfargument name="firstYear" required="no" default="#Evaluate(dateFormat(now(), "YYYY") - 1)#" type="numeric">
		<cfargument name="displayYears" required="no" default="10" type="numeric">

		<cfquery name="qryGetFWPInflation" datasource="#request.dsn#" maxrows="#displayYears#">
			Select	Year as year,
						Date_Start as startDate,
						Rate_Planned as ratePlan,
						Rate_Actual as rateAct,
						status as status
			From		Fed_Pers_Inflation
			Where 		Year >= #arguments.firstYear#
			Order By	Year
		</cfquery>

		<cfreturn qryGetFWPInflation>
	</cffunction>


	<cffunction name="saveFpwInflation" access="public" returntype="struct" hint="Save changes to OMB inflation rate">
		<cfargument name="FormData" type="struct" required="yes">

		<cfset success = "true">
		<cfset errorMessages = "">
		<cfset errorFields = "">

		<cftransaction>
			<cfquery name="getMaxYear" datasource="#request.dsn#">
				Select	max(Year) as lastYear
				from	Fed_Pers_Inflation
			</cfquery>

			<cfloop from="0" to="#Evaluate(arguments.formData.hidDisplayYears - 1)#" index="i">
				<cfif Evaluate(arguments.formData.hidFirstYear + i) lte getMaxYear.lastYear>

					<cfquery name="qryUpdateFpwInflation" datasource="#request.dsn#">
						Update	Fed_Pers_Inflation
						Set		Date_Start = to_date('#arguments.formData['txt_' & (arguments.formData.hidFirstYear + i) & '_startDate']#', 'MM/DD/YYYY'),
								Rate_Planned = #arguments.formData['txt_' & (arguments.formData.hidFirstYear + i) & '_planned']#,
								Rate_Actual = #arguments.formData['txt_' & (arguments.formData.hidFirstYear + i) & '_actual']#,
								<cfif arguments.formData['txt_' & (arguments.formData.hidFirstYear + i) & '_status'] is "ON">
									Status = 1,
								<cfelse>
									Status = 0,
								</cfif>
								UPDATE_USER_ID = '#session.userID#',
								UPDATE_FUNCTION = '#request.auditVarUpdate#',
								UPDATE_TIME = sysdate
						Where	Year = #arguments.formData['txt_' & (arguments.formData.hidFirstYear + i) & '_Calyear']#
					</cfquery>
				<cfelse>
					<cfquery name="qryInsertFpwInflation" datasource="#request.dsn#">
						Insert into Fed_Pers_Inflation
						Fields	(Year,
								Date_Start,
								Rate_Planned,
								Rate_Actual,
								Status,
								UPDATE_USER_ID,
								UPDATE_FUNCTION,
								UPDATE_TIME)
						Values	(#arguments.formData['txt_' & (arguments.formData.hidFirstYear + i) & '_Calyear']#,
								to_date('#arguments.formData['txt_' & (arguments.formData.hidFirstYear + i) & '_startDate']#', 'MM/DD/YYYY'),
								#arguments.formData['txt_' & (arguments.formData.hidFirstYear + i) & '_planned']#,
								#arguments.formData['txt_' & (arguments.formData.hidFirstYear + i) & '_actual']#,
								<cfif arguments.formData['txt_' & (arguments.formData.hidFirstYear + i) & '_status'] is "ON">
									1,
								<cfelse>
									0,
								</cfif>
								'#session.userID#',
								'#request.auditVarInsert#',
								sysdate
								)
					</cfquery>
				</cfif>

			</cfloop>

			<cfset application.outility.insertSystemAudit (
			description="Update Federal Wage Inflation",
			userID="#session.userID#")>
		</cftransaction>

		<cfset stcResults = StructNew()>
		<cfset stcResults.success = success>

		<cfreturn stcResults>

	</cffunction>

</cfcomponent>