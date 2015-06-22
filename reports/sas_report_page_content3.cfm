<style type="text/css">
/*
    #group-toggle{
        margin: 0 0 1em 20px;		
	}
	#mainContent #formUlfberht .ui-accordion-content legend{
		display: none;
	}
*/

    $(function() {
        $( "#accordion" ).accordion({
            collapsible: true
        });
    });

</style>
<div id="mainContent">
<aside>

<div id="accordion">
    <h3>Section 1</h3>
    <div>
        <p>Mauris mauris ante, blandit et, ultrices a, suscipit eget, quam. Integer ut neque. Vivamus nisi metus, molestie vel, gravida in, condimentum sit amet, nunc. Nam a nibh. Donec suscipit eros. Nam mi. Proin viverra leo ut odio. Curabitur malesuada. Vestibulum a velit eu ante scelerisque vulputate.</p>
    </div>
    <h3>Section 2</h3>
    <div>
        <p>Sed non urna. Donec et ante. Phasellus eu ligula. Vestibulum sit amet purus. Vivamus hendrerit, dolor at aliquet laoreet, mauris turpis porttitor velit, faucibus interdum tellus libero ac justo. Vivamus non quam. In suscipit faucibus urna. </p>
    </div>
    <h3>Section 3</h3>
    <div>
        <p>Nam enim risus, molestie et, porta ac, aliquam ac, risus. Quisque lobortis. Phasellus pellentesque purus in massa. Aenean in pede. Phasellus ac libero ac tellus pellentesque semper. Sed ac felis. Sed commodo, magna quis lacinia ornare, quam ante aliquam nisi, eu iaculis leo purus venenatis dui. </p>
        <ul>
            <li>List item one</li>
            <li>List item two</li>
            <li>List item three</li>
        </ul>
    </div>
    <h3>Section 4</h3>
    <div>
        <p>Cras dictum. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Aenean lacinia mauris vel est. </p><p>Suspendisse eu nisl. Nullam ut libero. Integer dignissim consequat lectus. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. </p>
    </div>
</div>

<div class="demo-description">
<p>By default, accordions always keep one section open. To allow for all sections to be be collapsible, set the <code>collapsible</code> option to true. Click on the currently open section to collapse its content pane.</p>
</div>	
	

<!---
<h1>Budget Authority Requirements</h1>
	<div id="divBAR">
        <h3>Budget Authority Requirements (by AAPP)</h3>		
		<fieldset id="fsBAR">
			<legend><strong>Budget Authority Requirements (by AAPP)</strong></legend>
			<p>
				<label for="selStatus">Status</label>
				<select id="selStatus">
					<option value="A" selected="true">Active</option>
					<option value="I">Inctive</option>
					<option value="AI">All</option>
				</select>
			</p>
			
			<legend><strong>Funding Offices</strong></legend>
            <p>
                <label for="selFundOffice1">Funding Office</label>
                <select id="selFundOffice1">
                    <option value="-1" selected="true">Select Fund. Office</option>
                    <option value="B">Boston</option>
                    <option value="P">Phila</option>
                </select>
            </p>
			
			<legend><strong>Report Format</strong></legend>
            <p>
			     <label for="rbtReptFormat1">Report Format</label>
				 <input type="radio" id="rbtReptFormat1" name="rbtReptFormat1" value="PDF" checked="true" >PDF
                 <input type="radio" id="rbtReptFormat1" name="rbtReptFormat1" value="HTML">HTML
				 <input type="radio" id="rbtReptFormat1" name="rbtReptFormat1" value="MSEXCEL">MS Excel
			</p>
		</fieldset>
	</div>
	
    <div id="divRR">
    	<h3>Reconciliation Reports</h3>
		<fieldset id="fsRR">
			
            <legend><strong>Funding Offices</strong></legend>
            <p>
                <label for="selFundOffice2">Funding Office</label>
                <select id="selFundOffice2">
                    <option value="-1" selected="true">Select Fund. Office</option>
                    <option value="B">Boston</option>
                    <option value="P">Phila</option>
                </select>
            </p>
            
            <legend><strong>Report Format</strong></legend>
            <p>
                 <label for="rbtReptFormat2">Report Format</label>
                 <input type="radio" id="rbtReptFormat2" name="rbtReptFormat2" value="PDF" checked="true">PDF
                 <input type="radio" id="rbtReptFormat2" name="rbtReptFormat2" value="HTML">HTML
                 <input type="radio" id="rbtReptFormat2" name="rbtReptFormat2" value="MSEXCEL">MS Excel
            </p>			
			
		</fieldset>
    </div>	
--->
</aside>
<article>
	article
</article>
</div>

<script>
'use strict';
jQuery(document).ready(function($){
	console.log('SAS msg.');
});



$(document).ready(function(){
	   $('#divBAR').accordion({'heightStyle': 'content'});
	}

);

	
	
</script>


