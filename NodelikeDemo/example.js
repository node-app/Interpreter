log("hello world");

module.exports = function () {

    var net = require('net');

    var server = net.createServer(function (c) {
        log('server connect');
        c.on("data", function (data) {
            log("data: " + data.toString());
        });
    });

    server.listen(5000);
    
    /*var con = net.createConnection({port:5000}, function () {
        log('client connect');
        con.write('hello world');
    });*/

};