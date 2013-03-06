---
layout: post
title: "Conditional GET with Rails, jQuery and Redis"
date: 2013-03-07 12:30
comments: false
categories: [http,etag,rails,jquery,redis]
---

As mentionned in my [previous post](/2013/03/backbone-collection-304-not-modified), I've been using conditional requests in a Rails app. To speed up things even more, I've also set up Redis to cache the contents of those requests which avoids a database hit. This post describes how to set up Redis, Rails and a jQuery AJAX call to do that. This post describes how I set it all up.

<!-- more -->

## Setting up Redis

Add the following gems and `bundle install`.

{% codeblock lang:ruby Gemfile %}
gem 'redis'             # client library for Redis
gem 'hiredis'           # C extension for speed
gem 'redis-namespace'   # to namespace keys in Redis
{% endcodeblock %}

{% codeblock lang:ruby config/initializers/redis.rb %}
rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'
config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
config = config[rails_env]

host, port, db = config.split /:/

$redis_db = Redis.new host: host, port: port, db: db.to_i, driver: :hiredis #, logger: Rails.logger
$redis = Redis::Namespace.new 'rox', redis: $redis_db
{% endcodeblock %}

{% codeblock lang:yml config/redis.yml %}
development: localhost:6379:0
test: localhost:6379:1
production: localhost:6379:0
{% endcodeblock %}

## Caching Contents with Redis

{% codeblock lang:ruby %}
$redis.multi do
        key = complete_key @key
        $redis.hmset key, :etag, @etag, :updated_at, @updated_at.to_i, :contents, @contents
        $redis.expire key, @options[:expire].to_i if @options[:expire]
      end

require 'digest/sha2'
Digest::SHA2.hexdigest "#{@updated_at.to_i} #{@contents}"
{% endcodeblock %}

## Conditional Request

{% codeblock lang:ruby %}
$redis.hgetall(complete_key(@key)).each_pair{ |k,v| send("#{k}=", v) }
stale? last_modified: cache.updated_at.utc, etag: cache.etag
{% endcodeblock %}

## Client

{% codeblock lang:javascript %}
{
        ifModified : true
              }
{% endcodeblock %}
