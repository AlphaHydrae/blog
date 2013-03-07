---
layout: post
title: "Conditional GET with Rails, jQuery and Redis"
date: 2013-03-07 12:30
comments: false
categories: [http,etag,rails,jquery,redis]
---

As mentionned in my [previous post](/2013/03/backbone-collection-304-not-modified), I've been using conditional requests in a [Rails](http://rubyonrails.org) app. To speed up things even more, I've also set up [Redis](http://redis.io) to cache the contents of those requests which avoids a hit on my SQL database. This post describes how I set it all up.

<!-- more -->

## Setting up Redis in a Rails app

Here's how I installed Redis on OS X with [MacPorts](http://www.macports.org). I'm sure your other favorite package manager has it as well.

{% codeblock lang:bash %}
sudo port install redis
sudo port load redis
{% endcodeblock %}

Add the following to your Gemfile and run `bundle install`.

{% codeblock lang:ruby Gemfile %}
gem 'redis'             # client library for Redis
gem 'hiredis'           # C extension for speed
gem 'redis-namespace'   # to namespace keys in Redis
{% endcodeblock %}

Here's an initializer for Redis inspired by the one from [Resque](https://github.com/defunkt/resque). It will load its configuration from `config/redis.yml`.

{% codeblock lang:ruby config/initializers/redis.rb %}
rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'

config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
config = config[rails_env]
host, port, db = config.split /:/

# The Redis connection.
# You can add "logger: Rails.logger" as an option
# if you want Redis operations logged like Active Record's.
$redis_db = Redis.new host: host, port: port, db: db.to_i, driver: :hiredis

# Wrap the connection in a namespace (if useful for you).
$redis = Redis::Namespace.new 'myapp', redis: $redis_db
{% endcodeblock %}

This is how the configuration file looks. Each line represents `environment: host:port:db`.

{% codeblock lang:yml config/redis.yml %}
development: localhost:6379:0
test: localhost:6379:1
production: localhost:6379:0
{% endcodeblock %}

Now you may connect to Redis on the command line with `redis-cli`, or use `$redis` in your application. The [Redis gem](https://github.com/redis/redis-rb) pretty much uses the same [commands](http://redis.io/commands) as Redis.

## Caching Contents with Redis

Now let's say I have a Rails action that looks like this.

{% codeblock lang:ruby %}
class PeopleController < ActionController::Base

  def show
    person = Person.where(id: params[:id]).includes(:lots, :of, :associated, :data).first
    render :json => person.to_json
  end
end
{% endcodeblock %}

The goal is to avoid loading the person and its associated data from the SQL database every time if it hasn't been modified. We want to store the resulting JSON and the last modification date in Redis so that we can quickly return a cached version. We will also generate an ETag which is a fingerprint of the cached contents.

{% codeblock lang:ruby %}
person = Person.where(id: params[:id]).includes(:lots, :of, :associated, :data).first

# Build cache data.
key = "person:#{person.id}"
updated_at = person.updated_at
json = person.to_json
etag = Digest::SHA2.hexdigest json

# Store the JSON and cache data in a Redis hash.
$redis.hmset key, :etag, etag, :updated_at, updated_at.to_i, :json, json
{% endcodeblock %}

When a person is modified, we must clear that cache.

{% codeblock lang:ruby %}
class Person < ActiveRecord::Base
  after_save :clear_cache

  def clear_cache
    $redis.del "person:#{id}"
  end
end
{% endcodeblock %}

This call will retrieve the cache hash from Redis.

{% codeblock lang:ruby %}
$redis.hgetall "person:#{params[:id].to_i}"
{% endcodeblock %}

## Conditional Request

Rails supports conditional requests out of the box with the `stale?` method. It will set the ETag and last modified header on the response and check them against the client request. If the request doesn't match, it should be generated from scratch, otherwise Rails will automatically return a 304 Not Modified.

Here's a complete example.

{% codeblock lang:ruby %}
require 'digest/sha2'

class PeopleController < ActionController::Base

  def show

    # Get the cached contents.
    cache = $redis.hgetall "person:#{params[:id].to_i}"

    # If that person isn't cached (Redis will return an empty hash),
    # load the person from the database and save the cache.
    cache = cache_person if cache.blank?

    # Parse the cache data.
    updated_at = Time.at(cache['updated_at'].to_i).utc
    etag = cache['etag']

    # Perform the conditional check.
    if stale? last_modified: updated_at, etag: etag

      # The request ETag or last modified date doesn't match what we have.
      # It's stale. Send the JSON with updated headers.
      render :json => cache['json']
    end

    # The request headers match. A 304 Not Modified will be sent.
  end

  private

  def cache_person

    person = Person.where(id: params[:id]).includes(:lots, :of, :associated, :data).first

    # Build cache data.
    key = "person:#{person.id}"
    updated_at = person.updated_at
    json = person.to_json
    etag = Digest::SHA2.hexdigest json

    # Store the JSON and cache data in a Redis hash.
    $redis.hmset key, :etag, etag, :updated_at, updated_at.to_i, :json, json

    # For simplicity, return the same hash Redis will return.
    { 'json' => json, 'updated_at' => updated_at.to_i, 'etag' => etag }
  end
end
{% endcodeblock %}

## Client

{% codeblock lang:javascript %}
{
        ifModified : true
              }
{% endcodeblock %}


    $redis.multi do
      $redis.hmset key, :etag, etag, :updated_at, updated_at.to_i, :json, json
      $redis.expire key, @options[:expire].to_i if @options[:expire]
    end
