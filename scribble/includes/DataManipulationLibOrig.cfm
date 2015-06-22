<!---
This library is part of the Common Function Library Project. An open source
	collection of UDF libraries designed for ColdFusion 5.0 and higher. For more information,
	please see the web site at:

		http://www.cflib.org

	Warning:
	You may not need all the functions in this library. If speed
	is _extremely_ important, you may want to consider deleting
	functions you do not plan on using. Normally you should not
	have to worry about the size of the library.

	License:
	This code may be used freely.
	You may modify this code as you see fit, however, this header, and the header
	for the functions must remain intact.

	This code is provided as is.  We make no warranty or guarantee.  Use of this code is at your own risk.
--->

<cfscript>
/**
 * This functions helps to quickly build arrays, both simple and complex.
 *
 * @param paramN 	 This UDF accepts N optional arguments. Each argument is added to the returned array. (Optional)
 * @return Returns an array.
 * @author Erki Esken (erki@dreamdrummer.com)
 * @version 1, July 3, 2002
 */
function Array() {
	var result = ArrayNew(1);
	var to = ArrayLen(arguments);
	var i = 0;
	for (i=1; i LTE to; i=i+1)
		result[i] = Duplicate(arguments[i]);
	return result;
}
</cfscript>

<cfscript>
/**
 * Appends two values to a 2D array.
 *
 * @param aName 	 The array. (Required)
 * @param value1 	 First value. (Required)
 * @param value2 	 Second value. (Required)
 * @return Returns the array.
 * @author Minh Lee Goon (contact@digeratidesignstudios.com)
 * @version 1, March 21, 2006
 */
function arrayAppend2D(aName, value1, value2) {
	var theLen = arrayLen(aName);

	aName[theLen+1][1] = value1;
	aName[theLen+1][2] = value2;

	return aName;
}
</cfscript>

<cfscript>
/**
 * Appends a value to an array if the value does not already exist within the array.
 *
 * @param a1 	 The array to modify.
 * @param val 	 The value to append.
 * @return Returns a modified array or an error string.
 * @author Craig Fisher (craig@altainteractive.com)
 * @version 1, October 29, 2001
 */
function ArrayAppendUnique(a1,val) {
	if ((NOT IsArray(a1))) {
		writeoutput("Error in <Code>ArrayAppendUnique()</code>! Correct usage: ArrayAppendUnique(<I>Array</I>, <I>Value</I>) -- Appends <em>Value</em> to the array if <em>Value</em> does not already exist");
		return 0;
	}
	if (NOT ListFind(Arraytolist(a1), val)) {
		arrayAppend(a1, val);
	}
	return a1;
}
</cfscript>

<cfscript>
/**
 * Returns a cartesian product (a join) of arbitrary number of arrays.
 * v1.0 by Azadi Saryev
 *
 * @param arrays 	 An array of arrays to process (Required)
 * @return An array that is the cartesian product of the passed-in arrays
 * @author Azadi Saryev (azadi.saryev@gmail.com)
 * @version 1.0, March 10, 2013
 */
public array function arrayCartesianProduct(required array arrays) {
	var result = [];
	var arraysLen = arrayLen(arguments.arrays);
	var size = (arraysLen) ? 1 : 0;
	var array = '';
	var x = 0;
	var i = 0;
	var j = 0;
	var current = [];

	for (x=1; x <= arraysLen; x++) {
		size = size * arrayLen(arguments.arrays[x]);
		current[x] = 1;
	}
	for (i=1; i <= size; i++) {
		result[i] = [];
		for (j=1; j <= arraysLen; j++) {
			arrayAppend(result[i], arguments.arrays[j][current[j]]);
		}
		for (j=arraysLen; j > 0; j--) {
			if (arrayLen(arguments.arrays[j]) > current[j])  {
				current[j]++;
				break;
			}
			else {
				current[j] = 1;
			}
		}
	}

	return result;
}
</cfscript>

<cfscript>
/**
 * Converts a Flex ArrayCollection object to a ColdFusion Query object
 * 03-mar-2010 added arguments scope
 *
 * @param arrayColl 	 Flex array collection (Required)
 * @return cfquery object
 * @author Adam Tuttle (adam@fusiongrokker.com)
 * @version 0, March 3, 2010
 */
function arrayCollectionToQuery(arrayColl){
	var qResult = 0;
	var columnList = structKeyList(arguments.arrayColl[1]);
	var typeList = '';
	var numericType = '';
	var k = 0;
	var i = 0;
	for ( k in arguments.arrayColl[1] ){
		if (isNumeric(arguments.arrayColl[1][k])){
			//decimal or integer?
			numericType = 'integer';
			for ( i = 1 ; i lte arrayLen(arguments.arrayColl) ; i = i + 1 ){
				if (arguments.arrayColl[i][k] - fix(arguments.arrayColl[i][k]) eq 0){
					numericType = 'decimal';
					break;
				}
		}
			typelist = listAppend(typeList, numericType);
		} else if (isSimpleValue(arguments.arrayColl[1][k])){
			typeList = listAppend(typeList, 'varchar');
		} else if (isBoolean(arguments.arrayColl[1][k])){
			typeList = listAppend(typeList, 'bit');
		} else if (isDate(arguments.arrayColl[1][k])){
			typeList = listAppend(typeList, 'date');
		} else {
			//we can't throw() in cf8, so uh...
			return "All keys in your array collection must be of one of the following types: Numeric (Int or Float), String, Boolean, Date. The following key contains data that is not one of these types: `#k#`";
		}
	}
	qResult = queryNew(columnList, typeList);
	for ( i = 1 ; i lte arrayLen(arguments.arrayColl) ; i = i + 1 ){
		queryAddRow(qResult);
		for (k in arguments.arrayColl[i]){
			if (not isNumeric(arguments.arrayColl[i][k]) and not isSimpleValue(arguments.arrayColl[i][k]) and not isBoolean(arguments.arrayColl[i][k]) and not isDate(arguments.arrayColl[i][k])){
				return "All keys in your array collection must be of one of the following types: Numeric (Int or Float), String, Boolean, Date. The following key contains data that is not one of these types: `#k#`";
			}
			querySetCell(qResult,k,arguments.arrayColl[i][k]);
		}
	}
	return qResult;
}
</cfscript>

<cfscript>
/**
 * Used to remove missing positions from an array.
 *
 * @param arr 	 Array to compact. (Required)
 * @param delim 	 Temporary list delimiter. Defaults to |. (Optional)
 * @return Returns an array.
 * @author M Gillespie for HOUCFUG (houcfug@yahoogroups.com)
 * @version 1, March 2, 2007
 */
function arrayCompact(arr) {
	var delim="|";
	if(arraylen(arguments) gt 1) {delim=arguments[2];}
	return listtoarray(arraytolist(arr,delim),delim);
}
</cfscript>

<cfscript>
/**
 * Recursive functions to compare arrays and nested structures.
 *
 * @param LeftArray 	 The first array. (Required)
 * @param RightArray 	 The second array. (Required)
 * @return Returns a boolean.
 * @author Ja Carter (ja@nuorbit.com)
 * @version 1, September 23, 2004
 */
function arrayCompare(LeftArray,RightArray) {
	var result = true;
	var i = "";

	//Make sure both params are arrays
	if (NOT (isArray(LeftArray) AND isArray(RightArray))) return false;

	//Make sure both arrays have the same length
	if (NOT arrayLen(LeftArray) EQ arrayLen(RightArray)) return false;

	// Loop through the elements and compare them one at a time
	for (i=1;i lte arrayLen(LeftArray); i = i+1) {
		//elements is a structure, call structCompare()
		if (isStruct(LeftArray[i])){
			result = structCompare(LeftArray[i],RightArray[i]);
			if (NOT result) return false;
		//elements is an array, call arrayCompare()
		} else if (isArray(LeftArray[i])){
			result = arrayCompare(LeftArray[i],RightArray[i]);
			if (NOT result) return false;
		//A simple type comparison here
		} else {
			if(LeftArray[i] IS NOT RightArray[i]) return false;
		}
	}

	return true;
}
</cfscript>

<cfscript>
/**
 * Concatenates two arrays.
 *
 * @param a1 	 The first array.
 * @param a2 	 The second array.
 * @return Returns an array.
 * @author Craig Fisher (craig@altainetractive.com)
 * @version 1, September 13, 2001
 */
function ArrayConcat(a1, a2){
	var i=1;
	if ((NOT IsArray(a1)) OR (NOT IsArray(a2))) {
		writeoutput("Error in <Code>ArrayConcat()</code>! Correct usage: ArrayConcat(<I>Array1</I>, <I>Array2</I>) -- Concatenates Array2 to the end of Array1");
		return 0;
	}
	for (i=1;i LTE ArrayLen(a2);i=i+1) {
		ArrayAppend(a1, Duplicate(a2[i]));
	}
	return a1;
}
</cfscript>


<cfscript>
/**
 * Returns the index of the first item in an array that contains a specified substring.
 * Mods by RCamden
 *
 * @param arrayToSearch 	 Array to search. (Required)
 * @param valueToFind 	 Value to look for. (Required)
 * @return Returns a number.
 * @author Sudhir Duddella (skduddella@hotmail.com)
 * @version 1, March 31, 2003
 */
function ArrayContainsNoCase(arrayToSearch,valueToFind){
	var arrayList = "";

	arrayList = ArrayToList(arrayToSearch);
	return ListContainsNoCase(arrayList,valueToFind);
}
</cfscript>

<cfscript>
/**
 * Returns true if a specified array position is defined.
 *
 * @param arr 	 The array to check. (Required)
 * @param pos 	 The position to check. (Required)
 * @return Returns a boolean.
 * @author Raymond Camden (ray@camdenfamily.com)
 * @version 2, October 24, 2003
 */
function arrayDefinedAt(arr,pos) {
	var temp = "";
	try {
		temp = arr[pos];
		return true;
	}
	catch(coldfusion.runtime.UndefinedElementException ex) {
		return false;
	}
	catch(coldfusion.runtime.CfJspPage$ArrayBoundException ex) {
		return false;
	}
}
</cfscript>

<cfscript>
/**
 * Remove elements from one array which exist in another array.
 *
 * @param baseArray 	 Main array of values. (Required)
 * @param deleteArray 	 Array of values to delete. (Required)
 * @return Returns an array.
 * @author Jason Rushton (jason@iworks.com)
 * @version 1, April 11, 2008
 */
function arrayDeleteArray( baseArray, deleteArray ) {
	arguments.baseArray.removeAll(arguments.deleteArray);
	return arguments.baseArray;
}
</cfscript>

<cfscript>
/**
 * Deletes an elements list from an array.
 *
 * @param a 	 The array to modify. (Required)
 * @param l 	 The list of indexes to remove. (Required)
 * @return Returns an array.
 * @author Giampaolo Bellavite (giampaolo@bellavite.com)
 * @version 1, January 21, 2005
 */
function ArrayDeleteAtList(a,l) {
	var i=1;
	l = listSort(l, "numeric", "desc");
	for(i=1; i lte listLen(l); i=i+1) arrayDeleteAt(a, listGetAt(l,i));
	return a;
}
</cfscript>

<cfscript>
/**
 * Compares two arrays and returns the difference between the two.
 * v1.0 by Greg Nettles
 * v2.0 by Adam Cameron under guidance from Jeff Coughlin - replaced unnecessary/ineffcient logic
 *
 * @param smallerArray 	 First array. (Required)
 * @param biggerArray 	 Second array. (Required)
 * @return Returns an array.
 * @author Greg Nettles (gregnettles@gmail.com)
 * @version 2.0, April 5, 2013
 */
function arrayDiff(smallerArray, biggerArray) {
	biggerArray.removeAll(smallerArray);
	return biggerArray;
}
</cfscript>

<!---
 Excludes numeric items from an array.
 V2 by Raymond Camden

 @param aObj 	 Array to filter. (Required)
 @return Returns an array.
 @author Marcos Placona (marcos.placona@gmail.com)
 @version 2, July 6, 2006
--->
<cffunction name="arrayExcludeNumeric" returntype="array">
	<cfargument name="aObj" type="array" required="Yes">
	<cfset var ii = "">

	<!--- Looping through the array --->
	<cfloop to="1" from="#arrayLen(aObj)#" index="ii" step="-1">
		<!--- Checking if it's a number --->
		<cfif isNumeric(aObj[ii])>
			<cfset arrayDeleteAt(arguments.aObj, ii) />
		</cfif>
	</cfloop>

	<cfreturn aObj />
</cffunction>

<!---
 Excludes string items from an array.

 @param aObj 	 Array to filter. (Required)
 @return Returns an array.
 @author Marcos Placona (marcos.placona@gmail.com)
 @version 1, July 11, 2006
--->
<cffunction name="arrayExcludeString" returntype="array">
	<cfargument name="aObj" type="array" required="Yes">
	<cfset var ii = "">

	<!--- Looping through the array --->
	<cfloop to="1" from="#arrayLen(aObj)#" index="ii" step="-1">
		<!--- Checking if it's a number --->
		<cfif not isNumeric(aObj[ii])>
			<cfset arrayDeleteAt(arguments.aObj, ii) />
		</cfif>
	</cfloop>

	<cfreturn aObj />
</cffunction>

<cfscript>
/**
 * Applies a filter to an array.
 *
 * @param array 	 Array to modify. (Required)
 * @param filter 	 The UDF, NOT THE NAME, but the UDF to use as a filter. (Required)
 * @return Returns an array.
 * @author Raymond Camden (ray@camdenfamily.com)
 * @version 1, March 31, 2003
 */
function arrayFilter(array,filter) {
	var newA = arrayNew(1);
	var i = 1;

	for(;i lte arrayLen(array); i=i+1) {
		if(filter(array[i])) arrayAppend(newA,array[i]);
	}

	return newA;
}
</cfscript>


<!---
 Search a multidimensional array for a value.

 @param arrayToSearch 	 Array to search. (Required)
 @param valueToFind 	 Value to find. (Required)
 @param dimensionToSearch 	 Dimension to search. (Required)
 @return Returns a number.
 @author Grant Szabo (grant@quagmire.com)
 @version 1, September 23, 2004
--->
<cffunction name="ArrayFindByDimension" access="public" returntype="numeric" output="false">
	<cfargument name="arrayToSearch" type="array" required="Yes">
	<cfargument name="valueToFind" type="string" required="Yes">
	<cfargument name="dimensionToSearch" type="numeric" required="Yes">
	<cfscript>
		var ii = 1;

		//loop through the array, looking for the value
		for(; ii LTE arrayLen(arguments.arrayToSearch); ii = ii + 1){
			//if this is the value, return the index
			if(NOT compareNoCase(arguments.arrayToSearch[ii][arguments.dimensionToSearch], arguments.valueToFind))
				return ii;
		}
		//if we've gotten this far, it means the value was not found, so return 0
		return 0;
	</cfscript>
</cffunction>


<cfscript>
/**
 * Locate a value in an already-sorted array.
 *
 * @param array 	 The array to check. (Required)
 * @param value 	 The value to look for. (Required)
 * @return Returns the position of the match, or 0.
 * @author Kenneth Fricklas (kenf@mallfinder.com)
 * @version 1, September 30, 2005
 */
function arrayFindSorted(arrayX, value)
{
	var m = 0;
	var found = 0;
	var done = 0;
	var hi = arrayLen(arrayX)+1;
	var lo = 1;
	var i = 1;
	var maxtest = 500;
	do {
		m = (hi + lo) \ 2;
		if (arrayX[m] EQ value)
		{
			found = 1;
			done = 1;
		}
		else
		{
			if ((m EQ lo) or (m EQ hi))
				done = 1; /* not found */
			else
			{
				if (value LT arrayX[m])
				{
				/* higher */
					hi = m;
				}
				else
				{
				/* lower */
					lo = m;
				}
			}
		}
		if (i EQ maxtest)
			{
			done = 1;
			writeoutput("Error! overflow in search");
			}
		else
			i = i + 1;
	} while (done EQ 0);
	if (found)
		return m;
	else
		return 0;
}
</cfscript>

<!---
 Splits or iterates over the array in number of groups.

 @param arrObj 	 Array to split up in groups. (Required)
 @param intGroup 	 Number of items allowed on each group. (Required)
 @param padding 	  What should it be filled with in case there's empty slots. (Optional)
 @return Returns an array.
 @author Marcos Placona (marcos.placona@gmail.com)
 @version 1, February 4, 2010
--->
<cffunction name="arrayGroupsOf" access="public" output="false" returntype="array">
	<cfargument name="arrObj" type="array" required="true" hint="An array object that will be split up in groups">
	<cfargument name="intGroup" type="numeric" required="true" hint="Number of items on each group">
	<cfargument name="padding" type="string" required="false" default=" " hint="What should it be filled with in case there's empty slots">

	<cfset var resArray = createObject("java", "java.util.ArrayList").Init(arguments.arrObj) />
	<cfset var arrGroup = arrayNew(1) />
	<cfset var arrObjGroup = arrayNew(1) />
	<cfset var arrObjSize = resArray.size()>
	<cfset var subStart = 0>
	<cfset var subEnd = arguments.intGroup>
	<cfset var ii = "">
	<cfset var difference = "">
	<cfset var jj = "">

	<cfset arrGroupSize = ceiling(arrObjSize / arguments.intGroup)>
	<cfset arrArrayGroupSize = arrGroupSize * arguments.intGroup>

	<cfif arrArrayGroupSize GT arrObjSize>
		<cfset difference = arrArrayGroupSize - arrObjSize>
		<cfloop from="1" to="#difference#" index="ii">
			<cfset resArray.add(arguments.padding) />
		</cfloop>
	</cfif>

	<cfloop from="1" to="#arrGroupSize#" index="jj">
		<cfset arrGroup = resArray.subList(subStart, subEnd)>
		<cfset arrayAppend(arrObjGroup, arrGroup)>

		<cfset subStart = subStart + arguments.intGroup>
		<cfset subEnd = subEnd  + arguments.intGroup>
		<cfset arrGroup = arrayNew(1) />
	</cfloop>

	<cfreturn arrObjGroup>

</cffunction>

<cfscript>
/**
 * Inserts an array at specified position in another array.
 *
 * @param a1 	 The first array.
 * @param a2 	 The second array.
 * @param pos 	 The position to insert at.
 * @return Returns an array.
 * @author Craig Fisher (craig@altainteractive.com)
 * @version 1, September 13, 2001
 */
function ArrayInsertArrayAt(a1, a2, pos) {
	var aNew = ArrayNew(1);
	var len1 = "";
	var len2 = "";
	var i = 1;
	if ((NOT isArray(a1)) OR (NOT isArray(a2)) OR (NOT IsNumeric(pos)) OR (pos LT 1) OR (pos GT ArrayLen(a1) +1) )  {
		writeoutput("Error in <Code>ArrayInsertArrayAt()</code>! Correct usage: ArrayInsertArrayAt(<I>Array1</I>, <I>Array2</I>,
<I>position</I>) -- Inserts <I>Array2</I> at <I>position</I> in
<I>Array2</I>");
		return 0;
	}
	pos=int(pos);
	len1=ArrayLen(a1);
	len2=ArrayLen(a2);
	aNew=Duplicate(a1);
	if (pos IS NOT Len1 + 1) {
		for (i=0; i LT len2; i=i+1) ArrayInsertAt(aNew, pos + i, Duplicate(a2[i+1]));
	}
	else {
		for (i=1;i LTE len2;i=i+1) ArrayAppend(aNew, Duplicate(a2[i]));
	}
	return aNew;
}
</cfscript>

<cfscript>
/**
 * Returns the index of the first item in an array that contains a list element.
 *
 * @param arrayToSearch 	 The array to search. (Required)
 * @param listToFind 	 List that will be searched for. If any item is found, the array index is returned. (Required)
 * @param delimiter 	 List delimiter. Defaults to a comma. (Optional)
 * @return Returns a number.
 * @author Steve Robison, Jr (steverobison@gmail.com)
 * @version 1, March 28, 2005
 */
function ArrayListCompareNoCase(arrayToSearch,listToFind){
	//a variable for looping
	var ii = 0;		// variable for looping through list
	var jj = 0;		// variable for looping through array
	var delimiter = ',';		// default delimiter


	// check to see if delimiters were passed
	if (ArrayLen(arguments) gt 2) delimiter = arguments[3];

	//loop through list
	for(ii = 1; ii LTE ListLen(listToFind, delimiter); ii = ii + 1) {
	//loop through the array, looking for the value
	for(jj = 1; jj LTE arrayLen(arrayToSearch); jj = jj + 1){
		//if this is the value, return the index
		if(NOT compareNoCase(arrayToSearch[jj],ListGetAt(listToFind, ii, delimiter)))
			return jj;
	}
	}
	//if we've gotten this far, it means the value was not found, so return 0
	return 0;
}
</cfscript>

<cfscript>
/**
 * Converts an array of objects to a CF Query Object.
 *
 * @param theArray 	 The array of CFCs. (Required)
 * @return Returns a query.
 * @author Don Quist (don.sigmaprojects@gmail.com)
 * @version 0, June 11, 2009
 */
function arrayOfObjectsToQuery(theArray){
    var colNames = ArrayNew(1);
    var theQuery = queryNew("");
    var i=0;
    var j=0;
	var o=0;
	var functions = '';
    //if there's nothing in the array, return the empty query
    if(NOT arrayLen(theArray)) return theQuery;

	//get meta data for the first object in the array and set the functions
	functions = getMetaData(theArray[1]).functions;
    //get the column names into an array =
	for(o=1; o LTE arrayLen(functions); o=o+1){
		if( REFindNoCase( 'get+', functions[o].NAME ) and functions[o].NAME IS NOT 'init' ) {
			arrayAppend(colNames, LCase(REReplaceNoCase(functions[o].NAME, "^get",'' )) );
		}
	}

	theQuery = queryNew(arrayToList(colNames));

    //add the right number of rows to the query
    queryAddRow(theQuery, arrayLen(theArray));
    //for each element in the array, loop through the columns, populating the query
    for(i=1; i LTE arrayLen(theArray); i=i+1){
        for(j=1; j LTE arrayLen(colNames); j=j+1){
			//bug out incase something isnt defined in the object
			try {
				querySetCell(theQuery, colNames[j], Evaluate('theArray[i].get#colNames[j]#()'), i);
			}
			catch(Any excpt) { }
        }
    }
    return theQuery;
}
</cfscript>

<cfscript>
/**
 * Returns the position of an element in an array of structures.
 *
 * @param array 	 Array to search. (Required)
 * @param searchKey 	 Key to check in the structs. (Required)
 * @param value 	 Value to search for. (Required)
 * @return Returns the numeric index of a match.
 * @author Nath Arduini (nathbot@gmail.com)
 * @version 0, June 11, 2009
 */
function arrayOfStructsFind(Array, SearchKey, Value){
	var result = 0;
	var i = 1;
	var key = "";
	for (i=1;i lte arrayLen(array);i=i+1){
		for (key in array[i])
		{
			if(array[i][key]==Value and key == SearchKey){
				result = i;
				return result;
			}
		}
	}

    return result;
}
</cfscript>

<cfscript>
/**
 * Sorts an array of structures based on a key in the structures.
 *
 * @param aofS 	 Array of structures. (Required)
 * @param key 	 Key to sort by. (Required)
 * @param sortOrder 	 Order to sort by, asc or desc. (Optional)
 * @param sortType 	 Text, textnocase, or numeric. (Optional)
 * @param delim 	 Delimiter used for temporary data storage. Must not exist in data. Defaults to a period. (Optional)
 * @return Returns a sorted array.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 1, April 4, 2013
 */
function arrayOfStructsSort(aOfS,key){
		//by default we'll use an ascending sort
		var sortOrder = "asc";
		//by default, we'll use a textnocase sort
		var sortType = "textnocase";
		//by default, use ascii character 30 as the delim
		var delim = ".";
		//make an array to hold the sort stuff
		var sortArray = arraynew(1);
		//make an array to return
		var returnArray = arraynew(1);
		//grab the number of elements in the array (used in the loops)
		var count = arrayLen(aOfS);
		//make a variable to use in the loop
		var ii = 1;
		//if there is a 3rd argument, set the sortOrder
		if(arraylen(arguments) GT 2)
			sortOrder = arguments[3];
		//if there is a 4th argument, set the sortType
		if(arraylen(arguments) GT 3)
			sortType = arguments[4];
		//if there is a 5th argument, set the delim
		if(arraylen(arguments) GT 4)
			delim = arguments[5];
		//loop over the array of structs, building the sortArray
		for(ii = 1; ii lte count; ii = ii + 1)
			sortArray[ii] = aOfS[ii][key] & delim & ii;
		//now sort the array
		arraySort(sortArray,sortType,sortOrder);
		//now build the return array
		for(ii = 1; ii lte count; ii = ii + 1)
			returnArray[ii] = aOfS[listLast(sortArray[ii],delim)];
		//return the array
		return returnArray;
}
</cfscript>

<!---
 Parses an array of consistent structs to return one key.

 @param arry 	 The array of structs. (Required)
 @param key 	 Key value to return. (Required)
 @param delim 	 List delimiter. Defaults to a comma. (Optional)
 @param dedup 	 If true, dedupes the list. Defaults to false. (Optional)
 @param returnas 	 Allows you to specify list or array for return type. Defaults to list. (Optional)
 @return Returns a list or array.
 @author Jon Briccetti (jbriccetti@gmail.com)
 @version 1, September 29, 2011
--->
<cffunction name="arrayofStuctsToList" output="true" access="public" returntype="any" hint="i return a list of values from a particular key in an array of structs. if the key doesnt exist in an element it is ignored">
	<cfargument name="arry" type="array" required="yes" hint="the array to search" />
	<cfargument name="key" type="string" required="yes" hint="the key name in the structure from which to pull a list value" />
	<cfargument name="delim" type="string" required="no" default="," hint="the list delim character(s)" />
	<cfargument name="dedup" type="boolean" required="no" default="false" hint="if you want me to de-dup the list, lemme know. dont expect any order coming back." />
	<cfargument name="returnas" type="string" required="no" default="list" hint="enum: list,array; you tell me what format you want your 'list' back" />
	<!--- KEEP IN MIND THAT WITH de-dup=true or in the event any key values are missing from struct elements, the order of the returned value may not correspond to the order of the original array --->
	<cfset var local = {} />
	<cfset local.result = "" />
	<cfset local.str = "" />
	<cfset local.dedup = {} />

	<cfset local.returnval = "" />
	<cfloop array="#arry#" index="local.i">
				<cftry>
					<cfif arguments.dedup>
							<cfset local.dedup[local.i[key]] = "" />
	      <cfelse>
	        <cfset local.str = listAppend(local.str,local.i[key],delim) />
	      </cfif>
	    	<cfcatch><!--- FAIL SILENTLY IF KEY DOESNT EXIST ---></cfcatch>
	    </cftry>
	</cfloop>
		<cfif arguments.dedup>
			<cfset local.str = structKeyList(local.dedup,delim) />
	</cfif>
	<cfif arguments.returnas EQ "array">
		<cfset local.result = listToArray(local.str,delim) />
	<cfelse>
		<cfset local.result = local.str />
	</cfif>

	<cfreturn local.result />
</cffunction>

<cfscript>
/**
 * Changes a given array of structures to a structure of arrays.
 *
 * @param ar 	 Array of structs. (Required)
 * @return Returns a struct.
 * @author Nathan Strutz (mrnate@hotmail.com)
 * @version 1, September 21, 2004
 */
function arrayOfStructsToStructOfArrays(ar) {
	var st = structNew();
	var arKeys = structKeyArray(ar[1]);
	var i=0;
	var j=0;
	var arLen = arrayLen(ar);
	for (i=1;i lte arrayLen(arKeys);i=i+1) {
		st[arKeys[i]] = arrayNew(1);
		for (j=1;j lte arLen;j=j+1) {
			st[arKeys[i]][j] = ar[j][arKeys[i]];
		}
	}
	return st;
}
</cfscript>

<!---
 Converts an array of structures to an structure of structures,

 @param array 	 An array of structs. (Required)
 @param key 	 A key value to use for the new structure. Must exist in all structs in the array. (Required)
 @return Returns a struct.
 @author Tayo Akinmade (olusina@hotmail.com)
 @version 0, June 11, 2009
--->
<cffunction name="ArrayOfStructsToStructsOfStructs" access="public" output="false" returntype="struct" hint="Converts an array of structs to an struct of structs">
		<cfargument name="array" type="array" required="true" hint="An array of structures">
		<cfargument name="key" type="string" required="true" hint="Key to use">

		<cfscript>
			var stStructOfStructs = structNew();
			var i = 0;

			// loop over array
			for(i=1;i lte arrayLen(arguments.array);i=i+1){
				stStructOfStructs[arguments.array[i][arguments.key]] = arguments.array[i];
			}

		    return stStructOfStructs;

		</cfscript>
	</cffunction>

<cfscript>
/**
 * Converts an array of structures to a CF Query Object.
 * 6-19-02: Minor revision by Rob Brooks-Bilson (rbils@amkor.com)
 *
 * Update to handle empty array passed in. Mod by Nathan Dintenfass. Also no longer using list func.
 *
 * @param Array 	 The array of structures to be converted to a query object.  Assumes each array element contains structure with same  (Required)
 * @return Returns a query object.
 * @author David Crawford (dcrawford@acteksoft.com)
 * @version 2, March 19, 2003
 */
