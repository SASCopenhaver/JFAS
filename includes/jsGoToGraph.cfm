<cfoutput>
<script>
// this is JS
function GoToAAPPGraph (cmd, sWindowName) {
	//alert('In GoToAAPPGraph cmd: ' + cmd + ' sWindowName: ' + sWindowName);
	// second argument is name of the window. SOME urls opened this way will use this as the TAB TITLE
	// third parameter can control whether the new window is part of the original browser (in a tab), or not. For example, if there is a window height, width given, it will be in a new window. NOT USING IT will let the window join the tabs

	//alert('in GoToAAPPGraph');
	//alert('cmd is ' + cmd);
	var sParameters = 'width=1024,height=800,scrollbars=yes'; // sample
	sParameters = '';
	// The sWindowName must be '_blank' for ie in emulation mode. WE ARE NOT USING EMULATION MODE.
	// Third parameter should be empty string
	// sWindowName cannot have a blank in ie8
	sWindowName = replaceAll(' ', '', sWindowName);
	var sWindow = window.open( '#application.urls.root#graphics/'+cmd, sWindowName, sParameters );
	//sWindow.name = sWindowName;

	// works on Chrome, but shows flashing Tab in ie. ie does this whether or not focus() is called, which is just warning you that the page has changed (ok)
	sWindow.focus();
}
</script>
</cfoutput>

