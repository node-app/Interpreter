NodelikeDemo
============

Nodelike is a weekend hack to implement a roughly Node.JS-compatible interface using JavaScriptCore.framework on iOS 7 and OS X Mavericks.

(JavaScriptCore hasn't been available before iOS 7, and on OS X the project makes extensive use of the newly-updated 10.9-only Objective-C API. Previously on 10.8 there existed only a very low-level and very verbose C API.)

This is currently in a very incomplete state, and not viable for serious use.
It could, however, become usable over the following weeks.

![demo time](http://nodeapp.org/demo.gif)

The goals
---------
- to be _drop-in compatible_ with the current nodejs master
- to be _very lightweight_
- to _reuse javascript code from node_ (/lib)
- to provide the _most minimal binding_ that is possible (via libuv)
- NOT to archieve Node.js performance (this is meant as a client-side, not a server-side application)
- NOT to be backwards-compatible (nodejs cutting edge and newest iOS/OS X required)

How to compile the demo app
---------------------------

You first need to fetch the nodejs submodule. Do so by:
1. `git submodule init`
2. `git submodule update`

Afterwards, just open `NodelikeDemo.xcodeproj`, build the app and you're all set!

How to use the demo app
-----------------------

You can enter Javascript code into the TextView and execute that via a tap on the `Execute` button.
After each execution, when the result of the executed script is not undefined, a popover will appear containing that result.

Have fun!

What's working right now
------------------------

- `process`: `.cwd()`, `.chdir()`, `.argv`, `.env`, `.exit()`, `.nextTick()`
- `require()` for native modules
- `fs`: `open`, `close`, `readdir`
- `util`
- `url`
- `events`
- `path`
- `stream`
- `querystring`
- `punycode`
- `assert`
