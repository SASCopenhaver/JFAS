<cfsilent>
<!---
page: omb_inflation.cfm

description: administrative page to view and set omb inflation rates

revisions:
2012-10-14	mstein	Changes to display 3 previous years, in addition to current and 9 future
--->

<cfset request.pageID = "2210" /> 
<cfset request.pageTitleDisplay = "JFAS System Administration">
<cfparam name="variables.lstErrorMessages" default="" /> <!--- required for data entry forms --->
<cfset display_years = 13>



<cfif isDefined("form.btnSubmit")> <!--- coming from form submittal --->

<cfset FirstDate = form.FirstDate>
<!--- database interaction / server-side validation --->
	
	<!--- set values of 0 for status variables that weren't checked --->
	<cfloop index="i" from="0" to="#Evaluate(display_years - 1)#">
	<cfset strDate = replace(Dateformat(Dateadd("yyyy", i, FirstDate), "mm/dd/yyyy"), "/", "_", "all")>
	<cfparam name="form.Status_#strDate#" default="0">
	</cfloop>
	
<!--- save changes/new rows to the database --->	
<cfinvoke component="#application.paths.components#aapp_inflation" method="SaveOMBInflation" 
		formData="#form#" returnvariable="stcResults">
	<!--- if no errors are returned, reload the page --->		
	<cfif stcResults.success>
		<cflocation url="#cgi.SCRIPT_NAME#?saved=true">
	</cfif>

	

<cfelse> <!--- first time viewing form --->	


	<!--- read data from database, set up form fields --->
	<cfparam name="url.saved" default="">
	
	<!--- Get the records that are in the database now --->
	<cfinvoke component="#application.paths.components#aapp_inflation" method="getOMBInflation" 
		returnvariable="rstOMBInflationResults">
	<!--- If there are no records, set the start date, last_date, and this fiscal year --->	
	<cfif rstOMBInflationResults.recordcount is 0>
		
		<cfif Dateformat(Now(), "mm/dd") GTE '07/01'>
			<cfset FirstYear = Dateformat(Now(), "yyyy")>
		<cfelse>
			<cfset FirstYear = Dateformat(Dateadd("yyyy", -1, Now()), "yyyy")>
		</cfif>
		
		<cfset FirstDate = '07/01/' & FirstYear>
		<cfset form.FirstDate = FirstDate>
		<cfset last_date = '07/01/' & FirstYear>
		<cfset form["year_" & replace(FirstDate, "/", "_", "all")] = FirstDate>
		<cfset form["rate_" & replace(FirstDate, "/", "_", "all")] = 0>
		<cfset form["status_" & replace(FirstDate, "/", "_", "all")] = 0>
	<cfelse>
	
	<!--- set FirstDate as this FY --->
	<cfset FirstDate = Dateformat(rstOMBInflationResults.YEAR, "mm/dd/yyyy")>
	<cfset form.FirstDate = FirstDate>
	
	</cfif>	
	
	<!--- loop through query results, setting variable names --->
	<cfloop query="rstOMBInflationResults">
	<cfset strDate = replace(Dateformat(YEAR, "mm/dd/yyyy"), "/", "_", "all")>
	<cfset form["rate_" & strDate] = INFLATION_RATE>
	<cfset form["year_" & strDate] = Dateformat(YEAR, "mm/dd/yyyy")>
	<cfset form["status_" & strDate] = STATUS>
	<cfset last_date = YEAR>
	</cfloop>
	
	<!--- if there are fewer than 10 records, create new rows for the rest --->
	<cfloop index="i" from="#Evaluate(rstOMBInflationResults.recordcount + 1)#" to="#display_years#">
	<cfset strDate = Dateformat(Dateadd("yyyy", i - rstOMBInflationResults.recordcount, last_date), "mm/dd/yyyy")>
	<cfset form["rate_" & replace(strDate, "/", "_", "all")] = 0>
	<cfset form["year_" & replace(strDate, "/", "_", "all")] = strDate>
	<cfset form["status_" & replace(strDate, "/", "_", "all")] = 0>
	</cfloop>

</cfif>






</cfsilent>
<!--- include main header --->
<cfinclude template="#application.paths.includes#header.cfm" />

<script language="javascript">

//if a status box is checked, make the rate box readOnly
//otherwise, if it's unchecked, make it editable
function Locked(status, rate)
{
if (status.checked == true)
	{
	rate.className='inputReadonly';
	rate.readOnly = 1;
	}
else
	{
	rate.className='inputEditable';
	rate.readOnly = 0;
	}
}

//make sure that the inflation rate is less than 1000
function checkMaxValue(txtControl)
{
if (!(parseFloat(txtControl.value) < 1000))
	{
	alert('Inflation Rate must be less than 1000')
	txtControl.value = 0
	} 
}

