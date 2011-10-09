(function($) {

	// Modernizr.csstransforms3d = false;
	// $('html').removeClass('csstransforms3d');
	$.support.csstransforms3d = Modernizr.csstransforms3d;

	if (/chrome/.test(navigator.userAgent.toLowerCase())) {
		$.browser.chrome = true;
		$.browser.safari = false;
	}

	$.getId = function(element) {
		var id = $(element).attr('id'),
			match;
		if ((id !== undefined) && (match = id.match(/\d{1,}$/))) match = match[0];
		return match;
	};

})(jQuery)
