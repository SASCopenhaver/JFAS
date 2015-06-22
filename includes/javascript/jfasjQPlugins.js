// jfasjQPlugins.js
// see http://learn.jquery.com/plugins/basic-plugin-creation/

(function( $ ) {

    $.fn.showLinkLocation = function() {

        this.filter( "a" ).append(function() {
            return " (" + this.href + ")";
        });

        return this;

    };

}( jQuery ));


(function ( $ ) {
	// sample call: $(".bannerLogoutNav").greenify({'color':'blue', backgroundColor: "red"});

    $.fn.greenify = function( options ) {

        // This is the easiest way to have default options.
        var settings = $.extend({
            // These are the defaults.
            color: "#556b2f",
            backgroundColor: "white"
        }, options );

        // Greenify the collection based on the settings variable.
        return this.css({
            color: settings.color,
            backgroundColor: settings.backgroundColor
        });

    };

}( jQuery ));