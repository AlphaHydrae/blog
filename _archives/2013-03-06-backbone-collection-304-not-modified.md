---
layout: post
title: "Backbone Collection 304 Not Modified"
date: 2013-03-06 20:23
comments: true
permalink: /:year/:month/:title/
categories: programming
tags: http etag
versions:
  javascript: ES5
  backbone: 0.9.x
---

I'm using conditional requests with [ETags][etag] in my latest Rails app to cut
down on bandwidth. I noticed that when my Backbone collections got a `304 Not
Modified` response, they kept being emptied, which is not nice.

After a little research, I found a way to modify them to re-use the same data
after receiving a 304.

```js
var CustomCollection = Backbone.Collection.extend({

  parse : function(models, options) {

    // Copy previous models array on HTTP 304 Not Modified.
    // The slice call is required to avoid the array being
    // emptied by reference.
    if (options.xhr.status == 304) {
      return this.models.slice();
    }

    return models;
  }
});
```

Note that the collection will still trigger a reset event with this technique.

This solution was inspired by the following Stack Overflow post: [*Backbone.js
parse not modified
response*](http://stackoverflow.com/questions/11114127/backbone-js-parse-not-modified-response).

[backbone]: https://backbonejs.org
[etag]: https://en.wikipedia.org/wiki/HTTP_ETag