</script>		

	<h2>OMB Inflation Rates</h2>
	<!--- If they submitted without errors, let them know it was saved --->
	<cfif url.saved is "true">
	<div class="confirmList">
	<li>Your changes have been saved.&nbsp;&nbsp;Return to the <a href="<cfoutput>#application.paths.admin#</cfoutput>">Admin Section</a>.
	</li>
	</div><br />
	</cfif>
	
	<!--- Start Display Table --->
	
<form name="frmOmbInflation" action="<cfoutput>#cgi.SCRIPT_NAME#</cfoutput>" method="post" >

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="contentTbl">
	
	<tr align="center">
		<th scope="row">
			Year
		</th>
		<th>
		Start Date
		</th>
		<th>
		End Date
		</th>
		<th>
		OMB Inflation Rate
		</th>
		<th>
		Locked
		</th>
	</tr>
		

<!--- loop to show records --->
<cfloop index="i" from="0" to="#Evaluate(display_years - 1)#">
<cfset strDate = replace(Dateformat(Dateadd("yyyy", i, FirstDate), "mm/dd/yyyy"), "/", "_", "all")><!--- add i to firstdate to get the start date --->
	
	<tr <cfif (Dateformat(Dateadd("yyyy", i, FirstDate), "yyyy") MOD 2)> class="AltRow"</cfif>><!--- alternate row shading based on FY --->
		<td align="center">
			<cfoutput><!--- add one to year of start date to get FY --->
				<label for="FY#Dateformat(Dateadd("yyyy", i, FirstDate), "yyyy")#">#Dateformat(Dateadd("yyyy", i, FirstDate), "yyyy")#</label>
			</cfoutput>
		</td>
		<td align="center">
			<cfoutput>
				#Dateformat(form["year_" & strDate], "mm/dd/yyyy")#<!--- Show start date, and set it as hidden input --->
				<input type="hidden" name="year_#strDate#" 
				value="#Dateformat(form["year_" & strDate], "mm/dd/yyyy")#" />
			</cfoutput>
		</td>
		<td align="center">
			<cfoutput><!--- calculate end date - add one year and subtract one day from start date --->
			#Dateformat(Dateadd("d", -1, Dateadd("yyyy", 1, form["year_" & strDate])), "mm/dd/yyyy")#
			</cfoutput>
		</td>
		<td align="center">
			<cfoutput><!--- create field for inflation rate, only allow three decimal places --->
			<label for="id_rate_#strDate#" class="hiddenLabel">OMB Inflation Rate for #strDate#</label>
			<input style="text-align:right" type="text" name="rate_#strDate#" value="#form["rate_" & strDate]#" size="7"
			tabindex="#request.nextTabIndex#" id="FY#Dateformat(Dateadd("yyyy", i, FirstDate), "yyyy")#"
			onChange="formatDecimal(this,3); checkMaxValue(this);"
			<cfif form["status_" & strDate] neq 0>
			readonly class="inputReadonly" <<<<!--- set to readonly if the accompanying status box is checked --->
			</cfif> />
			</cfoutput>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>	
		</td>
		<td align="center">
			<cfoutput>
			<cfset fieldStr = 'form["status_' & strDate & '"]' /><!--- set variable for fieldname --->
			<label for="id_status_#strDate#" class="hiddenLabel">Lock/Unlock OMB Rate for #strDate#</label>
			<input type="checkbox" name="status_#strDate#" id="id_status_#strDate#" 
			tabindex="#request.nextTabIndex#"
				<cfif form["status_" & strDate] neq 0>
				checked
				</cfif> onClick="Locked(this, this.form.rate_#strDate#);" /><!--- when clicked execute js to make rate field read-only --->
			</cfoutput>
			<cfset request.nextTabIndex = request.nextTabIndex + 1>	
		</td>
	</tr>
</cfloop>

	<tr>
<cfoutput>
<input type="hidden" name="FirstDate" value="#form.FirstDate#" /><!--- submit the first date from the query --->
</cfoutput>
</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
		<td colspan="5" align="right">
			<div class="buttons">
			<input name="btnSubmit" type="submit" value="Save" tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<input name="btnReset" type="reset" value="Reset"  tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			<!--- cancel returns them to the admin page --->
			<input name="btnCancel" type="button" value="Cancel" 
			onclick="javascript:window.location='<cfoutput>#application.paths.admin#</cfoutput>'" 
			tabindex="<cfoutput>#request.nextTabIndex#</cfoutput>" />
			<cfset request.nextTabIndex = request.nextTabIndex + 1>
			</div>
		</td>
	</tr>
</table>
</form>

<!--- include main footer --->
<cfinclude template="#application.paths.includes#footer.cfm" />