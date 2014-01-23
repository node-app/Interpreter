module.exports = function () {
    
    var fs = require("fs");
    
    fs.readdir("/", function (err, dir) {
        if (err) return log(err);
        log(dir);
    });
    
};