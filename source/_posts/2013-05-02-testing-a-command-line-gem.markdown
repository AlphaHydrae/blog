---
layout: post
title: "Testing a command-line gem"
date: 2013-05-02 19:12
comments: true
categories: [ruby,testing,commander,cli]
---

I've written many ruby gems that have binaries, generally with [commander](git://github.com/visionmedia/commander.git) for the command-line interface.
I was trying to increase the test coverage on those gems when I realized that it's tricky to test the parts are integrated with commander.

This is what a common commander setup looks like:

```rb
require 'rubygems'
require 'commander/import'

program :name, 'Foo Bar'
program :version, '1.0.0'
program :description, 'Stupid command that prints foo or bar.'

command :foo do |c|
  # ...
end
```

Requiring that file from your gem's binary does the trick.

```rb
#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'program')
```

Outstanding.

The main problem for testing is that this is meant for automatic execution.
The `commander/import` require runs commander on exit as soon as it's finished loading the file.
But for testing, you want to run commander in a test, not when the file is required.
And you definitely don't want to have to play with un-requiring files to run it multiple times.

<!-- more -->

What you need is to have the commander program available as an object that you can test at will with any arguments.
To achieve that, I looked at what `commander/import` does:

```rb
require 'commander'
require 'commander/delegates'

include Commander::UI
include Commander::UI::AskForClass
include Commander::Delegates

# ...

at_exit { run! }
```

What `Commander::Delegates` does is forward most commander methods (e.g. `program`, `command`) to a singleton `Commander::Runner` instance.
So let's do the same thing with a runner of our own.

```rb
require 'commander'

module FooBar
  
  class Program < Commander::Runner

    include Commander::UI
    include Commander::UI::AskForClass
    # no need to include Commander::Delegates, as we're a Commander::Runner already

    def initialize argv = ARGV
      super argv

      program :name, 'Foo Bar'
      program :version, '1.0.0'
      program :description, 'Stupid command that prints foo or bar.'

      command :foo do |c|
        # ...
      end
    end
  end
end
```

You can now test your commander program to your heart's content.

```rb
# test result
program = FooBar::Program.new custom_args
program.run!
expect(File.exists?('some file')).to be_true

# test errors
program = FooBar::Program.new bad_args
expect{ program.run! }.to raise_error(FooBar::Error)

# test output
program = FooBar::Program.new custom_args

stdout, stderr = StringIO.new, StringIO.new
$stdout, $stderr = stdout, stderr
program.run!
$stdout, $stderr = STDOUT, STDERR

expect(stdout.string.chomp("\n")).to eq('some output')
expect(stderr.string).to be_empty
```

Note that your binary must now run the commander program.

```rb
#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'foo_bar', 'program')
FooBar::Program.new.run!
```

Unfortunately that doesn't cover user interaction, but I don't know how to test that yet.
I will probably write another article when the time comes.
In the meantime, enjoy.

## Meta

* **Ruby:** 1.9.3 & 2.0.0
* **commander:** 4.1.3
