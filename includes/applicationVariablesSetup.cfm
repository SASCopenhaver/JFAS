<!--- applicationVariablesSetup.cfm

	I set up the application variables when the application starts.

--->
<cfscript>
//  set up application paths
length = len(cgi.script_name);
position = findnocase("/jfas/", cgi.script_name);

//  A copy of the string, with count characters removed from the specified start position.
//  application.paths.root = RemoveChars(cgi.script_name, position, length) & "/jfas/";
//  bellenger 09/25/2013
application.paths.root				= mid(cgi.script_name, 1, findnocase("/jfas/", cgi.script_name) + 5);
application.paths.dotroot			= mid(replacenocase(application.paths.root, '/', '.', 'all'), 2, len(application.paths.root) - 1);
application.paths.includes			= application.paths.root & "includes/";
application.paths.config			= expandPath("#application.paths.root#\extensions\config\");
application.paths.components 		= application.paths.root & "model/cfc/";
application.paths.events			= application.paths.root & "extensions/scheduledevents/";
application.paths.upload			= expandPath("#application.paths.root#\tempupload\");

application.paths.cssdir			= application.paths.root & "includes/styles/css/" ;

//  images must be a subdirectory under the css files, so that you can write things like background-image: url(images/cnr_topR.gif); in a .css file
application.paths.images			= application.paths.cssdir & "images/";
application.paths.jsdir				= application.paths.root & "includes/javascript/" ;

application.paths.help				= application.paths.root & "help/JFAS_Help.htm";

application.paths.aapp				= application.paths.root & "aapp/aapp_summary.cfm" ;
application.paths.aappdir			= application.paths.root & "aapp/" ;
application.paths.reports			= application.paths.root & "reports/reports_main.cfm" ;
application.paths.reportdir			= application.paths.root & "reports/" ;
application.paths.admin				= application.paths.root & "admin/admin_main.cfm" ;
application.paths.admindir			= application.paths.root & "admin/" ;
application.paths.budget			= application.paths.root & "budget/splan_main.cfm" ;
application.paths.budgetdir			= application.paths.root & "budget/" ;
application.paths.error				= application.paths.root & "error/error.htm" ;
application.paths.errordir			= application.paths.root & "error/" ;
application.paths.accessRestricted	= application.paths.root & "error/no_access.htm" ;

application.paths.css				= application.paths.cssdir & "jfas.css" ;
application.paths.reportcss			= application.paths.cssdir & "jfas_report.css" ;
application.paths.dolhome			= "http://www.dol.gov";


// here are permanent support objects containing functions
application.olookup				= CreateObject(application.paths.dotroot & "model.cfc.lookup");
application.outility			= CreateObject(application.paths.dotroot & "model.cfc.utility");
application.oaapp_home			= CreateObject(application.paths.dotroot & "model.cfc.aapp_home");
application.oreports			= CreateObject(application.paths.dotroot & "model.cfc.reports");
application.oaapp				= CreateObject(application.paths.dotroot & "model.cfc.aapp");
application.osplan				= CreateObject(application.paths.dotroot & "model.cfc.splan");
application.osplan_ajax			= CreateObject(application.paths.dotroot & "model.cfc.splan_ajax");

//04/13/2015 application.osplan_approp_allot	= CreateObject(application.paths.dotroot & "model.cfc.splan_approp_allot");
// The following 2 lines replace the line above.
application.oapprop_allot	    = CreateObject(application.paths.dotroot & "model.cfc.approp_allot");
//application.ospend_plan	    	= CreateObject(application.paths.dotroot & "model.cfc.spend_plan");
application.ospend_plan	    	= CreateObject(application.paths.dotroot & "model.cfc.splan");

application.ographicsUtils		= CreateObject(application.paths.dotroot & "model.cfc.graphicsUtils");
application.ographicsRestful	= CreateObject(application.paths.dotroot & "model.cfc.graphicsRestful");

//  environment detection
if (findnocase("devetareports.doleta.gov", cgi.server_name) or
		findnocase("localhost", cgi.server_name) ) {
	//  development
	application.cfEnv 		= "dev";
	application.cfEnvDesc	= "Development";
	application.urlstart	= "http://";
}
else if (findnocase("testetareports.doleta.gov", cgi.server_name) or
		findnocase("63.88.32.86", cgi.server_name) or
		findnocase("63.88.32.87", cgi.server_name)) {
	//  test
	application.cfEnv		= "test";
	application.cfEnvDesc	= "Test";
	application.urlstart	= "https://";
}
else
{
	//  production
	application.cfEnv		= "prod";
	application.cfEnvDesc	= "Production";
	application.urlstart	= "https://";
}

// looking for http://devetareports.doleta.gov/cfdocs/grantee_prod/jfas_don/jfas/?session_id=86298&fwreinit=true
application.urls.root = application.urlstart & cgi.server_name & application.paths.root;
application.urls.upload = application.urls.root & 'tempupload/';
application.urls.icon =  application.urlstart & cgi.http_host & application.paths.images & 'jfas.ico';
application.urls.cssdir =  application.urlstart & cgi.http_host & application.paths.cssdir;

// want something like file:/E:/Inetpub/wwwroot/cfdocs/grantee_prod/jfas_donbak/jfas/includes/styles/css/jfas_report.css
application.paths.reportcssPDF		= 'file:/'&expandPath("#application.paths.cssdir#\jfas_report.css");

// store some values for lookup tables into the application scope
application.rstServiceTypes		= application.olookup.getServiceTypes();
application.rstAgreementTypes	= application.olookup.getAgreementTypes();
// belldr removed fundingOfficeTypeNot="FED".  We worry about that elsewhere, depending on role of person logged in.
application.rstFundingOffices	= application.olookup.getFundingOffices();
application.rstStates			= application.olookup.getStates();
application.rstRoles			= application.olookup.getJFASUserRoles(sortbyID=true);
application.slroleids			= valuelist ( application.rstRoles.roleid );
application.slrolecds			= valuelist ( application.rstRoles.rolecd );

application.jfas_system_email = application.outility.getSystemSetting('jfas_system_email');
if (application.jfas_system_email EQ '') {
	application.jfas_system_email = 'jfas.web@dol.gov';
}

application.technical_poc_email = application.outility.getSystemSetting('technical_poc_email');
if (application.technical_poc_email EQ '') {
	application.technical_poc_email = 'jfas.web@dol.gov';
}


// build conversions from codes to "english" abbreviations
// the goal here is to bury the difference in field names, table names, etc.

tTemp = DefineDefaultFilter();
application.userPreferencesDefault.tMyFilterNow = Duplicate(tTemp.tFilter);
application.userPreferencesDefault.slRequiredDefinedFilters = tTemp.slRequiredDefinedFilters;
application.userPreferencesDefault.slFilterFormNames = tTemp.slFilterFormNames;
application.userPreferencesDefault.aMyAAPPs = [];
application.userPreferencesDefault.aMyFilters = [];

tTemp = DefineDefaultSplanDisplaySettings();
application.userPreferencesDefault.tMySplanNow = Duplicate(tTemp.tSettings);

tCodeAbbreviations = structNew();
walker = 0;
thisPreference = '';


for(walker = 1; walker le ListLen(application.userPreferencesDefault.slRequiredDefinedFilters ); walker += 1) {

	foundmap = 0;
	thisPreference = ListGetAt(application.userPreferencesDefault.slRequiredDefinedFilters , walker);

	// code for one of the preferences
	if (thisPreference eq 'home_contractStatusFilter') {
		foundmap = 1;
		slThisCodeList = 'active,current,future,recon,closeout,inact';
		slThisAbbrList = 'ACT,CUR,FUT,DUE,COM,INA';
	}
	else if (thisPreference eq 'home_agreementTypeFilter') {
		foundmap = 1;
		slThisCodeList = ValueList(application.rstAgreementTypes.agreementTypeCode);
		slThisAbbrList = ValueList(application.rstAgreementTypes.agreementTypeAbbr);
	}
	else if (thisPreference eq 'home_fundingOfficeFilter') {
		foundmap = 1;
		slThisCodeList = ValueList(application.rstFundingOffices.fundingOfficeNum);
		slThisAbbrList = ValueList(application.rstFundingOffices.fundingOfficeAbbr);
	}
	else if (thisPreference eq 'home_stateFilter') {
		foundmap = 1;
		slThisCodeList = ValueList(application.rstStates.state);
		slThisAbbrList = ValueList(application.rstStates.state);
	}
	else if (thisPreference eq 'home_serviceTypeFilter') {
		foundmap = 1;
		slThisCodeList = ValueList(application.rstServiceTypes.contractTypeCode);
		slThisAbbrList = ValueList(application.rstServiceTypes.contractTypeShortDesc);
	}

	if (foundmap eq 1) {
		for (codewalker = 1; codewalker le ListLen(slThisCodeList); codewalker += 1) {
			thisCode = ListGetAt(slThisCodeList, codewalker);
			thisAbbr = ListGetAt(slThisAbbrList, codewalker);
			structInsert(tCodeAbbreviations, thisPreference & thisCode, thisAbbr, true );
		}
	}

	// naming convention:  preference name is like "home_contractStatusFilter",
}

application.tCodeAbbreviations = Duplicate(tCodeAbbreviations);

//  this prevents constant reloading of these parameters

application.appDataLoaded = true;

</cfscript>
<!--- END of applicationVariablesSetup.cfm --->
