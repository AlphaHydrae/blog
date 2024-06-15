---
layout: post
title: "Ruby Configuration DSL"
date: 2012-09-13 09:32
comments: true
permalink: /:year/:month/:title/
categories: programming
tags: dsl
versions:
  ruby: 1.9.3
---

I had been wondering how that kind of Ruby magic works for some time.

```bash
MyClass.new.configure do
  name "the best class"
  purpose "to kick ass"
  tags "ruby", "configuration", "dsl"
end
```

<!--more-->

You have to be willing to use the nasty sounding `instance_eval` method. It's
scary but trivial:

```ruby
def MyClass

  def configure &block
    # The block will be called with the
    # MyClass instance as self.
    instance_eval &block
  end

  def name value
    @name = value
  end

  def purpose value
    @purpose = value
  end

  def tags *args
    @tags = args
  end
end
```

Note that you can also make your own DSL configuration file (like unicorn) using
the same technique:

```ruby
# File: /my/project/config.rb
name "my configuration"
purpose "to look prettier than YAML"
tags "ruby", "configuration", "dsl"
```

Add this method to the above class to load it:

```ruby
class MyClass

  def configure_from_file config_file
    instance_eval File.read(config_file), config_file
  end
end
```

See [*Ruby DSLs: instance_eval with delegation*][ruby-dsls] for a more complete
take on this. Take look at [Ruby's `BasicObject` class][ruby-instance-eval] for
the original documentation.

[ruby-dsls]: http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
[ruby-instance-eval]: http://ruby-doc.org/core-1.9.3/BasicObject.html#method-i-instance_eval
