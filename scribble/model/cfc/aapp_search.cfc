<!---
page: aapp_search.cfc

description: Search AAPPs

revisions:
2007-01-18	rroser	force text field searches to upper case
					make results for sorting by contract num case insensitive
2007-07-12	rroser	add venue to search feature
2007-07-23	mstein	Modified getSearchResults to allow regional office users access to CCCs
2009-10-20	mstein	Modified function to handle basic and advanced search differently	
--->

<cfcomponent displayname="Search" hint="Component that contains search functions">
	
	<cffunction name="getSearchResults" hint="Get general info about AAPP based on search criteria" returntype="struct" access="public">
		<cfargument name="formData" type="struct" required="yes">
		<cfargument name="sortby" type="string" required="no" default="aappNum">
		<cfargument name="sortDir" type="string" required="no" default="asc">
		
		<cfset stcResults = StructNew()>
		<cfset stcResults.aappRedirect = "">
		
		<!--- check to see if user entered numeric value --->
		<!--- if so, determine if there is an exact match on AAPP number --->
		<cfif arguments.formData.hidSearchType eq "basic" and isNumeric(arguments.formData.txtSearchText)
			and (arguments.formData.cboSearchIn eq "gen" or arguments.formData.cboSearchIn eq "aapp")>
			<cfquery name="qryGetResultsCount" datasource="#request.dsn#">
			select	aapp_num
			from	aapp
			where	aapp_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.txtSearchText#">
			<cfif listFind("3,4", session.roleID, ",")> <!--- for regional users, only search CCCs, and AAPPs from their region --->
				and (funding_office_num = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.region#" maxlength="4"> or agreement_type_code = 'CC')
			</cfif>
			</cfquery>
			
			<cfif qryGetResultsCount.recordcount>
				<cfset stcResults.aappRedirect = arguments.formData.txtSearchText>
			</cfif>
		</cfif>
		
		
		<cfif stcResults.aappRedirect eq ""> <!--- single matching aapp num was not found --->
	
			<!--- query against search results view --->	
			<cfquery name="qryGetSearchResults" datasource="#request.dsn#">
			select	distinct
					aappNum,
					programActivity,
					dateStart,
					dateEnd,
					contractStatusDesc,
					centerName,
					Venue,
					fundingOfficeDesc,
					contractNum,
					contractorName
			from	aapp_searchresults_view, footprint		
			where	aapp_searchresults_view.aappNum = footprint.aapp_num (+)
			
			<!--- if search is being performed from Quick Search (upper right) --->			
			<cfif arguments.formData.hidSearchType is "basic">
				
				<cfswitch expression="#arguments.formData.cboSearchIn#">
				<cfcase value="gen">
					and (
						upper(centerName) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtSearchText)#%" maxlength="24"> or
						upper(contractorName) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtSearchText)#%" maxlength="24"> or
						upper(contractNum) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtSearchText)#%" maxlength="24"> or
						upper(doc_num) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtSearchText)#%" maxlength="24">
					)
					</cfcase>
				<cfcase value="aapp">
					and aappNum = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.txtSearchText#" maxlength="24">
					</cfcase>
				<cfcase value="docno">
					and upper(doc_num) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtSearchText)#%" maxlength="24">
					</cfcase>
				<cfcase value="contractno">
					and upper(contractNum) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtSearchText)#%" maxlength="24">
				</cfcase>
				<cfcase value="contractorname">
					and upper(ContractorName) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtSearchText)#%" maxlength="24">
				</cfcase>
				<cfcase value="centername">
					and upper(centerName) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtSearchText)#%" maxlength="24">
				</cfcase>
				</cfswitch>
				
			<cfif listFind("3,4", session.roleID, ",")> <!--- for regional users, only show CCCs, and AAPPs from theior region --->
				and (fundingOfficeNum = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.region#" maxlength="4"> or agreementTypeCode = 'CC')
			</cfif>
			
			
		<!--- if search is being executed from Advanced Search Form --->
		<cfelseif arguments.formData.hidSearchType eq "advanced">
			
			<cfif arguments.formData.txtAAPP is not ''>
				and aappNum = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.txtAAPP#" maxlength="6">
			</cfif>
			
			<cfif arguments.formData.radStatus is not 'all'>
				and contractStatusID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.radStatus#" maxlength="1">
			</cfif>
			
			<cfif arguments.formData.txtDocumentNum is not ''>
				and upper(doc_num) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtDocumentNum)#%" maxlength="24">
			</cfif>
			<cfif arguments.formData.txtContractNum is not ''>
				and upper(contractNum) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtContractNum)#%" maxlength="24">
			</cfif>
			<cfif arguments.formData.cboAgreementTypeFilter is not 'all'>
				and upper(agreementTypeCode) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.cboAgreementTypeFilter)#" maxlength="5">
			</cfif>
			<cfif arguments.formData.cboServiceTypeFilter is not 'all'>
				and upper(contractTypes) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(arguments.formData.cboServiceTypeFilter)#%" maxlength="5">
			</cfif>
			<cfif arguments.formData.txtContractor is not ''>
				and upper(contractorName) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtContractor)#%" maxlength="30">
			</cfif>
			<cfif arguments.formData.txtCenter is not ''>
				and centerName like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.formData.txtCenter)#%" maxlength="30">
			</cfif>
			<cfif arguments.formData.cboFundingOfficeFilter is not 'all'>
				and fundingOfficeNum = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.cboFundingOfficeFilter#" maxlength="2">
			</cfif>
			<cfif arguments.formData.txtStartDate1 is not '' and arguments.formData.txtStartDate2 is not ''>
				and dateStart between
				<cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(arguments.formData.txtStartDate1, "dd-mmm-yyyy")#" maxlength="11"> and
				<cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(arguments.formData.txtStartDate2, "dd-mmm-yyyy")#" maxlength="11">
			</cfif>
			<cfif arguments.formData.txtEndDate1 is not '' and arguments.formData.txtEndDate2 is not ''>
				and dateEnd between
				<cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(arguments.formData.txtEndDate1, "dd-mmm-yyyy")#" maxlength="11"> and
				<cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(arguments.formData.txtEndDate2, "dd-mmm-yyyy")#" maxlength="11">
			</cfif>
			<cfif arguments.formData.txtFopDesc is not ''>
				and aappNum in (select	aapp_num 
								from	FOP
								where	upper(fop_description) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(arguments.formData.txtFopDesc)#%" maxlength="50">
							    )
			</cfif>
			<cfif listFind("3,4", session.roleID, ",")> <!--- for regional users, only show CCCs, and AAPPs from theior region --->
				and (fundingOfficeNum = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.region#" maxlength="4"> or agreementTypeCode = 'CC')
			</cfif>
		</cfif>
		
		<cfif isDefined("arguments.sortBy")>
		order	by <cfif arguments.sortby is 'contractNum'>
						upper(#arguments.sortBy#) #arguments.sortDir#
					<cfelse>
						#arguments.sortby# #arguments.sortDir#	
					</cfif>
		</cfif>
		</cfquery>
		
		
		
			<cfset stcResults.qryGetSearchResults = qryGetSearchResults>
		</cfif>
 				
		<cfreturn stcResults>
	
	</cffunction>
	
	
	
	
</cfcomponent>