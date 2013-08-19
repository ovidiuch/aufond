function resetHeightInContent(content) {
    return content.replace(/class="content" style=".+?"/,
                           'class="content" style="height: auto;"');
}

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
        // XXX the print display for the contact links differs in height so the
        // already set height for the container from JS logic must be removed
        page.setContent(resetHeightInContent(page.content), url);
        window.setTimeout(function () {
            page.render(output);
            phantom.exit();
        }, 200);
    }
});
