---
layout: post
title: "Rails 3 logger customization"
date: 2013-02-08 17:30
comments: true
permalink: /:year/:month/:title/
categories: programming
tags: logging
versions:
  ruby: 1.9.3
  ruby-on-rails: 3.x
---

Rails logging is pretty good but sometimes you need to tweak it a bit. In the
app I'm currently working on, clients frequently send JSON payloads of up to 100
kilobytes to a Rails app. Since Rails logs the request body, the log file was
cluttered and quickly growing beyond what the operations people would be
comfortable with. I also couldn't filter it out with the `filter_parameters`
configuration, as it wasn't a parameter but the body of the request.

<!-- more -->

I found out that it's not easy to silence parameters logging specifically, as
that occurs outside of the controller.

```ruby
# Silencing a controller action
class ApiController < ApplicationController
  around_filter :silence_logs, :only => :process_payload

  def process_payload
    # ...
  end

  private

  def silence_logs
    Rails.logger.silence do
      yield
    end
  end
end
```

This will silence any logs produced by the `process_payload` action, such as
active record query logs. But I was still getting those request logs:

```
Processing ApiController#process_payload (for 127.0.0.1 at 2013-02-08 11:52:54) [POST]
  Parameters: ["very", "big", "json", "payload", "filling", "the", "log", "file"]
Completed in 0.01224 (81 reqs/sec) | 202 Accepted [http://localhost/api/payload]
```

These logs are produced by a [LogSubscriber][rails-log-subscriber] which
attaches itself to action controller. I haven't found a way to unsubscribe or
replace it for a specific controller action, so I had to find another way.

Then I found the [silencer gem][silencer] which allows you to completely silence
logs for given URL patterns. That's pretty nifty, but I didn't want to disable
my warning or error logs so I couldn't use it.

## The Final Solution

In the end, I combined a few things to solve my logging problem. This is an
adapted version of the logger from the silencer gem (all credit to [Steve
Agalloco][stve]) that will set the log level to `WARN`.

```ruby
# File: lib/api_logger.rb
require 'rails/rack/logger'
require 'active_support/core_ext/array/wrap'

class ApiLogger < Rails::Rack::Logger

  def initialize app, *taggers
    @app = app
    opts = taggers.extract_options!
    @taggers = taggers.flatten
    @silence = Array.wrap(opts[:silence])
  end

  def call(env)
    old_logger_level = Rails.logger.level
    if silence_request?(env)
      Rails.logger.level = ::Logger::WARN
    end
    super
  ensure
    # Return back to previous logging level
    Rails.logger.level = old_logger_level
  end

  private

  def silence_request?(env)
    env['X-SILENCE-LOGGER'] ||
      @silence.any?{ |s| s === env['PATH_INFO'] }
  end
end
```

The idea is to replace the default Rack logger with this one, and to silence
only the URL that will receive the large request body.

```ruby
# File: config/application.rb
require './lib/api_logger'

module MyApp
  class Application < Rails::Application

    # ...

    # Set log level to WARN for API payload processing.
    config.middleware.swap Rails::Rack::Logger,
      ApiLogger, :silence => [%r{^/api/payload}]
  end
end
```

This solved the immediate problem of the main log file growing, and without
suppressing warning and error logs. However, I had lost the ability to debug
errors in the JSON payloads, so I decided to still log them but in a separate
log file which I would rotate to avoid size issues.

```ruby
# File: config/initializers/logs.rb
payload_log_file = File.join(
  Rails.root,
  "log",
  "payload.#{Rails.env}.log"
)

$payload_logger = Logger.new(
  payload_log_file,
  # Keep ten 1MB files.
  10, 1048576
)
```

As shown above, the [Ruby's basic `Logger`][ruby-logger] will handle rotation
quite nicely. Then all I had to do was to use that logger in my processing
action.

```ruby
# Action with customized logs
class ApiController < ApplicationController
  # /api/payload log level set to WARN in config/application.rb

  def process_payload
    payload = request.body.read

    bytes = payload.bytesize
    time_received = Time.now
    $payload_logger.info(
      "\nReceived payload (#{bytes}B) at #{time_received}"
    )

    $payload_logger.info payload

    # ... validate payload ...
    # ... put payload in processing queue ...

    duration = Time.now - time_received
    $payload_logger.info(
      "Accepted payload for processing in #{duration}s"
    )

    render :text => nil, :status => :accepted # HTTP 202 Accepted
  end
end
```

The JSON payload is now confined to the separate log file, leaving the main log
file uncluttered at the `INFO` log level.

[rails-log-subscriber]: https://github.com/rails/rails/blob/v3.2.11/actionpack/lib/action_controller/log_subscriber.rb
[ruby-logger]: http://www.ruby-doc.org/stdlib-1.9.3//libdoc/logger/rdoc/Logger.html
[silencer]: https://github.com/stve/silencer
[stve]: https://github.com/stve
