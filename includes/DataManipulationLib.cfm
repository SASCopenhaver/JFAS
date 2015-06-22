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
	//get the column names into an array by looking at the first record
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
