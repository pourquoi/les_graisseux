const path = require('path');
const mjml2html = require('mjml');
const glob = require('glob');
const fs = require('fs');

glob(path.join(__dirname, "../templates/**/*.mjml.twig"), {}, function (er, files) {
    var i;
    for(i=0; i<files.length; i++) {
        var file = files[i];
        fs.readFile(files[i], 'utf8', function (err,data) {
            if (err) {
                return console.log(err);
            }
            var compiled = mjml2html(data);
            console.log(file);

            var dir = path.dirname(file);
            var filename = path.basename(file).replace('mjml', 'html');

            fs.writeFile(path.join(dir, filename), compiled.html, function(err) {
                if (err) {
                    console.log(err);
                }
            });
        });
    }
    // files is an array of filenames.
    // If the `nonull` option is set, and nothing
    // was found, then files is ["**/*.js"]
    // er is an error object or null.
});