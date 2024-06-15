---
layout: post
title: "Node.js dependency injection"
date: 2013-06-28 19:12
comments: true
permalink: /:year/:month/:title/
categories: programming
tags: testing patterns
versions:
  node: 0.10.12
  javascript: ES5
---

Early in my [Node.js][node] adventures, I started asking myself how to write
real unit tests with mocked dependencies. Let's take a slightly modified Hello
World example:

```js
var http = require('http');

exports.start = function() {

  http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello World\n');
  }).listen(1337, '127.0.0.1');
};
```

{% img right /assets/contents/patterns/di-unit-test.png 285 %}

Imagine this is a unit of your app responsible for creating an HTTP server and
listening on port 1337. It exports a start method which does this.

To write isolated unit tests, you need to mock the server. Your tests will run
much faster against a mock HTTP server. It makes little difference for this
small example, but the gain will be significant for a more complex module that
makes many HTTP calls.

<br style="clear:both;" />

<!-- more -->

## Using a mock library for modules

I found several Node.js modules that can do this, such as
[sandboxed-module][sandboxed-module] or [mockery][mockery]. For example,
**sandboxed-module** can require your module in a way that allows you to supply
mocks for its own requires:

```js
var sandbox = require('sandboxed-module');

// Create a mock http module.
var httpMock = {

  createServer : function() {
    return createMockObject();
  }
};

// Require the module you wish to test.
var module = sandbox.require('./module', {

  requires : {
    // Use a mock HTTP server.
    http : httpMock
  }
});

// Test the module with mocked dependencies...
```

When the module you're testing requires `http`, it will be given the mock
instead of the real thing.

I was happy with this until I found out that it sometimes breaks things. I
recently had tests failing for no apparent reason with sandboxed-module
requiring one of my modules that uses [async][async]. It seems that they don't
play nice with each other.

## Manual dependency injection

You can always roll your own dependency injection. Note that there are
[dependency injection modules][di-modules] out there. I just didn't deem it
necessary to restructure my application to use those when it's so easy to do.

Here's how you could do it:

```js
// To use this module, call the exported inject function
// with an object of dependencies.
exports.inject = function(deps) {

  var http = deps.http;

  // Construct and return a module with the provided
  // dependencies.
  return {

    start : function() {

      // The core code hasn't changed. It's just using
      // the provided http module which could be either
      // the real module or a mock.
      http.createServer(function (req, res) {
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.end('Hello World\n');
      }).listen(1337, '127.0.0.1');
    }
  };
};
```

By passing dependencies to the `inject` function, you can easily swap
implementations:

```js
var myModuleForProduction = require('./module').inject({
  http : require('http')
});

var myModuleForTesting = require('./module').inject({
  http : httpMock
});
```

It can also be made easier to use by including default dependencies in the
`inject` function:

```js
exports.inject = function(deps) {
  deps = deps || {};

  // Use the real http module if none is provided.
  var http = deps.http || require('http');

  return {

    start : function() {

      http.createServer(function (req, res) {
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.end('Hello World\n');
      }).listen(1337, '127.0.0.1');
    }
  };
};
```

This simplifies production usage:

```js
var myModuleForProduction = require('./module').inject();

var myModuleForTesting = require('./module').inject({
  http : httpMock
});
```

May your unit tests be swift.

## Meta

* [Do I need dependency injection in Node.js? (Stack Overflow)](http://stackoverflow.com/questions/9250851/do-i-need-dependency-injection-in-nodejs-or-how-to-deal-with)
* [Dependency Injection with Node.js (diogogmt)](http://diogogmt.wordpress.com/2013/04/02/dependency-injection-with-node-js/)
* [Inversion of Control and Dependency Injection with Broadway (nodejitsu)](http://blog.nodejitsu.com/ioc-and-dependency-injection-with-broadway)

[async]: https://github.com/caolan/async
[di-modules]: https://github.com/joyent/node/wiki/modules#wiki-dependency-injection
[mockery]: https://github.com/mfncooper/mockery
[node]: http://nodejs.org
[sandboxed-module]: https://github.com/felixge/node-sandboxed-module
