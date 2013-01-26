---
layout: post
title: "Ruby Configuration DSL"
date: 2012-09-13 09:32
comments: false
categories: [ruby, dsl, patterns]
---

I had been wondering how that kind of Ruby magic works for some time.

{% codeblock lang:ruby %}
MyClass.new.configure do
  name "the best class"
  purpose "to kick ass"
  tags "ruby", "configuration", "dsl"
end
{% endcodeblock %}

<!--more-->

You have to be willing to use the nasty sounding `instance_eval` method. It's scary but trivial:

{% codeblock lang:ruby %}
def MyClass
 
  def configure &block
    # the block will be called with the MyClass instance as self
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
{% endcodeblock %}

Note that you can also make your own DSL configuration file (like unicorn) using the same technique:

{% codeblock lang:ruby %}
# Location: /my/project/config.rb
 
name "my configuration"
purpose "to look prettier than YAML"
tags "ruby", "configuration", "dsl"
{% endcodeblock %}

Add this method to the above class to load it:

{% codeblock lang:ruby %}
class MyClass
 
  def configure_from_file config_file
    instance_eval File.read(config_file), config_file
  end
end
{% endcodeblock %}

See [this article](http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation) for a more complete version. Take look at Ruby's [BasicObject](http://ruby-doc.org/core-1.9.3/BasicObject.html#method-i-instance_eval) for the original documentation.
