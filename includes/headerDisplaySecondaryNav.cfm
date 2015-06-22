<!---
headerDisplaySecondaryNav
--->

<cffunction Name="headerDisplaySecondaryNav">
	<cfsilent>
	<!--- get first level tabs --->
	<cfinvoke component="#application.paths.components#page" method="getFirstLevelTabs" pageID="#request.pageID#" aapp="#url.aapp#" returnvariable="rstFirstLevelTabs">

	<cfif request.pageSectionID neq "">
		<!--- get second level tabs --->
		<cfswitch expression="#request.pageSectionID#">
			<cfcase value="600">
				<cfinvoke component="#application.paths.components#page" method="getSecondLevelTabsDyn" sectionID="#request.pageSectionID#" returnvariable="rstSecondLevelTabs">
			</cfcase>
			<cfdefaultcase>
				<cfinvoke component="#application.paths.components#page" method="getSecondLevelTabs" sectionID="#request.parentSectionID#" returnvariable="rstSecondLevelTabs">
			</cfdefaultcase>
		</cfswitch>
	</cfif>
	</cfsilent>

	<cfif rstFirstLevelTabs.recordCount gt 0>
		<!--- display main level tabs --->
		<!--- link will be inactive if it points to the page that is currently being displayed --->
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr class="ctrSubNav">
			<td>
				<ul id="SubNav">
				<cfoutput query="rstFirstLevelTabs">
					<li <cfif sectionID eq request.parentSectionID or (sectionID eq 600 and len(request.parentSectionID) eq 0)>id="current2"</cfif>>
					<a href="<cfif (url.aapp neq 0) and (request.pageID neq defaultPageID)>#defaultTemplate#?aapp=#url.aapp#<cfelse>##</cfif>">#sectionName#</a></li>
				</cfoutput>
				</ul>
			</td>
		</tr>
		<tr class="ctrTerNav">
			<td>
				<!--- display sub-tabs --->
				<!--- link will be inactive if it points to the page that is currently being displayed --->
				<cfoutput query="rstSecondLevelTabs">
					<a href="
						<cfif url.aapp neq 0 and find(request.pageID,"610,620")>
							#defaultTemplate#?aapp=#url.aapp#&ContractTypeCode=#contract_type_code#
						<cfelseif (url.aapp neq 0) and (defaultPageID neq request.pageID)>
							#defaultTemplate#?aapp=#url.aapp#
						<cfelse>
							##
						</cfif>"
						<!---Only for Estimate Cost Profile--->
						<cfif find(request.pageID,"610,620") and isDefined("url.ContractTypeCode")>
							<cfif url.ContractTypeCode eq contract_type_code>
								class="current"
							</cfif>
						<!---Others--->
						<cfelse>
							<cfif defaultPageID eq request.pageID>
								class="current"
							</cfif>
						</cfif>
						>
						#sectionName#</a>
					<cfif currentRow neq recordCount> | </cfif>
				</cfoutput>
				<cfif rstSecondLevelTabs.recordcount eq 0>&nbsp;</cfif>
			</td>
		</tr>
		</table>
	</cfif> <!--- first level tabs found? --->

	<!---
	<cfif session.showDebug>
		<cfif isDefined("rstPageProperties")>
			<cfdump var="#rstPageProperties#" label="page properties"><br><br />
		</cfif>
		<cfif isDefined("rstFirstLevelTabs")>
			<cfdump var="#rstFirstLevelTabs#" label="first level tabs"><br><br />
		</cfif>
		<cfif isDefined("rstSecondLevelTabs")>
			<cfdump var="#rstSecondLevelTabs#" label="second level tabs"><br><br />
		</cfif>
	</cfif>
	--->
</cffunction> <!--- headerDisplaySecondayNav --->
