<cfsilent>
<!---
page: aapp_yearend.cfm

description: page that allows user to perform an end of contract year reconcialiation (or view a previously executed one)

revisions:
2006-12-28	mstein	Fixed defect 59 - year-end recon without Center Ops service type
2007-02-08	mstein	Fixed defect 135 - javascript error on non-OPS recon
2007-02-16	mstein	Adjusted page/help IDs
2007-09-12	mstein	Added in check for mod numbers... if they have not been assigned through year being reconciled,
					then process cannot be executed.
2007-09-12	mstein	allwoed segment ratings to be entered with one decimal place
2011-02-28	mstein	Rel 2.8 eliminates C1C2 column.
					Added Excess Underrun row which is now displayed, and saved
					Disabled Recalc button when form is valid, and user has not changed any values
2011-04-14	mstein	Release 2.7.1 - allowed for recon execution, even with no variances in planned/actual
--->
<cfset request.pageID = "420" />

<!--- Notes:
When page is first loaded, getYearEndData is called which takes the AAPP # and year
and determines whether this recon has already been perofrmed (pulls static recon record from db), or
if it is pending (pulls source data from FMS tables).

In the case of a recon that is pending (form is editable), the function calculateYearEndAmounts,
will then be called, to generate all of the calculated amounts. This is separate from getYearEndData,
because the user may be changing numbers multiple times (performance ratings, FMS dollars), which
requires a recalc, but does not require a trip to grab the FMS data again.

Once the user executes the recon, the record is saved, the necessary adjustments made, and the user is taken back tot he summary page.
--->

<cfif isDefined("form.hidAAPP")> <!--- form has been submitted --->

	<cfif form.hidAction eq "save">
		<!--- create Year-End Data --->
		<cfinvoke component="#application.paths.components#aapp_yearend" method="saveYearEndData" formData="#form#" returnvariable="stcYearendSaveResults" />

		<cfif stcYearendSaveResults.success>
			<!--- redirect back to summary page --->
			<cflocation url="aapp_yearend_summary.cfm?aapp=#url.aapp#&save=1" />
		<cfelse>
			<!--- otherwise set list of error messages --->
			<cfset variables.lstErrorMessages = stcYearendSaveResults.errorMessages />
			<cfset variables.lstErrorFields = stcYearendSaveResults.errorFields />
		</cfif>

	<cfelseif form.hidAction eq "undo">

		<cfinvoke component="#application.paths.components#aapp_yearend" method="deleteYearEndData" aapp="#url.aapp#" contractyear="#url.contractYear#" />

		<!--- redirect back to summary page --->
		<cflocation url="aapp_yearend_summary.cfm?aapp=#url.aapp#&save=1" />
	</cfif>


