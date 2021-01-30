---
layout: post
title: "Capturing output in pure ruby"
date: 2013-09-26 21:12
comments: true
permalink: /:year/:month/:title/
categories: programming
tags: []
versions:
  ruby: 1.9.3 & 2.0.0
---

Rails has its own capture method but I've often needed to capture the output in
a Ruby script, mainly for unit testing purposes. It is pretty easy:

```rb
require 'stringio'

# redirect output to StringIO objects
stdout, stderr = StringIO.new, StringIO.new
$stdout, $stderr = stdout, stderr

# output is captured
puts 'foo'
warn 'bar'

# restore normal output
$stdout, $stderr = STDOUT, STDERR

stdout.string.match /foo/   #=> true
stderr.string.match /bar/   #=> true
```

<!-- more -->

I like to wrap this to make it a bit more practical:

```rb
require 'stringio'
require 'ostruct'

class Capture

  def self.capture &block

    # redirect output to StringIO objects
    stdout, stderr = StringIO.new, StringIO.new
    $stdout, $stderr = stdout, stderr

    result = block.call

    # restore normal output
    $stdout, $stderr = STDOUT, STDERR

    OpenStruct.new(
      result: result,
      stdout: stdout.string,
      stderr: stderr.string
    )
  end
end

c = Capture.capture do
  puts 'foo'
  warn 'bar'
end

c.stdout.match 'foo'   #=> true
c.stderr.match 'bar'   #=> true
```
