---
layout: post
title: "Conditional GET with Rails, Redis and jQuery"
date: 2013-03-07 22:01
comments: true
permalink: /:year/:month/:title/
categories: programming
tags: ruby ruby-on-rails redis jquery http etag
versions:
  ruby: 1.9.3
  ruby-on-rails: 3.2.12
  redis: 2.4.16
  jquery: 1.9.1
  hiredis-rb: 0.4.5
  redis-namespace: 1.1.0
---

As mentionned in my [previous post][previous-post], I've been using conditional
requests in a [Ruby on Rails][ruby-on-rails] app.

The principle of conditional requests is that when providing a resource, the
server will add cache control headers such as an [ETag][etag] (an identifier of
a version of the resource) in the [`ETag` header][etag-header], or the last
modification date of the resource in the [`Last-Modified`
header][last-modified-header].

When the client sends its next request, it can send the ETag and the last
modification date in the [`If-None-Match` header][if-none-match-header] and the
[`If-Modified-Since` header][if-modified-since-header]. The server will then
compare them to the latest values. If they match, the client has fresh data and
thus the server can just send a 304 Not Modified response with no content,
saving bandwidth. If the headers do not match, the server will send a normal
response with updated cache control information.

Note that there are other cache control parameters. Read the [HTTP GET method
definition][http-get-method] to learn more about them.

This post describes how I set up conditional requests in a Rails app, using
[Redis][redis] as a cache to speed up things even more by avoiding a costly hit
on my SQL database.

<!-- more -->

## Setting up Redis in a Rails app

```bash
# Install on Fedora 17
sudo yum install redis
sudo systemctl enable redis.service
sudo systemctl start redis.service

# Install on OS X 10.8 with MacPorts
sudo port install redis
sudo port load redis
```

Add the following to your Gemfile and run `bundle install`:

```ruby
# Client library for Redis.
gem 'redis'
# C extension for speed (optional).
gem 'hiredis'
# To namespace keys in Redis (optional).
gem 'redis-namespace'
```

Here's an initializer for Redis inspired by the one from [Resque][resque]. It
will load its configuration from `config/redis.yml`:

```ruby
# File: config/initializers/redis.rb
rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'

config = YAML.load_file "#{rails_root}/config/redis.yml"
config = config[rails_env]
host, port, db = config.split /:/

# The Redis connection.
# You can add "logger: Rails.logger" as an option
# if you want Redis operations logged like Active Record's.
$redis_db = Redis.new(
  host: host,
  port: port,
  db: db.to_i,
  driver: :hiredis
)

# Wrap the connection in a namespace (if useful for you).
$redis = Redis::Namespace.new 'myapp', redis: $redis_db
```

This is how the configuration file looks. Each line represents `environment:
host:port:db`.

```yml
# File: config/redis.yml
development: localhost:6379:0
test: localhost:6379:1
production: localhost:6379:0
```

Now you may connect to Redis on the command line with `redis-cli`, or use
`$redis` in your application. The [redis-rb gem][redis-rb] pretty much uses the
same [commands as Redis][redis-commands].

## Caching Contents and Cache Control Parameters

Now let's say I have a Rails action that looks like this.

```ruby
class PeopleController < ActionController::Base
  def show
    person = Person.where(id: params[:id])
      .includes(:lots, :of, :associated, :data)
      .first

    render :json => person.to_json
  end
end
```

The goal is to avoid loading the person and its associated data from the SQL
database every time if it hasn't been modified. We want to store the resulting
JSON and the last modification date in Redis so that we can quickly return a
cached version. We will also generate an ETag by hashing the JSON.

For the sake of example, I added the caching methods to the `Person` class. This
could be generalized for any active record model.

```ruby
require 'digest/sha2'

class Person
  after_save :clear_cache

  # Returns the cache for the person with the given ID.
  def self.cache id

    # Return existing cached data.
    cache = load_from_cache id
    return cache if cache.present?

    # Or load the data, then cache and return it.
    person = self.where(id: params[:id])
      .includes(:lots, :of, :associated, :data)
      .first

    person.save_to_cache
  end

  def save_to_cache

    # Build cache data.
    json = self.to_json
    etag = Digest::SHA2.hexdigest json

    # Store it in a Redis hash.
    $redis.hmset(
      cache_key,
      :json, json,
      :updated_at, updated_at.to_i,
      :etag, etag
    )

    # For simplicity, we use the same
    # return format as load_from_cache.
    {
      'json' => json,
      'updated_at' => updated_at.to_i,
      'etag' => etag
    }
  end

  private

  def self.load_from_cache id

    # Return the Redis hash.
    # This will return an empty hash if no data is cached.
    $redis.hgetall cache_key(id)
  end

  def self.cache_key id
    "#{self.name.underscore}:#{id}" # => "person:42"
  end

  def clear_cache
    $redis.del cache_key
  end

  def cache_key
    self.class.cache_key id
  end
end
```

## Conditional Request

Rails supports conditional requests out of the box with the `stale?` method. It
will set the ETag and last modified headers on the response and check them
against the request headers. If the headers don't match, the response should be
generated from scratch, otherwise Rails will automatically return a 304 Not
Modified.

```ruby
class PeopleController < ActionController::Base
  def show
    cache = Person.cache params[:id]

    # Parse the cache data.
    updated_at = Time.at(cache['updated_at'].to_i).utc
    etag = cache['etag']

    # Perform the conditional check.
    if stale? last_modified: updated_at, etag: etag

      # The request ETag or last modified date
      # doesn't match what we have. The client
      # cache is stale. Send the JSON with updated
      # headers.
      render :json => cache['json']
    end

    # The request headers match.
    # A 304 Not Modified will be sent.
  end
end
```

## jQuery Client

And that's my periodic call from the browser. On the first request,
[jQuery][jquery] will automatically get the ETag and last modified date from the
server and send them for the next requests. Nothing to do here.

```js
function pollPerson() {

  $.ajax({
    url : '/people/42',
    dataType : 'json',
    // The "ifModified" option makes it so that
    // the done callback is only called if the
    // response is not a 304 Not Modified.
    ifModified : true
  }).done(function(response) {
    doStuffWith(response);
  });
}

// Poll every 30 seconds.
setInterval(pollPerson, 30000);
```

## Cache Auto-Expiration

If you prefer to expire your cache after a certain time rather than with or in
addition to the `after_save` callback, you can tell Redis to do that:

```ruby
# Wrap it in a multi block for faster execution.
$redis.multi do
  $redis.hmset(
    cache_key,
    :json, json,
    :updated_at, updated_at.to_i,
    :etag, etag
  )

  $redis.expire cache_key, 1.day.to_i
end
```

Go cache in peace.

[etag]: http://en.wikipedia.org/wiki/HTTP_ETag
[etag-header]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag
[http-get-method]: https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.3
[if-modified-since-header]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since
[if-none-match-header]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None-Match
[jquery]: https://jquery.com
[last-modified-header]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Last-Modified
[previous-post]: /2013/03/backbone-collection-304-not-modified
[redis]: http://redis.io
[redis-commands]: http://redis.io/commands
[redis-rb]: https://github.com/redis/redis-rb
[resque]: https://github.com/defunkt/resque
[ruby-on-rails]: http://rubyonrails.org
