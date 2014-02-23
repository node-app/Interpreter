# Interpreter [![Build Status](https://travis-ci.org/node-app/Interpreter.png?branch=master)](https://travis-ci.org/node-app/Interpreter) [![Gitter chat](https://badges.gitter.im/node-app/Interpreter.png)](https://gitter.im/node-app/Interpreter)

This is an example project implementing a Node.JS interpreter as an iOS app, utilising the [Nodelike](https://github.com/node-app/Nodelike) framework.

Nodelike is a project to implement a roughly Node.JS-compatible interface using JavaScriptCore.framework on iOS 7 and OS X Mavericks.

(JavaScriptCore hasn't been available before iOS 7, and on OS X the project makes extensive use of the newly-updated 10.9-only Objective-C API. Previously on 10.8 there existed only a very low-level and very verbose C API.)

This is currently in a very incomplete state. It could, however, become usable over the following weeks.

![demo time](https://raw.github.com/node-app/Interpreter/master/demo.png)

The goals
---------
- to be _drop-in compatible_ with the current nodejs master
- to be _very lightweight_
- to _reuse javascript code from node_ (/lib)
- to provide the _most minimal binding_ that is possible (via libuv)
- NOT to achieve Node.js performance (this is meant as a client-side, not a server-side application)
- NOT to be backwards-compatible (nodejs cutting edge and newest iOS/OS X required)

What's working right now
------------------------

- `console.log()`
- `process`: `.argv`, `.env`, `.exit()`, `.nextTick()`
- `require()` for native modules
- `fs`
- `net`
- `http`
- `timers`
- `util`
- `url`
- `events`
- `path`
- `stream`
- `querystring`
- `punycode`
- `assert`

How to compile
--------------

1. You need to have [CocoaPods](http://cocoapods.org) installed. If you do not have already, run `sudo gem install cocoapods`.
2. Install the dependencies via `pod install`.
3. Open `Interpreter.xcworkspace` in Xcode and run!

How to use the app
------------------

You can enter Javascript code into the TextView and execute that via a tap on the `Execute` button.
After each execution, when the result of the executed script is not undefined, a popover will appear containing that result.

Have fun!
