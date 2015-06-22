<!--- reportFunctions.cfm --->

<!--- required for PDf format under https --->
<cffunction name="MakeCSSForPDF" >
	   <cfargument name="file" />
	   <cfset var fpath = ExpandPath(file)>
	   <cfset var f="">
	   <cfset f = createObject("java", "java.io.File")>
	   <cfset f.init(fpath)>
	   <cfreturn f.toUrl().toString()>
</cffunction>

<cfscript>

function OnlyDefined ( tInp ) {
	// this cleans up an argument struction from session, so it can be used as an argumentsCollection
	var tRet = {};
	var inpKeys = StructKeyArray ( tInp );
	for (var walker = 1; walker LE ArrayLen(inpKeys); walker += 1 ) {
		var key = inpKeys [ walker ];
		var value = StructFind ( tInp, key );

		if ( value NEQ '') {
			structInsert ( tRet,  key, value, 1 );
		}
	}

	return tRet;

} // OnlyDefined
</cfscript>


