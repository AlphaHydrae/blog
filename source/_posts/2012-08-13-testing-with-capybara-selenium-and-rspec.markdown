---
layout: post
title: "Testing with Capybara, Selenium and RSpec"
date: 2012-08-13 22:45
comments: true
categories: [capybara, selenium, rspec, testing]
---

This is a quick-and-dirty tutorial to set up automated browser tests with the following tools:

* [RSpec](https://www.relishapp.com/rspec/) is a Ruby behavior-driven development framework.
* [Capybara](https://github.com/jnicklas/capybara/) is an acceptance test framework that simulates how a real user would interact with your web app.
* [Selenium Webdriver](http://seleniumhq.org/) automates browsers like Firefox.

Since browser tests are generally isolated from the rest of your project, the language of the web app is irrelevant. I wrote this guide after setting up a test suite for a Node.js web app.

<!--more-->

## Installation

I assume here that you have already installed and set up Ruby exactly the way you like it. I recommend the excellent [RVM](https://rvm.io/) for that. I used Ruby 1.9.2 for this tutorial. You should also have a recent version of Firefox.

Let’s start by writing a Gemfile to install everything we need.

{% codeblock lang:ruby %}
# Location: Gemfile
 
source "http://rubygems.org"
 
# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'bundler'
  gem 'rake'
  gem 'rspec'
  gem 'capybara'
end
{% endcodeblock %}

If it’s not part of your Ruby setup already, run `gem install bundler`. This will install what you need to use the Gemfile. Once that’s done, simply run `bundle install` to download and install all the gems and their dependencies.

You should now have a new `Gemfile.lock` file that lists the exact versions of the gems that were installed.

## Configuration

We still need a few files in place before we can run tests.

I prefer to use [Rake](http://rake.rubyforge.org/) to run my tests. If you’re not in a Ruby on Rails project or using another framework that includes Rake, create a Rakefile:

{% codeblock lang:ruby %}
# Location: Rakefile
 
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
 
require 'rspec/core/rake_task'
desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  #t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end
 
task :default => :spec
{% endcodeblock %}

This sets up RSpec so that you can run your tests with `bundle exec rake spec` or `bundle exec rake` (default task). Note the `bundle exec` part which makes sure Rake is executed in the context of your installed gems, which will probably save you some trouble.

As indicated in the Rakefile comments, you can customize RSpec settings by adding a `.rspec` file. I like activating the following options so I have a nicely formatted test output and colors. Run `bundle exec rspec --help` if you want to know what other options you can tweak.

{% codeblock %}
# Location: .rspec
 
--color
--format doc
{% endcodeblock %}

The last configuration file we need is a spec helper so that we don’t have to require everything in each test file. The following one will do that quite nicely. Note at the end that we switch the Capybara driver to Selenium, as it’s not using that by default.

{% codeblock lang:ruby %}
# Location: spec/helper.rb
 
require 'rubygems'
require 'bundler'
 
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
 
require 'rspec'
require 'capybara/rspec'
 
Capybara.default_driver = :selenium
{% endcodeblock %}

## Writing Specs

I won’t explain here how to write specs with RSpec or Capybara. You’ll have to read their fine documentation ([RSpec](https://www.relishapp.com/rspec/rspec-core/docs), [Capybara](https://github.com/jnicklas/capybara/)). However, this is a bare-bones example you can use as a starting point:

{% codeblock lang:ruby %}
# Location: spec/dummy_spec.rb
 
require 'helper'
 
describe 'A useless blog', :type => :request do
 
  it "should at least work" do
    visit 'https://alphahydrae.com'
    page.should have_content('Alpha Hydrae')
  end
end
{% endcodeblock %}

And that’s pretty much it. Run `bundle exec rake spec` to run the test. This will run all `*_spec.rb` files in the spec directory. Firefox will magically open, load the required page and the contents will be checked.

## Meta

* **Ruby:** 1.9.2
* **Capybara:** 1.1.2
* **RSpec:** 2.11.0
* **Rake:** 0.9.2.2
* **Bundler:** 1.1.0