function arrayOfStructuresToQuery(theArray){
	var colNames = "";
	var theQuery = queryNew("");
	var i=0;
	var j=0;
	//if there's nothing in the array, return the empty query
	if(NOT arrayLen(theArray))
		return theQuery;
	//get the column names into an array =
	colNames = structKeyArray(theArray[1]);
	//build the query based on the colNames
	theQuery = queryNew(arrayToList(colNames));
	//add the right number of rows to the query
	queryAddRow(theQuery, arrayLen(theArray));
	//for each element in the array, loop through the columns, populating the query
	for(i=1; i LTE arrayLen(theArray); i=i+1){
		for(j=1; j LTE arrayLen(colNames); j=j+1){
			querySetCell(theQuery, colNames[j], theArray[i][colNames[j]], i);
		}
	}
	return theQuery;
}
</cfscript>

<cfscript>
/**
 * Reverses the order of elements in a one-dimensional array.
 *
 * @param InArray 	 One-dimensional array to be reversed.
 * @return Returna a new one dimensional array.
 * @author Raymond Simmons (raymond@terraincognita.com)
 * @version 1.0, October 9, 2001
 */
function ArrayReverse(inArray){
	var outArray = ArrayNew(1);
	var i=0;
        var j = 1;
	for (i=ArrayLen(inArray);i GT 0;i=i-1){
		outArray[j] = inArray[i];
		j = j + 1;
	}
	return outArray;
}
</cfscript>


<cfscript>
/**
 * Shuffles the values in a one-dimensional array.
 *
 * @param ar 	 One dimensional array you want shuffled.
 * @return Returns an array.
 * @author Ivan Latunov (ivan@cfchat.net)
 * @version 1, October 9, 2001
 */
function ArrayShuffle(ar) {
	var ar1=ArrayNew(1);
	var i=1;
	var n=1;
	var len=ArrayLen(ar);
	if (NOT IsArray(ar,1)) {
		writeoutput("Error in <Code>ArrayShuffle()</code>! Correct usage: ArrayShuffle(<I>Array</I>) - Shuffles the values in one dimensional Array");
		return 0;
	}

	if (ArrayLen(ar) eq 0) {
		return ar1;
	}

	for (i=1; i lte len; i=i+1) {
		n = RandRange(1,ArrayLen(ar));
		ArrayAppend(ar1,ar[n]);
		ArrayDeleteAt(ar,n);
	}
	return ar1;
}
</cfscript>

<cfscript>
/**
 * Slices an array.
 *
 * @param ary 	 The array to slice. (Required)
 * @param start 	 The index to start with. Defaults to 1. (Optional)
 * @param finish 	 The index to end with. Defaults to the end of the array. (Optional)
 * @return Returns an array.
 * @author Darrell Maples (drmaples@gmail.com)
 * @version 1, July 13, 2005
 */
function arraySlice(ary) {
	var start = 1;
	var finish = arrayLen(ary);
	var slice = arrayNew(1);
	var j = 1;

	if (len(arguments[2])) { start = arguments[2]; };
	if (len(arguments[3])) { finish = arguments[3]; };

	for (j=start; j LTE finish; j=j+1) {
		arrayAppend(slice, ary[j]);
	}
	return slice;
}
</cfscript>

<!---
 An arraySlice using Java 1.4 ArrayList built-in method.

 @param thisArray 	 Array to slice. (Required)
 @param start 	 Starting value (defaults to 1). (Optional)
 @param length 	 Length of slice (defaults to 0 which will return the entire rest of the items after the start value). (Optional)
 @return Returns an array.
 @author G.Arlington (germann_arlington@yahoo.co.uk)
 @version 0, June 11, 2009
--->
<cffunction name="arraySlice2" returntype="array" output="false">
	<cfargument name="thisArray" required="true" type="array" />
	<cfargument name="start" required="false" type="numeric" default="1" />
	<cfargument name="length" required="false" type="numeric" default="0" />
	<cfset var resArray = createObject("java", "java.util.ArrayList").Init(arguments.thisArray) />
	<cfset var thisArrayLen = ArrayLen(arguments.thisArray) />
	<cfset var finish = 0 />
	<cfif (arguments.length EQ 0) OR ((arguments.start + arguments.length - 1) GT thisArrayLen)>
		<cfset arguments.length = thisArrayLen - arguments.start + 1 />
	</cfif>
	<cfset finish = arguments.start + arguments.length - 1 />

	<cfreturn resArray.subList(JavaCast("int", arguments.start - 1), JavaCast("int", finish)) />
</cffunction>

<cfscript>
/**
 * Sorts a two dimensional array by the specified column in the second dimension.
 * version 1.0 by Robert West
 * version 1.09 by Richard Davies (added support for delimiter)
 * version 1.1 by Adam Cameron (using a more appropriate default delimiter)
 *
 * @param arrayToSort 	 A two-dimensional array to sort (Required)
 * @param sortColumn 	 The index in the second-dimension to sort on (Required)
 * @param type 	 Type of sort (as per same-named argument for arraySort() (Required)
 * @param direction 	 How to sort. One of ASC (default) or DESC (Optional)
 * @param delimiter 	 Used to override the delimiter used internally. If the data to sort contains a ASCII 31 (unit separator) character, specify a DIFFERENT delimiter here (Optional)
 * @return Returns an array.
 * @author Robert West (robert.west@digiphilic.com)
 * @version 1.1, December 19, 2012
 */
function arraySort2D(arrayToSort, sortColumn, type) {
	var order			= "asc";
	var delim			= chr(31); // unit separator. This needs to be something that is very unlikely to show up in the values being sorted
	var i				= 1;
	var j				= 1;
	var thePosition		= "";
	var theList			= "";
	var arrayToReturn	= arrayNew(2);
	var sortArray		= arrayNew(1);
	var counter			= 1;

	if (arrayLen(arguments) GT 3){
		order = arguments[4];
	}

	if (arrayLen(arguments) GT 4){
		delim = arguments[5];
	}

	for (i=1; i LTE arrayLen(arrayToSort); i=i+1) {
		arrayAppend(sortArray, arrayToSort[i][sortColumn]);
	}

	theList = arrayToList(sortArray, delim);
	arraySort(sortArray, type, order);

	for (i=1; i LTE arrayLen(sortArray); i=i+1) {
		thePosition = listFind(theList, sortArray[i], delim);
		theList = listDeleteAt(theList, thePosition, delim);
		for (j=1; j LTE arrayLen(arrayToSort[thePosition]); j=j+1) {
			arrayToReturn[counter][j] = arrayToSort[thePosition][j];
		}
		arrayDeleteAt(arrayToSort, thePosition);
		counter = counter + 1;
	}
	return arrayToReturn;
}
</cfscript>

<!---
 This method trims an array to the specified number of elements.

 @return Returns an array.
 @author Tayo Akinmade (olusina@hotmail.com)
 @version 1, January 31, 2012
--->
<cffunction name="arrayTrim" access="public" returntype="array" output="false" hint="This method trims an array to the specified number of elements. Triming is from right to left by default">
	<cfargument name="aArray" type="array" required="true" hint="The array to be trimed">
	<cfargument name="iLength" type="numeric" required="true" hint="The length the array is to be trimmed to">
	<cfargument name="sTrimFrom" type="string" required="false" hint="Direction of the array trim. RIGHT->LEFT|R, LEFT-RIGHT|L" default="L">
	<cfscript>
		var stLocal							= structNew();

		stLocal.aTrimmedArray 				= arguments.aArray;										// set trimmed array
		stLocal.iLoopIteration				= arrayLen(stLocal.aTrimmedArray)-arguments.iLength; 	// get number of delete iterations

		// check if new length is less that the current length
		if(arguments.iLength lt  arrayLen(stLocal.aTrimmedArray)){
			for(stLocal.i = 1; stLocal.i lte stLocal.iLoopIteration;stLocal.i = stLocal.i + 1){
				// get index of array element to delete
				if(compareNoCase(arguments.sTrimFrom,"R") EQ 0){
					stLocal.iDeleteIindex	=  arrayLen(stLocal.aTrimmedArray);
				}
				else{
					stLocal.iDeleteIindex	= 1;
				}

				// delete array element
				arrayDeleteAt(stLocal.aTrimmedArray, stLocal.iDeleteIindex);
			}
		}

		return stLocal.aTrimmedArray;
	</cfscript>
</cffunction>

<cfscript>
/**
 * Complex variable checking with a single function call.
 * Version 2 by Michael Wolfe, mikey@mikeycentral.com. Returns false earlier.
 *
 * @param assertion 	 Assertion rule string you want to validate against.  Variable names should be delimited by the pipe (|). (Required)
 * @return Returns a Boolean value.
 * @author Dean Chalk (dchalk99@hotmail.com)
 * @version 2, September 23, 2004
 */
function assert(assertion) {
	var result = 1;
	var loopvar1 = 0;
	var loopvar2 = 0;
	var variableassertion = "";
	var varsection = "";
	var varname = "";
	var varalias = "";
	var assertionsection = "";
	var anassertion = "";
	var assertnow = "";
	var doBreak = false;

	for(loopvar1 = 1; loopvar1 LTE listlen(assertion, "!"); loopvar1 = incrementvalue(loopvar1)) {
		variableassertion = listgetat(assertion, loopvar1, "!");
		varsection = trim(gettoken(variableassertion, 1, ":"));
		varname = trim(listfirst(varsection, " "));
		varalias = trim(listlast(varsection, " "));
		assertionsection = trim(gettoken(variableassertion, 2, ":"));

		for(loopvar2 = 1; loopvar2 LTE listlen(assertionsection, ";"); loopvar2 = incrementvalue(loopvar2)) {
			anassertion = listgetat(assertionsection, loopvar2, ";");

			if(not isdefined(varname)){
				result = 0;
				doBreak = true;
				break;
			} else {
				assertnow = replacenocase(anassertion, "|#varalias#|", varname, "ALL");

				if(not(evaluate(trim(assertnow)))){
					result = 0;
					doBreak = true;
					break;
				}
			}
		}

		if(doBreak){
			break;
		}
	}

	return result;
}
</cfscript>

<cfscript>
/**
 * Simply converts access yes/no or other boolean variables to 0/1 format, almost opposite of yesnoformat
 *
 * @param value 	 The value to convert. (Optional)
 * @return Returns 1 or 0.
 * @author Craig M. Rosenblum (crosenblum@gmail.com)
 * @version 1, July 3, 2006
 */
function booleanize(value) {
	if (not isboolean(value)) {
		value = replacenocase(value,'on',1);
		value = replacenocase(value,'off',0);
	}
	if (yesnoformat(value) eq 'Yes') value = 1;
	if (yesnoformat(value) eq 'No') value = 0;
	return value;
}
</cfscript>

<!---
 I create a new user defined cache region in Ehcache with customizable parameters.

 @param name 	 Name of the cache. (Required)
 @param maxElementsInMemory 	 Defines max elements in memory. Defaults to 10000. (Optional)
 @param maxElementsOnDisk 	 Defines max elements on disk. Defaults to 10000000. (Optional)
 @param memoryStoreEvictionPolicy 	 Eviction policy for the cache. Defaults to LRU. (Optional)
 @param clearOnFlush 	 Boolean for cache flushing. Defaults to true. (Optional)
 @param eternal 	 Boolean for eternal setting. Defaults to false. (Optional)
 @param timeToIdleSeconds 	 Time to idle seconds setting. Defaults to 86400 (Optional)
 @param timeToLiveSeconds 	 Time to live seconds setting. Defaults to 86400 (Optional)
 @param overflowToDisk 	 Boolean for overflow to disk setting. Defaults to false. (Optional)
 @param diskPersistent 	 Disk persistence setting. Defaults to false. (Optional)
 @param diskSpoolBufferSizeMB 	 Disk spool buffer size setting. Defaults to 30. (Optional)
 @param diskAccessStripes 	 Disk access stripes setting. Defaults to 1. (Optional)
 @param diskExpiryThreadIntervalSeconds 	 Disk expiry thread interval seconds setting. Defaults to 120. (Optional)
 @return Returns nothing.
 @author Rob Brooks-Bilson (rbils@amkor.com)
 @version 1, June 22, 2011
