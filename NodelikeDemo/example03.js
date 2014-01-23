var http = require('http');

module.exports = function () {

    http.createServer(function (req, res) {
        res.statusCode = 200;
        res.write(new Buffer("PONG!"));
        res.end();
    }).listen(5000);
    
    http.get("http://localhost:5000/", function(res) {
        log("Got response: " + res.statusCode);
        res.on("data", function (data) {
            log("Got data: " + data);
        });
    }).on('error', function(e) {
        log("Got error: " + e.message);
    });

};