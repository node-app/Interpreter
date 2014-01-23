module.exports = function () {

var eventemitter = require('events').EventEmitter,
    timers       = require('timers');

var e = new eventemitter()

e.on("hello", function () {
    log("Hello!")
});

e.on("world", function () {
    log("World!")
});

timers.setTimeout(function () {
    e.emit('hello');
}, 5000);

timers.setTimeout(function () {
    e.emit('world');
}, 10000);

};