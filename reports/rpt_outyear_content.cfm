<!---
page: rpt_outyear_content.cfm

description: Outyear report content, included by  rpt_outyear.cfm

revisions:

2008-06-26	mstein	page created

--->
<cfoutput>
<!-- Begin Content Area -->
<table border="0" cellspacing="0" cellpadding="0" align="center" width="762">
<tr>
	<td align="center">		
		<div class="formContent">
		<h1>Out Year Funding Requirements Report <cfif form.cboFundingOffice neq 0> for #rsFundingOffice.fundingOfficeDesc#<cfelse> for All Funding Offices</cfif></h1>  
		<h2>Program Years #rsCurrentPY#&nbsp;-&nbsp;#evaluate("#rsCurrentPY# + 3")#</h2> 
		<h2>#rstContractTypeCode.contractTypeLongDesc# Funding Requirements</h2>

		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="formHdrInfo">
		<tr align="right">
			<td>Report run on: #dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm tt')#</td>
		</tr> 
		</table>

		<cfset altRowNum = 1>
		<table width="100%" align="center" border="0" cellpadding="0" cellspacing="0" class="form2DataTbl">
		<tr style="text-align:center">
			<th style="text-align:center">
				Funding<Br />Office
			</th>
			<th style="text-align:center">
				AAPP<Br />No.
			</th>
			<th style="text-align:center">
				Program Activity
			</th>
			<cfif i is "S">
			<th style="text-align:center">
				Other Service Description
			</th>
			</cfif>
			<th style="text-align:center">
				Center/Performance<br />Venue
			</th>
			<th style="text-align:center">
				Contractor
			</th>
			<th style="text-align:center">
				Performance<br />Period
			</th>
			<th style="text-align:center">
				Current PY<br />FOP Amount
			</th>
			<th style="text-align:center">
				Outyear 1<br />PY #evaluate("#rsCurrentPY# + 1")#
			</th>
			<th style="text-align:center">
				Outyear 2<br />PY #evaluate("#rsCurrentPY# + 2")#
			</th>
			<th style="text-align:center">
				Outyear 3<br />PY #evaluate("#rsCurrentPY# + 3")#
			</th>
		</tr>
		<cfif evaluate("rstOutyear_#i#.recordcount") gt 0><!--- if there are records in this cost category --->
			<cfloop query="rstOutyear_#i#"><!--- loop through the records for this cost category --->
			<tr <cfif altRowNum mod 2>class="form2AltRow"</cfif>>
				<td valign=top align="center">
					#fundOffNum#
				</td>
				<td valign=top align="center">
					#aappNum#
				</td>	
				<td valign=top nowrap="nowrap">
					#progAct#
				</td>	
				<cfif i is "S">
				<td valign="top">
					#otherTypeDesc#
				</td>
				</cfif>
				<td valign=top>
					#centerName#<cfif venue neq "" and centerName neq "">/ </cfif>#venue#
				</td>	
				<td valign=top>
					#contractorName#
				</td>
				<td valign=top>
					#dateformat(dateStart, "mm/dd/yyyy")#<br>
					#dateformat(dateEnd, "mm/dd/yyyy")#
				</td>	
				<td valign=top align="right">
					#numberFormat(PY0, "$,.99")#<cfset PY0sum = #PY0sum# + #PY0#><cfset PY0total = #PY0total# + #PY0#>
				</td>	
				<td valign=top align="right">
					#numberFormat(PY1, "$,.99")#<cfset PY1sum = #PY1sum# + #PY1#><cfset PY1total = #PY1total# + #PY1#>
				</td>
				<td valign=top align="right">
					#numberFormat(PY2, "$,.99")#<cfset PY2sum = #PY2sum# + #PY2#><cfset PY2total = #PY2total# + #PY2#>
				</td>
				<td valign=top align="right">
					#numberFormat(PY3, "$,.99")#<cfset PY3sum = #PY3sum# + #PY3#><cfset PY3total = #PY3total# + #PY3#>
				</td>
			</tr>
			<cfif form.radReportFormat neq "application/vnd.ms-excel"><!--- dont' show subtotals in Excel --->
				<cfif i is "A"><!--- for cost cat A --->
					<cfif centerID[currentrow] neq centerID[currentrow + 1]><!--- if the next row is a different center --->
							<cfif centerID[currentrow] eq centerID[currentrow - 1]><!--- and the previous row was the same center --->
								<tr <cfif altRowNum mod 2>class="form2AltRow"</cfif>><!--- show the subtotal for that group --->
									<td  colspan="5" >&nbsp;
										
									</td>
									<td valign="top" align="right">
										Subtotal
									</td>
									<td valign=top align="right">
										#numberFormat(PY0sum, "$,.99")#
									</td>
									<td valign=top align="right">
										#numberFormat(PY1sum, "$,.99")#
									</td>
									<td valign=top align="right">
										#numberFormat(PY2sum, "$,.99")#
									</td>
									<td valign=top align="right">
										#numberFormat(PY3sum, "$,.99")#
									</td>
								</tr>
							</cfif>
						<cfset PY0sum = 0><!--- reset the subtotals --->
						<cfset PY1sum = 0>
						<cfset PY2sum = 0>
						<cfset PY3sum = 0>
						<cfset altRowNum = altRowNum + 1><!--- and change the row color --->
					</cfif>
				<cfelseif i is "S"><!--- for S Cost Cat --->
					<cfif otherTypeDesc[currentrow] neq otherTypeDesc[currentrow + 1] or otherTypeDesc[currentrow] is ""><!--- if the next service description is different, or the service description is blank  --->
						<cfif otherTypeDesc[currentrow] eq otherTypeDesc[currentrow-1] and otherTypeDesc[currentrow] neq ""><!--- and the previous service description was the same, but not blank --->
							<tr <cfif altRowNum mod 2>class="form2AltRow"</cfif>><!--- show the subtotal for that service description --->
									<td colspan="6">&nbsp;
										
									</td>
									<td valign="top" align="right">
										Subtotal
									</td>
									<td valign=top align="right">
										#numberFormat(PY0sum, "$,.99")#
									</td>
									<td valign=top align="right">
										#numberFormat(PY1sum, "$,.99")#
									</td>
									<td valign=top align="right">
										#numberFormat(PY2sum, "$,.99")#
									</td>
									<td valign=top align="right">
										#numberFormat(PY3sum, "$,.99")#
									</td>
								</tr>
							</cfif>					
						<cfset PY0sum = 0>
						<cfset PY1sum = 0>
						<cfset PY2sum = 0>
						<cfset PY3sum = 0>
					<cfset altRowNum = altRowNum + 1>	
					</cfif>
				<cfelse>
					<cfif form.cboFundingOffice eq 0 and fundOffNum[currentrow] neq fundOffNum[currentrow + 1]>
					<cfset altRowNum = altRowNum + 1>
						<tr <!---style="font-weight:bold" <cfif altRowNum mod 2>class="form2AltRow"</cfif>--->>
							<td  colspan="4" >&nbsp;
								
							</td>
							<td valign="top" align="right" colspan="2">
								#fundOffDesc[currentrow]# Subtotal
							</td>
							<td valign=top align="right">
								#numberFormat(PY0sum, "$,.99")#
							</td>
							<td valign=top align="right">
								#numberFormat(PY1sum, "$,.99")#
							</td>
							<td valign=top align="right">
								#numberFormat(PY2sum, "$,.99")#
							</td>
							<td valign=top align="right">
								#numberFormat(PY3sum, "$,.99")#
							</td>
						</tr>			
						<cfif evaluate("rstOutyear_#i#.currentrow") neq evaluate("rstOutyear_#i#.recordcount")>
						<tr>
							<td colspan="10">&nbsp;
								
							</td>
						</tr>
						</cfif>	
						<cfset PY0sum = 0>
						<cfset PY1sum = 0>
						<cfset PY2sum = 0>
						<cfset PY3sum = 0>
						<cfset altRowNum = 0>
					</cfif>
					<cfset altRowNum = altRowNum + 1>
				</cfif>
				<cfif evaluate("rstOutyear_#i#.currentrow") is evaluate("rstOutyear_#i#.recordcount")>
					<tr style="font-weight:bold;" <!---<cfif altRowNum mod 2>class="form2AltRow"</cfif>--->>
						<td <cfif i is "S">colspan="4"<cfelse> colspan="3"</cfif>>&nbsp;
							
						</td>
						<td colspan="3" valign="top" align="right">
							#rstContractTypeCode.contractTypeLongDesc# Total
						</td>
						<td valign=top align="right">
							#numberFormat(PY0total, "$,.99")#
						</td>
						<td valign=top align="right">
							#numberFormat(PY1total, "$,.99")#
						</td>
						<td valign=top align="right">
							#numberFormat(PY2total, "$,.99")#
						</td>
						<td valign=top align="right">
							#numberFormat(PY3total, "$,.99")#
						</td>
					</tr>
					<cfset PY0total = 0>
					<cfset PY1total = 0>
					<cfset PY2total = 0>
					<cfset PY3total = 0>
					<tr>
						<td>&nbsp;</td>
					</tr>
				</cfif>
			</cfif>				
			</cfloop>
		<cfelse>
			<tr>
				<td align="center" <cfif i is "S">colspan="11"<cfelse> colspan="10"</cfif>>
					There are no AAPPs with #rstContractTypeCode.contractTypeLongDesc# Funding Requirements<cfif form.cboFundingOffice neq 0> in <cfif form.cboFundingOffice lte 6>the </cfif>#rsFundingOffice.fundingOfficeDesc#</cfif>
				</td>
			</tr>
		
		</cfif>
		</table>

<!-- Begin Form Footer Info -->
	    
	    <cfif isDefined("form.radReportFormat") and form.radReportFormat eq "application/pdf">
			<cfdocumentitem type="footer">
				<cfoutput>
				<table width=100% cellspacing="0" border=0 cellpadding="0">
				<tr>
					<td align=right>
						<font size="-2" face="Arial Narrow, Arial, Times New Roman, Times, serif">
							page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
						</font>
					</td>
				</tr>
				</table>
				</cfoutput>		
			</cfdocumentitem>  
		</cfif>  
	</td>
</tr>
</table>
<!---</div>--->
</cfoutput>