--->
<cffunction name="cacheCreate" output="false" returntype="void"
	hint="I create a new user defined cache region in Ehcache"
	description="I create a new user defined cache region in Ehcache. This function
			     allows you to also configure the attributes for the custom cache,
			     something you would normally have to hard code in the ehcache.xml
			     file if you rely on ColdFusion's built in caching functions. I named
			     the function cacheCreate() and not cacheNew() in the hopes that a
			     future version of ColdFusion includes a cacheNew() function with
			     similar functionality.">

	<!--- this is what's configurable as of Ehcache 2.0 (CF 9.0.1). Only required
		  argument is Name --->
	<cfargument name="name" type="string" required="true">
	<cfargument name="maxElementsInMemory" type="numeric" default="10000">
	<cfargument name="maxElementsOnDisk" type="numeric" default="10000000">
	<cfargument name="memoryStoreEvictionPolicy" type="string" default="LRU">
	<cfargument name="clearOnFlush" type="boolean" default="true">
	<cfargument name="eternal" type="boolean" default="false">
	<cfargument name="timeToIdleSeconds" type="numeric" default="86400">
	<cfargument name="timeToLiveSeconds" type="numeric" default="86400">
	<cfargument name="overflowToDisk" type="boolean" default="false">
	<cfargument name="diskPersistent" type="boolean" default="false">
	<cfargument name="diskSpoolBufferSizeMB" type="numeric" default="30">
	<cfargument name="diskAccessStripes" type="numeric" default="1">
	<cfargument name="diskExpiryThreadIntervalSeconds" type="numeric" default="120">

	<!--- We need to do this in java because ColdFusion's cacheGetSession() returns
	      the underlying object for an EXISTING cache, not the generic cache manager --->
	<cfset local.cacheManager = createObject('java', 'net.sf.ehcache.CacheManager').getInstance()>

	<!--- constructor takes cache name and max elements in memory --->
	<cfset local.cacheConfig = createObject("java", "net.sf.ehcache.config.CacheConfiguration").init("#arguments.name#", #arguments.maxElementsInMemory#)>
	<cfset local.cacheConfig.maxElementsOnDisk(#arguments.maxElementsOnDisk#)>
	<cfset local.cacheConfig.memoryStoreEvictionPolicy("#arguments.memoryStoreEvictionPolicy#")>
	<cfset local.cacheConfig.clearOnFlush(#arguments.clearOnFlush#)>
	<cfset local.cacheConfig.eternal(#arguments.eternal#)>
	<cfset local.cacheConfig.timeToIdleSeconds(#arguments.timeToIdleSeconds#)>
	<cfset local.cacheConfig.timeToLiveSeconds(#arguments.timeToLiveSeconds#)>
	<cfset local.cacheConfig.overflowToDisk(#arguments.overflowToDisk#)>
	<cfset local.cacheConfig.diskPersistent(#arguments.diskPersistent#)>
	<cfset local.cacheConfig.diskSpoolBufferSizeMB(#arguments.diskSpoolBufferSizeMB#)>
	<cfset local.cacheConfig.diskAccessStripes(#arguments.diskAccessStripes#)>
	<cfset local.cacheConfig.diskExpiryThreadIntervalSeconds(#arguments.diskExpiryThreadIntervalSeconds#)>

	<cfset local.cache = createObject("java", "net.sf.ehcache.Cache").init(local.cacheConfig)>
	<cfset local.cacheManager.addCache(local.cache)>
</cffunction>

<cfscript>
/**
 * Mocks the CFQUERY tag.
 *
 * @param dsn 	 Datasource. Must be registered in the ODBC Control Panel. (Required)
 * @param col 	 List of columns. (Required)
 * @param sql 	 Sql to use. (Required)
 * @return Returns a query.
 * @author Joe Nicora (joe@seemecreate.com)
 * @version 1, September 21, 2004
 */
function cfquery(dsn,col,sql) {
    var datasource = dsn;
    var userName = "";
    var password = "";
    var adOpenStatic = 3;
    var adLockReadOnly=1;
    var adCmdTxt = 1;
    var adGetRowsRest = -1;
    var columns = listToArray(col);
    var strSQL = sql;
    var objDataConn = CreateObject("COM", "ADODB.Connection");
    var objDataRst = "";
    var intRecordCount = "";
    var arrRst = "";
    var qry = queryNew(arrayToList(columns));
    var thisCol = "";
    var thisRow = "";

    objDataConn.Open(Datasource, userName, password, -1);
    objDataRst = CreateObject("COM", "ADODB.Recordset");
    objDataRst.open(strSQL, objDataConn, adOpenStatic, adLockReadOnly, adCmdTxt);
    intRecordCount = objDataRst.RecordCount;
    arrRst = objDataRst.GetRows(adGetRowsRest);

    queryAddRow(qry,intRecordCount);
    for (thisCol=1; thisCol LTE arrayLen(columns); thisCol=thisCol+1) {
        for (thisRow=1; thisRow LTE arrayLen(arrRst[thisCol]); thisRow=thisRow+1) {
	    querySetCell(qry,columns[thisCol],arrRst[thisCol][thisRow],thisRow);
	}
    }
    objDataRST.close();
    objDataConn.close();
    return qry;
}
</cfscript>

<!---
 This function recurse through a structure and makes all fields as empty string

 @param s 	 Structure to clear. (Required)
 @return Returns a structure.
 @author Qasim Rasheed (qasimrasheed@hotmail.com)
 @version 1, January 28, 2005
--->
<cffunction name="clearStructureNested" returntype="void" output="false">
	<cfargument name="s" type="struct" required="true" />
	<cfset var i = "">
	<cfloop collection="#arguments.s#" item="i">
		<cfif isstruct(arguments.s[i])>
			<cfset clearStructureNested(arguments.s[i])>
		<cfelse>
			<cfset structupdate(arguments.s, i,"")>
		</cfif>
	</cfloop>
</cffunction>

<cfscript>
/**
 * Applies simple evaluations to every cell in a query column.
 *
 * @param query 	 Query object. (Required)
 * @param columnName 	 Column to be modified. (Required)
 * @param theEval 	 Evaluation to be performed. Use X to represent column data. (Required)
 * @return Returns a query.
 * @author Shawn Seley (shawnse@aol.com)
 * @version 1, September 12, 2003
 */
function ColumnLoop(query, columnName, theEval) {
	var row = 0;
	var x = "";
	var rec_count = query.recordCount;
	for(row=1; row LTE rec_count; row=row+1) {
		x = query[columnName][row];
		querySetCell(query,columnname,evaluate(theEval),row);
	}
	return query;
}
</cfscript>

<cfscript>
/**
 * This UDF calculates the total of a column from a query.
 * Version 2 by Raymond Camden
 *
 * @param qryColumn 	 The name and column of the query, i.e. foo.total (Required)
 * @return Returns a number.
 * @author Scott Barber (charlesbarber@hotmail.com)
 * @version 2, May 13, 2003
 */
function columnTotal(qryColumn){
	return arraySum(listToArray(evaluate("valueList(" & qryColumn & ")")));
}
</cfscript>

<cfscript>
/**
 * Creates a CFC instance based upon a relative, absolute or dot notation path.
 *
 * @param path 	 Path for the component. (Required)
 * @param type 	 Type of the path. Possible values are "component" (normal dot notation), "relative" and "absolute". Defaults to component.  (Optional)
 * @return Returns a CFC.
 * @author Dan G. Switzer, II (dswitzer@pengoworks.com)
 * @version 1, May 13, 2003
 */
function component(path){
	var sPath=Arguments.path;var oProxy="";var oFile="";var sType="";
	if( arrayLen(Arguments) gt 1 ) sType = lCase(Arguments[2]);

	// determine a default type
	if( len(sType) eq 0 ){
		if( (sPath DOES NOT CONTAIN ".") OR ((sPath CONTAINS ".") AND (sPath DOES NOT CONTAIN "/") AND (sPath DOES NOT CONTAIN "\")) ) sType = "component";
		else sType = "relative";
	}

	// create the component
	switch( left(sType,1) ){
		case "c":
			return createObject("component", sPath);
		break;

		default:
			if( left(sType, 1) neq "a" ) sPath = expandPath(sPath);
			oProxy = createObject("java", "coldfusion.runtime.TemplateProxy");
			oFile = createObject("java", "java.io.File");
			oFile.init(sPath);
			return oProxy.resolveFile(getPageContext(), oFile);
		break;
	}
}
</cfscript>

<!---
 Takes a .Net dataset and converts it to a CF structure of queries.

 @param dataset 	 Dot net dataset. (Required)
 @return Returns a structure.
 @author Anthony Petruzzi (tonyp@rolist.com)
 @version 1, May 17, 2007
--->
<cffunction name="convertDotNetDataset" access="public" returnType="struct" output="false"
			hint="takes a .Net dataset and converts it to a CF structure of queries">
	<cfargument name="dataset" required="true">
	<cfset var Local = StructNew()>
	<cfset Local.result = structNew() />
	<cfset Local.aDataset = arguments.dataset.get_any() />
	<cfset Local.xSchema  = xmlParse(Local.aDataset[1]) />
	<cfset Local.xData  = xmlParse(Local.aDataset[2]) />

	<!--- Create Queries --->
	<cfset Local.xTables = Local.xSchema["xs:schema"]["xs:element"]["xs:complexType"]["xs:choice"] />
	<cfloop from="1" to="#arrayLen(Local.xTables.xmlChildren)#" index="Local.i">
		<cfset Local.tableName = Local.xTables.xmlChildren[Local.i].xmlAttributes.name />
		<cfset Local.xColumns = Local.xTables.xmlChildren[Local.i].xmlChildren[1].xmlChildren[1].xmlChildren/>
		<cfset Local.result[Local.tableName] = queryNew("") />
		<cfloop from="1" to="#arrayLen(Local.xColumns)#" index="Local.j">
			<cfset queryAddColumn(Local.result[Local.tableName], Local.xColumns[Local.j].xmlAttributes.name, arrayNew(1)) />
		</cfloop>
	</cfloop>

	<!--- see if there are any row of data, if not exit --->
	<cfif NOT StructKeyExists(Local.xData["diffgr:diffgram"], "NewDataSet")>
		<cfreturn Local.result>
	</cfif>

	<!--- Populate Queries --->
	<cfset Local.xRows = Local.xData["diffgr:diffgram"]["NewDataSet"] />
	<cfloop from="1" to="#arrayLen(Local.xRows.xmlChildren)#" index="Local.i">
		<cfset Local.thisRow = Local.xRows.xmlChildren[Local.i] />
		<cfset Local.tableName = Local.thisRow.xmlName />
		<cfset queryAddRow(Local.result[Local.tableName], 1) />
		<cfloop from="1" to="#arrayLen(Local.thisRow.xmlChildren)#" index="Local.j">
			<cfset querySetCell(Local.result[Local.tableName], Local.thisRow.xmlChildren[Local.j].xmlName, Local.thisRow.xmlChildren[Local.j].xmlText, Local.result[Local.tableName].recordCount) />
		</cfloop>
	</cfloop>

	<cfreturn Local.result>
</cffunction>

<!---
 Converts a URL query string to a struct
 v1.0 by Chris Weller
 v1.1 by Adam Cameron (removing redundant intermediary variables)

 @param querystring 	 Query string to convert (Required)
 @return A struct of query string name/value pairs
 @author Chris Weller (wellercs@gmail.com)
 @version 1, December 27, 2013
--->
<cffunction name="convertQueryStringToStruct" access="public" returntype="struct" output="false" hint="I accept a URL query string and return it as a structure.">
	<cfargument name="querystring" type="string" required="true" hint="I am the query string for which to parse.">

	<cfreturn createObject('java', 'coldfusion.util.HTMLTools').parseQueryString(arguments.querystring)>
</cffunction>

<cfscript>
/**
 * Simulate the c functionality of i--.
 *
 * @param intCounter 	 The name, not the value, of the variable to be decremented.
 * @return Returns the value of the variable BEFORE it has been decremented.
 * @author Stephan Scheele (stephan@stephan-t-scheele.de)
 * @version 1, April 19, 2002
 */
function counterMinusMinus(intCounter) {
	var temp = evaluate(intCounter);
	"#intCounter#" = temp - 1;
	return temp;
}
</cfscript>

<cfscript>
/**
 * Simulate the c functionality of i++.
 *
 * @param intCounter 	 The name, not the value, of the variable to be incremented.
 * @return Returns the value of the variable BEFORE it was incremented.
 * @author Stephan Scheele (stephan@stephan-t-scheele.de)
 * @version 1, April 17, 2002
 */
function counterPlusPlus(intCounter){
	var temp = evaluate(intCounter);
	"#intCounter#" = temp + 1;
	return temp;
}
</cfscript>

<cfscript>
/**
 * CSVFormat accepts the name of an existing query and converts it to csv format.
 * Updated version of UDF orig. written by Simon Horwith
 *
 * @param query 	 The query to format. (Required)
 * @param qualifer 	 A string to qualify the data with. (Optional)
 * @param columns 	 The columns ot use. Defaults to all columns. (Optional)
 * @return A CSV formatted string.
 * @author Jeff Howden (cflib@jeffhowden.com)
 * @version 2, August 26, 2008
 */
function CSVFormat(query) {
  var returnValue = ArrayNew(1);
  var rowValue = '';
  var columns = query.columnlist;
  var qualifier = '';
  var i = 1;
  var j = 1;
  if(ArrayLen(Arguments) GTE 2) qualifier = Arguments[2];
  if(ArrayLen(Arguments) GTE 3 AND Len(Arguments[3])) columns = Arguments[3];
  returnValue[1] = ListQualify(columns, qualifier);
  ArrayResize(returnValue, query.recordcount + 1);
  columns = ListToArray(columns);
  for(i = 1; i LTE query.recordcount; i = i + 1)
  {
    rowValue = ArrayNew(1);
    ArrayResize(rowValue, ArrayLen(columns));
    for(j = 1; j LTE ArrayLen(columns); j = j + 1)
      rowValue[j] = qualifier & query[columns[j]][i] & qualifier;
    returnValue[i + 1] = ArrayToList(rowValue);
  }
  returnValue = ArrayToList(returnValue, Chr(13));
  return returnValue;
}
</cfscript>

<cfscript>
/**
 * Transform a CSV formatted string with header column into a query object.
 *
 * @param cvsString 	 CVS Data. (Required)
 * @param rowDelim 	 Row delimiter. Defaults to CHR(10). (Optional)
 * @param colDelim 	 Column delimiter. Defaults to a comma. (Optional)
 * @return Returns a query.
 * @author Tony Brandner (tony@brandners.com)
 * @version 1, September 30, 2005
 */
function csvToQuery(csvString){
	var rowDelim = chr(10);
	var colDelim = ",";
	var numCols = 1;
	var newQuery = QueryNew("");
	var arrayCol = ArrayNew(1);
	var i = 1;
	var j = 1;

	csvString = trim(csvString);

	if(arrayLen(arguments) GE 2) rowDelim = arguments[2];
	if(arrayLen(arguments) GE 3) colDelim = arguments[3];

	arrayCol = listToArray(listFirst(csvString,rowDelim),colDelim);

	for(i=1; i le arrayLen(arrayCol); i=i+1) queryAddColumn(newQuery, arrayCol[i], ArrayNew(1));

	for(i=2; i le listLen(csvString,rowDelim); i=i+1) {
		queryAddRow(newQuery);
		for(j=1; j le arrayLen(arrayCol); j=j+1) {
			if(listLen(listGetAt(csvString,i,rowDelim),colDelim) ge j) {
				querySetCell(newQuery, arrayCol[j],listGetAt(listGetAt(csvString,i,rowDelim),j,colDelim), i-1);
			}
		}
	}
	return newQuery;
}
</cfscript>

<cfscript>
/**
 * Counts the number of keys in a structure of structures.
 * Added missing return statement (rkc)
 *
 * @param myStruct 	 The structure to examine. (Required)
 * @return Returns a numeric value.
 * @author Galen Smallen (galen@oncli.com)
 * @version 2, August 23, 2002
 */
function deepStructCount(myStruct) {
    var deepCount=0;
    var x = "";
    var i = "";

    for (x in myStruct) {
        if(isArray(myStruct[x])) {
            for(i=1; i lte arrayLen(myStruct[x]); i=i+1) {
                if(isStruct(myStruct[x][i])) deepCount = deepCount+deepStructCount(myStruct[x][i]);
            }
        } else if (isStruct(myStruct[x])) {
            deepCount=deepCount+deepStructCount(myStruct[x]);
        } else {
            deepCount=deepCount+1;
        }
    }
	return deepCount;
}
</cfscript>

<cfscript>
/**
 * Displays contents of any data type except WDDX.
 *
 * @param varToProcess 	 The variable to dump.
 * @return Returns a string.
 * @author Chris Benson (airfoof@yahoo.com)
 * @version 1, April 23, 2002
 */
function DumpVar(varToProcess){
		var structLoopCount = 0;
		var LoopCount = 0;
		var ObjSize = 0;
		var key = "";
        var keys = "";
		var numOfColumns = 0;
        var count2 = 0;

		var StartString = "";
		var EndString = "</table>#chr(10)#";
		if(isSimpleValue(varToProcess)){
			if(isWDDX(varToProcess)){
				StartString = "#chr(10)#<table bordercolor='black' border='1' cellspacing='0' cellpadding='1'>#chr(10)#";

				return StartString & "<tr>#chr(10)#<td>WDDX currently not displayable</td>#chr(10)#</tr>#chr(10)#" & EndString;
			}else{
				return varToProcess;
			}
		}else if(isArray(varToProcess)){
			StartString = "#chr(10)#<table bordercolor='##008000' border='1' cellspacing='0' cellpadding='1'>#chr(10)#";
			ObjSize = ArrayLen(varToProcess);

			for(LoopCount = 1;LoopCount LTE ObjSize;LoopCount = LoopCount + 1){
				StartString = StartString & "<tr>#chr(10)#<td bgcolor='##cceecc' valign='top'>#LoopCount#</td><td>#dumpVar(varToProcess[LoopCount])#</td>#chr(10)#</tr>#chr(10)#";
			}
			return StartString & EndString;
		}else if(isStruct(varToProcess)){
			StartString = "#chr(10)#<table bordercolor='blue' border='1' cellspacing='0' cellpadding='1'>#chr(10)#";

			for(key in varToProcess){
				StartString = StartString & "<tr>#chr(10)#<td bgcolor='##aaaaee' valign='top'>#key#</td>#chr(10)#<td>#dumpVar(varToProcess[key])#</td>#chr(10)#</tr>#chr(10)#";
			}
			return StartString & EndString;
		}else if(isQuery(varToProcess)){
			StartString = "#chr(10)#<table bordercolor='red' border='1' cellspacing='0' cellpadding='1'>#chr(10)#";
			ObjSize = varToProcess.recordCount;
			Keys = varToProcess.columnList;
			numOfColumns = ListLen(Keys);
			StartString = StartString & "<tr>#chr(10)#";

			for(count2 = 1;count2 LTE numOfColumns;count2 = count2 + 1){
				StartString = StartString & "<td bgcolor='##eeaaaa'>#listGetAt(Keys,count2)#</td>#chr(10)#";
			}
			StartString = StartString & "</tr>#chr(10)#";

			for(LoopCount = 1;LoopCount LTE ObjSize;LoopCount = LoopCount + 1){
				StartString = StartString & "<tr>#chr(10)#";
				for(count2 = 1;count2 LTE numOfColumns;count2 = count2 + 1){
					StartString = StartString & "<td>#varToProcess[listGetAt(Keys,count2)][loopCount]#</td>#chr(10)#";
				}
				StartString = StartString & "</tr>#chr(10)#";
			}
			return StartString & EndString;
		}else{
			return " ";
		}
}
</cfscript>

<!---
 Duplicates small to medium MySQL databases.

 @param datasource 	 DSN (Required)
 @param source 	 Source for duplication. (Required)
 @param target 	 Target for duplication. (Required)
 @param copyData 	 Boolean that determines if data along with structure. Defaults to false. (Optional)
 @return Returns nothing.
 @author Steve Good (steve@stevegood.org)
 @version 1, February 21, 2011
--->
<cffunction name="duplicateDB" access="public" returntype="void" output="false" hint="I duplicate a MySQL database locally on the same server.">
	<cfargument name="datasource" type="string" required="true" />
	<cfargument name="source" type="string" required="true" />
	<cfargument name="target" type="string" required="true" />
	<cfargument name="copyData" type="boolean" required="false" default="false" />

	<cfquery datasource="#arguments.datasource#">
	CREATE DATABASE  IF NOT EXISTS #arguments.target#;
	</cfquery>

	<cfdbinfo datasource="#arguments.datasource#" name="local.tbls" type="tables" />

	<cfloop query="local.tbls">
		<cfquery datasource="#arguments.datasource#">
		CREATE TABLE #arguments.target#.#table_name# LIKE #arguments.source#.#table_name#;
		</cfquery>

		<cfif arguments.copydata>
			<cfquery datasource="#arguments.datasource#">
			INSERT INTO #arguments.target#.#table_name# SELECT * FROM #arguments.source#.#table_name#;
			</cfquery>
		</cfif>
	</cfloop>
</cffunction>

<cfscript>
/**
 * Returns a value list from a dynamic column of a query.
 *
 * @param query 	 The query to examine. (Required)
 * @param col 	 The column to return values for. (Required)
 * @param delim 	 Delimiter. Defaults to comma. (Optional)
 * @return Returns a list.
 * @author Raymond Camden (ray@camdenfamily.com)
 * @version 1, August 14, 2002
 */
function DynamicValueList(query,col) {
	var delim = ",";
	if(arrayLen(arguments) gte 3) delim = arguments[3];
	return arrayToList(query[col],delim);
}
</cfscript>

<cfscript>
/**
 * Merge the contents of two or more structs together into the first struct.
 * v1.0 by Owen Knapp
 * v1.1 by Adam Cameron (simplified logic, making it CF9 compatible)
 *
 * @return A struct containing all the passed-in structs appended in turn
 * @author Owen Knapp (owen@letskillowen.com)
 * @version 1.1, September 12, 2013
 */
struct function extend() {
	var extended	= {};
	var arg			= "";

	for (arg in arguments){
		structAppend(extended, arguments[arg]);
	}

	return extended;
}
</cfscript>

<cfscript>
/**
 * Removes the element at index one and inserts a new element at the highest index plus one.
 *
 * @param array 	 Array to modify. (Required)
 * @param valueToAdd 	 Value to add. (Required)
 * @return Returns an array.
 * @author Adrian Lynch (adrian.l@thoughtbubble.net)
 * @version 1, May 13, 2003
 */
function FirstInFirstOut( array, valueToAdd ) {

	// Delete element at index 1
	ArrayDeleteAt( array, 1 );

	// Add new element at last index plus one
	array[ArrayLen( array ) + 1] = valueToAdd;

	return array;

}
</cfscript>

<!---
 Converts fixed width string to a ColdFusion query.
 Modified by Raymond Camden for missing var, and support newlines better.

 @param columnNames 	 A list of column names. (Required)
 @param widths 	 A corresponding list of widths. (Required)
 @param data 	 The data to parse. (Required)
 @param customRegex 	 A regular expression to be used to parse the line. (Optional)
 @return Returns a query.
 @author Umer Farooq (umer@octadyne.com)
 @version 1, December 20, 2007
--->
<cffunction name="fixedWidthToQuery" hint="I turn fixed width data to query">
	<cfargument name="columnNames" required="Yes" type="string">
	<cfargument name="widths" required="Yes" type="string">
	<cfargument name="data" required="Yes" type="string">
	<cfargument name="customRegex" required="No" type="string">
	<cfset var tempQuery = QueryNew(arguments.columnNames)>
	<cfset var regEx = "">
	<cfset var findResults = "">
	<cfset var i = "">
	<cfset var line = "">
	<cfset var x = "">

	<!--- build our regex --->
	<cfif NOT isDefined("arguments.customRegEx")>
		<cfloop list="#arguments.widths#" index="i">
			<cfset regex = regex & "(.{" & i & "})">
		</cfloop>
	<cfelse>
		<cfset regEx = arguments.customRegex>
	</cfif>

	<!--- fix newlines for different os --->
	<cfset arguments.data = replace(arguments.data,chr(10),chr(13),"all")>
	<cfset arguments.data = replace(arguments.data,chr(13)&chr(13),chr(13),"all")>

	<!--- loop the data --->
	<cfloop list="#arguments.data#" delimiters="#chr(13)#" index="line">
		<!--- run our regex --->
		<cfset findResults = refind(regEx, line, 1, true)>
		<!--- find our that our match records equals number of columns plus one. --->
		<cfif arrayLen(findResults.pos) eq listLen(arguments.columnNames)+1>
			<cfset QueryAddRow(tempQuery)>
			<!--- loop the find resuls array from postion 2...
			      and get the column name x-1 as our regex results are number of columsn plus 1
				  and load that data into the query  --->
			<cfloop from="2" to="#arrayLen(findResults.pos)#" index="x">
				<cfset QuerySetCell(tempQuery, listGetAt(arguments.columnNames, x-1), trim(mid(line, findResults.pos[x], findResults.len[x])))>
			</cfloop>
		</cfif>
	</cfloop>
	<cfreturn tempQuery>
</cffunction>

<!---
 Builds nested structs into a single struct.
 Updated v2 by author Simeon Cheeseman.

 @param stObject 	 Structure to flatten. (Required)
 @param delimiter 	 Value to use in new keys. Defaults to a period. (Optional)
 @param prefix 	 Value placed in front of flattened keys. Defaults to nothing. (Optional)
 @param stResult 	 Structure containing result. (Optional)
 @param addPrefix 	 Boolean value that determines if prefix should be used. Defaults to true. (Optional)
 @return Returns a structure.
 @author Tom de Manincor (tomdeman@gmail.com)
 @version 2, September 2, 2011
--->
<cffunction name="flattenStruct" access="public" output="false" returntype="struct">
	<cfargument name="original" type="struct" required="true"><!--- struct to flatten --->
    <cfargument name="delimiter" required="false" type="string" default="." />
	<cfargument name="flattened" type="struct" default="#StructNew()#" required="false"><!--- result struct, returned at the end --->
	<cfargument name="prefix_string" type="string" default="" required="false"><!--- used in the processing, stores the preceding struct names in the current branch, ends in a delimeter --->

	<!--- get this level's elements --->
	<cfset var names = StructKeyArray(original)>
	<cfset var name = "">

	<cfloop array="#names#" index="name">
		<!--- add name --->
		<cfif IsStruct(original[name])>
			<cfset flattened = flattenStruct(original[name], delimiter, flattened, prefix_string & name & delimiter)>
		<cfelse>
			<cfset flattened[prefix_string & name] = original[name]>
		</cfif>
	</cfloop>

	<cfreturn flattened>
</cffunction>

<cfscript>
/**
 * Converts form variables to query string.
 * Modified by RCamden
 *
 * @return Returns a string.
 * @author Billy Cravens (billy@architechx.com)
 * @version 1, June 26, 2002
 */
function form2qs() {
	var str = "";
	var field = "";
	for(key in form) {
		str = str & "&#key#=" & urlEncodedFormat(form[key]);
	}
	return str;
}
</cfscript>

<cfscript>
/**
 * Examine the contents of a BINARY file.
 *
 * @param BVar 	 Binary variable. (Required)
 * @param loc 	 Location in the binary file. (Required)
 * @return Returns a string.
 * @author John Bartlett (jbartlett@strangejourney.net)
 * @version 1, November 15, 2002
 */
function Get(BVar,loc) {
	if (isBinary(BVar) EQ "No") return 0;
	if (BVar[loc] GTE 0) return BVar[loc];
	return BVar[loc] + 256;
}
</cfscript>

<cfscript>
/**
 * Returns an array of all properties in cfc's metadata, inherited or not.
 * v2 was submitted by salvatore fusto
 * v3 ditto
 *
 * @param object 	 The metadata from a component. (Required)
 * @return Returns an array of structs.
 * @author Robby Lansaw (robby@ohsogooey.com)
 * @version 3, May 18, 2012
 */
function getComponentProps(object) {
       var propArray = arrayNew(1);
       if (structKeyExists(object,'properties')) {
               propArray = object.properties;
       }
       if (structKeyExists(object,'extends')) {
               propArray.addAll(getComponentProps(object.extends ));
       }
       return propArray;
}
</cfscript>

<!---
 Replicates the CF7 getMetadata(query) functionality for MX6.1+

 @param Query 	 ColdFusion query object to return metadata for (Required)
 @return Returns an array
 @author Marc Esher (marc.esher@gmail.com)
 @version 0, May 30, 2010
--->
<cffunction name="getQueryMetadata" access="public" returntype="array" hint="Replicates the CF7 getMetadata(query) functionality for MX6.1+">
		<cfargument name="query" type="query" required="true"/>
		<cfset var metadata = ArrayNew(1)>
		<cfset var columns = ArrayNew(1)>
		<cfset var col = 1>
		<cfset var map = StructNew()>
		<cfif listFirst(server.ColdFusion.ProductVersion) GT 6>
			<cfreturn getMetadata(arguments.query)>
		</cfif>

		<cfset columns = arguments.query.getMetaData().getColumnLabels() />

		<cfloop from="1" to="#ArrayLen(columns)#" index="col">
			<cfset map = StructNew()>
			<cfset map.name = columns[col]>
			<cfset map.IsCaseSensitive = arguments.query.getMetaData().isCaseSensitive( javacast("int",col))>
			<cfset map.TypeName = arguments.query.getMetadata().getColumnTypeName(javacast("int",col))>
			<cfset ArrayAppend(metadata,map)>
		</cfloop>

		<cfreturn metadata>
	</cffunction>

<!---
 Pass in an XML Node and attribute reference to receive the attribute's value.

 @param node 	 XML note to retrieve the attribute from. (Required)
 @param attribute 	 Attribute to retrieve. (Required)
 @param default 	 If attribute does not exist, return this default. (Optional)
 @return Returns a string.
 @author Kreig Zimmerman (kkz@foureyes.com)
 @version 1, December 23, 2002
--->
<cffunction name="GetXmlAttribute" output="false" returntype="any">
	<cfargument name="node" type="any" required="yes">
	<cfargument name="attribute" type="string" required="Yes">
	<cfargument name="default" type="string" default="" required="false">
	<cfset var myResult="#arguments.default#">
	<cfif StructKeyExists(node.XmlAttributes, attribute)>
		<cfset myResult=node.XmlAttributes["#attribute#"]>
	</cfif>
	<cfreturn myResult>
</cffunction>

<cfscript>
/**
 * Accepts a numeric GUID stored in a Byte Array and converts it to a string in the normal convention.
 *
 * @param guidByteArray 	 GUID Byte array returned from a query. (Required)
 * @return Returns a string.
 * @author Samuel Neff (sam@blinex.com)
 * @version 1, September 6, 2002
 */
function guidToString(guidByteArray) {
   var hexString='';

   if (IsArray(guidByteArray) AND ArrayLen(guidByteArray) GTE 16) {
     hexString=hexString & guidByteToHex(guidByteArray[4]);
     hexString=hexString & guidByteToHex(guidByteArray[3]);
     hexString=hexString & guidByteToHex(guidByteArray[2]);
     hexString=hexString & guidByteToHex(guidByteArray[1]);
     hexString=hexString & "-";
     hexString=hexString & guidByteToHex(guidByteArray[6]);
     hexString=hexString & guidByteToHex(guidByteArray[5]);
     hexString=hexString & "-";
     hexString=hexString & guidByteToHex(guidByteArray[8]);
     hexString=hexString & guidByteToHex(guidByteArray[7]);
     hexString=hexString & "-";
     hexString=hexString & guidByteToHex(guidByteArray[9]);
     hexString=hexString & guidByteToHex(guidByteArray[10]);
     hexString=hexString & "-";
     hexString=hexString & guidByteToHex(guidByteArray[11]);
     hexString=hexString & guidByteToHex(guidByteArray[12]);
     hexString=hexString & guidByteToHex(guidByteArray[13]);
     hexString=hexString & guidByteToHex(guidByteArray[14]);
     hexString=hexString & guidByteToHex(guidByteArray[15]);
     hexString=hexString & guidByteToHex(guidByteArray[16]);
   }

   return hexString;
}

function guidByteToHex(guidByte) {
   // Accepts a single byte and converts it to a two digit Hex number.

   var hexByte=Ucase(Right(FormatBaseN(guidByte, 16),2));
   if (Len(hexByte) IS 0) {
      hexByte='00';
   } else if (Len(hexByte) IS 1) {
      hexByte='0' & hexByte;
   }

   return hexByte;
}
</cfscript>

<cfscript>
/**
 * Tells you if a variable is an array of structs
 * version 0.9 by Jon Briccetti
 * version 1.0 by Adam Cameron (tidied logic, converted to script, removed some extraneous logic that didn't fit the function's stated purpose)
 *
 * @param object 	 The object to validate (Required)
 * @return Returns a boolean
 * @author Jon Briccetti (jbriccetti@gmail.com)
 * @version 1.0, December 19, 2012
 */
function isArrayOfStructs(object){
	if (!isArray(object)){
		return false;
	}
	for (var element in object){
		if (!isStruct(element)){
			return false;
		}
	}
	return true;
}
</cfscript>

<cfscript>
/**
 * Checks that a value is equal to 1 or 0.
 *
 * @param x 	 Value to check. (Required)
 * @return Returns a boolean.
 * @author Mike Tangorre (mtangorre@cfcoder.com)
 * @version 1, February 14, 2006
 */
function isBit(x){
   if(isSimpleValue(x) and len(x) eq 1 and (x eq 0 or x eq 1))
      return true;
   else
      return false;
}
</cfscript>

<!---
 Return true if the queryname passed was a cached query.

 @param queryname 	 Name of query to check. (Required)
 @return Returns a boolean.
 @author Qasim Rasheed (qasimrasheed@hotmail.com)
 @version 1, February 11, 2005
--->
<cffunction name="isCachedQuery" returntype="boolean" output="false">
	<cfargument name="queryname" required="true" type="string" />

	<cfset var events = "">
	<cfset var result = false>
	<cfset var temp = "">

	<cfif isdebugmode()>
		<cfset events = createobject('java','coldfusion.server.ServiceFactory').getDebuggingService().getDebugger().getData()>
		<cfquery name="temp" dbtype="query">
			select	cachedquery
			from	events
			WHERE 	type='SqlQuery'
					and name='#arguments.queryname#'
		</cfquery>
		<cfset result = yesnoformat(temp.cachedquery)>
	</cfif>

	<cfreturn result />
</cffunction>

<cfscript>
/**
 * Returns a boolean for whether a CF variable is a CFC instance.
 *
 * @param objectToCheck 	 The object to check. (Required)
 * @return Returns a boolean.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 1, October 16, 2002
 */
function IsCFC(objectToCheck){
	//get the meta data of the object we're inspecting
	var metaData = getMetaData(arguments.objectToCheck);
	//if it's an object, let's try getting the meta Data
	if(isObject(arguments.objectToCheck)){
		//if it has a type, and that type is "component", then it's a component
		if(structKeyExists(metaData,"type") AND metaData.type is "component"){
			return true;
		}
	}
	//if we've gotten here, it must not have been a contentObject
	return false;
}
</cfscript>

<cfscript>
/**
 * Checks if a given variable is a specific CFC type
 *
 * @param objectToCheck 	 CFC instance to check. (Required)
 * @param type 	 String name of CFC. (Required)
 * @param checkFullName 	 Boolean specifying if type should only match for the full name of the CFC. Defaults to false. If any value is passed, checkFullname is true. (Optional)
 * @return Returns a boolean.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 1, December 23, 2002
 */
function isCFCType(objectToCheck,type){
	//get the meta data of the object we're inspecting (we use duplicate so we don't mess with the instance)
	var metaData = getMetaData(arguments.objectToCheck);
	//are we going to check for a full name, or just the end?
	var checkFullName = true;
	//which component are we checking? (used to allow traversing the "extends" for extended components)
	var metaToCheck = metaData;
	//which name shall we check?
	var nameToCheck = metaData.name;
	//if the arguments.type has no periods, don't check the full name
	if(listLen(arguments.type,".") LTE 1)
		checkFullName = false;
	//allow a third argument to force the checkFullName
	if(structCount(arguments) GT 2)
		checkFullName = arguments[3];
	//if it's an object, see if it's the right kind of component
	if(isObject(arguments.objectToCheck)){
		//if it has a type, and that type is "component", then it's a component, so we then look at the type
		if(structKeyExists(metaData,"type") AND metaData.type is "component"){
			//do a while loop to be sure we see if this component extends the type we want
			while(structKeyExists(metaToCheck,"extends")){
				//if we are not checking the full name, then take only the last element in the full name
				if(NOT checkFullName)
					nameToCheck = listLast(metaToCheck.name,".");
				else
					nameToCheck = metaToCheck.name;
				//if the name of the component we're looking at is the type we're looking for, return true
				if(nameToCheck is arguments.type)
					return true;
				//set this to the extends of the current component to traverse the meta data tree
				metaToCheck = metaToCheck.extends;
			}
		}
	}
	//if we've gotten here, it must not have been a the right kind of object
	return false;
}
</cfscript>

<cfscript>
/**
 * Checks that a variable is defined and  that the variable  is not an empty value.  Optionally lets you check that the variable is a specific value.
 * See also: isEmpty() -- http://cflib.org/udf.cfm?id=420
 *
 * @param varname 	 Name of the variable to check for (Required)
 * @param value 	 The value a simple variable should be to pass the test (optional) (Optional)
 * @return boolean - 1 or 0
 * @author Joseph Flanigan (joseph@switch-box.org)
 * @version 1, October 30, 2013
 */
function isDefinedValue(varname)
{
  var value = "";
    if (IsDefined(listfirst(Arguments[1],"[")))
     {
     value = evaluate(Arguments[1]);
     if (IsSimpleValue(value))
        {
            if (ArrayLen(Arguments) EQ 2 )
                { if ( value EQ Arguments[2]){return 1;}
                else return 0;
                }
            else if ( find(value,"" )) {return 0;}
            else return 1;  // something is there, just not testing for it.
        }
     else if (IsStruct(value))
        {
            if (StructIsEmpty(value)) { return 0;}
            else {return 1;}
        }
     else if (IsArray(value))
        {
            if (ArrayIsEmpty(value)) {return 0;}
            else {return 1;}
        }
     else if (IsQuery(value))
        {
            if (YesNoFormat(value.recordcount)) {return 1;}
            else {return 0;}
        }
    return 0;
      }
return 0;
}
</cfscript>

<cfscript>
/**
 * Checks that a variable exists and has value. CFMX version.
 *
 * @param varname 	 The name of the variable to test for (Required)
 * @param value 	 The value a simple variable should be to pass the test (optional) (Optional)
 * @return 1 (yes, it is defined) or 0 (no, it is not defined)
 * @author Joseph Flanigan (joseph@switch-box.org)
 * @version 1, October 20, 2003
 */
function isDefinedValueMX(varname)
{
  var varvalue = "";
    try{
    if (IsDefined(listfirst(Arguments[1],"[")))
     {
     varvalue = evaluate(Arguments[1]);

     if (IsSimpleValue(varvalue))
        {
            if (ArrayLen(Arguments) EQ 2 )
                { if ( varvalue EQ Arguments[2]){return 1;}
                else return 0;
                }
            else if ( find(varvalue,"" )) {return 0;}
            else return 1;  // something is there, just not testing for it.
        }
     else if (IsStruct(varvalue))
        {
            if (StructIsEmpty(varvalue)) { return 0;}
            else {return 1;}
        }
     else if (IsArray(varvalue))
        {
            if (ArrayIsEmpty(varvalue)) {return 0;}
            else {return 1;}
        }
     else if (IsQuery(varvalue))
        {
            if (YesNoFormat(varvalue.recordcount)) {return 1;}
            else {return 0;}
        }
    return 0; // not defined
      }
     } //try
     catch(Any excpt)
      { return 0;} // return excpt.Message;
return 0;
}
</cfscript>

<cfscript>
/**
 * Check if a variable is set and has a value.
 * Mods by RCamden to add support for struct/query
 *
 * @param varName 	 Variable to check for. (Required)
 * @return Returns a boolean.
 * @author Fabio Serra (faser@faser.net)
 * @version 1, July 10, 2003
 */
function isEmpty(varName) {
	var ptr = "";

	if(not isDefined(varName)) return true;
	ptr = evaluate(varName);

	if(isSimpleValue(ptr)) {
		if(not len(ptr)) return true;
	} else if(isArray(ptr)) {
		if(arrayIsEmpty(ptr)) return true;
	} else if(isStruct(ptr)) {
		if(structIsEmpty(ptr)) return true;
	} else if(isQuery(ptr)) {
		if(not ptr.recordCount) return true;
	}

	return false;
}
</cfscript>


<cfscript>
/**
 * Returns true if all positions in an array are defined.
 *
 * @param arr 	 The array to check. (Required)
 * @return Returns a boolean.
 * @author Raymond Camden (ray@camdenfamily.com)
 * @version 1, April 29, 2002
 */
function IsSafeArray(arr) {
	var i=1;
	var temp = "";

	for(i=1; i lte arrayLen(arr); i=i+1) {
		try {
			temp = arr[i];
		} catch(coldfusion.runtime.UndefinedElementException ex) {
			return false;
		}
	}

	return true;
}
</cfscript>

<!---
 Checks to see if a string is valid XML.

 @param data 	 String to check. (Required)
 @return Returns a boolean.
 @author Ben Forta (ben@forta.com)
 @version 1, August 28, 2003
--->
<cffunction name="isXML" returnType="boolean" output="no">
   <cfargument name="data" type="string" required="yes">

   <!--- try catch block --->
   <cftry>
      <!--- try to parse the data as xml --->
      <cfset xmlparse(data)>
      <!--- if xmlparse() fails, it is not xml --->
      <cfcatch type="any">
         <cfreturn false>
      </cfcatch>
   </cftry>

   <cfreturn true>

</cffunction>

<cfscript>
/**
 * Computes the length of every key in the passed structure and returns a structure with unique key names of the lengths.
 *
 * @param structIn 	 The struct to check. (Required)
 * @param excludeList 	 List of keys to ignore. (Optional)
 * @param ending 	 String to append to key names in resulting struct. (Optional)
 * @return Returns a struct.
 * @author Peter J. Farrell (pjf@maestropublishing.com)
 * @version 1, October 5, 2004
 */
function LenStruct(structIn) {
	var i = 0;
	var structIn_count = StructCount(structIn);
	var struct0ut = StructNew();
	var ending = "_Len";
	var excludeList = "";
	var key = "";

	// Check if excludeList was passed
	if(arrayLen(Arguments) GT 1) {
		excludeList = Arguments[2];
	}

	// Check if different ending was passed
	if(arrayLen(Arguments) GT 2) {
		ending = Arguments[3];
	}
	for (key IN structIn) {
		if (NOT listFindNoCase(excludeList,key) AND isSimpleValue(structIn[key])) {
			structOut[key&ending] = Len(structIn[key]);
		}
	}
	return structOut;
}
</cfscript>

<cfscript>
/**
 * UDF to loop over a list
 * v1.0 by Adam Cameron
 *
 * @param list 	 A list to iterate over (Required)
 * @param callback 	 A callback to call for each element of the list (Required)
 * @param delimiters 	 The delimiters the list uses. Defaults to a comma (Optional)
 * @return An array containing the returned values from each callback call
 * @author Adam Cameron (dac.cfml@gmail.com)
 * @version 1.0, October 17, 2013
 */
public array function listEach(required string list, required function callback, string delimiters=","){
	var arr = listToArray(list, delimiters);
	var arrLen = arrayLen(arr);
	var result = [];
	for (var index=1; index <= arrLen; index++){
		arrayAppend(result, callBack(argumentCollection=arguments, index=index, element=arr[index], length=arrLen));
	}
	return result;
}
</cfscript>

<!---
 Converts a list to a single-column query.

 @param list 	 List of items. (Required)
 @param delimiters 	 List delimiters. Defaults to a comma. (Optional)
 @param column_name 	 Name to use for column. Defaults to column. (Optional)
 @return Returns a query.
 @author Russ Spivey (russellspivey@gmail.com)
 @version 0, September 9, 2009
--->
<cffunction name="listToQuery" access="public" returntype="query" output="false"
	hint="Converts a list to a single-column query.">
    <cfargument name="list" type="string" required="yes" hint="List to convert.">
    <cfargument name="delimiters" type="string" required="no" default="," hint="Things that separate list elements.">
    <cfargument name="column_name" type="string" required="no" default="column" hint="Name to give query column.">

    <cfset var query = queryNew(arguments.column_name)>
    <cfset var index = ''>

    <cfloop list="#arguments.list#" index="index" delimiters="#arguments.delimiters#">
        <cfset queryAddRow(query)>
        <cfset querySetCell(query,arguments.column_name,index)>
    </cfloop>

    <cfreturn query>
</cffunction>

<cfscript>
/**
 * Converts a delimited list of key/value pairs to a structure.
 * v2 mod by James Moberg
 *
 * @param list 	 List of key/value pairs to initialize the structure with.  Format follows key=value. (Required)
 * @param delimiter 	 Delimiter seperating the key/value pairs.  Default is the comma. (Optional)
 * @return Returns a structure.
 * @author Rob Brooks-Bilson (rbils@amkor.com)
 * @version 2, April 1, 2010
 */
function listToStruct(list){
       var myStruct = StructNew();
       var i = 0;
       var delimiter = ",";
       var tempList = arrayNew(1);
       if (ArrayLen(arguments) gt 1) {delimiter = arguments[2];}
       tempList = listToArray(list, delimiter);
       for (i=1; i LTE ArrayLen(tempList); i=i+1){
               if (not structkeyexists(myStruct, trim(ListFirst(tempList[i], "=")))) {
                       StructInsert(myStruct, trim(ListFirst(tempList[i], "=")), trim(ListLast(tempList[i], "=")));
               }
       }
       return myStruct;
}
</cfscript>

<cfscript>
/**
 * Based on ListToStruct() from Rob Brooks-Bilson, this one allows the structure key to be repeated and the value added to a list.
 * Version 2 - Ray modified the code a bit and fixed a missing var.
 *
 * @param list 	 List of key and value pairs. (Required)
 * @param delimiter 	 List delimiter. Defaults to a comma. (Optional)
 * @return Returns a struct.
 * @author Tony Brandner (tony@brandners.com)
 * @version 2, August 3, 2005
 */
function listToStructRepeatKeys(list){
  var myStruct=StructNew();
  var i=0;
  var delimiter=",";
  var tempVar="";

  if(arrayLen(arguments) gt 1) delimiter = arguments[2];

  for(i=listLen(list, delimiter); i gt 0; i=i-1) {
  	tempVar = trim(listGetAt(list, i, delimiter));
  	if (structKeyExists(myStruct,listFirst(tempVar, "="))) {
		myStruct[listFirst(tempVar, "=")] = listAppend(myStruct[listFirst(tempVar, "=")],listLast(tempVar, "="));
	} else {
		myStruct[listFirst(tempVar, "=")] = listLast(tempVar, "=");
	}
  }
  return myStruct;
}
</cfscript>

<cfscript>
/**
 * This function is a UDF for maketree custom tag developed by Michael Dinowitz.
 *
 * @param query 	 Query to be sorted. (Required)
 * @param unique 	 Name of the column containing the primary key. (Required)
 * @param parent 	 Name of the column containing the parent. (Required)
 * @return Returns a query.
 * @author Qasim Rasheed (qasimrasheed@hotmail.com)
 * @version 1, February 17, 2005
 */
function maketree( query, unique, parent ){
	var current = 0;
	var path = 0;
	var i = 0;
	var j = 0;
	var items = "";
	var parents = "";
	var position = "";
	var column = "";
	var retQuery = querynew( query.columnlist & ',sortlevel' );
	for (i=1;i lte query.recordcount;i=i+1)
		items = listappend( items, query[unique][i] );
	for (i=1;i lte query.recordcount;i=i+1)
		parents = listappend( parents, query[parent][i] );

	for (i=1;i lte query.recordcount;i=i+1){
		queryaddrow( retQuery );
		position = listfind( parents, current );
		while (not position){
			path= listrest( path );
			current = listfirst( path );
			position = listfind( parents, current );
		}
		for (j=1;j lte listlen( query.columnlist ); j=j+1){
			column = listgetat( query.columnlist, j );
			querysetcell( retQuery, column, evaluate( 'query.'&column&'[position]') );
		}
		querysetcell( retQuery, 'sortlevel', listlen( path ) );
		current = listgetat( items, position );
		parents = listsetat( parents, position, '-' );
		path = listprepend( path, current);
	}
	return retQuery;
}
</cfscript>

<cfscript>
/**
 * Simulate the c functionality of --i.
 *
 * @param intCounter 	 The name, not the value, of the variable to be decremented.
 * @return Returns the value of the variable after it has been decremented.
 * @author Stephan Scheele (stephan@stephan-t-scheele.de)
 * @version 1, April 17, 2002
 */
function minusMinusCounter(intCounter){
	"#intCounter#" = evaluate(intCounter) - 1;
	return evaluate(intCounter);
}
</cfscript>

<cfscript>
/**
 * Initialize an empty query with default values.
 *
 * @param q 	 Query. (Required)
 * @param Fields 	 Fields to use. (Required)
 * @param Values 	 Values to use. (Required)
 * @return Returns a query.
 * @author John Bartlett (jbartlett@strangejourney.net)
 * @version 1, August 10, 2007
 */
function nullQuery(q,Fields,Values) {
	var i=0;
	var NewQ=QueryNew(Replace(Fields,"|",",","ALL"));
	if (q.RecordCount GT 0) return q;
	QueryAddRow(NewQ);
	for(i=1; i LTE ListLen(Fields,'|'); i=i+1) {
		querySetCell(NewQ,ListGetAt(Fields,i,'|'),ListGetAt(Values,i,'|'));
	}
	return NewQ;
}
</cfscript>

<cfscript>
/**
 * Simulate the c functionality of ++i.
 *
 * @param intCounter 	 The name, not the value, of the variable to be incremented.
 * @return Returns the value of the variable after it has been incremented.
 * @author Stephan Scheele (stephan@stephan-t-scheele.de)
 * @version 1, April 17, 2002
 */
function plusPlusCounter(intCounter) {
	"#intCounter#" = evaluate(intCounter) + 1;
	return evaluate(intCounter);
}
</cfscript>

<cfscript>
/**
 * Converts a query to excel-ready format.
 * Version 2 by Andrew Tyrone. It now returns a string instead of directly outputting.
 *
 * @param query 	 The query to use. (Required)
 * @param headers 	 A list of headers. Defaults to col. (Optional)
 * @param cols 	 The columns of the query. Defaults to all columns. (Optional)
 * @param alternateColor 	 The color to use for every other row. Defaults to white. (Optional)
 * @return Returns a string.
 * @author Jesse Monson (jesse@ixstudios.com)
 * @version 2, February 23, 2005
 */
function Query2Excel(query) {
	var InputColumnList = query.columnList;
	var Headers = query.columnList;

	var AlternateColor = "FFFFFF";
	var header = "";
	var headerLen = 0;
	var col = "";
	var colValue = "";
	var colLen = 0;
	var i = 1;
	var j = 1;
	var k = 1;

	var HTMLData = "";

	if (arrayLen(arguments) gte 2) {
		Headers = arguments[2];
	}
	if (arrayLen(arguments) gte 3) {
		InputColumnList = arguments[3];
	}

	if (arrayLen(arguments) gte 4) {
		AlternateColor = arguments[4];
	}
	if (listLen(InputColumnList) neq listLen(Headers)) {
		return "Input Column list and Header list are not of equal length";
	}

	HTMLData = HTMLData & "<table border=1><tr bgcolor=""C0C0C0"">";
	for (i=1;i lte ListLen(Headers);i=i+1){
		header=listGetAt(Headers,i);
		headerLen=Len(header)*10;
		HTMLData = HTMLData & "<th width=""#headerLen#""><b>#header#</b></th>";
	}
	HTMLData = HTMLData & "</tr>";
	for (j=1;j lte query.recordcount;j=j+1){
		if (j mod 2) {
			HTMLData = HTMLData & "<tr bgcolor=""FFFFFF"">";
		} else {
			HTMLData = HTMLData & "<tr bgcolor=""#alternatecolor#"">";
		}
		for (k=1;k lte ListLen(InputColumnList);k=k+1) {
			col=ListGetAt(InputColumnList,k);
			colValue=query[trim(col)][j];
			colLength=Len(colValue)*10;
			if (NOT Len(colValue)) {
				colValue="&nbsp;";
			}
			if (isNumeric(colValue) and Len(colValue) gt 10) {
				colValue="'#colValue#";
			}
			HTMLData = HTMLData & "<td width=""#colLength#"">#colValue#</td>";
		}
	HTMLData = HTMLData & "</tr>";
	}
	HTMLData = HTMLData & "</table>";

	return HTMLData;
}
</cfscript>

<!---
 Adds a column filled with a value to a query object.
 V2 by Raymond Camden
 v3 by author

 @param query 	 Query to manipulate. (Required)
 @param column_name 	 Name of new column. (Required)
 @param value 	 Value to use. Defaults to nothing. (Optional)
 @return Returns a boolean.
 @author Gabriele Bernuzzi (gabriele.bernuzzi@gruppotesi.com)
 @version 3, December 13, 2005
--->
<cffunction name="queryAddColumnWithValue" returntype="boolean" output="false">
	<cfargument name="query" type="query" required="true" />
	<cfargument name="column_name" type="string" required="true" />
	<cfargument name="value" type="string" required="false" default="" />
	<cfset var arr=arrayNew(1) />

	<cfscript>
		arraySet(arr,1,arguments.query.recordCount,arguments.value);
		queryAddColumn(arguments.query, arguments.column_name, arr);
	</cfscript>

	<cfreturn true>
</cffunction>

<cfscript>
/**
 * Converts a Java QueryBean object to a ColdFusion query object.
 *
 * @param objQueryBean 	 A Java QueryBean object. (Required)
 * @return Returns a query.
 * @author Alistair Davidson (alistair_davidson@hotmail.com)
 * @version 1, May 20, 2005
 */
function queryBeanToQuery(objQueryBean) {
	var qry_return = "";
	var arrColumns = ArrayNew(1);
	var arrRows = arrayNew(1);
	var thisRow = 0;
	var thisCol = 0;
	var numRows = 0;
	var thisVal = "";

	if( objQueryBean.getClass() EQ "class coldfusion.xml.rpc.QueryBean" ){
		arrColumns = objQueryBean.getColumnList();
		numCols = arrayLen( arrColumns );
		arrRows = objQueryBean.getData();
		numRows = arrayLen( arrRows );
		// create the return query object
		qry_return = QueryNew( ArrayToList(arrColumns) );
		// loop round each row
		for( thisRow = 1; thisRow LTE numRows; thisRow = thisRow + 1 ){
			QueryAddRow( qry_return );
			// loop round each column
			for( thisCol = 1; thisCol LTE numCols; thisCol = thisCol + 1 ){
				// empty columns seem to give rise to undefined array elements!
				try{
					thisVal = arrRows[thisRow][thisCol];
				}
				catch(Any e) {
					thisVal = "";
				}
				QuerySetCell( qry_return, arrColumns[thisCol], thisVal );
			}
		}
		return qry_return;

	} else return queryNew("");
}
</cfscript>

<cfscript>
/**
 * Returns query column list.
 *
 * @param dbquery 	 Query to examine. (Required)
 * @return Returns a list.
 * @author John Bartlett (jbartlett@strangejourney.net)
 * @version 1, March 17, 2006
 */
function queryColumns(dbquery) {
	var queryFields = "";
	var metadata = dbquery.getMetadata();
	var i = 0;
	var col = "";

	for (i = 1; i lte metadata.getColumnCount(); i = i+1) {
		col = metadata.getColumnLabel(javaCast("int", i));
		queryFields = listAppend(queryFields,col);
	}

	return queryFields;
}
</cfscript>

<cfscript>
/**
 * Makes a struct for all values in a given column(s) of a query.
 * v2 by James Moberg
 *
 * @param query 	 The query to operate on (Required)
 * @param keyColumn 	 The name of the column to use for the key in the struct (Required)
 * @param valueColumn 	 The name of the column in the query to use for the values in the struct (defaults to whatever the keyColumn is) (Optional)
 * @param reverse 	 Boolean value for whether to go through the query in reverse (default is false) (Optional)
 * @param retainSort 	 If true, a Java LinkedHashMap will be used to create the result. This will create a struct with ordered keys. Defaults to false. (Optional)
 * @return struct
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 2, January 24, 2011
 */
function queryColumnsToStruct(query,keyColumn){
       var valueColumn = keyColumn;
       var reverse = false;
       var retainSort = false;
       var struct = structNew();
       var increment = 1;
       var ii = 1;
       var rowsGotten = 0;
       if(arrayLen(arguments) GT 2) valueColumn = arguments[3];
       if(arrayLen(arguments) GT 3) reverse = arguments[4];
       if(arrayLen(arguments) GT 4) retainSort = arguments[5];
       if(retainSort){
               struct = CreateObject("java", "java.util.LinkedHashMap").init();
       }
       if(reverse){
               ii = query.recordCount;
               increment = -1;
       }
       while(rowsGotten LT query.recordCount){
               struct[query[keyColumn][ii]] = query[valueColumn][ii];
               ii = ii + increment;
               rowsGotten = rowsGotten + 1;
       }
       return struct;
}
</cfscript>

<cfscript>
/**
 * Takes a selected column of data from a query and converts it into an array.
 *
 * @param query 	 The query to scan. (Required)
 * @param column 	 The name of the column to return data from. (Required)
 * @return Returns an array.
 * @author Peter J. Farrell (pjf@maestropublishing.com)
 * @version 1, July 22, 2005
 */
function queryColumnToArray(qry, column) {
	var arr = arrayNew(1);
	var ii = "";
	var loop_len = arguments.qry.recordcount;
	for (ii=1; ii lte loop_len; ii=ii+1) {
		arrayAppend(arr, arguments.qry[arguments.column][ii]);
	}
	return arr;
}
</cfscript>

<cfscript>
/**
 * Returns a list of query column data types.
 *
 * @param dbquery 	 Query to analyze. (Required)
 * @return Returns a list.
 * @author John Bartlett (jbartlett@strangejourney.net)
 * @version 1, April 11, 2006
 */
function queryColumnTypes(dbquery) {
	var columnTypes="";
	var metadata=dbquery.getMetadata();
	var i=0;
	var column="";

	for (i=1; i lte metadata.getColumnCount(); i=i+1) {
		column = metadata.getColumnLabel(javaCast("int",i));
		columnTypes = listAppend(columnTypes,dbquery.getColumnTypeName(metadata.getColumnType(dbquery.findColumn(column))));
	}

	return columnTypes;
}
</cfscript>

<!---
 This function will compare two queries and returns a struct which shows the difference between two queries if any.
 Fix by Rob Schimp

 @param query1 	 First query. (Required)
 @param query2 	 Second query. (Required)
 @return Returns a struct.
 @author Qasim Rasheed (qasimrasheed@hotmail.com)
 @version 2, November 4, 2005
--->
<cffunction name="queryCompare" returntype="struct" output="false">
	<cfargument name="query1" type="query" required="true" />
	<cfargument name="query2" type="query" required="true" />

	<cfset var rStruct = StructNew()>
	<cfset var q1 = arguments.query1>
	<cfset var q2 = arguments.query2>
	<cfset var q3 = QueryNew( q1.columnlist )>
	<cfset var q4 = QueryNew( q2.columnlist )>
	<cfset var message = "">
	<cfset var rowch = false>
	<cfset var colArray = listtoarray(q1.columnlist)>
	<cfset var thisCol = "">
	<cfset var count = 1>
	<cfset var i = "">
	<cfset var j = "">

	<cfloop from="1" to="#listlen(q1.columnlist)#" index="thisCol">
		<cfif listfindnocase(q2.columnlist,listgetat(q1.columnlist,thisCol)) eq 0>
			<cfset message = "Columns in query1 (#q1.columnlist#) and query2 (#q2.columnlist#) doesn't match">
		</cfif>
	</cfloop>
	<cfif not len(trim(message))>
		<cfloop from="1" to="#listlen(q2.columnlist)#" index="thisCol">
			<cfif listfindnocase(q1.columnlist,listgetat(q2.columnlist,thisCol)) eq 0>
				<cfset message = "Columns in query1 (#q1.columnlist#) and query2 (#q2.columnlist#) doesn't match">
			</cfif>
		</cfloop>
	</cfif>

	<cfif not len(trim(message))>
		<cfloop from="1" to="#q1.recordcount#" index="i">
			<cfset rowch = false>
			<cfloop from="1" to="#arraylen(colArray)#" index="j">
				<cfif comparenocase(q1[colArray[j]][i],q2[colArray[j]][i])>
					<cfset rowch = true>
				</cfif>
			</cfloop>
			<cfif rowch>
				<cfset queryaddrow(q3)>
				<cfloop from="1" to="#arraylen(colArray)#" index="k">
					<cfset querysetcell( q3, colArray[k], q1[colArray[k]][count] )>
				</cfloop>
			</cfif>
			<cfset count = count + 1>
		</cfloop>
		<cfset count = 1>
		<cfloop from="1" to="#q2.recordcount#" index="i">
			<cfset rowch = false>
			<cfloop from="1" to="#arraylen(colArray)#" index="j">
				<cfif comparenocase(q1[colArray[j]][i],q2[colArray[j]][i])>
					<cfset rowch = true>
				</cfif>
			</cfloop>
			<cfif rowch>
				<cfset queryaddrow(q4)>
				<cfloop from="1" to="#arraylen(colArray)#" index="k">
					<cfset querysetcell( q4, colArray[k], q2[colArray[k]][count] )>
				</cfloop>
			</cfif>
			<cfset count = count + 1>
		</cfloop>
		<cfif q4.recordcount OR q3.recordcount>
			<cfset message = "Records do not match">
		</cfif>
	</cfif>
	<cfif len(trim(message))>
		<cfset structinsert(rStruct,"message",message)>
		<cfset structinsert(rStruct,"in_query1_butnotin_query2",q3)>
		<cfset structinsert(rStruct,"in_query2_butnotin_query1",q4)>
	<cfelse>
		<cfset structinsert(rStruct,"message","Query 1 and Query 2 are identical")>
	</cfif>
	<cfreturn rStruct />
</cffunction>

<cfscript>
/**
 * Concatenate two queries together.
 *
 * @param q1 	 First query. (Optional)
 * @param q2 	 Second query. (Optional)
 * @return Returns a query.
 * @author Chris Dary (umbrae@gmail.com)
 * @version 1, February 23, 2006
 */
function queryConcat(q1,q2) {
	var row = "";
	var col = "";

	if(q1.columnList NEQ q2.columnList) {
		return q1;
	}

	for(row=1; row LTE q2.recordCount; row=row+1) {
	 queryAddRow(q1);
	 for(col=1; col LTE listLen(q1.columnList); col=col+1)
		querySetCell(q1,ListGetAt(q1.columnList,col), q2[ListGetAt(q1.columnList,col)][row]);
	}
	return q1;
}
</cfscript>

<cfscript>
/**
 * Creates a data structure that can be easily used by jqGrid.
 *
 * @param q 	 The query to be paginated (Required)
 * @param page 	 The page number to be returned (Required)
 * @param pageSize 	 The number of items per page (Required)
 * @return Returns a structure with the following keys {page, records, rows[], total}
 * @author Scott Stroz (scott@boyzoid.com)
 * @version 0, March 24, 2011
 */
function queryConvertForjQGrid( q, page, pageSize ){
	/*
	NOTE: In order for jqGrid to be able to use the result of this function
	you MUST add this to you jqGrid config:
	jsonReader : {
			repeatitems: false,
			id: "{id}}"
		},
	Where {id} is the unique identifier for each row in the query object.
	*/
	var ret = {};
	var row = {};
	var cols = listToArray( q.columnList );
	var col = "";
	var i = 0;
	var end = arguments.page * arguments.pageSize;
	var start = end - (arguments.pagesize - 1);
	ret[ "total" ] = 0;
	ret[ "page" ] = arguments.page;
	ret[ "records" ] = arguments.q.recordcount;
	if( q.recordCount ){
		ret[ "total" ] = ceiling( arguments.q.recordcount / arguments.pageSize );
	}
	ret["rows"] = [];
	for( i=start; i LTE min(q.recordCount, end); i++ ){
		structClear( row );
		for(col in cols){
			if(isDate( q[ col ][ i ] ) ){
				row[ lcase( col ) ] = dateFormat( q[ col ][ i ], "yyyy-dd-mm" ) & " " & timeFormat( q[ col ][ i ], "HH:mm:ss" );
			}
			else{
				row[ lcase( col )] = q[ col ][ i ];
			}
		}
		arrayAppend( ret[ "rows" ], duplicate( row ) );
	}
	return ret;
}
</cfscript>

<cfscript>
/**
 * Removes duplicate rows from a query based on a key column.
 * Modded by Ray Camden to remove evaluate
 *
 * @param theQuery 	 The query to dedupe. (Required)
 * @param keyColumn 	 Column name to check for duplicates. (Required)
 * @return Returns a query.
 * @author Matthew Fusfield (matt@fus.net)
 * @version 1, December 19, 2008
 */
function QueryDeDupe(theQuery,keyColumn) {
	var checkList='';
	var newResult=QueryNew(theQuery.ColumnList);
	var keyvalue='';
	var q = 1;
	var x = "";

	// loop through each row of the source query
	for (;q LTE theQuery.RecordCount;q=q+1) {

		keyvalue = theQuery[keycolumn][q];
		// see if the primary key value has already been used
		if (NOT ListFind(checkList,keyvalue)) {

			/* this is not a duplicate, so add it to the list and copy
			   the row to the destination query */
			checkList=ListAppend(checklist,keyvalue);
			QueryAddRow(NewResult);

			// copy all columns from source to destination for this row
			for (x=1;x LTE ListLen(theQuery.ColumnList);x=x+1) {
				QuerySetCell(NewResult,ListGetAt(theQuery.ColumnList,x),theQuery[ListGetAt(theQuery.ColumnList,x)][q]);
			}
		}
	}
	return NewResult;
}
</cfscript>

<cfscript>
/**
 * Removes rows from a query.
 * Added var col = "";
 * No longer using Evaluate. Function is MUCH smaller now.
 *
 * @param Query 	 Query to be modified
 * @param Rows 	 Either a number or a list of numbers
 * @return This function returns a query.
 * @author Raymond Camden (ray@camdenfamily.com)
 * @version 2, October 11, 2001
 */
function QueryDeleteRows(Query,Rows) {
	var tmp = QueryNew(Query.ColumnList);
	var i = 1;
	var x = 1;

	for(i=1;i lte Query.recordCount; i=i+1) {
		if(not ListFind(Rows,i)) {
			QueryAddRow(tmp,1);
			for(x=1;x lte ListLen(tmp.ColumnList);x=x+1) {
				QuerySetCell(tmp, ListGetAt(tmp.ColumnList,x), query[ListGetAt(tmp.ColumnList,x)][i]);
			}
		}
	}
	return tmp;
}
</cfscript>

<cfscript>
/**
 * Returns information about the differences between 2 queries with the same columns.
 *
 * @param q1 	 The first query. (Required)
 * @param q2 	 The second query. (Required)
 * @return Returns a structure.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 1, May 26, 2003
 */
function queryDiff(q1,q2){
	//vars for looping
	var ii = 0;
	var cc = 0;
	//a struct to hold the result
	var result = structNew();
	//grab the columns -- NOTE: THIS VERSION ASSUMES THEY HAVE THE SAME COLUMNS!!
	var cols = listToArray(q1.columnList);
	var thisCol = "";
	//we'll loop whichever query is shortest.  by default, we'll loop query1
	var shorterQuery = q1;
	var longerQuery = q2;
	var keyToUseForLonger = "added";
	var sameSize = true;
	var rowDiff = 0;
	//vars to use in the loop
	var q1Value = "";
	var q2Value = "";
	var thenNow = structNew();
	//make the standard keys in the result
	result.changed = structNew();
	result.added = structNew();
	result.removed = structNew();
	result.query1 = q1;
	result.query2 = q2;
	//if the queries are not the same size, indicate that
	if(q1.recordCount NEQ q2.recordCount){
		sameSize = false;
		//if q2 is shorter, use that instead
		if(q1.recordCount GT q2.recordCount){
			shorterQuery = q2;
			longerQuery = q1;
			keyToUseForLonger = "removed";
		}
	}
	//loop the correct query to get rows that are different in Q2 from Q1
	for(ii = 1; ii LTE shorterQuery.recordCount; ii = ii + 1){
		for(cc = 1; cc LTE arrayLen(cols); cc = cc + 1){
			thisCol = cols[cc];
			q1Value = q1[thisCol][ii];
			q2Value = q2[thisCol][ii];
			//if this col is different, grab the row index
			if(compare(q1Value,q2Value)){
				//if we don't already have this row in the changed group, put it there
				if(NOT structKeyExists(result.changed,ii))
					result.changed[ii] = structNew();
				thenNow = structNew();
				thenNow.then = q1Value;
				thenNow.now = q2Value;
				thenNow.row = ii;
				thenNow.col = thisCol;
				result.changed[ii][thisCol] = thenNow;
			}
		}
	}
	//if they are not the same size, add the row index to the appropriate key
	if(NOT sameSize){
		rowDiff = longerQuery.recordCount - shorterQuery.recordCount;
		for(ii = rowDiff + shorterQuery.recordCount; ii LTE longerQuery.recordCount; ii = ii + 1){
			result[keyToUseForLonger][ii] = ii;
		}
	}
	//return the result
	return result;
}
</cfscript>

<cfscript>
/**
 * Provides direct access to query cells by knowing a key field value within the same row.
 *
 * @param theQuery 	 The query to search. (Required)
 * @param keyField 	 The column value to return. (Required)
 * @param keyFieldValue 	 The value to search for in keyFIeld. (Required)
 * @param columnName 	 The column value to return. (Required)
 * @return Returns a string.
 * @author Shawn Seley (shawnse@aol.com)
 * @version 1, June 28, 2002
 */
function QueryGetCellByKey(theQuery, keyField, keyFieldValue, columnName){
	var key_field_value_list  = Evaluate("ValueList(theQuery.#keyField#)");
	var row_number            = ListFindNoCase(key_field_value_list, keyFieldValue);

	return theQuery[columnName][row_number];

}
</cfscript>

<cfscript>
/**
 * Return a single row from a query.
 *
 * @param qry 	 Query to inspect. (Required)
 * @param row 	 Numeric row to retrieve. (Required)
 * @return Returns a query.
 * @author Tony Felice (tfelice@reddoor.biz)
 * @version 0, February 14, 2009
 */
function queryGetRow(qry,row){
	var result = queryNew('');
	var cols = listToArray(arguments.qry.columnList);
	var i = '';

	for(i=1; i lte arrayLen(cols); i=i+1){
		queryAddColumn(result, cols[i], listToArray(arguments.qry[cols[i]][arguments.row]));
	}

	return result;
}
</cfscript>

<!---
 Returns a query with any string values sanitized by HTMLEditFormat.
 v2 modified by Raymond Camden

 @param query 	 Query to modify. (Required)
 @return Returns a query.
 @author Kalyan Dhar (kalyan.cse.jis@gmail.com)
 @version 2, May 1, 2011
--->
<cffunction name="queryh" returnType="query" description="returns query after senitize descriptive fields">
	<cfargument name="query" type="query" required="true">

	<cfset var list = "" />
	<cfset var listSelect = "varchar,char,nvarchar,text,ntext" />
	<cfset var column = "">
	<cfset var metadata = "">
	<cfset var type = "">

	<cfloop list="#query.ColumnList#" index="column">
		<cfscript>
		metadata = query.getMetaData();
		type = metadata.getColumnTypeName(query.findColumn(column));
		</cfscript>

		<cfif listFindNoCase(listSelect,type)>
			<cfset list = listAppend(list,column)>
		</cfif>
	</cfloop>

	<cfif listLen(list)>
		<cfloop query="query">
			<cfloop list="#list#" index="column">
				<cfset querySetCell(query, column, htmlEditFormat(query[column][currentRow]),currentRow)>
			</cfloop>
		</cfloop>
	</cfif>

	<cfreturn query />
</cffunction>

<cfscript>
/**
 * Merge two queries.
 *
 * @param querysource 	 Source query. (Required)
 * @param queryoutput 	 Destination query. (Required)
 * @param keyColumn 	 Column (that exists in both queries) to merge on. (Required)
 * @param mergeList 	 List of columns from source query to add to destination query. Defaults to all of them. (Optional)
 * @return Returns a query.
 * @author Alain Blais (Alain_blais@hotmail.com)
 * @version 1, July 21, 2004
 */
function querymerge(querysource,queryoutput,keyColumn){
	var mergeColumn = querysource.columnlist;
	var valueArray = arrayNew(1);
	// define counters
	var i = 1;
	var iRow = 1;
	var jRow = 1;
	//if there is a 4th argument, use that as the mergeColumn
	if(arrayLen(arguments) GT 3) mergeColumn = arguments[4];
	//loop through the merge column
	for(i=1; i lte listLen(mergeColumn,','); i=i+1) {
		if (listFindNoCase(queryoutput.columnlist,listGetAt(mergeColumn,i,','),',') eq 0) {
		    // loop through each row of queryoutput and add information from querysource
			found = listGetAt(mergeColumn,i,',');
		    for (iRow=1; iRow lte queryoutput.recordcount; iRow=iRow+1) {
			    // find the row in querysource that matches the value in keycolumn from queryoutput
				jRow = 1;
				while (jRow lt querysource.recordcount and querysource[keyColumn][jRow] neq queryoutput[keycolumn][iRow]) {
				    jRow = jRow + 1;
				}
				if (querysource[keyColumn][jRow] eq queryoutput[keycolumn][iRow]) {
				    valueArray[iRow] = querysource[listGetAt(mergeColumn,i,',')][jRow];
				}
			}
		    // add the columnm
			queryaddcolumn(queryoutput,listGetAt(mergeColumn,i,','),valueArray);
		}
	}
	return queryoutput;
}
</cfscript>

<cfscript>
/**
 * Returns specified number of random records.
 *
 * @param theQuery 	 The query to return random records from. (Required)
 * @param NumberOfRows 	 The number of random records to return. (Required)
 * @return Returns a query.
 * @author Shawn Seley and John King (shawnse@aol.com)
 * @version 1, July 10, 2002
 */
function QueryRandomRows(theQuery, NumberOfRows) {
	var FinalQuery      = QueryNew(theQuery.ColumnList);
	var x				= 0;
	var y               = 0;
	var i               = 0;
	var random_element  = 0;
	var random_row      = 0;
	var row_list        = "";

	if(NumberOfRows GT theQuery.recordcount) NumberOfRows = theQuery.recordcount;

	QueryAddRow(FinalQuery, NumberOfRows);

	// build a list of rows from which we will "scratch off" the randomly selected values in order to avoid repeats
	for (i=1; i LTE theQuery.RecordCount; i=i+1) row_list = row_list & i & ",";

	// Build the new query
	for(x=1; x LTE NumberOfRows; x=x+1){
		// pick a random_row from row_list and delete that element from row_list (to prevent duplicates)
		random_element  = RandRange(1, ListLen(row_list));          // pick a random list element
		random_row      = ListGetAt(row_list, random_element);      // get the corresponding query row number
		row_list        = ListDeleteAt(row_list, random_element);   // delete the used element from the list
		for(y=1; y LTE ListLen(theQuery.ColumnList); y=y+1) {
			QuerySetCell(FinalQuery, ListGetAt(theQuery.ColumnList, y), theQuery[ListGetAt(theQuery.ColumnList, y)][random_row],x);
		}
	}

	return FinalQuery;
}
</cfscript>

<!---
 Remove a list of columns from a specified query.

 @param theQuery 	 The query to manipulate. (Required)
 @param columnsToRemove 	 A list of columns to remove. (Required)
 @return Returns a query.
 @author Giampaolo Bellavite (giampaolo@bellavite.com)
 @version 1, April 14, 2005
--->
<cffunction name="queryRemoveColumns" output="false" returntype="query">
	<cfargument name="theQuery" type="query" required="yes">
	<cfargument name="columnsToRemove" type="string" required="yes">
	<cfset var columnList=theQuery.columnList>
	<cfset var columnPosition="">
	<cfset var c="">
	<cfset var newQuery="">
	<cfloop list="#arguments.columnsToRemove#" index="c">
		<cfset columnPosition=ListFindNoCase(columnList,c)>
		<cfif columnPosition NEQ 0>
			<cfset columnList=ListDeleteAt(columnList,columnPosition)>
		</cfif>
	</cfloop>
	<cfquery name="newQuery" dbtype="query">
		SELECT #columnList# FROM theQuery
	</cfquery>
	<cfreturn newQuery>
</cffunction>

<cfscript>
/**
 * Reverse the order of a query.
 *
 * @param qryOriginal 	 Name of the query you want to reverse (Required)
 * @return Returns a query object.
 * @author David Whiterod (whiterod.david@saugov.sa.gov.au)
 * @version 1, June 27, 2002
 */
function QueryReverse (qryOriginal) {

  // Reverse the order of qryOriginal
  // Make a new query using the same columns as qryOriginal
  var qryNew = QueryNew(qryOriginal.ColumnList);
  var row = 1;
  var column = 1;
  //Loop through qryOriginal in reverse order (last becomes first)
  for(row=qryOriginal.recordCount;row gte 1; row=row-1) {
    //Add a new row in the new query
    QueryAddRow(qryNew,1);
    //Get the values for each column in qryOriginal
    for(column=1;column lte ListLen(qryOriginal.ColumnList);column=column+1) {
      QuerySetCell(qryNew, ListGetAt(qryOriginal.ColumnList,column), qryOriginal[ListGetAt(qryOriginal.ColumnList,column)][row]);
    }
  }

  return qryNew;

}
</cfscript>

<cfscript>
/**
 * Returns the first query row number that contains the specified key value.
 *
 * @param theQuery 	 The query to search. (Required)
 * @param keyField 	 The column to search. (Required)
 * @param keyFieldValue 	 The value to search for. (Required)
 * @return Returns a numeric value.
 * @author Shawn Seley (shawnse@aol.com)
 * @version 1, June 28, 2002
 */
function QueryRowFromKey(theQuery, keyField, keyFieldValue){
	var key_field_value_list = Evaluate("ValueList(theQuery.#keyField#)");
	return ListFindNoCase(key_field_value_list, keyFieldValue);
}
</cfscript>

<cfscript>
/**
 * queryRowToArray
 * version 0.1 by Paul Kukiel
 * version 1.0 by Adam Cameron - fixing bug wherein not all columns were returned, plus factoring out unsupported query method usage in favour of native CFML getMetadata() function call to get query columns
 *
 * @param query 	 Query to extract from from (Required)
 * @param row 	 Which row to extract (Required)
 * @return Returns an array
 * @author Paul Kukiel (kukielp@gmail.com)
 * @version 1, July 27, 2012
 */
function queryRowToArray(query, row){
	var i = 1;
	var queryCols = getMetadata(query);
	var arrayReturn = [];

	for(i = 1; i <= arrayLen(querycols); i++){
		arrayReturn[i] = query[querycols[i].name][arguments.row];
	}
	return arrayReturn;
}
</cfscript>

<cfscript>
/**
 * Function to take a single row from a query and generate a list.
 *
 * @param query 	 The query to examine. (Required)
 * @param queryrow 	 Row to use. (Optional)
 * @param delim 	 Delimiter to use. (Optional)
 * @return Returns a string.
 * @author Tim Sloan (tim@sloanconsulting.com)
 * @version 1, August 6, 2004
 */
function queryRowToList(query){
	var queryrow = 1;
	var j = 1;
	var querycols = listToArray(query.columnList);
	var delim = ",";
	var listReturn = "";
	if(arrayLen(arguments) GT 1) queryrow = arguments[2];
	if(arrayLen(arguments) GT 2) delim = arguments[3];
	for(j = 1; j lte arraylen(querycols); j = j + 1){
		listReturn = ListAppend(listReturn, query[querycols[j]][queryrow], delim);
	}
	return listReturn;
}
</cfscript>

<cfscript>
/**
 * Makes a row of a query into a structure.
 *
 * @param query 	 The query to work with.
 * @param row 	 Row number to check. Defaults to row 1.
 * @return Returns a structure.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 1, December 11, 2001
 */
function queryRowToStruct(query){
	//by default, do this to the first row of the query
	var row = 1;
	//a var for looping
	var ii = 1;
	//the cols to loop over
	var cols = listToArray(query.columnList);
	//the struct to return
	var stReturn = structnew();
	//if there is a second argument, use that for the row number
	if(arrayLen(arguments) GT 1)
		row = arguments[2];
	//loop over the cols and build the struct from the query row
	for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
		stReturn[cols[ii]] = query[cols[ii]][row];
	}
	//return the struct
	return stReturn;
}
</cfscript>

<cfscript>
/**
 * Allows changing of a query cell by knowing a key field value within the same row.
 *
 * @param theQuery 	 The query to modify. (Required)
 * @param keyField 	 The column to search against. (Required)
 * @param keyFieldValue 	 The value to search for. (Required)
 * @param columnName 	 The column to modify. (Required)
 * @param newValue 	 The value to set. (Required)
 * @return Returns a query.
 * @author Shawn Seley (shawnse@aol.com)
 * @version 1, June 28, 2002
 */
function QuerySetCellByKey(theQuery, keyField, keyFieldValue, columnName, newValue){
	var key_field_value_list  = Evaluate("ValueList(theQuery.#keyField#)");
	var row_number            = ListFindNoCase(key_field_value_list, keyFieldValue);
	querysetCell(theQuery,columnName,newValue,row_number);
}
</cfscript>

<!---
 Sets the values for one or more columns in the specified query row.

 @param query 	 Query to manipulate. (Required)
 @param columnlist 	 List of columns to update. (Required)
 @param valuelist 	 Values for the new data. (Required)
 @param rownumber 	 Row number to modify. If not specified, row is added to end of query. (Optional)
 @param delimiter 	 Delimiter for columnlist and valuelist. Defaults to a comma. (Optional)
 @param trimElements 	 If true, trims all values. Defaults to true. (Optional)
 @return Returns void..
 @author Ell Cord (lunareclipse13@earthlink.net)
 @version 1, October 18, 2005
--->
<cffunction name="querySetRow" returntype="void" output="false">
	<cfargument name="query" type="query" required="true" />
	<cfargument name="columnList" type="string" required="true" />
	<cfargument name="valuesList" type="string" required="true" />
	<cfargument name="rowNumber" type="numeric" required="false" default="0" />
	<cfargument name="delimiter" type="string" required="false"  default="," />
	<cfargument name="trimElements" type="boolean" required="false"  default="true" />

	<cfset var i 	   	= 0>
	<cfset var col	   	= "">
	<cfset var value	= "">

	<cfif arguments.rowNumber gt 0 and arguments.rowNumber gt arguments.query.recordCount>
		<cfthrow type="InvalidArgument" message="Invalid rowNumber [#arguments.rowNumber#]. The specified query contains [#arguments.query.RecordCount#] records.">
	</cfif>
	<cfif ListLen(arguments.columnList, arguments.delimiter) NEQ ListLen(arguments.valuesList, arguments.delimiter)>
		<cfthrow type="InvalidArgument" message="[columnList] and [valuesList] do not contain the same number of elements.">
	</cfif>

	<cfscript>
		//by default, append new row to end of query
		if (val(arguments.rowNumber) lt 1) {
			QueryAddRow(arguments.query, 1);
			rowNumber = arguments.query.recordCount;
		}

		//set values for each column
		for (i = 1; i lte ListLen(arguments.columnList, arguments.delimiter); i = i + 1) {
			if (arguments.trimElements) {
				col   = Trim(ListGetAt(arguments.columnList, i, arguments.delimiter));
				value = Trim(ListGetAt(arguments.valuesList, i, arguments.delimiter));
			}
			else {
				col   = ListGetAt(arguments.columnList, i, arguments.delimiter);
				value = ListGetAt(arguments.valuesList, i, arguments.delimiter);
			}
		    query[col][arguments.rowNumber] = value;
		}
	</cfscript>
</cffunction>

<cfscript>
/**
 * Accepts a specifically formatted chunk of text, and returns it as a query object.
 * v2 rewrite by Jamie Jackson
 *
 * @param queryData 	 Specifically format chunk of text to convert to a query. (Required)
 * @return Returns a query object.
 * @author Bert Dawson (bert@redbanner.com)
 * @version 2, December 18, 2007
 */
function querySim(queryData) {
	var fieldsDelimiter="|";
	var colnamesDelimiter=",";
	var listOfColumns="";
	var tmpQuery="";
	var numLines="";
	var cellValue="";
	var cellValues="";
	var colName="";
	var lineDelimiter=chr(10) & chr(13);
	var lineNum=0;
	var colPosition=0;

	// the first line is the column list, eg "column1,column2,column3"
	listOfColumns = Trim(ListGetAt(queryData, 1, lineDelimiter));

	// create a temporary Query
	tmpQuery = QueryNew(listOfColumns);

	// the number of lines in the queryData
	numLines = ListLen(queryData, lineDelimiter);

	// loop though the queryData starting at the second line
	for(lineNum=2;  lineNum LTE numLines;  lineNum = lineNum + 1) {
	    cellValues = ListGetAt(queryData, lineNum, lineDelimiter);

		if (ListLen(cellValues, fieldsDelimiter) IS ListLen(listOfColumns,",")) {
			QueryAddRow(tmpQuery);
			for (colPosition=1; colPosition LTE ListLen(listOfColumns); colPosition = colPosition + 1){
				cellValue = Trim(ListGetAt(cellValues, colPosition, fieldsDelimiter));
				colName   = Trim(ListGetAt(listOfColumns,colPosition));
				QuerySetCell(tmpQuery, colName, cellValue);
			}
		}
	}

	return( tmpQuery );

}
</cfscript>

<!---
 Returns specific number of records starting with a specific row.
 Renamed by RCamden
 Version 2 with column name support by Christopher Bradford, christopher.bradford@aliveonline.com

 @param theQuery 	 The query to work with. (Required)
 @param StartRow 	 The row to start on. (Required)
 @param NumberOfRows 	 The number of rows to return. (Required)
 @param ColumnList 	 List of columns to return. Defaults to all the columns. (Optional)
 @return Returns a query.
 @author Kevin Bridges (cyberswat@orlandoartistry.com)
 @version 2, May 23, 2005
--->
<cffunction name="QuerySliceAndDice" returntype="query" output="false">
	<cfargument name="theQuery" type="query" required="true" />
	<cfargument name="StartRow" type="numeric" required="true" />
	<cfargument name="NumberOfRows" type="numeric" required="true" />
	<cfargument name="ColumnList" type="string" required="false" default="" />

	<cfscript>
		var FinalQuery = "";
		var EndRow = StartRow + NumberOfRows;
		var counter = 1;
		var x = "";
		var y = "";

		if (arguments.ColumnList IS "") {
			arguments.ColumnList = theQuery.ColumnList;
		}
		FinalQuery = QueryNew(arguments.ColumnList);

		if(EndRow GT theQuery.recordcount) {
			EndRow = theQuery.recordcount+1;
		}

		QueryAddRow(FinalQuery,EndRow - StartRow);

		for(x = 1; x LTE theQuery.recordcount; x = x + 1){
			if(x GTE StartRow AND x LT EndRow) {
				for(y = 1; y LTE ListLen(arguments.ColumnList); y = y + 1) {
					QuerySetCell(FinalQuery, ListGetAt(arguments.ColumnList, y), theQuery[ListGetAt(arguments.ColumnList, y)][x],counter);
				}
				counter = counter + 1;
			}
		}

		return FinalQuery;
	</cfscript>

</cffunction>

<!---
 Sorts a query using Query of Query.
 Updated for CFMX var syntax.

 @param query 	 The query to sort. (Required)
 @param column 	 The column to sort on. (Required)
 @param sortDir  	 The direction of the sort. Default is "ASC." (Optional)
 @return Returns a query.
 @author Raymond Camden (ray@camdenfamily.com)
 @version 2, October 15, 2002
--->
<cffunction name="QuerySort" output="no" returnType="query">
	<cfargument name="query" type="query" required="true">
	<cfargument name="column" type="string" required="true">
	<cfargument name="sortDir" type="string" required="false" default="asc">

	<cfset var newQuery = "">

	<cfquery name="newQuery" dbType="query">
		select * from query
		order by #column# #sortDir#
	</cfquery>

	<cfreturn newQuery>

</cffunction>

<cfscript>
/**
 * Converts a query object into an array of structures.
 *
 * @param query 	 The query to be transformed
 * @return This function returns a structure.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 1, September 27, 2001
 */
function QueryToArrayOfStructures(theQuery){
	var theArray = arraynew(1);
	var cols = ListtoArray(theQuery.columnlist);
	var row = 1;
	var thisRow = "";
	var col = 1;
	for(row = 1; row LTE theQuery.recordcount; row = row + 1){
		thisRow = structnew();
		for(col = 1; col LTE arraylen(cols); col = col + 1){
			thisRow[cols[col]] = theQuery[cols[col]][row];
		}
		arrayAppend(theArray,duplicate(thisRow));
	}
	return(theArray);
}
</cfscript>

<cfscript>
/**
 * Transform a query result into a csv formatted variable.
 *
 * @param query 	 The query to transform. (Required)
 * @param headers 	 A list of headers to use for the first row of the CSV string. Defaults to cols. (Optional)
 * @param cols 	 The columns from the query to transform. Defaults to all the columns. (Optional)
 * @return Returns a string.
 * @author adgnot sebastien (sadgnot@ogilvy.net)
 * @version 1, June 26, 2002
 */
function QueryToCsv(query){
	var csv = "";
	var cols = "";
	var headers = "";
	var i = 1;
	var j = 1;

	if(arrayLen(arguments) gte 2) headers = arguments[2];
	if(arrayLen(arguments) gte 3) cols = arguments[3];

	if(cols is "") cols = query.columnList;
	if(headers IS "") headers = cols;

	headers = listToArray(headers);

	for(i=1; i lte arrayLen(headers); i=i+1){
		csv = csv & """" & headers[i] & """;";
	}

	csv = csv & chr(13) & chr(10);

	cols = listToArray(cols);

	for(i=1; i lte query.recordCount; i=i+1){
		for(j=1; j lte arrayLen(cols); j=j+1){
			csv = csv & """" & query[cols[j]][i] & """;";
		}
		csv = csv & chr(13) & chr(10);
	}
	return csv;
}
</cfscript>

<cfscript>
/**
 * Changes a query into a struct of arrays.
 *
 * @param query 	 The query to be transformed.
 * @return Returns a structure.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 1, February 23, 2002
 */
function queryToStructOfArrays(q){
		//a variable to hold the struct
		var st = structNew();
		//two variable for iterating
		var ii = 1;
		var cc = 1;
		//grab the columns into an array for easy looping
		var cols = listToArray(q.columnList);
		//iterate over the columns of the query and create the arrays of values
		for(ii = 1; ii lte arrayLen(cols); ii = ii + 1){
			//make the array with the col name as the key in the root struct
			st[cols[ii]] = arrayNew(1);
			//now loop for the recordcount of the query and insert the values
			for(cc = 1; cc lte q.recordcount; cc = cc + 1)
				arrayAppend(st[cols[ii]],q[cols[ii]][cc]);
		}
		//return the struct
		return st;
	}
</cfscript>

<cfscript>
/**
 * Converts a query to a structure of structures with the primary index of the main structure auto incremented.
 *
 * @param theQuery 	 The query to transform. (Required)
 * @return Returns a struct.
 * @author Peter J. Farrell (pjf@maestropublishing.com)
 * @version 1, September 23, 2004
 */
function queryToStructOfStructsAutoRow(theQuery){
	var theStructure = StructNew();
	var cols = ListToArray(theQuery.columnlist);
	var row = 1;
	var thisRow = "";
	var col = 1;

	for(row = 1; row LTE theQuery.recordcount; row = row + 1){
		thisRow = StructNew();
		for(col = 1; col LTE arraylen(cols); col = col + 1){
			thisRow[cols[col]] = theQuery[cols[col]][row];
		}
		theStructure[row] = Duplicate(thisRow);
	}
	return theStructure;
}
</cfscript>

<cfscript>
/**
 * Converts a query object into a structure of structures accessible by its primary key.
 * v2 mod by James Moberg - added retainSort
 *
 * @param theQuery 	 The query you want to convert to a structure of structures. (Required)
 * @param primaryKey 	 Query column to use as the primary key. (Required)
 * @param retainSort 	 If true, a Java LinkedHashMap will be used to create the result. This will create a struct with ordered keys. Defaults to false. (Optional)
 * @return Returns a structure.
 * @author Shawn Seley (shawnse@aol.com)
 * @version 2, January 26, 2011
 */
function QueryToStructOfStructures(theQuery, primaryKey){
       var theStructure  = structnew();
       /* remove primary key from cols listing */
       var cols          = ListToArray(ListDeleteAt(theQuery.columnlist, ListFindNoCase(theQuery.columnlist, primaryKey)));
       var row           = 1;
       var thisRow       = "";
       var col           = 1;
       var retainSort = false;
       if(arrayLen(arguments) GT 2) retainSort = arguments[3];
       if(retainSort){
               theStructure = CreateObject("java", "java.util.LinkedHashMap").init();
       }
       for(row = 1; row LTE theQuery.recordcount; row = row + 1){
               thisRow = structnew();
               for(col = 1; col LTE arraylen(cols); col = col + 1){
                       thisRow[cols[col]] = theQuery[cols[col]][row];
               }
               theStructure[theQuery[primaryKey][row]] = duplicate(thisRow);
       }
       return(theStructure);
}
</cfscript>

<cfscript>
/**
 * Change a row in a query to variables in a scope.
 *
 * @param q 	 The query to use.
 * @param scope 	 Scope to save data in. Defaults to "" or local scope.
 * @param row 	 Row number to use. Defaults to 1.
 * @return Returns an empty string.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 1, March 11, 2002
 */
function queryToVars(q){
	//first, an array of the column names for looping
	var cols = listToArray(q.columnList);
	//a var to use as iterator
	var ii = 1;
	//by default, use no scope
	var scope = "";
	//by default, use the first row
	var row = 1;
	//if there is a second argument, use that as the scope
	if(arrayLen(arguments) GT 1)
		scope = arguments[2] & ".";
	//if there is a third argument and it is numeric, use that as the row (make sure it is a positive integer)
	if(arrayLen(arguments) GT 2 and isNumeric(arguments[3]))
		row = ceiling(abs(arguments[3]));
	//loop over the columns, making a variables for each one
	for(ii = 1; ii lte arrayLen(cols); ii = ii + 1)
		setVariable(scope & cols[ii],q[cols[ii]][row]);
	//return nothing
	return "";
}
</cfscript>

<cfscript>
/**
 * Generates an XMLDoc object from a basic CF Query.
 *
 * @param query 	 The query to transform. (Required)
 * @param rootElement 	 Name of the root node. (Default is "query.") (Optional)
 * @param row 	 Name of each row. Default is "row." (Optional)
 * @param nodeMode 	 Defines the structure of the resulting XML.  Options are 1) "values" (default), which makes each value of each column mlText of individual nodes; 2) "columns", which makes each value of each column an attribute of a node for that column; 3) "rows", which makes each row a node, with the column names as attributes. (Optional)
 * @return Returns a string.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 2, November 15, 2002
 */
function queryToXML(query){
	//the default name of the root element
	var root = "query";
	//the default name of each row
	var row = "row";
	//make an array of the columns for looping
	var cols = listToArray(query.columnList);
	//which mode will we use?
	var nodeMode = "values";
	//vars for iterating
	var ii = 1;
	var rr = 1;
	//vars for holding the values of the current column and value
	var thisColumn = "";
	var thisValue = "";
	//a new xmlDoc
	var xml = xmlNew();
	//if there are 2 arguments, the second one is name of the root element
	if(structCount(arguments) GTE 2)
		root = arguments[2];
	//if there are 3 arguments, the third one is the name each element
	if(structCount(arguments) GTE 3)
		row = arguments[3];
	//if there is a 4th argument, it's the nodeMode
	if(structCount(arguments) GTE 4)
		nodeMode = arguments[4];
	//create the root node
	xml.xmlRoot = xmlElemNew(xml,root);
	//capture basic info in attributes of the root node
	xml[root].xmlAttributes["columns"] = arrayLen(cols);
	xml[root].xmlAttributes["rows"] = query.recordCount;
	//loop over the recordcount of the query and add a row for each one
	for(rr = 1; rr LTE query.recordCount; rr = rr + 1){
		arrayAppend(xml[root].xmlChildren,xmlElemNew(xml,row));
		//loop over the columns, populating the values of this row
		for(ii = 1; ii LTE arrayLen(cols); ii = ii + 1){
			thisColumn = lcase(cols[ii]);
			thisValue = query[cols[ii]][rr];
			switch(nodeMode){
				case "rows":
					xml[root][row][rr].xmlAttributes[thisColumn] = thisValue;
					break;
				case "columns":
					arrayAppend(xml[root][row][rr].xmlChildren,xmlElemNew(xml,thisColumn));
					xml[root][row][rr][thisColumn].xmlAttributes["value"] = thisValue;
					break;
				default:
					arrayAppend(xml[root][row][rr].xmlChildren,xmlElemNew(xml,thisColumn));
					xml[root][row][rr][thisColumn].xmlText = thisValue;
			}

		}
	}
	//return the xmlDoc
	return xml;
}
</cfscript>

<!---
 Transpose a query.

 @param inputQuery 	 The query to transpose. (Required)
 @param includeHeaders 	 Determines if headers should be included as a column. Defaults to true. (Optional)
 @return Returns a query.
 @author Glenn Buteau (glenn.buteau@rogers.com)
 @version 1, August 24, 2005
--->
<cffunction name="queryTranspose" returntype="query">
	<cfargument name="inputQuery" type="query" required="true">
	<cfargument name="includeHeaders" type="boolean" default="true" required="false">

	<cfset var outputQuery = QueryNew("")>
	<cfset var columnsList = inputQuery.ColumnList>
	<cfset var newColumn = ArrayNew(1)>
	<cfset var row = 1>
	<cfset var zeroString = "000000">
	<cfset var padFactor = int(log10(inputQuery.recordcount)) + 1 >
	<cfset var i = "">

	<cfif includeHeaders>
		<cfset queryAddColumn(OutputQuery,"col_#right(zeroString & row, padFactor)#",listToArray(ColumnsList))>
		<cfset row = row + 1>
	</cfif>

	<cfloop query="inputQuery">
		<cfloop index="i" from="1" to="#listlen(columnsList)#">
			<cfset newColumn[i] = inputQuery[ListGetAt(columnsList, i)][currentRow]>
		</cfloop>
		<cfset queryAddColumn(outputQuery,"col_#right(zeroString & row, padFactor)#",newColumn)>
		<cfset row = row + 1>
	</cfloop>

	<cfreturn outputQuery>
</cffunction>

<!---
 QueryTreeSort takes a query and efficiently (O(n)) resorts it hierarchically (parent-child), adding a Depth column that can then be used when displaying the data.

 @param stuff 	 Query to sort. (Required)
 @param parentid 	 Column containing parent id. Defaults to parentid. (Optional)
 @param itemid 	 Column containing ID value. Defaults to itemid. (Optional)
 @param basedepth 	 Base depth of data. Defaults to 0. (Optional)
 @param depthname 	 Name for new column to use for depth. Defaults to TreeDepth. (Optional)
 @return Returns a query.
 @author Rick Osborne (deliver8r@gmail.com)
 @version 1, April 9, 2007
--->
<cffunction name="queryTreeSort" returntype="query" output="No">
	<cfargument name="Stuff" type="query" required="Yes">
	<cfargument name="ParentID" type="string" required="No" default="ParentID">
	<cfargument name="ItemID" type="string" required="No" default="ItemID">
	<cfargument name="BaseDepth" type="numeric" required="No" default="0">
	<cfargument name="DepthName" type="string" required="No" default="TreeDepth">
	<cfset var RowFromID=StructNew()>
	<cfset var ChildrenFromID=StructNew()>
	<cfset var RootItems=ArrayNew(1)>
	<cfset var Depth=ArrayNew(1)>
	<cfset var ThisID=0>
	<cfset var ThisDepth=0>
	<cfset var RowID=0>
	<cfset var ChildrenIDs="">
	<cfset var ColName="">
	<cfset var Ret=QueryNew(ListAppend(Stuff.ColumnList,Arguments.DepthName))>
	<!--- Set up all of our indexing --->
	<cfloop query="Stuff">
		<cfset RowFromID[Stuff[Arguments.ItemID][Stuff.CurrentRow]]=CurrentRow>
		<cfif NOT StructKeyExists(ChildrenFromID, Stuff[Arguments.ParentID][Stuff.CurrentRow])>
			<cfset ChildrenFromID[Stuff[Arguments.ParentID][Stuff.CurrentRow]]=ArrayNew(1)>
		</cfif>
		<cfset ArrayAppend(ChildrenFromID[Stuff[Arguments.ParentID][Stuff.CurrentRow]], Stuff[Arguments.ItemID][Stuff.CurrentRow])>
	</cfloop>
	<!--- Find parents without rows --->
	<cfloop query="Stuff">
		<cfif NOT StructKeyExists(RowFromID, Stuff[Arguments.ParentID][Stuff.CurrentRow])>
			<cfset ArrayAppend(RootItems, Stuff[Arguments.ItemID][Stuff.CurrentRow])>
			<cfset ArrayAppend(Depth, Arguments.BaseDepth)>
		</cfif>
	</cfloop>
	<!--- Do the deed --->
	<cfloop condition="ArrayLen(RootItems) GT 0">
		<cfset ThisID=RootItems[1]>
		<cfset ArrayDeleteAt(RootItems, 1)>
		<cfset ThisDepth=Depth[1]>
		<cfset ArrayDeleteAt(Depth, 1)>
		<cfif StructKeyExists(RowFromID, ThisID)>
			<!--- Add this row to the query --->
			<cfset RowID=RowFromID[ThisID]>
			<cfset QueryAddRow(Ret)>
			<cfset QuerySetCell(Ret, Arguments.DepthName, ThisDepth)>
			<cfloop list="#Stuff.ColumnList#" index="ColName">
				<cfset QuerySetCell(Ret, ColName, Stuff[ColName][RowID])>
			</cfloop>
		</cfif>
		<cfif StructKeyExists(ChildrenFromID, ThisID)>
			<!--- Push children into the stack --->
			<cfset ChildrenIDs=ChildrenFromID[ThisID]>
			<cfloop from="#ArrayLen(ChildrenIDs)#" to="1" step="-1" index="i">
				<cfset ArrayPrepend(RootItems, ChildrenIDs[i])>
				<cfset ArrayPrepend(Depth, ThisDepth + 1)>
			</cfloop>
		</cfif>
	</cfloop>
	<cfreturn Ret>
</cffunction>

<cfscript>
/**
 * Sorts a two dimensional array by the specified column using quicksort.
 *
 * @param arrayToSort 	 The array to sort. (Required)
 * @param key 	 Position in the second dimension to sort by. (Required)
 * @param down 	 Index in fist dimension indicating where to begin sorting. (Required)
 * @param top 	 Position in first dimension indicating where to end sorting. (Required)
 * @return Returns an array.
 * @author Matthew Wear (matt.b.wear@gmail.com)
 * @version 1, March 28, 2006
 */
function quickSort2D(arrayToSort, key, down, top) {
	var i = down;
	var j = top;
	var p = JavaCast("int",((down + top)/2));
	var x = arrayToSort[p][key];
	var temp = 0;
	var length = 0;
	var y = 0;
	var z = 0;

	do {
		while(arrayToSort[i][key] LT x AND i LT p) i=i+1;
		while(arrayToSort[j][key] GT x AND j GT p) j=j-1;
		if(i LT j){
			if(j EQ p){
				length = ArrayLen(arrayToSort)+1;
				for(z=length;z GT p+1;z=z-1)
					for(y=1;y LTE ArrayLen(arrayToSort[i]);y=y+1)
						arrayToSort[z][y]=arrayToSort[z-1][y];

				for(y=1;y LTE ArrayLen(arrayToSort[i]);y=y+1){
					arrayToSort[j+1][y] = arrayToSort[i][y];
					arrayToSort[i][y] = 0;
				}

				ArrayDeleteAt(arrayToSort,i);

				i=i-1;
				p=p-1;
			}

			else if(i EQ p){
				length = ArrayLen(arrayToSort)+1;
				for(z=length;z GT p;z=z-1)
					for(y=1;y LTE ArrayLen(arrayToSort[i]);y=y+1)
						arrayToSort[z][y]=arrayToSort[z-1][y];

				j = j + 1;
				i = i + 1;
				p = p + 1;

				for(y=1;y LTE ArrayLen(arrayToSort[i]);y=y+1){
					arrayToSort[i-1][y] = arrayToSort[j][y];
					arrayToSort[j][y] = 0;
				}

				ArrayDeleteAt(arrayToSort,j);
			}

			else{
				for(y=1;y LTE ArrayLen(arrayToSort[i]);y=y+1){
					temp = arrayToSort[i][y];
					arrayToSort[i][y] = arrayToSort[j][y];
					arrayToSort[j][y] = temp;
				}
			}
		}

		if(i LT p) i=i+1;
		if(j GT p) j=j-1;

	}while(i LT j);

	if(down LT j) arrayToSort = QuickSort2D(arrayToSort, key, down, p-1);
	if(i LT top) arrayToSort = QuickSort2D(arrayToSort, key, p+1, top);

	return arrayToSort;
}
</cfscript>

<cfscript>
/**
 * Returns a number of random selections from a list based on their given weights.
 *
 * @param weights 	 Structure with keys and numeric values for weights. (Required)
 * @param n 	 Number of selections to make. (Required)
 * @return Returns an array.
 * @author Chris Spencer (chrisspen@gmail.com)
 * @version 1, May 25, 2006
 */
function randomWeightedSelection(weights, n){
	var seq = structKeyArray(weights);
	var totals = arrayNew(1);
	var runningtotal = 0;
	var selections = arrayNew(1);
	var s = 0;
	var i = 0;

	for(i=1; i lte arrayLen(seq); i=i+1){
		runningtotal = runningtotal + weights[seq[i]];
		arrayAppend(totals, runningtotal);
	}
	for(s=1; s lte n; s=s+1){
		r = rand()*runningtotal;
		for(i=1; i lte arrayLen(seq); i=i+1){
			if(totals[i] gt r){
				arrayAppend(selections,seq[i]);
				break;
			}
		}
	}

	return selections;
}
</cfscript>

<cfscript>
/**
 * Takes a query and ranks the scores, including ties at the same rank.
 * v0.9 by John Ceci
 * v1.0 by Adam Cameron (improved validation, variable-naming; simplified logic)
 *
 * @param query 	 A query containing data to rank (Required)
 * @param scoreColumn 	 The column within the query argument containing the data to rank. Must be ordered according to sortOrder argument (Required)
 * @param rankColumn 	 The column to put the rankings in  (Required)
 * @param sortOrder 	 One of ASC (default) or DESC (Optional)
 * @return Nothing. Updates the query inline
 * @author John Ceci (tigeryan55@gmail.com)
 * @version 1.0, July 16, 2013
 */
void function rankScores(required query query, required string scoreColumn, required string rankColumn, sortOrder="ASC"){
	var currentRank		= 0;
	var previousScore	= 0;
	var rankIncrement	= 1;
	var row				= 0;

	if (!(listFindNoCase(query.columnlist, scoreColumn) || listFindNoCase(query.columnlist, rankColumn))) {
		throw(type="InvalidColumnException", message="Invalid score or rank column", detail="One or both of #scoreColumn# or #rankColumn# not found in #query.columnlist#");
	}

	if (!isValid("Regex", sortOrder, "(?i)^(?:ASC|DESC)$" )){
		throw(type="InvalidArgumentException", message="Invalid sortOrder", detail="The sortOrder argument - current value #sortOrder# - must be one of ASC or DESC");
	}

	if (sortOrder == "ASC"){
		previousScore = arrayMin(query[scoreColumn]) - 1;
	}else{
		previousScore = arrayMax(query[scoreColumn]) + 1;
	}

	for (row=1; row <= arrayLen(query[scoreColumn]); row++){
		if (query[scoreColumn][row] == previousScore){
			rankIncrement++;
		}else{
			currentRank += rankIncrement;
			rankIncrement = 1;
		}
		query[rankColumn][row] = currentRank;

		previousScore = query[scoreColumn][row];
	}
}
</cfscript>

<cfscript>
/**
 * Pass an Array of structures and the name of a column that exists within each, and it will create a Grouped &quot;Structure of Array of Structures&quot;.
 *
 * @param mydata 	 Structure to parse. (Optional)
 * @param col 	 Column to group by. (Required)
 * @return Returns a structure.
 * @author Casey Broich (cab@pagex.com)
 * @version 1, May 26, 2003
 */
function ReGroupBy(mydata,col){
  var i = "";
  var sttemp = structnew();
  var thisValue = "";
  for (i=1; i LTE arraylen(mydata); i=i+1){
    thisValue = mydata[i][col];
    if (not structkeyexists(sttemp, thisValue)){
      sttemp[thisValue] = arraynew(1);
    }
    arrayappend(sttemp[thisValue] , mydata[i]);
  }
  return sttemp;
}
</cfscript>

<cfscript>
/**
 * Removes any empty structure keys from within a structure.
 * version 2 by Raymond Camden, added var, slimmed things down a bit.
 *
 * @param structure 	 Structure to modify. (Required)
 * @return Returns a structure.
 * @author Brian Rinaldi (brinaldi@criticaldigital.com)
 * @version 1, April 19, 2004
 */
function removeEmptyStructureKeys(structure) {
	var newStructure = structNew();
	var keys = structKeyList(arguments.structure);
	var name = "";
	var i = 1;
	for (;i lte listLen(keys);i=i+1) {
		name = listGetAt(keys,i);
		if (not isSimpleValue(arguments.structure[name])) {
			newStructure[name] = arguments.structure[name];
		}
		else if (arguments.structure[name] neq "") {
			newStructure[name] = arguments.structure[name];
		}
	}
	return newStructure;
}
</cfscript>

<!---
 Searches recursively through a substructure of nested arrays, structures, and other elements for structures with values that match the search. pattern in the reg_expression parameter.

 @param top 	 Top level structure to search. (Required)
 @param reg_expression 	 Regular expression used for search. (Required)
 @param scope 	 Scope to use for search. If one, finds the first result, otherwise returns all results. Defaults to one. (Optional)
 @param owner 	 Pointer to item searched. Normally not passed. Defaults to top. (Optional)
 @param path 	 Path to search for within the data. Again, normally not passed. (Optional)
 @param results 	 Carries the results value and used recursively.  (Optional)
 @return Returns an array.
 @author Nathan Mische (nmische@gmail.com)
 @version 0, July 12, 2009
--->
<cffunction name="REStructFindValue" returntype="array" output="false">
	<cfargument name="top" type="any" required="true">
	<cfargument name="reg_expression" type="string" required="true">
	<cfargument name="scope" type="string" required="false">
	<cfargument name="owner" type="any" required="false">
	<cfargument name="path" type="string" required="false">
	<cfargument name="results" type="any" required="false">

	<cfset var key = "">
	<cfset var i = "">
	<cfset var result="">

	<!--- set default values --->
	<cfif not StructKeyExists(arguments,"scope")>
		<cfset arguments.scope = "one">
	</cfif>

	<cfif not StructKeyExists(arguments,"owner")>
		<cfset arguments.owner = arguments.top>
	</cfif>

	<cfif not StructKeyExists(arguments,"path")>
		<cfset arguments.path = "">
	</cfif>

	<cfif not StructKeyExists(arguments,"results")>
		<cfset arguments.results = CreateObject("java","java.util.ArrayList").init()>
	</cfif>

	<!--- exit if scope is "one" and we have a result --->
	<cfif CompareNoCase(arguments.scope,"one") eq 0
		and ArrayLen(arguments.results) eq 1>

		<cfreturn arguments.results>

	</cfif>

	<!--- recurse or do test depending on type --->
	<cfif IsStruct(arguments.top)>

		<cfloop collection="#arguments.top#" item="key">
			<cfset REStructFindValue(arguments.top[key],arguments.reg_expression,arguments.scope,arguments.top,"#arguments.path#.#key#",arguments.results)>
		</cfloop>

	<cfelseif IsArray(arguments.top)>

		<cfloop from="1" to="#ArrayLen(arguments.top)#" index="i">
			<cfset REStructFindValue(arguments.top[i],arguments.reg_expression,arguments.scope,arguments.top,"#path#[#i#]",arguments.results)>
		</cfloop>

	<cfelseif IsSimpleValue(arguments.top)
		and IsStruct(arguments.owner)
		and REFind(arguments.reg_expression,arguments.top)>

		<cfset result = StructNew()>
		<cfset result["key"] = ListLast(arguments.path,".")>
		<cfset result["owner"] = arguments.owner>
		<cfset result["path"] = arguments.path>
		<cfset ArrayAppend(arguments.results,result)>

	</cfif>

	<cfreturn arguments.results>

</cffunction>

<!---
 Searches recursively through a substructure of nested arrays, structures, and other elements for structures with values that match the search .pattern in the reg_expression parameter.

 @param top 	 Top level structure to search. (Required)
 @param reg_expression 	 Regular expression used for search. (Required)
 @param scope 	 Scope to use for search. If one, finds the first result, otherwise returns all results. Defaults to one. (Optional)
 @param owner 	 Pointer to item searched. Normally not passed. Defaults to top. (Optional)
 @param path 	 Path to search for within the data. Again, normally not passed. (Optional)
 @param results 	 Carries the results value and used recursively.  (Optional)
 @return Returns an array.
 @author Nathan Mische (nmische@gmail.com)
 @version 0, July 12, 2009
--->
<cffunction name="REStructFindValueNoCase" returntype="array" output="false">
	<cfargument name="top" type="any" required="true">
	<cfargument name="reg_expression" type="string" required="true">
	<cfargument name="scope" type="string" required="false">
	<cfargument name="owner" type="any" required="false">
	<cfargument name="path" type="string" required="false">
	<cfargument name="results" type="any" required="false">

	<cfset var key = "">
	<cfset var i = "">
	<cfset var result="">

	<!--- set default values --->
	<cfif not StructKeyExists(arguments,"scope")>
		<cfset arguments.scope = "one">
	</cfif>

	<cfif not StructKeyExists(arguments,"owner")>
		<cfset arguments.owner = arguments.top>
	</cfif>

	<cfif not StructKeyExists(arguments,"path")>
		<cfset arguments.path = "">
	</cfif>

	<cfif not StructKeyExists(arguments,"results")>
		<cfset arguments.results = CreateObject("java","java.util.ArrayList").init()>
	</cfif>

	<!--- exit if scope is "one" and we have a result --->
	<cfif CompareNoCase(arguments.scope,"one") eq 0
		and ArrayLen(arguments.results) eq 1>

		<cfreturn arguments.results>

	</cfif>

	<!--- recurse or do test depending on type --->
	<cfif IsStruct(arguments.top)>

		<cfloop collection="#arguments.top#" item="key">
			<cfset REStructFindValueNoCase(arguments.top[key],arguments.reg_expression,arguments.scope,arguments.top,"#arguments.path#.#key#",arguments.results)>
		</cfloop>

	<cfelseif IsArray(arguments.top)>

		<cfloop from="1" to="#ArrayLen(arguments.top)#" index="i">
			<cfset REStructFindValueNoCase(arguments.top[i],arguments.reg_expression,arguments.scope,arguments.top,"#path#[#i#]",arguments.results)>
		</cfloop>

	<cfelseif IsSimpleValue(arguments.top)
		and IsStruct(arguments.owner)
		and REFindNoCase(arguments.reg_expression,arguments.top)>

		<cfset result = StructNew()>
		<cfset result["key"] = ListLast(arguments.path,".")>
		<cfset result["owner"] = arguments.owner>
		<cfset result["path"] = arguments.path>
		<cfset ArrayAppend(arguments.results,result)>

	</cfif>

	<cfreturn arguments.results>

</cffunction>

<cfscript>
/**
 * Transforms queries for displaying as columns instead of rows.
 * This UDF is based on the custom tag CF_RowsToColumns created by Nathan Dintenfass and Ben Archibald in February, 2000
 *
 * @param query 	 A ColdFusion query. (Required)
 * @param maxcolumns 	 The maximum number of columns. (Required)
 * @param actualColumnCountVarName 	 The name of the variable to set containing the actual number of columns created. (Required)
 * @return Returns a query.
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 1, March 10, 2010
 */
function rowsToColumns(query,maxColumns,actualColumnCountVarName){
	//make an array of the columns in the incoming query for looping
	var columnArray = listToArray(query.columnlist);
	//make a new query to return based on the columns of the incoming query
	var newQuery = queryNew(query.columnlist);
	//figure out how many rows there will be
	var rows = ceiling(query.recordcount/maxColumns);
	//set up a var to count row we are on
	var onRow = 1;
	//set up a var to count the column we are on
	var onColumn = 0;
	//set up a var to hold the row we want to grab
	var getRow = 0;
	//set up a var to index the outer loop
	var ii = 1;
	//set up a var to index the inner loop
	var zz = 1;
	//if there will be extra columns, make sure no more columns than necessary.  this is necessary to ensure that if you ask for more columns than there are records to fill you know how many there really are!!
	if(ceiling(query.recordcount/rows) LT maxColumns)
		maxColumns = ceiling(query.recordcount/rows);
	//starting on row 1, loop through the recordcount of the original query, putting rows in the new query
	for(ii = 1; ii lte evaluate(rows * maxColumns); ii = ii + 1){
		//increment the column we are now on
		onColumn = onColumn + 1;
		//get the proper row from the original query
		getRow = ((onColumn - 1) * rows) + onRow;
		//now add a row to the newQuery
		queryAddRow(newQuery);
		//loop through the columns, putting the cells into the newQuery
		for(zz = 1; zz lte arraylen(columnArray); zz = zz + 1){
			//if the row we want is lower than than the recordcount, put in the value
			if(getRow LTE query.recordcount)
				querySetCell(newQuery,columnArray[zz],query[columnArray[zz]][getRow]);
			//otherwise, just set it to a blank string
			else
				querySetCell(newQuery,columnArray[zz],"");
		}
		//if the column we are on is the same as the maxColumns, reset the column we are on and increment the row
		if(onColumn EQ maxColumns){
			onColumn = 0;
			onRow = onRow + 1;
		}
	}
	//set the variable for the number of columns!
	setVariable(actualColumnCountVarName,maxColumns);
	//return the new query
	return newQuery;
}
</cfscript>

<cfscript>
/**
 * Converts a structure of arrays into a name/key style structure.
 *
 * @param struct 	 Structure to convert. (Required)
 * @param theKey 	 Struct key used to define new struct. (Required)
 * @param cols 	 Keys to include in new structure. (Optional)
 * @return Returns a structure.
 * @author Casey Broich (cab@pagex.com)
 * @version 1, June 12, 2003
 */
function saTOss(struct,thekey){
	var x = "";
	var i = "";
	var ii = "";
	var new = structnew();
	var cols = structkeyarray(Struct);

	if(arrayLen(arguments) GT 2) cols = listToArray(arguments[3]);

	for(i = 1; i lte arraylen(Struct[thekey]); i = i + 1){
		new[Struct[thekey][i]] = structnew();
		for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
			new[Struct[thekey][i]][cols[ii]] = Struct[cols[ii]][i];
		}
	}
	return new;
}
</cfscript>

<cfscript>
/**
 * This UDF will find the first variable scope that exists for a variable in the list of variable scopes and return its value.
 *
 * @param strVariable 	 Variable to check for. (Required)
 * @param lstScope 	 List of scopes to check. (Required)
 * @param default 	 Default value to use if the variable does not exists. Defaults to an empty string. (Optional)
 * @return Returns any possible value.
 * @author Scott Jibben (scott@jibben.com)
 * @version 1, February 17, 2004
 */
function ScopeCoalesce(strVariable, lstScopes) {
  var vRet = "";
  var nIndex = 1;
  var nLstLen = ListLen(lstScopes);

  // assign the default return if passed in
  If (ArrayLen(Arguments) GTE 3)
    vRet = Arguments[3];

  // loop over the list
  while (nIndex LTE nLstLen) {
    if (IsDefined(ListGetAt(lstScopes, nIndex) & '.' & strVariable)) {
      vRet = Evaluate(ListGetAt(lstScopes, nIndex) & '.' & strVariable);
      break;
    }
    nIndex = nIndex + 1;
  }

  return vRet;
}
</cfscript>

<cfscript>
/**
 * Returns a shifted array at the passed Shift On value.
 *
 * @param inArray 	 Array to shift. (Required)
 * @param shiftOnValue 	 Index to shift. (Required)
 * @return Returns an array.
 * @author Richard Nugen (richard@corporatemedia.com)
 * @version 1, August 16, 2005
 */
function shiftArray(inArray,ShiftOnVal) {
	var tmpArray = arrayNew(1);
	var x = 0;

	for(x=1; x lte arrayLen(inArray); x=x+1) {
		if(inArray[x] EQ ShiftOnVal) { break; }
		else {
			arrayAppend(tmpArray,inArray[x]);
			arrayDeleteAt(inArray,x);
			x=0;
		}
	}

	for(x=1;x lte arrayLen(tmpArray); x=x+1) arrayAppend(inArray,tmpArray[x]);

	return inArray;
}
</cfscript>

<cfscript>
/**
 * Sorts an array of structures on one or more keys.
 *
 * @param arrayToSort 	 Array of structs to sort. (Required)
 * @param sortKeys 	 Array of structs the define the sort. (Required)
 * @param doDuplicate 	 Return a duplicate of the data, not a pointer. Defaults to false. (Optional)
 * @return Returns an array of structs.
 * @author Martijn van der Woud (martijnvanderwoud@orange.nl)
 * @version 0, September 27, 2008
 */
function sortArrayOfStructures(arrayToSort,sortKeys){
	// This function takes three arguments, of which the third is optional

	// The first argument 'arrayToSort' is (obviously) the array to sort. This must be an array that is to be sorted
	// on one or more keys. Keys to be sorted on must contain numbers or strings

	// Sortkeys are specified as stuctures in the second argument 'sortkeys', which is an array
	// sortkey struct must contain the following keys:
	// keyname - string - the name of a key on which to
	// sortorder - string - either "ascending" or "descending"

	//NOTE: By default, the structures in the returned array point to the same memory location
	// as the structures in the argument 'arrayToSort'. After executing this function
	// changing a structure in the returned array thus also changes the corresponding
	// structure in the argument array, and vice versa! If this kind of behavior is unwanted,
	// specify the third argument 'doDuplicate' as true.

	// a struct to hold variables local to this function
	var locals = structNew();

	// by default, return the structs in the array by reference
	if (ArrayLen(Arguments) eq 2)	{
		arguments[3] = false;
	}

	// the array to be returned by this function (now empty)
	locals.arrayToReturn = arrayNew(1);
	// the number of elements in the array that was passed in
	locals.nElements = arrayLen(arguments.arrayToSort);
	// the number of key on which sorting is to take place
	locals.nSortKeys = arrayLen(arguments.sortKeys);

	// for every element in the array that was passed in
	for (locals.i = 1; locals.i lte locals.nElements; locals.i = locals.i + 1) {
		// reference to the data in the current element in 'arrayToSort'
		locals.elementData = arguments.arrayToSort[locals.i];

		// purpose of the code below is to determine on what position the
		// current element is to be put on the array to be returned
		// the position is initialized as 1
		locals.insertPosition = 1;

		// for every element that has been previously put in the array to return
		for (locals.j = 1; locals.j lt locals.i; locals.j = locals.j + 1) {

			// reference to the current element in the array to return
			locals.previousElementData = locals.arrayToReturn[locals.j];

			// boolean used in the loop over sortkeys, to indicate that the loop over
			// elements in the array to return must be broken out of.
			locals.doBreak = false;

			// for every sortkey
			for (locals.k = 1; locals.k lte locals.nSortKeys; locals.k = locals.k + 1) {

				// specifications for the current key
				locals.currentKey = arguments.sortKeys[locals.k];
				locals.currentValue = locals.elementData[locals.currentKey.keyName];

				// value of the current key in the current element in the array to return
				locals.previousValue = locals.previousElementData[locals.currentKey.keyName];

				// boolean indicating if the key-value of the current element in the passed-in array
				// is greater than the key-value in the current element, previously inserted in the array to return
				locals.currentGreater = locals.currentValue gt locals.previousValue;
				// boolean indicating if the key-value in the array to return is greater
				locals.previousGreater = locals.previousValue gt locals.currentValue;

				// boolean indicating if the current element in the array to sort must go
				// BEFORE the previously inserted element in the array to return
				locals.currentFirst =
					(locals.currentGreater AND (locals.currentKey.sortOrder eq "descending"))
					OR (locals.previousGreater AND (locals.currentKey.sortOrder eq "ascending"));

				// boolean indication if the current element in the array to sort must go
				// AFTER the previously inserted element in the array to return
				locals.previousFirst =
					(locals.previousGreater AND (locals.currentKey.sortOrder eq "descending"))
					OR (locals.currentGreater AND (locals.currentKey.sortOrder eq "ascending"));


				// if the element previously inserted in the array to return goes first
				if (locals.previousFirst)
					{
					// 	increment the insertPosition of the element in arrayToSort by one
					locals.insertPosition = locals.insertPosition + 1;
					// break out of the loop over sortkeys
					break;
					}

				// if the current element in the array to sort goes first
				if (locals.currentFirst)
					{
					// indicate that the loop over previously inserted elements in the array to return
					// must be broken out of
					locals.doBreak = true;
					// break out of the loop over sortkeys
					break;
					}
			} // end of loop over sortkeys


			// break out of the loop over previously inserted elements in the array to return,
			// when so indicated by the inner loop (over sortkeys)
			if (locals.doBreak)
				{
				break;
				}

		} //end of loop over elements that were previously put in the array to return


		// at this point locals.insertPosition holds the correct position, where the current
		// element in the array to sort (argument) should be put

		// based on the value of the 'doDuplicate' argument, get either a deep copy or a reference of the
		// data to insert in the array to return
		if (arguments[3]) {
			locals.insertData = duplicate(locals.elementData);
		} else {
			locals.insertData = locals.elementData;
		}

		// if the insertposition is not greater than the current length of the array to return
		if (locals.insertPosition lt locals.i)
			{
			// do an insert into the correct position
			arrayInsertAt(locals.arrayToReturn,locals.insertPosition,locals.insertData);
			}
		else // if not ..
			{
			// do an append
			arrayAppend(locals.arrayToReturn,locals.insertData);
			}
	} // end of loop over elements in the array that was passed in
	return locals.arrayToReturn;
}
</cfscript>

<!---
 Sends a SQL Batch script and reports results.

 @param BathCode 	 Set of SQL statements. (Required)
 @param DSN 	 The Datasource. (Required)
 @param sSep 	 Separator. Defaults to GO. (Optional)
 @return Returns a struct.
 @author Joseph Flanigan (joseph@switch-box.org)
 @version 2, November 9, 2006
--->
<cffunction name="SQLBatcher" access="public" returntype="string" hint="Runs a set of queries based on sql string" output="false">
	<cfargument name="BatchCode" type="string" required="yes">
	<cfargument name="theDSN" type="string" required="yes">
	<cfargument name="sSep" type="string" required="no" default="GO">

	<cfscript>
	var CleanedBatchCode = ReReplaceNoCase(BatchCode, "--.*?\r", "", "all");// clean sql comments
	var arBatchBlocks = ArrayNew(1); // index of each block and it's SQL string
	var separator = REFindNoCase("#arguments.sSep#\r",CleanedBatchCode,1,1); // looks for separators
	var pos = separator.pos[1]; // 0 or position of first separator
	var oldpos = 1;
	var Batch = 0; // count of separator blocks
	var Block = ""; // Code block of SQL
	var sSQL = ""; // string to be returned

	// make sure arguments have length
	if ( (Len(Trim(theDSN)) EQ 0) OR (Len(Trim(CleanedBatchCode)) EQ 0) ) {
		sSQL = "<<<ERROR>>> Invalid parameters";
		return sSQL; // if there is an error stop batcher and return to caller
	}

	// if no separator blocks, just query on the one block
	if(not pos) arBatchBlocks[1] = CleanedBatchCode;
	// loop around the separator blocks to get the code block for each separator
	while(pos gt 0) {
		block = mid(CleanedBatchCode,oldpos,pos-oldpos);
		// only add a block if there are characters in it.
		if (ReFind("[[:alnum:]]",block,1,"False")) arrayAppend(arBatchBlocks,block);
		oldpos = pos + separator.len[1];
		separator = REFindNoCase("#arguments.sSep#\r|$",CleanedBatchCode,oldpos+1,1);
		pos = separator.pos[1];
	}
	</cfscript>

	<!--- build return string --->
	<cfsavecontent variable="sSQL">

	<cfoutput>#Chr(60)#cftransaction#Chr(62)##Chr(10)##Chr(10)#</cfoutput>
		<cfloop index="Batch" from="1" to="#ArrayLen(arBatchBlocks)#" step="1">
			<cfset Block = arBatchBlocks[Batch]>
			<cfif Len(Trim(Block))><cfoutput>#Chr(60)#cfquery name="q#BATCH#" datasource="#Arguments.theDSN#"#Chr(62)##Chr(10)##Trim(PreserveSingleQuotes(Block))##Chr(10)##Chr(60)#/cfquery#Chr(62)##Chr(10)##Chr(10)#</cfoutput></cfif>
		</cfloop>
	<cfoutput>#Chr(60)#/cftransaction#Chr(62)#</cfoutput>
	</cfsavecontent>

	<cfreturn sSQL>
</cffunction>

<!---
 Converts a query of XML generated by MSSQL to readable XML string.

 @param doc 	 Name for root level element. (Required)
 @param qry 	 Query to convert. (Required)
 @return Returns a string.
 @author Russel Brown (russel.brown@universalmind.com)
 @version 1, April 9, 2007
--->
<cffunction name="sqlXMLToCFXML" access="public" output="false" returntype="Any" hint="This function will take a multiple row query result and turn it into a CF XML var.">
      <cfargument name="doc" type="String" required="false" default="xml" />
      <cfargument name="qry" type="Query" required="true" />

      <cfset var x = "" />
      <cfset var y = "" />
      <cfset var retXML = "" />

      <cfset x = listFirst(arguments.qry.columnList)>
      <cfloop index="y" from="1" to="#arguments.qry.recordCount#">
         <cfset retXML = retXML & arguments.qry[x][y]>
      </cfloop>

      <cfset retXML = "<#arguments.doc#>" & retXML & "</#arguments.doc#>">

      <cfreturn retXML>
</cffunction>

<cfscript>
/**
 * This functions helps to quickly build structures, both simple and complex.
 * v2 by Brendan Baldwin brendan.baldwin@gmail.com
 *
 * @param paramN 	 This UDF accepts N optional arguments. Each argument is added to the returned structure. (Optional)
 * @return Returns a structure.
 * @author Erki Esken (erki@dreamdrummer.com)
 * @version 2, August 22, 2007
 */
function struct() { return duplicate(arguments); }
</cfscript>

<cfscript>
/**
 * Blends all nested structs, arrays, and variables in a struct to another.
 *
 * @param struct1 	 The first struct. (Required)
 * @param struct2 	 The second sturct. (Required)
 * @param overwriteflag 	 Determines if keys are overwritten. Defaults to true. (Optional)
 * @return Returns a boolean.
 * @author Raymond Compton (usaRaydar@gmail.com)
 * @version 2, October 30, 2008
 */
function structBlend(Struct1,Struct2) {
	var i = 1;
	var OverwriteFlag = true;
	var StructKeyAr = listToArray(structKeyList(Struct2));
	var Success = true;
  	if ( arrayLen(arguments) gt 2 AND isBoolean(Arguments[3]) ) // Optional 3rd argument "OverwriteFlag"
  		OverwriteFlag = Arguments[3];
		try {
			for ( i=1; i lte structCount(Struct2); i=i+1 ) {
				if ( not isDefined('Struct1.#StructKeyAr[i]#') )  // If structkey doesn't exist in Struct1
					Struct1[StructKeyAr[i]] = Struct2[StructKeyAr[i]]; // Copy all as is.
				else if ( isStruct(struct2[StructKeyAr[i]]) )			// else if key is another struct
					Success = structBlend(Struct1[StructKeyAr[i]],Struct2[StructKeyAr[i]],OverwriteFlag);  // Recall function
				else if ( OverwriteFlag )	// if Overwrite
					Struct1[StructKeyAr[i]] = Struct2[StructKeyAr[i]];  // set Struct1 Key with Struct2 value.
			}
		}
		catch(any excpt) { Success = false; }
	return Success;
}
</cfscript>

<cfscript>
/**
 * Recursive functions to compare structures and arrays.
 * Fix by Jose Alfonso.
 *
 * @param LeftStruct 	 The first struct. (Required)
 * @param RightStruct 	 The second structure. (Required)
 * @return Returns a boolean.
 * @author Ja Carter (ja@nuorbit.com)
 * @version 2, October 14, 2005
 */
function structCompare(LeftStruct,RightStruct) {
	var result = true;
	var LeftStructKeys = "";
	var RightStructKeys = "";
	var key = "";

	//Make sure both params are structures
	if (NOT (isStruct(LeftStruct) AND isStruct(RightStruct))) return false;

	//Make sure both structures have the same keys
	LeftStructKeys = ListSort(StructKeyList(LeftStruct),"TextNoCase","ASC");
	RightStructKeys = ListSort(StructKeyList(RightStruct),"TextNoCase","ASC");
	if(LeftStructKeys neq RightStructKeys) return false;

	// Loop through the keys and compare them one at a time
	for (key in LeftStruct) {
		//Key is a structure, call structCompare()
		if (isStruct(LeftStruct[key])){
			result = structCompare(LeftStruct[key],RightStruct[key]);
			if (NOT result) return false;
		//Key is an array, call arrayCompare()
		} else if (isArray(LeftStruct[key])){
			result = arrayCompare(LeftStruct[key],RightStruct[key]);
			if (NOT result) return false;
		// A simple type comparison here
		} else {
			if(LeftStruct[key] IS NOT RightStruct[key]) return false;
		}
	}
	return true;
}
</cfscript>

<!---
 Like structFindKey except it matches a pattern.

 @param scope 	 Structure to search. (Required)
 @param keyword 	 Keyword to search for. (Required)
 @return Returns an array.
 @author Jeff Gladnick (jeff@greatdentalwebsites.com)
 @version 1, August 25, 2011
--->
<cffunction name="structFindKeyMatch" returntype="array" output="false">
	<cfargument name="scope" type="struct" required="true">
	<cfargument name="keyword" type="string" required="true">

	<cfset var key = "">
	<cfset var i = "">
	<cfset var result = arrayNew(1)>
	<cfset var tempstruct = structNew() />

	<cfloop index="i" list="#StructKeyList(arguments.scope)#" delimiters=",">
		<cfif findNoCase(arguments.keyword,i)>
			<cfset tempstruct[i] = arguments.scope[i]>
			<cfset arrayAppend(result, duplicate(tempstruct)) />
		</cfif>

		<cfset structClear(tempstruct) />
	</cfloop>

	<cfreturn result>

</cffunction>

<cfscript>
/**
 * Returns a key value from the given struct, or a default value.
 *
 * @param theStruct 	 The structure. (Required)
 * @param theKey 	 Key name. (Required)
 * @param defaultValue 	 Default value to use if key does not exist. (Required)
 * @return Returns a value.
 * @author Adam Tuttle (j.adam.tuttle@gmail.com)
 * @version 0, September 9, 2008
 */
function structGetKey(theStruct, theKey, defaultVal){
	if (structKeyExists(arguments.theStruct, arguments.theKey)){
		return arguments.theStruct[arguments.theKey];
	}else{
		return arguments.defaultVal;
	}
}
</cfscript>

<cfscript>
/**
 * Takes a struct of simple values and returns the structure with the values and keys inverted.
 *
 * @param st 	 Structure of simple name/value pairs you want inverted.
 * @return Returns a structure.
 * @author Craig Fisher (craig@altainteractive.com)
 * @version 1, November 13, 2001
 */
function StructInvert(st) {
		var stn=StructNew();
		var lKeys="";
		var nkey="";
		var i=1;
		var eflg=0;
		if (NOT IsStruct(st)) {
			eflg=1;
		}
		else {
			lKeys=StructKeyList(st);
			for (i=1; i LTE ListLen(lKeys); i=i+1) {
				nKey=listgetat(lkeys, i);
				if (IsSimpleValue(st[nKey]))
					stn[st[nKey]]=nKey;
				else {
					eflg=1;
					break;
				}
			}
		}
		if (eflg is 1) {
			writeoutput("Error in <Code>InvertStruct()</code>! Correct usage: InvertStruct(<I>Structure</I>) -- Returns a structure with the values and keys of <I>Structure</I> inverted when <i>Structure</i> is a structure of simple values.");
			return 0;
		}
		else {
			return stn;
		}
	}
</cfscript>

<!---
 Merge two simple structures in one combining keys or creating new ones.

 @param struct1 	 The first struct. (Required)
 @param struct2 	 The second struct. (Required)
 @return Returns a struct.
 @author Marcos Placona (marcos.placona@gmail.com)
 @version 1, March 2, 2006
--->
<cffunction name="structMerge" output="false">
	<cfargument name="struct1" type="struct" required="true">
	<cfargument name="struct2" type="struct" required="true">
	<cfset var ii = "" />

	<!--- Loop over the second structure passed --->
	<cfloop collection="#arguments.struct2#" item="ii">
		<cfif structKeyExists(struct1,ii)>
		<!--- In case it already exists, we just update it --->
			<cfset struct1[ii] = listAppend(struct1[ii], struct2[ii])>
		<cfelse>
		<!--- In all the other cases, just create a new key with the values or list of values --->
			<cfset struct1[ii] = struct2[ii] />
		</cfif>
	</cfloop>
	<cfreturn struct1 />
</cffunction>

<cfscript>
/**
 * Converts a structure of arrays to a CF Query.
 *
 * @param theStruct 	 The structure of arrays you want converted to a query.
 * @return Returns a query object.
 * @author Casey Broich (cab@pagex.com)
 * @version 1, March 27, 2002
 */
function StructOfArraysToQuery(thestruct){
   var fieldlist = structkeylist(thestruct);
   var numrows   = arraylen( thestruct[listfirst(fieldlist)] );
   var thequery  = querynew(fieldlist);
   var fieldname="";
   var thevalue="";
   var row=1;
   var col=1;
   for(row=1; row lte numrows; row = row + 1)
   {
      queryaddrow(thequery);
      for(col=1; col lte listlen(fieldlist); col = col + 1)
      {
	 fieldname = listgetat(fieldlist,col);
	 thevalue  = thestruct[fieldname][row];
	 querysetcell(thequery,fieldname,thevalue);
      }
   }
return(thequery); }
</cfscript>

<cfscript>
/**
 * Converts a structure of arrays to a keyed structure of structs.
 *
 * @param struct 	 Struct to examine. (Required)
 * @param theKey 	 Key in structure to use as new primary key. (Required)
 * @param cols 	 Keys from original structure to use. Defaults to all. (Optional)
 * @return Returns a struct.
 * @author Casey Broich (cab@pagex.com)
 * @version 1, August 2, 2003
 */
function StructOfArraysToStructOfStructs(struct,thekey){
   var i = "";
   var ii = "";
   var new = structNew();
   var value = "";
   var cols = "";

   if(arrayLen(arguments) GT 2) cols = listToArray(arguments[3]);
   else cols = structkeyarray(struct);

   for(i = 1; i lte arraylen(struct[thekey]); i = i + 1){
      new[struct[thekey][i]] = structNew();
      for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
      if(structKeyExists(struct,cols[ii])){
         value = struct[cols[ii]][i];
      }else{
         value = "";
      }
      new[struct[thekey][i]][cols[ii]] = value;
      }
   }
   return new;
}
</cfscript>

<cfscript>
/**
 * Converts a structure of Lists to an Array of structures.
 *
 * @param struct 	 Struct of lists. (Required)
 * @param delim 	 List delimiter. Defaults to a comma. (Optional)
 * @param cols 	 Struct keys to use. Defaults to all. (Optional)
 * @return Returns an array.
 * @author Casey Broich (cab@pagex.com)
 * @version 1, August 2, 2003
 */
function StructOfListsToArrayOfStructs(Struct){
   var delim = ",";
   var theArray = arraynew(1);
   var row = 1;
   var i = "";
   var cols = structkeyarray(Struct);
   var count = 0;
   var value = "";
   var strow = "";

   if(arrayLen(arguments) GT 1) delim = arguments[2];
   if(arrayLen(arguments) GT 2) cols = listToArray(arguments[3]);
   count = listlen(struct[cols[1]],delim);
   if(arraylen(cols) gt 0) {
      for(row=1; row LTE count; row = row + 1){
      strow = structnew();
      for(i=1; i lte arraylen(cols); i=i+1) {
         if(structKeyExists(Struct,cols[i])){
            if(listlen(Struct[cols[i]],delim) gte row){
               value = listgetat(Struct[cols[i]],row,delim);
            }else{
               value = "";
            }
         }else{
            value = "";
         }
         strow[cols[i]] = value;
      }
      arrayAppend(theArray,strow);
      }
   }
   return theArray;
}
</cfscript>

<cfscript>
/**
 * Converts a structure of structures to a CF Query.
 *
 * @param theStruct 	 The structure to translate. (Required)
 * @param primaryKey 	 The query column name to use for the primary key. (Required)
 * @return Returns a query.
 * @author Shawn Seley (shawnse@aol.com)
 * @version 1, June 28, 2002
 */
function StructOfStructuresToQuery(theStruct, primaryKey){
	var primary_key_list   = StructKeyList(theStruct);
	var field_list         = StructKeyList(theStruct[ListFirst(primary_key_list)]);
	var num_rows           = ListLen(primary_key_list);
	var the_query          = QueryNew(primaryKey & "," & field_list);
	var primary_key_value  = "";
	var field_name         = "";
	var the_value          = "";
	var row                = 0;
	var col                = 0;

	for(row=1; row LTE num_rows; row=row+1) {
		QueryAddRow(the_query);
		primary_key_value = ListGetAt(primary_key_list, row);
		QuerySetCell(the_query, primaryKey, primary_key_value);
		for(col=1; col LTE ListLen(field_list); col=col+1) {
			field_name = ListGetAt(field_list, col);
			the_value  = theStruct[primary_key_value][field_name];
			QuerySetCell(the_query, field_name, the_value);
		}
	}

	return(the_query);
}
</cfscript>

<cfscript>
/**
 * Renames a specified key in the specified structure.
 *
 * @param struct 	 The structure to modify. (Required)
 * @param key 	 The key to rename. (Required)
 * @param newkey 	 The new name of the key. (Required)
 * @param allowOverwrite 	 Boolean to determine if an existing key can be overwritten. Defaults to false. (Optional)
 * @return Returns a structure.
 * @author Erki Esken (erki@dreamdrummer.com)
 * @version 1, June 26, 2002
 */
function StructRenameKey(struct, key, newkey) {
	// Allow overwriting existing keys or not?
	var AllowOverWrite = false;
	switch (ArrayLen(Arguments)) {
		case "4":
			AllowOverWrite = Arguments[4];
	}

	// No key or keys are the same? Return.
	if (NOT StructKeyExists(struct, key) OR CompareNoCase(key, newkey) EQ 0)
		return struct;

	if (NOT AllowOverWrite AND StructKeyExists(struct, newkey)) {
		// New key already exists and overwriting is off? Return.
		return struct;
	} else {
		// Duplicate and delete old. Return.
		struct[newkey] = Duplicate(struct[key]);
		StructDelete(struct, key);
		return struct;
	}
}
</cfscript>

<cfscript>
/**
 * Converts struct into delimited key/value list.
 *
 * @param s 	 Structure. (Required)
 * @param delim 	 List delimeter. Defaults to a comma. (Optional)
 * @return Returns a string.
 * @author Greg Nettles (gregnettles@calvarychapel.com)
 * @version 2, July 25, 2006
 */
function structToList(s) {
	var delim = "&";
	var i = 0;
	var newArray = structKeyArray(arguments.s);

	if (arrayLen(arguments) gt 1) delim = arguments[2];

	for(i=1;i lte structCount(arguments.s);i=i+1) newArray[i] = newArray[i] & "=" & arguments.s[newArray[i]];

	return arraytoList(newArray,delim);
}
</cfscript>

<!---
 Adds a row to a query object and populates it with the values of a structure.

 @param query 	 the query to which the struct should be added as a row to (Required)
 @param struct 	 the struct that will be added to the query as a query row (Required)
 @return returns the query with the added row
 @author Brian Rinaldi (brian.rinaldi@gmail.com)
 @version 1, April 25, 2008
--->
<cffunction name="structToQueryRow" output="false" access="public" returntype="query">
	<cfargument name="query" required="true" type="query" />
	<cfargument name="struct" required="true" type="struct" />
	<cfset var item = "" />
	<cfset var returnQ = arguments.query />

	<cfset queryAddRow(arguments.query) />

	<cfloop collection="#arguments.struct#" item="item">
		<cfif listFindNoCase(returnQ.columnList,item)>
			<cfset querySetCell(returnQ,item,arguments.struct[item]) />
		</cfif>
	</cfloop>

	<cfreturn returnQ />
</cffunction>

<cfscript>
/**
 * Converts a structure to a URL query string.
 *
 * @param struct 	 Structure of key/value pairs you want converted to URL parameters
 * @param keyValueDelim 	 Delimiter for the keys/values.  Default is the equal sign (=).
 * @param queryStrDelim 	 Delimiter separating url parameters.  Default is the ampersand (&).
 * @return Returns a string.
 * @author Erki Esken (erki@dreamdrummer.com)
 * @version 1, December 17, 2001
 */
function StructToQueryString(struct) {
  var qstr = "";
  var delim1 = "=";
  var delim2 = "&";

  switch (ArrayLen(Arguments)) {
    case "3":
      delim2 = Arguments[3];
    case "2":
      delim1 = Arguments[2];
  }

  for (key in struct) {
    qstr = ListAppend(qstr, URLEncodedFormat(LCase(key)) & delim1 & URLEncodedFormat(struct[key]), delim2);
  }
  return qstr;
}
</cfscript>

<!---
 Update one structure values with values from another structure for those keys that match.

 @param struct1 	 The structure to be modified. (Required)
 @param struct2 	 The structure to copy values from. (Required)
 @return Returns a structure.
 @author Jorge Loyo (loyoj@fiu.edu)
 @version 1, December 22, 2005
--->
<cffunction name="structUpdateVals" returntype="struct" output="false">
	<cfargument name="struct1" required="yes" type="struct" />
	<cfargument name="struct2" required="yes" type="struct"  />

	<cfloop collection="#struct2#" item="key">
		<cfif structKeyExists(struct1, key)>
			<cfset structUpdate(struct1, key, struct2[key]) />
	</cfif>
	</cfloop>
	<cfreturn struct1 />
</cffunction>

<cfscript>
/**
 * Converts a structure into a key/value pair list.
 *
 * @param struct 	 Structure to list. (Required)
 * @param delimiter 	 Delimiter. Defaults to a comma. (Optional)
 * @return Returns a string.
 * @author Kit Brandner (kit.brandner@serebra.com)
 * @version 1, November 6, 2006
 */
function structValueList(struct) {
	var delimiter = ",";
	var element = 0;
	var kvName = "";
	var kvValue = "";
	var returnList = "";

	if(arrayLen(arguments) gt 1) delimiter = arguments[2];

	if (isStruct(struct)) {
		for (; element lt listLen(structKeyList(struct, delimiter)) ; element=element+1) {
			kvName = listGetAt(structKeyList(struct, delimiter), element+1, delimiter);
			kvValue = "";
			if(isSimpleValue(struct[kvName])) kvValue = struct[kvName];
			returnList = listAppend(returnList, kvName & iif(len(trim(kvValue)) gt 0, de("=" & kvValue), de("")));
		}
	}

	return returnList;
}
</cfscript>

<cfscript>
/**
 * Like structInsert() but does not throw an error if the key exists and you choose not to overwrite.
 *
 * @param structure 	 Struct to be modified. (Required)
 * @param key 	 Key to modify. (Required)
 * @param value 	 Value to use. (Required)
 * @param allowOverwrite 	 Boolean. If false and key exists, value will not be changed. Defaults to false. (Optional)
 * @return Returns yes or no indicating if a change was made.
 * @author Anthony Cooper (ant@bluevan.co.uk)
 * @version 1, May 9, 2003
 */
function structWrite(structure, key, value) {
	var valueWritten = false;
	var allowOverwrite = false;

	if(arrayLen(arguments) gte 4) allowOverwrite = arguments[4];

	if ( structKeyExists( structure, key ) IMP allowOverwrite ) {
		valueWritten = structInsert( structure, key, value, allowOverwrite );
	}
	return yesNoFormat(valueWritten);
}
</cfscript>

<!---
 Convert Structures/Arrays (including embedded) to XML.

 @param input 	 Data to convert into XML. (Required)
 @param element 	 Used to name the root element. (Required)
 @return Returns a string.
 @author Phil Arnold (philip.r.j.arnold@googlemail.com)
 @version 0, September 9, 2009
--->
<cffunction name="toXML" output="false" returntype="String">
	<cfargument name="input" type="Any" required="true" />
	<cfargument name="element" type="string" required="true" />
	<cfscript>
		var i = 0;
		var s = "";
		var s1 = "";
		s1 = arguments.element;
		if (right(s1, 1) eq "s") {
			s1 = left(s1, len(s1)-1);
		}

		s = s & "<#lcase(arguments.element)#>";
		if (isArray(arguments.input)) {
			for (i = 1; i lte arrayLen(arguments.input); i = i + 1) {
				if (isSimpleValue(arguments.input[i])) {
					s = s & "<#lcase(s1)#>" & arguments.input[i] & "</#lcase(s1)#>";
				} else {
					s = s & toXML(arguments.input[i], s1);
				}
			}
		} else if (isStruct(arguments.input)) {
			for (i in arguments.input) {
				if (isSimpleValue(arguments.input[i])) {
					s = s & "<#lcase(i)#>" & arguments.input[i] & "</#lcase(i)#>";
				} else {
					s = s & toXML(arguments.input[i], i);
				}
			}
		} else {
			s = s & XMLformat(arguments.input);
		}
		s = s & "</#lcase(arguments.element)#>";
	</cfscript>
	<cfreturn s />
</cffunction>

<cfscript>
/**
 * Function to translate Macromedia's XML Resource Feed into ColdFusion variables.
 *
 * @param s 	 variable containing the contents of the Macromedia XML feed.  Usually CFHTTP.FileContent (Required)
 * @return Returns an array of structures.
 * @author Jeffry Houser (jeff@farcryfly.com)
 * @version 2, August 12, 2002
 */
function TranslateMacromediaResourceFeed(S) {

	// the current token we are looking at
	var Token = GetToken(S,1,"<>");

	// LoopControl needs to be initialized
	var LoopControl = 1;

	// Initialize the Current Query Row
	var RowNumber = 1;

	// the number of the next token we are looking at
	var NextToken = 2;

	var ResourceStruct = StructNew();

	// Initialize Return Query
	var ResultQuery = QueryNew("Type, Title, Author, URL, ProductName");

	// loop until we are out of tokens
	while(Token is not "/macromedia_resources"){

		switch(Left(Token,7)){

			case "resourc":{
				// if we are getting a resource token, we want to:
				// create a new blank structure
				// and define the structure's type

				// define new structure
				ResourceStruct = StructNew();

				// add the type of entry to the structure
				StructInsert(ResourceStruct, "Type", GetToken(Token,  2, """"));

				// increment next token
				NextToken = NextToken + 1;
				break;
			} // end resource case

			case "/resour":{
				// if we are getting a /resource token, we want to:
				// Create a new row in the query for each product
				// Assuming the structure isn't empty

				// copy existing structure into result array
				if (not StructIsEmpty(ResourceStruct)){

					for (LoopControl = 1 ;
						 LoopControl LTE ArrayLen(ResourceStruct.Products) ;
						 LoopControl = LoopControl+1){

						// add a new row to the query
						RowNumber = QueryAddRow(ResultQuery);

						// populate Query
						QuerySetCell(ResultQuery, "Type", ResourceStruct.Type, RowNumber);
						QuerySetCell(ResultQuery, "Title", ResourceStruct.Title, RowNumber);
						QuerySetCell(ResultQuery, "Author", ResourceStruct.Author, RowNumber);
						QuerySetCell(ResultQuery, "URL", ResourceStruct.URL, RowNumber);
						QuerySetCell(ResultQuery, "ProductName", ResourceStruct.Products[LoopControl], RowNumber);

					}

				}

				// increment next token
				NextToken = NextToken + 1;
				break;
			} // end resource case


			case "title":{
				// if we are getting the title token, then we want to:
				// add the next token to our structure, because that will be our title text
				// increment the 'nexttoken' variable two increments past the end title token

				// add the title to the structure
				StructInsert(ResourceStruct, "Title", GetToken(S,  NextToken+1, "<>"));

				// increment next token
				NextToken = NextToken + 2;

				break;
			} // end title case

			case "author":{
				// if we are getting the author token, then we want to:
				// add the next token to our structure, because that will be our author text
				// increment the 'nexttoken' variable two increments past the end Author token

				// add the title to the structure
				StructInsert(ResourceStruct, "Author", GetToken(S,  NextToken+1, "<>"));

				// increment next token
				NextToken = NextToken + 2;

				break;
			} // end author case


			case "url":{
				// if we are getting the url token, then we want to:
				// add the next token to our structure, because that will be our url text
				// increment the 'nexttoken' variable two increments past the end url token

				// add the title to the structure
				StructInsert(ResourceStruct, "URL", GetToken(S,  NextToken+1, "<>"));

				// increment next token
				NextToken = NextToken + 2;

				break;
			} // end url case

			case "product":{
				// if the case is a product, we want to:
				// Pick out the name from the token and add it to our product array
				// increment the nexttoken variable once

				// if product array doesn't exist, create it
				if (not IsDefined("ResourceStruct.Products")){
					StructInsert(ResourceStruct, "Products", ArrayNew(1));
				}

				// add product name to array
				ArrayAppend(ResourceStruct.Products,GetToken(Token,  2, """"));

				// increment next token
				NextToken = NextToken + 1;

				break;
			} // end product case


//				case "/title","/author","/url"
//				these cases or anything else not defined, we just ignore, but we still wanna get the
// 			next token
			default: {
				Token = GetToken(S,NextToken,"<>");
				NextToken = NextToken + 1;
				break;
			} // end default case
		} // end switch
		Token = GetToken(S,NextToken,"<>");
	} // end while

	return (ResultQuery);
}
</cfscript>

<cfscript>
/**
 * Trim spaces from all records in a query.
 *
 * @param qry 	 The query to trim. (Required)
 * @return Returns a query.
 * @author Giampaolo Bellavite (giampaolo@bellavite.com)
 * @version 1, February 26, 2004
 */
function trimQuery(qry) {
	var col="";
	var i=1;
	var j=1;
	for(;i lte qry.recordCount;i=i+1) {
		for(j=1;j lte listLen(qry.columnList);j=j+1) {
			col=listGetAt(qry.columnList,j);
			querySetCell(qry,col,trim(qry[col][i]),i);
		}
	}
	return qry;
}
</cfscript>

<cfscript>
/**
 * Trims spaces from all keys in a structure.
 * Version 2 by Raymond Camden
 * Version 3 by author - he mentioned the need for isSimpleValue
 *
 * @param st 	 Structure to trim. (Required)
 * @param excludeList 	 List of keys to exclude. (Optional)
 * @return Returns a structure.
 * @author Mike Gillespie (mike@striking.com)
 * @version 3, July 11, 2002
 */
function TrimStruct(st) {
	var excludeList = "";
	var key = "";

	if(arrayLen(arguments) gte 2) excludeList = arguments[2];
	for(key in st) {
		if(not listFindNoCase(excludeList,key) and isSimpleValue(st[key])) st[key] = trim(st[key]);
	}
	return st;
}
</cfscript>

<cfscript>
/**
 * Function to easily create query objects with data types.
 *
 * @param columnData 	 Structure of label/type fields for the query. (Required)
 * @return Returns a query.
 * @author Ryan Stille (ryan@stillnet.org)
 * @version 1, November 16, 2010
 */
function typedQueryNew(columnData) {

	var columnname = "";
	var stringofColumns = "";
	var stringofTypes = "";
	var counter = 0;

	for (columnName in arguments.columnData) {
		counter++;

		stringOfColumns &= columnName;
		stringOfTypes &= arguments.columnData[columnName];
		if (counter NEQ StructCount(arguments.columnData)) {
			stringofColumns &= ", ";
			stringofTypes &= ", ";
			}
		}

	return queryNew(stringofColumns,stringofTypes);

	}
</cfscript>

<cfscript>
/**
 * Returns the type of the variable.
 * Made it cf5/mx compat with use of getFunctionList
 *
 * @param x 	 The data to inspect. (Required)
 * @return Returns a string.
 * @author Jordan Clark (JordanClark@Telus.net)
 * @version 3, August 16, 2002
 */
function TypeOf(x) {
   if(isArray(x)) return "array";
   if(isStruct(x)) return "structure";
   if(isQuery(x)) return "query";
   if(isSimpleValue(x) and isWddx(x)) return "wddx";
   if(isBinary(x)) return "binary";
   if(isCustomFunction(x)) return "custom function";
   if(isDate(x)) return "date";
   if(isNumeric(x)) return "numeric";
   if(isBoolean(x)) return "boolean";
   if( listFindNoCase( structKeyList( GetFunctionList() ), "isXMLDoc" ) AND
isXMLDoc(x)) return "xml";
   if(isSimpleValue(x)) return "string";
   return "unknown";
}
</cfscript>

<cfscript>
/**
 * Returns a list of unique values from a query column.
 *
 * @param queryname 	 Query to scan. (Required)
 * @param columnname 	 Column to use. (Required)
 * @param cs 	 If true, the unique list will check the case of the values. Defaults to false. (Optional)
 * @return Returns a string.
 * @author Nick Giovanni (ngiovanni@gmail.com)
 * @version 1, March 27, 2007
 */
function uniqueValueList(queryName, columnName) {
	var cs = 0;
	var curRow = 1;
	var uniqueList = "";

	if(arrayLen(arguments) GTE 3 AND isBoolean(arguments[3])) cs = arguments[3];

	for(; curRow LTE queryName.recordCount; curRow = curRow +1){
		if((not cs AND not listFindNoCase(uniqueList, trim(queryName[columnName][curRow]))) OR (cs AND not listFind(uniqueList, trim(queryName[columnName][curRow])))){
			uniqueList = ListAppend(uniqueList, trim(queryName[columnName][curRow]));
		}
	}
	return uniqueList;
}
</cfscript>

<!---
 Validate an XML file against a DTD.

 @param xmlUrl 	 File location of the XML document. (Required)
 @param throwOnError 	 Determines if the UDF should throw an error if the XML file doesn't validate. Defaults to false. (Optional)
 @param fileLocktimeout 	 Specifies how long CF should wait to obtain a lock on the file. Defaults to 5. (Optional)
 @return Returns a boolean.
 @author Massimo Foti (massimo@massimocorner.com)
 @version 1, February 18, 2004
--->
<cffunction name="validateXMLFile" output="false" returntype="boolean" hint="Validate an XML file against a DTD">
	<cfargument name="xmlUrl" type="string" required="true" hint="XML document url">
	<cfargument name="throwerror" type="boolean" required="false" default="false" hint="Throw an exception if the document isn't valid">
	<cfargument name="fileLockTimeout" type="numeric" required="false" default="5" hint="Specifies the maximum amount of time, to wait to obtain a lock on the file">
	<cfset var isValid=true>
	<cfset var saxFactory="">
	<cfset var xmlReader="">
	<cfset var eHandler="">
	<!--- Better to be sure the file exist --->
	<cfif NOT FileExists(arguments.xmlUrl)>
		<cfthrow message="validateXMLFile: #arguments.xmlUrl# doesn't exist" type="validateXMLFile">
	</cfif>
	<cftry>
		<cfscript>
		//Call the SAX parser factory
		saxFactory = CreateObject("java","javax.xml.parsers.SAXParserFactory").newInstance();
		//Creates a SAX parser and get the XML Reader
		xmlReader = saxFactory.newSAXParser().getXMLReader();
		//Turn on validation
		xmlReader.setFeature("http://xml.org/sax/features/validation",true);
		//Create an error handler
		eHandler = CreateObject("java","org.apache.xml.utils.DefaultErrorHandler").init();
		//Assign the error handler
		xmlReader.setErrorHandler(eHandler);
		</cfscript>
		<!--- Throw an exception in case any Java initialization failed --->
		<cfcatch type="Object">
			<cfthrow message="validateXMLFile: failed to initialize Java objects" type="validateXMLFile">
		</cfcatch>
	</cftry>
	<cftry>
		<!---
		Since we are reading the file, we better lock it.
		Safer thing to do is to use the file's url as name for the lock
		 --->
		<cflock name="#arguments.xmlUrl#" timeout="#arguments.fileLockTimeout#" throwontimeout="yes" type="readonly">
			<cfset xmlReader.parse(arguments.xmlUrl)>
		</cflock>
		<!--- Catch SAX's exception and set the flag --->
	<cfcatch type="org.xml.sax.SAXParseException">
		<!--- The SAX parser failed to validate the document --->
		<cfset isValid=false>
		<cfif arguments.throwerror>
			<!--- Throw an exception with the error message if required	--->
			<cfthrow message="validateXMLFile: Failed to validate the document, #cfcatch.Message#" type="validateXMLFile">
		</cfif>
	</cfcatch>
	</cftry>
	<!--- Return the boolean --->
	<cfreturn isValid>
</cffunction>

<!---
 Validate a formatted XML string against a DTD.

 @param xmlString 	 XML to validate. (Required)
 @param throwError 	 Determines if the UDF should throw an error if the XML string doesnt validate. Defaults to false. (Optional)
 @param baseURL 	 Needed to resolve url found in the DOCTYPE declaration and external entity references. Format must be: http://www.mydomain.com/xmldirectory/ (Optional)
 @return Returns a boolean.
 @author Massimo Foti (massimo@massimocorner.com)
 @version 1, February 18, 2004
--->
<cffunction name="validateXMLString" output="false" returntype="boolean" hint="Validate a formatted XML string against a DTD">
	<cfargument name="xmlString" type="string" required="true" hint="XML document as string">
	<cfargument name="throwerror" type="boolean" required="false" default="false" hint="Throw an exception if the document isn't valid">
	<cfargument name="baseUrl" type="string" required="false" default="" hint="Needed to resolve url found in the DOCTYPE declaration and external entity references. Format must be: http://www.mydomain.com/xmldirectoty/">
	<cfset var isValid=true>
	<cfset var jStringReader="">
	<cfset var xmlInputSource="">
	<cfset var saxFactory="">
	<cfset var xmlReader="">
	<cfset var eHandler="">
	<cftry>
		<cfscript>
		//Use Java string reader to read the CFML variable
		jStringReader = CreateObject("java","java.io.StringReader").init(arguments.xmlString);
		//Turn the string into a SAX input source
		xmlInputSource = CreateObject("java","org.xml.sax.InputSource").init(jStringReader);
		//Call the SAX parser factory
		saxFactory = CreateObject("java","javax.xml.parsers.SAXParserFactory").newInstance();
		//Creates a SAX parser and get the XML Reader
		xmlReader = saxFactory.newSAXParser().getXMLReader();
		//Turn on validation
		xmlReader.setFeature("http://xml.org/sax/features/validation",true);
		//Add a system id if required
		if(IsDefined("arguments.baseUrl")){
			xmlInputSource.setSystemId(arguments.baseUrl);
		}
		//Create an error handler
		eHandler = CreateObject("java","org.apache.xml.utils.DefaultErrorHandler").init();
		//Assign the error handler
		xmlReader.setErrorHandler(eHandler);
		</cfscript>
		<!--- Throw an exception in case any Java initialization failed --->
		<cfcatch type="Object">
			<cfthrow message="validateXMLString: failed to initialize Java objects" type="validateXMLString">
		</cfcatch>
	</cftry>
	<cftry>
		<cfset xmlReader.parse(xmlInputSource)>
		<!--- Catch SAX's exception and set the flag --->
	<cfcatch type="org.xml.sax.SAXParseException">
		<!--- The SAX parser failed to validate the document --->
		<cfset isValid=false>
		<cfif arguments.throwerror>
			<!--- Throw an exception with the error message if required	--->
			<cfthrow message="validateXMLString: Failed to validate the document, #cfcatch.Message#" type="validateXMLString">
		</cfif>
	</cfcatch>
	</cftry>
	<!--- Return the boolean --->
	<cfreturn isValid>
</cffunction>

<cfscript>
/**
 * Reverses a CF variable into CFScript.
 *
 * @param lObj 	 The object to be recreated in script. (Required)
 * @param lName 	 The name for the object. (Required)
 * @return Returns a string.
 * @author Bert Dawson (bdawson@redbanner.com)
 * @version 1, September 18, 2002
 */
function VarToScript(lObj,lName) {
	var i="";
	var j="";
	var k="";
	var l="";
	var crlf=chr(13) & chr(10);
	var s="";
	var t="";
	var u='",##';
	var v='"",####';

	if (IsStruct(lObj)) {
		s = s & crlf & lName & "=StructNew();";
		for (i IN lObj) {
			if (IsSimpleValue( lObj[i] )) {
				s = s & crlf & lName & "[""" & i & """]=""" & ReplaceList(lObj[i],u,v) & """;";
			} else {
				s = s & varToScript(lObj[i], lName & "[""" & i & """]");
			}
		}

	} else if (IsArray(lObj)) {
		s = s & crlf & lName & "=ArrayNew(1);";
		for(i=1; i LTE ArrayLen(lObj); i=i+1) {
			if (IsSimpleValue( lObj[i] )) {
				s = s & crlf & lName & "[" & i & "]=""" & ReplaceList(lObj[i],u,v) & """;";
			} else {
				s = s & varToScript(lObj[i], lName & "[""" & i & """]");
			}
		}

	} else if (IsQuery(lObj)) {
		l = lObj.columnList;

		s = s & crlf & lName & "=QueryNew(""" & l & """);";
		s = s & crlf & "QueryAddRow(" & lName & ", " & lObj.recordcount & ");";

		for(i=1; i LTE lObj.recordcount; i=i+1) {
			for(j=1; j LTE ListLen(l); j=j+1) {
				k = lObj[ListGetAt(l,j)][i];
				if (IsSimpleValue(k)) {
					s = s & crlf & "QuerySetCell(" & lName & ",""" & ListGetAt(l,j) & """, """ & ReplaceList(k,u,v) & """," & i & ");";
				} else {
					t = "request.var2script_" & Replace(CreateUUID(),'-','_','all');
					s = s & crlf & "QuerySetCell(" & lName & ",""" & ListGetAt(l,j) & """, " & t & "," & i & ");";
					s = varToScript(k, t) & s;
					s = s & crlf & "StructDelete(variables,""#t#"");";
				}
			}
		}

	} else if (IsSimpleValue(lObj)) {
		s = s & crlf & lName & "=""" & ReplaceList(lObj,u,v) & """;";

	} else if (IsCustomFunction(lObj)) {
		s = s & crlf & "/* " & lName & " is a custom fuction, but i can't cfscript it */";

	} else {
		s = s & crlf & "/* " & lName & " - not sure what it is.... */";
	}

	return s;
}
</cfscript>

<cfscript>
/**
 * Produces output used by the vCalendar standard for PIM's (such as Outlook).
 * There are other tags available such as (CF_AdvancedEmail) that will support multi-part mime encoding where the text of the attachment can be imbeded right into the email
 *
 * @param stEvent 	 Structure containg the key/value pairs comprising the vCalendar data.  Keys are shown below:
 * @param stEvent.description 	 Description for the event.
 * @param stEvent.subject 	 Subject of the event.
 * @param stEvent.location 	 Location for the event.
 * @param stEvent.startTime 	 Event's start time in GMT.
 * @param stEvent.endTime 	 Event's end time in GMT.
 * @param stEvent.priority 	 Numeric priority for the event (1,2,3).
 * @return Returns a string.
 * @author Chris Wigginton (cwigginton@macromedia.com)
 * @version 1.1, April 10, 2002
 */
function vCal(stEvent)
{

	var description = "";
	var vCal = "";

	var CRLF=chr(13)&chr(10);

	if (NOT IsDefined("stEvent.startTime"))
		stEvent.startTime = DateConvert('local2Utc', Now());

	if (NOT IsDefined("stEvent.endTime"))
		stEvent.endTime = DateConvert('local2Utc', Now());

	if (NOT IsDefined("stEvent.location"))
		stEvent.location = "N/A";

	if (NOT IsDefined("stEvent.subject"))
		stEvent.subject = "Auto vCalendar Generated";

	if (NOT IsDefined("stEvent.description"))
		stEvent.description = "Autobot VCalendar Generated";

	if (NOT IsDefined("stEvent.priority"))
		stEvent.priority = "1";


	vCal = "BEGIN:VCALENDAR" & CRLF;
	vCal = vCal & "PRODID:-//Microsoft Corporation//OutlookMIMEDIR//EN" & CRLF;
	vCal = vCal & "VERSION:1.0" & CRLF;
	vCal = vCal & "BEGIN:VEVENT" & CRLF;
	vCal = vCal & "DTSTART:" &
			DateFormat(stEvent.startTime,"yyyymmdd") & "T" &
			TimeFormat(stEvent.startTime, "HHmmss") & "Z" & CRLF;
	vCal = vCal & "DTEND:" & DateFormat(stEvent.endTime, "yyyymmdd") & "T" &
			TimeFormat(stEvent.endTime, "HHmmss") & "Z" & CRLF;
	vCal = vCal & "LOCATION:" & stEvent.location & CRLF;
	vCal = vCal & "SUMMARY;ENCODING=QUOTED-PRINTABLE:" & stEvent.subject & CRLF;

	vCal = vCal & "DESCRIPTION;ENCODING=QUOTED-PRINTABLE:";
	// Convert CF_CRLF (13_10) into =0D=0A with CR/LF and indent sequences
	description = REReplace(stEvent.description,"[#Chr(13)##Chr(10)#]", "=0D=0A=#Chr(13)##Chr(10)#     ", "ALL");
	vCal = vCal & description & CRLF;

	vCal = vCal & "PRIORITY:" & stEvent.priority & CRLF;
	vCal = vCal & "END:VEVENT" & CRLF;
	vCal = vCal & "END:VCALENDAR" & CRLF;

	return vCal;

}
</cfscript>

<!---
 Converts an CF XML objects to string without the XML declaration.

 @param xmlDoc 	 Either a XML document or string. (Required)
 @return Returns a string.
 @author Massimo Foti (massimo@massimocorner.com)
 @version 1, August 2, 2003
--->
<cffunction name="xmlDoctoString" output="no" returntype="string" displayname="xmlDoctoString" hint="Extract the root element inside an XML Doc and return it as a string">
	<cfargument name="xmlDoc" type="string" required="true" displayname="xmlDoc" hint="An XML Doc or a well formed XML string">
	<cfset var xmlToParse="">
	<!--- Check to see if the argument is already an XMLDoc --->
	<cfif IsXmlDoc(arguments.xmlDoc)>
		<cfset xmlToParse=arguments.xmlDoc>
	<cfelse>
		<!--- We need a parsed XML doc, not just a simple string --->
		<cftry>
			<cfset xmlToParse=XmlParse(arguments.xmlDoc, "yes")>
			<!--- Failed parsing, the string culd be not a well formed XML, throw an exception --->
			<cfcatch type="Any">
				<cfthrow message="xmlDoctoString: failed to parse argument.xmlDoc" type="xmlDoctoString">
			</cfcatch>
		</cftry>
	</cfif>
	<cfreturn xmlToParse.getDocumentElement().toString()>
</cffunction>

<!---
 Extracts the text of named XML elements and returns it in a list.

 @param inString 	 Either an XML object or a string representation. (Required)
 @param tagName 	 Tag to look for. (Required)
 @param delimiter 	 Delimiter for returned string. Defaults to a comma. (Optional)
 @return Returns a string.
 @author Samuel Neff (sam@serndesign.com)
 @version 1, March 16, 2004
--->
<cffunction name="xmlExtractList" returnType="string" output="no">
   <cfargument name="inString" type="any">
   <cfargument name="tagName" type="string">
   <cfargument name="delim" default=",">

   <cfset var inXML = "">

   <cfset var elementsArray = "">
   <cfset var valuesArray = arrayNew(1)>
   <cfset var i=1>
   <cfset var j=1>
   <cfset var ret = "">

   <cfif isXmlDoc(arguments.inString)>
      <cfset inXML = arguments.inString>
   <cfelse>
      <cfset inXML  = xmlParse(arguments.inString)>
   </cfif>

   <cfset elementsArray = xmlSearch(inXML, "//" & arguments.tagName)>


   <cfloop index="j" from="1" to="#arrayLen(elementsArray)#">
      <cfif elementsArray[j].xmlText neq "">
         <cfset valuesArray[i] = elementsArray[j].xmlText>
         <cfset i=i+1>
      </cfif>
   </cfloop>

   <cfset ret = arrayToList(valuesArray, arguments.delim)>
   <cfreturn ret>
</cffunction>

<cfscript>
/**
 * Merges one xml document into another
 * Fix sent in by Scott Talmsa
 *
 * @param xml1 	 The XML object into which you want to merge (Required)
 * @param xml2 	 The XML object from which you want to merge (Required)
 * @param overwriteNodes 	 Boolean value for whether you want to overwrite (default is true) (Optional)
 * @return void (changes the first XML object)
 * @author Nathan Dintenfass (nathan@changemedia.com)
 * @version 2, October 15, 2008
 */
function xmlMerge(xml1,xml2){
	var readNodeParent = arguments.xml2;
	var writeNodeList = arguments.xml1;
	var writeNodeDoc = arguments.xml1;
	var readNodeList = "";
	var writeNode = "";
	var readNode = "";
	var nodeName = "";
	var ii = 0;
	var writeNodeOffset = 0;
	var toAppend = 0;
	var nodesDone = structNew();
	//by default, overwrite nodes
	var overwriteNodes = true;
	//if there's a 3rd arguments, that's the overWriteNodes flag
	if(structCount(arguments) GT 2)
		overwriteNodes = arguments[3];
	//if there's a 4th argument, it's the DOC of the writeNode -- not a user provided argument -- just used when doing recursion, so we know the original XMLDoc object
	if(structCount(arguments) GT 3)
		writeNodeDoc = arguments[4];
	//if we are looking at the whole document, get the root element
	if(isXMLDoc(arguments.xml2))
		readNodeParent = arguments.xml2.xmlRoot;
	//if we are looking at the whole Doc for the first element, get the root element
	if(isXMLDoc(arguments.xml1))
		writeNodeList = arguments.xml1.xmlRoot;
	//loop through the readNodeParent (recursively) and override all xmlAttributes/xmlText in the first document with those of elements that match in the second document
	for(nodeName in readNodeParent){
		writeNodeOffset = 0;
		//if we haven't yet dealt with nodes of this name, do it
		if(NOT structKeyExists(nodesDone,nodeName)){
			readNodeList = readNodeParent[nodeName];
			//if there aren't any of this node, we need to append however many there are
			if(NOT structKeyExists(writeNodeList,nodeName)){
				toAppend = arrayLen(readNodeList);
			}
			//if there are already at least one node of this name
			else{
				//if we are overwriting nodes, we need to append however many there are minus however many there were (if there none new, it will be 0)
				if(overWriteNodes){
					toAppend = arrayLen(readNodeList) - arrayLen(writeNodeList[nodeName]);
				}
				//if we are not overwriting, we need to add however many there are
				else{
					toAppend = arrayLen(readNodeList);
					//if we are not overwriting, we need to make the offset of the writeNode equal to however many there already are
					writeNodeOffset = arrayLen(writeNodeList[nodeName]);
				}
			}
			//append however many nodes necessary of the name
			for(ii = 1;  ii LTE toAppend; ii = ii + 1){
				arrayAppend(writeNodeList.xmlChildren,xmlElemNew(writeNodeDoc,nodeName));
			}
			//loop through however many of this nodeName there are, writing them to the writeNodes
			for(ii = 1; ii LTE arrayLen(readNodeList); ii = ii + 1){
				writeNode = writeNodeList[nodeName][ii + writeNodeOffset];
				readNode = readNodeList[ii];
				//set the xmlAttributes and xmlText to this child's values
				writeNode.xmlAttributes = readNode.xmlAttributes;
				//deal with the CDATA scenario to properly preserve (though, if it contains CDATA and text nodes, this won't work!!
				if(arrayLen(readNode.xmlNodes) AND XmlGetNodeType(readNode.xmlNodes[1]) is "CDATA_SECTION_NODE"){
					writeNode.xmlCData = readNode.xmlcdata;
				}
				else{
					//modify to check to see if it's cData or not
					writeNode.xmlText = readNode.xmlText;
				}
				//if this element has any children, recurse
				if(arrayLen(readNode.xmlChildren)){
					xmlMerge(writeNode,readNode,overwriteNodes,writeNodeDoc);
				}
			}
			//add this node name to those nodes we have done -- we need to do this because an XMLDoc object can have duplicate keys
			nodesDone[nodeName] = true;
		}
	}
}
</cfscript>

<!---
 Converts valid xml and valid xhtml to json

 @param xml 	 XML to convert. (Optional)
 @param includeFormatting 	 Boolean value that determines if tabs, line feeds, and carriage returns should be preserved. Defaults to false. (Optional)
 @return Returns a string.
 @author Tony Felice (tfelice@reddoor.biz)
 @version 0, February 27, 2009
--->
<cffunction name="xmlToJson" output="false" returntype="any" hint="convert xml to JSON">
		<cfargument name="xml" default="" required="false" hint="raw xml"/>
		<cfargument name="includeFormatting" type="boolean" default="false" required="false" hint="whether or not to maintain and encode tabs, linefeeds and carriage returns"/>
		<cfset var result ="">
		<cfset var xsl ="">
		<cfsavecontent variable="xsl">
			<?xml version="1.0" encoding="UTF-8"?>
			<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="UTF-8" media-type="application/json"/>
				<xsl:strip-space elements="*"/>

				<!-- used to identify unique children in Muenchian grouping, credit Martynas Jusevicius http://www.xml.lt -->
				<xsl:key name="elements-by-name" match="@* | *" use="concat(generate-id(..), '@', name(.))"/>

				<!-- string -->
				<xsl:template match="text()">
					<xsl:call-template name="processValues">
						 <xsl:with-param name="s" select="."/>
					</xsl:call-template>
				</xsl:template>

				<!-- text values (from text nodes and attributes) -->
				<xsl:template name="processValues">
					<xsl:param name="s"/>
					<xsl:choose>
						<!-- number -->
						<xsl:when test="not(string(number($s))='NaN')">
							<xsl:value-of select="$s"/>
						</xsl:when>
						<!-- boolean -->
						<xsl:when test="translate($s,'TRUE','true')='true'">true</xsl:when>
						<xsl:when test="translate($s,'FALSE','false')='false'">false</xsl:when>
						<!-- string -->
						<xsl:otherwise>
							<xsl:call-template name="escapeArtist">
								<xsl:with-param name="s" select="$s"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>

				<!-- begin filter chain -->
				<xsl:template name="escapeArtist">
					<xsl:param name="s"/>
					"
					<xsl:call-template name="escapeBackslash">
						<xsl:with-param name="s" select="$s"/>
					</xsl:call-template>
					"
				</xsl:template>

				<!-- escape the backslash (\) before everything else. -->
				<xsl:template name="escapeBackslash">
					<xsl:param name="s"/>
					<xsl:choose>
						<xsl:when test="contains($s,'\')">
							<xsl:call-template name="escapeQuotes">
								<xsl:with-param name="s" select="concat(substring-before($s,'\'),'\\')"/>
							</xsl:call-template>
							<xsl:call-template name="escapeBackslash">
								<xsl:with-param name="s" select="substring-after($s,'\')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="escapeQuotes">
								<xsl:with-param name="s" select="$s"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>

				<!-- escape the double quote ("). -->
				<xsl:template name="escapeQuotes">
					<xsl:param name="s"/>
					<xsl:choose>
						<xsl:when test="contains($s,'&quot;')">
							<xsl:call-template name="encoder">
								<xsl:with-param name="s" select="concat(substring-before($s,'&quot;'),'\&quot;')"/>
							</xsl:call-template>
							<xsl:call-template name="escapeQuotes">
								<xsl:with-param name="s" select="substring-after($s,'&quot;')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="encoder">
								<xsl:with-param name="s" select="$s"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>

				<!-- encode tab, line feed and/or carriage return-->
				<xsl:template name="encoder">
					<xsl:param name="s"/>
					<xsl:choose>
						<!-- tab -->
						<xsl:when test="contains($s,'&#x9;')">
							<xsl:call-template name="encoder">
								<xsl:with-param name="s" select="concat(substring-before($s,'&#x9;'),'<cfoutput>#iif(arguments.includeFormatting,DE("\t"),DE(" "))#</cfoutput>',substring-after($s,'&#x9;'))"/>
							</xsl:call-template>
						</xsl:when>
						<!-- line feed -->
						<xsl:when test="contains($s,'&#xA;')">
							<xsl:call-template name="encoder">
								<xsl:with-param name="s" select="concat(substring-before($s,'&#xA;'),'<cfoutput>#iif(arguments.includeFormatting,DE("\n"),DE(" "))#</cfoutput>',substring-after($s,'&#xA;'))"/>
							</xsl:call-template>
						</xsl:when>
						<!-- carriage return -->
						<xsl:when test="contains($s,'&#xD;')">
							<xsl:call-template name="encoder">
								<xsl:with-param name="s" select="concat(substring-before($s,'&#xD;'),'<cfoutput>#iif(arguments.includeFormatting,DE("\r"),DE(" "))#</cfoutput>',substring-after($s,'&#xD;'))"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
					</xsl:choose>
				</xsl:template>

				<!-- main handler template
					creates a struct containing: the node text(); struct of attributes; and set a struct key for any node children.
					this template then drills into the children, repeating itself until complete
				-->
				<xsl:template name="processNode">
					{
						"text":
						<xsl:call-template name="escapeArtist">
							<xsl:with-param name="s" select="key('elements-by-name', concat(generate-id(..), '@', name(.)))/text()"/>
						</xsl:call-template>
						,"attributes":{
							<xsl:for-each select="@*">
								<xsl:call-template name="escapeArtist">
									<xsl:with-param name="s" select="name()"/>
								</xsl:call-template>
								:
								<xsl:call-template name="processValues">
									<xsl:with-param name="s" select="."/>
								</xsl:call-template>
								<xsl:if test="position() &lt; count(parent::node()/attribute::*)">
									,
								</xsl:if>
							</xsl:for-each>
						}
						<!-- drill down the tree -->
						<xsl:for-each select="*[generate-id(.) = generate-id(key('elements-by-name', concat(generate-id(..), '@', name(.))))]">
							,
							<xsl:call-template name="escapeArtist">
								<xsl:with-param name="s" select="name()"/>
							</xsl:call-template>
							:
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					}
				</xsl:template>

				<!-- main parser
					basically a node 'loop' - performed once for all matches of *, so once for each node including the root.
					note: this loop has no knowledge of other iterations it may have performed.
				-->
				<xsl:template match="*">
					<!-- determine whether any peers share the node name, so we can spool off into 'array mode' -->
					<xsl:variable name="isArray" select="count(key('elements-by-name', concat(generate-id(..), '@', name(.)))) &gt; 1"/>

					<xsl:if test="count(ancestor::node()) = 1"><!-- begin the root node-->
						{
						<xsl:call-template name="escapeArtist">
							<xsl:with-param name="s" select="name()"/>
						</xsl:call-template>
						:
					</xsl:if>

					<xsl:if test="not($isArray)">
						<xsl:call-template name="processNode">
							<xsl:with-param name="s" select="."/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$isArray">
						[
							<xsl:apply-templates select="key('elements-by-name', concat(generate-id(..), '@', name(.)))" mode="array"/>
						]
					</xsl:if>
					<xsl:if test="count(ancestor::node()) = 1">}</xsl:if><!-- close the root node -->
				</xsl:template>

				<!-- array template called from main parser -->
				<xsl:template match="*" mode="array">
					<xsl:call-template name="processNode">
						<xsl:with-param name="s" select="."/>
					</xsl:call-template>
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:template>

			</xsl:stylesheet>
		</cfsavecontent>
		<cfset xsl = xmlParse(reReplace(xsl,'([\s\S\w\W]*)(<\?xml)','\2','all'))>
		<cfscript>
			result = arguments.xml;
			result = reReplace(result,'([\s\S\w\W]*)(<\?xml)','\2','all');
			result = xmlTransform(trim(result),xsl);
			return result;
		</cfscript>
	</cffunction>

<!---
 Validates an XML file against an XML Schema (XSD).

 @param xmlPath 	 Path to XML file. (Required)
 @param noNamespaceXsdUri 	 Path to XML Schema file. (Required)
 @param namespaceXsdUri 	 Name space. (Required)
 @param parseError 	 Struct to contain error information. (Required)
 @return Returns a boolean.
 @author Samuel Neff (sam@blinex.com)
 @version 1, April 14, 2005
--->
<cffunction name="xsdValidate" returnType="boolean" output="false">
  <cfargument name="xmlPath" type="string">
  <cfargument name="noNamespaceXsdUri" type="string">
  <cfargument name="namespaceXsdUri" type="string">
  <cfargument name="parseError" type="struct">

  <cfscript>
    var parser = createObject("java","org.apache.xerces.parsers.SAXParser");

    var err = structNew();
    var k = "";
    var success = true;

    var eHandler = createObject(
                     "java",
                     "org.apache.xml.utils.DefaultErrorHandler");

    var apFeat = "http://apache.org/xml/features/";
    var apProp = "http://apache.org/xml/properties/";

    eHandler.init();

    if (structKeyExists(arguments, "parseError")) {
       err = arguments.parseError;
     }


    try {
       parser.setErrorHandler(eHandler);

       parser.setFeature(
          "http://xml.org/sax/features/validation",
          true);

       parser.setFeature(
          apFeat & "validation/schema",
          true);

       parser.setFeature(
          apFeat & "validation/schema-full-checking",
          true);

       if (structKeyExists(arguments, "noNamespaceXsdUri") and
           arguments.noNamespaceXsdUri neq "") {

          parser.setProperty(
            apProp & "schema/external-noNamespaceSchemaLocation",
            arguments.noNamespaceXsdUri

          );
        }

       if (structKeyExists(arguments, "namespaceXsdUri") and
           arguments.namespaceXsdUri neq "") {

          parser.setProperty(
            apProp & "schema/external-schemaLocation",
            arguments.namespaceXsdUri
          );
        }


       parser.parse(arguments.xmlPath);
     } catch (Any ex) {
       structAppend(err, ex, true);
       success = false;
     }
  </cfscript>

  <cfreturn success>

</cffunction>

<!---
 Provides CFMX native XSL transformations using Java, with support for parameter pass through and relative &amp;lt;xsl:import&amp;gt; tags.
 Version 1 was by Dan Switzer

 @param xmlSource 	 The XML Source. (Required)
 @param xslSource 	 The XSL Source. (Required)
 @param stParameters 	 XSL Parameters. (Optional)
 @return Returns a string.
 @author Mark Mandel (mark@compoundtheory.com)
 @version 2, January 16, 2006
--->
<cffunction name="xslt" returntype="string" output="No">
	<cfargument name="xmlSource" type="string" required="yes">
	<cfargument name="xslSource" type="string" required="yes">
	<cfargument name="stParameters" type="struct" default="#StructNew()#" required="No">

	<cfscript>
		var source = "";		var transformer = "";	var aParamKeys = "";	var pKey = "";
		var xmlReader = "";		var xslReader = "";		var pLen = 0;
		var xmlWriter = "";		var xmlResult = "";		var pCounter = 0;
		var tFactory = createObject("java", "javax.xml.transform.TransformerFactory").newInstance();

		//if xml use the StringReader - otherwise, just assume it is a file source.
		if(Find("<", arguments.xslSource) neq 0)
		{
			xslReader = createObject("java", "java.io.StringReader").init(arguments.xslSource);
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init(xslReader);
		}
		else
		{
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init("file:///#arguments.xslSource#");
		}

		transformer = tFactory.newTransformer(source);

		//if xml use the StringReader - otherwise, just assume it is a file source.
		if(Find("<", arguments.xmlSource) neq 0)
		{
			xmlReader = createObject("java", "java.io.StringReader").init(arguments.xmlSource);
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init(xmlReader);
		}
		else
		{
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init("file:///#arguments.xmlSource#");
		}

		//use a StringWriter to allow us to grab the String out after.
		xmlWriter = createObject("java", "java.io.StringWriter").init();

		xmlResult = createObject("java", "javax.xml.transform.stream.StreamResult").init(xmlWriter);

		if(StructCount(arguments.stParameters) gt 0)
		{
			aParamKeys = structKeyArray(arguments.stParameters);
			pLen = ArrayLen(aParamKeys);
			for(pCounter = 1; pCounter LTE pLen; pCounter = pCounter + 1)
			{
				//set params
				pKey = aParamKeys[pCounter];
				transformer.setParameter(pKey, arguments.stParameters[pKey]);
			}
		}

		transformer.transform(source, xmlResult);

		return xmlWriter.toString();
	</cfscript>
</cffunction>

<cfscript>
/**
 * Processes an XSL Template against an XML document and returns the transformed content.
 *
 * @param Source 	 XML Source (Required)
 * @param Style 	 XML Stylesheet (Required)
 * @return Returns the XML data with formatting.
 * @author Joshua Miller (josh@joshuasmiller.com)
 * @version 1, September 20, 2004
 */
function xsltcf5(source,style){
	// Instantiate COM Objects
	var objSource=CreateObject("COM", "Microsoft.XMLDOM", "INPROC");
	var objStyle=CreateObject("COM", "Microsoft.XMLDOM", "INPROC");
	var sourceReturn = "";
	var styleReturn = "";
	var styleRoot = "";
	var xsloutput = "";
	// Parse XML
	objSource.async = "false";
	sourceReturn = objSource.load("#source#");
	// Parse XSL
	objStyle.async = "false";
	styleReturn = objStyle.load("#style#");
	// Transform Document
	styleRoot = objStyle.documentElement;
	xsloutput = objSource.transformNode(styleRoot);
	// Output Results
	return xsloutput;
}
</cfscript>






