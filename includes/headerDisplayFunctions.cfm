<!--- headerDisplayFunctions.cfm

	Display banner, for home page, and non-home page

	Initial setup for all pages is in htmlSetup.cfm

--->
<cfoutput>
<cffunction name="DisplayTopUI" hint="I am a function to display the top-most banner for the jfas home page.">
	<cfargument name="IsHomePage" required="no" default="no">
	<noscript>
		<center>
		<br><br><br>
		<font color="white" face="Arial, Helvetica, sans-serif"><strong>
		The JFAS application requires the use of a javascript-enabled browser.<br>
		Please modify your browser settings to enable javascript.
		</strong></font><br><br><br><br>
		</center>
	</noscript>

	<!-- Begin Banner (contains logo, and  - for Home Page - the logout menu)-->
	<div class="banner">

		<!--- logo image --->
		<div class="bannerLogo">
			<a href="#application.paths.root#"><img src="#application.paths.images#logo_jfas.gif" alt="Job Corps logo" border="0" class="logoJFAS" title="Go to JFAS Home Page" /></a>
			<!--- logo JFAS text --->
			<a href="#application.paths.root#"><img src="#application.paths.images#hdr_txt_jfas.gif" alt="JFAS - Job Corps Fund Allocation System" border="0" class="headerTxtJFAS"  title="Go to JFAS Home Page" /></a>
		</div>
		<!-- /bannerLogo -->
		<div id="<cfif arguments.IsHomePage EQ "yes">bannerRightofLogo<cfelse>bannerRightofLogoDetail</cfif>">
			<cfset DisplayLogout()>
			<!--- Quick Search is an in-inline form on right --->
			<cfset DisplayQuickSearch()>
		</div>
		<!-- /bannerRightofLogo/bannerRightofLogoDetail -->
	</div>
	<!-- /banner -->
	<div class="clear"></div>
	<cfscript>
	if (not isDefined("footerpage")) {
		// display primary navigation
		DisplayPrimaryNav(arguments.IsHomePage);
	}
	</cfscript>
	<div class="clear"></div>
	<cfif arguments.IsHomePage EQ "yes">
		<cfset DisplayHeaderTitle()>
	</cfif>

	<cfif findNocase("\aapp\", CGI.PATH_TRANSLATED)>
		<!--- include AAPP summary information --->
		<!--- show contract info block (if not creating new contract --->
		<cfinclude template="#application.paths.includes#headerDisplayContractInfo.cfm">
		<!--- include information for secondary navigation (tabs) --->
		<cfinclude template="#application.paths.includes#headerDisplaySecondaryNav.cfm">

	<cfelseif findNocase("\budget\", CGI.PATH_TRANSLATED)>
		<!--- include Budget summary information --->
		<!--- show contract info block (if not creating new contract --->
		<cfinclude template="#application.paths.includes#headerDisplayBudgetFunctions.cfm">
	</cfif>

</cffunction> <!--- DisplayTopUI --->

<cffunction name="DisplayHTMLSetup" hint="I am a function to display the top-most banner for the jfas home page.">
	<cfargument name="IsHomePage" required="no" default="no">
	<cfif arguments.IsHomePage EQ "yes">
		<!--- set up for bootstrap --->
		<!DOCTYPE html>
		<html lang="en">
		<head>
		<!--- set up for bootstrap --->
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">

		<link rel="icon" href="#application.urls.icon#" type="image/x-icon" />

		<!--- CSS --->
		<!--- bootstrap --->
		<link href="#application.paths.cssdir#bootstrap.css" rel="stylesheet">
		<!--- for jQuery DatePicker, with something to shrink the calendar --->
		<link rel="stylesheet" href="#application.paths.cssdir#ui/1.11.2/themes/smoothness/jquery-ui.css">

		<!--- datepicker MUST precede jfas.css, so jfas settings override --->
		<!--- jfas-specific (jfas.css) --->
		<link href="#application.paths.css#" rel="stylesheet" type="text/css" />

		<!--- additional css for media queries --->

		<link href="#application.paths.cssdir#jfashome.css" rel="stylesheet" type="text/css" />
		<!--- use this for browser feature detection, which is similar to "browser sniffing". see modernizr.com.  Must be in the HEAD section --->
		<script language="javascript"	src="#application.paths.jsdir#modernizr.js"></script>
		<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
		<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
		<!--[if lt IE 9]>
		  <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
		  <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
		<![endif]-->
		<!--- set up div with one-time alert message upon login. It it styled to be invisible until activated by JS --->
		<div id="SessionAnnouncement" >
			<div class="titlebar"> <!--- titlebar --->
				<div class="title">JFAS System Announcement
				</div>
				<!-- end of title -->
				<div class="btnTitleBar">
				<button class="usetooltip btn btn-link" btn-type="link"
				data-toggle="tooltip" data-placement="bottom" title="Close this announcement" name="btnAnnouncement"
				onClick = "glJFAS.oAnnouncementPopup.close();"
				>
				<img src="#application.paths.images#close.gif" alt="Close"  />
				</button>
				</div>
				<!-- button -->
			</div> <!--- titlebar --->
			<br style="clear: left;" />
			#session.Announcement#
		</div>
		<!-- SessionAnnouncement -->

	<cfelse>

		<!--- All pages except the Home page.  The old jfas setup --->
		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
		<link rel="icon" href="#application.urls.icon#" type="image/x-icon" />

		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<!--- CSS --->
		<!--- NO bootstrap.css here --->
		<!--- for jQuery DatePicker, with something to shrink the calendar --->
		<link rel="stylesheet" href="#application.paths.cssdir#ui/1.11.2/themes/smoothness/jquery-ui.css">

		<!--- datepicker MUST precede jfas.css, so jfas settings override --->
		<!--- jfas-specific (jfas.css) --->
		<link href="#application.paths.css#" rel="stylesheet" type="text/css" />

		<cfif findNocase("\budget\", CGI.PATH_TRANSLATED)>
			<link rel="stylesheet" href="#application.paths.cssdir#budget.css">
		</cfif>

	</cfif>
	<!--- end of set up bootstrap --->

	<title>#request.htmlTitleBase# : #request.htmlTitleDetail#</title>


	</head>
	<cfif arguments.IsHomePage EQ "yes">
		<body class="bodyHomeStyle">
	<cfelse>
		<body class="bodyDetailStyle">
	</cfif>
	<a name="pagebody"></a>

</cffunction>

<cffunction name="displayPrimaryNav">
	<cfargument name="IsHomePage" required="no" default="no">
	<cfsilent>
	<cfset var jsIsHomePage = "false">
	<cfset var btnstyle = "border:normal 0px !important; height:25px; border-top: 0px solid black !important;border-right: 1px solid black !important;">

	<cfif arguments.IsHomePage EQ "yes">
		<cfset jsIsHomePage = "true">
	</cfif>
	<!--- determines which area we are in, based on the specific location of the files --->
	<cfif findNocase("\admin\", CGI.PATH_TRANSLATED)>
		<cfset variables.currentSection = "admin">
	<cfelseif findNocase("\reports\", CGI.PATH_TRANSLATED)>
		<cfset variables.currentSection = "reports">
	<cfelseif findNocase("\budget\", CGI.PATH_TRANSLATED)>
		<cfset variables.currentSection = "budget">
	<cfelse>
		<cfset variables.currentSection = "contracts">
	</cfif>
	<!--- primary navigation buttons --->
	</cfsilent>
	<div class="PriNavDiv">
	<div class="PriNavDivLeft">
		<ul id="PriNav">
			<!--- set id="current" to show which section we are in????  Affects highlighting? --->

			<li <cfif variables.currentSection eq "contracts">id="current"</cfif>>
				<button type="button" class="btn btn-default btn-xs btn_pri_nav btn_pri_nav_gray " style="#btnStyle#" title="Go to JFAS Home Page to select AAPPs"  onclick="document.location='#application.paths.root#';"><span>&nbsp;&nbsp;AAPPs&nbsp;&nbsp;</span></button>
			</li>

			<cfif request.reportsAccess EQ 1>
				<li <cfif variables.currentSection eq "reports">id="current"</cfif>>
					<button type="button" class="btn btn-default btn-xs btn_pri_nav btn_pri_nav_gray " style="#btnStyle#" title="Go to List of Reports"  onclick="document.location='#application.paths.reports#';"><span>&nbsp;&nbsp;Reports&nbsp;&nbsp;</span></button>
				</li>
			</cfif>

			<cfif request.budgetAccess EQ 1>
				<!--- user has budget access --->
				<li <cfif variables.currentSection eq "budget">id="current"</cfif>>
					<button type="button" class="btn btn-default btn-xs btn_pri_nav_gray btn_pri_nav " style="#btnStyle#" title="Go to JFAS Budget Options" onclick="document.location='#application.paths.budget#';"><span>&nbsp;&nbsp;Budget&nbsp;&nbsp;</span></button>
				</li>

			</cfif>
			<cfif request.adminAccess EQ 1>
				<!--- user has admin access --->
				<li <cfif variables.currentSection eq "admin">id="current"</cfif>>
					<button type="button" class="btn btn-default btn-xs btn_pri_nav_gray btn_pri_nav " style="#btnStyle#" title="Go to JFAS Administration Options" onclick="document.location='#application.paths.admin#';"><span>&nbsp;&nbsp;Admin&nbsp;&nbsp;</span></button>
				</li>

			</cfif>
			<li >
				<button type="button" id="btnMyAAPPs" class="btn_pri_nav btn btn-default btn-xs " style="#btnStyle#" title="Jump to Detail about a particular My AAPP" onclick="openOneSubmenu('idMyAAPPs', '#session.userID#', #jsIsHomePage#);">&nbsp;&nbsp;My AAPPs <span class="caret"></span>&nbsp;&nbsp;</button>
			</li>

			<li <cfif variables.currentSection eq "myFilters">id="current"</cfif>>
				<button type="button" class="btn_pri_nav btn btn-default btn-xs " style="#btnStyle#"  <cfif arguments.IsHomePage NEQ "yes"> style="border-right:0 !important;" </cfif>title="Jump to the Home Page using a particular My Filter" onclick="openOneSubmenu('idMyFilters', '#session.userID#', #jsIsHomePage#);">&nbsp;&nbsp;My Filters <span class="caret"></span>&nbsp;&nbsp;</button>
			</li>

			<cfif arguments.IsHomePage EQ "yes">
				<!--- only allow admins and budget unit staff to create new AAPPs --->
				<cfif  request.reportsAccess AND listFind("1,2", session.roleID)>
					<li> <!--- newAAPP --->
						<button type="button" id="btnNewAAPP" class="btn_pri_nav btn btn-default btn-xs " style="#btnStyle#" style="border-right:0 !important; " title="Create a new DOL or CCC AAPP" onclick="openOneSubmenu('idNewAAPP', '#session.userID#', #jsIsHomePage#);">&nbsp;&nbsp;New AAPP <span class="caret">&nbsp;&nbsp;</span></button>
					</li> <!--- newAAPP --->
				</cfif>
			</cfif>
		</ul>
		<!-- PriNav -->
	</div>
	<!-- PriNavDivLeft -->
	<!--- "Additional Options" is defined only for AAPP page --->
	<div id="PriNavDivRight" class="PriNavDivRight">

		<cfif arguments.IsHomePage EQ "yes">

			<button type="button" class="btn_pri_nav btn btn-default btn-xs " style="border-right:0 !important;width:23px;" title="Additional Options" onclick="openOneSubmenu ('idHomePageOptions',  '#session.userID#', true);">
			<img src="#application.paths.images#options.png" class="ImgOnPriNav" />
			</button>

		<cfelseif findNocase("\aapp\", CGI.PATH_TRANSLATED)>

			<cfif structkeyexists (request, 'agreementtypecode') and request.agreementtypecode eq 'DC' AND request.budgetInputType neq "F">
				<button type="button" class="btn_pri_nav btn btn-default btn-xs " style="border-right:0 !important;width:26px;" title="Charts" onclick="openOneSubmenu ('idAAPPChartOptions',  '#session.userID#', false);">
				<img src="#application.paths.images#chart_icon.png" class="ImgOnPriNav" />
				</button>
			</cfif>

			<button type="button" class="btn_pri_nav btn btn-default btn-xs " style="border-right:0 !important;width:26px;" title="Additional Options" onclick="openOneSubmenu ('idAAPPPageOptions',  '#session.userID#', false);">
			<img src="#application.paths.images#options.png" class="ImgOnPriNav" />
			</button>

		</cfif>
	</div>
	<!-- /PriNavDivRight -->
	</div>
	<!-- /PriNavDiv -->
	<div class="clear"></div>
</cffunction> <!---displayPrimaryNav--->

<cffunction name="DisplayLogout" hint="I am a function to display links for logout, etc.">

	<div class="bannerLogoutNav" >
		#session.fullName# (#session.roleDesc#) | <a href="#application.paths.root#?logout=yes" title="Click to close this JFAS session">Logout</a> | <a href="javascript:openWindow('#application.urls.root#views/recentUpdates.cfm');" title="Click to see a description of recent updates to JFAS">Recent Updates</a> | <a href="javascript:OpenHelpWin(#request.pageHelpID#);" title="Click to see information about JFAS">Help</a> | <a href="javascript:openWindow('#application.urls.root#includes/JFAS_User_Manual.pdf');" title="Click to see the JFAS User Manual (PDF)">User Manual</a>
	</div>
	<!-- /bannerLogoutNav -->

</cffunction> <!--- DisplayLogout --->


<cffunction name="DisplayHeaderTitle" hint="I am a function to display Banner Title and the (hidden) NoFilter Icon">

	<cfset var titletext=ltrim(rtrim(request.pageTitleDisplay))>
	<!--- be sure jfasHeaderTitle height takes up enough room to have the overlay for Filtertext and ColumnHeadings --->
	<div id="jfasHeaderTitle">
		#titletext#
	</div>

</cffunction> <!--- DisplayHeaderTitle --->

<cffunction name="DisplayFilterText" hint="I am a function to display filters in effect.">
	<div id="idFilterText">
	</div>
</cffunction> <!--- DisplayFilterText --->

<cffunction name="DisplayColumnHeadings">
	<div id="ColumnHeadings" class="ColumnHeadings">
		<!--- display Column Headings --->
		<table width="100%" class="AAPPHomeTbl" summary="Column Headings for list of AAPPs">
		<tr>
			<th scope="col" width="6%"> <a href="##" onclick="javascript:adjustSortBy('aappNum');" title="Click to sort by AAPP Number" >AAPP</a></th>
			<th scope="col" width="6%"><a href="##" onclick="javascript:adjustSortBy('fundingOfficeDesc');" title="Click to sort by Funding Office">Fund</a></th>
			<th scope="col" width="22%"><a href="##" onclick="javascript:adjustSortBy('centerName');" title="Click to sort by Center">Center</a></th>
			<th scope="col" width="22%"><a href="##" onclick="javascript:adjustSortBy('programActivity');" title="Click to sort by Activity">Activity</a></th>
			<th scope="col" width="16%"><a href="##" onclick="javascript:adjustSortBy('contractorName');" title="Click to sort by Contractor">Contractor</a></th>
			<th scope="col" width="12%"><a href="##" onclick="javascript:adjustSortBy('contractNum');" title="Click to sort by Contract">Contract</a></th>
			<th scope="col" width="8%"><a href="##" onclick="javascript:adjustSortBy('dateStart');" title="Click to sort by Start Date">Start</a></th>
			<th scope="col" width="8%"><a href="##" onclick="javascript:adjustSortBy('dateEnd');" title="Click to sort by End Date">End</a></th>
		</tr>
		</table> <!--- column headings --->
	</div> <!-- divColumnHeadings -->
</cffunction> <!--- DisplayColumnHeadings --->


<cffunction name="DisplayQuickSearch">

	<!--- what is this??? --->
	<cfif isDefined("footerpage")>
		<div class="divQuickSearch"><br /><br /><a href="javascript:window.close(this);">Close</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</div> <!-- divQuickSearch -->
	</cfif> <!--- isDefined(footerpage)--->

	<cfif request.includeSearch>
		<div class="divQuickSearch">
		<!--- application.paths.aapp is aapp/aapp_summary.cfm --->
		<!--- the validateQuickSearch may go to an aapp Summary Page, or Home with a new criteria --->
			<form name="frmQuickSearch"
				<!--- If this action is actually performed, it is a bug. --->
				action="#application.paths.root#?jfasAction=deadend"
				method="post"
				onsubmit="return validateQuickSearch(this);"
				>

				<label for="quickaapp">AAPP Quick Search</label>
				<input name="quickaapp" id="quickaapp" type="text" maxlength="50"  title="Enter an AAPP number to find, then click GO" />
				<input name="btnSearch" type="submit" value="Go" title="Enter an AAPP number to find, then click GO" />
			</form>

		</div> <!-- divQuickSearch -->
	</cfif> <!--- request.includeSearch --->

</cffunction> <!--- DisplayQuickSearch --->

<!--- DisplayHomeFooter is called only by for the Home page --->

<cffunction name="DisplayHomeFooter">
	<cfif not isDefined("footerpage")>
		<script language="javascript">
			function openWindow(url)
			// opens a window detached from the main browser
			{
				newWin = window.open(url, "Info", 'status=no,toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=yes, width=790, height=350');
			}
		</script>
	</cfif>

	<cfif not isDefined("footerpage")>
		<!--- there is not already a footer page.  Put one on (without associated JS onDocument.Ready) --->
		<div class="homeFooter" id="homeFooter">
			<div class="FooterL">
				<a href="javascript:openWindow('#application.urls.root#views/accessibility.cfm');" >Accessibility</a> | <a href="javascript:openWindow('#application.urls.root#views/DisplayPrivacyAct.cfm');">Privacy</a> | <a href="javascript:openWindow('#application.urls.root#views/DisplayContactInfo.cfm');">Contact</a>
			</div> <!-- FooterL -->
			<div class="FooterR">
				<a href="#application.paths.dolhome#">Department of Labor</a> <a href="#application.paths.dolhome#"><img src="#application.paths.images#logo_dol.gif" alt="Department of Labor logo" width="33" height="32" border="0" align="middle" /></a>
			</div> <!-- FooterR -->
		</div> <!-- homeFooter -->
	</cfif>
</cffunction> <!--- DisplayHomeFooter --->

</cfoutput>

<!--- END of headerHome.cfm --->
