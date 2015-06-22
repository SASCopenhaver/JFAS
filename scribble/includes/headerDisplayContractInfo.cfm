<cfsilent>
<!---
page: headerDisplayContractInfo.cfm

description: header portion with app contract info

revisions:
2007-12-18	rroser	defect #6
					only display Contractor Name and Contract Number line when one exists,
					only display slash between them when both exist
2007-09-10	mstein	added "Reactivate this AAPP" button if AAPP is inactive, and user is admin
2011-12-02	mstein	changed aapp_summary to aapp_setup
--->
<cfparam name="url.hidMode" default="">
</cfsilent>

<cfoutput>
<cffunction name="headerDisplayContractInfo">
	<cfif request.aapp neq 0>
		<h1>AAPP #request.aapp# #request.centerName#</h1>
		<!--- button to create successor, will display in header if: --->
		<!--- 1) AAPP is contract or grant --->
		<!--- 2) Successor does not exist yet --->
		<!--- 3) current contract is 3.5 years from end date (or less) --->
		<!--- 4) user has appropriate access --->
		<cfif listfindnocase("DC,GR",request.agreementTypeCode) and
			  (request.succAAPPNum eq "") and
			  (dateDiff("m",now(), request.dateEnd) lte 42) and
			  (listFindNoCase("1,2", session.roleID)) and
			  (request.statusID eq 1)>
			<div class="btnRight">
			<form action="aapp_setup.cfm" method="get">
			<input type="hidden" name="aapp" value="0" />
			<input type="hidden" name="predaapp" value="#url.aapp#" />
			<input type="hidden" name="hidMode" value="copy" />
			<input type="hidden" name="radAgreementType" value="DC" />
			<input name="btnSubmit" type="submit" value="Create Successor" />
			</form>
			</div>
		</cfif>
		<!--- if AAPP is inactive, and current user is admin, show button to reactivate --->
		<cfif request.statusID eq 0 and session.roleID eq 2>
			<div class="btnRight">
			<form action="aapp_setup.cfm" method="get">
			<input type="hidden" name="aapp" value="#request.aapp#" />
			<input type="hidden" name="reactivateAAPP" value="1" />
			<input name="btnSubmit" type="submit" value="Reactivate this AAPP" />
			</form>
			</div>
		</cfif>

		<cfswitch expression="#request.agreementTypeCode#">
			<cfcase value="DC,GR">
				<p class="contractInfo">
				<cfif request.contractorName neq '' or request.contractNum neq ''>
				<cfif request.contractorName neq ''>#request.contractorName#</cfif><cfif request.contractorName neq '' and request.contractNum neq ''> / </cfif><cfif request.contractNum neq ''>#request.contractNum#</cfif>
				<br />
				</cfif>
				#request.fundingOfficeDesc#<br />
				Start date: #dateformat(request.dateStart, "mm/dd/yyyy")#;&nbsp;
				End date: #dateformat(request.dateEnd, "mm/dd/yyyy")#
				<cfif request.predAAPPNum neq "">
					<br />
					Predecessor: <a href="#application.paths.aapp#?aapp=#request.predAAPPNum#">#request.predAAPPNum#</a>
				</cfif>
				<cfif request.succAAPPNum neq "">
					<br />
					Successor: <a href="#application.paths.aapp#?aapp=#request.succAAPPNum#">#request.succAAPPNum#</a>
				</cfif>
				</p>
			</cfcase>
			<cfdefaultcase>
				<p class="contractInfo">
				<cfif request.contractNum neq "">#request.contractNum#<br /></cfif>
				#request.fundingOfficeDesc#<br />
				</p>
			</cfdefaultcase>
		</cfswitch>

	<cfelseif url.hidMode eq "new">
		<h1>Create New AAPP</h1><br />
	<cfelseif url.hidMode eq "copy">
		<h1>Create Successor AAPP</h1><br />
	</cfif>
</cffunction>
</cfoutput>