<!---
page: page.cfc

description: functions that get data for tabs, sub-tabs, and page properties

revisions:
2007-02-05	mstein	Modified getFirstLevelTabs to return default_page_id
2007-02-08	mstein	Modified getFirstLevelTabs to show "Close-out" at correct time
2007-03-30	mstein	Modified getFirstLevelTabs to not run getAAPPGeneral for new AAPPs
2010-12-09	mstein	Modified getFirstLevelTabs to not show "Close-out" if year-end recons are pending
--->

<cfcomponent displayname="Page Properties Component" hint="Contains queries and functions for template properties">

	<cffunction name="getPageProperties" access="public" returntype="query" hint="returns page properties">
		<cfargument name="pageID" type="string" required="true">

		<cfquery name="qryGetPageProperties">
		select	page_properties.aapp_section_id as sectionID,
				help_id as helpID,
				p_section_id as parentID
		from	page_properties left outer join aapp_section on
					(page_properties.aapp_section_id = aapp_section.aapp_section_id)
		where	page_properties.page_id = '#arguments.pageID#'
		</cfquery>

		<cfreturn qryGetPageProperties>
	</cffunction>

	<cffunction name="getFirstLevelTabs" access="public" returntype="query" hint="returns list of all primary aapp tabs">
		<cfargument name="aapp" type="numeric" required="no"/>

		<cfset lstServiceTypes = "">
		<cfif isDefined("arguments.aapp")>
			<!--- for DOL Contracts, and Grants, check to see if any real service types are checked --->
			<!--- if just OTHER is checked, don't show Est Cost Profile, Year End, Closeout--->
			<cfinvoke component="#application.paths.components#aapp" method="getAAPPServiceTypes" aapp="#arguments.aapp#" returnvariable="lstServiceTypes">
			<cfset lstServiceTypes = replace(lstServiceTypes, "OT","", "all")>
			<cfif arguments.aapp neq 0>
				<cfinvoke component="#application.paths.components#aapp" method="getAAPPGeneral" aapp="#arguments.aapp#" returnvariable="rstAAPPGeneral">
			</cfif>
		</cfif>

		<!--- are there notes for this AAPP? --->
		<cfinvoke component="#application.paths.components#aapp_note" method="getAAPPNoteCount" aapp="#arguments.aapp#" returnvariable="noteCount" />

		<!--- is a year-end recon pending for this AAPP? --->
		<cfif listfindnocase("DC,GR", request.agreementTypeCode) and arguments.aapp neq 0>
			<cfinvoke component="#application.paths.components#aapp_yearend" method="pendingYERecon" aapp="#arguments.aapp#" returnvariable="pendingCY">
		</cfif>

		<cfquery name="qryGetFirstLevelTabs">
		select	aapp_section.aapp_section_id as sectionID,
				case
				when aapp_section.aapp_section_id = 400 then
					<!--- for grants/contracts with Service Types, that have passed their end date, show "Close-out" label insteaod of Recon --->
					<cfif arguments.aapp neq 0 and listfindnocase("DC,GR", request.agreementTypeCode) and listLen(lstServiceTypes) gt 0 and
							datecompare(rstAAPPGeneral.dateEnd,dateformat(now(), "mm/dd/yyyy")) lt 1 and pendingCY lte 0>
						'Contract Close-out'
					<cfelse>
						aapp_section_name
					</cfif>
				when aapp_section.aapp_section_id = 200 then
					<!--- for grants/contracts with Service Types, that have been awarded, show modified label--->
					<cfif listfindnocase("DC,GR", request.agreementTypeCode) and listLen(lstServiceTypes) gt 0 and request.budgetInputType eq "A">
						'Contract Info'
					<cfelse>
						aapp_section_name
					</cfif>
				when aapp_section.aapp_section_id = 900 then
					<!--- determine if notes exist for this aapp --->
					<cfif noteCount>
						'Notes*'
					<cfelse>
						aapp_section_name
					</cfif>
				else
					aapp_section_name
				end as sectionName,
				case when aapp_section.aapp_section_id = 200 then
					<cfif listfindnocase("DC,GR", request.agreementTypeCode) and listLen(lstServiceTypes) gt 0 and request.budgetInputType eq "A">
						'aapp_contract_award.cfm'
					<cfelse>
						template_name
					</cfif>
				else
					template_name
				end as defaultTemplate,
				case when aapp_section.aapp_section_id = 200 then
					<cfif listfindnocase("DC,GR", request.agreementTypeCode) and listLen(lstServiceTypes) gt 0 and request.budgetInputType eq "A">
						240
					<cfelse>
						default_page_id
					</cfif>
				else
					default_page_id
				end as defaultPageID
		from	aapp_section, page_properties,
				aapp_section_agreement_type, aapp_section_role
		where	p_section_id is null and
				aapp_section.default_page_id = page_properties.page_id and
				aapp_section.aapp_section_id = aapp_section_agreement_type.aapp_section_id and
				agreement_type_code = '#request.agreementTypeCode#' and
				aapp_section.aapp_section_id = aapp_section_role.aapp_section_id (+) and
				aapp_section_role.user_role_id is not null and
				aapp_section_role.user_role_id = #session.roleID#
				<cfif isDefined("arguments.aapp") and listlen(lstServiceTypes) eq 0>
					and aapp_section.aapp_section_id not in (200,400,600)
				</cfif>
		order	by aapp_section.sort_order
		</cfquery>

		<cfreturn qryGetFirstLevelTabs>
	</cffunction>

	<cffunction name="getSecondLevelTabs" access="public" returntype="query" hint="list of secondary aapp sub tabs for given section">
		<cfargument name="sectionID" type="numeric" required="yes">

		<cfquery name="qryGetSecondLevelTabs">
		select	aapp_section.aapp_section_id as sectionID,
				aapp_section_name as sectionName,
				default_page_id as defaultPageID,
				template_name as defaultTemplate
		from	aapp_section, page_properties,
				aapp_section_agreement_type, aapp_section_role
		where	p_section_id = #arguments.sectionID# and
				aapp_section.default_page_id = page_properties.page_id and
				aapp_section.aapp_section_id = aapp_section_agreement_type.aapp_section_id and
				agreement_type_code = '#request.agreementTypeCode#' and
				aapp_section.aapp_section_id = aapp_section_role.aapp_section_id (+) and
				aapp_section_role.user_role_id is not null and
				aapp_section_role.user_role_id = #session.roleID#
		order	by aapp_section.sort_order
		</cfquery>

		<cfreturn qryGetSecondLevelTabs>
	</cffunction>

	<cffunction name="getSecondLevelTabsDyn" access="public" returntype="query" hint="list of secondary aapp sub tabs for given section by user setting">
		<cfargument name="sectionID" type="numeric" required="yes">
		<cfif arguments.sectionID eq 600>
			<cfquery name="qryGetSecondLevelTabs">
			select	0 as sectionID,
					'0' as contract_type_code,
					'Summary' as sectionName,
					610 as defaultPageID,
					'aapp_ecp_summary.cfm' as defaultTemplate
			from	dual
			union
			select	c.sort_order as sectionID,
					c.contract_type_code,
					c.contract_type_desc_long || ' ('|| c.contract_type_desc_short ||')'as sectionName,
					620 as defaultPageID,
					'aapp_ecp_detail.cfm' as defaultTemplate
			from	aapp a, aapp_contract_type b, lu_contract_type c
			where	a.aapp_num=#request.aapp#
			and		a.aapp_num=b.aapp_num
			and		b.contract_type_code=c.contract_type_code
			order by sectionID
			</cfquery>
		</cfif>
		<cfreturn qryGetSecondLevelTabs>
	</cffunction>
</cfcomponent>