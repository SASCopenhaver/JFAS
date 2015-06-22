<HTML>
<HEAD>
<TITLE>Restful Test</TITLE>

<cfset formdata=structNew()>
<cfset formdata.aapp=2352>
<cfset formdata.cbopy='all'>

<cfset fred = application.ographicsrestful.f_getrst_fop_aapp(formdata)>
<cfdump var="#fred#" label="Having FUN!">


</HEAD>
</HTML>