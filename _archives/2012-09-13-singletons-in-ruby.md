---
layout: post
title: "Singletons in Ruby"
date: 2012-09-13 09:29
comments: true
categories: [ruby, singleton, patterns]
permalink: /:year/:month/:title/
---

Here's how:

{% highlight ruby %}
require 'singleton'

class MySingletonClass
  include Singleton
end

MySingletonClass.instance   #=> the singleton instance
MySingletonClass.new        #=> NoMethodError
{% endhighlight %}

I love dynamic languages.

[http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html)