<cfelse> <!--- first time viewing form --->

	<!--- get year-end data (component will decide if data is existing, --->
	<!--- or if this is for a pending year-end recon --->
	<cfinvoke component="#application.paths.components#aapp_yearend" method="getYearEndData"
		aapp="#url.aapp#" contractYear="#url.contractYear#" returnvariable="rstYearEndData">


	<cfif rstYearEndData.recordCount neq 0> <!--- valid year passed in --->

	<cfinvoke component="#application.paths.components#aapp_yearend" method="GetNumofPYs"
	 CYStartDate="#DateFormat(rstYearEndData.contractYearStartDate, 'mm/dd/yyyy')#"
	 CYEndDate="#DateFormat(rstYearEndData.contractYearEndDate, 'mm/dd/yyyy')#"
	 returnvariable="rstNumOfPYs">

		<!---<cfdump var="#rstYearEndData#" />--->
		<cfset lstServiceTypes = valueList(rstYearEndData.costCatCode) />


		<!--- determine if this is data for an existing reconciliation, or if it is pending --->
		<cfif rstYearEndData.actualRollover eq "">
			<cfset form.hidMode = "edit" /> <!--- pending reconciliation (edit mode) --->
		<cfelse>
			<cfset form.hidMode = "readonly" />	<!--- existing reconciliation (readonly mode) --->
			<cfset request.pageID = "421" />
		</cfif>

		<cfset form.hidReportingDate = rstYearEndData.reportingDate />
		<cfset form.hidContractYearStartDate = rstYearEndData.contractYearStartDate/>
		<cfset form.hidContractYearEndDate = rstYearEndData.contractYearEndDate/>
		<cfset form.hidSeg1_startDate  = rstYearEndData.dateSeg1Start />
		<cfset form.hidSeg1_endDate  = rstYearEndData.dateSeg1End />
		<cfset form.hidSeg2_startDate  = rstYearEndData.dateSeg2Start />
		<cfset form.hidSeg2_endDate  = rstYearEndData.dateSeg2end />
		<cfset form.txtComments = rstYearEndData.comments />
		<cfset form.hidServiceTypes = lstServiceTypes />
		<cfset form.hidNumOfPYs = rstNumOfPYs />
		<cfset form.hidFormVersion = rstYearEndData.formVersion>

		<cfloop query="rstYearEndData">
			<!--- loop through service types, and populate form fields with data --->
			<cfif costcatCode eq "A">
				<cfset form[costcatCode & "_perfRatingSeg1"] = perfRatingSeg1 />
				<cfset form[costcatCode & "_perfRatingSeg2"] = perfRatingSeg2 />
				<cfset form[costcatCode & "_perfRatingWeighted"] = perfRatingWeighted />
				<cfif SYplanned neq "">
					<cfset form[costcatCode & "_SYplanned"] = SYplanned />
				<cfelse>
					<cfset form[costcatCode & "_SYplanned"] = 0>
				</cfif>
				<cfset form[costcatCode & "_SYplanned_hid"] = form[costcatCode & "_SYplanned"]>

				<cfif SYactual neq "">
					<cfset form[costcatCode & "_SYactual"] = SYactual />
				<cfelse>
					<cfset form[costcatCode & "_SYactual"] = 0>
				</cfif>
				<cfset form[costcatCode & "_SYactual_hid"] = form[costcatCode & "_SYactual"]>

				<cfif SYplanned is "" or SYactual is "" or SYplanned is "0" or SYactual is "0">
					<cfset form[costcatCode & "_capUtilization"] = 0 />
				<cfelse>
					<cfset form[costcatCode & "_capUtilization"] = SYactual/SYplanned />
				</cfif>
				<cfset form[costcatCode & "_SYcostPer"] = SYcostPer />
				<cfif SYplanned neq "" and SYactual neq "">
					<cfset form[costcatCode & "_SYshortfall"] = SYplanned - SYactual />
				<cfelseif SYplanned eq "" and SYactual neq "">
					<cfset form[costcatCode & "_SYshortfall"] = 0 - SYactual />
				<cfelseif SYplanned neq "" and SYactual eq "">
					<cfset form[costcatCode & "_SYshortfall"] = SYplanned - SYactual />
				<cfelse>
					<cfset form[costcatCode & "_SYshortfall"] = 0 />
				</cfif>
				<cfif lowOBSrate neq "">
					<cfset form[costcatCode & "_lowOBSrate"] = lowOBSrate />
				<cfelse>
					<cfset form[costcatCode & "_lowOBSrate"] = 0 />
				</cfif>
				<cfset form[costcatCode & "_lowOBStarget"] = lowOBStarget />
			</cfif>
			<cfset form[costcatCode & "_cumContractValueEstimate"] = cumContractValueEstimate />
			<cfset form[costcatCode & "_cumContractCost"] = cumContractCost />
			<cfset form[costcatCode & "_cumContractCost_hid"] = cumContractCost />
			<cfset form[costcatCode & "_underrun"] = underrun />
			<cfset form[costcatCode & "_lowOBStakeback"] = lowOBStakeback />
			<cfset form[costcatCode & "_lowOBSdeficiency"] = lowOBSdeficiency />
			<cfset form[costcatCode & "_netRollover"] = netRollover />
			<cfset form[costcatCode & "_contractYearBudget"] = contractYearBudget />
			<cfset form[costcatCode & "_rolloverRate"] = rolloverRate />
			<cfset form[costcatCode & "_rolloverCap"] = rolloverCap />
			<cfset form[costcatCode & "_actualRollover"] = actualRollover />
			<cfset form[costcatCode & "_excessUnderrun"] = excessUnderrun />
			<cfset form[costcatCode & "_takeback"] = takeback />
			<cfset form[costcatCode & "_costCatDesc"] = costCatDesc />
		</cfloop>

		<!--- validation check: make sure no adjustments for reconciled contract year are waiting for mod numbers --->
		<cfinvoke component="#application.paths.components#aapp_yearend" method="CheckModCompletion"
			aapp="#url.aapp#"
			contractYear="#url.contractYear#"
			returnvariable="modsComplete">

		<cfset form.hidModsComplete = modsComplete>


	<cfelse>
		<!--- if query returned no results, this means that invalid CY was passed in to this page --->
		<cflocation url="aapp_yearend_summary.cfm?aapp=#url.aapp#" />
	</cfif>
</cfif>
<!---<cfif isDefined("rstYearEndData")><cfdump var="#rstYearEndData#"></cfif>--->

<cfif form.hidMode neq "readonly">
	<!--- run calculations to determine rollovers/take-backs --->
	<cfinvoke component="#application.paths.components#aapp_yearend" method="calculateYearEndAmounts"
		aapp="#url.aapp#" formData="#form#" returnvariable="form" />
</cfif>
</cfsilent>


<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm">

<div class="ctrSubContent">
<cfoutput>
<h2>Year-End Reconciliation, Contract Year #url.contractYear#</h2>
<h3>
Contract Year End Date: #dateformat(form.hidContractYearEndDate, "mm/dd/yyyy")#<br />
FMS Reporting Date: #dateformat(form.hidReportingDate, "mm/dd/yyyy")#
<cfif (form.hidMode neq "readonly") and (not form.hidModsComplete)>
	<br /><br />
	<span style="color:red;font-weight:normal;">
	NOTE: There are adjustments for this contract year awaiting
	Mod Numbers. Year-End Reconciliation cannot be executed.
	</span>
</cfif>
</h3>
<cfset dataColWidth="110"/>
<cfset textBoxSize="17"/>
<table border="0" cellpadding="0" cellspacing="0" class="dataTblCol">
<form name="frmYearEnd" action="#cgi.SCRIPT_NAME#?aapp=#url.aapp#&contractYear=#url.contractYear#" method="post" onsubmit="return formValid(this);">
<tr>
	<td width="200"></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td width="#dataColWidth#" <cfif count mod 2>class="AltCol"</cfif> style="text-align:center">
			#form[sType & "_costCatDesc"]#
		</td>
		<cfset count=count+1>
	</cfloop>
</tr>

<cfif listFindNoCase(form.hidServiceTypes, "A")> <!--- if contract has center ops --->

	<!--- Segment 1 rating --->
	<tr>
		<td align="right">
			<label for="id#listfirst(form.hidServiceTypes)#_perfRatingSeg1"><cfif form.hidNumOfPYs GT 0>Segment 1 </cfif>Performance Rating</label><br />
			(#dateformat(form.hidSeg1_StartDate, "mm/dd/yyyy")#-#dateformat(form.hidSeg1_EndDate, "mm/dd/yyyy")#)
		</td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					<input type="text" name="#sType#_perfRatingSeg1" value="#form[sType & "_perfRatingSeg1"]#"
						size="#textBoxSize#" maxlength="5" id="id#sType#_perfRatingSeg1" tabindex="#request.nextTabIndex#"
						<cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>
						onChange="formChanged(this.form);" onblur="formatDecimal(this,1);" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- Segment 2 rating --->

	<cfif form.hidNumOfPYs GT 0><!--- Only if there's more than one program year in the contract year --->
	<tr>
		<td align="right">
			<label for="id#listfirst(form.hidServiceTypes)#_perfRatingSeg2">Segment 2 performance rating</label><br />
			(#dateformat(form.hidSeg2_StartDate, "mm/dd/yyyy")#-#dateformat(form.hidSeg2_EndDate, "mm/dd/yyyy")#)
		</td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
						<input type="text" name="#sType#_perfRatingSeg2" value="#form[sType & "_perfRatingSeg2"]#"
							size="#textBoxSize#" maxlength="5" id="id#sType#_perfRatingSeg2" tabindex="#request.nextTabIndex#"
							<cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>
							onChange="formChanged(this.form);" onblur="formatDecimal(this,1);"  />

				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>
	</cfif>

	<!--- Weighted rating --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_perfRatingWeighted">Weighted performance rating</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					<input type="text" name="#sType#_perfRatingWeighted" value="#form[sType & "_perfRatingWeighted"]#"
						size="#textBoxSize#" maxlength="5" id="id#sType#_perfRatingWeighted" tabindex="#request.nextTabIndex#"
						readonly class="inputReadonly" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- white space --->
	<tr>
		<td></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >&nbsp;</td>
			<cfset count=count+1>
		</cfloop>
	</tr>

	<!--- Planned SYs --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_SYplanned">Planned SYs</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					<input type="text" name="#sType#_SYplanned" value="#numberformat(form[sType & "_SYplanned"])#"
						size="#textBoxSize#" maxlength="9" id="id#sType#_SYplanned" tabindex="#request.nextTabIndex#"
						<cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>
						onChange="formChanged(this.form);formatNum(this,1);"  />
					<input type="hidden" name="#sType#_SYplanned_hid" value="#numberformat(form[sType & "_SYplanned_hid"])#" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- Actual SYs --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_SYactual">Actual SYs</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					<input type="text" name="#sType#_SYactual" value="#numberformat(form[sType & "_SYactual"])#"
						size="#textBoxSize#" maxlength="9" id="id#sType#_SYactual" tabindex="#request.nextTabIndex#"
						<cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>
						onChange="formChanged(this.form);formatNum(this,1);"  />
					<input type="hidden" name="#sType#_SYactual_hid" value="#numberformat(form[sType & "_SYactual_hid"])#" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- Capacity Utilization --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_capUtilization">Capacity Utilization</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					<input type="text" name="#sType#_capUtilization" value="#numberformat(form[sType & "_capUtilization"],"9.999")#"
						size="#textBoxSize#" maxlength="5" id="id#sType#_capUtilization" tabindex="#request.nextTabIndex#"
						readonly class="inputReadonly" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- Planned Cost / SY --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_SYcostPer">Planned Cost/SY</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					$<input type="text" name="#sType#_SYcostPer" value="#numberformat(form[sType & "_SYcostPer"])#"
						size="#textBoxSize#" maxlength="5" id="id#sType#_SYcostPer" tabindex="#request.nextTabIndex#"
						readonly class="inputReadonly" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- SY Shortfall --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_SYshortfall">SY Shortfall</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					<input type="text" name="#sType#_SYshortfall" value="#numberformat(form[sType & "_SYshortfall"])#"
						size="#textBoxSize#" maxlength="5" id="id#sType#_SYshortfall" tabindex="#request.nextTabIndex#"
						readonly class="inputReadonly" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- Low OBS Takeback Rate --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_lowOBSrate">Low OBS Takeback Rate</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					<input type="text" name="#sType#_lowOBSrate" value="#numberformat(form[sType & "_lowOBSrate"],"0.000")#"
						size="#textBoxSize#" maxlength="5" id="id#sType#_lowOBSrate" tabindex="#request.nextTabIndex#"
						readonly class="inputReadonly" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- Low OBS Takeback Target --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_lowOBStarget">Low OBS Takeback Target</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					$<input type="text" name="#sType#_lowOBStarget" value="#numberformat(form[sType & "_lowOBStarget"])#"
						size="#textBoxSize#" maxlength="5" id="id#sType#_lowOBStarget" tabindex="#request.nextTabIndex#"
						readonly class="inputReadonly" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- white space --->
	<tr>
		<td></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >&nbsp;</td>
			<cfset count=count+1>
		</cfloop>
	</tr>
</cfif> <!--- center ops (A) specific fields --->

<!--- Cumulative Contract Value --->
<tr>
	<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_cumContractValueEstimate">Cumulative Contract Value</label></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
			<cfif count gt 1>
				<label for="id#sType#_cumContractValueEstimate" class="hiddenLabel">#sType# Cumulative Contract Value</label>
			</cfif>
			$<input type="text" name="#sType#_cumContractValueEstimate" value="#numberformat(form[sType & "_cumContractValueEstimate"])#"
				size="#textBoxSize#" maxlength="15" id="id#sType#_cumContractValueEstimate" tabindex="#request.nextTabIndex#"
				readonly class="inputReadonly" />
		</td>
		<cfset count=count+1>
	</cfloop>
	<cfset request.nextTabIndex = request.nextTabindex + 1 />
</tr>

<!--- Cumulative Contract Cost --->
<tr>
	<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_cumContractCost">Cumulative Contract Cost</label></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
			<cfif count gt 1>
				<label for="id#sType#_cumContractCost" class="hiddenLabel">#sType# Cumulative Contract Cost</label>
			</cfif>
			$<input type="text" name="#sType#_cumContractCost" value="#numberformat(form[sType & "_cumContractCost"])#"
				size="#textBoxSize#" maxlength="15" id="id#sType#_cumContractCost" tabindex="#request.nextTabIndex#"
				<cfif sType eq "C1C2" or form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>
				onChange="formChanged(this.form);formatNum(this,2);"  />
			<cfif sType neq "C1C2">
				<!--- store original value from FMS, to see if user edited --->
				<input type="hidden" name="#sType#_cumContractCost_hid" value="#numberformat(form[sType & "_cumContractCost_hid"])#" />
			</cfif>
		</td>
		<cfset count=count+1>
	</cfloop>
	<cfset request.nextTabIndex = request.nextTabindex + 1 />
</tr>

<!--- Net Under-run (AAPP Context) --->
<cfset varianceExists = "false">
<tr>
	<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_underrun">Net Under-run (AAPP Context)</label></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
			<cfif count gt 1>
				<label for="id#sType#_underrun" class="hiddenLabel">#sType# Cumulative Contract Value</label>
			</cfif>
			$<input type="text" name="#sType#_underrun" value="#numberformat(form[sType & "_underrun"])#"
				size="#textBoxSize#" maxlength="15" id="id#sType#_underrun" tabindex="#request.nextTabIndex#"
				readonly class="inputReadonly" />
		</td>
		<cfset count=count+1>
		<cfif form[sType & "_underrun"] neq 0>
			<cfset varianceExists = "true">
		</cfif>
	</cfloop>
	<cfset request.nextTabIndex = request.nextTabindex + 1 />
</tr>

<!--- white space --->
<tr>
	<td></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td align="right" <cfif count mod 2>class="AltCol"</cfif> >&nbsp;</td>
		<cfset count=count+1>
	</cfloop>
</tr>

<!--- Budget for Year Just Ended --->
<tr>
	<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_contractYearBudget">Budget for Year Just Ended</label></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
			<cfif count gt 1>
				<label for="id#sType#_contractYearBudget" class="hiddenLabel">#sType# Budget for Year Just Ended</label>
			</cfif>
			$<input type="text" name="#sType#_contractYearBudget" value="#numberformat(form[sType & "_contractYearBudget"])#"
				size="#textBoxSize#" maxlength="15" id="id#sType#_contractYearBudget" tabindex="#request.nextTabIndex#"
				readonly class="inputReadonly" />
		</td>
		<cfset count=count+1>
	</cfloop>
	<cfset request.nextTabIndex = request.nextTabindex + 1 />
</tr>

<!--- Applicable Rollover Cap Rate --->
<tr>
	<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_rolloverRate">Applicable Rollover Cap Rate</label></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
			<cfif count gt 1>
				<label for="id#sType#_rolloverRate" class="hiddenLabel">#sType# Applicable Rollover Cap Rate</label>
			</cfif>
			<input type="text" name="#sType#_rolloverRate" value="#form[sType & "_rolloverRate"]#"
				size="#textBoxSize#" maxlength="5" id="id#sType#_rolloverRate" tabindex="#request.nextTabIndex#"
				readonly class="inputReadonly" />
		</td>
		<cfset count=count+1>
	</cfloop>
	<cfset request.nextTabIndex = request.nextTabindex + 1 />
</tr>

<!--- Applicable Rollover Cap Amount --->
<tr>
	<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_rolloverCap">Applicable Rollover Cap Amount</label></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
			<cfif count gt 1>
				<label for="id#sType#_rolloverCap" class="hiddenLabel">#sType# Applicable Rollover Cap Amount</label>
			</cfif>
			$<input type="text" name="#sType#_rolloverCap"
			<cfif form[sType & "_rolloverCap"] neq "">
			 value="#numberformat(form[sType & "_rolloverCap"])#"
			<cfelse>
			 value=""
			</cfif>
				size="#textBoxSize#" maxlength="5" id="id#sType#_rolloverCap" tabindex="#request.nextTabIndex#"
				readonly class="inputReadonly" />
		</td>
		<cfset count=count+1>
	</cfloop>
	<cfset request.nextTabIndex = request.nextTabindex + 1 />
</tr>

<!--- white space --->
<tr>
	<td></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td align="right" <cfif count mod 2>class="AltCol"</cfif> >&nbsp;</td>
		<cfset count=count+1>
	</cfloop>
</tr>

<cfif listFindNoCase(form.hidServiceTypes, "A")> <!--- if contract has center ops --->

	<!--- Low OBS Takeback Available --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_lowOBStakeback">Low OBS Takeback Available</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					$<input type="text" name="#sType#_lowOBStakeback" value="#numberformat(form[sType & "_lowOBStakeback"])#"
							size="#textBoxSize#" maxlength="5" id="id#sType#_lowOBStakeback" tabindex="#request.nextTabIndex#"
							readonly class="inputReadonly" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- Deficiency in Low OBS savings --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_lowOBSdeficiency">Low OBS Deficiency</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					$<input type="text" name="#sType#_lowOBSdeficiency" value="#numberformat(form[sType & "_lowOBSdeficiency"])#"
							size="#textBoxSize#" maxlength="5" id="id#sType#_lowOBSdeficiency" tabindex="#request.nextTabIndex#"
							readonly class="inputReadonly" />
				</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- Net Rollover --->
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_netRollover">Net Rollover</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif sType eq "A">
					<cfif count gt 1>
						<label for="id#sType#_netRollover" class="hiddenLabel">#sType# Net Rollover</label>
					</cfif>
					$<input type="text" name="#sType#_netRollover" value="#numberformat(form[sType & "_netRollover"])#"
						size="#textBoxSize#" maxlength="5" id="id#sType#_netRollover" tabindex="#request.nextTabIndex#"
						readonly class="inputReadonly" />
					</cfif>
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>

	<!--- white space --->
	<tr>
		<td></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >&nbsp;</td>
			<cfset count=count+1>
		</cfloop>
	</tr>
</cfif> <!--- center ops (A) specific fields --->


<!--- ACTUAL ROLLOVER --->
<tr>
	<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_actualRollover">ACTUAL ROLLOVER</label></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
			<cfif count gt 1>
				<label for="id#sType#_actualRollover" class="hiddenLabel">#sType# ACTUAL ROLLOVER</label>
			</cfif>
			$<input type="text" name="#sType#_actualRollover" value="#numberformat(form[sType & "_actualRollover"])#"
				size="#textBoxSize#" maxlength="5" id="id#sType#_actualRollover" tabindex="#request.nextTabIndex#"
				readonly class="inputReadonly" />

		</td>
		<cfset count=count+1>
	</cfloop>
	<cfset request.nextTabIndex = request.nextTabindex + 1 />
</tr>

<!--- EXCESS UNDER-RUN  :: display in form versions 2 and later --->
<cfif form.hidFormVersion gte 2>
	<tr>
		<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_excessUnderrun">Excess Under-run</label></td>
		<cfset count=1>
		<cfloop list="#form.hidServiceTypes#" index="sType">
			<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
				<cfif count gt 1>
					<label for="id#sType#_excessUnderrun" class="hiddenLabel">#sType# EXCESS UNDERRUN</label>
				</cfif>
				$<input type="text" name="#sType#_excessUnderrun" value="#numberformat(form[sType & "_excessUnderrun"])#"
					size="#textBoxSize#" maxlength="5" id="id#sType#_excessUnderrun" tabindex="#request.nextTabIndex#"
					readonly class="inputReadonly" />
			</td>
			<cfset count=count+1>
		</cfloop>
		<cfset request.nextTabIndex = request.nextTabindex + 1 />
	</tr>
</cfif>

<!--- TAKEBACK --->
<tr>
	<td align="right"><label for="id#listfirst(form.hidServiceTypes)#_takeback">TAKEBACK</label></td>
	<cfset count=1>
	<cfloop list="#form.hidServiceTypes#" index="sType">
		<td align="right" <cfif count mod 2>class="AltCol"</cfif> >
			<cfif count gt 1>
				<label for="id#sType#_takeback" class="hiddenLabel">#sType# TAKEBACK</label>
			</cfif>
			$<input type="text" name="#sType#_takeback" value="#numberformat(form[sType & "_takeback"])#"
				size="#textBoxSize#" maxlength="5" id="id#sType#_takeback" tabindex="#request.nextTabIndex#"
				readonly class="inputReadonly" />
		</td>
		<cfset count=count+1>
	</cfloop>
	<cfset request.nextTabIndex = request.nextTabindex + 1 />
</tr>


<!--- white space --->
<tr>
	<td></td>
	<td align="right" colspan="#listlen(form.hidServiceTypes)#">&nbsp;</td>

</tr>
</table>

<!--- COMMENTS --->
<table border="0" cellpadding="0" cellspacing="0" class="dataTbl">
<tr valign="top">
	<td width="200" align="right"><label for="idComments">Comments</label></td>
	<td colspan="#listlen(form.hidServiceTypes)#">
		<textarea id="idComments" name="txtComments" tabindex="#request.nextTabIndex#" cols="70" rows="4"
		onKeyDown="textCounter(this, 4000);" onKeyUp="textCounter(this, 4000);"
		<cfif form.hidMode eq "readonly">readonly class="inputReadonly"</cfif>>#form.txtComments#</textarea>
	</td>
	<cfset request.nextTabIndex = request.nextTabindex + 1 />
</tr>
</table>

<cfif form.hidMode neq "readonly">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="red">
	<tr valign="top">
		<td>
			<div class="buttons" style="text-align:left">
			<input type="button" name="btnRecalc" value="Recalculate Form Values" onClick="recalcForm(this.form);" style="text-align:center"/>
			</div>
		</td>
		<td>
			<div class="buttons">
				<cfoutput>
				<input type="hidden" name="hidAAPP" value="#url.aapp#">
				<input type="hidden" name="hidMode" value="#form.hidMode#" />
				<input type="hidden" name="hidReportingDate" value="#form.hidReportingDate#" />
				<input type="hidden" name="hidContractYear" value="#url.contractYear#" />
				<input type="hidden" name="hidContractYearStartDate" value="#form.hidContractYearStartDate#" />
				<input type="hidden" name="hidContractYearEndDate" value="#form.hidContractYearEndDate#" />
				<input type="hidden" name="hidSeg1_StartDate" value="#form.hidSeg1_StartDate#" />
				<input type="hidden" name="hidSeg1_EndDate" value="#form.hidSeg1_EndDate#" />
				<input type="hidden" name="hidSeg2_StartDate" value="#form.hidSeg2_StartDate#" />
				<input type="hidden" name="hidSeg2_EndDate" value="#form.hidSeg2_EndDate#" />
				<input type="hidden" name="hidServiceTypes" value="#form.hidServiceTypes#" />
				<input type="hidden" name="hidAction" value="" />
				<input type="hidden" name="hidModsComplete" value="#form.hidModsComplete#" />
				<input type="hidden" name="hidNumOfPYs" value="#form.hidNumOfPYs#" />
				<input type="hidden" name="hidFormVersion" value="#form.hidFormVersion#" />

				<cfif form.hidNumOfPYs eq 0>
					<input type="hidden" name="A_perfRatingSeg2" value="0" />
				</cfif>
				<cfloop list="#form.hidServiceTypes#" index="sType">
					<input type="hidden" name="#sType#_costCatDesc" value="#form[sType & "_costCatDesc"]#" />
				</cfloop>

				<!--- form buttons --->
				<!--- Rel 2.7.1 - no longer need to have variance to perform Recon --->
				<cfif form.hidModsComplete>
					<!--- if there are variances, and all mod numbers have been entered --->
					<input name="btnSubmit" type="submit" value="Finalize Reconciliation" tabindex="#request.nextTabIndex#" style="text-align:center" DISABLED />
				<cfelse>
					<input name="btnSubmit" type="button" value="Finalize Reconciliation" tabindex="#request.nextTabIndex#" style="text-align:center" DISABLED
					onClick="alert('There are adjustments for this contract year awaiting Mod Numbers.\nYear-End Reconciliation cannot be executed.');"/>
				</cfif>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				<input name="btnClear" type="button" value="Reset" tabindex="#request.nextTabIndex#" style="text-align:center"
					onClick="window.location.href='#cgi.SCRIPT_NAME#?aapp=#url.aapp#&contractYear=#url.contractYear#';"/>
				<cfset request.nextTabIndex = request.nextTabIndex + 1>
				<input name="btnCancel" type="button" value="Cancel" onClick="window.location.href='aapp_yearend_summary.cfm?aapp=#url.aapp#';"
					tabindex="#request.nextTabIndex#" style="text-align:center"  />
				</cfoutput>
			</div>
		</td>
	</tr>
	</table>

	<!--- ability to "UNDO" removed in Release 2.8 (could be temporary)
	<cfelseif (form.hidMode eq "readonly") and (request.statusID eq 1) and (url.contractYear eq request.curContractYear - 1)>
	<!--- recon has been performed, AAPP is still active, and recon was from previous contract year --->
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="red">
	<tr>
		<td>
			<div class="buttons">
				<cfoutput>
				<input type="hidden" name="hidAAPP" value="#url.aapp#">
				<input type="hidden" name="hidMode" value="#form.hidMode#" />
				<input type="hidden" name="hidAction" value="undo" />

				<!--- form buttons --->
				<cfif listFind('1,2', session.roleId, ",")>
					<input name="btnSubmit" type="button" value="Undo Reconciliation" tabindex="#request.nextTabIndex#" style="text-align:center"
					onClick="undoRecon(this.form);"/>
					<cfset request.nextTabIndex = request.nextTabIndex + 1>
				</cfif>
				<input name="btnCancel" type="button" value="Cancel" onClick="window.location.href='aapp_yearend_summary.cfm?aapp=#url.aapp#';"
					tabindex="#request.nextTabIndex#" style="text-align:center"  />
				</cfoutput>
			</div>
		</td>
	</tr>
	</table>
	--->
</cfif>
</form>
</cfoutput>
</div>

</div>


<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm">

<!--- additional JS for this page --->

<cfoutput>
<script language="javascript">
var arrServiceTypes = new Array(#listQualify(replace(form.hidServiceTypes,"C1C2","","all"),"'")#);

function recalcForm(form) {

	//make sure all fields are populated with numbers
	if (formValid(form))
		{
		form.hidAction.value = 'calc';
		if (form.hidNumOfPYs > 0)
			{
			form.A_perfRatingSeg2.value = form.A_perfRatingSeg1.value;
			}
		form.submit();
		}
	else
		alert('Make sure all editable fields have been populated with valid numbers.');
} // recalcForm

function formInit(form) {
	form.hidAction.value = 'undo';
	form.btnSubmit.disabled = 0;
	form.btnRecalc.disabled = 1;
	$( "input" ).removeClass( "btnDisabled" );
	$( "input:disabled" ).addClass( "btnDisabled" );


} // formChanged

function formChanged(form) {
	form.hidAction.value = 'calc';
	form.btnSubmit.disabled = 1;
	form.btnRecalc.disabled = 0;
	$( "input" ).removeClass( "btnDisabled" );
	$( "input:disabled" ).addClass( "btnDisabled" );

} // formChanged


//form.hidServiceTypes
function formValid(form) {
	trimFormTextFields(document.frmYearEnd);

	allValid = 1;
	FMSdataChange = 0;

	<cfif listFindNoCase(form.hidServiceTypes, "A")> <!--- if contract has center ops --->
		if (
			((form.A_perfRatingSeg1.value == '') || isNaN(stripCharsInBag(form.A_perfRatingSeg1.value, ","))) ||
			((form.A_perfRatingSeg2.value == '') || isNaN(stripCharsInBag(form.A_perfRatingSeg2.value, ","))) ||
			((form.A_SYplanned.value == '') || isNaN(stripCharsInBag(form.A_SYplanned.value, ","))) ||
			((form.A_SYactual.value == '') || isNaN(stripCharsInBag(form.A_SYactual.value, ",")))
			)
			allValid = 0;
	</cfif>

	if (allValid) {
		// loop through all editable fields in the form to make sure they are filled in
		for (var counter = 0; counter < arrServiceTypes.length; counter++) {
			if ( (form[arrServiceTypes[counter]+'_cumContractCost'].value == '') ||
				isNaN(stripCharsInBag(form[arrServiceTypes[counter]+'_cumContractCost'].value, ","))
				) {
				allValid = 0;
			}
		} // loop
	}

	if (allValid && form.hidAction.value == 'save') {
		// check to see if user has changed FMS data (comments required)
		<cfif listfindnocase(form.hidServiceTypes, "A")> <!--- ops fields --->
			if (stripCharsInBag(form.A_SYplanned.value,",") != stripCharsInBag(form.A_SYplanned_hid.value,",")) {  FMSdataChange = 1; }
			if (stripCharsInBag(form.A_SYactual.value,",") != stripCharsInBag(form.A_SYactual_hid.value,",")) {  FMSdataChange = 1; }
		</cfif>
		for (var counter = 0; counter < arrServiceTypes.length; counter++) {
			if (
				stripCharsInBag(form[arrServiceTypes[counter]+'_cumContractCost'].value, ",") !=
				stripCharsInBag(form[arrServiceTypes[counter]+'_cumContractCost_hid'].value, ",")
				) {
				FMSdataChange = 1;
			}
		} // loop
	}

	if (form.hidAction.value == 'save') {
		if (FMSdataChange && form.txtComments.value == '') {
			alert('If any of the FMS provided costs have been changed, comments are required.')
			return false;
		}
	}

	if (allValid) {
		return true;
	}
	return false;

} // formValid

<cfif form.hidMode neq "readonly">

	function checkbuttonStatus() {

		// check to see if form fields are valid to allow reconciliation
		if (formValid(document.frmYearEnd)) {
			// enable 'Finalize' button, disable recalc button
			document.frmYearEnd.btnSubmit.disabled = 0;
			document.frmYearEnd.btnRecalc.disabled = 1;
			document.frmYearEnd.hidAction.value = 'save';
		}
		else {
			// force: disable 'Finalize' button, enable recalc button, set form.hidAction.value = 'calc'
			formChanged(document.frmYearEnd);
		}
	} // checkbuttonStatus

	$("document").ready(function(){

		// enable/disable the Recalc and Submit buttons, based on formValid(document.frmYearEnd)
		formInit(document.frmYearEnd);
		checkbuttonStatus();

		$( "input:disabled" ).addClass( "btnDisabled" );
	}); // ready

</cfif>

</script>
</cfoutput>


