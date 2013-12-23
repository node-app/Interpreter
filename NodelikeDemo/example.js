log("hello world");

module.exports = function () {

    var net = require('net');

    var server = net.createServer(function (c) {
        log('connect');
        c.on("data", function (data) {
            log("data: " + data.toString());
        });
    });

    server.listen(5000);

};