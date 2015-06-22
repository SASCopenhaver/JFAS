<!---
page: utility.cfc

description: component that handles system utility functions

revisions:
07-10-2007	rroser	add functions to search for recent updates/release notes
07-26-2007	yjeng	add functions to format string to different type
2014-03-29	mstein	Added getQuarter function
--->
<cfcomponent displayname="Lookup Component" hint="Contains various functions/methods for JFAS System">

	<cffunction name="getCurrentSystemProgramYear" access="public" returntype="numeric" hint="Returns current program year (DOL AAPPS)">

		<cfquery name="qryCurrentPY">
		select utility.fun_getcurrntprogram_year as currentPY
		from dual
		</cfquery>

		<cfreturn qryCurrentPY.currentPY>
	</cffunction>

	<cffunction name="getCurrentSystemProgramYear_CCC" access="public" returntype="numeric" hint="Returns current program year (CCCs)">

		<cfquery name="qryCurrentPY">
		select utility.fun_getcurrntprogram_year_ccc as currentPY
		from dual
		</cfquery>

		<cfreturn qryCurrentPY.currentPY>
	</cffunction>

	<cffunction name="getProgramYearDate" access="public" returntype="date" hint="Returns start or end date of specified PY">
		<cfargument name="py" type="numeric" required="yes">
		<cfargument name="type" type="string" required="no" default="S">

		<cfquery name="qryPYdate">
		select Utility.fun_get_py_date (#arguments.py#, '#ucase(arguments.type)#') as PYdate
		from dual
		</cfquery>

		<cfreturn qryPYdate.PYDate>
	</cffunction>



	<cffunction name="getYear_byDate" access="public" returntype="numeric" hint="Returns current fiscal/program/calendar year based on date">
		<cfargument name="yearType" type="string" required="no" default="C">
		<cfargument name="baseDate" type="date" required="no" default="#now()#">

		<cfquery name="qryYear_byDate">
		select utility.fun_get_year(to_date('#dateformat(arguments.baseDate, "mm/dd/yyyy")#','MM/DD/YYYY'),'#ucase(yearType)#') as getYear
		from dual
		</cfquery>

		<cfreturn qryYear_byDate.getYear>
	</cffunction>

	<cffunction name="insertSystemAudit" access="public" returntype="void" hint="Inserts history record in system auditing table">

		<cfargument name="aapp" type="numeric" required="no" />
		<cfargument name="statusID" type="numeric" required="no" />
		<cfargument name="fopID" type="numeric" required="no" />
		<cfargument name="adjustID" type="numeric" required="no" />
		<cfargument name="sectionID" type="numeric" required="no" />
		<cfargument name="description" type="string" required="yes" />
		<cfargument name="userID" type="string" required="yes" />

		<cfquery name="qryInsertAudit" >
		insert into system_audit (
			audit_id,
			<cfif isDefined("arguments.aapp")>aapp_num,</cfif>
			<cfif isDefined("arguments.statusID")>contract_status_id,</cfif>
			<cfif isDefined("arguments.fopID")>fop_id,</cfif>
			<cfif isDefined("arguments.adjustID")>adjustment_id,</cfif>
			<cfif isDefined("arguments.sectionID")>aapp_section_id,</cfif>
			<cfif isDefined("arguments.description")>description,</cfif>
			user_id)
		values (
			seq_system_audit.nextval,
			<cfif isDefined("arguments.aapp")>#arguments.aapp#,</cfif>
			<cfif isDefined("arguments.statusID")>#arguments.statusID#,</cfif>
			<cfif isDefined("arguments.fopID")>#arguments.fopID#,</cfif>
			<cfif isDefined("arguments.adjustID")>#arguments.adjustID#,</cfif>
			<cfif isDefined("arguments.sectionID")>#arguments.sectionID#,</cfif>
			<cfif isDefined("arguments.description")>'#arguments.description#',</cfif>
			'#arguments.userID#')
		</cfquery>

	</cffunction>

	<cffunction name="getSystemSetting" access="public" returntype="string" hint="Gets value (by code) from System Setting table">
		<cfargument name="systemSettingCode" type="string" required="yes">

		<cfquery name="qrySystemSetting">
		select	value
		from	system_setting
		where	system_setting_code = '#arguments.systemSettingCode#'
		</cfquery>

		<cfreturn qrySystemSetting.value>

	</cffunction>

	<cffunction name="getPOCs" access="public" returntype="query" hint="Gets contact information">
		<cfargument name="contactType" type="string" required="no">

		<cfquery name="qryContactTypes">
		select	system_setting_code,
				value
		from	system_setting
		where	1=1
			<cfif isDefined("arguments.contactType")>
				and system_setting_code like '#arguments.contactType#%'
			</cfif>
		</cfquery>

		<cfset qryContacts = QueryNew("#valuelist(qryContactTypes.system_setting_code)#")>
		<cfset temp = QueryAddRow(qryContacts)>
		<cfloop query="qryContactTypes">
			<cfset temp = QuerySetCell(qryContacts, system_setting_code, value)>
		</cfloop>

	<cfreturn qryContacts>

	</cffunction>

	<cffunction name="GetCurrentQuarterNum" access="public" returntype="numeric" hint="Get Current Quarter Number">
		<cfargument name="quarter_type" type="string" required="true">

		<cfquery name="qryCurrentQuarter">
		select utility.fun_get_quarter(sysdate, '#arguments.quarter_type#') as currentQuarterNum
		from dual
		</cfquery>

		<cfreturn qryCurrentQuarter.currentQuarterNum>
	</cffunction>

	<cffunction name="VerticalList" access="public" returntype="string" hint="Convert the list to order by Vertical">
		<cfargument name="col" type="numeric" required="true">
		<cfargument name="list" type="string" required="true">
		<cfargument name="blank_filler" type="string" required="no" default="NA">
		<cfset newlist="">
		<cfset looper=1>
		<cfset container=arraynew(2)>
		<cfif arguments.col neq 0>
			<cfset row=ceiling(listlen(arguments.list)/arguments.col)>
			<cfloop index="idx" from="1" to="#arguments.col#">
				<cfloop index="idx1" from="1" to="#row#">
					<cfset pos=idx+(idx1-1)*arguments.col>
					<cfif pos gt listlen(arguments.list)>
						<cfset container[idx1][idx]=arguments.blank_filler>
					<cfelse>
						<cfset container[idx1][idx]=listgetat(arguments.list,looper)>
						<cfset looper=looper+1>
					</cfif>
				</cfloop>
			</cfloop>
			<cfloop index="idx" from="1" to="#row#">
				<cfloop index="idx1" from="1" to="#arguments.col#">
					<cfset newlist=listappend(newlist,container[idx][idx1])>
				</cfloop>
			</cfloop>
		<cfelse>
			<cfset newlist=arguments.list>
		</cfif>
		<cfreturn newlist>
	</cffunction>

	<cffunction name="Crosstab" access="public" returntype="array" hint="Provide a crosstab function by return 2 dimension array">
		<!---Query for Crosstab: data source --->
		<cfargument name="qry" type="query" required="true">
		<!---A column in qry. In crosstab presentation will be the columns--->
		<cfargument name="col" type="string" required="true">
		<!---A column in qry. Display order for col, require if order by other column--->
		<cfargument name="col_sort" type="string" required="no" default="#arguments.col#">
		<!---A column in qry. In crosstab presentation will be the rows--->
		<cfargument name="row" type="string" required="true">
		<!---A column in qry. Display order for row usually same as row--->
		<cfargument name="row_sort" type="string" required="no" default="#arguments.row#">
		<!---The value column in qry.--->
		<cfargument name="val" type="string" required="true">
		<!---In crosstab presentation will be the [1][1] usually this is a header--->
		<cfargument name="corner" type="string" required="no">
		<!---In crosstab presentation, will be [1][col] if supply, instead of display col, you can specify the columns namem usually this is header--->
		<cfargument name="col_titles" type="string" required="no">
		<cfset crosstab=arraynew(2)>
		<cfquery name="total_rows" dbtype="query">
			select	distinct #arguments.row# as row_name
			from	arguments.qry
			order by #arguments.row_sort#
		</cfquery>
		<cfset row_list=valuelist(total_rows.row_name)>
		<cfquery name="total_cols" dbtype="query">
			select	distinct #arguments.col# as col_name
			from	arguments.qry
			order by #arguments.col_sort#
		</cfquery>
		<cfset col_list=valuelist(total_cols.col_name)>

		<cfquery name="subqry" dbtype="query">
			select	#arguments.row# as subrow, #arguments.col# as subcol, #arguments.val# as subvalue
			from	arguments.qry
		</cfquery>
		<!---Initial Array--->
		<cfloop index="idx_row" from="1" to="#listlen(row_list)+1#">
			<cfloop index="idx_col" from="1" to="#listlen(col_list)+1#">
				<cfset crosstab[idx_row][idx_col]="">
			</cfloop>
		</cfloop>
		<!---Setup for corner--->
		<cfset crosstab[1][1]=#arguments.corner#>
		<!---Crosstabing -- Setup for first Column--->
		<cfif isDefined("arguments.col_titles") and listlen(arguments.col_titles) and listlen(arguments.col_titles) eq listlen(col_list)>
		<cfloop index="idx" from="1" to="#listlen(arguments.col_titles)#">
			<cfset crosstab[1][#idx#+1]=#listgetat(arguments.col_titles,idx)#>
		</cfloop>
		<cfelse>
		<cfloop query="total_cols">
			<cfset crosstab[1][#currentrow#+1]=#col_name#>
		</cfloop>
		</cfif>

		<!---Crosstabing -- Setup for first Row--->
		<cfloop query="total_rows">
			<cfset crosstab[#currentrow#+1][1]=#row_name#>
		</cfloop>
		<!---Fill in Array from [2][2]--->
		<cfloop query="subqry">
			<cfset col_position=listfind(col_list,subcol)+1>
			<cfset row_position=listfind(row_list,subrow)+1>
			<cfset crosstab[#row_position#][#col_position#]=subvalue>
		</cfloop>
		<cfreturn crosstab>
	</cffunction>



	<cffunction name="formatString" access="public" returntype="string" hint="Returns string on specify type and format">
		<cfargument name="str" type="string" required="yes">
		<cfargument name="type" type="string" required="yes">
		<cfargument name="mask" type="string" required="no">
		<cfargument name="except" type="string" required="no" default="">
		<cfset myStr = "">
		<cftry>
			<cfswitch expression="#type#">
				<cfcase value="dollar">
					<cfif arguments.str lt 0>
						<cfset myStr = "-$"&#numberformat(abs(arguments.str),",")#>
					<cfelse>
						<cfset myStr = "$"&#numberformat(arguments.str,",")#>
					</cfif>
				</cfcase>
				<cfcase value="int">
					<cfset myStr = #int(arguments.str)#>
				</cfcase>
				<cfcase value="date">
					<cfset myStr = #dateformat(arguments.str,arguments.mask)#>
				</cfcase>
				<cfcase value="time">
					<cfset myStr = #timeformat(arguments.str,arguments.mask)#>
				</cfcase>
			</cfswitch>
			<cfcatch type="any">
				<cfset myStr = arguments.except>
			</cfcatch>
		</cftry>
		<cfreturn myStr>
	</cffunction>

	<cffunction name="getFormVersion" access="public" returntype="numeric" hint="Return most recent form version (based on type passed)">
		<cfargument name="formType" type="string" required="yes">

		<cfquery name="qryGetFormVersion">
		select	max(form_version) as maxVersion
		from	lu_form_version
		where	form_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formType)#">
		</cfquery>

		<cfreturn qryGetFormVersion.maxVersion>

	</cffunction>


	<cffunction name="getOMBInflationRate" access="public" returntype="numeric" hint="Takes date, and returns OMB infl rate on that date">
		<cfargument name="effectDate" type="date" required="true">
		<cfargument name="costCat" type="string" required="false" default="A" hint="B3 uses different method of infl rate">

		<cfquery name="qryGetOMBRate">
		select utility.fun_get_omb_inflat_rate('#dateformat(arguments.effectDate,"dd-mmm-yyyy")#','#arguments.costCat#') as ombRate
		from dual
		</cfquery>
		<cfreturn qryGetOMBRate.ombRate>

	</cffunction>


	<cffunction name="getQuarter" access="public" returntype="numeric" hint="Returns quarter of the year, based on date">
		<cfargument name="yearType" type="string" required="yes" default="PROG">
		<cfargument name="myDate" type="date" required="yes" default="#now()#">

		<cfswitch expression="#arguments.yearType#">
			<cfcase value="PROG">
				<cfswitch expression="#month(arguments.myDate)#">
					<cfcase value="7,8,9">		<cfset myQtr = 1></cfcase>
					<cfcase value="10,11,12">	<cfset myQtr = 2></cfcase>
					<cfcase value="1,2,3">		<cfset myQtr = 3></cfcase>
					<cfcase value="4,5,6">		<cfset myQtr = 4></cfcase>
				</cfswitch>
			</cfcase>
			<cfcase value="FISC">
				<cfswitch expression="#month(arguments.myDate)#">
					<cfcase value="7,8,9">		<cfset myQtr = 4></cfcase>
					<cfcase value="10,11,12">	<cfset myQtr = 1></cfcase>
					<cfcase value="1,2,3">		<cfset myQtr = 2></cfcase>
					<cfcase value="4,5,6">		<cfset myQtr = 3></cfcase>
				</cfswitch>
			</cfcase>
			<cfcase value="CAL">
				<cfswitch expression="#month(arguments.myDate)#">
					<cfcase value="7,8,9">		<cfset myQtr = 3></cfcase>
					<cfcase value="10,11,12">	<cfset myQtr = 4></cfcase>
					<cfcase value="1,2,3">		<cfset myQtr = 1></cfcase>
					<cfcase value="4,5,6">		<cfset myQtr = 2></cfcase>
				</cfswitch>
			</cfcase>
		</cfswitch>

		<cfreturn myQtr>

	</cffunction>


</cfcomponent>