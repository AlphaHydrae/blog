---
layout: post
title: "Backbone Collection 304 Not Modified"
date: 2013-03-06 20:23
comments: true
categories: [javascript,backbone,http,etag]
---

I'm using conditional requests with [ETags](http://en.wikipedia.org/wiki/HTTP_ETag) in my latest Rails app to cut down on bandwidth. I noticed that when my Backbone collections got a 304 Not Modified response, they kept being emptied, which is not nice.

After a little research, I found a way to modify them to re-use the same data after receiving a 304.

{% codeblock lang:ruby %}
var CustomCollection = Backbone.Collection.extend({

  parse : function(models, options) {

    # Copy previous models array on HTTP 304 Not Modified.
    # The slice call is required to avoid the array being emptied by reference.
    if (options.xhr.status == 304) {
      return this.models.slice();
    }

    return models;
  }
});
{% endcodeblock %}

Note that the collection will still trigger a reset event with this technique.

* [**Backbone.js:**](http://rubyonrails.org) 0.9.10
* **Source:** [Stack Overflow: Backbone.js parse not modified response](http://stackoverflow.com/questions/11114127/backbone-js-parse-not-modified-response)
