var page = require('webpage').create(),
    system = require('system');

var url = system.args[1];
var output = system.args[2];

page.viewportSize = {width: 800, height: 800};
page.paperSize = {format: 'A4'};

page.open(url, function (status) {
    if (status !== 'success') {
        console.log('Unable to load the address ' + url + '!');
        phantom.exit();
    } else {
        var jQueryExternalUrl = "http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js";
        page.includeJs(jQueryExternalUrl, function() {
            page.evaluate(function() {
                // XXX PhantomJS does not yet work with Google Web Fonts, so we
                // need to remove the external link altogether. They need to be
                // installed on the local machine in order to work
                $('#google-fonts-link').remove();
                // XXX the print display for the contact links differs in
                // height so the already set height for the container from JS
                // logic must be removed
                $('.header .content').css('height', 'auto');
            });
            window.setTimeout(function () {
                page.render(output);
                phantom.exit();
            }, 1000);
        });
    }
});
