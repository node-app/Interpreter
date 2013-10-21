log("hello world");

global.Buffer = require("buffer").Buffer;

try {

    var net = require('net');
    var server = net.createServer(function (c) {
        log('connect');
    });
    server.listen(5000);

} catch(e) {
    log(e.toString())
}