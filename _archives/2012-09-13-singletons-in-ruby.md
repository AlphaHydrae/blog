---
layout: post
title: "Singletons in Ruby"
date: 2012-09-13 09:29
comments: true
permalink: /:year/:month/:title/
categories: programming
tags: singleton patterns
versions:
  ruby: 1.9.3
---

```ruby
require 'singleton'

class MySingletonClass
  include Singleton
end

MySingletonClass.instance   #=> the singleton instance
MySingletonClass.new        #=> NoMethodError
```

I love dynamic languages.

See [Ruby's `Singleton` module][ruby-singleton] for more information.

[ruby-singleton]: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html
